--==================================================
-- RiiHUB HomeGui (FINAL FIX - SAFE RE-EXECUTE)
--==================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--==================================================
-- STATE (PERSIST SELAMA CLIENT HIDUP)
--==================================================
_G.RiiHUB_STATE = _G.RiiHUB_STATE or {
    ESP = false,
    AIM = false,
    EVENT = false,
    KILLER = false,
    STALK = false,
    UI_OPEN = false,
    FLOAT_POS = UDim2.fromScale(0.05, 0.5),
}

--==================================================
-- DESTROY OLD GUI (WAJIB)
--==================================================
pcall(function()
    local old = PlayerGui:FindFirstChild("RiiHUB_GUI")
    if old then old:Destroy() end
end)

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
FloatBtn.Size = UDim2.fromOffset(60,60)
FloatBtn.Position = _G.RiiHUB_STATE.FLOAT_POS
FloatBtn.Text = "≡"
FloatBtn.Font = Enum.Font.GothamBold
FloatBtn.TextSize = 28
FloatBtn.TextColor3 = Color3.fromRGB(255,255,255)
FloatBtn.BackgroundColor3 = Color3.fromRGB(140,90,220)
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
Main.Size = UDim2.fromScale(0.7,0.6)
Main.Position = UDim2.fromScale(0.5,0.5)
Main.AnchorPoint = Vector2.new(0.5,0.5)
Main.BackgroundColor3 = Color3.fromRGB(90,50,140)
Main.BackgroundTransparency = 0.25
Main.Visible = _G.RiiHUB_STATE.UI_OPEN
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,18)

-- OPEN / CLOSE
FloatBtn.MouseButton1Click:Connect(function()
    _G.RiiHUB_STATE.UI_OPEN = not _G.RiiHUB_STATE.UI_OPEN
    Main.Visible = _G.RiiHUB_STATE.UI_OPEN
end)

--==================================================
-- SIMPLE TOGGLE
--==================================================
local function createToggle(text, stateKey, module)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(1,-20,0,40)
    btn.Position = UDim2.new(0,10,0,10 + (#Main:GetChildren()-1)*45)
    btn.BackgroundColor3 = Color3.fromRGB(120,70,170)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 18
    Instance.new("UICorner", btn)

    local function refresh()
        btn.Text = text..": "..(_G.RiiHUB_STATE[stateKey] and "ON" or "OFF")
    end
    refresh()

    btn.MouseButton1Click:Connect(function()
        _G.RiiHUB_STATE[stateKey] = not _G.RiiHUB_STATE[stateKey]
        refresh()
        if module then
            (_G.RiiHUB_STATE[stateKey] and module.Enable or module.Disable)(module)
        end
    end)
end

--==================================================
-- MODULE REFERENCES
--==================================================
createToggle("ESP",    "ESP",    _G.ESPModule)
createToggle("AIM",    "AIM",    _G.AimAssistModule)
createToggle("EVENT",  "EVENT",  _G.EventModule)
createToggle("KILLER", "KILLER", _G.KillerModule)
createToggle("STALK",  "STALK",  _G.StalkAssistModule)

-- RE-ENABLE ACTIVE MODULES
for k, m in pairs({
    ESP=_G.ESPModule,
    AIM=_G.AimAssistModule,
    EVENT=_G.EventModule,
    KILLER=_G.KillerModule,
    STALK=_G.StalkAssistModule
}) do
    if _G.RiiHUB_STATE[k] and m then
        pcall(function() m:Enable() end)
    end
end

print("[RiiHUB] HomeGui loaded (safe re-execute)")
