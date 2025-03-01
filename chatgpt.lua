local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local SettingsFile = "MyScriptSettings.json"

local Settings = {
    FlySpeed = 85,
    FlyKey = Enum.KeyCode.F,
    MenuKey = Enum.KeyCode.Insert,
    AimbotKey = Enum.KeyCode.E
}

-- Ładowanie zapisanych ustawień
pcall(function()
    if isfile(SettingsFile) then
        Settings = HttpService:JSONDecode(readfile(SettingsFile))
    end
end)

-- Zapisywanie ustawień
local function SaveSettings()
    writefile(SettingsFile, HttpService:JSONEncode(Settings))
end

-- GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Enabled = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 350, 0, 400)
Frame.Position = UDim2.new(0.5, -175, 0.5, -200)
Frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Frame.Active = true
Frame.Draggable = true

local UIListLayout = Instance.new("UIListLayout", Frame)
UIListLayout.Padding = UDim.new(0, 5)

local function CreateButton(text, callback)
    local Button = Instance.new("TextButton", Frame)
    Button.Size = UDim2.new(1, 0, 0, 30)
    Button.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Text = text
    Button.MouseButton1Click:Connect(callback)
end

-- Fly System
local flying = false
local keys = {W = 0, A = 0, S = 0, D = 0, Space = 0, LeftShift = 0}

local function toggleFly()
    flying = not flying
    if not flying then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end

-- Noclip + Fly handling
RunService.RenderStepped:Connect(function()
    if not flying then return end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    char.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)

    local moveDirection = Vector3.new()
    local camCF = workspace.CurrentCamera.CFrame

    if keys.W == 1 then moveDirection += camCF.LookVector end
    if keys.S == 1 then moveDirection -= camCF.LookVector end
    if keys.A == 1 then moveDirection -= camCF.RightVector end
    if keys.D == 1 then moveDirection += camCF.RightVector end
    if keys.Space == 1 then moveDirection += Vector3.new(0, 1, 0) end
    if keys.LeftShift == 1 then moveDirection -= Vector3.new(0, 1, 0) end

    char.HumanoidRootPart.Velocity = moveDirection.Unit * Settings.FlySpeed
    char.HumanoidRootPart.CanCollide = false -- Noclip
end)

-- Keybind handling
UIS.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Settings.MenuKey and not gameProcessed then
        ScreenGui.Enabled = not ScreenGui.Enabled
        UIS.MouseBehavior = ScreenGui.Enabled and Enum.MouseBehavior.Default or Enum.MouseBehavior.LockCenter
    elseif input.KeyCode == Settings.FlyKey then
        toggleFly()
    elseif input.KeyCode == Settings.AimbotKey then
        -- Tutaj będzie aimbot
    end
    if keys[input.KeyCode.Name] ~= nil then
        keys[input.KeyCode.Name] = 1
    end
end)

UIS.InputEnded:Connect(function(input)
    if keys[input.KeyCode.Name] ~= nil then
        keys[input.KeyCode.Name] = 0
    end
end)

-- Lista graczy + teleport
local function UpdatePlayerList()
    for _, v in pairs(Frame:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            CreateButton(player.Name, function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
                end
            end)
        end
    end
end

Players.PlayerAdded:Connect(UpdatePlayerList)
Players.PlayerRemoving:Connect(UpdatePlayerList)
UpdatePlayerList()

-- ESP
local ESPBoxes = {}

local function CreateESP(player)
    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Color = Color3.new(1, 0, 0)
    box.Filled = false
    ESPBoxes[player] = box
end

local function RemoveESP(player)
    if ESPBoxes[player] then
        ESPBoxes[player]:Remove()
        ESPBoxes[player] = nil
    end
end

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end

Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

RunService.RenderStepped:Connect(function()
    for player, box in pairs(ESPBoxes) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local size = Vector2.new(50, 100) / pos.Z
                box.Size = size
                box.Position = Vector2.new(pos.X - size.X / 2, pos.Y - size.Y / 2)
                box.Visible = true
            else
                box.Visible = false
            end
        else
            box.Visible = false
        end
    end
end)

-- Aimbot z team check
local function GetClosestTarget()
    local closest, dist = nil, math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local mag = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(UIS:GetMouseLocation().X, UIS:GetMouseLocation().Y)).Magnitude
                    if mag < dist then
                        closest, dist = player, mag
                    end
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if UIS:IsKeyDown(Settings.AimbotKey) then
        local target = GetClosestTarget()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)

-- Menu: zmiana bindów i flyspeed
CreateButton("Zmień Fly Speed", function()
    Settings.FlySpeed = tonumber(game:GetService("Players").LocalPlayer:FindFirstChildWhichIsA("PlayerGui"):PromptInput("Nowa prędkość:"))
    SaveSettings()
end)

SaveSettings()
