-- RiiHUB HomeGui.lua
-- UI ONLY | Dynamic Sidebar | Switch Toggle
-- Controlled by <Game>/main.lua

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

-- ======================================================
-- GUARD
-- ======================================================
if PlayerGui:FindFirstChild("RiiHUB_GUI") then
	PlayerGui.RiiHUB_GUI:Destroy()
end

-- ======================================================
-- SCREEN GUI
-- ======================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RiiHUB_GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

-- ======================================================
-- MAIN WINDOW
-- ======================================================
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.fromOffset(520, 340)
Main.Position = UDim2.fromScale(0.5, 0.5)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = Color3.fromRGB(22, 12, 38)
Main.BackgroundTransparency = 0.05
Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 16)

local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(160, 120, 255)
Stroke.Thickness = 2
Stroke.Transparency = 0.2

-- ======================================================
-- HEADER
-- ======================================================
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 46)
Header.BackgroundColor3 = Color3.fromRGB(30, 16, 52)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -120, 1, 0)
Title.Position = UDim2.new(0, 16, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "RiiHUB"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Left
Title.TextColor3 = Color3.fromRGB(210, 180, 255)

-- Buttons
local function HeaderBtn(txt, x)
	local b = Instance.new("TextButton", Header)
	b.Size = UDim2.fromOffset(36, 26)
	b.Position = UDim2.new(1, x, 0.5, 0)
	b.AnchorPoint = Vector2.new(1, 0.5)
	b.Text = txt
	b.Font = Enum.Font.GothamBold
	b.TextSize = 14
	b.TextColor3 = Color3.fromRGB(230, 210, 255)
	b.BackgroundColor3 = Color3.fromRGB(70, 36, 120)
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
	return b
end

local MinBtn = HeaderBtn("–", -56)
local CloseBtn = HeaderBtn("✕", -12)

-- ======================================================
-- SIDEBAR (EMPTY BY DEFAULT)
-- ======================================================
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 150, 1, -46)
Sidebar.Position = UDim2.new(0, 0, 0, 46)
Sidebar.BackgroundColor3 = Color3.fromRGB(26, 14, 44)

local SidebarList = Instance.new("UIListLayout", Sidebar)
SidebarList.Padding = UDim.new(0, 8)
SidebarList.HorizontalAlignment = Center
SidebarList.VerticalAlignment = Top

-- ======================================================
-- CONTENT
-- ======================================================
local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, -150, 1, -46)
Content.Position = UDim2.new(0, 150, 0, 46)
Content.BackgroundColor3 = Color3.fromRGB(18, 10, 32)

local Scroll = Instance.new("ScrollingFrame", Content)
Scroll.Size = UDim2.new(1, -16, 1, -16)
Scroll.Position = UDim2.new(0, 8, 0, 8)
Scroll.CanvasSize = UDim2.fromOffset(0, 0)
Scroll.ScrollBarImageTransparency = 0.6
Scroll.BackgroundTransparency = 1

local ContentList = Instance.new("UIListLayout", Scroll)
ContentList.Padding = UDim.new(0, 10)

-- ======================================================
-- INTERNAL STATE
-- ======================================================
local Tabs = {}
local CurrentTab = nil

local function ClearContent()
	for _, v in ipairs(Scroll:GetChildren()) do
		if not v:IsA("UIListLayout") then
			v:Destroy()
		end
	end
end

-- ======================================================
-- UI API (EXPOSED)
-- ======================================================
local UI = {}

