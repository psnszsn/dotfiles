#!/usr/bin/env -S deno run --allow-run

import { readLines, readStringDelim } from "https://deno.land/std/io/bufio.ts";

console.log("haha")

const cmd = Deno.run({
  cmd: ["pinentry-gnome3"], 
  stdout: "piped",
  stdin: "piped",
  stderr: "piped"
});

const encoder = new TextEncoder();
const decoder = new TextDecoder();

const contentBytes = encoder.encode("GETPIN\n");
await cmd.stdin.write(contentBytes);
await cmd.stdin.close();


let pass, reg;

for await (const line of readLines(cmd.stdout)) {
    if (/^OK/.test(line))
      console.log("read line", line);
    else if (/^ERR/.test(line))
        console.log("err")
    else if (reg=/^D (.+)/.exec(line)){
        pass=reg[1]
        // console.log(pass)
    }
      // console.log("read line", line);
}

cmd.close(); // Don't forget to close it

const db="/home/vlad/documents/Passwords.kdbx"

const kp = Deno.run({
  cmd: ["keepassxc-cli", "open", db], 
  stdout: "piped",
  stdin: "piped",
  stderr: "piped"
});

await kp.stdin.write(encoder.encode(pass+ "\n"));
console.log(1)
console.log(2)

console.log("waiting...");
// await new Promise(resolve => setTimeout(resolve, 1000));
let l = readStringDelim(kp.stdout, "> ")
let delim = (await l.next()).value;

async function readCommandResult(command){
  await kp.stdin.write(encoder.encode(command+"\n"));
  console.log(await readLines(kp.stdout).next())
  let c = (await readStringDelim(kp.stdout, "\n"+delim+"> ").next())
  return c.value;
}

let pws=(await readCommandResult("ls -Rf")).split("\n").filter(x=>x.slice(-1)!=="/")
console.log(pws)

const dmenu = Deno.run({
  cmd: ["bemenu"], 
  stdout: "piped",
  stdin: "piped",
});

await dmenu.stdin.write(encoder.encode(pws.join("\n")));
await dmenu.stdin.close()
// let selected = await readLines(kp.stdout).next()
let selected = await dmenu.output()
console.log(selected)

let pwd=(await readCommandResult("clip " + `${decoder.decode(selected)}`));

console.log(pwd)

// await new Promise(resolve => setTimeout(resolve, 1000));
kp.close();
