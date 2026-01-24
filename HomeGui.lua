-- HomeGui.lua (FINAL)

-- ⛔ JANGAN AUTO RETURN
repeat task.wait() until _G.RiiHUB and _G.RiiHUB.Game

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local guiParent = player:WaitForChild("PlayerGui")

-- CLEAN OLD
pcall(function()
    guiParent.RiiHUB:Destroy()
end)

local ScreenGui = Instance.new("ScreenGui", guiParent)
ScreenGui.Name = "RiiHUB"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.fromScale(0.65,0.6)
Main.Position = UDim2.fromScale(0.5,0.5)
Main.AnchorPoint = Vector2.new(0.5,0.5)
Main.BackgroundColor3 = Color3.fromRGB(40,10,70)
Main.BorderSizePixel = 0
Main.BackgroundTransparency = 0.05
Main.UICorner = Instance.new("UICorner", Main)
Main.UICorner.CornerRadius = UDim.new(0,20)

-- TITLE
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.fromScale(1,0.1)
Title.Text = "RiiHUB"
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true
Title.TextColor3 = Color3.fromRGB(180,120,255)
Title.BackgroundTransparency = 1

-- SIDEBAR
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.fromScale(0.2,0.9)
Sidebar.Position = UDim2.fromScale(0,0.1)
Sidebar.BackgroundTransparency = 1

-- CONTENT
local Content = Instance.new("Frame", Main)
Content.Size = UDim2.fromScale(0.8,0.9)
Content.Position = UDim2.fromScale(0.2,0.1)
Content.BackgroundTransparency = 1

-- GENERATE SIDEBAR BUTTONS
local y = 0
for _,tabName in ipairs(_G.RiiHUB.Game.Sidebar) do
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.fromScale(1,0.08)
    btn.Position = UDim2.fromScale(0,y)
    btn.Text = tabName
    btn.BackgroundColor3 = Color3.fromRGB(60,20,90)
    btn.TextColor3 = Color3.fromRGB(200,160,255)
    btn.Font = Enum.Font.Gotham
    btn.TextScaled = true
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.UICorner = Instance.new("UICorner", btn)
    y += 0.09
end

TweenService:Create(
    Main,
    TweenInfo.new(0.4, Enum.EasingStyle.Back),
    {Size = UDim2.fromScale(0.75,0.65)}
):Play()

print("[RiiHUB] HomeGui loaded successfully")