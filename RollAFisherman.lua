local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local UIS=game:GetService("UserInputService")
local RS=game:GetService("ReplicatedStorage")
local CoreGui=game:GetService("CoreGui")
local Player=Players.LocalPlayer
assert(Player,"Run MomongaHub on the client")
local PlayerGui=Player:WaitForChild("PlayerGui")
local player=Player
local alive=true
local connections,jobs={},{}
local rollEnabled=false
local buyEnabled=false
local restoreBuyPosition=function() end
local rollWorker,heldPrompt
local heldKey
local restoreNamePrivacy=function() end
local function releaseRollKey()
    heldKey=nil
end
local rollGeneration=0
local Config={HideName=false}
local containers={PlayerGui}
pcall(function() table.insert(containers,CoreGui) end)
if type(gethui)=="function" then pcall(function() table.insert(containers,gethui()) end) end
for _,container in ipairs(containers) do
    local previous=container:FindFirstChild("MomongaHubFish")
    if previous then previous:Destroy() end
end
local MOMONGA_IMAGE = "rbxassetid://120248975380456"
local UIConnections = connections
local ScreenGui
local UI = {Sections={}, Selected="Auto"}
local Theme = {
    BG=Color3.fromRGB(24,25,28), BG2=Color3.fromRGB(24,25,28),
    Side=Color3.fromRGB(10,10,12), Card=Color3.fromRGB(21,21,24),
    Card2=Color3.fromRGB(26,26,30), Hover=Color3.fromRGB(39,41,47),
    Purple=Color3.fromRGB(38,101,240), Lavender=Color3.fromRGB(71,75,84),
    Pink=Color3.fromRGB(106,163,255), Blue=Color3.fromRGB(75,144,255),
    White=Color3.fromRGB(242,243,247), Sub=Color3.fromRGB(157,160,171),
    Off=Color3.fromRGB(60,63,72)
}
local function UIConnect(sig,fn)
    local c=sig:Connect(fn)
    table.insert(UIConnections,c)
    return c
end
local function Corner(o,r)
    local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 14); c.Parent=o
end
local function Stroke(o,col,tr,th)
    local s=Instance.new("UIStroke"); s.Color=col or Theme.Lavender
    s.Transparency=tr or 0; s.Thickness=th or 1; s.Parent=o
end
local function Label(p,txt,size,pos,ts,font,col)
    local l=Instance.new("TextLabel")
    l.BackgroundTransparency=1; l.Size=size; l.Position=pos; l.Text=txt
    l.TextColor3=col or Theme.White; l.TextSize=ts or 14
    l.TextWrapped=true; l.Font=Enum.Font.FredokaOne; l.TextXAlignment=Enum.TextXAlignment.Left
    l.Parent=p; return l
end
local function Button(p,txt,size,pos)
    local b=Instance.new("TextButton")
    b.AutoButtonColor=false; b.Size=size; b.Position=pos; b.BackgroundColor3=Theme.Card2
    b.BorderSizePixel=0; b.Text=txt; b.TextColor3=Theme.White; b.TextSize=13
    b.Font=Enum.Font.FredokaOne; b.Parent=p; Corner(b,8); Stroke(b,Theme.Lavender,.6,1)
    UIConnect(b.MouseEnter,function() if not b:GetAttribute("FixedColor") then b.BackgroundColor3=Theme.Hover end end)
    UIConnect(b.MouseLeave,function() if not b:GetAttribute("FixedColor") then b.BackgroundColor3=Theme.Card2 end end)
    return b
end
local function Card(p,h)
    if UI.Sections[p] then p=UI.Sections[p][1] end
    local f=Instance.new("Frame")
    f.Size=UDim2.new(1,0,0,h); f.BackgroundColor3=Theme.Card
    f.BackgroundTransparency=.04; f.BorderSizePixel=0; f.Parent=p
    Corner(f,9); Stroke(f,Theme.Lavender,.8,1); return f
end
ScreenGui=Instance.new("ScreenGui")
ScreenGui.IgnoreGuiInset=true; ScreenGui.Name="MomongaHubFish"; ScreenGui.ResetOnSpawn=false
ScreenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
ScreenGui.Enabled=true
ScreenGui.DisplayOrder=10000
if type(gethui)=="function" then
    pcall(function() ScreenGui.Parent=gethui() end)
end
if not ScreenGui.Parent then pcall(function() ScreenGui.Parent=CoreGui end) end
if not ScreenGui.Parent then ScreenGui.Parent=PlayerGui end
local DropdownOverlay=Instance.new("Frame")
DropdownOverlay.Name="DropdownOverlay"
DropdownOverlay.BackgroundTransparency=1
DropdownOverlay.BorderSizePixel=0
DropdownOverlay.Size=UDim2.fromScale(1,1)
DropdownOverlay.Position=UDim2.fromScale(0,0)
DropdownOverlay.ClipsDescendants=false
DropdownOverlay.ZIndex=500
DropdownOverlay.Parent=ScreenGui
local ActiveDropdownPopup=nil
local function CloseActiveDropdown()
    if ActiveDropdownPopup then
        pcall(function() ActiveDropdownPopup:Destroy() end)
        ActiveDropdownPopup=nil
    end
end
local Main=Instance.new("Frame")
Main.AnchorPoint=Vector2.new(.5,.5); Main.Position=UDim2.fromScale(.5,.5)
Main.Size=UDim2.fromOffset(980,600); Main.BackgroundColor3=Theme.BG
Main.BackgroundTransparency=.12; Main.BorderSizePixel=0; Main.Parent=ScreenGui
Corner(Main,20); Stroke(Main,Theme.Lavender,.4,1)
local Sidebar=Instance.new("Frame")
Sidebar.Size=UDim2.new(0,210,1,0); Sidebar.BackgroundColor3=Theme.Side
Sidebar.BorderSizePixel=0; Sidebar.Parent=Main; Corner(Sidebar,20); Stroke(Sidebar,Theme.Lavender,.65,1)
local mascot=Instance.new("ImageLabel")
mascot.BackgroundTransparency=1; mascot.Size=UDim2.fromOffset(40,40)
mascot.Position=UDim2.fromOffset(16,18); mascot.Image=MOMONGA_IMAGE
mascot.ScaleType=Enum.ScaleType.Fit; mascot.Parent=Sidebar
Label(Sidebar,"MOMONGAHUB",UDim2.fromOffset(145,24),UDim2.fromOffset(65,17),14,Enum.Font.FredokaOne)
UI.AccountLabel=Label(Sidebar,"v1.0  •  "..Player.Name,UDim2.fromOffset(135,20),UDim2.fromOffset(65,40),10,nil,Theme.Sub)
UI.Avatar=Instance.new("ImageLabel"); UI.Avatar.Size=UDim2.fromOffset(34,34)
UI.Avatar.Position=UDim2.new(0,16,1,-64); UI.Avatar.BackgroundColor3=Theme.Card2
UI.Avatar.Parent=Sidebar; Corner(UI.Avatar,17)
task.spawn(function()
    local ok,url=pcall(function() return Players:GetUserThumbnailAsync(Player.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100) end)
    if ok and UI.Avatar.Parent then UI.Avatar.Image=url end
end)
UI.ProfileLabel=Label(Sidebar,Player.DisplayName,UDim2.new(1,-70,0,22),UDim2.new(0,60,1,-68),12)
Label(Sidebar,"Press Alt to minimize",UDim2.new(1,-70,0,16),UDim2.new(0,60,1,-44),10,nil,Theme.Sub)
Label(Sidebar,"Press F to unload",UDim2.new(1,-70,0,16),UDim2.new(0,60,1,-27),10,nil,Theme.Sub)
function UI.ApplyNamePrivacy()
    local hidden=Config.HideName==true
    UI.AccountLabel.Text=hidden and "v1.0" or ("v1.0  •  "..Player.Name)
    UI.ProfileLabel.Text=hidden and "Name hidden" or Player.DisplayName
    if UI.NamePrivacy then UI.NamePrivacy.SetEnabled(hidden) end
