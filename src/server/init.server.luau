-- Winter Village: generated entirely from Roblox parts; no external assets.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local world = Instance.new("Model")
world.Name = "WinterVillage"
world.Parent = workspace
local snow = Color3.fromRGB(239, 247, 255)
local red = Color3.fromRGB(181, 48, 58)
local green = Color3.fromRGB(31, 100, 78)
local gold = Color3.fromRGB(255, 200, 91)
local function part(name, size, position, color, material, parent)
 local p = Instance.new("Part")
 p.Name, p.Size, p.Position = name, size, position
 p.Color, p.Material = color, material or Enum.Material.SmoothPlastic
 p.Anchored = true
 p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
 p.Parent = parent or world
 return p
end
local function ball(name, size, position, color)
 local p = part(name, Vector3.new(size,size,size), position, color)
 p.Shape = Enum.PartType.Ball
 return p
end
local function sign(on, text, offset)
 local gui = Instance.new("BillboardGui")
 gui.Size, gui.StudsOffset = UDim2.fromOffset(180, 44), offset or Vector3.new(0,5,0)
 gui.MaxDistance = 32
 gui.AlwaysOnTop = false
 gui.Parent = on
 local label = Instance.new("TextLabel")
 label.Size = UDim2.fromScale(1,1)
 label.BackgroundColor3, label.BackgroundTransparency = Color3.fromRGB(22,39,58), 1
 label.TextColor3, label.TextSize = snow, 14
 label.TextStrokeTransparency = 0.45
 label.Font, label.TextWrapped = Enum.Font.GothamBold, true
 label.Text = text
 label.Parent = gui
end
local function sound(on,id,volume)
 local audio=Instance.new("Sound")
 audio.SoundId,audio.Volume,audio.RollOffMaxDistance=id,volume or 0.4,65
 audio.Parent=on
 audio:Play()
 Debris:AddItem(audio,4)
end
local function prompt(on, text, callback)
 local p = Instance.new("ProximityPrompt")
 p.ActionText, p.ObjectText, p.MaxActivationDistance = text, on.Name, 10
 p.RequiresLineOfSight = false
 p.Parent = on
 p.Triggered:Connect(function(player)
  local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
  if root and (root.Position-on.Position).Magnitude<=14 then callback(player) end
 end)
end
local function light(on, color, range, brightness)
 local l = Instance.new("PointLight")
 l.Color, l.Range, l.Brightness = color, range, brightness or 1
 l.Parent = on
end
-- Tapered circular tiers produce a fir silhouette without uploaded meshes.
local function tree(x,z,height)
 part("Ствол",Vector3.new(1.2,height*0.32,1.2),Vector3.new(x,height*0.16,z),Color3.fromRGB(97,64,47),Enum.Material.Wood)
 for tier=0,3 do
  local base=height*(0.16+tier*0.19)
  local tierHeight=height*0.34
  local radius=height*(0.29-tier*0.055)
  for ring=0,7 do
   local width=math.max(0.15,radius*2*(1-ring/8))
   local thickness=tierHeight/8
   local disc=part("Еловые ветви",Vector3.new(thickness+0.04,width,width),Vector3.new(x,base+ring*thickness,z),green)
   disc.Shape=Enum.PartType.Cylinder
   disc.Orientation=Vector3.new(0,0,90)
   if ring==0 then
    local cap=part("Снежная кайма",Vector3.new(0.18,width+0.1,width+0.1),disc.Position+Vector3.new(0,thickness/2,0),snow,Enum.Material.Snow)
    cap.Shape=Enum.PartType.Cylinder
    cap.Orientation=Vector3.new(0,0,90)
   end
  end
 end
end
part("Снежный остров",Vector3.new(400,5,360),Vector3.new(0,-2.5,0),snow,Enum.Material.Snow)
part("Дорожка",Vector3.new(12,0.15,145),Vector3.new(0,0.1,0),Color3.fromRGB(186,211,229),Enum.Material.Ice)
local spawn = Instance.new("SpawnLocation")
spawn.Name, spawn.Size, spawn.Position = "Добро пожаловать", Vector3.new(8,1,8), Vector3.new(0,0.5,50)
spawn.Neutral, spawn.Anchored, spawn.Color = true,true,green
spawn.Parent = world
sign(spawn,"НОВОГОДНЯЯ ДЕРЕВНЯ\nГорки • санки • чай у камина")
tree(0,-12,27)
for i=1,20 do
 local a=i*math.pi*2/20
 local y=5+(i%4)*4
 local r=7-y*0.18
 local ornament=ball("Гирлянда",1,Vector3.new(math.cos(a)*r,y, -12+math.sin(a)*r),i%2==0 and gold or red)
 ornament.Material=Enum.Material.Neon
 if i%4==0 then light(ornament,gold,12) end
