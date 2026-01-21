-- HOMEGUI.LUA (GitHub Version)
local GUI = { Tabs = {} }
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.Name = "RiiHUB_Modular"

-- Frame Utama (Sixter Style)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 450, 0, 300)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", MainFrame)

-- Sidebar
local Sidebar = Instance.new("ScrollingFrame", MainFrame)
Sidebar.Size = UDim2.new(0, 140, 1, -10)
Sidebar.Position = UDim2.new(0, 5, 0, 5)
Sidebar.BackgroundTransparency = 1
Sidebar.CanvasSize = UDim2.new(0, 0, 2, 0)
Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 5)

-- Fungsi Membuat Tab
local function AddTab(fileName, displayName)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.Text = displayName or fileName
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn)
    
    -- Simpan dengan key nama file asli agar Loader bisa memanggilnya
    GUI.Tabs[fileName] = btn
end

-- MENYAMAKAN DENGAN SCREENSHOT REPOSITORY:
AddTab("AimAssistModule.lua", "Aim Assist")
AddTab("ESPModule.lua", "Visuals / ESP")
AddTab("EventModule.lua", "Events")
AddTab("HitBoxKiller.lua", "Hitbox Expander")
AddTab("SkillCheckGenerator.lua", "Auto Skillcheck")

-- Tambahkan fitur Flashlight yang kita buat sebelumnya jika sudah diupload:
-- AddTab("FlashlightMod.lua", "Flashlight God")

print("HomeGui Ready!")
return GUI
