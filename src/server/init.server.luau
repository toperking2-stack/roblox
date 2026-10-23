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
local removeSkates
local navigationObstacles={}
local snowLoungeCenters={Vector3.new(-220,0,-180),Vector3.new(220,0,180),Vector3.new(0,0,240),Vector3.new(220,0,60),Vector3.new(-235,0,0),Vector3.new(90,0,-220)}
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
-- Rounded, reusable details. Cylinder parts use their X axis as the length axis.
local function rod(name,a,b,radius,color,parent,material)
 local p=part(name,Vector3.new((b-a).Magnitude,radius*2,radius*2),a:Lerp(b,0.5),color,material or Enum.Material.Wood,parent)
 p.Shape=Enum.PartType.Cylinder
 p.CFrame=CFrame.lookAt(a:Lerp(b,0.5),b)*CFrame.Angles(0,math.pi/2,0)
 p.CanCollide=false
 return p
end
local function round(name,size,position,color,parent)
 local p=part(name,size,position,color,nil,parent)
 p.Shape=Enum.PartType.Ball
 p.CanCollide=false
 return p
end
local function carrot(position,parent,scale,standing)
 scale=scale or 1
 local root=part("Морковка",Vector3.new(0.2,0.2,0.2),position,red,nil,parent)
 root.Transparency,root.CanCollide=1,false
 local axis=standing and Vector3.new(0,0,1) or Vector3.new(1,0.08,0.2).Unit
 local start=position-axis*0.75*scale
 for i=0,11 do
  local t=i/12
  rod("Конус моркови",start+axis*t*1.6*scale,start+axis*(t+1/12)*1.6*scale,
   (0.31*(1-t)+0.025)*scale,Color3.fromRGB(239-i%3*9,122-i%3*8,29),root,Enum.Material.SmoothPlastic)
 end
 for i=-1,1 do
  rod("Зелёная ботва",start,start+Vector3.new(-0.55,0.45+i*0.25,i*0.3)*scale,0.065*scale,green,root)
 end
 return root
end
local function bucket(position,parent,scale)
 scale=scale or 1
 local root=part("Ведёрко",Vector3.new(0.2,0.2,0.2),position,snow,nil,parent)
 root.Transparency,root.CanCollide=1,false
 local metal=Color3.fromRGB(149,170,185)
 local base=part("Дно ведра",Vector3.new(0.09,1.1,1.1)*scale,position-Vector3.new(0,0.58,0)*scale,metal,Enum.Material.Metal,root)
 base.Shape,base.Orientation,base.CanCollide=Enum.PartType.Cylinder,Vector3.new(0,0,90),false
 for i=0,19 do
  local a=i*math.pi*2/20
  local wall=part("Стенка ведра",Vector3.new(0.23,1.25,0.08)*scale,position+Vector3.new(math.sin(a)*0.64,0,math.cos(a)*0.64)*scale,metal,Enum.Material.Metal,root)
  wall.CFrame=CFrame.new(wall.Position)*CFrame.Angles(math.sin(a)*0.12,a,0)
  wall.CanCollide=false
  local nextA=(i+1)*math.pi*2/20
  rod("Ободок ведра",position+Vector3.new(math.sin(a)*0.72,0.65,math.cos(a)*0.72)*scale,
   position+Vector3.new(math.sin(nextA)*0.72,0.65,math.cos(nextA)*0.72)*scale,0.045*scale,snow,root,Enum.Material.Metal)
 end
 for i=0,11 do
  local a,b=i*math.pi/12,(i+1)*math.pi/12
  rod("Ручка ведра",position+Vector3.new(math.cos(a)*0.76,0.2+math.sin(a)*0.95,0)*scale,
   position+Vector3.new(math.cos(b)*0.76,0.2+math.sin(b)*0.95,0)*scale,0.04*scale,metal,root,Enum.Material.Metal)
 end
 return root
