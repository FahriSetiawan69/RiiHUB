-- =========================================
-- SPECTATOR FEATURE - MOBILE FRIENDLY
-- =========================================

return function(parent)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local lp = Players.LocalPlayer

    parent:ClearAllChildren()

    -- ================= ROOT UI =================
    local root = Instance.new("Frame", parent)
    root.Size = UDim2.new(1,0,1,0)
    root.BackgroundTransparency = 1

    -- ================= HUD =================
    local hud = Instance.new("Frame", root)
    hud.Size = UDim2.new(0,200,0,60)
    hud.Position = UDim2.new(0,10,1,-70)
    hud.BackgroundTransparency = 0.3
    hud.BackgroundColor3 = Color3.fromRGB(40,40,40)
    hud.Visible = false
    Instance.new("UICorner", hud)

    local nameLabel = Instance.new("TextLabel", hud)
    nameLabel.Size = UDim2.new(1,0,0.5,0)
    nameLabel.Position = UDim2.new(0,0,0,0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.new(1,1,1)
    nameLabel.TextScaled = true
    nameLabel.Text = "Spectator:"

    local infoLabel = Instance.new("TextLabel", hud)
    infoLabel.Size = UDim2.new(1,0,0.5,0)
    infoLabel.Position = UDim2.new(0,0,0.5,0)
    infoLabel.BackgroundTransparency = 1
    infoLabel.TextColor3 = Color3.new(1,1,1)
    infoLabel.TextScaled = true
    infoLabel.Text = "Use arrows to switch player"

    -- ================= VARIABLES =================
    local spectatorEnabled = false
    local targetIndex = 1
    local targetPlayer = nil

    local cam = workspace.CurrentCamera
    local camOffset = Vector3.new(0,3,8)
    local dragStart = nil
    local camRot = Vector2.new(0,0)

    -- ================= FUNCTIONS =================
    local function updateTarget()
        local list = {}
        for _,p in ipairs(Players:GetPlayers()) do
            if p ~= lp then
                table.insert(list,p)
            end
        end
        if #list == 0 then
            targetPlayer = nil
            nameLabel.Text = "No players"
            return
        end
        if targetIndex > #list then targetIndex = 1 end
        if targetIndex < 1 then targetIndex = #list end
        targetPlayer = list[targetIndex]
        nameLabel.Text = "Spectator: "..targetPlayer.Name
    end

    local function onInputBegan(input, gpe)
        if not spectatorEnabled then return end
        if input.UserInputType == Enum.UserInputType.Touch then
            dragStart = input.Position
        end
    end

    local function onInputChanged(input, gpe)
        if not spectatorEnabled then return end
        if dragStart and input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            camRot = camRot + Vector2.new(-delta.Y*0.2,-delta.X*0.2)
            dragStart = input.Position
        end
    end

    local function onInputEnded(input, gpe)
        if not spectatorEnabled then return end
        if input.UserInputType == Enum.UserInputType.Touch then
            dragStart = nil
        end
    end

    local function updateCamera()
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = targetPlayer.Character.HumanoidRootPart
            local cf = CFrame.new(hrp.Position + Vector3.new(0,camOffset.Y,camOffset.Z))
                * CFrame.Angles(math.rad(camRot.X),math.rad(camRot.Y),0)
            cam.CFrame = cf
        end
    end

    -- ================= TOGGLE HANDLER =================
    local function toggleSpectator(on)
        spectatorEnabled = on
        hud.Visible = on
        if on then
            updateTarget()
        else
            cam.CameraType = Enum.CameraType.Custom
        end
    end

    -- ================= PLAYER SWITCH =================
    local function nextPlayer()
        targetIndex += 1
        updateTarget()
    end

    local function prevPlayer()
        targetIndex -= 1
        updateTarget()
    end

    -- ================= RUN LOOP =================
    RunService.RenderStepped:Connect(function()
        if spectatorEnabled then
            updateCamera()
        end
    end)

    -- ================= INPUT =================
    UserInputService.InputBegan:Connect(onInputBegan)
    UserInputService.InputChanged:Connect(onInputChanged)
    UserInputService.InputEnded:Connect(onInputEnded)

    -- ================= MODULE RETURN =================
    return {
        Toggle = toggleSpectator,
        NextPlayer = nextPlayer,
        PrevPlayer = prevPlayer,
    }
end
