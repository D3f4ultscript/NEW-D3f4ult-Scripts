local KeySystem = {}
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

-- Configuration
local config = {
    title = "Key System",
    loadingText = "Checking game status...",
    keySystemText = "Enter your key to continue",
    getKeyButtonText = "Get Key",
    checkKeyButtonText = "Check Key",
    loadingDuration = 3,
    validKey = "dsgijkou4zt89234ndv",
    discordLink = "https://discord.gg/2ynN9zcVFk",
    -- Work.Ink integration
    useWorkInk = true,
    workInkApiKey = "a8158313-161a-45fb-abd1-35c9cf9dbbe7",
    workInkEndpoint = "https://work.ink/_api/v2/token/isValid/%s",
    -- Whitelisted Roblox Analytics Client IDs that automatically bypass the key system
    whitelistedClientIds = {
        "2B20B7A6-9BF5-483D-A133-5D4836E25527",
        -- weitere hier!
    }
}

-- Variable to track if key validation was successful
local keyValidated = false

-- Function to check if current player is whitelisted
function KeySystem:IsPlayerWhitelisted()
    local currentClientId = self:GetRobloxClientId()
    if not currentClientId then return false end
    
    for _, whitelistedClientId in ipairs(config.whitelistedClientIds) do
        if currentClientId == whitelistedClientId then
            return true
        end
    end
    
    return false
end

-- Function to get Roblox Analytics Client ID
function KeySystem:GetRobloxClientId()
    local success, clientId = pcall(function()
        if game and game:GetService("RbxAnalyticsService") then
            return game:GetService("RbxAnalyticsService"):GetClientId()
        end
        return nil
    end)
    
    if success and clientId then
        return clientId
    end
    
    return nil
end

-- Function to get the user's HWID
function KeySystem:GetHWID()
    local hwid = ""
    
    -- Try different methods to get HWID
    pcall(function()
        -- Method 1: Using Syn's HWID function
        if syn and syn.request then
            hwid = syn.crypt.hash(syn.crypt.custom.hwid(), "sha384")
        -- Method 2: Using exploit-specific HWID functions
        elseif getexecutorname then
            hwid = getexecutorname():gsub("%s+", "")
            if gethwid then
                hwid = gethwid()
            end
        -- Method 3: Using RobloxPlayerBeta path
        elseif game and game:GetService("RbxAnalyticsService") then
            hwid = game:GetService("RbxAnalyticsService"):GetClientId()
        -- Method 4: Using HTTP service
        elseif HttpService then
            hwid = HttpService:GenerateGUID(false)
        end
    end)
    
    -- Fallback to a generated GUID if HWID couldn't be obtained
    if hwid == "" then
        hwid = HttpService:GenerateGUID(false)
    end
    
    return hwid
end

-- Function to show notification
function KeySystem:ShowNotification(title, text, duration)
    local success = pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 3
        })
    end)
end

-- Function to open a link
function KeySystem:OpenLink(url)
    local success = pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Discord Link",
            Text = "Link copied: " .. url,
            Duration = 5
        })
        
        if setclipboard then
            setclipboard(url)
        end
    end)
end

