-- Loader.lua (FINAL CLEAN ROUTER)

print("[RiiHUB] Loader start")

_G.RiiHUB = _G.RiiHUB or {}

local GAME_MAP = {
    [93978595733734] = "ViolenceDistrict",
    [6358567974] = "SalonDeFiestas",
}

local folder = GAME_MAP[game.PlaceId]
if not folder then
    warn("[RiiHUB] Game tidak didukung:", game.PlaceId)
    return
end

-- Load HomeGui FIRST
local homeUrl = "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/HomeGui.lua"
local okUI, errUI = pcall(function()
    loadstring(game:HttpGet(homeUrl))()
end)

if not okUI then
    warn("[RiiHUB] Gagal load HomeGui.lua")
    warn(errUI)
    return
end

-- Tunggu UI API siap
repeat task.wait() until _G.RiiHUB_UI

print("[RiiHUB] UI Engine ready")

-- Load Game main.lua
local mainUrl = ("https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/%s/main.lua"):format(folder)
local okGame, errGame = pcall(function()
    loadstring(game:HttpGet(mainUrl))()
end)

if not okGame then
    warn("[RiiHUB] Gagal load main.lua game")
    warn(errGame)
    return
end

print("[RiiHUB] Game loaded:", folder)