-- Loader.lua (FINAL)

local Players = game:GetService("Players")
local lp = Players.LocalPlayer

_G.RiiHUB = _G.RiiHUB or {}

-- Debug dasar
print("========== RiiHUB DEBUG ==========")
print("PlaceId :", game.PlaceId)
print("JobId   :", game.JobId)

-- Mapping PlaceId ke folder game
local GAME_MAP = {
    [93978595733734] = "ViolenceDistrict", -- Violence District
    [6358567974]     = "SalonDeFiestas",   -- contoh
}

local folder = GAME_MAP[game.PlaceId]

if not folder then
    warn("[RiiHUB] Game tidak didukung. Loader berhenti.")
    return
end

print("[RiiHUB] Game terdeteksi :", folder)

-- Load main.lua game
local mainUrl = ("https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/%s/main.lua"):format(folder)
local success, err = pcall(function()
    loadstring(game:HttpGet(mainUrl))()
end)

if not success then
    warn("[RiiHUB] Gagal load main.lua :", err)
    return
end

-- Pastikan data game sudah siap
repeat task.wait() until _G.RiiHUB.Game

-- Load HomeGui
local homeGuiUrl = "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/HomeGui.lua"
local ok, guiErr = pcall(function()
    loadstring(game:HttpGet(homeGuiUrl))()
end)

if not ok then
    warn("[RiiHUB] Gagal load HomeGui :", guiErr)
end