-- Create UI
function KeySystem:CreateUI()
    -- Check if another KeySystem UI already exists and destroy it
    local existingUI = game.Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("D3f4ultKeySystem")
    if existingUI then
        existingUI:Destroy()
    end
    
    -- New UI based on provided design
    local D3f4ultKeySystem = Instance.new("ScreenGui")
    D3f4ultKeySystem.Name = "D3f4ultKeySystem"
    D3f4ultKeySystem.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    D3f4ultKeySystem.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Parent = D3f4ultKeySystem
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Main.BackgroundTransparency = 0.200
    Main.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Main.BorderSizePixel = 0
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.Size = UDim2.new(0.329103887, 0, 0.315500677, 0)

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = Main

    local Header = Instance.new("TextLabel")
    Header.Name = "Header"
    Header.Parent = Main
    Header.AnchorPoint = Vector2.new(0.5, 0.5)
    Header.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Header.BackgroundTransparency = 1.000
    Header.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Header.BorderSizePixel = 0
    Header.Position = UDim2.new(0.496987939, 0, 0.081521742, 0)
    Header.Size = UDim2.new(1, 0, 0.163043484, 0)
    Header.Font = Enum.Font.FredokaOne
    Header.Text = "D3f4ult Key System"
    Header.TextColor3 = Color3.fromRGB(255, 255, 255)
    Header.TextScaled = true
    Header.TextSize = 14.000
    Header.TextWrapped = true

    -- Header has no gradient animation anymore

    local Version = Instance.new("TextLabel")
    Version.Name = "Version"
    Version.Parent = Main
    Version.AnchorPoint = Vector2.new(0.5, 0.5)
    Version.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Version.BackgroundTransparency = 1.000
    Version.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Version.BorderSizePixel = 0
    Version.Position = UDim2.new(0.50000006, 0, 0.945652187, 0)
    Version.Size = UDim2.new(1, 0, 0.0928695649, 0)
    Version.Font = Enum.Font.FredokaOne
    Version.Text = "v2.4 | Discord: 2ynN9zcVFk"
    Version.TextColor3 = Color3.fromRGB(136, 136, 136)
    Version.TextScaled = true
    Version.TextSize = 14.000
    Version.TextWrapped = true

    local HeaderLine = Instance.new("Frame")
    HeaderLine.Name = "HeaderLine"
    HeaderLine.Parent = Main
    HeaderLine.AnchorPoint = Vector2.new(0.5, 0.5)
    HeaderLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    HeaderLine.BorderColor3 = Color3.fromRGB(0, 0, 0)
    HeaderLine.BorderSizePixel = 0
    HeaderLine.Position = UDim2.new(0.5, 0, 0.189739123, 0)
    HeaderLine.Size = UDim2.new(1, 0, 0.0163043477, 0)

    local UIGradient = Instance.new("UIGradient")
    UIGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0.00, 1.00), 
        NumberSequenceKeypoint.new(0.50, 0.00), 
        NumberSequenceKeypoint.new(1.00, 1.00)
    }
    UIGradient.Parent = HeaderLine

    local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
    UIAspectRatioConstraint.Parent = HeaderLine
    UIAspectRatioConstraint.AspectRatio = 110.667

    local Input = Instance.new("Frame")
    Input.Name = "Input"
    Input.Parent = Main
    Input.AnchorPoint = Vector2.new(0.5, 0.5)
    Input.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Input.BackgroundTransparency = 0.700
    Input.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Input.BorderSizePixel = 0
    Input.Position = UDim2.new(0.499999732, 0, 0.456521749, 0)
    Input.Size = UDim2.new(0.864457846, 0, 0.25, 0)

    local Input_2 = Instance.new("TextBox")
    Input_2.Name = "Input"
    Input_2.Parent = Input
    Input_2.AnchorPoint = Vector2.new(0.5, 0.5)
    Input_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Input_2.BackgroundTransparency = 1.000
    Input_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Input_2.BorderSizePixel = 0
    Input_2.Position = UDim2.new(0.5, 0, 0.5, 0)
    Input_2.Size = UDim2.new(1, 0, 1, 0)
    Input_2.Font = Enum.Font.FredokaOne
    Input_2.Text = ""
    Input_2.TextColor3 = Color3.fromRGB(180, 180, 180)
    Input_2.TextScaled = true
    Input_2.TextSize = 25.000
    Input_2.TextWrapped = true
    Input_2.ClearTextOnFocus = false

    local UITextSizeConstraint = Instance.new("UITextSizeConstraint")
    UITextSizeConstraint.Parent = Input_2
    UITextSizeConstraint.MaxTextSize = 25

    local UICorner_2 = Instance.new("UICorner")
    UICorner_2.CornerRadius = UDim.new(0, 12)
    UICorner_2.Parent = Input

    local UIAspectRatioConstraint_2 = Instance.new("UIAspectRatioConstraint")
    UIAspectRatioConstraint_2.Parent = Input
    UIAspectRatioConstraint_2.AspectRatio = 6.239

    local GetKey = Instance.new("TextButton")
    GetKey.Name = "Get Key"
    GetKey.Parent = Main
    GetKey.AnchorPoint = Vector2.new(0.5, 0.5)
    GetKey.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    GetKey.BackgroundTransparency = 0.700
    GetKey.BorderColor3 = Color3.fromRGB(0, 0, 0)
    GetKey.BorderSizePixel = 0
    GetKey.Position = UDim2.new(0.269578397, 0, 0.758152187, 0)
    GetKey.Size = UDim2.new(0.406626493, 0, 0.222826093, 0)
    GetKey.Font = Enum.Font.FredokaOne
    GetKey.Text = "Get Key"
    GetKey.TextColor3 = Color3.fromRGB(255, 255, 255)
    GetKey.TextScaled = false
    GetKey.TextSize = 20.000
    GetKey.TextWrapped = true

    local UICorner_3 = Instance.new("UICorner")
    UICorner_3.CornerRadius = UDim.new(0, 12)
    UICorner_3.Parent = GetKey

    local UITextSizeConstraint_2 = Instance.new("UITextSizeConstraint")
    UITextSizeConstraint_2.Parent = GetKey
    UITextSizeConstraint_2.MaxTextSize = 20

    -- Get Key button hover effects
    local getKeyStroke = Instance.new("UIStroke")
    getKeyStroke.Thickness = 0
    getKeyStroke.Color = Color3.fromRGB(255, 255, 255)
    getKeyStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    getKeyStroke.Parent = GetKey

    local getKeyTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    GetKey.MouseEnter:Connect(function()
        local textSizeTween = game:GetService("TweenService"):Create(UITextSizeConstraint_2, getKeyTweenInfo, {
            MaxTextSize = 24
        })
        local strokeTween = game:GetService("TweenService"):Create(getKeyStroke, getKeyTweenInfo, {
            Thickness = 3
        })
        textSizeTween:Play()
        strokeTween:Play()
    end)
    
    GetKey.MouseLeave:Connect(function()
        local textSizeBackTween = game:GetService("TweenService"):Create(UITextSizeConstraint_2, getKeyTweenInfo, {
            MaxTextSize = 20
        })
        local strokeBackTween = game:GetService("TweenService"):Create(getKeyStroke, getKeyTweenInfo, {
            Thickness = 0
        })
        textSizeBackTween:Play()
        strokeBackTween:Play()
    end)

    local CheckKey = Instance.new("TextButton")
    CheckKey.Name = "Check Key"
    CheckKey.Parent = Main
    CheckKey.AnchorPoint = Vector2.new(0.5, 0.5)
    CheckKey.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    CheckKey.BackgroundTransparency = 0.700
    CheckKey.BorderColor3 = Color3.fromRGB(0, 0, 0)
    CheckKey.BorderSizePixel = 0
    CheckKey.Position = UDim2.new(0.72740972, 0, 0.758152187, 0)
    CheckKey.Size = UDim2.new(0.406626493, 0, 0.222826093, 0)
    CheckKey.Font = Enum.Font.FredokaOne
    CheckKey.Text = "Check Key"
    CheckKey.TextColor3 = Color3.fromRGB(255, 255, 255)
    CheckKey.TextScaled = false
    CheckKey.TextSize = 20.000
    CheckKey.TextWrapped = true

    local UICorner_4 = Instance.new("UICorner")
    UICorner_4.CornerRadius = UDim.new(0, 12)
    UICorner_4.Parent = CheckKey

    local UITextSizeConstraint_3 = Instance.new("UITextSizeConstraint")
    UITextSizeConstraint_3.Parent = CheckKey
    UITextSizeConstraint_3.MaxTextSize = 20

    -- Check Key button hover effects
    local checkKeyStroke = Instance.new("UIStroke")
    checkKeyStroke.Thickness = 0
    checkKeyStroke.Color = Color3.fromRGB(255, 255, 255)
    checkKeyStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    checkKeyStroke.Parent = CheckKey

    local checkKeyTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    CheckKey.MouseEnter:Connect(function()
        local textSizeTween = game:GetService("TweenService"):Create(UITextSizeConstraint_3, checkKeyTweenInfo, {
            MaxTextSize = 24
        })
        local strokeTween = game:GetService("TweenService"):Create(checkKeyStroke, checkKeyTweenInfo, {
            Thickness = 3
        })
        textSizeTween:Play()
        strokeTween:Play()
    end)
    
    CheckKey.MouseLeave:Connect(function()
        local textSizeBackTween = game:GetService("TweenService"):Create(UITextSizeConstraint_3, checkKeyTweenInfo, {
            MaxTextSize = 20
        })
        local strokeBackTween = game:GetService("TweenService"):Create(checkKeyStroke, checkKeyTweenInfo, {
            Thickness = 0
        })
        textSizeBackTween:Play()
        strokeBackTween:Play()
    end)

    local UIAspectRatioConstraint_3 = Instance.new("UIAspectRatioConstraint")
    UIAspectRatioConstraint_3.Parent = Main
    UIAspectRatioConstraint_3.AspectRatio = 1.804

    local Close = Instance.new("TextButton")
    Close.Name = "Close"
    Close.Parent = Main
    Close.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Close.BackgroundTransparency = 1.000
    Close.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Close.BorderSizePixel = 0
    Close.Position = UDim2.new(0.903470397, 0, 0.0118414639, 0)
    Close.Size = UDim2.new(0.0896907672, 0, 0.161833346, 0)
    Close.Font = Enum.Font.FredokaOne
    Close.Text = "X"
    Close.TextColor3 = Color3.fromRGB(255, 255, 255)
    Close.TextScaled = true
    Close.TextSize = 14.000
    Close.TextWrapped = true

    local UICorner_5 = Instance.new("UICorner")
    UICorner_5.CornerRadius = UDim.new(0, 12)
    UICorner_5.Parent = Close

    local PlayerInfo = Instance.new("Frame")
    PlayerInfo.Name = "PlayerInfo"
    PlayerInfo.Parent = D3f4ultKeySystem
    PlayerInfo.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    PlayerInfo.BackgroundTransparency = 1.000
    PlayerInfo.BorderColor3 = Color3.fromRGB(0, 0, 0)
    PlayerInfo.BorderSizePixel = 0
    PlayerInfo.Position = UDim2.new(0, 20, 0, 20)
    PlayerInfo.Size = UDim2.new(0, 200, 0, 100)

    local UICorner_6 = Instance.new("UICorner")
    UICorner_6.CornerRadius = UDim.new(0, 12)
    UICorner_6.Parent = PlayerInfo

    local PlayerName = Instance.new("TextLabel")
    PlayerName.Name = "PlayerName"
    PlayerName.Parent = PlayerInfo
    PlayerName.AnchorPoint = Vector2.new(0.5, 0.5)
    PlayerName.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    PlayerName.BackgroundTransparency = 0.400
    PlayerName.BorderColor3 = Color3.fromRGB(0, 0, 0)
    PlayerName.BorderSizePixel = 0
    PlayerName.Position = UDim2.new(0.499925435, 0, 0.319732159, 0)
    PlayerName.Size = UDim2.new(0.896550298, 0, 0.382051587, 0)
    PlayerName.Font = Enum.Font.FredokaOne
    PlayerName.Text = "Hello [PlayerName]!"
    PlayerName.TextColor3 = Color3.fromRGB(255, 255, 255)
    PlayerName.TextScaled = true
    PlayerName.TextSize = 14.000
    PlayerName.TextWrapped = true

    local UICorner_7 = Instance.new("UICorner")
    UICorner_7.CornerRadius = UDim.new(0, 5)
    UICorner_7.Parent = PlayerName

    local PlayerExecutor = Instance.new("TextLabel")
    PlayerExecutor.Name = "PlayerExecutor"
    PlayerExecutor.Parent = PlayerInfo
    PlayerExecutor.AnchorPoint = Vector2.new(0.5, 0.5)
    PlayerExecutor.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    PlayerExecutor.BackgroundTransparency = 0.400
    PlayerExecutor.BorderColor3 = Color3.fromRGB(0, 0, 0)
    PlayerExecutor.BorderSizePixel = 0
    PlayerExecutor.Position = UDim2.new(0.425134867, 0, 0.680568814, 5)
    PlayerExecutor.Size = UDim2.new(0.748564899, 0, 0.344005555, 0)
    PlayerExecutor.Font = Enum.Font.FredokaOne
    PlayerExecutor.Text = "Executor: [PlayerExecutor]"
    PlayerExecutor.TextColor3 = Color3.fromRGB(255, 255, 255)
    PlayerExecutor.TextScaled = true
    PlayerExecutor.TextSize = 20.000
    PlayerExecutor.TextWrapped = true

    local UICorner_8 = Instance.new("UICorner")
    UICorner_8.CornerRadius = UDim.new(0, 5)
    UICorner_8.Parent = PlayerExecutor

    local UIAspectRatioConstraint_4 = Instance.new("UIAspectRatioConstraint")
    UIAspectRatioConstraint_4.Parent = PlayerInfo
    UIAspectRatioConstraint_4.AspectRatio = 2.880

    local GradientShine = Instance.new("Frame")
    GradientShine.Name = "GradientShine"
    GradientShine.Parent = Main
    GradientShine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    GradientShine.BorderColor3 = Color3.fromRGB(0, 0, 0)
    GradientShine.BorderSizePixel = 0
    GradientShine.Size = UDim2.new(1, 0, 1, 0)
    GradientShine.ZIndex = 0

    local UICorner_9 = Instance.new("UICorner")
    UICorner_9.CornerRadius = UDim.new(0, 12)
    UICorner_9.Parent = GradientShine

    local UIGradient_3 = Instance.new("UIGradient")
    UIGradient_3.Rotation = 50
    UIGradient_3.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 1.00), NumberSequenceKeypoint.new(0.49, 0.90), NumberSequenceKeypoint.new(1.00, 1.00)}
    UIGradient_3.Parent = GradientShine

    -- Close button functionality
    Close.MouseButton1Click:Connect(function()
        D3f4ultKeySystem:Destroy()
    end)

    -- Close button hover effects
    local closeTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    Close.MouseEnter:Connect(function()
        local textRedTween = game:GetService("TweenService"):Create(Close, closeTweenInfo, {
            TextColor3 = Color3.fromRGB(255, 0, 0)
        })
        local rotateTween = game:GetService("TweenService"):Create(Close, closeTweenInfo, {
            Rotation = 15
        })
        textRedTween:Play()
        rotateTween:Play()
    end)
    
    Close.MouseLeave:Connect(function()
        local textNormalTween = game:GetService("TweenService"):Create(Close, closeTweenInfo, {
            TextColor3 = Color3.fromRGB(255, 255, 255)
        })
        local rotateBackTween = game:GetService("TweenService"):Create(Close, closeTweenInfo, {
            Rotation = 0
        })
        textNormalTween:Play()
        rotateBackTween:Play()
    end)

    -- Populate player and executor information
    local player = game.Players.LocalPlayer
    if player then
        PlayerName.Text = "Hello " .. player.Name .. "!"
    end

    -- Try to get executor name
    local executorName = "Unknown"
    pcall(function()
        if getexecutorname then
            executorName = getexecutorname()
        end
    end)
    PlayerExecutor.Text = "Executor: " .. executorName

    -- Drag functionality
    local UserInputService = game:GetService("UserInputService")
    local dragging = false
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    Main.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    -- Return UI mapping to existing logic
    return {
        ScreenGui = D3f4ultKeySystem,
        KeySystemFrame = Main,
        KeyInputBox = Input_2,
        GetKeyButton = GetKey,
        CheckKeyButton = CheckKey
    }
