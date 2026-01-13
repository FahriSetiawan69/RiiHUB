--==================================================
-- RepairFailGuard.lua
-- 1x Mid-Safe Window Auto Tap
-- Prevent Repair Miss / Explosion
-- Delta Mobile Safe | Client-side
--==================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--========================
-- CONFIG (SAFE DEFAULT)
--========================
local MID_SAFE_DELAY = 0.68   -- ~65–70% window
local MAX_UI_LIFETIME = 1.2   -- safety cutoff

--========================
-- STATE
--========================
local enabled = false
local activeSkillCheck = false
local skillStartTime = 0
local tapped = false

--========================
-- HELPER: TAP
--========================
local function tapOnce()
    -- Simulate 1 screen tap (center-bottom, safe area)
    VirtualInputManager:SendMouseButtonEvent(
        500, 500, -- arbitrary safe screen coord
        0,
        true,
        game,
        0
    )
    VirtualInputManager:SendMouseButtonEvent(
        500, 500,
        0,
        false,
        game,
        0
    )
end

--========================
-- SKILL CHECK UI DETECTOR
--========================
local function onGuiAdded(gui)
    if not enabled then return end
    if activeSkillCheck then return end

    -- Heuristic:
    -- Skill-check UI is temporary, appears suddenly, then disappears
    if gui:IsA("ScreenGui") or gui:IsA("Frame") then
        activeSkillCheck = true
        tapped = false
        skillStartTime = tick()

        -- Monitor timing window
        task.spawn(function()
            while activeSkillCheck do
                local elapsed = tick() - skillStartTime

                -- Mid-safe window tap (ONLY ONCE)
                if not tapped and elapsed >= MID_SAFE_DELAY then
                    tapOnce()
                    tapped = true
                end

                -- Safety exit
                if elapsed > MAX_UI_LIFETIME then
                    break
                end

                task.wait(0.02)
            end

            -- Reset state
            activeSkillCheck = false
            tapped = false
        end)
    end
end

--========================
-- GUI REMOVAL = END SKILL
--========================
local function onGuiRemoved(gui)
    -- When UI disappears, skill check is over
    activeSkillCheck = false
end

--========================
-- CONNECTIONS
--========================
playerGui.ChildAdded:Connect(onGuiAdded)
playerGui.ChildRemoved:Connect(onGuiRemoved)

--========================
-- GLOBAL TOGGLE (HOMEGUI)
--========================
_G.ToggleRepairFailGuard = function(state)
    enabled = state
end
