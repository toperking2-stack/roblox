local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local mouse=player:GetMouse()
local TweenService=game:GetService("TweenService")
local UserInputService=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local gui=Instance.new("ScreenGui")
gui.Name,gui.ResetOnSpawn="WinterHUD",false
gui.Parent=player:WaitForChild("PlayerGui")
local label=Instance.new("TextLabel")
label.Size,label.Position=UDim2.new(0,310,0,54),UDim2.new(0,16,1,-118)
label.BackgroundColor3,label.BackgroundTransparency=Color3.fromRGB(20,39,55),0.15
label.TextColor3,label.Font,label.TextSize=Color3.fromRGB(255,239,205),Enum.Font.GothamBold,14
label.TextWrapped=true
label.Parent=gui
local corner=Instance.new("UICorner")
corner.CornerRadius=UDim.new(0,12)
corner.Parent=label
local ingredientAttributes={["Палочки"]="InventorySticks",["Морковка"]="InventoryCarrot",["Ведёрко"]="InventoryBucket"}
local function update()
 local size=player:GetAttribute("SnowSize") or 0
 local found={}
 for _,name in {"Палочки","Морковка","Ведёрко"} do
  if player:GetAttribute(ingredientAttributes[name]) then table.insert(found,name) end
 end
 label.Text="❄ ЗИМНИЙ ПАРК • v9 ❄\n"..(size>0 and ("Ком: "..size.." / 4 м • Q — оставить") or "E — взаимодействие • снежки наносят урон")
 if #found>0 then label.Text..="\n"..table.concat(found," • ") end
 if player:GetAttribute("DeerCarrots") then label.Text..="\nМорковок для оленя: "..player:GetAttribute("DeerCarrots") end
end
label.Size=UDim2.new(0,330,0,78)
update()
for _,name in {"SnowSize","InventorySticks","InventoryCarrot","InventoryBucket","DeerCarrots"} do player:GetAttributeChangedSignal(name):Connect(update) end
player:GetAttributeChangedSignal("WinterMessage"):Connect(function()
 label.Text=player:GetAttribute("WinterMessage") or ""
 task.delay(4,update)
end)
local drop=Instance.new("TextButton")
drop.Text,drop.Size,drop.Position="Оставить ком",UDim2.fromOffset(140,38),UDim2.new(1,-155,1,-170)
drop.BackgroundColor3,drop.TextColor3=Color3.fromRGB(30,60,80),Color3.new(1,1,1)
drop.Parent=gui
local function dropBall() ReplicatedStorage:WaitForChild("StopRollingSnow"):FireServer() end
drop.Activated:Connect(dropBall)
player:GetAttributeChangedSignal("SnowSize"):Connect(function() drop.Visible=(player:GetAttribute("SnowSize") or 0)>0 end)
drop.Visible=false
UserInputService.InputBegan:Connect(function(input,processed)
 if not processed and input.KeyCode==Enum.KeyCode.Q then dropBall() end
end)
local dialogue=Instance.new("Frame")
dialogue.Size,dialogue.Position,dialogue.AnchorPoint=UDim2.new(0.9,0,0,340),UDim2.fromScale(0.5,0.5),Vector2.new(0.5,0.5)
dialogue.BackgroundColor3,dialogue.Visible=Color3.fromRGB(24,47,57),false
dialogue.Parent=gui
local limit=Instance.new("UISizeConstraint") limit.MaxSize=Vector2.new(430,340) limit.Parent=dialogue
local rounding=Instance.new("UICorner") rounding.CornerRadius=UDim.new(0,14) rounding.Parent=dialogue
local speech=Instance.new("TextLabel")
speech.Size,speech.Position=UDim2.new(1,-32,0,142),UDim2.fromOffset(16,12)
speech.BackgroundTransparency,speech.TextWrapped,speech.TextSize=1,true,17
speech.Font,speech.TextColor3=Enum.Font.Gotham,Color3.fromRGB(255,239,214)
speech.Parent=dialogue
local answers={
 {"Как кататься на коньках?","🎅 Дед Мороз\nВозьми коньки у зелёного проката перед катком. На льду двигайся обычными клавишами: разгон и торможение плавные. Без коньков поскользнёшься! Для выхода есть проход у проката; X снимает коньки в любом месте."},
 {"Как собрать снеговика?","🎅 Дед Мороз\nНайди веточки, морковку и ведёрко. Накатай ком до 4 метров и принеси его на поляну снеговиков. Можно построить несколько — у каждого своя подсказка удаления."},
 {"Как подружиться с оленем?","🎅 Дед Мороз\nЭто мои олени! Возьми морковки из мешочка на боку оленя, выбери морковку и нажми рядом с ним. Он пойдёт за тобой — можно привести к камину и угощать, пока ты пьёшь чай. Без упряжи или друга олени ждут санки."},
 {"До встречи!",false},
}
for i,answer in answers do
 local button=Instance.new("TextButton")
 button.Size,button.Position=UDim2.new(1,-32,0,36),UDim2.fromOffset(16,154+(i-1)*43)
 button.BackgroundColor3,button.TextColor3=Color3.fromRGB(50,91,86),Color3.fromRGB(255,246,226)
 button.Text,button.TextSize,button.Font=answer[1],15,Enum.Font.GothamBold
 button.Parent=dialogue
 button.Activated:Connect(function()
  if answer[2] then speech.Text=answer[2] else dialogue.Visible=false end
 end)
