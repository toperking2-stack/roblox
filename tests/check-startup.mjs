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
local function checkPhones()
 local roof=named('Сплошная крыша дома Леона')
 assert(roof.Size.X>=58 and roof.Size.Z>=50,'solid roof covers Leon house')
 interact(named('Телефон из подарка'))
 assert(backpack:FindFirstChild('Телефон'),'gift gives usable phone')
 local other=Instance.new('Player') other.Name,other.UserId,other.Parent='PhoneFriend',123,services.Players
 local otherCharacter=Instance.new('Model') otherCharacter.Parent=workspace other.Character=otherCharacter
 local otherRoot=Instance.new('Part') otherRoot.Name,otherRoot.Parent='HumanoidRootPart',otherCharacter
 local otherHumanoid=Instance.new('Humanoid') otherHumanoid.Health,otherHumanoid.Parent=100,otherCharacter
 local otherPack=Instance.new('Backpack') otherPack.Name,otherPack.Parent='Backpack',other other.Backpack=otherPack
 phoneState.give(other)
 local action=phoneState.remote
 action.OnServerEvent:Fire(player,'call',other.UserId)
 assert(player:GetAttribute('PhoneState')=='calling' and other:GetAttribute('PhoneState')=='incoming','two player call rings recipient')
 action.OnServerEvent:Fire(other,'accept')
 assert(player:GetAttribute('PhoneState')=='active' and other:GetAttribute('PhoneState')=='active','recipient accepts')
 advance(0.3) action.OnServerEvent:Fire(player,'say',2)
 assert(string.find(other:GetAttribute('PhoneLine'),'котиков'),'call delivers selected phrase')
 action.OnServerEvent:Fire(player,'hangup')
 assert(not phoneState.calls[player] and not phoneState.calls[other],'hangup clears both sides')
 advance(0.3) action.OnServerEvent:Fire(player,'call','Настя')
 assert(string.find(player:GetAttribute('PhoneLine'),'Макарошки'),'Nastya answers phone')
 action.OnServerEvent:Fire(player,'hangup')
 advance(0.3) action.OnServerEvent:Fire(player,'call',other.UserId)
 otherHumanoid.Health=0 services.RunService.Heartbeat:Fire(0.1)
 assert(not phoneState.calls[player] and not phoneState.calls[other],'death cleans pending call')
 interact(named('Леон'),'Подарить телефон')
 assert(not backpack:FindFirstChild('Телефон') and named('Леон'):GetAttribute('HasMobilePhone'),'phone can be gifted to Leon')
 interact(named('Телефон у Насти'))
 assert(backpack:FindFirstChild('Телефон'),'can get replacement phone')
 services.Players.PlayerRemoving:Fire(other) other.Parent=nil otherCharacter:Destroy()
