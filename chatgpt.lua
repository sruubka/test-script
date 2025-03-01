local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- UI Library (prosta ramka)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 300)
Frame.Position = UDim2.new(0.5, -100, 0.5, -150)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Visible = false -- Startowo ukryte
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Text = "Teleport GUI"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Parent = Frame

local PlayerList = Instance.new("ScrollingFrame")
PlayerList.Size = UDim2.new(1, 0, 1, -30)
PlayerList.Position = UDim2.new(0, 0, 0, 30)
PlayerList.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerList.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
PlayerList.Parent = Frame

local function updatePlayerList()
    for _, v in pairs(PlayerList:GetChildren()) do
        if v:IsA("TextButton") then
            v:Destroy()
        end
    end

    local ySize = 0
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local button = Instance.new("TextButton")
            button.Size = UDim2.new(1, 0, 0, 30)
            button.Text = player.Name
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
            button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

            button.MouseButton1Click:Connect(function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
                end
            end)

            button.Parent = PlayerList
            ySize = ySize + 30
        end
    end

    PlayerList.CanvasSize = UDim2.new(0, 0, 0, ySize)
end

-- Klawisz Insert - Show/Hide GUI
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
        Frame.Visible = not Frame.Visible
        if Frame.Visible then
            updatePlayerList()
        end
    end
end)

-- Auto-update lista graczy co 5 sekund
while true do
    if Frame.Visible then
        updatePlayerList()
    end
    wait(5)
end
