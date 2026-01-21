-- LOADER.LUA (RiiHUB Optimized Toggle System)
local BaseURL = "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/"
local Modules = {} -- Menyimpan script yang sudah didownload agar tidak download ulang terus-menerus

-- Fungsi untuk mengambil script dari GitHub
local function GetScript(file)
    if Modules[file] then return Modules[file] end -- Ambil dari cache jika sudah ada
    
    local success, content = pcall(function()
        return game:HttpGet(BaseURL .. file)
    end)
    
    if success and content then
        local func, err = loadstring(content)
        if func then
            Modules[file] = func -- Simpan ke cache
            return func
        else
            warn("Syntax Error dalam file: " .. file .. " | " .. tostring(err))
        end
    else
        warn("Gagal mendownload file: " .. file)
    end
    return nil
end

-- 1. Load HomeGui sebagai pondasi UI
local HomeGuiScript = GetScript("HomeGui.lua")
if HomeGuiScript then
    local UI = HomeGuiScript() -- Menjalankan HomeGui.lua dan menerima tabel GUI
    
    if UI and UI.Tabs then
        print("[RiiHUB] UI Loaded, Connecting Modules...")

        -- 2. KONEKSI DINAMIS UNTUK SETIAP TOGGLE
        -- Kita looping setiap tab yang didaftarkan di HomeGui
        for fileName, tabData in pairs(UI.Tabs) do
            
            -- Kita berikan fungsi (callback) ke setiap tombol ON/OFF di HomeGui
            tabData:SetCallback(function(isActive)
                print("[RiiHUB] Module " .. fileName .. " set to: " .. tostring(isActive))
                
                local moduleFunc = GetScript(fileName)
                if moduleFunc then
                    -- Menjalankan module dengan parameter true/false
                    -- Catatan: Script module kamu (misal ESPModule.lua) harus bisa menerima parameter
                    task.spawn(function()
                        moduleFunc(isActive)
                    end)
                end
            end)
            
        end
    end
else
    warn("[RiiHUB] Gagal memuat HomeGui. Cek koneksi atau URL GitHub.")
end

-- Info tambahan di Console
print("--- RiiHUB LOADED SUCCESSFULLY ---")
