--====================================================
-- RiiHUB ESPModule FINAL (OBJECT BASED)
--====================================================

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace  = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local ESPModule = {}
ESPModule.Enabled = false

-- STORAGE
local PlayerHL  = {}
local NameGui   = {}
local NameConn  = {}
local ObjectHL  = {}

local PlayerLoop = nil
local ObjectLoop = nil

-- COLORS
local COLORS = {
    Survivor  = Color3.fromRGB(0,255,120),
    Killer    = Color3.fromRGB(255,70,70),
    Generator = Color3.fromRGB(255,220,80),
    Pallet    = Color3.fromRGB(255,140,0),
    Gate      = Color3.fromRGB(80,120,255),
}

-- GLOBAL STATE HELPER
local function on(key)
    return _G.RiiHUB_STATE and _G.RiiHUB_STATE[key] == true
end

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

--====================================================
-- PLAYER ESP
--====================================================
local function updatePlayers()
    if not ESPModule.Enabled then return end

    for _,plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end

        local char = plr.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end

        local isKiller = plr.Team and plr.Team.Name == "Killer"
        local allowed =
            (isKiller and on("KILLER_ESP")) or
            ((not isKiller) and on("SURVIVOR_ESP"))

        -- OUTLINE
        if allowed then
            if not PlayerHL[plr] then
                local hl = Instance.new("Highlight")
                hl.Adornee = char
                hl.FillTransparency = 1
                hl.OutlineTransparency = 0
                hl.OutlineColor = isKiller and COLORS.Killer or COLORS.Survivor
                hl.Parent = char
                PlayerHL[plr] = hl
            end
        else
            if PlayerHL[plr] then
                PlayerHL[plr]:Destroy()
                PlayerHL[plr] = nil
            end
        end

        -- NAME + HP
        if allowed and on("ESP_NAME_HP") then
            if not NameGui[plr] then
                local gui = Instance.new("BillboardGui")
                gui.Adornee = char:FindFirstChild("Head") or char.PrimaryPart
                gui.Size = UDim2.new(0,140,0,26)
                gui.AlwaysOnTop = true
                gui.Parent = char
                NameGui[plr] = gui

                local txt = Instance.new("TextLabel", gui)
                txt.Size = UDim2.fromScale(1,1)
                txt.BackgroundTransparency = 1
                txt.Font = Enum.Font.SourceSansBold
                txt.TextSize = 14
                txt.TextStrokeTransparency = 0
                txt.TextColor3 = isKiller and COLORS.Killer or COLORS.Survivor

                NameConn[plr] = RunService.Heartbeat:Connect(function()
                    txt.Text = plr.Name .. " [" .. math.floor(hum.Health) .. "]"
                end)
            end
        else
            if NameGui[plr] then
                NameGui[plr]:Destroy()
                NameGui[plr] = nil
            end
            if NameConn[plr] then
                NameConn[plr]:Disconnect()
                NameConn[plr] = nil
            end
        end
    end
end

--====================================================
-- OBJECT ESP (FINAL FIX)
--====================================================
local function updateObjects()
    clear(ObjectHL)
    if not ESPModule.Enabled then return end

    for _,obj in ipairs(Workspace:GetDescendants()) do

        -- GENERATOR
        if on("GENERATOR_ESP")
        and obj:IsA("BasePart")
        and obj.Name == "HitBox"
        and obj.Parent
        and obj.Parent.Name == "Generator" then

            local hl = Instance.new("Highlight")
            hl.Adornee = obj
            hl.FillTransparency = 1
            hl.OutlineTransparency = 0
            hl.OutlineColor = COLORS.Generator
            hl.Parent = obj
            ObjectHL[obj] = hl

        -- PALLET
        elseif on("PALLET_ESP")
        and obj:IsA("BasePart")
        and obj.Name == "HumanoidRootPart"
        and obj.Parent
        and obj.Parent.Name == "Palletwrong" then

            local hl = Instance.new("Highlight")
            hl.Adornee = obj
            hl.FillTransparency = 1
            hl.OutlineTransparency = 0
            hl.OutlineColor = COLORS.Pallet
            hl.Parent = obj
            ObjectHL[obj] = hl

        -- GATE
        elseif on("GATE_ESP")
        and obj:IsA("BasePart")
        and obj.Name == "MeshPart"
        and obj.Parent
        and obj.Parent.Name == "ExitLever" then

            local hl = Instance.new("Highlight")
            hl.Adornee = obj
            hl.FillTransparency = 1
            hl.OutlineTransparency = 0
            hl.OutlineColor = COLORS.Gate
            hl.Parent = obj
            ObjectHL[obj] = hl
        end
    end
end

local function anyObjectOn()
    return on("GENERATOR_ESP") or on("PALLET_ESP") or on("GATE_ESP")
end

local function startObjectLoop()
    if ObjectLoop then return end
    ObjectLoop = task.spawn(function()
        while ESPModule.Enabled and anyObjectOn() do
            updateObjects()
            task.wait(0.7)
        end
        ObjectLoop = nil
    end)
end

--====================================================
-- PUBLIC API
--====================================================
function ESPModule:Enable()
    if self.Enabled then return end
    self.Enabled = true

    PlayerLoop = RunService.Heartbeat:Connect(updatePlayers)
    startObjectLoop()
end

function ESPModule:Disable()
    if not self.Enabled then return end
    self.Enabled = false

    if PlayerLoop then
        PlayerLoop:Disconnect()
        PlayerLoop = nil
    end

    clear(PlayerHL)
    clear(NameGui)
    clear(NameConn)
    clear(ObjectHL)
end

return ESPModule