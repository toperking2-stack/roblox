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
 label.Text="❄ ЗИМНИЙ ПАРК ❄\n"..(size>0 and ("Ком: "..size.." / 4 м • Q — оставить") or "E — взаимодействие • снежки наносят урон")
 if #found>0 then label.Text..="\n"..table.concat(found," • ") end
end
label.Size=UDim2.new(0,330,0,78)
update()
for _,name in {"SnowSize","InventorySticks","InventoryCarrot","InventoryBucket"} do player:GetAttributeChangedSignal(name):Connect(update) end
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
 {"Как кататься на коньках?","🎅 Дед Мороз\nВозьми коньки у зелёного проката перед катком. На льду двигайся обычными клавишами: разгон и торможение плавные. Без коньков поскользнёшься!"},
 {"Как собрать снеговика?","🎅 Дед Мороз\nНайди веточки, морковку и ведёрко. Накатай ком до 4 метров и принеси его на поляну снеговиков. Можно построить несколько — у каждого своя подсказка удаления."},
 {"Кто гуляет в лесу?","🎅 Дед Мороз\nЭто мои олени! Они гуляют на четырёх лесных полянках. У одного красный нос — попробуй его найти. Ты можешь вернуться в дом и согреться чаем. Олени остаются в лесу — приманивать их к камину нельзя."},
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
-- Client owns character physics, so skating input is applied here rather than reading
-- Humanoid.MoveDirection on the server (that property does not replicate).
local skateVelocity=Vector3.zero
local skateHumanoid,skateForce,oldWalk,oldRotate
local skateEffects={}
local leanJoint,leanBase
local function finishSkating()
 for _,effect in skateEffects do if effect.Parent then effect.Enabled=false end end
 table.clear(skateEffects)
 if leanJoint and leanJoint.Parent then leanJoint.C0=leanBase end
 leanJoint,leanBase=nil,nil
 if skateForce then skateForce:Destroy() skateForce=nil end
 if skateHumanoid and skateHumanoid.Parent then skateHumanoid.WalkSpeed=oldWalk skateHumanoid.AutoRotate=oldRotate end
 skateHumanoid=nil skateVelocity=Vector3.zero
end
RunService.PreSimulation:Connect(function(dt)
 local character=player.Character
 local root=character and character:FindFirstChild("HumanoidRootPart")
 local humanoid=character and character:FindFirstChildOfClass("Humanoid")
 local pos=root and root.Position
 local onIce=pos and math.abs(pos.X+105)<28 and math.abs(pos.Z-75)<21 and pos.Y>1 and pos.Y<9
 if not humanoid or humanoid.Health<=0 or not onIce or not player:GetAttribute("SkatesEquipped") then finishSkating() return end
 if skateHumanoid~=humanoid then
  finishSkating()
  skateHumanoid,oldWalk,oldRotate=humanoid,humanoid.WalkSpeed,humanoid.AutoRotate
  humanoid.WalkSpeed,humanoid.AutoRotate=0,false
  skateForce=Instance.new("BodyVelocity")
  skateForce.Name,skateForce.MaxForce,skateForce.P="SkatingMomentum",Vector3.new(50000,0,50000),4000
  skateForce.Parent=root
  local gear=character:FindFirstChild("SkateGear")
  if gear then
   for _,effect in gear:GetDescendants() do
    if effect:IsA("Trail") or effect:IsA("ParticleEmitter") then table.insert(skateEffects,effect) end
   end
  end
  leanJoint=character:FindFirstChild("Waist",true) or character:FindFirstChild("RootJoint",true)
  if leanJoint then leanBase=leanJoint.C0 end
 end
 local input=humanoid.MoveDirection
 local desired=Vector3.new(input.X,0,input.Z)*27
 local response=input.Magnitude>0.05 and 3.4 or 0.23
 skateVelocity=skateVelocity:Lerp(desired,1-math.exp(-dt*response))
 skateForce.Velocity=skateVelocity
 for _,effect in skateEffects do effect.Enabled=skateVelocity.Magnitude>3 end
 if leanJoint then leanJoint.C0=leanBase*CFrame.Angles(-0.09*math.min(skateVelocity.Magnitude/27,1),0,0) end
 if skateVelocity.Magnitude>1 then root.CFrame=CFrame.lookAt(pos,pos+skateVelocity) end
end)
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
  if child.Name~="Снежки" and child.Name~="Горячий чай" then return end
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
   if child.Parent~=character or os.clock()-last<(tea and 2.4 or 0.9) then return end
   last=os.clock()
   -- Gameplay is sent BEFORE optional arm/sound effects; an animation error cannot block throwing.
   if not tea then
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
   if indoors and flakes.Enabled then flakes:Clear() end
   flakes.Enabled=not indoors
  end
  task.wait(0.3)
 end
end)
