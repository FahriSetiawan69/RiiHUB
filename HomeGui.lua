-- ===============================
-- RiiHUB HomeGui (STATE SAFE FIX)
-- ===============================

if _G.RiiHUB_GUI_LOADED then
    warn("RiiHUB already loaded")
    return
end
_G.RiiHUB_GUI_LOADED = true

-- ===============================
-- GLOBAL STATE (PENTING)
-- ===============================
_G.RiiHUB_State = _G.RiiHUB_State or {
    ESP = false,
    AimAssist = false,
    Event = false,
    KillerHitbox = false,
    KillerStalk = false
}

-- ===============================
-- SERVICES
-- ===============================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ===============================
-- CLEAN OLD GUI
-- ===============================
pcall(function()
    if PlayerGui:FindFirstChild("RiiHUB_GUI") then
        PlayerGui.RiiHUB_GUI:Destroy()
    end
end)

-- ===============================
-- MAIN GUI
-- ===============================
local gui = Instance.new("ScreenGui")
gui.Name = "RiiHUB_GUI"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

-- ===============================
-- MAIN FRAME
-- ===============================
local main = Instance.new("Frame", gui)
main.Size = UDim2.fromScale(0.65, 0.6)
main.Position = UDim2.fromScale(0.5, 0.5)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = Color3.fromRGB(95, 60, 140)
main.BackgroundTransparency = 0.1
main.Visible = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 22)

-- ===============================
-- HEADER
-- ===============================
local header = Instance.new("TextLabel", main)
header.Size = UDim2.new(1, -60, 0, 50)
header.Position = UDim2.new(0, 20, 0, 5)
header.Text = "RiiHUB PANEL"
header.TextColor3 = Color3.new(1,1,1)
header.TextScaled = true
header.Font = Enum.Font.GothamBold
header.BackgroundTransparency = 1
header.TextXAlignment = Left

-- ===============================
-- MINIMIZE BUTTON
-- ===============================
local minimize = Instance.new("TextButton", main)
minimize.Size = UDim2.fromOffset(40,40)
minimize.Position = UDim2.new(1, -45, 0, 5)
minimize.Text = "–"
minimize.TextScaled = true
minimize.Font = Enum.Font.GothamBold
minimize.TextColor3 = Color3.new(1,1,1)
minimize.BackgroundTransparency = 0.3
minimize.BackgroundColor3 = Color3.fromRGB(120,80,180)
Instance.new("UICorner", minimize).CornerRadius = UDim.new(1,0)

-- ===============================
-- TAB PANEL
-- ===============================
local tabs = Instance.new("Frame", main)
tabs.Size = UDim2.new(0, 160, 1, -70)
tabs.Position = UDim2.new(0, 10, 0, 60)
tabs.BackgroundTransparency = 1

local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, -180, 1, -70)
content.Position = UDim2.new(0, 170, 0, 60)
content.BackgroundTransparency = 1

-- ===============================
-- UTIL
-- ===============================
local function clearContent()
    for _,v in pairs(content:GetChildren()) do
        if v:IsA("GuiObject") then v:Destroy() end
    end
end

local function makeButton(parent, text)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, 0, 0, 42)
    b.Text = text
    b.TextScaled = true
    b.Font = Enum.Font.Gotham
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(120,80,180)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,14)
    return b
end

local function makeToggle(text, stateGetter, stateSetter, callback)
    local btn = makeButton(content, "")
    local function refresh()
        btn.Text = text .. " : " .. (stateGetter() and "ON" or "OFF")
    end
    refresh()
    btn.MouseButton1Click:Connect(function()
        stateSetter(not stateGetter())
        refresh()
        if callback then callback(stateGetter()) end
    end)
end

-- ===============================
-- TAB LOGIC
-- ===============================
local function tabESP()
    clearContent()
    makeToggle(
        "ESP",
        function() return _G.RiiHUB_State.ESP end,
        function(v) _G.RiiHUB_State.ESP = v end,
        function(v)
            if _G.ToggleESP then _G.ToggleESP(v) end
        end
    )
end

local function tabSurvivor()
    clearContent()
    makeToggle(
        "Aim Assist",
        function() return _G.RiiHUB_State.AimAssist end,
        function(v) _G.RiiHUB_State.AimAssist = v end,
        function(v)
            if _G.ToggleAimAssist then _G.ToggleAimAssist(v) end
        end
    )
end

local function tabEvent()
    clearContent()
    makeToggle(
        "Event Helper",
        function() return _G.RiiHUB_State.Event end,
        function(v) _G.RiiHUB_State.Event = v end,
        function(v)
            if _G.ToggleEvent then _G.ToggleEvent(v) end
        end
    )
end

local function tabKiller()
    clearContent()
    makeToggle(
        "Hitbox Assist",
        function() return _G.RiiHUB_State.KillerHitbox end,
        function(v) _G.RiiHUB_State.KillerHitbox = v end,
        function(v)
            if _G.ToggleKillerHitbox then _G.ToggleKillerHitbox(v) end
        end
    )

    makeToggle(
        "Stalk Assist",
        function() return _G.RiiHUB_State.KillerStalk end,
        function(v) _G.RiiHUB_State.KillerStalk = v end,
        function(v)
            if _G.ToggleStalkAssist then _G.ToggleStalkAssist(v) end
        end
    )
end

-- ===============================
-- TAB BUTTONS
-- ===============================
local layout = Instance.new("UIListLayout", tabs)
layout.Padding = UDim.new(0, 10)

local function addTab(name, callback)
    local b = makeButton(tabs, name)
    b.MouseButton1Click:Connect(callback)
end

addTab("ESP", tabESP)
addTab("Survivor", tabSurvivor)
addTab("Event", tabEvent)
addTab("Killer", tabKiller)

-- ===============================
-- DEFAULT TAB
-- ===============================
tabESP()

-- ===============================
-- FLOATING BUTTON
-- ===============================
local float = Instance.new("TextButton", gui)
float.Size = UDim2.fromOffset(60,60)
float.Position = UDim2.fromScale(0.05,0.5)
float.Text = "Rii"
float.TextScaled = true
float.Font = Enum.Font.GothamBold
float.TextColor3 = Color3.new(1,1,1)
float.BackgroundColor3 = Color3.fromRGB(120,80,180)
Instance.new("UICorner", float).CornerRadius = UDim.new(1,0)
float.Visible = false

minimize.MouseButton1Click:Connect(function()
    main.Visible = false
    float.Visible = true
end)

float.MouseButton1Click:Connect(function()
    main.Visible = true
    float.Visible = false
end)

print("RiiHUB HomeGui loaded successfully")