end
local function branch(position,parent)
 local root=part("Палочки",Vector3.new(0.2,0.2,0.2),position,green,nil,parent)
 root.Transparency,root.CanCollide=1,false
 rod("Ветка с корой",position+Vector3.new(-1.4,0,-0.2),position+Vector3.new(1.4,0.1,0.3),0.13,Color3.fromRGB(102,67,41),root)
 rod("Ответвление",position,position+Vector3.new(0.7,0.05,0.95),0.08,Color3.fromRGB(118,77,47),root)
 rod("Тонкая веточка",position+Vector3.new(-0.6,0,0),position+Vector3.new(-0.4,0.15,-0.65),0.06,Color3.fromRGB(118,77,47),root)
 return root
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
local function prompt(on, text, callback, keyName)
 local p = Instance.new("ProximityPrompt")
 p.ActionText, p.ObjectText, p.MaxActivationDistance = text, on.Name, 10
 p.RequiresLineOfSight = false
 p.KeyboardKeyCode=Enum.KeyCode[keyName or "E"]
 if keyName then p.UIOffset=Vector2.new(0,({F=30,E=-30})[keyName] or 0) end
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
 table.insert(navigationObstacles,{x=x,z=z,radius=math.max(9,height*0.29+4)})
 part("Ствол",Vector3.new(1.2,height*0.32,1.2),Vector3.new(x,height*0.16,z),Color3.fromRGB(97,64,47),Enum.Material.Wood)
 local rings=(math.abs(x)>180 or math.abs(z)>170) and 4 or 8
 for tier=0,3 do
  local base=height*(0.16+tier*0.19)
  local tierHeight=height*0.34
  local radius=height*(0.29-tier*0.055)
  for ring=0,rings-1 do
   local width=math.max(0.15,radius*2*(1-ring/rings))
   local thickness=tierHeight/rings
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
part("Снежный остров",Vector3.new(640,5,580),Vector3.new(0,-2.5,0),snow,Enum.Material.Snow)
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
 {-250,210,24,24},{245,215,24,24},{250,-210,24,24},{-250,-210,24,24},
 {-155,135,22,22},{150,125,22,22},{155,-140,22,22},{-160,-30,22,22},
 {-43,-22,28,27},{58,-40,28,27},{-130,-100,29,27},{-40,125,28,27},
 {85,88,30,70},{135,-5,30,100},{30,-65,30,100},
 {-105,75,42,36},{-98,-45,35,32},{-40,43,37,29},{0,-12,27,35},
}
for _=1,240 do
 local x,z=forestRandom:NextNumber(-298,298),forestRandom:NextNumber(-268,268)
 local clear=math.abs(x)<16
 for _,center in snowLoungeCenters do
  if math.abs(x-center.X)<20 and math.abs(z-center.Z)<20 then clear=true end
 end
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
-- Larger, rounded Father Frost with a detailed coat, face, fur and mittens.
local santaModel=Instance.new("Model")
santaModel.Name,santaModel.Parent="Дед Мороз",world
local santa=round("Дед Мороз",Vector3.new(5.6,6.4,3.6),Vector3.new(23,5.9,-10),red,santaModel)
santaModel.PrimaryPart=santa
for _,side in ipairs({-1,1}) do
 round("Сапог",Vector3.new(1.8,1.7,2.7),Vector3.new(23+side*1.25,0.95,-9.7),Color3.fromRGB(42,39,45),santaModel)
 rod("Штанина",Vector3.new(23+side*1.25,1.8,-10),Vector3.new(23+side*1.25,3.6,-10),0.65,red,santaModel,Enum.Material.Fabric)
 rod("Рукав шубы",Vector3.new(23+side*2.3,7.2,-10),Vector3.new(23+side*3.4,4.9,-9.6),0.78,red,santaModel,Enum.Material.Fabric)
 round("Меховой манжет",Vector3.new(1.7,0.8,1.7),Vector3.new(23+side*3.4,4.9,-9.6),snow,santaModel)
 round("Варежка",Vector3.new(1.2,1.5,1.2),Vector3.new(23+side*3.5,4.2,-9.5),red,santaModel)
end
round("Меховой подол",Vector3.new(5.7,0.7,3.7),Vector3.new(23,3,-10),snow,santaModel)
round("Пояс",Vector3.new(5.7,0.5,3.7),Vector3.new(23,5,-10),Color3.fromRGB(46,34,37),santaModel)
part("Пряжка",Vector3.new(0.9,0.75,0.2),Vector3.new(23,5,-8.05),gold,Enum.Material.Metal,santaModel)
round("Голова",Vector3.new(2.7,3,2.7),Vector3.new(23,10,-10),Color3.fromRGB(245,202,170),santaModel)
for _,side in ipairs({-1,1}) do
 round("Щёчка",Vector3.new(0.65,0.45,0.25),Vector3.new(23+side*0.85,9.7,-8.9),Color3.fromRGB(232,148,135),santaModel)
 round("Глаза",Vector3.new(0.2,0.25,0.16),Vector3.new(23+side*0.48,10.25,-8.68),Color3.fromRGB(39,62,75),santaModel)
 round("Бровь",Vector3.new(0.65,0.17,0.2),Vector3.new(23+side*0.48,10.6,-8.77),snow,santaModel)
end
round("Нос",Vector3.new(0.45,0.5,0.5),Vector3.new(23,9.9,-8.45),Color3.fromRGB(238,171,151),santaModel)
for i=-3,3 do
 round("Прядь бороды",Vector3.new(0.85,2.2-math.abs(i)*0.2,0.8),Vector3.new(23+i*0.35,8.9,-8.9),snow,santaModel)
end
round("Усы",Vector3.new(1.8,0.5,0.55),Vector3.new(23,9.45,-8.5),snow,santaModel)
for i=0,7 do
 local hat=part("Шапка",Vector3.new(0.28,2.9-i*0.28,2.9-i*0.28),Vector3.new(23+i*0.07,11.4+i*0.23,-10),red,Enum.Material.Fabric,santaModel)
 hat.Shape,hat.Orientation=Enum.PartType.Cylinder,Vector3.new(0,0,90)
