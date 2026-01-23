--====================================================
-- RiiHUB ESPModule (STABLE + CATEGORY FILTER)
-- ESP Aman • Tidak Stuck • Kategori Aktif
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
local function clear(tbl)
    for _,v in pairs(tbl) do
        if typeof(v) == "RBXScriptConnection" then
            v:Disconnect()
        elseif typeof(v) == "Instance" then
            v:Destroy()
        end
    end
    table.clear(tbl)
end

local function state(key)
    return _G.RiiHUB_STATE and _G.RiiHUB_STATE[key]
end

-- =========================
-- PLAYER ESP
-- =========================
local function applyPlayer(player)
    if not ESPModule.Enabled then return end
    if player == LocalPlayer then return end

    local char = player.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end

    local isKiller = player.Team and player.Team.Name == "Killer"

    -- ===== FILTER KATEGORI =====
    if isKiller and not state("KILLER_ESP") then return end
    if (not isKiller) and not state("SURVIVOR_ESP") then return end

    if PlayerHL[player] then return end

    local hl = Instance.new("Highlight")
    hl.Adornee = char
    hl.FillTransparency = 1
    hl.OutlineTransparency = 0
    hl.OutlineColor = isKiller and COLORS.Killer or COLORS.Survivor
    hl.Parent = char
    PlayerHL[player] = hl

    -- ===== NAME + HP =====
    if state("ESP_NAME_HP") then
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
        txt.TextColor3 = hl.OutlineColor

        NameHPConn[player] = RunService.Heartbeat:Connect(function()
            txt.Text = string.format("%s [%d]", player.Name, hum.Health)
        end)
    end
end

local function refreshPlayers()
    clear(PlayerHL)
    clear(NameHPGui)
    clear(NameHPConn)

    for _,p in ipairs(Players:GetPlayers()) do
        applyPlayer(p)
    end
end

-- =========================
-- OBJECT ESP
-- =========================
local function scanObjects()
    clear(ObjectHL)

    for _,v in ipairs(Workspace:GetDescendants()) do
        if not v:IsA("Model") then continue end

        if v.Name == "Generator" and state("GENERATOR_ESP") then
            local hl = Instance.new("Highlight")
            hl.Adornee = v
            hl.FillTransparency = 1
            hl.OutlineTransparency = 0
            hl.OutlineColor = COLORS.Generator
            hl.Parent = v
            ObjectHL[v] = hl

        elseif v.Name == "Palletwrong" and state("PALLET_ESP") then
            local hl = Instance.new("Highlight")
            hl.Adornee = v
            hl.FillTransparency = 1
            hl.OutlineTransparency = 0
            hl.OutlineColor = COLORS.Pallet
            hl.Parent = v
            ObjectHL[v] = hl

        elseif (v.Name == "ExitLever" or v.Name == "ExitGate") and state("GATE_ESP") then
            local hl = Instance.new("Highlight")
            hl.Adornee = v
            hl.FillTransparency = 1
            hl.OutlineTransparency = 0
            hl.OutlineColor = COLORS.Gate
            hl.Parent = v
            ObjectHL[v] = hl
        end
    end
end

-- =========================
-- PUBLIC API (TIDAK DIUBAH)
-- =========================
function ESPModule:Enable()
    if self.Enabled then return end
    self.Enabled = true
    refreshPlayers()
    scanObjects()
end

function ESPModule:Disable()
    if not self.Enabled then return end
    self.Enabled = false
    clear(PlayerHL)
    clear(NameHPGui)
    clear(NameHPConn)
    clear(ObjectHL)
end

return ESPModule