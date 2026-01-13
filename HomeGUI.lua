--==================================================
-- Purple Feature Panel GUI (Template Only)
-- Delta Executor Mobile Compatible
-- GUI + Minimize System
--==================================================

local Players = game:GetService("Players")
local player = Players.LocalPlayer

--========================
-- ScreenGui
--========================
local gui = Instance.new("ScreenGui")
gui.Name = "PurpleFeatureGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

--========================
-- Main Frame
--========================
local main = Instance.new("Frame", gui)
main.Name = "MainFrame"
main.Size = UDim2.new(0, 420, 0, 280)
main.Position = UDim2.new(0.05, 0, 0.25, 0)
main.BackgroundColor3 = Color3.fromRGB(80, 45, 120)
main.BackgroundTransparency = 0.15
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Visible = true

-- Corner
local mainCorner = Instance.new("UICorner", main)
mainCorner.CornerRadius = UDim.new(0, 12)

--========================
-- Header
--========================
local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 36)
header.BackgroundColor3 = Color3.fromRGB(120, 70, 180)
header.BackgroundTransparency = 0.1
header.BorderSizePixel = 0

local headerCorner = Instance.new("UICorner", header)
headerCorner.CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "FEATURE PANEL"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.TextColor3 = Color3.new(1,1,1)
title.TextXAlignment = Left

-- Minimize Button
local minimize = Instance.new("TextButton", header)
minimize.Size = UDim2.new(0, 28, 0, 28)
minimize.Position = UDim2.new(1, -34, 0, 4)
minimize.BackgroundColor3 = Color3.fromRGB(160, 110, 220)
minimize.Text = "–"
minimize.Font = Enum.Font.SourceSansBold
minimize.TextSize = 22
minimize.TextColor3 = Color3.new(1,1,1)
minimize.BorderSizePixel = 0

local minCorner = Instance.new("UICorner", minimize)
minCorner.CornerRadius = UDim.new(1, 0)

--========================
-- Left Panel (Menu)
--========================
local left = Instance.new("Frame", main)
left.Position = UDim2.new(0, 0, 0, 36)
left.Size = UDim2.new(0, 130, 1, -36)
left.BackgroundColor3 = Color3.fromRGB(60, 30, 100)
left.BackgroundTransparency = 0.1
left.BorderSizePixel = 0

local leftCorner = Instance.new("UICorner", left)
leftCorner.CornerRadius = UDim.new(0, 12)

local list = Instance.new("UIListLayout", left)
list.Padding = UDim.new(0, 8)
list.HorizontalAlignment = Center

local pad = Instance.new("UIPadding", left)
pad.PaddingTop = UDim.new(0, 12)

local function menuButton(text)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.9, 0, 0, 36)
    b.BackgroundColor3 = Color3.fromRGB(120, 70, 180)
    b.BackgroundTransparency = 0.15
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.SourceSans
    b.TextSize = 15
    b.BorderSizePixel = 0
    local c = Instance.new("UICorner", b)
    c.CornerRadius = UDim.new(0, 8)
    b.Parent = left
end

menuButton("Perk Config")
menuButton("Weapon Mods")
menuButton("ESP Options")
menuButton("Settings")

--========================
-- Right Panel (Content)
--========================
local right = Instance.new("Frame", main)
right.Position = UDim2.new(0, 140, 0, 46)
right.Size = UDim2.new(1, -150, 1, -56)
right.BackgroundColor3 = Color3.fromRGB(40, 20, 70)
right.BackgroundTransparency = 0.15
right.BorderSizePixel = 0

local rightCorner = Instance.new("UICorner", right)
rightCorner.CornerRadius = UDim.new(0, 12)

local contentTitle = Instance.new("TextLabel", right)
contentTitle.Size = UDim2.new(1, -20, 0, 32)
contentTitle.Position = UDim2.new(0, 10, 0, 10)
contentTitle.BackgroundTransparency = 1
contentTitle.Text = "SELECT FEATURE"
contentTitle.Font = Enum.Font.SourceSansBold
contentTitle.TextSize = 16
contentTitle.TextColor3 = Color3.new(1,1,1)

local hint = Instance.new("TextLabel", right)
hint.Size = UDim2.new(1, -20, 0, 40)
hint.Position = UDim2.new(0, 10, 0, 60)
hint.BackgroundTransparency = 1
hint.TextWrapped = true
hint.Text = "Feature controls will appear here."
hint.Font = Enum.Font.SourceSans
hint.TextSize = 14
hint.TextColor3 = Color3.fromRGB(200,200,200)

--========================
-- Floating Button (Minimized)
--========================
local floatBtn = Instance.new("TextButton", gui)
floatBtn.Size = UDim2.new(0, 52, 0, 52)
floatBtn.Position = UDim2.new(0.05, 0, 0.6, 0)
floatBtn.BackgroundColor3 = Color3.fromRGB(150, 90, 220)
floatBtn.BackgroundTransparency = 0.1
floatBtn.Text = "FX"
floatBtn.Font = Enum.Font.SourceSansBold
floatBtn.TextSize = 18
floatBtn.TextColor3 = Color3.new(1,1,1)
floatBtn.BorderSizePixel = 0
floatBtn.Visible = false
floatBtn.Active = true
floatBtn.Draggable = true

local floatCorner = Instance.new("UICorner", floatBtn)
floatCorner.CornerRadius = UDim.new(1, 0)

--========================
-- Minimize Logic
--========================
minimize.MouseButton1Click:Connect(function()
    main.Visible = false
    floatBtn.Visible = true
end)

floatBtn.MouseButton1Click:Connect(function()
    floatBtn.Visible = false
    main.Visible = true
end)
