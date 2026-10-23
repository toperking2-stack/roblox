// Usage: node tests/check-startup.mjs /absolute/path/to/luau-web/src/index.js
import fs from 'node:fs';
import {pathToFileURL} from 'node:url';
const {LuauState}=await import(pathToFileURL(process.argv[2]).href);
const server=fs.readFileSync(new URL('../src/server/init.server.luau',import.meta.url),'utf8');
const prelude=fs.readFileSync(new URL('./startup-mock.luau',import.meta.url),'utf8');
const assertions=`
local sleds,floors,fires,oldStages,targets=0,0,0,0,0
for _,o in objects do
 local name=rawget(o,'Name') or ''
 if name=='Санки' then sleds+=1 end
 if name=='Пол домика' then floors+=1 assert(o.Position.Y==1.7, 'floor elevation') end
 if name=='Живой огонь' then fires+=1 end
 if string.match(name,'^Этап ') then oldStages+=1 end
 if name=='Мишень для снежков' then targets+=1 end
end
assert(sleds==3,'three sled rides')
assert(floors==2 and fires==2,'two raised interiors with open fires')
assert(oldStages==0,'old obby removed')
assert(targets==3,'snowball targets')
return #objects
`;
const state=await LuauState.createAsync();
try {
 const run=state.loadstring(prelude+'\n'+server+'\n'+assertions,'server construction test',true);
 const result=await run();
 console.log('Server construction passed:',result,'instances; 3 sleds, 2 raised floors, 2 fires, 3 targets, no obby.');
 const client=fs.readFileSync(new URL('../src/client/init.client.luau',import.meta.url),'utf8');
 state.loadstring(client,'client',true);
 console.log('Client compilation passed.');
} finally { state.destroy(); }
