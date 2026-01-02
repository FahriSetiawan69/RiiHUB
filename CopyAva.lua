-- =====================================================
-- RII HUB - COPY AVATAR (REAL FIX VERSION)
-- =====================================================

return function(parent)
    local Players = game:GetService("Players")

    parent:ClearAllChildren()

    local BG = Color3.fromRGB(55,35,95)
    local BTN = Color3.fromRGB(130,90,255)
    local BTN_H = Color3.fromRGB(170,130,255)
    local TEXT = Color3.new(1,1,1)

    -- ROOT
    local root = Instance.new("Frame", parent)
    root.Size = UDim2.new(1,0,1,0)
    root.BackgroundColor3 = BG
    root.BorderSizePixel = 0
    Instance.new("UICorner", root)

    -- ================= PLAYER LIST =================
    local plist = Instance.new("ScrollingFrame", root)
    plist.Position = UDim2.new(0,10,0,10)
    plist.Size = UDim2.new(0.28,-10,1,-20)
    plist.ScrollBarThickness = 6
    plist.CanvasSize = UDim2.new()
    plist.AutomaticCanvasSize = Enum.AutomaticSize.Y
    plist.BackgroundTransparency = 1

    local plLayout = Instance.new("UIListLayout", plist)
    plLayout.Padding = UDim.new(0,6)

    -- ================= RIGHT PANEL =================
    local right = Instance.new("Frame", root)
    right.Position = UDim2.new(0.28,10,0,10)
    right.Size = UDim2.new(0.72,-20,1,-20)
    right.BackgroundTransparency = 1

    -- ================= VIEWPORT =================
    local viewport = Instance.new("ViewportFrame", right)
    viewport.Size = UDim2.new(0,260,0,300)
    viewport.Position = UDim2.new(0.5,-130,0,0)
    viewport.BackgroundTransparency = 1

    local cam = Instance.new("Camera")
    cam.Parent = viewport
    viewport.CurrentCamera = cam

    -- ================= ASSET LIST =================
    local assetList = Instance.new("ScrollingFrame", right)
    assetList.Position = UDim2.new(0,20,0,310)
    assetList.Size = UDim2.new(1,-40,1,-360)
    assetList.ScrollBarThickness = 6
    assetList.CanvasSize = UDim2.new()
    assetList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    assetList.BackgroundTransparency = 1

    local asLayout = Instance.new("UIListLayout", assetList)
    asLayout.Padding = UDim.new(0,8)

    -- ================= COPY BUTTON =================
    local copyBtn = Instance.new("TextButton", right)
    copyBtn.Size = UDim2.new(0.35,0,0,34)
    copyBtn.Position = UDim2.new(0,20,1,-38)
    copyBtn.Text = "COPY ALL"
    copyBtn.BackgroundColor3 = BTN
    copyBtn.TextColor3 = TEXT
    Instance.new("UICorner", copyBtn)

    copyBtn.MouseEnter:Connect(function()
        copyBtn.BackgroundColor3 = BTN_H
    end)
    copyBtn.MouseLeave:Connect(function()
        copyBtn.BackgroundColor3 = BTN
    end)

    local currentIds = {}

    local function copy(txt)
        if setclipboard then setclipboard(txt) end
    end

    copyBtn.MouseButton1Click:Connect(function()
        copy(table.concat(currentIds," "))
    end)

    -- ================= SHOW PLAYER =================
    local function showPlayer(plr)
        viewport:ClearAllChildren()
        assetList:ClearAllChildren()

        -- PENTING: BALIKIN LAYOUT
        asLayout.Parent = assetList

        table.clear(currentIds)

        -- Camera
        cam = Instance.new("Camera")
        cam.Parent = viewport
        viewport.CurrentCamera = cam

        -- === AVATAR MODEL ===
        local model = Players:GetCharacterAppearanceAsync(plr.UserId)
        model.Parent = viewport

        -- FIX MODEL
        local hrp = model:FindFirstChild("HumanoidRootPart")
            or model:FindFirstChildWhichIsA("BasePart")

        if hrp then
            model.PrimaryPart = hrp
            model:SetPrimaryPartCFrame(CFrame.new(0,0,0))
        end

        cam.CFrame = CFrame.new(0,2.2,7)

        -- === ASSETS ===
        local ok, info = pcall(function()
            return Players:GetCharacterAppearanceInfoAsync(plr.UserId)
        end)
        if not ok or not info or not info.assets then return end

        for _,a in ipairs(info.assets) do
            table.insert(currentIds, a.id)

            local row = Instance.new("Frame", assetList)
            row.Size = UDim2.new(1,0,0,28)
            row.BackgroundColor3 = Color3.fromRGB(80,55,140)
            Instance.new("UICorner", row)

            local t = Instance.new("TextLabel", row)
            t.Size = UDim2.new(1,-10,1,0)
            t.Position = UDim2.new(0,5,0,0)
            t.TextXAlignment = Enum.TextXAlignment.Left
            t.Text = a.name.." ["..a.id.."]"
            t.TextSize = 12
            t.TextColor3 = TEXT
            t.BackgroundTransparency = 1
        end
    end

    -- ================= PLAYER LIST =================
    local function build()
        plist:ClearAllChildren()
        plLayout.Parent = plist

        for _,p in ipairs(Players:GetPlayers()) do
            local b = Instance.new("TextButton", plist)
            b.Size = UDim2.new(1,0,0,36)
            b.Text = p.Name
            b.TextColor3 = TEXT
            b.BackgroundColor3 = Color3.fromRGB(90,60,150)
            Instance.new("UICorner", b)

            b.MouseButton1Click:Connect(function()
                showPlayer(p)
            end)
        end
    end

    build()
    Players.PlayerAdded:Connect(build)
    Players.PlayerRemoving:Connect(build)
end