end
round("Мех шапки",Vector3.new(3.2,0.5,3.2),Vector3.new(23,11.3,-10),snow,santaModel)
round("Помпон",Vector3.new(0.9,0.9,0.9),Vector3.new(23.6,13.3,-10),snow,santaModel)
sign(santa,"ДЕД МОРОЗ • E — поговорить",Vector3.new(0,8.5,0))
prompt(santa,"Поговорить",function(player) player:SetAttribute("SantaGreeting",(player:GetAttribute("SantaGreeting") or 0)+1) end)
-- Ground navigation across the expanded park. A cached grid avoids houses, ice,
-- slopes, trees and drift lounges. Each flood search chooses a reachable distant goal.
local navigationRects={
 {-43,-22,22,22},{58,-40,22,22},{-130,-100,22,22},{-40,125,22,22},
 {-105,75,36,30},{85,50,22,42},{135,-45,22,53},{30,-105,22,45},
}
local navigationGrid
local function gridKey(x,z) return x..":"..z end
local function buildNavigationGrid()
 local grid={}
 for x=-18,18 do for z=-16,16 do
  local wx,wz=x*16,z*16
  local blocked=false
  for _,rect in navigationRects do
   if math.abs(wx-rect[1])<rect[3] and math.abs(wz-rect[2])<rect[4] then blocked=true break end
  end
  if not blocked then
   for _,obstacle in navigationObstacles do
    if (wx-obstacle.x)^2+(wz-obstacle.z)^2<obstacle.radius^2 then blocked=true break end
   end
  end
  if not blocked then grid[gridKey(x,z)]={x=x,z=z,point=Vector3.new(wx,3.2,wz)} end
 end end
 return grid
