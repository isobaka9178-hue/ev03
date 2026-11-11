--==================================================
-- EV03 BODY FLING V4.1 / V4.2 STANDALONE EDITION
-- Creator: 阿叶ev03
-- Executor LocalScript (No Server Required)
--==================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui", 10)
if not PG then return end

--==================================================
-- CLEAN OLD GUI
--==================================================

local old = PG:FindFirstChild("EV03_BODY_FLING")
if old then old:Destroy() end

local RED = Color3.fromRGB(195, 30, 45)
local GREEN = Color3.fromRGB(25, 160, 75)
local BG = Color3.fromRGB(15, 15, 20)
local PANEL = Color3.fromRGB(30, 30, 38)
local WHITE = Color3.fromRGB(245, 245, 245)

local gui = Instance.new("ScreenGui")
gui.Name = "EV03_BODY_FLING"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = PG

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(440, 390)
main.Position = UDim2.new(0.5, -220, 0.5, -195)
main.BackgroundColor3 = BG
main.BorderSizePixel = 0
main.Active = true
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Color = RED
stroke.Thickness = 2
stroke.Parent = main

local function label(text, position, size, parent)
	local obj = Instance.new("TextLabel")
	obj.BackgroundTransparency = 1
	obj.Position = position
	obj.Size = size
	obj.Text = text
	obj.TextColor3 = WHITE
	obj.TextSize = 13
	obj.Font = Enum.Font.GothamBold
	obj.TextXAlignment = Enum.TextXAlignment.Left
	obj.Parent = parent
	return obj
end

local function button(text, position, size, parent, callback)
	local obj = Instance.new("TextButton")
	obj.Position = position
	obj.Size = size
	obj.Text = text
	obj.TextColor3 = WHITE
	obj.BackgroundColor3 = RED
	obj.TextSize = 13
	obj.Font = Enum.Font.GothamBold
	obj.BorderSizePixel = 0
	obj.Parent = parent

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 6)
	c.Parent = obj

	obj.MouseButton1Click:Connect(function()
		pcall(callback)
	end)
	return obj
end

local function input(placeholder, position, size, parent, default)
	local obj = Instance.new("TextBox")
	obj.Position = position
	obj.Size = size
	obj.Text = default or ""
	obj.PlaceholderText = placeholder
	obj.TextColor3 = WHITE
	obj.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
	obj.BackgroundColor3 = PANEL
	obj.TextSize = 13
	obj.Font = Enum.Font.Gotham
	obj.ClearTextOnFocus = false
	obj.BorderSizePixel = 0
	obj.Parent = parent

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 6)
	c.Parent = obj

	return obj
end

--==================================================
-- HEADER & DRAG
--==================================================

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 55)
header.BackgroundColor3 = PANEL
header.BorderSizePixel = 0
header.Parent = main

label(
	"EV03 BODY FLING V4.2 [STANDALONE]",
	UDim2.fromOffset(15, 5),
	UDim2.new(1, -30, 0, 28),
	header
)

label(
	"CREATOR: 阿叶ev03",
	UDim2.fromOffset(16, 32),
	UDim2.new(1, -30, 0, 15),
	header
)

local dragging = false
local dragStart
local startPos

header.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = i.Position
		startPos = main.Position
	end
end)

