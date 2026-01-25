-- Loader.lua FINAL

_G.RiiHUB = _G.RiiHUB or {}

print("========== RiiHUB DEBUG ==========")
print("PlaceId:", game.PlaceId)
print("JobId:", game.JobId)

local MAP = {
    [93978595733734] = "ViolenceDistrict",
    [6358567974]     = "SalonDeFiestas",
}

local gameFolder = MAP[game.PlaceId]
if not gameFolder then
    warn("[RiiHUB] Game tidak didukung")
    return
end

print("[RiiHUB] Game detected:", gameFolder)

-- Load main.lua
local mainUrl = ("https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/%s/main.lua"):format(gameFolder)
loadstring(game:HttpGet(mainUrl))()

repeat task.wait() until _G.RiiHUB.Game

-- Load HomeGui
local homeUrl = "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/HomeGui.lua"
loadstring(game:HttpGet(homeUrl))()