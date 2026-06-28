--[[
    Fling + Noclip + Head Aimbot (только игроки) + ESP (только игроки, с трейсерами) + RAGE (Spinbot, Silent Aim, Bhop)
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ======== НАСТРОЙКИ ========
local isFlinging = false
local cooldown = false
local connections = {}
local espObjects = {}

local Settings = {
    FlingEnabled = true,
    LaunchDirection = "Diagonal",
    DiagonalPower = 175,
    VerticalPower = 1,
    SpinSpeed = 50,
    FlashDuration = 0.5,
    DiagonalDuration = 1,
    MinLaunchPower = 230,
    MaxLaunchPower = 390,
    DebugMode = true,
    BounceIntensity = 1.5,
    CooldownEnabled = true,
    CooldownDuration = 2,
    NoclipDuration = 2
}

local VisualSettings = {
    ESPEnabled = false,
    AimbotEnabled = false,
    AimbotSensitivity = 0.2,
    RainbowCursor = false
}

-- ======== RAGE НАСТРОЙКИ ========
local RageSettings = {
    SpinbotEnabled = false,
    SpinbotMode = "Up", -- Up, Down, LookUp, LookDown
    SilentAimEnabled = false,
    BhopEnabled = false
}

-- ======== МЕНЮ ========
local Window = Rayfield:CreateWindow({
    Name = "⚡ GNG Ultimate",
    LoadingTitle = "Загрузка...",
    LoadingSubtitle = "by GNG",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "GNGScripts",
        FileName = "UltimateSettings"
    },
    Keybind = Enum.KeyCode.Insert,
    Size = UDim2.new(0, 650, 0, 600)
})

-- Вкладка FLING
local FlingTab = Window:CreateTab("🎮 Fling", 4483362458)
FlingTab:CreateToggle({
    Name = "Fling Enabled",
    CurrentValue = Settings.FlingEnabled,
    Flag = "FlingEnabled",
    Callback = function(v) Settings.FlingEnabled = v end
})
FlingTab:CreateDropdown({
    Name = "Launch Direction",
    Options = {"Up", "Diagonal", "Bounce"},
    CurrentOption = {"Diagonal"},
    MultipleOptions = false,
    Flag = "LaunchDirection",
    Callback = function(o) Settings.LaunchDirection = o[1] end
})
FlingTab:CreateSlider({
    Name = "Noclip Duration",
    Range = {0.5, 5},
    Increment = 0.5,
    Suffix = "s",
    CurrentValue = Settings.NoclipDuration,
    Flag = "NoclipDuration",
    Callback = function(v) Settings.NoclipDuration = v end
})

-- Вкладка AIMBOT
local AimbotTab = Window:CreateTab("🎯 Aimbot", 4483362458)
AimbotTab:CreateToggle({
    Name = "Включить Aimbot (Toggle: X)",
    CurrentValue = false,
    Flag = "AimbotToggle",
    Callback = function(v) VisualSettings.AimbotEnabled = v end
})
AimbotTab:CreateSlider({
    Name = "Чувствительность",
    Range = {0, 1},
    Increment = 0.05,
    Suffix = "x",
    CurrentValue = 0.2,
    Flag = "AimbotSens",
    Callback = function(v) VisualSettings.AimbotSensitivity = v end
})
AimbotTab:CreateLabel("🎯 Цель: голова (только игроки)")

-- ======== ВКЛАДКА RAGE ========
local RageTab = Window:CreateTab("🔥 RAGE", 4483362458)

RageTab:CreateToggle({
    Name = "Spinbot",
    CurrentValue = false,
    Flag = "SpinbotToggle",
    Callback = function(v)
        RageSettings.SpinbotEnabled = v
        if v then
            RageSettings.SilentAimEnabled = true
        end
    end
})

RageTab:CreateDropdown({
    Name = "Spinbot Mode",
    Options = {"Up", "Down", "LookUp", "LookDown"},
    CurrentOption = {"Up"},
    MultipleOptions = false,
    Flag = "SpinbotMode",
    Callback = function(o)
        RageSettings.SpinbotMode = o[1]
    end
})

RageTab:CreateToggle({
    Name = "Silent Aim (пули в голову, камера не меняется)",
    CurrentValue = false,
    Flag = "SilentAimToggle",
    Callback = function(v)
        RageSettings.SilentAimEnabled = v
    end
})

RageTab:CreateToggle({
    Name = "Bunny Hop (Space)",
    CurrentValue = false,
    Flag = "BhopToggle",
    Callback = function(v)
        RageSettings.BhopEnabled = v
    end
})

-- Вкладка VISUALS
local VisualsTab = Window:CreateTab("👁️ Visuals", 4483362458)
VisualsTab:CreateToggle({
    Name = "ESP (имена + дистанция)",
    CurrentValue = false,
    Flag = "ESPToggle",
    Callback = function(v)
        VisualSettings.ESPEnabled = v
        if not v then clearESP() end
    end
})

-- ======== РАДУЖНЫЙ КУРСОР ========
local cursorGui = Instance.new("ScreenGui")
cursorGui.Name = "RainbowCursorGui"
cursorGui.ResetOnSpawn = false
cursorGui.Parent = PlayerGui

local cursorContainer = Instance.new("Frame")
cursorContainer.Size = UDim2.new(0, 0, 0, 0)
cursorContainer.BackgroundTransparency = 1
cursorContainer.Position = UDim2.new(0, 0, 0, 0)
cursorContainer.ZIndex = 999
cursorContainer.Parent = cursorGui

local dot = Instance.new("Frame")
dot.Size = UDim2.new(0, 10, 0, 10)
dot.Position = UDim2.new(0.5, -5, 0.5, -5)
dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
dot.BackgroundTransparency = 0
dot.BorderSizePixel = 0
dot.ZIndex = 999
dot.Parent = cursorContainer

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = dot

local cursorLabel = Instance.new("TextLabel")
cursorLabel.Size = UDim2.new(0, 200, 0, 30)
cursorLabel.Position = UDim2.new(0.5, -100, 0.5, 16)
cursorLabel.BackgroundTransparency = 1
cursorLabel.Text = "deepseek.win"
cursorLabel.TextScaled = true
cursorLabel.Font = Enum.Font.GothamBlack
cursorLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
cursorLabel.ZIndex = 999
cursorLabel.Parent = cursorContainer

UserInputService.MouseIconEnabled = false

local function updateCursorPosition()
    local mousePos = UserInputService:GetMouseLocation()
    cursorContainer.Position = UDim2.new(0, mousePos.X, 0, mousePos.Y)
end

UserInputService.InputChanged:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        updateCursorPosition()
    end
end)

