-- HomeGui.lua (FINAL SAFE)

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local pgui = lp:WaitForChild("PlayerGui")

-- Tunggu data game
repeat task.wait() until _G.RiiHUB and _G.RiiHUB.Game and _G.RiiHUB.Game.Sidebar

-- Cegah double UI
if pgui:FindFirstChild("RiiHUB_UI") then
    pgui.RiiHUB_UI:Destroy()
end

-- ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "RiiHUB_UI"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Parent = pgui

-- Main Frame
local main = Instance.new("Frame", gui)
main.Size = UDim2.fromScale(0.75, 0.6)
main.Position = UDim2.fromScale(0.125, 0.2)
main.BackgroundColor3 = Color3.fromRGB(40, 10, 70)
main.BackgroundTransparency = 0.05
main.BorderSizePixel = 0
main.Name = "Main"

local corner = Instance.new("UICorner", main)
corner.CornerRadius = UDim.new(0, 18)

-- Title
local title = Instance.new("TextLabel", main)
title.Size = UDim2.fromScale(1, 0.08)
title.BackgroundTransparency = 1
title.Text = "RiiHUB - " .. (_G.RiiHUB.Game.Name or "Unknown")
title.TextColor3 = Color3.fromRGB(190, 120, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 22

-- Sidebar
local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.fromScale(0.18, 0.92)
sidebar.Position = UDim2.fromScale(0, 0.08)
sidebar.BackgroundColor3 = Color3.fromRGB(30, 5, 55)
sidebar.BorderSizePixel = 0

local list = Instance.new("UIListLayout", sidebar)
list.Padding = UDim.new(0, 8)

-- Content
local content = Instance.new("Frame", main)
content.Size = UDim2.fromScale(0.82, 0.92)
content.Position = UDim2.fromScale(0.18, 0.08)
content.BackgroundTransparency = 1

-- Generate Sidebar Buttons
for _, tabName in ipairs(_G.RiiHUB.Game.Sidebar) do
    local btn = Instance.new("TextButton", sidebar)
    btn.Size = UDim2.fromScale(1, 0.08)
    btn.Text = tabName
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.TextColor3 = Color3.fromRGB(220, 180, 255)
    btn.BackgroundColor3 = Color3.fromRGB(60, 20, 100)
    btn.BorderSizePixel = 0

    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0, 10)

    btn.MouseButton1Click:Connect(function()
        print("[RiiHUB] Tab selected :", tabName)
        -- nanti di sini kamu sambungkan ke module
    end)
end

print("[RiiHUB] HomeGui loaded successfully")