end
UI.ApplyNamePrivacy()
UI.Header=Instance.new("Frame"); UI.Header.BackgroundTransparency=1
UI.Header.Position=UDim2.fromOffset(225,0); UI.Header.Size=UDim2.new(1,-225,0,66)
UI.Header.Active=true; UI.Header.Parent=Main
UI.Title=Label(UI.Header,"Auto",UDim2.fromOffset(260,28),UDim2.fromOffset(0,10),18,Enum.Font.FredokaOne)
UI.Subtitle=Label(UI.Header,"Fish & wheel automation",UDim2.fromOffset(340,18),UDim2.fromOffset(0,37),11,nil,Theme.Sub)
UI.Search=Instance.new("TextBox"); UI.Search.Size=UDim2.fromOffset(220,34)
UI.Search.Position=UDim2.new(1,-320,0,15); UI.Search.BackgroundColor3=Theme.Card
UI.Search.BorderSizePixel=0; UI.Search.Text=""; UI.Search.PlaceholderText="Search features..."
UI.Search.TextColor3=Theme.White; UI.Search.PlaceholderColor3=Theme.Sub
UI.Search.TextSize=12; UI.Search.Font=Enum.Font.FredokaOne; UI.Search.ClearTextOnFocus=false
UI.Search.Parent=UI.Header; Corner(UI.Search,17); Stroke(UI.Search,Theme.Lavender,.5,1)
local close=Button(UI.Header,"×",UDim2.fromOffset(20,20),UDim2.new(1,-80,0,22))
local minimize=Button(UI.Header,"−",UDim2.fromOffset(20,20),UDim2.new(1,-54,0,22))
UI.Restore=Button(UI.Header,"+",UDim2.fromOffset(20,20),UDim2.new(1,-28,0,22))
for _,spec in ipairs({{close,Color3.fromRGB(246,72,76)},{minimize,Color3.fromRGB(250,194,34)},{UI.Restore,Color3.fromRGB(34,206,128)}}) do
    spec[1]:SetAttribute("FixedColor",true); spec[1].BackgroundColor3=spec[2]; Corner(spec[1],20)
end
local ContentBG=Instance.new("Frame")
ContentBG.Position=UDim2.fromOffset(224,68); ContentBG.Size=UDim2.new(1,-238,1,-82)
ContentBG.BackgroundTransparency=1; ContentBG.Parent=Main
local Content=Instance.new("Frame"); Content.Size=UDim2.fromScale(1,1)
Content.BackgroundTransparency=1; Content.Parent=ContentBG
local Pages,Tabs={},{}
local function NewPage(n)
    local p=Instance.new("ScrollingFrame"); p.Name=n; p.Size=UDim2.fromScale(1,1)
    p.BackgroundTransparency=1; p.BorderSizePixel=0; p.ScrollBarThickness=3
    p.ScrollBarImageColor3=Theme.Blue; p.AutomaticCanvasSize=Enum.AutomaticSize.Y
    p.CanvasSize=UDim2.new(); p.Visible=false; p.Parent=Content
    if n=="Shop TP" then
        local layout=Instance.new("UIListLayout"); layout.Padding=UDim.new(0,8); layout.Parent=p
        local pad=Instance.new("UIPadding"); pad.PaddingRight=UDim.new(0,6); pad.Parent=p
    else
        UI.Sections[p]={}
        local headings=({Auto={"Auto","Rolling"},Bosses={"Boss farming","World bosses"},Settings={"Movement","Preferences"},Config={"Movement","Combat"}})[n]
        for i=1,2 do
            local section=Instance.new("Frame"); section.Name=headings[i]
            section.Size=UDim2.new(.5,-8,0,0); section.Position=UDim2.new((i-1)*.5,(i-1)*4,0,0)
            section.AutomaticSize=Enum.AutomaticSize.Y; section.BackgroundColor3=Theme.Side
            section.BorderSizePixel=0; section.Parent=p; Corner(section,14); Stroke(section,Theme.Lavender,.7,1)
            local pad=Instance.new("UIPadding"); pad.PaddingTop=UDim.new(0,8); pad.PaddingBottom=UDim.new(0,8)
            pad.PaddingLeft=UDim.new(0,8); pad.PaddingRight=UDim.new(0,8); pad.Parent=section
            local lay=Instance.new("UIListLayout"); lay.Padding=UDim.new(0,6); lay.SortOrder=Enum.SortOrder.LayoutOrder; lay.Parent=section
            local heading=Label(section,headings[i],UDim2.new(1,-8,0,26),UDim2.new(),13,Enum.Font.FredokaOne)
            heading.LayoutOrder=-1
            UI.Sections[p][i]=section
        end
    end
    Pages[n]=p; return p
end
function UI.Route(p,title)
    if not UI.Sections[p] then return p end
    local t=string.lower(title); local right=false
    if p.Name=="Auto" then right=t:find("stat") or t:find("points") or t:find("prestige")
    elseif p.Name=="Bosses" then right=t:find("world")
    elseif p.Name=="Settings" then right=not t:find("damage")
    elseif p.Name=="Config" then right=t:find("attack") end
    return UI.Sections[p][right and 2 or 1]
end
local AutoPage=NewPage("Auto")
local SettingsPage=NewPage("Settings")
local function NewTab(n,display,y)
    local b=Button(Sidebar,display,UDim2.new(1,-20,0,46),UDim2.fromOffset(10,y))
    b.TextXAlignment=Enum.TextXAlignment.Left; b.TextSize=13; b:SetAttribute("FixedColor",true)
    local pad=Instance.new("UIPadding"); pad.PaddingLeft=UDim.new(0,16); pad.Parent=b
    Tabs[n]=b; return b
end
NewTab("Auto","⌂    Auto",92)
NewTab("Settings","⚙    Settings",148)
local function SelectPage(n)
    CloseActiveDropdown(); UI.Selected=n
    for k,p in pairs(Pages) do p.Visible=(k==n) end
    for k,b in pairs(Tabs) do
        b.BackgroundColor3=(k==n) and Theme.Purple or Theme.Side
        b.TextColor3=(k==n) and Theme.White or Theme.Sub
        local stroke=b:FindFirstChildOfClass("UIStroke"); if stroke then stroke.Transparency=1 end
    end
    UI.Title.Text=n
    UI.Subtitle.Text=({Auto="Fish & wheel automation",Bosses="Summoning, difficulty & world bosses",["Shop TP"]="All islands & shop NPCs",Settings="Equipment, spawn & display",Config="Movement & combat tuning"})[n]
