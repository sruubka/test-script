-- Services
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- Config system (zapis i odczyt)
local ConfigFile = "ModernMenu_Config.json"
local Config = {
    FlySpeed = 100,
    BhopSpeed = 60,
    ESPEnabled = false,
    AimbotEnabled = false,
    AimbotKey = Enum.KeyCode.E,
    MenuKey = Enum.KeyCode.Insert,
    FlyKey = Enum.KeyCode.F,
    BhopKey = Enum.KeyCode.B
}

local function LoadConfig()
    if isfile(ConfigFile) then
        Config = HttpService:JSONDecode(readfile(ConfigFile))
    else
        writefile(ConfigFile, HttpService:JSONEncode(Config))
    end
end

local function SaveConfig()
    writefile(ConfigFile, HttpService:JSONEncode(Config))
end

LoadConfig()

-- GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Enabled = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 350, 0, 500)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true

local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(255, 255, 255)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "Modern Menu"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 24
Title.Font = Enum.Font.GothamBold

local OptionsFrame = Instance.new("ScrollingFrame", MainFrame)
OptionsFrame.Size = UDim2.new(1, 0, 1, -50)
OptionsFrame.Position = UDim2.new(0, 0, 0, 50)
OptionsFrame.CanvasSize = UDim2.new(0, 0, 0, 400)
OptionsFrame.ScrollBarThickness = 3
OptionsFrame.BackgroundTransparency = 1

local UIListLayout = Instance.new("UIListLayout", OptionsFrame)
UIListLayout.Padding = UDim.new(0, 5)

local function AddToggleOption(text, configKey)
    local button = Instance.new("TextButton", OptionsFrame)
    button.Size = UDim2.new(1, 0, 0, 40)
    button.BackgroundColor3 = Config[configKey] and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Text = text

    button.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        button.BackgroundColor3 = Config[configKey] and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
        SaveConfig()
    end)
end

local function AddSliderOption(text, configKey, min, max)
    local label = Instance.new("TextLabel", OptionsFrame)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Text = text .. ": " .. Config[configKey]
    label.TextXAlignment = Enum.TextXAlignment.Left

    local slider = Instance.new("TextBox", OptionsFrame)
    slider.Size = UDim2.new(1, 0, 0, 30)
    slider.Text = tostring(Config[configKey])
    slider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    slider.TextColor3 = Color3.fromRGB(255, 255, 255)

    slider.FocusLost:Connect(function()
        local value = tonumber(slider.Text)
        if value then
            Config[configKey] = math.clamp(value, min, max)
            label.Text = text .. ": " .. Config[configKey]
            SaveConfig()
        end
    end)
end

AddToggleOption("ESP", "ESPEnabled")
AddToggleOption("Aimbot", "AimbotEnabled")
AddSliderOption("Fly Speed", "FlySpeed", 50, 300)
AddSliderOption("Bhop Speed", "BhopSpeed", 20, 200)

-- Teleport menu
local function AddPlayerButton(player)
    local button = Instance.new("TextButton", OptionsFrame)
    button.Size = UDim2.new(1, 0, 0, 30)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Text = "Teleport to: " .. player.Name

    button.MouseButton1Click:Connect(function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame
        end
    end)
end

local function UpdatePlayerList()
    for _, child in pairs(OptionsFrame:GetChildren()) do
        if child:IsA("TextButton") and child.Text:find("Teleport to") then
            child:Destroy()
        end
    end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            AddPlayerButton(player)
        end
    end
end

Players.PlayerAdded:Connect(UpdatePlayerList)
Players.PlayerRemoving:Connect(UpdatePlayerList)
UpdatePlayerList()

-- Keybind and Menu Handling
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Config.MenuKey then
        ScreenGui.Enabled = not ScreenGui.Enabled
        UIS.MouseIconEnabled = ScreenGui.Enabled
        UIS.MouseBehavior = ScreenGui.Enabled and Enum.MouseBehavior.Default or Enum.MouseBehavior.LockCenter
    elseif input.KeyCode == Config.FlyKey then
        Config.FlyEnabled = not Config.FlyEnabled
    elseif input.KeyCode == Config.BhopKey then
        Config.BhopEnabled = not Config.BhopEnabled
    end
end)

-- Bhop
RunService.RenderStepped:Connect(function()
    if Config.BhopEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Config.BhopSpeed
    elseif not Config.BhopEnabled then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end
end)

-- Fly
RunService.RenderStepped:Connect(function()
    if Config.FlyEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local HRP = LocalPlayer.Character.HumanoidRootPart
        local cf = workspace.CurrentCamera.CFrame
        HRP.Velocity = Vector3.new()

        local move = Vector3.new(
            (UIS:IsKeyDown(Enum.KeyCode.D) and 1 or 0) - (UIS:IsKeyDown(Enum.KeyCode.A) and 1 or 0),
            (UIS:IsKeyDown(Enum.KeyCode.Space) and 1 or 0) - (UIS:IsKeyDown(Enum.KeyCode.LeftShift) and 1 or 0),
            (UIS:IsKeyDown(Enum.KeyCode.S) and 1 or 0) - (UIS:IsKeyDown(Enum.KeyCode.W) and 1 or 0)
        )

        HRP.CFrame = cf
        HRP.Velocity = cf:VectorToWorldSpace(move) * Config.FlySpeed
    end
end)

-- ESP i Aimbot mogą być dodane dalej

SaveConfig()
