--========================================
-- RiiHUB Event Module (Christmas)
-- FINAL • STEALTH • FAST • MAP-ONLY
--========================================

local EventModule = {}
EventModule.Enabled = false

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Player
local LocalPlayer = Players.LocalPlayer

-- State
local connections = {}
local giftHighlights = {}
local floatingGui
local mapCtx -- { map, chris }

--==============================
-- LOG
--==============================
local function log(msg)
    print("[RiiHUB EVENT]", msg)
end

--==============================
-- SAFE MAP WAIT (NO LOBBY)
--==============================
local function waitForGameMap(timeout)
    timeout = timeout or 40
    local t0 = tick()
    while tick() - t0 < timeout do
        local map = Workspace:FindFirstChild("Map")
        if map then
            local chris = map:FindFirstChild("chris")
            local trees = chris and chris:FindFirstChild("ChristmasTrees")
            if chris and trees then
                return { map = map, chris = chris }
            end
        end
        task.wait(0.3)
    end
    return nil
end

--==============================
-- UTILS
--==============================
local function getChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getRoot()
    return getChar():WaitForChild("HumanoidRootPart")
end

local function getModelCF(model)
    local cf = model:GetBoundingBox()
    return cf
end

--==============================
-- FIND CHRISTMAS TREE (MAP ONLY)
--==============================
local function getChristmasTree(chris)
    local root = chris:FindFirstChild("ChristmasTrees")
    if not root then return nil end
    for _, m in ipairs(root:GetChildren()) do
        if m:IsA("Model") and m.Name == "ChristmasTree" then
            return m
        end
    end
    return nil
end

--==============================
-- FIND GIFTS (MAP ONLY)
--==============================
local function getGifts(chris)
    local list = {}
    for _, d in ipairs(chris:GetDescendants()) do
        if d:IsA("Model") and d.Name == "Gift" then
            table.insert(list, d)
        end
    end
    return list
end

--==============================
-- HIGHLIGHT GIFTS (LIGHT)
--==============================
local function clearHighlights()
    for _, h in ipairs(giftHighlights) do
        h:Destroy()
    end
    giftHighlights = {}
end

local function highlightGifts(chris)
    clearHighlights()
    local gifts = getGifts(chris)
    for _, g in ipairs(gifts) do
        local h = Instance.new("Highlight")
        h.FillColor = Color3.fromRGB(0,255,120)
        h.OutlineColor = Color3.fromRGB(0,180,80)
        h.FillTransparency = 0.6
        h.OutlineTransparency = 0
        h.Parent = g
        table.insert(giftHighlights, h)
    end
    log("Gift highlighted: "..#giftHighlights)
end

--==============================
-- STEALTH TELEPORT (2-STEP)
-- Step 1: micro offset (server tick sync)
-- Step 2: final snap (very fast)
--==============================
local function stealthTeleport(cf)
    local root = getRoot()
    root.AssemblyLinearVelocity = Vector3.zero
    root.CFrame = cf * CFrame.new(0, 0.15, 0) -- micro step
    RunService.Heartbeat:Wait()
    root.CFrame = cf -- final snap
end

--==============================
-- TELEPORT TO NEAREST GIFT
--==============================
local function teleportToNearestGift(chris)
    local root = getRoot()
    local gifts = getGifts(chris)
    if #gifts == 0 then
        log("No gifts found")
        return
    end

    local best, dist = nil, math.huge
    for _, g in ipairs(gifts) do
        local cf = getModelCF(g)
        local d = (root.Position - cf.Position).Magnitude
        if d < dist then
            dist = d
            best = g
        end
    end

    if best then
        local targetCF = getModelCF(best) * CFrame.new(0,0,-2.5)
        stealthTeleport(targetCF)
        log("Stealth TP -> Gift")
    end
end

--==============================
-- AUTO TP AFTER PICKUP
--==============================
local function hookAutoTeleport(chris)
    local char = getChar()
    connections.pick = char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") and child.Name == "Gift" then
            task.wait(0.12) -- very short delay
            local tree = getChristmasTree(chris)
            if tree then
                local cf = getModelCF(tree) * CFrame.new(0,0,-3.5)
                stealthTeleport(cf)
                log("Auto TP -> ChristmasTree")
            else
                log("Tree not found (map lock)")
            end
        end
    end)
end

--==============================
-- FLOATING BUTTON (DRAGGABLE)
--==============================
local function createFloatingButton(chris)
    local gui = Instance.new("ScreenGui")
    gui.Name = "RiiHUB_EventGUI"
    gui.ResetOnSpawn = false
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromOffset(160, 48)
    btn.Position = UDim2.fromScale(0.5, 0.75)
    btn.AnchorPoint = Vector2.new(0.5, 0.5)
    btn.Text = "TELE TO GIFT"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 15
    btn.BackgroundColor3 = Color3.fromRGB(120,80,200)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Parent = gui
    btn.ZIndex = 9999
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,14)

    -- Drag
    local dragging, startPos, startInput
    btn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startPos = btn.Position
            startInput = i.Position
        end
    end)
    btn.InputEnded:Connect(function()
        dragging = false
    end)
    connections.drag = RunService.RenderStepped:Connect(function()
        if dragging then
            local delta = UserInputService:GetMouseLocation() - startInput
            btn.Position = startPos + UDim2.fromOffset(delta.X, delta.Y)
        end
    end)

    btn.MouseButton1Click:Connect(function()
        teleportToNearestGift(chris)
    end)

    floatingGui = gui
end

--==============================
-- ENABLE / DISABLE
--==============================
function EventModule.Enable()
    if EventModule.Enabled then return end
    EventModule.Enabled = true

    log("Enable requested")
    mapCtx = waitForGameMap(45)
    if not mapCtx then
        log("Map not ready, EventModule idle")
        return
    end

    highlightGifts(mapCtx.chris)
    createFloatingButton(mapCtx.chris)
    hookAutoTeleport(mapCtx.chris)

    log("EventModule ENABLED (map confirmed)")
end

function EventModule.Disable()
    EventModule.Enabled = false
    clearHighlights()

    if floatingGui then
        floatingGui:Destroy()
        floatingGui = nil
    end

    for _, c in pairs(connections) do
        c:Disconnect()
    end
    connections = {}

    log("EventModule DISABLED")
end

return EventModule
