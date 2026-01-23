--====================================================
-- RiiHUB ESPModule (MODULAR + OPTIMIZED)
--====================================================

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace  = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local ESP = {}

-- =========================
-- STATE (SEMUA OFF)
-- =========================
ESP.Enabled = false
ESP.Flags = {
    Survivor = false,
    Killer   = false,
    Generator = false,
    Pallet   = false,
    Gate     = false,
    NameHP   = false,
}

-- =========================
-- STORAGE
-- =========================
local PlayerESP = {}
local ObjectESP = {}
local Connections = {}
local ScanLoop = nil

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
        if typeof(v) == "Instance" then v:Destroy() end
        if typeof(v) == "RBXScriptConnection" then v:Disconnect() end
    end
    table.clear(tbl)
end

-- =========================
-- PLAYER ESP
-- =========================
local function applyPlayerESP(player)
    if not ESP.Enabled or player == LocalPlayer then return end
    if PlayerESP[player] then PlayerESP[player]:Destroy() end

    local char = player.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end

    local isKiller = player.Team and player.Team.Name == "Killer"

    if (isKiller and not ESP.Flags.Killer) or (not isKiller and not ESP.Flags.Survivor) then
        return
    end

    local hl = Instance.new("Highlight")
    hl.Adornee = char
    hl.FillTransparency = 1
    hl.OutlineTransparency = 0
    hl.OutlineColor = isKiller and COLORS.Killer or COLORS.Survivor
    hl.Parent = char

    -- NAME + HP
    if ESP.Flags.NameHP then
        local tag = Instance.new("BillboardGui")
        tag.Size = UDim2.new(0,120,0,30)
        tag.AlwaysOnTop = true
        tag.Adornee = char:FindFirstChild("Head") or char.PrimaryPart
        tag.Parent = char

        local lbl = Instance.new("TextLabel", tag)
        lbl.Size = UDim2.fromScale(1,1)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = hl.OutlineColor
        lbl.TextStrokeTransparency = 0
        lbl.TextSize = 14
        lbl.Font = Enum.Font.SourceSansBold

        Connections[player] = RunService.Heartbeat:Connect(function()
            if hum.Health > 0 then
                lbl.Text = string.format("%s [%d]", player.Name, hum.Health)
            end
        end)
    end

    PlayerESP[player] = hl
end

local function refreshPlayers()
    for _,p in ipairs(Players:GetPlayers()) do
        if PlayerESP[p] then PlayerESP[p]:Destroy() PlayerESP[p]=nil end
        if Connections[p] then Connections[p]:Disconnect() Connections[p]=nil end
        applyPlayerESP(p)
    end
end

-- =========================
-- OBJECT ESP
-- =========================
local function applyObjectESP(obj, color)
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
    for _,v in ipairs(Workspace:GetDescendants()) do
        if not ESP.Enabled then return end

        if v:IsA("Model") then
            if v.Name == "Generator" and ESP.Flags.Generator then
                applyObjectESP(v, COLORS.Generator)

            elseif v.Name == "Palletwrong" and ESP.Flags.Pallet then
                applyObjectESP(v, COLORS.Pallet)

            elseif (v.Name == "ExitLever" or v.Name == "ExitGate") and ESP.Flags.Gate then
                applyObjectESP(v, COLORS.Gate)
            end
        end
    end
end

-- =========================
-- LOOP (OPTIMIZED)
-- =========================
local function startScanLoop()
    ScanLoop = task.spawn(function()
        while ESP.Enabled do
            scanObjects()
            task.wait(1) -- OPTIMASI
        end
    end)
end

-- =========================
-- PUBLIC API
-- =========================
function ESP:Enable()
    if self.Enabled then return end
    self.Enabled = true
    refreshPlayers()
    startScanLoop()
end

function ESP:Disable()
    self.Enabled = false
    clear(PlayerESP)
    clear(ObjectESP)
    clear(Connections)
end

function ESP:Set(flag, state)
    if self.Flags[flag] == nil then return end
    self.Flags[flag] = state

    if self.Enabled then
        refreshPlayers()
        scanObjects()
    end
end

return ESP