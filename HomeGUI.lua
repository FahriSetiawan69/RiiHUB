-- =====================================================
-- RII HUB - HOME GUI
-- =====================================================

local Players = game:GetService("Players")
local lp = Players.LocalPlayer

-- ================= SETTINGS =================
local THEME_BG = Color3.fromRGB(35,20,70)
local SIDEBAR_BG = Color3.fromRGB(50,30,90)
local PANEL_BG = Color3.fromRGB(60,40,100)
local BTN_HOVER = Color3.fromRGB(80,50,150)
local TEXT_COLOR = Color3.fromRGB(255,255,255)

-- ================= MAIN GUI =================
local gui = Instance.new("ScreenGui", lp.PlayerGui)
gui.Name = "RiiHubGUI"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,620,0,500)
frame.Position = UDim2.new(0.5,-310,0.5,-250)
frame.BackgroundColor3 = THEME_BG
frame.BackgroundTransparency = 0.1
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame)

local originalSize = frame.Size

-- ================= TITLE BAR =================
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,-80,0,40)
title.Position = UDim2.new(0,10,0,0)
title.Text = "Rii HUB"
title.TextColor3 = TEXT_COLOR
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.TextScaled = true

-- ================= CLOSE BUTTON =================
local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0,40,0,40)
close.Position = UDim2.new(1,-40,0,0)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(180,50,90)
close.TextColor3 = TEXT_COLOR
Instance.new("UICorner", close)
close.MouseEnter:Connect(function() close.BackgroundColor3 = Color3.fromRGB(255,50,120) end)
close.MouseLeave:Connect(function() close.BackgroundColor3 = Color3.fromRGB(180,50,90) end)
close.MouseButton1Click:Connect(function() gui:Destroy() end)

-- ================= MINIMIZE BULAT =================
local minimize = Instance.new("TextButton", frame)
minimize.Size = UDim2.new(0,28,0,28)
minimize.Position = UDim2.new(1,-70,0,6)
minimize.Text = "–"
minimize.BackgroundColor3 = Color3.fromRGB(100,70,180)
minimize.TextColor3 = TEXT_COLOR
minimize.TextScaled = true
local minCorner = Instance.new("UICorner", minimize)
minCorner.CornerRadius = UDim.new(0.5,0)
local isMinimized = false

-- ================= CONTENT =================
local content = Instance.new("Frame", frame)
content.Position = UDim2.new(0,0,0,40)
content.Size = UDim2.new(1,0,1,-40)
content.BackgroundTransparency = 1

minimize.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	if isMinimized then
		content.Visible = false
		frame.Size = UDim2.new(0,200,0,40)
	else
		content.Visible = true
		frame.Size = originalSize
	end
end)

-- ================= SIDEBAR =================
local sidebar = Instance.new("Frame", content)
sidebar.Position = UDim2.new(0,0,0,0)
sidebar.Size = UDim2.new(0,160,1,0)
sidebar.BackgroundColor3 = SIDEBAR_BG
sidebar.BackgroundTransparency = 0.1
Instance.new("UICorner", sidebar)

local sbLayout = Instance.new("UIListLayout", sidebar)
sbLayout.Padding = UDim.new(0,8)
sbLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
sbLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- ================= CONTENT PANEL =================
local panelContainer = Instance.new("Frame", content)
panelContainer.Position = UDim2.new(0,160,0,0)
panelContainer.Size = UDim2.new(1,-160,1,0)
panelContainer.BackgroundTransparency = 1

-- ================= TAB MANAGEMENT =================
-- Placeholder function untuk load fitur
local function loadFeature(tabName, featureFunc)
	-- Hide semua children di panelContainer
	for _,c in ipairs(panelContainer:GetChildren()) do
		c.Visible = false
	end
	-- Jalankan fitur, beri parent panelContainer
	featureFunc(panelContainer)
end

-- ================= SIDEBAR EXAMPLE BUTTON =================
local function createSidebarButton(name, featureFunc)
	local btn = Instance.new("TextButton", sidebar)
	btn.Size = UDim2.new(1,-20,0,40)
	btn.Text = name
	btn.TextColor3 = TEXT_COLOR
	btn.BackgroundColor3 = Color3.fromRGB(90,60,140)
	Instance.new("UICorner", btn)
	btn.MouseEnter:Connect(function() btn.BackgroundColor3 = BTN_HOVER end)
	btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(90,60,140) end)
	btn.MouseButton1Click:Connect(function()
		loadFeature(name, featureFunc)
	end)
end

-- ================= EXAMPLE =================
-- nanti fitur Copy Ava akan di-load dari modul/script terpisah
-- createSidebarButton("Copy Ava", function(parent) end)

-- ================= RETURN PANEL CONTAINER =================
-- jika kamu ingin modul fitur bisa mengakses panelContainer
return panelContainer