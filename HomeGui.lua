--==================================================
-- RiiHUB HomeGui (FINAL FIX)
-- Layout & Style TIDAK DIUBAH
--==================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--========================
-- DESTROY OLD GUI
--========================
pcall(function()
    local old = PlayerGui:FindFirstChild("RiiHUB_GUI")
    if old then old:Destroy() end
end)

--========================
-- GLOBAL STATE (DEFAULT OFF)
--========================
_G.RiiHUB_STATE = _G.RiiHUB_STATE or {
    ESP = false,
    AIM = false,
    HITBOX = false,
    SKILL = false,
    EVENT = false,

    -- ESP FLAGS
    SURVIVOR_ESP  = false,
    KILLER_ESP    = false,
    GENERATOR_ESP = false,
    PALLET_ESP    = false,
    GATE_ESP      = false,
    ESP_NAME_HP   = false,
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
main.BackgroundColor3 = Color3.fromRGB(32, 14, 45)
main.BackgroundTransparency = 0.05
main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)

local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(170, 80, 255)
stroke.Thickness = 1.5
stroke.Transparency = 0.25

--========================
-- HEADER
--========================
local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 42)
header.BackgroundTransparency = 1

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -80, 1, 0)
title.Position = UDim2.fromOffset(12, 0)
title.Text = "RiiHUB"
title.Font = Enum.Font.GothamBold
title.TextSize = 22
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.fromRGB(235, 215, 255)
title.BackgroundTransparency = 1

local btnMin = Instance.new("TextButton", header)
btnMin.Size = UDim2.fromOffset(28, 28)
btnMin.Position = UDim2.new(1, -64, 0.5, -14)
btnMin.Text = "–"
btnMin.Font = Enum.Font.GothamBold
btnMin.TextSize = 22
btnMin.TextColor3 = Color3.fromRGB(240,240,255)
btnMin.BackgroundColor3 = Color3.fromRGB(90, 40, 150)
Instance.new("UICorner", btnMin)

local btnClose = Instance.new("TextButton", header)
btnClose.Size = UDim2.fromOffset(28, 28)
btnClose.Position = UDim2.new(1, -32, 0.5, -14)
btnClose.Text = "X"
btnClose.Font = Enum.Font.GothamBold
btnClose.TextSize = 16
btnClose.TextColor3 = Color3.fromRGB(255,200,200)
btnClose.BackgroundColor3 = Color3.fromRGB(140, 50, 80)
Instance.new("UICorner", btnClose)

--========================
-- DRAG WINDOW
--========================
do
    local dragging, startInput, startPos
    header.InputBegan:Connect(function(i)
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
-- SIDEBAR
--========================
local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0, 160, 1, -42)
sidebar.Position = UDim2.fromOffset(0, 42)
sidebar.BackgroundColor3 = Color3.fromRGB(22, 10, 32)
sidebar.BorderSizePixel = 0
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 10)

--========================
-- PANEL
--========================
local panel = Instance.new("Frame", main)
panel.Size = UDim2.new(1, -170, 1, -42)
panel.Position = UDim2.new(0, 170, 0, 42)
panel.BackgroundTransparency = 1
panel.Parent = main

local layout = Instance.new("UIListLayout", panel)
layout.Padding = UDim.new(0, 8)

local function clearPanel()
    for _,c in ipairs(panel:GetChildren()) do
        if not c:IsA("UIListLayout") then
            c:Destroy()
        end
    end
end

--========================
-- TABS
--========================
local tabs = {
    { Name = "ESP", Key = "ESP" },
    { Name = "Survivor", Key = "SURVIVOR" },
    { Name = "Killer", Key = "KILLER" },
    { Name = "Other", Key = "OTHER" },
}

local selectedTab = "ESP"

local function makeTabButton(info, idx)
    local btn = Instance.new("TextButton", sidebar)
    btn.Size = UDim2.new(1, -16, 0, 34)
    btn.Position = UDim2.fromOffset(8, 8 + (idx-1)*40)
    btn.Text = info.Name
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 18
    btn.TextColor3 = Color3.fromRGB(230,230,255)
    btn.BackgroundColor3 = Color3.fromRGB(42, 16, 60)
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function()
        selectedTab = info.Key
        updatePanel()
    end)
end

for i,t in ipairs(tabs) do
    makeTabButton(t,i)
end

