--==================================================
-- EventModule.lua (FINAL FIX)
-- Gift Event | Map Only | Global API
--==================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

--==================================================
-- MODULE TABLE
--==================================================
local EventModule = {}

--==================================================
-- INTERNAL STATE
--==================================================
local ENABLED = false
local giftHighlights = {}
local scanConnection = nil

--==================================================
-- MAP ROOT (ANTI LOBBY)
--==================================================
local function getMapRoot()
    local map = Workspace:FindFirstChild("Map")
    if map then return map end
    return nil
end

--==================================================
-- VALID GIFT CHECK (BASED ON SNAPSHOT)
--==================================================
local function isValidGift(model)
    if not model or not model:IsA("Model") then return false end
    if model.Name ~= "Gift" then return false end

    -- signature parts (from your snapshot)
    if not model:FindFirstChildWhichIsA("MeshPart", true) then
        return false
    end

    return true
end

--==================================================
-- ADD OUTLINE
--==================================================
local function addOutline(model)
    if giftHighlights[model] then return end

    local h = Instance.new("Highlight")
    h.Name = "_RiiHUB_GiftHighlight"
    h.FillTransparency = 1
    h.OutlineColor = Color3.fromRGB(0,255,120)
    h.OutlineTransparency = 0
    h.Adornee = model
    h.Parent = model

    giftHighlights[model] = h
end

--==================================================
-- CLEAR ALL
--==================================================
local function clearAll()
    for model,hl in pairs(giftHighlights) do
        if hl then hl:Destroy() end
    end
    giftHighlights = {}
end

--==================================================
-- SCAN LOOP (MAP ONLY)
--==================================================
local function scanGifts()
    local map = getMapRoot()
    if not map then return end

    for _,obj in ipairs(map:GetDescendants()) do
        if isValidGift(obj) then
            addOutline(obj)
        end
    end
end

--==================================================
-- FIND NEAREST GIFT
--==================================================
local function getNearestGift()
    local map = getMapRoot()
    if not map then return nil end

    local char = player.Character
    if not char then return nil end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local nearest, dist = nil, math.huge

    for model,_ in pairs(giftHighlights) do
        local part = model.PrimaryPart
            or model:FindFirstChildWhichIsA("BasePart", true)
        if part then
            local d = (part.Position - hrp.Position).Magnitude
            if d < dist then
                dist = d
                nearest = part
            end
        end
    end

    return nearest
end

--==================================================
-- FIND CHRISTMAS TREE (MAP ONLY)
--==================================================
local function getChristmasTree()
    local map = getMapRoot()
    if not map then return nil end

    for _,obj in ipairs(map:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == "ChristmasTree" then
            local part = obj.PrimaryPart
                or obj:FindFirstChildWhichIsA("BasePart", true)
            if part then
                return part
            end
        end
    end

    return nil
end

--==================================================
-- TELEPORT SAFE
--==================================================
local function teleportTo(part)
    if not part then return end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    hrp.CFrame = part.CFrame * CFrame.new(0, 0, -3)
end

--==================================================
-- PUBLIC API
--==================================================
function EventModule.Enable(state)
    ENABLED = state and true or false

    if ENABLED then
        if scanConnection then scanConnection:Disconnect() end
        scanConnection = RunService.Heartbeat:Connect(scanGifts)
        warn("[EventModule] ENABLED")
    else
        if scanConnection then
            scanConnection:Disconnect()
            scanConnection = nil
        end
        clearAll()
        warn("[EventModule] DISABLED")
    end
end

function EventModule.TeleportToNearestGift()
    local gift = getNearestGift()
    if gift then
        teleportTo(gift)
        warn("[EventModule] Teleported to Gift")
    else
        warn("[EventModule] No Gift Found")
    end
end

function EventModule.TeleportToTree()
    local tree = getChristmasTree()
    if tree then
        teleportTo(tree)
        warn("[EventModule] Teleported to Christmas Tree")
    else
        warn("[EventModule] Tree Not Found")
    end
end

--==================================================
-- GLOBAL REGISTER (CRITICAL)
--==================================================
_G.EventModule = EventModule
warn("[EventModule] Global EventModule registered")

--==================================================
-- END OF FILE
--==================================================