end
player:GetAttributeChangedSignal("SantaGreeting"):Connect(function()
 speech.Text="🎅 Дед Мороз\nС праздником, друг! Заходи погреться, прокатись по льду или слепи снеговика. О чём хочешь спросить?"
 dialogue.Visible=true
end)
-- Public-domain Jingle Bells melody, arranged from built-in bell-like notes.
local SoundService=game:GetService("SoundService")
local musicGroup=Instance.new("SoundGroup")
musicGroup.Name,musicGroup.Volume,musicGroup.Parent="HolidayMusic",0.055,SoundService
local musicToggle=Instance.new("TextButton")
musicToggle.Size,musicToggle.Position=UDim2.fromOffset(144,32),UDim2.new(1,-160,0,14)
musicToggle.Text,musicToggle.TextSize="♫ Музыка: вкл",14
musicToggle.BackgroundColor3,musicToggle.TextColor3=Color3.fromRGB(28,55,67),Color3.fromRGB(255,239,214)
musicToggle.Parent=gui
musicToggle.Activated:Connect(function()
 musicGroup.Volume=musicGroup.Volume>0 and 0 or 0.055
 musicToggle.Text=musicGroup.Volume>0 and "♫ Музыка: вкл" or "♫ Музыка: выкл"
end)
local tune={
 {76,1},{76,1},{76,2},{76,1},{76,1},{76,2},
 {76,1},{79,1},{72,1.5},{74,0.5},{76,4},
 {77,1},{77,1},{77,1.5},{77,0.5},{77,1},{76,1},{76,1},{76,0.5},{76,0.5},
 {76,1},{74,1},{74,1},{76,1},{74,2},{79,2},
 {76,1},{76,1},{76,2},{76,1},{76,1},{76,2},
 {76,1},{79,1},{72,1.5},{74,0.5},{76,4},
 {77,1},{77,1},{77,1},{77,1},{77,1},{76,1},{76,1},{76,0.5},{76,0.5},
 {79,1},{79,1},{77,1},{74,1},{72,4},
}
task.spawn(function()
 while gui.Parent do
  for _,note in tune do
   if musicGroup.Volume>0 then
    local chime=Instance.new("Sound")
    chime.SoundId,chime.Volume,chime.SoundGroup="rbxasset://sounds/electronicpingshort.wav",0.6,musicGroup
    chime.PlaybackSpeed=2^((note[1]-76)/12)
    chime.Parent=SoundService
    chime:Play()
    game:GetService("Debris"):AddItem(chime,2.5)
   end
   task.wait(note[2]*0.32)
  end
  task.wait(3)
 end
end)
-- Skating has no persistent force objects: every exit restores normal character control.
local skateVelocity=Vector3.zero
local skateHumanoid,skateRoot
local skateEffects={}
local hasSkated,pendingRemoval=false,false
local function clearOldForces(root)
 if not root then return end
 for _,child in root:GetChildren() do
  if child.Name=="SkatingMomentum" then child:Destroy() end
 end