end
local star=ball("Звезда",2.5,Vector3.new(0,28,-12),gold)
star.Material=Enum.Material.Neon
light(star,gold,35,2)
for i=1,8 do
 local x=(i%2==0 and 1 or -1)*(7+i%3*3)
 local gift=part("Подарок",Vector3.new(3,2.5,3),Vector3.new(x,1.25,-12+(i%4)*3),i%2==0 and red or green)
 part("Лента",Vector3.new(0.4,2.6,3.1),gift.Position,gold)
end
for i=1,32 do
 tree(-190+(i%2)*380,-165+math.floor((i-1)/2)*21,12+i%3*3)
end
for _,z in ipairs({-48,-25,0,25,48}) do
 for _,x in ipairs({-9,9}) do
  part("Фонарный столб",Vector3.new(0.5,7,0.5),Vector3.new(x,3.5,z),Color3.fromRGB(43,56,65),Enum.Material.Metal)
  local lantern=part("Тёплый фонарь",Vector3.new(1.3,1.6,1.3),Vector3.new(x,7.5,z),Color3.fromRGB(255,215,153),Enum.Material.Neon)
  part("Крышка фонаря",Vector3.new(1.8,0.3,1.8),Vector3.new(x,8.5,z),snow)
  light(lantern,Color3.fromRGB(255,207,140),17,0.8)
 end
