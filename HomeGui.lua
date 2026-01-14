--==================================================
-- HomeGui.lua
-- RiiHUB Main UI (with Floating Button)
--==================================================

local Players = game:GetService("Players")
local player = Players.LocalPlayer

--========================
-- GUI ROOT
--========================
local gui = Instance.new("ScreenGui")
gui.Name = "RiiHUB"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

--========================
-- FLOATING BUTTON
--========================
local floatBtn = Instance.new("TextButton")
floatBtn.Name = "RiiHUB_Float"
floatBtn.Parent = gui
floatBtn.Size = UDim2.new(0, 52, 0, 52)
floatBtn.Position = UDim2.new(0.02, 0, 0.5, 0)
floatBtn.BackgroundColor3 = Color3.fromRGB(120, 70, 180)
floatBtn.BorderSizePixel = 0
floatBtn.Text = "Rii"
floatBtn.Font = Enum.Font.GothamBold
floatBtn.TextSize = 20
floatBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
floatBtn.Visible = false
floatBtn.Active = true
floatBtn.Draggable = true

local floatCorner = Instance.new("UICorner", floatBtn)
floatCorner.CornerRadius = UDim.new(1, 0)

--========================
-- MAIN FRAME
--========================
local main = Instance.new("Frame", gui)
main.Size = UDim2.fromScale(0.6, 0.6)
main.Position = UDim2.fromScale(0.2, 0.2)
main.BackgroundColor3 = Color3.fromRGB(90, 40, 140)
main.BackgroundTransparency = 0.1
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true

local corner = Instance.new("UICorner", main)
corner.CornerRadius = UDim.new(0, 16)

--========================
-- TITLE BAR
--========================
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, -40, 0, 40)
title.Position = UDim2.new(0, 20, 0, 10)
title.Text = "RiiHUB PANEL"
title.TextColor3 = Color3.fromRGB(230,230,230)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextXAlignment = Enum.TextXAlignment.Left

-- Minimize Button
local minimize = Instance.new("TextButton", main)
minimize.Size = UDim2.new(0, 28, 0, 28)
minimize.Position = UDim2.new(1, -40, 0, 10)
minimize.Text = "–"
minimize.Font = Enum.Font.GothamBold
minimize.TextSize = 24
minimize.TextColor3 = Color3.fromRGB(230, 230, 230)
minimize.BackgroundColor3 = Color3.fromRGB(160, 110, 220)
minimize.BorderSizePixel = 0

local minCorner = Instance.new("UICorner", minimize)
minCorner.CornerRadius = UDim.new(1, 0)

--========================
-- LEFT / RIGHT PANELS
--========================
local left = Instance.new("Frame", main)
left.Size = UDim2.new(0.25, -10, 1, -70)
left.Position = UDim2.new(0, 10, 0, 60)
left.BackgroundTransparency = 1

local right = Instance.new("Frame", main)
right.Size = UDim2.new(0.75, -20, 1, -70)
right.Position = UDim2.new(0.25, 10, 0, 60)
right.BackgroundTransparency = 1

--========================
-- UI HELPERS
--========================
local function createButton(parent, text, height)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, height or 42)
    b.BackgroundColor3 = Color3.fromRGB(120,70,180)
    b.TextColor3 = Color3.fromRGB(230,230,230)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextScaled = true
    b.AutoButtonColor = true
    b.BorderSizePixel = 0
    b.Parent = parent

    local c = Instance.new("UICorner", b)
    c.CornerRadius = UDim.new(0, 12)

    return b
end

local function clearRight()
    for _,v in ipairs(right:GetChildren()) do
        v:Destroy()
    end
end

local function listLayout(parent, pad)
    local l = Instance.new("UIListLayout", parent)
    l.Padding = UDim.new(0, pad or 10)
    return l
end

listLayout(left, 12)
listLayout(right, 14)

--========================
-- TAB BUTTONS
--========================
local espTab = createButton(left, "ESP")
local survivorTab = createButton(left, "Survivor")
local eventTab = createButton(left, "Event")
local killerTab = createButton(left, "Killer")

--========================
-- TAB FUNCTIONS
--========================

espTab.MouseButton1Click:Connect(function()
    clearRight()
    createButton(right, "ESP Config (existing)", 44)
end)

survivorTab.MouseButton1Click:Connect(function()
    clearRight()
    createButton(right, "Survivor Features (existing)", 44)
end)

eventTab.MouseButton1Click:Connect(function()
    clearRight()
    createButton(right, "Event Features (existing)", 44)
end)

killerTab.MouseButton1Click:Connect(function()
    clearRight()

    -- Hitbox Assist
    local hitboxOn = false
    local hitboxBtn = createButton(right, "Hitbox Assist : OFF", 44)
    local function updateHitbox()
        hitboxBtn.Text = hitboxOn and "Hitbox Assist : ON" or "Hitbox Assist : OFF"
        hitboxBtn.BackgroundColor3 = hitboxOn and Color3.fromRGB(180,180,180) or Color3.fromRGB(120,70,180)
    end
    updateHitbox()
    hitboxBtn.MouseButton1Click:Connect(function()
        hitboxOn = not hitboxOn
        updateHitbox()
        if _G.KillerModule and _G.KillerModule.Enable then
            _G.KillerModule.Enable(hitboxOn)
        end
    end)

    -- Stalk Assist
    local stalkOn = false
    local stalkBtn = createButton(right, "Stalk Assist : OFF", 44)
    local function updateStalk()
        stalkBtn.Text = stalkOn and "Stalk Assist : ON" or "Stalk Assist : OFF"
        stalkBtn.BackgroundColor3 = stalkOn and Color3.fromRGB(200,200,200) or Color3.fromRGB(120,70,180)
    end
    updateStalk()
    stalkBtn.MouseButton1Click:Connect(function()
        stalkOn = not stalkOn
        updateStalk()
        if _G.StalkAssistModule and _G.StalkAssistModule.Enable then
            _G.StalkAssistModule.Enable(stalkOn)
        end
    end)
end)

--========================
-- MINIMIZE BEHAVIOR
--========================
minimize.MouseButton1Click:Connect(function()
    main.Visible = false
    floatBtn.Visible = true
end)

floatBtn.MouseButton1Click:Connect(function()
    main.Visible = true
    floatBtn.Visible = false
end)

warn("[RiiHUB] HomeGui loaded successfully")
