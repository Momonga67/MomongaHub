if getgenv().MomongaHubUnload then
	pcall(getgenv().MomongaHubUnload)
	getgenv().MomongaHubUnload = nil
end

if getgenv().EnemyTPUnload then
	pcall(getgenv().EnemyTPUnload)
	getgenv().EnemyTPUnload = nil
end

local CoreGui = game:GetService("CoreGui")

for _, gui in ipairs(CoreGui:GetChildren()) do
	if gui.Name == "MomongaHub"
	or gui.Name == "EnemyTPGUI" then
		pcall(function()
			gui:Destroy()
		end)
	end
end

task.wait(0.2)
if getgenv().EnemyTPUnload then
	pcall(getgenv().EnemyTPUnload)
end

local a = game:GetService("Players")
local b = game:GetService("CoreGui")
local c = game:GetService("Workspace")
local d = game:GetService("UserInputService")

local e = a.LocalPlayer
local f = false
local g = {}
local h = {}
local i = {}
local j = {}
local k = nil
local l = nil
local m = false
local n = nil

--========================================================
-- CLEAN OLD GUI
--========================================================

local old = b:FindFirstChild("EnemyTPGUI")
if old then
	old:Destroy()
end

--========================================================
-- TARGET DATABASE
--========================================================

local function seq(prefix, first, last)
	local t = {}

	for x = first, last do
		t[#t + 1] = prefix .. tostring(x)
	end

	return t
end

-- Trial

g.Aizen = {
	"Enemy_Aizen1_1",
	"Enemy_Aizen1_2",
	"Enemy_Aizen1_3"
}

g.Kisuke = {
	"Enemy_Kisuke1_1",
	"Enemy_Kisuke1_2",
	"Enemy_Kisuke1_3"
}

g.Yoruichi = {
	"Enemy_Yoruichi3_1",
	"Enemy_Yoruichi3_2",
	"Enemy_Yoruichi3_3"
}

g.Boss = {
	"Boss"
}

-- Portal

h.GutsEvo = seq("Enemy_GutsEvo_", 1, 5)
h.Ichigo6 = seq("Enemy_Ichigo6_", 1, 5)
h.Kenpachi2 = seq("Enemy_Kenpachi2_", 1, 5)
h.Rukia3 = seq("Boss_Rukia3_", 1, 5)

-- Infinity

i.Ichigo = seq("Enemy_Ichigo1_", 1, 100)
i.Rukia = seq("Enemy_Rukia1_", 1, 100)
i.Uryu = seq("Enemy_Uryu1_", 1, 100)
i.Kenpachi = seq("Boss_Kenpachi1_", 1, 100)

--========================================================
-- ENABLE STATES
--========================================================

local trialEnabled = {
	Aizen = false,
	Kisuke = false,
	Yoruichi = false,
	Boss = false
}

local portalEnabled = {
	GutsEvo = false,
	Ichigo6 = false,
	Kenpachi2 = false,
	Rukia3 = false
}

local infinityEnabled = {
	Ichigo = false,
	Rukia = false,
	Uryu = false,
	Kenpachi = false
}

--========================================================
-- INFINITY PROGRESSION
--========================================================

local infinityKills = {
	Ichigo = false,
	Rukia = false,
	Uryu = false
}

local function infinityBossUnlocked()
	return infinityKills.Ichigo
		and infinityKills.Rukia
		and infinityKills.Uryu
end

local function infinityKillCount()
	local count = 0

	if infinityKills.Ichigo then
		count += 1
	end

	if infinityKills.Rukia then
		count += 1
	end

	if infinityKills.Uryu then
		count += 1
	end

	return count
end

--========================================================
-- BUILD FAST NAME LOOKUP
--========================================================

local lookup = {}

local function register(mode, group, names)
	for _, name in ipairs(names) do
		lookup[name] = {
			mode = mode,
			group = group
		}
	end
end

for group, names in pairs(g) do
	register("Trial", group, names)
end

for group, names in pairs(h) do
	register("Portal", group, names)
end

for group, names in pairs(i) do
	register("Infinity", group, names)
end

--========================================================
-- CHARACTER
--========================================================

local function root()
	local character = e.Character

	if not character then
		return nil
	end

	return character:FindFirstChild("HumanoidRootPart")
		or character:FindFirstChild("Torso")
		or character:FindFirstChild("UpperTorso")
end

--========================================================
-- TARGET PART
--========================================================

local function targetPart(obj)
	if not obj then
		return nil
	end

	if obj:IsA("BasePart") then
		return obj
	end

	if not obj:IsA("Model") then
		return nil
	end

	return obj:FindFirstChild("HumanoidRootPart")
		or obj:FindFirstChild("RootPart")
		or obj:FindFirstChild("UpperTorso")
		or obj:FindFirstChild("Torso")
		or obj.PrimaryPart
		or obj:FindFirstChildWhichIsA("BasePart", true)
end

--========================================================
-- HEALTH
--========================================================

local function getHealth(obj)
	if not obj then
		return 0
	end

	local hum

	if obj:IsA("Model") then
		hum = obj:FindFirstChildWhichIsA("Humanoid", true)
	end

	if hum then
		return hum.Health
	end

	for _, name in ipairs({
		"Health",
		"HP",
		"Hp",
		"health"
	}) do

		local value = obj:FindFirstChild(name, true)

		if value and
			(value:IsA("NumberValue") or value:IsA("IntValue")) then

			return value.Value
		end
	end

	for _, attribute in ipairs({
		"Health",
		"HP",
		"Hp"
	}) do

		local value = obj:GetAttribute(attribute)

		if typeof(value) == "number" then
			return value
		end
	end

	return nil
end

local function dead(obj)
	if not obj then
		return true
	end

	if not obj.Parent then
		return true
	end

	local hp = getHealth(obj)

	if hp ~= nil and hp <= 0 then
		return true
	end

	return false
end

--========================================================
-- TRIAL ROUND DETECTION
--========================================================

local function isBossRound()
	local pg = e:FindFirstChild("PlayerGui")

	if not pg then
		return false
	end

	local trial = pg:FindFirstChild("TrialUI")

	if not trial then
		return false
	end

	local match = trial:FindFirstChild("Match")

	if not match then
		return false
	end

	local round = match:FindFirstChild("Round")

	if not round then
		return false
	end

	local ok, text = pcall(function()
		return tostring(round.Text)
	end)

	if not ok then
		return false
	end

	text = text:gsub("%s+", "")

	return string.find(text, "3/3", 1, true) ~= nil
end

--========================================================
-- ENABLE CHECK
--========================================================

local function enabled(info)
	if not info then
		return false
	end

	if info.mode == "Trial" then

		if not trialEnabled[info.group] then
			return false
		end

		if info.group == "Boss" and not isBossRound() then
			return false
		end

		return true
	end

	if info.mode == "Portal" then
		return portalEnabled[info.group] == true
	end

	if info.mode == "Infinity" then

		if not infinityEnabled[info.group] then
			return false
		end

		if info.group == "Kenpachi"
			and not infinityBossUnlocked() then

			return false
		end

		return true
	end

	return false
end

--========================================================
-- DISTANCE
--========================================================

local function distance(obj)
	local pr = root()
	local tp = targetPart(obj)

	if not pr or not tp then
		return math.huge
	end

	return (pr.Position - tp.Position).Magnitude
end

--========================================================
-- FIND NEAREST TARGET
--========================================================

local function nearest()
	local best = nil
	local bestInfo = nil
	local bestDistance = math.huge

	for _, obj in ipairs(c:GetDescendants()) do

		if not j[obj] then

			local info = lookup[obj.Name]

			if info
				and enabled(info)
				and not dead(obj) then

				local tp = targetPart(obj)

				if tp then
					local dist = distance(obj)

					if dist < bestDistance then
						bestDistance = dist
						best = obj
						bestInfo = info
					end
				end
			end
		end
	end

	return best, bestInfo
end

--========================================================
-- TELEPORT ONCE
--========================================================

local function teleportTo(obj)
	local pr = root()
	local tp = targetPart(obj)

	if not pr or not tp then
		return false
	end

	pr.CFrame = tp.CFrame * CFrame.new(0, 4, 0)

	return true
end

--========================================================
-- GUI
--========================================================

local gui = Instance.new("ScreenGui")
gui.Name = "EnemyTPGUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = b

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(540, 510)
main.Position = UDim2.new(
	0.5,
	-270,
	0.5,
	-255
)
main.BackgroundColor3 = Color3.fromRGB(17, 13, 25)
main.BorderSizePixel = 0
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(100, 66, 150)
stroke.Thickness = 1
stroke.Transparency = 0.25
stroke.Parent = main

--========================================================
-- HEADER
--========================================================

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 68)
header.BackgroundColor3 = Color3.fromRGB(25, 18, 37)
header.BorderSizePixel = 0
header.Parent = main

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header

