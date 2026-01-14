--==================================================
-- HomeGui.lua (FINAL FIX)
-- Force Visible | Mobile Safe | Modular Ready
--==================================================

--========================
-- FORCE RESET (ANTI GHOST GUI)
--========================
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local old = PlayerGui:FindFirstChild("HomeGui")
if old then
    old:Destroy()
end

--========================
-- MODULE ACCESS (GLOBAL)
--========================
local EventModule = _G.EventModule
local ToggleESP = _G.ToggleESP
local ToggleAimAssist = _G.ToggleAimAssist

--========================
-- SCREEN GUI
--========================
local gui = Instance.new("ScreenGui")
gui.Name = "HomeGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = PlayerGui

warn("[HOMEGUI] ScreenGui created")

--========================
-- MAIN FRAME (CENTERED)
--========================
local main = Instance.new("Frame")
main.Name = "Main"
main.Parent = gui
main.Size = UDim2.new(0, 420, 0, 330)
main.Position = UDim2.new(0.5, -210, 0.5, -165) -- FORCE CENTER
main.BackgroundColor3 = Color3.fromRGB(70, 40, 120)
main.BackgroundTransparency = 0.15
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.ZIndex = 50

local corner = Instance.new("UICorner", main)
corner.CornerRadius = UDim.new(0, 14)

--========================
-- FORCE ZINDEX CHILDREN
--========================
local function applyZ(obj)
    if obj:IsA("GuiObject") then
        obj.ZIndex = 50
    end
    for _,v in ipairs(obj:GetChildren()) do
        applyZ(v)
    end
end

applyZ(main)

--========================
-- HEADER
--========================
local header = Instance.new("Frame", main)
header.Size = UDim2.new(1,0,0,40)
header.BackgroundColor3 = Color3.fromRGB(120,70,180)
header.BackgroundTransparency = 0.1
header.BorderSizePixel = 0

Instance.new("UICorner", header).CornerRadius = UDim.new(0,14)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1,-50,1,0)
title.Position = UDim2.new(0,12,0,0)
title.BackgroundTransparency = 1
title.Text = "RiiHUB PANEL"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.TextColor3 = Color3.new(1,1,1)
title.TextXAlignment = Enum.TextXAlignment.Left

--========================
-- MINIMIZE BUTTON
--========================
local minimized = false
local miniBtn = Instance.new("TextButton", header)
miniBtn.Size = UDim2.new(0,30,0,30)
miniBtn.Position = UDim2.new(1,-38,0,5)
miniBtn.Text = "–"
miniBtn.Font = Enum.Font.SourceSansBold
miniBtn.TextSize = 22
miniBtn.TextColor3 = Color3.new(1,1,1)
miniBtn.BackgroundColor3 = Color3.fromRGB(160,110,220)
miniBtn.BorderSizePixel = 0
Instance.new("UICorner", miniBtn).CornerRadius = UDim.new(1,0)

--========================
-- CONTENT FRAMES
--========================
local left = Instance.new("Frame", main)
left.Position = UDim2.new(0,0,0,40)
left.Size = UDim2.new(0,130,1,-40)
left.BackgroundColor3 = Color3.fromRGB(60,30,100)
left.BackgroundTransparency = 0.15
left.BorderSizePixel = 0
Instance.new("UICorner", left).CornerRadius = UDim.new(0,14)

local right = Instance.new("Frame", main)
right.Position = UDim2.new(0,140,0,50)
right.Size = UDim2.new(1,-150,1,-60)
right.BackgroundColor3 = Color3.fromRGB(40,20,70)
right.BackgroundTransparency = 0.15
right.BorderSizePixel = 0
Instance.new("UICorner", right).CornerRadius = UDim.new(0,14)

--========================
-- LEFT BUTTON LAYOUT
--========================
local layout = Instance.new("UIListLayout", left)
layout.Padding = UDim.new(0,8)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Instance.new("UIPadding", left).PaddingTop = UDim.new(0,12)

