const std = @import("std");
const crypto = @import("std").crypto;

const MESSAGE = [_]u8{ 0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99, 0xaa, 0xbb, 0xcc, 0xdd, 0xee, 0xff };

fn genKey(keySize: u8) [32]u8 {
    var buffer = [_]u8{0x00} ** 32;
    crypto.random.bytes(buffer[32 - keySize ..]);
    return buffer;
}

const GenRes = struct { key: [32]u8, cipher: [16]u8 };

fn gen(keySize: u8) GenRes {
    const key = genKey(keySize);
    var ctx = crypto.core.aes.Aes256.initEnc(key);
    var cipher = [_]u8{0x00} ** 16;
    ctx.encrypt(cipher[0..], MESSAGE[0..]);
    return GenRes{ .key = key, .cipher = cipher };
}

fn crack(cipher: [16]u8, keySize: u8) usize {
    var attempts: usize = 0;

    var decrypted = [_]u8{0x00} ** 16;

    while (!std.mem.eql(u8, &decrypted, &MESSAGE)) : (attempts += 1) {
        decrypted = undefined;
        var key: [32]u8 = genKey(keySize);
        var ctx = crypto.core.aes.Aes256.initDec(key);
        ctx.decrypt(decrypted[0..], cipher[0..]);
    }

    return attempts;
}

pub fn maint() void {
    std.debug.print("{}", .{gen(1)});
}

pub fn main() void {
    var size: u8 = 1;
    while (size < 12) {
        var totalAttempts: usize = 0;
        var i: u8 = 0;
        while (i < 30) {
            const generated = gen(size);
            var attempts = crack(generated.cipher, size);
            totalAttempts += attempts;
            std.debug.print("Iteration {} done with {} attempts\n", .{ i, attempts });
            i += 1;
        }
        std.debug.print("Key size {} averages {}\n", .{ size, totalAttempts / 30 });
        size += 1;
    }
}