local cover = Instance.new("Frame")
cover.Size = UDim2.new(1, 0, 0, 12)
cover.Position = UDim2.new(0, 0, 1, -12)
cover.BackgroundColor3 = header.BackgroundColor3
cover.BorderSizePixel = 0
cover.Parent = header

local avatar = Instance.new("ImageLabel")
avatar.Size = UDim2.fromOffset(48, 48)
avatar.Position = UDim2.fromOffset(10, 10)
avatar.BackgroundTransparency = 1
avatar.Image = "rbxassetid://120248975380456"
avatar.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 220, 0, 35)
title.Position = UDim2.fromOffset(68, 8)
title.BackgroundTransparency = 1
title.Text = "MomongaHub"
title.TextColor3 = Color3.fromRGB(240, 235, 255)
title.TextSize = 21
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local gameTitle = Instance.new("TextLabel")
gameTitle.Size = UDim2.new(0, 250, 0, 20)
gameTitle.Position = UDim2.fromOffset(69, 37)
gameTitle.BackgroundTransparency = 1
gameTitle.Text = "Anime World Capsule"
gameTitle.TextColor3 = Color3.fromRGB(151, 128, 186)
gameTitle.TextSize = 11
gameTitle.Font = Enum.Font.Gotham
gameTitle.TextXAlignment = Enum.TextXAlignment.Left
gameTitle.Parent = header

