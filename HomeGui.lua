-- RiiHUB HomeGui.lua (UI ONLY - FINAL)

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local lp = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "RiiHUB_GUI"
gui.ResetOnSpawn = false
gui.Parent = lp:WaitForChild("PlayerGui")

-------------------------------------------------
-- MAIN FRAME
-------------------------------------------------
local main = Instance.new("Frame")
main.Size = UDim2.fromScale(0.7, 0.6)
main.Position = UDim2.fromScale(0.15, 0.2)
main.BackgroundColor3 = Color3.fromRGB(60, 20, 100)
main.BackgroundTransparency = 0.05
main.BorderSizePixel = 0
main.Parent = gui
main.ZIndex = 2
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
title.TextColor3 = Color3.fromRGB(220, 180, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 22
title.TextXAlignment = Left
title.BackgroundTransparency = 1

-------------------------------------------------
-- BUTTONS
-------------------------------------------------
local function makeTopBtn(text, x)
    local b = Instance.new("TextButton", top)
    b.Size = UDim2.new(0, 40, 0, 32)
    b.Position = UDim2.new(1, x, 0.5, -16)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 18
    b.TextColor3 = Color3.fromRGB(255, 220, 255)
    b.BackgroundColor3 = Color3.fromRGB(120, 50, 180)
    b.BorderSizePixel = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    return b
end

local minimizeBtn = makeTopBtn("-", -96)
local closeBtn = makeTopBtn("X", -48)

-------------------------------------------------
-- SIDEBAR
-------------------------------------------------
local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0, 160, 1, -48)
sidebar.Position = UDim2.new(0, 0, 0, 48)
sidebar.BackgroundColor3 = Color3.fromRGB(40, 10, 70)
sidebar.BorderSizePixel = 0
sidebar.ZIndex = 2
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 18)

local sidebarLayout = Instance.new("UIListLayout", sidebar)
sidebarLayout.Padding = UDim.new(0, 8)
sidebarLayout.HorizontalAlignment = Center
sidebarLayout.VerticalAlignment = Top

-------------------------------------------------
-- CONTENT
-------------------------------------------------
local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, -170, 1, -56)
content.Position = UDim2.new(0, 170, 0, 56)
content.BackgroundTransparency = 1

-------------------------------------------------
-- FLOATING BUTTON
-------------------------------------------------
local floatBtn = Instance.new("TextButton")
floatBtn.Size = UDim2.fromOffset(56, 56)
floatBtn.Position = UDim2.fromScale(0.05, 0.5)
floatBtn.Text = "[R]"
floatBtn.Font = Enum.Font.GothamBold
floatBtn.TextSize = 22
floatBtn.TextColor3 = Color3.fromRGB(255, 220, 255)
floatBtn.BackgroundColor3 = Color3.fromRGB(120, 50, 180)
floatBtn.Visible = false
floatBtn.Parent = gui
Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(1, 0)

-------------------------------------------------
-- DRAG FLOAT
-------------------------------------------------
do
    local drag, start, startPos
    floatBtn.InputBegan:Connect(function(i)
        if i.UserInputType == MouseButton1 then
            drag = true
            start = i.Position
            startPos = floatBtn.Position
        end
    end)

    UIS.InputChanged:Connect(function(i)
        if drag and i.UserInputType == MouseMovement then
            local delta = i.Position - start
            floatBtn.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == MouseButton1 then
            drag = false
        end
    end)
end

-------------------------------------------------
-- MINIMIZE / RESTORE
-------------------------------------------------
local minimized = false

local function toggleMinimize()
    minimized = not minimized
    if minimized then
        main.Visible = false
        floatBtn.Visible = true
    else
        main.Visible = true
        floatBtn.Visible = false
    end
end

minimizeBtn.MouseButton1Click:Connect(toggleMinimize)
floatBtn.MouseButton1Click:Connect(toggleMinimize)

-------------------------------------------------
-- CLOSE
-------------------------------------------------
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-------------------------------------------------
-- PUBLIC API (DIPAKAI main.lua)
-------------------------------------------------
local UI = {}

function UI:RegisterTab(name)
    local btn = Instance.new("TextButton", sidebar)
    btn.Size = UDim2.new(1, -16, 0, 36)
    btn.Text = name
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 16
    btn.TextColor3 = Color3.fromRGB(255, 230, 255)
    btn.BackgroundColor3 = Color3.fromRGB(110, 40, 180)
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(150, 80, 220)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(110, 40, 180)
    end)

    return btn
end

function UI:AddToggle(tabBtn, label, callback)
    local t = Instance.new("TextButton", content)
    t.Size = UDim2.new(0, 220, 0, 42)
    t.Text = label .. " : OFF"
    t.Font = Enum.Font.Gotham
    t.TextSize = 14
    t.TextColor3 = Color3.fromRGB(255,255,255)
    t.BackgroundColor3 = Color3.fromRGB(90,30,140)
    t.BorderSizePixel = 0
    Instance.new("UICorner", t).CornerRadius = UDim.new(0, 10)

    local on = false
    t.MouseButton1Click:Connect(function()
        on = not on
        t.Text = label .. (on and " : ON" or " : OFF")
        callback(on)
    end)
end

-------------------------------------------------
-- EXPORT
-------------------------------------------------
_G.RiiHUB_UI = UI
print("[RiiHUB] HomeGui loaded (UI only)")