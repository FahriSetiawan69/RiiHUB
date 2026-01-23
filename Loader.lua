-- RiiHUB Loader (FINAL - SAFE)

local BASE = "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/"

local function fetch(file)
    local ok, res = pcall(function()
        return game:HttpGet(BASE .. file)
    end)
    if not ok or type(res) ~= "string" or #res < 20 or res:find("<html") then
        warn("[RiiHUB] Gagal load:", file)
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

for _, name in ipairs({
    "ESPModule.lua",
    "AimAssistModule.lua",
    "EventModule.lua",
    "HitBoxKiller.lua",
    "SkillCheckGenerator.lua",
}) do
    local src = fetch(name)
    if src then
        local ok, mod = pcall(loadstring(src))
        if ok and type(mod) == "table" then
            modules[name] = mod
            print("[RiiHUB] Loaded:", name)
        else
            warn("[RiiHUB] Error module:", name)
        end
    end
end

-- Start HomeGui
local ok, err = pcall(function()
    loadstring(homeSrc)(modules)
end)

if not ok then
    warn("[RiiHUB] HomeGui error:", err)
end