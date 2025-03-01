local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local flyEnabled = false
local noclipEnabled = false
local guiEnabled = false

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
local Title = Instance.new("TextLabel", Frame)
local PlayerList = Instance.new("ScrollingFrame", Frame)

Frame.Size = UDim2.new(0, 300, 0, 400)
Frame.Position = UDim2.new(0.5, -150, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Frame.Visible = false

Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Text = "Teleport Menu"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20

PlayerList.Size = UDim2.new(1, 0, 1, -50)
PlayerList.Position = UDim2.new(0, 0, 0, 50)
PlayerList.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerList.ScrollBarThickness = 5

local function updatePlayerList()
    for _, child in ipairs(PlayerList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local button = Instance.new("TextButton", PlayerList)
            button.Size = UDim2.new(1, 0, 0, 30)
            button.Text = player.Name
            button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            button.TextColor3 = Color3.fromRGB(255, 255, 255)

            button.MouseButton1Click:Connect(function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character:SetPrimaryPartCFrame(player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0))
                end
            end)
        end
    end
    PlayerList.CanvasSize = UDim2.new(0, 0, 0, #Players:GetPlayers() * 30)
end

updatePlayerList()
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)

-- Fly + Noclip handler
local flySpeed = 85

local function setNoclip(enabled)
    noclipEnabled = enabled
end

local function flyStep()
    if not flyEnabled then return end

    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end

    local rootPart = character.HumanoidRootPart
    local camCFrame = Camera.CFrame
    local direction = Vector3.zero

    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        direction = direction + camCFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        direction = direction - camCFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        direction = direction - camCFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        direction = direction + camCFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        direction = direction + Vector3.new(0, 1, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        direction = direction - Vector3.new(0, 1, 0)
    end

    rootPart.Velocity = direction.Unit * flySpeed * 50
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

RunService.RenderStepped:Connect(function()
    flyStep()
    noclipStep()
end)

local function toggleFly()
    flyEnabled = not flyEnabled
    setNoclip(flyEnabled)

    if not flyEnabled then
        -- Wyłącz ruch
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.Velocity = Vector3.zero
        end
    end
end

local function toggleGui()
    guiEnabled = not guiEnabled
    Frame.Visible = guiEnabled
    UserInputService.MouseIconEnabled = guiEnabled

    if guiEnabled then
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    else
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    end
end

-- Bindy
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.F then
        toggleFly()
    elseif input.KeyCode == Enum.KeyCode.Insert then
        toggleGui()
    end
end)

print("Script loaded - F for fly, Insert for GUI")
