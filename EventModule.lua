--==================================================
-- EventModule.lua (FINAL)
-- Fast Teleport | Gift Outline | Auto Pickup -> Tree
-- Button ONLY teleports to next Gift
--==================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--==================================================
-- CONFIG
--==================================================
local GIFT_MODEL_NAME = "Gift"
local TREE_MODEL_NAME = "ChristmasTree"

local LOBBY_KEYWORDS = { "lobby", "spawn", "waiting", "menu" }

-- teleport offset & speed
local TELEPORT_OFFSET = Vector3.new(0, 3, 0)
local FAST_TELEPORT = true  -- kept for clarity

-- highlight color
local GIFT_OUTLINE_COLOR = Color3.fromRGB(0, 255, 120)

-- pickup detect tuning
local PICKUP_RADIUS = 7        -- studs (HRP near gift)
local PICKUP_CONFIRM_TIME = 0.15

--==================================================
-- MODULE
--==================================================
local EventModule = {}
EventModule.Enabled = false

-- state
local gifts = {}
local trees = {}
local giftIndex = 1
local currentGift = nil
local pickupConn = nil
local gui, floatBtn
local highlights = {}

--==================================================
-- UTILS
--==================================================
local function isLobbyContainer(inst)
    local cur = inst
    while cur do
        local name = string.lower(cur.Name)
        for _, k in ipairs(LOBBY_KEYWORDS) do
            if string.find(name, k) then return true end
        end
        cur = cur.Parent
    end
    return false
end

local function getPrimary(model)
    if model.PrimaryPart then return model.PrimaryPart end
    for _, d in ipairs(model:GetDescendants()) do
        if d:IsA("BasePart") then return d end
    end
    return nil
end

local function getHRP()
    local ch = LocalPlayer.Character
    return ch and ch:FindFirstChild("HumanoidRootPart")
end

local function teleportToModel(model)
    local hrp = getHRP()
    if not hrp then return end
    local part = getPrimary(model)
    if not part then return end
    hrp.CFrame = CFrame.new(part.Position + TELEPORT_OFFSET)
end

--==================================================
-- SCAN MAP (EXCLUDE LOBBY)
--==================================================
local function scanMap()
    table.clear(gifts)
    table.clear(trees)

    for _, m in ipairs(Workspace:GetDescendants()) do
        if m:IsA("Model") then
            if m.Name == GIFT_MODEL_NAME and not isLobbyContainer(m) then
                table.insert(gifts, m)
            elseif m.Name == TREE_MODEL_NAME and not isLobbyContainer(m) then
                table.insert(trees, m)
            end
        end
    end

    print("[EventModule] Gifts:", #gifts, "| Trees:", #trees)
end

--==================================================
-- HIGHLIGHT GIFTS (GREEN OUTLINE)
--==================================================
local function clearHighlights()
    for _, h in ipairs(highlights) do
        if h then h:Destroy() end
    end
    table.clear(highlights)
end

local function applyHighlights()
    clearHighlights()
    for _, g in ipairs(gifts) do
        local h = Instance.new("Highlight")
        h.Name = "EventGiftHighlight"
        h.FillTransparency = 1
        h.OutlineTransparency = 0
        h.OutlineColor = GIFT_OUTLINE_COLOR
        h.Adornee = g
        h.Parent = g
        table.insert(highlights, h)
    end
end

--==================================================
-- AUTO PICKUP DETECTOR
-- Detect when player gets close to current gift
--==================================================
local function startPickupWatcher()
    if pickupConn then pickupConn:Disconnect() end
    pickupConn = nil

    if not currentGift then return end
    local giftPart = getPrimary(currentGift)
    if not giftPart then return end

    local t0 = 0
    pickupConn = RunService.Heartbeat:Connect(function(dt)
        if not EventModule.Enabled then return end
        local hrp = getHRP()
        if not hrp then return end

        local dist = (hrp.Position - giftPart.Position).Magnitude
        if dist <= PICKUP_RADIUS then
            t0 += dt
            if t0 >= PICKUP_CONFIRM_TIME then
                -- picked up -> auto teleport to tree
                pickupConn:Disconnect()
                pickupConn = nil
                currentGift = nil

                if #trees > 0 then
                    local idx = (giftIndex - 1) % #trees + 1
                    teleportToModel(trees[idx])
                    print("[EventModule] Auto teleport to Tree")
                end
            end
        else
            t0 = 0
        end
    end)
end

--==================================================
-- GUI (FLOATING BUTTON, DRAGGABLE)
--==================================================
local function destroyGui()
    if gui then gui:Destroy() end
    gui, floatBtn = nil, nil
end

local function createGui()
    destroyGui()

    gui = Instance.new("ScreenGui")
    gui.Name = "EventModule_GUI"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 999
    gui.Parent = PlayerGui

    floatBtn = Instance.new("TextButton")
    floatBtn.Size = UDim2.fromOffset(190, 44)
    floatBtn.Position = UDim2.fromScale(0.05, 0.7)
    floatBtn.Text = "EVENT: NEXT GIFT"
    floatBtn.Font = Enum.Font.GothamBold
    floatBtn.TextSize = 16
    floatBtn.TextColor3 = Color3.new(1,1,1)
    floatBtn.BackgroundColor3 = Color3.fromRGB(150, 90, 220)
    floatBtn.BackgroundTransparency = 0.15
    floatBtn.Parent = gui
    Instance.new("UICorner", floatBtn)

    -- drag
    do
        local dragging, startPos, dragStart
        floatBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = floatBtn.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseMovement) then
                local d = input.Position - dragStart
                floatBtn.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + d.X,
                    startPos.Y.Scale, startPos.Y.Offset + d.Y
                )
            end
        end)
        UserInputService.InputEnded:Connect(function()
            dragging = false
        end)
    end

    -- click -> teleport to next gift ONLY
    floatBtn.MouseButton1Click:Connect(function()
        if not EventModule.Enabled then return end
        if #gifts == 0 then
            warn("[EventModule] No gifts found")
            return
        end

        currentGift = gifts[giftIndex]
        teleportToModel(currentGift)
        print("[EventModule] Teleport to Gift:", giftIndex)

        giftIndex += 1
        if giftIndex > #gifts then giftIndex = 1 end

        startPickupWatcher()
    end)
end

--==================================================
-- PUBLIC API
--==================================================
function EventModule:Enable()
    if EventModule.Enabled then return end
    EventModule.Enabled = true

    scanMap()
    applyHighlights()
    createGui()

    print("[EventModule] Enabled")
end

function EventModule:Disable()
    EventModule.Enabled = false

    if pickupConn then pickupConn:Disconnect() pickupConn = nil end
    currentGift = nil

    clearHighlights()
    destroyGui()

    print("[EventModule] Disabled")
end

--==================================================
-- EXPORT
--==================================================
_G.EventModule = EventModule
return EventModule
