--====================================================
-- RiiHUB ESPModule (FINAL LOGIC FIX)
-- Compatible with HomeGui.lua
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
    ESP        = false,
    Survivor   = false,
    Killer     = false,
    Generator  = false,
    Pallet     = false,
    Gate       = false,
    NameHP     = false,
}

-- =========================
-- STORAGE
-- =========================
local PlayerHL  = {}
local NameGui   = {}
local ObjHL     = {}
local Loop      = nil

-- =========================
-- COLORS
-- =========================
local C = {
    Survivor  = Color3.fromRGB(0,255,120),
    Killer    = Color3.fromRGB(255,70,70),
    Generator = Color3.fromRGB(255,220,80),
    Pallet    = Color3.fromRGB(255,140,0),
    Gate      = Color3.fromRGB(80,120,255),
}

-- =========================
-- CLEAR
-- =========================
local function clear(t)
    for k,v in pairs(t) do
        if typeof(v) == "Instance" then v:Destroy() end
        if typeof(v) == "RBXScriptConnection" then v:Disconnect() end
        t[k] = nil
    end
end

local function anyActive()
    if not ESP.Flags.ESP then return false end
    for k,v in pairs(ESP.Flags) do
        if k ~= "ESP" and v then return true end
    end
    return false
end

-- =========================
-- PLAYER ESP
-- =========================
local function applyPlayer(p)
    if p == LocalPlayer then return end
    local char = p.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end

    local isKiller = p.Team and p.Team.Name == "Killer"
    if isKiller and not ESP.Flags.Killer then return end
    if not isKiller and not ESP.Flags.Survivor then return end

    if not PlayerHL[p] then
        local hl = Instance.new("Highlight")
        hl.Adornee = char
        hl.FillTransparency = 1
        hl.OutlineTransparency = 0
        hl.OutlineColor = isKiller and C.Killer or C.Survivor
        hl.Parent = char
        PlayerHL[p] = hl
    end

    if ESP.Flags.NameHP and not NameGui[p] then
        local gui = Instance.new("BillboardGui")
        gui.Adornee = char:FindFirstChild("Head")
        gui.Size = UDim2.new(0,150,0,28)
        gui.AlwaysOnTop = true
        gui.Parent = char
        NameGui[p] = gui

        local txt = Instance.new("TextLabel", gui)
        txt.Size = UDim2.fromScale(1,1)
        txt.BackgroundTransparency = 1
        txt.TextStrokeTransparency = 0
        txt.Font = Enum.Font.SourceSansBold
        txt.TextSize = 14
        txt.TextColor3 = PlayerHL[p].OutlineColor

        RunService.Heartbeat:Connect(function()
            if hum.Health > 0 then
                txt.Text = p.Name .. " [" .. math.floor(hum.Health) .. "]"
            end
        end)
    end
end

-- =========================
-- OBJECT ESP
-- =========================
local function scanObjects()
    clear(ObjHL)
    for _,v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Model") then
            local color
            if v.Name == "Generator" and ESP.Flags.Generator then
                color = C.Generator
            elseif v.Name == "Palletwrong" and ESP.Flags.Pallet then
                color = C.Pallet
            elseif (v.Name == "ExitGate" or v.Name == "ExitLever") and ESP.Flags.Gate then
                color = C.Gate
            end

            if color then
                local hl = Instance.new("Highlight")
                hl.Adornee = v
                hl.FillTransparency = 1
                hl.OutlineTransparency = 0
                hl.OutlineColor = color
                hl.Parent = v
                ObjHL[v] = hl
            end
        end
    end
end

-- =========================
-- LOOP
-- =========================
local function start()
    if Loop then return end
    Loop = task.spawn(function()
        while anyActive() do
            clear(PlayerHL)
            clear(NameGui)
            for _,p in ipairs(Players:GetPlayers()) do
                applyPlayer(p)
            end
            scanObjects()
            task.wait(1)
        end
        Loop = nil
    end)
end

-- =========================
-- HOMEGUI API (INI KUNCI FIX)
-- =========================
function ESP:Enable() ESP.Flags.ESP = true start() end
function ESP:Disable()
    ESP.Flags.ESP = false
    clear(PlayerHL)
    clear(NameGui)
    clear(ObjHL)
end

function ESP:EnableSurvivor() ESP.Flags.Survivor = true start() end
function ESP:DisableSurvivor() ESP.Flags.Survivor = false end

function ESP:EnableKiller() ESP.Flags.Killer = true start() end
function ESP:DisableKiller() ESP.Flags.Killer = false end

function ESP:EnableGenerator() ESP.Flags.Generator = true start() end
function ESP:DisableGenerator() ESP.Flags.Generator = false end

function ESP:EnablePallet() ESP.Flags.Pallet = true start() end
function ESP:DisablePallet() ESP.Flags.Pallet = false end

function ESP:EnableGate() ESP.Flags.Gate = true start() end
function ESP:DisableGate() ESP.Flags.Gate = false end

function ESP:EnableNameHP() ESP.Flags.NameHP = true start() end
function ESP:DisableNameHP() ESP.Flags.NameHP = false clear(NameGui) end

return ESP