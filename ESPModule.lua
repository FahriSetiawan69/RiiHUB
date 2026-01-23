--====================================================
-- RiiHUB ESPModule (FINAL • ANTI STUCK)
-- Toggle Terpisah • ON/OFF Stabil • Optimized
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
local PlayerHL   = {}   -- Highlight per player
local PlayerConn = {}   -- CharacterAdded / HP loop
local NameHPGui  = {}   -- BillboardGui per player
local NameHPConn = {}   -- Heartbeat per player
local ObjectHL   = {}   -- Highlight per object
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
local function clearMap(map)
    for k,v in pairs(map) do
        if typeof(v) == "RBXScriptConnection" then
            v:Disconnect()
        elseif typeof(v) == "Instance" then
            v:Destroy()
        end
        map[k] = nil
    end
end

-- =========================
-- PLAYER HELPERS
-- =========================
local function cleanupPlayer(player)
    if PlayerHL[player] then PlayerHL[player]:Destroy(); PlayerHL[player] = nil end
    if PlayerConn[player] then PlayerConn[player]:Disconnect(); PlayerConn[player] = nil end
    if NameHPGui[player] then NameHPGui[player]:Destroy(); NameHPGui[player] = nil end
    if NameHPConn[player] then NameHPConn[player]:Disconnect(); NameHPConn[player] = nil end
end

local function applyPlayer(player)
    if not ESP.Enabled or player == LocalPlayer then return end

    -- Jangan hapus dulu di sini (anti-stuck)
    local char = player.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end

    local isKiller = player.Team and player.Team.Name == "Killer"
    if isKiller and not ESP.Flags.Killer then return end
    if (not isKiller) and not ESP.Flags.Survivor then return end

    -- ===== OUTLINE =====
    if not PlayerHL[player] then
        local hl = Instance.new("Highlight")
        hl.Adornee = char
        hl.FillTransparency = 1
        hl.OutlineTransparency = 0
        hl.OutlineColor = isKiller and COLORS.Killer or COLORS.Survivor
        hl.Parent = char
        PlayerHL[player] = hl
    else
        -- update warna jika role berubah
        PlayerHL[player].OutlineColor = isKiller and COLORS.Killer or COLORS.Survivor
    end

    -- ===== NAME + HP =====
    if ESP.Flags.NameHP then
        if not NameHPGui[player] then
            local tag = Instance.new("BillboardGui")
            tag.Name = "Rii_NameHP"
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
            txt.TextColor3 = PlayerHL[player].OutlineColor

            NameHPConn[player] = RunService.Heartbeat:Connect(function()
                if hum.Health > 0 then
                    txt.Text = string.format("%s [%d]", player.Name, hum.Health)
                end
            end)
        end
    end
end

local function refreshPlayers()
    for _,p in ipairs(Players:GetPlayers()) do
        applyPlayer(p)
    end
end

-- =========================
-- OBJECT HELPERS
-- =========================
local function removeObject(obj)
    if ObjectHL[obj] then
        ObjectHL[obj]:Destroy()
        ObjectHL[obj] = nil
    end
end

local function applyObject(obj, color)
    if ObjectHL[obj] then return end
    local hl = Instance.new("Highlight")
    hl.Adornee = obj
    hl.FillTransparency = 1
    hl.OutlineTransparency = 0
    hl.OutlineColor = color
    hl.Parent = obj
    ObjectHL[obj] = hl
end

local function scanObjects()
    if not ESP.Enabled then return end
    for _,v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Model") then
            if v.Name == "Generator" then
                ESP.Flags.Generator and applyObject(v, COLORS.Generator) or removeObject(v)
            elseif v.Name == "Palletwrong" then
                ESP.Flags.Pallet and applyObject(v, COLORS.Pallet) or removeObject(v)
            elseif v.Name == "ExitLever" or v.Name == "ExitGate" then
                ESP.Flags.Gate and applyObject(v, COLORS.Gate) or removeObject(v)
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

    -- hook respawn
    for _,p in ipairs(Players:GetPlayers()) do
        PlayerConn[p] = p.CharacterAdded:Connect(function()
            task.wait(0.1)
            applyPlayer(p)
        end)
    end
    PlayerConn._add = Players.PlayerAdded:Connect(function(p)
        PlayerConn[p] = p.CharacterAdded:Connect(function()
            task.wait(0.1)
            applyPlayer(p)
        end)
    end)
    PlayerConn._rem = Players.PlayerRemoving:Connect(function(p)
        cleanupPlayer(p)
    end)

    refreshPlayers()
    startScan()
end

function ESP:Disable()
    if not self.Enabled then return end
    self.Enabled = false

    clearMap(PlayerHL)
    clearMap(PlayerConn)
    clearMap(NameHPGui)
    clearMap(NameHPConn)
    clearMap(ObjectHL)
end

function ESP:Set(flag, state)
    if self.Flags[flag] == nil then return end
    self.Flags[flag] = state
    if not self.Enabled then return end

    -- ===== OFF: BERSIHKAN TERKAIT SAJA =====
    if not state then
        if flag == "NameHP" then
            clearMap(NameHPGui)
            clearMap(NameHPConn)
        elseif flag == "Survivor" or flag == "Killer" then
            -- hapus outline player saja, tanpa ganggu NameHP flag lain
            for p,_ in pairs(PlayerHL) do cleanupPlayer(p) end
        elseif flag == "Generator" or flag == "Pallet" or flag == "Gate" then
            clearMap(ObjectHL)
        end
        return
    end

    -- ===== ON: APPLY TANPA CLEAR =====
    refreshPlayers()
    scanObjects()
end

return ESP