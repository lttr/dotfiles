const zsh = Deno.run({
  cmd: ["which", "zsh"],
  stdout: "null",
  stderr: "null"
});

const success = (await zsh.status()).success;
console.log();
