--====================================================
-- RiiHUB ESPModule (FINAL STABLE)
-- No Master Lock • No Stuck • Simple & Reliable
--====================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local ESP = {}

-- =========================
-- FLAGS
-- =========================
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
local PlayerHL   = {}
local NameHPGui  = {}
local NameHPConn = {}
local ObjectHL   = {}
local ScanLoop   = nil

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

local function anyESPOn()
    for k,v in pairs(ESP.Flags) do
        if v then return true end
    end
    return false
end

-- =========================
-- PLAYER ESP
-- =========================
local function applyPlayer(player)
    if player == LocalPlayer then return end

    local char = player.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end

    local isKiller = player.Team and player.Team.Name == "Killer"
    if isKiller and not ESP.Flags.Killer then return end
    if not isKiller and not ESP.Flags.Survivor then return end

    if not PlayerHL[player] then
        local hl = Instance.new("Highlight")
        hl.Adornee = char
        hl.FillTransparency = 1
        hl.OutlineTransparency = 0
        hl.OutlineColor = isKiller and COLORS.Killer or COLORS.Survivor
        hl.Parent = char
        PlayerHL[player] = hl
    end

    -- NAME + HP
    if ESP.Flags.NameHP and not NameHPGui[player] then
        local tag = Instance.new("BillboardGui")
        tag.Adornee = char:FindFirstChild("Head") or char.PrimaryPart
        tag.Size = UDim2.new(0,140,0,28)
        tag.AlwaysOnTop = true
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
            txt.Text = string.format("%s [%d]", player.Name, hum.Health)
        end)
    end
end

local function refreshPlayers()
    clearMap(PlayerHL)
    clearMap(NameHPGui)
    clearMap(NameHPConn)

    for _,p in ipairs(Players:GetPlayers()) do
        applyPlayer(p)
    end
end

-- =========================
-- OBJECT ESP
-- =========================
local function scanObjects()
    clearMap(ObjectHL)

    for _,v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Model") then
            if v.Name == "Generator" and ESP.Flags.Generator then
                local hl = Instance.new("Highlight")
                hl.Adornee = v
                hl.FillTransparency = 1
                hl.OutlineTransparency = 0
                hl.OutlineColor = COLORS.Generator
                hl.Parent = v
                ObjectHL[v] = hl

            elseif v.Name == "Palletwrong" and ESP.Flags.Pallet then
                local hl = Instance.new("Highlight")
                hl.Adornee = v
                hl.FillTransparency = 1
                hl.OutlineTransparency = 0
                hl.OutlineColor = COLORS.Pallet
                hl.Parent = v
                ObjectHL[v] = hl

            elseif (v.Name == "ExitLever" or v.Name == "ExitGate") and ESP.Flags.Gate then
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
end

-- =========================
-- LOOP
-- =========================
local function startLoop()
    if ScanLoop then return end
    ScanLoop = task.spawn(function()
        while anyESPOn() do
            refreshPlayers()
            scanObjects()
            task.wait(1)
        end
        ScanLoop = nil
    end)
end

-- =========================
-- PUBLIC API
-- =========================
function ESP:Set(flag, state)
    if ESP.Flags[flag] == nil then return end
    ESP.Flags[flag] = state

    if anyESPOn() then
        startLoop()
    else
        clearMap(PlayerHL)
        clearMap(NameHPGui)
        clearMap(NameHPConn)
        clearMap(ObjectHL)
    end
end

return ESP