--// ===============================
--// RiiHUB HomeGui FINAL
--// ===============================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

--// ===============================
--// GLOBAL STATE (PERSISTENT)
--// ===============================
_G.RiiHUB_State = _G.RiiHUB_State or {
    ESP = false,
    AimAssist = false,
    Event = false,
    KillerHitbox = false,
    KillerStalk = false,
}

--// ===============================
--// DESTROY OLD GUI (ALWAYS REBUILD)
--// ===============================
local oldGui = PlayerGui:FindFirstChild("RiiHUB_GUI")
if oldGui then
    oldGui:Destroy()
end

--// ===============================
--// MAIN GUI
--// ===============================
local gui = Instance.new("ScreenGui")
gui.Name = "RiiHUB_GUI"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

--// ===============================
--// MAIN FRAME
--// ===============================
local main = Instance.new("Frame", gui)
main.Size = UDim2.fromScale(0.8, 0.55)
main.Position = UDim2.fromScale(0.1, 0.22)
main.BackgroundColor3 = Color3.fromRGB(98, 56, 150)
main.BackgroundTransparency = 0.15
main.Active = true
main.Draggable = true
main.Visible = true

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 22)

--// ===============================
--// TITLE BAR
--// ===============================
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, -60, 0, 60)
title.Position = UDim2.new(0, 30, 0, 0)
title.Text = "RiiHUB PANEL"
title.Font = Enum.Font.GothamBold
title.TextSize = 28
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1

--// ===============================
--// MINIMIZE BUTTON
--// ===============================
local minimize = Instance.new("TextButton", main)
minimize.Size = UDim2.fromOffset(40,40)
minimize.Position = UDim2.new(1, -50, 0, 10)
minimize.Text = "-"
minimize.Font = Enum.Font.GothamBold
minimize.TextSize = 26
minimize.BackgroundColor3 = Color3.fromRGB(120,80,180)
minimize.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", minimize).CornerRadius = UDim.new(1,0)

--// ===============================
--// FLOATING BUTTON
--// ===============================
local floatBtn = Instance.new("TextButton", gui)
floatBtn.Size = UDim2.fromOffset(56,56)
floatBtn.Position = UDim2.fromScale(0.05,0.5)
floatBtn.Text = "Rii"
floatBtn.Font = Enum.Font.GothamBold
floatBtn.TextSize = 20
floatBtn.Visible = false
floatBtn.Active = true
floatBtn.Draggable = true
floatBtn.BackgroundColor3 = Color3.fromRGB(120,80,180)
floatBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(1,0)

--// ===============================
--// TAB PANEL
--// ===============================
local tabPanel = Instance.new("Frame", main)
tabPanel.Size = UDim2.new(0, 160, 1, -70)
tabPanel.Position = UDim2.new(0, 10, 0, 60)
tabPanel.BackgroundTransparency = 1

local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, -190, 1, -80)
content.Position = UDim2.new(0, 180, 0, 70)
content.BackgroundTransparency = 1

--// ===============================
--// UTIL
--// ===============================
local function clearContent()
    for _,v in ipairs(content:GetChildren()) do
        if v:IsA("GuiObject") then
            v:Destroy()
        end
    end
end

local function makeTab(text, order)
    local b = Instance.new("TextButton", tabPanel)
    b.Size = UDim2.new(1, -10, 0, 48)
    b.Position = UDim2.new(0, 5, 0, (order-1)*54)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 16
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(120,80,180)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,14)
    return b
end

local function makeToggle(label, stateKey, callback)
    local btn = Instance.new("TextButton", content)
    btn.Size = UDim2.new(0, 280, 0, 52)
    btn.Position = UDim2.new(0, 10, 0, (#content:GetChildren())*60)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 16
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,14)

    local function refresh()
        btn.Text = label .. " : " .. (_G.RiiHUB_State[stateKey] and "ON" or "OFF")
        btn.BackgroundColor3 = _G.RiiHUB_State[stateKey]
            and Color3.fromRGB(70,170,120)
            or Color3.fromRGB(140,90,200)
    end

    refresh()

    btn.MouseButton1Click:Connect(function()
        _G.RiiHUB_State[stateKey] = not _G.RiiHUB_State[stateKey]
        refresh()
        if callback then callback(_G.RiiHUB_State[stateKey]) end
    end)
end

--// ===============================
--// TABS
--// ===============================
local tabESP = makeTab("ESP",1)
local tabSur = makeTab("Selamat",2)
local tabEvent = makeTab("Event",3)
local tabKill = makeTab("Pembunuh",4)

tabESP.MouseButton1Click:Connect(function()
    clearContent()
    makeToggle("ESP", "ESP", _G.ToggleESP)
end)

tabSur.MouseButton1Click:Connect(function()
    clearContent()
    makeToggle("Aim Assist", "AimAssist", _G.ToggleAimAssist)
end)

tabEvent.MouseButton1Click:Connect(function()
    clearContent()
    makeToggle("Event Mode", "Event", _G.ToggleEvent)
end)

tabKill.MouseButton1Click:Connect(function()
    clearContent()
    makeToggle("Hitbox Survivor", "KillerHitbox", _G.ToggleKillerHitbox)
    makeToggle("Stalk Assist", "KillerStalk", _G.ToggleKillerStalk)
end)

--// ===============================
--// MINIMIZE LOGIC
--// ===============================
minimize.MouseButton1Click:Connect(function()
    main.Visible = false
    floatBtn.Visible = true
end)

floatBtn.MouseButton1Click:Connect(function()
    main.Visible = true
    floatBtn.Visible = false
end)

print("RiiHUB HomeGui FINAL loaded successfully")
