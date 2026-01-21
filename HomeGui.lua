--==================================================
-- RiiHUB HomeGui (FINAL)
-- Sidebar grouped | Neon Purple | Minimize + Close
-- Client-side only
--==================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Destroy old
pcall(function()
    local old = PlayerGui:FindFirstChild("RiiHUB_GUI")
    if old then old:Destroy() end
end)

--========================
-- GLOBAL STATE
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
-- HEADER
--========================
local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundTransparency = 1

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -80, 1, 0)
title.Position = UDim2.fromOffset(12, 0)
title.Text = "RiiHUB"
title.Font = Enum.Font.GothamBold
title.TextSize = 22
title.TextXAlignment = Left
title.TextColor3 = Color3.fromRGB(230, 200, 255)
title.BackgroundTransparency = 1

-- Buttons
local btnMin = Instance.new("TextButton", header)
btnMin.Size = UDim2.fromOffset(28, 28)
btnMin.Position = UDim2.new(1, -64, 0.5, -14)
btnMin.Text = "–"
btnMin.Font = Enum.Font.GothamBold
btnMin.TextSize = 22
btnMin.TextColor3 = Color3.fromRGB(230,230,255)
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
-- DRAG MAIN
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
-- SIDEBAR + PANEL
--========================
local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0, 160, 1, -40)
sidebar.Position = UDim2.fromOffset(0, 40)
sidebar.BackgroundColor3 = Color3.fromRGB(20, 8, 30)
sidebar.BorderSizePixel = 0
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 10)

local panel = Instance.new("Frame", main)
panel.Size = UDim2.new(1, -170, 1, -40)
panel.Position = UDim2.new(0, 170, 0, 40)
panel.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", panel)
layout.Padding = UDim.new(0, 8)

local function clearPanel()
    for _, c in ipairs(panel:GetChildren()) do
        if not c:IsA("UIListLayout") then c:Destroy() end
    end
end

--========================
-- TABS
--========================
local tabs = {
    { Name = "ESP",      Key = "ESP" },
    { Name = "Survivor", Key = "SURVIVOR" },
    { Name = "Killer",   Key = "KILLER" },
    { Name = "Other",    Key = "OTHER" },
}
local selectedTab = "ESP"

local function makeTabButton(info, idx)
    local btn = Instance.new("TextButton", sidebar)
    btn.Size = UDim2.new(1, -16, 0, 34)
    btn.Position = UDim2.fromOffset(8, 8 + (idx-1)*40)
    btn.Text = info.Name
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 18
    btn.TextColor3 = Color3.fromRGB(225, 225, 255)
    btn.BackgroundColor3 = Color3.fromRGB(40, 14, 55)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    btn.MouseButton1Click:Connect(function()
        selectedTab = info.Key
        updatePanel()
    end)
end

for i,t in ipairs(tabs) do makeTabButton(t,i) end

--========================
-- TOGGLE
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
    lbl.TextColor3 = Color3.fromRGB(230,230,255)
    lbl.BackgroundTransparency = 1

    local btn = Instance.new("TextButton", row)
    btn.Size = UDim2.new(0.4, -6, 1, 0)
    btn.Position = UDim2.new(0.6, 6, 0, 0)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.BackgroundColor3 = Color3.fromRGB(110, 50, 180)
    Instance.new("UICorner", btn)

    local function refresh()
        btn.Text = (_G.RiiHUB_STATE[key] and "ON" or "OFF")
    end
    refresh()

    btn.MouseButton1Click:Connect(function()
        _G.RiiHUB_STATE[key] = not _G.RiiHUB_STATE[key]
        if module then
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

updatePanel()

--========================
-- MINIMIZE / FLOATING
--========================
local floating

btnMin.MouseButton1Click:Connect(function()
    local tween = TweenService:Create(main, TweenInfo.new(0.25), {
        Size = UDim2.fromOffset(0,0),
        BackgroundTransparency = 1
    })
    tween:Play()
    tween.Completed:Wait()
    main.Visible = false

    floating = Instance.new("TextButton", gui)
    floating.Size = UDim2.fromOffset(120, 36)
    floating.Position = UDim2.fromScale(0.1, 0.5)
    floating.Text = "RiiHUB"
    floating.Font = Enum.Font.GothamBold
    floating.TextSize = 16
    floating.TextColor3 = Color3.fromRGB(255,255,255)
    floating.BackgroundColor3 = Color3.fromRGB(120, 60, 200)
    Instance.new("UICorner", floating)

    -- drag floating
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
        UIS.InputEnded:Connect(function(i)
            dragging = false
        end)
    end

    floating.MouseButton1Click:Connect(function()
        floating:Destroy()
        main.Visible = true
        TweenService:Create(main, TweenInfo.new(0.25), {
            Size = UDim2.fromOffset(640,420),
            BackgroundTransparency = 0.08
        }):Play()
    end)
end)

--========================
-- CLOSE
--========================
btnClose.MouseButton1Click:Connect(function()
    TweenService:Create(main, TweenInfo.new(0.25), {
        Size = UDim2.fromOffset(0,0),
        BackgroundTransparency = 1
    }):Play()
    task.wait(0.25)
    gui:Destroy()
end)