UIS.InputChanged:Connect(function(i)
	if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = i.Position - dragStart
		main.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

UIS.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

--==================================================
-- UI CONTROLS
--==================================================

label("TARGET USERNAME", UDim2.fromOffset(18, 75), UDim2.fromOffset(200, 25), main)
local targetInputBox = input("Example: ez", UDim2.fromOffset(18, 105), UDim2.fromOffset(400, 36), main)

label("FLING POWER (1 - 100)", UDim2.fromOffset(18, 151), UDim2.fromOffset(200, 25), main)
local powerInputBox = input("Power", UDim2.fromOffset(18, 181), UDim2.fromOffset(190, 36), main, "50")

label("RETURN POSITION", UDim2.fromOffset(18, 231), UDim2.fromOffset(200, 25), main)
local returnPosition = true

local returnButton = button(
	"RETURN POSITION: ON",
	UDim2.fromOffset(220, 226),
	UDim2.fromOffset(198, 36),
	main,
	function()
		returnPosition = not returnPosition
		returnButton.Text = "RETURN POSITION: " .. (returnPosition and "ON" or "OFF")
		returnButton.BackgroundColor3 = returnPosition and GREEN or RED
	end
)

local status = label("STATUS: READY", UDim2.fromOffset(18, 280), UDim2.fromOffset(400, 25), main)

local function setStatus(message, color)
	pcall(function()
		status.Text = "STATUS: " .. message
		status.TextColor3 = color or GREEN
	end)
end

--==================================================
-- LOCAL FLING LOGIC (CLIENT STANDALONE)
--==================================================

local function getCharacter(plr)
	if not plr or not plr.Character then return nil, nil, nil end
	local char = plr.Character
	local hum = char:FindFirstChildOfClass("Humanoid")
	local root = char:FindFirstChild("HumanoidRootPart")
	if not hum or not root or hum.Health <= 0 then return nil, nil, nil end
	return char, hum, root
end

local function findMatches(prefix)
	prefix = prefix:lower():match("^%s*(.-)%s*$")
	local matches = {}
	if prefix == "" then return matches end
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Name:lower():sub(1, #prefix) == prefix then
			table.insert(matches, player)
		end
	end
	return matches
end

local function flingTargetPlayer(targetPlayer, powerVal, shouldReturn)
	local char, hum, root = getCharacter(targetPlayer)
	if not char or not root then return false end

	local _, _, adminRoot = getCharacter(LP)
	if not adminRoot then return false end

	local originalCFrame = root.CFrame
	local direction = root.Position - adminRoot.Position
	if direction.Magnitude < 0.01 then
		direction = adminRoot.CFrame.LookVector
	else
		direction = direction.Unit
	end

	local power = math.clamp(tonumber(powerVal) or 50, 1, 100)

	pcall(function()
		root:SetNetworkOwner(LP)
	end)

	hum:ChangeState(Enum.HumanoidStateType.Freefall)

	local impulse = (direction * power + Vector3.new(0, power * 0.8, 0)) * root.AssemblyMass
	pcall(function()
		root:ApplyImpulse(impulse)
	end)

	task.delay(2, function()
		pcall(function()
			if targetPlayer.Parent == Players and targetPlayer.Character == char and root.Parent == char and hum.Health > 0 then
				if shouldReturn == true then
					root.CFrame = originalCFrame
					root.AssemblyLinearVelocity = Vector3.zero
					root.AssemblyAngularVelocity = Vector3.zero
					hum:ChangeState(Enum.HumanoidStateType.GettingUp)
				end
				root:SetNetworkOwnershipAuto()
			end
		end)
	end)

	return true
end

-- LOCK TARGET BUTTON
button(
	"LOCK TARGET",
	UDim2.fromOffset(18, 320),
	UDim2.fromOffset(190, 42),
	main,
	function()
		local matches = findMatches(targetInputBox.Text)
		if #matches == 0 then
			setStatus("PLAYER NOT FOUND", RED)
			return
		end
		if #matches > 1 then
			local names = {}
			for _, player in ipairs(matches) do
				table.insert(names, player.Name)
			end
			setStatus("MULTIPLE: " .. table.concat(names, ", "), Color3.fromRGB(220, 175, 55))
			return
		end
		targetInputBox.Text = matches[1].Name
		setStatus("LOCKED: " .. matches[1].Name, GREEN)
	end
)

-- FLING TARGET BUTTON
button(
	"FLING TARGET",
	UDim2.fromOffset(220, 320),
	UDim2.fromOffset(198, 42),
	main,
	function()
		local matches = findMatches(targetInputBox.Text)
		if #matches ~= 1 then
			setStatus("SELECT EXACTLY ONE PLAYER", RED)
			return
		end
		local amount = tonumber(powerInputBox.Text)
		if not amount then
			setStatus("INVALID POWER", RED)
			return
		end

		local success = flingTargetPlayer(matches[1], amount, returnPosition)
		if success then
			setStatus("FLING EXECUTED", GREEN)
		else
			setStatus("FLING FAILED", RED)
		end
	end
)

-- PANIC / CLOSE
button(
	"PANIC / CLOSE",
	UDim2.fromOffset(18, 370),
	UDim2.fromOffset(400, 12),
	main,
	function()
		pcall(function() gui:Destroy() end)
	end
)

-- MENU HOTKEY (RightShift)
UIS.InputBegan:Connect(function(i, processed)
	if processed then return end
	if i.KeyCode == Enum.KeyCode.RightShift then
		pcall(function()
			gui.Enabled = not gui.Enabled
		end)
	end
end)

print("[EV03] BODY FLING V4.2 STANDALONE CLIENT READY")
```[cite: 3, 4]