end
local function finishSkating()
 local wasActive=skateHumanoid~=nil
 for _,effect in skateEffects do if effect.Parent then effect.Enabled=false end end
 table.clear(skateEffects)
 if skateHumanoid and skateHumanoid.Parent then
  skateHumanoid.WalkSpeed,skateHumanoid.AutoRotate,skateHumanoid.PlatformStand=16,true,false
 end
 if skateRoot and skateRoot.Parent then
  clearOldForces(skateRoot)
  if wasActive then
   skateRoot.AssemblyLinearVelocity=Vector3.new(0,skateRoot.AssemblyLinearVelocity.Y,0)
   skateRoot.AssemblyAngularVelocity=Vector3.zero
  end
 end
 skateHumanoid,skateRoot=nil,nil
 skateVelocity=Vector3.zero
end
local removeButton=Instance.new("TextButton")
removeButton.Size,removeButton.Position=UDim2.fromOffset(170,36),UDim2.new(1,-185,1,-215)
removeButton.Text,removeButton.TextSize="Снять коньки • X",14
removeButton.BackgroundColor3,removeButton.TextColor3=Color3.fromRGB(40,70,86),Color3.fromRGB(255,245,220)
removeButton.Visible,removeButton.Parent=false,gui
local function requestRemoveSkates()
 finishSkating()
 if pendingRemoval then return end
 pendingRemoval=true
 ReplicatedStorage:WaitForChild("RemoveSkates"):FireServer()
end
removeButton.Activated:Connect(requestRemoveSkates)
local function resetSkateSession()
 finishSkating()
 hasSkated,pendingRemoval=false,false
 removeButton.Visible=player:GetAttribute("SkatesEquipped")==true
 local character=player.Character
 local humanoid=character and character:FindFirstChildOfClass("Humanoid")
 local root=character and character:FindFirstChild("HumanoidRootPart")
 clearOldForces(root)
 if humanoid then humanoid.WalkSpeed,humanoid.AutoRotate,humanoid.PlatformStand=16,true,false end
end
player:GetAttributeChangedSignal("SkatesEquipped"):Connect(resetSkateSession)
player:GetAttributeChangedSignal("SkateSession"):Connect(resetSkateSession)
player.CharacterAdded:Connect(resetSkateSession)
UserInputService.InputBegan:Connect(function(input,processed)
 if not processed and input.KeyCode==Enum.KeyCode.X then requestRemoveSkates() end
end)
RunService.Heartbeat:Connect(function(dt)
 local character=player.Character
 local root=character and character:FindFirstChild("HumanoidRootPart")
 local humanoid=character and character:FindFirstChildOfClass("Humanoid")
 local pos=root and root.Position
 local inBounds=pos and math.abs(pos.X+105)<28.5 and math.abs(pos.Z-75)<21.5
 local equipped=player:GetAttribute("SkatesEquipped")==true
 if hasSkated and equipped and not inBounds then requestRemoveSkates() return end
 local onIce=inBounds and pos.Y>1 and pos.Y<9
 if pendingRemoval or not equipped or not onIce or not humanoid or humanoid.Health<=0 then finishSkating() return end
 if skateHumanoid~=humanoid or skateRoot~=root then
  finishSkating()
  skateHumanoid,skateRoot=humanoid,root
  clearOldForces(root)
  humanoid.WalkSpeed,humanoid.AutoRotate,humanoid.PlatformStand=24,true,false
  local gear=character:FindFirstChild("SkateGear")
  if gear then
   for _,effect in gear:GetDescendants() do
    if effect:IsA("Trail") or effect:IsA("ParticleEmitter") then table.insert(skateEffects,effect) end
   end
  end
 end
 hasSkated=true
 local input=humanoid.MoveDirection
 local desired=Vector3.new(input.X,0,input.Z)*27
 local response=input.Magnitude>0.05 and 4 or 0.6
 skateVelocity=skateVelocity:Lerp(desired,1-math.exp(-math.min(dt,0.1)*response))
 -- Apply velocity after physics; no BodyVelocity remains to pin the next session in place.
 root.AssemblyLinearVelocity=Vector3.new(skateVelocity.X,root.AssemblyLinearVelocity.Y,skateVelocity.Z)
 for _,effect in skateEffects do effect.Enabled=skateVelocity.Magnitude>3 end
end)
local waitButton=Instance.new("TextButton")
waitButton.Size,waitButton.Position=UDim2.fromOffset(170,36),UDim2.new(1,-185,1,-258)
waitButton.Text,waitButton.TextSize="Олень: ждать здесь",14
waitButton.BackgroundColor3,waitButton.TextColor3=Color3.fromRGB(72,94,67),Color3.fromRGB(255,239,214)
waitButton.Visible,waitButton.Parent=false,gui
waitButton.Activated:Connect(function() ReplicatedStorage:WaitForChild("CarrotAction"):FireServer("wait") end)
player:GetAttributeChangedSignal("CompanionDeer"):Connect(function() waitButton.Visible=player:GetAttribute("CompanionDeer")~=nil end)
local boundTools=setmetatable({}, {__mode="k"})
local function playSound(parent,id,volume,speed)
 local audio=Instance.new("Sound")
 audio.SoundId,audio.Volume,audio.PlaybackSpeed=id,volume,speed or 1
 audio.Parent=parent
 audio:Play()
 game:GetService("Debris"):AddItem(audio,4)
