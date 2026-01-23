--====================================================
-- RiiHUB ESPModule (STABLE BASE + NameHP FIX)
-- Toggle Aman • Tidak Stuck • Minimal Change
--====================================================

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace  = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local ESPModule = {}

-- =========================
-- STATE
-- =========================
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

-- =========================
-- PLAYER ESP
-- =========================
local function applyPlayer(player)
    if player == LocalPlayer then return end
    if not ESPModule.Enabled then return end

    local char = player.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end

    local isKiller = player.Team and player.Team.Name == "Killer"

    if PlayerHL[player] then return end

    local hl = Instance.new("Highlight")
    hl.Adornee = char
    hl.FillTransparency = 1
    hl.OutlineTransparency = 0
    hl.OutlineColor = isKiller and COLORS.Killer or COLORS.Survivor
    hl.Parent = char
    PlayerHL[player] = hl

    -- ===== NAME + HP =====
    if _G.RiiHUB_STATE and _G.RiiHUB_STATE.ESP_NAME_HP then
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
            if hum.Health > 0 then
                txt.Text = string.format("%s [%d]", player.Name, hum.Health)
            end
        end)
    end
end

local function refreshPlayers()
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
        if v:IsA("Model") then
            local color

            if v.Name == "Generator" then
                color = COLORS.Generator
            elseif v.Name == "Palletwrong" then
                color = COLORS.Pallet
            elseif v.Name == "ExitLever" or v.Name == "ExitGate" then
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
end

-- =========================
-- PUBLIC API (TIDAK BERUBAH)
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
    clear(ObjectHL)

    -- ⬇⬇⬇ FIX UTAMA NAME & HP ⬇⬇⬇
    clear(NameHPGui)
    clear(NameHPConn)
end

return ESPModule