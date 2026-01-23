--====================================================
-- RiiHUB ESPModule (FIXED, NO AUTO-ON, SAFE)
--====================================================

local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local Workspace   = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local ESPModule = {}
ESPModule.Enabled = false

-- =========================
-- STORAGE
-- =========================
local PlayerESP = {}
local ObjectESP = {}
local Connections = {}

-- =========================
-- COLORS (LOGIKA LAMA TETAP)
-- =========================
local COLORS = {
    Survivor  = Color3.fromRGB(0, 255, 120),
    Killer    = Color3.fromRGB(255, 70, 70),
    Generator = Color3.fromRGB(255, 220, 80),
    Pallet    = Color3.fromRGB(255, 140, 0),
    Gate      = Color3.fromRGB(80, 120, 255),
}

-- =========================
-- CLEANUP
-- =========================
local function clearTable(t)
    for k,v in pairs(t) do
        if typeof(v) == "Instance" then
            v:Destroy()
        elseif typeof(v) == "RBXScriptConnection" then
            v:Disconnect()
        end
        t[k] = nil
    end
end

-- =========================
-- PLAYER ESP (LOGIKA LAMA)
-- =========================
local function createPlayerESP(player)
    if not ESPModule.Enabled then return end
    if player == LocalPlayer then return end
    if PlayerESP[player] then return end

    local function apply(character)
        if not ESPModule.Enabled then return end
        if not character then return end

        local hum = character:FindFirstChildOfClass("Humanoid")
        local root = character:FindFirstChild("HumanoidRootPart")
        if not hum or hum.Health <= 0 or not root then return end

        local isKiller = player.Team and player.Team.Name == "Killer"

        local hl = Instance.new("Highlight")
        hl.Adornee = character
        hl.FillTransparency = 1
        hl.OutlineTransparency = 0
        hl.OutlineColor = isKiller and COLORS.Killer or COLORS.Survivor
        hl.Parent = character

        PlayerESP[player] = hl
    end

    if player.Character then
        apply(player.Character)
    end

    Connections[player] = player.CharacterAdded:Connect(apply)
end

local function removePlayerESP(player)
    if PlayerESP[player] then
        PlayerESP[player]:Destroy()
        PlayerESP[player] = nil
    end

    if Connections[player] then
        Connections[player]:Disconnect()
        Connections[player] = nil
    end
end

-- =========================
-- OBJECT ESP (GEN / PALLET / GATE)
-- =========================
local function createObjectESP(obj, color)
    if ObjectESP[obj] then return end

    local hl = Instance.new("Highlight")
    hl.Adornee = obj
    hl.FillTransparency = 1
    hl.OutlineTransparency = 0
    hl.OutlineColor = color
    hl.Parent = obj

    ObjectESP[obj] = hl

    obj.AncestryChanged:Connect(function(_, parent)
        if not parent and ObjectESP[obj] then
            ObjectESP[obj]:Destroy()
            ObjectESP[obj] = nil
        end
    end)
end

local function scanObjects()
    for _,v in ipairs(Workspace:GetDescendants()) do
        if not ESPModule.Enabled then return end

        if v:IsA("Model") then
            if v.Name == "Generator" then
                createObjectESP(v, COLORS.Generator)

            elseif v.Name == "Palletwrong" then
                createObjectESP(v, COLORS.Pallet)

            elseif v.Name == "ExitLever" or v.Name == "ExitGate" then
                createObjectESP(v, COLORS.Gate)
            end
        end
    end
end

-- =========================
-- ENABLE
-- =========================
function ESPModule:Enable()
    if self.Enabled then return end
    self.Enabled = true
    print("[ESPModule] Enabled")

    -- Player ESP
    for _,p in ipairs(Players:GetPlayers()) do
        createPlayerESP(p)
    end

    Connections.playerAdded = Players.PlayerAdded:Connect(createPlayerESP)
    Connections.playerRemoving = Players.PlayerRemoving:Connect(removePlayerESP)

    -- Object ESP
    scanObjects()
    Connections.descendantAdded = Workspace.DescendantAdded:Connect(function()
        if ESPModule.Enabled then
            scanObjects()
        end
    end)
end

-- =========================
-- DISABLE
-- =========================
function ESPModule:Disable()
    if not self.Enabled then return end
    self.Enabled = false
    print("[ESPModule] Disabled")

    clearTable(PlayerESP)
    clearTable(ObjectESP)
    clearTable(Connections)
end

return ESPModule