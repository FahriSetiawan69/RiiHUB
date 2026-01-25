-- Loader.lua (RiiHUB FINAL FIX)
-- Tugas: Load HomeGui DULU, baru load main.lua game

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ===============================
-- DEBUG INFO
-- ===============================
print("========== RiiHUB DEBUG ==========")
print("PlaceId :", game.PlaceId)
print("JobId   :", game.JobId)
print("Game    :", game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)
print("=================================")

-- ===============================
-- LOAD HOMEGUI FIRST (WAJIB)
-- ===============================
local successGui, errGui = pcall(function()
    loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/HomeGui.lua"
    ))()
end)

if not successGui then
    warn("[RiiHUB] Gagal load HomeGui.lua")
    warn(errGui)
    return
end

-- ===============================
-- WAIT UI API READY
-- ===============================
local timeout = 0
while not _G.RiiHUB_RegisterMenu do
    task.wait(0.05)
    timeout += 0.05
    if timeout > 5 then
        warn("[RiiHUB] UI API timeout (HomeGui gagal init)")
        return
    end
end

print("[RiiHUB] UI API siap")

-- ===============================
-- GAME ROUTER
-- ===============================
local GAME_MAIN = {
    [93978595733734] = "ViolenceDistrict/main.lua",
    [6358567974]     = "SalonDeFiestas/main.lua",
}

local path = GAME_MAIN[game.PlaceId]

if not path then
    warn("[RiiHUB] Game tidak didukung, UI tidak dimuat")
    return
end

-- ===============================
-- LOAD GAME MAIN
-- ===============================
local successMain, errMain = pcall(function()
    loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/" .. path
    ))()
end)

if not successMain then
    warn("[RiiHUB] Gagal load game main.lua")
    warn(errMain)
    return
end

print("[RiiHUB] Game module loaded:", path)