end
local function aimPoint(character)
 local camera=workspace.CurrentCamera
 if not camera then return nil end
 local ray
 if UserInputService.TouchEnabled then
  ray=camera:ViewportPointToRay(camera.ViewportSize.X/2,camera.ViewportSize.Y/2)
 else
  ray=mouse.UnitRay
 end
 local params=RaycastParams.new()
 params.FilterType=Enum.RaycastFilterType.Exclude
 params.FilterDescendantsInstances={character}
 local hit=workspace:Raycast(ray.Origin,ray.Direction*350,params)
 return hit and hit.Position or ray.Origin+ray.Direction*350
end
local function characterAdded(character)
 local function bind(child)
  if not child:IsA("Tool") or boundTools[child] then return end
  if child.Name~="Снежки" and child.Name~="Горячий чай" and child.Name~="Морковка для оленя" then return end
  boundTools[child]=true
  local last=0
  local originalGrip=child.Grip
  local shoulder,originalC0,tween,connection
  local function restore()
   if connection then connection:Disconnect() connection=nil end
   if tween then tween:Cancel() tween=nil end
   if shoulder and shoulder.Parent and originalC0 then shoulder.C0=originalC0 end
   child.Grip=originalGrip
  end
  child.Unequipped:Connect(restore)
  child.Activated:Connect(function()
   local tea=child.Name=="Горячий чай"
   local feeding=child.Name=="Морковка для оленя"
   if child.Parent~=character or os.clock()-last<(tea and 2.4 or 0.9) then return end
   last=os.clock()
   -- Gameplay is sent BEFORE optional arm/sound effects; an animation error cannot block throwing.
   if feeding then
    ReplicatedStorage:WaitForChild("CarrotAction"):FireServer("feed")
   elseif not tea then
    local target=aimPoint(character)
    if target then ReplicatedStorage:WaitForChild("ThrowSnowball"):FireServer(target) end
   end
   restore()
   local handle=child:FindFirstChild("Handle")
   local humanoid=character:FindFirstChildOfClass("Humanoid")
   shoulder=character:FindFirstChild("RightShoulder",true) or character:FindFirstChild("Right Shoulder",true)
   if shoulder then
    originalC0=shoulder.C0
    local r6=humanoid and humanoid.RigType==Enum.HumanoidRigType.R6
    local angle=tea and 110 or 85
    local pose=r6 and CFrame.Angles(0,0,math.rad(angle)) or CFrame.Angles(math.rad(angle),0,math.rad(-12))
    tween=TweenService:Create(shoulder,TweenInfo.new(0.3,Enum.EasingStyle.Sine),{C0=originalC0*pose})
    tween:Play()
   end
   local started=os.clock()
   if tea and handle then
    label.Text="☕ Пьём горячий чай…"
    task.delay(0.35,function()
     if child.Parent==character then playSound(handle,"rbxasset://sounds/action_swim.mp3",0.65,1.5) end
    end)
   end
   connection=RunService.PreSimulation:Connect(function()
    local elapsed=os.clock()-started
    if child.Parent~=character or elapsed>(tea and 1.8 or 0.55) then restore() update() return end
    if tea and elapsed>0.3 then
     local tilt=math.sin(math.clamp((elapsed-0.3)/1.5,0,1)*math.pi)
     child.Grip=originalGrip*CFrame.new(0,-0.2*tilt,-0.25*tilt)*CFrame.Angles(math.rad(-28*tilt),0,0)
    end
   end)
  end)
 end
 character.ChildAdded:Connect(bind)
 for _,child in character:GetChildren() do bind(child) end
