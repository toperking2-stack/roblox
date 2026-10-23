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
player.Name,player.UserId,player.Parent='TestPlayer',42,services.Players
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
-- New detailed collectibles are composed of rounded parts, not a single block.
assert(#named('Палочки'):GetDescendants()>=3,'branched sticks')
assert(#named('Морковка'):GetDescendants()>=15,'tapered carrot and leaves')
assert(#named('Ведёрко'):GetDescendants()>=45,'hollow bucket walls, rim and handle')
for _,o in objects do
 if o.ClassName=='Sound' then assert(o.SoundId~='rbxasset://sounds/impact_water.mp3','watery hit effect removed') end
end
-- A second recipe must preserve the first snowman; removal only removes that figure.
for _,name in {'Палочки','Морковка','Ведёрко'} do interact(named(name)) end
interact(named('Заготовка снежного кома'))
defaultRayHit={Instance=snowGround,Position=Vector3.zero,Normal=Vector3.new(0,1,0)}
advance(0.1)
for _=1,36 do root.Position+=Vector3.new(2,0,0) advance(0.1) end
interact(station)
assert(#builtByPlayer[player]==2 and builtByPlayer[player][1].Parent,'second snowman preserves first')
local first=builtByPlayer[player][1]
interact(first.PrimaryPart)
assert(#builtByPlayer[player]==1 and builtByPlayer[player][1].Parent,'individual snowman removal')
defaultRayHit=nil
-- Deer follow a route; Father Frost opens dialogue only after close interaction.
assert(#reindeer==4,'four reindeer')
local deerBefore=reindeer[1].model:GetPivot().Position
advance(1)
assert((reindeer[1].model:GetPivot().Position-deerBefore).Magnitude>0.05,'reindeer move along woodland routes')
interact(santa)
assert(player:GetAttribute('SantaGreeting')==1,'Father Frost dialogue trigger')
-- Ice is above snow, unshod players fall and recover; the rack equips visible blades.
assert(pond.Position.Y-pond.Size.Y/2>0,'ice surface is not buried under snow')
root.Position=Vector3.new(-105,5,75)
advance(0.1)
assert(humanoid.PlatformStand,'without skates player slips')
advance(1.2)
assert(humanoid.PlatformStand==false,'slip recovers control')
for _,side in {'Left','Right'} do
 local foot=Instance.new('Part') foot.Name,foot.Parent=side..'Foot',character foot.Position=root.Position
end
interact(rack)
assert(player:GetAttribute('SkatesEquipped')==true,'rack equips skates')
local firstSkateColor=character:FindFirstChild('SkateGear'):GetAttribute('ColorIndex')
assert(character:FindFirstChild('SkateGear'):FindFirstChild('Подошва конька'),'skates include soles')
assert(character:FindFirstChild('SkateGear'):FindFirstChild('Высокий манжет'),'skates include raised cuffs')
root.Position=Vector3.new(-105,5,75)
advance(0.5)
assert(humanoid.PlatformStand==false,'skates prevent slipping')
interact(rack)
assert(player:GetAttribute('SkatesEquipped')==false and not character:FindFirstChild('SkateGear'),'rack unequips gear')
-- A forced escape from the ice cannot leave walking disabled or skates equipped.
interact(rack)
root.Position=Vector3.new(-105,5,75)
advance(0.15)
root.Position=Vector3.new(-70,5,75)
humanoid.WalkSpeed=0 humanoid.PlatformStand=true
advance(0.15)
assert(player:GetAttribute('SkatesEquipped')==false,'leaving rink automatically removes skates')
assert(humanoid.WalkSpeed==16 and humanoid.AutoRotate and not humanoid.PlatformStand,'walking recovers after forced rink exit')
assert(named('Бортик катка').Size.Y>=4,'rink has a high fence')
-- Exactly two animal actions remain; faster wandering picks noncircular destinations.
local deer=reindeer[1]
local actions=0
for _,p in deer.model.PrimaryPart:GetChildren() do if p.ClassName=='ProximityPrompt' then actions+=1 end end
assert(actions==2,'deer only exposes pet and hitch actions')
interact(deer.model.PrimaryPart,'Погладить оленя')
assert(deer.petUntil>os.clock(),'pet pauses deer and creates feedback')
local parked=tourSleds[1]
parked:PivotTo(CFrame.new(deer.model.PrimaryPart.Position+Vector3.new(6,-1.5,5)))
interact(deer.model.PrimaryPart,'Прицепить / отцепить ближайшие санки')
assert(deer.tow and deer.tow:GetAttribute('TowedBy')==deer.model.Name,'nearby sled is hitched')
interact(deer.model.PrimaryPart,'Прицепить / отцепить ближайшие санки')
assert(not deer.tow,'sled can be unhitched')
advance(3.2)
local beforeWander=deer.model:GetPivot().Position
advance(0.5)
assert((deer.model:GetPivot().Position-beforeWander).Magnitude>1,'deer moves faster between destinations')
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
workspace.CurrentCamera={CFrame=CFrame.new()}
local playerGui=Instance.new('Folder') playerGui.Name,playerGui.Parent='PlayerGui',player
local shoulder=Instance.new('Motor6D') shoulder.Name,shoulder.C0,shoulder.Parent='RightShoulder',CFrame.new(),character
humanoid.RigType=Enum.HumanoidRigType.R15
humanoid.WalkSpeed,humanoid.AutoRotate,humanoid.MoveDirection=16,true,Vector3.new(1,0,0)
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
services.RunService.PreSimulation:Fire(0.1)
assert(tea.Grip~=teaGripBefore,'tea grip animation changes the actual held-tool pose')
tea.Unequipped:Fire()
-- Four complete sessions reproduce entering, exiting and putting skates back on.
for cycle=1,4 do
 local previousColor=lastSkateColor[player]
 if cycle==2 then
  -- Simulate the legacy freeze, including an orphan force left on the character.
  local stale=Instance.new('BodyVelocity') stale.Name,stale.Parent='SkatingMomentum',root
  humanoid.WalkSpeed,humanoid.AutoRotate,humanoid.PlatformStand=0,false,true
 end
 interact(rack)
 assert(player:GetAttribute('SkatesEquipped'),'equip cycle '..cycle)
 assert(not root:FindFirstChild('SkatingMomentum'),'legacy force removed before re-equip')
 assert(humanoid.WalkSpeed>=16 and not humanoid.PlatformStand,'re-equip recovers fallen or frozen character')
 root.Position=Vector3.new(-105,5,75)
 humanoid.MoveDirection=Vector3.new(1,0,0)
 services.RunService.Heartbeat:Fire(0.1)
 local speed=Vector3.new(root.AssemblyLinearVelocity.X,0,root.AssemblyLinearVelocity.Z).Magnitude
 assert(speed>0,'movement input accelerates skates in cycle '..cycle)
 assert(not root:FindFirstChild('SkatingMomentum'),'skating creates no persistent force')
 local gear=assert(character:FindFirstChild('SkateGear'))
 assert(gear:GetAttribute('ColorIndex')~=previousColor,'random color differs from previous session')
 local iceEffects={}
 for _,effect in gear:GetDescendants() do
  if effect.ClassName=='Trail' or effect.ClassName=='ParticleEmitter' then
   table.insert(iceEffects,effect) assert(effect.Enabled,'moving skates show ice effects')
  end
 end
 assert(#iceEffects==4,'each skate has a trace and ice spray')
 humanoid.MoveDirection=Vector3.zero
 services.RunService.Heartbeat:Fire(0.1)
 local coast=root.AssemblyLinearVelocity.Magnitude
 assert(coast>0 and coast<speed,'release of input keeps a decaying glide')
 root.Position=Vector3.new(-70,5,75)
 services.RunService.Heartbeat:Fire(0.1)
 assert(not player:GetAttribute('SkatesEquipped') and not character:FindFirstChild('SkateGear'),'exit removes skates in cycle '..cycle)
 assert(humanoid.WalkSpeed==16 and humanoid.AutoRotate and not humanoid.PlatformStand,'exit restores walking in cycle '..cycle)
 assert(Vector3.new(root.AssemblyLinearVelocity.X,0,root.AssemblyLinearVelocity.Z).Magnitude==0,'exit clears residual horizontal glide')
 for _,effect in iceEffects do assert(not effect.Enabled,'ice effects stop outside rink') end
end
-- Dialogue buttons and music mute are connected, not decorative UI.
interact(santa)
local dialog=named('Frame')
assert(dialog.Visible,'Father Frost dialogue opens')
local muted=false
for _,o in objects do
 if o.ClassName=='TextButton' and o.Text=='♫ Музыка: вкл' then
  o.Activated:Fire() muted=true
 end
end
assert(muted and named('HolidayMusic').Volume==0,'background melody can be muted')
-- The emergency remove button is usable even when the player is away from the rack.
interact(rack)
root.Position=Vector3.new(0,5,0)
for _,o in objects do
 if o.ClassName=='TextButton' and o.Text=='Снять коньки • X' then o.Activated:Fire() end
end
assert(not player:GetAttribute('SkatesEquipped') and humanoid.WalkSpeed==16,'emergency skate removal restores walking anywhere')
return true
`;
 const full=prelude+'\n'+server+'\n'+assertions.replace('return #objects','')+'\n'+setupClient+'\ndo\n'+client+'\nend\n'+clientChecks;
 await state.loadstring(full,'client-server interaction regression',true)();
 console.log('Client/server regression passed: throws, tea, skating acceleration/coasting/exit, dialogue, music mute, four skating equip/exit cycles, legacy freeze recovery and two reindeer actions.');
} finally { state.destroy(); }
