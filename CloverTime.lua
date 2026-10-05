if game:GetService("\082\117\110\083\101\114\118\105\099\101"):IsServer() then
 local Players=game:GetService("\080\108\097\121\101\114\115")
 local RS=game:GetService("\082\101\112\108\105\099\097\116\101\100\083\116\111\114\097\103\101")
 local DSS=game:GetService("\068\097\116\097\083\116\111\114\101\083\101\114\118\105\099\101")
 if RS:FindFirstChild("\077\111\109\111\110\103\097\083\101\116\116\105\110\103\115") then return end
 local folder=Instance.new("\070\111\108\100\101\114"); folder.Name="\077\111\109\111\110\103\097\083\101\116\116\105\110\103\115"; folder.Parent=RS
 local get=Instance.new("\082\101\109\111\116\101\070\117\110\099\116\105\111\110"); get.Name="\071\101\116"; get.Parent=folder
 local set=Instance.new("\082\101\109\111\116\101\069\118\101\110\116"); set.Name="\083\101\116"; set.Parent=folder
 local status=Instance.new("\082\101\109\111\116\101\069\118\101\110\116"); status.Name="\083\116\097\116\117\115"; status.Parent=folder
 local store=DSS:GetDataStore("\077\111\109\111\110\103\097\072\117\098\080\114\101\102\101\114\101\110\099\101\115\095\118\049")
 local sessions={}
 local numberRules={ ["\065\117\116\111\047\070\108\121\032\115\112\101\101\100"]={10,150},["\065\117\116\111\047\065\116\116\097\099\107\032\105\110\116\101\114\118\097\108"]={0.15,1.5},["\083\101\116\116\105\110\103\115\047\087\097\108\107\032\083\112\101\101\100"]={8,100} }
 local boolRules={ ["\065\117\116\111\047\065\117\116\111\032\081\117\101\115\116"]=true,["\065\117\116\111\047\065\117\116\111\032\076\101\118\101\108"]=true,["\065\117\116\111\047\065\117\116\111\032\069\113\117\105\112"]=true,["\065\117\116\111\032\068\111\100\103\101\047\065\117\116\111\032\068\111\100\103\101"]=true,["\065\117\116\111\083\116\097\116\047\065\117\116\111\032\083\116\097\116"]=true,["\083\101\116\116\105\110\103\115\047\078\080\067\032\069\083\080"]=true }
 local stringRules={ ["\065\117\116\111\047\083\101\108\101\099\116\032\081\117\101\115\116"]=true,["\065\117\116\111\047\084\119\101\101\110\077\101\116\104\111\100"]=true,["\065\117\116\111\047\083\101\108\101\099\116\032\072\111\116\098\097\114\032\073\116\101\109"]=true,["\065\117\116\111\083\116\097\116\047\083\101\108\101\099\116\032\083\116\097\116\115"]=true,["\073\116\101\109\085\073\068"]=true,["\073\116\101\109\073\068"]=true,["\084\101\108\101\112\111\114\116\047\083\101\108\101\099\116\032\078\080\067"]=true }
 local function sanitize(input)
  local clean={}
  if type(input)~="\116\097\098\108\101" then return clean end
  for key,bounds in pairs(numberRules) do
   local value=input[key]
   if type(value)=="\110\117\109\098\101\114" and value==value then clean[key]=math.clamp(value,bounds[1],bounds[2]) end
  end
  for key in pairs(boolRules) do if type(input[key])=="\098\111\111\108\101\097\110" then clean[key]=input[key] end end
  for key in pairs(stringRules) do
   local value=input[key]
   if type(value)=="\115\116\114\105\110\103" and #value<=160 then clean[key]=value
   elseif (key=="\073\116\101\109\073\068" or key=="\073\116\101\109\085\073\068") and type(value)=="\110\117\109\098\101\114" and value==value and math.abs(value)<1e15 then clean[key]=value end
  end
  return clean
 end
 local function walk(player,data)
  local char=player.Character
  local humanoid=char and char:FindFirstChildOfClass("\072\117\109\097\110\111\105\100")
  if humanoid and data["\083\101\116\116\105\110\103\115\047\087\097\108\107\032\083\112\101\101\100"] then humanoid.WalkSpeed=data["\083\101\116\116\105\110\103\115\047\087\097\108\107\032\083\112\101\101\100"] end
 end
 local function save(player,session)
  if not session or not session.loaded or not session.dirty or session.saving then return end
  session.saving=true
  local revision=session.revision
  local snapshot=table.clone(session.data)
  local ok,err=pcall(function() store:UpdateAsync(tostring(player.UserId),function() return snapshot end) end)
  session.saving=false
  if ok and session.revision==revision then session.dirty=false end
  if player.Parent then status:FireClient(player,ok and "\083\097\118\101\100\032\097\099\114\111\115\115\032\115\101\115\115\105\111\110\115" or "\083\097\118\101\032\102\097\105\108\101\100\059\032\114\101\116\114\121\105\110\103\032\108\097\116\101\114") end
  if not ok then warn("\077\111\109\111\110\103\097\072\117\098\032\115\101\116\116\105\110\103\115\032\115\097\118\101\058",err) end
 end
 local function added(player)
  if sessions[player] then return end
  local session={data={},loaded=false,loading=true,dirty=false,revision=0,lastSet=0}
  sessions[player]=session
  player.CharacterAdded:Connect(function(char)
   char:WaitForChild("\072\117\109\097\110\111\105\100",10)
   if sessions[player]==session then walk(player,session.data) end
  end)
  task.spawn(function()
   local ok,data=pcall(function() return store:GetAsync(tostring(player.UserId)) end)
   if sessions[player]~=session then return end
   session.loading=false; session.loaded=ok
   if ok then session.data=sanitize(data); walk(player,session.data) end
  end)
 end
 Players.PlayerAdded:Connect(added)
 for _,player in ipairs(Players:GetPlayers()) do added(player) end
 get.OnServerInvoke=function(player)
  local session=sessions[player]
  if not session then return nil,"\087\097\105\116\105\110\103\032\102\111\114\032\115\101\116\116\105\110\103\115" end
  if session.loading then return nil,"\076\111\097\100\105\110\103\032\115\097\118\101\100\032\115\101\116\116\105\110\103\115\226\128\166" end
  if not session.loaded then return nil,"\083\116\111\114\097\103\101\032\117\110\097\118\097\105\108\097\098\108\101\059\032\115\101\115\115\105\111\110\045\111\110\108\121\032\115\097\118\105\110\103" end
  return table.clone(session.data),"\076\111\097\100\101\100\032\115\097\118\101\100\032\115\101\116\116\105\110\103\115"
 end
 set.OnServerEvent:Connect(function(player,data)
  local session=sessions[player]
  if not session or not session.loaded or os.clock()-session.lastSet<0.5 then return end
  session.lastSet=os.clock(); session.data=sanitize(data); session.dirty=true; session.revision=session.revision+1
  walk(player,session.data)
  status:FireClient(player,"\080\101\110\100\105\110\103\032\115\097\118\101\032\226\128\162\032\115\097\118\101\115\032\101\118\101\114\121\032\051\048\032\115\101\099\111\110\100\115\032\097\110\100\032\111\110\032\108\101\097\118\101")
 end)
 Players.PlayerRemoving:Connect(function(player)
  local session=sessions[player]
  if session and session.saving then
   local limit=os.clock()+10
   while session.saving and os.clock()<limit do task.wait(0.1) end
  end
  save(player,session); sessions[player]=nil
 end)
 task.spawn(function()
  while folder.Parent do
   task.wait(30)
   for player,session in pairs(sessions) do task.spawn(save,player,session) end
  end
 end)
 game:BindToClose(function()
  local pending=0
  for player,session in pairs(sessions) do
   pending=pending+1
   task.spawn(function()
    while session.saving do task.wait(0.1) end
    save(player,session); pending=pending-1
   end)
  end
  local deadline=os.clock()+25
  while pending>0 and os.clock()<deadline do task.wait(0.1) end
 end)
 return
end
local Players = game:GetService("\080\108\097\121\101\114\115")
local TweenService = game:GetService("\084\119\101\101\110\083\101\114\118\105\099\101")
local UIS = game:GetService("\085\115\101\114\073\110\112\117\116\083\101\114\118\105\099\101")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("\080\108\097\121\101\114\071\117\105")
for _,name in ipairs({"\077\111\109\111\110\103\097\072\117\098\079\112\116\105\109\105\122\101\100","\065\115\116\114\097\085\073"}) do
 local previous=playerGui:FindFirstChild(name)
 if previous then previous:Destroy() end
end
local C = {
 Background = Color3.fromRGB(20,18,31), Sidebar = Color3.fromRGB(27,23,40),
 Card = Color3.fromRGB(35,30,49), Border = Color3.fromRGB(64,51,82),
 Text = Color3.fromRGB(241,240,250), Muted = Color3.fromRGB(145,149,172),
 Accent = Color3.fromRGB(220,163,255), AccentDark = Color3.fromRGB(68,44,85),
 Track = Color3.fromRGB(58,60,79), Green = Color3.fromRGB(115,224,175),
}
local connections, dead = {}, false
local cleanupFlight
local HttpService=game:GetService("\072\116\116\112\083\101\114\118\105\099\101")
local preferences={}
local bindings={}
local touched={}
local restoring=false
local saveRemote
local savePending=false
local saveMessage="\083\101\115\115\105\111\110\045\111\110\108\121\032\115\097\118\105\110\103\032\226\128\162\032\105\110\115\116\097\108\108\032\116\104\101\032\115\101\114\118\101\114\032\099\111\112\121\032\102\111\114\032\114\101\106\111\105\110\105\110\103"
local function flushPreferences()
 savePending=false
 local ok,json=pcall(function() return HttpService:JSONEncode(preferences) end)
 if ok then player:SetAttribute("\077\111\109\111\110\103\097\072\117\098\080\114\101\102\101\114\101\110\099\101\115",json) end
 if saveRemote then saveRemote:FireServer(table.clone(preferences)) end
end
local function remember(key,value)
 preferences[key]=value
 if restoring then return end
 touched[key]=true
 if savePending then return end
 savePending=true
 task.delay(0.75,function() if not dead then flushPreferences() end end)
end
local function bindPreference(key,default,setter)
 preferences[key]=default
 bindings[key]={set=setter,kind=type(default),default=default}
end
local function connect(signal, callback)
 local connection = signal:Connect(callback)
 table.insert(connections, connection)
 return connection
end
local function new(class, props, parent)
 local object = Instance.new(class)
 for key, value in pairs(props or {}) do object[key] = value end
 object.Parent = parent
 return object
end
local function corner(object, radius)
 new("\085\073\067\111\114\110\101\114", {CornerRadius = UDim.new(0, radius or 12)}, object)
end
local function stroke(object, color)
 return new("\085\073\083\116\114\111\107\101", {Color = color or C.Border, Thickness = 1, Transparency = 0.2}, object)
end
local function tween(object, props)
 TweenService:Create(object, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end
local function text(parent, value, position, size, color, fontSize)
 return new("\084\101\120\116\076\097\098\101\108", {BackgroundTransparency=1, Text=value, Position=position, Size=size,
  Font=Enum.Font.GothamMedium, TextSize=fontSize or 13, TextColor3=color or C.Text,
  TextXAlignment=Enum.TextXAlignment.Left, TextTruncate=Enum.TextTruncate.AtEnd}, parent)
end
local function button(parent, value, position, size, background)
 local b = new("\084\101\120\116\066\117\116\116\111\110", {Text=value, Position=position, Size=size, BackgroundColor3=background or C.Card,
  BorderSizePixel=0, AutoButtonColor=false, Font=Enum.Font.GothamMedium, TextSize=13, TextColor3=C.Text}, parent)
 corner(b, 9)
 return b
end
local function call(callback, value)
 if callback and not dead then
  task.spawn(function()
   if dead then return end
   local ok, err = pcall(callback, value)
   if not ok then warn("\077\111\109\111\110\103\097\072\117\098\032\099\097\108\108\098\097\099\107\058\032" .. tostring(err)) end
  end)
 end
end
local gui = new("\083\099\114\101\101\110\071\117\105", {Name="\077\111\109\111\110\103\097\072\117\098\079\112\116\105\109\105\122\101\100", ResetOnSpawn=false, ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
 DisplayOrder=20, IgnoreGuiInset=false}, playerGui)
local root = new("\070\114\097\109\101", {Size=UDim2.fromScale(1,1), BackgroundTransparency=1}, gui)
local window = new("\070\114\097\109\101", {Name="\087\105\110\100\111\119", AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.fromScale(0.5,0.5),
 Size=UDim2.fromOffset(760,500), BackgroundColor3=C.Background, BorderSizePixel=0, ClipsDescendants=true}, root)
corner(window,18); stroke(window)
local scale = new("\085\073\083\099\097\108\101", {}, window)
local function fit()
 local viewport = root.AbsoluteSize
 scale.Scale = math.min(1, math.max(0.1, math.min((viewport.X-20)/760, (viewport.Y-20)/500)))
 local half = Vector2.new(380,250)*scale.Scale
 local p = window.AbsolutePosition - root.AbsolutePosition + window.AbsoluteSize/2
 window.Position = UDim2.fromOffset(math.clamp(p.X,half.X+10,math.max(half.X+10,viewport.X-half.X-10)),
  math.clamp(p.Y,half.Y+10,math.max(half.Y+10,viewport.Y-half.Y-10)))
end
connect(root:GetPropertyChangedSignal("\065\098\115\111\108\117\116\101\083\105\122\101"), fit)
task.defer(function() if not dead then fit() end end)
local sidebar = new("\070\114\097\109\101", {Size=UDim2.new(0,185,1,0), BackgroundColor3=C.Sidebar, BorderSizePixel=0}, window)
local mark=new("\073\109\097\103\101\076\097\098\101\108",{BackgroundTransparency=1,Image="\114\098\120\097\115\115\101\116\105\100\058\047\047\049\051\048\054\050\049\051\051\050\048\054\054\048\052\055",
 Position=UDim2.fromOffset(14,17),Size=UDim2.fromOffset(48,48),ScaleType=Enum.ScaleType.Fit},sidebar)
local brand=text(sidebar,"\077\111\109\111\110\103\097\072\117\098",UDim2.fromOffset(65,24),UDim2.fromOffset(112,21),C.Text,14)
new("\085\073\071\114\097\100\105\101\110\116",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,184,220)),
 ColorSequenceKeypoint.new(1,Color3.fromRGB(170,171,255))})},brand)
text(sidebar,"\118\049\046\048\032\032\047\032\032\080\069\082\083\079\078\065\076\032\072\085\066",UDim2.fromOffset(65,48),UDim2.fromOffset(114,14),C.Muted,8)
text(sidebar,"\087\079\082\075\083\080\065\067\069",UDim2.fromOffset(22,94),UDim2.fromOffset(140,16),C.Muted,10)
local nav=new("\070\114\097\109\101",{Position=UDim2.fromOffset(12,122),Size=UDim2.new(1,-24,1,-220),BackgroundTransparency=1},sidebar)
new("\085\073\076\105\115\116\076\097\121\111\117\116",{Padding=UDim.new(0,7),SortOrder=Enum.SortOrder.LayoutOrder},nav)
local profile=new("\070\114\097\109\101",{Position=UDim2.new(0,14,1,-67),Size=UDim2.new(1,-28,0,51),BackgroundColor3=C.Card,BorderSizePixel=0},sidebar)
corner(profile,10)
local avatar=button(profile,string.upper(string.sub(player.DisplayName,1,1)),UDim2.fromOffset(9,9),UDim2.fromOffset(32,32),C.AccentDark)
avatar.TextColor3=C.Accent
text(profile,player.DisplayName,UDim2.fromOffset(50,9),UDim2.new(1,-58,0,16),C.Text,11)
text(profile,"\076\111\099\097\108\032\115\101\115\115\105\111\110",UDim2.fromOffset(50,28),UDim2.new(1,-58,0,13),C.Green,9)
local header=new("\070\114\097\109\101",{Position=UDim2.fromOffset(185,0),Size=UDim2.new(1,-185,0,83),BackgroundTransparency=1,Active=true},window)
local title=text(header,"\065\117\116\111",UDim2.fromOffset(25,22),UDim2.new(1,-140,0,25),C.Text,21)
local subtitle=text(header,"\089\111\117\114\032\119\111\114\107\115\112\097\099\101\044\032\098\101\097\117\116\105\102\117\108\108\121\032\115\105\109\112\108\101\046",UDim2.fromOffset(25,51),UDim2.new(1,-115,0,16),C.Muted,11)
local resetAllSettings
local resetSettings=button(header,"\226\134\186",UDim2.new(1,-125,0,23),UDim2.fromOffset(29,29))
resetSettings.TextSize=17
local minimize=button(header,"\226\136\146",UDim2.new(1,-88,0,23),UDim2.fromOffset(29,29))
local close=button(header,"\195\151",UDim2.new(1,-51,0,23),UDim2.fromOffset(29,29))
close.TextSize=20
local line=new("\070\114\097\109\101",{Position=UDim2.fromOffset(210,82),Size=UDim2.new(1,-235,0,1),BackgroundColor3=C.Border,BorderSizePixel=0},window)
local pages=new("\070\114\097\109\101",{Position=UDim2.fromOffset(209,98),Size=UDim2.new(1,-233,1,-122),BackgroundTransparency=1},window)
local reopen=button(root,"\226\153\161\032\032\079\112\101\110\032\104\117\098",UDim2.new(0,16,1,-54),UDim2.fromOffset(108,38),C.AccentDark)
reopen.Visible=false; stroke(reopen,C.Accent)
local function visible(value) window.Visible=value; reopen.Visible=not value end
connect(resetSettings.Activated,function()
 if resetAllSettings then resetAllSettings() end
end)
connect(minimize.Activated,function() visible(false) end)
connect(close.Activated,function() visible(false) end)
connect(reopen.Activated,function() visible(true) end)
local drag, dragStart, origin
connect(header.InputBegan,function(input)
 if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
  drag=input; dragStart=Vector2.new(input.Position.X,input.Position.Y)
  origin=window.AbsolutePosition-root.AbsolutePosition+window.AbsoluteSize/2
 end
end)
local activeSlider
connect(UIS.InputChanged,function(input)
 if drag and (input.UserInputType==Enum.UserInputType.MouseMovement or input==drag) then
  local point=origin+Vector2.new(input.Position.X,input.Position.Y)-dragStart
  local half=window.AbsoluteSize/2; local bounds=root.AbsoluteSize
  window.Position=UDim2.fromOffset(math.clamp(point.X,half.X,math.max(half.X,bounds.X-half.X)),math.clamp(point.Y,half.Y,math.max(half.Y,bounds.Y-half.Y)))
 end
 if activeSlider and (input.UserInputType==Enum.UserInputType.MouseMovement or input==activeSlider.input) then
  activeSlider.update(input.Position.X)
 end
end)
connect(UIS.InputEnded,function(input)
 if input==drag or input.UserInputType==Enum.UserInputType.MouseButton1 then drag=nil end
 if activeSlider and (input==activeSlider.input or input.UserInputType==Enum.UserInputType.MouseButton1) then activeSlider=nil end
end)
connect(UIS.InputBegan,function(input,processed)
 if not processed and not UIS:GetFocusedTextBox() and input.KeyCode==Enum.KeyCode.RightShift then visible(not window.Visible) end
end)
connect(gui.Destroying,function()
 flushPreferences()
 dead=true
 if cleanupFlight then cleanupFlight() end
 for _,connection in ipairs(connections) do connection:Disconnect() end
 connections={}; activeSlider=nil; drag=nil
end)
local API={Tabs={}}
function API:Notify(message)
 local toast=new("\084\101\120\116\076\097\098\101\108",{AnchorPoint=Vector2.new(0.5,1),Position=UDim2.new(0.5,0,1,-18),Size=UDim2.new(0.85,0,0,42),
  BackgroundColor3=C.AccentDark,BorderSizePixel=0,Text=message,TextColor3=C.Text,Font=Enum.Font.GothamMedium,TextSize=12,
  TextWrapped=true,ZIndex=10},window)
 corner(toast,10); stroke(toast,C.Accent)
 task.delay(2.5,function() if toast.Parent then toast:Destroy() end end)