end
player.CharacterAdded:Connect(characterAdded)
if player.Character then characterAdded(player.Character) end
-- Pickups are personal: hide collected ingredients only for their collector.
local collectibles={}
for _,on in workspace:GetDescendants() do
 if on:IsA("BasePart") and on:GetAttribute("IngredientKey") then table.insert(collectibles,on) end
end
local function refreshCollectibles()
 for _,on in collectibles do
  local owned=player:GetAttribute(on:GetAttribute("IngredientKey"))==true
  on.LocalTransparencyModifier=owned and 1 or 0
  for _,child in on:GetChildren() do
   if child:IsA("ProximityPrompt") or child:IsA("BillboardGui") then child.Enabled=not owned end
  end
 end
end
for _,key in ingredientAttributes do player:GetAttributeChangedSignal(key):Connect(refreshCollectibles) end
refreshCollectibles()
local crosshair=Instance.new("TextLabel")
crosshair.Size,crosshair.Position,crosshair.AnchorPoint=UDim2.fromOffset(24,24),UDim2.fromScale(0.5,0.5),Vector2.new(0.5,0.5)
crosshair.BackgroundTransparency,crosshair.Text,crosshair.TextSize=1,"+",24
crosshair.TextColor3,crosshair.TextStrokeTransparency=Color3.new(1,1,1),0.3
crosshair.Parent=gui
crosshair.Visible=UserInputService.TouchEnabled
-- Snow follows the local character, keeping the effect inexpensive.
local emitterPart=Instance.new("Part")
emitterPart.Name,emitterPart.Size="LocalSnow",Vector3.new(90,1,90)
emitterPart.Anchored,emitterPart.CanCollide,emitterPart.CanQuery,emitterPart.Transparency=true,false,false,1
emitterPart.Parent=workspace
local flakes=Instance.new("ParticleEmitter")
flakes.Texture="rbxasset://textures/particles/sparkles_main.dds"
flakes.Rate,flakes.Lifetime,flakes.Speed=240,NumberRange.new(7,10),NumberRange.new(5,8)
flakes.EmissionDirection=Enum.NormalId.Bottom
flakes.SpreadAngle=Vector2.new(15,15)
flakes.Size=NumberSequence.new(0.2)
flakes.LightInfluence=0
flakes.Rotation=NumberRange.new(0,360)
flakes.RotSpeed=NumberRange.new(-25,25)
flakes.Acceleration=Vector3.new(1,-1,0)
flakes.Parent=emitterPart
local snowWaveParts={}
for _,item in workspace:WaitForChild("WinterVillage"):WaitForChild("Огромная движущаяся волна снега"):GetDescendants() do
 if item:IsA("BasePart") then table.insert(snowWaveParts,item) end
end
task.spawn(function()
 while emitterPart.Parent do
  local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
  if root then
   emitterPart.Position=root.Position+Vector3.new(0,35,0)
   local pos=root.Position
   local indoors=(math.abs(pos.X+43)<15 and math.abs(pos.Z+22)<14 and pos.Y<24)
    or (math.abs(pos.X-58)<15 and math.abs(pos.Z+40)<14 and pos.Y<24)
    or (math.abs(pos.X+130)<15 and math.abs(pos.Z+100)<14 and pos.Y<24)
    or (math.abs(pos.X+40)<15 and math.abs(pos.Z-125)<14 and pos.Y<24)
   indoors=indoors or (math.abs(pos.X-155)<20.5 and math.abs(pos.Z+340)<18.5 and pos.Y<26)
   indoors=indoors or (math.abs(pos.X-235)<28 and math.abs(pos.Z+345)<24 and pos.Y<31)
   local storm=workspace:GetAttribute("BlizzardActive")
   flakes.Rate=storm and 850 or 240
   flakes.Speed=storm and NumberRange.new(25,38) or NumberRange.new(5,8)
   flakes.Acceleration=storm and Vector3.new(35,-8,12) or Vector3.new(1,-1,0)
   if indoors and flakes.Enabled then flakes:Clear() end
   flakes.Enabled=not indoors
   for _,item in snowWaveParts do item.LocalTransparencyModifier=indoors and 1 or 0 end
  end
  task.wait(0.3)
 end
end)

