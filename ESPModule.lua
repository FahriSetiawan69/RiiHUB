--====================================================
-- RiiHUB ESPModule (FINAL FIX)
-- ON/OFF BERSIH • TOGGLE TERPISAH • OPTIMIZED
--====================================================

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace  = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local ESP = {}

-- =========================
-- STATE
-- =========================
ESP.Enabled = false
ESP.Flags = {
    Survivor  = false,
    Killer    = false,
    Generator = false,
    Pallet    = false,
    Gate      = false,
    NameHP    = false,
}

-- =========================
-- STORAGE
-- =========================
local PlayerESP  = {}
local PlayerConn = {}
local ObjectESP  = {}
local ScanThread = nil

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
local function clearTable(t)
    for k,v in pairs(t) do
        if typeof(v) == "RBXScriptConnection" then
            v:Disconnect()
        elseif typeof(v) == "Instance" then
            v:Destroy()
        end
        t[k] = nil
    end
end

-- =========================
-- PLAYER ESP
-- =========================
local function removePlayer(player)
    if PlayerESP[player] then
        PlayerESP[player]:Destroy()
        PlayerESP[player] = nil
    end
    if PlayerConn[player] then
        PlayerConn[player]:Disconnect()
        PlayerConn[player] = nil
    end
end

local function applyPlayer(player)
    if not ESP.Enabled or player == LocalPlayer then return end

    removePlayer(player)

    local char = player.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end

    local isKiller = player.Team and player.Team.Name == "Killer"

    if isKiller and not ESP.Flags.Killer then return end
    if not isKiller and not ESP.Flags.Survivor then return end

    local hl = Instance.new("Highlight")
    hl.Adornee = char
    hl.FillTransparency = 1
    hl.OutlineTransparency = 0
    hl.OutlineColor = isKiller and COLORS.Killer or COLORS.Survivor
    hl.Parent = char

    PlayerESP[player] = hl

    -- ===== NAME + HP =====
    if ESP.Flags.NameHP then
        local tag = Instance.new("BillboardGui")
        tag.Name = "Rii_NameHP"
        tag.Adornee = char:FindFirstChild("Head") or char.PrimaryPart
        tag.AlwaysOnTop = true
        tag.Size = UDim2.new(0,130,0,28)
        tag.Parent = char

        local txt = Instance.new("TextLabel", tag)
        txt.Size = UDim2.fromScale(1,1)
        txt.BackgroundTransparency = 1
        txt.Font = Enum.Font.SourceSansBold
        txt.TextSize = 14
        txt.TextStrokeTransparency = 0
        txt.TextColor3 = hl.OutlineColor

        PlayerConn[player] = RunService.Heartbeat:Connect(function()
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
local function removeObject(obj)
    if ObjectESP[obj] then
        ObjectESP[obj]:Destroy()
        ObjectESP[obj] = nil
    end
end

local function applyObject(obj, color)
    if ObjectESP[obj] then return end

    local hl = Instance.new("Highlight")
    hl.Adornee = obj
    hl.FillTransparency = 1
    hl.OutlineTransparency = 0
    hl.OutlineColor = color
    hl.Parent = obj

    ObjectESP[obj] = hl
end

local function scanObjects()
    if not ESP.Enabled then return end

    for _,v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Model") then
            if v.Name == "Generator" then
                if ESP.Flags.Generator then
                    applyObject(v, COLORS.Generator)
                else
                    removeObject(v)
                end

            elseif v.Name == "Palletwrong" then
                if ESP.Flags.Pallet then
                    applyObject(v, COLORS.Pallet)
                else
                    removeObject(v)
                end

            elseif v.Name == "ExitLever" or v.Name == "ExitGate" then
                if ESP.Flags.Gate then
                    applyObject(v, COLORS.Gate)
                else
                    removeObject(v)
                end
            end
        end
    end
end

-- =========================
-- SCAN LOOP (OPTIMIZED)
-- =========================
local function startScan()
    if ScanThread then return end
    ScanThread = task.spawn(function()
        while ESP.Enabled do
            scanObjects()
            task.wait(1)
        end
        ScanThread = nil
    end)
end

-- =========================
-- PUBLIC API
-- =========================
function ESP:Enable()
    if self.Enabled then return end
    self.Enabled = true
    refreshPlayers()
    startScan()
end

function ESP:Disable()
    if not self.Enabled then return end
    self.Enabled = false

    clearTable(PlayerESP)
    clearTable(PlayerConn)
    clearTable(ObjectESP)
end

function ESP:Set(flag, state)
    if self.Flags[flag] == nil then return end
    self.Flags[flag] = state

    if not self.Enabled then return end

    -- ===== OFF → BERSIHKAN =====
    if not state then
        if flag == "Survivor" or flag == "Killer" or flag == "NameHP" then
            clearTable(PlayerESP)
            clearTable(PlayerConn)
        end

        if flag == "Generator" or flag == "Pallet" or flag == "Gate" then
            clearTable(ObjectESP)
        end
    end

    refreshPlayers()
    scanObjects()
end

return ESP