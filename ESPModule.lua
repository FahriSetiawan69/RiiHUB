-- ESPModule.lua (Delta Safe / With Enable/Disable)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local ESPModule = {}
ESPModule.Enabled = false
ESPModule.PlayerHighlights = {}
ESPModule.GeneratorHighlights = {}

local COLORS = {
    Survivor = Color3.fromRGB(0,255,120),
    Killer = Color3.fromRGB(255,70,70),
    Generator = Color3.fromRGB(255,220,80),
}

local LocalPlayer = Players.LocalPlayer

-- Utility Functions
local function clearPlayerESP(player)
    if ESPModule.PlayerHighlights[player] then
        for _,v in ipairs(ESPModule.PlayerHighlights[player]) do
            v:Destroy()
        end
        ESPModule.PlayerHighlights[player] = nil
    end
end

local function clearGeneratorESP()
    for _,v in ipairs(ESPModule.GeneratorHighlights) do
        v:Destroy()
    end
    table.clear(ESPModule.GeneratorHighlights)
end

local function createPlayerESP(player)
    if player == LocalPlayer then return end
    clearPlayerESP(player)

    if not player.Character then
        return
    end

    local char = player.Character
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")

    if not hum or hum.Health <= 0 or not root then
        return
    end

    ESPModule.PlayerHighlights[player] = {}

    local isKiller = (player.Team and player.Team.Name == "Killer")

    local hl = Instance.new("Highlight")
    hl.Adornee = char
    hl.FillTransparency = 1
    hl.OutlineTransparency = 0
    hl.OutlineColor = isKiller and COLORS.Killer or COLORS.Survivor
    hl.Parent = char

    table.insert(ESPModule.PlayerHighlights[player], hl)
end

local function createGeneratorESP()
    clearGeneratorESP()
    for _,obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == "Generator" then
            local hl = Instance.new("Highlight")
            hl.Adornee = obj
            hl.FillTransparency = 1
            hl.OutlineTransparency = 0
            hl.OutlineColor = COLORS.Generator
            hl.Parent = obj

            table.insert(ESPModule.GeneratorHighlights, hl)
        end
    end
end

-- Enable Function
function ESPModule:Enable()
    ESPModule.Enabled = true

    for _,p in ipairs(Players:GetPlayers()) do
        createPlayerESP(p)
    end

    createGeneratorESP()

    Players.PlayerAdded:Connect(function(p)
        createPlayerESP(p)
    end)

    Players.PlayerRemoving:Connect(function(p)
        clearPlayerESP(p)
    end)
end

-- Disable Function
function ESPModule:Disable()
    ESPModule.Enabled = false

    for _,p in ipairs(Players:GetPlayers()) do
        clearPlayerESP(p)
    end

    clearGeneratorESP()
end

--==================================================
-- FLASHLIGHT CROSSHAIR (VISUAL ONLY)
-- DOES NOT AFFECT ESP LOGIC
--==================================================

task.spawn(function()
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

    -- Prevent duplicate
    if PlayerGui:FindFirstChild("Flashlight_Crosshair_GUI") then
        return
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "Flashlight_Crosshair_GUI"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 3000
    gui.Parent = PlayerGui

    -- Crosshair container
    local crosshair = Instance.new("Frame")
    crosshair.Size = UDim2.fromOffset(18, 18)
    crosshair.Position = UDim2.fromScale(0.5, 0.5)
    crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
    crosshair.BackgroundTransparency = 1
    crosshair.Parent = gui

    local function line(size, pos)
        local l = Instance.new("Frame")
        l.Size = size
        l.Position = pos
        l.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        l.BorderSizePixel = 0
        l.Parent = crosshair
    end

    -- Vertical
    line(UDim2.fromOffset(2, 18), UDim2.fromOffset(8, 0))
    -- Horizontal
    line(UDim2.fromOffset(18, 2), UDim2.fromOffset(0, 8))

    print("[ESPModule] Flashlight crosshair loaded (visual only)")
end)

-- EXPORT MODULE
_G.ESPModule = ESPModule
return ESPModule

