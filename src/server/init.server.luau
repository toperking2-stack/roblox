-- Winter Village: generated entirely from Roblox parts; no external assets.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
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
 gui.Size, gui.StudsOffset = UDim2.fromOffset(300, 85), offset or Vector3.new(0,5,0)
 gui.MaxDistance = 100
 gui.Parent = on
 local label = Instance.new("TextLabel")
 label.Size = UDim2.fromScale(1,1)
 label.BackgroundColor3, label.BackgroundTransparency = Color3.fromRGB(22,39,58), 0.2
 label.TextColor3, label.TextSize = snow, 19
 label.Font, label.TextWrapped = Enum.Font.GothamBold, true
 label.Text = text
 label.Parent = gui
end
local function prompt(on, text, callback)
 local p = Instance.new("ProximityPrompt")
 p.ActionText, p.ObjectText, p.MaxActivationDistance = text, on.Name, 10
 p.RequiresLineOfSight = false
 p.Parent = on
 p.Triggered:Connect(callback)
end
local function light(on, color, range, brightness)
 local l = Instance.new("PointLight")
 l.Color, l.Range, l.Brightness = color, range, brightness or 1
 l.Parent = on
end
local function tree(x,z,height)
 part("Ствол", Vector3.new(2,height/2,2), Vector3.new(x,height/4,z), Color3.fromRGB(97,64,47), Enum.Material.Wood)
 for i=1,3 do
  local width = height*(0.95-i*0.19)
  local p = part("Еловая крона", Vector3.new(width,height/3,width), Vector3.new(x,height*(0.3+i*0.18),z),green)
  part("Снег на ветках",Vector3.new(width+0.3,0.45,width+0.3),p.Position+Vector3.new(0,height/6,0),snow)
 end
end
part("Снежный остров",Vector3.new(180,5,150),Vector3.new(0,-2.5,0),snow,Enum.Material.Snow)
part("Дорожка",Vector3.new(12,0.15,115),Vector3.new(0,0.1,0),Color3.fromRGB(186,211,229),Enum.Material.Ice)
local spawn = Instance.new("SpawnLocation")
spawn.Name, spawn.Size, spawn.Position = "Добро пожаловать", Vector3.new(8,1,8), Vector3.new(0,0.5,50)
spawn.Neutral, spawn.Anchored, spawn.Color = true,true,green
spawn.Parent = world
sign(spawn,"НОВОГОДНЯЯ ДЕРЕВНЯ\nОбби • снежки • чай у камина")
tree(0,-12,27)
for i=1,20 do
 local a=i*math.pi*2/20
 local y=5+(i%4)*4
 local r=9-y*0.2
 local ornament=ball("Гирлянда",1,Vector3.new(math.cos(a)*r,y, -12+math.sin(a)*r),i%2==0 and gold or red)
 ornament.Material=Enum.Material.Neon
 if i%4==0 then light(ornament,gold,12) end
end
local star=ball("Звезда",2.5,Vector3.new(0,27,-12),gold)
star.Material=Enum.Material.Neon
light(star,gold,35,2)
for i=1,8 do
 local x=(i%2==0 and 1 or -1)*(7+i%3*3)
 local gift=part("Подарок",Vector3.new(3,2.5,3),Vector3.new(x,1.25,-12+(i%4)*3),i%2==0 and red or green)
 part("Лента",Vector3.new(0.4,2.6,3.1),gift.Position,gold)
end
for i=1,14 do
 tree(-81+(i%2)*160,-65+math.floor((i-1)/2)*20,12+i%3*3)
end
-- Open doorway, usable interior and furniture.
local function house(x,z,main)
 local brown=Color3.fromRGB(151,91,61)
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
 part("Снежная крыша",Vector3.new(31,2,29),Vector3.new(x,13,z),snow)
 for i=-3,3 do
  local bulb=ball("Лампочка",0.7,Vector3.new(x+i*4,11.5,z+14),i%2==0 and red or gold)
  bulb.Material=Enum.Material.Neon
 end
 local hearth=part("Камин",Vector3.new(8,5,3),Vector3.new(x,3,z-10),Color3.fromRGB(78,61,67),Enum.Material.Brick)
 local fire=Instance.new("Fire")
 fire.Size,fire.Heat,fire.Parent=3,0,hearth
 light(hearth,Color3.fromRGB(255,143,69),25,2)
 for _,dx in ipairs({-8,8}) do
  local seat=Instance.new("Seat")
  seat.Size,seat.Position,seat.Anchored=Vector3.new(4,1,4),Vector3.new(x+dx,2,z),true
  seat.Color,seat.Parent=red,world
  part("Спинка кресла",Vector3.new(4,4,1),Vector3.new(x+dx,3,z+2),red)
 end
 local tableTop=part("Стол с чаем",Vector3.new(6,0.5,4),Vector3.new(x,2.5,z+3),brown,Enum.Material.Wood)
 part("Ножка стола",Vector3.new(1,2.5,1),Vector3.new(x,1.25,z+3),brown)
 sign(tableTop,main and "УЮТНЫЙ ДОМ\nСогрейся и выпей чаю" or "ПРЯНИЧНЫЙ ДОМИК",Vector3.new(0,4,0))
 prompt(tableTop,"Взять чай",function(player)
  if player.Backpack:FindFirstChild("Горячий чай") or (player.Character and player.Character:FindFirstChild("Горячий чай")) then return end
  local tool=Instance.new("Tool")
  tool.Name="Горячий чай"
  local cup=Instance.new("Part")
  cup.Name,cup.Size,cup.Color,cup.CanCollide="Handle",Vector3.new(0.7,0.8,0.7),snow,false
  cup.Parent=tool
  local steam=Instance.new("Smoke")
  steam.Size,steam.Opacity,steam.RiseVelocity,steam.Parent=0.3,0.15,2,cup
  tool.Parent=player.Backpack
 end)