UserInputService.JumpRequest:Connect(function()
 if player:GetAttribute("MountainGear") then ReplicatedStorage:WaitForChild("LeaveMountainRide"):FireServer() end
end)

local dismount=Instance.new("TextButton")
dismount.Size,dismount.Position=UDim2.fromOffset(175,40),UDim2.new(1,-190,1,-300)
dismount.Text,dismount.TextSize="Сойти со снаряжения",14
dismount.BackgroundColor3,dismount.TextColor3=Color3.fromRGB(72,85,103),Color3.fromRGB(255,239,214)
dismount.Visible,dismount.Parent=false,gui
dismount.Activated:Connect(function() ReplicatedStorage:WaitForChild("LeaveMountainRide"):FireServer() end)
player:GetAttributeChangedSignal("MountainGear"):Connect(function() dismount.Visible=player:GetAttribute("MountainGear")~=nil end)

-- Controls apply only while this player drives equipment on the large mountain.
local alpineTouchX,alpineTouchY=0,0
local alpineButtons={}
for i,entry in {{"◀",-1,0},{"▶",1,0},{"Разгон",0,1},{"Тормоз",0,-1}} do
 local button=Instance.new("TextButton")
 button.Size,button.Position=UDim2.fromOffset(66,46),UDim2.new(1,-290+(i-1)*70,1,-155)
 button.Text,button.TextSize,button.Visible=entry[1],14,false
 button.BackgroundColor3,button.TextColor3=Color3.fromRGB(35,62,80),Color3.fromRGB(255,240,214)
 button.Parent=gui
 button.MouseButton1Down:Connect(function() if entry[2]~=0 then alpineTouchX=entry[2] else alpineTouchY=entry[3] end end)
 button.MouseButton1Up:Connect(function() if entry[2]~=0 then alpineTouchX=0 else alpineTouchY=0 end end)
 table.insert(alpineButtons,button)
end
local alpineSpeed=Instance.new("TextLabel")
alpineSpeed.Size,alpineSpeed.Position=UDim2.fromOffset(285,38),UDim2.new(1,-300,1,-202)
alpineSpeed.BackgroundTransparency,alpineSpeed.TextSize,alpineSpeed.TextColor3=0.2,15,Color3.fromRGB(255,240,214)
alpineSpeed.BackgroundColor3,alpineSpeed.Visible,alpineSpeed.Parent=Color3.fromRGB(35,62,80),false,gui
local spawnBoost=false
local driftTouch=false
local driftButton=Instance.new("TextButton")
driftButton.Size,driftButton.Position=UDim2.fromOffset(125,36),UDim2.new(1,-140,0,104)
driftButton.Text,driftButton.TextSize,driftButton.Visible="Дрифт • C",15,false
driftButton.BackgroundColor3,driftButton.TextColor3=Color3.fromRGB(60,83,118),Color3.fromRGB(255,239,214)
driftButton.Parent=gui
driftButton.MouseButton1Down:Connect(function() driftTouch=true end)
driftButton.MouseButton1Up:Connect(function() driftTouch=false end)
local boostButton=Instance.new("TextButton")
boostButton.Size,boostButton.Position=UDim2.fromOffset(125,36),UDim2.new(1,-140,0,60)
boostButton.Text,boostButton.TextSize,boostButton.Visible="Форсаж",15,false
boostButton.BackgroundColor3,boostButton.TextColor3=Color3.fromRGB(150,76,45),Color3.fromRGB(255,239,214)
boostButton.Parent=gui
boostButton.MouseButton1Down:Connect(function() spawnBoost=true end)
boostButton.MouseButton1Up:Connect(function() spawnBoost=false end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.Touch then spawnBoost=false driftTouch=false end end)
local function updateAlpineHUD()
 local driving=player:GetAttribute("MountainDriving")==true or player:GetAttribute("GroundDriving")~=nil
 boostButton.Visible=player:GetAttribute("GroundDriving")=="Реактивные сани"
 if not boostButton.Visible then spawnBoost=false end
 driftButton.Visible=driving
 if not driving then driftTouch=false end
 for _,button in alpineButtons do button.Visible=driving end
 alpineSpeed.Visible=driving
 alpineSpeed.Text="Скорость: "..tostring(player:GetAttribute("GroundSpeed") or player:GetAttribute("MountainSpeed") or 0).." • A/D поворот • W/S скорость"
 if not driving then alpineTouchX,alpineTouchY=0,0 end
