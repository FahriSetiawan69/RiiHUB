-- AUTO REPAIR V7.6: DYNAMIC MULTI-POINT DETECTION
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Root = Character:WaitForChild("HumanoidRootPart")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local RepairRemote = ReplicatedStorage.Remotes.Generator.RepairEvent
local isExploitActive = false

-- 1. UI TOGGLE
local screenGui = Instance.new("ScreenGui", CoreGui)
local toggleBtn = Instance.new("TextButton", screenGui)
toggleBtn.Size = UDim2.new(0, 180, 0, 45)
toggleBtn.Position = UDim2.new(0.5, -90, 0, 20)
toggleBtn.Text = "MULTI-POINT: OFF"
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Font = Enum.Font.SourceSansBold

toggleBtn.MouseButton1Click:Connect(function()
    isExploitActive = not isExploitActive
    toggleBtn.Text = isExploitActive and "MULTI-POINT: ON" or "MULTI-POINT: OFF"
    toggleBtn.BackgroundColor3 = isExploitActive and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(200, 0, 0)
end)

-- 2. FUNGSI SMART SCANNER (Mencari GeneratorPoint1, 2, 3, dst)
local function getBestInteractionPoint()
    local closestPoint = nil
    local maxDistance = 12 -- Jarak jangkauan deteksi
    
    -- Mencari semua objek di Workspace
    for _, obj in pairs(workspace:GetDescendants()) do
        -- Cek apakah nama objek mengandung kata "GeneratorPoint"
        if obj:IsA("BasePart") and string.find(obj.Name, "GeneratorPoint") then
            local dist = (Root.Position - obj.Position).Magnitude
            if dist < maxDistance then
                maxDistance = dist
                closestPoint = obj
            end
        end
    end
    return closestPoint
end

-- 3. METATABLE HOOK (Logic Bypass V6 Asli)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if isExploitActive and method == "FireServer" and self == RepairRemote then
        -- Jika analog gerak, jangan bypass (biarkan sinyal batal lewat)
        if Humanoid.MoveDirection.Magnitude > 0 then
            return oldNamecall(self, unpack(args))
        end

        -- Bypass: Ubah False jadi True
        if args[2] == false then
            args[2] = true
            return oldNamecall(self, unpack(args))
        end
    end
    return oldNamecall(self, ...)
end)

-- 4. SPAM LOOP WITH AUTO-ATTACH
task.spawn(function()
    while true do
        task.wait(0.4)
        
        if isExploitActive then
            local target = getBestInteractionPoint() -- Cari titik point terdekat secara dinamis
            
            if Humanoid.MoveDirection.Magnitude == 0 then
                if target then
                    -- Kirim sinyal True untuk nempel otomatis ke point yang ditemukan
                    RepairRemote:FireServer(target, true)
                end
            elseif Humanoid.MoveDirection.Magnitude > 0 then
                -- Kirim sinyal False untuk cancel jika gerak
                if target then
                    RepairRemote:FireServer(target, false)
                end
                task.wait(0.3)
            end
        end
    end
end)

warn("V7.6 ACTIVE: Mendukung GeneratorPoint1, 2, 3, dst.")
