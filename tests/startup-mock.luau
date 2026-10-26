-- Deterministic API mock: construction and gameplay logic, not Roblox physics/rendering.
local objects={}
local mockKeys={}
local clockNow=0
local realOs=os
os={clock=function() return clockNow end}
local threads={}
local delayed={}
local function resume(thread,...)
 local ok,err,delay=coroutine.resume(thread,...)
 assert(ok,err)
 if coroutine.status(thread)~='dead' then threads[thread]=clockNow+(err=='sleep' and (delay or 0) or 0) else threads[thread]=nil end
end
task={
 spawn=function(fn) local thread=coroutine.create(fn) resume(thread) return thread end,
 wait=function(seconds) return coroutine.yield("sleep",seconds or 0) end,
 delay=function(seconds,fn) table.insert(delayed,{at=clockNow+seconds,fn=fn}) end,
}
local function signal()
 local callbacks={}
 return {
  Connect=function(_,callback) table.insert(callbacks,callback) return {Disconnect=function() end} end,
  Fire=function(_,...) for _,callback in table.clone(callbacks) do callback(...) end end,
  Wait=function() return coroutine.yield() end,
 }
end
local vector={}
vector.__index=function(v,key)
 if key=='Magnitude' then return math.sqrt(v.X*v.X+v.Y*v.Y+v.Z*v.Z) end
 if key=='Unit' then local m=v.Magnitude return Vector3.new(v.X/m,v.Y/m,v.Z/m) end
 if key=='Lerp' then return function(a,b,t) return a+(b-a)*t end end
end
vector.__add=function(a,b) return Vector3.new(a.X+b.X,a.Y+b.Y,a.Z+b.Z) end
vector.__sub=function(a,b) return Vector3.new(a.X-b.X,a.Y-b.Y,a.Z-b.Z) end
vector.__mul=function(a,b) if type(a)=='number' then a,b=b,a end return Vector3.new(a.X*b,a.Y*b,a.Z*b) end
vector.__div=function(a,b) return Vector3.new(a.X/b,a.Y/b,a.Z/b) end
Vector3={new=function(x,y,z) return setmetatable({X=x,Y=y,Z=z},vector) end}
Vector3.zero=Vector3.new(0,0,0)
local realTypeof=typeof
typeof=function(value) if getmetatable(value)==vector then return 'Vector3' end return realTypeof(value) end
Vector2={new=function(...) return {...} end}
Color3={fromRGB=function(...) return {...} end,new=function(...) return {...} end}
UDim={new=function(...) return {...} end}
local cf={}
cf.__index=cf
function cf:ToObjectSpace(other) return CFrame.new(other.Position-self.Position) end
cf.__mul=function(a,b) return CFrame.new(a.Position+b.Position) end
CFrame={
 new=function(x,y,z)
  return setmetatable({Position=type(x)=='table' and x or Vector3.new(x or 0,y or 0,z or 0),LookVector=Vector3.new(0,0,-1)},cf)
 end,
 lookAt=function(a,b) local c=CFrame.new(a) c.LookVector=(b-a).Unit return c end,
 Angles=function() return CFrame.new() end,
}
local enumMeta={__index=function(t,k) local v=setmetatable({},getmetatable(t)) rawset(t,k,v) return v end}
Enum=setmetatable({},enumMeta)
UDim2={new=function(...) return {...} end,fromOffset=function(...) return {...} end,fromScale=function(...) return {...} end}
local properties={}
local events={}
local children={}
local services={}
local methods={}
local eventNames={Touched=true,Triggered=true,OnServerEvent=true,PlayerRemoving=true,PlayerAdded=true,Heartbeat=true,PreSimulation=true,ChildAdded=true,CharacterAdded=true,Activated=true,Unequipped=true,InputBegan=true,JumpRequest=true,InputEnded=true,MouseButton1Down=true,MouseButton1Up=true}
function methods:GetPropertyChangedSignal(name)
 local key='Changed:'..name
 if not events[self][key] then events[self][key]=signal() end
 return events[self][key]
end
function methods:GetChildren()
 return table.clone(children[self])
end
function methods:GetDescendants()
 local result={}
 for _,o in self:GetChildren() do
  table.insert(result,o)
  for _,desc in o:GetDescendants() do table.insert(result,desc) end
 end
 return result
end
function methods:FindFirstChild(name,recursive)
 for _,o in (recursive and self:GetDescendants() or self:GetChildren()) do if o.Name==name then return o end end
end
function methods:FindFirstChildOfClass(class)
 for _,o in self:GetChildren() do if o.ClassName==class then return o end end
end
function methods:FindFirstAncestorOfClass(class)
 local parent=self.Parent
 while parent do if parent.ClassName==class then return parent end parent=parent.Parent end
end
function methods:IsA(class)
 return self.ClassName==class or (class=='BasePart' and (self.ClassName=='Part' or self.ClassName=='Seat' or self.ClassName=='SpawnLocation'))
end
function methods:GetPivot() return self.PrimaryPart and self.PrimaryPart.CFrame or CFrame.new() end
function methods:PivotTo(frame)
 local old=self:GetPivot().Position
 local delta=frame.Position-old
 for _,o in self:GetDescendants() do if o:IsA('BasePart') then o.CFrame=CFrame.new(o.Position+delta) end end
end
function methods:SetAttribute(key,value)
 assert(string.match(key,'^[A-Za-z][A-Za-z0-9_]*$'),'attribute names must be portable ASCII identifiers')
 local previous=properties[self].attributes[key]
 properties[self].attributes[key]=value
 local event=events[self]['Attribute:'..key]
 if event and previous~=value then event:Fire() end
