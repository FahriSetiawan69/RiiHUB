--==================================================
-- RiiHUB HomeGui.lua
-- FULL FIX VERSION (ANTI NIL / SAFE CALL)
--==================================================

--=========== GUARD (ANTI DOUBLE LOAD) ===========
if _G.RIIHUB_HOMEGUI_LOADED then
    warn("[RiiHUB] HomeGui already loaded, aborting")
    return
end
_G.RIIHUB_HOMEGUI_LOADED = true

--=========== SERVICES ===========
local Players = game:GetService("Players")
local player = Players.LocalPlayer

--=========== SAFE CALL HELPER ===========
local function safeCall(fn, ...)
    if typeof(fn) == "function" then
        return pcall(fn, ...)
    end
    return false
end

--=========== SCREEN GUI ===========
local gui = Instance.new("ScreenGui")
gui.Name = "RiiHUB"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

--=========== MAIN PANEL ===========
local main = Instance.new("Frame", gui)
main.Name = "MainPanel"
main.Size = UDim2.new(0, 420, 0, 280)
main.Position = UDim2.new(0.05, 0, 0.25, 0)
main.BackgroundColor3 = Color3.fromRGB(80, 45, 120)
main.BackgroundTransparency = 0.15
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

--=========== HEADER ===========
local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 36)
header.BackgroundTransparency = 1

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.Text = "RiiHUB PANEL"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left

local minimize = Instance.new("TextButton", header)
minimize.Size = UDim2.new(0, 28, 0, 28)
minimize.Position = UDim2.new(1, -34, 0, 4)
minimize.Text = "–"
minimize.Font = Enum.Font.SourceSansBold
minimize.TextSize = 22
minimize.TextColor3 = Color3.new(1,1,1)
minimize.BackgroundColor3 = Color3.fromRGB(160,110,220)
minimize.BorderSizePixel = 0
Instance.new("UICorner", minimize).CornerRadius = UDim.new(1,0)

--=========== LEFT PANEL ===========
local left = Instance.new("Frame", main)
left.Position = UDim2.new(0, 0, 0, 36)
left.Size = UDim2.new(0, 130, 1, -36)
left.BackgroundTransparency = 1

local leftLayout = Instance.new("UIListLayout", left)
leftLayout.Padding = UDim.new(0, 8)
leftLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Instance.new("UIPadding", left).PaddingTop = UDim.new(0, 12)

--=========== RIGHT PANEL ===========
local right = Instance.new("Frame", main)
right.Position = UDim2.new(0, 140, 0, 46)
right.Size = UDim2.new(1, -150, 1, -56)
right.BackgroundTransparency = 1

--=========== HELPERS ===========
local function clearRight()
    for _,v in ipairs(right:GetChildren()) do
        v:Destroy()
    end
end

local function makeButton(parent, text)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.9, 0, 0, 36)
    b.Text = text
    b.Font = Enum.Font.SourceSans
    b.TextSize = 15
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(120,70,180)
    b.BorderSizePixel = 0
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    return b
end

--=========== TAB CONTENT ===========
local function tabESP()
    clearRight()
    local btn = makeButton(right, "ESP : OFF")
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = state and "ESP : ON" or "ESP : OFF"
        safeCall(_G.ToggleESP, state)
    end)
end

local function tabSurvivor()
    clearRight()
    local btn = makeButton(right, "Aim Assist : OFF")
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = state and "Aim Assist : ON" or "Aim Assist : OFF"
        safeCall(_G.ToggleAimAssist, state)
    end)
end

local function tabEvent()
    clearRight()
    local btn = makeButton(right, "Event Assist : OFF")
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = state and "Event Assist : ON" or "Event Assist : OFF"
        safeCall(_G.ToggleEvent, state)
    end)
end

local function tabKiller()
    clearRight()

    local hitboxBtn = makeButton(right, "Hitbox Assist : OFF")
    local hitbox = false
    hitboxBtn.MouseButton1Click:Connect(function()
        hitbox = not hitbox
        hitboxBtn.Text = hitbox and "Hitbox Assist : ON" or "Hitbox Assist : OFF"
        if _G.KillerModule and typeof(_G.KillerModule.Enable) == "function" then
            safeCall(_G.KillerModule.Enable, hitbox)
        end
    end)

    local stalkBtn = makeButton(right, "Stalk Assist : OFF")
    local stalk = false
    stalkBtn.MouseButton1Click:Connect(function()
        stalk = not stalk
        stalkBtn.Text = stalk and "Stalk Assist : ON" or "Stalk Assist : OFF"
        if _G.StalkAssistModule and typeof(_G.StalkAssistModule.Enable) == "function" then
            safeCall(_G.StalkAssistModule.Enable, stalk)
        end
    end)
end

--=========== TAB BUTTONS ===========
makeButton(left, "ESP").MouseButton1Click:Connect(tabESP)
makeButton(left, "Survivor").MouseButton1Click:Connect(tabSurvivor)
makeButton(left, "Event").MouseButton1Click:Connect(tabEvent)
makeButton(left, "Killer").MouseButton1Click:Connect(tabKiller)

--=========== FLOATING BUTTON ===========
local float = Instance.new("TextButton", gui)
float.Size = UDim2.new(0, 50, 0, 50)
float.Position = UDim2.new(0.03, 0, 0.5, 0)
float.Text = "Rii"
float.Font = Enum.Font.SourceSansBold
float.TextSize = 18
float.TextColor3 = Color3.new(1,1,1)
float.BackgroundColor3 = Color3.fromRGB(120,70,180)
float.BorderSizePixel = 0
float.Visible = false
float.Active = true
float.Draggable = true
float.ZIndex = 999
Instance.new("UICorner", float).CornerRadius = UDim.new(1,0)

--=========== MINIMIZE LOGIC ===========
minimize.MouseButton1Click:Connect(function()
    main.Visible = false
    float.Visible = true
end)

float.MouseButton1Click:Connect(function()
    main.Visible = true
    float.Visible = false
end)

warn("[RiiHUB] HomeGui loaded safely (no nil crash)")
