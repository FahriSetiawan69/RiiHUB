--// SERVICES
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--// GUI ROOT
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CopyAvaGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

--// MAIN FRAME
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 520, 0, 360)
Main.Position = UDim2.new(0.5, -260, 0.5, -180)
Main.BackgroundColor3 = Color3.fromRGB(45, 25, 80)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

--// PLAYER LIST
local List = Instance.new("ScrollingFrame")
List.Size = UDim2.new(0, 170, 1, -10)
List.Position = UDim2.new(0, 5, 0, 5)
List.CanvasSize = UDim2.new(0, 0, 0, 0)
List.AutomaticCanvasSize = Enum.AutomaticSize.Y
List.ScrollBarImageTransparency = 0.3
List.Parent = Main

local ListLayout = Instance.new("UIListLayout", List)
ListLayout.Padding = UDim.new(0, 6)

--// DETAIL PANEL
local Detail = Instance.new("Frame")
Detail.Size = UDim2.new(1, -185, 1, -10)
Detail.Position = UDim2.new(0, 180, 0, 5)
Detail.BackgroundTransparency = 1
Detail.Parent = Main

local DetailLayout = Instance.new("UIListLayout", Detail)
DetailLayout.Padding = UDim.new(0, 8)

--// VIEWPORT
local Viewport = Instance.new("ViewportFrame")
Viewport.Size = UDim2.new(1, 0, 0, 180)
Viewport.BackgroundTransparency = 1
Viewport.Parent = Detail

local Camera = Instance.new("Camera")
Camera.Parent = Viewport
Viewport.CurrentCamera = Camera

--// ASSET TEXT
local AssetText = Instance.new("TextLabel")
AssetText.Size = UDim2.new(1, -10, 0, 80)
AssetText.TextWrapped = true
AssetText.TextYAlignment = Top
AssetText.TextXAlignment = Left
AssetText.TextSize = 13
AssetText.BackgroundTransparency = 1
AssetText.TextColor3 = Color3.new(1,1,1)
AssetText.Text = "Select a player"
AssetText.Parent = Detail

--// COPY BUTTON
local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.new(0, 140, 0, 34)
CopyBtn.Text = "COPY"
CopyBtn.TextSize = 14
CopyBtn.BackgroundColor3 = Color3.fromRGB(110, 80, 200)
CopyBtn.TextColor3 = Color3.new(1,1,1)
CopyBtn.Parent = Detail
Instance.new("UICorner", CopyBtn).CornerRadius = UDim.new(0, 6)

--// CLEAR VIEWPORT
local function clearViewport()
    for _, v in ipairs(Viewport:GetChildren()) do
        if not v:IsA("Camera") then
            v:Destroy()
        end
    end
end

--// LOAD PLAYER DATA
local function loadPlayer(player)
    clearViewport()
    AssetText.Text = "Loading..."

    task.spawn(function()
        local desc = Players:GetHumanoidDescriptionFromUserId(player.UserId)
        local rig = Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R15)

        rig.Parent = Viewport
        rig:SetPrimaryPartCFrame(CFrame.new(0, 0, 0))

        local hrp = rig:FindFirstChild("HumanoidRootPart")
        if hrp then
            Camera.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 2.5, 6), hrp.Position)
        end

        -- Collect assets
        local assets = {}
        for _, acc in pairs(desc:GetAccessories(true)) do
            table.insert(assets, tostring(acc.AssetId))
        end

        AssetText.Text = table.concat(assets, ", ")

        CopyBtn.MouseButton1Click:Connect(function()
            if setclipboard then
                setclipboard(AssetText.Text)
            end
        end)
    end)
end

--// PLAYER BUTTON
local function createPlayerButton(player)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -6, 0, 34)
    btn.Text = player.Name
    btn.TextSize = 14
    btn.TextWrapped = true
    btn.BackgroundColor3 = Color3.fromRGB(80, 55, 140)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Parent = List
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        loadPlayer(player)
    end)
end

--// INIT PLAYERS
for _, plr in ipairs(Players:GetPlayers()) do
    createPlayerButton(plr)
end

Players.PlayerAdded:Connect(createPlayerButton)
