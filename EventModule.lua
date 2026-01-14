--==================================================
-- EventModule.lua (DEBUG MODE - RAY FIXED)
-- Raycast ignores own avatar completely
--==================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--==================================================
-- DEBUG LOG (DELTA CONSOLE)
--==================================================
print("[EventModule][DEBUG] Script executed")
warn("[EventModule][DEBUG] Raycast ignores local avatar")

--==================================================
-- CLEAR OLD DEBUG GUI
--==================================================
pcall(function()
    local old = PlayerGui:FindFirstChild("EventModule_DEBUG_GUI")
    if old then old:Destroy() end
end)

--==================================================
-- ROOT GUI
--==================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EventModule_DEBUG_GUI"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 1000
ScreenGui.Parent = PlayerGui

--==================================================
-- TOP-LEFT INDICATOR
--==================================================
local Indicator = Instance.new("TextLabel")
Indicator.Size = UDim2.fromOffset(240, 30)
Indicator.Position = UDim2.fromOffset(10, 10)
Indicator.BackgroundColor3 = Color3.fromRGB(120, 60, 180)
Indicator.BackgroundTransparency = 0.2
Indicator.Text = "EventModule DEBUG ACTIVE"
Indicator.TextColor3 = Color3.new(1,1,1)
Indicator.Font = Enum.Font.GothamBold
Indicator.TextSize = 14
Indicator.Parent = ScreenGui
Instance.new("UICorner", Indicator)

--==================================================
-- CROSSHAIR (CENTER)
--==================================================
local Crosshair = Instance.new("Frame")
Crosshair.Size = UDim2.fromOffset(20, 20)
Crosshair.Position = UDim2.fromScale(0.5, 0.5)
Crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
Crosshair.BackgroundTransparency = 1
Crosshair.Parent = ScreenGui

local function drawLine(size, pos)
    local l = Instance.new("Frame")
    l.Size = size
    l.Position = pos
    l.BackgroundColor3 = Color3.fromRGB(200, 150, 255)
    l.BorderSizePixel = 0
    l.Parent = Crosshair
end

drawLine(UDim2.fromOffset(2, 20), UDim2.fromOffset(9, 0))
drawLine(UDim2.fromOffset(20, 2), UDim2.fromOffset(0, 9))

--==================================================
-- FLOATING BUTTON (DRAGGABLE)
--==================================================
local FloatBtn = Instance.new("TextButton")
FloatBtn.Size = UDim2.fromOffset(150, 44)
FloatBtn.Position = UDim2.fromScale(0.05, 0.7)
FloatBtn.Text = "GET DATA"
FloatBtn.Font = Enum.Font.GothamBold
FloatBtn.TextSize = 16
FloatBtn.TextColor3 = Color3.new(1,1,1)
FloatBtn.BackgroundColor3 = Color3.fromRGB(150, 90, 220)
FloatBtn.BackgroundTransparency = 0.15
FloatBtn.Parent = ScreenGui
Instance.new("UICorner", FloatBtn)

-- DRAG
do
    local dragging, startPos, dragStart
    FloatBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = FloatBtn.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            FloatBtn.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function()
        dragging = false
    end)
end

--==================================================
-- RAYCAST SCAN (IGNORE LOCAL AVATAR)
--==================================================
local function scanTarget()
    local cam = Workspace.CurrentCamera
    if not cam then
        warn("[EventModule][DEBUG] Camera not ready")
        return
    end

    local origin = cam.CFrame.Position
    local direction = cam.CFrame.LookVector * 500

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.IgnoreWater = true

    -- 🔴 PENTING: blacklist seluruh avatar
    if LocalPlayer.Character then
        params.FilterDescendantsInstances = { LocalPlayer.Character }
    end

    local result = Workspace:Raycast(origin, direction, params)

    if result then
        local inst = result.Instance
        print("====== EVENT DEBUG SCAN ======")
        print("Instance Name :", inst.Name)
        print("ClassName    :", inst.ClassName)
        print("Parent       :", inst.Parent and inst.Parent.Name)
        print("World Pos    :", inst.Position)
        local model = inst:FindFirstAncestorOfClass("Model")
        print("Model Root   :", model and model.Name)
        print("==============================")
    else
        warn("[EventModule][DEBUG] Raycast hit nothing")
    end
end

--==================================================
-- BUTTON CLICK
--==================================================
FloatBtn.MouseButton1Click:Connect(function()
    print("[EventModule][DEBUG] Scan requested")
    scanTarget()
end)