end
-- Open doorway, usable interior and furniture.
local function house(x,z,theme)
 local main=theme==1
 local accent=({red,green,Color3.fromRGB(76,128,173),Color3.fromRGB(164,91,117)})[theme]
 -- Raise the whole interior above terrain. No coincident snow/wood surfaces.
 local basePart=part
 local function part(name,size,position,color,material,parent)
  return basePart(name,size,position+Vector3.new(0,1.2,0),color,material,parent)
 end
 local brown=theme==3 and Color3.fromRGB(107,124,145) or Color3.fromRGB(151,91,61)
 part("Пол домика",Vector3.new(28,1,26),Vector3.new(x,0.5,z),brown,Enum.Material.WoodPlanks)
 part("Задняя стена",Vector3.new(28,12,1),Vector3.new(x,6,z-13),brown,Enum.Material.WoodPlanks)
 for _,dx in ipairs({-14,14}) do
  part("Боковая стена",Vector3.new(1,12,26),Vector3.new(x+dx,6,z),brown,Enum.Material.WoodPlanks)
 end
 for _,dx in ipairs({-9,9}) do
  part("Фасад",Vector3.new(10,12,1),Vector3.new(x+dx,6,z+13),brown)
  local w=part("Окно",Vector3.new(4,4,1.1),Vector3.new(x+dx,7,z+13),gold,Enum.Material.Neon)
  light(w,gold,14,0.7)
 end
 part("Над дверью",Vector3.new(8,3,1),Vector3.new(x,10.5,z+13),brown)
 -- Pitched roof, gingerbread gables and icing trim.
 for side=-1,1,2 do
  local roof=part("Скат крыши",Vector3.new(18.5,1.2,30),Vector3.new(x+side*8,16.5,z),Color3.fromRGB(103,51,43),Enum.Material.WoodPlanks)
  roof.Orientation=Vector3.new(0,0,-side*30)
  local icing=part("Снег на крыше",Vector3.new(18.7,0.55,30.4),roof.Position+Vector3.new(0,-0.35,0),snow,Enum.Material.Snow)
  icing.Orientation=roof.Orientation
  for _,edge in ipairs({-13,13}) do
   part("Сахарная колонна",Vector3.new(0.7,12,0.7),Vector3.new(x+edge,6,z+side*13),snow)
  end
 end
 for step=0,10 do
  local width=28*(1-step/11)
  for _,depth in ipairs({-13,13}) do
   part("Пряничный фронтон",Vector3.new(width,0.68,1),Vector3.new(x,12+step*0.65,z+depth),brown)
  end
 end
 part("Снежный конёк",Vector3.new(1,0.9,31),Vector3.new(x,21.7,z),snow)
 for _,dx in ipairs({-9,9}) do
  part("Переплёт окна",Vector3.new(0.22,4.3,0.25),Vector3.new(x+dx,7,z+13.7),snow)
  part("Переплёт окна",Vector3.new(4.3,0.22,0.25),Vector3.new(x+dx,7,z+13.7),snow)
  part("Подоконник",Vector3.new(5,0.4,1.2),Vector3.new(x+dx,4.8,z+13.7),snow)
 end
 part("Ковёр",Vector3.new(17,0.12,12),Vector3.new(x,1.08,z+1),accent,Enum.Material.Fabric)
 local chimney=part("Дымоход",Vector3.new(3,7,3),Vector3.new(x+8,20,z-7),Color3.fromRGB(113,65,58),Enum.Material.Brick)
 local smoke=Instance.new("Smoke")
 smoke.Size,smoke.Opacity,smoke.RiseVelocity,smoke.Parent=3,0.15,3,chimney
 for i=-3,3 do
  local bulb=ball("Лампочка",0.7,Vector3.new(x+i*4,11.5,z+14),i%2==0 and red or gold)
  bulb.Material=Enum.Material.Neon
 end
 -- Open hearth: stone frame around visible logs and flames.
 part("Задник камина",Vector3.new(8,6,0.7),Vector3.new(x,3.5,z-11.5),Color3.fromRGB(47,40,43),Enum.Material.Slate)
 for _,side in ipairs({-1,1}) do
  part("Стойка камина",Vector3.new(1.5,5,3.5),Vector3.new(x+side*3.5,3,z-10),Color3.fromRGB(106,83,78),Enum.Material.Brick)
 end
 part("Каминная полка",Vector3.new(10,0.8,4.5),Vector3.new(x,5.8,z-10),snow,Enum.Material.Marble)
 part("Под камина",Vector3.new(9,0.5,4.5),Vector3.new(x,1,z-10),Color3.fromRGB(74,68,71),Enum.Material.Slate)
 for _,dx in ipairs({-1,1}) do
  local log=part("Поленья",Vector3.new(0.8,0.8,3),Vector3.new(x+dx,1.7,z-9.8),Color3.fromRGB(77,47,32),Enum.Material.Wood)
  log.Orientation=Vector3.new(0,dx*25,0)
 end
 local hearth=part("Живой огонь",Vector3.new(3,0.4,2),Vector3.new(x,1.9,z-9.5),Color3.fromRGB(255,126,41),Enum.Material.Neon)
 hearth.CanCollide=false
 local fire=Instance.new("Fire")
 fire.Size,fire.Heat,fire.Parent=3.5,3,hearth
 light(hearth,Color3.fromRGB(255,165,85),18,1.1)
 for i=-2,2 do
  local candle=part("Свеча",Vector3.new(0.35,0.8,0.35),Vector3.new(x+i*1.6,6.6,z-10),gold)
  local flame=Instance.new("Fire")
  flame.Size,flame.Heat,flame.Parent=0.4,0,candle
 end
 part("Полка с книгами",Vector3.new(7,0.4,2),Vector3.new(x-9,7,z-11),brown,Enum.Material.Wood)
 for i=1,6 do
  part("Книга",Vector3.new(0.6,1.5+(i%2)*0.3,1.3),Vector3.new(x-12+i,8,z-11),i%2==0 and green or red)
 end
 for _,dx in ipairs({-11,11}) do
  part("Подарок в доме",Vector3.new(2,1.6,2),Vector3.new(x+dx,1.8,z-7),dx<0 and red or green)
  part("Лента подарка",Vector3.new(0.25,1.7,2.1),Vector3.new(x+dx,1.8,z-7),gold)
 end
 part("Ступень у входа",Vector3.new(8,0.6,3),Vector3.new(x,0.1,z+15),brown,Enum.Material.WoodPlanks)
 part("Верхняя ступень",Vector3.new(8,1.1,2),Vector3.new(x,0.45,z+13.5),brown,Enum.Material.WoodPlanks)
 for _,dx in ipairs({-8,8}) do
  local seat=Instance.new("Seat")
  seat.Size,seat.Position,seat.Anchored=Vector3.new(4,1,4),Vector3.new(x+dx,3.2,z),true
  seat.Color,seat.Parent=accent,world
  part("Спинка кресла",Vector3.new(4,4,1),Vector3.new(x+dx,3,z+2),red)
 end
 for i=1,9 do
  local a=i*math.pi*2/9
  local ornament=part("Настенный венок",Vector3.new(0.8,0.8,0.5),Vector3.new(x+math.cos(a)*1.4,8+math.sin(a)*1.4,z-12.2),i%3==0 and red or green)
  ornament.Shape=Enum.PartType.Ball
 end
 for i=-2,2 do
  part("Праздничная подушка",Vector3.new(1.2,0.5,1.2),Vector3.new(x+i*0.8,1.6,z+7),i%2==0 and red or gold,Enum.Material.Fabric)
 end
 local tableTop=part("Стол с чаем",Vector3.new(6,0.5,4),Vector3.new(x,2.5,z+3),brown,Enum.Material.Wood)
 part("Ножка стола",Vector3.new(1,2.5,1),Vector3.new(x,1.25,z+3),brown)
 sign(tableTop,({"ЧАЙНЫЙ ДОМИК","ПРЯНИЧНЫЙ ДОМ","ЛЕДЯНОЕ ШАЛЕ","МАСТЕРСКАЯ ПОДАРКОВ"})[theme],Vector3.new(0,4,0))
 if theme==2 then
  for i=1,5 do
   part("Пряничное печенье",Vector3.new(0.7,0.18,0.7),Vector3.new(x-2+i*0.7,2.9,z+3),gold)
  end
 elseif theme==3 then
  for i=1,5 do
   local crystal=part("Ледяная звезда",Vector3.new(0.5,0.5,0.5),Vector3.new(x-7+i*2,8,z-12),Color3.fromRGB(157,231,255),Enum.Material.Neon)
   crystal.Orientation=Vector3.new(0,0,45)
  end
 elseif theme==4 then
  part("Верстак подарков",Vector3.new(8,0.5,3),Vector3.new(x-8,3,z-5),brown,Enum.Material.Wood)
  for i=1,4 do
   part("Завёрнутый подарок",Vector3.new(1.3,1.3,1.3),Vector3.new(x-12+i*1.5,3.9,z-5),i%2==0 and green or red)
  end
 end
 prompt(tableTop,"Взять чай",function(player)
  if player.Backpack:FindFirstChild("Горячий чай") or (player.Character and player.Character:FindFirstChild("Горячий чай")) then return end
  local tool=Instance.new("Tool")
  tool.Name="Горячий чай"
  local cup=Instance.new("Part")
  cup.Name,cup.Size,cup.Color,cup.CanCollide="Handle",Vector3.new(0.7,0.8,0.7),snow,false
  local cupMesh=Instance.new("CylinderMesh")
  cupMesh.Parent=cup
  cup.Massless=true
  local tea=Instance.new("Part")
  tea.Name,tea.Size,tea.Color,tea.CanCollide,tea.Massless="Чай",Vector3.new(0.55,0.06,0.55),Color3.fromRGB(113,64,29),false,true
  tea.CFrame=cup.CFrame*CFrame.new(0,0.4,0)
  tea.Parent=tool
  local weld=Instance.new("WeldConstraint")
  weld.Part0,weld.Part1,weld.Parent=cup,tea,cup
  tool.CanBeDropped=false
  cup.Parent=tool
  local steam=Instance.new("Smoke")
  steam.Size,steam.Opacity,steam.RiseVelocity,steam.Parent=0.3,0.15,2,cup
  tool.Parent=player.Backpack
 end)
