-- ESP + Fly com UI Mobile-Friendly
-- Autor: kawai (adaptado para mobile)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ESPFolder"
ESPFolder.Parent = game.CoreGui

local FlyEnabled = false
local ESPEnabled = false

-- UI Library (mobile-friendly)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/wally-rblx/uwuware-ui/main/main.lua"))()
local Window = Library:CreateWindow("ESP & Fly", UDim2.new(0, 300, 0, 400))

local ESPtab = Window:AddTab("ESP")
local Flytab = Window:AddTab("Fly")
local Configtab = Window:AddTab("Config")

-- ESP Toggle
ESPtab:AddToggle("Ativar ESP", function(state)
    ESPEnabled = state
end)

-- Fly Toggle
Flytab:AddToggle("Ativar Fly", function(state)
    FlyEnabled = state
    if FlyEnabled then
        startFly()
    else
        stopFly()
    end
end)

-- Config
Configtab:AddSlider("Tamanho da Box", 1, 10, 5, function(val)
    _G.BoxSize = val
end)

-- ESP Functions
local function createESP(player)
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.fromRGB(255, 255, 255)
    Box.Thickness = 1
    Box.Filled = false

    local Line = Drawing.new("Line")
    Line.Visible = false
    Line.Color = Color3.fromRGB(255, 255, 255)
    Line.Thickness = 1

    local Text = Drawing.new("Text")
    Text.Visible = false
    Text.Color = Color3.fromRGB(255, 255, 255)
    Text.Size = 16
    Text.Center = true
    Text.Outline = true

    local function updateESP()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            local vector, onScreen = Camera:WorldToViewportPoint(root.Position)

            if onScreen and ESPEnabled then
                local topY = Camera:WorldToViewportPoint((root.CFrame * CFrame.new(0, 3, 0)).Position).Y
                local bottomY = Camera:WorldToViewportPoint((root.CFrame * CFrame.new(0, -3, 0)).Position).Y
                local height = bottomY - topY
                local width = height / 2

                Box.Visible = true
                Box.Size = Vector2.new(width * (_G.BoxSize or 1), height)
                Box.Position = Vector2.new(vector.X - Box.Size.X / 2, topY)

                Line.Visible = true
                Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                Line.To = Vector2.new(vector.X, bottomY)

                Text.Visible = true
                Text.Position = Vector2.new(vector.X, topY - 20)
                Text.Text = player.Name .. " [" .. math.floor((root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) .. "m]"
            else
                Box.Visible = false
                Line.Visible = false
                Text.Visible = false
            end
        else
            Box.Visible = false
            Line.Visible = false
            Text.Visible = false
        end
    end

    RunService.RenderStepped:Connect(updateESP)
end

-- Auto ESP para novos jogadores
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createESP(player)
    end
end

Players.PlayerAdded:Connect(createESP)

-- Fly
local BodyGyro, BodyVelocity
local function startFly()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end

    BodyGyro = Instance.new("BodyGyro")
    BodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
    BodyGyro.P = 30000
    BodyGyro.Parent = LocalPlayer.Character.HumanoidRootPart

    BodyVelocity = Instance.new("BodyVelocity")
    BodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
    BodyVelocity.Velocity = Vector3.new(0, 0, 0)
    BodyVelocity.Parent = LocalPlayer.Character.HumanoidRootPart

    local function fly()
        if FlyEnabled then
            local vel = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                vel = vel + Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                vel = vel - Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                vel = vel - Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                vel = vel + Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                vel = vel + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                vel = vel - Vector3.new(0, 1, 0)
            end
            BodyVelocity.Velocity = vel * 50
            BodyGyro.CFrame = Camera.CFrame
        end
    end

    _G.FlyConnection = RunService.RenderStepped:Connect(fly)
end

local function stopFly()
    if BodyGyro then BodyGyro:Destroy() end
    if BodyVelocity then BodyVelocity:Destroy() end
    if _G.FlyConnection then _G.FlyConnection:Disconnect() end
end

-- Anti-ban (evita detecção)
local meta = getrawmetatable(game)
local oldNamecall = meta.__namecall
setreadonly(meta, false)

meta.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method == "Kick" or method == "kick" then
        return
    end
    return oldNamecall(self, ...)
end)

setreadonly(meta, true)

print("✅ Script carregado com sucesso!")