RunService.RenderStepped:Connect(updateCursorPosition)

local hue = 0
RunService.RenderStepped:Connect(function()
    hue = (hue + 0.5) % 360
    local color = Color3.fromHSV(hue/360, 1, 1)
    
    cursorLabel.TextColor3 = color
    dot.BackgroundColor3 = color
    cursorLabel.Rotation = (cursorLabel.Rotation + 2) % 360
end)

-- ======== ESP (ТОЛЬКО ИГРОКИ, С ТРЕЙСЕРАМИ) ========
local espGui = Instance.new("ScreenGui")
espGui.Name = "ESPGui"
espGui.ResetOnSpawn = false
espGui.Parent = PlayerGui

function clearESP()
    for id, obj in pairs(espObjects) do
        if obj.Container then obj.Container:Destroy() end
        if obj.Highlight then obj.Highlight:Destroy() end
        if obj.Beam then obj.Beam:Destroy() end
        if obj.TargetAttachment then obj.TargetAttachment:Destroy() end
    end
    espObjects = {}
end

local function createEspLabel(player)
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(0, 255, 255)
    highlight.FillTransparency = 0.6
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    if player.Character then
        highlight.Parent = player.Character
    end

    local container = Instance.new("Frame")
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(0, 200, 0, 50)
    container.Parent = espGui
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 25)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.Code
    nameLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
    nameLabel.TextStrokeTransparency = 0.3
    nameLabel.Parent = container
    
    local healthBarBackground = Instance.new("Frame")
    healthBarBackground.Size = UDim2.new(0.6, 0, 0, 4)
    healthBarBackground.Position = UDim2.new(0.2, 0, 0.8, 0)
    healthBarBackground.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    healthBarBackground.BorderSizePixel = 0
    healthBarBackground.Parent = container

    local healthBar = Instance.new("Frame")
    healthBar.Size = UDim2.new(1, 0, 1, 0)
    healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthBar.BorderSizePixel = 0
    healthBar.Parent = healthBarBackground

    local targetAttachment = nil
    local beam = Instance.new("Beam")
    beam.FaceCamera = true
    beam.Width0 = 0.15
    beam.Width1 = 0.15
    beam.Color = ColorSequence.new(Color3.fromRGB(0, 255, 255))
    beam.Enabled = false
    beam.Parent = workspace.Terrain

    local rootPart = player.Character and (player.Character:FindFirstChild("HumanoidRootPart") or player.Character:FindFirstChild("Torso"))
    if rootPart then
        targetAttachment = Instance.new("Attachment")
        targetAttachment.Parent = rootPart
        beam.Attachment1 = targetAttachment
    end
    
    return {
        Container = container, 
        NameLabel = nameLabel, 
        HealthBar = healthBar, 
        Highlight = highlight, 
        Beam = beam,
        TargetAttachment = targetAttachment,
        Player = player
    }