end
house(-43,-22,1)
house(58,-40,2)
house(-130,-100,3)
house(-40,125,4)
local paths={{0,50,-40,145},{0,-65,-130,-80}}
for _,path in paths do
 local a,b=Vector3.new(path[1],0.18,path[2]),Vector3.new(path[3],0.18,path[4])
 local road=part("Дорожка к домикам",Vector3.new(7,0.2,(b-a).Magnitude),a:Lerp(b,0.5),Color3.fromRGB(200,219,234),Enum.Material.Snow)
 road.CFrame=CFrame.lookAt(a:Lerp(b,0.5),b)
end
local forestRandom=Random.new(479)
local clearings={
 {-43,-22,28,27},{58,-40,28,27},{-130,-100,29,27},{-40,125,28,27},
 {85,88,30,70},{135,-5,30,100},{30,-65,30,100},
 {-105,75,42,36},{-98,-45,35,32},{-40,43,37,29},{0,-12,27,35},
}
for _=1,170 do
 local x,z=forestRandom:NextNumber(-178,178),forestRandom:NextNumber(-155,155)
 local clear=math.abs(x)<16
 for _,path in paths do
  local dx,dz=path[3]-path[1],path[4]-path[2]
  local t=math.clamp(((x-path[1])*dx+(z-path[2])*dz)/(dx*dx+dz*dz),0,1)
  if (x-path[1]-t*dx)^2+(z-path[2]-t*dz)^2<100 then clear=true end
 end
 for _,area in clearings do
  if math.abs(x-area[1])<area[3] and math.abs(z-area[2])<area[4] then clear=true break end
 end
 if not clear then tree(x,z,forestRandom:NextNumber(10,19)) end
end
-- Friendly Santa, no uploaded character assets.
local santa=part("Санта-Клаус",Vector3.new(4,5,2),Vector3.new(23,3,-10),red)
ball("Голова Санты",2.7,Vector3.new(23,6.7,-10),Color3.fromRGB(247,209,180))
ball("Борода",2,Vector3.new(23,6,-8.9),snow)
part("Шапка",Vector3.new(3,1.8,3),Vector3.new(23,8.6,-10),red)
ball("Помпон",1,Vector3.new(23,9.8,-10),snow)
sign(santa,"САНТА\nС праздником! Горки ждут справа.")
prompt(santa,"Поздороваться",function(player) player:SetAttribute("SantaGreeting",(player:GetAttribute("SantaGreeting") or 0)+1) end)
-- Winter park: rounded drifts, a frozen pond and three guided sled routes.
local random=Random.new(2026)
for i=1,38 do
 local x=(i%2==0 and -1 or 1)*random:NextNumber(95,180)
 local z=random:NextNumber(-155,155)
 local drift=ball("Сугроб",1,Vector3.new(x,-0.6,z),snow)
 drift.Size=Vector3.new(random:NextNumber(9,20),random:NextNumber(3,7),random:NextNumber(9,20))
 drift.Material=Enum.Material.Snow
