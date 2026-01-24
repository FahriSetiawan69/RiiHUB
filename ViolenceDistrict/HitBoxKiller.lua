-- HITBOX EXPANDER V3 (TEAM FILTERED: KILLER ONLY)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LP = Players.LocalPlayer

local hitboxEnabled = false
local hitboxSize = 15

-- 1. SETUP UI
local screenGui = Instance.new("ScreenGui", CoreGui)
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 200, 0, 130)
mainFrame.Position = UDim2.new(0.5, -100, 0, 80)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", mainFrame)

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "KILLER HITBOX (TEAM)"
title.TextColor3 = Color3.new(1, 0.2, 0.2) -- Teks merah
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold

local toggleBtn = Instance.new("TextButton", mainFrame)
toggleBtn.Size = UDim2.new(0.9, 0, 0, 35)
toggleBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
toggleBtn.Text = "STATUS: OFF"
toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", toggleBtn)

local scaleLabel = Instance.new("TextLabel", mainFrame)
scaleLabel.Size = UDim2.new(1, 0, 0, 20)
scaleLabel.Position = UDim2.new(0, 0, 0.6, 0)
scaleLabel.Text = "SCALE: " .. hitboxSize
scaleLabel.TextColor3 = Color3.new(1, 1, 1)
scaleLabel.BackgroundTransparency = 1

local minusBtn = Instance.new("TextButton", mainFrame)
minusBtn.Size = UDim2.new(0, 40, 0, 25)
minusBtn.Position = UDim2.new(0.15, 0, 0.75, 0)
minusBtn.Text = "-"
minusBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
minusBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", minusBtn)

local plusBtn = Instance.new("TextButton", mainFrame)
plusBtn.Size = UDim2.new(0, 40, 0, 25)
plusBtn.Position = UDim2.new(0.65, 0, 0.75, 0)
plusBtn.Text = "+"
plusBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
plusBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", plusBtn)

-- 2. LOGIKA VISUAL
local function getVisual(parent)
    local box = parent:FindFirstChild("KillerVisual")
    if not box then
        box = Instance.new("SelectionBox")
        box.Name = "KillerVisual"
        box.Parent = parent
        box.Adornee = parent
        box.LineThickness = 0.04
        box.SurfaceTransparency = 1
        box.Color3 = Color3.fromRGB(255, 0, 0)
    end
    return box
end

-- 3. LOOP UTAMA DENGAN FILTER TIM
RunService.RenderStepped:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local root = p.Character.HumanoidRootPart
            local visual = getVisual(root)
            
            -- FILTER: Hanya eksekusi jika pemain berada di tim "Killer"
            -- Nama tim harus sesuai persis dengan yang ada di Dex (Case Sensitive)
            local isKiller = (p.Team and p.Team.Name == "Killer")
            
            if hitboxEnabled and isKiller then
                root.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                root.Transparency = 1
                root.CanCollide = false
                visual.Visible = true
            else
                -- Kembalikan ke normal jika bukan killer atau fitur OFF
                root.Size = Vector3.new(2, 2, 1)
                root.Transparency = 1
                root.CanCollide = true
                visual.Visible = false
            end
        end
    end
end)

-- 4. INTERAKSI UI
toggleBtn.MouseButton1Click:Connect(function()
    hitboxEnabled = not hitboxEnabled
    toggleBtn.Text = hitboxEnabled and "STATUS: ON" or "STATUS: OFF"
    toggleBtn.BackgroundColor3 = hitboxEnabled and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(150, 0, 0)
end)

plusBtn.MouseButton1Click:Connect(function()
    hitboxSize = math.clamp(hitboxSize + 5, 5, 50)
    scaleLabel.Text = "SCALE: " .. hitboxSize
end)

minusBtn.MouseButton1Click:Connect(function()
    hitboxSize = math.clamp(hitboxSize - 5, 5, 50)
    scaleLabel.Text = "SCALE: " .. hitboxSize
end)