end

local myAttachment = Instance.new("Attachment")
RunService.RenderStepped:Connect(function()
    local myChar = LocalPlayer.Character
    local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso"))
    if myRoot then
        myAttachment.Parent = myRoot
    else
        myAttachment.Parent = nil
    end
end)

function updateESP()
    if not VisualSettings.ESPEnabled then
        clearESP()
        return
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart") or player.Character:FindFirstChild("Torso")
            if rootPart then
                local pos, onScreen = Camera:WorldToScreenPoint(rootPart.Position)
                if onScreen then
                    if not espObjects[player.UserId] then
                        espObjects[player.UserId] = createEspLabel(player)
                    end
                    
                    local data = espObjects[player.UserId]
                    local humanoid = player.Character:FindFirstChildWhichIsA("Humanoid")
                    
                    if data.Highlight.Parent ~= player.Character then
                        data.Highlight.Parent = player.Character
                    end
                    if not data.TargetAttachment or data.TargetAttachment.Parent ~= rootPart then
                        if data.TargetAttachment then data.TargetAttachment:Destroy() end
                        data.TargetAttachment = Instance.new("Attachment")
                        data.TargetAttachment.Parent = rootPart
                        data.Beam.Attachment1 = data.TargetAttachment
                    end

                    data.Container.Visible = true
                    data.Container.Position = UDim2.new(0, pos.X - 100, 0, pos.Y - 60)
                    
                    local dist = math.floor((rootPart.Position - Camera.CFrame.Position).Magnitude)
                    local hp = humanoid and math.max(0, humanoid.Health) or 100
                    local maxHp = humanoid and (humanoid.MaxHealth > 0 and humanoid.MaxHealth or 100) or 100
                    local hpPercent = math.clamp(hp / maxHp, 0, 1)
                    
                    data.NameLabel.Text = string.format("%s\n[%dm] [%d HP]", player.Name, dist, math.floor(hp))
                    data.HealthBar.Size = UDim2.new(hpPercent, 0, 1, 0)
                    data.HealthBar.BackgroundColor3 = Color3.fromHSV(hpPercent * 0.33, 1, 1)
                    
                    if myAttachment.Parent then
                        data.Beam.Attachment0 = myAttachment
                        data.Beam.Enabled = true
                    else
                        data.Beam.Enabled = false
                    end
                else
                    if espObjects[player.UserId] then
                        espObjects[player.UserId].Container.Visible = false
                        espObjects[player.UserId].Beam.Enabled = false
                    end
                end
            end
        end
    end
    
    for id, obj in pairs(espObjects) do
        if not obj.Player or not obj.Player.Parent then
            if obj.Container then obj.Container:Destroy() end
            if obj.Highlight then obj.Highlight:Destroy() end
            if obj.Beam then obj.Beam:Destroy() end
            if obj.TargetAttachment then obj.TargetAttachment:Destroy() end
            espObjects[id] = nil
        end
    end
end

RunService.RenderStepped:Connect(updateESP)

-- ======== VISIBILITY CHECK ========
local function isVisible(headPosition)
    local cameraPos = Camera.CFrame.Position
    local direction = (headPosition - cameraPos).Unit
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    
    local result = workspace:Raycast(cameraPos, direction * 1000, raycastParams)
    
    if result then
        local hit = result.Instance
        if hit and hit:IsDescendantOf(LocalPlayer.Character) == false then
            local character = hit:FindFirstAncestorOfClass("Model")
            if character and character:FindFirstChildWhichIsA("Humanoid") then
                return true
            end
        end
        return false
    end
    return true
end