--========================================================
-- AUTO ALL
--========================================================

local autoAll = false

local autoButton = Instance.new("TextButton")
autoButton.Size = UDim2.fromOffset(90, 32)
autoButton.Position = UDim2.new(1, -138, 0, 18)
autoButton.BackgroundColor3 = Color3.fromRGB(54, 39, 77)
autoButton.Text = "Auto All: OFF"
autoButton.TextColor3 = Color3.new(1, 1, 1)
autoButton.TextSize = 11
autoButton.Font = Enum.Font.GothamBold
autoButton.AutoButtonColor = false
autoButton.Parent = header

local ac = Instance.new("UICorner")
ac.CornerRadius = UDim.new(0, 7)
ac.Parent = autoButton

--========================================================
-- MINIMIZE
--========================================================

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.fromOffset(34, 32)
minimize.Position = UDim2.new(1, -40, 0, 18)
minimize.BackgroundColor3 = Color3.fromRGB(54, 39, 77)
minimize.Text = "—"
minimize.TextColor3 = Color3.new(1, 1, 1)
minimize.TextSize = 16
minimize.Font = Enum.Font.GothamBold
minimize.Parent = header

local mc = Instance.new("UICorner")
mc.CornerRadius = UDim.new(0, 7)
mc.Parent = minimize

--========================================================
-- BODY
--========================================================

local body = Instance.new("Frame")
body.Size = UDim2.new(1, 0, 1, -68)
body.Position = UDim2.fromOffset(0, 68)
body.BackgroundTransparency = 1
body.Parent = main

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -30, 0, 24)
status.Position = UDim2.fromOffset(15, 7)
status.BackgroundTransparency = 1
status.Text = "Ready"
status.TextColor3 = Color3.fromRGB(175, 158, 205)
status.TextSize = 11
status.Font = Enum.Font.Gotham
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = body

--========================================================
-- TABS
--========================================================

local tabs = Instance.new("Frame")
tabs.Size = UDim2.new(1, -30, 0, 38)
tabs.Position = UDim2.fromOffset(15, 34)
tabs.BackgroundTransparency = 1
tabs.Parent = body

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 7)
tabLayout.Parent = tabs

local pages = {}

