import assert from 'node:assert/strict';
import {readFileSync,readdirSync} from 'node:fs';
import {performance} from 'node:perf_hooks';
import {resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
const entry=resolve(process.env.VM_ENTRY??'/workspaces/tiny-stack-vm-01-run-20261122');
const kit=resolve(process.env.VM_KIT??'/tmp/tiny-stack-vm-01-run-20261122-kit');
const {execute}=await import(pathToFileURL(entry+'/main.ts'));
const {run}=await import(pathToFileURL(kit+'/program/generator/subject/vm.mjs'));

const start=performance.now();let checks=0;
const push=n=>[2,n&255,(n>>>8)&255,(n>>>16)&255,(n>>>24)&255];
function check(name,bytes,input=[],expected=null) {
  const code=Buffer.from(bytes),ins=Buffer.from(input);
  const actual=execute(code,ins),reference=run(code,ins);
  assert.equal(actual.exit,reference.exit,name+' exit');
  assert.deepEqual(actual.output,Buffer.from(reference.stdout),name+' stdout');
  if(expected){assert.equal(actual.exit,expected.exit,name+' independent exit');
    assert.deepEqual(actual.output,Buffer.from(expected.output??[]),name+' independent stdout');}
  checks++;
  return actual;
}
const c=(name,bytes,exit,output=[])=>check(name,bytes,[],{exit,output});
c('halt',[0],0);
c('fall through',[],9);
c('unknown opcode',[255],5);
c('underflow',[3],2);
c('overflow',Array.from({length:257},()=>[1,0]).flat(),3);
c('zero division',[1,9,1,0,0x13],4);
c('bad memory',[1,-1,0x40],6);
c('call overflow',[0x33,0,0],7);
c('empty return',[0x34],8);
c('step limit',[0x30,253,255],10);
c('output limit',[1,65,0x51,0x30,250,255],11,Buffer.alloc(65536,65));
c('keep output on trap',[1,88,0x51,255],5,[88]);
c('sign extended push8',[1,255,0x50,0],0,'-1');
c('exit low byte',[1,255,0x53],255);
c('multiply exact low bits',[...push(2147483647),...push(2147483647),0x12,0x50,0],0,'1');
c('divide overflow',[...push(-2147483648),1,255,0x13,0x50,0],0,'-2147483648');
c('remainder overflow',[...push(-2147483648),1,255,0x14,0x50,0],0,'0');
c('signed remainder',[1,249,1,3,0x14,0x50,0],0,'-1');
c('unsigned quotient',[1,255,1,2,0x15,0x50,0],0,'2147483647');
c('unsigned remainder',[1,255,1,2,0x16,0x50,0],0,'1');
c('unsigned compare',[1,255,1,0,0x22,0x50,0],0,'0');
c('shift negative count',[1,1,1,255,0x1c,0x50,0],0,'-2147483648');
c('shift count wrap',[1,255,1,32,0x1e,0x50,0],0,'-1');
c('arithmetic shift',[1,255,1,1,0x1d,0x50,0],0,'-1');
c('logical shift',[1,255,1,1,0x1e,0x50,0],0,'2147483647');
c('call return',[0x33,4,0,0,1,42,0x50,0x34],0,'42');
c('jump into immediate',[0x30,1,0,2,0],0);
c('jump below zero',[0x30,252,255],9);
c('jump past end',[0x30,0,0],9);
c('untaken invalid branch',[1,1,0x31,255,127,0],0);
c('taken invalid branch',[1,0,0x31,255,127,0],9);
c('store negative address',[1,42,1,255,0x41],6);
c('memory initialized',[1,0,0x40,0x50,0],0,'0');
c('memory last address',[1,42,...push(255),0x41,...push(255),0x40,0x50,0],0,'42');
check('input exhausted repeatedly',[0x52,0x50,0x52,0x50,0x52,0x50,0],[128],{exit:0,output:'128-1-1'});
for(const op of [1,2,0x30,0x31,0x32,0x33]) {
  const width=op===1?1:op===2?4:2;
  for(let len=0;len<width;len++)c('truncated '+op+'/'+len,[op,...Array(len).fill(0)],9);
}
// Immediate truncation precedes stack checks; underflow precedes an opcode's own trap.
c('truncated branch before underflow',[0x31],9);
c('memory underflow before address',[1,255,0x41],2);
for(const op of [0x13,0x14,0x15,0x16])c('division underflow '+op,[1,0,op],2);
c('DUP overflow', [...Array.from({length:256},()=>[1,1]).flat(),4],3);
c('OVER overflow', [...Array.from({length:256},()=>[1,1]).flat(),6],3);
c('IN overflow', [...Array.from({length:256},()=>[1,1]).flat(),0x52],3);
// A bounded counter loop lands on an invalid PC at instruction 1,000,000.
// Step limit wins over invalid PC on the next iteration.
const limitProgram=[...push(249999),1,1,0x11,4,0x32,249,255,3,1,1,0x30,255,127];
c('step versus invalid target',limitProgram,10);
// Build large outputs with a loop, then try an atomic multi-byte PRINT.
const atomic=[...push(65535),1,65,0x51,1,1,0x11,4,0x32,246,255,3,1,10,0x50,0];
c('PRINT writes no partial bytes at cap',atomic,11,Buffer.alloc(65535,65));
const values=[0,1,-1,2,-2,31,32,33,-32,-33,2147483647,-2147483648,65535,65536];
for(const op of [0x10,0x11,0x12,0x13,0x14,0x15,0x16,0x18,0x19,0x1a,0x1c,0x1d,0x1e,0x20,0x21,0x22])
 for(const a of values)for(const b of values)check('arithmetic '+op+'/'+a+'/'+b,[...push(a),...push(b),op,0x50,0]);
let seed=0xc0712026;
const rand=()=>{seed^=seed<<13;seed^=seed>>>17;seed^=seed<<5;return seed>>>0;};
const operations=[3,4,5,6,7,0x10,0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1a,0x1b,0x1c,0x1d,0x1e,0x20,0x21,0x22,0x40,0x41,0x50,0x51,0x52];
for(let n=0;n<1500;n++) {
 const bytes=[];
 for(let j=0;j<80;j++) {
  if(rand()%3===0)bytes.push(...push(rand()|0));
  else bytes.push(operations[rand()%operations.length]);
 }
 bytes.push(0);check('seeded instruction stream '+n,bytes,Array.from({length:16},()=>rand()&255));
}
for(let n=0;n<500;n++)check('seeded raw bytecode '+n,Array.from({length:rand()%96},()=>rand()&255));
// Valid, deep executions exercise effects rather than ending at early underflow.
for(let n=0;n<500;n++) {
 const bytes=[];
 for(let j=0;j<30;j++) {
  const value=rand()|0,addr=rand()&255;
  bytes.push(...push(value),...push(addr),0x41,...push(addr),0x40);
  bytes.push(...push(rand()|0),[0x10,0x12,0x1a,0x1e,0x22][rand()%5],0x50);
  // CALL a short subroutine which reads input and returns, then jump over it.
  const callAt=bytes.length,target=callAt+6;
  bytes.push(0x33,target&255,target>>>8,0x30,3,0,0x52,0x51,0x34);
 }
 bytes.push(0);check('seeded memory arithmetic and calls '+n,bytes,[0,128,255]);
}
for(const op of [0x40,0x41])for(const addr of [-2147483648,-1,0,1,255,256,2147483647])
 check('memory bounds '+op+'/'+addr,[...(op===0x41?push(42):[]),...push(addr),op,0]);
const practice=kit+'/practice/input/';
for(const id of readdirSync(practice).sort()) {
 const code=readFileSync(practice+id+'/program.bin'),input=readFileSync(practice+id+'/input.bin');
 const a=check('practice '+id,code,input),b=execute(code,input);
 assert.equal(a.exit,b.exit);assert.deepEqual(a.output,b.output);
}
console.log(JSON.stringify({checks,seed:'0xc0712026',practice:40,determinism:true,elapsed_ms:Math.round(performance.now()-start),rss_bytes:process.memoryUsage().rss}));
