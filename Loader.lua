-- RiiHUB Loader FINAL (SESUI REPO)

local BASE = "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/"

-- file → global name (WAJIB SAMA DENGAN HOMEGUI)
local MODULES = {
    ["ESPModule.lua"] = "ESPModule",
    ["AimAssistModule.lua"] = "AimAssistModule",
    ["EventModule.lua"] = "EventModule",
    ["HitBoxKiller.lua"] = "HitBoxKiller",
    ["SkillCheckGenerator.lua"] = "SkillCheckGenerator",
}

print("[RiiHUB] Loader start")

for file, globalName in pairs(MODULES) do
    local url = BASE .. file
    local ok, src = pcall(function()
        return game:HttpGet(url)
    end)

    if not ok or type(src) ~= "string" or #src < 20 or src:find("<html") then
        warn("[RiiHUB] Gagal load:", file)
    else
        local fn, err = loadstring(src)
        if not fn then
            warn("[RiiHUB] Syntax error:", file, err)
        else
            local success, mod = pcall(fn)
            if success and type(mod) == "table" then
                _G[globalName] = mod
                print("[RiiHUB] Inject:", globalName)
            else
                warn("[RiiHUB] Module invalid:", file)
            end
        end
    end
end

-- Load HomeGui (TIDAK DIUBAH)
print("[RiiHUB] Loading HomeGui")

local ok, err = pcall(function()
    loadstring(game:HttpGet(BASE .. "HomeGui.lua"))()
end)

if not ok then
    warn("[RiiHUB] HomeGui error:", err)
end