local function page(name)
	local p = Instance.new("ScrollingFrame")
	p.Name = name
	p.Size = UDim2.new(1, -30, 1, -135)
	p.Position = UDim2.fromOffset(15, 80)
	p.BackgroundTransparency = 1
	p.BorderSizePixel = 0
	p.ScrollBarThickness = 3
	p.ScrollBarImageColor3 = Color3.fromRGB(110, 79, 156)
	p.CanvasSize = UDim2.new()
	p.AutomaticCanvasSize = Enum.AutomaticSize.Y
	p.Visible = false
	p.Parent = body

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 7)
	layout.Parent = p

	pages[name] = p

	return p
end

local trialPage = page("Trial")
local portalPage = page("Portal")
local infinityPage = page("Infinity")

local tabButtons = {}

local function switchPage(name)

	for n2, p in pairs(pages) do
		p.Visible = n2 == name
	end

	for n2, btn in pairs(tabButtons) do

		if n2 == name then
			btn.BackgroundColor3 =
				Color3.fromRGB(101, 65, 145)
		else
			btn.BackgroundColor3 =
				Color3.fromRGB(42, 31, 59)
		end
	end
end

local function makeTab(name, text)

	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.new(0.333, -5, 1, 0)
	btn.BackgroundColor3 = Color3.fromRGB(42, 31, 59)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(240, 235, 255)
	btn.TextSize = 12
	btn.Font = Enum.Font.GothamBold
	btn.AutoButtonColor = false
	btn.Parent = tabs

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 7)
	corner.Parent = btn

	tabButtons[name] = btn

	btn.MouseButton1Click:Connect(function()
		switchPage(name)
	end)
end

makeTab("Trial", "⚔ Trial")
makeTab("Portal", "🌀 Portal")
makeTab("Infinity", "♾ Infinity")

--========================================================
-- SECTION
--========================================================

local function section(parent, text)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -5, 0, 27)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(165, 134, 205)
	label.TextSize = 12
	label.Font = Enum.Font.GothamBold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent

	return label
end

--========================================================
-- BUTTON
--========================================================

local function button(parent, text, callback)

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -5, 0, 40)
	btn.BackgroundColor3 = Color3.fromRGB(43, 31, 60)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(235, 229, 245)
	btn.TextSize = 12
	btn.Font = Enum.Font.GothamMedium
	btn.AutoButtonColor = false
	btn.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 7)
	corner.Parent = btn

	btn.MouseButton1Click:Connect(function()
		pcall(callback)
	end)

	return btn
end

--========================================================
-- TOGGLE
--========================================================

local toggleButtons = {}

local function toggle(parent, text, tableRef, key)

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -5, 0, 40)
	btn.BackgroundColor3 = Color3.fromRGB(43, 31, 60)
	btn.TextColor3 = Color3.fromRGB(235, 229, 245)
	btn.TextSize = 12
	btn.Font = Enum.Font.GothamMedium
	btn.AutoButtonColor = false
	btn.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 7)
	corner.Parent = btn

	local function refresh()

		if tableRef[key] then
			btn.Text = "✓  " .. text
			btn.BackgroundColor3 =
				Color3.fromRGB(91, 58, 132)
		else
			btn.Text = "○  " .. text
			btn.BackgroundColor3 =
				Color3.fromRGB(43, 31, 60)
		end
	end

	btn.MouseButton1Click:Connect(function()

		tableRef[key] = not tableRef[key]

		refresh()

		-- Drop current target if its group was disabled.
		if k and l and not enabled(l) then
			k = nil
			l = nil
			m = false
		end

		task.defer(function()
			local all = true

			for _, v in pairs(trialEnabled) do
				if not v then
					all = false
				end
			end

			for _, v in pairs(portalEnabled) do
				if not v then
					all = false
				end
			end

			for _, v in pairs(infinityEnabled) do
				if not v then
					all = false
				end
			end

			autoAll = all

			autoButton.Text =
				autoAll
				and "Auto All: ON"
				or "Auto All: OFF"

			autoButton.BackgroundColor3 =
				autoAll
				and Color3.fromRGB(91, 58, 132)
				or Color3.fromRGB(54, 39, 77)
		end)
	end)

	refresh()

	toggleButtons[#toggleButtons + 1] = {
		refresh = refresh,
		tableRef = tableRef,
		key = key
	}

	return btn
