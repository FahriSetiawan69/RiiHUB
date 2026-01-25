-- RiiHUB HomeGui.lua
-- UI ONLY | Switch Toggle | Animated | Stable

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local lp = Players.LocalPlayer

-------------------------------------------------
-- GUI ROOT
-------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "RiiHUB_GUI"
gui.ResetOnSpawn = false
gui.Parent = lp:WaitForChild("PlayerGui")

-------------------------------------------------
-- MAIN FRAME
-------------------------------------------------
local main = Instance.new("Frame", gui)
main.Size = UDim2.fromScale(0.72, 0.6)
main.Position = UDim2.fromScale(0.14, 0.2)
main.BackgroundColor3 = Color3.fromRGB(60, 20, 100)
main.BorderSizePixel = 0
main.BackgroundTransparency = 0.04
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 18)

-------------------------------------------------
-- TOP BAR
-------------------------------------------------
local top = Instance.new("Frame", main)
top.Size = UDim2.new(1, 0, 0, 48)
top.BackgroundTransparency = 1

local title = Instance.new("TextLabel", top)
title.Size = UDim2.new(1, -120, 1, 0)
title.Position = UDim2.new(0, 16, 0, 0)
title.Text = "RiiHUB"
title.Font = Enum.Font.GothamBold
title.TextSize = 22
title.TextColor3 = Color3.fromRGB(220,180,255)
title.TextXAlignment = Left
title.BackgroundTransparency = 1

-------------------------------------------------
-- TOP BUTTONS
-------------------------------------------------
local function topBtn(txt, x)
    local b = Instance.new("TextButton", top)
    b.Size = UDim2.fromOffset(36, 30)
    b.Position = UDim2.new(1, x, 0.5, -15)
    b.Text = txt
    b.Font = Enum.Font.GothamBold
    b.TextSize = 18
    b.TextColor3 = Color3.fromRGB(255,220,255)
    b.BackgroundColor3 = Color3.fromRGB(120,50,180)
    b.BorderSizePixel = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    return b
end

local btnMin = topBtn("-", -90)
local btnClose = topBtn("X", -45)

-------------------------------------------------
-- SIDEBAR
-------------------------------------------------
local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0, 170, 1, -48)
sidebar.Position = UDim2.new(0, 0, 0, 48)
sidebar.BackgroundColor3 = Color3.fromRGB(40, 10, 70)
sidebar.BorderSizePixel = 0
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 18)

local sideLayout = Instance.new("UIListLayout", sidebar)
sideLayout.Padding = UDim.new(0, 8)
sideLayout.HorizontalAlignment = Center

-------------------------------------------------
-- CONTENT
-------------------------------------------------
local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, -180, 1, -56)
content.Position = UDim2.new(0, 180, 0, 56)
content.BackgroundTransparency = 1

local contentLayout = Instance.new("UIListLayout", content)
contentLayout.Padding = UDim.new(0, 10)

-------------------------------------------------
-- FLOATING BUTTON
-------------------------------------------------
local floatBtn = Instance.new("TextButton", gui)
floatBtn.Size = UDim2.fromOffset(56,56)
floatBtn.Position = UDim2.fromScale(0.06,0.5)
floatBtn.Text = "[R]"
floatBtn.Font = Enum.Font.GothamBold
floatBtn.TextSize = 22
floatBtn.TextColor3 = Color3.fromRGB(255,220,255)
floatBtn.BackgroundColor3 = Color3.fromRGB(120,50,180)
floatBtn.Visible = false
floatBtn.BorderSizePixel = 0
Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(1,0)

-------------------------------------------------
-- DRAG FLOAT
-------------------------------------------------
do
    local drag, start, pos
    floatBtn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true
            start = i.Position
            pos = floatBtn.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - start
            floatBtn.Position = UDim2.new(
                pos.X.Scale, pos.X.Offset + d.X,
                pos.Y.Scale, pos.Y.Offset + d.Y
            )
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = false
        end
    end)
end

-------------------------------------------------
-- MINIMIZE
-------------------------------------------------
local minimized = false
local function toggleMin()
    minimized = not minimized
    main.Visible = not minimized
    floatBtn.Visible = minimized
end

btnMin.MouseButton1Click:Connect(toggleMin)
floatBtn.MouseButton1Click:Connect(toggleMin)
btnClose.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-------------------------------------------------
-- UI API
-------------------------------------------------
local UI = {}
local currentTab

function UI:RegisterTab(name)
    local b = Instance.new("TextButton", sidebar)
    b.Size = UDim2.new(1, -20, 0, 36)
    b.Text = name
    b.Font = Enum.Font.Gotham
    b.TextSize = 16
    b.TextColor3 = Color3.fromRGB(255,230,255)
    b.BackgroundColor3 = Color3.fromRGB(100,40,160)
    b.BorderSizePixel = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)

    b.MouseButton1Click:Connect(function()
        for _,v in ipairs(content:GetChildren()) do
            if v:IsA("Frame") then v.Visible = false end
        end
        if currentTab then currentTab.Visible = true end
    end)

    return b
end

-------------------------------------------------
-- SWITCH TOGGLE
-------------------------------------------------
function UI:AddToggle(_, label, callback)
    local row = Instance.new("Frame", content)
    row.Size = UDim2.new(1, -20, 0, 44)
    row.BackgroundColor3 = Color3.fromRGB(80,30,130)
    row.BorderSizePixel = 0
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 12)

    local txt = Instance.new("TextLabel", row)
    txt.Size = UDim2.new(1, -80, 1, 0)
    txt.Position = UDim2.new(0, 12, 0, 0)
    txt.Text = label
    txt.Font = Enum.Font.Gotham
    txt.TextSize = 14
    txt.TextColor3 = Color3.fromRGB(255,255,255)
    txt.BackgroundTransparency = 1
    txt.TextXAlignment = Left

    local sw = Instance.new("Frame", row)
    sw.Size = UDim2.fromOffset(44, 22)
    sw.Position = UDim2.new(1, -56, 0.5, -11)
    sw.BackgroundColor3 = Color3.fromRGB(120,60,160)
    Instance.new("UICorner", sw).CornerRadius = UDim.new(1,0)

    local knob = Instance.new("Frame", sw)
    knob.Size = UDim2.fromOffset(18,18)
    knob.Position = UDim2.fromOffset(2,2)
    knob.BackgroundColor3 = Color3.fromRGB(230,200,255)
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

    local state = false

    local function set(v)
        state = v
        TweenService:Create(knob, TweenInfo.new(0.2),
            {Position = v and UDim2.fromOffset(24,2) or UDim2.fromOffset(2,2)}
        ):Play()
        callback(v)
    end

    row.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            set(not state)
        end
    end)
end

-------------------------------------------------
-- EXPORT
-------------------------------------------------
_G.RiiHUB_UI = UI
print("[RiiHUB] HomeGui ready (Switch + Animation)")