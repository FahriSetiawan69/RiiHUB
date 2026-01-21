-- ESPMODULE.LUA (Logic Source: Infinite Yield / IY)
return function(state)
    _G.ESP_Active = state
    local Players = game:GetService("Players")
    local CoreGui = game:GetService("CoreGui")

    -- Menghapus ESP lama agar tidak menumpuk
    local function CleanUp()
        for _, v in pairs(CoreGui:GetChildren()) do
            if v.Name == "RiiHUB_ESP_IY" then
                v:Destroy()
            end
        end
    end

    if not state then
        CleanUp()
        return 
    end

    -- FUNGSI INTI: Logic Visual ESP IY
    local function CreateESP(parent, colorVar, nameText)
        if not parent then return end
        
        -- Container Billboard (Logic Teks & Box IY)
        local bbg = Instance.new("BillboardGui")
        bbg.Name = "RiiHUB_ESP_IY"
        bbg.Adornee = parent
        bbg.Size = UDim2.new(4, 0, 5, 0)
        bbg.AlwaysOnTop = true
        bbg.Parent = CoreGui

        -- Frame Box (Garis Kotak)
        local frame = Instance.new("Frame", bbg)
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.BorderSizePixel = 2 -- Ketebalan garis
        
        -- Nama Tag
        local label = Instance.new("TextLabel", bbg)
        label.BackgroundTransparency = 1
        label.Position = UDim2.new(0, 0, 0, -25)
        label.Size = UDim2.new(1, 0, 0, 20)
        label.Text = nameText
        label.Font = Enum.Font.GothamBold
        label.TextSize = 13
        label.TextStrokeTransparency = 0 -- Agar teks ada garis hitam (mudah dibaca)

        -- REAL-TIME COLOR UPDATE (Logic Modifikasi RiiHUB)
        -- Ini yang membuat warna bisa berubah dari UI tanpa restart ESP
        task.spawn(function()
            while _G.ESP_Active and bbg.Parent do
                local chosenColor = _G[colorVar] or Color3.new(1, 1, 1)
                frame.BorderColor3 = chosenColor
                label.TextColor3 = chosenColor
                task.wait(0.5) -- Update warna setiap 0.5 detik
            end
        end)
    end

    -- LOOP MONITORING (Agar pemain baru otomatis kena ESP)
    task.spawn(function()
        while _G.ESP_Active do
            -- 1. Scan Players
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local root = player.Character.HumanoidRootPart
                    if not CoreGui:FindFirstChild("RiiHUB_ESP_IY") or not bbg_exists_for_this_player then -- Logic IY Check
                         -- Tentukan kategori warna
                         local cat = "SurvivorColor"
                         if player.TeamColor == BrickColor.new("Bright red") or player.Name:lower():find("killer") then
                             cat = "KillerColor"
                         end
                         
                         -- Cek apakah sudah ada ESP di part tersebut
                         local existing = false
                         for _, v in pairs(CoreGui:GetChildren()) do
                             if v.Name == "RiiHUB_ESP_IY" and v.Adornee == root then existing = true break end
                         end
                         
                         if not existing then
                             CreateESP(root, cat, player.Name)
                         end
                    end
                end
            end

            -- 2. Scan Generators (Object ESP)
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj.Name:lower():find("generator") and (obj:IsA("BasePart") or obj:IsA("MeshPart")) then
                    local existing = false
                    for _, v in pairs(CoreGui:GetChildren()) do
                        if v.Name == "RiiHUB_ESP_IY" and v.Adornee == obj then existing = true break end
                    end
                    
                    if not existing then
                        CreateESP(obj, "GenColor", "Generator")
                    end
                end
            end
            
            task.wait(2) -- Jeda scan pemain baru (Optimasi Mobile)
        end
        CleanUp()
    end)
end
