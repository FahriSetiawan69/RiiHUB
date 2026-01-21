--==================================================
-- ESPModule (Fixed)
--==================================================
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace  = game:GetService("Workspace")

local ESPModule = {}
ESPModule.Enabled = false
ESPModule.PlayerHighlights = {}
ESPModule.GeneratorHighlights = {}

local COLORS = {
    Survivor  = Color3.fromRGB(0,255,120),
    Killer    = Color3.fromRGB(255,70,70),
    Generator = Color3.fromRGB(255,220,80),
}

local LocalPlayer = Players.LocalPlayer

-- Cleanup helpers
local function removePlayerHighlight(player)
    if ESPModule.PlayerHighlights[player] then
        for _,v in ipairs(ESPModule.PlayerHighlights[player]) do
            v:Destroy()
        end
        ESPModule.PlayerHighlights[player] = nil
    end
end

local function removeAllGenerators()
    for _,v in ipairs(ESPModule.GeneratorHighlights) do
        v:Destroy()
    end
    table.clear(ESPModule.GeneratorHighlights)
end

-- Create highlight for one player
local function addPlayerHighlight(player)
    if player == LocalPlayer then return end
    removePlayerHighlight(player)

    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end

    ESPModule.PlayerHighlights[player] = {}

    local char = player.Character
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health > 0 then
        local hl = Instance.new("Highlight")
        hl.Adornee = char
        hl.FillTransparency = 1
        hl.OutlineTransparency = 0
        hl.OutlineColor = (player.Team and player.Team.Name == "Killer")
                         and COLORS.Killer or COLORS.Survivor
        hl.Parent = char
        table.insert(ESPModule.PlayerHighlights[player], hl)
    end
end

-- Create generator highlights
local function addGeneratorHighlights()
    removeAllGenerators()
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

-- Update loop (runs while Enabled)
local function refreshAll()
    for _,p in ipairs(Players:GetPlayers()) do
        addPlayerHighlight(p)
    end
    addGeneratorHighlights()
end

-- Enable ESP
function ESPModule:Enable()
    if ESPModule.Enabled then return end
    ESPModule.Enabled = true

    refreshAll()

    ESPModule.playerAddedConn = Players.PlayerAdded:Connect(function(p)
        if ESPModule.Enabled then
            addPlayerHighlight(p)
        end
    end)

    ESPModule.playerRemovingConn = Players.PlayerRemoving:Connect(function(p)
        removePlayerHighlight(p)
    end)
end

-- Disable ESP
function ESPModule:Disable()
    ESPModule.Enabled = false

    if ESPModule.playerAddedConn then
        ESPModule.playerAddedConn:Disconnect()
    end
    if ESPModule.playerRemovingConn then
        ESPModule.playerRemovingConn:Disconnect()
    end

    for p,_ in pairs(ESPModule.PlayerHighlights) do
        removePlayerHighlight(p)
    end
    removeAllGenerators()
end

-- export
_G.ESPModule = ESPModule
return ESPModule