local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local flyEnabled = false
local noclipEnabled = false
local flySpeed = 5

local movement = {W = 0, A = 0, S = 0, D = 0, Space = 0, Shift = 0}

local function updateMovement(input, isPressed)
    local value = isPressed and 1 or 0
    if input.KeyCode == Enum.KeyCode.W then movement.W = value end
    if input.KeyCode == Enum.KeyCode.S then movement.S = value end
    if input.KeyCode == Enum.KeyCode.A then movement.A = value end
    if input.KeyCode == Enum.KeyCode.D then movement.D = value end
    if input.KeyCode == Enum.KeyCode.Space then movement.Space = value end
    if input.KeyCode == Enum.KeyCode.LeftShift then movement.Shift = value end
end

local function setNoclip(enabled)
    noclipEnabled = enabled
end

local function noclipStep()
    if not noclipEnabled then return end
    local character = LocalPlayer.Character
    if not character then return end

    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

local function flyStep()
    if not flyEnabled then return end

    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end

    local rootPart = character.HumanoidRootPart
    local camCF = Camera.CFrame

    local forward = camCF.LookVector * (movement.W - movement.S)
    local right = camCF.RightVector * (movement.D - movement.A)
    local up = Vector3.new(0, 1, 0) * (movement.Space - movement.Shift)

    local moveDirection = (forward + right + up).Unit

    if moveDirection.Magnitude > 0 then
        rootPart.CFrame = rootPart.CFrame + (moveDirection * flySpeed / 5)
    end
end

-- Fly Toggle
local function toggleFly()
    flyEnabled = not flyEnabled
    setNoclip(flyEnabled)

    if not flyEnabled then
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.Velocity = Vector3.zero
        end
    end
end

-- Klawisze ruchu (obsługa)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        updateMovement(input, true)

        if input.KeyCode == Enum.KeyCode.F then
            toggleFly()
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    updateMovement(input, false)
end)

RunService.RenderStepped:Connect(function()
    flyStep()
    noclipStep()
end)

print("Fly+Noclip załadowany (F = fly)!")
