--========================================================
-- EV03 CONTROL V3.7 (EXECUTOR EDITION)
-- CAMERA DIRECTION FLIGHT
-- Creator: 阿叶ev03
-- Client Standalone / Executor Compatible
--========================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui", 10)
if not PG then return end

--========================================================
-- CLEAN OLD GUI
--========================================================

for _, name in ipairs({"EV03_CONTROL", "EV03_ESP"}) do
	local old = PG:FindFirstChild(name)
	if old then pcall(function() old:Destroy() end) end
end

--========================================================
-- COLORS
--========================================================

local C = {
	BG = Color3.fromRGB(13, 13, 17),
	SIDEBAR = Color3.fromRGB(19, 19, 24),
	PANEL = Color3.fromRGB(26, 26, 33),
	PANEL2 = Color3.fromRGB(36, 36, 44),
	RED = Color3.fromRGB(195, 31, 49),
	DARK_RED = Color3.fromRGB(105, 20, 30),
	GREEN = Color3.fromRGB(27, 155, 76),
	YELLOW = Color3.fromRGB(220, 175, 55),
	WHITE = Color3.fromRGB(245, 245, 245),
	GRAY = Color3.fromRGB(155, 155, 165),
}

local function validNumber(n)
	return typeof(n) == "number"
		and n == n
		and n ~= math.huge
		and n ~= -math.huge
end

local function create(className, props, parent)
	local obj = Instance.new(className)
	for key, value in pairs(props or {}) do
		pcall(function() obj[key] = value end)
	end
	obj.Parent = parent
	return obj
end

--========================================================
-- WINDOW SIZE
--========================================================

local camera = workspace.CurrentCamera
local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)

local windowWidth = math.floor(math.clamp(viewport.X - 30, 560, 900))
local windowHeight = math.floor(math.clamp(viewport.Y - 40, 440, 680))

--========================================================
-- GUI ROOT
--========================================================

