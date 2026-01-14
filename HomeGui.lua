--==================================================
-- RiiHUB HomeGui ADVANCED
-- Drag + Floating Button + Animation + Neon Theme
--==================================================

if _G.RiiHUB_GUI_LOADED then return end
_G.RiiHUB_GUI_LOADED = true

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- DESTROY OLD GUI
pcall(function()
    local old = PlayerGui:FindFirstChild("RiiHUB_GUI")
    if old then old:Destroy() end
end)

--==================================================
-- ROOT GUI
--==================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RiiHUB_GUI"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = PlayerGui

--==================================================
-- FLOATING BUTTON
--==================================================
local FloatBtn = Instance.new("TextButton")
FloatBtn.Size = UDim2.fromOffset(60,60)
FloatBtn.Position = UDim2.fromScale(0.02,0.5)
FloatBtn.Text = "≡"
FloatBtn.Font = Enum.Font.GothamBold
FloatBtn.TextSize = 28
FloatBtn.TextColor3 = Color3.fromRGB(255,255,255)
FloatBtn.BackgroundColor3 = Color3.fromRGB(130,80,200)
FloatBtn.BackgroundTransparency = 0.15
FloatBtn.Parent = ScreenGui
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1,0)

--==================================================
-- MAIN PANEL
--==================================================
local Main = Instance.new("Frame")
Main.Size = UDim2.fromScale(0.85,0.75)
Main.Position = UDim2.fromScale(0.5,0.5)
Main.AnchorPoint = Vector2.new(0.5,0.5)
Main.BackgroundColor3 = Color3.fromRGB(90,50,140)
Main.BackgroundTransparency = 0.25
Main.Visible = false
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,18)

-- SHOW / HIDE ANIMATION
local function toggleMain(state)
    Main.Visible = true
    local goal = {
        Size = state and UDim2.fromScale(0.85,0.75) or UDim2.fromScale(0,0),
        BackgroundTransparency = state and 0.25 or 1
    }
    TweenService:Create(Main, TweenInfo.new(0.35, Enum.EasingStyle.Quad), goal):Play()
    task.delay(0.35, function()
        if not state then Main.Visible = false end
    end)
end

local open = false
FloatBtn.MouseButton1Click:Connect(function()
    open = not open
    toggleMain(open)
end)

--==================================================
-- DRAG FUNCTION (MOBILE + PC)
--==================================================
do
    local dragging, dragStart, startPos
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function()
        dragging = false
    end)
end

--==================================================
-- PANELS
--==================================================
local Tabs = Instance.new("Frame", Main)
Tabs.Size = UDim2.new(0.3,0,1,0)
Tabs.BackgroundColor3 = Color3.fromRGB(70,35,110)
Tabs.BackgroundTransparency = 0.25
Tabs.BorderSizePixel = 0
Instance.new("UICorner", Tabs).CornerRadius = UDim.new(0,18)

local Content = Instance.new("Frame", Main)
Content.Position = UDim2.new(0.3,0,0,0)
Content.Size = UDim2.new(0.7,0,1,0)
Content.BackgroundTransparency = 1

--==================================================
-- THEME MODE (NEON / DARK)
--==================================================
local neon = true
local function applyTheme()
    local color = neon and Color3.fromRGB(150,90,255) or Color3.fromRGB(80,50,120)
    Main.BackgroundColor3 = color
    FloatBtn.BackgroundColor3 = color
end

--==================================================
-- HELPERS
--==================================================
local function clearContent()
    for _,v in ipairs(Content:GetChildren()) do
        if not v:IsA("UIListLayout") then v:Destroy() end
    end
end

local function createToggle(text, callback)
    local btn = Instance.new("TextButton", Content)
    btn.Size = UDim2.new(1,-20,0,45)
    btn.BackgroundColor3 = Color3.fromRGB(120,70,170)
    btn.BackgroundTransparency = 0.35
    btn.Text = text.." : OFF"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 18
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,12)

    local on = false
    btn.MouseButton1Click:Connect(function()
        on = not on
        btn.Text = text.." : "..(on and "ON" or "OFF")
        TweenService:Create(btn,TweenInfo.new(0.2),{
            BackgroundColor3 = on and Color3.fromRGB(170,90,255) or Color3.fromRGB(120,70,170)
        }):Play()
        callback(on)
    end)
end

--==================================================
-- MODULES
--==================================================
local ESP = _G.ESPModule
local AIM = _G.AimAssistModule
local EVENT = _G.EventModule
local KILLER = _G.KillerModule
local STALK = _G.StalkAssistModule

--==================================================
-- DEFAULT CONTENT
--==================================================
local layout = Instance.new("UIListLayout", Content)
layout.Padding = UDim.new(0,10)

createToggle("ESP", function(v)
    if ESP then (v and ESP.Enable or ESP.Disable)(ESP) end
end)

createToggle("Aim Assist", function(v)
    if AIM then (v and AIM.Enable or AIM.Disable)(AIM) end
end)

createToggle("Killer Mode", function(v)
    if KILLER then (v and KILLER.Enable or KILLER.Disable)(KILLER) end
end)

createToggle("Stalk Assist", function(v)
    if STALK then (v and STALK.Enable or STALK.Disable)(STALK) end
end)

createToggle("Neon Theme", function(v)
    neon = v
    applyTheme()
end)

applyTheme()

print("[RiiHUB] Advanced HomeGui loaded successfully")
