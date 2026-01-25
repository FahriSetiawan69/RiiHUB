-- RiiHUB Loader.lua (FINAL STABLE)

if _G.__RIIHUB_LOADER_LOCK then
    return
end
_G.__RIIHUB_LOADER_LOCK = true

print("[RiiHUB] Loader start")

-------------------------------------------------
-- LOAD HOME GUI (ONCE)
-------------------------------------------------
if not _G.RiiHUB_UI then
    local ok, err = pcall(function()
        loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/HomeGui.lua"
        ))()
    end)

    if not ok then
        warn("[RiiHUB] Failed to load HomeGui:", err)
        return
    end

    print("[RiiHUB] HomeGui READ")
else
    print("[RiiHUB] HomeGui already loaded")
end

-------------------------------------------------
-- WAIT UI ENGINE READY (NO LOOP CALL)
-------------------------------------------------
task.spawn(function()
    while not (_G.RiiHUB_UI and _G.RiiHUB_UI.Ready) do
        task.wait()
    end

    print("[RiiHUB] UI Engine ready")

    -------------------------------------------------
    -- GAME DETECTION (ONCE)
    -------------------------------------------------
    local placeId = game.PlaceId
    local gameMap = {
        [93978595733734] = "ViolenceDistrict",
        [6358567974]     = "SalonDeFiestas"
    }

    local gameName = gameMap[placeId]
    if not gameName then
        warn("[RiiHUB] Game not supported:", placeId)
        return
    end

    if _G.__RIIHUB_GAME_LOADED then
        return
    end
    _G.__RIIHUB_GAME_LOADED = true

    -------------------------------------------------
    -- LOAD GAME MAIN.LUA (ONCE)
    -------------------------------------------------
    print("[RiiHUB] Loading game:", gameName)

    local ok, err = pcall(function()
        loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/" .. gameName .. "/main.lua"
        ))()
    end)

    if not ok then
        warn("[RiiHUB] Failed to load main.lua:", err)
        return
    end

    print("[RiiHUB] " .. gameName .. " main.lua loaded")
end)