end

--========================================================
-- TRIAL PAGE
--========================================================

section(trialPage, "TRIAL")

button(
	trialPage,
	"🚪  TP to Trial",
	function()

		local pr = root()

		if not pr then
			return
		end

		for _, obj in ipairs(c:GetDescendants()) do

			if obj.Name == "Trial"
				and obj:IsA("BasePart") then

				pr.CFrame =
					obj.CFrame * CFrame.new(0, 4, 0)

				status.Text = "Teleported to Trial"
				return
			end
		end

		status.Text = "Trial teleport not found"
	end
)

section(trialPage, "AUTO TARGET")

toggle(
	trialPage,
	"Aizen",
	trialEnabled,
	"Aizen"
)

toggle(
	trialPage,
	"Kisuke",
	trialEnabled,
	"Kisuke"
)

toggle(
	trialPage,
	"Yoruichi",
	trialEnabled,
	"Yoruichi"
)

toggle(
	trialPage,
	"Boss [Round 3/3]",
	trialEnabled,
	"Boss"
)

--========================================================
-- PORTAL PAGE
--========================================================

section(portalPage, "PORTAL TARGETS")

toggle(
	portalPage,
	"Guts Evo",
	portalEnabled,
	"GutsEvo"
)

toggle(
	portalPage,
	"Ichigo 6",
	portalEnabled,
	"Ichigo6"
)

toggle(
	portalPage,
	"Kenpachi 2",
	portalEnabled,
	"Kenpachi2"
)

toggle(
	portalPage,
	"Rukia 3",
	portalEnabled,
	"Rukia3"
)

--========================================================
-- INFINITY PAGE
--========================================================

section(infinityPage, "INFINITY TARGETS")

toggle(
	infinityPage,
	"Ichigo",
	infinityEnabled,
	"Ichigo"
)

toggle(
	infinityPage,
	"Rukia",
	infinityEnabled,
	"Rukia"
)

toggle(
	infinityPage,
	"Uryu",
	infinityEnabled,
	"Uryu"
)

toggle(
	infinityPage,
	"Kenpachi [Boss]",
	infinityEnabled,
	"Kenpachi"
)

--========================================================
-- UNLOAD
--========================================================

local unload = Instance.new("TextButton")
unload.Size = UDim2.new(1, -30, 0, 38)
unload.Position = UDim2.new(0, 15, 1, -46)
unload.BackgroundColor3 = Color3.fromRGB(72, 39, 70)
unload.Text = "Unload MomongaHub"
unload.TextColor3 = Color3.fromRGB(245, 230, 245)
unload.TextSize = 12
unload.Font = Enum.Font.GothamBold
unload.Parent = body

local uc = Instance.new("UICorner")
uc.CornerRadius = UDim.new(0, 7)
uc.Parent = unload

--========================================================
-- AUTO ALL
--========================================================

local function setAll(value)

	for key in pairs(trialEnabled) do
		trialEnabled[key] = value
	end

	for key in pairs(portalEnabled) do
		portalEnabled[key] = value
	end

	for key in pairs(infinityEnabled) do
		infinityEnabled[key] = value
	end

	for _, data in ipairs(toggleButtons) do
		data.refresh()
	end

	autoAll = value

	autoButton.Text =
		value
			and "Auto All: ON"
			or "Auto All: OFF"

	autoButton.BackgroundColor3 =
		value
			and Color3.fromRGB(91, 58, 132)
			or Color3.fromRGB(54, 39, 77)

	if not value then
		k = nil
		l = nil
		m = false
	end
end

autoButton.MouseButton1Click:Connect(function()
	setAll(not autoAll)
end)

--========================================================
-- MINIMIZE
--========================================================

local minimized = false

minimize.MouseButton1Click:Connect(function()

	minimized = not minimized

	body.Visible = not minimized

	if minimized then

		main.Size =
			UDim2.fromOffset(540, 68)

		minimize.Text = "+"

	else

		main.Size =
			UDim2.fromOffset(540, 510)

		minimize.Text = "—"
	end
end)

--========================================================
-- DRAG
--========================================================

