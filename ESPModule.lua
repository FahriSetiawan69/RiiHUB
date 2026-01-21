-- ESPMODULE.LUA (Full IY Logic with RiiHUB Custom Colors)
return function(state)
    _G.ESP_Active = state
    local Players = game:GetService("Players")
    local CoreGui = game:GetService("CoreGui")

    -- Membersihkan ESP agar tidak duplikat (Logic Cleanup IY)
    local function CleanUp()
        for _, v in pairs(CoreGui:GetChildren()) do
            if v.Name:find("_RiiESP") then
                v:Destroy()
            end
        end
    end

    if not state then
        CleanUp()
        return 
    end

    -- JANTUNG LOGIKA ESP IY (function ESP(p) asli IY)
    local function CreateESP(p, colorVar, customName)
        task.spawn(function()
            -- Tunggu karakter muncul (Metode IY)
            local char = p.Character or p.CharacterAdded:Wait()
            local root = char:WaitForChild("HumanoidRootPart", 5)
            
            if root then
                -- Membuat BillboardGui (Mesin utama ESP IY)
                local bbg = Instance.new("BillboardGui")
                bbg.Name = p.Name .. "_RiiESP"
                bbg.Adornee = root
                bbg.AlwaysOnTop = true
                bbg.Size = UDim2.new(4, 0, 5.2, 0)
                bbg.ExtentsOffset = Vector3.new(0, 0, 0)
                bbg.Parent = CoreGui

                -- Box / Garis Kotak (Internal IY Logic)
                local frame = Instance.new("Frame", bbg)
                frame.Size = UDim2.new(1, 0, 1, 0)
                frame.BackgroundTransparency = 1
                frame.BorderSizePixel = 1 -- IY Style (Tipis)
                
                -- Label Nama (Internal IY Logic)
                local label = Instance.new("TextLabel", bbg)
                label.BackgroundTransparency = 1
                label.Text = customName or p.Name
                label.Size = UDim2.new(1, 0, 0, 20)
                label.Position = UDim2.new(0, 0, 0, -25)
                label.Font = Enum.Font.SourceSansBold
                label.TextSize = 14
                label.TextStrokeTransparency = 0 -- Outline hitam agar jelas

                -- MODIFIKASI RiiHUB: Sinkronisasi Warna Real-time
                task.spawn(function()
                    while _G.ESP_Active and bbg.Parent do
                        -- Ambil warna dari Global Variable UI
                        local targetColor = _G[colorVar] or Color3.new(1, 1, 1)
                        frame.BorderColor3 = targetColor
                        label.TextColor3 = targetColor
                        task.wait(0.5) -- Update warna tanpa lag
                    end
                end)
            end
        end)
    end

    -- Loop untuk memberikan ESP ke semua pemain (IY Command Style)
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            local role = "SurvivorColor"
            if player.TeamColor == BrickColor.new("Bright red") or player.Name:lower():find("killer") then
                role = "KillerColor"
            end
            CreateESP(player, role)
        end
    end

    -- Merekam Pemain yang Baru Masuk/Respawn (IY Logic)
    local connection = Players.PlayerAdded:Connect(function(p)
        p.CharacterAdded:Connect(function()
            if _G.ESP_Active then
                task.wait(1) -- Delay sebentar agar karakter stabil
                local role = "SurvivorColor"
                if p.TeamColor == BrickColor.new("Bright red") or p.Name:lower():find("killer") then
                    role = "KillerColor"
                end
                CreateESP(p, role)
            end
        end)
    end)

    -- Logic Tambahan: Scan Generator
    task.spawn(function()
        while _G.ESP_Active do
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj.Name:lower():find("generator") and (obj:IsA("BasePart") or obj:IsA("MeshPart")) then
                    if not CoreGui:FindFirstChild(obj.Name .. "_RiiESP") then
                        -- Gunakan fungsi yang sama tapi untuk objek
                        CreateESP(obj, "GenColor", "Generator")
                    end
                end
            end
            task.wait(3)
        end
        connection:Disconnect() -- Matikan koneksi saat ESP OFF
    end)
end
