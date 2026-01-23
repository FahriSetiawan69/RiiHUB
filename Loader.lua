--==================================================
-- RIIHUB LOADER (FIX HTTP 404 + SAFE LOAD)
--==================================================

-- Anti double execute
if _G.RIIHUB_LOADED then
    warn("[RiiHUB] Loader sudah dijalankan")
    return
end
_G.RIIHUB_LOADED = true

local function loadModule(name, url)
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)

    if not success or not result then
        warn("[RiiHUB] Gagal load:", name)
        return nil
    end

    local ok, module = pcall(function()
        return loadstring(result)()
    end)

    if not ok then
        warn("[RiiHUB] Error eksekusi:", name)
        return nil
    end

    print("[RiiHUB] Loaded:", name)
    return module
end

-- ================= LOAD MODULES =================

local ESP = loadModule(
    "ESPModule",
    "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/ESPModule.lua"
)

-- ================= DEFAULT STATE =================

if ESP then
    -- Semua toggle TERPISAH
    ESP:SetPlayer(true)      -- Survivor + Killer
    ESP:SetGenerator(true)   -- Generator
    ESP:SetPallet(true)      -- Pallet
    ESP:SetGate(true)        -- Gate
else
    warn("[RiiHUB] ESPModule tidak berhasil dimuat")
end

print("[RiiHUB] Loader selesai")