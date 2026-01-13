--==================================================
-- RepairFailGuard.lua (ANIMATION-BASED FINAL)
-- Triggered ONLY by repair/heal animation
-- Delta Mobile Safe | Client-side
--==================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer

--========================
-- CONFIG
--========================
local TARGET_ANIM = "rbxassetid://131815550993649"
local TAP_INTERVAL = 0.95   -- ~1 detik (skill check window)

--========================
-- STATE
--========================
local enabled = false
local animActive = false
local lastTap = 0

--========================
-- TAP
--========================
local function tapOnce()
    VirtualInputManager:SendMouseButtonEvent(500, 500, 0, true, game, 0)
    VirtualInputManager:SendMouseButtonEvent(500, 500, 0, false, game, 0)
end

--========================
-- ANIMATION HOOK
--========================
local function hookCharacter(char)
    local humanoid = char:WaitForChild("Humanoid", 5)
    if not humanoid then return end

    local animator = humanoid:WaitForChild("Animator", 5)
    if not animator then return end

    animator.AnimationPlayed:Connect(function(track)
        local anim = track.Animation
        if not anim then return end

        if anim.AnimationId == TARGET_ANIM then
            animActive = true

            -- Stop when animation stops
            track.Stopped:Connect(function()
                animActive = false
            end)
        end
    end)
end

-- Hook character
if player.Character then
    hookCharacter(player.Character)
end
player.CharacterAdded:Connect(hookCharacter)

--========================
-- CORE LOOP
--========================
RunService.RenderStepped:Connect(function()
    if not enabled then return end
    if not animActive then return end

    if tick() - lastTap >= TAP_INTERVAL then
        tapOnce()
        lastTap = tick()
    end
end)

--========================
-- TOGGLE FROM HOMEGUI
--========================
_G.ToggleRepairFailGuard = function(state)
    enabled = state and true or false
    if not enabled then
        animActive = false
        lastTap = 0
    end
end