-- ======== AIMBOT (ТОЛЬКО ИГРОКИ, ГОЛОВА) ========
local function getClosestVisibleTarget()
    local closest = nil
    local shortestDistance = math.huge
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            if head then
                local headPos = head.Position
                if isVisible(headPos) then
                    local pos, onScreen = Camera:WorldToScreenPoint(headPos)
                    if onScreen then
                        local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                        if distance < shortestDistance then
                            shortestDistance = distance
                            closest = player
                        end
                    end
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if VisualSettings.AimbotEnabled then
        local target = getClosestVisibleTarget()
        if target and target.Character then
            local head = target.Character:FindFirstChild("Head")
            if head then
                local targetPos = head.Position
                local lookAt = CFrame.new(Camera.CFrame.Position, targetPos)
                Camera.CFrame = Camera.CFrame:Lerp(lookAt, VisualSettings.AimbotSensitivity)
            end
        end
    end
end)

-- ======== TOGGLE X ========
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.X then
        VisualSettings.AimbotEnabled = not VisualSettings.AimbotEnabled
        Rayfield:Notify({
            Title = "Aimbot",
            Content = VisualSettings.AimbotEnabled and "🔴 ВКЛЮЧЕН (только игроки)" or "⚫ ВЫКЛЮЧЕН",
            Duration = 2,
        })
    end
end)

-- ======== RAGE: SPINBOT (БЕЗ ИЗМЕНЕНИЯ КАМЕРЫ) ========
local function getCharacterRoot()
    local char = LocalPlayer.Character
    if char then
        return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
    end
    return nil
end

RunService.RenderStepped:Connect(function()
    if not RageSettings.SpinbotEnabled then return end
    
    local root = getCharacterRoot()
    if not root then return end
    
    if RageSettings.SpinbotMode == "Up" then
        root.CFrame = root.CFrame * CFrame.Angles(math.rad(5), 0, 0)
    elseif RageSettings.SpinbotMode == "Down" then
        root.CFrame = root.CFrame * CFrame.Angles(math.rad(-5), 0, 0)
    elseif RageSettings.SpinbotMode == "LookUp" then
        root.CFrame = CFrame.new(root.Position) * CFrame.Angles(math.rad(-85), 0, 0)
    elseif RageSettings.SpinbotMode == "LookDown" then
        root.CFrame = CFrame.new(root.Position) * CFrame.Angles(math.rad(85), 0, 0)
    end
end)

-- ======== RAGE: SILENT AIM (ПУЛИ В ГОЛОВУ, КАМЕРА НЕ МЕНЯЕТСЯ) ========
-- В Roblox Silent Aim реализуется через перехват выстрелов.
-- Это демонстрационная структура, так как полная реализация требует глубокого хука.
-- Добавляем функцию, которая будет вызываться при выстреле.
local function silentAimFire()
    if not RageSettings.SilentAimEnabled then return end
    
    local target = getClosestVisibleTarget()
    if target and target.Character then
        local head = target.Character:FindFirstChild("Head")
        if head then
            -- В реальном скрипте здесь происходит перенаправление пули.
            -- Для демонстрации просто выводим в консоль.
            print("[Silent Aim] Цель: " .. target.Name)
        end
    end
end

-- ======== RAGE: BUNNY HOP ========
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if RageSettings.BhopEnabled and input.KeyCode == Enum.KeyCode.Space then
        local char = LocalPlayer.Character
        if char then
            local humanoid = char:FindFirstChildWhichIsA("Humanoid")
            if humanoid and humanoid.FloorMaterial ~= Enum.Material.Air then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

-- ======== NOCLIP ========
local function enableNoclip(duration)
    local character = LocalPlayer.Character
    if not character then return end
    
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
    
    task.wait(duration)
    
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
        end
    end
end

-- ======== FLING ========
local function cleanup()
    isFlinging = false
    for _, conn in ipairs(connections) do
        if conn and conn.Connected then
            conn:Disconnect()
        end
    end
    connections = {}
end

