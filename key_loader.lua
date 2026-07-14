-- Advanced Key System Loader with Game Selection
-- Made with ❤️ for Roblox Community

local GITHUB_USERNAME = "iriska222-2"  -- Замените на ваш GitHub username
local REPOSITORY_NAME = "checkads"  -- Замените на название репозитория
local BRANCH = "main"

-- Services
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- Configuration URLs
local KEYS_URL = "https://github.com/iriska222-2/checkads/releases/download/lua/keys.json"

-- Script URLs
local HAVOC_SCRIPT_URL = "https://github.com/iriska222-2/checkads/releases/download/havoc/havoc.lua"

-- Saved Key Storage
local SavedKeyFile = "CheatLoader_Key.txt"

-- Game Scripts Configuration
local GameScripts = {
    {
        Name = "Havoc",
        Image = "rbxassetid://0",
        ScriptURL = HAVOC_SCRIPT_URL,
        Description = "Advanced cheat with ESP, Aimbot, Combat features"
    },
    -- Добавьте больше игр здесь:
    -- {
    --     Name = "Game Name",
    --     Image = "rbxassetid://ID",
    --     ScriptURL = "https://your-url-here.lua",
    --     Description = "Description"
    -- }
}

-- UI Variables
local ScreenGui
local KeyFrame
local MainFrame
local KeyExpirationTime = 0
local TimerRunning = false

-- Utility Functions
local function SaveKey(key, expiration)
    writefile(SavedKeyFile, HttpService:JSONEncode({
        key = key,
        expiration = expiration,
        hwid = game:GetService("RbxAnalyticsService"):GetClientId()
    }))
end

local function LoadSavedKey()
    if isfile and isfile(SavedKeyFile) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(SavedKeyFile))
        end)
        
        if success and data then
            local currentHWID = game:GetService("RbxAnalyticsService"):GetClientId()
            if data.hwid == currentHWID then
                return data.key, data.expiration
            end
        end
    end
    return nil, nil
end

local function Notify(title, text, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title;
        Text = text;
        Duration = duration or 3;
    })
end

local function CreateTween(object, properties, duration, easingStyle, easingDirection)
    local tweenInfo = TweenInfo.new(
        duration or 0.3,
        easingStyle or Enum.EasingStyle.Quad,
        easingDirection or Enum.EasingDirection.Out
    )
    return TweenService:Create(object, tweenInfo, properties)
end

-- Fetch and Validate Key
local function ValidateKey(inputKey)
    local success, response = pcall(function()
        return game:HttpGet(KEYS_URL)
    end)
    
    if not success then
        return false, "Failed to connect to key server"
    end
    
    local keysData
    local parseSuccess, parseResult = pcall(function()
        return HttpService:JSONDecode(response)
    end)
    
    if not parseSuccess then
        return false, "Failed to parse key data"
    end
    
    keysData = parseResult
    
    -- Validate key
    for _, keyData in pairs(keysData.keys or {}) do
        if keyData.key == inputKey then
            if keyData.active then
                local currentTime = os.time()
                if currentTime < keyData.expiration then
                    return true, keyData.expiration
                else
                    return false, "Key has expired"
                end
            else
                return false, "Key has been revoked"
            end
        end
    end
    
    return false, "Invalid key"
end

-- Timer Update
local function UpdateTimer()
    while TimerRunning do
        local currentTime = os.time()
        local timeRemaining = KeyExpirationTime - currentTime
        
        if timeRemaining <= 0 then
            Notify("Key Expired", "Your key has expired!", 5)
            if MainFrame then
                MainFrame.Visible = false
            end
            if KeyFrame then
                KeyFrame.Visible = true
            end
            TimerRunning = false
            break
        end
        
        local days = math.floor(timeRemaining / 86400)
        local hours = math.floor((timeRemaining % 86400) / 3600)
        local minutes = math.floor((timeRemaining % 3600) / 60)
        local seconds = timeRemaining % 60
        
        if MainFrame and MainFrame:FindFirstChild("TimerLabel") then
            MainFrame.TimerLabel.Text = string.format(
                "Key Expires: %dd %dh %dm %ds",
                days, hours, minutes, seconds
            )
        end
        
        wait(1)
    end
end

-- Load Script for Game
local function LoadGameScript(scriptURL)
    Notify("Loading", "Loading script...", 2)
    
    local success, scriptContent = pcall(function()
        return game:HttpGet(scriptURL)
    end)
    
    if success and scriptContent then
        local executeSuccess, executeError = pcall(function()
            loadstring(scriptContent)()
        end)
        
        if executeSuccess then
            Notify("Success", "Script loaded successfully!", 3)
            if ScreenGui then
                ScreenGui:Destroy()
            end
        else
            Notify("Error", "Failed to execute script", 5)
            warn("Execution Error:", executeError)
        end
    else
        Notify("Error", "Failed to load script from server", 5)
        warn("Load Error:", scriptContent)
    end
