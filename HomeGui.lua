-- HOMEGUI.LUA
local GUI = { Tabs = {} }
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- 1. MAIN CONTAINER
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "RiiHUB_V2_Sixter"

-- Frame Utama
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 550, 0, 350)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15) -- Gelap ala Sixter
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 6)

-- Glow Effect (Neon Ungu)
local Shadow = Instance.new("Frame", MainFrame)
Shadow.ZIndex = 0
Shadow.Size = UDim2.new(1, 10, 1, 10)
Shadow.Position = UDim2.new(0, -5, 0, -5)
Shadow.BackgroundColor3 = Color3.fromRGB(138, 43, 226) -- Purple Neon
Shadow.BackgroundTransparency = 0.8
Instance.new("UICorner", Shadow).CornerRadius = UDim.new(0, 10)

-- 2. SIDEBAR
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 150, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Sidebar.BorderSizePixel = 0
local SidebarCorner = Instance.new("UICorner", Sidebar)
SidebarCorner.CornerRadius = UDim.new(0, 6)

-- Logo / Title
local Logo = Instance.new("TextLabel", Sidebar)
Logo.Size = UDim2.new(1, 0, 0, 50)
Logo.Text = "RiiHUB"
Logo.TextColor3 = Color3.fromRGB(191, 0, 255) -- Neon Purple
Logo.Font = Enum.Font.GothamBold
Logo.TextSize = 22
Logo.BackgroundTransparency = 1

-- Tab Container (Scrolling)
local TabContainer = Instance.new("ScrollingFrame", Sidebar)
TabContainer.Size = UDim2.new(1, 0, 1, -60)
TabContainer.Position = UDim2.new(0, 0, 0, 50)
TabContainer.BackgroundTransparency = 1
TabContainer.BorderSizePixel = 0
TabContainer.CanvasSize = UDim2.new(0, 0, 1.5, 0)
TabContainer.ScrollBarVisibility = Enum.ScrollBarVisibility.Never

local Layout = Instance.new("UIListLayout", TabContainer)
Layout.Padding = UDim.new(0, 2)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- 3. CONTENT AREA
local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Size = UDim2.new(1, -160, 1, -20)
ContentFrame.Position = UDim2.new(0, 155, 0, 10)
ContentFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Instance.new("UICorner", ContentFrame)

-- 4. TAB CREATION FUNCTION
local function CreateTab(fileName, displayName, icon)
    local TabBtn = Instance.new("TextButton", TabContainer)
    TabBtn.Size = UDim2.new(0.9, 0, 0, 35)
    TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TabBtn.BorderSizePixel = 0
    TabBtn.Text = "  " .. (displayName or fileName)
    TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.Font = Enum.Font.Gotham
    TabBtn.TextSize = 14
    
    local Corner = Instance.new("UICorner", TabBtn)
    Corner.CornerRadius = UDim.new(0, 4)

    -- Indicator Line (Neon Ungu di samping tombol)
    local Indicator = Instance.new("Frame", TabBtn)
    Indicator.Size = UDim2.new(0, 3, 0.6, 0)
    Indicator.Position = UDim2.new(0, 0, 0.2, 0)
    Indicator.BackgroundColor3 = Color3.fromRGB(191, 0, 255)
    Indicator.Visible = false

    -- Hover & Click Effects
    TabBtn.MouseEnter:Connect(function()
        TabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        Indicator.Visible = true
    end)
    TabBtn.MouseLeave:Connect(function()
        TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Indicator.Visible = false
    end)

    GUI.Tabs[fileName] = TabBtn
    return TabBtn
end

-- 5. DAFTAR FITUR (Samakan dengan file di GitHub kamu)
CreateTab("Main", "🏠 Main")
CreateTab("AimAssistModule.lua", "🎯 Aim Assist")
CreateTab("ESPModule.lua", "👁️ Visuals")
CreateTab("FlashlightMod.lua", "🔦 Flashlight") -- Senter yang kita buat
CreateTab("HitBoxKiller.lua", "📏 Hitbox")
CreateTab("SkillCheckGenerator.lua", "⚙️ Generator")
CreateTab("TeleportModule.lua", "🌀 Teleport")
CreateTab("Settings", "⚙️ Settings")

-- Dragging Logic (Agar UI bisa digeser di HP)
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

print("RiiHUB HomeGui Loaded Successfully!")
return GUI
