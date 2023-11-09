const base64Chars =
  "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".split("");

for (let s = 12; s < 15; s++) {
  let set = [];
  for (let i = 0; i < 30; i++) {
    let result = crack(gen(s)).iterations;
    set.push(result);
    console.log(`Iteration ${i} done with ${result} attempts`);
  }
  console.log(`Key size ${s} averages ${findAverage(set)}`);
}

function findAverage(numbers: number[]): number {
  const sum = numbers.reduce((acc, num) => acc + num, 0);
  return sum / numbers.length;
}

export function gen(size: number) {
  let messageArray: number[] = [];
  for (let i = 0; i < 64; i++) {
    messageArray.push(Math.floor(Math.random() * size));
  }
  let key = shuffle(base64Chars.slice(0, size));
  let cipher = "";
  for (let index of messageArray) {
    cipher += key[index];
  }
  return {
    message: messageArray
      .map((index) => {
        return base64Chars[index];
      })
      .join(""),
    size,
    key: key.join(""),
    cipher,
  };
}

export function crack(data: {
  message: string;
  size: number;
  key: string;
  cipher: string;
}) {
  let iterations = 0;
  let deciphered = "";
  let key: string[] = [];
  while (deciphered != data.message) {
    iterations++;
    deciphered = "";
    key = shuffle(base64Chars.slice(0, data.size));
    for (let char of data.cipher.split("")) {
      deciphered += base64Chars[key.indexOf(char)];
    }
  }
  return {
    iterations,
    key: key.join(""),
  };
}

function shuffle(array: string[]) {
  for (let i = array.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [array[i], array[j]] = [array[j], array[i]];
  }
  return array;
}
