--========================================================
-- EV03 STANDALONE SAFE CLIENT TEMPLATE
-- Creator: 阿叶ev03
-- Execution Target: Third-Party Executors (Xeno, etc.)
--========================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui", 10)
if not PG then
    warn("[EV03] PlayerGui not found, script aborted.")
    return
end

--========================================================
-- 1. 安全防闪退 UI 渲染与兜底清理
--========================================================
local GUI_NAME = "EV03_STANDALONE_UI"

pcall(function()
    local old = PG:FindFirstChild(GUI_NAME)
    if old then old:Destroy() end
end)

local gui = Instance.new("ScreenGui")
gui.Name = GUI_NAME
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local success, err = pcall(function()
    gui.Parent = PG
end)

if not success then
    warn("[EV03] Failed to parent ScreenGui: ", err)
    return
end

--========================================================
-- 2. 纯客户端核心逻辑实现（不依赖任何服务端 Remote）
--========================================================

-- 安全获取角色及核心部件
local function getLocalCharacterParts()
    local char = LP.Character
    if not char then return nil, nil, nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root or hum.Health <= 0 then return nil, nil, nil end
    return char, hum, root
end

-- 纯客户端穿墙 (Noclip) 核心逻辑
local noclipActive = false
RunService.Stepped:Connect(function()
    if not noclipActive then return end
    pcall(function()
        local char = LP.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end)

-- 纯客户端隐身 (Invisible) 本地透明度修改
local invisibleActive = false
local function setLocalInvisible(state)
    invisibleActive = state
    pcall(function()
        local char = LP.Character
        if not char then return end
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("Decal") then
                obj.Transparency = state and 1 or 0
            end
        end
    end)
end

-- 纯客户端物理甩飞 (Fling) 兜底实现
local function localFlingTarget(targetName)
    pcall(function()
        local targetPlayer = Players:FindFirstChild(targetName)
        if not targetPlayer or targetPlayer == LP then return end
        
        local _, _, root = getLocalCharacterParts()
        local _, targetHum, targetRoot = nil, nil, nil
        
        if targetPlayer.Character then
            targetHum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
            targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        end
        
        if root and targetRoot and targetHum then
            targetHum:ChangeState(Enum.HumanoidStateType.Freefall)
            pcall(function() targetRoot:SetNetworkOwner(LP) end)
            
            local direction = (targetRoot.Position - root.Position).Unit
            targetRoot.AssemblyLinearVelocity = direction * 80 + Vector3.new(0, 120, 0)
            
            task.delay(1.5, function()
                pcall(function()
                    targetRoot:SetNetworkOwnershipAuto()
                end)
            end)
        end
    end)
end

--========================================================
-- 3. UI 交互与主面板构建 (带 pcall 保护)
--========================================================
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.fromOffset(400, 300)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true -- 简易自带拖动
mainFrame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "EV03 STANDALONE EDITION"
titleLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = mainFrame

-- 示例：Noclip 切换按钮
local noclipBtn = Instance.new("TextButton")
noclipBtn.Size = UDim2.fromOffset(160, 35)
noclipBtn.Position = UDim2.fromOffset(20, 60)
noclipBtn.Text = "NOCLIP: OFF"
noclipBtn.BackgroundColor3 = Color3.fromRGB(100, 20, 20)
noclipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
noclipBtn.Font = Enum.Font.GothamBold
noclipBtn.TextSize = 12
noclipBtn.Parent = mainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = noclipBtn

noclipBtn.MouseButton1Click:Connect(function()
    pcall(function()
        noclipActive = not noclipActive
        noclipBtn.Text = "NOCLIP: " .. (noclipActive and "ON" or "OFF")
        noclipBtn.BackgroundColor3 = noclipActive and Color3.fromRGB(25, 150, 75) or Color3.fromRGB(100, 20, 20)
    end)
end)

-- 菜单隐藏热键 (RightShift)
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        pcall(function()
            gui.Enabled = not gui.Enabled
        end)
    end
end)

print("[EV03] Standalone client script successfully loaded without server dependencies.")
