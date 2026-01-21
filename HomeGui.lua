--==================================================
-- RiiHUB HomeGui
-- Sidebar grouped | Neon Purple | Client-side
--==================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Destroy old GUI
pcall(function()
    local old = PlayerGui:FindFirstChild("RiiHUB_GUI")
    if old then old:Destroy() end
end)

--========================
-- GLOBAL STATE (SAFE)
--========================
_G.RiiHUB_STATE = _G.RiiHUB_STATE or {
    ESP = false,
    AIM = false,
    HITBOX = false,
    SKILL = false,
    EVENT = false,
}

--========================
-- ROOT GUI
--========================
local gui = Instance.new("ScreenGui")
gui.Name = "RiiHUB_GUI"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 1000
gui.Parent = PlayerGui

--========================
-- MAIN WINDOW
--========================
local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(640, 420)
main.Position = UDim2.fromScale(0.5, 0.5)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = Color3.fromRGB(28, 12, 40)
main.BackgroundTransparency = 0.08
main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)

local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(170, 80, 255)
stroke.Thickness = 1.5
stroke.Transparency = 0.25

--========================
-- DRAGGABLE
--========================
do
    local dragging, startInput, startPos
    main.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startInput = i.Position
            startPos = main.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - startInput
            main.Position = startPos + UDim2.fromOffset(d.X, d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

--========================
-- HEADER
--========================
local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundTransparency = 1
header.Text = "RiiHUB"
header.Font = Enum.Font.GothamBold
header.TextSize = 22
header.TextColor3 = Color3.fromRGB(230, 200, 255)
header.Parent = main

--========================
-- SIDEBAR
--========================
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 160, 1, -40)
sidebar.Position = UDim2.fromOffset(0, 40)
sidebar.BackgroundColor3 = Color3.fromRGB(20, 8, 30)
sidebar.BorderSizePixel = 0
sidebar.Parent = main
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 10)

local sStroke = Instance.new("UIStroke", sidebar)
sStroke.Color = Color3.fromRGB(150, 60, 240)
sStroke.Thickness = 1.2
sStroke.Transparency = 0.35

--========================
-- PANEL
--========================
local panel = Instance.new("Frame")
panel.Size = UDim2.new(1, -170, 1, -40)
panel.Position = UDim2.new(0, 170, 0, 40)
panel.BackgroundTransparency = 1
panel.Parent = main

local layout = Instance.new("UIListLayout", panel)
layout.Padding = UDim.new(0, 8)

local function clearPanel()
    for _, c in ipairs(panel:GetChildren()) do
        if not c:IsA("UIListLayout") then c:Destroy() end
    end
end

--========================
-- TABS (GROUPED)
--========================
local tabs = {
    { Name = "ESP",      Key = "ESP" },
    { Name = "Survivor", Key = "SURVIVOR" },
    { Name = "Killer",   Key = "KILLER" },
    { Name = "Other",    Key = "OTHER" },
}
local selectedTab = "ESP"

local function makeTabButton(info, idx)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -16, 0, 34)
    btn.Position = UDim2.fromOffset(8, 8 + (idx-1)*40)
    btn.Text = info.Name
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 18
    btn.TextColor3 = Color3.fromRGB(225, 225, 255)
    btn.BackgroundColor3 = Color3.fromRGB(40, 14, 55)
    btn.Parent = sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local function refresh()
        btn.BackgroundColor3 = (selectedTab == info.Key)
            and Color3.fromRGB(120, 40, 200)
            or  Color3.fromRGB(40, 14, 55)
    end
    refresh()

    btn.MouseButton1Click:Connect(function()
        selectedTab = info.Key
        for _, b in ipairs(sidebar:GetChildren()) do
            if b:IsA("TextButton") then
                b.BackgroundColor3 = Color3.fromRGB(40, 14, 55)
            end
        end
        btn.BackgroundColor3 = Color3.fromRGB(120, 40, 200)
        updatePanel()
    end)
end

for i, t in ipairs(tabs) do
    makeTabButton(t, i)
end

--========================
-- TOGGLE HELPER
--========================
local function makeToggle(title, stateKey, module)
    local row = Instance.new("Frame", panel)
    row.Size = UDim2.new(1, -10, 0, 32)
    row.BackgroundTransparency = 1

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0.6, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = title
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 16
    lbl.TextColor3 = Color3.fromRGB(230, 230, 255)

    local btn = Instance.new("TextButton", row)
    btn.Size = UDim2.new(0.4, -6, 1, 0)
    btn.Position = UDim2.new(0.6, 6, 0, 0)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.BackgroundColor3 = Color3.fromRGB(110, 50, 180)
    Instance.new("UICorner", btn)

    local function refresh()
        btn.Text = (_G.RiiHUB_STATE[stateKey] and "ON" or "OFF")
    end
    refresh()

    btn.MouseButton1Click:Connect(function()
        _G.RiiHUB_STATE[stateKey] = not _G.RiiHUB_STATE[stateKey]
        if module and module.Enable and module.Disable then
            (_G.RiiHUB_STATE[stateKey] and module.Enable or module.Disable)(module)
        end
        refresh()
    end)
end

--========================
-- PANEL CONTENT
--========================
function updatePanel()
    clearPanel()

    local title = Instance.new("TextLabel", panel)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextColor3 = Color3.fromRGB(235, 220, 255)

    if selectedTab == "ESP" then
        title.Text = "ESP"
        makeToggle("ESP", "ESP", _G.ESPModule)

    elseif selectedTab == "SURVIVOR" then
        title.Text = "Survivor"
        makeToggle("Aim Assist", "AIM", _G.AimAssistModule)
        makeToggle("HitBox Killer", "HITBOX", _G.HitBoxKiller)
        makeToggle("Skill Check", "SKILL", _G.SkillCheckGenerator)

    elseif selectedTab == "KILLER" then
        title.Text = "Killer"
        local note = Instance.new("TextLabel", panel)
        note.BackgroundTransparency = 1
        note.TextWrapped = true
        note.Text = "Fitur Killer akan ditambahkan nanti."
        note.Font = Enum.Font.Gotham
        note.TextSize = 14
        note.TextColor3 = Color3.fromRGB(200, 190, 230)

    elseif selectedTab == "OTHER" then
        title.Text = "Other"
        makeToggle("Event", "EVENT", _G.EventModule)
    end
end

updatePanel()