end
function API:Tab(name, description, symbol)
 local tab={}
 local navButton=button(nav,(symbol or "\226\128\162").."\032\032\032"..name,UDim2.new(),UDim2.new(1,0,0,41),C.Sidebar)
 navButton.Name=name.."\084\097\098"
 navButton.LayoutOrder=#API.Tabs+1
 navButton.Visible=true
 navButton.TextXAlignment=Enum.TextXAlignment.Left
 new("\085\073\080\097\100\100\105\110\103",{PaddingLeft=UDim.new(0,13)},navButton)
 local page=new("\083\099\114\111\108\108\105\110\103\070\114\097\109\101",{Name=name,Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,
  ScrollBarThickness=3,ScrollBarImageColor3=C.Accent,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,
  ScrollingDirection=Enum.ScrollingDirection.Y,Visible=false},pages)
 new("\085\073\080\097\100\100\105\110\103",{PaddingRight=UDim.new(0,7),PaddingBottom=UDim.new(0,8),PaddingTop=UDim.new(0,1),PaddingLeft=UDim.new(0,1)},page)
 new("\085\073\076\105\115\116\076\097\121\111\117\116",{Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder},page)
 tab.Page=page; tab.Nav=navButton
 function tab:Select()
  for _,other in ipairs(API.Tabs) do
   other.Page.Visible=false; tween(other.Nav,{BackgroundColor3=C.Sidebar,TextColor3=C.Muted})
  end
  page.Visible=true; tween(navButton,{BackgroundColor3=C.AccentDark,TextColor3=C.Accent})
  title.Text=name; subtitle.Text=description or ""
 end
 connect(navButton.Activated,function() tab:Select() end)
 table.insert(API.Tabs,tab)
 local function row(label,detail,height,reserved)
  local frame=new("\070\114\097\109\101",{Size=UDim2.new(1,0,0,height or 68),BackgroundColor3=C.Card,BorderSizePixel=0},page)
  corner(frame,12); stroke(frame)
  text(frame,label,UDim2.fromOffset(16,13),UDim2.new(1,-(reserved or 100),0,19),C.Text,13)
  text(frame,detail or "",UDim2.fromOffset(16,36),UDim2.new(1,-(reserved or 100),0,17),C.Muted,10)
  return frame
 end
 function tab:Section(label)
  return text(page,string.upper(label),UDim2.new(),UDim2.new(1,0,0,23),C.Muted,10)
 end
 function tab:Paragraph(label,body)
  local frame=row(label,"",98,32)
  local bodyText=text(frame,body,UDim2.fromOffset(16,38),UDim2.new(1,-32,0,48),C.Muted,12)
  bodyText.TextWrapped=true; bodyText.TextTruncate=Enum.TextTruncate.None; bodyText.TextYAlignment=Enum.TextYAlignment.Top
  return frame
 end
 function tab:Button(label,detail,action,callback)
  local frame=row(label,detail,68,142)
  local b=button(frame,action or "\082\117\110",UDim2.new(1,-116,0,19),UDim2.fromOffset(100,30),C.AccentDark)
  b.TextColor3=C.Accent
  connect(b.Activated,function() call(callback) end)
  connect(b.MouseEnter,function() tween(b,{BackgroundColor3=C.Track}) end)
  connect(b.MouseLeave,function() tween(b,{BackgroundColor3=C.AccentDark}) end)
  return b
 end
 function tab:Toggle(label,detail,default,callback)
  local key=name.."\047"..label
  local value=default==true
  local frame=row(label,detail)
  local b=button(frame,"",UDim2.new(1,-63,0,23),UDim2.fromOffset(46,24))
  corner(b,20)
  local dot=new("\070\114\097\109\101",{Size=UDim2.fromOffset(18,18),BackgroundColor3=C.Text,BorderSizePixel=0},b); corner(dot,20)
  local function set(v,fire)
   value=v==true
   tween(b,{BackgroundColor3=value and C.Accent or C.Track})
   tween(dot,{Position=UDim2.fromOffset(value and 25 or 3,3)})
   if fire then remember(key,value); call(callback,value) end
  end
  bindPreference(key,value,function(v) set(v,true) end)
  set(value,false); connect(b.Activated,function() set(not value,true) end)
  return {Set=function(_,v) set(v,true) end,Get=function() return value end}
 end
 function tab:Slider(label,detail,min,max,default,step,callback)
  local key=name.."\047"..label
  assert(max>min,"\083\108\105\100\101\114\032\109\097\120\105\109\117\109\032\109\117\115\116\032\098\101\032\103\114\101\097\116\101\114\032\116\104\097\110\032\109\105\110\105\109\117\109")
  step=step or 1; assert(step>0,"\083\108\105\100\101\114\032\115\116\101\112\032\109\117\115\116\032\098\101\032\112\111\115\105\116\105\118\101")
  local value=min
  local frame=row(label,detail,97,90)
  local badge=text(frame,"",UDim2.new(1,-76,0,13),UDim2.fromOffset(59,20),C.Accent,13)
  badge.TextXAlignment=Enum.TextXAlignment.Right
  local hit=button(frame,"",UDim2.new(0,17,0,61),UDim2.new(1,-34,0,28))
  hit.BackgroundTransparency=1
  local track=new("\070\114\097\109\101",{Position=UDim2.new(0,0,0.5,-3),Size=UDim2.new(1,0,0,6),BackgroundColor3=C.Track,BorderSizePixel=0},hit); corner(track,8)
  local fill=new("\070\114\097\109\101",{Size=UDim2.new(),BackgroundColor3=C.Accent,BorderSizePixel=0},track); corner(fill,8)
  local dot=new("\070\114\097\109\101",{AnchorPoint=Vector2.new(0.5,0.5),Size=UDim2.fromOffset(14,14),BackgroundColor3=C.Text,BorderSizePixel=0},track); corner(dot,10)
  local function set(v,fire)
   local nextValue=math.clamp(min+math.floor((v-min)/step+0.5)*step,min,max)
   local changed=nextValue~=value; value=nextValue
   local alpha=(value-min)/(max-min)
   fill.Size=UDim2.new(alpha,0,1,0); dot.Position=UDim2.fromScale(alpha,0.5)
   badge.Text=tostring(math.round(value*1000)/1000)
   if fire and changed then remember(key,value); call(callback,value) end
  end
  local function update(x) set(min+math.clamp((x-track.AbsolutePosition.X)/math.max(1,track.AbsoluteSize.X),0,1)*(max-min),true) end
  connect(hit.InputBegan,function(input)
   if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
    activeSlider={input=input,update=update}; update(input.Position.X)
   end
  end)
  set(default or min,false)
  bindPreference(key,value,function(v) set(v,true) end)
  return {Set=function(_,v) set(v,true) end,Get=function() return value end}
 end
 function tab:Dropdown(label,detail,options,default,callback)
  local key=name.."\047"..label
  assert(#options>0,"\068\114\111\112\100\111\119\110\032\110\101\101\100\115\032\111\112\116\105\111\110\115")
  local value=table.find(options,default) and default or options[1]
  local frame=row(label,detail,108,32)
  local b=button(frame,value.."\032\032\032\226\150\190",UDim2.fromOffset(16,65),UDim2.new(1,-32,0,30),C.Background)
  b.TextXAlignment=Enum.TextXAlignment.Left
  new("\085\073\080\097\100\100\105\110\103",{PaddingLeft=UDim.new(0,12)},b)
  local list=new("\083\099\114\111\108\108\105\110\103\070\114\097\109\101",{Position=UDim2.fromOffset(16,103),Size=UDim2.new(1,-32,0,0),BackgroundTransparency=1,
   BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=C.Accent,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,Visible=false},frame)
  new("\085\073\076\105\115\116\076\097\121\111\117\116",{Padding=UDim.new(0,4)},list)
  local expanded=false
  local function expand(v)
   expanded=v; list.Visible=v
   local height=math.min(#options*32,128)
   list.Size=UDim2.new(1,-32,0,height)
   frame.Size=UDim2.new(1,0,0,v and 115+height or 108)
   b.Text=value..(v and "\032\032\032\226\150\180" or "\032\032\032\226\150\190")
  end
  local function set(v,fire)
   if not table.find(options,v) then return end
   value=v; expand(false); if fire then remember(key,v); call(callback,v) end
  end
  local function rebuild(nextOptions,preferred)
   options=nextOptions
   for _,child in ipairs(list:GetChildren()) do
    if child:IsA("\084\101\120\116\066\117\116\116\111\110") then child:Destroy() end
   end
   value=table.find(options,preferred) and preferred or options[1]
   for _,option in ipairs(options) do
    local item=button(list,option,UDim2.new(),UDim2.new(1,-6,0,28),C.AccentDark)
    item.Activated:Connect(function() if not dead then set(option,true) end end)
   end
   expand(false)
  end
  bindPreference(key,value,function(v) set(v,true) end)
  rebuild(options,value)
  connect(b.Activated,function() expand(not expanded) end)
  return {Set=function(_,v) set(v,true) end,Get=function() return value end,
   SetOptions=function(_,values,preferred) rebuild(values,preferred) end}
 end
 function tab:MultiDropdown(label,detail,options,defaults,callback)
  local key=name.."\047"..label
  assert(#options>0,"\077\117\108\116\105\068\114\111\112\100\111\119\110\032\110\101\101\100\115\032\111\112\116\105\111\110\115")
  local selected={}
  for _,option in ipairs(defaults or {}) do if table.find(options,option) then selected[option]=true end end
  local frame=row(label,detail,108,32)
  local b=button(frame,"",UDim2.fromOffset(16,65),UDim2.new(1,-32,0,30),C.Background)
  b.TextXAlignment=Enum.TextXAlignment.Left
  new("\085\073\080\097\100\100\105\110\103",{PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,8)},b)
  local list=new("\083\099\114\111\108\108\105\110\103\070\114\097\109\101",{Position=UDim2.fromOffset(16,103),Size=UDim2.new(1,-32,0,0),BackgroundTransparency=1,
   BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=C.Accent,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,Visible=false},frame)
  new("\085\073\076\105\115\116\076\097\121\111\117\116",{Padding=UDim.new(0,4)},list)
  local expanded=false
  local itemButtons={}
  local function selectedArray()
   local values={}
   for _,option in ipairs(options) do if selected[option] then table.insert(values,option) end end
   return values
  end
  local function encode()
   return table.concat(selectedArray(),"\124")
  end
  local function updateCaption()
   local values=selectedArray()
   local caption=#values==0 and "\078\111\110\101\032\115\101\108\101\099\116\101\100" or table.concat(values,"\044\032")
   if #caption>48 then caption=caption:sub(1,45).."\046\046\046" end
   b.Text=caption..(expanded and "\032\032\032\226\150\180" or "\032\032\032\226\150\190")
   for option,item in pairs(itemButtons) do item.Text=(selected[option] and "\226\156\147\032\032" or "\226\151\139\032\032")..option end
  end
  local function expand(v)
   expanded=v; list.Visible=v
   local height=math.min(#options*32,160)
   list.Size=UDim2.new(1,-32,0,height)
   frame.Size=UDim2.new(1,0,0,v and 115+height or 108)
   updateCaption()
  end
  local function emit()
   local encoded=encode()
   remember(key,encoded)
   call(callback,selectedArray())
  end
  local function rebuild()
   for _,child in ipairs(list:GetChildren()) do if child:IsA("\084\101\120\116\066\117\116\116\111\110") then child:Destroy() end end
   table.clear(itemButtons)
   for _,option in ipairs(options) do
    local item=button(list,"",UDim2.new(),UDim2.new(1,-6,0,28),C.AccentDark)
    item.TextXAlignment=Enum.TextXAlignment.Left
    new("\085\073\080\097\100\100\105\110\103",{PaddingLeft=UDim.new(0,10)},item)
    itemButtons[option]=item
    item.Activated:Connect(function()
     if dead then return end
     selected[option]=not selected[option] or nil
     updateCaption(); emit()
    end)
   end
   updateCaption()
  end
  local function setEncoded(value,fire)
   table.clear(selected)
   if type(value)=="\116\097\098\108\101" then
    for _,option in ipairs(value) do if table.find(options,option) then selected[option]=true end end
   elseif type(value)=="\115\116\114\105\110\103" then
    for option in string.gmatch(value,"\091\094\124\093\043") do if table.find(options,option) then selected[option]=true end end
   end
   updateCaption()
   if fire then remember(key,encode()); call(callback,selectedArray()) end
  end
  bindPreference(key,encode(),function(v) setEncoded(v,true) end)
  rebuild()
  connect(b.Activated,function() expand(not expanded) end)
  return {Set=function(_,v) setEncoded(v,true) end,Get=function() return selectedArray() end}
 end
 function tab:Input(label,detail,placeholder,callback)
  local frame=row(label,detail,108,32)
  local box=new("\084\101\120\116\066\111\120",{Position=UDim2.fromOffset(16,65),Size=UDim2.new(1,-32,0,30),BackgroundColor3=C.Background,
   BorderSizePixel=0,Text="",PlaceholderText=placeholder or "\084\121\112\101\032\104\101\114\101\226\128\166",PlaceholderColor3=C.Muted,TextColor3=C.Text,
   ClearTextOnFocus=false,Font=Enum.Font.GothamMedium,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left},frame)
  corner(box,8); new("\085\073\080\097\100\100\105\110\103",{PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10)},box)
  connect(box.FocusLost,function(enterPressed) if enterPressed then call(callback,box.Text) end end)
  return box
 end
 if #API.Tabs==1 then tab:Select() end
 return tab
end
local RunService=game:GetService("\082\117\110\083\101\114\118\105\099\101")
local questList={
 {"\084\111\110\121\032\040\076\086\049\041","\104\097\103\101\095\098\097\110\100\105\116\115","\116\111\110\121","\084\111\110\121","\104\097\103\101\095\098\097\110\100\105\116",1,3,false},
 {"\087\111\111\100\115\109\097\110\032\079\114\105\110\032\040\076\086\052\041","\108\117\109\098\101\114\106\097\099\107\095\098\097\110\100\105\116\115","\119\111\111\100\115\109\097\110\095\111\114\105\110","\087\111\111\100\115\109\097\110\032\079\114\105\110","\108\117\109\098\101\114\106\097\099\107\095\098\097\110\100\105\116",4,7,false},
 {"\087\097\114\100\101\110\032\071\114\101\116\097\032\040\076\086\055\041","\115\107\117\108\108\095\098\097\110\100\105\116\115","\113\117\097\114\114\121\095\119\097\114\100\101\110\095\103\114\101\116\097","\087\097\114\100\101\110\032\071\114\101\116\097","\115\107\117\108\108\095\098\097\110\100\105\116",7,10,false},
 {"\070\097\114\109\101\114\032\040\076\086\049\048\041","\102\111\114\101\115\116\095\098\111\097\114\115","\102\097\114\109\101\114","\070\097\114\109\101\114","\098\111\097\114",10,15,false},
 {"\083\099\111\117\116\032\082\111\119\097\110\032\040\076\086\049\053\041","\114\111\097\100\095\116\111\095\103\114\105\109\111\105\114\101\095\116\111\119\101\114","\115\099\111\117\116\095\114\111\119\097\110","\083\099\111\117\116\032\082\111\119\097\110","\114\111\097\100\095\098\097\110\100\105\116",15,20,false},
 {"\087\097\114\100\101\110\032\067\111\108\101\032\040\076\086\050\048\041","\099\104\097\105\110\095\098\097\110\100\105\116","\119\097\114\100\101\110\095\099\111\108\101","\087\097\114\100\101\110\032\067\111\108\101","\099\104\097\105\110\095\098\097\110\100\105\116",20,25,true},
 {"\082\111\097\100\107\101\101\112\101\114\032\068\101\108\108\032\040\076\086\050\053\041","\101\097\114\116\104\095\098\097\110\100\105\116\115","\114\111\097\100\107\101\101\112\101\114\095\100\101\108\108","\082\111\097\100\107\101\101\112\101\114\032\068\101\108\108","\101\097\114\116\104\095\098\097\110\100\105\116",25,30,false},
 {"\077\097\115\111\110\032\084\104\111\114\097\032\040\076\086\050\053\041","\101\097\114\116\104\095\098\097\110\100\105\116\095\098\111\115\115","\109\097\115\111\110\095\116\104\111\114\097","\077\097\115\111\110\032\084\104\111\114\097","\101\097\114\116\104\095\098\097\110\100\105\116\095\098\111\115\115",25,30,true},
 {"\067\097\114\097\118\097\110\032\077\097\115\116\101\114\032\072\117\103\111\032\040\076\086\051\048\041","\099\097\114\097\118\097\110\095\100\101\102\101\110\115\101","\099\097\114\097\118\097\110\095\109\097\115\116\101\114\095\104\117\103\111","\067\097\114\097\118\097\110\032\077\097\115\116\101\114\032\072\117\103\111","\099\097\114\097\118\097\110\095\098\097\110\100\105\116",30,35,false},
 {"\072\117\110\116\101\114\032\077\097\101\118\101\032\040\076\086\051\053\041","\102\111\114\101\115\116\095\119\111\108\118\101\115","\104\117\110\116\101\114\095\109\097\101\118\101","\072\117\110\116\101\114\032\077\097\101\118\101","\119\111\108\102",35,40,false},
 {"\066\101\097\115\116\109\097\115\116\101\114\032\075\097\101\108\032\040\076\086\051\053\041","\109\097\110\097\095\119\111\108\102\095\104\117\110\116","\098\101\097\115\116\109\097\115\116\101\114\095\107\097\101\108","\066\101\097\115\116\109\097\115\116\101\114\032\075\097\101\108","\109\097\110\097\095\119\111\108\102",35,40,true},
 {"\079\102\102\105\099\101\114\032\086\101\114\097\032\040\076\086\052\048\041","\114\097\121\097\107\097\095\100\101\108\105\110\113\117\101\110\116\115","\111\102\102\105\099\101\114\095\118\101\114\097","\079\102\102\105\099\101\114\032\086\101\114\097","\114\097\121\097\107\097\095\100\101\108\105\110\113\117\101\110\116",40,45,false},
 {"\076\105\116\116\108\101\032\090\111\114\097\032\040\076\086\052\053\041","\097\114\109\101\100\095\100\101\108\105\110\113\117\101\110\116\115","\122\111\114\097","\076\105\116\116\108\101\032\090\111\114\097","\122\111\114\097\095\100\101\108\105\110\113\117\101\110\116",45,50,false},
 {"\071\117\097\114\100\032\077\097\114\097\032\040\076\086\053\048\041","\122\111\114\097\095\098\111\115\115","\103\117\097\114\100\095\109\097\114\097","\071\117\097\114\100\032\077\097\114\097","\122\111\114\097",50,55,true},
 {"\067\097\114\112\101\110\116\101\114\032\066\114\097\109\032\040\076\086\053\053\041","\102\105\114\101\095\109\097\103\101\115","\099\097\114\112\101\110\116\101\114\095\098\114\097\109","\067\097\114\112\101\110\116\101\114\032\066\114\097\109","\102\105\114\101\095\109\097\103\101",55,60,false},
 {"\083\109\105\116\104\032\073\108\115\097\032\040\076\086\053\053\041","\102\105\114\101\095\109\097\103\101\095\098\111\115\115","\115\109\105\116\104\095\105\108\115\097","\083\109\105\116\104\032\073\108\115\097","\102\105\114\101\095\109\097\103\101\095\098\111\115\115",55,60,true},
 {"\072\117\110\116\101\114\032\068\097\105\110\032\040\076\086\054\048\041","\103\105\097\110\116\095\098\111\097\114\115","\104\117\110\116\101\114\095\100\097\105\110","\072\117\110\116\101\114\032\068\097\105\110","\103\105\097\110\116\095\098\111\097\114",60,65,false},
 {"\067\097\112\116\097\105\110\032\068\097\114\105\097\032\040\076\086\054\053\041","\115\116\114\111\110\103\095\098\097\110\100\105\116\095\104\117\110\116","\099\097\112\116\097\105\110\095\100\097\114\105\097","\067\097\112\116\097\105\110\032\068\097\114\105\097","\115\116\114\111\110\103\095\098\097\110\100\105\116",65,70,false},
 {"\082\097\110\103\101\114\032\083\101\108\108\097\032\040\076\086\055\048\041","\105\099\101\095\109\097\103\101\115","\114\097\110\103\101\114\095\115\101\108\108\097","\082\097\110\103\101\114\032\083\101\108\108\097","\105\099\101\095\109\097\103\101",70,75,false},
 {"\065\114\099\097\110\105\115\116\032\073\108\118\097\032\040\076\086\055\053\041","\104\101\097\116\104\095\103\114\105\099\101","\097\114\099\097\110\105\115\116\095\105\108\118\097","\065\114\099\097\110\105\115\116\032\073\108\118\097","\104\101\097\116\104\095\103\114\105\099\101",75,80,true},
 {"\082\111\097\100\107\101\101\112\101\114\032\089\097\114\110\032\040\076\086\056\048\041","\109\097\103\110\097\095\115\119\105\110\103","\114\111\097\100\107\101\101\112\101\114\095\121\097\114\110","\082\111\097\100\107\101\101\112\101\114\032\089\097\114\110","\109\097\103\110\097\095\115\119\105\110\103",80,90,true},
}
local questDefinitions={}
local questTargets={}
local targetNames={}
local questLabels={}
local labelByQuestID={}
for index,q in ipairs(questList) do
 questDefinitions[q[1]]={questID=q[2],giverID=q[3],giverName=q[4],mob=q[5],min=q[6],max=q[7],boss=q[8],index=index}
 questTargets[q[1]]=q[5]; targetNames[q[5]]=true
 labelByQuestID[q[2]]=q[1]
 table.insert(questLabels,q[1])
end
local selectedQuest="\084\111\110\121\032\040\076\086\049\041"
local autoQuest=false
local autoLevel=false
local skippedQuests={}   -- only quests the server refuses this session; completed farming quests remain repeatable
local questDropdown
local flightSpeed=70
local movementMethod="\070\108\121"
local target, flightRoot, flightHumanoid, attachment, mover
local oldPlatformStand, oldAutoRotate
local orientation
local controller
local startController
local updateElapsed=0
local statusElapsed=0
local lastStatus
local candidates={}
local npcModels={}
local cleanupExtras
local attackTarget
local questGate
local questProgress=""
local questAcceptAttempts=0
local questLastAccept=-100
local stopAttack
local scanElapsed=0
local home=API:Tab("\065\117\116\111","\067\104\111\111\115\101\032\097\032\113\117\101\115\116\032\097\110\100\032\109\111\118\101\032\116\111\032\105\116\115\032\116\097\114\103\101\116\046","\226\140\130")
local autoDodgeTab=API:Tab("\065\117\116\111\032\068\111\100\103\101","\065\117\116\111\109\097\116\105\099\097\108\108\121\032\100\111\100\103\101\032\119\104\101\110\032\116\104\101\032\114\101\097\108\032\068\111\100\103\101\032\099\104\097\114\103\101\032\114\101\097\099\104\101\115\032\049\048\048\037\046","\226\151\135")
local autoStatTab=API:Tab("\065\117\116\111\083\116\097\116","\065\117\116\111\109\097\116\105\099\097\108\108\121\032\115\112\101\110\100\032\115\116\097\116\032\112\111\105\110\116\115\032\097\099\114\111\115\115\032\115\101\108\101\099\116\101\100\032\115\116\097\116\115\046","\226\156\166")
local teleport=API:Tab("\084\101\108\101\112\111\114\116","\067\104\111\111\115\101\032\097\032\113\117\101\115\116\032\103\105\118\101\114\044\032\115\104\111\112\032\078\080\067\044\032\111\114\032\101\110\101\109\121\032\115\112\097\119\110\046","\226\134\151")
local settings=API:Tab("\083\101\116\116\105\110\103\115","\075\101\101\112\032\121\111\117\114\032\119\111\114\107\115\112\097\099\101\032\099\111\109\102\111\114\116\097\098\108\101\046","\226\154\153")
home:Section("\065\117\116\111\032\081\117\101\115\116")
questDropdown=home:Dropdown("\083\101\108\101\099\116\032\081\117\101\115\116","\067\104\111\111\115\101\032\097\032\113\117\101\115\116\032\103\105\118\101\114\046\032\065\117\116\111\032\076\101\118\101\108\032\111\118\101\114\114\105\100\101\115\032\116\104\105\115\046",questLabels,"\084\111\110\121\032\040\076\086\049\041",function(value)
 if value==selectedQuest then return end
 selectedQuest=value
 target=nil; questAcceptAttempts=0; questLastAccept=-100
 if stopAttack then stopAttack() end
end)
home:Dropdown("\084\119\101\101\110\077\101\116\104\111\100","\070\108\121\032\109\111\118\101\115\032\115\109\111\111\116\104\108\121\032\116\104\114\111\117\103\104\032\119\097\108\108\115\046\032\084\101\108\101\112\111\114\116\032\105\110\115\116\097\110\116\108\121\032\109\111\118\101\115\032\098\101\115\105\100\101\032\116\104\101\032\113\117\101\115\116\032\078\080\067\047\101\110\101\109\121\046",{"\070\108\121","\084\101\108\101\112\111\114\116"},"\070\108\121",function(value)
 movementMethod=value
 target=nil
end)
local status=home:Paragraph("\081\117\101\115\116\032\115\116\097\116\117\115","\079\102\102\032\226\128\162\032\083\101\108\101\099\116\032\084\111\110\121\032\040\076\086\049\041\044\032\116\104\101\110\032\101\110\097\098\108\101\032\065\117\116\111\032\081\117\101\115\116\046")
local statusText=status:GetChildren()
local statusLabel
for _,child in ipairs(statusText) do
 if child:IsA("\084\101\120\116\076\097\098\101\108") and child.Text:sub(1,3)=="\079\102\102" then statusLabel=child end
end
local function setStatus(message)
 if message==lastStatus then return end
 lastStatus=message
 if statusLabel and statusLabel.Parent then statusLabel.Text=message end
end
local collisionParts={}
local collisionStep,collisionAdded,collisionRemoved
local function restoreCollision()
 if collisionStep then collisionStep:Disconnect(); collisionStep=nil end
 if collisionAdded then collisionAdded:Disconnect(); collisionAdded=nil end
 if collisionRemoved then collisionRemoved:Disconnect(); collisionRemoved=nil end
 for part,original in pairs(collisionParts) do
  if part.Parent then part.CanCollide=original end
 end
 table.clear(collisionParts)
end
local function beginWallPass(character)
 restoreCollision()
 local function track(part)
  if part:IsA("\066\097\115\101\080\097\114\116") and collisionParts[part]==nil then
   collisionParts[part]=part.CanCollide
   part.CanCollide=false
  end
 end
 for _,part in ipairs(character:GetDescendants()) do track(part) end
 collisionAdded=character.DescendantAdded:Connect(track)
 collisionRemoved=character.DescendantRemoving:Connect(function(part)
  local original=collisionParts[part]
  if original~=nil then
   part.CanCollide=original
   collisionParts[part]=nil
  end
 end)
 collisionStep=RunService.PreSimulation:Connect(function()
  for part in pairs(collisionParts) do
   if part.Parent and part.CanCollide then part.CanCollide=false end
  end
 end)
end
local function stopFlight()
 restoreCollision()
 if not flightRoot and not mover and not attachment then return end
 if orientation then orientation:Destroy(); orientation=nil end
 if mover then mover:Destroy(); mover=nil end
 if attachment then attachment:Destroy(); attachment=nil end
 if flightHumanoid and flightHumanoid.Parent then
  flightHumanoid.PlatformStand=oldPlatformStand
  flightHumanoid.AutoRotate=oldAutoRotate
 end
 if flightRoot and flightRoot.Parent then flightRoot.AssemblyLinearVelocity=Vector3.zero end
 flightRoot=nil; flightHumanoid=nil
end
local mapWide={
 range=20000,
 lastStreamRequest=0,
 lastStreamPosition=nil,
 models={},
 spawnMarkers={},
 lastFullScan=0,
 fullScanInterval=3.0
}
function mapWide.requestStream(position)
 if typeof(position)~="\086\101\099\116\111\114\051" then return end
 local now=os.clock()
 if mapWide.lastStreamPosition and (mapWide.lastStreamPosition-position).Magnitude<150 and now-mapWide.lastStreamRequest<2.5 then
  return
 end
 mapWide.lastStreamRequest=now
 mapWide.lastStreamPosition=position
 task.spawn(function()
  pcall(function()
   player:RequestStreamAroundAsync(position,3)
  end)
 end)
end
function mapWide.normalize(value)
 local s=tostring(value or ""):lower()
 s=s:gsub("\095","\032"):gsub("\037\045","\032")
 s=s:gsub("\037\091\046\045\037\093","")
 s=s:gsub("\037\040\037\115\042\091\076\108\093\091\086\118\093\091\076\108\093\063\091\094\037\041\093\042\037\041","")
 s=s:gsub("\091\076\108\093\091\086\118\093\091\076\108\093\063\037\046\063\037\115\042\037\100\043","")
 s=s:gsub("\091\076\108\093\091\069\101\093\091\086\118\093\091\069\101\093\091\076\108\093\037\115\042\037\100\043","")
 s=s:gsub("\091\094\037\119\037\115\093","\032")
 s=s:gsub("\037\115\043","\032")
 return s:match("\094\037\115\042\040\046\045\041\037\115\042\036") or ""
end
function mapWide.compact(value)
 return mapWide.normalize(value):gsub("\037\115\043","")
end
function mapWide.root(model)
 if not model or not model:IsA("\077\111\100\101\108") then return nil end
 return model:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116",true)
  or model:FindFirstChild("\085\112\112\101\114\084\111\114\115\111",true)
  or model:FindFirstChild("\084\111\114\115\111",true)
  or model:FindFirstChild("\072\101\097\100",true)
  or model.PrimaryPart
  or model:FindFirstChildWhichIsA("\066\097\115\101\080\097\114\116",true)
end
function mapWide.humanoid(model)
 if not model or not model:IsA("\077\111\100\101\108") then return nil end
 return model:FindFirstChildWhichIsA("\072\117\109\097\110\111\105\100",true)
end
function mapWide.alive(model)
 local humanoid=mapWide.humanoid(model)
 if humanoid then return humanoid.Health>0 end
 for _,name in ipairs({"\072\101\097\108\116\104","\072\080","\072\105\116\080\111\105\110\116\115","\067\117\114\114\101\110\116\072\101\097\108\116\104"}) do
  local value=model:FindFirstChild(name,true)
  if value and (value:IsA("\078\117\109\098\101\114\086\097\108\117\101") or value:IsA("\073\110\116\086\097\108\117\101")) then
   return value.Value>0
  end
 end
 return mapWide.root(model)~=nil
end
function mapWide.nameMatches(model,wanted)
 if not model or not wanted then return false end
 local wantedNormal=mapWide.normalize(wanted)
 local wantedCompact=mapWide.compact(wanted)
 if wantedCompact=="" then return false end
 local function matches(value)
  local normal=mapWide.normalize(value)
  local compact=normal:gsub("\037\115\043","")
  if compact==wantedCompact then return true end
  if #wantedCompact>=4 and compact:find(wantedCompact,1,true) then return true end
  if #compact>=4 and wantedCompact:find(compact,1,true) then return true end
  return normal==wantedNormal
 end
 if matches(model.Name) then return true end
 for _,attribute in ipairs({"\078\080\067\078\097\109\101","\077\111\098\078\097\109\101","\068\105\115\112\108\097\121\078\097\109\101","\069\110\101\109\121\078\097\109\101","\078\097\109\101"}) do
  local ok,value=pcall(function() return model:GetAttribute(attribute) end)
  if ok and value~=nil and matches(value) then return true end
 end
 for _,desc in ipairs(model:GetDescendants()) do
  if desc:IsA("\084\101\120\116\076\097\098\101\108") or desc:IsA("\084\101\120\116\066\117\116\116\111\110") then
   local value=desc.Text
   if value and value~="" and matches(value) then return true end
  end
 end
 return false
end
local function targetParts(model)
 if not model or model==player.Character or not model:IsDescendantOf(workspace) then return end
 local wanted=questTargets[selectedQuest]
 if not wanted or not mapWide.nameMatches(model,wanted) then return end
 if not mapWide.alive(model) then return end
 return mapWide.root(model)
end
local function register(object)
 if object:IsA("\072\117\109\097\110\111\105\100") and object.Parent and object.Parent:IsA("\077\111\100\101\108") then
  npcModels[object.Parent]=true
 end
end
for _,object in ipairs(workspace:GetDescendants()) do register(object) end
connect(workspace.DescendantAdded,register)
connect(workspace.DescendantRemoving,function(object)
 npcModels[object]=nil
 if object:IsA("\072\117\109\097\110\111\105\100") and object.Parent then npcModels[object.Parent]=nil end
end)
function mapWide.indexObject(object)
 if object:IsA("\077\111\100\101\108") then
  mapWide.models[object]=true
 elseif object:IsA("\065\116\116\097\099\104\109\101\110\116") or object:IsA("\066\097\115\101\080\097\114\116") then
  local parent=object.Parent
  if parent and parent.Name=="\104\111\115\116\105\108\101" then
   mapWide.spawnMarkers[object]=true
  elseif parent and parent.Parent and parent.Parent.Name=="\104\111\115\116\105\108\101" then
   mapWide.spawnMarkers[object]=true
  end
 end
end
function mapWide.removeObject(object)
 mapWide.models[object]=nil
 mapWide.spawnMarkers[object]=nil
end
function mapWide.rebuildIndex()
 table.clear(mapWide.models)
 table.clear(mapWide.spawnMarkers)
 for _,object in ipairs(workspace:GetDescendants()) do
  mapWide.indexObject(object)
 end
 mapWide.lastFullScan=os.clock()
end
mapWide.rebuildIndex()
connect(workspace.DescendantAdded,function(object)
 mapWide.indexObject(object)
end)
connect(workspace.DescendantRemoving,function(object)
 mapWide.removeObject(object)
end)
function mapWide.objectPosition(object)
 if not object then return nil end
 if object:IsA("\065\116\116\097\099\104\109\101\110\116") then return object.WorldPosition end
 if object:IsA("\066\097\115\101\080\097\114\116") then return object.Position end
 if object:IsA("\077\111\100\101\108") then
  local rootPart=mapWide.root(object)
  return rootPart and rootPart.Position or object:GetPivot().Position
 end
end
function mapWide.spawnMatches(object,wanted)
 if not object or not wanted then return false end
 local wantedCompact=mapWide.compact(wanted)
 if wantedCompact=="" then return false end
 local function check(value)
  local compact=mapWide.compact(value)
  return compact==wantedCompact
   or (#wantedCompact>=4 and compact:find(wantedCompact,1,true)~=nil)
   or (#compact>=4 and wantedCompact:find(compact,1,true)~=nil)
 end
 if check(object.Name) then return true end
 if object.Parent and check(object.Parent.Name) then return true end
 for _,attribute in ipairs({"\078\080\067\078\097\109\101","\077\111\098\078\097\109\101","\069\110\101\109\121\078\097\109\101","\068\105\115\112\108\097\121\078\097\109\101","\078\097\109\101"}) do
  local ok,value=pcall(function() return object:GetAttribute(attribute) end)
  if ok and value~=nil and check(value) then return true end
 end
 return false
end
function mapWide.findSpawn(wanted,origin)
 local bestPosition,bestDistance
 local maxDistanceSquared=mapWide.range*mapWide.range
 for object in pairs(mapWide.spawnMarkers) do
  if object.Parent and object:IsDescendantOf(workspace) and mapWide.spawnMatches(object,wanted) then
   local position=mapWide.objectPosition(object)
   if position then
    local delta=position-origin
    local distanceSquared=delta:Dot(delta)
    if distanceSquared<=maxDistanceSquared and (not bestDistance or distanceSquared<bestDistance) then
     bestPosition=position
     bestDistance=distanceSquared
    end
   end
  else
   mapWide.spawnMarkers[object]=nil
  end
 end
 return bestPosition
end
local function findNearest(position)
 local best,bestDistance
 local maxDistanceSquared=mapWide.range*mapWide.range
 if os.clock()-mapWide.lastFullScan>=mapWide.fullScanInterval then
  mapWide.rebuildIndex()
 end
 for object in pairs(mapWide.models) do
  if object.Parent and object:IsDescendantOf(workspace) and object~=player.Character then
   local part=targetParts(object)
   if part then
    local delta=part.Position-position
    local distanceSquared=delta:Dot(delta)
    if distanceSquared<=maxDistanceSquared and (not bestDistance or distanceSquared<bestDistance) then
     best=object
     bestDistance=distanceSquared
    end
   end
  else
   mapWide.models[object]=nil
  end
 end
 return best
end
local function startFlight(rootPart,humanoid)
 stopFlight()
 flightRoot=rootPart; flightHumanoid=humanoid
 oldPlatformStand=humanoid.PlatformStand; oldAutoRotate=humanoid.AutoRotate
 attachment=Instance.new("\065\116\116\097\099\104\109\101\110\116")
 attachment.Name="\077\111\109\111\110\103\097\070\108\105\103\104\116\065\116\116\097\099\104\109\101\110\116"; attachment.Parent=rootPart
 mover=Instance.new("\065\108\105\103\110\080\111\115\105\116\105\111\110")
 mover.Name="\077\111\109\111\110\103\097\070\108\105\103\104\116\080\111\115\105\116\105\111\110"
 mover.Mode=Enum.PositionAlignmentMode.OneAttachment
 mover.Attachment0=attachment
 mover.ApplyAtCenterOfMass=true
 mover.MaxForce=math.max(100000,rootPart.AssemblyMass*workspace.Gravity*20)
 mover.MaxVelocity=flightSpeed
 mover.Responsiveness=20
 mover.Position=rootPart.Position
 mover.Parent=rootPart
 orientation=Instance.new("\065\108\105\103\110\079\114\105\101\110\116\097\116\105\111\110")
 orientation.Name="\077\111\109\111\110\103\097\070\108\105\103\104\116\079\114\105\101\110\116\097\116\105\111\110"
 orientation.Mode=Enum.OrientationAlignmentMode.OneAttachment
 orientation.Attachment0=attachment
 orientation.MaxTorque=100000
 orientation.Responsiveness=15
 orientation.CFrame=rootPart.CFrame.Rotation
 orientation.Parent=rootPart
 humanoid.PlatformStand=true; humanoid.AutoRotate=false
 beginWallPass(rootPart.Parent)
end
local function teleportNear(rootPart,position,offset)
 local character=rootPart and rootPart.Parent
 if not character or not character:IsA("\077\111\100\101\108") then return nil end
 local goal=position+(offset or Vector3.new(0,0,3))
 if (rootPart.Position-goal).Magnitude>2.5 then
  stopFlight()
  rootPart.AssemblyLinearVelocity=Vector3.zero
  local flatLook=Vector3.new(position.X,goal.Y,position.Z)
  local cf
  if (flatLook-goal).Magnitude>0.05 then cf=CFrame.lookAt(goal,flatLook) else cf=CFrame.new(goal)*rootPart.CFrame.Rotation end
  character:PivotTo(cf)
 end
 return goal
end
home:Toggle("\065\117\116\111\032\081\117\101\115\116","\065\099\099\101\112\116\032\116\104\101\032\115\101\108\101\099\116\101\100\032\113\117\101\115\116\044\032\116\104\101\110\032\100\101\102\101\097\116\032\105\116\115\032\109\111\098\115\046",false,function(enabled)
 if dead then return end
 autoQuest=enabled; target=nil; scanElapsed=0.5
 questAcceptAttempts=0; questLastAccept=-100
 if not enabled then
  if controller then controller:Disconnect(); controller=nil end
  if stopAttack then stopAttack() end
  stopFlight(); setStatus("\079\102\102\032\226\128\162\032\070\108\105\103\104\116\032\115\116\111\112\112\101\100\046")
  if autoLevel and bindings["\065\117\116\111\047\065\117\116\111\032\076\101\118\101\108"] then bindings["\065\117\116\111\047\065\117\116\111\032\076\101\118\101\108"].set(false) end
 else
  setStatus("\080\114\101\112\097\114\105\110\103\032"..selectedQuest.."\226\128\166")
  startController()
 end
end)
home:Toggle("\065\117\116\111\032\076\101\118\101\108","\068\101\116\101\099\116\115\032\121\111\117\114\032\108\105\118\101\032\108\101\118\101\108\032\097\110\100\032\102\097\114\109\115\032\116\104\101\032\104\105\103\104\101\115\116\032\115\117\105\116\097\098\108\101\032\113\117\101\115\116\032\097\117\116\111\109\097\116\105\099\097\108\108\121\046",false,function(enabled)
 if dead then return end
 autoLevel=enabled
 table.clear(skippedQuests)
 target=nil; questAcceptAttempts=0; questLastAccept=-100
 if enabled then
  setStatus("\065\117\116\111\032\076\101\118\101\108\032\226\128\162\032\068\101\116\101\099\116\105\110\103\032\121\111\117\114\032\108\101\118\101\108\032\097\110\100\032\099\104\111\111\115\105\110\103\032\116\104\101\032\098\101\115\116\032\113\117\101\115\116\226\128\166")
  if not autoQuest and bindings["\065\117\116\111\047\065\117\116\111\032\081\117\101\115\116"] then bindings["\065\117\116\111\047\065\117\116\111\032\081\117\101\115\116"].set(true) end
 end
end)
home:Slider("\070\108\121\032\115\112\101\101\100","\077\111\118\101\109\101\110\116\032\115\112\101\101\100\032\105\110\032\115\116\117\100\115\032\112\101\114\032\115\101\099\111\110\100\046",10,150,70,5,function(value)
 flightSpeed=value
 if mover then mover.MaxVelocity=value end
end)
home:Paragraph("\065\117\116\111\032\081\117\101\115\116\032\099\111\109\098\097\116","\065\108\108\032\050\049\032\107\105\108\108\032\113\117\101\115\116\115\044\032\084\111\110\121\032\040\076\086\049\041\032\116\111\032\082\111\097\100\107\101\101\112\101\114\032\089\097\114\110\032\040\076\086\056\048\041\046\032\085\115\101\115\032\116\104\101\032\115\101\108\101\099\116\101\100\032\084\119\101\101\110\077\101\116\104\111\100\032\116\111\032\114\101\097\099\104\032\116\104\101\032\103\105\118\101\114\032\097\110\100\032\101\110\101\109\121\044\032\119\097\105\116\115\032\102\111\114\032\115\101\114\118\101\114\045\099\111\110\102\105\114\109\101\100\032\113\117\101\115\116\032\097\099\099\101\112\116\097\110\099\101\044\032\116\104\101\110\032\102\105\103\104\116\115\046\032\065\117\116\111\032\076\101\118\101\108\032\114\101\097\100\115\032\121\111\117\114\032\108\105\118\101\032\108\101\118\101\108\032\097\110\100\032\114\101\112\101\097\116\101\100\108\121\032\102\097\114\109\115\032\116\104\101\032\104\105\103\104\101\115\116\032\115\117\105\116\097\098\108\101\032\113\117\101\115\116\044\032\115\119\105\116\099\104\105\110\103\032\098\114\097\099\107\101\116\115\032\097\115\032\121\111\117\032\108\101\118\101\108\032\117\112\046\032\077\111\098\032\097\110\100\032\113\117\101\115\116\045\078\080\067\032\100\101\116\101\099\116\105\111\110\032\117\115\101\115\032\097\110\032\111\112\116\105\109\105\122\101\100\032\050\048\044\048\048\048\045\115\116\117\100\032\105\110\100\101\120\101\100\032\115\099\097\110\110\101\114\032\119\105\116\104\032\104\111\115\116\105\108\101\032\115\112\097\119\110\032\109\097\114\107\101\114\115\032\097\110\100\032\116\104\114\111\116\116\108\101\100\032\115\116\114\101\097\109\105\110\103\032\114\101\113\117\101\115\116\115\046")
cleanupFlight=function()
 autoQuest=false; autoLevel=false
 if controller then controller:Disconnect(); controller=nil end
 stopFlight()
 if cleanupExtras then cleanupExtras() end
 table.clear(candidates)
 table.clear(npcModels)
end
connect(player.CharacterRemoving,function() target=nil; stopFlight() end)
local function updateFlight(dt)
 if dead or not autoQuest then return end
 statusElapsed=statusElapsed+dt
 local character=player.Character
 local rootPart=character and character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116")
 local humanoid=character and character:FindFirstChildOfClass("\072\117\109\097\110\111\105\100")
 if not rootPart or not humanoid or humanoid.Health<=0 then
  stopFlight(); target=nil; setStatus("\087\097\105\116\105\110\103\032\102\111\114\032\121\111\117\114\032\099\104\097\114\097\099\116\101\114\226\128\166"); return
 end
 if not questGate then setStatus("\087\097\105\116\105\110\103\032\102\111\114\032\113\117\101\115\116\032\105\110\116\101\103\114\097\116\105\111\110\226\128\166"); return end
 local ok,ready=pcall(questGate,rootPart,humanoid)
 if not ok then
  if stopAttack then stopAttack() end
  stopFlight(); setStatus("\081\117\101\115\116\032\101\114\114\111\114\058\032"..tostring(ready)); return
 end
 if not ready then return end
 local targetRoot=targetParts(target)
 if not targetRoot then
  if stopAttack then stopAttack() end
  target=nil
  scanElapsed=scanElapsed+dt
  if scanElapsed>=0.75 then
   scanElapsed=0
   target=findNearest(rootPart.Position)
   targetRoot=targetParts(target)
   if not targetRoot then
    local wanted=questTargets[selectedQuest]
    local spawnPosition=mapWide.findSpawn(wanted,rootPart.Position)
    if spawnPosition then
     mapWide.requestStream(spawnPosition)
     target=findNearest(rootPart.Position)
     targetRoot=targetParts(target)
     if not targetRoot then
      local spawnDistance=(spawnPosition-rootPart.Position).Magnitude
      if movementMethod=="\084\101\108\101\112\111\114\116" then
       teleportNear(rootPart,spawnPosition,Vector3.new(0,0,5))
       mapWide.requestStream(spawnPosition)
       setStatus("\083\116\114\101\097\109\105\110\103\032"..wanted.."\032\115\112\097\119\110\032\226\128\162\032"..math.floor(spawnDistance).."\032\115\116\117\100\115")
      else
       if flightRoot~=rootPart or not mover then startFlight(rootPart,humanoid) end
       local streamGoal=spawnPosition+Vector3.new(0,3,5)
       mover.Position=streamGoal
       local look=Vector3.new(spawnPosition.X,rootPart.Position.Y,spawnPosition.Z)
       if (look-rootPart.Position).Magnitude>0.1 then
        orientation.CFrame=CFrame.lookAt(rootPart.Position,look).Rotation
       end
       setStatus("\070\108\121\105\110\103\032\116\111\119\097\114\100\032"..wanted.."\032\115\112\097\119\110\032\226\128\162\032"..math.floor(spawnDistance).."\032\115\116\117\100\115\032\226\128\162\032\115\116\114\101\097\109\105\110\103\032\097\114\101\097")
      end
     end
    end
   end
  end
  if not targetRoot then
   if flightRoot and movementMethod=="\084\101\108\101\112\111\114\116" then stopFlight() end
   return
  end
 end
 local goal
 if movementMethod=="\084\101\108\101\112\111\114\116" then
  goal=teleportNear(rootPart,targetRoot.Position,Vector3.new(0,0,3))
 else
  if flightRoot~=rootPart or not mover then startFlight(rootPart,humanoid) end
  goal=targetRoot.Position+Vector3.new(0,0,3)
  if (mover.Position-goal).Magnitude>0.1 then mover.Position=goal end
  local look=Vector3.new(targetRoot.Position.X,rootPart.Position.Y,targetRoot.Position.Z)
  if (look-rootPart.Position).Magnitude>0.1 then
   orientation.CFrame=CFrame.lookAt(rootPart.Position,look).Rotation
  end
 end
 if attackTarget then attackTarget(rootPart,targetRoot) end
 if statusElapsed<0.25 then return end
 statusElapsed=0
 local distance=(goal-rootPart.Position).Magnitude
 if distance<3 then
  setStatus("\081\117\101\115\116\032\097\099\116\105\118\101\032"..questProgress.."\032\226\128\162\032\070\105\103\104\116\105\110\103\032"..questTargets[selectedQuest].."\046")
 elseif movementMethod=="\084\101\108\101\112\111\114\116" then
  setStatus("\084\101\108\101\112\111\114\116\105\110\103\032\116\111\032"..questTargets[selectedQuest].."\032\226\128\162\032"..math.floor(distance).."\032\115\116\117\100\115")
 else
  setStatus("\070\108\121\105\110\103\032\116\111\032"..questTargets[selectedQuest].."\032\226\128\162\032"..math.floor(distance).."\032\115\116\117\100\115")
 end
end
startController=function()
 if controller then return end
 updateElapsed=0; statusElapsed=0.25
 controller=RunService.Heartbeat:Connect(function(dt)
  updateElapsed=updateElapsed+dt
  if updateElapsed<0.05 then return end
  local elapsed=updateElapsed; updateElapsed=0
  updateFlight(elapsed)
 end)
end
local ReplicatedStorage=game:GetService("\082\101\112\108\105\099\097\116\101\100\083\116\111\114\097\103\101")
local autoEquip=false
local selectedUID
local desiredUID
local desiredItemID
local selectedLabel
local labelsToItems={}
local currentItems={}
local lastInventory=""
local refreshTools
local lastAttack=0
local lastEquip=0
local attackInterval=0.35
local attackGeneration=0
local heldCombat
local bridge={ready=false,loading=false,error="\087\097\105\116\105\110\103\032\102\111\114\032\103\097\109\101\032\099\111\110\116\114\111\108\108\101\114\115\226\128\166"}
local espEnabled=false
local espEntries={}
local ESP_LIMIT=30
local ESP_RANGE=1000
local espFolder=new("\070\111\108\100\101\114",{Name="\077\111\109\111\110\103\097\078\080\067\069\083\080"},gui)
home:Section("\065\117\116\111\032\069\113\117\105\112")
local lastReport
local function report(message)
 message=tostring(message)
 if message~=lastReport then
  lastReport=message
  if message:lower():find("\101\114\114\111\114",1,true) or message:lower():find("\117\110\097\118\097\105\108\097\098\108\101",1,true) then
   warn("\091\077\111\109\111\110\103\097\072\117\098\093\032"..message)
  end
 end
end
local function loadBridge()
 if bridge.ready or bridge.loading then return end
 bridge.loading=true
 task.spawn(function()
  local ok,err=pcall(function()
   local system=ReplicatedStorage:FindFirstChild("\083\121\115\116\101\109")
   local modules=ReplicatedStorage:FindFirstChild("\077\111\100\117\108\101\115")
   local engineModule=system and system:FindFirstChild("\069\110\103\105\110\101")
   local itemsModule=modules and modules:FindFirstChild("\105\116\101\109\095\117\116\105\108\115")
   local remotesModule=ReplicatedStorage:FindFirstChild("\082\101\109\111\116\101\115")
   if not engineModule or not itemsModule or not remotesModule then error("\071\097\109\101\032\109\111\100\117\108\101\115\032\110\111\116\032\097\118\097\105\108\097\098\108\101\032\121\101\116") end
   local engine=require(engineModule)
   local user=engine.get_controller("\085\115\101\114\067\111\110\116\114\111\108\108\101\114")
   local equipController=engine.get_controller("\069\113\117\105\112\067\111\110\116\114\111\108\108\101\114")
   local combat=engine.get_controller("\067\111\109\098\097\116\067\111\110\116\114\111\108\108\101\114")
   local dodgeController=engine.get_controller("\068\111\100\103\101\067\111\110\116\114\111\108\108\101\114")
   local quests=engine.get_controller("\081\117\101\115\116\067\111\110\116\114\111\108\108\101\114")
   if not user or not user.inventory or not equipController or not combat or not combat.combat or not quests then error("\071\097\109\101\032\099\111\110\116\114\111\108\108\101\114\115\032\097\114\101\032\115\116\105\108\108\032\115\116\097\114\116\105\110\103") end
   local remotes=require(remotesModule)
   local itemUtils=require(itemsModule)
   if dead then return end
   bridge.user=user; bridge.equip=equipController; bridge.combat=combat; bridge.dodge=dodgeController; bridge.remotes=remotes; bridge.items=itemUtils
   bridge.quests=quests; bridge.questUtils=require(modules:FindFirstChild("\113\117\101\115\116\115")); bridge.ready=true
  end)
  bridge.loading=false
  if not ok then
   bridge.error=tostring(err)
   if not dead then report("\067\111\110\110\101\099\116\105\111\110\032\112\101\110\100\105\110\103\058\032"..bridge.error) end
  end
 end)
end
local function releaseAttack()
 attackGeneration=attackGeneration+1
 if heldCombat then
  local combat=heldCombat; heldCombat=nil
  pcall(function() combat:set_button_pressed("\104\105\116",false); combat.combat:request_hit(false) end)
 end
end
stopAttack=releaseAttack
local function normalizeUID(value)
 if value==nil then return nil end
 return tostring(value)
end
local function resolveToolID(item)
 if not item or not bridge.ready then return nil end
 if type(item.toolID)=="\110\117\109\098\101\114" then return item.toolID end
 local rawID=item.id
 if rawID==nil and type(item.raw)=="\116\097\098\108\101" then rawID=item.raw.id end
 local numeric
 if type(rawID)=="\110\117\109\098\101\114" then
  numeric=rawID
 elseif type(rawID)=="\115\116\114\105\110\103" and type(bridge.items.get_id)=="\102\117\110\099\116\105\111\110" then
  local ok,value=pcall(bridge.items.get_id,rawID)
  if ok then numeric=value end
 end
 if type(numeric)=="\110\117\109\098\101\114" then
  numeric=math.floor(numeric)
  if numeric>=0 and numeric<=65535 then
   item.toolID=numeric
   return numeric
  end
 end
 return nil
end
local function selectedToolMatches(item)
 if not bridge.ready or not item then return false end
 local wanted=resolveToolID(item)
 if not wanted then return false end
 if bridge.combat and bridge.combat.selected_item_id==wanted then return true end
 local ok,selected=pcall(function()
  return bridge.user:get_player_selected_tool(player.UserId)
 end)
 if not ok or type(selected)~="\116\097\098\108\101" then return false end
 return selected.id==wanted
end
local function tryRemoteEquip(item)
 local numericToolID=resolveToolID(item)
 if not numericToolID then
  report("\069\113\117\105\112\032\117\110\097\118\097\105\108\097\098\108\101\058\032\099\111\117\108\100\032\110\111\116\032\114\101\115\111\108\118\101\032\110\117\109\101\114\105\099\032\116\111\111\108\032\105\100\032\102\111\114\032"..tostring(item and item.id))
  return false
 end
 local equip=bridge.remotes and bridge.remotes.equip
 local remote=equip and equip.select_tool
 if not remote or type(remote.Fire)~="\102\117\110\099\116\105\111\110" then
  report("\069\113\117\105\112\032\117\110\097\118\097\105\108\097\098\108\101\058\032\115\101\108\101\099\116\095\116\111\111\108\032\114\101\109\111\116\101\032\109\105\115\115\105\110\103")
  return false
 end
 local ok,err=pcall(function()
  remote.Fire(numericToolID)
 end)
 if not ok then
  report("\069\113\117\105\112\032\101\114\114\111\114\058\032"..tostring(err))
  return false
 end
 return true
end
local equipGeneration=0
local function equipSelected(force)
 if not force and not autoEquip then return false end
 if not bridge.ready then loadBridge(); return false end
 if selectedUID==nil then return false end
 local item=currentItems[normalizeUID(selectedUID)] or labelsToItems[selectedLabel]
 if not item then return false end
 local character=player.Character
 local humanoid=character and character:FindFirstChildOfClass("\072\117\109\097\110\111\105\100")
 if not humanoid or humanoid.Health<=0 then return false end
 if selectedToolMatches(item) then return true end
 if not force and os.clock()-lastEquip<0.35 then return false end
 lastEquip=os.clock()
 equipGeneration=equipGeneration+1
 local generation=equipGeneration
 if not tryRemoteEquip(item) then return false end
 task.delay(0.22,function()
  if dead or generation~=equipGeneration then return end
  if not force and not autoEquip then return end
  if selectedToolMatches(item) then return end
  tryRemoteEquip(item)
 end)
 return true
end
local toolDropdown=home:Dropdown("\083\101\108\101\099\116\032\072\111\116\098\097\114\032\073\116\101\109","\068\101\116\101\099\116\115\032\101\118\101\114\121\032\105\116\101\109\032\099\117\114\114\101\110\116\108\121\032\097\115\115\105\103\110\101\100\032\116\111\032\121\111\117\114\032\103\097\109\101\032\104\111\116\098\097\114\044\032\114\101\103\097\114\100\108\101\115\115\032\111\102\032\105\116\101\109\032\116\121\112\101\046",{"\076\111\097\100\105\110\103\032\104\111\116\098\097\114\226\128\166"},"\076\111\097\100\105\110\103\032\104\111\116\098\097\114\226\128\166",function(label)
 selectedLabel=label
 local item=labelsToItems[label]
 selectedUID=item and item.uid or nil
 desiredUID=selectedUID
 desiredItemID=item and item.id or nil
 if item then
  remember("\073\116\101\109\085\073\068",item.uid)
  remember("\073\116\101\109\073\068",item.id)
 end
 releaseAttack()
 lastEquip=0
 equipSelected(true)
end)
home:Toggle("\065\117\116\111\032\069\113\117\105\112","\075\101\101\112\032\116\104\101\032\115\101\108\101\099\116\101\100\032\104\111\116\098\097\114\032\105\116\101\109\032\115\101\108\101\099\116\101\100\032\117\115\105\110\103\032\116\104\101\032\115\097\109\101\032\101\113\117\105\112\032\114\101\113\117\101\115\116\032\097\115\032\116\104\101\032\103\097\109\101\032\104\111\116\098\097\114\046",false,function(enabled)
 autoEquip=enabled
 lastEquip=0
 if enabled then equipSelected(true) end
end)
home:Button("\082\101\102\114\101\115\104\032\072\111\116\098\097\114","\070\111\114\099\101\032\097\032\102\114\101\115\104\032\115\099\097\110\032\111\102\032\101\118\101\114\121\032\105\116\101\109\032\099\117\114\114\101\110\116\108\121\032\097\115\115\105\103\110\101\100\032\116\111\032\121\111\117\114\032\104\111\116\098\097\114\032\097\110\100\032\114\101\098\117\105\108\100\032\116\104\101\032\100\114\111\112\100\111\119\110\046","\082\101\102\114\101\115\104",function()
 local current=selectedUID and currentItems[normalizeUID(selectedUID)] or labelsToItems[selectedLabel]
 if current then
  desiredUID=current.uid or selectedUID
  desiredItemID=current.id or desiredItemID
 elseif selectedUID~=nil then
  desiredUID=selectedUID
 end
 lastInventory="\095\095\077\079\077\079\078\071\065\095\070\079\082\067\069\095\082\069\070\082\069\083\072\095\095"
 if not bridge.ready then
  loadBridge()
  API:Notify("\067\111\110\110\101\099\116\105\110\103\032\116\111\032\104\111\116\098\097\114\226\128\166")
  task.delay(0.6,function()
   if dead or not refreshTools then return end
   lastInventory="\095\095\077\079\077\079\078\071\065\095\070\079\082\067\069\095\082\069\070\082\069\083\072\095\082\069\084\082\089\095\095"
   refreshTools()
   if autoEquip then lastEquip=0; equipSelected(true) end
   API:Notify("\072\111\116\098\097\114\032\114\101\102\114\101\115\104\101\100\046")
  end)
  return
 end
 refreshTools()
 if autoEquip then lastEquip=0; equipSelected(true) end
 API:Notify("\072\111\116\098\097\114\032\114\101\102\114\101\115\104\101\100\046")
end)
home:Slider("\065\116\116\097\099\107\032\105\110\116\101\114\118\097\108","\082\101\113\117\101\115\116\032\105\110\116\101\114\118\097\108\059\032\116\104\101\032\103\097\109\101\039\115\032\099\111\111\108\100\111\119\110\115\032\115\116\105\108\108\032\097\112\112\108\121\046",0.15,1.5,0.35,0.05,function(value)
 attackInterval=value
end)
refreshTools=function()
 if not bridge.ready then loadBridge(); return end
 local ok,err=pcall(function()
  local inventory=bridge.user.inventory()
  if type(inventory)~="\116\097\098\108\101" or type(inventory.container)~="\116\097\098\108\101" then
   report("\087\097\105\116\105\110\103\032\102\111\114\032\105\110\118\101\110\116\111\114\121\032\100\097\116\097\226\128\166")
   return
  end
  local byUID={}
  for key,raw in pairs(inventory.container) do
   if type(raw)=="\116\097\098\108\101" then
    local uid=raw.uid
    if uid==nil then uid=key end
    if uid~=nil then
     byUID[tostring(uid)]={uid=uid,id=raw.id,raw=raw}
    end
   end
  end
  local items={}
  local seenUID={}
  currentItems={}
  local function prepareItem(item,slot)
   item.slot=slot
   local display=item.id~=nil and tostring(item.id) or ("\072\111\116\098\097\114\032\073\116\101\109\032"..tostring(slot))
   if item.id~=nil and type(bridge.items.get_display_name)=="\102\117\110\099\116\105\111\110" then
    local okDisplay,value=pcall(bridge.items.get_display_name,item.id)
    if okDisplay and value and tostring(value)~="" then display=tostring(value) end
   end
   item.displayName=display
   item.toolID=resolveToolID(item)
   return item
  end
  for slot,hotbarUID in ipairs(inventory.hotbar_order or {}) do
   local uidKey=tostring(hotbarUID)
   local item=byUID[uidKey]
   if item then
    prepareItem(item,slot)
    table.insert(items,item)
    currentItems[uidKey]=item
    seenUID[uidKey]=true
   end
  end
  for uidKey,item in pairs(byUID) do
   local raw=item.raw
   if raw and raw.equipped==true and not seenUID[uidKey] then
    prepareItem(item,#items+1)
    table.insert(items,item)
    currentItems[uidKey]=item
    seenUID[uidKey]=true
   end
  end
  for slot,hotbarUID in ipairs(inventory.hotbar_order or {}) do
   local uidKey=tostring(hotbarUID)
   if not seenUID[uidKey] then
    local placeholder={uid=hotbarUID,id=nil,raw=nil,slot=slot,displayName="\072\111\116\098\097\114\032\083\108\111\116\032"..tostring(slot),toolID=nil}
    table.insert(items,placeholder)
    currentItems[uidKey]=placeholder
    seenUID[uidKey]=true
   end
  end
  local labels,signature={},{}
  local preferred
  labelsToItems={}
  for index,item in ipairs(items) do
   local slot=item.slot~=999 and item.slot or index
   local label=string.format("\037\100\032\226\128\162\032\037\115",slot,tostring(item.displayName))
   labelsToItems[label]=item
   table.insert(labels,label)
   table.insert(signature,tostring(item.uid).."\058"..tostring(item.id).."\058"..tostring(item.toolID).."\058"..label)
   if desiredUID~=nil and tostring(item.uid)==tostring(desiredUID) then preferred=label end
   if not preferred and selectedUID~=nil and tostring(item.uid)==tostring(selectedUID) then preferred=label end
  end
  if not preferred and desiredItemID~=nil then
   for _,label in ipairs(labels) do
    local item=labelsToItems[label]
    if item and tostring(item.id)==tostring(desiredItemID) then preferred=label; break end
   end
  end
  if #labels==0 then labels={"\078\111\032\104\111\116\098\097\114\032\105\116\101\109\115\032\100\101\116\101\099\116\101\100"} end
  preferred=preferred or labels[1]
  local key=table.concat(signature,"\n")
  if key~=lastInventory or selectedLabel~=preferred then
   lastInventory=key
   toolDropdown:SetOptions(labels,preferred)
   selectedLabel=preferred
   local item=labelsToItems[preferred]
   selectedUID=item and item.uid or nil
  end
 end)
 if not ok then report("\073\110\118\101\110\116\111\114\121\032\101\114\114\111\114\058\032"..tostring(err)) end
end
local function giverPosition(questID,giverID)
 local quest=bridge.quests
 local model=quest:get_giver_model(giverID)
 if model and model.Parent then
  local rootPart=mapWide.root(model)
  if rootPart then return rootPart.Position end
  return model:GetPivot().Position
 end
 local spawns=workspace:FindFirstChild("\110\112\099\095\115\112\097\119\110\115")
 local givers=spawns and spawns:FindFirstChild("\113\117\101\115\116\095\103\105\118\101\114")
 local marker=givers and givers:FindFirstChild(questID)
 if marker then
  if marker:IsA("\065\116\116\097\099\104\109\101\110\116") then return marker.WorldPosition end
  if marker:IsA("\066\097\115\101\080\097\114\116") then return marker.Position end
  if marker:IsA("\077\111\100\101\108") then
   local rootPart=mapWide.root(marker)
   return rootPart and rootPart.Position or marker:GetPivot().Position
  end
 end
 local selected=questDefinitions[selectedQuest]
 local giverName=selected and selected.giverName
 local wanted={giverID,giverName,questID}
 local character=player.Character
 local playerRoot=character and character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116")
 local function withinRange(position)
  return not playerRoot or (position-playerRoot.Position).Magnitude<=mapWide.range
 end
 for _,object in ipairs(workspace:GetDescendants()) do
  if object:IsA("\077\111\100\101\108") then
   for _,name in ipairs(wanted) do
    if name and mapWide.nameMatches(object,name) then
     local rootPart=mapWide.root(object)
     if rootPart and withinRange(rootPart.Position) then return rootPart.Position end
    end
   end
  elseif object:IsA("\065\116\116\097\099\104\109\101\110\116") or object:IsA("\066\097\115\101\080\097\114\116") then
   local objectName=mapWide.compact(object.Name)
   for _,name in ipairs(wanted) do
    if name and objectName==mapWide.compact(name) then
     local position=object:IsA("\065\116\116\097\099\104\109\101\110\116") and object.WorldPosition or object.Position
     if withinRange(position) then return position end
    end
   end
  end
 end
end
local function getCurrentLevel()
 local level
 if bridge.ready and bridge.user and type(bridge.user.profile_data)=="\102\117\110\099\116\105\111\110" then
  local ok,profile=pcall(function() return bridge.user.profile_data() end)
  if ok and type(profile)=="\116\097\098\108\101" then
   level=tonumber(profile.level or profile.Level)
   if not level and type(profile.stats)=="\116\097\098\108\101" then
    level=tonumber(profile.stats.level or profile.stats.Level)
   end
  end
 end
 if not level then
  local leaderstats=player:FindFirstChild("\108\101\097\100\101\114\115\116\097\116\115")
  local value=(leaderstats and (leaderstats:FindFirstChild("\076\101\118\101\108") or leaderstats:FindFirstChild("\108\101\118\101\108")))
   or player:FindFirstChild("\076\101\118\101\108") or player:FindFirstChild("\108\101\118\101\108")
  if value and (value:IsA("\073\110\116\086\097\108\117\101") or value:IsA("\078\117\109\098\101\114\086\097\108\117\101")) then level=value.Value end
 end
 if not level then
  level=tonumber(player:GetAttribute("\076\101\118\101\108") or player:GetAttribute("\108\101\118\101\108"))
 end
 return math.max(1,math.floor(tonumber(level) or 1))
end
local function pickLevelQuest()
 local level=getCurrentLevel()
 local best,bestScore
 for pass=1,2 do
  for _,q in ipairs(questList) do
   local d=questDefinitions[q[1]]
   local inRange=(d.max==nil or level<=d.max)
   if d.min<=level and d.questID~="\099\097\114\097\118\097\110\095\100\101\102\101\110\115\101" and not skippedQuests[d.questID] and (pass==2 or inRange) then
    local score=d.min*1000+(d.boss and 0 or 100)-d.index*0.001
    if not bestScore or score>bestScore then
     best=q[1]
     bestScore=score
    end
   end
  end
  if best then break end
 end
 return best,level
end
local function chooseQuest(label)
 if label==selectedQuest then return end
 selectedQuest=label
 target=nil; questAcceptAttempts=0; questLastAccept=-100
 releaseAttack()
 if questDropdown then questDropdown:Set(label) end   -- dropdown callback ignores it: already selected
end
questGate=function(rootPart,humanoid)
 if not bridge.ready then
  releaseAttack(); stopFlight(); setStatus("\087\097\105\116\105\110\103\032\102\111\114\032\113\117\101\115\116\032\099\111\110\116\114\111\108\108\101\114\226\128\166"); return false
 end
 local quest=bridge.quests
 if autoLevel then
  local best,level=pickLevelQuest()
  local assigned=quest:get_assigned_entry()
  local assignedLabel=assigned and labelByQuestID[assigned.id]
  if assignedLabel then
   chooseQuest(assignedLabel)
   local assignedDef=questDefinitions[assignedLabel]
   if assignedDef then
    setStatus("\065\117\116\111\032\076\101\118\101\108\032\226\128\162\032\076\086"..tostring(level).."\032\226\128\162\032\070\105\110\105\115\104\105\110\103\032"..assignedLabel.."\032\098\101\102\111\114\101\032\115\119\105\116\099\104\105\110\103\046")
   end
  elseif best then
   chooseQuest(best)
  else
   releaseAttack(); stopFlight(); target=nil
   setStatus("\065\117\116\111\032\076\101\118\101\108\032\226\128\162\032\078\111\032\117\115\097\098\108\101\032\113\117\101\115\116\032\102\111\117\110\100\032\102\111\114\032\076\086"..tostring(level).."\046")
   return false
  end
 end
 local selected=questDefinitions[selectedQuest]
 local QUEST_ID,GIVER_ID=selected.questID,selected.giverID
 local giverName=selected.giverName
 local entry=quest:get_entry(QUEST_ID)
 if entry then
  questAcceptAttempts=0; questLastAccept=-100
  local definition=bridge.questUtils.get_quest(QUEST_ID)
  local done,total=bridge.questUtils.get_entry_progress(definition,entry)
  questProgress=string.format("\037\100\047\037\100",done,total)
  if entry.completed==true or done>=total then
   releaseAttack(); stopFlight(); target=nil
   local currentLevel=getCurrentLevel()
   local nextBest=autoLevel and select(1,pickLevelQuest()) or nil
   if autoLevel and nextBest then
    setStatus("\065\117\116\111\032\076\101\118\101\108\032\226\128\162\032\076\086"..tostring(currentLevel).."\032\226\128\162\032\081\117\101\115\116\032\099\111\109\112\108\101\116\101\059\032\110\101\120\116\032\098\101\115\116\058\032"..nextBest.."\046")
   else
    setStatus("\081\117\101\115\116\032"..questProgress.."\032\099\111\109\112\108\101\116\101\032\226\128\162\032\087\097\105\116\105\110\103\032\102\111\114\032\115\101\114\118\101\114\032\114\101\119\097\114\100\047\115\116\097\116\101\032\117\112\100\097\116\101\226\128\166")
   end
   return false
  end
  return true
 end
 local assigned=quest:get_assigned_entry()
 if assigned then
  releaseAttack(); stopFlight(); target=nil
  setStatus("\065\110\111\116\104\101\114\032\113\117\101\115\116\032\105\115\032\097\099\116\105\118\101\058\032"..tostring(assigned.id).."\046\032\070\105\110\105\115\104\032\105\116\032\102\105\114\115\116\046")
  return false
 end
 releaseAttack(); target=nil
 local profile=bridge.user.profile_data()
 local definition=bridge.questUtils.get_quest(QUEST_ID)
 if (profile.level or 1)<(definition.min_level or 1) then
  stopFlight(); setStatus(giverName.."\039\115\032\113\117\101\115\116\032\110\101\101\100\115\032\108\101\118\101\108\032"..tostring(definition.min_level)); return false
 end
 local position=giverPosition(QUEST_ID,GIVER_ID)
 if not position then
  stopFlight(); setStatus("\087\097\105\116\105\110\103\032\102\111\114\032"..giverName.."\032\111\114\032\116\104\101\032\113\117\101\115\116\032\109\097\114\107\101\114\032\116\111\032\108\111\097\100\226\128\166"); return false
 end
 local distance=(position-rootPart.Position).Magnitude
 if questAcceptAttempts>=3 and os.clock()-questLastAccept>=5 then
  stopFlight()
  if autoLevel then
   skippedQuests[QUEST_ID]=true; questAcceptAttempts=0; questLastAccept=-100
   setStatus("\065\117\116\111\032\076\101\118\101\108\032\226\128\162\032"..giverName.."\032\100\105\100\032\110\111\116\032\099\111\110\102\105\114\109\059\032\116\114\121\105\110\103\032\116\104\101\032\110\101\120\116\032\113\117\101\115\116\226\128\166")
  else
   setStatus(giverName.."\032\104\097\115\032\110\111\116\032\099\111\110\102\105\114\109\101\100\032\116\104\101\032\113\117\101\115\116\046\032\067\104\101\099\107\032\116\104\101\032\100\105\097\108\111\103\117\101\044\032\116\104\101\110\032\116\111\103\103\108\101\032\065\117\116\111\032\081\117\101\115\116\032\097\103\097\105\110\046")
  end
  return false
 end
 if movementMethod=="\084\101\108\101\112\111\114\116" then
  teleportNear(rootPart,position,Vector3.new(0,0,3))
  if distance>5 then
   setStatus("\084\101\108\101\112\111\114\116\105\110\103\032\116\111\032"..giverName.."\032\226\128\162\032"..math.floor(distance).."\032\115\116\117\100\115"); return false
  end
 else
  if flightRoot~=rootPart or not mover then startFlight(rootPart,humanoid) end
  local goal=position+Vector3.new(0,0,3)
  if (mover.Position-goal).Magnitude>0.1 then mover.Position=goal end
  local look=Vector3.new(position.X,rootPart.Position.Y,position.Z)
  if (look-rootPart.Position).Magnitude>0.1 then orientation.CFrame=CFrame.lookAt(rootPart.Position,look).Rotation end
  if distance>5 then
   setStatus("\070\108\121\105\110\103\032\116\111\032"..giverName.."\032\226\128\162\032"..math.floor(distance).."\032\115\116\117\100\115"); return false
  end
 end
 if os.clock()-questLastAccept<5 then
  setStatus("\065\099\099\101\112\116\105\110\103\032"..giverName.."\039\115\032\113\117\101\115\116\032\226\128\162\032\087\097\105\116\105\110\103\032\102\111\114\032\115\101\114\118\101\114\032\099\111\110\102\105\114\109\097\116\105\111\110\226\128\166"); return false
 end
 questLastAccept=os.clock(); questAcceptAttempts=questAcceptAttempts+1
 local handle
 for _,candidate in pairs(quest.handles or {}) do
  if candidate.giver_id==GIVER_ID and candidate.quest_id==QUEST_ID and candidate.model.Parent then handle=candidate; break end
 end
 if handle then
  local dialogue=quest:get_dialogue(handle)
  local canAccept=false
  for _,response in ipairs(dialogue.responses or {}) do if response.action=="\097\099\099\101\112\116" then canAccept=true end end
  if not canAccept then
   stopFlight(); questAcceptAttempts=3
   setStatus(giverName.."\058\032"..tostring(dialogue.prompt or "\081\117\101\115\116\032\117\110\097\118\097\105\108\097\098\108\101")); return false
  end
  quest:open_dialogue(handle)
  quest:respond_to_dialogue("\097\099\099\101\112\116")
 else
  bridge.remotes.quests.accept.Fire(QUEST_ID)
 end
 setStatus("\065\099\099\101\112\116\105\110\103\032"..giverName.."\039\115\032\113\117\101\115\116\032\226\128\162\032\087\097\105\116\105\110\103\032\102\111\114\032\115\101\114\118\101\114\032\099\111\110\102\105\114\109\097\116\105\111\110\226\128\166")
 return false
end
attackTarget=function(rootPart,targetRoot)
 if not autoQuest or (rootPart.Position-targetRoot.Position).Magnitude>6 then releaseAttack(); return end
 if not bridge.ready then report("\087\097\105\116\105\110\103\032\102\111\114\032\099\111\109\098\097\116\032\099\111\110\116\114\111\108\108\101\114\226\128\166"); return end
 if os.clock()-lastAttack<attackInterval then return end
 lastAttack=os.clock()
 local ok,err=pcall(function()
  local combat=bridge.combat
  if not combat.selected_item_id then releaseAttack(); report("\083\101\108\101\099\116\032\097\032\109\101\108\101\101\032\105\116\101\109\032\097\110\100\032\101\110\097\098\108\101\032\065\117\116\111\032\069\113\117\105\112\046"); return end
  if combat:is_gun_selected() then releaseAttack(); report("\083\101\108\101\099\116\101\100\032\105\116\101\109\032\105\115\032\097\032\103\117\110\046\032\084\104\105\115\032\097\100\097\112\116\101\114\032\115\117\112\112\111\114\116\115\032\109\101\108\101\101\032\097\116\116\097\099\107\115\046"); return end
  local config=bridge.items.get_config_from_id(combat.selected_item_id)
  if not config or not config.combat then releaseAttack(); report("\083\101\108\101\099\116\101\100\032\105\116\101\109\032\104\097\115\032\110\111\032\109\101\108\101\101\032\099\111\109\098\097\116\032\099\111\110\102\105\103\117\114\097\116\105\111\110\046"); return end
  if combat:is_casting() or not combat.combat:can_request_hit() then
   releaseAttack(); report("\087\097\105\116\105\110\103\032\102\111\114\032\099\111\109\098\097\116\032\097\118\097\105\108\097\098\105\108\105\116\121\226\128\166"); return
  end
  if not combat:can_predict_swing() then return end
  releaseAttack()
  heldCombat=combat
  local generation=attackGeneration
  combat:set_button_pressed("\104\105\116",true)
  combat:request_hit()
  report("\077\101\108\101\101\032\097\116\116\097\099\107\032\114\101\113\117\101\115\116\101\100\032\226\128\162\032"..tostring(bridge.items.get_name_from_id(combat.selected_item_id)))
  task.delay(0.1,function()
   if generation==attackGeneration and heldCombat==combat then releaseAttack() end
  end)
 end)
 if not ok then releaseAttack(); report("\067\111\109\098\097\116\032\101\114\114\111\114\058\032"..tostring(err)) end
end
local function removeESP(model)
 local entry=espEntries[model]
 if entry then entry.highlight:Destroy(); entry.billboard:Destroy(); espEntries[model]=nil end
end
local function clearESP()
 for model in pairs(espEntries) do removeESP(model) end
end
local function updateESP()
 if not espEnabled then return end
 local character=player.Character
 local rootPart=character and character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116")
 if not rootPart then clearESP(); return end
 local nearby={}
 for model in pairs(npcModels) do
  if model:IsDescendantOf(workspace) and not Players:GetPlayerFromCharacter(model) then
   local humanoid=model:FindFirstChildOfClass("\072\117\109\097\110\111\105\100")
   local part=model:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") or model.PrimaryPart or model:FindFirstChild("\072\101\097\100")
   if humanoid and humanoid.Health>0 and part and part:IsA("\066\097\115\101\080\097\114\116") then
    local distance=(part.Position-rootPart.Position).Magnitude
    if distance<=ESP_RANGE then table.insert(nearby,{model=model,part=part,humanoid=humanoid,distance=distance}) end
   end
  end
 end
 table.sort(nearby,function(a,b) return a.distance<b.distance end)
 local keep={}
 for i=1,math.min(ESP_LIMIT,#nearby) do
  local info=nearby[i]; local model=info.model; keep[model]=true
  local entry=espEntries[model]
  if not entry then
   local highlight=new("\072\105\103\104\108\105\103\104\116",{Adornee=model,FillColor=C.Accent,OutlineColor=Color3.fromRGB(255,210,237),
    FillTransparency=0.8,OutlineTransparency=0.15,DepthMode=Enum.HighlightDepthMode.AlwaysOnTop},espFolder)
   local billboard=new("\066\105\108\108\098\111\097\114\100\071\117\105",{Adornee=info.part,Size=UDim2.fromOffset(190,42),
    StudsOffsetWorldSpace=Vector3.new(0,3.5,0),AlwaysOnTop=true,MaxDistance=ESP_RANGE},espFolder)
   local label=new("\084\101\120\116\076\097\098\101\108",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Font=Enum.Font.GothamBold,
    TextSize=12,TextColor3=C.Text,TextStrokeTransparency=0.2,TextWrapped=true},billboard)
   entry={highlight=highlight,billboard=billboard,label=label}; espEntries[model]=entry
  end
  entry.billboard.Adornee=info.part
  local caption=string.format("%s • %d studs\n%d / %d HP",model.Name,math.floor(info.distance),math.ceil(info.humanoid.Health),math.ceil(info.humanoid.MaxHealth))
  if entry.label.Text~=caption then entry.label.Text=caption end
 end
 for model in pairs(espEntries) do if not keep[model] then removeESP(model) end end
end
cleanupExtras=function()
 autoEquip=false; espEnabled=false; releaseAttack(); clearESP()
end
refreshTools()
task.spawn(function()
 while not dead do
  task.wait(0.5)
  if dead then break end
  if window.Visible or autoEquip or autoQuest then refreshTools() end
  if autoEquip then equipSelected() end
  if not autoQuest then releaseAttack() end
  updateESP()
 end
end)
local dodgeState={enabled=false,lastAttempt=0,statusLabel=nil,lastText=nil}
autoDodgeTab:Section("\065\117\116\111\032\068\111\100\103\101")
local dodgeStatus=autoDodgeTab:Paragraph("\068\111\100\103\101\032\115\116\097\116\117\115","\079\102\102\032\226\128\162\032\087\097\105\116\105\110\103\032\102\111\114\032\068\111\100\103\101\067\104\097\114\103\101\046")
for _,child in ipairs(dodgeStatus:GetChildren()) do
 if child:IsA("\084\101\120\116\076\097\098\101\108") and child.Text:sub(1,3)=="\079\102\102" then
  dodgeState.statusLabel=child
  break
 end
end
function dodgeState.setStatus(message)
 if message==dodgeState.lastText then return end
 dodgeState.lastText=message
 if dodgeState.statusLabel and dodgeState.statusLabel.Parent then
  dodgeState.statusLabel.Text=message
 end
end
function dodgeState.getController()
 if bridge.ready and bridge.dodge then return bridge.dodge end
 if not bridge.ready then loadBridge() end
 local system=ReplicatedStorage:FindFirstChild("\083\121\115\116\101\109")
 local engineModule=system and system:FindFirstChild("\069\110\103\105\110\101")
 if not engineModule then return nil end
 local ok,controller=pcall(function()
  return require(engineModule).get_controller("\068\111\100\103\101\067\111\110\116\114\111\108\108\101\114")
 end)
 if ok and controller then
  bridge.dodge=controller
  return controller
 end
 return nil
end
function dodgeState.chargePercent()
 local controller=dodgeState.getController()
 if controller and type(controller.get_charge)=="\102\117\110\099\116\105\111\110" then
  local ok,charge=pcall(function() return controller:get_charge() end)
  if ok and type(charge)=="\110\117\109\098\101\114" then
   return math.clamp(charge,0,1)*100,controller
  end
 end
 local character=player.Character
 local humanoid=character and character:FindFirstChildOfClass("\072\117\109\097\110\111\105\100")
 local charge=humanoid and humanoid:GetAttribute("\068\111\100\103\101\067\104\097\114\103\101")
 if type(charge)=="\110\117\109\098\101\114" then
  return math.clamp(charge,0,1)*100,controller
 end
 return 0,controller
end
function dodgeState.trigger(controller)
 if os.clock()-dodgeState.lastAttempt<0.35 then return false end
 dodgeState.lastAttempt=os.clock()
 controller=controller or dodgeState.getController()
 if controller and type(controller.can_dodge)=="\102\117\110\099\116\105\111\110" and type(controller.dodge)=="\102\117\110\099\116\105\111\110" then
  local ok,can=pcall(function() return controller:can_dodge() end)
  if ok and can then
   return pcall(function() controller:dodge() end)
  end
 end
 local remote=bridge.remotes and bridge.remotes.combat and bridge.remotes.combat.request_dodge
 if remote and type(remote.Fire)=="\102\117\110\099\116\105\111\110" then
  return pcall(function() remote.Fire() end)
 end
 return false
end
autoDodgeTab:Toggle("\065\117\116\111\032\068\111\100\103\101","\087\104\101\110\032\116\104\101\032\114\101\097\108\032\068\111\100\103\101\032\098\097\114\032\114\101\097\099\104\101\115\032\049\048\048\037\044\032\116\114\105\103\103\101\114\032\116\104\101\032\115\097\109\101\032\100\111\100\103\101\032\097\099\116\105\111\110\032\117\115\101\100\032\098\121\032\070\046",false,function(enabled)
 dodgeState.enabled=enabled
 dodgeState.lastAttempt=0
 if enabled then
  dodgeState.setStatus("\065\117\116\111\032\068\111\100\103\101\032\226\128\162\032\087\097\116\099\104\105\110\103\032\068\111\100\103\101\067\104\097\114\103\101\226\128\166")
 else
  dodgeState.setStatus("\079\102\102\032\226\128\162\032\065\117\116\111\032\068\111\100\103\101\032\115\116\111\112\112\101\100\046")
 end
end)
autoDodgeTab:Paragraph("\072\111\119\032\105\116\032\119\111\114\107\115","\085\115\101\115\032\116\104\101\032\103\097\109\101\039\115\032\114\101\097\108\032\068\111\100\103\101\067\104\097\114\103\101\032\118\097\108\117\101\032\105\110\115\116\101\097\100\032\111\102\032\103\117\101\115\115\105\110\103\032\102\114\111\109\032\116\104\101\032\071\085\073\032\102\105\108\108\046\032\065\116\032\049\048\048\037\044\032\105\116\032\116\114\105\103\103\101\114\115\032\116\104\101\032\101\120\097\099\116\032\068\111\100\103\101\067\111\110\116\114\111\108\108\101\114\032\097\099\116\105\111\110\032\098\111\117\110\100\032\116\111\032\070\046")
task.spawn(function()
 while not dead do
  task.wait(0.08)
  if dead then break end
  if not dodgeState.enabled then continue end
  local percent,controller=dodgeState.chargePercent()
  local rounded=math.floor(percent+0.5)
  if percent>=99.999 then
   dodgeState.setStatus("\065\117\116\111\032\068\111\100\103\101\032\226\128\162\032\049\048\048\037\032\226\128\162\032\068\111\100\103\105\110\103\226\128\166")
   if dodgeState.trigger(controller) then
    task.wait(0.18)
   end
  else
   dodgeState.setStatus("\065\117\116\111\032\068\111\100\103\101\032\226\128\162\032"..tostring(rounded).."\037")
  end
 end
end)
local autoStat=false
local selectedStats={}
local statOrder={"\083\116\114\101\110\103\116\104","\083\116\097\109\105\110\097","\071\117\110\032\080\111\119\101\114","\083\119\111\114\100","\072\101\097\108\116\104"}
local statAliases={
 ["\083\116\114\101\110\103\116\104"]={"\115\116\114\101\110\103\116\104"},
 ["\083\116\097\109\105\110\097"]={"\115\116\097\109\105\110\097","\101\110\101\114\103\121"},
 ["\071\117\110\032\080\111\119\101\114"]={"\103\117\110\112\111\119\101\114","\103\117\110","\102\105\114\101\097\114\109\112\111\119\101\114","\102\105\114\101\097\114\109"},
 ["\083\119\111\114\100"]={"\115\119\111\114\100","\115\119\111\114\100\112\111\119\101\114"},
 ["\072\101\097\108\116\104"]={"\104\101\097\108\116\104","\104\112","\118\105\116\097\108\105\116\121"},
}
local statButtonCache={}
local statIndex=0
local lastStatClick=0
local lastStatScan={}
local function setStatStatus(_message)
end
local function normalized(value)
 return tostring(value or ""):lower():gsub("\091\094\037\119\093","")
end
local function statMatches(instance,stat)
 local aliases=statAliases[stat] or {}
 local candidates={normalized(instance.Name)}
 if instance:IsA("\084\101\120\116\076\097\098\101\108") or instance:IsA("\084\101\120\116\066\117\116\116\111\110") or instance:IsA("\084\101\120\116\066\111\120") then table.insert(candidates,normalized(instance.Text)) end
 for _,candidate in ipairs(candidates) do
  for _,alias in ipairs(aliases) do
   local a=normalized(alias)
   if candidate==a or (#a>=3 and candidate:find(a,1,true)) then return true end
  end
 end
 return false
end
local function usefulUpgradeButton(button)
 if not button:IsA("\071\117\105\066\117\116\116\111\110") then return false end
 local n=normalized(button.Name)
 local t=button:IsA("\084\101\120\116\066\117\116\116\111\110") and normalized(button.Text) or ""
 return n=="\097\100\100" or n=="\112\108\117\115" or n=="\117\112\103\114\097\100\101" or n=="\104\105\116\098\111\120" or n=="\105\110\099\114\101\097\115\101" or n:find("\117\112\103\114\097\100\101",1,true) or t=="\043" or t=="\097\100\100" or t=="\117\112\103\114\097\100\101"
end
local function findStatButton(stat)
 local cached=statButtonCache[stat]
 if cached and cached.Parent then return cached end
 statButtonCache[stat]=nil
 if os.clock()-(lastStatScan[stat] or -100)<1.5 then return nil end
 lastStatScan[stat]=os.clock()
 local matches={}
 for _,object in ipairs(playerGui:GetDescendants()) do
  if object:IsA("\071\117\105\066\117\116\116\111\110") and usefulUpgradeButton(object) then
   local node=object
   local score=0
   for depth=1,7 do
    node=node.Parent
    if not node or node==playerGui then break end
    if statMatches(node,stat) then score=score+20-depth end
   end
   if score>0 then table.insert(matches,{button=object,score=score}) end
  end
 end
 table.sort(matches,function(a,b) return a.score>b.score end)
 local button=matches[1] and matches[1].button
 statButtonCache[stat]=button
 return button
end
local function activateButton(button)
 if not button or not button.Parent then return false end
 local env
 pcall(function()
  if type(getgenv)=="\102\117\110\099\116\105\111\110" then env=getgenv()
  elseif type(getfenv)=="\102\117\110\099\116\105\111\110" then env=getfenv() end
 end)
 local fs=env and env.firesignal
 if type(fs)=="\102\117\110\099\116\105\111\110" then
  local ok=pcall(function()
   if button:IsA("\084\101\120\116\066\117\116\116\111\110") or button:IsA("\073\109\097\103\101\066\117\116\116\111\110") then fs(button.MouseButton1Click) end
  end)
  if ok then return true end
 end
 return pcall(function() button:Activate() end)
end
local function currentStatPoints()
 for _,container in ipairs({player:FindFirstChild("\068\097\116\097"),player:FindFirstChild("\108\101\097\100\101\114\115\116\097\116\115"),player}) do
  if container then
   for _,name in ipairs({"\080\111\105\110\116\115","\083\116\097\116\080\111\105\110\116\115","\083\116\097\116\095\080\111\105\110\116\115","\083\107\105\108\108\080\111\105\110\116\115","\065\116\116\114\105\098\117\116\101\080\111\105\110\116\115"}) do
    local value=container:FindFirstChild(name)
    if value and (value:IsA("\073\110\116\086\097\108\117\101") or value:IsA("\078\117\109\098\101\114\086\097\108\117\101")) then return value.Value end
   end
  end
 end
 if bridge.ready and bridge.user and bridge.user.profile_data then
  local ok,profile=pcall(function() return bridge.user.profile_data() end)
  if ok and type(profile)=="\116\097\098\108\101" then
   for _,name in ipairs({"\112\111\105\110\116\115","\115\116\097\116\095\112\111\105\110\116\115","\115\107\105\108\108\095\112\111\105\110\116\115","\097\116\116\114\105\098\117\116\101\095\112\111\105\110\116\115"}) do
    if type(profile[name])=="\110\117\109\098\101\114" then return profile[name] end
   end
  end
 end
end
local function rebuildSelectedStats(values)
 table.clear(selectedStats)
 for _,stat in ipairs(values or {}) do selectedStats[stat]=true end
end
autoStatTab:Section("\065\117\116\111\032\083\116\097\116")
autoStatTab:MultiDropdown("\083\101\108\101\099\116\032\083\116\097\116\115","\067\104\111\111\115\101\032\109\117\108\116\105\112\108\101\032\115\116\097\116\115\046\032\065\117\116\111\083\116\097\116\032\114\111\116\097\116\101\115\032\116\104\114\111\117\103\104\032\101\118\101\114\121\032\115\101\108\101\099\116\101\100\032\111\112\116\105\111\110\046",statOrder,{},function(values)
 rebuildSelectedStats(values)
 statIndex=0
 if autoStat and #values==0 then setStatStatus("\065\117\116\111\032\083\116\097\116\032\105\115\032\111\110\044\032\098\117\116\032\110\111\032\115\116\097\116\115\032\097\114\101\032\115\101\108\101\099\116\101\100\046") end
end)
autoStatTab:Toggle("\065\117\116\111\032\083\116\097\116","\065\117\116\111\109\097\116\105\099\097\108\108\121\032\112\114\101\115\115\032\116\104\101\032\103\097\109\101\039\115\032\115\116\097\116\032\117\112\103\114\097\100\101\032\098\117\116\116\111\110\032\102\111\114\032\101\097\099\104\032\115\101\108\101\099\116\101\100\032\115\116\097\116\046",false,function(enabled)
 autoStat=enabled
 statIndex=0; lastStatClick=0
 if enabled then setStatStatus("\065\117\116\111\032\083\116\097\116\032\226\128\162\032\076\111\111\107\105\110\103\032\102\111\114\032\115\101\108\101\099\116\101\100\032\115\116\097\116\032\117\112\103\114\097\100\101\032\098\117\116\116\111\110\115\226\128\166") else setStatStatus("\079\102\102\032\226\128\162\032\065\117\116\111\032\083\116\097\116\032\115\116\111\112\112\101\100\046") end
end)
autoStatTab:Paragraph("\072\111\119\032\105\116\032\119\111\114\107\115","\083\101\108\101\099\116\032\083\116\114\101\110\103\116\104\044\032\083\116\097\109\105\110\097\044\032\071\117\110\032\080\111\119\101\114\044\032\083\119\111\114\100\044\032\097\110\100\047\111\114\032\072\101\097\108\116\104\046\032\084\104\101\032\104\117\098\032\114\111\116\097\116\101\115\032\116\104\114\111\117\103\104\032\121\111\117\114\032\115\101\108\101\099\116\105\111\110\032\097\110\100\032\117\115\101\115\032\116\104\101\032\103\097\109\101\039\115\032\111\119\110\032\117\112\103\114\097\100\101\032\098\117\116\116\111\110\115\044\032\115\111\032\110\111\114\109\097\108\032\112\111\105\110\116\032\099\104\101\099\107\115\032\115\116\105\108\108\032\097\112\112\108\121\046")
task.spawn(function()
 while not dead do
  task.wait(0.12)
  if dead then break end
  if not autoStat then continue end
  local active={}
  for _,stat in ipairs(statOrder) do if selectedStats[stat] then table.insert(active,stat) end end
  if #active==0 then setStatStatus("\065\117\116\111\032\083\116\097\116\032\226\128\162\032\083\101\108\101\099\116\032\097\116\032\108\101\097\115\116\032\111\110\101\032\115\116\097\116\046"); continue end
  if os.clock()-lastStatClick<0.22 then continue end
  statIndex=statIndex%#active+1
  local stat=active[statIndex]
  local button=findStatButton(stat)
  if not button then
   setStatStatus("\065\117\116\111\032\083\116\097\116\032\226\128\162\032\067\097\110\039\116\032\102\105\110\100\032\116\104\101\032"..stat.."\032\117\112\103\114\097\100\101\032\098\117\116\116\111\110\032\121\101\116\046\032\079\112\101\110\032\116\104\101\032\083\116\097\116\115\032\109\101\110\117\032\111\110\099\101\032\105\102\032\110\101\101\100\101\100\046")
   continue
  end
  local points=currentStatPoints()
  if points~=nil and points<=0 then
   setStatStatus("\065\117\116\111\032\083\116\097\116\032\226\128\162\032\087\097\105\116\105\110\103\032\102\111\114\032\115\116\097\116\032\112\111\105\110\116\115\046")
   continue
  end
  lastStatClick=os.clock()
  if activateButton(button) then
   local suffix=points~=nil and ("\032\226\128\162\032\080\111\105\110\116\115\058\032"..tostring(points)) or ""
   setStatStatus("\065\117\116\111\032\083\116\097\116\032\226\128\162\032\085\112\103\114\097\100\105\110\103\032"..stat..suffix)
  else
   statButtonCache[stat]=nil
   setStatStatus("\065\117\116\111\032\083\116\097\116\032\226\128\162\032\067\111\117\108\100\032\110\111\116\032\097\099\116\105\118\097\116\101\032"..stat.."\046\032\082\101\045\115\099\097\110\110\105\110\103\032\105\116\115\032\098\117\116\116\111\110\226\128\166")
  end
 end
end)
teleport:Section("\078\080\067\032\084\101\108\101\112\111\114\116")
local teleportEntries={}
local selectedDestination
local teleportSearch=""
local destinationIDs=setmetatable({},{__mode="\107"})
local nextDestinationID=0
local teleportDropdown
local teleportStatus=teleport:Paragraph("\068\101\115\116\105\110\097\116\105\111\110\115","\073\110\099\108\117\100\101\115\032\113\117\101\115\116\032\103\105\118\101\114\115\044\032\115\104\111\112\115\044\032\101\110\101\109\121\032\115\112\097\119\110\032\109\097\114\107\101\114\115\044\032\097\110\100\032\108\111\097\100\101\100\032\108\105\118\105\110\103\032\078\080\067\115\046\032\082\101\102\114\101\115\104\032\097\102\116\101\114\032\101\110\116\101\114\105\110\103\032\097\032\110\101\119\032\097\114\101\097\032\105\102\032\115\116\114\101\097\109\105\110\103\032\105\115\032\101\110\097\098\108\101\100\046")
local function readableName(name)
 local value=tostring(name):gsub("\095","\032")
 return (value:gsub("\040\037\097\041\040\091\037\119\039\093\042\041",function(a,b) return a:upper()..b end))
end
local function destinationPosition(object)
 if not object or not object:IsDescendantOf(workspace) then return nil end
 if object:IsA("\065\116\116\097\099\104\109\101\110\116") then return object.WorldPosition end
 if object:IsA("\066\097\115\101\080\097\114\116") then return object.Position end
 if object:IsA("\077\111\100\101\108") then
  local rootPart=object:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") or object.PrimaryPart
  return rootPart and rootPart.Position or object:GetPivot().Position
 end
end
local function refreshDestinations()
 local entries={}
 local seen={}
 local function add(object,name,category)
  if seen[object] or not destinationPosition(object) then return end
  if object:IsA("\077\111\100\101\108") and Players:GetPlayerFromCharacter(object) then return end
  seen[object]=true
  if not destinationIDs[object] then nextDestinationID=nextDestinationID+1; destinationIDs[object]=nextDestinationID end
  local label=readableName(name).."\032\226\128\162\032"..category.."\032\035"..destinationIDs[object]
  if teleportSearch=="" or label:lower():find(teleportSearch,1,true) then
   table.insert(entries,{label=label,object=object})
  end
 end
 local spawns=workspace:FindFirstChild("\110\112\099\095\115\112\097\119\110\115")
 if spawns then
  for _,object in ipairs(spawns:GetDescendants()) do
   if object:IsA("\065\116\116\097\099\104\109\101\110\116") then
    local category="\078\080\067\032\115\112\097\119\110"
    local name=object.Name
    if object.Parent.Name=="\113\117\101\115\116\095\103\105\118\101\114" then
     category="\081\117\101\115\116\032\103\105\118\101\114"
     if bridge.ready then
      local definition=bridge.questUtils.get_quest(object.Name)
      local giver=definition and bridge.questUtils.get_giver(definition.giver_id)
      name=giver and giver.display_name or name
     end
    elseif object.Parent.Name=="\104\111\115\116\105\108\101" then category="\069\110\101\109\121\032\115\112\097\119\110"
    else category="\083\104\111\112\032\047\032\078\080\067" end
    add(object,name,category)
   end
  end
 end
 if bridge.ready then
  for _,handle in pairs(bridge.quests.handles or {}) do
   if handle.model and handle.model.Parent then
    local giver=bridge.questUtils.get_giver(handle.giver_id)
    add(handle.model,giver and giver.display_name or handle.giver_id,"\081\117\101\115\116\032\078\080\067")
   end
  end
 end
 for model in pairs(npcModels) do
  if model:IsDescendantOf(workspace) and not Players:GetPlayerFromCharacter(model) then
   local humanoid=model:FindFirstChildOfClass("\072\117\109\097\110\111\105\100")
   if humanoid and humanoid.Health>0 then add(model,model.Name,"\076\105\118\101\032\078\080\067") end
  end
 end
 for _,folderName in ipairs({"\110\112\099\095\109\097\114\107\101\114\115","\113\117\101\115\116\095\110\112\099\115"}) do
  local folder=workspace:FindFirstChild(folderName)
  if folder then
   for _,object in ipairs(folder:GetDescendants()) do
    if object:IsA("\077\111\100\101\108") and not object.Parent:IsA("\077\111\100\101\108") then add(object,object.Name,"\078\080\067\032\109\097\114\107\101\114") end
   end
  end
 end
 table.sort(entries,function(a,b) return a.label<b.label end)
 local labels={};local preferred
 teleportEntries={}
 for _,entry in ipairs(entries) do
  table.insert(labels,entry.label);teleportEntries[entry.label]=entry.object
  if entry.object==selectedDestination then preferred=entry.label end
 end
 if #labels==0 then labels={"\078\111\032\109\097\116\099\104\105\110\103\032\078\080\067\032\100\101\115\116\105\110\097\116\105\111\110\115"} end
 preferred=preferred or labels[1]
 teleportDropdown:SetOptions(labels,preferred)
 selectedDestination=teleportEntries[preferred]
end
teleport:Input("\083\101\097\114\099\104\032\078\080\067\115","\084\121\112\101\032\097\032\110\097\109\101\032\097\110\100\032\112\114\101\115\115\032\069\110\116\101\114\046\032\067\108\101\097\114\032\105\116\032\116\111\032\115\104\111\119\032\097\108\108\046","\084\111\110\121\044\032\071\114\101\116\097\044\032\115\104\111\112\044\032\098\097\110\100\105\116\226\128\166",function(value)
 teleportSearch=value:lower():match("\094\037\115\042\040\046\045\041\037\115\042\036") or ""
 refreshDestinations()
end)
teleportDropdown=teleport:Dropdown("\083\101\108\101\099\116\032\078\080\067","\067\104\111\111\115\101\032\097\032\108\105\118\101\032\078\080\067\032\111\114\032\105\116\115\032\115\112\097\119\110\032\100\101\115\116\105\110\097\116\105\111\110\046",{"\076\111\097\100\105\110\103\032\078\080\067\115\226\128\166"},"\076\111\097\100\105\110\103\032\078\080\067\115\226\128\166",function(label)
 selectedDestination=teleportEntries[label]
end)
teleport:Button("\082\101\102\114\101\115\104\032\078\080\067\032\108\105\115\116","\083\099\097\110\032\097\118\097\105\108\097\098\108\101\032\078\080\067\115\032\097\110\100\032\115\112\097\119\110\032\108\111\099\097\116\105\111\110\115\046","\082\101\102\114\101\115\104",refreshDestinations)
teleport:Button("\084\101\108\101\112\111\114\116\032\116\111\032\078\080\067","\080\097\117\115\101\115\032\065\117\116\111\032\081\117\101\115\116\032\098\101\102\111\114\101\032\109\111\118\105\110\103\032\121\111\117\114\032\099\104\097\114\097\099\116\101\114\046","\084\101\108\101\112\111\114\116",function()
 local position=destinationPosition(selectedDestination)
 if not position then API:Notify("\068\101\115\116\105\110\097\116\105\111\110\032\117\110\097\118\097\105\108\097\098\108\101\046\032\082\101\102\114\101\115\104\032\116\104\101\032\078\080\067\032\108\105\115\116\046"); return end
 local character=player.Character
 local rootPart=character and character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116")
 local humanoid=character and character:FindFirstChildOfClass("\072\117\109\097\110\111\105\100")
 if not rootPart or not humanoid or humanoid.Health<=0 then API:Notify("\087\097\105\116\032\102\111\114\032\121\111\117\114\032\099\104\097\114\097\099\116\101\114\032\116\111\032\115\112\097\119\110\046");return end
 autoQuest=false
 if controller then controller:Disconnect();controller=nil end
 releaseAttack();stopFlight();target=nil
 bindings["\065\117\116\111\047\065\117\116\111\032\081\117\101\115\116"].set(false)
 rootPart.AssemblyLinearVelocity=Vector3.zero
 character:PivotTo(CFrame.new(position+Vector3.new(0,3,5))*rootPart.CFrame.Rotation)
 API:Notify("\084\101\108\101\112\111\114\116\101\100\032\098\101\115\105\100\101\032\116\104\101\032\115\101\108\101\099\116\101\100\032\078\080\067\032\100\101\115\116\105\110\097\116\105\111\110\046")
end)
connect(teleport.Page:GetPropertyChangedSignal("\086\105\115\105\098\108\101"),function()
 if teleport.Page.Visible then refreshDestinations() end
end)
refreshDestinations()
settings:Section("\082\101\100\101\101\109\032\067\111\100\101\115")
local codeInput
local submitCode
local redeemBusy=false
local redeemSequence=0
local lastRedeem=-100
codeInput=settings:Input("\069\110\116\101\114\032\067\111\100\101","\080\097\115\116\101\032\097\032\099\111\100\101\044\032\116\104\101\110\032\112\114\101\115\115\032\069\110\116\101\114\032\111\114\032\082\101\100\101\101\109\046","\069\110\116\101\114\032\099\111\100\101\032\104\101\114\101\226\128\166",function()
 if submitCode then submitCode() end
end)
local redeemStatus=settings:Paragraph("\067\111\100\101\032\115\116\097\116\117\115","\082\101\097\100\121\032\226\128\162\032\069\110\116\101\114\032\111\110\101\032\099\111\100\101\032\097\116\032\097\032\116\105\109\101\046")
local redeemLabel
for _,child in ipairs(redeemStatus:GetChildren()) do
 if child:IsA("\084\101\120\116\076\097\098\101\108") and child.Text:sub(1,5)=="\082\101\097\100\121" then redeemLabel=child end
end
local function codeStatus(message,success)
 if dead then return end
 if redeemLabel then
  redeemLabel.Text=message
  redeemLabel.TextColor3=success==true and C.Green or (success==false and Color3.fromRGB(255,150,168) or C.Muted)
 end
end
submitCode=function()
 if dead or redeemBusy or os.clock()-lastRedeem<1 then return end
 redeemBusy=true;lastRedeem=os.clock();redeemSequence=redeemSequence+1
 local sequence=redeemSequence
 codeInput.TextEditable=false
 local function finish(message,success)
  if dead or sequence~=redeemSequence then return end
  redeemBusy=false;codeInput.TextEditable=true
  codeStatus(message,success)
  if success then codeInput.Text="" end
 end
 local ok,err=pcall(function()
  local configFolder=ReplicatedStorage:FindFirstChild("\067\111\110\102\105\103")
  local configModule=configFolder and configFolder:FindFirstChild("\099\111\100\101\115")
  local remoteModule=ReplicatedStorage:FindFirstChild("\082\101\109\111\116\101\115")
  if not configModule or not remoteModule then
   finish("\067\111\100\101\115\032\097\114\101\032\117\110\097\118\097\105\108\097\098\108\101\046\032\087\097\105\116\032\102\111\114\032\116\104\101\032\103\097\109\101\032\116\111\032\102\105\110\105\115\104\032\108\111\097\100\105\110\103\046",false);return
  end
  local config=require(configModule)
  local remotes=require(remoteModule)
  local code=config.normalize(codeInput.Text)
  local valid,message=config.validate_id(code)
  if not valid then finish(tostring(message or "\069\110\116\101\114\032\097\032\118\097\108\105\100\032\099\111\100\101\046"),false);return end
  codeStatus("\067\104\101\099\107\105\110\103\032\099\111\100\101\226\128\166")
  remotes.codes.redeem.Invoke(code):andThen(function(result)
   if type(result)~="\116\097\098\108\101" then finish("\085\110\101\120\112\101\099\116\101\100\032\115\101\114\118\101\114\032\114\101\115\112\111\110\115\101\046\032\067\104\101\099\107\032\116\104\101\032\103\097\109\101\039\115\032\099\111\100\101\032\109\101\110\117\046",false);return end
   finish(tostring(result.message or (result.ok and "\067\111\100\101\032\114\101\100\101\101\109\101\100\033" or "\067\111\100\101\032\119\097\115\032\110\111\116\032\097\099\099\101\112\116\101\100\046")),result.ok==true)
  end):catch(function()
   finish("\084\104\101\032\115\101\114\118\101\114\032\100\105\100\032\110\111\116\032\097\110\115\119\101\114\046\032\080\108\101\097\115\101\032\116\114\121\032\097\103\097\105\110\046",false)
  end)
 end)
 if not ok then finish("\067\111\117\108\100\032\110\111\116\032\114\101\100\101\101\109\058\032"..tostring(err),false) end
 task.delay(15,function()
  if dead or not redeemBusy or sequence~=redeemSequence then return end
  finish("\082\101\113\117\101\115\116\032\116\105\109\101\100\032\111\117\116\046\032\067\104\101\099\107\032\121\111\117\114\032\114\101\119\097\114\100\115\032\098\101\102\111\114\101\032\114\101\116\114\121\105\110\103\046",false)
  redeemSequence=redeemSequence+1
 end)
end
settings:Button("\082\101\100\101\101\109\032\067\111\100\101","\083\104\111\119\115\032\116\104\101\032\103\097\109\101\039\115\032\097\099\116\117\097\108\032\114\101\100\101\109\112\116\105\111\110\032\114\101\115\117\108\116\046","\082\101\100\101\101\109",submitCode)
settings:Section("\078\080\067\032\069\083\080")
settings:Toggle("\078\080\067\032\069\083\080","\078\097\109\101\044\032\072\080\032\097\110\100\032\100\105\115\116\097\110\099\101\032\102\111\114\032\110\101\097\114\098\121\032\108\105\118\105\110\103\032\078\080\067\115\046",false,function(enabled)
 espEnabled=enabled
 if enabled then updateESP() else clearESP() end
end)
settings:Paragraph("\069\083\080\032\114\097\110\103\101","\083\104\111\119\115\032\116\104\101\032\110\101\097\114\101\115\116\032\051\048\032\078\080\067\115\032\119\105\116\104\105\110\032\049\044\048\048\048\032\115\116\117\100\115\046\032\085\112\100\097\116\101\115\032\116\119\105\099\101\032\112\101\114\032\115\101\099\111\110\100\046\032\080\108\097\121\101\114\032\099\104\097\114\097\099\116\101\114\115\032\097\114\101\032\101\120\099\108\117\100\101\100\044\032\097\110\100\032\097\108\108\032\109\097\114\107\101\114\115\032\097\114\101\032\114\101\109\111\118\101\100\032\111\110\032\117\110\108\111\097\100\046")
settings:Section("\077\111\118\101\109\101\110\116")
local walkSpeed=16
local function applyWalkSpeed(character)
 local humanoid=character and character:FindFirstChildOfClass("\072\117\109\097\110\111\105\100")
 if humanoid then humanoid.WalkSpeed=walkSpeed end
end
settings:Slider("\087\097\108\107\032\083\112\101\101\100","\087\097\108\107\105\110\103\032\115\112\101\101\100\032\105\110\032\115\116\117\100\115\032\112\101\114\032\115\101\099\111\110\100\046",8,100,16,1,function(value)
 walkSpeed=value; applyWalkSpeed(player.Character)
end)
connect(player.CharacterAdded,function(character)
 task.spawn(function()
  character:WaitForChild("\072\117\109\097\110\111\105\100",10)
  if not dead then applyWalkSpeed(character) end
 end)
end)
settings:Section("\065\117\116\111\032\083\097\118\101")
local saveCard=settings:Paragraph("\083\097\118\101\032\115\116\097\116\117\115",saveMessage)
local saveLabel
for _,child in ipairs(saveCard:GetChildren()) do
 if child:IsA("\084\101\120\116\076\097\098\101\108") and child.Text==saveMessage then saveLabel=child end
end
local function setSaveMessage(message)
 saveMessage=message
 if saveLabel and saveLabel.Parent then saveLabel.Text=message end
end
settings:Paragraph("\077\111\118\101\109\101\110\116\032\098\101\104\097\118\105\111\114","\084\119\101\101\110\077\101\116\104\111\100\032\105\115\032\099\111\110\116\114\111\108\108\101\100\032\105\110\032\065\117\116\111\046\032\070\108\121\032\112\097\115\115\101\115\032\116\104\114\111\117\103\104\032\119\097\108\108\115\059\032\084\101\108\101\112\111\114\116\032\105\110\115\116\097\110\116\108\121\032\109\111\118\101\115\032\098\101\115\105\100\101\032\116\104\101\032\115\101\108\101\099\116\101\100\032\113\117\101\115\116\032\103\105\118\101\114\047\101\110\101\109\121\046\032\070\108\105\103\104\116\032\099\111\108\108\105\115\105\111\110\032\115\101\116\116\105\110\103\115\032\114\101\115\116\111\114\101\032\119\104\101\110\032\115\116\111\112\112\101\100\044\032\111\110\032\114\101\115\112\097\119\110\044\032\097\110\100\032\111\110\032\117\110\108\111\097\100\046")
resetAllSettings=function()
 if dead then return end
 restoring=true
 for key,binding in pairs(bindings) do
  if binding and binding.default~=nil then
   pcall(binding.set,binding.default)
  end
 end
 desiredUID=nil
 desiredItemID=nil
 selectedUID=nil
 selectedLabel=nil
 selectedDestination=nil
 teleportSearch=""
 preferences["\073\116\101\109\085\073\068"]=nil
 preferences["\073\116\101\109\073\068"]=nil
 preferences["\065\117\116\111\047\083\101\108\101\099\116\032\072\111\116\098\097\114\032\073\116\101\109"]=nil
 preferences["\084\101\108\101\112\111\114\116\047\083\101\108\101\099\116\032\078\080\067"]=nil
 restoring=false
 table.clear(touched)
 window.Position=UDim2.fromScale(0.5,0.5)
 visible(true)
 if home then home:Select() end
 task.defer(function()
  if dead then return end
  refreshTools()
  refreshDestinations()
  applyWalkSpeed(player.Character)
  flushPreferences()
  setSaveMessage(saveRemote and "\083\101\116\116\105\110\103\115\032\114\101\115\101\116\032\226\128\162\032\100\101\102\097\117\108\116\115\032\115\097\118\101\100" or "\083\101\116\116\105\110\103\115\032\114\101\115\101\116\032\226\128\162\032\115\101\115\115\105\111\110\032\100\101\102\097\117\108\116\115\032\114\101\115\116\111\114\101\100")
  API:Notify("\065\108\108\032\077\111\109\111\110\103\097\072\117\098\032\115\101\116\116\105\110\103\115\032\114\101\115\101\116\046")
 end)
end
settings:Section("\087\105\110\100\111\119")
settings:Button("\067\101\110\116\101\114\032\119\105\110\100\111\119","\077\111\118\101\032\116\104\101\032\105\110\116\101\114\102\097\099\101\032\098\097\099\107\032\116\111\032\116\104\101\032\109\105\100\100\108\101\046","\067\101\110\116\101\114",function()
 window.Position=UDim2.fromScale(0.5,0.5)
end)
settings:Button("\072\105\100\101\032\105\110\116\101\114\102\097\099\101","\082\101\111\112\101\110\032\117\115\105\110\103\032\082\105\103\104\116\032\083\104\105\102\116\032\111\114\032\116\104\101\032\079\112\101\110\032\098\117\116\116\111\110\046","\072\105\100\101",function() visible(false) end)
settings:Paragraph("\077\111\109\111\110\103\097\072\117\098\032\118\049\046\048","\065\032\115\111\102\116\032\112\105\110\107\032\097\110\100\032\108\097\118\101\110\100\101\114\032\119\111\114\107\115\112\097\099\101\046\032\082\105\103\104\116\032\083\104\105\102\116\032\116\111\103\103\108\101\115\032\116\104\101\032\119\105\110\100\111\119\046\032\084\104\101\032\226\134\186\032\098\117\116\116\111\110\032\098\101\115\105\100\101\032\109\105\110\105\109\105\122\101\032\114\101\115\101\116\115\032\101\118\101\114\121\032\115\097\118\101\100\032\085\073\032\115\101\116\116\105\110\103\046\032\065\117\116\111\032\069\113\117\105\112\032\110\111\119\032\109\105\114\114\111\114\115\032\116\104\101\032\103\097\109\101\032\104\111\116\098\097\114\032\110\117\109\101\114\105\099\032\116\111\111\108\045\115\101\108\101\099\116\105\111\110\032\114\101\113\117\101\115\116\046")
settings:Button("\085\110\108\111\097\100\032\105\110\116\101\114\102\097\099\101","\082\101\109\111\118\101\032\116\104\105\115\032\085\073\032\117\110\116\105\108\032\116\104\101\032\115\099\114\105\112\116\032\114\117\110\115\032\097\103\097\105\110\046","\085\110\108\111\097\100",function() gui:Destroy() end)
local function restorePreferences(data)
 if type(data)~="\116\097\098\108\101" then return end
 restoring=true
 for key,value in pairs(data) do
  if not touched[key] then
   if key=="\073\116\101\109\085\073\068" then desiredUID=value; preferences[key]=value
   elseif key=="\073\116\101\109\073\068" then desiredItemID=value; preferences[key]=value
   else
    local binding=bindings[key]
    if binding and type(value)==binding.kind and binding.kind~="\098\111\111\108\101\097\110" then binding.set(value) end
   end
  end
 end
 restoring=false
 task.defer(function()
  if dead then return end
  restoring=true
  for key,value in pairs(data) do
   local binding=bindings[key]
   if binding and binding.kind=="\098\111\111\108\101\097\110" and type(value)=="\098\111\111\108\101\097\110" and not touched[key] then binding.set(value) end
  end
  restoring=false
 end)
end
local sessionJSON=player:GetAttribute("\077\111\109\111\110\103\097\072\117\098\080\114\101\102\101\114\101\110\099\101\115")
if type(sessionJSON)=="\115\116\114\105\110\103" then
 local ok,data=pcall(function() return HttpService:JSONDecode(sessionJSON) end)
 if ok then restorePreferences(data) end
end
task.spawn(function()
 local folder=ReplicatedStorage:WaitForChild("\077\111\109\111\110\103\097\083\101\116\116\105\110\103\115",10)
 if dead or not folder then return end
 local get=folder:WaitForChild("\071\101\116",5)
 local set=folder:WaitForChild("\083\101\116",5)
 local status=folder:WaitForChild("\083\116\097\116\117\115",5)
 if dead or not get or not set or not status then return end
 connect(status.OnClientEvent,function(message) setSaveMessage(message) end)
 for attempt=1,10 do
  if dead then return end
  local ok,data,message=pcall(function() return get:InvokeServer() end)
  if dead then return end
  if ok and type(data)=="\116\097\098\108\101" then
   saveRemote=set
   if not sessionJSON then restorePreferences(data) end
   setSaveMessage("\065\117\116\111\032\083\097\118\101\032\099\111\110\110\101\099\116\101\100\032\226\128\162\032\099\104\097\110\103\101\115\032\115\097\118\101\032\097\099\114\111\115\115\032\115\101\115\115\105\111\110\115")
   task.delay(1,function() if not dead then flushPreferences() end end)
   return
  end
  setSaveMessage(ok and (message or "\087\097\105\116\105\110\103\032\102\111\114\032\115\116\111\114\097\103\101\226\128\166") or "\083\116\111\114\097\103\101\032\099\111\110\110\101\099\116\105\111\110\032\102\097\105\108\101\100\059\032\115\101\115\115\105\111\110\045\111\110\108\121\032\115\097\118\105\110\103")
  task.wait(1)
 end
end)
