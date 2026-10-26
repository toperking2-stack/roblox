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
assert(#reindeer==8,'eight reindeer')
local deerBefore=reindeer[1].model:GetPivot().Position
advance(1)
assert((reindeer[1].model:GetPivot().Position-deerBefore).Magnitude<0.01,'unhitched deer waits by its sled')
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
assert((deer.model:GetPivot().Position-beforeWander).Magnitude<0.01,'unhitched deer keeps waiting')
-- Expanded map: connected routes reach far beyond each original meadow.
assert(named('Снежный остров').Size.X==1100 and named('Снежный остров').Size.Z==900,'expanded island size')
for _,animal in reindeer do
 local route=planDeerPath(animal.model:GetPivot().Position,deerRandom)
 assert(#route>3 and (route[#route]-animal.model:GetPivot().Position).Magnitude>100,'deer chooses a distant reachable goal')
 for i=2,#route do assert((route[i]-route[i-1]).Magnitude<=16.01,'route stays on connected grid') end
end
assert(#snowLounges==6,'six interactive snow lounges')
local lounge=snowLounges[1]
root.Position=lounge.zone.Position+Vector3.new(0,3,0)
root.AssemblyLinearVelocity=Vector3.new(0,-18,0)
lounge.zone.Touched:Fire(root)
assert(lounge.seats[1].Occupant==humanoid and humanoid.Sit,'jumping into drift seats player')
assert(lounge.puff.Emitted==35,'drift landing emits snow puff')
lounge.seats[1].Occupant=nil humanoid.Sit=false
interact(lounge.zone)
assert(lounge.seats[1].Occupant==humanoid,'drift can be used again after leaving')
lounge.seats[1].Occupant=nil humanoid.Sit=false
-- Companion flow: bag, feeding, leading and a visit to the hearth.
local companion=reindeer[1]
interact(companion.model:FindFirstChild('Мешочек с морковками'))
assert(player:GetAttribute('DeerCarrots')==8,'bag supplies eight carrots')
local carrotTool=assert(backpack:FindFirstChild('Морковка для оленя'))
carrotTool.Parent=character
root.Position=companion.model:GetPivot().Position+Vector3.new(0,2,2)
named('CarrotAction').OnServerEvent:Fire(player,'feed')
assert(player:GetAttribute('DeerCarrots')==7 and companion.leader==player,'feeding consumes carrot and starts following')
local beforeLeading=companion.model:GetPivot().Position
root.Position+=Vector3.new(14,0,0)
advance(1.3)
assert((companion.model:GetPivot().Position-beforeLeading).Magnitude>0.1,'companion follows the carrot holder')
-- Bring the deer to the front door, then exercise the actual entry stages.
companion.model:PivotTo(CFrame.new(-43,3.2,-3))
root.Position=Vector3.new(-43,5,-20)
carrotTool.Parent=backpack
advance(5)
assert(companion.visitRoom==1 and companion.entryStage==4,'companion enters the house through door stages')
assert((companion.model:GetPivot().Position-Vector3.new(-37.5,5.4,-26)).Magnitude<2,'companion waits near fireplace on raised floor')
interact(named('Стол с чаем'))
assert(backpack:FindFirstChild('Горячий чай'),'player can get tea while deer stays nearby')
carrotTool.Parent=character
root.Position=companion.model:GetPivot().Position+Vector3.new(0,1,2)
named('CarrotAction').OnServerEvent:Fire(player,'feed')
assert(player:GetAttribute('DeerCarrots')==6 and companion.chewUntil>os.clock(),'feeding works by the fireplace')
named('CarrotAction').OnServerEvent:Fire(player,'wait')
assert(not companion.leader and not player:GetAttribute('CompanionDeer'),'wait button releases companion at current place')
carrotTool.Parent=backpack
-- Alpine lift: wait for the local cabin, board, and actually travel to the top.
assert(#cabinSeats==4 and #mountainVehicles==4,'four-person cable car and four rental kinds')
assert(mountain.height==140,'large mountain elevation')
cabinTime=0 cableCar:PivotTo(CFrame.new(lowerStation))
local posts={}
for _,object in objects do if object.Name=='Посадка на фуникулёр' then table.insert(posts,object) end end
interact(posts[2])
assert(not cabinSeats[1].Occupant,'cannot board a cabin waiting at the other station')
interact(posts[1])
assert(cabinSeats[1].Occupant==humanoid,'cable car boarding')
advance(22)
assert((cabinFloor.Position-topStation).Magnitude<2,'cabin reaches summit')
cabinSeats[1].Occupant=nil humanoid.Sit=false
-- Two friends board the same mountain sled before either starts it.
local friend=Instance.new('Player') friend.Name,friend.Parent='Friend',services.Players
local friendCharacter=Instance.new('Model') friendCharacter.Parent=workspace
local friendRoot=Instance.new('Part') friendRoot.Name,friendRoot.Parent='HumanoidRootPart',friendCharacter
friendCharacter.PrimaryPart=friendRoot
local friendHumanoid=Instance.new('Humanoid') friendHumanoid.Health,friendHumanoid.Parent=100,friendCharacter
friend.Character=friendCharacter
local sledRental=named('Прокат: Двухместные санки')
interact(sledRental)
friendRoot.Position=sledRental.Position+Vector3.new(0,3,0)
for _,p in sledRental:GetChildren() do if p.ClassName=='ProximityPrompt' and p.ActionText=='Взять: Двухместные санки' then p.Triggered:Fire(friend) end end
local alpineSled=mountainVehicles[1]
assert(alpineSled.seats[1].Occupant==humanoid and alpineSled.seats[2].Occupant==friendHumanoid,'two friends share mountain sled')
interact(alpineSled.model.PrimaryPart,'Начать спуск • F')
local inputControl=assert(mountainControls[player])
local initialSpeed=inputControl.speed
local originalX=alpineSled.model.PrimaryPart.Position.X
named('MountainControl').OnServerEvent:Fire(friend,Vector3.new(-1,-1,0))
assert(inputControl.steer==0,'passenger cannot override driver')
named('MountainControl').OnServerEvent:Fire(player,Vector3.new(1,1,0))
advance(0.3)
assert(inputControl.speed>initialSpeed and alpineSled.model.PrimaryPart.Position.X>originalX,'driver accelerates and steers')
local faster=inputControl.speed
named('MountainControl').OnServerEvent:Fire(player,Vector3.new(-1,-1,0))
advance(0.3)
assert(inputControl.speed<faster,'driver brakes')
advance(11)
assert(not alpineSled.model.PrimaryPart.Anchored and alpineSled.model.PrimaryPart.AssemblyLinearVelocity.Z==42,'mountain descent transitions to coasting')
assert(alpineSled.seats[1].Occupant==humanoid and alpineSled.seats[2].Occupant==friendHumanoid,'both friends remain seated through descent')
alpineSled.seats[1].Occupant=nil alpineSled.seats[2].Occupant=nil humanoid.Sit=false friendHumanoid.Sit=false
-- Leaving standing equipment before starting must allow the next rental.
interact(named('Прокат: Лыжи'))
assert(mountainRiders[player] and humanoid.PlatformStand,'skis attach standing rider')
named('LeaveMountainRide').OnServerEvent:Fire(player)
assert(not mountainRiders[player] and not humanoid.PlatformStand and humanoid.WalkSpeed==16,'dismount restores movement')
interact(named('Прокат: Лыжи'))
assert(mountainRiders[player],'skis can be rented again after dismount')
named('LeaveMountainRide').OnServerEvent:Fire(player)
for _,sled in world:GetChildren() do
 if sled:IsA('Model') and (sled.Name=='Санки' or sled.Name=='Прогулочные санки') then
  assert(sled:FindFirstChild('Место друга'),'existing sled has friend seat')
 end
end
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
-- Tool activation really forwards carrot use from client to server.
advance(1)
local carrotTool=assert(backpack:FindFirstChild('Морковка для оленя'))
tea.Parent=backpack
carrotTool.Parent=character
root.Position=reindeer[1].model:GetPivot().Position+Vector3.new(0,1,2)
local foodBefore=player:GetAttribute('DeerCarrots')
carrotTool.Activated:Fire()
assert(player:GetAttribute('DeerCarrots')==foodBefore-1 and reindeer[1].leader==player,'client carrot tool feeds companion')
for _,o in objects do
 if o.ClassName=='TextButton' and o.Text=='Олень: ждать здесь' then o.Activated:Fire() end
end
assert(not reindeer[1].leader,'client wait button stops following')
carrotTool.Parent=backpack carrotTool.Unequipped:Fire()
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
interact(named('Прокат: Сноуборд'))
assert(mountainRiders[player],'snowboard equipped')
interact(mountainVehicles[4].model.PrimaryPart,'Начать спуск • F')
mockKeys[Enum.KeyCode.D],mockKeys[Enum.KeyCode.W]=true,true
services.RunService.Heartbeat:Fire(0.15)
assert(mountainControls[player].steer==1 and mountainControls[player].throttle==1,'keyboard forwards alpine steering and speed input')
mockKeys[Enum.KeyCode.D],mockKeys[Enum.KeyCode.W]=false,false
services.UserInputService.JumpRequest:Fire()
assert(not mountainRiders[player] and not humanoid.PlatformStand,'jump request exits snowboard and restores control')
return true
`;
 const full=prelude+'\n'+server+'\n'+assertions.replace('return #objects','')+'\n'+setupClient+'\nlocal function runClient()\n'+client+'\nend\nrunClient()\nlocal function runClientChecks()\n'+clientChecks+'\nend\nreturn runClientChecks()';
 await state.loadstring(full,'client-server interaction regression',true)();
 console.log('Client/server regression passed: throws, tea, skating acceleration/coasting/exit, dialogue, music mute, four skating equip/exit cycles, legacy freeze recovery, waiting deer, carrot bag/tool feeding, house visit, snow lounges, summit lift, two-person sled descent and repeated ski/snowboard dismount.');
} finally { state.destroy(); }