end
player:GetAttributeChangedSignal("MountainDriving"):Connect(updateAlpineHUD)
player:GetAttributeChangedSignal("MountainSpeed"):Connect(updateAlpineHUD)
player:GetAttributeChangedSignal("GroundDriving"):Connect(updateAlpineHUD)
player:GetAttributeChangedSignal("GroundSpeed"):Connect(updateAlpineHUD)
UserInputService.InputEnded:Connect(function(input)
 if input.UserInputType==Enum.UserInputType.Touch then alpineTouchX,alpineTouchY=0,0 end
end)
local alpineInputTime=0
RunService.Heartbeat:Connect(function(dt)
 if not player:GetAttribute("MountainDriving") and not player:GetAttribute("GroundDriving") then alpineInputTime=0 return end
 alpineInputTime+=dt
 if alpineInputTime<0.1 then return end alpineInputTime=0
 local x,y=alpineTouchX,alpineTouchY
 if not UserInputService:GetFocusedTextBox() then
  if UserInputService:IsKeyDown(Enum.KeyCode.A) then x-=1 end
  if UserInputService:IsKeyDown(Enum.KeyCode.D) then x+=1 end
  if UserInputService:IsKeyDown(Enum.KeyCode.W) then y+=1 end
  if UserInputService:IsKeyDown(Enum.KeyCode.S) then y-=1 end
 end
 local ground=player:GetAttribute("GroundDriving")
 local boost=(spawnBoost or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)) and 1 or 0
 ReplicatedStorage:WaitForChild(ground and "GroundVehicleControl" or "MountainControl"):FireServer(Vector3.new(math.clamp(x,-1,1),math.clamp(y,-1,1),boost),driftTouch or UserInputService:IsKeyDown(Enum.KeyCode.C))
end)

