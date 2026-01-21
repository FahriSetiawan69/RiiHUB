-- LOADER.LUA (Fixed & Optimized)
local Loader = {}
_G.RiiHUB_BaseUrl = "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/"

-- Inisialisasi Variabel Global Warna (Agar tidak nil saat ESP dinyalakan)
_G.SurvivorColor = Color3.fromRGB(0, 255, 13)
_G.KillerColor = Color3.fromRGB(255, 0, 0)
_G.GenColor = Color3.fromRGB(255, 255, 0)

-- Fungsi untuk menjalankan Module dari GitHub secara dinamis
function Loader.RunModule(fileName, state)
    local success, scriptContent = pcall(function()
        return game:HttpGet(_G.RiiHUB_BaseUrl .. fileName)
    end)

    if success then
        local func, err = loadstring(scriptContent)
        if func then
            local module = func()
            if type(module) == "function" then
                module(state) -- Mengirimkan true/false ke ESPModule.lua
                print("RiiHUB: " .. fileName .. " is now " .. (state and "ON" or "OFF"))
            end
        else
            warn("RiiHUB Error: Syntax error di " .. fileName .. " -> " .. tostring(err))
        end
    else
        warn("RiiHUB Error: File tidak ditemukan di GitHub: " .. fileName)
    end
end

-- Simpan Loader ke Global agar bisa diakses HomeGui
_G.RiiLoader = Loader

-- Memanggil HomeGui.lua
print("RiiHUB: Loading UI...")
local uiSuccess, uiErr = pcall(function()
    loadstring(game:HttpGet(_G.RiiHUB_BaseUrl .. "HomeGui.lua"))()
end)

if not uiSuccess then
    warn("RiiHUB Fatal Error: Gagal memuat HomeGui -> " .. tostring(uiErr))
end

return Loader
