--==================================================
-- HomeGui.lua
-- Updated with ESP, Survivor, Event, Killer Tabs
-- Proper Tab Switch & Default Selected
--==================================================

local Players = game:GetService("Players")
local player = Players.LocalPlayer

--========================
-- ScreenGui
--========================
local gui = Instance.new("ScreenGui")
gui.Name = "HomeGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

--========================
-- Main Frame
--========================
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 420, 0, 280)
main.Position = UDim2.new(0.05, 0, 0.25, 0)
main.BackgroundColor3 = Color3.fromRGB(80,45,120)
main.BackgroundTransparency = 0.15
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,12)

--========================
-- Header
--========================
local header = Instance.new("Frame", main)
header.Size = UDim2.new(1,0,0,36)
header.BackgroundColor3 = Color3.fromRGB(120,70,180)
header.BackgroundTransparency = 0.1
header.BorderSizePixel = 0
Instance.new("UICorner", header).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1,-40,1,0)
title.Position = UDim2.new(0,10,0,0)
title.BackgroundTransparency = 1
title.Text = "FEATURE PANEL"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.TextColor3 = Color3.new(1,1,1)
title.TextXAlignment = Enum.TextXAlignment.Left

--========================
-- Minimize
--========================
local minimize = Instance.new("TextButton", header)
minimize.Size = UDim2.new(0,28,0,28)
minimize.Position = UDim2.new(1,-34,0,4)
minimize.Text = "–"
minimize.Font = Enum.Font.SourceSansBold
minimize.TextSize = 22
minimize.TextColor3 = Color3.new(1,1,1)
minimize.BackgroundColor3 = Color3.fromRGB(160,110,220)
minimize.BorderSizePixel = 0
Instance.new("UICorner", minimize).CornerRadius = UDim.new(1,0)

--========================
-- Left Panel
--========================
local left = Instance.new("Frame", main)
left.Position = UDim2.new(0,0,0,36)
left.Size = UDim2.new(0,130,1,-36)
left.BackgroundColor3 = Color3.fromRGB(60,30,100)
left.BackgroundTransparency = 0.1
left.BorderSizePixel = 0
Instance.new("UICorner", left).CornerRadius = UDim.new(0,12)

local list = Instance.new("UIListLayout", left)
list.Padding = UDim.new(0,8)
list.HorizontalAlignment = Enum.HorizontalAlignment.Center
Instance.new("UIPadding", left).PaddingTop = UDim.new(0,12)

--========================
-- Right Panel
--========================
local right = Instance.new("Frame", main)
right.Position = UDim2.new(0,140,0,46)
right.Size = UDim2.new(1,-150,1,-56)
right.BackgroundColor3 = Color3.fromRGB(40,20,70)
right.BackgroundTransparency = 0.15
right.BorderSizePixel = 0
Instance.new("UICorner", right).CornerRadius = UDim.new(0,12)

--========================
-- Tab System Logic
--========================

local function clearRight()
    for _,v in ipairs(right:GetChildren()) do
        if not v:IsA("UICorner") then
            v:Destroy()
        end
    end
end

local function selectESP()
    clearRight()
    local label = Instance.new("TextLabel", right)
    label.Size = UDim2.new(1,-20,0,30)
    label.Position = UDim2.new(0,10,0,10)
    label.BackgroundTransparency = 1
    label.Text = "ESP OPTIONS"
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 16
    label.TextColor3 = Color3.new(1,1,1)

    local toggle = Instance.new("TextButton", right)
    toggle.Size = UDim2.new(0,160,0,36)
    toggle.Position = UDim2.new(0,10,0,60)
    toggle.Font = Enum.Font.SourceSans
    toggle.TextSize = 14
    toggle.TextColor3 = Color3.new(1,1,1)
    toggle.BorderSizePixel = 0
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(0,8)

    local espEnabled = false
    local function update()
        toggle.Text = espEnabled and "ESP : ON" or "ESP : OFF"
        toggle.BackgroundColor3 = espEnabled
            and Color3.fromRGB(0,180,120)
            or Color3.fromRGB(120,70,180)
    end
    update()
    toggle.MouseButton1Click:Connect(function()
        espEnabled = not espEnabled
        update()
        if _G.ToggleESP then
            _G.ToggleESP(espEnabled)
        end
    end)
