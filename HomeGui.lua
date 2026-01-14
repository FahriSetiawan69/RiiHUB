--==================================================
-- HomeGui.lua
-- RiiHUB Main UI
--==================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

--========================
-- GUI ROOT
--========================
local gui = Instance.new("ScreenGui")
gui.Name = "RiiHUB"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

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
title.TextXAlignment = Left

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
-- TABS (LEFT)
--========================
local espTab      = createButton(left, "ESP")
local survivorTab = createButton(left, "Survivor")
local eventTab    = createButton(left, "Event")
local killerTab   = createButton(left, "Killer")

--========================
-- ESP TAB (TIDAK DIUBAH)
--========================
espTab.MouseButton1Click:Connect(function()
    clearRight()
    createButton(right, "ESP Config (existing)", 44)
end)

--========================
-- SURVIVOR TAB (TIDAK DIUBAH)
--========================
survivorTab.MouseButton1Click:Connect(function()
    clearRight()
    createButton(right, "Survivor Features (existing)", 44)
end)

--========================
-- EVENT TAB (TIDAK DIUBAH)
--========================
eventTab.MouseButton1Click:Connect(function()
    clearRight()
    createButton(right, "Event Features (existing)", 44)
end)

--==================================================
-- KILLER TAB (BARU)
--==================================================
killerTab.MouseButton1Click:Connect(function()
    clearRight()

    --======== HITBOX ASSIST CUBE ========
    local hitboxOn = false
    local hitboxBtn = createButton(right, "Hitbox Assist : OFF", 44)

    local function updateHitbox()
        hitboxBtn.Text = hitboxOn and "Hitbox Assist : ON" or "Hitbox Assist : OFF"
        hitboxBtn.BackgroundColor3 =
            hitboxOn and Color3.fromRGB(180,180,180)
            or Color3.fromRGB(120,70,180)
    end
    updateHitbox()

    hitboxBtn.MouseButton1Click:Connect(function()
        hitboxOn = not hitboxOn
        updateHitbox()
        if _G.KillerModule and _G.KillerModule.Enable then
            _G.KillerModule.Enable(hitboxOn)
        end
    end)

    --======== STALK ASSIST MEYERS ========
    local stalkOn = false
    local stalkBtn = createButton(right, "Stalk Assist : OFF", 44)

    local function updateStalk()
        stalkBtn.Text = stalkOn and "Stalk Assist : ON" or "Stalk Assist : OFF"
        stalkBtn.BackgroundColor3 =
            stalkOn and Color3.fromRGB(200,200,200)
            or Color3.fromRGB(120,70,180)
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

warn("[RiiHUB] HomeGui loaded successfully")
