--==================================================
-- HomeGui.lua (FINAL CLEAN)
-- Touch Safe | Floating Button | Delta Mobile
--==================================================

--========================
-- SERVICES & PLAYER
--========================
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

--========================
-- REMOVE OLD GUI
--========================
local old = PlayerGui:FindFirstChild("HomeGui")
if old then old:Destroy() end

--========================
-- MODULE HOOKS (GLOBAL)
--========================
local EventModule     = _G.EventModule
local ToggleESP       = _G.ToggleESP
local ToggleAimAssist = _G.ToggleAimAssist

--========================
-- SCREEN GUI
--========================
local gui = Instance.new("ScreenGui")
gui.Name = "HomeGui"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

--========================
-- MAIN PANEL
--========================
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,420,0,330)
main.Position = UDim2.new(0.5,-210,0.5,-165)
main.BackgroundColor3 = Color3.fromRGB(80,45,130)
main.BackgroundTransparency = 0.15
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.ZIndex = 50
Instance.new("UICorner", main).CornerRadius = UDim.new(0,14)

--========================
-- HEADER
--========================
local header = Instance.new("Frame", main)
header.Size = UDim2.new(1,0,0,40)
header.BackgroundColor3 = Color3.fromRGB(130,80,190)
header.BackgroundTransparency = 0.1
header.BorderSizePixel = 0
header.Active = false
Instance.new("UICorner", header).CornerRadius = UDim.new(0,14)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1,-60,1,0)
title.Position = UDim2.new(0,12,0,0)
title.BackgroundTransparency = 1
title.Text = "RiiHUB PANEL"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.TextColor3 = Color3.new(1,1,1)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Active = false

--========================
-- MINIMIZE BUTTON
--========================
local minimized = false

local minBtn = Instance.new("TextButton", header)
minBtn.Size = UDim2.new(0,30,0,30)
minBtn.Position = UDim2.new(1,-38,0,5)
minBtn.Text = "–"
minBtn.Font = Enum.Font.SourceSansBold
minBtn.TextSize = 22
minBtn.TextColor3 = Color3.new(1,1,1)
minBtn.BackgroundColor3 = Color3.fromRGB(180,120,230)
minBtn.BorderSizePixel = 0
minBtn.Active = true
minBtn.AutoButtonColor = true
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(1,0)

--========================
-- FLOATING BUTTON
--========================
local floatBtn = Instance.new("TextButton", gui)
floatBtn.Size = UDim2.new(0,54,0,54)
floatBtn.Position = UDim2.new(0.05,0,0.4,0)
floatBtn.Text = "RH"
floatBtn.Font = Enum.Font.SourceSansBold
floatBtn.TextSize = 18
floatBtn.TextColor3 = Color3.new(1,1,1)
floatBtn.BackgroundColor3 = Color3.fromRGB(150,90,210)
floatBtn.BorderSizePixel = 0
floatBtn.Visible = false
floatBtn.Active = true
floatBtn.Draggable = true
floatBtn.ZIndex = 60
Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(1,0)

--========================
-- CONTENT PANELS
--========================
local left = Instance.new("Frame", main)
left.Position = UDim2.new(0,0,0,40)
left.Size = UDim2.new(0,130,1,-40)
left.BackgroundColor3 = Color3.fromRGB(60,30,100)
left.BackgroundTransparency = 0.15
left.BorderSizePixel = 0
left.Active = false
Instance.new("UICorner", left).CornerRadius = UDim.new(0,14)

local right = Instance.new("Frame", main)
right.Position = UDim2.new(0,140,0,50)
right.Size = UDim2.new(1,-150,1,-60)
right.BackgroundColor3 = Color3.fromRGB(40,20,70)
right.BackgroundTransparency = 0.15
right.BorderSizePixel = 0
right.Active = false
Instance.new("UICorner", right).CornerRadius = UDim.new(0,14)