end

-- Set the valid key
function KeySystem:SetValidKey(newKey)
    config.validKey = newKey
end

-- Get the current valid key
function KeySystem:GetValidKey()
    return config.validKey
end

-- Set the Discord link
function KeySystem:SetDiscordLink(newLink)
    config.discordLink = newLink
    if self.ui and self.ui.DiscordLinkLabel then
        self.ui.DiscordLinkLabel.Text = "Discord: " .. newLink
    end
end

-- Simulate loading process
function KeySystem:SimulateLoading(ui)
    -- Animate loading bar
    local loadingTween = TweenService:Create(
        ui.LoadingBarFill,
        TweenInfo.new(config.loadingDuration, Enum.EasingStyle.Linear),
        {Size = UDim2.new(1, 0, 1, 0)}
    )
    
    loadingTween:Play()
    
    -- Update percentage text
    local startTime = tick()
    local connection
    connection = RunService.RenderStepped:Connect(function()
        local elapsed = tick() - startTime
        local progress = math.min(elapsed / config.loadingDuration, 1)
        local percentage = math.floor(progress * 100)
        
        ui.StatusLabel.Text = percentage .. "%"
        
        if progress >= 1 then
            connection:Disconnect()
            self:ShowKeySystem(ui)
        end
    end)
end

