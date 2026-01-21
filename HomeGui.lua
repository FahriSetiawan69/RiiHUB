-- HOMEGUI.LUA (RiiHUB Purple Neon - Final Custom Logo Edition)
local GUI = { Tabs = {} }
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- CONFIGURATION
local LogoID = "rbxassetid://123119175840490" -- ID Asset RiiHUB Kamu
local AccentColor = Color3.fromRGB(191, 0, 255) -- Ungu Neon

-- 1. MAIN CONTAINER
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "RiiHUB_V2_Modular"
ScreenGui.ResetOnSpawn = false

-- Frame Utama
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 500, 0, 320)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- Glow Effect (Neon Purple)
local Glow = Instance.new("ImageLabel", MainFrame)
Glow.BackgroundTransparency = 1
Glow.Position = UDim2.new(0, -15, 0, -15)
Glow.Size = UDim2.new(1, 30, 1, 30)
Glow.ZIndex = 0
Glow.Image = "rbxassetid://4996891999"
Glow.ImageColor3 = AccentColor
Glow.ScaleType = Enum.ScaleType.Slice
Glow.SliceCenter = Rect.new(20, 20, 280, 280)

-- 2. FLOATING BUTTON (Minimize Logo)
local FloatingBtn = Instance.new("ImageButton", ScreenGui)
FloatingBtn.Size = UDim2.new(0, 55, 0, 55)
FloatingBtn.Position = UDim2.new(0.05, 0, 0.4, 0) -- Posisi awal kiri tengah
FloatingBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
FloatingBtn.Image = LogoID
FloatingBtn.Visible = false -- Sembunyi saat awal
FloatingBtn.BorderSizePixel = 0
Instance.new("UICorner", FloatingBtn).CornerRadius = UDim.new(1, 0) -- Bulat

local FloatStroke = Instance.new("UIStroke", FloatingBtn)
FloatStroke.Color = AccentColor
FloatStroke.Thickness = 2

-- 3. TOP BAR (Tombol Close & Minimize)
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.Text = "×" -- Simbol Kali
CloseBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 24

local MiniBtn = Instance.new("TextButton", TopBar)
MiniBtn.Size = UDim2.new(0, 30, 0, 30)
MiniBtn.Position = UDim2.new(1, -65, 0, 5)
MiniBtn.Text = "−" -- Simbol Kurang
MiniBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MiniBtn.BackgroundTransparency = 1
MiniBtn.Font = Enum.Font.GothamBold
MiniBtn.TextSize = 24

-- 4. SIDEBAR & TABS
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 145, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Sidebar.BorderSizePixel = 0
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

local TabContainer = Instance.new("ScrollingFrame", Sidebar)
TabContainer.Size = UDim2.new(1, 0, 1, -60)
TabContainer.Position = UDim2.new(0, 0, 0, 55)
TabContainer.BackgroundTransparency = 1
TabContainer.BorderSizePixel = 0
TabContainer.CanvasSize = UDim2.new(0, 0, 1.3, 0)
TabContainer.ScrollBarThickness = 0
Instance.new("UIListLayout", TabContainer).Padding = UDim.new(0, 5)

-- 5. FUNCTIONALITY
-- Close
CloseBtn.Activated:Connect(function()
    ScreenGui:Destroy()
end)

-- Minimize (Ke Floating Logo)
MiniBtn.Activated:Connect(function()
    MainFrame.Visible = false
    FloatingBtn.Visible = true
end)

-- Maximize (Dari Floating Logo)
FloatingBtn.Activated:Connect(function()
    MainFrame.Visible = true
    FloatingBtn.Visible = false
end)

-- Dragging System (Support PC & Mobile)
local function EnableDrag(obj)
    local dragging, dragInput, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = obj.Position
        end
    end)
    obj.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

EnableDrag(MainFrame)
EnableDrag(FloatingBtn)

-- Tab Builder Function
local function AddTab(fileName, displayName)
    local TabBtn = Instance.new("TextButton", TabContainer)
    TabBtn.Size = UDim2.new(0.9, 0, 0, 35)
    TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TabBtn.Text = "  " .. (displayName or fileName)
    TabBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
    TabBtn.Font = Enum.Font.Gotham
    TabBtn.TextSize = 13
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.BorderSizePixel = 0
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 5)

    GUI.Tabs[fileName] = TabBtn
    return TabBtn
end

-- DAFTAR FITUR REPOSITORY
AddTab("AimAssistModule.lua", "🎯 Aim Assist")
AddTab("ESPModule.lua", "👁️ Visuals / ESP")
AddTab("EventModule.lua", "📡 Events")
AddTab("HitBoxKiller.lua", "📏 Hitbox Expander")
AddTab("SkillCheckGenerator.lua", "⚙️ Auto Skillcheck")

return GUI
