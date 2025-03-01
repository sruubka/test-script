-- GUI i teleport
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Enabled = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 400)
Frame.Position = UDim2.new(0.5, -150, 0.5, -200)
Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

local UIListLayout = Instance.new("UIListLayout", Frame)
UIListLayout.Padding = UDim.new(0, 5)

local function UpdatePlayerList()
    for _, child in pairs(Frame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local PlayerButton = Instance.new("TextButton", Frame)
            PlayerButton.Size = UDim2.new(1, 0, 0, 30)
            PlayerButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            PlayerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            PlayerButton.Text = player.Name

            PlayerButton.MouseButton1Click:Connect(function()
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame
                end
            end)
        end
    end
end

Players.PlayerAdded:Connect(UpdatePlayerList)
Players.PlayerRemoving:Connect(UpdatePlayerList)

UIS.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.Insert and not gameProcessed then
        ScreenGui.Enabled = not ScreenGui.Enabled
        UIS.MouseBehavior = ScreenGui.Enabled and Enum.MouseBehavior.Default or Enum.MouseBehavior.LockCenter
    end
end)

UpdatePlayerList()

-- Fly + Noclip system
local flying = false
local flySpeed = 50
local flyVelocity = Vector3.new()

local keys = {W = 0, A = 0, S = 0, D = 0, Space = 0, LeftShift = 0}

-- Funkcja zmiany noclipa
local function setNoclip(state)
    local char = LocalPlayer.Character
    if not char then return end
    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("BasePart") and v.CanCollide ~= nil then
            v.CanCollide = not state
        end
    end
end

-- Funkcja do włączania/wyłączania fly + noclip
local function toggleFly()
    flying = not flying
    setNoclip(flying)

    if not flying and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end

-- Sterowanie fly
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F then
        toggleFly()
    elseif input.KeyCode == Enum.KeyCode.W then
        keys.W = 1
    elseif input.KeyCode == Enum.KeyCode.S then
        keys.S = 1
    elseif input.KeyCode == Enum.KeyCode.A then
        keys.A = 1
    elseif input.KeyCode == Enum.KeyCode.D then
        keys.D = 1
    elseif input.KeyCode == Enum.KeyCode.Space then
        keys.Space = 1
    elseif input.KeyCode == Enum.KeyCode.LeftShift then
        keys.LeftShift = 1
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then
        keys.W = 0
    elseif input.KeyCode == Enum.KeyCode.S then
        keys.S = 0
    elseif input.KeyCode == Enum.KeyCode.A then
        keys.A = 0
    elseif input.KeyCode == Enum.KeyCode.D then
        keys.D = 0
    elseif input.KeyCode == Enum.KeyCode.Space then
        keys.Space = 0
    elseif input.KeyCode == Enum.KeyCode.LeftShift then
        keys.LeftShift = 0
    end
end)

RunService.RenderStepped:Connect(function()
    if not flying then return end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local rootPart = char.HumanoidRootPart

    local moveDirection = Vector3.new()
    local camCF = workspace.CurrentCamera.CFrame

    if keys.W == 1 then
        moveDirection = moveDirection + camCF.LookVector
    end
    if keys.S == 1 then
        moveDirection = moveDirection - camCF.LookVector
    end
    if keys.A == 1 then
        moveDirection = moveDirection - camCF.RightVector
    end
    if keys.D == 1 then
        moveDirection = moveDirection + camCF.RightVector
    end
    if keys.Space == 1 then
        moveDirection = moveDirection + Vector3.new(0, 1, 0)
    end
    if keys.LeftShift == 1 then
        moveDirection = moveDirection - Vector3.new(0, 1, 0)
    end

    flyVelocity = moveDirection.Unit * flySpeed

    if flyVelocity.Magnitude > 0 then
        rootPart.Velocity = flyVelocity
    else
        rootPart.Velocity = Vector3.new(0, 0, 0)
    end
end)
