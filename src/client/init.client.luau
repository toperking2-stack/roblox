local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local mouse=player:GetMouse()
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
 label.Text="❄ НОВОГОДНЯЯ ДЕРЕВНЯ ❄\nЭтап: "..tostring(player:GetAttribute("Checkpoint") or 0).." / 15 • E — взаимодействие"
end
update()
player:GetAttributeChangedSignal("Checkpoint"):Connect(update)
player:GetAttributeChangedSignal("SantaGreeting"):Connect(function()
 label.Text="Санта: С праздником! Согрейся у камина и попробуй пройти обби!"
 task.delay(6,update)
end)
local boundTools=setmetatable({}, {__mode="k"})
local function characterAdded(character)
 character.ChildAdded:Connect(function(child)
  if child:IsA("Tool") and child.Name=="Снежки" and not boundTools[child] then
   boundTools[child]=true
   child.Activated:Connect(function() ReplicatedStorage:WaitForChild("ThrowSnowball"):FireServer(mouse.Hit.Position) end)
  end
 end)
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
  if root then emitterPart.Position=root.Position+Vector3.new(0,35,0) end
  task.wait(0.3)
 end
end)