-- ADD TAB
function UI:AddTab(name)
	if Tabs[name] then return end

	local btn = Instance.new("TextButton", Sidebar)
	btn.Size = UDim2.new(1, -16, 0, 40)
	btn.Text = name
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.TextColor3 = Color3.fromRGB(200, 180, 255)
	btn.BackgroundColor3 = Color3.fromRGB(42, 22, 72)
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

	local tab = {
		Button = btn,
		Items = {}
	}
	Tabs[name] = tab

	btn.MouseButton1Click:Connect(function()
		if CurrentTab then
			CurrentTab.Button.BackgroundColor3 = Color3.fromRGB(42, 22, 72)
		end
		CurrentTab = tab
		btn.BackgroundColor3 = Color3.fromRGB(90, 46, 160)
		ClearContent()

		for _, item in ipairs(tab.Items) do
			item.Parent = Scroll
		end
	end)

	if not CurrentTab then
		btn:Activate()
	end
end

-- ADD SWITCH TOGGLE
function UI:AddToggle(tabName, labelText)
	local tab = Tabs[tabName]
	if not tab then return end

	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, -8, 0, 44)
	holder.BackgroundColor3 = Color3.fromRGB(34, 18, 58)
	Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 10)

	local label = Instance.new("TextLabel", holder)
	label.Size = UDim2.new(1, -80, 1, 0)
	label.Position = UDim2.new(0, 12, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = labelText
	label.Font = Enum.Font.Gotham
	label.TextSize = 14
	label.TextXAlignment = Left
	label.TextColor3 = Color3.fromRGB(220, 200, 255)

	-- Switch
	local switch = Instance.new("Frame", holder)
	switch.Size = UDim2.fromOffset(46, 22)
	switch.Position = UDim2.new(1, -58, 0.5, 0)
	switch.AnchorPoint = Vector2.new(0, 0.5)
	switch.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
	Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)

	local knob = Instance.new("Frame", switch)
	knob.Size = UDim2.fromOffset(18, 18)
	knob.Position = UDim2.fromOffset(2, 2)
	knob.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

	local state = false
	local callback = nil

	local function set(on)
		state = on
		TweenService:Create(
			switch,
			TweenInfo.new(0.2),
			{ BackgroundColor3 = on and Color3.fromRGB(140, 90, 255) or Color3.fromRGB(90, 90, 90) }
		):Play()

		TweenService:Create(
			knob,
			TweenInfo.new(0.2),
			{ Position = on and UDim2.fromOffset(26, 2) or UDim2.fromOffset(2, 2) }
		):Play()

		if callback then
			callback(on)
		end
	end

	switch.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			set(not state)
		end
	end)

	tab.Items[#tab.Items + 1] = holder

	return {
		Set = set,
		Bind = function(_, cb)
			callback = cb
		end
	}
end

-- ======================================================
-- MINIMIZE / CLOSE
-- ======================================================
local Floating = Instance.new("TextButton", ScreenGui)
Floating.Size = UDim2.fromOffset(50, 50)
Floating.Position = UDim2.fromScale(0.5, 0.5)
Floating.Text = "R"
Floating.Font = Enum.Font.GothamBlack
Floating.TextSize = 20
Floating.TextColor3 = Color3.fromRGB(230, 200, 255)
Floating.BackgroundColor3 = Color3.fromRGB(90, 46, 160)
Floating.Visible = false
Instance.new("UICorner", Floating).CornerRadius = UDim.new(1, 0)

MinBtn.MouseButton1Click:Connect(function()
	Main.Visible = false
	Floating.Visible = true
end)

Floating.MouseButton1Click:Connect(function()
	Main.Visible = true
	Floating.Visible = false
end)

CloseBtn.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
end)

-- ======================================================
-- DRAG FLOATING
-- ======================================================
do
	local drag, startPos, startInput
	Floating.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			drag = true
			startPos = Floating.Position
			startInput = i.Position
		end
	end)

	UIS.InputChanged:Connect(function(i)
		if drag and i.Position then
			local delta = i.Position - startInput
			Floating.Position = UDim2.fromOffset(
				startPos.X.Offset + delta.X,
				startPos.Y.Offset + delta.Y
			)
		end
	end)

	UIS.InputEnded:Connect(function()
		drag = false
	end)
end

-- ======================================================
-- EXPOSE UI API
-- ======================================================
_G.RiiHUB_UI = UI