--========================
-- UTIL
--========================
local function clearRight()
    for _,v in ipairs(right:GetChildren()) do
        if not v:IsA("UICorner") then
            v:Destroy()
        end
    end
end

local function createButton(parent, text)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.9,0,0,36)
    b.Text = text
    b.Font = Enum.Font.SourceSans
    b.TextSize = 15
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(120,70,180)
    b.BackgroundTransparency = 0.15
    b.BorderSizePixel = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    b.Parent = parent
    return b
end

--========================
-- ESP TAB
--========================
local espOn = false
local espBtn = createButton(left, "ESP")

espBtn.MouseButton1Click:Connect(function()
    clearRight()
    local toggle = createButton(right, "ESP : OFF")
    toggle.Position = UDim2.new(0,10,0,20)

    local function update()
        toggle.Text = espOn and "ESP : ON" or "ESP : OFF"
        toggle.BackgroundColor3 = espOn and Color3.fromRGB(0,180,120) or Color3.fromRGB(120,70,180)
    end
    update()

    toggle.MouseButton1Click:Connect(function()
        espOn = not espOn
        update()
        if ToggleESP then
            ToggleESP(espOn)
        end
    end)
end)

--========================
-- AIM TAB
--========================
local aimOn = false
local aimBtn = createButton(left, "Survivor")

aimBtn.MouseButton1Click:Connect(function()
    clearRight()
    local toggle = createButton(right, "Aim Assist : OFF")
    toggle.Position = UDim2.new(0,10,0,20)

    local function update()
        toggle.Text = aimOn and "Aim Assist : ON" or "Aim Assist : OFF"
        toggle.BackgroundColor3 = aimOn and Color3.fromRGB(0,180,120) or Color3.fromRGB(120,70,180)
    end
    update()

    toggle.MouseButton1Click:Connect(function()
        aimOn = not aimOn
        update()
        if ToggleAimAssist then
            ToggleAimAssist(aimOn)
        end
    end)
end)

--========================
-- EVENT TAB
--========================
local eventOn = false
local eventBtn = createButton(left, "Event")

eventBtn.MouseButton1Click:Connect(function()
    clearRight()

    local toggle = createButton(right, "Event : OFF")
    toggle.Position = UDim2.new(0,10,0,20)

    local giftBtn = createButton(right, "Go To Nearest Gift")
    giftBtn.Position = UDim2.new(0,10,0,70)
    giftBtn.BackgroundColor3 = Color3.fromRGB(90,180,120)

    local treeBtn = createButton(right, "Go To Christmas Tree")
    treeBtn.Position = UDim2.new(0,10,0,120)
    treeBtn.BackgroundColor3 = Color3.fromRGB(90,120,180)

    local function update()
        toggle.Text = eventOn and "Event : ON" or "Event : OFF"
        toggle.BackgroundColor3 = eventOn and Color3.fromRGB(0,180,120) or Color3.fromRGB(120,70,180)
    end
    update()

    toggle.MouseButton1Click:Connect(function()
        eventOn = not eventOn
        update()
        if EventModule and EventModule.Enable then
            EventModule.Enable(eventOn)
        end
    end)

    giftBtn.MouseButton1Click:Connect(function()
        if EventModule and EventModule.TeleportToNearestGift then
            EventModule.TeleportToNearestGift()
        end
    end)

    treeBtn.MouseButton1Click:Connect(function()
        if EventModule and EventModule.TeleportToTree then
            EventModule.TeleportToTree()
        end
    end)
end)

--========================
-- MINIMIZE LOGIC
--========================
miniBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    left.Visible = not minimized
    right.Visible = not minimized
    main.Size = minimized and UDim2.new(0,200,0,40) or UDim2.new(0,420,0,330)
    miniBtn.Text = minimized and "+" or "–"
end)

--========================
-- FINAL VISUAL LOG
--========================
warn("[HOMEGUI] GUI READY | ABS POS:", main.AbsolutePosition, "SIZE:", main.AbsoluteSize)
