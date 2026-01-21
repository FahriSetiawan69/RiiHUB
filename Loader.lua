-- LOADER.LUA (Main Entry)
local BaseURL = "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/"

local function LoadFromRepo(fileName)
    local success, content = pcall(function()
        return game:HttpGet(BaseURL .. fileName)
    end)
    if success and content then
        local func, err = loadstring(content)
        if func then return func() else warn("Error in " .. fileName .. ": " .. err) end
    else
        warn("Gagal mengambil file: " .. fileName)
    end
end

-- 1. Load HomeGui sebagai pondasi UI
local UI = LoadFromRepo("HomeGui.lua")

if UI and UI.Tabs then
    -- 2. Koneksi Otomatis berdasarkan nama file di repository
    -- Nama Tab di HomeGui.lua HARUS sama dengan nama file di GitHub
    for fileName, button in pairs(UI.Tabs) do
        button.Activated:Connect(function()
            print("Executing Module: " .. fileName)
            LoadFromRepo(fileName) -- Memanggil file seperti 'ESPModule.lua'
            
            -- Feedback Visual
            button.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            task.wait(0.3)
            button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        end)
    end
end