end

local function selectSurvivor()
    clearRight()
    local label = Instance.new("TextLabel", right)
    label.Size = UDim2.new(1,-20,0,30)
    label.Position = UDim2.new(0,10,0,10)
    label.BackgroundTransparency = 1
    label.Text = "SURVIVOR OPTIONS"
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 16
    label.TextColor3 = Color3.new(1,1,1)

    local toggle = Instance.new("TextButton", right)
    toggle.Size = UDim2.new(0,220,0,36)
    toggle.Position = UDim2.new(0,10,0,60)
    toggle.Font = Enum.Font.SourceSans
    toggle.TextSize = 14
    toggle.TextColor3 = Color3.new(1,1,1)
    toggle.BorderSizePixel = 0
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(0,8)

    local aimStatus = false
    local function update()
        toggle.Text = aimStatus and "Aim Assist : ON" or "Aim Assist : OFF"
        toggle.BackgroundColor3 = aimStatus
            and Color3.fromRGB(0,180,120)
            or Color3.fromRGB(120,70,180)
    end
    update()
    toggle.MouseButton1Click:Connect(function()
        aimStatus = not aimStatus
        update()
        if _G.ToggleAimAssist then
            _G.ToggleAimAssist(aimStatus)
        end
    end)
end

local function selectEvent()
    clearRight()
    local label = Instance.new("TextLabel", right)
    label.Size = UDim2.new(1,-20,0,30)
    label.Position = UDim2.new(0,10,0,10)
    label.BackgroundTransparency = 1
    label.Text = "EVENT - CHRISTMAS"
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 16
    label.TextColor3 = Color3.new(1,1,1)

    local toggle = Instance.new("TextButton", right)
    toggle.Size = UDim2.new(0,220,0,36)
    toggle.Position = UDim2.new(0,10,0,60)
    toggle.Font = Enum.Font.SourceSans
    toggle.TextSize = 14
    toggle.TextColor3 = Color3.new(1,1,1)
    toggle.BorderSizePixel = 0
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(0,8)

    local eventEnabled = false
    local function update()
        toggle.Text = eventEnabled and "Event Assist : ON" or "Event Assist : OFF"
        toggle.BackgroundColor3 = eventEnabled
            and Color3.fromRGB(0,180,120)
            or Color3.fromRGB(120,70,180)
    end
    update()
    toggle.MouseButton1Click:Connect(function()
        eventEnabled = not eventEnabled
        update()
        if _G.ToggleEvent then
            _G.ToggleEvent(eventEnabled)
        end
    end)
end

local function selectKiller()
    clearRight()
    -- Hitbox Assist Toggle
    local hitboxEnabled = false
    local hitboxBtn = Instance.new("TextButton", right)
    hitboxBtn.Size = UDim2.new(0,200,0,36)
    hitboxBtn.Position = UDim2.new(0,10,0,10)
    hitboxBtn.Font = Enum.Font.SourceSans
    hitboxBtn.TextSize = 14
    hitboxBtn.TextColor3 = Color3.new(1,1,1)
    hitboxBtn.BorderSizePixel = 0
    Instance.new("UICorner", hitboxBtn).CornerRadius = UDim.new(0,8)

    local function updateHitbox()
        hitboxBtn.Text = hitboxEnabled and "Hitbox Assist : ON" or "Hitbox Assist : OFF"
        hitboxBtn.BackgroundColor3 = hitboxEnabled
            and Color3.fromRGB(0,180,120)
            or Color3.fromRGB(120,70,180)
    end
    updateHitbox()
    hitboxBtn.MouseButton1Click:Connect(function()
        hitboxEnabled = not hitboxEnabled
        updateHitbox()
        if _G.KillerModule and _G.KillerModule.Enable then
            _G.KillerModule.Enable(hitboxEnabled)
        end
    end)

    -- Stalk Assist Toggle
    local stalkEnabled = false
    local stalkBtn = Instance.new("TextButton", right)
    stalkBtn.Size = UDim2.new(0,200,0,36)
    stalkBtn.Position = UDim2.new(0,10,0,60)
    stalkBtn.Font = Enum.Font.SourceSans
    stalkBtn.TextSize = 14
    stalkBtn.TextColor3 = Color3.new(1,1,1)
    stalkBtn.BorderSizePixel = 0
    Instance.new("UICorner", stalkBtn).CornerRadius = UDim.new(0,8)

    local function updateStalk()
        stalkBtn.Text = stalkEnabled and "Stalk Assist : ON" or "Stalk Assist : OFF"
        stalkBtn.BackgroundColor3 = stalkEnabled
            and Color3.fromRGB(0,180,120)
            or Color3.fromRGB(120,70,180)
    end
    updateStalk()
    stalkBtn.MouseButton1Click:Connect(function()
        stalkEnabled = not stalkEnabled
        updateStalk()
        if _G.StalkAssistModule and _G.StalkAssistModule.Enable then
            _G.StalkAssistModule.Enable(stalkEnabled)
        end
    end)