end
for n,b in pairs(Tabs) do UIConnect(b.Activated,function() SelectPage(n) end) end
local function Toggle(p,title,desc,default,callback)
    p=UI.Route(p,title)
    local c=Card(p,(desc and desc~="") and 94 or 50)
    Label(c,title,UDim2.new(1,-72,0,32),UDim2.new(0,18,0,8),13,Enum.Font.FredokaOne)
    local description=Label(c,desc or "",UDim2.new(1,-28,0,42),UDim2.new(0,14,0,44),10,Enum.Font.FredokaOne,Theme.Sub)
    local b=Button(c,"",UDim2.fromOffset(42,24),UDim2.new(1,-54,0,14))
    b:SetAttribute("FixedColor",true)
    local k=Instance.new("Frame"); k.Size=UDim2.fromOffset(18,18); k.BackgroundColor3=Theme.White; k.BorderSizePixel=0; k.Parent=b; Corner(k,30)
    local state=default==true
    local function render()
        b.BackgroundColor3=state and Theme.Purple or Theme.Off
        k.Position=state and UDim2.new(1,-21,.5,-9) or UDim2.new(0,3,.5,-9)
    end
    render()
    UIConnect(b.Activated,function() state=not state; render(); if callback then task.spawn(callback,state) end end)
    return {Card=c, Status=description, Get=function() return state end, Set=function(value) state=value; render() end}