local function setupFlightControls()
 local wheelClimb=0
 local wheelBound=false
 local actions=game:GetService("ContextActionService")
 local touchTurn,touchThrottle,touchClimb=0,0,0
 local buttons={}
 local flightHUD=Instance.new("TextLabel")
 flightHUD.Size,flightHUD.Position=UDim2.fromOffset(360,86),UDim2.fromOffset(16,110)
 flightHUD.BackgroundColor3,flightHUD.BackgroundTransparency=Color3.fromRGB(27,52,73),0.15
 flightHUD.TextColor3,flightHUD.Font,flightHUD.TextSize=Color3.fromRGB(255,241,219),Enum.Font.GothamBold,14
 flightHUD.TextWrapped,flightHUD.Visible,flightHUD.Parent=true,false,gui
 local jumpButton=Instance.new("TextButton")
 jumpButton.Size,jumpButton.Position=UDim2.fromOffset(175,40),UDim2.new(1,-190,0,148)
 jumpButton.Text,jumpButton.TextSize,jumpButton.Visible="Парашют • R",15,false
 jumpButton.BackgroundColor3,jumpButton.TextColor3=Color3.fromRGB(91,70,110),Color3.fromRGB(255,241,219)
 jumpButton.Parent=gui
 local function jump() ReplicatedStorage:WaitForChild("AircraftAction"):FireServer("jump") end
 jumpButton.Activated:Connect(jump)
 for i,entry in {{"◀",-1,0,0},{"▶",1,0,0},{"Газ",0,1,0},{"Тормоз",0,-1,0},{"Выше",0,0,1},{"Ниже",0,0,-1}} do
  local button=Instance.new("TextButton")
  button.Size,button.Position=UDim2.fromOffset(58,44),UDim2.new(1,-375+(i-1)*61,1,-205)
  button.Text,button.TextSize,button.Visible=entry[1],13,false
  button.BackgroundColor3,button.TextColor3=Color3.fromRGB(42,75,104),Color3.fromRGB(255,241,219)
  button.Parent=gui
  button.MouseButton1Down:Connect(function()
   if entry[2]~=0 then touchTurn=entry[2] elseif entry[3]~=0 then touchThrottle=entry[3] else touchClimb=entry[4] end
  end)
  button.MouseButton1Up:Connect(function()
   if entry[2]~=0 then touchTurn=0 elseif entry[3]~=0 then touchThrottle=0 else touchClimb=0 end
  end)
  table.insert(buttons,button)
 end
 local function refresh()
  local pilot=player:GetAttribute("AircraftPilot")~=nil
  local chute=player:GetAttribute("ParachuteOpen")==true
  local passenger=player:GetAttribute("AircraftPassenger")~=nil
  if pilot and not wheelBound then
   wheelBound=true wheelClimb=0
   actions:BindActionAtPriority("AircraftWheelHeight",function(_,_,input)
    if not player:GetAttribute("AircraftPilot") then return Enum.ContextActionResult.Pass end
    wheelClimb=math.clamp(wheelClimb-input.Position.Z*0.25,-1,1)
    return Enum.ContextActionResult.Sink
   end,false,3000,Enum.UserInputType.MouseWheel)
  elseif not pilot and wheelBound then
   wheelBound=false wheelClimb=0 actions:UnbindAction("AircraftWheelHeight")
  end
  flightHUD.Visible=pilot or passenger or chute
  jumpButton.Visible=pilot or passenger or player:GetAttribute("HasParachute")==true
  for i,button in buttons do button.Visible=pilot or (chute and i<=4) end
  if chute then flightHUD.Text="ПАРАШЮТ\nWASD — направлять • приземление автоматически"
  elseif pilot then flightHUD.Text="ПИЛОТ • скорость "..tostring(player:GetAttribute("FlightSpeed") or 0).." • высота "..tostring(player:GetAttribute("FlightHeight") or 0).."\nW/S — скорость • A/D — поворот • Колесо ↓ — вверх, ↑ — вниз • R — парашют"
  else flightHUD.Text="ПАССАЖИР\nR или прыжок — покинуть самолёт с парашютом" end
  if not pilot and not chute then touchTurn,touchThrottle,touchClimb=0,0,0 end
 end
 for _,attribute in {"AircraftPilot","AircraftPassenger","ParachuteOpen","HasParachute","FlightSpeed","FlightHeight"} do
  player:GetAttributeChangedSignal(attribute):Connect(refresh)
 end
 UserInputService.InputBegan:Connect(function(input,processed)
  if not processed and input.KeyCode==Enum.KeyCode.R then jump() end
 end)
 UserInputService.JumpRequest:Connect(function()
  if player:GetAttribute("AircraftPilot") or player:GetAttribute("AircraftPassenger") then jump() end
 end)
 UserInputService.InputEnded:Connect(function(input)
  if input.UserInputType==Enum.UserInputType.Touch then touchTurn,touchThrottle,touchClimb=0,0,0 end
 end)
 local timer=0
 RunService.Heartbeat:Connect(function(dt)
  local pilot=player:GetAttribute("AircraftPilot")~=nil
  local chute=player:GetAttribute("ParachuteOpen")==true
  if not pilot and not chute then timer=0 return end
  timer+=dt if timer<0.1 then return end timer=0
  local x,y,z=touchTurn,touchThrottle,(touchClimb~=0 and touchClimb or wheelClimb)
  if not UserInputService:GetFocusedTextBox() then
   if UserInputService:IsKeyDown(Enum.KeyCode.A) then x-=1 end
   if UserInputService:IsKeyDown(Enum.KeyCode.D) then x+=1 end
   if UserInputService:IsKeyDown(Enum.KeyCode.W) then y+=1 end
   if UserInputService:IsKeyDown(Enum.KeyCode.S) then y-=1 end
   if UserInputService:IsKeyDown(Enum.KeyCode.Up) then z=1 end
   if UserInputService:IsKeyDown(Enum.KeyCode.Down) then z=-1 end
  end
  x,y,z=math.clamp(x,-1,1),math.clamp(y,-1,1),math.clamp(z,-1,1)
  if chute then
   local camera=workspace.CurrentCamera
   local forward=camera and Vector3.new(camera.CFrame.LookVector.X,0,camera.CFrame.LookVector.Z) or Vector3.new(0,0,-1)
   if forward.Magnitude<0.01 then forward=Vector3.new(0,0,-1) end forward=forward.Unit
   local movement=Vector3.new(-forward.Z,0,forward.X)*x+forward*y
   if movement.Magnitude>1 then movement=movement.Unit end
   x,y,z=movement.X,movement.Z,0
  end
  ReplicatedStorage:WaitForChild("AircraftControl"):FireServer(Vector3.new(x,y,z))
 end)
 refresh()
end
setupFlightControls()
