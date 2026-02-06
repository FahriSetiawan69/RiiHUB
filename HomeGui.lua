-- RiiHUB HomeGui - Dynamic Feature Rendering
local HomeGui = {}
local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local pgui = lp:WaitForChild("PlayerGui")

function HomeGui:Init(TargetFolder)
    -- Cleanup UI Lama agar tidak bertumpuk
    if pgui:FindFirstChild("RiiHUB_Main") then pgui.RiiHUB_Main:Destroy() end

    -- Base UI Setup
    local sg = Instance.new("ScreenGui", pgui)
    sg.Name = "RiiHUB_Main"
    sg.ResetOnSpawn = false

    local MainFrame = Instance.new("Frame", sg)
    MainFrame.Size = UDim2.new(0, 380, 0, 300)
    MainFrame.Position = UDim2.new(0.5, -190, 0.5, -150)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35) -- Tema Gelap
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    local corner = Instance.new("UICorner", MainFrame)
    corner.CornerRadius = UDim.new(0, 12)

    -- Header Title
    local Header = Instance.new("TextLabel", MainFrame)
    Header.Size = UDim2.new(1, 0, 0, 45)
    Header.Text = "RiiHUB | " .. (TargetFolder and TargetFolder.Name or "Unknown")
    Header.TextColor3 = Color3.new(1, 1, 1)
    Header.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    Header.Font = Enum.Font.GothamBold
    Header.TextSize = 16
    Instance.new("UICorner", Header)

    -- Container Scrolling (Tempat Fitur)
    local Container = Instance.new("ScrollingFrame", MainFrame)
    Container.Size = UDim2.new(1, -20, 1, -65)
    Container.Position = UDim2.new(0, 10, 0, 55)
    Container.BackgroundTransparency = 1
    Container.ScrollBarThickness = 2
    Container.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local Layout = Instance.new("UIListLayout", Container)
    Layout.Padding = UDim.new(0, 6)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder

    -- Auto Adjust Scrolling
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Container.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
    end)

    -- RENDER BUTTONS FROM FOLDER
    if TargetFolder then
        local modules = TargetFolder:GetChildren()
        if #modules == 0 then
            local info = Instance.new("TextLabel", Container)
            info.Size = UDim2.new(1, 0, 0, 50)
            info.Text = "Tidak ada fitur di folder ini."
            info.TextColor3 = Color3.fromRGB(150, 150, 150)
            info.BackgroundTransparency = 1
        else
            for _, module in pairs(modules) do
                if module:IsA("ModuleScript") then
                    local btn = Instance.new("TextButton", Container)
                    btn.Name = module.Name
                    btn.Size = UDim2.new(1, -10, 0, 40)
                    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
                    btn.Text = "  " .. module.Name -- Beri sedikit spasi
                    btn.TextColor3 = Color3.new(1, 1, 1)
                    btn.Font = Enum.Font.GothamMedium
                    btn.TextXAlignment = Enum.TextXAlignment.Left
                    btn.TextSize = 14
                    
                    Instance.new("UICorner", btn)

                    btn.MouseButton1Click:Connect(function()
                        local success, err = pcall(function()
                            require(module) -- Menjalankan script fitur
                        end)
                        if not success then warn("[RiiHUB Error]: " .. err) end
                    end)
                end
            end
        end
    end
end

return HomeGui