end
local function planDeerPath(position,random)
 if not navigationGrid then navigationGrid=buildNavigationGrid() end
 local start,best=nil,math.huge
 for _,node in navigationGrid do
  local distance=(node.point-position).Magnitude
  if distance<best then start,best=node,distance end
 end
 if not start then return {} end
 local queue={start}
 local parents={[gridKey(start.x,start.z)]=false}
 local distant={}
 local cursor=1
 while cursor<=#queue do
  local node=queue[cursor] cursor+=1
  if (node.point-position).Magnitude>100 then table.insert(distant,node) end
  for _,offset in {{1,0},{-1,0},{0,1},{0,-1}} do
   local key=gridKey(node.x+offset[1],node.z+offset[2])
   if navigationGrid[key] and parents[key]==nil then
    parents[key]=node table.insert(queue,navigationGrid[key])
   end
  end
 end
 if #distant==0 then return {} end
 local goal=distant[math.floor(random:NextNumber(1,#distant+0.999))]
 local reversed={}
 local node=goal
 while node do table.insert(reversed,node.point) node=parents[gridKey(node.x,node.z)] end
 local path={}
 for i=#reversed,1,-1 do table.insert(path,reversed[i]) end
 return path
end
-- Eight reindeer can travel between distant reachable areas of the park.
local reindeer={}
local tourSleds={}
local deerRandom=Random.new(937)
local function detachSled(deer)
 if not deer.tow then return end
 local sled=deer.tow
 for _,object in deer.towParts do object:Destroy() end
 sled:SetAttribute("TowedBy",nil)
 deer.tow,deer.towParts=nil,nil
end
for index,center in {Vector3.new(-155,3.2,135),Vector3.new(150,3.2,125),Vector3.new(155,3.2,-140),Vector3.new(-160,3.2,-30),Vector3.new(-250,3.2,210),Vector3.new(245,3.2,215),Vector3.new(250,3.2,-210),Vector3.new(-250,3.2,-210)} do
 local model=Instance.new("Model") model.Name,model.Parent="Олень "..index,world
 local body=round("Тело оленя",Vector3.new(3.5,3.1,6),center,Color3.fromRGB(139,91,56),model)
 model.PrimaryPart=body
 round("Грудка",Vector3.new(2.5,2.9,2.2),center+Vector3.new(0,0,-2),Color3.fromRGB(194,158,111),model)
 rod("Шея",center+Vector3.new(0,0.5,-1.8),center+Vector3.new(0,2,-3.1),0.95,Color3.fromRGB(139,91,56),model)
 round("Голова оленя",Vector3.new(1.5,1.8,2.3),center+Vector3.new(0,2,-3.4),Color3.fromRGB(155,105,63),model)
 round("Нос оленя",Vector3.new(0.65,0.5,0.5),center+Vector3.new(0,1.9,-4.6),index==1 and red or Color3.fromRGB(47,35,31),model)
 local legs={}
 for _,side in ipairs({-1,1}) do
  round("Ухо оленя",Vector3.new(0.5,1,0.8),center+Vector3.new(side*0.85,2.8,-3),Color3.fromRGB(159,113,73),model)
  round("Глаз оленя",Vector3.new(0.16,0.2,0.2),center+Vector3.new(side*0.72,2.25,-4),Color3.fromRGB(20,25,29),model)
  local start=center+Vector3.new(side*0.5,2.8,-3)
  local tip=center+Vector3.new(side*1.2,4.5,-2.8)
  rod("Рог",start,tip,0.085,gold,model)
  for twig=1,3 do
   local a=start:Lerp(tip,twig/4)
   rod("Отросток рога",a,a+Vector3.new(side*0.55,0.55,0.1),0.06,gold,model)
  end
  for _,z in ipairs({-1.8,1.8}) do
   local offset=Vector3.new(side*0.95,-1.8,z)
   local leg=rod("Нога оленя",center+offset+Vector3.new(0,0.9,0),center+offset-Vector3.new(0,0.9,0),0.29,Color3.fromRGB(115,75,46),model)
   local hoof=round("Копытце",Vector3.new(0.55,0.5,0.7),center+offset-Vector3.new(0,0.8,0),Color3.fromRGB(53,44,39),model)
   table.insert(legs,{part=leg,hoof=hoof,offset=offset,phase=side*(z>0 and 1 or -1)})
  end
 end
 local deer={model=model,center=center,legs=legs,path={},waypoint=1,pauseUntil=0}
 table.insert(reindeer,deer)
 -- Each meadow has a small usable touring sled ready to hitch.
 local sled=Instance.new("Model") sled.Name,sled.Parent="Прогулочные санки",world
 local sledSeat=Instance.new("Seat")
 sledSeat.Name,sledSeat.Size,sledSeat.Anchored,sledSeat.CanTouch="Сиденье прогулочных санок",Vector3.new(3,0.5,3),true,false
 sledSeat.CFrame,sledSeat.Color,sledSeat.Parent=CFrame.new(center+Vector3.new(6,-1.6,6)),green,sled
 sled.PrimaryPart=sledSeat
 for _,side in ipairs({-1,1}) do
  local runner=part("Полозья",Vector3.new(0.25,0.3,4.4),sledSeat.Position+Vector3.new(side*1.4,-0.7,0),gold,Enum.Material.Metal,sled)
  runner.CustomPhysicalProperties=PhysicalProperties.new(1,0.12,0.05)
  runner.Anchored,runner.Massless=false,true
  local weld=Instance.new("WeldConstraint") weld.Part0,weld.Part1,weld.Parent=sledSeat,runner,runner
 end
 sledSeat.Anchored=false
 sledSeat:SetNetworkOwner(nil)
 sled:SetAttribute("Towable",true)
 table.insert(tourSleds,sled)
 prompt(sledSeat,"Сесть в санки • прыжок — выйти",function(player)
  local character=player.Character
  local humanoid=character and character:FindFirstChildOfClass("Humanoid")
  if not humanoid or humanoid.Health<=0 or humanoid.Sit or sledSeat.Occupant then return end
  if removeSkates then removeSkates(player) end
  character:PivotTo(sledSeat.CFrame*CFrame.new(0,2,0))
  sledSeat:Sit(humanoid)
 end)
 prompt(body,"Погладить оленя",function(player)
  deer.petUntil=os.clock()+3
  player:SetAttribute("WinterMessage","Олень доволен! ♥ E — погладить • F — прицепить санки")
  local gui=Instance.new("BillboardGui") gui.Size,gui.StudsOffset,gui.Parent=UDim2.fromOffset(70,50),Vector3.new(0,5,0),body
  local heart=Instance.new("TextLabel") heart.Size,heart.BackgroundTransparency,heart.Text,heart.TextSize=UDim2.fromScale(1,1),1,"♥",36
  heart.TextColor3,heart.Parent=red,gui
  Debris:AddItem(gui,2)
 end,"E")
 prompt(body,"Прицепить / отцепить ближайшие санки",function(player)
  if deer.tow then detachSled(deer) player:SetAttribute("WinterMessage","Санки отцеплены") return end
  local closest,distance=nil,30
  for _,candidate in world:GetChildren() do
   if candidate:IsA("Model") and candidate:GetAttribute("Towable") and not candidate:GetAttribute("TowedBy") and candidate.PrimaryPart then
    local d=(candidate.PrimaryPart.Position-body.Position).Magnitude
    if d<distance then closest,distance=candidate,d end
   end
  end
  if not closest then player:SetAttribute("WinterMessage","Подожди оленя у свободных санок: расстояние до 30 шагов") return end
  local a,b=Instance.new("Attachment"),Instance.new("Attachment")
  a.Position,b.Position=Vector3.new(0,-1.5,3),Vector3.new(0,0,-1.8)
  a.Parent,b.Parent=body,closest.PrimaryPart
  local rope=Instance.new("RopeConstraint")
  rope.Name,rope.Attachment0,rope.Attachment1="Упряжь",a,b
  rope.Length,rope.Thickness,rope.Visible=8,0.12,true
  rope.Parent=body
  closest:SetAttribute("TowedBy",model.Name)
  closest.PrimaryPart:SetNetworkOwner(nil)
  deer.tow,deer.towParts=closest,{rope,a,b}
  player:SetAttribute("WinterMessage","Санки прицеплены! Садись в них — олень повезёт по парку")
 end,"F")
end
local deerTime,deerTick=0,0
RunService.Heartbeat:Connect(function(dt)
 deerTime+=dt deerTick+=dt
 if deerTick<0.1 then return end deerTick=0
 for _,deer in reindeer do
  local current=deer.model:GetPivot().Position
  local target=deer.path[deer.waypoint]
  if target and (target-current).Magnitude<1 then
   deer.waypoint+=1 target=deer.path[deer.waypoint]
   if not target then deer.pauseUntil=os.clock()+deerRandom:NextNumber(0.5,1.5) end
  end
  if not target and os.clock()>=deer.pauseUntil then
   deer.path=planDeerPath(current,deerRandom) deer.waypoint=1
   target=deer.path[1]
  end
  target=target or current
  local speed=deer.tow and 6.5 or 8.2
  if deer.petUntil and os.clock()<deer.petUntil then target=current end
  local delta=Vector3.new(target.X-current.X,0,target.Z-current.Z)
  local movement=delta.Magnitude>0.01 and delta.Unit*math.min(delta.Magnitude,speed*0.1) or Vector3.zero
  local params=RaycastParams.new()
  params.FilterType=Enum.RaycastFilterType.Exclude
  local exclude={deer.model}
  if deer.tow then table.insert(exclude,deer.tow) end
  params.FilterDescendantsInstances=exclude
  if movement.Magnitude>0.01 and workspace:Raycast(current,movement.Unit*3,params) then movement=Vector3.zero
   deer.blockedFor=(deer.blockedFor or 0)+0.1
   if deer.blockedFor>1 then deer.path={} deer.pauseUntil=os.clock()+0.3 deer.blockedFor=0 end end
  local pos=Vector3.new(math.clamp(current.X+movement.X,-302,302),3.2,math.clamp(current.Z+movement.Z,-272,272))
  if math.abs(pos.X+105)<32 and math.abs(pos.Z-75)<26 then pos=current movement=Vector3.zero end
  local direction=movement.Magnitude>0.01 and movement.Unit or deer.model:GetPivot().LookVector
  local frame=CFrame.lookAt(pos,pos+direction)
  deer.model:PivotTo(frame)
  for _,leg in deer.legs do
   leg.part.CFrame=frame*CFrame.new(leg.offset)*CFrame.Angles((movement.Magnitude>0.01 and math.sin(deerTime*4+leg.phase*math.pi/2)*0.25 or 0),0,math.pi/2)
   leg.hoof.CFrame=leg.part.CFrame*CFrame.new(-0.8,0,0)*CFrame.Angles(0,0,-math.pi/2)
  end
 end
end)
-- Winter park: rounded drifts, a frozen pond and three guided sled routes.
local random=Random.new(2026)
for i=1,65 do
 local x=(i%2==0 and -1 or 1)*random:NextNumber(95,290)
 local z=random:NextNumber(-258,258)
 if math.abs(x+105)<40 and math.abs(z-75)<36 then z=-150 end
 for _,center in snowLoungeCenters do
  if math.abs(x-center.X)<20 and math.abs(z-center.Z)<20 then z=center.Z>0 and -250 or 250 end
 end
 local drift=ball("Сугроб",1,Vector3.new(x,-0.6,z),snow)
 drift.Size=Vector3.new(random:NextNumber(9,20),random:NextNumber(3,7),random:NextNumber(9,20))
 drift.Material=Enum.Material.Snow
 table.insert(navigationObstacles,{x=x,z=z,radius=12})
end
local snowLounges={}
for index,center in snowLoungeCenters do
 table.insert(navigationRects,{center.X,center.Z,13,13})
 local zone=part("Мягкий сугроб "..index,Vector3.new(12,6,12),center+Vector3.new(0,2,0),snow)
 zone.Transparency,zone.CanCollide=1,false
 for lobe=1,6 do
  local angle=lobe*math.pi/3
  local mound=round("Пушистый край сугроба",Vector3.new(6,3.8,6),center+Vector3.new(math.cos(angle)*5,0.8,math.sin(angle)*5),snow)
  mound.Material=Enum.Material.Snow
 end
 part("Снежная подушка",Vector3.new(7,0.3,7),center+Vector3.new(0,0.15,0),snow,Enum.Material.Snow)
 local seats={}
 for _,offset in ipairs({-1.7,1.7}) do
  local seat=Instance.new("Seat")
  seat.Name,seat.Size,seat.Anchored,seat.CanTouch,seat.CanCollide,seat.Transparency="Отдых в снегу",Vector3.new(2,0.4,2),true,false,false,1
  seat.Position,seat.Parent=center+Vector3.new(offset,0.8,0),world
  table.insert(seats,seat)
 end
 local puff=Instance.new("ParticleEmitter")
 puff.Texture,puff.Rate,puff.Lifetime="rbxasset://textures/particles/sparkles_main.dds",0,NumberRange.new(0.4,0.9)
 puff.Speed,puff.SpreadAngle,puff.Size=NumberRange.new(3,8),Vector2.new(180,180),NumberSequence.new(0.2)
 puff.Parent=zone
 local function relax(player)
  local character=player.Character
  local humanoid=character and character:FindFirstChildOfClass("Humanoid")
  if not humanoid or humanoid.Health<=0 or humanoid.Sit then return end
  for _,seat in seats do
   if not seat.Occupant then
    if removeSkates then removeSkates(player) end
    local root=character:FindFirstChild("HumanoidRootPart")
    if root then root.AssemblyLinearVelocity=Vector3.zero end
    character:PivotTo(seat.CFrame*CFrame.new(0,2,0))
    seat:Sit(humanoid)
    puff:Emit(35)
    sound(zone,"rbxasset://sounds/action_footsteps_plastic.mp3",0.25)
    player:SetAttribute("WinterMessage","Плюх! Устраивайся в снегу ☃ Прыжок — выйти")
    return
   end
  end
 end
 prompt(zone,"Плюхнуться и отдохнуть",relax)
 sign(zone,"МЯГКИЙ СУГРОБ • прыгай или нажми E",Vector3.new(0,4,0))
 zone.Touched:Connect(function(hit)
  local player=Players:GetPlayerFromCharacter(hit.Parent)
  local root=player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")
  if root and root.AssemblyLinearVelocity.Y< -5 then relax(player) end
 end)
 table.insert(snowLounges,{zone=zone,seats=seats,puff=puff})
end
local pond=part("Ледяной каток",Vector3.new(58,1,45),Vector3.new(-105,1.15,75),Color3.fromRGB(102,183,213),Enum.Material.Ice)
pond.Reflectance=0.55
pond.CustomPhysicalProperties=PhysicalProperties.new(0.7,0.005,0.05)
sign(pond,"КАТОК • коньки у входа",Vector3.new(0,4,0))
for _,dx in ipairs({-29,29}) do
 part("Бортик катка",Vector3.new(1,4.8,47),Vector3.new(-105+dx,4.05,75),snow)
end
for _,dx in ipairs({-16.5,16.5}) do
 part("Передний бортик",Vector3.new(25,4.8,1),Vector3.new(-105+dx,4.05,97.5),snow)
end
part("Задний бортик",Vector3.new(59,4.8,1),Vector3.new(-105,4.05,52.5),snow)
for _,fence in world:GetChildren() do
 if fence.Name=="Бортик катка" or fence.Name=="Передний бортик" or fence.Name=="Задний бортик" then
  fence.Material,fence.Transparency=Enum.Material.Glass,0.35
  part("Поручень катка",Vector3.new(fence.Size.X+0.2,0.35,fence.Size.Z+0.2),fence.Position+Vector3.new(0,2.4,0),red)
 end
end
part("Ступень катка",Vector3.new(16,0.8,4),Vector3.new(-105,0.4,100),snow)
for i=1,7 do
 local line=part("Узор на льду",Vector3.new(0.08,0.025,10+i),Vector3.new(-128+i*6,1.68,66+i%3*7),Color3.fromRGB(192,231,244),Enum.Material.Glass)
 line.Orientation=Vector3.new(0,i*37,0)
 line.Transparency,line.CanCollide=0.3,false
end
local rack=part("Прокат коньков",Vector3.new(5,3,2),Vector3.new(-94,1.5,103),green,Enum.Material.Wood)
sign(rack,"КОНЬКИ • E надеть / снять")
local slipStates={}
local skateColors={Color3.fromRGB(206,61,80),Color3.fromRGB(62,145,212),Color3.fromRGB(112,184,137),Color3.fromRGB(162,106,209),Color3.fromRGB(235,164,64),Color3.fromRGB(227,119,178)}
local skateRandom=Random.new()
local lastSkateColor={}

local wasOnIce={}
removeSkates=function(player)
 player:SetAttribute("SkatesEquipped",false)
 wasOnIce[player]=nil
 local character=player.Character
 local humanoid=character and character:FindFirstChildOfClass("Humanoid")
 if humanoid then humanoid.WalkSpeed=16 humanoid.AutoRotate=true humanoid.PlatformStand=false end
 local root=character and character:FindFirstChild("HumanoidRootPart")
 if root then
  for _,child in root:GetChildren() do if child.Name=="SkatingMomentum" then child:Destroy() end end
  root.AssemblyLinearVelocity=Vector3.new(0,root.AssemblyLinearVelocity.Y,0)
  root.AssemblyAngularVelocity=Vector3.zero
 end
 local gear=player.Character and player.Character:FindFirstChild("SkateGear")
 if gear then gear:Destroy() end
end
local removeSkatesEvent=Instance.new("RemoteEvent")
removeSkatesEvent.Name,removeSkatesEvent.Parent="RemoveSkates",ReplicatedStorage
removeSkatesEvent.OnServerEvent:Connect(removeSkates)
prompt(rack,"Надеть / снять коньки",function(player)
 if player:GetAttribute("SkatesEquipped") then removeSkates(player) return end
 local character=player.Character
 local humanoid=character and character:FindFirstChildOfClass("Humanoid")
 if not humanoid or humanoid.Health<=0 then return end
 -- Remove stale gear and recover a fallen humanoid before starting a new session.
 removeSkates(player)
 humanoid.WalkSpeed,humanoid.AutoRotate,humanoid.PlatformStand=16,true,false
 humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
 local previous=lastSkateColor[player] or 0
 local colorIndex
 repeat colorIndex=math.floor(skateRandom:NextNumber(1,#skateColors+0.999)) until colorIndex~=previous
 lastSkateColor[player]=colorIndex
 local bootColor=skateColors[colorIndex]
 local gear=Instance.new("Model") gear.Name,gear.Parent="SkateGear",character
 gear:SetAttribute("ColorIndex",colorIndex)
 for _,side in ipairs({"Left","Right"}) do
  local foot=character:FindFirstChild(side.."Foot") or character:FindFirstChild(side.." Leg")
  if foot then
   local offset=foot.Name==side.."Foot" and -0.45 or -1.1
   local blade=part("Лезвие конька",Vector3.new(0.18,0.3,1.9),Vector3.zero,Color3.fromRGB(202,219,230),Enum.Material.Metal,gear)
   blade.CFrame=foot.CFrame*CFrame.new(0,offset,0)
   blade.Anchored,blade.CanCollide,blade.Massless=false,false,true
   local weld=Instance.new("WeldConstraint") weld.Part0,weld.Part1,weld.Parent=foot,blade,blade
   local left,right=Instance.new("Attachment"),Instance.new("Attachment")
   left.Position,right.Position=Vector3.new(-0.09,-0.13,0.6),Vector3.new(0.09,-0.13,0.6)
   left.Parent,right.Parent=blade,blade
   local trace=Instance.new("Trail")
   trace.Name,trace.Attachment0,trace.Attachment1="IceTrace",left,right
   trace.Lifetime,trace.LightEmission,trace.Enabled=1.2,0.35,false
   trace.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0.25),NumberSequenceKeypoint.new(1,1)})
   trace.Parent=blade
   local spray=Instance.new("ParticleEmitter")
   spray.Name,spray.Texture="IceSpray","rbxasset://textures/particles/sparkles_main.dds"
   spray.Enabled,spray.Rate,spray.Lifetime=false,22,NumberRange.new(0.15,0.4)
   spray.Speed,spray.Size=NumberRange.new(2,5),NumberSequence.new(0.08)
   spray.Acceleration,spray.SpreadAngle=Vector3.new(0,-10,0),Vector2.new(40,40)
   spray.Parent=left
   local boot=part("Ботинок конька",Vector3.new(1.1,0.85,1.8),Vector3.zero,bootColor,nil,gear)
   boot.Shape=Enum.PartType.Ball
   boot.CFrame=foot.CFrame*CFrame.new(0,offset+0.55,-0.1)
   boot.Anchored,boot.CanCollide,boot.Massless=false,false,true
   local binding=Instance.new("WeldConstraint") binding.Part0,binding.Part1,binding.Parent=foot,boot,boot
   local function bootDetail(name,size,position,color)
    local detail=part(name,size,Vector3.zero,color,nil,gear)
    detail.CFrame=foot.CFrame*CFrame.new(position)
    detail.Anchored,detail.CanCollide,detail.Massless=false,false,true
    local link=Instance.new("WeldConstraint") link.Part0,link.Part1,link.Parent=foot,detail,detail
    return detail
   end
   bootDetail("Подошва конька",Vector3.new(1.08,0.16,1.8),Vector3.new(0,offset+0.21,-0.1),Color3.fromRGB(43,47,58))
   local cuff=bootDetail("Высокий манжет",Vector3.new(0.98,0.85,0.95),Vector3.new(0,offset+1.02,0.25),bootColor)
   cuff.Shape=Enum.PartType.Ball
   for i=1,3 do
    bootDetail("Шнуровка",Vector3.new(0.6,0.06,0.1),Vector3.new(0,offset+0.92,0.35-i*0.25),snow)
   end
  end
 end
 player:SetAttribute("SkateSession",(player:GetAttribute("SkateSession") or 0)+1)
 player:SetAttribute("SkatesEquipped",true)
 player:SetAttribute("WinterMessage","Коньки надеты! На льду разгоняйся клавишами движения")
end)
RunService.Heartbeat:Connect(function()
 for _,player in Players:GetPlayers() do
  local character=player.Character
  local root=character and character:FindFirstChild("HumanoidRootPart")
  local humanoid=character and character:FindFirstChildOfClass("Humanoid")
  if root and humanoid and humanoid.Health>0 then
   local pos=root.Position
   local onIce=math.abs(pos.X+105)<28 and math.abs(pos.Z-75)<21 and pos.Y>1 and pos.Y<9
   local inBounds=math.abs(pos.X+105)<28.5 and math.abs(pos.Z-75)<21.5
   if player:GetAttribute("SkatesEquipped") then
    if inBounds then wasOnIce[player]=true elseif wasOnIce[player] then removeSkates(player) end
   end
   if not inBounds and humanoid.PlatformStand and slipStates[player] then
    humanoid.PlatformStand=false humanoid.WalkSpeed=16 humanoid.AutoRotate=true
    root.AssemblyAngularVelocity=Vector3.zero
   end
   if onIce and not player:GetAttribute("SkatesEquipped") and os.clock()-(slipStates[player] or -10)>3 then
    slipStates[player]=os.clock()
    humanoid.PlatformStand=true
    root.AssemblyAngularVelocity=Vector3.new(0,0,5)
    root.AssemblyLinearVelocity=root.CFrame.LookVector*12+Vector3.new(0,2,0)
    player:SetAttribute("WinterMessage","Скользко! Возьми коньки у входа на каток")
    task.delay(1.1,function()
     if humanoid.Parent and player.Character==character then
      humanoid.PlatformStand=false
      root.AssemblyAngularVelocity=Vector3.zero
      humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
     end
    end)
   end
  end
 end
end)
local function initializePlayer(player)
 player.CharacterAdded:Connect(function()
  player:SetAttribute("SkatesEquipped",false)
  slipStates[player],wasOnIce[player]=nil,nil
 end)
end
Players.PlayerAdded:Connect(initializePlayer)
for _,player in Players:GetPlayers() do initializePlayer(player) end
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
  sled:SetAttribute("Towable",true)
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
  if sled:GetAttribute("TowedBy") or not freeSled or seat.Occupant or seat.AssemblyLinearVelocity.Magnitude>1.5 then return end
  for _,weld in seat:GetChildren() do if weld:IsA("WeldConstraint") then weld:Destroy() end end
  for _,p in sled:GetDescendants() do if p:IsA("BasePart") then p.Anchored=true end end
  sled:PivotTo(home)
  sled:SetAttribute("Towable",false)
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
local snowmanPlots={}
local required={"Палочки","Морковка","Ведёрко"}
local ingredientAttributes={["Палочки"]="InventorySticks",["Морковка"]="InventoryCarrot",["Ведёрко"]="InventoryBucket"}
local function inventory(player)
 if not inventories[player] then inventories[player]={} end
 return inventories[player]
end
for index,name in required do
 for copy=1,3 do
  local pos=Vector3.new(-150+(index-1)*20+copy*7,0.7,-30+(copy-1)*17)
  local item
  if name=="Палочки" then item=branch(Vector3.new(pos.X,0.3,pos.Z),world)
  elseif name=="Морковка" then item=carrot(Vector3.new(pos.X,0.35,pos.Z),world)
  else item=bucket(Vector3.new(pos.X,0.8,pos.Z),world) end
  item:SetAttribute("IngredientKey",ingredientAttributes[name])
  for _,detail in item:GetDescendants() do
   if detail:IsA("BasePart") then detail:SetAttribute("IngredientKey",ingredientAttributes[name]) end
  end
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
 local collection=builtByPlayer[player] or {}
 if #collection>=6 then player:SetAttribute("WinterMessage","У тебя уже 6 снеговиков. Убери одного через его подсказку") return end
 local plot
 for i=1,24 do if not snowmanPlots[i] then plot=i break end end
 if not plot then player:SetAttribute("WinterMessage","Поляна заполнена снеговиками") return end
 local model=Instance.new("Model")
 model.Name,model.Parent="Снеговик "..player.Name,world
 table.insert(collection,model)
 builtByPlayer[player]=collection
 snowmanPlots[plot]=model
 model:SetAttribute("PlotIndex",plot)
 local x,z=-125+((plot-1)%6)*7,-72+math.floor((plot-1)/6)*7
 local function piece(name,size,pos,color)
  local p=part(name,size,pos,color,nil,model)
  return p
 end
 local function snowBall(size,y)
  local p=piece("Снежный ком",Vector3.new(size,size,size),Vector3.new(x,y,z),snow)
  p.Shape=Enum.PartType.Ball
  if not model.PrimaryPart then model.PrimaryPart=p end
 end
 snowBall(4,2) snowBall(3,4.8) snowBall(2,7)
 for _,side in ipairs({-1,1}) do
  local arm=piece("Палочка",Vector3.new(0.2,0.2,3),Vector3.new(x+side*2.4,4.8,z),Color3.fromRGB(100,65,37))
  arm.Orientation=Vector3.new(0,side*65,side*20)
  local eye=piece("Уголёк",Vector3.new(0.18,0.18,0.18),Vector3.new(x+side*0.35,7.2,z+0.95),Color3.fromRGB(25,30,35))
  eye.Shape=Enum.PartType.Ball
 end
 carrot(Vector3.new(x,6.95,z+1.3),model,0.65,true)
 bucket(Vector3.new(x,8.2,z),model,0.85)
 prompt(model.PrimaryPart,"Убрать своего снеговика",function(owner)
  if owner~=player then return end
  local index=table.find(collection,model)
  if index then table.remove(collection,index) end
  snowmanPlots[plot]=nil
  model:Destroy()
 end)
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
    for layer=1,2 do
     local crunch=Instance.new("Sound")
     crunch.SoundId,crunch.Volume,crunch.RollOffMaxDistance="rbxasset://sounds/action_footsteps_plastic.mp3",0.45/layer,55
     crunch.PlaybackSpeed=layer==1 and 0.85 or 1.6
     crunch.TimePosition=0.03*layer
     crunch.Parent=projectile
     local equalizer=Instance.new("EqualizerSoundEffect")
     equalizer.LowGain,equalizer.MidGain,equalizer.HighGain=-14,4,-2
     equalizer.Parent=crunch
     crunch:Play()
     task.delay(0.15,function() if crunch.Parent then crunch:Stop() end end)
    end
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
 if builtByPlayer[player] then
  for _,model in builtByPlayer[player] do snowmanPlots[model:GetAttribute("PlotIndex")]=nil model:Destroy() end
  builtByPlayer[player]=nil
 end
 slipStates[player]=nil
 lastSkateColor[player]=nil wasOnIce[player]=nil

end)
