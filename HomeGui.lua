--==================================================
-- HomeGui.lua (UPDATED with Event Integration)
-- Modular Ready | Delta Mobile Safe
--==================================================

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Require EventModule
local EventModule = _G.EventModule or require(game:GetService("ReplicatedStorage"):FindFirstChild("EventModule")) -- fallback

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
main.Size = UDim2.new(0, 420, 0, 330)
main.Position = UDim2.new(0.05, 0, 0.2, 0)
main.BackgroundColor3 = Color3.fromRGB(80,45,120)
main.BackgroundTransparency = 0.15
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,12)

-- Header
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

-- Minimize
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

-- Left Panel
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

-- Right Panel
local right = Instance.new("Frame", main)
right.Position = UDim2.new(0,140,0,46)
right.Size = UDim2.new(1,-150,1,-56)
right.BackgroundColor3 = Color3.fromRGB(40,20,70)
right.BackgroundTransparency = 0.15
right.BorderSizePixel = 0
Instance.new("UICorner", right).CornerRadius = UDim.new(0,12)

-- UTIL
local function clearRight()
    for _,v in ipairs(right:GetChildren()) do
        if not v:IsA("UICorner") then
            v:Destroy()
        end
    end
end

--========================
-- ESP TAB
--========================
local espEnabled = false
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
espBtn.MouseButton1Click:Connect(function()
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

    local function update()
        toggle.Text = espEnabled and "ESP : ON" or "ESP : OFF"
        toggle.BackgroundColor3 = espEnabled and Color3.fromRGB(0,180,120) or Color3.fromRGB(120,70,180)
    end
    update()

    toggle.MouseButton1Click:Connect(function()
        espEnabled = not espEnabled
        update()
        if _G.ToggleESP then
            _G.ToggleESP(espEnabled) 
        end
    end)
end)


--========================
-- AIM ASSIST TAB
--========================
local aimEnabled = false
local aimBtn = Instance.new("TextButton", left)
aimBtn.Size = UDim2.new(0.9,0,0,36)
aimBtn.Text = "Aim Assist"
aimBtn.Font = Enum.Font.SourceSans
aimBtn.TextSize = 15
aimBtn.TextColor3 = Color3.new(1,1,1)
aimBtn.BackgroundColor3 = Color3.fromRGB(120,70,180)
aimBtn.BackgroundTransparency = 0.15
aimBtn.BorderSizePixel = 0
Instance.new("UICorner", aimBtn).CornerRadius = UDim.new(0,8)
aimBtn.MouseButton1Click:Connect(function()
    clearRight()
    local label = Instance.new("TextLabel", right)
    label.Size = UDim2.new(1,-20,0,30)
    label.Position = UDim2.new(0,10,0,10)
    label.BackgroundTransparency = 1
    label.Text = "AIM ASSIST"
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

    local function update()
        toggle.Text = aimEnabled and "Aim Assist : ON" or "Aim Assist : OFF"
        toggle.BackgroundColor3 = aimEnabled and Color3.fromRGB(0,180,120) or Color3.fromRGB(120,70,180)
    end
    update()

    toggle.MouseButton1Click:Connect(function()
        aimEnabled = not aimEnabled
        update()
        if _G.ToggleAimAssist then
            _G.ToggleAimAssist(aimEnabled)
        end
    end)
end)


--========================
-- EVENT TAB
--========================
local eventEnabled = false
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

eventBtn.MouseButton1Click:Connect(function()
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

    local function update()
        toggle.Text = eventEnabled and "Event : ON" or "Event : OFF"
        toggle.BackgroundColor3 = eventEnabled and Color3.fromRGB(0,180,120) or Color3.fromRGB(120,70,180)
    end
    update()

    toggle.MouseButton1Click:Connect(function()
        eventEnabled = not eventEnabled
        update()
        if EventModule and EventModule.Enable then
            EventModule.Enable(eventEnabled)
        end
        -- Teleport buttons
        clearRight()
        local t1 = Instance.new("TextButton", right)
        t1.Size = UDim2.new(0,220,0,36)
        t1.Position = UDim2.new(0,10,0,120)
        t1.Font = Enum.Font.SourceSans
        t1.TextSize = 14
        t1.TextColor3 = Color3.new(1,1,1)
        t1.BorderSizePixel = 0
        Instance.new("UICorner", t1).CornerRadius = UDim.new(0,8)
        t1.Text = "Go To Nearest Gift"
        t1.BackgroundColor3 = Color3.fromRGB(90,180,120)
        t1.MouseButton1Click:Connect(function()
            if EventModule and EventModule.TeleportToNearestGift then
                EventModule.TeleportToNearestGift()
            end
        end)

        local t2 = Instance.new("TextButton", right)
        t2.Size = UDim2.new(0,220,0,36)
        t2.Position = UDim2.new(0,10,0,170)
        t2.Font = Enum.Font.SourceSans
        t2.TextSize = 14
        t2.TextColor3 = Color3.new(1,1,1)
        t2.BorderSizePixel = 0
        Instance.new("UICorner", t2).CornerRadius = UDim.new(0,8)
        t2.Text = "Go To Christmas Tree"
        t2.BackgroundColor3 = Color3.fromRGB(90,120,180)
        t2.MouseButton1Click:Connect(function()
            if EventModule and EventModule.TeleportToTree then
                EventModule.TeleportToTree()
            end
        end)
    end)
end)

-- Existing floating button logic ...
-- (keep as-is — no changes required)