end
checkPhones()
local function checkStorm()
 humanoid.MaxHealth=100
 assert(#stormState.doors==6,'all six houses have doors')
 local doorway=stormState.doors[1]
 assert(doorway.panel.CanCollide and not doorway.panel:GetAttribute('Open'),'door initially closed')
 interact(doorway.control)
 assert(not doorway.panel.CanCollide and doorway.panel:GetAttribute('Open'),'door opens from fixed control')
 root.Position=Vector3.new(0,4,50)
 local tv=named('Телевизор лимонного дома')
 assert(tv:GetAttribute('CatChannelEnabled'),'cats channel on by default')
 interact(tv)
 assert(not tv:GetAttribute('CatChannelEnabled'),'switch from cats to news')
 interact(tv)
 assert(tv:GetAttribute('CatChannelEnabled'),'switch back to cats')
 interact(named('Табличка подарка'))
 local lemons=assert(backpack:FindFirstChild('Лимоны'),'gift gives lemons')
 lemons.Parent=character humanoid.Health=70 lemons.Activated:Fire()
 assert(humanoid.Health==80 and lemons:GetAttribute('LemonsLeft')==7,'lemon heals and consumes one fruit')
 lemons.Activated:Fire() assert(lemons:GetAttribute('LemonsLeft')==7,'lemon eating cooldown')
 lemons.Parent=backpack humanoid.Health=100
 root.Position=stormState.poolCenter+Vector3.new(0,3,0)
 root.AssemblyLinearVelocity=Vector3.new(2,-5,3)
 services.RunService.Heartbeat:Fire(0.1)
 assert(root.AssemblyLinearVelocity.Y>0 and root.AssemblyLinearVelocity.X==2,'lemon pool buoyancy preserves horizontal movement')
 root.Position=Vector3.new(0,4,50) root.AssemblyLinearVelocity=Vector3.zero
 services.RunService.Heartbeat:Fire(0.1)
 assert(root.AssemblyLinearVelocity.Y==0,'leaving lemon pool stops buoyancy')
 interact(named('Папа'))
 assert(string.find(player:GetAttribute('WinterMessage'),'Папа Егор:'),'upstairs dad dialogue')
 interact(named('Посмотреть телевизор с папой'))
 assert(named('Посмотреть телевизор с папой').Occupant==humanoid,'watch TV beside dad')
 named('Посмотреть телевизор с папой').Occupant=nil humanoid.Sit=false
 assert(stormState.sheltered(Vector3.new(235,5,-345)),'lemon house shelter')
 interact(named('Леон'))
 assert(string.find(player:GetAttribute('WinterMessage'),'Леон:'),'Leona friend dialogue')
 assert(stormState.sheltered(Vector3.new(155,5,-340)),'Nastya ground floor shelter')
 assert(stormState.sheltered(Vector3.new(155,18,-340)),'Nastya second floor shelter')
 assert(not stormState.sheltered(Vector3.new(155,35,-340)),'roof is exposed')
 root.Position=Vector3.new(0,4,50)
 stormState.step(150)
 assert(workspace:GetAttribute('BlizzardActive'),'storm starts')
 assert(string.find(workspace:GetAttribute('StormForecast'),'Буря идёт'),'TV forecast reports storm')
 local before=humanoid.Health
 stormState.step(5)
 assert(humanoid.Health==before,'warning grace period')
 stormState.step(5)
 assert(humanoid.Health<before,'storm damages outside')
 root.Position=Vector3.new(0,4,-700)
 services.RunService.Heartbeat:Fire(0.1)
 assert(stormState.wave.PrimaryPart.Position.Y>0,'snow wave enters map during storm')
 assert(humanoid.Health<before-20,'snow wave has contact damage')
 root.Position=Vector3.new(155,5,-340)
 before=humanoid.Health stormState.step(1)
 assert(humanoid.Health==before,'indoors prevents storm damage')
 interact(named('Настя'))
 local pasta=assert(backpack:FindFirstChild('Макарошки'),'Nastya cooks pasta')
 pasta.Parent=character pasta.Activated:Fire()
 assert(humanoid.Health>before,'eating restores health')
 pasta.Parent=backpack
 interact(named('Саженец ёлки'))
 assert(player:GetAttribute('FirSaplings')==1,'collect storm sapling')
 local seedTool=assert(backpack:FindFirstChild('Посадить ёлочку')) seedTool.Parent=character
 root.Position=Vector3.new(155,5,-340) seedTool.Activated:Fire()
 assert(player:GetAttribute('FirSaplings')==1,'cannot plant inside house')
 for px=-300,250,25 do
  if stormState.planted>0 then break end
  root.Position=Vector3.new(px,3,-280) seedTool.Activated:Fire()
 end
 assert(stormState.planted==1 and player:GetAttribute('FirSaplings')==0,'plant consumes seed once')
 seedTool.Activated:Fire() assert(stormState.planted==1,'empty inventory cannot plant')
 seedTool.Parent=backpack
 stormState.step(79)
 assert(not workspace:GetAttribute('BlizzardActive'),'storm ends after ninety seconds')
 humanoid.Health=100
end
checkStorm()
local function checkSnowDrifts()
 local savedElapsed=stormState.elapsed
 local door=stormState.doors[6]
 local pile=stormState.piles[16]
 assert(pile.door==door,'lemon house has shared snow piles')
 stormState.active=true stormState.elapsed=20
 door.panel:SetAttribute('Open',false)
 local before=pile.amount stormState.accumulate(10)
 assert(pile.amount==before,'closed door prevents accumulation')
 door.panel:SetAttribute('Open',true)
 stormState.accumulate(40)
 assert(pile.amount>before and pile.snow.CanCollide,'open door builds collidable snow drift')
 stormState.active=false
 stormState.giveShovel(player)
 local shovel=assert(backpack:FindFirstChild('Лопата')) shovel.Parent=character
 root.Position=pile.base+Vector3.new(0,2,5)
 before=pile.amount shovel.Activated:Fire()
 assert(pile.amount==before-2.5,'player digs from outside')
 shovel.Activated:Fire() assert(pile.amount==before-2.5,'shovel cooldown blocks repeated instant clicks')
 local friend=Instance.new('Player') friend.Name,friend.UserId,friend.Parent='RescueFriend',456,services.Players
 local body=Instance.new('Model') body.Parent=workspace friend.Character=body
 local friendRoot=Instance.new('Part') friendRoot.Name,friendRoot.Position,friendRoot.Parent='HumanoidRootPart',root.Position,body
 local friendHumanoid=Instance.new('Humanoid') friendHumanoid.Health,friendHumanoid.Parent=100,body
 local pack=Instance.new('Backpack') pack.Name,pack.Parent='Backpack',friend friend.Backpack=pack
 stormState.giveShovel(friend)
 local friendShovel=pack:FindFirstChild('Лопата') friendShovel.Parent=body
 before=pile.amount friendShovel.Activated:Fire()
 assert(pile.amount==math.max(0,before-2.5),'second player clears same shared drift')
 root.Position=Vector3.new(0,4,50) advance(0.7)
 before=pile.amount shovel.Activated:Fire()
 assert(pile.amount==before,'cannot dig distant snow')
 services.Players.PlayerRemoving:Fire(friend) friend.Parent=nil body:Destroy()
 shovel.Parent=backpack door.panel:SetAttribute('Open',false)
 stormState.elapsed=savedElapsed
end
checkSnowDrifts()
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
assert(named('Снежный остров').Size.X==1800 and named('Снежный остров').Size.Z==1400,'expanded island size')
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
local function checkSpawnVehicles()
 assert(#spawnVehicles==5,'five spawn vehicles')
 assert(spawnVehicles[3].model.Name=='Снежный мотоцикл' and spawnVehicles[4].model.Name=='Мотоцикл BMW' and spawnVehicles[5].model.Name=='Снежная BMW','three requested new vehicles')
 local angle=math.atan(3.7/50)
 local lower=mountainApproach.Position.Y-1.85+0.15/math.cos(angle)
 local upper=mountainApproach.Position.Y+1.85+0.15/math.cos(angle)
 local slopeAtJoin=70-(140+35)*140/360+2/math.cos(slopeAngle)
 assert(math.abs(lower-0.4)<0.05 and math.abs(upper-slopeAtJoin)<0.1,'approach meets runout and main slope without a step')
 -- Verify physical connectivity, rather than just a model grouping.
 for _,piece in santaModel:GetDescendants() do
  if piece:IsA('BasePart') and piece~=santa then
   assert(not piece.Anchored,'Father Frost detail belongs to root assembly')
   local connected=false
   for _,joint in piece:GetChildren() do
    if joint:IsA('WeldConstraint') and joint.Part0==santa and joint.Part1==piece then connected=true end
   end
   assert(connected,'Father Frost body detail welded to torso')
  end
 end
 local snowmobile=spawnVehicles[1]
 interact(snowmobile.driver,'Водитель: сесть')
 assert(groundDrivers[player]==snowmobile,'driver gains ground vehicle authority')
 friendRoot.Position=snowmobile.passenger.Position+Vector3.new(0,3,0)
 for _,prompt in snowmobile.passenger:GetChildren() do if prompt:IsA('ProximityPrompt') then prompt.Triggered:Fire(friend) end end
 assert(snowmobile.driver.Occupant==humanoid and snowmobile.passenger.Occupant==friendHumanoid,'two people share snowmobile')
 named('GroundVehicleControl').OnServerEvent:Fire(friend,Vector3.new(1,1,0))
 assert(snowmobile.throttle==0,'passenger cannot drive')
 named('GroundVehicleControl').OnServerEvent:Fire(player,Vector3.new(0.5,1,0))
 advance(0.3)
 assert(snowmobile.speed>0 and snowmobile.yaw~=0,'snowmobile accelerates and turns')
 assert(snowmobile.drive.MaxForce.X>0 and snowmobile.drive.MaxForce.Y==0 and snowmobile.drive.Velocity.Magnitude>0,'physics drive maintains horizontal traction with driver and passenger')
 named('GroundVehicleControl').OnServerEvent:Fire(player,Vector3.new(1,1,0),true)
 advance(0.3)
 assert(snowmobile.model:GetAttribute('Drifting') and snowmobile.spray.Enabled,'drift creates a snow plume')
 local forward=Vector3.new(-math.sin(snowmobile.yaw),0,-math.cos(snowmobile.yaw))*snowmobile.speed
 assert((snowmobile.velocity-forward).Magnitude>0.5,'drift retains lateral momentum instead of snapping to heading')
 named('GroundVehicleControl').OnServerEvent:Fire(player,Vector3.new(0,0,0),false)
 advance(0.1)
 assert(not snowmobile.model:GetAttribute('Drifting'),'release of drift restores grip')
 local speed=snowmobile.speed
 named('GroundVehicleControl').OnServerEvent:Fire(player,Vector3.new(0,-1,0))
 advance(0.2)
 assert(snowmobile.speed<speed,'snowmobile brakes')
 snowmobile.driver.Occupant=nil humanoid.Sit=false
 assert(not groundDrivers[player] and not player:GetAttribute('GroundDriving'),'driver exit clears controls')
 advance(0.1)
 assert(snowmobile.drive.MaxForce.Magnitude==0,'exit disables drive force without pinning passenger')
 assert(snowmobile.passenger.Occupant==friendHumanoid,'passenger remains seated after driver exits')
 snowmobile.passenger.Occupant=nil friendHumanoid.Sit=false
 local jet=spawnVehicles[2]
 interact(jet.driver,'Водитель: сесть')
 for _=1,14 do
  named('GroundVehicleControl').OnServerEvent:Fire(player,Vector3.new(0,1,1))
  advance(0.3)
 end
 assert(jet.speed>90 and jet.speed<=125 and jet.fires[1].Enabled,'jet sled boost increases speed and shows exhaust')
 jet.driver.Occupant=nil humanoid.Sit=false
end
checkSpawnVehicles()
local function checkAirport()
 assert(#airportState.staff==5,'airport has five staff roles')
 interact(airportState.staff[1].PrimaryPart,'Поговорить')
 assert(string.find(player:GetAttribute('WinterMessage'),'Регистратор',1,true),'airport staff provides boarding instructions')
 assert(#airportState.aircraft==2 and #airportState.aircraft[1].seats==2 and #airportState.aircraft[2].seats==6,'small and large aircraft seat counts')
 local plane=airportState.aircraft[1]
 interact(plane.seats[1],'Сесть пилотом')
 assert(airportState.pilots[player]==plane and player:GetAttribute('HasParachute'),'pilot boards with parachute')
 friendRoot.Position=plane.seats[2].Position+Vector3.new(0,3,0)
 for _,p in plane.seats[2]:GetChildren() do if p:IsA('ProximityPrompt') then p.Triggered:Fire(friend) end end
 assert(plane.seats[2].Occupant==friendHumanoid,'passenger boards small plane')
 named('AircraftControl').OnServerEvent:Fire(friend,Vector3.new(1,1,1))
 assert(plane.throttle==0,'passenger cannot fly plane')
 local origin=plane.root.Position
 for _=1,12 do
  named('AircraftControl').OnServerEvent:Fire(player,Vector3.new(0.3,1,1))
  advance(0.25)
 end
 assert(plane.speed>40 and plane.root.Position.Y>20 and (plane.root.Position-origin).Magnitude>30,'pilot accelerates, turns and climbs')
 named('AircraftAction').OnServerEvent:Fire(friend,'jump')
 assert(airportState.parachutes[friend] and airportState.parachutes[friend].force.Velocity.Y==-13,'passenger ejects with open parachute')
 plane.seats[2].Occupant=nil friendHumanoid.Sit=false
 nextRayHit={Instance=named('Снежный остров'),Position=friendRoot.Position-Vector3.new(0,3,0),Normal=Vector3.new(0,1,0)}
 advance(0.1)
 assert(not airportState.parachutes[friend] and friendHumanoid.WalkSpeed==16,'parachute landing removes force and restores walking')
 named('AircraftAction').OnServerEvent:Fire(player,'jump')
 assert(airportState.parachutes[player] and not airportState.pilots[player],'pilot can eject too')
 plane.seats[1].Occupant=nil humanoid.Sit=false
 nextRayHit={Instance=named('Снежный остров'),Position=root.Position-Vector3.new(0,3,0),Normal=Vector3.new(0,1,0)}
 advance(0.1)
 assert(not airportState.parachutes[player],'pilot lands safely')
end
checkAirport()
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
workspace:SetAttribute('StormForecast','До снежной бури: 1 мин 12 сек')
assert(named('Таймер бури').Text=='До снежной бури: 1 мин 12 сек','bottom left countdown follows server forecast')
phoneState.remote.OnServerEvent:Fire(player,'close')
local phoneTool=assert(backpack:FindFirstChild('Телефон'))
phoneTool.Parent=character phoneTool.Activated:Fire()
assert(named('Телефонная книга').Visible,'phone tool opens contacts UI')
phoneState.remote.OnServerEvent:Fire(player,'close')
assert(not named('Телефонная книга').Visible,'phone closes through server')
phoneTool.Activated:Fire()
assert(named('Телефонная книга').Visible,'phone can reopen after closing')
phoneState.remote.OnServerEvent:Fire(player,'close') phoneTool.Parent=backpack

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
interact(spawnVehicles[1].driver,'Водитель: сесть')
mockKeys[Enum.KeyCode.W],mockKeys[Enum.KeyCode.C]=true,true
services.RunService.Heartbeat:Fire(0.15)
assert(spawnVehicles[1].drift==true,'client drift key reaches vehicle controller')
assert(spawnVehicles[1].throttle==1,'client keyboard controls spawn vehicle')
mockKeys[Enum.KeyCode.W],mockKeys[Enum.KeyCode.C]=false,false
spawnVehicles[1].driver.Occupant=nil humanoid.Sit=false
assert(not player:GetAttribute('GroundDriving'),'client UI exits vehicle mode')
interact(named('Возврат: Маленький самолёт'))
local plane=airportState.aircraft[1]
interact(plane.seats[1],'Сесть пилотом')
mockKeys[Enum.KeyCode.W],mockKeys[Enum.KeyCode.Up]=true,true
services.RunService.Heartbeat:Fire(0.15)
assert(plane.throttle==1 and plane.climb==1,'client flight keyboard input reaches pilot controller')
mockKeys[Enum.KeyCode.W],mockKeys[Enum.KeyCode.Up]=false,false
assert(mockActions.AircraftWheelHeight,'pilot wheel handler bound')
mockActions.AircraftWheelHeight(nil,nil,{Position=Vector3.new(0,0,-1)})
services.RunService.Heartbeat:Fire(0.15)
assert(plane.climb>0,'wheel down commands climb')
mockActions.AircraftWheelHeight(nil,nil,{Position=Vector3.new(0,0,1)})
mockActions.AircraftWheelHeight(nil,nil,{Position=Vector3.new(0,0,1)})
services.RunService.Heartbeat:Fire(0.15)
assert(plane.climb<0,'wheel up commands descent')
plane.model:PivotTo(CFrame.new(plane.home.X,100,plane.home.Z))
services.UserInputService.JumpRequest:Fire()
assert(player:GetAttribute('ParachuteOpen') and airportState.parachutes[player],'client jump opens parachute from airborne plane')
assert(not mockActions.AircraftWheelHeight,'eject restores normal mouse wheel')
plane.seats[1].Occupant=nil humanoid.Sit=false
mockKeys[Enum.KeyCode.D]=true
services.RunService.Heartbeat:Fire(0.15)
assert(airportState.parachutes[player].input.X>0,'parachute steering reaches server')
mockKeys[Enum.KeyCode.D]=false
nextRayHit={Instance=named('Снежный остров'),Position=root.Position-Vector3.new(0,3,0),Normal=Vector3.new(0,1,0)}
advance(0.1)
assert(not player:GetAttribute('ParachuteOpen') and not root:FindFirstChild('Плавное снижение'),'landing clears parachute and flight force')
return true
`;
 const full=prelude+'\n'+server+'\n'+assertions.replace('return #objects','')+'\n'+setupClient+'\nlocal function runClient()\n'+client+'\nend\nrunClient()\nlocal function runClientChecks()\n'+clientChecks+'\nend\nreturn runClientChecks()';
 await state.loadstring(full,'client-server interaction regression',true)();
 console.log('Client/server regression passed: throws, tea, skating acceleration/coasting/exit, dialogue, music mute, four skating equip/exit cycles, legacy freeze recovery, waiting deer, carrot bag/tool feeding, house visit, snow lounges, summit lift, two-person sled descent, repeated dismount, spawn vehicles, airport takeoff, pilot/passenger ejection, parachute steering and landing cleanup.');
} finally { state.destroy(); }
