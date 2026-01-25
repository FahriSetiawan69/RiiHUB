-- HomeGui.lua (FINAL UI ENGINE)

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local pgui = lp:WaitForChild("PlayerGui")

-- Destroy old UI
if pgui:FindFirstChild("RiiHUB_UI") then
    pgui.RiiHUB_UI:Destroy()
end

-- Root GUI
local gui = Instance.new("ScreenGui", pgui)
gui.Name = "RiiHUB_UI"
gui.ResetOnSpawn = false

-- Main Frame
local main = Instance.new("Frame", gui)
main.Size = UDim2.fromScale(0.7, 0.6)
main.Position = UDim2.fromScale(0.15, 0.2)
main.BackgroundColor3 = Color3.fromRGB(35, 10, 60)
main.BorderSizePixel = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 18)

-- Sidebar
local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.fromScale(0.18, 1)
sidebar.BackgroundColor3 = Color3.fromRGB(25, 5, 45)
sidebar.BorderSizePixel = 0

local sidebarLayout = Instance.new("UIListLayout", sidebar)
sidebarLayout.Padding = UDim.new(0, 6)

-- Content
local content = Instance.new("Frame", main)
content.Position = UDim2.fromScale(0.18, 0)
content.Size = UDim2.fromScale(0.82, 1)
content.BackgroundTransparency = 1

-- Internal storage
local Tabs = {}
local Pages = {}

-- =========================
-- UI ENGINE API
-- =========================
local UI = {}

function UI:AddTab(name)
    if Tabs[name] then return end

    local btn = Instance.new("TextButton", sidebar)
    btn.Size = UDim2.fromScale(1, 0.085)
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 15
    btn.TextColor3 = Color3.fromRGB(210, 170, 255)
    btn.BackgroundColor3 = Color3.fromRGB(60, 20, 100)
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

    local page = Instance.new("Frame", content)
    page.Size = UDim2.fromScale(1, 1)
    page.Visible = false
    page.BackgroundTransparency = 1

    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do
            p.Visible = false
        end
        page.Visible = true
    end)

    Tabs[name] = btn
    Pages[name] = page

    -- Auto select first tab
    if not UI._Selected then
        UI._Selected = name
        page.Visible = true
    end
end

function UI:AddToggle(tabName, label, default)
    local page = Pages[tabName]
    if not page then return end

    local toggle = Instance.new("TextButton", page)
    toggle.Size = UDim2.fromScale(0.7, 0.08)
    toggle.Text = label .. " : OFF"
    toggle.Font = Enum.Font.GothamBold
    toggle.TextSize = 14
    toggle.TextColor3 = Color3.new(1, 1, 1)
    toggle.BackgroundColor3 = Color3.fromRGB(90, 30, 140)
    toggle.BorderSizePixel = 0
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 10)

    local state = default or false

    local api = {}
    function api:Bind(callback)
        toggle.MouseButton1Click:Connect(function()
            state = not state
            toggle.Text = label .. " : " .. (state and "ON" or "OFF")
            callback(state)
        end)
    end

    return api
end

-- Expose API
_G.RiiHUB_UI = UI
print("[RiiHUB] UI Engine ready")