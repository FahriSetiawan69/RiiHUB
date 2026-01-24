-- ==========================================
-- RiiHUB | HomeGui.lua (Registry Driven UI)
-- ==========================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local lp = Players.LocalPlayer
local guiParent = lp:WaitForChild("PlayerGui")

-- Safety
if not _G.RiiHUB or not _G.RiiHUB.Game then
    warn("[RiiHUB] No game registry found")
    return
end

-- Cleanup old UI
if guiParent:FindFirstChild("RiiHUB_GUI") then
    guiParent.RiiHUB_GUI:Destroy()
end

-- ========================
-- MAIN SCREEN GUI
-- ========================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RiiHUB_GUI"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = guiParent

-- ========================
-- MAIN WINDOW
-- ========================
local Main = Instance.new("Frame")
Main.Size = UDim2.fromScale(0.6, 0.6)
Main.Position = UDim2.fromScale(0.2, 0.2)
Main.BackgroundColor3 = Color3.fromRGB(24, 10, 40)
Main.BackgroundTransparency = 0.05
Main.Parent = ScreenGui
Main.BorderSizePixel = 0
Main.Name = "Main"

local corner = Instance.new("UICorner", Main)
corner.CornerRadius = UDim.new(0, 16)

local stroke = Instance.new("UIStroke", Main)
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(170, 90, 255)

-- ========================
-- TITLE
-- ========================
local Title = Instance.new("TextLabel")
Title.Text = "RiiHUB"
Title.Size = UDim2.new(1, -20, 0, 40)
Title.Position = UDim2.new(0, 10, 0, 5)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(190, 120, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22
Title.Parent = Main

-- ========================
-- SIDEBAR
-- ========================
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 160, 1, -60)
Sidebar.Position = UDim2.new(0, 10, 0, 50)
Sidebar.BackgroundColor3 = Color3.fromRGB(18, 8, 30)
Sidebar.Parent = Main
Sidebar.BorderSizePixel = 0

Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)

-- ========================
-- CONTENT AREA
-- ========================
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -190, 1, -60)
Content.Position = UDim2.new(0, 180, 0, 50)
Content.BackgroundTransparency = 1
Content.Parent = Main

-- ========================
-- HELPERS
-- ========================
local Tabs = {}
local CurrentTab

local function clearContent()
    for _, v in ipairs(Content:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end
end

local function createToggle(parent, text, callback)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 44)
    row.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", row)
    label.Text = text
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Left
    label.TextColor3 = Color3.fromRGB(220, 200, 255)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14

    local toggle = Instance.new("Frame", row)
    toggle.Size = UDim2.new(0, 46, 0, 22)
    toggle.Position = UDim2.new(1, -56, 0.5, -11)
    toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", toggle)
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = UDim2.new(0, 2, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local state = false

    toggle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state

            TweenService:Create(knob, TweenInfo.new(0.2),
                {Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}
            ):Play()

            toggle.BackgroundColor3 = state
                and Color3.fromRGB(160, 90, 255)
                or Color3.fromRGB(60, 60, 60)

            if callback then
                task.spawn(callback, state)
            end
        end
    end)
end

-- ========================
-- BUILD TABS FROM REGISTRY
-- ========================
for tabName, features in pairs(_G.RiiHUB.Game.Tabs) do
    local btn = Instance.new("TextButton")
    btn.Text = tabName
    btn.Size = UDim2.new(1, -10, 0, 36)
    btn.Position = UDim2.new(0, 5, 0, (#Tabs * 40) + 5)
    btn.BackgroundColor3 = Color3.fromRGB(40, 20, 60)
    btn.TextColor3 = Color3.fromRGB(200, 170, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Parent = Sidebar
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    Tabs[tabName] = btn

    btn.MouseButton1Click:Connect(function()
        clearContent()
        CurrentTab = tabName

        local list = Instance.new("UIListLayout", Content)
        list.Padding = UDim.new(0, 6)

        for _, feature in ipairs(features) do
            createToggle(Content, feature.Name, feature.Callback)
        end
    end)
end

-- Auto open first tab
for name, btn in pairs(Tabs) do
    btn:Activate()
    break
end

print("[RiiHUB] HomeGui loaded successfully")