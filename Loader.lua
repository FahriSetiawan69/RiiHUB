-- RiiHUB Loader - Game Specific Fix
local MainFolder = script.Parent
local PlaceId = game.PlaceId

local RiiHUB = {
    Version = "1.0.7",
}

-- DAFTAR ID GAME
local GameMaps = {
    [93978595733734] = "ViolenceDistrict", -- ID Panjang (Pastikan PlaceId)
    [6358567974] = "SalonDeFiestas",      -- Salon De Fiestas
}

-- Deteksi Folder Berdasarkan Game
local folderName = GameMaps[PlaceId] or "Others"
local SelectedFolder = MainFolder:FindFirstChild(folderName)

print("[RiiHUB] Initializing...")
print("[RiiHUB] Current PlaceId: " .. tostring(PlaceId))

if SelectedFolder then
    print("[RiiHUB] Target Folder Found: " .. folderName)
    local HomeGuiModule = MainFolder:FindFirstChild("HomeGui")
    
    if HomeGuiModule then
        local HomeGui = require(HomeGuiModule)
        task.spawn(function()
            -- Kirim folder yang terdeteksi ke UI untuk di-render
            HomeGui:Init(SelectedFolder) 
        end)
    else
        warn("[RiiHUB] Error: HomeGui.lua tidak ditemukan!")
    end
else
    warn("[RiiHUB] PlaceId tidak terdaftar di GameMaps. Memuat folder 'Others'...")
    local OthersFolder = MainFolder:FindFirstChild("Others")
    local HomeGui = require(MainFolder.HomeGui)
    HomeGui:Init(OthersFolder)
end

return RiiHUB