end
local pond=part("Ледяной каток",Vector3.new(58,0.3,45),Vector3.new(-105,0.3,75),Color3.fromRGB(160,213,234),Enum.Material.Ice)
pond.CustomPhysicalProperties=PhysicalProperties.new(0.7,0.01,0.1)
sign(pond,"КАТОК • скользкий лёд")
for _,dx in ipairs({-29,29}) do
 part("Бортик катка",Vector3.new(1,1,47),Vector3.new(-105+dx,0.8,75),snow)
end
-- Route rides are server-controlled; seats cannot be flung by network physics.
local riding={}
local function hill(x,z,height,length,title)
 local width=15
 local angle=math.atan(height/length)
 local slope=part("Снежный спуск",Vector3.new(width,2,math.sqrt(height*height+length*length)),Vector3.new(x,height/2,z),snow,Enum.Material.Snow)
 slope.Orientation=Vector3.new(math.deg(angle),0,0)
 local top=Vector3.new(x,height+1,z-length/2)
 local bottom=Vector3.new(x,1,z+length/2)
 part("Стартовая площадка",Vector3.new(22,2,10),top+Vector3.new(0,-1,-3),snow)
 for i=0,math.ceil(height/0.8) do
  local t=i/math.ceil(height/0.8)
  part("Лестница на горку",Vector3.new(5,1+t*height,3),Vector3.new(x+12,(1+t*height)/2,z+length/2-t*length),Color3.fromRGB(179,201,216),Enum.Material.Snow)
 end
 for _,side in ipairs({-1,1}) do
  local rail=part("Бортик спуска",Vector3.new(0.6,1.2,math.sqrt(height*height+length*length)),slope.Position+Vector3.new(side*7.5,1.5,0),Color3.fromRGB(180,221,240),Enum.Material.Ice)
  rail.Orientation=slope.Orientation
 end
 local start=part("Прокат санок",Vector3.new(3,2,2),Vector3.new(x+20,1,z+length/2),red)
 sign(start,title.."\nE — подняться на старт")
 prompt(start,"На вершину",function(player)
  if riding[player] or not player.Character then return end
  player.Character:PivotTo(CFrame.new(top+Vector3.new(0,4,-4)))
 end)
 local sled=Instance.new("Model")
 sled.Name,sled.Parent="Санки",world
 local seat=Instance.new("Seat")
 seat.Name,seat.Size,seat.Anchored,seat.CanTouch="Сиденье санок",Vector3.new(3,0.5,3),true,false
 seat.CFrame=CFrame.lookAt(top+Vector3.new(0,1,0),Vector3.new(bottom.X,top.Y+1,bottom.Z))
 seat.Color,seat.Material,seat.Parent=red,Enum.Material.Wood,sled
 sled.PrimaryPart=seat
 local function sledPart(name,size,offset,color)
  local p=part(name,size,Vector3.zero,color,Enum.Material.Wood,sled)
  p.CFrame=seat.CFrame*CFrame.new(offset)
  p.CanCollide=name=="Полозья"
  p.CustomPhysicalProperties=PhysicalProperties.new(1,0.11,0.05)
 end
 for _,side in ipairs({-1,1}) do
  sledPart("Полозья",Vector3.new(0.25,0.3,4.5),Vector3.new(side*1.4,-0.8,0),Color3.fromRGB(118,150,170))
  sledPart("Опоры",Vector3.new(0.25,0.9,2),Vector3.new(side*1.2,-0.4,0),gold)
 end
 sledPart("Спинка санок",Vector3.new(3,1.5,0.3),Vector3.new(0,0.8,1.4),red)
 local home=sled:GetPivot()
 local busy=false
 local freeSled=false
 local function release(speed)
  if freeSled then return end
  freeSled=true
  for _,p in sled:GetDescendants() do
   if p:IsA("BasePart") and p~=seat then
    local weld=Instance.new("WeldConstraint")
    weld.Part0,weld.Part1,weld.Parent=seat,p,seat
    p.Anchored=false
    p.Massless=true
   end
  end
  seat.CustomPhysicalProperties=PhysicalProperties.new(1,0.11,0.05)
  seat.Anchored=false
  seat:SetNetworkOwner(nil)
  seat.AssemblyLinearVelocity=Vector3.new(0,0,speed)
  seat.AssemblyAngularVelocity=Vector3.zero
 end
 local lastRider=nil
 seat:GetPropertyChangedSignal("Occupant"):Connect(function()
  if not seat.Occupant and lastRider then riding[lastRider]=nil lastRider=nil end
 end)
 prompt(seat,"Сесть на санки • прыжок — выйти",function(player)
  local character=player.Character
  local humanoid=character and character:FindFirstChildOfClass("Humanoid")
  if riding[player] or not humanoid or humanoid.Health<=0 or seat.Occupant then return end
  if busy and not freeSled then return end
  riding[player],lastRider=true,player
  character:PivotTo(seat.CFrame*CFrame.new(0,2,0))
  seat:Sit(humanoid)
  if freeSled then return end
  busy=true
  task.spawn(function()
   task.wait(0.3)
   local started=os.clock()
   local duration=2.1+length/65
   while os.clock()-started<duration do
    local t=math.clamp((os.clock()-started)/duration,0,1)
    local pos=(top+Vector3.new(0,1.5,0)):Lerp(bottom+Vector3.new(0,1.5,0),t*t)
    sled:PivotTo(CFrame.lookAt(pos,pos+Vector3.new(0,-height/length,1)))
    RunService.Heartbeat:Wait()
   end
   -- Keep the rider seated; jumping is the only automatic way out.
   sled:PivotTo(CFrame.lookAt(bottom+Vector3.new(0,1.5,2),bottom+Vector3.new(0,1.5,10)))
   release(45)
  end)
 end)
 -- Explicit retrieval preserves the sled at the runout until requested.
 local returnPost=part("Возврат санок",Vector3.new(2,2,2),start.Position+Vector3.new(5,0,0),green)
 prompt(returnPost,"Вернуть свободные санки наверх",function()
  if not freeSled or seat.Occupant or seat.AssemblyLinearVelocity.Magnitude>1.5 then return end
  for _,weld in seat:GetChildren() do if weld:IsA("WeldConstraint") then weld:Destroy() end end
  for _,p in sled:GetDescendants() do if p:IsA("BasePart") then p.Anchored=true end end
  sled:PivotTo(home)
  freeSled,busy=false,false
 end)