end
function methods:GetAttributeChangedSignal(key)
 local id='Attribute:'..key
 if not events[self][id] then events[self][id]=signal() end
 return events[self][id]
end
function methods:WaitForChild(name) return assert(self:FindFirstChild(name),'missing child '..name) end
function methods:GetMouse() return {UnitRay={Origin=Vector3.new(-40,8,45),Direction=Vector3.new(0,0,-1)}} end
function methods:Create(object,info,values)
 return {Play=function() for k,v in values do object[k]=v end end,Cancel=function() end}
end
function methods:FireServer(...) self.OnServerEvent:Fire(services.Players.LocalPlayer,...) end
function methods:GetAttribute(key) return properties[self].attributes[key] end
function methods:Destroy()
 for _,o in self:GetChildren() do o:Destroy() end
 self.Parent=nil
 self.Destroyed=true
end
function methods:Sit(humanoid) self.Occupant=humanoid humanoid.Sit=true end
function methods:Play() self.Played=true end
function methods:GetFocusedTextBox() return nil end
function methods:IsKeyDown(key) return mockKeys[key]==true end
function methods:Stop() self.Played=false end
function methods:ChangeState(value) self.State=value end
function methods:GetPlayerFromCharacter(character)
 for _,player in self:GetPlayers() do if player.Character==character then return player end end
end
function methods:GetPlayers()
 local result={} for _,o in self:GetChildren() do if o.ClassName=='Player' then table.insert(result,o) end end return result
end
function methods:Clear() self.Cleared=true end
function methods:Emit(count) self.Emitted=count end
function methods:SetNetworkOwner() end
function methods:TakeDamage(amount) self.Health=math.max(0,self.Health-amount) end
local defaults={Parent=true,PrimaryPart=true,Occupant=true,Character=true}
local objectMeta={
 __index=function(t,k)
  local stored=properties[t][k]
  if stored~=nil then return stored end
  if methods[k] then return methods[k] end
  if eventNames[k] then if not events[t][k] then events[t][k]=signal() end return events[t][k] end
  local value=properties[t][k]
  if value~=nil then return value end
  if defaults[k] then return nil end
  error('Unexpected mock access: '..properties[t].ClassName..'.'..k)
 end,
 __newindex=function(t,k,v)
  if k=='Parent' then
   local old=properties[t].Parent
   if old then local index=table.find(children[old],t) if index then table.remove(children[old],index) end end
   if v then table.insert(children[v],t) end
  end
  properties[t][k]=v
  if k=='Position' then properties[t].CFrame=CFrame.new(v) end
  if k=='CFrame' then properties[t].Position=v.Position end
  if k=='Parent' and v and events[v].ChildAdded then events[v].ChildAdded:Fire(t) end
  local event=events[t]['Changed:'..k]
  if event then event:Fire() end
 end,
}
Instance={new=function(class)
 local v=setmetatable({},objectMeta)
 properties[v]={ClassName=class,Name=class,attributes={},Position=Vector3.zero,CFrame=CFrame.new(),AssemblyLinearVelocity=Vector3.zero,AssemblyMass=90,Grip=CFrame.new()}
 if class=="ParticleEmitter" or class=="Trail" then properties[v].Enabled=true end
 if class=="Humanoid" then properties[v].PlatformStand=false properties[v].Sit=false properties[v].WalkSpeed=16 properties[v].AutoRotate=true end
 events[v]={} children[v]={}
 table.insert(objects,v)
 return v
end}
for _,name in {'Players','ReplicatedStorage','Debris','TweenService','RunService','UserInputService','SoundService'} do services[name]=Instance.new(name) end
function methods:AddItem(object,seconds) task.delay(seconds,function() object:Destroy() end) end
game={GetService=function(_,name) return assert(services[name],name) end}
workspace=Instance.new('Workspace')
workspace.Gravity=196.2
local nextRayHit=nil
local defaultRayHit=nil
function methods:Raycast(origin,direction,params)
 if params and params.FilterDescendantsInstances and params.FilterDescendantsInstances[1] then
  local first=params.FilterDescendantsInstances[1]
  if string.match(first.Name,'^Олень ') then return nil end
 end
 local hit=nextRayHit nextRayHit=nil return hit or defaultRayHit
end
Random={new=function(seed)
 local n=seed or 1
 return {NextNumber=function(_,a,b) n=(n*16807)%2147483647 return a+(b-a)*(n/2147483647) end}
end}
PhysicalProperties={new=function(...) return {...} end}
NumberRange={new=function(...) return {...} end}
NumberSequence={new=function(...) return {...} end}
NumberSequenceKeypoint={new=function(...) return {...} end}
RaycastParams={new=function() return {} end}
TweenInfo={new=function(...) return {...} end}
local function advance(seconds)
 for _=1,math.ceil(seconds/0.05) do
  clockNow+=0.05
  services.RunService.Heartbeat:Fire(0.05)
  local due={}
  for i=#delayed,1,-1 do if delayed[i].at<=clockNow then table.insert(due,table.remove(delayed,i).fn) end end
  for _,fn in due do fn() end
  local snapshot={}
  for thread in threads do table.insert(snapshot,thread) end
  for _,thread in snapshot do if threads[thread] and threads[thread]<=clockNow then resume(thread,0.05) end end
 end
end
-- The test runner appends the server source and assertions below.