end
house(-43,-22,true)
house(58,-40,false)
-- Friendly Santa, no uploaded character assets.
local santa=part("Санта-Клаус",Vector3.new(4,5,2),Vector3.new(23,3,-10),red)
ball("Голова Санты",2.7,Vector3.new(23,6.7,-10),Color3.fromRGB(247,209,180))
ball("Борода",2,Vector3.new(23,6,-8.9),snow)
part("Шапка",Vector3.new(3,1.8,3),Vector3.new(23,8.6,-10),red)
ball("Помпон",1,Vector3.new(23,9.8,-10),snow)
sign(santa,"САНТА\nС праздником! Подарки ждут на финише.")
prompt(santa,"Поздороваться",function(player) player:SetAttribute("SantaGreeting",(player:GetAttribute("SantaGreeting") or 0)+1) end)
-- A looping route along the eastern edge. All jumps are <= 8 studs center to center.
local checkpoints={}
for i=1,15 do
 local pos=Vector3.new(25+(i%2)*5,2+(i%3)*0.5,62-(i-1)*7.8)
 local p=part("Этап "..i,Vector3.new(6,1,6),pos,i%3==0 and green or (i%2==0 and snow or red),i%3==0 and Enum.Material.SmoothPlastic or Enum.Material.Ice)
 checkpoints[i]=pos+Vector3.new(0,4,0)
 sign(p,i==15 and "15 / 15 — ФИНИШ!" or tostring(i).." / 15",Vector3.new(0,2,0))
 p.Touched:Connect(function(hit)
  local player=Players:GetPlayerFromCharacter(hit.Parent)
  if not player then return end
  local current=player:GetAttribute("Checkpoint") or 0
  if i==current+1 then
   player:SetAttribute("Checkpoint",i)
   if player:FindFirstChild("leaderstats") then player.leaderstats.Stage.Value=i end
  end
 end)
end
sign(world:FindFirstChild("Этап 1"),"СТАРТ ОББИ\n15 этапов • прогресс до выхода",Vector3.new(0,6,0))
-- Catch falls off the elevated course; the route is above a trench, not the village ground.
local catch=part("Возврат на этап",Vector3.new(14,1,125),Vector3.new(27.5,0.2,7),Color3.fromRGB(130,185,216))
catch.Transparency=0.6
catch.Touched:Connect(function(hit)
 local character=hit.Parent
 local player=Players:GetPlayerFromCharacter(character)
 if player and character:FindFirstChild("HumanoidRootPart") then
  local t=os.clock()
  if t-(player:GetAttribute("LastReturn") or 0)>1 then
   player:SetAttribute("LastReturn",t)
   character:PivotTo(CFrame.new(checkpoints[player:GetAttribute("Checkpoint") or 0] or Vector3.new(25,5,69)))
  end
 end
end)
local arena=part("Снежковая площадка",Vector3.new(35,0.2,30),Vector3.new(-40,0.2,43),Color3.fromRGB(206,229,243),Enum.Material.Snow)
sign(arena,"СНЕЖКИ БЕЗ УРОНА\nВозьми снежок • нажми, чтобы бросить")
local remote=Instance.new("RemoteEvent")
remote.Name,remote.Parent="ThrowSnowball",ReplicatedStorage
local lastThrow={}
prompt(arena,"Взять снежки",function(player)
 if player.Backpack:FindFirstChild("Снежки") or (player.Character and player.Character:FindFirstChild("Снежки")) then return end
 local tool=Instance.new("Tool")
 tool.Name,tool.RequiresHandle="Снежки",false
 tool.Parent=player.Backpack
end)
remote.OnServerEvent:Connect(function(player,target)
 if typeof(target)~="Vector3" or target.X~=target.X or target.Y~=target.Y or target.Z~=target.Z or target.Magnitude>100000 then return end
 local character=player.Character
 local root=character and character:FindFirstChild("HumanoidRootPart")
 if not root or not character:FindFirstChild("Снежки") or os.clock()-(lastThrow[player] or 0)<0.7 then return end
 local direction=target-root.Position
 if direction.Magnitude<0.1 then return end
 lastThrow[player]=os.clock()
 local projectile=ball("Снежок",0.9,root.Position+Vector3.new(0,2,0)+direction.Unit*3,snow)
 projectile.Anchored,projectile.CanCollide=false,false
 projectile:SetNetworkOwner(nil)
 projectile.AssemblyLinearVelocity=direction.Unit*75+Vector3.new(0,15,0)
 projectile.Touched:Connect(function(hit)
  if hit:IsDescendantOf(character) then return end
  projectile:Destroy()
 end)
 Debris:AddItem(projectile,4)
end)
Players.PlayerAdded:Connect(function(player)
 player:SetAttribute("Checkpoint",0)
 local stats=Instance.new("Folder")
 stats.Name,stats.Parent="leaderstats",player
 local stage=Instance.new("IntValue")
 stage.Name,stage.Parent="Stage",stats
 player.CharacterAdded:Connect(function(character)
  character:WaitForChild("HumanoidRootPart")
  local cp=player:GetAttribute("Checkpoint") or 0
  if checkpoints[cp] then character:PivotTo(CFrame.new(checkpoints[cp])) end
 end)
end)
Players.PlayerRemoving:Connect(function(player) lastThrow[player]=nil end)
