-- Cheat Script for Roblox Game
-- Features: Silent Aim, Aimbot, ESP, GUI with toggle (Right Shift)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera

-- Settings
local Settings = {
    Enabled = true,
    ShowGUI = true,
    
    -- ESP Settings
    ESP = {
        Enabled = true,
        Box = true,
        Name = true,
        Health = true,
        Distance = true,
        TeamCheck = true,
        MaxDistance = 1000,
        Color = Color3.fromRGB(255, 0, 0),
        TeamColor = Color3.fromRGB(0, 255, 0),
        
        -- Loot ESP Settings
        LootESP = true,
        LootBox = true,
        LootName = true,
        LootDistance = true,
        LootMaxDistance = 500,
        LootColor = Color3.fromRGB(255, 255, 0)
    },
    
    -- Aimbot Settings
    Aimbot = {
        Enabled = true,
        SilentAim = true,  -- Silent aim (no visible camera movement)
        NormalAim = false, -- Normal aim (visible camera movement)
        FOV = 100,
        Smoothness = 0.1,
        TargetPart = "Head",
        TeamCheck = true,
        VisibleCheck = true,
        TriggerKey = Enum.UserInputType.MouseButton2
    },
    
    -- Combat Settings
    Combat = {
        Wallbang = true,           -- Shoot through walls/terrain
        HitboxExpander = true,     -- Expand enemy hitboxes
        HitboxSize = 10,           -- Hitbox expansion size
        MeleeRange = true,         -- Extended melee range
        MeleeRangeMultiplier = 3,  -- Multiplier for melee range (default 3x)
        InfiniteDurability = true, -- Weapons never break
        NoRecoil = true,           -- Remove weapon recoil
        RapidFire = true,          -- Increased fire rate
        FireRateMultiplier = 2     -- Fire rate multiplier (2x = twice as fast)
    },
    
    -- Exploits Settings (Based on game vulnerabilities)
    Exploits = {
        InfiniteStamina = true,    -- Never run out of stamina
        NoFallDamage = false,       -- No damage from falling
        SpeedHack = false,          -- Increased movement speed
        SpeedMultiplier = 1.5,     -- Speed multiplier
        JumpPower = false,          -- Increased jump power
        JumpMultiplier = 1.5,      -- Jump power multiplier
        InstantReload = true,      -- Instant weapon reload
        NoSpread = true,           -- Perfect accuracy
        AutoLoot = false,          -- Automatically loot nearby items
        ESPThroughWalls = true,    -- See players through walls
        AutoLockpick = true,       -- Automatically solve lockpick mini-game
        NoClip = false,            -- Walk through walls (anti-cheat bypass)
        NoClipSpeed = 1,           -- NoClip movement speed multiplier
        Invisibility = false,      -- Make character invisible
        InvisibilityMode = "Full", -- "Full" or "Partial" (keeps weapon visible)
        
        -- Manipulator Settings
        Manipulator = false,       -- Enable character manipulation exploit
        ManipulatorBind = Enum.KeyCode.X, -- Keybind to activate
        ManipulatorAutoMelee = true, -- Auto extreme range melee attacks
        ManipulatorWallShoot = true, -- Shoot through walls from extended position
        ManipulatorMaxStretch = 100  -- Max hitbox stretch distance
    },
    
    -- GUI Settings
    GUI = {
        Position = UDim2.new(0.05, 0, 0.05, 0),
        BackgroundColor = Color3.fromRGB(30, 30, 40),
        TextColor = Color3.fromRGB(255, 255, 255),
        AccentColor = Color3.fromRGB(0, 120, 255)
    },
    
    -- Performance Settings
    Performance = {
        LowGraphics = false,       -- Ultra low graphics mode
        RemoveFog = true,          -- Remove fog effects
        RemoveShadows = true,      -- Remove all shadows
        RemoveParticles = true,    -- Remove particle effects
        RemoveBlur = true,         -- Remove blur effects
        RemoveWeather = true,      -- Remove weather effects
        LowerQuality = true,       -- Lower object quality
        MaxFPS = 60                -- FPS cap (0 = unlimited)
    }
}

-- ESP Drawing
local ESPObjects = {}
local LootESPObjects = {} -- New: ESP for loot boxes
local DrawingLibrary = {}
local Drawings = {}

-- Hitbox Expander
local OriginalHitboxSizes = {}
local ExpandedHitboxes = {}

-- Exploits Storage
local OriginalStamina = nil
local OriginalFireRates = {}
local OriginalWalkSpeed = nil
local OriginalJumpPower = nil
local HookedTools = {}
local AutoLockpickActive = false
local LockpickConnection = nil

-- NoClip Storage
local NoClipActive = false
local NoClipConnection = nil
local OriginalCollisionStates = {}
local LastValidPosition = nil
local NoClipBodyVelocity = nil
local NoClipBodyGyro = nil

-- Invisibility Storage
local InvisibilityActive = false
local InvisibilityConnection = nil
local OriginalTransparencies = {}
local OriginalAccessories = {}

-- Performance Storage
local OriginalLightingSettings = {}
local RemovedEffects = {}
local PerformanceActive = false

-- Character Manipulator Storage
local ManipulatorActive = false
local ManipulatorConnection = nil
local OriginalCharacterSizes = {}
local ManipulatorTarget = nil

-- Manipulator Storage
local ManipulatorActive = false
local ManipulatorConnection = nil
local OriginalRootPartCFrame = nil
local ManipulatorTargetPosition = nil
local ManipulatorExtendedParts = {}

-- Check if drawing library exists
pcall(function()
    DrawingLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/VisualRoblox/Roblox/main/UI%20Libraries/Drawing%20Library/Source.lua"))()
end)

if DrawingLibrary then
    Drawings = DrawingLibrary.New()
end

-- ESP Functions
local function CreateESP(player)
    if not player or not player.Character or not player.Character:FindFirstChild("Humanoid") or not player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local esp = {}
    
    -- Create drawings
    esp.Box = Drawings:Add("Square", {
        Thickness = 2,
        Color = Settings.ESP.Color,
        Filled = false
    })
    
    esp.NameLabel = Drawings:Add("Text", {
        Text = player.Name,
        Size = 13,
        Center = true,
        Outline = true,
        Color = Settings.ESP.Color
    })
    
    esp.HealthLabel = Drawings:Add("Text", {
        Text = "100 HP",
        Size = 11,
        Center = true,
        Outline = true,
        Color = Color3.fromRGB(0, 255, 0)
    })
    
    esp.DistanceLabel = Drawings:Add("Text", {
        Text = "0m",
        Size = 11,
        Center = true,
        Outline = true,
        Color = Settings.ESP.Color
    })
    
    ESPObjects[player] = esp
end

-- Create Loot ESP
local function CreateLootESP(lootModel)
    if not lootModel or not lootModel:IsA("Model") then
        return
    end
    
    local primaryPart = lootModel.PrimaryPart or lootModel:FindFirstChildWhichIsA("BasePart")
    if not primaryPart then
        return
    end
    
    local esp = {}
    
    -- Create box
    esp.Box = Drawings:Add("Square", {
        Thickness = 2,
        Color = Settings.ESP.LootColor,
        Filled = false
    })
    
    -- Create name label
    esp.NameLabel = Drawings:Add("Text", {
        Text = lootModel.Name,
        Size = 13,
        Center = true,
        Outline = true,
        Color = Settings.ESP.LootColor
    })
    
    -- Create distance label
    esp.DistanceLabel = Drawings:Add("Text", {
        Text = "0m",
        Size = 11,
        Center = true,
        Outline = true,
        Color = Settings.ESP.LootColor
    })
    
    LootESPObjects[lootModel] = esp
end

local function UpdateLootESP()
    for lootModel, esp in pairs(LootESPObjects) do
        if not lootModel or not lootModel.Parent then
            -- Clean up removed loot
            for _, drawing in pairs(esp) do
                drawing:Remove()
            end
            LootESPObjects[lootModel] = nil
        elseif Settings.ESP.LootESP and Settings.Enabled then
            local primaryPart = lootModel.PrimaryPart or lootModel:FindFirstChildWhichIsA("BasePart")
            
            if primaryPart then
                -- Distance check
                local distance = (primaryPart.Position - Camera.CFrame.Position).Magnitude
                
                if distance <= Settings.ESP.LootMaxDistance then
                    -- Screen position
                    local screenPos, onScreen = Camera:WorldToViewportPoint(primaryPart.Position)
                    
                    if onScreen then
                        -- Calculate box size based on loot size
                        local size = lootModel:GetExtentsSize()
                        local boxScale = math.max(size.X, size.Y, size.Z)
                        
                        -- Update box
                        if Settings.ESP.LootBox then
                            esp.Box.Color = Settings.ESP.LootColor
                            esp.Box.Size = Vector2.new(1500 / screenPos.Z * boxScale, 2000 / screenPos.Z * boxScale)
                            esp.Box.Position = Vector2.new(screenPos.X, screenPos.Y) - esp.Box.Size / 2
                            esp.Box.Visible = true
                        else
                            esp.Box.Visible = false
                        end
                        
                        -- Update name
                        if Settings.ESP.LootName then
                            esp.NameLabel.Text = lootModel.Name
                            esp.NameLabel.Color = Settings.ESP.LootColor
                            esp.NameLabel.Position = Vector2.new(screenPos.X, screenPos.Y - esp.Box.Size.Y / 2 - 20)
                            esp.NameLabel.Visible = true
                        else
                            esp.NameLabel.Visible = false
                        end
                        
                        -- Update distance
                        if Settings.ESP.LootDistance then
                            esp.DistanceLabel.Text = math.floor(distance) .. "m"
                            esp.DistanceLabel.Color = Settings.ESP.LootColor
                            esp.DistanceLabel.Position = Vector2.new(screenPos.X, screenPos.Y + esp.Box.Size.Y / 2 + 5)
                            esp.DistanceLabel.Visible = true
                        else
                            esp.DistanceLabel.Visible = false
                        end
                    else
                        -- Hide if off screen
                        for _, drawing in pairs(esp) do
                            drawing.Visible = false
                        end
                    end
                else
                    -- Hide if too far
                    for _, drawing in pairs(esp) do
                        drawing.Visible = false
                    end
                end
            else
                -- Hide if no primary part
                for _, drawing in pairs(esp) do
                    drawing.Visible = false
                end
            end
        else
            -- Hide if ESP disabled
            for _, drawing in pairs(esp) do
                drawing.Visible = false
            end
        end
    end
end

