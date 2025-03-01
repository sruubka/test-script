-- Skrypt w LocalScript

-- Zmienna do gracza i GUI
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Tworzymy GUI, które będzie widoczne po naciśnięciu Insert
local gui = Instance.new("ScreenGui")
gui.Name = "AimAssistGui"
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.3, 0, 0.3, 0) -- Rozmiar okna
frame.Position = UDim2.new(0.35, 0, 0.35, 0) -- Pozycja okna na ekranie
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.5
frame.Parent = gui

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 1, 0)
label.Text = "Aim Assist: Off"
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.BackgroundTransparency = 1
label.Parent = frame

-- Stan aktywacji aim assist
local aimAssistEnabled = false

-- Funkcja do aktywowania lub dezaktywowania GUI
local function toggleAimAssist()
    aimAssistEnabled = not aimAssistEnabled
    gui.Enabled = aimAssistEnabled
    label.Text = aimAssistEnabled and "Aim Assist: On" or "Aim Assist: Off"
end

-- Funkcja nakierowująca kamerę na głowy przeciwników
local function aimAtEnemies()
    -- Szukamy przeciwników w grze (graczy innych niż nasz)
    for _, otherPlayer in ipairs(game.Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("Head") then
            local headPosition = otherPlayer.Character.Head.Position
            -- Sprawdzamy, czy gracz znajduje się w zasięgu
            local direction = (headPosition - workspace.CurrentCamera.CFrame.Position).unit
            -- Tworzymy nową CFrame dla kamery, aby patrzyła na głowę przeciwnika
            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, headPosition)
            break  -- Tylko pierwszy przeciwnik zostanie wybrany
        end
    end
end

-- Nasłuchujemy na naciśnięcie klawisza Insert
local userInputService = game:GetService("UserInputService")
userInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    -- Sprawdzamy, czy naciśnięto klawisz Insert
    if input.KeyCode == Enum.KeyCode.Insert then
        toggleAimAssist()
    end
end)

-- Co sekundę sprawdzamy, czy mamy włączony aim assist i jeśli tak, nakierowujemy kamerę
game:GetService("RunService").Heartbeat:Connect(function()
    if aimAssistEnabled then
        aimAtEnemies()
    end
end)