-- Start the Key System
function KeySystem:Start(thread)
    -- Check if current player is whitelisted
    if self:IsPlayerWhitelisted() then
        self:ShowNotification("Instant Access", "You're on the whitelist! No key needed.", 4)
        
        -- Set keyValidated to true and wait a moment like normal key validation
        keyValidated = true
        wait(1) -- Same delay as normal key validation
        
        -- Resume the thread with keyValidated = true
        if thread then
            coroutine.resume(thread, true)
        end
        
        return true
    end
    
    local ui = self:CreateUI()
    self.ui = ui
    
    -- Show version notification at start
    self:ShowNotification("KeySystem Version", "v2.4", 3)
    
    -- Parent ScreenGui to PlayerGui
    local player = Players.LocalPlayer
    if player then
        ui.ScreenGui.Parent = player:WaitForChild("PlayerGui")
    else
        ui.ScreenGui.Parent = game:GetService("CoreGui")
    end
    
    -- Set up button functionality
    ui.GetKeyButton.MouseButton1Click:Connect(function()
        self:OpenLink(config.discordLink)
    end)
    
    ui.CheckKeyButton.MouseButton1Click:Connect(function()
        local keyInput = ui.KeyInputBox.Text or ""
        if keyInput == "" then
            self:ShowNotification("Error", "Please enter a key!", 3)
            return
        end
        self:ValidateKey(keyInput, ui, thread)
    end)
    
    return ui