end
local function MultiDropdown(p,title,options,selected,callback)
    p=UI.Route(p,title)
    local c=Card(p,69)
    Label(c,title,UDim2.new(.42,-10,1,0),UDim2.new(0,18,0,0),13,Enum.Font.FredokaOne)
    local chosen={}
    for k,v in pairs(selected or {}) do
        if type(k)=="number" then chosen[v]=true elseif v then chosen[k]=true end
    end
    local function summary()
        local a={}
        for _,o in ipairs(options) do if chosen[o] then table.insert(a,o) end end
        return #a>0 and table.concat(a,", ") or "Select rarities"
    end
    local b=Button(c,summary(),UDim2.new(.52,-18,0,39),UDim2.new(.48,0,.5,-19.5))
    b.TextXAlignment=Enum.TextXAlignment.Left; b.TextTruncate=Enum.TextTruncate.AtEnd
    local popup
    local function close()
        if popup then
            if ActiveDropdownPopup==popup then ActiveDropdownPopup=nil end
            popup:Destroy(); popup=nil
        end
    end
    local function emit()
        local a={}
        for _,o in ipairs(options) do if chosen[o] then table.insert(a,o) end end
        b.Text=summary(); callback(a)
    end
    UIConnect(b.Activated,function()
        if popup and popup.Parent then close(); return end
        popup=nil
        CloseActiveDropdown()
        local pos=b.AbsolutePosition; local sz=b.AbsoluteSize
        popup=Instance.new("ScrollingFrame")
        popup.Name="MultiDropdownPopup"; popup.BackgroundColor3=Theme.Card; popup.BorderSizePixel=0
        popup.Position=UDim2.fromOffset(math.clamp(pos.X,0,math.max(0,DropdownOverlay.AbsoluteSize.X-sz.X)),math.clamp(pos.Y+sz.Y+4,0,math.max(0,DropdownOverlay.AbsoluteSize.Y-math.min(#options*36+8,190))))
        popup.Size=UDim2.fromOffset(sz.X,math.min(#options*36+8,190))
        popup.CanvasSize=UDim2.fromOffset(0,#options*36+8); popup.ScrollBarThickness=4
        popup.ZIndex=600; popup.Parent=DropdownOverlay
        Corner(popup,8); Stroke(popup,Theme.Lavender,.2,1)
        local lay=Instance.new("UIListLayout"); lay.Padding=UDim.new(0,2); lay.Parent=popup
        local pad=Instance.new("UIPadding")
        pad.PaddingTop=UDim.new(0,4); pad.PaddingBottom=UDim.new(0,4)
        pad.PaddingLeft=UDim.new(0,4); pad.PaddingRight=UDim.new(0,4); pad.Parent=popup
        for i,o in ipairs(options) do
            local row=Button(popup,(chosen[o] and "☑  " or "☐  ")..o,UDim2.new(1,-8,0,34),UDim2.new())
            row.LayoutOrder=i; row.ZIndex=610
            UIConnect(row.Activated,function()
                chosen[o]=not chosen[o]
                row.Text=(chosen[o] and "☑  " or "☐  ")..o
                emit()
            end)
        end
        ActiveDropdownPopup=popup
    end)
    return c
end
local minimized=false
local MiniIcon=Instance.new("ImageButton")
MiniIcon.Name="MomongaRestore"
MiniIcon.Image=MOMONGA_IMAGE
MiniIcon.BackgroundTransparency=1
MiniIcon.Size=UDim2.fromOffset(60,60)
MiniIcon.Position=UDim2.fromOffset(18,150)
MiniIcon.ScaleType=Enum.ScaleType.Fit
MiniIcon.Visible=false
MiniIcon.Parent=ScreenGui
function UI.SetMinimized(value)
    CloseActiveDropdown()
    minimized=value
    Main.Visible=not value
    MiniIcon.Visible=value
end
UIConnect(MiniIcon.Activated,function() UI.SetMinimized(false) end)
UIConnect(minimize.Activated,function() UI.SetMinimized(not minimized) end)
UIConnect(UI.Restore.Activated,function() UI.SetMinimized(false); Main.Position=UDim2.fromScale(.5,.5) end)
local dragging,dragStart,startPos,dragInput=false,nil,nil,nil
UIConnect(UI.Header.InputBegan,function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        CloseActiveDropdown(); dragging=true; dragStart=i.Position; startPos=Main.Position; dragInput=i
    end
end)
UIConnect(UIS.InputChanged,function(i)
    if dragging and (i==dragInput or i.UserInputType==Enum.UserInputType.MouseMovement) then
        local d=i.Position-dragStart
        Main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
    end
end)
UIConnect(UIS.InputEnded,function(i)
    if i==dragInput or i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false; dragInput=nil end
end)
UIConnect(UIS.InputBegan,function(i)
    if ActiveDropdownPopup and (i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch) then
        local pos,size=ActiveDropdownPopup.AbsolutePosition,ActiveDropdownPopup.AbsoluteSize
        if i.Position.X<pos.X or i.Position.X>pos.X+size.X or i.Position.Y<pos.Y or i.Position.Y>pos.Y+size.Y then CloseActiveDropdown() end
    end
end)
for _,page in pairs(Pages) do UIConnect(page:GetPropertyChangedSignal("CanvasPosition"),CloseActiveDropdown) end
local MobileScale=Instance.new("UIScale")
MobileScale.Name="MobileScale"
MobileScale.Parent=Main
local function UpdateMobileScale()
    local cam=workspace.CurrentCamera
    if not cam then return end
    local v=cam.ViewportSize
    local scale=math.min(1,(v.X-16)/980,(v.Y-16)/600)
    MobileScale.Scale=math.max(scale,0.1)
end
UpdateMobileScale()
if workspace.CurrentCamera then
    UIConnect(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"),UpdateMobileScale)
end
SelectPage("Auto")
local function ownPlot()
    local scriptable = workspace:FindFirstChild("Scriptable")
    local plots = scriptable and scriptable:FindFirstChild("Plots")
    local buildings = plots and plots:FindFirstChild("Buildings")
    if not buildings then return nil end
    for _, plot in ipairs(buildings:GetChildren()) do
        if tostring(plot:GetAttribute("Owner")) == tostring(player.UserId) then return plot end
    end
    local data = player:FindFirstChild("Data")
    local plotValue = data and data:FindFirstChild("Plot")
    local plot = plotValue and buildings:FindFirstChild(tostring(plotValue.Value))
    if plot then
        local owner = plot:GetAttribute("Owner")
        if owner == nil or tostring(owner) == tostring(player.UserId) then return plot end
    end
end
local netCard=Card(UI.Sections[AutoPage][2],94)
local netStatus=Label(netCard,"Connecting to game…",UDim2.new(1,-24,1,-16),UDim2.fromOffset(12,8),12,nil,Theme.Sub)
local function addJob(title,desc,remoteName,isFunction,argument)
    local job={enabled=false,nextRun=0,lastRun=-math.huge,remoteName=remoteName,isFunction=isFunction,argument=argument,title=title}
    job.ui=Toggle(AutoPage,title,desc,false,function(on)
        if not alive then return end
        job.enabled=on
        job.nextRun=math.max(os.clock(),job.lastRun+5)
        if not on then
            if job.worker and coroutine.status(job.worker)~="dead" then pcall(task.cancel,job.worker) end
            job.busy=false
            job.ui.Status.Text=desc
        end
    end)
    table.insert(jobs,job)
end
addJob("Auto Equip Best","Equip your best setup every 5 seconds.","EquipBest")
addJob("Auto Sell","Sell fish every 5 seconds using game filters.","SellAll",false,"Fish")
addJob("Auto Spin","Spin the wheel every 5 seconds. Requires spins.","WheelSpin",true)
UIConnect(UI.Search:GetPropertyChangedSignal("Text"),function()
    local query=string.lower(UI.Search.Text)
    for _,job in ipairs(jobs) do job.ui.Card.Visible=query=="" or string.find(string.lower(job.title),query,1,true)~=nil end
end)
local cleanupMovementSettings=function() end
local function unload()
    if not alive then return end
    alive=false
    cleanupMovementSettings()
    restoreNamePrivacy()
    rollEnabled=false
    buyEnabled=false
    restoreBuyPosition()
    rollGeneration=rollGeneration+1
    releaseRollKey()
    if heldPrompt then pcall(function() heldPrompt:InputHoldEnd() end); heldPrompt=nil end
    if rollWorker and coroutine.status(rollWorker)~="dead" then pcall(task.cancel,rollWorker) end
    for _,job in ipairs(jobs) do
        job.enabled=false
        if job.worker and coroutine.status(job.worker)~="dead" then pcall(task.cancel,job.worker) end
    end
    for _,c in ipairs(connections) do c:Disconnect() end
    ScreenGui:Destroy()
end
UIConnect(ScreenGui.Destroying,unload)
UIConnect(close.Activated,unload)
UIConnect(UIS.InputBegan,function(input,processed)
    if processed or UIS:GetFocusedTextBox() then return end
    if input.KeyCode==Enum.KeyCode.F then unload()
    elseif input.KeyCode==Enum.KeyCode.LeftAlt or input.KeyCode==Enum.KeyCode.RightAlt then UI.SetMinimized(not minimized) end
end)
Toggle(SettingsPage,"Hide Name","Hide your name in the hub and game (local display).",false,function(on) Config.HideName=on; UI.ApplyNamePrivacy() end)
local settingsCard=Card(UI.Sections[SettingsPage][1],92)
Label(settingsCard,"MomongaHub Fish v1.0",UDim2.new(1,-24,0,28),UDim2.fromOffset(12,8),14)
local unloadButton=Button(settingsCard,"Unload Script",UDim2.new(1,-24,0,34),UDim2.fromOffset(12,44))
UIConnect(unloadButton.Activated,unload)
task.spawn(function()
    local ok,net=pcall(function()
        local function need(parent,name)
            local item=parent:WaitForChild(name,15)
            assert(item,"Missing "..name)
            return item
        end
        local module=need(need(need(RS,"Modules"),"Util"),"Net")
        need(RS,"NetClient")
        return require(module)
    end)
    if not alive then return end
    if not ok then netStatus.Text="Game connection failed. Check Output / console."; warn(net); return end
    for _,job in ipairs(jobs) do
        if job.remoteName then
            task.spawn(function()
                local connected,remote=pcall(function()
                    return job.isFunction and net:Function(job.remoteName) or net:Event(job.remoteName)
                end)
                if alive then job.remote=connected and remote or nil end
            end)
        end
    end
    netStatus.Text="Game module connected.\nAll toggles start OFF."
end)
task.spawn(function()
    while alive do
        local now=os.clock()
        for _,job in ipairs(jobs) do
            if job.enabled then
                if not job.remote then
                    job.ui.Status.Text="Waiting for game connection…"
                else
                    if not job.busy and now>=job.nextRun then
                        job.busy=true; job.lastRun=now; job.nextRun=now+5
                        job.worker=task.spawn(function()
                            local ok,result=pcall(function()
                                if job.isFunction then return job.remote:InvokeServer() end
                                if job.argument then job.remote:FireServer(job.argument) else job.remote:FireServer() end
                            end)
                            if not alive then return end
                            job.busy=false; job.failed=not ok
                            job.noResult=job.isFunction and ok and not result
                            if not ok then warn("[MomongaHub] "..job.title..": "..tostring(result)) end
                        end)
                    end
                    if job.busy then job.ui.Status.Text="Waiting for game response…"
                    elseif job.failed then job.ui.Status.Text="Error • check Output / console"
                    elseif job.noResult then job.ui.Status.Text="No spin result • waiting to retry"
                    else job.ui.Status.Text=string.format("Next cycle in %.1fs",math.max(0,job.nextRun-now)) end
                end
            end
        end
        task.wait(0.1)
    end
end)
local selectedRarities={}
local fishermen={}
local FISHERMAN_CATALOG={
    {Rarity="Common",Id="HomelessFisher",Name="Homeless Fisher",Price=250},
    {Rarity="Common",Id="LobsterTrap",Name="Lobster Trap",Price=1000},
    {Rarity="Common",Id="RookieSam",Name="Rookie Sam",Price=5000},
    {Rarity="Common",Id="DeepFisher",Name="Deep Fisher",Price=15000},
    {Rarity="Rare",Id="AnglerMia",Name="Angler Mia",Price=45000},
    {Rarity="Rare",Id="Alaskan",Name="Alaskan",Price=90000},
    {Rarity="Rare",Id="UncleBob",Name="Uncle Bob",Price=175000},
    {Rarity="Rare",Id="KoiFisher",Name="Koi Fisher",Price=350000},
    {Rarity="Rare",Id="Gnome",Name="Gnome",Price=600000},
    {Rarity="Epic",Id="PiratePete",Name="Pirate Pete",Price=750000},
    {Rarity="Epic",Id="SirTrooper",Name="Sir Trooper",Price=1500000},
    {Rarity="Epic",Id="FeatherBoy",Name="Feather Boy",Price=2000000},
    {Rarity="Epic",Id="DrBob",Name="Dr. Bob",Price=3000000},
    {Rarity="Epic",Id="PearlDiver",Name="Pearl Diver",Price=6000000},
    {Rarity="Epic",Id="Miner",Name="Miner",Price=10000000},
    {Rarity="Legendary",Id="ClownTimmy",Name="Clown Timmy",Price=15000000},
    {Rarity="Legendary",Id="CoralZoe",Name="Coral Zoe",Price=25000000},
    {Rarity="Legendary",Id="CloudNine",Name="Cloud Nine",Price=30000000},
    {Rarity="Legendary",Id="WizardTom",Name="Wizard Tom",Price=40000000},
    {Rarity="Legendary",Id="ToadFisher",Name="Toad Fisher",Price=120000000},
    {Rarity="Mythical",Id="SoldierSteve",Name="Soldier Steve",Price=300000000},
    {Rarity="Mythical",Id="SeaCommander",Name="Sea Commander",Price=750000000},
    {Rarity="Mythical",Id="CursedPirate",Name="Cursed Pirate",Price=3330000000},
    {Rarity="Mythical",Id="ArcticNoah",Name="Arctic Noah",Price=10000000000},
    {Rarity="Divine",Id="AlienFisher",Name="Alien Fisher",Price=37500000000},
    {Rarity="Divine",Id="BeeKeeper",Name="Bee Keeper",Price=65000000000},
    {Rarity="Divine",Id="Hazmat",Name="Hazmat",Price=112000000000},
    {Rarity="Deep",Id="TideKnight",Name="Tide Knight",Price=400000000000},
    {Rarity="Deep",Id="Necromancer",Name="Necromancer",Price=900000000000},
    {Rarity="Deep",Id="IceKing",Name="Ice King",Price=2000000000000},
    {Rarity="Deep",Id="Tyrone",Name="Tyrone",Price=4500000000000},
    {Rarity="Abyss",Id="CryoWarden",Name="Cryo Warden",Price=10000000000000},
    {Rarity="Abyss",Id="TundraPathfinder",Name="Tundra Pathfinder",Price=22500000000000},
    {Rarity="Abyss",Id="ArcticHunter",Name="Arctic Hunter",Price=50000000000000},
    {Rarity="Abyss",Id="RimeWizard",Name="Rime Wizard",Price=112500000000000},
    {Rarity="Event",Id="TidalChamp",Name="Tidal Champion",Price=900000000000},
    {Rarity="Event",Id="KidFloaty",Name="Kid Floaty",Price=990000000000},
    {Rarity="Event",Id="CrabLord",Name="Crab Lord",Price=1125000000000},
    {Rarity="Event",Id="BeachKing",Name="Beach King",Price=1350000000000},
    {Rarity="Event",Id="SeaSpecialist",Name="Sea Specialist",Price=1350000000000},
    {Rarity="Golden",Id="GoldenSam",Name="Golden Sam",Price=900000000000},
    {Rarity="Golden",Id="GoldenPirate",Name="Golden Pirate",Price=990000000000},
    {Rarity="Golden",Id="GoldenDiver",Name="Golden Diver",Price=1125000000000},
    {Rarity="Admin",Id="SealMan",Name="Seal Man",Price=3600000000000},
}
local function registerFisherman(def)
    if type(def)~="table" then return end
    if def.Id then fishermen[tostring(def.Id)]=def end
    if def.Name then fishermen[tostring(def.Name)]=def end
end
for _,def in ipairs(FISHERMAN_CATALOG) do
    registerFisherman(def)
end
local definitionsReady=true
local rollCard=Card(UI.Sections[AutoPage][2],100)
rollCard.LayoutOrder=4
netCard.LayoutOrder=5
local rollStatus=Label(rollCard,"Auto Roll OFF • Auto Buy OFF",UDim2.new(1,-24,1,-16),UDim2.fromOffset(12,8),12,nil,Theme.Sub)
local rarityOptions={"Common","Rare","Epic","Legendary","Mythical","Divine","Deep","Abyss","Event","Golden","Admin"}
local rarityCard=MultiDropdown(UI.Sections[AutoPage][2],"Purchase Rarities",rarityOptions,{},function(list)
    selectedRarities={}
    for _,rarity in ipairs(list) do selectedRarities[rarity]=true end
end)
rarityCard.LayoutOrder=3
local function hasSelectedBuyRarity()
    return next(selectedRarities)~=nil
end
local function autoBuyActive()
    return buyEnabled or (rollEnabled and hasSelectedBuyRarity())
end
local function promptPosition(prompt)
    local parent=prompt.Parent
    if parent and parent:IsA("Attachment") then return parent.WorldPosition end
    if parent and parent:IsA("BasePart") then return parent.Position end
    if parent and parent:IsA("Model") then return parent:GetPivot().Position end
end
local function withinRange(prompt)
    local char=Player.Character
    local root=char and char:FindFirstChild("HumanoidRootPart")
    local pos=promptPosition(prompt)
    if not root or not pos or not prompt.Enabled then return false end
    if (root.Position-pos).Magnitude>prompt.MaxActivationDistance then return false end
    return true
end
local function promptCombinedText(prompt)
    if not prompt then return "" end
    return string.lower(
        tostring(prompt.Name or "").." "
        ..tostring(prompt.ActionText or "").." "
        ..tostring(prompt.ObjectText or "")
    )
end
local function isRollPrompt(prompt)
    local t=promptCombinedText(prompt)
    return string.find(t,"roll",1,true)~=nil
        or string.find(t,"spin",1,true)~=nil
        or string.find(t,"wheel",1,true)~=nil
end
local function pressPrompt(prompt,generation,direct)
    if not alive or not (rollEnabled or buyEnabled) or generation~=rollGeneration then
        return false,"Automation stopped"
    end
    if not prompt or not prompt.Parent or not prompt.Enabled then
        return false,"Prompt unavailable"
    end
    if direct and isRollPrompt(prompt) then
        return false,"Blocked Roll prompt"
    end
    if not withinRange(prompt) then
        return false,direct and "Stand near podium" or "Stand near button"
    end
    heldPrompt=prompt
    local ok,err=pcall(function()
        prompt:InputHoldBegin()
        task.wait(math.max(prompt.HoldDuration,0.05)+0.05)
        prompt:InputHoldEnd()
    end)
    heldPrompt=nil
    if not ok then
        return false,tostring(err)
    end
    return alive and (rollEnabled or buyEnabled) and generation==rollGeneration
end
local function normalizeText(value)
    return string.lower(tostring(value or "")):gsub("[^%w]","")
end
local function addSearchText(buffer,value)
    value=tostring(value or "")
    if value~="" then
        buffer[#buffer+1]=value
    end
end
local fishermanAliases={}
for _,def in ipairs(FISHERMAN_CATALOG) do
    local aliases={
        normalizeText(def.Id),
        normalizeText(def.Name),
        normalizeText((def.Name or ""):gsub("%s+","")),
    }
    for _,alias in ipairs(aliases) do
        if alias~="" then fishermanAliases[alias]=def end
    end
end
local function definitionFor(prompt,plot)
    if not prompt then return nil end
    local search={}
    addSearchText(search,prompt.Name)
    addSearchText(search,prompt.ActionText)
    addSearchText(search,prompt.ObjectText)
    local object=prompt
    local depth=0
    while object and object~=workspace and depth<12 do
        local id=
            object:GetAttribute("Fisherman")
            or object:GetAttribute("FishermanId")
            or object:GetAttribute("FishermanID")
            or object:GetAttribute("Id")
            or object:GetAttribute("ID")
        if id and fishermen[tostring(id)] then
            return fishermen[tostring(id)]
        end
        if fishermen[object.Name] then
            return fishermen[object.Name]
        end
        addSearchText(search,object.Name)
        for _,child in ipairs(object:GetChildren()) do
            if child:IsA("StringValue") then
                addSearchText(search,child.Name)
                addSearchText(search,child.Value)
            elseif child:IsA("TextLabel") or child:IsA("TextButton") then
                addSearchText(search,child.Text)
            end
        end
        if object==plot then break end
        object=object.Parent
        depth=depth+1
    end
    local holder=prompt.Parent
    if holder then
        local scanRoot=holder.Parent or holder
        local scanned=0
        for _,desc in ipairs(scanRoot:GetDescendants()) do
            scanned=scanned+1
            if scanned>250 then break end
            if desc:IsA("TextLabel") or desc:IsA("TextButton") then
                addSearchText(search,desc.Text)
            elseif desc:IsA("StringValue") then
                addSearchText(search,desc.Name)
                addSearchText(search,desc.Value)
            elseif desc:IsA("ObjectValue") and desc.Value then
                addSearchText(search,desc.Value.Name)
            end
        end
    end
    local combined=normalizeText(table.concat(search," "))
    for alias,def in pairs(fishermanAliases) do
        if alias~="" and string.find(combined,alias,1,true) then
            return def
        end
    end
    local seen={}
    for _,def in pairs(fishermen) do
        if type(def)=="table" and not seen[def] then
            seen[def]=true
            local defName=normalizeText(def.Name)
            local defId=normalizeText(def.Id)
            if defName~="" and string.find(combined,defName,1,true) then
                return def
            end
            if defId~="" and string.find(combined,defId,1,true) then
                return def
            end
        end
    end
    return nil
end
local function looksLikePurchasePrompt(prompt)
    if not prompt:IsA("ProximityPrompt") or not prompt.Enabled then return false end
    if isRollPrompt(prompt) then return false end
    local text=normalizeText(
        tostring(prompt.Name).." "
        ..tostring(prompt.ActionText).." "
        ..tostring(prompt.ObjectText)
    )
    return
        string.find(text,"hire",1,true)~=nil
        or string.find(text,"buy",1,true)~=nil
        or string.find(text,"purchase",1,true)~=nil
        or string.find(text,"recruit",1,true)~=nil
end
local BUY_DETECTION_RADIUS=1000000
local promptScanCache={}
local lastPromptScan=0
local PROMPT_SCAN_INTERVAL=1.5
local function worldPositionOf(object)
    if not object then return nil end
    if object:IsA("Attachment") then return object.WorldPosition end
    if object:IsA("BasePart") then return object.Position end
    if object:IsA("Model") then return object:GetPivot().Position end
    local parent=object.Parent
    while parent and parent~=workspace do
        if parent:IsA("Attachment") then return parent.WorldPosition end
        if parent:IsA("BasePart") then return parent.Position end
        if parent:IsA("Model") then return parent:GetPivot().Position end
        parent=parent.Parent
    end
end
local function belongsToPlayer(object)
    local current=object
    local sawOwnership=false
    while current and current~=workspace do
        for _,attr in ipairs({"Owner","OwnerId","OwnerUserId","UserId","PlayerId"}) do
            local value=current:GetAttribute(attr)
            if value~=nil then
                sawOwnership=true
                if tostring(value)==tostring(Player.UserId) or tostring(value)==Player.Name then
                    return true,true
                end
            end
        end
        local ownerValue=current:FindFirstChild("Owner")
        if ownerValue and ownerValue:IsA("ValueBase") then
            sawOwnership=true
            local value=ownerValue.Value
            if tostring(value)==tostring(Player.UserId) or tostring(value)==Player.Name then
                return true,true
            end
        end
        current=current.Parent
    end
    return false,sawOwnership
end
local function refreshPromptCache()
    local now=os.clock()
    if now-lastPromptScan<PROMPT_SCAN_INTERVAL then return end
    lastPromptScan=now
    table.clear(promptScanCache)
    for _,object in ipairs(workspace:GetDescendants()) do
        if object:IsA("ProximityPrompt") and object.Enabled then
            if looksLikePurchasePrompt(object) then
                promptScanCache[#promptScanCache+1]=object
            end
        end
    end
end
local function findWantedHirePrompt(plot)
    if not autoBuyActive() or not definitionsReady then
        return nil,nil,0,0
    end
    refreshPromptCache()
    local char=Player.Character
    local root=char and char:FindFirstChild("HumanoidRootPart")
    local rootPos=root and root.Position
    local foundPrompts=0
    local matchedFishermen=0
    local fallbackPrompt,fallbackDefinition
    local bestPrompt,bestDefinition
    local bestDistance=math.huge
    for _,prompt in ipairs(promptScanCache) do
        if prompt and prompt.Parent and prompt.Enabled then
            local pos=worldPositionOf(prompt)
            local distance=(rootPos and pos) and (rootPos-pos).Magnitude or 0
            if not rootPos or not pos or distance<=BUY_DETECTION_RADIUS then
                local owned,hasOwnerInfo=belongsToPlayer(prompt)
                local inOwnPlot=plot and prompt:IsDescendantOf(plot)
                if inOwnPlot or owned or not hasOwnerInfo then
                    local def=definitionFor(prompt,plot or workspace)
                    foundPrompts=foundPrompts+1
                    if def then
                        matchedFishermen=matchedFishermen+1
                        if selectedRarities[def.Rarity] then
                            if distance<bestDistance then
                                bestDistance=distance
                                bestPrompt=prompt
                                bestDefinition=def
                            end
                        elseif not fallbackDefinition then
                            fallbackPrompt=prompt
                            fallbackDefinition=def
                        end
                    end
                end
            end
        end
    end
    if plot then
        for _,object in ipairs(plot:GetDescendants()) do
            if object:IsA("ProximityPrompt") and object.Enabled and looksLikePurchasePrompt(object) then
                local already=false
                for _,cached in ipairs(promptScanCache) do
                    if cached==object then already=true break end
                end
                if not already then
                    local def=definitionFor(object,plot)
                    if def then
                        foundPrompts=foundPrompts+1
                        matchedFishermen=matchedFishermen+1
                        local pos=worldPositionOf(object)
                        local distance=(rootPos and pos) and (rootPos-pos).Magnitude or 0
                        if selectedRarities[def.Rarity] and distance<=BUY_DETECTION_RADIUS then
                            if distance<bestDistance then
                                bestDistance=distance
                                bestPrompt=object
                                bestDefinition=def
                            end
                        elseif not fallbackDefinition then
                            fallbackPrompt=object
                            fallbackDefinition=def
                        end
                    end
                end
            end
        end
    end
    if bestPrompt then
        return bestPrompt,bestDefinition,foundPrompts,matchedFishermen,fallbackPrompt,fallbackDefinition,bestDistance
    end
    return nil,nil,foundPrompts,matchedFishermen,fallbackPrompt,fallbackDefinition,nil
end
local function getCashValue()
    local data=Player:FindFirstChild("Data")
    local cash=data and data:FindFirstChild("Cash")
    return cash and tonumber(cash.Value) or nil
end
local function getHiredValue()
    local data=Player:FindFirstChild("Data")
    local stats=data and data:FindFirstChild("Stats")
    local hired=stats and stats:FindFirstChild("Hired")
    return hired and tonumber(hired.Value) or nil
end
local function purchaseChanged(prompt,beforeCash,beforeHired)
    if not prompt or not prompt.Parent or not prompt.Enabled then
        return true
    end
    local afterCash=getCashValue()
    local afterHired=getHiredValue()
    if beforeCash~=nil and afterCash~=nil and afterCash<beforeCash then
        return true
    end
    if beforeHired~=nil and afterHired~=nil and afterHired>beforeHired then
        return true
    end
    return false
end
local function rollAtButton(prompt,generation)
    if not prompt or not prompt.Parent or not prompt.Enabled or not isRollPrompt(prompt) then
        return false,"Roll prompt unavailable"
    end
    if not withinRange(prompt) then
        return false,"Stand near button"
    end
    return pressPrompt(prompt,generation,false)
end
local function purchaseFisherman(prompt,generation)
    if not prompt or isRollPrompt(prompt) then
        return false,"Blocked non-Hire prompt"
    end
    if not withinRange(prompt) then
        return false,"Stand near podium"
    end
    local beforeCash=getCashValue()
    local beforeHired=getHiredValue()
    local ok,reason=pressPrompt(prompt,generation,true)
    if not ok then
        return false,reason
    end
    task.wait(0.25)
    if purchaseChanged(prompt,beforeCash,beforeHired) then
        return true,"Purchased"
    end
    return false,"Purchase not confirmed"
end
local function runRoll(generation)
    local nextRoll=0
    local nextBuy=0
    while alive and (rollEnabled or buyEnabled) and generation==rollGeneration do
        if UIS:GetFocusedTextBox() then
            rollStatus.Text="Paused while typing"
        else
            local plot=ownPlot()
            if not plot then
                rollStatus.Text="Waiting for your plot"
            else
                local buyingMode=autoBuyActive()
                local wanted,definition,promptCount,matchedCount,seenPrompt,seenDefinition,buyDistance
                if buyingMode then
                    wanted,definition,promptCount,matchedCount,seenPrompt,seenDefinition,buyDistance=findWantedHirePrompt(plot)
                else
                    promptCount,matchedCount=0,0
                end
                if buyingMode and not definitionsReady then
                    rollStatus.Text="Loading fisherman definitions"
                elseif buyEnabled and not hasSelectedBuyRarity() and not rollEnabled then
                    rollStatus.Text="Select purchase rarities"
                elseif wanted and not isRollPrompt(wanted) then
                    if not withinRange(wanted) then
                        rollStatus.Text="Paused roll • "..tostring(definition.Name)
                            .." • "..tostring(definition.Rarity)
                            .." • Stand near podium"
                    elseif os.clock()>=nextBuy then
                        local data=Player:FindFirstChild("Data")
                        local cash=data and data:FindFirstChild("Cash")
                        local price=definition and tonumber(definition.Price)
                        local currentCash=cash and tonumber(cash.Value)
                        if currentCash and price and currentCash<price then
                            rollStatus.Text="Paused roll • need more cash for "..tostring(definition.Name)
                            nextBuy=os.clock()+0.75
                        else
                            rollStatus.Text="Paused roll • buying "..tostring(definition.Name)
                                .." • "..tostring(definition.Rarity)
                            local ok,reason=purchaseFisherman(wanted,generation)
                            if ok then
                                rollStatus.Text="Bought "..tostring(definition.Name).." • checking for more selected rarities"
                                nextRoll=0
                            else
                                rollStatus.Text="Paused roll • "..tostring(definition.Name).." • "..tostring(reason)
                            end
                            nextBuy=os.clock()+0.8
                        end
                    else
                        rollStatus.Text="Paused roll • selected rarity detected • confirming purchase"
                    end
                elseif rollEnabled and os.clock()>=nextRoll then
                    local button=plot:FindFirstChild("RollButton")
                    local prompt=button and button:FindFirstChild("Roll")
                    if prompt and prompt:IsA("ProximityPrompt") then
                        rollStatus.Text=hasSelectedBuyRarity()
                            and "No selected rarity detected • rolling again"
                            or "Rolling at the red button"
                        local rolled,reason=rollAtButton(prompt,generation)
                        if rolled then
                            nextRoll=os.clock()+4.5
                        else
                            rollStatus.Text="Auto Roll • "..tostring(reason)
                        end
                    else
                        rollStatus.Text="Roll button not detected"
                    end
                elseif buyingMode then
                    if promptCount==0 then
                        rollStatus.Text=rollEnabled
                            and "Rolling • scanning map-wide for selected rarities"
                            or "No purchase prompt detected map-wide"
                    elseif matchedCount==0 then
                        rollStatus.Text="Found "..tostring(promptCount).." podium prompt(s) • reading fisherman"
                    elseif seenDefinition then
                        rollStatus.Text="Detected "..tostring(seenDefinition.Name).." • "
                            ..tostring(seenDefinition.Rarity).." • not selected"
                    else
                        rollStatus.Text="No selected rarity detected • waiting"
                    end
                elseif not rollEnabled then
                    rollStatus.Text="Auto Roll OFF • Auto Buy OFF"
                end
            end
        end
        task.wait(0.2)
    end
end
local function restartAutomation()
    rollGeneration=rollGeneration+1
    releaseRollKey()
    if heldPrompt then
        pcall(function() heldPrompt:InputHoldEnd() end)
        heldPrompt=nil
    end
    if rollWorker and coroutine.status(rollWorker)~="dead" then
        pcall(task.cancel,rollWorker)
    end
    restoreBuyPosition()
    restoreBuyPosition=function() end
    if not alive then return end
    if not rollEnabled and not buyEnabled then
        rollStatus.Text="Auto Roll OFF • Auto Buy OFF"
        return
    end
    local generation=rollGeneration
    rollWorker=task.spawn(function()
        local ok,err=pcall(runRoll,generation)
        if not ok and alive then
            releaseRollKey()
            restoreBuyPosition()
            rollStatus.Text="Automation error • see console"
            warn("[MomongaHub] "..tostring(err))
        end
    end)
end
local rollToggle=Toggle(UI.Sections[AutoPage][2],"Auto Roll","Stand near button",false,function(on)
    rollEnabled=on
    restartAutomation()
end)
rollToggle.Card.LayoutOrder=1
local buyToggle=Toggle(
    UI.Sections[AutoPage][2],
    "Auto Buy",
    "Stand near podium",
    false,
    function(on)
        buyEnabled=on
        restartAutomation()
    end
)
buyToggle.Card.LayoutOrder=2
task.spawn(function()
    local ok,result=pcall(function()
        local modules=RS:WaitForChild("Modules",15)
        assert(modules,"Modules missing")
        local gameplay=modules:WaitForChild("Gameplay",15)
        assert(gameplay,"Gameplay missing")
        local content=gameplay:WaitForChild("Content",15)
        assert(content,"Content missing")
        local module=content:WaitForChild("Fishermen",15)
        assert(module,"Fishermen missing")
        return require(module)
    end)
    if not alive then return end
    if not ok or type(result)~="table" or type(result.List)~="table" then
        warn("[MomongaHub] Runtime Fishermen module unavailable; using embedded 44-name catalog: "..tostring(result))
        return
    end
    for _,def in ipairs(result.List) do
        registerFisherman(def)
    end
    definitionsReady=true
end)
local privacyOriginal=setmetatable({}, {__mode="k"})
local privacyWatching=setmetatable({}, {__mode="k"})
local privacyGuard=false
local function isOwnName(text)
    text=string.lower(tostring(text)):gsub("<[^>]->","")
    for _,name in ipairs({Player.Name,Player.DisplayName}) do
        if #name>0 and string.find(text,string.lower(name),1,true) then return true end
    end
    return false
end
local function privacyApply(object)
    if privacyGuard or not object.Parent or object:IsDescendantOf(ScreenGui) then return end
    if object:IsA("TextLabel") or object:IsA("TextButton") then
        local saved=privacyOriginal[object]
        if Config.HideName and isOwnName(object.Text) then
            if not saved then saved={property="Visible",value=object.Visible}; privacyOriginal[object]=saved end
            privacyGuard=true; object.Visible=false; privacyGuard=false
        elseif saved then
            privacyGuard=true; object[saved.property]=saved.value; privacyGuard=false
            privacyOriginal[object]=nil
        end
    elseif object:IsA("Humanoid") and Player.Character and object:IsDescendantOf(Player.Character) then
        local saved=privacyOriginal[object]
        if Config.HideName then
            if not saved then privacyOriginal[object]={property="NameDisplayDistance",value=object.NameDisplayDistance} end
            privacyGuard=true; object.NameDisplayDistance=0; privacyGuard=false
        elseif saved then
            privacyGuard=true; object.NameDisplayDistance=saved.value; privacyGuard=false
            privacyOriginal[object]=nil
        end
    end
end
local function privacyTrack(object)
    if privacyWatching[object] or object:IsDescendantOf(ScreenGui) then return end
    if object:IsA("TextLabel") or object:IsA("TextButton") then
        privacyWatching[object]=true
        UIConnect(object:GetPropertyChangedSignal("Text"),function() privacyApply(object) end)
        UIConnect(object:GetPropertyChangedSignal("Visible"),function() privacyApply(object) end)
        privacyApply(object)
    elseif object:IsA("Humanoid") then
        privacyWatching[object]=true
        UIConnect(object:GetPropertyChangedSignal("NameDisplayDistance"),function() privacyApply(object) end)
        privacyApply(object)
    end
end
restoreNamePrivacy=function()
    privacyGuard=true
    for object,saved in pairs(privacyOriginal) do
        pcall(function() object[saved.property]=saved.value end)
        privacyOriginal[object]=nil
    end
    privacyGuard=false
end
local originalApplyPrivacy=UI.ApplyNamePrivacy
UI.ApplyNamePrivacy=function()
    originalApplyPrivacy()
    if not Config.HideName then restoreNamePrivacy(); return end
    for object in pairs(privacyWatching) do privacyApply(object) end
end
for _,container in ipairs({workspace,PlayerGui}) do
    UIConnect(container.DescendantAdded,function(object)
        task.defer(function() if alive then privacyTrack(object) end end)
    end)
    task.spawn(function()
        for i,object in ipairs(container:GetDescendants()) do
            if not alive then return end
            privacyTrack(object)
            if i%500==0 then task.wait() end
        end
    end)
end
UIConnect(Player.CharacterAdded,function(character)
    task.defer(function()
        if not alive then return end
        for _,object in ipairs(character:GetDescendants()) do privacyTrack(object); privacyApply(object) end
    end)
end)
local antiAfk=false
local idleMouseDown=false
local idleCamera=CFrame.new()
local VirtualUser=game:GetService("VirtualUser")
local function releaseIdleInput()
    if idleMouseDown then
        pcall(function() VirtualUser:Button2Up(Vector2.new(0,0),idleCamera) end)
        idleMouseDown=false
    end
end
local antiControl=Toggle(UI.Sections[SettingsPage][2],"Anti AFK","Sends a brief idle input while enabled.",false,function(on)
    antiAfk=on
    if not on then releaseIdleInput() end
end)
UIConnect(Player.Idled,function()
    if not alive or not antiAfk or idleMouseDown then return end
    local ok,err=pcall(function()
        VirtualUser:CaptureController()
        idleCamera=workspace.CurrentCamera and workspace.CurrentCamera.CFrame or CFrame.new()
        idleMouseDown=true
        VirtualUser:Button2Down(Vector2.new(0,0),idleCamera)
    end)
    if not ok then
        releaseIdleInput()
        antiControl.Status.Text="Idle input unavailable in this environment."
        warn("[MomongaHub Anti AFK] "..tostring(err))
        return
    end
    task.delay(0.1,releaseIdleInput)
end)
local originalSpeeds=setmetatable({}, {__mode="k"})
local speedEnabled=false
local currentHumanoid=Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
local chosenSpeed=currentHumanoid and currentHumanoid.WalkSpeed or 16
local function rememberSpeed(humanoid)
    if originalSpeeds[humanoid]==nil then originalSpeeds[humanoid]=humanoid.WalkSpeed end
end
local function applySpeed(humanoid)
    if humanoid and humanoid.Parent then
        rememberSpeed(humanoid)
        if speedEnabled then humanoid.WalkSpeed=chosenSpeed end
    end
end
if currentHumanoid then rememberSpeed(currentHumanoid) end
local speedCard=Card(UI.Sections[SettingsPage][1],122)
speedCard.LayoutOrder=-1
Label(speedCard,"WalkSpeed",UDim2.new(1,-110,0,28),UDim2.fromOffset(14,8),14)
local speedValue=Label(speedCard,tostring(chosenSpeed),UDim2.fromOffset(76,28),UDim2.new(1,-90,0,8),13,nil,Theme.Pink)
speedValue.TextXAlignment=Enum.TextXAlignment.Right
local speedBar=Instance.new("Frame")
speedBar.Size=UDim2.new(1,-32,0,8)
speedBar.Position=UDim2.fromOffset(16,53)
speedBar.BackgroundColor3=Theme.Off
speedBar.BorderSizePixel=0
speedBar.Active=true
speedBar.Parent=speedCard
Corner(speedBar,5)
local speedFill=Instance.new("Frame")
speedFill.BackgroundColor3=Theme.Purple
speedFill.BorderSizePixel=0
speedFill.Parent=speedBar
Corner(speedFill,5)
local speedKnob=Instance.new("TextButton")
speedKnob.Text=""
speedKnob.AutoButtonColor=false
speedKnob.Size=UDim2.fromOffset(20,20)
speedKnob.AnchorPoint=Vector2.new(0.5,0.5)
speedKnob.BackgroundColor3=Theme.White
speedKnob.BorderSizePixel=0
speedKnob.Parent=speedBar
Corner(speedKnob,10)
local function renderSpeed()
    local ratio=math.clamp(chosenSpeed/100,0,1)
    speedFill.Size=UDim2.new(ratio,0,1,0)
    speedKnob.Position=UDim2.new(ratio,0,0.5,0)
    speedValue.Text=tostring(chosenSpeed)
end
local function setSpeed(value)
    chosenSpeed=math.clamp(math.floor(value+0.5),0,100)
    speedEnabled=true
    renderSpeed()
    applySpeed(Player.Character and Player.Character:FindFirstChildOfClass("Humanoid"))
end
renderSpeed()
Label(speedCard,"0",UDim2.fromOffset(30,20),UDim2.fromOffset(16,68),10,nil,Theme.Sub)
Label(speedCard,"100",UDim2.fromOffset(30,20),UDim2.new(1,-40,0,68),10,nil,Theme.Sub)
local resetSpeed=Button(speedCard,"Reset speed",UDim2.fromOffset(110,25),UDim2.new(0.5,-55,0,87))
local speedDragging=false
local speedTouch
local function updateSpeed(input)
    local width=speedBar.AbsoluteSize.X
    if width>0 then setSpeed((input.Position.X-speedBar.AbsolutePosition.X)/width*100) end
end
local function beginSpeed(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        speedDragging=true
        speedTouch=input.UserInputType==Enum.UserInputType.Touch and input or nil
        updateSpeed(input)
    end
end
UIConnect(speedBar.InputBegan,beginSpeed)
UIConnect(speedKnob.InputBegan,beginSpeed)
UIConnect(UIS.InputChanged,function(input)
    if speedDragging and (input==speedTouch or (not speedTouch and input.UserInputType==Enum.UserInputType.MouseMovement)) then updateSpeed(input) end
end)
UIConnect(UIS.InputEnded,function(input)
    if input==speedTouch or input.UserInputType==Enum.UserInputType.MouseButton1 then speedDragging=false; speedTouch=nil end
end)
UIConnect(resetSpeed.Activated,function()
    speedEnabled=false
    local humanoid=Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        chosenSpeed=originalSpeeds[humanoid] or humanoid.WalkSpeed
        humanoid.WalkSpeed=chosenSpeed
    end
    renderSpeed()
end)
UIConnect(Player.CharacterAdded,function(character)
    task.spawn(function()
        local humanoid=character:WaitForChild("Humanoid",10)
        if alive and humanoid and Player.Character==character then applySpeed(humanoid) end
    end)
end)
cleanupMovementSettings=function()
    antiAfk=false
    speedDragging=false
    releaseIdleInput()
    for humanoid,speed in pairs(originalSpeeds) do
        if humanoid.Parent then pcall(function() humanoid.WalkSpeed=speed end) end
    end
end
