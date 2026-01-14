--========================================
-- RiiHUB Event Module (Christmas FINAL FIX)
-- SAFE MAP WAIT (NO INFINITE YIELD)
--========================================

local EventModule = {}
EventModule.Enabled = false

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

--==============================
-- STATE
--==============================
local giftHighlights = {}
local floatingGui
local connections = {}

--==============================
-- LOG
--==============================
local function log(msg)
    print("[RiiHUB EVENT]", msg)
end

--==============================
-- WAIT FOR MAP GAME (SAFE)
--==============================
local function waitForGameMap(timeout)
    timeout = timeout or 30
    local start = tick()

    while tick() - start < timeout do
        local map = Workspace:FindFirstChild("Map")
        if map then
            local chris = map:FindFirstChild("chris")
            if chris and chris:FindFirstChild("ChristmasTrees") then
                return map, chris
            end
        end
        task.wait(0.5)
    end

    return nil
end

--==============================
-- UTILS
--==============================
local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getModelCFrame(model)
    local cf, _ = model:GetBoundingBox()
    return cf
end

--==============================
-- FIND CHRISTMAS TREE (MAP ONLY)
--==============================
local function getChristmasTree(chris)
    local root = chris:FindFirstChild("ChristmasTrees")
    if not root then return nil end

    for _, obj in ipairs(root:GetChildren()) do
        if obj:IsA("Model") and obj.Name == "ChristmasTree" then
            return obj
        end
    end
    return nil
end

--==============================
-- FIND GIFTS (MAP ONLY)
--==============================
local function getGifts(chris)
    local list = {}
    for _, obj in ipairs(chris:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == "Gift" then
            table.insert(list, obj)
        end
    end
    return list
end

--==============================
-- HIGHLIGHT GIFTS
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

    for _, gift in ipairs(gifts) do
        local h = Instance.new("Highlight")
        h.FillColor = Color3.fromRGB(0,255,120)
        h.OutlineColor = Color3.fromRGB(0,180,80)
        h.FillTransparency = 0.55
        h.Parent = gift
        table.insert(giftHighlights, h)
    end

    log("Gift highlighted: "..#giftHighlights)
end

--==============================
-- TELEPORT TO NEAREST GIFT
--==============================
local function teleportToGift(chris)
    local char = getCharacter()
    local root = char:WaitForChild("HumanoidRootPart")
    local gifts = getGifts(chris)

    if #gifts == 0 then
        log("No gifts found")
        return
    end

    local closest, dist = nil, math.huge
    for _, g in ipairs(gifts) do
        local cf = getModelCFrame(g)
        local d = (root.Position - cf.Position).Magnitude
        if d < dist then
            dist = d
            closest = g
        end
    end

    if closest then
        root.CFrame = getModelCFrame(closest) * CFrame.new(0,0,-3)
        log("Teleported to gift")
    end
end

--==============================
-- AUTO TELEPORT AFTER PICKUP
--==============================
local function setupAutoTeleport(chris)
    local char = getCharacter()

    connections.pickup = char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") and child.Name == "Gift" then
            task.wait(0.2)
            local tree = getChristmasTree(chris)
            if tree then
                char.HumanoidRootPart.CFrame =
                    getModelCFrame(tree) * CFrame.new(0,0,-4)
                log("Auto teleported to ChristmasTree")
            end
        end
    end)
end

--==============================
-- FLOATING BUTTON
--==============================
local function createFloatingButton(chris)
    local gui = Instance.new("ScreenGui")
    gui.Name = "RiiHUB_EventGUI"
    gui.ResetOnSpawn = false
    gui.Parent = LocalPlayer.PlayerGui

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromOffset(160,50)
    btn.Position = UDim2.fromScale(0.5,0.7)
    btn.AnchorPoint = Vector2.new(0.5,0.5)
    btn.Text = "TELE TO GIFT"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.BackgroundColor3 = Color3.fromRGB(120,80,200)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Parent = gui
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,14)

    btn.MouseButton1Click:Connect(function()
        teleportToGift(chris)
    end)

    floatingGui = gui
end

--==============================
-- ENABLE / DISABLE
--==============================
function EventModule.Enable()
    if EventModule.Enabled then return end
    EventModule.Enabled = true

    log("Waiting for game map...")
    local map, chris = waitForGameMap(40)
    if not map then
        log("Map not found, abort EventModule")
        return
    end

    highlightGifts(chris)
    createFloatingButton(chris)
    setupAutoTeleport(chris)

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
