--==================================================
-- RiiHUB HomeGui AUTO-PERSIST FINAL
-- Delta Mobile Safe | Drag Floating Button
--==================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--==================================================
-- GLOBAL STATE (PERSIST ACROSS MAP)
--==================================================
_G.RiiHUB_STATE = _G.RiiHUB_STATE or {
    ESP = false,
    AIM = false,
    EVENT = false,
    KILLER = false,
    STALK = false,
    NEON = true,
    UI_OPEN = false,
    FLOAT_POS = UDim2.fromScale(0.05, 0.5),
}

--==================================================
-- DESTROY OLD GUI IF PLAYERGUI RESET
--==================================================
local function clearOld()
    local old = PlayerGui:FindFirstChild("RiiHUB_GUI")
    if old then old:Destroy() end
end

clearOld()

--==================================================
-- ROOT GUI
--==================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RiiHUB_GUI"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = PlayerGui

--==================================================
-- FLOATING BUTTON (DRAGGABLE)
--==================================================
local FloatBtn = Instance.new("TextButton")
FloatBtn.Size = UDim2.fromOffset(60, 60)
FloatBtn.Position = _G.RiiHUB_STATE.FLOAT_POS
FloatBtn.Text = "≡"
FloatBtn.Font = Enum.Font.GothamBold
FloatBtn.TextSize = 28
FloatBtn.TextColor3 = Color3.fromRGB(255,255,255)
FloatBtn.BackgroundColor3 = Color3.fromRGB(140, 90, 220)
FloatBtn.BackgroundTransparency = 0.15
FloatBtn.Parent = ScreenGui
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1,0)

-- DRAG FLOAT BUTTON
do
    local dragging, startPos, dragStart
    FloatBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = FloatBtn.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            FloatBtn.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
            _G.RiiHUB_STATE.FLOAT_POS = FloatBtn.Position
        end
    end)

    UserInputService.InputEnded:Connect(function()
        dragging = false
    end)
end

--==================================================
-- MAIN PANEL
--==================================================
local Main = Instance.new("Frame")
Main.Size = UDim2.fromScale(0.85, 0.75)
Main.Position = UDim2.fromScale(0.5, 0.5)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = Color3.fromRGB(90, 50, 140)
Main.BackgroundTransparency = 0.25
Main.Visible = false
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,18)

-- DRAG MAIN PANEL
do
    local dragging, startPos, dragStart
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function()
        dragging = false
    end)
end

--==================================================
-- OPEN / CLOSE ANIMATION
--==================================================
local function toggleMain(state)
    Main.Visible = true
    TweenService:Create(Main, TweenInfo.new(0.3), {
        Size = state and UDim2.fromScale(0.85,0.75) or UDim2.fromScale(0,0),
        BackgroundTransparency = state and 0.25 or 1
    }):Play()

    task.delay(0.3, function()
        if not state then Main.Visible = false end
    end)
end

FloatBtn.MouseButton1Click:Connect(function()
    _G.RiiHUB_STATE.UI_OPEN = not _G.RiiHUB_STATE.UI_OPEN
    toggleMain(_G.RiiHUB_STATE.UI_OPEN)
end)

--==================================================
-- CONTENT
--==================================================
local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, -30, 1, -30)
Content.Position = UDim2.new(0, 15, 0, 15)
Content.BackgroundTransparency = 1

local Layout = Instance.new("UIListLayout", Content)
Layout.Padding = UDim.new(0,10)

--==================================================
-- THEME
--==================================================
local function applyTheme()
    Main.BackgroundColor3 = _G.RiiHUB_STATE.NEON
        and Color3.fromRGB(150,90,255)
        or Color3.fromRGB(70,40,120)
end

--==================================================
-- TOGGLE CREATOR
--==================================================
local function createToggle(name, key, module)
    local btn = Instance.new("TextButton", Content)
    btn.Size = UDim2.new(1, 0, 0, 45)
    btn.BackgroundColor3 = Color3.fromRGB(120,70,170)
    btn.BackgroundTransparency = 0.35
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 18
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,12)

    local function refresh()
        btn.Text = name.." : "..(_G.RiiHUB_STATE[key] and "ON" or "OFF")
        btn.BackgroundColor3 = _G.RiiHUB_STATE[key]
            and Color3.fromRGB(170,90,255)
            or Color3.fromRGB(120,70,170)
    end

    refresh()

    btn.MouseButton1Click:Connect(function()
        _G.RiiHUB_STATE[key] = not _G.RiiHUB_STATE[key]
        refresh()
        if module then
            (_G.RiiHUB_STATE[key] and module.Enable or module.Disable)(module)
        end
    end)
end

--==================================================
-- MODULE REFERENCES
--==================================================
local ESP = _G.ESPModule
local AIM = _G.AimAssistModule
local EVENT = _G.EventModule
local KILLER = _G.KillerModule
local STALK = _G.StalkAssistModule

--==================================================
-- BUILD UI
--==================================================
createToggle("ESP", "ESP", ESP)
createToggle("Aim Assist", "AIM", AIM)
createToggle("Event Helper", "EVENT", EVENT)
createToggle("Killer Mode", "KILLER", KILLER)
createToggle("Stalk Assist", "STALK", STALK)

createToggle("Neon Theme", "NEON", {
    Enable = applyTheme,
    Disable = applyTheme
})

applyTheme()

--==================================================
-- AUTO RE-ENABLE MODULES AFTER MAP CHANGE
--==================================================
for key, module in pairs({
    ESP = ESP,
    AIM = AIM,
    EVENT = EVENT,
    KILLER = KILLER,
    STALK = STALK
}) do
    if _G.RiiHUB_STATE[key] and module then
        pcall(function() module:Enable() end)
    end
end

--==================================================
-- AUTO-RECREATE GUI ON RESPAWN / MAP CHANGE
--==================================================
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if not PlayerGui:FindFirstChild("RiiHUB_GUI") then
        loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/HomeGui.lua"
        ))()
    end
end)

print("[RiiHUB] HomeGui auto-persist loaded")
