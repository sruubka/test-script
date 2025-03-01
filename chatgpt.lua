-- SETTINGS
getgenv().Settings = {
    Keybinds = {
        ToggleMenu = Enum.KeyCode.Insert,
        FlyToggle = Enum.KeyCode.F,
        AimbotToggle = Enum.KeyCode.Q,
        BhopToggle = Enum.KeyCode.B
    },
    FlySpeed = 80,
    ESP = {
        Enabled = true,
        BoxColor = Color3.fromRGB(255, 0, 0),
        TeamCheck = true
    },
    Aimbot = {
        Enabled = false,
        Smoothness = 0.1,
        TeamCheck = true
    }
}

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Enabled = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 400)
Frame.Position = UDim2.new(0.5, -150, 0.5, -200)
Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)

local UIListLayout = Instance.new("UIListLayout", Frame)

local function UpdatePlayerList()
    for _, v in pairs(Frame:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local btn = Instance.new("TextButton", Frame)
            btn.Size = UDim2.new(1, 0, 0, 30)
            btn.Text = player.Name
            btn.MouseButton1Click:Connect(function()
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

local function SetMouseState(open)
    if open then
        UIS.MouseBehavior = Enum.MouseBehavior.Default
        UIS.MouseIconEnabled = true
    else
        UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
        UIS.MouseIconEnabled = false
    end
end

UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Settings.Keybinds.ToggleMenu then
        ScreenGui.Enabled = not ScreenGui.Enabled
        SetMouseState(ScreenGui.Enabled)
    end
end)

-- ESP
local function CreateESP(player)
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Settings.ESP.BoxColor
    box.Thickness = 2
    box.Filled = false

    RunService.RenderStepped:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            box.Visible = false
            return
        end

        local root = player.Character.HumanoidRootPart
        local pos, visible = Camera:WorldToViewportPoint(root.Position)

        if Settings.ESP.Enabled and visible then
            if Settings.ESP.TeamCheck and player.Team == LocalPlayer.Team then
                box.Visible = false
            else
                box.Size = Vector2.new(1000 / pos.Z, 1500 / pos.Z)
                box.Position = Vector2.new(pos.X - box.Size.X / 2, pos.Y - box.Size.Y / 2)
                box.Visible = true
            end
        else
            box.Visible = false
        end
    end)
end

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end

Players.PlayerAdded:Connect(CreateESP)

-- Aimbot
local function ClosestPlayer()
    local target, dist = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if Settings.Aimbot.TeamCheck and player.Team == LocalPlayer.Team then
                continue
            end
            local pos, visible = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(UIS:GetMouseLocation().X, UIS:GetMouseLocation().Y)).Magnitude
            if visible and mag < dist then
                dist = mag
                target = player
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    if Settings.Aimbot.Enabled then
        local target = ClosestPlayer()
        if target and target.Character then
            local root = target.Character.HumanoidRootPart
            local targetPos = Camera:WorldToViewportPoint(root.Position)
            local mousePos = UIS:GetMouseLocation()
            local smooth = Settings.Aimbot.Smoothness

            local moveX = (targetPos.X - mousePos.X) * smooth
            local moveY = (targetPos.Y - mousePos.Y) * smooth
            mousemoverel(moveX, moveY)
        end
    end
end)

UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Settings.Keybinds.AimbotToggle then
        Settings.Aimbot.Enabled = not Settings.Aimbot.Enabled
    end
end)

-- Fly + NoClip
local fly = false
local flyVelocity = Vector3.zero
local move = {W = 0, A = 0, S = 0, D = 0, Space = 0, Shift = 0}

UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Settings.Keybinds.FlyToggle then
        fly = not fly
    elseif input.KeyCode == Enum.KeyCode.W then move.W = 1
    elseif input.KeyCode == Enum.KeyCode.S then move.S = 1
    elseif input.KeyCode == Enum.KeyCode.A then move.A = 1
    elseif input.KeyCode == Enum.KeyCode.D then move.D = 1
    elseif input.KeyCode == Enum.KeyCode.Space then move.Space = 1
    elseif input.KeyCode == Enum.KeyCode.LeftShift then move.Shift = 1
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then move.W = 0
    elseif input.KeyCode == Enum.KeyCode.S then move.S = 0
    elseif input.KeyCode == Enum.KeyCode.A then move.A = 0
    elseif input.KeyCode == Enum.KeyCode.D then move.D = 0
    elseif input.KeyCode == Enum.KeyCode.Space then move.Space = 0
    elseif input.KeyCode == Enum.KeyCode.LeftShift then move.Shift = 0
    end
end)

RunService.RenderStepped:Connect(function()
    if fly then
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local cam = workspace.CurrentCamera.CFrame
            local moveDir = cam.LookVector * (move.W - move.S) + cam.RightVector * (move.D - move.A)
            moveDir = moveDir.Unit * Settings.FlySpeed + Vector3.new(0, (move.Space - move.Shift) * Settings.FlySpeed, 0)
            root.Velocity = moveDir
            root.CanCollide = false
        end
    end
end)

-- Bhop
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Settings.Keybinds.BhopToggle then
        LocalPlayer.Character.Humanoid.JumpPower = 50
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)