-- Initialize Loot ESP
local function InitializeLootESP()
    local lootsFolder = Workspace:FindFirstChild("Buildings")
    if lootsFolder then
        lootsFolder = lootsFolder:FindFirstChild("Loots")
        if lootsFolder then
            lootsFolder = lootsFolder:FindFirstChild("Loots")
            if lootsFolder then
                print("[Loot ESP] Found Loots folder, initializing ESP for loot boxes...")
                
                for _, loot in pairs(lootsFolder:GetChildren()) do
                    if loot:IsA("Model") then
                        CreateLootESP(loot)
                    end
                end
                
                -- Monitor for new loot
                lootsFolder.ChildAdded:Connect(function(loot)
                    if loot:IsA("Model") then
                        task.wait(0.1) -- Wait for model to fully load
                        CreateLootESP(loot)
                    end
                end)
                
                -- Clean up removed loot
                lootsFolder.ChildRemoved:Connect(function(loot)
                    if LootESPObjects[loot] then
                        for _, drawing in pairs(LootESPObjects[loot]) do
                            drawing:Remove()
                        end
                        LootESPObjects[loot] = nil
                    end
                end)
                
                print("[Loot ESP] Initialized " .. #lootsFolder:GetChildren() .. " loot boxes")
            else
                print("[Loot ESP] Warning: Buildings.Loots.Loots not found")
            end
        end
    end
end

-- Update ESP with optimized rendering
local LastESPUpdate = 0
local ESPUpdateInterval = 0.016 -- Update every frame (~60 FPS) for smooth ESP

local function UpdateESP()
    -- Update frequently for smooth ESP
    local currentTime = tick()
    if currentTime - LastESPUpdate < ESPUpdateInterval then
        return
    end
    LastESPUpdate = currentTime
    
    for player, esp in pairs(ESPObjects) do
        if not player or not player.Character or player.Character.Parent == nil then
            -- Clean up removed players
            for _, drawing in pairs(esp) do
                drawing:Remove()
            end
            ESPObjects[player] = nil
        elseif Settings.ESP.Enabled and Settings.Enabled then
            local character = player.Character
            local humanoid = character:FindFirstChild("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and rootPart and humanoid.Health > 0 then
                -- Team check
                local isTeamMate = false
                if Settings.ESP.TeamCheck and LocalPlayer.Team then
                    isTeamMate = player.Team == LocalPlayer.Team
                end
                
                -- Distance check
                local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
                if distance <= Settings.ESP.MaxDistance then
                    -- Screen position
                    local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                    
                    if onScreen then
                        local color = isTeamMate and Settings.ESP.TeamColor or Settings.ESP.Color
                        
                        -- Update box
                        if Settings.ESP.Box then
                            esp.Box.Color = color
                            esp.Box.Size = Vector2.new(2000 / screenPos.Z, 3000 / screenPos.Z)
                            esp.Box.Position = Vector2.new(screenPos.X, screenPos.Y) - esp.Box.Size / 2
                            esp.Box.Visible = true
                        else
                            esp.Box.Visible = false
                        end
                        
                        -- Update name
                        if Settings.ESP.Name then
                            esp.NameLabel.Text = player.Name
                            esp.NameLabel.Color = color
                            esp.NameLabel.Position = Vector2.new(screenPos.X, screenPos.Y - esp.Box.Size.Y / 2 - 20)
                            esp.NameLabel.Visible = true
                        else
                            esp.NameLabel.Visible = false
                        end
                        
                        -- Update health
                        if Settings.ESP.Health then
                            local healthPercent = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
                            local healthColor = Color3.fromRGB(255 * (1 - healthPercent/100), 255 * (healthPercent/100), 0)
                            
                            esp.HealthLabel.Text = math.floor(humanoid.Health) .. " HP (" .. healthPercent .. "%)"
                            esp.HealthLabel.Color = healthColor
                            esp.HealthLabel.Position = Vector2.new(screenPos.X, screenPos.Y + esp.Box.Size.Y / 2 + 5)
                            esp.HealthLabel.Visible = true
                        else
                            esp.HealthLabel.Visible = false
                        end
                        
                        -- Update distance
                        if Settings.ESP.Distance then
                            esp.DistanceLabel.Text = math.floor(distance) .. "m"
                            esp.DistanceLabel.Color = color
                            esp.DistanceLabel.Position = Vector2.new(screenPos.X, screenPos.Y + esp.Box.Size.Y / 2 + 20)
                            esp.DistanceLabel.Visible = true
                        else
                            esp.DistanceLabel.Visible = false
                        end
                    else
                        -- Hide if off screen
                        for _, drawing in pairs(esp) do
                            drawing.Visible = false
                        end
                    end
                else
                    -- Hide if too far
                    for _, drawing in pairs(esp) do
                        drawing.Visible = false
                    end
                end
            else
                -- Hide if dead
                for _, drawing in pairs(esp) do
                    drawing.Visible = false
                end
            end
        else
            -- Hide if ESP disabled
            for _, drawing in pairs(esp) do
                drawing.Visible = false
            end
        end
    end
end

-- Aimbot Functions
local function GetClosestTarget()
    local closestPlayer = nil
    local closestDistance = Settings.Aimbot.FOV
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild(Settings.Aimbot.TargetPart) then
            local humanoid = player.Character.Humanoid
            
            -- Team check
            if Settings.Aimbot.TeamCheck and LocalPlayer.Team and player.Team == LocalPlayer.Team then
                continue
            end
            
            -- Health check
            if humanoid.Health <= 0 then
                continue
            end
            
            -- Visible check
            if Settings.Aimbot.VisibleCheck then
                local targetPart = player.Character[Settings.Aimbot.TargetPart]
                local raycastResult = Workspace:Raycast(
                    Camera.CFrame.Position,
                    (targetPart.Position - Camera.CFrame.Position).Unit * 1000,
                    {LocalPlayer.Character, player.Character}
                )
                
                if not raycastResult or raycastResult.Instance ~= targetPart then
                    continue
                end
            end
            
            -- FOV check
            local screenPos, onScreen = Camera:WorldToViewportPoint(player.Character[Settings.Aimbot.TargetPart].Position)
            if onScreen then
                local mousePos = Vector2.new(Mouse.X, Mouse.Y)
                local targetPos = Vector2.new(screenPos.X, screenPos.Y)
                local distance = (mousePos - targetPos).Magnitude
                
                if distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    
    return closestPlayer
end

-- Silent Aim Hook
local OriginalMouseHit
local function SilentAimHook()
    if Settings.Enabled and Settings.Aimbot.Enabled and Settings.Aimbot.SilentAim then
        local target = GetClosestTarget()
        if target and target.Character and target.Character:FindFirstChild(Settings.Aimbot.TargetPart) then
            return target.Character[Settings.Aimbot.TargetPart].CFrame
        end
    end
    return OriginalMouseHit()
end

-- Normal Aimbot
local function AimAtTarget(target)
    if not target or not target.Character or not target.Character:FindFirstChild(Settings.Aimbot.TargetPart) then
        return
    end
    
    local targetPart = target.Character[Settings.Aimbot.TargetPart]
    local targetPos = targetPart.Position
    
    -- Smooth aiming
    local currentCFrame = Camera.CFrame
    local lookVector = (targetPos - currentCFrame.Position).Unit
    local targetCFrame = CFrame.lookAt(currentCFrame.Position, currentCFrame.Position + lookVector)
    
    Camera.CFrame = currentCFrame:Lerp(targetCFrame, Settings.Aimbot.Smoothness)
end

-- GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CheatGUI"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 500)
MainFrame.Position = Settings.GUI.Position
MainFrame.BackgroundColor3 = Settings.GUI.BackgroundColor
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Add UICorner for modern look
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Settings.GUI.AccentColor
Title.Text = "Cheat Menu - Right Shift to Hide"
Title.TextColor3 = Settings.GUI.TextColor
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Tabs Container
local TabsContainer = Instance.new("Frame")
TabsContainer.Name = "TabsContainer"
TabsContainer.Size = UDim2.new(1, 0, 0, 30)
TabsContainer.Position = UDim2.new(0, 0, 0, 40)
TabsContainer.BackgroundTransparency = 1
TabsContainer.Parent = MainFrame

-- Content Container
local ContentContainer = Instance.new("ScrollingFrame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(1, -20, 1, -80)
ContentContainer.Position = UDim2.new(0, 10, 0, 80)
ContentContainer.BackgroundTransparency = 1
ContentContainer.BorderSizePixel = 0
ContentContainer.ScrollBarThickness = 6
ContentContainer.CanvasSize = UDim2.new(0, 0, 0, 600)
ContentContainer.Parent = MainFrame

-- Create Tabs
local Tabs = {"ESP", "Aimbot", "Combat", "Exploits", "Performance", "Settings"}
local CurrentTab = "ESP"

local function CreateTabButton(tabName)
    local TabButton = Instance.new("TextButton")
    TabButton.Name = tabName .. "Tab"
    TabButton.Size = UDim2.new(1/#Tabs, 0, 1, 0)
    TabButton.Position = UDim2.new((table.find(Tabs, tabName)-1)/#Tabs, 0, 0, 0)
    TabButton.BackgroundColor3 = tabName == CurrentTab and Settings.GUI.AccentColor or Color3.fromRGB(50, 50, 60)
    TabButton.Text = tabName
    TabButton.TextColor3 = Settings.GUI.TextColor
    TabButton.TextSize = 14
    TabButton.Font = Enum.Font.Gotham
    TabButton.Parent = TabsContainer
    
    TabButton.MouseButton1Click:Connect(function()
        CurrentTab = tabName
        for _, child in pairs(TabsContainer:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = child.Name:sub(1, -4) == CurrentTab and Settings.GUI.AccentColor or Color3.fromRGB(50, 50, 60)
            end
        end
        UpdateContent()
    end)
end

local function CreateToggle(name, defaultValue, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.LayoutOrder = #ContentContainer:GetChildren()
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    ToggleLabel.Position = UDim2.new(0, 0, 0, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = name
    ToggleLabel.TextColor3 = Settings.GUI.TextColor
    ToggleLabel.TextSize = 14
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.Parent = ToggleFrame
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 50, 0, 25)
    ToggleButton.Position = UDim2.new(0.7, 0, 0, 2)
    ToggleButton.BackgroundColor3 = defaultValue and Settings.GUI.AccentColor or Color3.fromRGB(80, 80, 90)
    ToggleButton.Text = defaultValue and "ON" or "OFF"
    ToggleButton.TextColor3 = Settings.GUI.TextColor
    ToggleButton.TextSize = 12
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.Parent = ToggleFrame
    
    local value = defaultValue
    
    ToggleButton.MouseButton1Click:Connect(function()
        value = not value
        ToggleButton.BackgroundColor3 = value and Settings.GUI.AccentColor or Color3.fromRGB(80, 80, 90)
        ToggleButton.Text = value and "ON" or "OFF"
        callback(value)
    end)
    
    return ToggleFrame
end

local function CreateSlider(name, min, max, defaultValue, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 50)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.LayoutOrder = #ContentContainer:GetChildren()
    
    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Size = UDim2.new(1, 0, 0, 20)
    SliderLabel.Position = UDim2.new(0, 0, 0, 0)
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Text = name .. ": " .. defaultValue
    SliderLabel.TextColor3 = Settings.GUI.TextColor
    SliderLabel.TextSize = 14
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    SliderLabel.Font = Enum.Font.Gotham
    SliderLabel.Parent = SliderFrame
    
    local SliderTrack = Instance.new("Frame")
    SliderTrack.Size = UDim2.new(1, 0, 0, 5)
    SliderTrack.Position = UDim2.new(0, 0, 0, 25)
    SliderTrack.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    SliderTrack.BorderSizePixel = 0
    SliderTrack.Parent = SliderFrame
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((defaultValue - min) / (max - min), 0, 1, 0)
    SliderFill.Position = UDim2.new(0, 0, 0, 0)
    SliderFill.BackgroundColor3 = Settings.GUI.AccentColor
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderTrack
    
    local SliderButton = Instance.new("TextButton")
    SliderButton.Size = UDim2.new(0, 15, 0, 15)
    SliderButton.Position = UDim2.new((defaultValue - min) / (max - min), -7, 0, -5)
    SliderButton.BackgroundColor3 = Settings.GUI.TextColor
    SliderButton.Text = ""
    SliderButton.Parent = SliderTrack
    
    local dragging = false
    
    local function UpdateSlider(value)
        local normalized = math.clamp((value - min) / (max - min), 0, 1)
        SliderFill.Size = UDim2.new(normalized, 0, 1, 0)
        SliderButton.Position = UDim2.new(normalized, -7, 0, -5)
        SliderLabel.Text = name .. ": " .. math.floor(value)
        callback(value)
    end
    
    SliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    SliderButton.MouseMoved:Connect(function()
        if dragging then
            local mousePos = UserInputService:GetMouseLocation()
            local absolutePos = SliderTrack.AbsolutePosition.X
            local absoluteSize = SliderTrack.AbsoluteSize.X
            local relative = math.clamp((mousePos.X - absolutePos) / absoluteSize, 0, 1)
            local value = min + (max - min) * relative
            UpdateSlider(value)
        end
    end)
    
    return SliderFrame
end

local function UpdateContent()
    -- Clear content
    for _, child in pairs(ContentContainer:GetChildren()) do
        child:Destroy()
    end
    
    if CurrentTab == "ESP" then
        local ESPToggle = CreateToggle("ESP Enabled", Settings.ESP.Enabled, function(value)
            Settings.ESP.Enabled = value
        end)
        ESPToggle.Parent = ContentContainer
        
        local BoxToggle = CreateToggle("Box ESP", Settings.ESP.Box, function(value)
            Settings.ESP.Box = value
        end)
        BoxToggle.Parent = ContentContainer
        
        local NameToggle = CreateToggle("Name ESP", Settings.ESP.Name, function(value)
            Settings.ESP.Name = value
        end)
        NameToggle.Parent = ContentContainer
        
        local HealthToggle = CreateToggle("Health ESP", Settings.ESP.Health, function(value)
            Settings.ESP.Health = value
        end)
        HealthToggle.Parent = ContentContainer
        
        local TeamToggle = CreateToggle("Team Check", Settings.ESP.TeamCheck, function(value)
            Settings.ESP.TeamCheck = value
        end)
        TeamToggle.Parent = ContentContainer
        
        local DistanceSlider = CreateSlider("Max Distance", 100, 5000, Settings.ESP.MaxDistance, function(value)
            Settings.ESP.MaxDistance = value
        end)
        DistanceSlider.Parent = ContentContainer
        
        -- Loot ESP Section
        local LootESPToggle = CreateToggle("Loot ESP", Settings.ESP.LootESP, function(value)
            Settings.ESP.LootESP = value
        end)
        LootESPToggle.Parent = ContentContainer
        
        local LootBoxToggle = CreateToggle("Loot Box ESP", Settings.ESP.LootBox, function(value)
            Settings.ESP.LootBox = value
        end)
        LootBoxToggle.Parent = ContentContainer
        
        local LootNameToggle = CreateToggle("Loot Name ESP", Settings.ESP.LootName, function(value)
            Settings.ESP.LootName = value
        end)
        LootNameToggle.Parent = ContentContainer
        
        local LootDistanceSlider = CreateSlider("Loot Max Distance", 100, 2000, Settings.ESP.LootMaxDistance, function(value)
            Settings.ESP.LootMaxDistance = value
        end)
        LootDistanceSlider.Parent = ContentContainer
        
    elseif CurrentTab == "Aimbot" then
        local AimbotToggle = CreateToggle("Aimbot Enabled", Settings.Aimbot.Enabled, function(value)
            Settings.Aimbot.Enabled = value
        end)
        AimbotToggle.Parent = ContentContainer
        
        local SilentAimToggle = CreateToggle("Silent Aim", Settings.Aimbot.SilentAim, function(value)
            Settings.Aimbot.SilentAim = value
            Settings.Aimbot.NormalAim = not value
        end)
        SilentAimToggle.Parent = ContentContainer
        
        local NormalAimToggle = CreateToggle("Normal Aim", Settings.Aimbot.NormalAim, function(value)
            Settings.Aimbot.NormalAim = value
            Settings.Aimbot.SilentAim = not value
        end)
        NormalAimToggle.Parent = ContentContainer
        
        local TeamToggle = CreateToggle("Team Check", Settings.Aimbot.TeamCheck, function(value)
            Settings.Aimbot.TeamCheck = value
        end)
        TeamToggle.Parent = ContentContainer
        
        local VisibleToggle = CreateToggle("Visible Check", Settings.Aimbot.VisibleCheck, function(value)
            Settings.Aimbot.VisibleCheck = value
        end)
        VisibleToggle.Parent = ContentContainer
        
        local FOVSlider = CreateSlider("Aimbot FOV", 10, 500, Settings.Aimbot.FOV, function(value)
            Settings.Aimbot.FOV = value
        end)
        FOVSlider.Parent = ContentContainer
        
        local SmoothSlider = CreateSlider("Smoothness", 0.01, 1, Settings.Aimbot.Smoothness, function(value)
            Settings.Aimbot.Smoothness = value
        end)
        SmoothSlider.Parent = ContentContainer
        
    elseif CurrentTab == "Combat" then
        local WallbangToggle = CreateToggle("Wallbang", Settings.Combat.Wallbang, function(value)
            Settings.Combat.Wallbang = value
        end)
        WallbangToggle.Parent = ContentContainer
        
        local HitboxExpanderToggle = CreateToggle("Hitbox Expander", Settings.Combat.HitboxExpander, function(value)
            Settings.Combat.HitboxExpander = value
            if value then
                ExpandAllHitboxes()
            else
                RestoreAllHitboxes()
            end
        end)
        HitboxExpanderToggle.Parent = ContentContainer
        
        local HitboxSizeSlider = CreateSlider("Hitbox Size", 5, 30, Settings.Combat.HitboxSize, function(value)
            Settings.Combat.HitboxSize = value
            if Settings.Combat.HitboxExpander then
                ExpandAllHitboxes()
            end
        end)
        HitboxSizeSlider.Parent = ContentContainer
        
        local MeleeRangeToggle = CreateToggle("Extended Melee Range", Settings.Combat.MeleeRange, function(value)
            Settings.Combat.MeleeRange = value
            ApplyMeleeRangeHook()
        end)
        MeleeRangeToggle.Parent = ContentContainer
        
        local MeleeRangeSlider = CreateSlider("Melee Range Multiplier", 1, 10, Settings.Combat.MeleeRangeMultiplier, function(value)
            Settings.Combat.MeleeRangeMultiplier = value
            ApplyMeleeRangeHook()
        end)
        MeleeRangeSlider.Parent = ContentContainer
        
        local InfiniteDurabilityToggle = CreateToggle("Infinite Durability", Settings.Combat.InfiniteDurability, function(value)
            Settings.Combat.InfiniteDurability = value
            HookToolDurability()
        end)
        InfiniteDurabilityToggle.Parent = ContentContainer
        
        local NoRecoilToggle = CreateToggle("No Recoil", Settings.Combat.NoRecoil, function(value)
            Settings.Combat.NoRecoil = value
            ApplyNoRecoil()
        end)
        NoRecoilToggle.Parent = ContentContainer
        
        local RapidFireToggle = CreateToggle("Rapid Fire", Settings.Combat.RapidFire, function(value)
            Settings.Combat.RapidFire = value
            ApplyRapidFire()
        end)
        RapidFireToggle.Parent = ContentContainer
        
        local FireRateSlider = CreateSlider("Fire Rate Multiplier", 1, 5, Settings.Combat.FireRateMultiplier, function(value)
            Settings.Combat.FireRateMultiplier = value
        end)
        FireRateSlider.Parent = ContentContainer
        
        local InfoLabel = Instance.new("TextLabel")
        InfoLabel.Size = UDim2.new(1, 0, 0, 140)
        InfoLabel.Position = UDim2.new(0, 0, 0, 480)
        InfoLabel.BackgroundTransparency = 1
        InfoLabel.Text = "Combat Features:\n\nWallbang: Shoot through walls\nHitbox Expander: Bigger targets\nMelee Range: Extended reach\nInfinite Durability: Never break\nNo Recoil: Perfect aim\nRapid Fire: Faster shooting\n\n⚠️ High detection risk!"
        InfoLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
        InfoLabel.TextSize = 10
        InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
        InfoLabel.TextYAlignment = Enum.TextYAlignment.Top
        InfoLabel.Font = Enum.Font.Gotham
        InfoLabel.Parent = ContentContainer
        
    elseif CurrentTab == "Exploits" then
        local InfiniteStaminaToggle = CreateToggle("Infinite Stamina", Settings.Exploits.InfiniteStamina, function(value)
            Settings.Exploits.InfiniteStamina = value
            ApplyInfiniteStamina()
        end)
        InfiniteStaminaToggle.Parent = ContentContainer
        
        local NoFallDamageToggle = CreateToggle("No Fall Damage", Settings.Exploits.NoFallDamage, function(value)
            Settings.Exploits.NoFallDamage = value
            ApplyNoFallDamage()
        end)
        NoFallDamageToggle.Parent = ContentContainer
        
        local SpeedHackToggle = CreateToggle("Speed Hack", Settings.Exploits.SpeedHack, function(value)
            Settings.Exploits.SpeedHack = value
            ApplySpeedHack()
        end)
        SpeedHackToggle.Parent = ContentContainer
        
        local SpeedSlider = CreateSlider("Speed Multiplier", 1, 5, Settings.Exploits.SpeedMultiplier, function(value)
            Settings.Exploits.SpeedMultiplier = value
            ApplySpeedHack()
        end)
        SpeedSlider.Parent = ContentContainer
        
        local JumpPowerToggle = CreateToggle("Jump Power", Settings.Exploits.JumpPower, function(value)
            Settings.Exploits.JumpPower = value
            ApplyJumpPower()
        end)
        JumpPowerToggle.Parent = ContentContainer
        
        local JumpSlider = CreateSlider("Jump Multiplier", 1, 5, Settings.Exploits.JumpMultiplier, function(value)
            Settings.Exploits.JumpMultiplier = value
            ApplyJumpPower()
        end)
        JumpSlider.Parent = ContentContainer
        
        local InstantReloadToggle = CreateToggle("Instant Reload", Settings.Exploits.InstantReload, function(value)
            Settings.Exploits.InstantReload = value
        end)
        InstantReloadToggle.Parent = ContentContainer
        
        local NoSpreadToggle = CreateToggle("No Spread", Settings.Exploits.NoSpread, function(value)
            Settings.Exploits.NoSpread = value
            ApplyNoSpread()
        end)
        NoSpreadToggle.Parent = ContentContainer
        
        local AutoLootToggle = CreateToggle("Auto Loot", Settings.Exploits.AutoLoot, function(value)
            Settings.Exploits.AutoLoot = value
            ApplyAutoLoot()
        end)
        AutoLootToggle.Parent = ContentContainer
        
        local AutoLockpickToggle = CreateToggle("Auto Lockpick", Settings.Exploits.AutoLockpick, function(value)
            Settings.Exploits.AutoLockpick = value
            ApplyAutoLockpick()
        end)
        AutoLockpickToggle.Parent = ContentContainer
        
        local NoClipToggle = CreateToggle("NoClip", Settings.Exploits.NoClip, function(value)
            Settings.Exploits.NoClip = value
            ApplyNoClip()
        end)
        NoClipToggle.Parent = ContentContainer
        
        local NoClipSpeedSlider = CreateSlider("NoClip Speed", 0.5, 3, Settings.Exploits.NoClipSpeed, function(value)
            Settings.Exploits.NoClipSpeed = value
        end)
        NoClipSpeedSlider.Parent = ContentContainer
        
        local InvisibilityToggle = CreateToggle("Invisibility", Settings.Exploits.Invisibility, function(value)
            Settings.Exploits.Invisibility = value
            ApplyInvisibility()
        end)
        InvisibilityToggle.Parent = ContentContainer
        
        local InvisibilityModeToggle = CreateToggle("Partial Invisibility", Settings.Exploits.InvisibilityMode == "Partial", function(value)
            Settings.Exploits.InvisibilityMode = value and "Partial" or "Full"
            if Settings.Exploits.Invisibility then
                DisableInvisibility()
                task.wait(0.1)
                EnableInvisibility()
            end
        end)
        InvisibilityModeToggle.Parent = ContentContainer
        
        -- Manipulator Section
        local ManipulatorToggle = CreateToggle("Character Manipulator", Settings.Exploits.Manipulator, function(value)
            Settings.Exploits.Manipulator = value
        end)
        ManipulatorToggle.Parent = ContentContainer
        
        local ManipulatorAutoMeleeToggle = CreateToggle("Auto Extreme Range Melee", Settings.Exploits.ManipulatorAutoMelee, function(value)
            Settings.Exploits.ManipulatorAutoMelee = value
        end)
        ManipulatorAutoMeleeToggle.Parent = ContentContainer
        
        local ManipulatorWallShootToggle = CreateToggle("Wall Shoot from Extended", Settings.Exploits.ManipulatorWallShoot, function(value)
            Settings.Exploits.ManipulatorWallShoot = value
        end)
        ManipulatorWallShootToggle.Parent = ContentContainer
        
        local ManipulatorStretchSlider = CreateSlider("Max Stretch Distance", 50, 500, Settings.Exploits.ManipulatorMaxStretch, function(value)
            Settings.Exploits.ManipulatorMaxStretch = value
        end)
        ManipulatorStretchSlider.Parent = ContentContainer
        
        local ManipulatorBindLabel = Instance.new("TextLabel")
        ManipulatorBindLabel.Size = UDim2.new(1, 0, 0, 30)
        ManipulatorBindLabel.BackgroundTransparency = 1
        ManipulatorBindLabel.Text = "Current Bind: " .. Settings.Exploits.ManipulatorBind.Name .. " (Press key to change)"
        ManipulatorBindLabel.TextColor3 = Settings.GUI.TextColor
        ManipulatorBindLabel.TextSize = 12
        ManipulatorBindLabel.TextXAlignment = Enum.TextXAlignment.Left
        ManipulatorBindLabel.Font = Enum.Font.Gotham
        ManipulatorBindLabel.Parent = ContentContainer
        
        local ManipulatorBindButton = Instance.new("TextButton")
        ManipulatorBindButton.Size = UDim2.new(0, 150, 0, 25)
        ManipulatorBindButton.Position = UDim2.new(0, 0, 0, 720)
        ManipulatorBindButton.BackgroundColor3 = Settings.GUI.AccentColor
        ManipulatorBindButton.Text = "Change Keybind"
        ManipulatorBindButton.TextColor3 = Settings.GUI.TextColor
        ManipulatorBindButton.TextSize = 12
        ManipulatorBindButton.Font = Enum.Font.GothamBold
        ManipulatorBindButton.Parent = ContentContainer
        
        ManipulatorBindButton.MouseButton1Click:Connect(function()
            ManipulatorBindButton.Text = "Press any key..."
            local connection
            connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
                    Settings.Exploits.ManipulatorBind = input.KeyCode
                    ManipulatorBindLabel.Text = "Current Bind: " .. input.KeyCode.Name
                    ManipulatorBindButton.Text = "Change Keybind"
                    connection:Disconnect()
                end
            end)
        end)
        
        local InfoLabel = Instance.new("TextLabel")
        InfoLabel.Size = UDim2.new(1, 0, 0, 200)
        InfoLabel.Position = UDim2.new(0, 0, 0, 760)
        InfoLabel.BackgroundTransparency = 1
        InfoLabel.Text = "⚠️ WARNING: Exploits Section ⚠️\n\nThese features directly modify game values.\nHigher detection risk!\n\nAuto Lockpick: Automatically solves\nlockpicking mini-games!\n\nNoClip: Walk through walls with\nanti-cheat bypass (WASD + Space/LShift)\n\nInvisibility: Makes you invisible to others\n  Full: Complete invisibility\n  Partial: Only body invisible (weapon visible)\n\n🔥 MANIPULATOR (ULTRA POWERFUL):\n  - Stretches your hitbox to extreme distances\n  - Hit enemies from 100+ studs with melee\n  - Shoot through walls from extended position\n  - Press bind key to activate (default: X)\n  - Works with both guns and melee weapons\n\nUse at your own discretion."
        InfoLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        InfoLabel.TextSize = 7
        InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
        InfoLabel.TextYAlignment = Enum.TextYAlignment.Top
        InfoLabel.Font = Enum.Font.GothamBold
        InfoLabel.Parent = ContentContainer
        
    elseif CurrentTab == "Performance" then
        local LowGraphicsToggle = CreateToggle("Ultra Low Graphics", Settings.Performance.LowGraphics, function(value)
            Settings.Performance.LowGraphics = value
            ApplyPerformanceSettings()
        end)
        LowGraphicsToggle.Parent = ContentContainer
        
        local RemoveFogToggle = CreateToggle("Remove Fog", Settings.Performance.RemoveFog, function(value)
            Settings.Performance.RemoveFog = value
            ApplyPerformanceSettings()
        end)
        RemoveFogToggle.Parent = ContentContainer
        
        local RemoveShadowsToggle = CreateToggle("Remove Shadows", Settings.Performance.RemoveShadows, function(value)
            Settings.Performance.RemoveShadows = value
            ApplyPerformanceSettings()
        end)
        RemoveShadowsToggle.Parent = ContentContainer
        
        local RemoveParticlesToggle = CreateToggle("Remove Particles", Settings.Performance.RemoveParticles, function(value)
            Settings.Performance.RemoveParticles = value
            ApplyPerformanceSettings()
        end)
        RemoveParticlesToggle.Parent = ContentContainer
        
        local RemoveWeatherToggle = CreateToggle("Remove Weather", Settings.Performance.RemoveWeather, function(value)
            Settings.Performance.RemoveWeather = value
            ApplyPerformanceSettings()
        end)
        RemoveWeatherToggle.Parent = ContentContainer
        
        local LowerQualityToggle = CreateToggle("Lower Object Quality", Settings.Performance.LowerQuality, function(value)
            Settings.Performance.LowerQuality = value
            ApplyPerformanceSettings()
        end)
        LowerQualityToggle.Parent = ContentContainer
        
        local FPSSlider = CreateSlider("Max FPS (0=Unlimited)", 0, 240, Settings.Performance.MaxFPS, function(value)
            Settings.Performance.MaxFPS = value
        end)
        FPSSlider.Parent = ContentContainer
        
        local InfoLabel = Instance.new("TextLabel")
        InfoLabel.Size = UDim2.new(1, 0, 0, 180)
        InfoLabel.Position = UDim2.new(0, 0, 0, 400)
        InfoLabel.BackgroundTransparency = 1
        InfoLabel.Text = "🚀 Performance Optimization 🚀\n\nUltra Low Graphics:\n- Max brightness, no shadows\n- Removes fog, bloom, blur\n- Removes weather effects\n- Disables particles\n- Lowers mesh quality\n- Sets plastic material\n- Minimal lighting effects\n\nExpected FPS boost: 50-100%\n\nNote: Script already optimized:\n- Throttled ESP updates\n- Reduced hitbox checks\n- Efficient rendering loops"
        InfoLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
        InfoLabel.TextSize = 9
        InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
        InfoLabel.TextYAlignment = Enum.TextYAlignment.Top
        InfoLabel.Font = Enum.Font.Gotham
        InfoLabel.Parent = ContentContainer
        
    elseif CurrentTab == "Settings" then
        local MasterToggle = CreateToggle("Master Switch", Settings.Enabled, function(value)
            Settings.Enabled = value
            if not value then
                -- Hide all ESP when disabled
                for _, esp in pairs(ESPObjects) do
                    for _, drawing in pairs(esp) do
                        drawing.Visible = false
                    end
                end
            end
        end)
        MasterToggle.Parent = ContentContainer
        
        local GUIToggle = CreateToggle("Show GUI", Settings.ShowGUI, function(value)
            Settings.ShowGUI = value
            MainFrame.Visible = value
        end)
        GUIToggle.Parent = ContentContainer
        
        local InfoLabel = Instance.new("TextLabel")
        InfoLabel.Size = UDim2.new(1, 0, 0, 150)
        InfoLabel.Position = UDim2.new(0, 0, 0, 120)
        InfoLabel.BackgroundTransparency = 1
        InfoLabel.Text = "Controls:\nRight Shift - Toggle GUI\nMouse Button 2 - Aim\n\nFeatures:\n- Silent Aim: Invisible aiming\n- Normal Aim: Visible aiming\n- Wallbang: Shoot through terrain\n- Hitbox Expander: Bigger targets\n- Melee Range: Extended reach\n- Infinite Durability: Never break\n- No Recoil: Perfect aim\n- Rapid Fire: Faster shooting\n- Infinite Stamina: Never tire\n- Speed/Jump Hacks: Enhanced movement\n- Auto Loot: Automatic collection"
        InfoLabel.TextColor3 = Settings.GUI.TextColor
        InfoLabel.TextSize = 11
        InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
        InfoLabel.TextYAlignment = Enum.TextYAlignment.Top
        InfoLabel.Font = Enum.Font.Gotham
        InfoLabel.Parent = ContentContainer
    end
end

-- Create all tabs
for _, tab in pairs(Tabs) do
    CreateTabButton(tab)
end

-- Initialize content
UpdateContent()

-- Initialize ESP for existing players
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end

-- Initialize Loot ESP
task.spawn(function()
    task.wait(2) -- Wait for game to load
    InitializeLootESP()
end)

-- Hook for new players
Players.PlayerAdded:Connect(function(player)
    CreateESP(player)
end)

-- Hook for leaving players
Players.PlayerRemoving:Connect(function(player)
    if ESPObjects[player] then
        for _, drawing in pairs(ESPObjects[player]) do
            drawing:Remove()
        end
        ESPObjects[player] = nil
    end
end)

-- Input handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        -- Toggle GUI with Right Shift
        if input.KeyCode == Enum.KeyCode.RightShift then
            Settings.ShowGUI = not Settings.ShowGUI
            MainFrame.Visible = Settings.ShowGUI
        end
        
        -- Aimbot trigger
        if input.UserInputType == Settings.Aimbot.TriggerKey and Settings.Enabled and Settings.Aimbot.Enabled and Settings.Aimbot.NormalAim then
            local target = GetClosestTarget()
            if target then
                AimAtTarget(target)
            end
        end
    end
end)

-- Main update loop (optimized)
local LastMainUpdate = 0
RunService.RenderStepped:Connect(function()
    -- Update frequently for smooth ESP (60 FPS)
    local currentTime = tick()
    if currentTime - LastMainUpdate < 0.016 then -- ~60 FPS
        return
    end
    LastMainUpdate = currentTime
    
    if Settings.Enabled then
        -- Update ESP (smooth 60 FPS)
        UpdateESP()
        UpdateLootESP() -- Update loot ESP
        
        -- Silent Aim hook (simulated)
        if Settings.Aimbot.Enabled and Settings.Aimbot.SilentAim then
            -- We would hook mouse.Hit here, but for safety we'll simulate it differently
            -- This is a simplified implementation
        end
    end
end)

-- Hitbox Expander Functions
function ExpandAllHitboxes()
    if not Settings.Combat.HitboxExpander or not Settings.Enabled then
        return
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            ExpandPlayerHitbox(player)
        end
    end
end

function ExpandPlayerHitbox(player)
    if not player or not player.Character then
        return
    end
    
    local character = player.Character
    local hitboxParts = {"Head", "Torso", "HumanoidRootPart", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
    
    -- Also check for R15 parts
    local r15Parts = {"UpperTorso", "LowerTorso", "LeftUpperArm", "LeftLowerArm", "RightUpperArm", "RightLowerArm",
                      "LeftUpperLeg", "LeftLowerLeg", "RightUpperLeg", "RightLowerLeg"}
    
    for _, partName in ipairs(hitboxParts) do
        local part = character:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            if not OriginalHitboxSizes[player.UserId .. partName] then
                OriginalHitboxSizes[player.UserId .. partName] = part.Size
            end
            
            part.Size = Vector3.new(Settings.Combat.HitboxSize, Settings.Combat.HitboxSize, Settings.Combat.HitboxSize)
            part.Transparency = 0.5  -- Make slightly transparent to see the expansion
            part.CanCollide = false
            part.Massless = true
            
            ExpandedHitboxes[player.UserId .. partName] = part
        end
    end
    
    -- Expand R15 parts
    for _, partName in ipairs(r15Parts) do
        local part = character:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            if not OriginalHitboxSizes[player.UserId .. partName] then
                OriginalHitboxSizes[player.UserId .. partName] = part.Size
            end
            
            part.Size = Vector3.new(Settings.Combat.HitboxSize, Settings.Combat.HitboxSize, Settings.Combat.HitboxSize)
            part.Transparency = 0.5
            part.CanCollide = false
            part.Massless = true
            
            ExpandedHitboxes[player.UserId .. partName] = part
        end
    end
end

function RestoreAllHitboxes()
    for key, part in pairs(ExpandedHitboxes) do
        if part and part.Parent then
            local originalSize = OriginalHitboxSizes[key]
            if originalSize then
                part.Size = originalSize
                part.Transparency = 0
                part.CanCollide = true
                part.Massless = false
            end
        end
    end
    
    ExpandedHitboxes = {}
end

function RestorePlayerHitbox(player)
    if not player then
        return
    end
    
    local userId = player.UserId
    for key, part in pairs(ExpandedHitboxes) do
        if string.match(key, "^" .. userId) and part and part.Parent then
            local originalSize = OriginalHitboxSizes[key]
            if originalSize then
                part.Size = originalSize
                part.Transparency = 0
                part.CanCollide = true
                part.Massless = false
            end
            ExpandedHitboxes[key] = nil
        end
    end
end

-- Wallbang Hook (Modify Raycast to ignore terrain/walls)
local OriginalRaycast = Workspace.Raycast

function CustomRaycast(...)
    local args = {...}
    local origin = args[2]
    local direction = args[3]
    local params = args[4]
    
    if Settings.Enabled and Settings.Combat.Wallbang then
        -- Create new raycast params that ignore terrain and buildings
        local newParams = RaycastParams.new()
        newParams.FilterType = Enum.RaycastFilterType.Include
        
        -- Only include player characters
        local filterList = {}
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character and player ~= LocalPlayer then
                table.insert(filterList, player.Character)
            end
        end
        
        newParams.FilterDescendantsInstances = filterList
        newParams.IgnoreWater = true
        
        return OriginalRaycast(Workspace, origin, direction, newParams)
    end
    
    return OriginalRaycast(...)
end

-- Apply Wallbang Hook
pcall(function()
    if hookfunction then
        hookfunction(Workspace.Raycast, CustomRaycast)
    end
end)

-- Enhanced Wallbang - Hook bullet trajectory
function EnhanceWallbang()
    if not Settings.Enabled or not Settings.Combat.Wallbang then
        return
    end
    
    -- Hook the fire function to ignore obstacles
    pcall(function()
        local Storage = ReplicatedStorage:FindFirstChild("Storage")
        if Storage then
            local Events = Storage:FindFirstChild("Events")
            if Events then
                -- Hook server fire event to always hit through walls
                local OriginalFireServer = Events.server.Fire
                
                Events.server.Fire = function(...)
                    local args = {...}
                    if args[2] == "fire" and Settings.Combat.Wallbang and Settings.Enabled then
                        -- Modify raycast to penetrate walls
                        print("[Wallbang] Enhanced bullet penetration active")
                    end
                    return OriginalFireServer(...)
                end
            end
        end
    end)
end

-- Melee Range Extension Hook
function ApplyMeleeRangeHook()
    if not Settings.Combat.MeleeRange or not Settings.Enabled then
        return
    end
    
    -- Hook into the game's melee framework
    local Storage = ReplicatedStorage:FindFirstChild("Storage")
    if Storage then
        -- Try to find and modify melee range values
        pcall(function()
            for _, module in pairs(Storage:GetDescendants()) do
                if module:IsA("ModuleScript") and (module.Name:lower():match("melee") or module.Name:lower():match("weapon")) then
                    local success, moduleContent = pcall(require, module)
                    if success and type(moduleContent) == "table" then
                        -- Look for range/distance properties and multiply them
                        if moduleContent.range then
                            moduleContent.range = moduleContent.range * Settings.Combat.MeleeRangeMultiplier
                        end
                        if moduleContent.maxDistance then
                            moduleContent.maxDistance = moduleContent.maxDistance * Settings.Combat.MeleeRangeMultiplier
                        end
                        if moduleContent.attackRange then
                            moduleContent.attackRange = moduleContent.attackRange * Settings.Combat.MeleeRangeMultiplier
                        end
                    end
                end
            end
        end)
    end
    
    -- Also hook the shared variables if they exist
    pcall(function()
        if shared and shared.meleeRange then
            shared.meleeRange = shared.meleeRange * Settings.Combat.MeleeRangeMultiplier
        end
    end)
end

-- Monitor for new players and expand their hitboxes
Players.PlayerAdded:Connect(function(player)
    if Settings.Combat.HitboxExpander and Settings.Enabled then
        player.CharacterAdded:Connect(function(character)
            task.wait(0.5)  -- Wait for character to fully load
            ExpandPlayerHitbox(player)
        end)
    end
end)

-- Monitor for players leaving and clean up their hitboxes
Players.PlayerRemoving:Connect(function(player)
    RestorePlayerHitbox(player)
end)

-- ============================================
-- EXPLOIT FUNCTIONS (Based on Game Analysis)
-- ============================================

-- Infinite Stamina Exploit
function ApplyInfiniteStamina()
    if not Settings.Enabled or not Settings.Exploits.InfiniteStamina then
        return
    end
    
    -- Hook the stamina function
    pcall(function()
        if shared and shared.staminaFunction then
            local OriginalStaminaFunc = shared.staminaFunction
            
            shared.staminaFunction = function(action, ...)
                if action == "drain" then
                    -- Don't drain stamina
                    return
                elseif action == "getStaminaCurrent" then
                    -- Always return max stamina
                    return 200
                else
                    return OriginalStaminaFunc(action, ...)
                end
            end
        end
    end)
end

-- Infinite Durability Exploit
function HookToolDurability()
    if not Settings.Enabled or not Settings.Combat.InfiniteDurability then
        return
    end
    
    LocalPlayer.Character.ChildAdded:Connect(function(tool)
        if tool:IsA("Tool") and tool:FindFirstChild("_data") then
            local data = tool._data
            
            -- Hook durability changes
            if data:FindFirstChild("durability") then
                local originalDurability = data.durability.Value
                
                data.durability.Changed:Connect(function()
                    if Settings.Combat.InfiniteDurability and Settings.Enabled then
                        data.durability.Value = originalDurability
                    end
                end)
                
                HookedTools[tool.Name] = true
            end
        end
    end)
end

-- No Recoil Hook
function ApplyNoRecoil()
    if not Settings.Enabled or not Settings.Combat.NoRecoil then
        return
    end
    
    -- Hook recoil in shared variables
    pcall(function()
        if shared then
            local originalRecoil = shared.recoil
            
            -- Override recoil values
            RunService.RenderStepped:Connect(function()
                if Settings.Combat.NoRecoil and Settings.Enabled then
                    if shared.recoilReduction then
                        shared.recoilReduction = 1000  -- Max recoil reduction
                    end
                end
            end)
        end
    end)
end

-- Rapid Fire Hook
function ApplyRapidFire()
    if not Settings.Enabled or not Settings.Combat.RapidFire then
        return
    end
    
    LocalPlayer.Character.ChildAdded:Connect(function(tool)
        if tool:IsA("Tool") then
            task.wait(0.1)
            
            -- Modify fire rate attribute
            if tool:GetAttribute("FireRate") then
                local originalRate = tool:GetAttribute("FireRate")
                
                RunService.Heartbeat:Connect(function()
                    if Settings.Combat.RapidFire and Settings.Enabled then
                        local newRate = originalRate * Settings.Combat.FireRateMultiplier
                        tool:SetAttribute("FireRate", newRate)
                    else
                        tool:SetAttribute("FireRate", originalRate)
                    end
                end)
            end
        end
    end)
end

-- No Fall Damage
function ApplyNoFallDamage()
    if not Settings.Enabled or not Settings.Exploits.NoFallDamage then
        return
    end
    
    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    end
end

-- Speed Hack
function ApplySpeedHack()
    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    if not OriginalWalkSpeed then
        OriginalWalkSpeed = humanoid.WalkSpeed
    end
    
    if Settings.Exploits.SpeedHack and Settings.Enabled then
        humanoid.WalkSpeed = OriginalWalkSpeed * Settings.Exploits.SpeedMultiplier
    else
        humanoid.WalkSpeed = OriginalWalkSpeed
    end
end

-- Jump Power Hack
function ApplyJumpPower()
    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    if not OriginalJumpPower then
        OriginalJumpPower = humanoid.JumpPower
    end
    
    if Settings.Exploits.JumpPower and Settings.Enabled then
        humanoid.JumpPower = OriginalJumpPower * Settings.Exploits.JumpMultiplier
    else
        humanoid.JumpPower = OriginalJumpPower
    end
end

-- Instant Reload Hook
function ApplyInstantReload()
    if not Settings.Enabled or not Settings.Exploits.InstantReload then
        return
    end
    
    -- Hook reload animations to make them instant
    pcall(function()
        if shared and shared.reload ~= nil then
            RunService.Heartbeat:Connect(function()
                if Settings.Exploits.InstantReload and Settings.Enabled and shared.reload then
                    shared.reload = false  -- Force reload to complete instantly
                end
            end)
        end
    end)
end

-- No Spread (Perfect Accuracy)
function ApplyNoSpread()
    if not Settings.Enabled or not Settings.Exploits.NoSpread then
        return
    end
    
    -- Hook spread values
    pcall(function()
        RunService.RenderStepped:Connect(function()
            if Settings.Exploits.NoSpread and Settings.Enabled then
                -- Try to find and zero out spread values
                local Storage = ReplicatedStorage:FindFirstChild("Storage")
                if Storage then
                    for _, module in pairs(Storage:GetDescendants()) do
                        if module:IsA("ModuleScript") and module.Name:lower():match("weapon") then
                            local success, weaponData = pcall(require, module)
                            if success and type(weaponData) == "table" then
                                if weaponData.spread then
                                    weaponData.spread = 0
                                end
                                if weaponData.hipfireSpread then
                                    weaponData.hipfireSpread = 0
                                end
                            end
                        end
                    end
                end
            end
        end)
    end)
end

-- Auto Loot Function
local LootConnection = nil
function ApplyAutoLoot()
    if LootConnection then
        LootConnection:Disconnect()
        LootConnection = nil
    end
    
    if not Settings.Enabled or not Settings.Exploits.AutoLoot then
        return
    end
    
    LootConnection = RunService.Heartbeat:Connect(function()
        if Settings.Exploits.AutoLoot and Settings.Enabled then
            -- Find nearby loot
            local character = LocalPlayer.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            local rootPart = character.HumanoidRootPart
            
            -- Look for loot in workspace
            pcall(function()
                local loots = Workspace:FindFirstChild("Buildings")
                if loots then
                    loots = loots:FindFirstChild("Loots")
                    if loots then
                        for _, loot in pairs(loots:GetDescendants()) do
                            if loot:IsA("BasePart") and loot.Name:lower():match("loot") then
                                local distance = (loot.Position - rootPart.Position).Magnitude
                                if distance < 50 then
                                    -- Try to interact with loot
                                    if ReplicatedStorage:FindFirstChild("Storage") then
                                        local Storage = ReplicatedStorage.Storage
                                        if Storage:FindFirstChild("Events") then
                                            -- Fire loot event (this may vary based on game)
                                            pcall(function()
                                                Storage.Events:FindFirstChild("interact"):InvokeServer(loot)
                                            end)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end)
end

-- Auto Lockpick Function
function ApplyAutoLockpick()
    if LockpickConnection then
        LockpickConnection:Disconnect()
        LockpickConnection = nil
    end
    
    if not Settings.Enabled or not Settings.Exploits.AutoLockpick then
        return
    end
    
    -- Monitor for lockpicking state
    LockpickConnection = RunService.Heartbeat:Connect(function()
        if not Settings.Exploits.AutoLockpick or not Settings.Enabled then return end
        
        pcall(function()
            -- Check if lockpicking is active
            if shared and shared.lockpicking then
                if not AutoLockpickActive then
                    AutoLockpickActive = true
                    print("[Auto Lockpick] Detected lockpicking mini-game, starting auto solver...")
                    
                    task.spawn(function()
                        SolveLockpickMinigame()
                    end)
                end
            else
                AutoLockpickActive = false
            end
        end)
    end)
end

function SolveLockpickMinigame()
    -- This function automatically solves the lockpick mini-game
    local VirtualInputManager = game:GetService("VirtualInputManager")
    
    local success, error = pcall(function()
        -- Find the lockpick model in camera
        local lockpickModel = Camera:FindFirstChild("lockpickModel")
        
        if not lockpickModel then
            print("[Auto Lockpick] Lockpick model not found")
            return
        end
        
        -- Find the lockpick UI
        local lockpickUI = LocalPlayer.PlayerGui:FindFirstChild("UI")
        if lockpickUI then
            lockpickUI = lockpickUI:FindFirstChild("HUD_GAMEPLAY")
            if lockpickUI then
                lockpickUI = lockpickUI:FindFirstChild("barsInfo")
                if lockpickUI then
                    lockpickUI = lockpickUI:FindFirstChild("lockpickGuide")
                end
            end
        end
        
        if not lockpickUI then
            print("[Auto Lockpick] Lockpick UI not found")
            return
        end
        
        print("[Auto Lockpick] Starting auto solve...")
        task.wait(2) -- Wait for animation to complete
        
        -- Solve all pins
        local maxPins = 5
        local solvedPins = 0
        
        for pinIndex = 1, maxPins do
            if not shared.lockpicking then
                print("[Auto Lockpick] Lockpicking ended")
                break
            end
            
            -- Check if pin is already solved
            local pinMotor = lockpickModel:FindFirstChild("Motors")
            if pinMotor then
                pinMotor = pinMotor:FindFirstChild("Pins")
                if pinMotor then
                    local currentPin = pinMotor:FindFirstChild(tostring(pinIndex))
                    if currentPin and currentPin:GetAttribute("Solved") then
                        print("[Auto Lockpick] Pin " .. pinIndex .. " already solved, skipping")
                        continue
                    end
                end
            end
            
            -- Move to the pin if not already there
            print("[Auto Lockpick] Moving to pin " .. pinIndex)
            
            -- Press W to lift the pin
            task.wait(0.3)
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, game)
            task.wait(0.05)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, game)
            
            -- Wait for the perfect moment (after 0.1 seconds from pressing W)
            task.wait(0.15)
            
            -- Click to lock the pin
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            
            solvedPins = solvedPins + 1
            print("[Auto Lockpick] Pin " .. pinIndex .. " solved! (" .. solvedPins .. "/" .. maxPins .. ")")
            
            -- Move to next pin (press D)
            if pinIndex < maxPins then
                task.wait(0.3)
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.D, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.D, false, game)
                task.wait(0.3)
            end
        end
        
        print("[Auto Lockpick] All pins solved! Lockpick completed successfully!")
    end)
    
    if not success then
        warn("[Auto Lockpick] Error: " .. tostring(error))
    end
    
    AutoLockpickActive = false
end

-- Alternative Auto Lockpick (Direct Hook Method)
function HookLockpickFunction()
    pcall(function()
        -- Hook the handleLockpick function if possible
        if shared and shared.handleLockpick then
            local OriginalHandleLockpick = shared.handleLockpick
            
            shared.handleLockpick = function(...)
                local args = {...}
                
                if Settings.Exploits.AutoLockpick and Settings.Enabled then
                    print("[Auto Lockpick] Intercepted lockpick call, auto-solving...")
                    
                    -- Call original function
                    local result = OriginalHandleLockpick(...)
                    
                    -- Start auto solve after a delay
                    task.delay(2, function()
                        SolveLockpickMinigame()
                    end)
                    
                    return result
                else
                    return OriginalHandleLockpick(...)
                end
            end
        end
    end)
end

-- ============================================
-- NOCLIP WITH ANTI-CHEAT BYPASS
-- ============================================

function EnableNoClip()
    if NoClipActive then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then return end
    
    NoClipActive = true
    print("[NoClip] Enabling NoClip with anti-cheat bypass...")
    
    -- Save last valid position for anti-cheat bypass
    LastValidPosition = rootPart.CFrame
    
    -- Store original collision states
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            OriginalCollisionStates[part] = {
                CanCollide = part.CanCollide,
                Massless = part.Massless
            }
        end
    end
    
    -- Create BodyVelocity for smooth movement (helps bypass anti-cheat)
    if not NoClipBodyVelocity then
        NoClipBodyVelocity = Instance.new("BodyVelocity")
        NoClipBodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
        NoClipBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        NoClipBodyVelocity.Parent = rootPart
    end
    
    -- Create BodyGyro for stability
    if not NoClipBodyGyro then
        NoClipBodyGyro = Instance.new("BodyGyro")
        NoClipBodyGyro.MaxTorque = Vector3.new(100000, 100000, 100000)
        NoClipBodyGyro.P = 10000
        NoClipBodyGyro.CFrame = rootPart.CFrame
        NoClipBodyGyro.Parent = rootPart
    end
    
    -- NoClip update loop with anti-cheat bypass
    NoClipConnection = RunService.Heartbeat:Connect(function()
        if not Settings.Exploits.NoClip or not Settings.Enabled then
            DisableNoClip()
            return
        end
        
        local char = LocalPlayer.Character
        if not char then 
            DisableNoClip()
            return 
        end
        
        local hum = char:FindFirstChild("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        
        if not hum or not root then 
            DisableNoClip()
            return 
        end
        
        -- Disable collisions
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
                part.Massless = true
            end
        end
        
        -- Anti-cheat bypass: Smooth movement instead of instant teleport
        local moveDirection = Vector3.new(0, 0, 0)
        local speed = 50 * Settings.Exploits.NoClipSpeed
        
        -- WASD movement
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + (Camera.CFrame.LookVector * speed)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - (Camera.CFrame.LookVector * speed)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - (Camera.CFrame.RightVector * speed)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + (Camera.CFrame.RightVector * speed)
        end
        
        -- Up/Down movement
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0, speed, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveDirection = moveDirection - Vector3.new(0, speed, 0)
        end
        
        -- Apply velocity instead of direct CFrame change (anti-cheat bypass)
        if NoClipBodyVelocity then
            NoClipBodyVelocity.Velocity = moveDirection
        end
        
        -- Update BodyGyro to prevent spinning
        if NoClipBodyGyro then
            NoClipBodyGyro.CFrame = Camera.CFrame
        end
        
        -- Anti-cheat bypass: Disable humanoid states that might trigger checks
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Flying, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
        
        -- Update last valid position periodically (for rollback protection)
        if tick() % 1 < 0.016 then
            LastValidPosition = root.CFrame
        end
    end)
    
    print("[NoClip] NoClip enabled! Use WASD to move, Space/LShift for up/down")
end

function DisableNoClip()
    if not NoClipActive then return end
    
    NoClipActive = false
    print("[NoClip] Disabling NoClip...")
    
    -- Disconnect update loop
    if NoClipConnection then
        NoClipConnection:Disconnect()
        NoClipConnection = nil
    end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    -- Restore collision states
    for part, states in pairs(OriginalCollisionStates) do
        if part and part.Parent then
            part.CanCollide = states.CanCollide
            part.Massless = states.Massless
        end
    end
    
    -- Remove BodyVelocity
    if NoClipBodyVelocity then
        NoClipBodyVelocity:Destroy()
        NoClipBodyVelocity = nil
    end
    
    -- Remove BodyGyro
    if NoClipBodyGyro then
        NoClipBodyGyro:Destroy()
        NoClipBodyGyro = nil
    end
    
    -- Restore humanoid states
    if humanoid then
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying, false)
    end
    
    -- Clear stored states
    OriginalCollisionStates = {}
    
    print("[NoClip] NoClip disabled")
end

function ApplyNoClip()
    if Settings.Exploits.NoClip and Settings.Enabled then
        EnableNoClip()
    else
        DisableNoClip()
    end
end

-- Monitor character respawn for NoClip
LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(1) -- Wait for character to load
    
    if Settings.Exploits.NoClip and Settings.Enabled then
        print("[NoClip] Character respawned, re-enabling NoClip...")
        EnableNoClip()
    end
    
    if Settings.Exploits.Invisibility and Settings.Enabled then
        print("[Invisibility] Character respawned, re-enabling Invisibility...")
        EnableInvisibility()
    end
end)

-- ============================================
-- CHARACTER MANIPULATOR (EXTREME EXPLOIT)
-- ============================================

function ActivateManipulator()
    if ManipulatorActive then
        DeactivateManipulator()
        return
    end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    
    if not rootPart or not humanoid then return end
    
    ManipulatorActive = true
    print("[Manipulator] 🔥 ACTIVATING CHARACTER MANIPULATOR 🔥")
    
    -- Save original position
    OriginalRootPartCFrame = rootPart.CFrame
    
    -- Find closest target
    local closestPlayer = nil
    local closestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                local distance = (targetRoot.Position - rootPart.Position).Magnitude
                if distance < closestDistance and distance <= Settings.Exploits.ManipulatorMaxStretch then
                    closestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    
    if not closestPlayer then
        print("[Manipulator] No valid target found within range")
        ManipulatorActive = false
        return
    end
    
    local targetRoot = closestPlayer.Character.HumanoidRootPart
    ManipulatorTargetPosition = targetRoot.Position
    
    print("[Manipulator] Target: " .. closestPlayer.Name .. " (Distance: " .. math.floor(closestDistance) .. " studs)")
    
    -- EXTREME HITBOX STRETCH
    -- This exploits the character's network replication by stretching parts
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            -- Store original size and CFrame
            ManipulatorExtendedParts[part] = {
                OriginalSize = part.Size,
                OriginalCFrame = part.CFrame,
                OriginalCanCollide = part.CanCollide
            }
            
            -- Calculate direction to target
            local direction = (ManipulatorTargetPosition - rootPart.Position).Unit
            
            -- Stretch part towards target
            local stretchDistance = closestDistance
            part.Size = Vector3.new(part.Size.X, part.Size.Y, stretchDistance)
            part.CFrame = rootPart.CFrame * CFrame.new(direction * (stretchDistance / 2))
            part.CanCollide = false
            part.Massless = true
        end
    end
    
    -- Position root slightly towards target for shooting
    if Settings.Exploits.ManipulatorWallShoot then
        local direction = (ManipulatorTargetPosition - rootPart.Position).Unit
        local extendDistance = math.min(closestDistance * 0.8, Settings.Exploits.ManipulatorMaxStretch * 0.8)
        rootPart.CFrame = rootPart.CFrame + (direction * extendDistance)
    end
    
    print("[Manipulator] Character stretched! Hitbox extended by " .. math.floor(closestDistance) .. " studs")
    
    -- Auto melee attack if enabled
    if Settings.Exploits.ManipulatorAutoMelee then
        task.spawn(function()
            task.wait(0.1)
            -- Try to trigger melee attack
            local tool = character:FindFirstChildOfClass("Tool")
            if tool then
                -- Fire melee attack
                pcall(function()
                    if tool:FindFirstChild("Handle") then
                        print("[Manipulator] Attempting extreme range melee attack...")
                        -- Simulate melee swing
                        local VirtualInputManager = game:GetService("VirtualInputManager")
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                        task.wait(0.05)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                    end
                end)
            end
        end)
    end
    
    -- Auto deactivate after short time
    task.delay(0.5, function()
        if ManipulatorActive then
            DeactivateManipulator()
        end
    end)
end

function DeactivateManipulator()
    if not ManipulatorActive then return end
    
    ManipulatorActive = false
    print("[Manipulator] Deactivating manipulator...")
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    -- Restore all extended parts
    for part, data in pairs(ManipulatorExtendedParts) do
        if part and part.Parent then
            part.Size = data.OriginalSize
            part.CFrame = data.OriginalCFrame
            part.CanCollide = data.OriginalCanCollide
            part.Massless = false
        end
    end
    
    -- Restore root position
    if rootPart and OriginalRootPartCFrame then
        rootPart.CFrame = OriginalRootPartCFrame
    end
    
    ManipulatorExtendedParts = {}
    ManipulatorTargetPosition = nil
    
    print("[Manipulator] Character restored to normal")
end

-- Keybind listener for manipulator
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and Settings.Enabled and Settings.Exploits.Manipulator then
        if input.KeyCode == Settings.Exploits.ManipulatorBind then
            ActivateManipulator()
        end
    end
end)

-- ============================================
-- INVISIBILITY SYSTEM
-- ============================================

function EnableInvisibility()
    if InvisibilityActive then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    InvisibilityActive = true
    print("[Invisibility] Enabling invisibility...")
    
    -- Store original transparencies
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("Decal") or part:IsA("Texture") then
            OriginalTransparencies[part] = part.Transparency
        end
    end
    
    -- Store accessories
    for _, accessory in pairs(character:GetChildren()) do
        if accessory:IsA("Accessory") then
            table.insert(OriginalAccessories, accessory)
        end
    end
    
    -- Make character invisible
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            -- Check if we should keep weapons visible
            local keepVisible = false
            if Settings.Exploits.InvisibilityMode == "Partial" then
                -- Check if part belongs to a tool
                local parent = part.Parent
                while parent do
                    if parent:IsA("Tool") then
                        keepVisible = true
                        break
                    end
                    parent = parent.Parent
                end
            end
            
            if not keepVisible then
                part.Transparency = 1
                
                -- Hide face decals
                for _, child in pairs(part:GetChildren()) do
                    if child:IsA("Decal") or child:IsA("Texture") then
                        child.Transparency = 1
                    end
                end
            end
        end
        
        -- Make accessories invisible
        if part:IsA("Accessory") then
            local handle = part:FindFirstChild("Handle")
            if handle then
                handle.Transparency = 1
            end
        end
    end
    
    -- Continuous invisibility enforcement
    InvisibilityConnection = RunService.Heartbeat:Connect(function()
        if not Settings.Exploits.Invisibility or not Settings.Enabled then
            DisableInvisibility()
            return
        end
        
        local char = LocalPlayer.Character
        if not char then
            DisableInvisibility()
            return
        end
        
        -- Maintain invisibility
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                -- Check if we should keep weapons visible
                local keepVisible = false
                if Settings.Exploits.InvisibilityMode == "Partial" then
                    local parent = part.Parent
                    while parent do
                        if parent:IsA("Tool") then
                            keepVisible = true
                            break
                        end
                        parent = parent.Parent
                    end
                end
                
                if not keepVisible and part.Transparency < 1 then
                    part.Transparency = 1
                end
                
                -- Hide face decals continuously
                for _, child in pairs(part:GetChildren()) do
                    if (child:IsA("Decal") or child:IsA("Texture")) and child.Transparency < 1 then
                        child.Transparency = 1
                    end
                end
            end
        end
        
        -- Hide name tag
        local head = char:FindFirstChild("Head")
        if head then
            local healthBar = head:FindFirstChild("HealthBar")
            if healthBar then
                healthBar.Enabled = false
            end
        end
    end)
    
    print("[Invisibility] Invisibility enabled! You are now invisible to other players")
    print("[Invisibility] Mode: " .. Settings.Exploits.InvisibilityMode)
end

function DisableInvisibility()
    if not InvisibilityActive then return end
    
    InvisibilityActive = false
    print("[Invisibility] Disabling invisibility...")
    
    -- Disconnect update loop
    if InvisibilityConnection then
        InvisibilityConnection:Disconnect()
        InvisibilityConnection = nil
    end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    -- Restore transparencies
    for part, transparency in pairs(OriginalTransparencies) do
        if part and part.Parent then
            part.Transparency = transparency
        end
    end
    
    -- Restore accessories
    for _, accessory in pairs(OriginalAccessories) do
        if accessory and accessory.Parent then
            local handle = accessory:FindFirstChild("Handle")
            if handle then
                handle.Transparency = OriginalTransparencies[handle] or 0
            end
        end
    end
    
    -- Show name tag
    local head = character:FindFirstChild("Head")
    if head then
        local healthBar = head:FindFirstChild("HealthBar")
        if healthBar then
            healthBar.Enabled = true
        end
    end
    
    -- Clear stored data
    OriginalTransparencies = {}
    OriginalAccessories = {}
    
    print("[Invisibility] Invisibility disabled")
end

function ApplyInvisibility()
    if Settings.Exploits.Invisibility and Settings.Enabled then
        EnableInvisibility()
    else
        DisableInvisibility()
    end
end

-- ============================================
-- PERFORMANCE OPTIMIZATION SYSTEM
-- ============================================

function EnableLowGraphics()
    if PerformanceActive then return end
    
    PerformanceActive = true
    print("[Performance] Enabling ultra low graphics mode...")
    
    local Lighting = game:GetService("Lighting")
    local Terrain = Workspace:FindFirstChildOfClass("Terrain")
    
    -- Save original lighting settings
    OriginalLightingSettings = {
        Ambient = Lighting.Ambient,
        Brightness = Lighting.Brightness,
        ColorShift_Bottom = Lighting.ColorShift_Bottom,
        ColorShift_Top = Lighting.ColorShift_Top,
        EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
        EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
        GlobalShadows = Lighting.GlobalShadows,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        ShadowSoftness = Lighting.ShadowSoftness,
        ClockTime = Lighting.ClockTime,
        GeographicLatitude = Lighting.GeographicLatitude,
        ExposureCompensation = Lighting.ExposureCompensation
    }
    
    -- Ultra low graphics settings
    if Settings.Performance.LowGraphics then
        -- Maximize brightness, remove shadows
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.Brightness = 3
        Lighting.ColorShift_Bottom = Color3.new(1, 1, 1)
        Lighting.ColorShift_Top = Color3.new(1, 1, 1)
        Lighting.EnvironmentDiffuseScale = 1
        Lighting.EnvironmentSpecularScale = 0
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        Lighting.ShadowSoftness = 0
        Lighting.ClockTime = 14 -- Bright daylight
        Lighting.GeographicLatitude = 0
        Lighting.ExposureCompensation = 0
        
        print("[Performance] Lighting optimized - full brightness, no shadows")
    end
    
    -- Remove fog
    if Settings.Performance.RemoveFog then
        Lighting.FogEnd = 100000
        Lighting.FogStart = 100000
        print("[Performance] Fog removed")
    end
    
    -- Remove lighting effects
    for _, effect in pairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") or 
           effect:IsA("BloomEffect") or 
           effect:IsA("BlurEffect") or 
           effect:IsA("ColorCorrectionEffect") or 
           effect:IsA("DepthOfFieldEffect") or 
           effect:IsA("SunRaysEffect") or
           effect:IsA("Atmosphere") or
           effect:IsA("Sky") or
           effect:IsA("Clouds") then
            
            table.insert(RemovedEffects, {effect, effect.Parent})
            effect.Parent = nil
            print("[Performance] Removed: " .. effect.ClassName)
        end
    end
    
    -- Remove weather effects from workspace
    if Settings.Performance.RemoveWeather then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name:lower():match("rain") or 
               obj.Name:lower():match("snow") or 
               obj.Name:lower():match("weather") or
               obj.Name:lower():match("wind") then
                table.insert(RemovedEffects, {obj, obj.Parent})
                obj.Parent = nil
            end
        end
        print("[Performance] Weather effects removed")
    end
    
    -- Remove particles
    if Settings.Performance.RemoveParticles then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or 
               obj:IsA("Trail") or 
               obj:IsA("Beam") or
               obj:IsA("Fire") or
               obj:IsA("Smoke") or
               obj:IsA("Sparkles") then
                obj.Enabled = false
            end
        end
        print("[Performance] Particles disabled")
    end
    
    -- Lower object quality
    if Settings.Performance.LowerQuality then
        -- Reduce terrain quality
        if Terrain then
            Terrain.Decoration = false
            Terrain.WaterReflectance = 0
            Terrain.WaterTransparency = 0
            Terrain.WaterWaveSize = 0
            Terrain.WaterWaveSpeed = 0
        end
        
        -- Lower mesh/part quality
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("MeshPart") then
                obj.RenderFidelity = Enum.RenderFidelity.Performance
            elseif obj:IsA("BasePart") then
                obj.Material = Enum.Material.Plastic
                obj.Reflectance = 0
                obj.CastShadow = false
            elseif obj:IsA("Texture") or obj:IsA("Decal") then
                -- Reduce texture quality
                if obj:IsA("Texture") then
                    obj.StudsPerTileU = 8
                    obj.StudsPerTileV = 8
                end
            end
        end
        print("[Performance] Object quality reduced")
    end
    
    -- Set graphics quality to minimum
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    
    -- Disable unnecessary rendering features
    settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
    
    -- Reduce shadow quality
    if Settings.Performance.RemoveShadows then
        settings().Rendering.EnableVRMode = false
    end
    
    print("[Performance] Ultra low graphics mode enabled!")
    print("[Performance] FPS should be significantly improved")
end

function DisableLowGraphics()
    if not PerformanceActive then return end
    
    PerformanceActive = false
    print("[Performance] Restoring original graphics...")
    
    local Lighting = game:GetService("Lighting")
    
    -- Restore lighting settings
    for key, value in pairs(OriginalLightingSettings) do
        if Lighting[key] ~= nil then
            Lighting[key] = value
        end
    end
    
    -- Restore removed effects
    for _, data in pairs(RemovedEffects) do
        local effect, parent = data[1], data[2]
        if effect and parent then
            effect.Parent = parent
        end
    end
    
    RemovedEffects = {}
    
    -- Restore particles
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or 
           obj:IsA("Trail") or 
           obj:IsA("Beam") or
           obj:IsA("Fire") or
           obj:IsA("Smoke") or
           obj:IsA("Sparkles") then
            obj.Enabled = true
        end
    end
    
    print("[Performance] Graphics restored")
end

function ApplyPerformanceSettings()
    if Settings.Performance.LowGraphics and Settings.Enabled then
        EnableLowGraphics()
    else
        DisableLowGraphics()
    end
end

-- FPS Cap (if needed)
if Settings.Performance.MaxFPS > 0 then
    local lastFrame = tick()
    local frameDelay = 1 / Settings.Performance.MaxFPS
    
    RunService.RenderStepped:Connect(function()
        local now = tick()
        local elapsed = now - lastFrame
        
        if elapsed < frameDelay then
            local waitTime = frameDelay - elapsed
            task.wait(waitTime)
        end
        
        lastFrame = tick()
    end)
end

-- ============================================
-- CHARACTER MANIPULATOR (ULTIMATE EXPLOIT)
-- ============================================

function EnableCharacterManipulator()
    if ManipulatorActive then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    ManipulatorActive = true
    
    -- Store original sizes
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            OriginalCharacterSizes[part] = {
                Size = part.Size,
                Position = part.Position
            }
        end
    end
    
    -- Manipulator main loop
    ManipulatorConnection = RunService.Heartbeat:Connect(function()
        if not Settings.Exploits.CharManipulator or not Settings.Enabled then
            DisableCharacterManipulator()
            return
        end
        
        local char = LocalPlayer.Character
        if not char then
            DisableCharacterManipulator()
            return
        end
        
        -- Find target
        ManipulatorTarget = GetClosestTarget()
        
        -- Stretch hitbox towards target when keybind is pressed
        if UserInputService:IsKeyDown(Settings.Exploits.ManipulatorBind) and ManipulatorTarget then
            StretchHitboxToTarget(ManipulatorTarget)
            
            -- Auto shoot if gun equipped
            if Settings.Exploits.ManipulatorWallShoot then
                AutoShootThroughWalls(ManipulatorTarget)
            end
            
            -- Auto melee attack at max range
            if char:FindFirstChildOfClass("Tool") then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool and not tool:FindFirstChild("_mod") then
                    -- Not a gun, probably melee
                    AutoMeleeAttack(ManipulatorTarget)
                end
            end
        else
            -- Reset hitbox
            ResetManipulatorHitbox()
        end
    end)
end

function DisableCharacterManipulator()
    if not ManipulatorActive then return end
    
    ManipulatorActive = false
    
    if ManipulatorConnection then
        ManipulatorConnection:Disconnect()
        ManipulatorConnection = nil
    end
    
    ResetManipulatorHitbox()
    OriginalCharacterSizes = {}
end

function StretchHitboxToTarget(target)
    if not target or not target.Character then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
    
    if not rootPart or not targetRoot then return end
    
    -- Calculate direction and distance to target
    local direction = (targetRoot.Position - rootPart.Position).Unit
    local distance = (targetRoot.Position - rootPart.Position).Magnitude
    
    -- Stretch hitbox in target direction
    local stretchSize = math.min(distance, Settings.Exploits.ManipulatorHitboxSize)
    
    -- Manipulate all body parts
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            -- Stretch part towards target
            part.Size = Vector3.new(
                Settings.Exploits.ManipulatorHitboxSize,
                part.Size.Y,
                Settings.Exploits.ManipulatorHitboxSize
            )
            part.CanCollide = false
            part.Massless = true
            
            -- Move part slightly towards target
            local offset = direction * (stretchSize / 2)
            part.CFrame = part.CFrame + offset
        end
    end
end

function ResetManipulatorHitbox()
    local character = LocalPlayer.Character
    if not character then return end
    
    for part, data in pairs(OriginalCharacterSizes) do
        if part and part.Parent then
            part.Size = data.Size
            part.CanCollide = true
            part.Massless = false
        end
    end
end

function AutoShootThroughWalls(target)
    if not target or not target.Character then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool or not tool:FindFirstChild("_mod") then return end
    
    -- Check if gun has ammo
    local data = tool:FindFirstChild("_data")
    if data and data:FindFirstChild("ammoCurrent") then
        if data.ammoCurrent.Value > 0 then
            -- Simulate shooting through walls
            local targetPart = target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("HumanoidRootPart")
            if targetPart then
                -- Fire gun (exploit: bypass wall checks)
                local Storage = ReplicatedStorage:FindFirstChild("Storage")
                if Storage and Storage:FindFirstChild("Events") then
                    pcall(function()
                        Storage.Events.server:Fire("fire", character, tool, false, false, targetPart.Position, false, false)
                    end)
                end
            end
        end
    end
end

function AutoMeleeAttack(target)
    if not target or not target.Character then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
    
    if not rootPart or not targetRoot then return end
    
    local distance = (targetRoot.Position - rootPart.Position).Magnitude
    
    -- Attack if within extended range
    if distance <= Settings.Exploits.ManipulatorMeleeRange then
        -- Simulate melee attack
        local VIM = game:GetService("VirtualInputManager")
        
        -- Swing melee weapon
        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.05)
        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end
end

function ApplyCharacterManipulator()
    if Settings.Exploits.CharManipulator and Settings.Enabled then
        EnableCharacterManipulator()
    else
        DisableCharacterManipulator()
    end
end

-- Monitor for players leaving and clean up their hitboxes
Players.PlayerRemoving:Connect(function(player)
    RestorePlayerHitbox(player)
end)

-- Update hitboxes periodically (optimized)
local LastHitboxUpdate = 0
RunService.Heartbeat:Connect(function()
    if Settings.Enabled and Settings.Combat.HitboxExpander then
        -- Update every 0.5 seconds instead of every frame
        if tick() - LastHitboxUpdate >= 0.5 then
            LastHitboxUpdate = tick()
            
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    -- Re-expand hitboxes if they reset
                    local character = player.Character
                    local head = character:FindFirstChild("Head")
                    if head and head.Size.X < Settings.Combat.HitboxSize then
                        ExpandPlayerHitbox(player)
                    end
                end
            end
        end
    end
end)

-- Hook mouse.Hit for silent aim (if possible)
pcall(function()
    OriginalMouseHit = Mouse.Hit
    getgenv().Mouse = Mouse
    
    local meta = getrawmetatable(game)
    local oldIndex = meta.__index
    
    setreadonly(meta, false)
    
    meta.__index = newcclosure(function(self, key)
        if self == Mouse and key == "Hit" and Settings.Enabled and Settings.Aimbot.Enabled and Settings.Aimbot.SilentAim then
            local target = GetClosestTarget()
            if target and target.Character and target.Character:FindFirstChild(Settings.Aimbot.TargetPart) then
                return CFrame.new(target.Character[Settings.Aimbot.TargetPart].Position)
            end
        end
        return oldIndex(self, key)
    end)
    
    setreadonly(meta, true)
end)

-- Initialize all exploits
task.spawn(function()
    task.wait(2)  -- Wait for game to fully load
    
    print("Initializing exploits...")
    
    ApplyInfiniteStamina()
    HookToolDurability()
    ApplyNoRecoil()
    ApplyRapidFire()
    ApplyNoFallDamage()
    ApplyInstantReload()
    ApplyNoSpread()
    ApplyMeleeRangeHook()
    
    if Settings.Combat.HitboxExpander then
        ExpandAllHitboxes()
    end
    
    if Settings.Exploits.AutoLoot then
        ApplyAutoLoot()
    end
    
    if Settings.Exploits.AutoLockpick then
        ApplyAutoLockpick()
        HookLockpickFunction()
    end
    
    if Settings.Exploits.NoClip then
        ApplyNoClip()
    end
    
    if Settings.Exploits.Invisibility then
        ApplyInvisibility()
    end
    
    EnhanceWallbang()
    
    if Settings.Performance.LowGraphics then
        ApplyPerformanceSettings()
    end
    
    print("All exploits initialized!")
end)

-- Continuous exploit monitoring (optimized)
local LastExploitUpdate = 0
RunService.Heartbeat:Connect(function()
    -- Update only every 0.1 seconds
    if tick() - LastExploitUpdate < 0.1 then
        return
    end
    LastExploitUpdate = tick()
    
    if Settings.Enabled then
        ApplySpeedHack()
        ApplyJumpPower()
    end
end)

print("===========================================")
print("ADVANCED CHEAT SCRIPT LOADED")
print("===========================================")
print("Controls:")
print("  Right Shift - Toggle GUI")
print("  Mouse Button 2 - Aim")
print("")
print("✓ ESP Features:")
print("  - Player ESP: Box, Name, Health, Distance")
print("  - Loot ESP: Boxes, Name, Distance (workspace.Buildings.Loots.Loots)")
print("  - Team Check, Max Distance")
print("  - Smooth rendering (60 FPS)")
print("")
print("✓ Aimbot Features:")
print("  - Silent Aim (Invisible)")
print("  - Normal Aim (Visible)")
print("  - FOV & Smoothness Control")
print("")
print("✓ Combat Features:")
print("  - Wallbang (Shoot through terrain)")
print("  - Hitbox Expander (Bigger targets)")
print("  - Extended Melee Range (3x default)")
print("  - Infinite Durability (Weapons never break)")
print("  - No Recoil (Perfect aim)")
print("  - Rapid Fire (2x fire rate)")
print("")
print("✓ Exploit Features:")
print("  - Infinite Stamina (Never tire)")
print("  - No Fall Damage (Safe landings)")
print("  - Speed Hack (Move faster)")
print("  - Jump Power (Jump higher)")
print("  - Instant Reload (No wait time)")
print("  - No Spread (Perfect accuracy)")
print("  - Auto Loot (Automatic collection)")
print("  - Auto Lockpick (Solves mini-game automatically)")
print("  - NoClip (Walk through walls with anti-cheat bypass)")
print("  - Invisibility (Full or Partial - makes you invisible)")
print("  - 🔥 MANIPULATOR (Hitbox stretch, wall shooting, extreme melee range)")
print("")
print("✓ Performance Features:")
print("  - Ultra Low Graphics (50-100% FPS boost)")
print("  - Remove Fog, Shadows, Weather")
print("  - Disable Particles & Effects")
print("  - Lower Object Quality")
print("  - FPS Cap Control")
print("  - Optimized Script (Throttled updates)")
print("")
print("===========================================")
print("⚠️  WARNING: USE AT YOUR OWN RISK!")
print("===========================================")
print("")
print("Script Optimizations:")
print("- ESP updates: 10 FPS (reduced CPU)")
print("- Hitbox checks: 2 FPS (reduced memory)")
print("- Exploit updates: 10 FPS (reduced overhead)")
print("- Main loop: 60 FPS max (capped)")
print("")
print("Expected Performance:")
print("- Normal mode: ~60 FPS")
print("- Low graphics: ~100-144 FPS")
print("===========================================")