end

-- Show the key system UI
function KeySystem:ShowKeySystem(ui)
    ui.LoadingFrame.Visible = false
    ui.KeySystemFrame.Visible = true
    
    -- Add a nice fade-in effect
    ui.KeySystemFrame.BackgroundTransparency = 1
    for i = 1, 0, -0.1 do
        ui.KeySystemFrame.BackgroundTransparency = i
        wait(0.02)
    end
    ui.KeySystemFrame.BackgroundTransparency = 0
    
    -- Show notification that key system is ready
    self:ShowNotification("Key System", "Please enter your key to continue", 3)
end

-- Function to execute after successful key validation
function KeySystem:OnKeySuccess(ui, thread)
    -- Show notification that the script is loading
    self:ShowNotification("Success", "Key valid! Loading script...", 3)
    
    -- Wait a moment before removing UI
    wait(1)
    
    -- Remove UI
    ui.ScreenGui:Destroy()
    
    -- Set keyValidated to true
    keyValidated = true
    
    -- Resume the thread with keyValidated = true
    if thread then
        coroutine.resume(thread, true)
    end
end

-- Validate the key
function KeySystem:ValidateKey(key, ui, thread)
    -- Show checking notification
    self:ShowNotification("Key Check", "Checking key...", 2)
    
    wait(0.25)
    
    -- Sanitize input by removing all whitespace
    local enteredKey = tostring(key or ""):gsub("%s+", "")
    local configuredKey = tostring(config.validKey or ""):gsub("%s+", "")

    local isValid = false

    -- Prefer work.ink validation when enabled
    if config.useWorkInk then
        local ok, result = pcall(function()
            return self:ValidateWithWorkInk(enteredKey)
        end)
        if ok and result == true then
            isValid = true
        end
    end

    -- Fallback to local key if not valid yet
    if not isValid and configuredKey ~= "" and enteredKey == configuredKey then
        isValid = true
    end
    
    if isValid then
        self:OnKeySuccess(ui, thread)
    else
        self:ShowNotification("Error", "Invalid key! Please try again.", 3)
    end
