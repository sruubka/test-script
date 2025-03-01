local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- UI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 250, 0, 300)
Frame.Position = UDim2.new(0.5, -125, 0.5, -150)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Visible = false
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Text = "Teleport GUI"
Title.TextScaled = true

local PlayerList = Instance.new("ScrollingFrame", Frame)
PlayerList.Size = UDim2.new(1, 0, 1, -30)
PlayerList.Position = UDim2.new(0, 0, 0, 30)
PlayerList.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerList.ScrollBarThickness = 5
PlayerList.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

local function updatePlayerList()
    for _, child in pairs(PlayerList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    local yPos = 0

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local button = Instance.new("TextButton")
            button.Size = UDim2.new(1, 0, 0, 30)
            button.Position = UDim2.new(0, 0, 0, yPos)
            button.Text = player.Name
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
            button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            button.Parent = PlayerList

            button.MouseButton1Click:Connect(function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
                end
            end)

            yPos = yPos + 30
        end
    end

    PlayerList.CanvasSize = UDim2.new(0, 0, 0, yPos)
end

local guiVisible = false

local function toggleGUI()
    guiVisible = not guiVisible
    Frame.Visible = guiVisible

    if guiVisible then
        updatePlayerList()
        UserInputService.MouseIconEnabled = true
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    else
        UserInputService.MouseIconEnabled = false
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
        toggleGUI()
    end
end)

-- Aktualizacja listy co 5 sekund, jak GUI jest otwarte
RunService.Heartbeat:Connect(function()
    if guiVisible then
        updatePlayerList()
    end
end)
