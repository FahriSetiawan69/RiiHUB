-- RiiHUB HomeGui.lua (FIXED)
-- ESP GLOBAL REMOVED (Per-category control only)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

if PlayerGui:FindFirstChild("RiiHUB_GUI") then
    PlayerGui.RiiHUB_GUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RiiHUB_GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

-- =========================
-- UI ROOT
-- =========================
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.fromScale(0.85, 0.85)
Main.Position = UDim2.fromScale(0.5, 0.5)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = Color3.fromRGB(45, 20, 65)
Main.BorderSizePixel = 0

local UICorner = Instance.new("UICorner", Main)
UICorner.CornerRadius = UDim.new(0, 18)

-- =========================
-- SIDEBAR
-- =========================
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.fromScale(0.18, 1)
Sidebar.BackgroundColor3 = Color3.fromRGB(30, 12, 50)
Sidebar.BorderSizePixel = 0

local Tabs = {
    "ESP",
    "SURVIVOR",
    "KILLER",
    "OTHER"
}

local selectedTab = "ESP"
local tabButtons = {}

local function createTab(name, order)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(1, 0, 0, 50)
    btn.Position = UDim2.new(0, 0, 0, (order - 1) * 55 + 20)
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.TextColor3 = Color3.new(1,1,1)
    btn.BackgroundColor3 = Color3.fromRGB(60, 30, 90)
    btn.BorderSizePixel = 0

    btn.MouseButton1Click:Connect(function()
        selectedTab = name
        updatePanel()
    end)

    tabButtons[name] = btn
end

for i,tab in ipairs(Tabs) do
    createTab(tab, i)
end

-- =========================
-- CONTENT PANEL
-- =========================
local Panel = Instance.new("Frame", Main)
Panel.Position = UDim2.fromScale(0.2, 0.05)
Panel.Size = UDim2.fromScale(0.78, 0.9)
Panel.BackgroundTransparency = 1

local function clearPanel()
    for _,v in ipairs(Panel:GetChildren()) do
        v:Destroy()
    end
end

-- =========================
-- TOGGLE MAKER
-- =========================
local function makeToggle(text, flag, module)
    local btn = Instance.new("TextButton", Panel)
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(90, 50, 140)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Text = text
    btn.BorderSizePixel = 0

    local state = false

    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. " : " .. (state and "ON" or "OFF")
        if module and module.Set then
            module:Set(flag, state)
        end
    end)
end

-- =========================
-- UPDATE PANEL
-- =========================
function updatePanel()
    clearPanel()

    if selectedTab == "ESP" then
        local info = Instance.new("TextLabel", Panel)
        info.Size = UDim2.new(1,0,0,40)
        info.Text = "ESP dikontrol per kategori."
        info.Font = Enum.Font.Gotham
        info.TextSize = 14
        info.TextColor3 = Color3.fromRGB(200,180,255)
        info.BackgroundTransparency = 1

    elseif selectedTab == "SURVIVOR" then
        makeToggle("Survivor ESP", "Survivor", _G.ESPModule)
        makeToggle("Nama + HP", "NameHP", _G.ESPModule)

    elseif selectedTab == "KILLER" then
        makeToggle("Killer ESP", "Killer", _G.ESPModule)

    elseif selectedTab == "OTHER" then
        makeToggle("Generator ESP", "Generator", _G.ESPModule)
        makeToggle("Pallet ESP", "Pallet", _G.ESPModule)
        makeToggle("Gate ESP", "Gate", _G.ESPModule)
    end
end

updatePanel()