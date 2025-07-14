--// ESP + Fly | Fluent UI
--// Mobile-friendly | GitHub RAW ready
--// Autor: kawai

local repo = "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/"

local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet(repo .. "addons/InterfaceManager.lua"))()

local Window = Library:CreateWindow({
    Title = "ESP & Fly | Mobile Ready",
    SubTitle = "by kawai",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl,
    DisableRay = false,
    DisableMenuAnchor = true
})

local Tabs = {
    ESP = Window:AddTab({ Title = "ESP", Icon = "eye" }),
    Fly = Window:AddTab({ Title = "Fly", Icon = "wind" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ESPObjects"
ESPFolder.Parent = game:GetService("CoreGui")

-- ESP
local ESPEnabled = false
local BoxColor = Color3.new(1, 1, 1)
local UseTeamColor = false

local function createESP(player)
    local Box = Drawing.new("Square")
    local NameText = Drawing.new("Text")
    local Line = Drawing.new("Line")

    local function update()
        if not ESPEnabled then
            Box.Visible = false
            NameText.Visible = false
            Line.Visible = false
            return
        end

        local character = player.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then return end

        local root = character.HumanoidRootPart
        local vector, onScreen = Camera:WorldToViewportPoint(root.Position)

        if onScreen then
            local topY = Camera:WorldToViewportPoint((root.CFrame * CFrame.new(0, 3, 0)).Position).Y
            local bottomY = Camera:WorldToViewportPoint((root.CFrame * CFrame.new(0, -3, 0)).Position).Y
            local height = bottomY - topY
            local width = height / 2

            Box.Visible = true
            Box.Size = Vector2.new(width, height)
            Box.Position = Vector2.new(vector.X - width / 2, topY)
            Box.Color = UseTeamColor and (player.Team and player.TeamColor.Color or BoxColor) or BoxColor
            Box.Thickness = 1
            Box.Filled = false

            NameText.Visible = true
            NameText.Text = player.Name .. " [" .. math.floor((root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) .. "m]"
            NameText.Position = Vector2.new(vector.X, topY - 15)
            NameText.Size = 16
            NameText.Center = true
            NameText.Outline = true
            NameText.Color = Box.Color

            Line.Visible = true
            Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            Line.To = Vector2.new(vector.X, bottomY)
            Line.Color = Box.Color
            Line.Thickness = 1
        else
            Box.Visible = false
            NameText.Visible = false
            Line.Visible = false
        end
    end

    RunService.RenderStepped:Connect(update)
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createESP(player)
    end
end
Players.PlayerAdded:Connect(createESP)

-- ESP Toggle
Tabs.ESP:AddToggle("Ativar ESP", { Title = "Ativar ESP", Default = false })
    :OnChanged(function(value)
        ESPEnabled = value
    end)

Tabs.ESP:AddToggle("Cor do Time", { Title = "Usar cor do time", Default = false })
    :OnChanged(function(value)
        UseTeamColor = value
    end)

Tabs.ESP:AddColorpicker("Cor da Box", {
    Default = BoxColor,
    Title = "Cor",
    Transparency = 0
}, function(value)
    BoxColor = value
end)

-- Fly
local flying = false
local bV, bG

local function startFly()
    if flying then return end
    flying = true

    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    bV = Instance.new("BodyVelocity")
    bV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bV.Velocity = Vector3.zero
    bV.Parent = root

    bG = Instance.new("BodyGyro")
    bG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bG.P = 10000
    bG.Parent = root

    local function updateFly()
        if not flying then return end
        local cf = Camera.CFrame
        local direction = Vector3.zero

        local moveVector = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveVector = moveVector + cf.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveVector = moveVector - cf.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveVector = moveVector - cf.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveVector = moveVector + cf.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveVector = moveVector + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveVector = moveVector - Vector3.new(0, 1, 0)
        end

        bV.Velocity = moveVector.Unit * 50
        bG.CFrame = cf
    end

    _G.flyConnection = RunService.RenderStepped:Connect(updateFly)
end

local function stopFly()
    flying = false
    if bV then bV:Destroy() end
    if bG then bG:Destroy() end
    if _G.flyConnection then _G.flyConnection:Disconnect() end
end

Tabs.Fly:AddToggle("Ativar Fly", { Title = "Ativar Fly", Default = false })
    :OnChanged(function(value)
        if value then
            startFly()
        else
            stopFly()
        end
    end)

-- Save & Interface Manager
SaveManager:SetLibrary(Library)
InterfaceManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("ESP_Fly_Config")
SaveManager:SetFolder("ESP_Fly_Config")
SaveManager:BuildConfigSection(Tabs.Settings)
InterfaceManager:ApplyToTab(Tabs.Settings)

Library:Notify("Carregado! Use a UI para controlar ESP e Fly.")
