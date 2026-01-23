-- RIIHUB ESP MODULE (FINAL FIX)
-- Survivor / Killer / Generator / Pallet / Gate
-- Highlight applied ONLY to MODEL (ANTI INVISIBLE PART BUG)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local ESP = {}
ESP.Enabled = false

-- =========================
-- FLAGS (SEMUA DEFAULT OFF)
-- =========================
ESP.Flags = {
    Survivor = false,
    Killer = false,
    Generator = false,
    Pallet = false,
    Gate = false,
    NameHP = false,
}

-- =========================
-- COLORS
-- =========================
local COLORS = {
    Survivor = Color3.fromRGB(0,255,120),
    Killer   = Color3.fromRGB(255,70,70),
    Generator= Color3.fromRGB(255,220,80),
    Pallet   = Color3.fromRGB(255,170,60),
    Gate     = Color3.fromRGB(80,160,255),
}

local LocalPlayer = Players.LocalPlayer

-- =========================
-- STORAGE
-- =========================
local PlayerHL = {}
local ObjectHL = {}
local NameGui = {}

-- =========================
-- UTILS
-- =========================
local function clear(tbl)
    for k,v in pairs(tbl) do
        if typeof(v) == "Instance" then
            v:Destroy()
        elseif typeof(v) == "table" then
            for _,x in pairs(v) do
                if typeof(x) == "Instance" then
                    x:Destroy()
                end
            end
        end
        tbl[k] = nil
    end
end

local function on(flag)
    return ESP.Enabled and ESP.Flags[flag]
end

-- =========================
-- PLAYER ESP
-- =========================
local function applyPlayer(player)
    if player == LocalPlayer then return end
    if not player.Character then return end

    local char = player.Character
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end

    local isKiller = player.Team and player.Team.Name == "Killer"

    if (isKiller and not on("Killer")) or (not isKiller and not on("Survivor")) then
        return
    end

    if not PlayerHL[player] then
        local hl = Instance.new("Highlight")
        hl.Adornee = char
        hl.FillTransparency = 1
        hl.OutlineTransparency = 0
        hl.OutlineColor = isKiller and COLORS.Killer or COLORS.Survivor
        hl.Parent = char
        PlayerHL[player] = hl
    end

    -- Name + HP
    if on("NameHP") and not NameGui[player] then
        local gui = Instance.new("BillboardGui")
        gui.Size = UDim2.fromOffset(160,40)
        gui.StudsOffset = Vector3.new(0,3,0)
        gui.AlwaysOnTop = true
        gui.Adornee = char:FindFirstChild("Head")
        gui.Parent = char

        local txt = Instance.new("TextLabel", gui)
        txt.Size = UDim2.fromScale(1,1)
        txt.BackgroundTransparency = 1
        txt.TextScaled = true
        txt.TextColor3 = Color3.new(1,1,1)
        txt.Font = Enum.Font.GothamBold
        txt.Text = player.Name.." | "..math.floor(hum.Health)

        hum.HealthChanged:Connect(function(h)
            if txt then
                txt.Text = player.Name.." | "..math.floor(h)
            end
        end)

        NameGui[player] = gui
    end
end

local function refreshPlayers()
    clear(PlayerHL)
    clear(NameGui)
    for _,p in ipairs(Players:GetPlayers()) do
        applyPlayer(p)
    end
end

-- =========================
-- OBJECT ESP (MODEL ONLY)
-- =========================
local function addObject(model, color)
    if ObjectHL[model] then return end

    local hl = Instance.new("Highlight")
    hl.Adornee = model
    hl.FillTransparency = 1
    hl.OutlineTransparency = 0
    hl.OutlineColor = color
    hl.Parent = model

    ObjectHL[model] = hl
end

local function scanObjects()
    clear(ObjectHL)
    if not ESP.Enabled then return end

    for _,v in ipairs(Workspace:GetDescendants()) do

        -- GENERATOR
        if on("Generator")
        and v:IsA("BasePart")
        and v.Name == "HitBox"
        and v.Parent
        and v.Parent.Name == "Generator" then
            addObject(v.Parent, COLORS.Generator)

        -- PALLET
        elseif on("Pallet")
        and v:IsA("BasePart")
        and v.Name == "HumanoidRootPart"
        and v.Parent
        and v.Parent.Name == "Palletwrong" then
            addObject(v.Parent, COLORS.Pallet)

        -- GATE
        elseif on("Gate")
        and v:IsA("BasePart")
        and v.Parent
        and v.Parent.Name == "ExitLever" then
            addObject(v.Parent, COLORS.Gate)
        end
    end
end

-- =========================
-- PUBLIC API
-- =========================
function ESP:Enable()
    if ESP.Enabled then return end
    ESP.Enabled = true
    refreshPlayers()
    scanObjects()
end

function ESP:Disable()
    ESP.Enabled = false
    clear(PlayerHL)
    clear(ObjectHL)
    clear(NameGui)
end

function ESP:Set(flag, state)
    if ESP.Flags[flag] == nil then return end
    ESP.Flags[flag] = state

    if not ESP.Enabled then return end

    -- OFF
    if not state then
        if flag == "Survivor" or flag == "Killer" then
            clear(PlayerHL)
            clear(NameGui)
        elseif flag == "Generator" or flag == "Pallet" or flag == "Gate" then
            clear(ObjectHL)
        elseif flag == "NameHP" then
            clear(NameGui)
        end
    end

    -- ON
    refreshPlayers()
    scanObjects()
end

print("[RiiHUB] ESPModule loaded (FINAL FIX)")
return ESP