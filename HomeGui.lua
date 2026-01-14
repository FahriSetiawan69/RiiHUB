--==================================================
-- RiiHUB HomeGui (Purple Transparent UI | Delta Safe)
--==================================================

if _G.RiiHUB_GUI_LOADED then return end
_G.RiiHUB_GUI_LOADED = true

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- DESTROY OLD GUI IF EXISTS
pcall(function()
    local old = PlayerGui:FindFirstChild("RiiHUB_GUI")
    if old then old:Destroy() end
end)

-- ROOT GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RiiHUB_GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = PlayerGui

-- MAIN CONTAINER
local Main = Instance.new("Frame")
Main.Size = UDim2.fromScale(0.85, 0.75)
Main.Position = UDim2.fromScale(0.5, 0.5)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = Color3.fromRGB(90, 50, 130)
Main.BackgroundTransparency = 0.25
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local UICorner = Instance.new("UICorner", Main)
UICorner.CornerRadius = UDim.new(0, 18)

-- LEFT PANEL (TABS)
local Tabs = Instance.new("Frame")
Tabs.Size = UDim2.new(0.3, 0, 1, 0)
Tabs.BackgroundColor3 = Color3.fromRGB(70, 35, 110)
Tabs.BackgroundTransparency = 0.2
Tabs.BorderSizePixel = 0
Tabs.Parent = Main

Instance.new("UICorner", Tabs).CornerRadius = UDim.new(0, 18)

-- RIGHT PANEL (CONTENT)
local Content = Instance.new("Frame")
Content.Position = UDim2.new(0.3, 0, 0, 0)
Content.Size = UDim2.new(0.7, 0, 1, 0)
Content.BackgroundTransparency = 1
Content.Parent = Main

-- TITLE
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "RiiHUB"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 26
Title.TextColor3 = Color3.fromRGB(240, 220, 255)
Title.Parent = Tabs

-- TAB LIST
local TabList = Instance.new("UIListLayout")
TabList.Padding = UDim.new(0, 8)
TabList.SortOrder = Enum.SortOrder.LayoutOrder
TabList.Parent = Tabs
TabList.VerticalAlignment = Enum.VerticalAlignment.Top

TabList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Tabs.CanvasSize = UDim2.new(0,0,0,TabList.AbsoluteContentSize.Y)
end)

-- CONTENT LIST
local ContentList = Instance.new("UIListLayout")
ContentList.Padding = UDim.new(0, 10)
ContentList.SortOrder = Enum.SortOrder.LayoutOrder
ContentList.Parent = Content

-- HELPERS
local function createTab(text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 42)
    btn.Position = UDim2.new(0, 10, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(120, 70, 170)
    btn.BackgroundTransparency = 0.35
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 18
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    btn.Parent = Tabs
    return btn
end

local function createToggle(text, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -20, 0, 45)
    holder.BackgroundTransparency = 1
    holder.Parent = Content

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.Font = Enum.Font.Gotham
    label.TextSize = 18
    label.TextColor3 = Color3.fromRGB(240, 220, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = holder

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0.25, 0, 0.7, 0)
    toggle.Position = UDim2.new(0.75, 0, 0.15, 0)
    toggle.BackgroundColor3 = Color3.fromRGB(120, 70, 170)
    toggle.Text = "OFF"
    toggle.TextColor3 = Color3.fromRGB(255,255,255)
    toggle.Font = Enum.Font.GothamBold
    toggle.TextSize = 16
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(1,0)
    toggle.Parent = holder

    local state = false
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.Text = state and "ON" or "OFF"
        toggle.BackgroundColor3 = state
            and Color3.fromRGB(170, 90, 255)
            or Color3.fromRGB(120, 70, 170)
        callback(state)
    end)
end

-- MODULES
local ESP = _G.ESPModule
local AIM = _G.AimAssistModule
local EVENT = _G.EventModule
local KILLER = _G.KillerModule
local STALK = _G.StalkAssistModule

-- TABS
local tabCombat = createTab("Combat")
local tabVisual = createTab("Visual")
local tabMisc = createTab("Misc")

-- CLEAR CONTENT
local function clearContent()
    for _,v in ipairs(Content:GetChildren()) do
        if not v:IsA("UIListLayout") then v:Destroy() end
    end
end

-- TAB ACTIONS
tabCombat.MouseButton1Click:Connect(function()
    clearContent()
    createToggle("Aim Assist", function(v)
        if AIM then (v and AIM.Enable or AIM.Disable)(AIM) end
    end)
    createToggle("Killer Mode", function(v)
        if KILLER then (v and KILLER.Enable or KILLER.Disable)(KILLER) end
    end)
    createToggle("Stalk Assist", function(v)
        if STALK then (v and STALK.Enable or STALK.Disable)(STALK) end
    end)
end)

tabVisual.MouseButton1Click:Connect(function()
    clearContent()
    createToggle("ESP", function(v)
        if ESP then (v and ESP.Enable or ESP.Disable)(ESP) end
    end)
end)

tabMisc.MouseButton1Click:Connect(function()
    clearContent()
    createToggle("Event Helper", function(v)
        if EVENT then (v and EVENT.Enable or EVENT.Disable)(EVENT) end
    end)
end)

print("[RiiHUB] HomeGui loaded successfully")