local dragging = false
local dragStart
local startPosition

header.InputBegan:Connect(function(input)

	if input.UserInputType ==
		Enum.UserInputType.MouseButton1
		or input.UserInputType ==
		Enum.UserInputType.Touch then

		dragging = true
		dragStart = input.Position
		startPosition = main.Position
	end
end)

header.InputEnded:Connect(function(input)

	if input.UserInputType ==
		Enum.UserInputType.MouseButton1
		or input.UserInputType ==
		Enum.UserInputType.Touch then

		dragging = false
	end
end)

d.InputChanged:Connect(function(input)

	if not dragging then
		return
	end

	if input.UserInputType ~=
		Enum.UserInputType.MouseMovement
		and input.UserInputType ~=
		Enum.UserInputType.Touch then

		return
	end

	local delta = input.Position - dragStart

	main.Position =
		UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
end)

--========================================================
-- UNLOAD FUNCTION
--========================================================

local function destroy()

	if f then
		return
	end

	f = true

	k = nil
	l = nil
	m = false

	if gui then
		gui:Destroy()
	end

	getgenv().EnemyTPUnload = nil
end

getgenv().EnemyTPUnload = destroy

unload.MouseButton1Click:Connect(destroy)

--========================================================
-- TARGET DEATH HANDLER
--========================================================

local function completedTarget(target, info)

	if not target or not info then
		return
	end

	-- Blacklist this exact instance only.
	j[target] = true

	-- Infinity only needs one kill from each required group.
	if info.mode == "Infinity" then

		if info.group == "Ichigo"
			or info.group == "Rukia"
			or info.group == "Uryu" then

			infinityKills[info.group] = true
		end
	end
end

--========================================================
-- UNIFIED TARGET SCHEDULER
--
-- Trial / Portal / Infinity all use ONE scheduler.
-- This prevents the different modes fighting over CFrame.
--========================================================

task.spawn(function()

	while not f do

		local success, err = pcall(function()

			--================================================
			-- CURRENT TARGET
			--================================================

			if k then

				-- Target died/disappeared.
				if dead(k) then

					completedTarget(k, l)

					k = nil
					l = nil
					m = false

				-- Toggle disabled or gate became invalid.
				elseif not enabled(l) then

					k = nil
					l = nil
					m = false

				else

					if l.mode == "Infinity" then

						status.Text =
							"Target: "
							.. l.group
							.. "  |  Kenpachi: "
							.. tostring(infinityKillCount())
							.. "/3"

					elseif l.mode == "Trial"
						and l.group == "Boss" then

						status.Text =
							"Target: Trial Boss | Round 3/3"

					else

						status.Text =
							l.mode
							.. " | "
							.. l.group
					end
				end
			end

			--================================================
			-- FIND NEW TARGET
			--================================================

			if not k then

				local newTarget, info = nearest()

				if newTarget and info then

					k = newTarget
					l = info
					m = false
				end
			end

			--================================================
			-- TELEPORT EXACTLY ONCE
			--================================================

			if k
				and l
				and not m
				and not dead(k)
				and enabled(l) then

				if teleportTo(k) then

					m = true

					if l.mode == "Infinity" then

						status.Text =
							"Target: "
							.. l.group
							.. "  |  Kenpachi: "
							.. tostring(infinityKillCount())
							.. "/3"

					else

						status.Text =
							l.mode
							.. " | "
							.. l.group
					end
				end
			end

			--================================================
			-- IDLE STATUS
			--================================================

			if not k then

				if infinityEnabled.Kenpachi
					and not infinityBossUnlocked() then

					status.Text =
						"Kenpachi: "
						.. tostring(infinityKillCount())
						.. "/3 enemies defeated"

				else

					status.Text =
						"Waiting for target..."
				end
			end
		end)

		if not success then
			warn("[MH] " .. tostring(err))
		end

		task.wait(0.15)
	end
end)

--========================================================
-- CHARACTER RESPAWN
--========================================================

e.CharacterAdded:Connect(function()

	k = nil
	l = nil
	m = false

	task.wait(1)
end)

--========================================================
-- START
--========================================================

switchPage("Trial")

print("[MomongaHub] Anime World Capsule loaded.")
