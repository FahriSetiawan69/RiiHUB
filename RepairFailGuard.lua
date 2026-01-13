--==================================================
-- RepairFailGuard.lua (FINAL)
-- State-based Fail-Prevention Input Guard
-- Works for Repair Generator & Heal Survivor
-- Delta Mobile Safe | Client-side
--==================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer

--========================
-- CONFIG (SAFE DEFAULTS)
--========================
local TAP_INTERVAL = 0.98          -- ~1 detik (sinkron skill check)
local MOVE_EPSILON = 0.05          -- ambang gerak kecil (analog)
local MIN_ACTION_TIME = 0.25       -- debounce masuk aksi
local MAX_IDLE_TAP_GUARD = 0.12    -- anti false-tap singkat

--========================
-- STATE
--========================
local enabled = false
local lastTap = 0
local actionStart = 0
local lastStill = 0
local inAction = false

--========================
-- HELPERS
--========================
local function getChar()
    return player.Character
end

local function getHumanoid()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid") or nil
end

local function getRoot()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart") or nil
end

-- Simulate 1 light tap (center-ish; mobile safe)
local function tapOnce()
    VirtualInputManager:SendMouseButtonEvent(500, 500, 0, true, game, 0)
    VirtualInputManager:SendMouseButtonEvent(500, 500, 0, false, game, 0)
end

--========================
-- ACTION DETECTION (KEY)
--========================
-- Kita TIDAK pakai GUI. Kita pakai:
-- 1) Humanoid state (bukan idle)
-- 2) Gerak hampir nol (analog tidak digerakkan)
-- 3) Aksi kontinu (repair/heal) batal jika analog digerakkan
--
-- Catatan:
-- - Diam bersembunyi = Idle → TIDAK masuk aksi
-- - Repair/Heal = non-idle + tidak bergerak → MASUK aksi

local function isStill()
    local root = getRoot()
    if not root then return false end
    local v = root.AssemblyLinearVelocity
    return math.abs(v.X) < MOVE_EPSILON
       and math.abs(v.Y) < MOVE_EPSILON
       and math.abs(v.Z) < MOVE_EPSILON
end

local function isActionState()
    local hum = getHumanoid()
    if not hum then return false end

    -- State yang BUKAN repair/heal:
    -- Idle, Running, Jumping, Freefall, Climbing
    local st = hum:GetState()
    if st == Enum.HumanoidStateType.Idle then return false end
    if st == Enum.HumanoidStateType.Running then return false end
    if st == Enum.HumanoidStateType.Jumping then return false end
    if st == Enum.HumanoidStateType.Freefall then return false end
    if st == Enum.HumanoidStateType.Climbing then return false end

    -- State lain (Physics/Seated) jarang untuk repair; kita filter via "still"
    return true
end

--========================
-- CORE LOOP
--========================
RunService.RenderStepped:Connect(function(dt)
    if not enabled then
        inAction = false
        return
    end

    local hum = getHumanoid()
    local root = getRoot()
    if not hum or not root then
        inAction = false
        return
    end

    local still = isStill()
    local actionState = isActionState()

    -- Gate 1: harus benar-benar aksi repair/heal
    if actionState and still then
        -- debounce masuk aksi
        if not inAction then
            actionStart = tick()
            lastStill = tick()
            inAction = true
            return
        end

        -- pastikan aksi berkelanjutan (bukan kedip)
        if tick() - actionStart < MIN_ACTION_TIME then
            return
        end

        -- Guard: jika sempat bergerak sebentar, jangan tap
        if tick() - lastStill < MAX_IDLE_TAP_GUARD then
            return
        end

        -- Rate limit tap
        if tick() - lastTap >= TAP_INTERVAL then
            tapOnce()
            lastTap = tick()
        end
    else
        -- Keluar aksi (analog digerakkan / state berubah)
        inAction = false
        lastStill = tick()
    end
end)

--========================
-- GLOBAL TOGGLE (HOMEGUI)
--========================
_G.ToggleRepairFailGuard = function(state)
    enabled = state and true or false
    -- reset state saat toggle
    inAction = false
    lastTap = 0
    actionStart = 0
    lastStill = 0
end
