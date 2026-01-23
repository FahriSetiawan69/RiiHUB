-- ESPModule.lua (Fixed Version)
local ESP = {
    States = {},
    Folders = {}
}

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local pgui = lp:WaitForChild("PlayerGui")

-- Fungsi untuk mendapatkan atau membuat folder khusus per kategori
local function GetCategoryFolder(name)
    local folderName = "Rii_ESP_" .. name
    local folder = pgui:FindFirstChild(folderName)
    if not folder then
        folder = Instance.new("Folder", pgui)
        folder.Name = folderName
    end
    return folder
end

-- Fungsi membuat Box Visual (Logic asli kamu)
local function CreateBox(obj, category, color)
    local folder = GetCategoryFolder(category)
    
    local bbg = Instance.new("BillboardGui", folder)
    bbg.Name = "ESP_Tag"
    bbg.Adornee = obj
    bbg.AlwaysOnTop = true
    bbg.Size = UDim2.new(4, 0, 4, 0)
    bbg.DistanceUpperLimit = 10000

    local frame = Instance.new("Frame", bbg)
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.BorderColor3 = color
    frame.BorderSizePixel = 2
end

-- Logic Pengecekan Objek (Tetap menggunakan logic asli kamu)
local function CheckObject(v)
    if not v:IsA("BasePart") and not v:IsA("MeshPart") then return end
    local p = v.Parent
    if not p then return end

    -- Generator Logic
    if ESP.States["Generator"] and v.Name == "HitBox" and p.Name == "Generator" then
        CreateBox(v, "Generator", Color3.fromRGB(255, 255, 0))
    
    -- Pallet Logic
    elseif ESP.States["Pallet"] and v.Name == "HumanoidRootPart" and p.Name == "Palletwrong" then
        CreateBox(v, "Pallet", Color3.fromRGB(255, 165, 0))
    
    -- Gate Logic
    elseif ESP.States["Gate"] and v.Name == "MeshPart" and p.Name == "ExitLever" then
        CreateBox(v, "Gate", Color3.fromRGB(0, 0, 255))
        
    -- Window Logic
    elseif ESP.States["Window"] and v.Name == "inviswall" and p.Name == "Window" then
        CreateBox(v, "Window", Color3.fromRGB(0, 255, 255))

    -- Survivor / Player Logic (Jika ada)
    elseif ESP.States["Survivor"] and v.Name == "HumanoidRootPart" and p:FindFirstChild("Humanoid") and p.Name ~= lp.Name then
        CreateBox(v, "Survivor", Color3.fromRGB(0, 255, 0))
    end
end

-- Watcher: Otomatis deteksi objek baru (Anti-StreamingEnabled)
if not _G.RiiWatcherActive then
    _G.RiiWatcherActive = true
    workspace.DescendantAdded:Connect(function(v)
        -- Beri jeda sedikit agar properti objek ter-load sempurna
        task.wait(0.1)
        CheckObject(v)
    end)
end

-- Fungsi Utama yang dipanggil oleh HomeGui.lua
return function(category, state)
    -- Simpan status toggle
    ESP.States[category] = state
    
    if state == true then
        -- Jika ON: Scan semua objek yang sudah ada di workspace
        for _, v in pairs(workspace:GetDescendants()) do
            CheckObject(v)
        end
        print("RiiHUB: " .. category .. " ESP Enabled")
    else
        -- Jika OFF: Hapus folder kategori tersebut saja (Instant Clean)
        local folderName = "Rii_ESP_" .. category
        local folder = pgui:FindFirstChild(folderName)
        if folder then
            folder:Destroy()
        end
        print("RiiHUB: " .. category .. " ESP Disabled")
    end
end
