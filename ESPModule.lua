--====================================================
-- RiiHUB ESPModule (FINAL OBJECT FIX)
-- Player + Object ESP • All Categories Work
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

local PlayerConn = nil
local ObjectLoop = nil

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

-- Cari BasePart valid untuk Highlight
local function getAdornee(obj)
    if obj:IsA("BasePart") then
        return obj
    end
    if obj:IsA("Model") then
        if obj.PrimaryPart then
            return obj.PrimaryPart
        end
        for _,d in ipairs(obj:GetDescendants()) do
            if d:IsA("BasePart") then
                return d
            end
        end
    end
    return nil
end

-- =========================
-- PLAYER UPDATE
-- =========================
local function updatePlayers()
    if not ESPModule.Enabled then return end

    for _,player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end

        local char = player.Character
        if not char then continue end

        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end

        local isKiller = player.Team and player.Team.Name == "Killer"
        local allowed =
            (isKiller and state("KILLER_ESP")) or
            ((not isKiller) and state("SURVIVOR_ESP"))

        if allowed then
            if not PlayerHL[player] then
                local hl = Instance.new("Highlight")
                hl.Adornee = char
                hl.FillTransparency = 1
                hl.OutlineTransparency = 0
                hl.OutlineColor = isKiller and COLORS.Killer or COLORS.Survivor
                hl.Parent = char
                PlayerHL[player] = hl
            end
        else
            if PlayerHL[player] then
                PlayerHL[player]:Destroy()
                PlayerHL[player] = nil
            end
        end

        -- NAME + HP
        if allowed and state("ESP_NAME_HP") then
            if not NameHPGui[player] then
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
-- OBJECT UPDATE (FINAL FIX)
-- =========================
local function updateObjects()
    destroy(ObjectHL)
    if not ESPModule.Enabled then return end

    for _,obj in ipairs(Workspace:GetDescendants()) do
        local color

        if obj.Name == "Generator" and state("GENERATOR_ESP") then
            color = COLORS.Generator
        elseif obj.Name == "Palletwrong" and state("PALLET_ESP") then
            color = COLORS.Pallet
        elseif (obj.Name == "ExitGate" or obj.Name == "ExitLever") and state("GATE_ESP") then
            color = COLORS.Gate
        end

        if color then
            local part = getAdornee(obj)
            if part then
                local hl = Instance.new("Highlight")
                hl.Adornee = part
                hl.FillTransparency = 1
                hl.OutlineTransparency = 0
                hl.OutlineColor = color
                hl.Parent = part
                ObjectHL[obj] = hl
            end
        end
    end
end

local function anyObjectESPOn()
    return state("GENERATOR_ESP") or state("PALLET_ESP") or state("GATE_ESP")
end

local function startObjectLoop()
    if ObjectLoop then return end
    ObjectLoop = task.spawn(function()
        while ESPModule.Enabled and anyObjectESPOn() do
            updateObjects()
            task.wait(0.8)
        end
        ObjectLoop = nil
    end)
end

-- =========================
-- PUBLIC API
-- =========================
function ESPModule:Enable()
    if self.Enabled then return end
    self.Enabled = true

    PlayerConn = RunService.Heartbeat:Connect(updatePlayers)
    startObjectLoop()
end

function ESPModule:Disable()
    if not self.Enabled then return end
    self.Enabled = false

    if PlayerConn then
        PlayerConn:Disconnect()
        PlayerConn = nil
    end

    destroy(PlayerHL)
    destroy(NameHPGui)
    destroy(NameHPConn)
    destroy(ObjectHL)

    ObjectLoop = nil
end

return ESPModule