-- Lightweight construction test, not a Roblox physics or rendering simulator.
local objects={}
local vector={}
vector.__index=vector
function vector.__add(a,b) return Vector3.new(a.X+b.X,a.Y+b.Y,a.Z+b.Z) end
function vector.__sub(a,b) return Vector3.new(a.X-b.X,a.Y-b.Y,a.Z-b.Z) end
function vector.__mul(a,b) if type(a)=='number' then a,b=b,a end return Vector3.new(a.X*b,a.Y*b,a.Z*b) end
Vector3={new=function(x,y,z) return setmetatable({X=x,Y=y,Z=z},vector) end}
Vector3.zero=Vector3.new(0,0,0)
Vector2={new=function(...) return {...} end}
Color3={fromRGB=function(...) return {...} end}
local cf={}
cf.__index=cf
cf.__mul=function() return setmetatable({},cf) end
CFrame={new=function() return setmetatable({},cf) end,lookAt=function() return setmetatable({},cf) end,Angles=function() return setmetatable({},cf) end}
local enumMeta={__index=function(t,k) local v=setmetatable({},getmetatable(t)) rawset(t,k,v) return v end}
Enum=setmetatable({},enumMeta)
UDim2={fromOffset=function(...) return {...} end,fromScale=function(...) return {...} end}
local function noop() end
local methods={}
function methods:Connect(callback) return {Disconnect=noop} end
function methods:GetPivot() return CFrame.new() end
function methods:SetAttribute(key,value) self.attributes[key]=value end
function methods:GetAttribute(key) return self.attributes[key] end
local objectMeta={__index=function(t,k)
 if methods[k] then return methods[k] end
 if k=='Touched' or k=='Triggered' or k=='OnServerEvent' or k=='PlayerRemoving' then return {Connect=methods.Connect} end
 error('Unexpected startup access: '..tostring(t.ClassName)..'.'..k)
end}
Instance={new=function(class)
 local v=setmetatable({ClassName=class,attributes={}},objectMeta)
 table.insert(objects,v)
 return v
end}
local services={}
for _,name in {'Players','ReplicatedStorage','Debris','TweenService','RunService'} do services[name]=Instance.new(name) end
game={GetService=function(_,name) return assert(services[name],name) end}
workspace=Instance.new('Workspace')
workspace.Gravity=196.2
Random={new=function() return {NextNumber=function(_,a,b) return (a+b)/2 end} end}
PhysicalProperties={new=function(...) return {...} end}
NumberRange={new=function(...) return {...} end}
NumberSequence={new=function(...) return {...} end}
NumberSequenceKeypoint={new=function(...) return {...} end}
-- The runner appends the server source here, followed by construction assertions.
