-- HOMEGUI.LUA (RiiHUB Purple Neon Edition)
local GUI = { Tabs = {} }
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- 1. MAIN CONTAINER
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "RiiHUB_V2_Modular"

-- Frame Utama (Background Sangat Gelap ala Sixter)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 500, 0, 320)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.BorderSizePixel = 0
local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 8)

-- Glow/Shadow Effect (Neon Purple)
local Glow = Instance.new("ImageLabel", MainFrame)
Glow.Name = "Glow"
Glow.BackgroundTransparency = 1
Glow.Position = UDim2.new(0, -15, 0, -15)
Glow.Size = UDim2.new(1, 30, 1, 30)
Glow.ZIndex = 0
Glow.Image = "rbxassetid://4996891999" -- Shadow asset
Glow.ImageColor3 = Color3.fromRGB(160, 32, 240) -- Purple Neon
Glow.ScaleType = Enum.ScaleType.Slice
Glow.SliceCenter = Rect.new(20, 20, 280, 280)

-- 2. SIDEBAR (Kiri)
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 140, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Sidebar.BorderSizePixel = 0
local SidebarCorner = Instance.new("UICorner", Sidebar)
SidebarCorner.CornerRadius = UDim.new(0, 8)

-- Logo / Title RiiHUB
local Title = Instance.new("TextLabel", Sidebar)
Title.Size = UDim2.new(1, 0, 0, 45)
Title.Text = "RiiHUB"
Title.TextColor3 = Color3.fromRGB(191, 0, 255) -- Neon Purple
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.BackgroundTransparency = 1

-- Container untuk Tombol Fitur (Scrolling)
local TabContainer = Instance.new("ScrollingFrame", Sidebar)
TabContainer.Size = UDim2.new(1, 0, 1, -55)
TabContainer.Position = UDim2.new(0, 0, 0, 50)
TabContainer.BackgroundTransparency = 1
TabContainer.BorderSizePixel = 0
TabContainer.CanvasSize = UDim2.new(0, 0, 1.2, 0)
TabContainer.ScrollBarThickness = 0

local Layout = Instance.new("UIListLayout", TabContainer)
Layout.Padding = UDim.new(0, 4)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- 3. CONTENT AREA (Kanan)
local Content = Instance.new("Frame", MainFrame)
Content.Size = UDim2.new(1, -155, 1, -15)
Content.Position = UDim2.new(0, 145, 0, 7)
Content.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
Instance.new("UICorner", Content).CornerRadius = UDim.new(0, 6)

-- 4. FUNGSI CREATE TAB
local function AddTab(fileName, displayName, icon)
    local TabBtn = Instance.new("TextButton", TabContainer)
    TabBtn.Size = UDim2.new(0.92, 0, 0, 32)
    TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TabBtn.Text = "  " .. (displayName or fileName)
    TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabBtn.Font = Enum.Font.Gotham
    TabBtn.TextSize = 13
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.BorderSizePixel = 0
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 4)

    -- Indicator Line (Neon Purple)
    local Ind = Instance.new("Frame", TabBtn)
    Ind.Size = UDim2.new(0, 2, 0.5, 0)
    Ind.Position = UDim2.new(0, 0, 0.25, 0)
    Ind.BackgroundColor3 = Color3.fromRGB(191, 0, 255)
    Ind.Visible = false

    -- Hover & Click logic
    TabBtn.MouseEnter:Connect(function() 
        TabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        Ind.Visible = true 
    end)
    TabBtn.MouseLeave:Connect(function() 
        TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        Ind.Visible = false 
    end)

    GUI.Tabs[fileName] = TabBtn
    return TabBtn
end

-- 5. MENDAFTARKAN FITUR SESUAI REPOSITORY ANDA
-- Pastikan key (argumen pertama) sama persis dengan nama file di GitHub
AddTab("AimAssistModule.lua", "🎯 Aim Assist")
AddTab("ESPModule.lua", "👁️ Visuals / ESP")
AddTab("EventModule.lua", "📡 Events")
AddTab("HitBoxKiller.lua", "📏 Hitbox Expander")
AddTab("SkillCheckGenerator.lua", "⚙️ Auto Skillcheck")

-- Draggable UI Logic (Untuk Mobile)
local dragStart, startPos, dragging
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

return GUI
