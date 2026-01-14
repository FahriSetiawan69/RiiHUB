--==================================================
-- EventModule.lua (FINAL - TOOL BASED PICKUP)
-- Button -> Gift ONLY
-- Detect pickup via Tool in Character
-- Auto teleport -> ChristmasTree
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

-- kata kunci nama Tool kado (case-insensitive)
local GIFT_TOOL_KEYWORDS = { "gift", "present", "christmas" }

local LOBBY_KEYWORDS = { "lobby", "spawn", "waiting", "menu" }
local TELEPORT_OFFSET = Vector3.new(0, 3, 0)

--==================================================
-- MODULE
--==================================================
local EventModule = {}
EventModule.Enabled = false

-- state
local gifts = {}
local trees = {}
local giftIndex = 1
local waitingForPickup = false
local toolConn = nil

local gui, floatBtn

--==================================================
-- UTIL
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

local function teleportToNearestTree()
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
        teleportToModel(nearest)
        print("[EventModule] Auto teleport to ChristmasTree")
    end
end

local function hasGiftTool()
    local ch = LocalPlayer.Character
    if not ch then return false end

    for _, inst in ipairs(ch:GetChildren()) do
        if inst:IsA("Tool") then
            local lname = string.lower(inst.Name)
            for _, k in ipairs(GIFT_TOOL_KEYWORDS) do
                if string.find(lname, k) then
                    return true
                end
            end
        end
    end
    return false
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
-- PICKUP DETECTOR (TOOL-BASED)
--==================================================
local function startPickupWatcher()
    if toolConn then toolConn:Disconnect() end

    toolConn = LocalPlayer.Character.ChildAdded:Connect(function(child)
        if not waitingForPickup then return end
        if not child:IsA("Tool") then return end

        local lname = string.lower(child.Name)
        for _, k in ipairs(GIFT_TOOL_KEYWORDS) do
            if string.find(lname, k) then
                waitingForPickup = false
                teleportToNearestTree()
                return
            end
        end
    end)
end

--==================================================
-- GUI
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

    -- CLICK -> TELEPORT TO GIFT ONLY
    floatBtn.MouseButton1Click:Connect(function()
        if not EventModule.Enabled then return end
        if #gifts == 0 then return end

        local gift = gifts[giftIndex]
        teleportToModel(gift)
        print("[EventModule] Teleport to Gift:", giftIndex)

        giftIndex += 1
        if giftIndex > #gifts then giftIndex = 1 end

        waitingForPickup = true
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
    createGui()

    print("[EventModule] Enabled")
end

function EventModule:Disable()
    EventModule.Enabled = false
    waitingForPickup = false

    if toolConn then toolConn:Disconnect() end
    toolConn = nil

    destroyGui()
    print("[EventModule] Disabled")
end

--==================================================
-- EXPORT
--==================================================
_G.EventModule = EventModule
return EventModule
