// Usage: node tests/check-startup.mjs /absolute/path/to/luau-web/src/index.js
import fs from 'node:fs';
import {pathToFileURL} from 'node:url';
const {LuauState}=await import(pathToFileURL(process.argv[2]).href);
const server=fs.readFileSync(new URL('../src/server/init.server.luau',import.meta.url),'utf8');
const prelude=fs.readFileSync(new URL('./startup-mock.luau',import.meta.url),'utf8');
const assertions=`
local sleds,floors,fires,oldStages,targets=0,0,0,0,0
for _,o in objects do
 local name=o.Name
 if name=='Санки' then sleds+=1 end
 if name=='Пол домика' then floors+=1 assert(o.Position.Y==1.7, 'floor elevation') end
 if name=='Живой огонь' then fires+=1 end
 if string.match(name,'^Этап ') then oldStages+=1 end
 if name=='Мишень для снежков' then targets+=1 end
end
assert(sleds==3,'three sled rides')
assert(floors==4 and fires==4,'four raised interiors with open fires')
assert(oldStages==0,'old obby removed')
assert(targets==3,'snowball targets')
-- Fire the real registered prompt/remote callbacks using a mock player.
local function named(name)
 for _,o in objects do if o.Name==name then return o end end
 error('missing object '..name)
end
local player=Instance.new('Player')
player.Name,player.UserId='TestPlayer',42
local character=Instance.new('Model')
character.Name,character.Parent='Character',workspace
local root=Instance.new('Part')
root.Name,root.Parent='HumanoidRootPart',character
character.PrimaryPart=root
local humanoid=Instance.new('Humanoid')
humanoid.Health,humanoid.Parent=100,character
local backpack=Instance.new('Backpack')
backpack.Name,backpack.Parent='Backpack',player
player.Backpack,player.Character=backpack,character
local function interact(on,action)
 root.Position=on.Position+Vector3.new(0,3,0)
 for _,p in on:GetChildren() do
  if p.ClassName=='ProximityPrompt' and (not action or p.ActionText==action) then
   p.Triggered:Fire(player) return
  end
 end
 error('missing prompt '..on.Name)
end
local function count(name)
 local n=0 for _,o in objects do if o.Name==name then n+=1 end end return n
end
-- Distance validation rejects a remote prompt activation across the map.
root.Position=Vector3.new(190,3,170)
local pile=named('Гора снежков')
for _,p in pile:GetChildren() do if p.ClassName=='ProximityPrompt' then p.Triggered:Fire(player) end end
assert(not backpack:FindFirstChild('Снежки'),'pickup distance validation')
interact(pile)
local tool=assert(backpack:FindFirstChild('Снежки'),'snowball pickup')
assert(tool:FindFirstChild('Handle').CanQuery==false,'held snowball must not intercept aiming')
tool.Parent=character
local victim=Instance.new('Model') victim.Parent=workspace
local victimHumanoid=Instance.new('Humanoid') victimHumanoid.Health,victimHumanoid.Parent=100,victim
local hitPart=Instance.new('Part') hitPart.Parent=victim
nextRayHit={Instance=hitPart,Position=Vector3.new(-40,4,20),Normal=Vector3.new(0,1,0)}
local remote=named('ThrowSnowball')
remote.OnServerEvent:Fire(player,Vector3.new(-40,4,20))
assert(count('Летящий снежок')==1,'real server callback creates projectile')
remote.OnServerEvent:Fire(player,Vector3.new(-40,4,20))
assert(count('Летящий снежок')==1,'throw cooldown enforced')
advance(0.1)
assert(victimHumanoid.Health==85,'snowball hit causes exactly 15 damage')
assert(count('Место попадания')==1,'visible impact mark')
advance(1)
remote.OnServerEvent:Fire(player,Vector3.new(0/0,0,0))
assert(count('Летящий снежок')==1,'invalid target rejected')
tool.Parent=backpack
advance(1)
remote.OnServerEvent:Fire(player,Vector3.new(-40,4,20))
assert(count('Летящий снежок')==1,'unequipped throw rejected')
-- Gather all ingredients, grow a ball by walking on snow, consume them to build.
for _,name in {'Палочки','Морковка','Ведёрко'} do interact(named(name)) assert(player:GetAttribute(ingredientAttributes[name])) end
local station=named('Мастерская снеговиков')
interact(station)
assert(count('Снеговик TestPlayer')==0,'cannot build without a grown ball')
interact(named('Заготовка снежного кома'))
local snowGround=named('Снежный остров')
defaultRayHit={Instance=snowGround,Position=Vector3.zero,Normal=Vector3.new(0,1,0)}
advance(0.1)
for _=1,36 do root.Position+=Vector3.new(2,0,0) advance(0.1) end
assert(player:GetAttribute('SnowSize')>=4,'rolling grows with travelled distance')
interact(station)
assert(count('Снеговик TestPlayer')==1,'full recipe builds snowman')
assert(player:GetAttribute('SnowSize')==0,'ball consumed')
for _,name in {'Палочки','Морковка','Ведёрко'} do assert(player:GetAttribute(ingredientAttributes[name])==false,'ingredient consumed') end
defaultRayHit=nil
-- Complete a sled ride: no forced dismount, no reset, assembly is released with velocity.
local seat=named('Сиденье санок')
interact(seat)
advance(4)
assert(seat.Anchored==false,'sled released into physics after descent')
assert(seat.AssemblyLinearVelocity.Z==45,'sled retains runout momentum')
assert(seat.Occupant==humanoid and humanoid.Sit,'rider remains seated after descent')
seat.Occupant=nil humanoid.Sit=false
advance(1)
assert(seat.Anchored==false,'jumping does not remove or reset sled')
return #objects
`;
const state=await LuauState.createAsync();
try {
 const run=state.loadstring(prelude+'\n'+server+'\n'+assertions,'server construction test',true);
 const result=await run();
 console.log('Server construction passed:',result,'instances; 3 sleds, 4 raised floors, 4 fires, 3 targets, no obby.');
 const client=fs.readFileSync(new URL('../src/client/init.client.luau',import.meta.url),'utf8');
 state.loadstring(client,'client',true);
 console.log('Client compilation passed. Gameplay mock passed: pickup distance, throws, cooldown, damage, impact, snowman recipe and persistent sled runout.');
 const setupClient=`
services.Players.LocalPlayer=player
services.UserInputService.TouchEnabled=false
workspace.CurrentCamera={}
local playerGui=Instance.new('Folder') playerGui.Name,playerGui.Parent='PlayerGui',player
local shoulder=Instance.new('Motor6D') shoulder.Name,shoulder.C0,shoulder.Parent='RightShoulder',CFrame.new(),character
humanoid.RigType=Enum.HumanoidRigType.R15
`;
 const clientChecks=`
advance(2)
local before=count('Летящий снежок')
tool.Parent=character
root.Position=Vector3.new(-40,4,43)
tool.Activated:Fire()
assert(count('Летящий снежок')==before+1,'client Tool.Activated reaches server and spawns snowball')
interact(named('Стол с чаем'))
local tea=assert(backpack:FindFirstChild('Горячий чай'))
tool.Parent=backpack tool.Unequipped:Fire()
tea.Parent=character
local soundsBefore=0 for _,o in objects do if o.ClassName=='Sound' then soundsBefore+=1 end end
local teaGripBefore=tea.Grip
tea.Activated:Fire()
advance(0.4)
local soundsAfter=0 for _,o in objects do if o.ClassName=='Sound' then soundsAfter+=1 end end
assert(soundsAfter>soundsBefore,'tea sip schedules audible effect')
services.RunService.PreSimulation:Fire()
assert(tea.Grip~=teaGripBefore,'tea grip animation changes the actual held-tool pose')
tea.Unequipped:Fire()
return true
`;
 const full=prelude+'\n'+server+'\n'+assertions.replace('return #objects','')+'\n'+setupClient+'\ndo\n'+client+'\nend\n'+clientChecks;
 await state.loadstring(full,'client-server interaction regression',true)();
 console.log('Client/server regression passed: equipped tool activation throws; tea use schedules sound and animates grip.');
} finally { state.destroy(); }
