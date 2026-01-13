--==================================================
-- ESPModule.lua
-- Survivor / Killer / Generator ESP
-- Delta Mobile Safe
--==================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local ESP_ENABLED = false

local PLAYER_ESP = {}
local GENERATOR_ESP = {}

--========================
-- COLORS
--========================
local COLORS = {
    Survivor  = Color3.fromRGB(0,255,120),
    Killer    = Color3.fromRGB(255,70,70),
    Generator = Color3.fromRGB(255,220,80)
}

--========================
-- ROLE DETECTION
--========================
local function isKiller(player)
    if player == LocalPlayer then return false end

    if player.Character then
        for _,v in ipairs(player.Character:GetChildren()) do
            if v:IsA("Tool") and v.Name:lower():find("knife") then
                return true
            end
        end
    end

    return player:GetAttribute("Role") == "Killer"
end

--========================
-- GENERATOR DETECTION
-- EDIT HERE IF NAME DIFFERENT
--========================
local function isGenerator(obj)
    if not obj:IsA("Model") then return false end

    local name = obj.Name:lower()
    if name:find("generator") or name:find("gen") then
        return true
    end

    return obj:GetAttribute("Type") == "Generator"
end

--========================
-- CLEAR FUNCTIONS
--========================
local function clearPlayerESP(player)
    if PLAYER_ESP[player] then
        for _,v in ipairs(PLAYER_ESP[player]) do
            v:Destroy()
        end
        PLAYER_ESP[player] = nil
    end
end

local function clearGeneratorESP()
    for _,v in ipairs(GENERATOR_ESP) do
        v:Destroy()
    end
    table.clear(GENERATOR_ESP)
end

--========================
-- CREATE PLAYER ESP
--========================
local function createPlayerESP(player)
    if player == LocalPlayer then return end
    clearPlayerESP(player)

    local char = player.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end

    PLAYER_ESP[player] = {}

    local killer = isKiller(player)

    -- Outline
    local hl = Instance.new("Highlight")
    hl.Adornee = char
    hl.FillTransparency = 1
    hl.OutlineTransparency = 0
    hl.OutlineColor = killer and COLORS.Killer or COLORS.Survivor
    hl.Parent = char
    table.insert(PLAYER_ESP[player], hl)

    -- HP BAR (SURVIVOR ONLY)
    if not killer then
        local bill = Instance.new("BillboardGui", root)
        bill.Size = UDim2.new(0,40,0,6)
        bill.StudsOffset = Vector3.new(0,3.2,0)
        bill.AlwaysOnTop = true

        local bg = Instance.new("Frame", bill)
        bg.Size = UDim2.new(1,0,1,0)
        bg.BackgroundColor3 = Color3.fromRGB(40,40,40)
        bg.BorderSizePixel = 0

        local bar = Instance.new("Frame", bg)
        bar.Size = UDim2.new(1,0,1,0)
        bar.BackgroundColor3 = COLORS.Survivor
        bar.BorderSizePixel = 0

        table.insert(PLAYER_ESP[player], bill)

        RunService.RenderStepped:Connect(function()
            if hum.Health > 0 then
                bar.Size = UDim2.new(hum.Health / hum.MaxHealth, 0, 1, 0)
            end
        end)
    end
end

--========================
-- CREATE GENERATOR ESP
--========================
local function createGeneratorESP()
    clearGeneratorESP()

    for _,obj in ipairs(Workspace:GetChildren()) do
        if isGenerator(obj) then
            local hl = Instance.new("Highlight")
            hl.Adornee = obj
            hl.FillTransparency = 1
            hl.OutlineTransparency = 0
            hl.OutlineColor = COLORS.Generator
            hl.Parent = obj
            table.insert(GENERATOR_ESP, hl)
        end
    end
end

--========================
-- PLAYER HANDLING
--========================
local function handlePlayer(player)
    player.CharacterAdded:Connect(function()
        task.wait(1)
        if ESP_ENABLED then
            createPlayerESP(player)
        end
    end)

    if player.Character and ESP_ENABLED then
        createPlayerESP(player)
    end
end

for _,p in ipairs(Players:GetPlayers()) do
    handlePlayer(p)
end

Players.PlayerAdded:Connect(handlePlayer)
Players.PlayerRemoving:Connect(clearPlayerESP)

--========================
-- GLOBAL TOGGLE (HOMEGUI)
--========================
_G.ToggleESP = function(state)
    ESP_ENABLED = state

    for _,p in ipairs(Players:GetPlayers()) do
        clearPlayerESP(p)
        if state then
            createPlayerESP(p)
        end
    end

    if state then
        createGeneratorESP()
    else
        clearGeneratorESP()
    end
end