end

-- Create Key Input UI
local function CreateKeyUI()
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "KeyLoaderGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = CoreGui
    
    -- Blur Background
    local BlurFrame = Instance.new("Frame")
    BlurFrame.Name = "BlurFrame"
    BlurFrame.Size = UDim2.new(1, 0, 1, 0)
    BlurFrame.Position = UDim2.new(0, 0, 0, 0)
    BlurFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    BlurFrame.BackgroundTransparency = 0.5
    BlurFrame.BorderSizePixel = 0
    BlurFrame.Parent = ScreenGui
    
    -- Key Frame
    KeyFrame = Instance.new("Frame")
    KeyFrame.Name = "KeyFrame"
    KeyFrame.Size = UDim2.new(0, 400, 0, 250)
    KeyFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
    KeyFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    KeyFrame.BorderSizePixel = 0
    KeyFrame.Parent = ScreenGui
    
    local KeyCorner = Instance.new("UICorner")
    KeyCorner.CornerRadius = UDim.new(0, 12)
    KeyCorner.Parent = KeyFrame
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    Title.Text = "🔐 Key System"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 24
    Title.Font = Enum.Font.GothamBold
    Title.Parent = KeyFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = Title
    
    -- Subtitle
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Name = "Subtitle"
    Subtitle.Size = UDim2.new(1, -40, 0, 30)
    Subtitle.Position = UDim2.new(0, 20, 0, 60)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "Enter your key to continue"
    Subtitle.TextColor3 = Color3.fromRGB(180, 180, 190)
    Subtitle.TextSize = 14
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    Subtitle.Parent = KeyFrame
    
    -- Key Input Box
    local KeyInput = Instance.new("TextBox")
    KeyInput.Name = "KeyInput"
    KeyInput.Size = UDim2.new(1, -40, 0, 45)
    KeyInput.Position = UDim2.new(0, 20, 0, 100)
    KeyInput.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    KeyInput.BorderSizePixel = 0
    KeyInput.Text = ""
    KeyInput.PlaceholderText = "Enter your key here..."
    KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
    KeyInput.TextSize = 16
    KeyInput.Font = Enum.Font.Gotham
    KeyInput.ClearTextOnFocus = false
    KeyInput.Parent = KeyFrame
    
    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 8)
    InputCorner.Parent = KeyInput
    
    local InputPadding = Instance.new("UIPadding")
    InputPadding.PaddingLeft = UDim.new(0, 15)
    InputPadding.Parent = KeyInput
    
    -- Submit Button
    local SubmitButton = Instance.new("TextButton")
    SubmitButton.Name = "SubmitButton"
    SubmitButton.Size = UDim2.new(1, -40, 0, 45)
    SubmitButton.Position = UDim2.new(0, 20, 0, 160)
    SubmitButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    SubmitButton.BorderSizePixel = 0
    SubmitButton.Text = "Verify Key"
    SubmitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SubmitButton.TextSize = 18
    SubmitButton.Font = Enum.Font.GothamBold
    SubmitButton.Parent = KeyFrame
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 8)
    ButtonCorner.Parent = SubmitButton
    
    -- Get Key Button
    local GetKeyButton = Instance.new("TextButton")
    GetKeyButton.Name = "GetKeyButton"
    GetKeyButton.Size = UDim2.new(1, -40, 0, 30)
    GetKeyButton.Position = UDim2.new(0, 20, 0, 215)
    GetKeyButton.BackgroundTransparency = 1
    GetKeyButton.Text = "📋 How to get a key?"
    GetKeyButton.TextColor3 = Color3.fromRGB(0, 150, 255)
    GetKeyButton.TextSize = 14
    GetKeyButton.Font = Enum.Font.Gotham
    GetKeyButton.Parent = KeyFrame
    
    -- Button Hover Effect
    SubmitButton.MouseEnter:Connect(function()
        CreateTween(SubmitButton, {BackgroundColor3 = Color3.fromRGB(0, 140, 255)}, 0.2):Play()
    end)
    
    SubmitButton.MouseLeave:Connect(function()
        CreateTween(SubmitButton, {BackgroundColor3 = Color3.fromRGB(0, 120, 255)}, 0.2):Play()
    end)
    
    -- Submit Button Click
    SubmitButton.MouseButton1Click:Connect(function()
        local key = KeyInput.Text
        
        if key == "" then
            Notify("Error", "Please enter a key", 3)
            return
        end
        
        SubmitButton.Text = "Verifying..."
        SubmitButton.BackgroundColor3 = Color3.fromRGB(100, 100, 110)
        
        local isValid, result = ValidateKey(key)
        
        if isValid then
            KeyExpirationTime = result
            SaveKey(key, result)
            Notify("Success", "Key verified successfully!", 3)
            
            KeyFrame.Visible = false
            CreateMainUI()
        else
            Notify("Error", result, 5)
            SubmitButton.Text = "Verify Key"
            SubmitButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
            KeyInput.Text = ""
        end
    end)
    
    -- Get Key Button Click
    GetKeyButton.MouseButton1Click:Connect(function()
        local keyURL = string.format(
            "https://github.com/%s/%s#getting-a-key",
            GITHUB_USERNAME, REPOSITORY_NAME
        )
        Notify("Info", "Check your GitHub repository for key info", 5)
        setclipboard(keyURL)
    end)
    
    -- Enter key press
    KeyInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            SubmitButton.MouseButton1Click:Fire()
        end
    end)
    
    -- Animation
    KeyFrame.Size = UDim2.new(0, 0, 0, 0)
    KeyFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    CreateTween(KeyFrame, {
        Size = UDim2.new(0, 400, 0, 250),
        Position = UDim2.new(0.5, -200, 0.5, -125)
    }, 0.5, Enum.EasingStyle.Back):Play()