end

--========================
-- Tab Buttons in Left Panel
--========================
local espBtn = Instance.new("TextButton", left)
espBtn.Size = UDim2.new(0.9,0,0,36)
espBtn.Text = "ESP"
espBtn.Font = Enum.Font.SourceSans
espBtn.TextSize = 15
espBtn.TextColor3 = Color3.new(1,1,1)
espBtn.BackgroundColor3 = Color3.fromRGB(120,70,180)
espBtn.BackgroundTransparency = 0.15
espBtn.BorderSizePixel = 0
Instance.new("UICorner", espBtn).CornerRadius = UDim.new(0,8)
espBtn.MouseButton1Click:Connect(selectESP)

local survivorBtn = Instance.new("TextButton", left)
survivorBtn.Size = UDim2.new(0.9,0,0,36)
survivorBtn.Text = "Survivor"
survivorBtn.Font = Enum.Font.SourceSans
survivorBtn.TextSize = 15
survivorBtn.TextColor3 = Color3.new(1,1,1)
survivorBtn.BackgroundColor3 = Color3.fromRGB(120,70,180)
survivorBtn.BackgroundTransparency = 0.15
survivorBtn.BorderSizePixel = 0
Instance.new("UICorner", survivorBtn).CornerRadius = UDim.new(0,8)
survivorBtn.MouseButton1Click:Connect(selectSurvivor)

local eventBtn = Instance.new("TextButton", left)
eventBtn.Size = UDim2.new(0.9,0,0,36)
eventBtn.Text = "Event"
eventBtn.Font = Enum.Font.SourceSans
eventBtn.TextSize = 15
eventBtn.TextColor3 = Color3.new(1,1,1)
eventBtn.BackgroundColor3 = Color3.fromRGB(120,70,180)
eventBtn.BackgroundTransparency = 0.15
eventBtn.BorderSizePixel = 0
Instance.new("UICorner", eventBtn).CornerRadius = UDim.new(0,8)
eventBtn.MouseButton1Click:Connect(selectEvent)

local killerBtn = Instance.new("TextButton", left)
killerBtn.Size = UDim2.new(0.9,0,0,36)
killerBtn.Text = "Killer"
killerBtn.Font = Enum.Font.SourceSans
killerBtn.TextSize = 15
killerBtn.TextColor3 = Color3.new(1,1,1)
killerBtn.BackgroundColor3 = Color3.fromRGB(120,70,180)
killerBtn.BackgroundTransparency = 0.15
killerBtn.BorderSizePixel = 0
Instance.new("UICorner", killerBtn).CornerRadius = UDim.new(0,8)
killerBtn.MouseButton1Click:Connect(selectKiller)

--========================
-- Minimize Logic
--========================
minimize.MouseButton1Click:Connect(function()
    main.Visible = false
end)

--========================
-- DEFAULT TAB ON LOAD
--========================
selectESP()  -- default tab

--========================
-- GLOBAL EXPORT (if needed)
--========================
_G.FeatureUI = { RightPanel = right, LeftPanel = left }
