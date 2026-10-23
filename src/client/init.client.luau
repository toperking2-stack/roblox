local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local mouse=player:GetMouse()
local TweenService=game:GetService("TweenService")
local UserInputService=game:GetService("UserInputService")
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
local function update()
 label.Text="❄ ЗИМНИЙ ПАРК ❄\nE — взаимодействие • выбери чай или снежки"
end
update()
player:GetAttributeChangedSignal("SantaGreeting"):Connect(function()
 label.Text="Санта: С праздником! Прокатись на санках и согрейся у камина!"
 task.delay(6,update)
end)
local boundTools=setmetatable({}, {__mode="k"})
local function playSound(parent,id,volume)
 local sound=Instance.new("Sound")
 sound.SoundId,sound.Volume=id,volume
 sound.Parent=parent
 sound:Play()
 game:GetService("Debris"):AddItem(sound,3)
end
local function characterAdded(character)
 local function bind(child)
  if not child:IsA("Tool") or boundTools[child] then return end
  if child.Name~="Снежки" and child.Name~="Горячий чай" then return end
  boundTools[child]=true
  local last=0
  local generation=0
  local shoulder,originalC0,activeTween
  local originalGrip=child.Grip
  local function restore()
   generation+=1
   if activeTween then activeTween:Cancel() end
   if shoulder and shoulder.Parent and originalC0 then shoulder.C0=originalC0 end
   child.Grip=originalGrip
  end
  child.Unequipped:Connect(restore)
  child.Activated:Connect(function()
   local tea=child.Name=="Горячий чай"
   if os.clock()-last<(tea and 2.2 or 0.9) then return end
   last=os.clock()
   generation+=1
   local current=generation
   shoulder=character:FindFirstChild("RightShoulder",true) or character:FindFirstChild("Right Shoulder",true)
   if shoulder and not originalC0 then originalC0=shoulder.C0 end
   local handle=child:FindFirstChild("Handle")
   if shoulder then
    activeTween=TweenService:Create(shoulder,TweenInfo.new(0.2,Enum.EasingStyle.Sine),{C0=originalC0*CFrame.Angles(math.rad(tea and -65 or -100),0,math.rad(tea and -15 or 15))})
    activeTween:Play()
   end
   if tea then
    child.Grip=originalGrip*CFrame.Angles(0,0,math.rad(-25))
    if handle then playSound(handle,"rbxasset://sounds/action_swim.mp3",0.25) end
    label.Text="☕ Горячий чай — согреваемся у камина"
    task.delay(1.4,function() if current==generation then restore() update() end end)
   else
    if handle then playSound(handle,"rbxasset://sounds/action_jump.mp3",0.25) end
    local camera=workspace.CurrentCamera
    local target=mouse.Hit.Position
    if UserInputService.TouchEnabled and camera then
     target=camera.CFrame.Position+camera.CFrame.LookVector*120
    end
    task.delay(0.18,function()
     if child.Parent==character and current==generation then
      ReplicatedStorage:WaitForChild("ThrowSnowball"):FireServer(target)
     end
    end)
    task.delay(0.45,function() if current==generation then restore() end end)
   end
  end)
 end
 character.ChildAdded:Connect(bind)
 for _,child in character:GetChildren() do bind(child) end
end
player.CharacterAdded:Connect(characterAdded)
if player.Character then characterAdded(player.Character) end
-- Snow follows the local character, keeping the effect inexpensive.
local emitterPart=Instance.new("Part")
emitterPart.Name,emitterPart.Size="LocalSnow",Vector3.new(90,1,90)
emitterPart.Anchored,emitterPart.CanCollide,emitterPart.CanQuery,emitterPart.Transparency=true,false,false,1
emitterPart.Parent=workspace
local flakes=Instance.new("ParticleEmitter")
flakes.Texture="rbxasset://textures/particles/sparkles_main.dds"
flakes.Rate,flakes.Lifetime,flakes.Speed=100,NumberRange.new(7,10),NumberRange.new(5,8)
flakes.EmissionDirection=Enum.NormalId.Bottom
flakes.SpreadAngle=Vector2.new(15,15)
flakes.Size=NumberSequence.new(0.13)
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
   if indoors and flakes.Enabled then flakes:Clear() end
   flakes.Enabled=not indoors
  end
  task.wait(0.3)
 end
end)