local gui = create("ScreenGui", {
	Name = "EV03_CONTROL",
	ResetOnSpawn = false,
	IgnoreGuiInset = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, PG)

local espGui = create("ScreenGui", {
	Name = "EV03_ESP",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, PG)

local main = create("Frame", {
	Name = "Main",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(windowWidth, windowHeight),
	BackgroundColor3 = C.BG,
	BorderSizePixel = 0,
	Active = true,
	ClipsDescendants = true,
}, gui)

create("UICorner", { CornerRadius = UDim.new(0, 11) }, main)
create("UIStroke", { Color = C.RED, Thickness = 2 }, main)

--========================================================
-- HEADER
--========================================================

local header = create("Frame", {
	Size = UDim2.new(1, 0, 0, 58),
	BackgroundColor3 = C.SIDEBAR,
	BorderSizePixel = 0,
}, main)

local dragArea = create("TextButton", {
	Size = UDim2.new(1, -110, 1, 0),
	BackgroundTransparency = 1,
	Text = "",
	AutoButtonColor = false,
	Active = true,
}, header)

create("TextLabel", {
	Size = UDim2.new(1, -20, 0, 29),
	Position = UDim2.fromOffset(15, 4),
	BackgroundTransparency = 1,
	Text = "EV03 CONTROL",
	TextColor3 = C.RED,
	TextSize = 23,
	Font = Enum.Font.GothamBlack,
	TextXAlignment = Enum.TextXAlignment.Left,
}, dragArea)

create("TextLabel", {
	Size = UDim2.new(1, -20, 0, 15),
	Position = UDim2.fromOffset(16, 34),
	BackgroundTransparency = 1,
	Text = "EXECUTOR EDITION // V3.7",
	TextColor3 = C.GRAY,
	TextSize = 9,
	Font = Enum.Font.Code,
	TextXAlignment = Enum.TextXAlignment.Left,
}, dragArea)

local function headerButton(text, offset)
	local b = create("TextButton", {
		Size = UDim2.fromOffset(36, 32),
		Position = UDim2.new(1, offset, 0, 13),
		BackgroundColor3 = C.DARK_RED,
		Text = text,
		TextColor3 = C.WHITE,
		TextSize = 18,
		Font = Enum.Font.GothamBold,
		BorderSizePixel = 0,
	}, header)
	create("UICorner", { CornerRadius = UDim.new(0, 6) }, b)
	return b
end

local minimizeButton = headerButton("—", -88)
local closeButton = headerButton("×", -45)

--========================================================
-- MAIN BODY & NAVIGATION
--========================================================

local body = create("Frame", {
	Position = UDim2.fromOffset(0, 58),
	Size = UDim2.new(1, 0, 1, -86),
	BackgroundTransparency = 1,
}, main)

local sidebar = create("Frame", {
	Size = UDim2.new(0, 158, 1, 0),
	BackgroundColor3 = C.SIDEBAR,
	BorderSizePixel = 0,
}, body)

create("TextLabel", {
	Size = UDim2.new(1, -20, 0, 23),
	Position = UDim2.fromOffset(12, 15),
	BackgroundTransparency = 1,
	Text = "NAVIGATION",
	TextColor3 = C.GRAY,
	TextSize = 10,
	Font = Enum.Font.GothamBold,
	TextXAlignment = Enum.TextXAlignment.Left,
}, sidebar)

local navContainer = create("Frame", {
	Position = UDim2.fromOffset(8, 48),
	Size = UDim2.new(1, -16, 0, 370),
	BackgroundTransparency = 1,
}, sidebar)

create("UIListLayout", { Padding = UDim.new(0, 7) }, navContainer)

local contentHost = create("Frame", {
	Position = UDim2.new(0, 158, 0, 0),
	Size = UDim2.new(1, -158, 1, 0),
	BackgroundTransparency = 1,
	ClipsDescendants = true,
}, body)

local footer = create("Frame", {
	Position = UDim2.new(0, 0, 1, -28),
	Size = UDim2.new(1, 0, 0, 28),
	BackgroundColor3 = C.SIDEBAR,
	BorderSizePixel = 0,
}, main)

local status = create("TextLabel", {
	Size = UDim2.new(1, -24, 1, 0),
	Position = UDim2.fromOffset(12, 0),
	BackgroundTransparency = 1,
	Text = "SYSTEM READY",
	TextColor3 = C.GREEN,
	TextSize = 10,
	Font = Enum.Font.Code,
	TextXAlignment = Enum.TextXAlignment.Left,
}, footer)

local function setStatus(message, color)
	status.Text = tostring(message)
	status.TextColor3 = color or C.GREEN
end

-- PAGE SYSTEM
local pages = {}
local navButtons = {}

local function createPage(name)
	local page = create("ScrollingFrame", {
		Name = name,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 5,
		ScrollBarImageColor3 = C.RED,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		Visible = false,
	}, contentHost)

	create("UIPadding", {
		PaddingLeft = UDim.new(0, 13),
		PaddingRight = UDim.new(0, 13),
		PaddingTop = UDim.new(0, 13),
		PaddingBottom = UDim.new(0, 15),
	}, page)

	create("UIListLayout", {
		Padding = UDim.new(0, 12),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, page)

	pages[name] = page
	return page
end

local function createSection(parent, title, height)
	local card = create("Frame", {
		Name = title:gsub("%W", "") .. "Section",
		Size = UDim2.new(1, -5, 0, height),
		BackgroundColor3 = C.PANEL,
		BorderSizePixel = 0,
	}, parent)

	create("UICorner", { CornerRadius = UDim.new(0, 9) }, card)
	create("UIStroke", { Color = C.PANEL2, Thickness = 1 }, card)

	create("TextLabel", {
		Size = UDim2.new(1, -24, 0, 26),
		Position = UDim2.fromOffset(12, 7),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = C.RED,
		TextSize = 14,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, card)

	return card
end

local function makeButton(parent, text, x, y, width, height, callback)
	local button = create("TextButton", {
		Size = UDim2.new(width, 0, 0, height),
		Position = UDim2.new(x, 0, 0, y),
		BackgroundColor3 = C.DARK_RED,
		Text = text,
		TextColor3 = C.WHITE,
		TextSize = 12,
		Font = Enum.Font.GothamBold,
		BorderSizePixel = 0,
		AutoButtonColor = true,
	}, parent)

	create("UICorner", { CornerRadius = UDim.new(0, 6) }, button)
	button.MouseButton1Click:Connect(function()
		local ok, err = pcall(callback)
		if not ok then warn("[EV03 ACTION ERROR]", err) end
	end)
	return button
end

local function makeInput(parent, placeholder, x, y, width, height, initial)
	local input = create("TextBox", {
		Size = UDim2.new(width, 0, 0, height),
		Position = UDim2.new(x, 0, 0, y),
		BackgroundColor3 = C.PANEL2,
		TextColor3 = C.WHITE,
		PlaceholderColor3 = C.GRAY,
		PlaceholderText = placeholder,
		Text = initial or "",
		TextSize = 13,
		Font = Enum.Font.Gotham,
		ClearTextOnFocus = false,
		BorderSizePixel = 0,
	}, parent)
	create("UICorner", { CornerRadius = UDim.new(0, 6) }, input)
	return input
end

local function makeToggle(parent, title, y, callback)
	local active = false
	local button
	local function setState(value)
		active = value == true
		pcall(callback, active)
		button.Text = title .. (active and "  //  ON" or "  //  OFF")
		button.BackgroundColor3 = active and C.GREEN or C.DARK_RED
	end
	button = makeButton(parent, title .. "  //  OFF", 0, y, 1, 38, function()
		setState(not active)
	end)
	return button, setState
end

local function addNavigation(name, label, symbol)
	local button = create("TextButton", {
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = C.SIDEBAR,
		Text = symbol .. "   " .. label,
		TextColor3 = C.GRAY,
		TextSize = 11,
		Font = Enum.Font.GothamBold,
		BorderSizePixel = 0,
	}, navContainer)
	create("UICorner", { CornerRadius = UDim.new(0, 6) }, button)
	navButtons[name] = button

	button.MouseButton1Click:Connect(function()
		for pageName, page in pairs(pages) do page.Visible = pageName == name end
		for pageName, nav in pairs(navButtons) do
			local selected = pageName == name
			nav.BackgroundColor3 = selected and C.DARK_RED or C.SIDEBAR
			nav.TextColor3 = selected and C.WHITE or C.GRAY
		end
		setStatus("PAGE: " .. name)
	end)
	return button
end

-- PAGES
local dashboardPage = createPage("DASHBOARD")
local playerPage = createPage("PLAYER")
local movementPage = createPage("MOVEMENT")
local espPage = createPage("ESP")
local hotkeyPage = createPage("HOTKEYS")
local aboutPage = createPage("ABOUT")

addNavigation("DASHBOARD", "Dashboard", "◆")
addNavigation("PLAYER", "Player", "◈")
addNavigation("MOVEMENT", "Movement", "↗")
addNavigation("ESP", "ESP System", "◎")
addNavigation("HOTKEYS", "Hotkeys", "⌨")
addNavigation("ABOUT", "About", "ⓘ")

-- SHARED STATES
local infiniteJump = false
local flyEnabled = false
local noclipEnabled = false
local invisibleEnabled = false
local espEnabled = false
local flySpeed = 80

local setJumpState, setFlyState, setNoclipState, setInvisibleState, setESPState

-- DASHBOARD
local dashboardCard = createSection(dashboardPage, "EV03 // DASHBOARD", 160)
create("TextLabel", {
	Size = UDim2.new(1, -28, 0, 35),
	Position = UDim2.fromOffset(14, 40),
	BackgroundTransparency = 1,
	Text = "WELCOME TO EV03 CONTROL",
	TextColor3 = C.WHITE,
	TextSize = 19,
	Font = Enum.Font.GothamBlack,
	TextXAlignment = Enum.TextXAlignment.Left,
}, dashboardCard)

create("TextLabel", {
	Size = UDim2.new(1, -28, 0, 70),
	Position = UDim2.fromOffset(14, 82),
	BackgroundTransparency = 1,
	Text = "Creator: 阿叶ev03\nVersion: V3.7\nCamera Direction Flight (Executor Edition)",
	TextColor3 = C.GRAY,
	TextSize = 12,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Left,
}, dashboardCard)

--========================================================
-- CLIENT PLAYER ACTIONS (TELEPORT / FLING)
--========================================================

local playerCard = createSection(playerPage, "PLAYER // MANAGEMENT", 160)
local targetInput = makeInput(playerCard, "Enter Roblox Username...", 0, 39, 1, 36, "")

local function findTarget(username)
	if not username or username == "" then return nil end
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Name:lower():find(username:lower()) then return p end
	end
	return nil
end

makeButton(playerCard, "TELEPORT TO TARGET", 0, 88, 0.32, 40, function()
	local target = findTarget(targetInput.Text)
	if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
		if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
			LP.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
			setStatus("TELEPORTED TO " .. target.Name, C.GREEN)
		end
	else
		setStatus("TARGET NOT FOUND", C.RED)
	end
end)

makeButton(playerCard, "FLING TARGET (LOCAL)", 0.34, 88, 0.32, 40, function()
	local target = findTarget(targetInput.Text)
	if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
		local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
		if root then
			root.AssemblyLinearVelocity = Vector3.new(99999, 99999, 99999)
			setStatus("FLINGING " .. target.Name, C.YELLOW)
		end
	else
		setStatus("TARGET NOT FOUND", C.RED)
	end
end)

makeButton(playerCard, "BRING TARGET", 0.68, 88, 0.32, 40, function()
	setStatus("CLIENT CANNOT BRING TARGET", C.RED)
end)

--========================================================
-- MOVEMENT ENGINE (FLY / SPEED / NOCLIP / INVISIBLE)
--========================================================

local movementCard = createSection(movementPage, "MOVEMENT // CAMERA FLY / SPEED / NOCLIP", 365)

_, setJumpState = makeToggle(movementCard, "INFINITE JUMP", 42, function(s) infiniteJump = s end)

local walkInput = makeInput(movementCard, "Walk speed", 0, 91, 0.62, 36, "32")
makeButton(movementCard, "APPLY WALK SPEED", 0.65, 91, 0.35, 36, function()
	local speed = tonumber(walkInput.Text)
	if speed and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
		LP.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = speed
		setStatus("WALK SPEED: " .. speed, C.GREEN)
	end
end)

local flyInput = makeInput(movementCard, "Fly speed", 0, 141, 0.62, 36, "80")
makeButton(movementCard, "APPLY FLY SPEED", 0.65, 141, 0.35, 36, function()
	local speed = tonumber(flyInput.Text)
	if speed then flySpeed = speed setStatus("FLY SPEED: " .. speed, C.GREEN) end
end)

-- FLY ENGINE
local flyAttachment, flyVelocity, flyOrientation, flyConnection

local function cleanupFly()
	if flyConnection then pcall(function() flyConnection:Disconnect() end) flyConnection = nil end
	for _, o in ipairs({flyVelocity, flyOrientation, flyAttachment}) do if o then pcall(function() o:Destroy() end) end end
	flyVelocity, flyOrientation, flyAttachment = nil, nil, nil
	if LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
		LP.Character:FindFirstChildOfClass("Humanoid").PlatformStand = false
	end
end

local function setupFly()
	cleanupFly()
	local char = LP.Character
	if not char then return false end
	local root = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not root or not hum then return false end

	hum.PlatformStand = true
	flyAttachment = Instance.new("Attachment", root)
	flyVelocity = Instance.new("LinearVelocity", root)
	flyVelocity.Attachment0 = flyAttachment
	flyVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
	flyVelocity.MaxForce = 100000000

	flyOrientation = Instance.new("AlignOrientation", root)
	flyOrientation.Attachment0 = flyAttachment
	flyOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	flyOrientation.Responsiveness = 200
	flyOrientation.MaxTorque = 100000000

	flyConnection = RunService.PreSimulation:Connect(function()
		if not flyEnabled or not root.Parent then return end
		local cam = workspace.CurrentCamera
		if not cam then return end

		local move = Vector3.zero
		if not UIS:GetFocusedTextBox() then
			if UIS:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.yAxis end
			if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.yAxis end
		end

		if move.Magnitude > 1 then move = move.Unit end
		flyVelocity.VectorVelocity = move * flySpeed
		flyOrientation.CFrame = cam.CFrame
	end)
	return true
end

_, setFlyState = makeToggle(movementCard, "CAMERA FLY", 191, function(s)
	flyEnabled = s
	if s then setupFly() else cleanupFly() end
end)

-- NOCLIP
local noclipConnection
_, setNoclipState = makeToggle(movementCard, "NOCLIP / 穿墙", 241, function(s)
	noclipEnabled = s
	if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
	if s then
		noclipConnection = RunService.Stepped:Connect(function()
			if LP.Character then
				for _, part in ipairs(LP.Character:GetDescendants()) do
					if part:IsA("BasePart") then part.CanCollide = false end
				end
			end
		end)
	end
end)

-- INVISIBILITY (CLIENT LOCAL)
_, setInvisibleState = makeToggle(movementCard, "INVISIBILITY / 隐身", 291, function(s)
	invisibleEnabled = s
	if LP.Character then
		for _, part in ipairs(LP.Character:GetDescendants()) do
			if part:IsA("BasePart") or part:IsA("Decal") then
				part.Transparency = s and 1 or 0
			end
		end
	end
end)

-- INFINITE JUMP EVENT
UIS.JumpRequest:Connect(function()
	if infiniteJump and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
		LP.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

--========================================================
-- ESP SYSTEM
--========================================================

local espCard = createSection(espPage, "ESP // VISUAL SYSTEM", 145)
local espObjects = {}

local function removeESP(p)
	if espObjects[p] then
		pcall(function() espObjects[p]:Destroy() end)
		espObjects[p] = nil
	end
end

local function createESP(p)
	if not espEnabled or p == LP or not p.Character then return end
	removeESP(p)
	local highlight = Instance.new("Highlight")
	highlight.Name = "EV03_Highlight"
	highlight.Adornee = p.Character
	highlight.FillColor = C.RED
	highlight.OutlineColor = C.WHITE
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = p.Character
	espObjects[p] = highlight
end

_, setESPState = makeToggle(espCard, "PLAYER ESP", 42, function(s)
	espEnabled = s
	if not s then
		for p in pairs(espObjects) do removeESP(p) end
	else
		for _, p in ipairs(Players:GetPlayers()) do createESP(p) end
	end
end)

Players.PlayerAdded:Connect(function(p)
	p.CharacterAdded:Connect(function() task.wait(0.5) createESP(p) end)
end)

--========================================================
-- HOTKEYS & ABOUT
--========================================================

local hotkeyCard = createSection(hotkeyPage, "HOTKEYS // 快捷键控制", 200)
makeButton(hotkeyCard, "TOGGLE MENU (RIGHT SHIFT)", 0, 40, 1, 38, function()
	gui.Enabled = not gui.Enabled
end)

makeButton(hotkeyCard, "PANIC // DISABLE ALL", 0, 90, 1, 38, function()
	setFlyState(false)
	setNoclipState(false)
	setESPState(false)
	setInvisibleState(false)
	setJumpState(false)
	setStatus("PANIC ACTIVATED", C.RED)
end)

local aboutCard = createSection(aboutPage, "ABOUT // 身份组", 200)
create("TextLabel", {
	Size = UDim2.new(1, -20, 1, -40),
	Position = UDim2.fromOffset(10, 35),
	BackgroundTransparency = 1,
	Text = "PROJECT: EV03 CONTROL V3.7\nCREATOR: 阿叶ev03\nSTATUS: EXECUTOR STANDALONE",
	TextColor3 = C.WHITE,
	TextSize = 12,
	Font = Enum.Font.Code,
	TextXAlignment = Enum.TextXAlignment.Left,
}, aboutCard)

-- DRAG
local dragging, dragStart, startPos
dragArea.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true dragStart = input.Position startPos = main.Position
	end
end)
UIS.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)
UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

minimizeButton.MouseButton1Click:Connect(function()
	body.Visible = not body.Visible
	footer.Visible = not footer.Visible
	main.Size = body.Visible and UDim2.fromOffset(windowWidth, windowHeight) or UDim2.fromOffset(windowWidth, 58)
end)

closeButton.MouseButton1Click:Connect(function() gui.Enabled = false end)

UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.RightShift then gui.Enabled = not gui.Enabled end
	if input.KeyCode == Enum.KeyCode.F then setFlyState(not flyEnabled) end
	if input.KeyCode == Enum.KeyCode.N then setNoclipState(not noclipEnabled) end
end)

setStatus("EV03 EXECUTOR V3.7 READY", C.GREEN)