end
hill(85,50,18,55,"МАЛАЯ ГОРКА")
hill(135,-45,30,80,"БОЛЬШАЯ ГОРКА")
hill(30,-105,23,65,"ЛЕСНОЙ СПУСК")
-- Snowman ingredients are personal; rolling and completed figures are replicated.
local inventories={}
local rolling={}
local builtByPlayer={}
local required={"Палочки","Морковка","Ведёрко"}
local ingredientAttributes={["Палочки"]="InventorySticks",["Морковка"]="InventoryCarrot",["Ведёрко"]="InventoryBucket"}
local function inventory(player)
 if not inventories[player] then inventories[player]={} end
 return inventories[player]
end
for index,name in required do
 for copy=1,3 do
  local pos=Vector3.new(-150+(index-1)*20+copy*7,0.7,-30+(copy-1)*17)
  local item=part(name, name=="Палочки" and Vector3.new(0.3,0.3,3) or Vector3.new(1,1,1),pos,
   name=="Морковка" and Color3.fromRGB(241,140,39) or (name=="Палочки" and Color3.fromRGB(96,63,41) or Color3.fromRGB(143,175,191)))
  item:SetAttribute("IngredientKey",ingredientAttributes[name])
  if name=="Ведёрко" then item.Shape=Enum.PartType.Cylinder end
  sign(item,name,Vector3.new(0,2,0))
  prompt(item,"Подобрать",function(player)
   inventory(player)[name]=true
   player:SetAttribute(ingredientAttributes[name],true)
  end)
 end
end
local snowmanBase=part("Мастерская снеговиков",Vector3.new(8,0.25,8),Vector3.new(-98,0.25,-45),Color3.fromRGB(202,224,235))
sign(snowmanBase,"СНЕГОВИК\nКом + палочки + морковка + ведёрко")
local rollingBase=ball("Заготовка снежного кома",1.8,Vector3.new(-84,0.9,-42),snow)
prompt(rollingBase,"Катать снежный ком",function(player)
 if rolling[player] or not player.Character then return end
 local sphere=ball("Ком игрока",1.8,Vector3.zero,snow)
 sphere.CanCollide,sphere.CanQuery=false,false
 sphere.Material=Enum.Material.Snow
 rolling[player]={sphere=sphere,size=1.8,distance=0}
 player:SetAttribute("SnowSize",1.8)
end)
local stopRolling=Instance.new("RemoteEvent")
stopRolling.Name,stopRolling.Parent="StopRollingSnow",ReplicatedStorage
local function dropSnow(player)
 local state=rolling[player]
 if not state then return end
 -- Dropped balls stay decorative for one minute; they never damage players.
 state.sphere.CanCollide=true
 Debris:AddItem(state.sphere,60)
 rolling[player]=nil
 player:SetAttribute("SnowSize",0)