end

-- Lightweight HTTP request helper (supports multiple executors)
local function performRequest(url, method, headers)
    method = method or "GET"
    headers = headers or {}
    -- prefer executor request if available
    if syn and syn.request then
        local ok, res = pcall(function()
            return syn.request({Url = url, Method = method, Headers = headers})
        end)
        if not ok or not res then return false, 0, "" end
        return (res.Success ~= false) and true or (res.StatusCode and res.StatusCode < 400), res.StatusCode or 0, res.Body or ""
    elseif http_request then
        local ok, res = pcall(function()
            return http_request({Url = url, Method = method, Headers = headers})
        end)
        if not ok or not res then return false, 0, "" end
        return (res.StatusCode or 0) < 400, res.StatusCode or 0, res.Body or ""
    elseif request then
        local ok, res = pcall(function()
            return request({Url = url, Method = method, Headers = headers})
        end)
        if not ok or not res then return false, 0, "" end
        return (res.StatusCode or 0) < 400, res.StatusCode or 0, res.Body or ""
    else
        local ok, res = pcall(function()
            return HttpService:RequestAsync({Url = url, Method = method, Headers = headers})
        end)
        if not ok or not res then return false, 0, "" end
        return res.Success, res.StatusCode or 0, res.Body or ""
    end
end