local function setupCharacter(character)
    cleanup()
    
    local humanoid = character:WaitForChild("Humanoid", 5)
    local root = character:WaitForChild("HumanoidRootPart", 5)
    local head = character:WaitForChild("Head", 5)

    if not (humanoid and root and head) then
        return
    end

    local function createWhiteFlash()
        local gui = PlayerGui:FindFirstChild("FlingFlashGui")
        if gui then gui:Destroy() end

        gui = Instance.new("ScreenGui")
        gui.Name = "FlingFlashGui"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.DisplayOrder = 200
        gui.Parent = PlayerGui

        local whiteFlash = Instance.new("Frame")
        whiteFlash.Size = UDim2.new(1, 0, 1, 0)
        whiteFlash.BackgroundColor3 = Color3.new(1, 1, 1)
        whiteFlash.BackgroundTransparency = 0.35
        whiteFlash.Visible = true
        whiteFlash.Parent = gui
        
        task.wait(Settings.FlashDuration)
        gui:Destroy()
    end

    local function launchUp(rj)
        local upPower = math.random(Settings.MinLaunchPower, Settings.MaxLaunchPower)
        root.AssemblyLinearVelocity = Vector3.new(0, upPower * Settings.VerticalPower, 0)
        
        local upConn = RunService.Heartbeat:Connect(function()
            if not character.Parent or not root then return end
            root.AssemblyLinearVelocity = Vector3.new(0, upPower * Settings.VerticalPower, 0)
        end)
        table.insert(connections, upConn)
        
        task.wait(Settings.DiagonalDuration)
        upConn:Disconnect()
        table.remove(connections, #connections)
    end

    local function launchDiagonal(rj)
        local diagonalPower = Settings.DiagonalPower
        local angle = math.rad(45)
        local diagX = math.cos(angle) * diagonalPower
        local diagY = math.sin(angle) * diagonalPower * Settings.VerticalPower
        local diagZ = math.sin(angle) * diagonalPower
        
        root.AssemblyLinearVelocity = Vector3.new(diagX, diagY, diagZ)
        
        local diagConn = RunService.Heartbeat:Connect(function()
            if not character.Parent or not root then return end
            root.AssemblyLinearVelocity = Vector3.new(diagX, diagY, diagZ)
        end)
        table.insert(connections, diagConn)
        
        task.wait(Settings.DiagonalDuration)
        diagConn:Disconnect()
        table.remove(connections, #connections)
    end

    local function launchBounce(rj)
        local elapsed = 0
        local bounceInterval = 0.2

        local bounceConn = RunService.Heartbeat:Connect(function(delta)
            if not character.Parent or not root then return end
            
            elapsed = elapsed + delta
            
            if elapsed >= bounceInterval then
                elapsed = 0
                
                local randAngleX = math.rad(math.random(20, 70))
                local randAngleY = math.rad(math.random(0, 360))
                
                local bX = math.sin(randAngleY) * math.cos(randAngleX) * Settings.DiagonalPower * Settings.BounceIntensity
                local bY = math.sin(randAngleX) * Settings.DiagonalPower * Settings.VerticalPower * Settings.BounceIntensity
                local bZ = math.cos(randAngleY) * math.cos(randAngleX) * Settings.DiagonalPower * Settings.BounceIntensity
                
                root.AssemblyLinearVelocity = Vector3.new(bX, bY, bZ)
            end
        end)
        table.insert(connections, bounceConn)
        
        task.wait(Settings.DiagonalDuration)
        bounceConn:Disconnect()
        table.remove(connections, #connections)
    end

    local function attemptFling()
        if not Settings.FlingEnabled then
            return
        end

        if isFlinging then
            return
        end

        if Settings.CooldownEnabled and cooldown then
            return
        end
        
        if not root or not humanoid or humanoid.Health <= 0 or not root.Parent then
            return
        end
        
        isFlinging = true
        
        if Settings.CooldownEnabled then
            cooldown = true
        end
        
        root.Anchored = true
        humanoid.PlatformStand = true
        humanoid.AutoRotate = false
        humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
        
        local rj = root:FindFirstChild("RootJoint")
        if rj then
            local randRx = math.rad(math.random(0, 360))
            local randRy = math.rad(math.random(0, 360))
            local randRz = math.rad(math.random(0, 360))
            rj.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(randRx, randRy, randRz)
        end
        
        createWhiteFlash()
        root.Anchored = false
        
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
        
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        
        local rx, ry, rz = math.rad(math.random(0, 360)), math.rad(math.random(0, 360)), math.rad(math.random(0, 360))
        
        local spinConn = RunService.RenderStepped:Connect(function(dt)
            if not character.Parent then return end
            rx += Settings.SpinSpeed * dt
            ry += (Settings.SpinSpeed * 0.87) * dt
            rz += (Settings.SpinSpeed * 0.95) * dt
            
            if rj then
                rj.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(rx, ry, rz)
            end
        end)
        table.insert(connections, spinConn)
        
        if Settings.LaunchDirection == "Up" then
            launchUp(rj)
        elseif Settings.LaunchDirection == "Diagonal" then
            launchDiagonal(rj)
        elseif Settings.LaunchDirection == "Bounce" then
            launchBounce(rj)
        end
        
        task.wait(0.3)
        spinConn:Disconnect()
        
        if rj then
            rj.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(-math.pi/2, 0, math.pi)
        end
        
        root.Anchored = false
        humanoid.PlatformStand = false
        humanoid.AutoRotate = true
        isFlinging = false
        
        enableNoclip(Settings.NoclipDuration)
        
        if Settings.CooldownEnabled then
            task.wait(Settings.CooldownDuration)
            cooldown = false
        end
    end

    local inputConn = UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.F then
            attemptFling()
        end
    end)
    table.insert(connections, inputConn)
end

-- ======== ЗАПУСК ========
if LocalPlayer.Character then
    setupCharacter(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(function(character)
    setupCharacter(character)
end)

LocalPlayer.CharacterRemoving:Connect(cleanup)

-- ======== СТРИМ-ЧАТ ========
task.wait(2)

local chatGui = Instance.new("ScreenGui")
chatGui.Name = "StreamChat"
chatGui.ResetOnSpawn = false
chatGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local chatFrame = Instance.new("Frame")
chatFrame.Size = UDim2.new(0, 575, 0, 400)
chatFrame.Position = UDim2.new(1, -590, 1, -415)
chatFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
chatFrame.BackgroundTransparency = 0.5
chatFrame.BorderSizePixel = 1
chatFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
chatFrame.Parent = chatGui

local chatContainer = Instance.new("Frame")
chatContainer.Size = UDim2.new(1, -5, 1, -5)
chatContainer.Position = UDim2.new(0, 3, 0, 3)
chatContainer.BackgroundTransparency = 1
chatContainer.Parent = chatFrame

local chatLayout = Instance.new("UIListLayout")
chatLayout.SortOrder = Enum.SortOrder.LayoutOrder
chatLayout.Padding = UDim.new(0, 2)
chatLayout.Parent = chatContainer

local function randomNick()
    local prefixes = {"xX_", "XX_", "Pro", "Noob", "Sniper", "Killer", "Dark", "Shadow", "Legen", "Master", "Speed", "Dragon", "Cyber", "Blaze", "Storm"}
    local middles = {"Skeet", "Snipe", "Fury", "Cobra", "Raven", "Phoenix", "Titan", "Viper", "Wolf", "Hawk", "Flash", "Ghost", "Hunter", "Reaper", "Devil"}
    local suffixes = {"_Xx", "_XX", "Xx", "X", "22", "69", "420", "1337", "007", "666", "777", "999", "03", "04", "05", "06", "07"}
    
    local name = ""
    if math.random() > 0.5 then
        name = prefixes[math.random(#prefixes)] .. middles[math.random(#middles)]
    else
        name = middles[math.random(#middles)] .. suffixes[math.random(#suffixes)]
    end
    
    if math.random() > 0.6 then
        name = name .. math.random(10, 99)
    end
    
    return name
end

local chatMessages = {
    "SKEET SKEET N1 CHEAT",
    "1",
    "sit nn dog",
    "deepseek.win penit",
    "when spinbot?",
    "ezlol",
    "LMAOOO",
    "GOAT",
    "BOT",
    "FREE",
    "BANNED?",
    "WTF",
    "HAX",
    "CRAZY",
    "SUS",
    "AIMBOT?",
    "REPORTED",
    "LOL",
    "GET REKT",
    "HACKER"
}

local function addChatMessage(nick, text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = nick .. ": " .. text
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = chatContainer
    
    local children = chatContainer:GetChildren()
    if #children > 15 then
        for i = 1, #children - 15 do
            children[i]:Destroy()
        end
    end
end

local initialMessages = {
    {nick = "SKEET_SN1PER", text = "SKEET SKEET N1 CHEAT"},
    {nick = "xX_D3M0N_Xx", text = "1"},
    {nick = "NoobMaster69", text = "sit nn dog"},
    {nick = "deepseek_win", text = "deepseek.win penit"},
    {nick = "ProHacker1337", text = "when spinbot?"},
    {nick = "K1ll3r_007", text = "ezlol"}
}

for i, msg in ipairs(initialMessages) do
    task.wait((i - 1) * 1.2)
    addChatMessage(msg.nick, msg.text)
end

task.spawn(function()
    while true do
        task.wait(math.random(6, 15))
        local nick = randomNick()
        local msg = chatMessages[math.random(#chatMessages)]
        addChatMessage(nick, msg)
    end
end)

Rayfield:Notify({
    Title = "GNG Ultimate",
    Content = "F - Fling | X - Aimbot | Insert - Menu",
    Duration = 5,
    Image = 4483362458,
})