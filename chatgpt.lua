-- GUI
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")

-- Tworzenie GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Enabled = false  -- domyślnie ukryte

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 400)
Frame.Position = UDim2.new(0.5, -150, 0.5, -200)
Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

local UIListLayout = Instance.new("UIListLayout", Frame)
UIListLayout.Padding = UDim.new(0, 5)

-- Funkcja do aktualizacji listy graczy
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

-- Aktualizacja przy join/leave gracza
Players.PlayerAdded:Connect(UpdatePlayerList)
Players.PlayerRemoving:Connect(UpdatePlayerList)

-- Klawisz Insert do pokazania GUI
UIS.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.Insert and not gameProcessed then
        ScreenGui.Enabled = not ScreenGui.Enabled
        UIS.MouseBehavior = ScreenGui.Enabled and Enum.MouseBehavior.Default or Enum.MouseBehavior.LockCenter
    end
end)

-- Pierwsze zaladowanie listy
UpdatePlayerList()
