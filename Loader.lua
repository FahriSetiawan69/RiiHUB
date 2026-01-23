-- RiiHUB Loader (Delta Safe)

local BASE = "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/"

local function fetch(name)
    local url = BASE .. name
    local ok, res = pcall(function()
        return game:HttpGet(url)
    end)
    if not ok or type(res) ~= "string" or #res < 20 then
        warn("[RiiHUB] Gagal load:", name)
        return nil
    end
    if res:find("<html") then
        warn("[RiiHUB] Bukan RAW:", name)
        return nil
    end
    return res
end

print("[RiiHUB] Loader start")

-- Load HomeGui
local homeSrc = fetch("HomeGui.lua")
if not homeSrc then return end

-- Load Modules
local modules = {}

for _,m in ipairs({
    "ESPModule.lua",
    "AimAssistModule.lua",
    "EventModule.lua",
    "HitBoxKiller.lua",
    "SkillCheckGenerator.lua"
}) do
    local src = fetch(m)
    if src then
        local ok, mod = pcall(loadstring(src))
        if ok and type(mod) == "table" then
            modules[m] = mod
            print("[RiiHUB] Loaded:", m)
        else
            warn("[RiiHUB] Error load:", m)
        end
    end
end

-- Jalankan HomeGui
local ok, err = pcall(function()
    loadstring(homeSrc)(modules)
end)

if not ok then
    warn("[RiiHUB] HomeGui error:", err)
end