--========================
-- TOGGLE CREATOR (FIXED)
--========================
local function makeToggle(title, key, module)
    local row = Instance.new("Frame", panel)
    row.Size = UDim2.new(1, -10, 0, 32)
    row.BackgroundTransparency = 1

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0.6, 0, 1, 0)
    lbl.Text = title
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 16
    lbl.TextColor3 = Color3.fromRGB(235,235,255)
    lbl.BackgroundTransparency = 1

    local btn = Instance.new("TextButton", row)
    btn.Size = UDim2.new(0.4, -6, 1, 0)
    btn.Position = UDim2.new(0.6, 6, 0, 0)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.BackgroundColor3 = Color3.fromRGB(120, 60, 200)
    Instance.new("UICorner", btn)

    local function refresh()
        btn.Text = (_G.RiiHUB_STATE[key] and "ON" or "OFF")
    end

    refresh()

    btn.MouseButton1Click:Connect(function()
        _G.RiiHUB_STATE[key] = not _G.RiiHUB_STATE[key]

        -- ===== ESP MODULE HANDLING =====
        if module == _G.ESPModule then
            if key == "ESP" then
                if _G.RiiHUB_STATE[key] then
                    module:Enable()
                else
                    module:Disable()
                end
            else
                if not module.Enabled then
                    module:Enable()
                end

                local map = {
                    SURVIVOR_ESP  = "Survivor",
                    KILLER_ESP    = "Killer",
                    GENERATOR_ESP = "Generator",
                    PALLET_ESP    = "Pallet",
                    GATE_ESP      = "Gate",
                    ESP_NAME_HP   = "NameHP",
                }

                local flag = map[key]
                if flag then
                    module:Set(flag, _G.RiiHUB_STATE[key])
                end
            end

        -- ===== OTHER MODULES =====
        elseif module and module.Enable and module.Disable then
            (_G.RiiHUB_STATE[key] and module.Enable or module.Disable)(module)
        end

        refresh()
    end)
end

--========================
-- PANEL CONTENT
--========================
function updatePanel()
    clearPanel()

    if selectedTab == "ESP" then
        makeToggle("ESP", "ESP", _G.ESPModule)
        makeToggle("Survivor ESP", "SURVIVOR_ESP", _G.ESPModule)
        makeToggle("Killer ESP", "KILLER_ESP", _G.ESPModule)
        makeToggle("Generator ESP", "GENERATOR_ESP", _G.ESPModule)
        makeToggle("Pallet ESP", "PALLET_ESP", _G.ESPModule)
        makeToggle("Gate ESP", "GATE_ESP", _G.ESPModule)
        makeToggle("Nama + HP", "ESP_NAME_HP", _G.ESPModule)

    elseif selectedTab == "SURVIVOR" then
        makeToggle("Aim Assist", "AIM", _G.AimAssistModule)
        makeToggle("HitBox Killer", "HITBOX", _G.HitBoxKiller)
        makeToggle("Skill Check", "SKILL", _G.SkillCheckGenerator)

    elseif selectedTab == "KILLER" then
        local txt = Instance.new("TextLabel", panel)
        txt.Text = "Fitur Killer akan ditambahkan."
        txt.Font = Enum.Font.Gotham
        txt.TextSize = 14
        txt.TextColor3 = Color3.fromRGB(200,190,230)
        txt.BackgroundTransparency = 1

    elseif selectedTab == "OTHER" then
        makeToggle("Event", "EVENT", _G.EventModule)
    end
end

task.wait(0.1)
updatePanel()

--========================
-- MINIMIZE
--========================
btnMin.MouseButton1Click:Connect(function()
    main.Visible = false
    local floating = Instance.new("TextButton", gui)
    floating.Size = UDim2.fromOffset(120, 36)
    floating.Position = UDim2.fromScale(0.1, 0.5)
    floating.Text = "RiiHUB"
    floating.Font = Enum.Font.GothamBold
    floating.TextSize = 16
    floating.TextColor3 = Color3.fromRGB(255,255,255)
    floating.BackgroundColor3 = Color3.fromRGB(120, 60, 200)
    Instance.new("UICorner", floating)

    do
        local dragging, start, pos
        floating.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                start = i.Position
                pos = floating.Position
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                local d = i.Position - start
                floating.Position = pos + UDim2.fromOffset(d.X, d.Y)
            end
        end)
        UIS.InputEnded:Connect(function()
            dragging = false
        end)
    end

    floating.MouseButton1Click:Connect(function()
        floating:Destroy()
        main.Visible = true
    end)
end)

--========================
-- CLOSE
--========================
btnClose.MouseButton1Click:Connect(function()
    gui:Destroy()
end)