--========================================
-- RiiHUB HomeGui (FINAL FIX)
-- ESP / Survivor / Event / Killer
--========================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--==============================
-- LOAD MODULES (SAFE)
--==============================
local ESPModule, AimModule, EventModule

pcall(function()
    ESPModule = require(game:GetService("ReplicatedStorage"):WaitForChild("ESPModule"))
end)

pcall(function()
    AimModule = require(game:GetService("ReplicatedStorage"):WaitForChild("AimAssistModule"))
end)

pcall(function()
    EventModule = require(game:GetService("ReplicatedStorage"):WaitForChild("EventModule"))
end)

--==============================
-- STATE (PERSISTENT)
--==============================
local state = {
    ESP = false,
    AIM = false,
    EVENT = false
}

--==============================
-- GUI ROOT
--==============================
local gui = Instance.new("ScreenGui")
gui.Name = "RiiHUB_GUI"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

--==============================
-- MAIN FRAME
--==============================
local main = Instance.new("Frame", gui)
main.Size = UDim2.fromOffset(520, 320)
main.Position = UDim2.fromScale(0.5, 0.5)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = Color3.fromRGB(80, 45, 130)
main.BackgroundTransparency = 0.05
main.BorderSizePixel = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)

--==============================
-- LEFT MENU
--==============================
local left = Instance.new("Frame", main)
left.Size = UDim2.fromOffset(130, 320)
left.BackgroundColor3 = Color3.fromRGB(60, 35, 100)
left.BorderSizePixel = 0

--==============================
-- RIGHT PANEL
--==============================
local right = Instance.new("Frame", main)
right.Position = UDim2.fromOffset(130, 0)
right.Size = UDim2.fromOffset(390, 320)
right.BackgroundTransparency = 1

--==============================
-- UTIL
--==============================
local function clearRight()
    for _,v in ipairs(right:GetChildren()) do
        v:Destroy()
    end
end

local function makeMenuButton(text)
    local b = Instance.new("TextButton", left)
    b.Size = UDim2.new(1, -10, 0, 36)
    b.Position = UDim2.fromOffset(5, (#left:GetChildren()-1)*42 + 10)
    b.Text = text
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 15
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(120, 70, 180)
    b.BorderSizePixel = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    return b
end

local function makeToggle(y, labelText, getState, onToggle)
    local label = Instance.new("TextLabel", right)
    label.Size = UDim2.new(1, -20, 0, 26)
    label.Position = UDim2.fromOffset(10, y)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 14
    label.TextColor3 = Color3.new(1,1,1)

    local btn = Instance.new("TextButton", right)
    btn.Size = UDim2.fromOffset(160, 34)
    btn.Position = UDim2.fromOffset(10, y + 30)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 14
    btn.TextColor3 = Color3.new(1,1,1)
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local function refresh()
        local on = getState()
        btn.Text = on and "ON" or "OFF"
        btn.BackgroundColor3 = on and Color3.fromRGB(0,180,120) or Color3.fromRGB(120,70,180)
    end

    refresh()

    btn.MouseButton1Click:Connect(function()
        onToggle()
        refresh()
    end)
end

--==============================
-- MENU BUTTONS
--==============================
local espBtn   = makeMenuButton("ESP")
local survBtn  = makeMenuButton("Survivor")
local eventBtn = makeMenuButton("Event")

--==============================
-- ESP PANEL
--==============================
espBtn.MouseButton1Click:Connect(function()
    clearRight()
    makeToggle(10, "ESP", function() return state.ESP end, function()
        state.ESP = not state.ESP
        if _G.ToggleESP then
            _G.ToggleESP(state.ESP)
        elseif ESPModule then
            if state.ESP then ESPModule.Enable() else ESPModule.Disable() end
        end
    end)
end)

--==============================
-- SURVIVOR (AIM)
--==============================
survBtn.MouseButton1Click:Connect(function()
    clearRight()
    makeToggle(10, "Aim Assist", function() return state.AIM end, function()
        state.AIM = not state.AIM
        if AimModule then
            AimModule.SetEnabled(state.AIM)
        end
    end)
end)

--==============================
-- EVENT PANEL (FIXED)
--==============================
eventBtn.MouseButton1Click:Connect(function()
    clearRight()
    makeToggle(10, "Christmas Event", function() return state.EVENT end, function()
        state.EVENT = not state.EVENT
        if EventModule then
            if state.EVENT then
                EventModule.Enable()
            else
                EventModule.Disable()
            end
        end
    end)
end)

--==============================
-- DEFAULT TAB
--==============================
espBtn:Activate()