end
stopRolling.OnServerEvent:Connect(dropSnow)
local accumulator=0
RunService.Heartbeat:Connect(function(dt)
 accumulator+=dt
 if accumulator<0.08 then return end
 accumulator=0
 for player,state in rolling do
  local character=player.Character
  local root=character and character:FindFirstChild("HumanoidRootPart")
  local humanoid=character and character:FindFirstChildOfClass("Humanoid")
  if not root or not humanoid or humanoid.Health<=0 then
   state.sphere:Destroy() rolling[player]=nil
  else
   local pos=root.Position
   local look=Vector3.new(root.CFrame.LookVector.X,0,root.CFrame.LookVector.Z)
   if look.Magnitude>0.1 then look=look.Unit else look=Vector3.new(0,0,-1) end
   local travel=state.previous and (Vector3.new(pos.X,0,pos.Z)-state.previous).Magnitude or 0
   state.previous=Vector3.new(pos.X,0,pos.Z)
   local point=pos+look*(2.7+state.size/2)
   local params=RaycastParams.new()
   params.FilterType=Enum.RaycastFilterType.Exclude
   params.FilterDescendantsInstances={character,state.sphere}
   local ground=workspace:Raycast(point+Vector3.new(0,8,0),Vector3.new(0,-35,0),params)
   if ground and ground.Instance.Material==Enum.Material.Snow and ground.Normal.Y>0.7
    and travel<6 and math.abs(pos.X)<190 and math.abs(pos.Z)<170 then
    state.size=math.min(6,state.size+travel*0.035)
   end
   state.sphere.Size=Vector3.new(state.size,state.size,state.size)
   state.sphere.CFrame=CFrame.new(point.X,(ground and ground.Position.Y or 0)+state.size/2,point.Z)*CFrame.Angles(state.distance,0,0)
   state.distance+=travel/math.max(state.size/2,0.9)
   local rounded=math.floor(state.size*10)/10
   if player:GetAttribute("SnowSize")~=rounded then player:SetAttribute("SnowSize",rounded) end
  end
 end
end)
prompt(snowmanBase,"Собрать снеговика",function(player)
 local items=inventory(player)
 local state=rolling[player]
 if not state or state.size<4 then player:SetAttribute("WinterMessage","Сначала накатай ком до 4 метров") return end
 for _,name in required do
  if not items[name] then player:SetAttribute("WinterMessage","Не хватает: "..name) return end
 end
 if builtByPlayer[player] then builtByPlayer[player]:Destroy() end
 local model=Instance.new("Model")
 model.Name,model.Parent="Снеговик "..player.Name,world
 builtByPlayer[player]=model
 local x,z=-98+((player.UserId%3)-1)*7,-52
 local function piece(name,size,pos,color)
  local p=part(name,size,pos,color,nil,model)
  return p
 end
 local function snowBall(size,y)
  local p=piece("Снежный ком",Vector3.new(size,size,size),Vector3.new(x,y,z),snow)
  p.Shape=Enum.PartType.Ball
 end
 snowBall(4,2) snowBall(3,4.8) snowBall(2,7)
 for _,side in ipairs({-1,1}) do
  local arm=piece("Палочка",Vector3.new(0.2,0.2,3),Vector3.new(x+side*2.4,4.8,z),Color3.fromRGB(100,65,37))
  arm.Orientation=Vector3.new(0,side*65,side*20)
  local eye=piece("Уголёк",Vector3.new(0.18,0.18,0.18),Vector3.new(x+side*0.35,7.2,z+0.95),Color3.fromRGB(25,30,35))
  eye.Shape=Enum.PartType.Ball
 end
 piece("Морковка",Vector3.new(0.3,0.3,1),Vector3.new(x,6.95,z+1.3),Color3.fromRGB(244,141,38))
 local bucket=piece("Ведёрко",Vector3.new(1.1,1.7,1.7),Vector3.new(x,8.3,z),Color3.fromRGB(140,169,190))
 bucket.Shape=Enum.PartType.Cylinder bucket.Orientation=Vector3.new(0,0,90)
 piece("Шарф",Vector3.new(2.4,0.4,2.4),Vector3.new(x,6,z),red)
 for _,name in required do items[name]=nil player:SetAttribute(ingredientAttributes[name],false) end
 state.sphere:Destroy() rolling[player]=nil player:SetAttribute("SnowSize",0)
 player:SetAttribute("WinterMessage","Снеговик готов! Можно собрать ещё одного")
end)
local arena=part("Снежковая площадка",Vector3.new(35,0.2,30),Vector3.new(-40,0.2,43),Color3.fromRGB(206,229,243),Enum.Material.Snow)
sign(arena,"СНЕЖКОВАЯ БИТВА • УРОН 15\nВозьми снежок • нажми, чтобы бросить")
local remote=Instance.new("RemoteEvent")
remote.Name,remote.Parent="ThrowSnowball",ReplicatedStorage
local lastThrow={}
local pile=ball("Гора снежков",5,Vector3.new(-40,1.5,43),snow)
for i=1,12 do
 local a=i*math.pi*2/12
 ball("Запас снежков",1.2,Vector3.new(-40+math.cos(a)*2.8,0.7+(i%3)*0.45,43+math.sin(a)*2.8),snow)
