--==================================================
-- RIIHUB ESP MODULE (FINAL)
-- Survivor / Killer / Generator / Pallet / Gate
-- Toggle Terpisah
--==================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local ESP = {}

-- ================= CONFIG =================
local COLORS = {
    Survivor  = Color3.fromRGB(0, 255, 120),
    Killer    = Color3.fromRGB(255, 70, 70),
    Generator = Color3.fromRGB(255, 220, 80),
    Pallet    = Color3.fromRGB(255, 165, 0),
    Gate      = Color3.fromRGB(80, 140, 255),
}

-- ================= STATES =================
ESP.Enabled = {
    Player    = false, -- Survivor + Killer
    Generator = false,
    Pallet    = false,
    Gate      = false,
}

-- ================= STORAGE =================
local PlayerESP   = {}
local GeneratorESP = {}
local PalletESP   = {}
local GateESP     = {}

-- ================= UTILS =================
local function safeDestroy(obj)
    if obj and obj.Parent then
        obj:Destroy()
    end
end

local function clearTable(t)
    for _,v in pairs(t) do
        if typeof(v) == "table" then
            for _,x in ipairs(v) do safeDestroy(x) end
        else
            safeDestroy(v)
        end
    end
    table.clear(t)
end

-- ================= PLAYER ESP =================
local function clearPlayerESP(player)
    if PlayerESP[player] then
        for _,v in ipairs(PlayerESP[player]) do
            safeDestroy(v)
        end
        PlayerESP[player] = nil
    end
end

local function createPlayerESP(player)
    if not ESP.Enabled.Player then return end
    if player == LocalPlayer then return end

    clearPlayerESP(player)

    local char = player.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    local head = char:FindFirstChild("Head")
    if not hum or not head or hum.Health <= 0 then return end

    PlayerESP[player] = {}

    local isKiller = (player.Team and player.Team.Name == "Killer")

    -- Outline
    local hl = Instance.new("Highlight")
    hl.Adornee = char
    hl.FillTransparency = 1
    hl.OutlineTransparency = 0
    hl.OutlineColor = isKiller and COLORS.Killer or COLORS.Survivor
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = Workspace
    table.insert(PlayerESP[player], hl)

    -- Name + HP
    local gui = Instance.new("BillboardGui")
    gui.Name = "RiiHUB_NameHP"
    gui.Adornee = head
    gui.Size = UDim2.new(0, 160, 0, 36)
    gui.StudsOffset = Vector3.new(0, 2.4, 0)
    gui.AlwaysOnTop = true
    gui.Parent = head

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.TextScaled = true
    text.Font = Enum.Font.GothamBold
    text.TextStrokeTransparency = 0
    text.TextStrokeColor3 = Color3.new(0,0,0)
    text.TextColor3 = isKiller and COLORS.Killer or COLORS.Survivor
    text.Parent = gui

    local function updateText()
        text.Text = string.format("%s | %d HP", player.Name, math.floor(hum.Health))
    end
    updateText()
    hum.HealthChanged:Connect(updateText)

    table.insert(PlayerESP[player], gui)
end

-- ================= MAP ESP HELPERS =================
local function createHighlight(model, color)
    local hl = Instance.new("Highlight")
    hl.Adornee = model
    hl.FillTransparency = 1
    hl.OutlineTransparency = 0
    hl.OutlineColor = color
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = Workspace
    return hl
end

-- ================= GENERATOR =================
local function enableGeneratorESP()
    if not ESP.Enabled.Generator then return end
    clearTable(GeneratorESP)

    for _,obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == "Generator" then
            table.insert(GeneratorESP, createHighlight(obj, COLORS.Generator))
        end
    end
end

-- ================= PALLET =================
local function enablePalletESP()
    if not ESP.Enabled.Pallet then return end
    clearTable(PalletESP)

    for _,obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == "Palletwrong" then
            table.insert(PalletESP, createHighlight(obj, COLORS.Pallet))
        end
    end
end

-- ================= GATE =================
local function enableGateESP()
    if not ESP.Enabled.Gate then return end
    clearTable(GateESP)

    for _,obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == "ExitLever" then
            table.insert(GateESP, createHighlight(obj, COLORS.Gate))
        end
    end
end

-- ================= PUBLIC TOGGLES =================
function ESP:SetPlayer(state)
    ESP.Enabled.Player = state
    if not state then
        for p in pairs(PlayerESP) do clearPlayerESP(p) end
    else
        for _,p in ipairs(Players:GetPlayers()) do
            createPlayerESP(p)
        end
    end
end

function ESP:SetGenerator(state)
    ESP.Enabled.Generator = state
    if state then enableGeneratorESP() else clearTable(GeneratorESP) end
end

function ESP:SetPallet(state)
    ESP.Enabled.Pallet = state
    if state then enablePalletESP() else clearTable(PalletESP) end
end

function ESP:SetGate(state)
    ESP.Enabled.Gate = state
    if state then enableGateESP() else clearTable(GateESP) end
end

-- ================= EVENTS =================
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.5)
        createPlayerESP(p)
    end)
end)

Workspace.DescendantAdded:Connect(function(obj)
    task.wait(0.2)
    if obj:IsA("Model") then
        if obj.Name == "Generator" and ESP.Enabled.Generator then
            enableGeneratorESP()
        elseif obj.Name == "Palletwrong" and ESP.Enabled.Pallet then
            enablePalletESP()
        elseif obj.Name == "ExitLever" and ESP.Enabled.Gate then
            enableGateESP()
        end
    end
end)

return ESP