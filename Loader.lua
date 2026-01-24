-- RiiHUB Loader.lua
-- Popup Neon Purple + [R] Logo
-- Loader -> Popup -> HomeGui -> <Game>/main.lua

-- =========================
-- ANTI DOUBLE EXECUTE
-- =========================
if _G.RIIHUB_LOADER_LOADED then
    return
end
_G.RIIHUB_LOADER_LOADED = true

-- =========================
-- SERVICES
-- =========================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

if not LocalPlayer:FindFirstChild("PlayerGui") then
    LocalPlayer:WaitForChild("PlayerGui")
end
local PlayerGui = LocalPlayer.PlayerGui

-- =========================
-- PLACEID -> GAME FOLDER
-- =========================
local GAME_MAP = {
    [93978595733734] = "ViolenceDistrict",
    [6358567974]     = "SalonDeFiestas",
}

local placeId = game.PlaceId
local gameFolder = GAME_MAP[placeId]

if not gameFolder then
    warn("[RiiHUB] Game tidak didukung. PlaceId:", placeId)
    return
end

-- =========================
-- NEON POPUP
-- =========================
local function showPopup(gameName)
    local gui = Instance.new("ScreenGui")
    gui.Name = "RiiHUB_Popup"
    gui.ResetOnSpawn = false
    gui.Parent = PlayerGui

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.fromOffset(300, 84)
    frame.Position = UDim2.new(1, -320, 1, 120)
    frame.AnchorPoint = Vector2.new(0, 1)
    frame.BackgroundColor3 = Color3.fromRGB(48, 18, 78) -- ungu neon gelap
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 0

    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 16)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(170, 120, 255)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.15

    -- Logo [R]
    local logo = Instance.new("TextLabel", frame)
    logo.Size = UDim2.fromOffset(40, 40)
    logo.Position = UDim2.fromOffset(16, 22)
    logo.BackgroundTransparency = 1
    logo.Text = "[R]"
    logo.Font = Enum.Font.GothamBlack
    logo.TextSize = 22
    logo.TextColor3 = Color3.fromRGB(190, 150, 255)

    -- Text container
    local textHolder = Instance.new("Frame", frame)
    textHolder.Position = UDim2.fromOffset(64, 14)
    textHolder.Size = UDim2.new(1, -76, 1, -28)
    textHolder.BackgroundTransparency = 1

    local title = Instance.new("TextLabel", textHolder)
    title.Size = UDim2.new(1, 0, 0, 24)
    title.BackgroundTransparency = 1
    title.Text = "Game berhasil diload"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextColor3 = Color3.fromRGB(220, 200, 255)

    local subtitle = Instance.new("TextLabel", textHolder)
    subtitle.Position = UDim2.fromOffset(0, 26)
    subtitle.Size = UDim2.new(1, 0, 0, 22)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = gameName
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 13
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.TextColor3 = Color3.fromRGB(180, 160, 230)

    -- Animasi masuk (slide + fade)
    frame.BackgroundTransparency = 1
    stroke.Transparency = 1
    logo.TextTransparency = 1
    title.TextTransparency = 1
    subtitle.TextTransparency = 1

    local enter = TweenService:Create(
        frame,
        TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { Position = UDim2.new(1, -320, 1, -24), BackgroundTransparency = 0 }
    )
    enter:Play()

    TweenService:Create(stroke, TweenInfo.new(0.45), { Transparency = 0.15 }):Play()
    TweenService:Create(logo, TweenInfo.new(0.45), { TextTransparency = 0 }):Play()
    TweenService:Create(title, TweenInfo.new(0.45), { TextTransparency = 0 }):Play()
    TweenService:Create(subtitle, TweenInfo.new(0.45), { TextTransparency = 0 }):Play()

    -- Tahan sebentar lalu keluar
    task.delay(1.6, function()
        local exit = TweenService:Create(
            frame,
            TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            { Position = UDim2.new(1, -320, 1, 120), BackgroundTransparency = 1 }
        )
        exit:Play()
        TweenService:Create(stroke, TweenInfo.new(0.35), { Transparency = 1 }):Play()
        TweenService:Create(logo, TweenInfo.new(0.35), { TextTransparency = 1 }):Play()
        TweenService:Create(title, TweenInfo.new(0.35), { TextTransparency = 1 }):Play()
        TweenService:Create(subtitle, TweenInfo.new(0.35), { TextTransparency = 1 }):Play()
        exit.Completed:Wait()
        gui:Destroy()
    end)
end

showPopup(gameFolder)

-- =========================
-- BASE RAW GITHUB URL
-- =========================
local BASE_URL = "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/"

-- =========================
-- LOAD HOMEGUI + MAIN.LUA
-- =========================
task.delay(0.35, function()
    local okGui, errGui = pcall(function()
        loadstring(game:HttpGet(BASE_URL .. "HomeGui.lua"))()
    end)
    if not okGui then
        warn("[RiiHUB] Gagal load HomeGui.lua:", errGui)
        return
    end

    local okGame, errGame = pcall(function()
        loadstring(game:HttpGet(BASE_URL .. gameFolder .. "/main.lua"))()
    end)
    if not okGame then
        warn("[RiiHUB] Gagal load main.lua:", errGame)
        return
    end
end)