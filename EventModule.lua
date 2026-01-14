--==================================================
-- EventModule.lua (FINAL FIX)
-- Christmas Event Logic (MAP ONLY)
-- Gift ESP + Teleport Gift / Tree
--==================================================

local EventModule = {}

--========================
-- SERVICES
--========================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

--========================
-- CONSTANTS (LOCKED)
--========================
local MAP_ROOT_NAME = "Map"
local EVENT_FOLDER_NAME = "CHRIS"
local GIFT_FOLDER_NAME = "gLFTS"
local GIFT_MODEL_NAME = "Gift"
local TREE_MODEL_NAME = "ChristmasTree"

--========================
-- STATE
--========================
local enabled = false
local gifts = {}
local christmasTree = nil
local highlights = {}

--========================
-- UTILITIES
--========================
local function getMapRoot()
    return Workspace:FindFirstChild(MAP_ROOT_NAME)
end

local function isInMap(inst)
    local map = getMapRoot()
    if not map or not inst then return false end
    return inst:IsDescendantOf(map)
end

local function getRootPart(model)
    return model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
end

local function clearHighlights()
    for _,h in ipairs(highlights) do
        if h and h.Parent then
            h:Destroy()
        end
    end
    table.clear(highlights)
end

local function addGiftHighlight(model)
    local h = Instance.new("Highlight")
    h.FillTransparency = 1
    h.OutlineColor = Color3.fromRGB(0, 255, 120) -- hijau
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = model
    table.insert(highlights, h)
end

local function teleportToModel(model, offset)
    if not model or not isInMap(model) then return end

    local root = getRootPart(model)
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not root or not hrp then return end

    offset = offset or Vector3.new(0, 0, -3)
    hrp.CFrame = CFrame.new(root.Position + offset, root.Position)
end

--========================
-- SIGNATURE CHECK (GIFT)
--========================
local function isValidGift(model)
    if not model:IsA("Model") then return false end
    if model.Name ~= GIFT_MODEL_NAME then return false end
    if not isInMap(model) then return false end

    local partCount = 0
    local hasMesh = false
    local hasAttachment = false

    for _,d in ipairs(model:GetDescendants()) do
        if d:IsA("BasePart") then
            partCount += 1
        end
        if d:IsA("MeshPart") or d:IsA("SpecialMesh") then
            hasMesh = true
        end
        if d:IsA("Attachment") then
            hasAttachment = true
        end
    end

    return partCount == 2 and hasMesh and hasAttachment
end

--========================
-- SCAN GIFTS (MAP ONLY)
--========================
local function scanGifts()
    table.clear(gifts)
    clearHighlights()

    local map = getMapRoot()
    if not map then return end

    local chris = map:FindFirstChild(EVENT_FOLDER_NAME)
    if not chris then return end

    local giftFolder = chris:FindFirstChild(GIFT_FOLDER_NAME)
    if not giftFolder then return end

    for _,inst in ipairs(giftFolder:GetChildren()) do
        if isValidGift(inst) then
            table.insert(gifts, inst)
            addGiftHighlight(inst)
        end
    end
end

--========================
-- SCAN TREE (MAP ONLY)
--========================
local function scanTree()
    christmasTree = nil

    local map = getMapRoot()
    if not map then return end

    local chris = map:FindFirstChild(EVENT_FOLDER_NAME)
    if not chris then return end

    for _,inst in ipairs(chris:GetDescendants()) do
        if inst:IsA("Model")
            and inst.Name == TREE_MODEL_NAME
            and isInMap(inst)
        then
            christmasTree = inst
            break
        end
    end
end

--========================
-- PUBLIC API
--========================
function EventModule.Enable(state)
    enabled = state

    if enabled then
        scanGifts()
        scanTree()
        print("[EVENT] Enabled | Gifts:", #gifts, "| Tree:", christmasTree ~= nil)
    else
        clearHighlights()
        table.clear(gifts)
        christmasTree = nil
        print("[EVENT] Disabled")
    end
end

function EventModule.TeleportToNearestGift()
    if not enabled or #gifts == 0 then return end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local nearest, dist = nil, math.huge

    for _,g in ipairs(gifts) do
        local root = getRootPart(g)
        if root then
            local d = (root.Position - hrp.Position).Magnitude
            if d < dist then
                dist = d
                nearest = g
            end
        end
    end

    if nearest then
        teleportToModel(nearest)
    end
end

function EventModule.TeleportToTree()
    if not enabled or not christmasTree then return end
    teleportToModel(christmasTree, Vector3.new(0, 0, -5))
end

return EventModule