--========================
-- LEFT LIST
--========================
local list = Instance.new("UIListLayout", left)
list.Padding = UDim.new(0,8)
list.HorizontalAlignment = Enum.HorizontalAlignment.Center
Instance.new("UIPadding", left).PaddingTop = UDim.new(0,12)

--========================
-- UTILITIES
--========================
local function clearRight()
    for _,v in ipairs(right:GetChildren()) do
        if not v:IsA("UICorner") then
            v:Destroy()
        end
    end
end

local function createButton(parent, text, y)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0.9,0,0,36)
    b.Position = y and UDim2.new(0.05,0,0,y) or UDim2.new()
    b.Text = text
    b.Font = Enum.Font.SourceSans
    b.TextSize = 15
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(120,70,180)
    b.BackgroundTransparency = 0.15
    b.BorderSizePixel = 0
    b.Active = true
    b.AutoButtonColor = true
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    return b
end

--========================
-- LEFT TABS
--========================
local espBtn   = createButton(left, "ESP")
local aimBtn   = createButton(left, "Survivor")
local eventBtn = createButton(left, "Event")

--========================
-- ESP TAB
--========================
local espOn = false
espBtn.MouseButton1Click:Connect(function()
    clearRight()
    local t = createButton(right, "ESP : OFF", 20)
    local function u()
        t.Text = espOn and "ESP : ON" or "ESP : OFF"
        t.BackgroundColor3 = espOn and Color3.fromRGB(0,180,120) or Color3.fromRGB(120,70,180)
    end
    u()
    t.MouseButton1Click:Connect(function()
        espOn = not espOn
        u()
        if ToggleESP then ToggleESP(espOn) end
    end)
end)

--========================
-- AIM TAB
--========================
local aimOn = false
aimBtn.MouseButton1Click:Connect(function()
    clearRight()
    local t = createButton(right, "Aim Assist : OFF", 20)
    local function u()
        t.Text = aimOn and "Aim Assist : ON" or "Aim Assist : OFF"
        t.BackgroundColor3 = aimOn and Color3.fromRGB(0,180,120) or Color3.fromRGB(120,70,180)
    end
    u()
    t.MouseButton1Click:Connect(function()
        aimOn = not aimOn
        u()
        if ToggleAimAssist then ToggleAimAssist(aimOn) end
    end)
end)

--========================
-- EVENT TAB
--========================
local eventOn = false
eventBtn.MouseButton1Click:Connect(function()
    clearRight()

    local t = createButton(right, "Event : OFF", 20)
    local g = createButton(right, "Go To Nearest Gift", 70)
    local c = createButton(right, "Go To Christmas Tree", 120)

    g.BackgroundColor3 = Color3.fromRGB(90,180,120)
    c.BackgroundColor3 = Color3.fromRGB(90,120,180)

    local function u()
        t.Text = eventOn and "Event : ON" or "Event : OFF"
        t.BackgroundColor3 = eventOn and Color3.fromRGB(0,180,120) or Color3.fromRGB(120,70,180)
    end
    u()

    t.MouseButton1Click:Connect(function()
        eventOn = not eventOn
        u()
        if EventModule and EventModule.Enable then
            EventModule.Enable(eventOn)
        end
    end)

    g.MouseButton1Click:Connect(function()
        if EventModule and EventModule.TeleportToNearestGift then
            EventModule.TeleportToNearestGift()
        end
    end)

    c.MouseButton1Click:Connect(function()
        if EventModule and EventModule.TeleportToTree then
            EventModule.TeleportToTree()
        end
    end)
end)

--========================
-- MINIMIZE / FLOAT LOGIC
--========================
minBtn.MouseButton1Click:Connect(function()
    minimized = true
    main.Visible = false
    floatBtn.Visible = true
end)

floatBtn.MouseButton1Click:Connect(function()
    minimized = false
    floatBtn.Visible = false
    main.Visible = true
end)

warn("[HOMEGUI] FINAL GUI READY")
