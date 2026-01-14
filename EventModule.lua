--==================================================
-- EventModule.lua (FINAL - 2 BUTTON MODE)
-- Button GIFT  -> teleport to Gift
-- Button TREE  -> teleport to Tree
-- Gift outlined (green), Tree no outline
--==================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--==================================================
-- CONFIG
--==================================================
local GIFT_MODEL_NAME = "Gift"
local TREE_MODEL_NAME = "ChristmasTree"

local LOBBY_KEYWORDS = { "lobby", "spawn", "waiting", "menu" }

local GIFT_OUTLINE_COLOR = Color3.fromRGB(0, 255, 120)
local GIFT_UP_OFFSET = 3
local TREE_FORWARD_OFFSET = 6
local TREE_UP_OFFSET = 2

--==================================================
-- MODULE
--==================================================
local EventModule = {}
EventModule.Enabled = false

local gifts, trees = {}, {}
local giftIndex = 1
local gui, giftBtn, treeBtn
local highlights = {}

--==================================================
-- UTILS
--==================================================
local function isLobbyContainer(inst)
    local cur = inst
    while cur do
        local n = string.lower(cur.Name)
        for _, k in ipairs(LOBBY_KEYWORDS) do
            if string.find(n, k) then return true end
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
end

local function getHRP()
    local ch = LocalPlayer.Character
    return ch and ch:FindFirstChild("HumanoidRootPart")
end

--==================================================
-- SCAN MAP
--==================================================
local function scanMap()
    table.clear(gifts)
    table.clear(trees)

    for _, m in ipairs(Workspace:GetDescendants()) do
        if m:IsA("Model") and not isLobbyContainer(m) then
            if m.Name == GIFT_MODEL_NAME then
                table.insert(gifts, m)
            elseif m.Name == TREE_MODEL_NAME then
                table.insert(trees, m)
            end
        end
    end

    print("[EventModule] Gifts:", #gifts, "| Trees:", #trees)
end

--==================================================
-- HIGHLIGHT GIFTS ONLY
--==================================================
local function clearHighlights()
    for _, h in ipairs(highlights) do
        if h then h:Destroy() end
    end
    table.clear(highlights)
end

local function applyGiftHighlight()
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
-- TELEPORT LOGIC
--==================================================
local function teleportToGift()
    if #gifts == 0 then return end
    local hrp = getHRP()
    local gift = gifts[giftIndex]
    local p = getPrimary(gift)

    if hrp and p then
        hrp.CFrame = CFrame.new(p.Position + Vector3.new(0, GIFT_UP_OFFSET, 0))
        print("[EventModule] Teleport -> Gift", giftIndex)
    end

    giftIndex += 1
    if giftIndex > #gifts then giftIndex = 1 end
end

local function teleportToNearestTree()
    if #trees == 0 then return end
    local hrp = getHRP()
    if not hrp then return end

    local nearest, best = nil, math.huge
    for _, t in ipairs(trees) do
        local p = getPrimary(t)
        if p then
            local d = (p.Position - hrp.Position).Magnitude
            if d < best then
                best = d
                nearest = t
            end
        end
    end

    if nearest then
        local p = getPrimary(nearest)
        local cf = p.CFrame
        local pos =
            cf.Position
            - cf.LookVector * TREE_FORWARD_OFFSET
            + Vector3.new(0, TREE_UP_OFFSET, 0)

        hrp.CFrame = CFrame.new(pos, cf.Position)
        print("[EventModule] Teleport -> Tree")
    end
end

--==================================================
-- GUI (2 BUTTONS, DRAGGABLE)
--==================================================
local function destroyGui()
    if gui then gui:Destroy() end
    gui, giftBtn, treeBtn = nil, nil, nil
end

local function createGui()
    destroyGui()

    gui = Instance.new("ScreenGui")
    gui.Name = "EventModule_GUI"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 999
    gui.Parent = PlayerGui

    local function createButton(text, posY)
        local b = Instance.new("TextButton")
        b.Size = UDim2.fromOffset(160, 44)
        b.Position = UDim2.fromScale(0.05, posY)
        b.Text = text
        b.Font = Enum.Font.GothamBold
        b.TextSize = 16
        b.TextColor3 = Color3.new(1,1,1)
        b.BackgroundColor3 = Color3.fromRGB(150, 90, 220)
        b.BackgroundTransparency = 0.15
        b.Parent = gui
        Instance.new("UICorner", b)
        return b
    end

    giftBtn = createButton("EVENT: GIFT", 0.65)
    treeBtn = createButton("EVENT: TREE", 0.72)

    -- DRAG GROUP
    do
        local dragging, dragStart, startPos
        giftBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = giftBtn.Position
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseMovement) then
                local d = input.Position - dragStart
                giftBtn.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + d.X,
                    startPos.Y.Scale, startPos.Y.Offset + d.Y
                )
                treeBtn.Position = giftBtn.Position + UDim2.fromOffset(0, 50)
            end
        end)

        UserInputService.InputEnded:Connect(function()
            dragging = false
        end)
    end

    giftBtn.MouseButton1Click:Connect(function()
        if EventModule.Enabled then teleportToGift() end
    end)

    treeBtn.MouseButton1Click:Connect(function()
        if EventModule.Enabled then teleportToNearestTree() end
    end)
end

--==================================================
-- PUBLIC API
--==================================================
function EventModule:Enable()
    if EventModule.Enabled then return end
    EventModule.Enabled = true

    scanMap()
    applyGiftHighlight()
    createGui()

    print("[EventModule] Enabled")
end

function EventModule:Disable()
    EventModule.Enabled = false
    clearHighlights()
    destroyGui()
    print("[EventModule] Disabled")
end

--==================================================
-- EXPORT
--==================================================
_G.EventModule = EventModule
return EventModule
