-- ESPMODULE.LUA (RiiHUB Optimized - Real-time Color)
return function(state)
    _G.ESP_Active = state
    
    -- Fungsi untuk membersihkan semua ESP saat dimatikan
    local function CleanUp()
        for _, v in pairs(game:GetService("Players"):GetPlayers()) do
            if v.Character and v.Character:FindFirstChild("RiiHUB_ESP") then
                v.Character.RiiHUB_ESP:Destroy()
            end
        end
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Highlight") and obj.Name == "RiiHUB_ESP" then
                obj:Destroy()
            end
        end
    end

    if not state then
        CleanUp()
        return 
    end

    -- Loop Utama ESP
    task.spawn(function()
        while _G.ESP_Active do
            -- 1. ESP PEMAIN (Killer & Survivor)
            for _, player in pairs(game:GetService("Players"):GetPlayers()) do
                if player ~= game.Players.LocalPlayer and player.Character then
                    local char = player.Character
                    local highlight = char:FindFirstChild("RiiHUB_ESP")
                    
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "RiiHUB_ESP"
                        highlight.FillTransparency = 0.6
                        highlight.Parent = char
                    end

                    -- Logika Penentuan Warna (Real-time dari Global Variable UI)
                    -- Ganti pengecekan tim sesuai dengan sistem game yang kamu mainkan
                    if player.TeamColor == BrickColor.new("Bright red") or player.Name:lower():find("killer") then
                        highlight.OutlineColor = _G.KillerColor or Color3.fromRGB(255, 0, 0)
                        highlight.FillColor = _G.KillerColor or Color3.fromRGB(255, 0, 0)
                    else
                        highlight.OutlineColor = _G.SurvivorColor or Color3.fromRGB(0, 255, 0)
                        highlight.FillColor = _G.SurvivorColor or Color3.fromRGB(0, 255, 0)
                    end
                end
            end

            -- 2. ESP OBJECT (Generator)
            -- Ganti "Generator" dengan nama objek generator yang ada di workspace game
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj.Name == "Generator" or obj:FindFirstChild("Generator") then
                    local highlight = obj:FindFirstChild("RiiHUB_ESP")
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "RiiHUB_ESP"
                        highlight.FillTransparency = 0.6
                        highlight.Parent = obj
                    end
                    highlight.OutlineColor = _G.GenColor or Color3.fromRGB(255, 255, 0)
                    highlight.FillColor = _G.GenColor or Color3.fromRGB(255, 255, 0)
                end
            end
            
            task.wait(1.5) -- Jeda update untuk stabilitas performa
        end
        CleanUp() -- Bersihkan jika loop berhenti
    end)
end
