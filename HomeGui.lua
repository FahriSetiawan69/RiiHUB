-- HOMEGUI.LUA (RiiHUB Purple Neon - Grouped Sidebar Edition)
local GUI = { Tabs = {} }
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- CONFIGURATION
local LogoID = "rbxassetid://123119175840490"
local AccentColor = Color3.fromRGB(191, 0, 255) -- Ungu Neon

-- 1. MAIN CONTAINER
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "RiiHUB_V2_Modular"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 520, 0, 330)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -165)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- Neon Glow Effect
local Glow = Instance.new("ImageLabel", MainFrame)
Glow.BackgroundTransparency = 1
Glow.Position = UDim2.new(0, -15, 0, -15)
Glow.Size = UDim2.new(1, 30, 1, 30)
Glow.ZIndex = 0
Glow.Image = "rbxassetid://4996891999"
Glow.ImageColor3 = AccentColor
Glow.ScaleType = Enum.ScaleType.Slice
Glow.SliceCenter = Rect.new(20, 20, 280, 280)

-- 2. SIDEBAR
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 140, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Sidebar.BorderSizePixel = 0
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

local TabList = Instance.new("UIListLayout", Sidebar)
TabList.Padding = UDim.new(0, 5)
TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local LogoLabel = Instance.new("ImageLabel", Sidebar)
LogoLabel.Size = UDim2.new(0, 60, 0, 60)
LogoLabel.BackgroundTransparency = 1
LogoLabel.Image = LogoID
LogoLabel.LayoutOrder = -1

-- 3. CONTENT AREA
local PageContainer = Instance.new("Frame", MainFrame)
PageContainer.Size = UDim2.new(1, -155, 1, -40)
PageContainer.Position = UDim2.new(0, 145, 0, 35)
PageContainer.BackgroundTransparency = 1

-- 4. FLOATING & TOP BAR
local FloatingBtn = Instance.new("ImageButton", ScreenGui)
FloatingBtn.Size = UDim2.new(0, 55, 0, 55)
FloatingBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
FloatingBtn.Image = LogoID
FloatingBtn.Visible = false
Instance.new("UICorner", FloatingBtn).CornerRadius = UDim.new(1, 0)
local FloatStroke = Instance.new("UIStroke", FloatingBtn)
FloatStroke.Color = AccentColor
FloatStroke.Thickness = 2

local MiniBtn = Instance.new("TextButton", MainFrame)
MiniBtn.Size = UDim2.new(0, 30, 0, 30)
MiniBtn.Position = UDim2.new(1, -65, 0, 5)
MiniBtn.Text = "−"
MiniBtn.TextColor3 = Color3.new(1, 1, 1)
MiniBtn.BackgroundTransparency = 1
MiniBtn.TextSize = 20

local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextSize = 20

-- 5. TAB & TOGGLE SYSTEM
local Pages = {}
local CurrentPage = nil

local function CreatePage(name)
    local Page = Instance.new("ScrollingFrame", PageContainer)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 2
    Page.CanvasSize = UDim2.new(0, 0, 1.5, 0)
    Instance.new("UIListLayout", Page).Padding = UDim.new(0, 8)
    
    local TabBtn = Instance.new("TextButton", Sidebar)
    TabBtn.Size = UDim2.new(0.9, 0, 0, 35)
    TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TabBtn.Text = name
    TabBtn.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    TabBtn.Font = Enum.Font.Gotham
    Instance.new("UICorner", TabBtn)

    TabBtn.Activated:Connect(function()
        if CurrentPage then CurrentPage.Visible = false end
        Page.Visible = true
        CurrentPage = Page
    end)
    
    Pages[name] = Page
    return Page
end

local function AddToggle(parentPage, text, fileName)
    local Frame = Instance.new("Frame", parentPage)
    Frame.Size = UDim2.new(0.95, 0, 0, 40)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Instance.new("UICorner", Frame)
    
    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.Text = text
    Label.TextColor3 = Color3.new(1, 1, 1)
    Label.BackgroundTransparency = 1
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local Btn = Instance.new("TextButton", Frame)
    Btn.Size = UDim2.new(0, 60, 0, 25)
    Btn.Position = UDim2.new(1, -70, 0.5, -12)
    Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Btn.Text = "OFF"
    Btn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", Btn)

    local active = false
    Btn.Activated:Connect(function()
        active = not active
        Btn.Text = active and "ON" or "OFF"
        Btn.BackgroundColor3 = active and AccentColor or Color3.fromRGB(40, 40, 40)
        
        -- Triger Load Module dari Loader.lua
        if GUI.Tabs[fileName] then
            GUI.Tabs[fileName]:GetCallback()(active) 
        end
    end)
    
    -- Daftarkan ke GUI.Tabs agar Loader.lua bisa memberikan callback
    GUI.Tabs[fileName] = {
        Button = Btn,
        SetCallback = function(self, cb) self.callback = cb end,
        GetCallback = function(self) return self.callback or function() end end
    }
end

-- 6. SETUP TABS (Berdasarkan Permintaanmu)
local ESPPage = CreatePage("ESP")
AddToggle(ESPPage, "Enable ESP", "ESPModule.lua")

local SurvPage = CreatePage("Survivor")
AddToggle(SurvPage, "Aim Assist", "AimAssistModule.lua")
AddToggle(SurvPage, "Hitbox Expander", "HitBoxKiller.lua")
AddToggle(SurvPage, "Auto Skillcheck", "SkillCheckGenerator.lua")

local KillerPage = CreatePage("Killer")
-- Kosong (Sesuai Permintaan)

local OtherPage = CreatePage("Other")
AddToggle(OtherPage, "Event Module", "EventModule.lua")

-- Default Page
ESPPage.Visible = true
CurrentPage = ESPPage

-- 7. DRAGGABLE & SYSTEM LOGIC
local function MakeDraggable(obj)
    local dragging, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true dragStart = input.Position startPos = obj.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

MakeDraggable(MainFrame)
MakeDraggable(FloatingBtn)

MiniBtn.Activated:Connect(function() MainFrame.Visible = false FloatingBtn.Visible = true end)
FloatingBtn.Activated:Connect(function() MainFrame.Visible = true FloatingBtn.Visible = false end)
CloseBtn.Activated:Connect(function() ScreenGui:Destroy() end)

return GUI