end
prompt(pile,"Взять снежки",function(player)
 if player.Backpack:FindFirstChild("Снежки") or (player.Character and player.Character:FindFirstChild("Снежки")) then return end
 local tool=Instance.new("Tool")
 tool.Name,tool.RequiresHandle,tool.CanBeDropped="Снежки",true,false
 local handle=Instance.new("Part")
 handle.Name,handle.Size,handle.Shape="Handle",Vector3.new(0.85,0.85,0.85),Enum.PartType.Ball
 handle.Color,handle.CanCollide,handle.Massless,handle.CanQuery=snow,false,true,false
 handle.Parent=tool
 tool.Parent=player.Backpack
end)
for i=1,3 do
 local target=ball("Мишень для снежков",4,Vector3.new(-55+(i-1)*15,5,25),i%2==0 and red or gold)
 target:SetAttribute("SnowTarget",true)
 part("Стойка мишени",Vector3.new(0.5,3.5,0.5),target.Position-Vector3.new(0,3,0),green)
end
remote.OnServerEvent:Connect(function(player,target)
 if typeof(target)~="Vector3" or target.X~=target.X or target.Y~=target.Y or target.Z~=target.Z or target.Magnitude>100000 then return end
 local character=player.Character
 local root=character and character:FindFirstChild("HumanoidRootPart")
 if not root or not character:FindFirstChild("Снежки") or (lastThrow[player] and os.clock()-lastThrow[player]<0.85) then return end
 local origin=root.Position+Vector3.new(0,1.5,0)
 local direction=target-origin
 if direction.Magnitude<0.1 then return end
 lastThrow[player]=os.clock()
 origin+=direction.Unit*2
 sound(root,"rbxasset://sounds/action_jump.mp3",0.6)
 local projectile=ball("Летящий снежок",1.2,origin,snow)
 projectile.CanCollide,projectile.CanQuery=false,false
 local a0,a1=Instance.new("Attachment"),Instance.new("Attachment")
 a0.Position,a1.Position=Vector3.new(-0.25,0,0),Vector3.new(0.25,0,0)
 a0.Parent,a1.Parent=projectile,projectile
 local trail=Instance.new("Trail")
 trail.Attachment0,trail.Attachment1,trail.Lifetime=a0,a1,0.35
 trail.FaceCamera=true
 trail.LightEmission=0.6
 trail.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0.4),NumberSequenceKeypoint.new(1,1)})
 trail.Parent=projectile
 local velocity=direction.Unit*105+Vector3.new(0,12,0)
 local params=RaycastParams.new()
 params.FilterType=Enum.RaycastFilterType.Exclude
 params.FilterDescendantsInstances={character,projectile}
 task.spawn(function()
  local age=0
  while projectile.Parent and age<3 do
   local dt=RunService.Heartbeat:Wait()
   age+=dt
   local move=velocity*dt
   local hit=workspace:Raycast(projectile.Position,move,params)
   if hit then
    local victim=hit.Instance:FindFirstAncestorOfClass("Model")
    local humanoid=victim and victim:FindFirstChildOfClass("Humanoid")
    if humanoid and victim~=character and humanoid.Health>0 then humanoid:TakeDamage(15) end
    local mark=ball("Место попадания",0.2,hit.Position+hit.Normal*0.08,snow)
    mark.Size=Vector3.new(1.8,0.12,1.8)
    mark.CFrame=CFrame.lookAt(hit.Position+hit.Normal*0.08,hit.Position+hit.Normal)*CFrame.Angles(math.pi/2,0,0)
    mark.CanCollide,mark.CanQuery=false,false
    Debris:AddItem(mark,8)
    projectile.Position=hit.Position
    projectile.Transparency=1
    local puff=Instance.new("ParticleEmitter")
    puff.Texture="rbxasset://textures/particles/sparkles_main.dds"
    puff.Rate,puff.Lifetime,puff.Speed=0,NumberRange.new(0.2,0.45),NumberRange.new(4,9)
    puff.SpreadAngle=Vector2.new(180,180)
    puff.Size=NumberSequence.new(0.2)
    puff.Parent=projectile
    puff:Emit(18)
    local sound=Instance.new("Sound")
    sound.SoundId,sound.Volume,sound.RollOffMaxDistance="rbxasset://sounds/impact_water.mp3",0.25,45
    sound.Parent=projectile
    sound:Play()
    if hit.Instance:GetAttribute("SnowTarget") then
     local original=hit.Instance.Color
     hit.Instance.Color=snow
     task.delay(0.4,function() if hit.Instance.Parent then hit.Instance.Color=original end end)
    end
    Debris:AddItem(projectile,1)
    return
   end
   projectile.Position+=move
   velocity+=Vector3.new(0,-workspace.Gravity*0.28*dt,0)
  end
  projectile:Destroy()
 end)
end)
Players.PlayerRemoving:Connect(function(player)
 lastThrow[player],riding[player],inventories[player]=nil,nil,nil
 if rolling[player] then rolling[player].sphere:Destroy() rolling[player]=nil end
 if builtByPlayer[player] then builtByPlayer[player]:Destroy() builtByPlayer[player]=nil end
end)
