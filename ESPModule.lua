--====================================================
-- RiiHUB ESPModule (FINAL • REACTIVE CATEGORY)
-- Per-kategori REALTIME • Tidak Stuck • Stabil
--====================================================

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace  = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local ESPModule = {}
ESPModule.Enabled = false

-- =========================
-- STORAGE
-- =========================
local PlayerHL   = {}
local NameHPGui  = {}
local NameHPConn = {}
local ObjectHL   = {}
local UpdateConn = nil

-- =========================
-- COLORS
-- =========================
local COLORS = {
    Survivor  = Color3.fromRGB(0,255,120),
    Killer    = Color3.fromRGB(255,70,70),
    Generator = Color3.fromRGB(255,220,80),
    Pallet    = Color3.fromRGB(255,140,0),
    Gate      = Color3.fromRGB(80,120,255),
}

-- =========================
-- UTILS
-- =========================
local function state(key)
    return _G.RiiHUB_STATE and _G.RiiHUB_STATE[key] == true
end

local function destroy(map)
    for _,v in pairs(map) do
        if typeof(v) == "RBXScriptConnection" then
            v:Disconnect()
        elseif typeof(v) == "Instance" then
            v:Destroy()
        end
    end
    table.clear(map)
end

-- =========================
-- PLAYER UPDATE (REACTIVE)
-- =========================
local function updatePlayers()
    if not ESPModule.Enabled then return end

    for _,player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end

        local char = player.Character
        if not char then
            if PlayerHL[player] then
                PlayerHL[player]:Destroy()
                PlayerHL[player] = nil
            end
            continue
        end

        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then
            if PlayerHL[player] then
                PlayerHL[player]:Destroy()
                PlayerHL[player] = nil
            end
            continue
        end

        local isKiller = player.Team and player.Team.Name == "Killer"

        local allowed =
            (isKiller and state("KILLER_ESP")) or
            (not isKiller and state("SURVIVOR_ESP"))

        -- =========================
        -- OUTLINE
        -- =========================
        if allowed then
            if not PlayerHL[player] then
                local hl = Instance.new("Highlight")
                hl.Adornee = char
                hl.FillTransparency = 1
                hl.OutlineTransparency = 0
                hl.OutlineColor = isKiller and COLORS.Killer or COLORS.Survivor
                hl.Parent = char
                PlayerHL[player] = hl
            else
                PlayerHL[player].OutlineColor = isKiller and COLORS.Killer or COLORS.Survivor
            end
        else
            if PlayerHL[player] then
                PlayerHL[player]:Destroy()
                PlayerHL[player] = nil
            end
        end

        -- =========================
        -- NAME + HP
        -- =========================
        if allowed and state("ESP_NAME_HP") then
            if not NameHPGui[player] then
                local tag = Instance.new("BillboardGui")
                tag.Adornee = char:FindFirstChild("Head") or char.PrimaryPart
                tag.AlwaysOnTop = true
                tag.Size = UDim2.new(0,140,0,28)
                tag.Parent = char
                NameHPGui[player] = tag

                local txt = Instance.new("TextLabel", tag)
                txt.Size = UDim2.fromScale(1,1)
                txt.BackgroundTransparency = 1
                txt.Font = Enum.Font.SourceSansBold
                txt.TextSize = 14
                txt.TextStrokeTransparency = 0
                txt.TextColor3 = isKiller and COLORS.Killer or COLORS.Survivor

                NameHPConn[player] = RunService.Heartbeat:Connect(function()
                    txt.Text = string.format("%s [%d]", player.Name, hum.Health)
                end)
            end
        else
            if NameHPGui[player] then
                NameHPGui[player]:Destroy()
                NameHPGui[player] = nil
            end
            if NameHPConn[player] then
                NameHPConn[player]:Disconnect()
                NameHPConn[player] = nil
            end
        end
    end
end

-- =========================
-- OBJECT ESP (ON DEMAND)
-- =========================
local function updateObjects()
    destroy(ObjectHL)

    if not ESPModule.Enabled then return end

    for _,v in ipairs(Workspace:GetDescendants()) do
        if not v:IsA("Model") then continue end

        local color

        if v.Name == "Generator" and state("GENERATOR_ESP") then
            color = COLORS.Generator
        elseif v.Name == "Palletwrong" and state("PALLET_ESP") then
            color = COLORS.Pallet
        elseif (v.Name == "ExitGate" or v.Name == "ExitLever") and state("GATE_ESP") then
            color = COLORS.Gate
        end

        if color then
            local hl = Instance.new("Highlight")
            hl.Adornee = v
            hl.FillTransparency = 1
            hl.OutlineTransparency = 0
            hl.OutlineColor = color
            hl.Parent = v
            ObjectHL[v] = hl
        end
    end
end

-- =========================
-- PUBLIC API
-- =========================
function ESPModule:Enable()
    if self.Enabled then return end
    self.Enabled = true

    UpdateConn = RunService.Heartbeat:Connect(function()
        updatePlayers()
    end)

    updateObjects()
end

function ESPModule:Disable()
    if not self.Enabled then return end
    self.Enabled = false

    if UpdateConn then
        UpdateConn:Disconnect()
        UpdateConn = nil
    end

    destroy(PlayerHL)
    destroy(NameHPGui)
    destroy(NameHPConn)
    destroy(ObjectHL)
end

return ESPModule