end

-- Create Main UI (Game Selection)
function CreateMainUI()
    MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 600, 0, 450)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -225)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame
    
    -- Top Bar
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 60)
    TopBar.Position = UDim2.new(0, 0, 0, 0)
    TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame
    
    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 12)
    TopCorner.Parent = TopBar
    
    -- Title
    local MainTitle = Instance.new("TextLabel")
    MainTitle.Name = "MainTitle"
    MainTitle.Size = UDim2.new(0, 300, 0, 30)
    MainTitle.Position = UDim2.new(0, 20, 0, 10)
    MainTitle.BackgroundTransparency = 1
    MainTitle.Text = "🎮 Game Selection"
    MainTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    MainTitle.TextSize = 20
    MainTitle.Font = Enum.Font.GothamBold
    MainTitle.TextXAlignment = Enum.TextXAlignment.Left
    MainTitle.Parent = TopBar
    
    -- Timer Label
    local TimerLabel = Instance.new("TextLabel")
    TimerLabel.Name = "TimerLabel"
    TimerLabel.Size = UDim2.new(1, -40, 0, 20)
    TimerLabel.Position = UDim2.new(0, 20, 0, 35)
    TimerLabel.BackgroundTransparency = 1
    TimerLabel.Text = "Key Expires: Loading..."
    TimerLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    TimerLabel.TextSize = 12
    TimerLabel.Font = Enum.Font.Gotham
    TimerLabel.TextXAlignment = Enum.TextXAlignment.Left
    TimerLabel.Parent = TopBar
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 40, 0, 40)
    CloseButton.Position = UDim2.new(1, -50, 0, 10)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    CloseButton.BorderSizePixel = 0
    CloseButton.Text = "✕"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 20
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Parent = TopBar
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 8)
    CloseCorner.Parent = CloseButton
    
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
        TimerRunning = false
    end)
    
    -- Games Container
    local GamesContainer = Instance.new("ScrollingFrame")
    GamesContainer.Name = "GamesContainer"
    GamesContainer.Size = UDim2.new(1, -40, 1, -100)
    GamesContainer.Position = UDim2.new(0, 20, 0, 70)
    GamesContainer.BackgroundTransparency = 1
    GamesContainer.BorderSizePixel = 0
    GamesContainer.ScrollBarThickness = 6
    GamesContainer.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
    GamesContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    GamesContainer.Parent = MainFrame
    
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Padding = UDim.new(0, 15)
    ListLayout.Parent = GamesContainer
    
    -- Create Game Cards
    for index, gameData in ipairs(GameScripts) do
        local GameCard = Instance.new("Frame")
        GameCard.Name = "GameCard_" .. gameData.Name
        GameCard.Size = UDim2.new(1, 0, 0, 100)
        GameCard.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        GameCard.BorderSizePixel = 0
        GameCard.Parent = GamesContainer
        
        local CardCorner = Instance.new("UICorner")
        CardCorner.CornerRadius = UDim.new(0, 10)
        CardCorner.Parent = GameCard
        
        -- Game Icon (optional)
        local GameIcon = Instance.new("ImageLabel")
        GameIcon.Name = "GameIcon"
        GameIcon.Size = UDim2.new(0, 80, 0, 80)
        GameIcon.Position = UDim2.new(0, 10, 0, 10)
        GameIcon.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
        GameIcon.BorderSizePixel = 0
        GameIcon.Image = gameData.Image
        GameIcon.ScaleType = Enum.ScaleType.Fit
        GameIcon.Parent = GameCard
        
        local IconCorner = Instance.new("UICorner")
        IconCorner.CornerRadius = UDim.new(0, 8)
        IconCorner.Parent = GameIcon
        
        -- Game Name
        local GameName = Instance.new("TextLabel")
        GameName.Name = "GameName"
        GameName.Size = UDim2.new(1, -180, 0, 25)
        GameName.Position = UDim2.new(0, 100, 0, 15)
        GameName.BackgroundTransparency = 1
        GameName.Text = gameData.Name
        GameName.TextColor3 = Color3.fromRGB(255, 255, 255)
        GameName.TextSize = 18
        GameName.Font = Enum.Font.GothamBold
        GameName.TextXAlignment = Enum.TextXAlignment.Left
        GameName.Parent = GameCard
        
        -- Game Description
        local GameDesc = Instance.new("TextLabel")
        GameDesc.Name = "GameDesc"
        GameDesc.Size = UDim2.new(1, -180, 0, 40)
        GameDesc.Position = UDim2.new(0, 100, 0, 40)
        GameDesc.BackgroundTransparency = 1
        GameDesc.Text = gameData.Description
        GameDesc.TextColor3 = Color3.fromRGB(180, 180, 190)
        GameDesc.TextSize = 12
        GameDesc.Font = Enum.Font.Gotham
        GameDesc.TextXAlignment = Enum.TextXAlignment.Left
        GameDesc.TextWrapped = true
        GameDesc.Parent = GameCard
        
        -- Launch Button
        local LaunchButton = Instance.new("TextButton")
        LaunchButton.Name = "LaunchButton"
        LaunchButton.Size = UDim2.new(0, 100, 0, 35)
        LaunchButton.Position = UDim2.new(1, -110, 0.5, -17.5)
        LaunchButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        LaunchButton.BorderSizePixel = 0
        LaunchButton.Text = "Launch"
        LaunchButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        LaunchButton.TextSize = 16
        LaunchButton.Font = Enum.Font.GothamBold
        LaunchButton.Parent = GameCard
        
        local LaunchCorner = Instance.new("UICorner")
        LaunchCorner.CornerRadius = UDim.new(0, 8)
        LaunchCorner.Parent = LaunchButton
        
        -- Button Hover
        LaunchButton.MouseEnter:Connect(function()
            CreateTween(LaunchButton, {BackgroundColor3 = Color3.fromRGB(0, 140, 255)}, 0.2):Play()
            CreateTween(GameCard, {BackgroundColor3 = Color3.fromRGB(40, 40, 55)}, 0.2):Play()
        end)
        
        LaunchButton.MouseLeave:Connect(function()
            CreateTween(LaunchButton, {BackgroundColor3 = Color3.fromRGB(0, 120, 255)}, 0.2):Play()
            CreateTween(GameCard, {BackgroundColor3 = Color3.fromRGB(35, 35, 50)}, 0.2):Play()
        end)
        
        -- Launch Click
        LaunchButton.MouseButton1Click:Connect(function()
            LoadGameScript(gameData.ScriptURL)
        end)
    end
    
    -- Update canvas size
    GamesContainer.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)
    
    -- Start Timer
    TimerRunning = true
    spawn(UpdateTimer)
    
    -- Animation
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    CreateTween(MainFrame, {
        Size = UDim2.new(0, 600, 0, 450),
        Position = UDim2.new(0.5, -300, 0.5, -225)
    }, 0.5, Enum.EasingStyle.Back):Play()
end

-- Initialize
local function Initialize()
    Notify("Key System", "Loading key system...", 2)
    
    -- Check for saved key
    local savedKey, savedExpiration = LoadSavedKey()
    
    if savedKey and savedExpiration then
        local currentTime = os.time()
        if currentTime < savedExpiration then
            local isValid = ValidateKey(savedKey)
            if isValid then
                KeyExpirationTime = savedExpiration
                CreateKeyUI()
                KeyFrame.Visible = false
                CreateMainUI()
                Notify("Welcome Back", "Key loaded from cache!", 3)
                return
            end
        end
    end
    
    -- Show key input
    CreateKeyUI()
end

-- Run
Initialize()