-- Validate using work.ink API
function KeySystem:ValidateWithWorkInk(token)
    if not config.useWorkInk then return false end
    local trimmedToken = tostring(token or ""):gsub("%s+", "")
    if trimmedToken == "" then return false end

    local endpoint = string.format(config.workInkEndpoint or "https://work.ink/_api/v2/token/isValid/%s", trimmedToken)
    local headers = { ["Content-Type"] = "application/json" }
    if config.workInkApiKey and #config.workInkApiKey > 0 then
        headers["Authorization"] = "Bearer " .. config.workInkApiKey
        headers["x-api-key"] = config.workInkApiKey -- try both schemes for compatibility
    end

    local ok, status, body = performRequest(endpoint, "GET", headers)
    if not ok then return false end

    local success, data = pcall(function()
        return HttpService:JSONDecode(body)
    end)
    if not success or type(data) ~= "table" then
        return false
    end

    if data.valid == true then
        return true
    end
    return false
end

-- Add a Client ID to the whitelist
function KeySystem:AddWhitelistedClientId(clientId)
    if clientId and type(clientId) == "string" and clientId ~= "" then
        -- Check if Client ID already exists
        for _, existingClientId in ipairs(config.whitelistedClientIds) do
            if existingClientId == clientId then
                return false
            end
        end
        
        table.insert(config.whitelistedClientIds, clientId)
        return true
    end
    return false
end

-- Remove a Client ID from the whitelist
function KeySystem:RemoveWhitelistedClientId(clientId)
    for i, whitelistedClientId in ipairs(config.whitelistedClientIds) do
        if whitelistedClientId == clientId then
            table.remove(config.whitelistedClientIds, i)
            return true
        end
    end
    return false
end

-- Get all whitelisted Client IDs
function KeySystem:GetWhitelistedClientIds()
    return config.whitelistedClientIds
end

-- Check if a specific Client ID is whitelisted
function KeySystem:IsClientIdWhitelisted(clientId)
    for _, whitelistedClientId in ipairs(config.whitelistedClientIds) do
        if whitelistedClientId == clientId then
            return true
        end
    end
    return false
end

-- Modify the ModuleFunction to show both windows simultaneously
local function ModuleFunction()
    keyValidated = false
    local thread = coroutine.running()
    
    -- Start KeySystem
    local keySystem = KeySystem:Start(thread)
    
    -- If KeySystem returned true (whitelisted), don't wait for yield
    if keySystem == true then
        return true
    end
    
    local result = coroutine.yield()
    return result
end

-- Prüfe, ob das Skript direkt ausgeführt wird oder als Modul geladen wird
local isModuleScript = getfenv(1).script and getfenv(1).script:IsA("ModuleScript")

-- Wenn es als Modul geladen wird, gib die Funktion zurück
if isModuleScript or getgenv().KeySystemAsModule then
    return ModuleFunction
else
    keyValidated = false
    
    local success, result = pcall(function()
        local thread = coroutine.create(function()
            local keySystemResult = KeySystem:Start(coroutine.running())
            -- If KeySystem returned true (whitelisted), return immediately
            if keySystemResult == true then
                return true
            end
            return coroutine.yield()
        end)
        
        coroutine.resume(thread)
        
        while not keyValidated do
            wait(0.1)
        end
        
        return true
    end)
    
    if not success then
        warn("KeySystem Error: " .. tostring(result))
    end
    
    return ModuleFunction
end 