local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Funktion zum Abrufen des Spielnamens
local function getGameName()
    return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
end

local Window = Fluent:CreateWindow({
    Title = getGameName() .. " by D3f4ult",
    SubTitle = "by D3f4ult",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl -- Used when theres no MinimizeKeybind
})

--Fluent provides Lucide Icons https://lucide.dev/icons/ for the tabs, icons are optional
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
    ESP = Window:AddTab({ Title = "ESP", Icon = "eye" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

do
    Fluent:Notify({
        Title = "Notification",
        Content = "This is a notification",
        SubContent = "SubContent", -- Optional
        Duration = 5 -- Set to nil to make the notification not disappear
    })

    -- Main Tab bleibt leer (nur die Überschrift)
    -- Hier können später Funktionen hinzugefügt werden
    
    -- Toggle für No Spread
    local originalValues = {} -- Speichert die ursprünglichen Werte
    
    local NoSpreadToggle = Tabs.Main:AddToggle("NoSpreadToggle", {
        Title = "No Spread", 
        Description = "Sets MaxSpread and MinSpread to 0",
        Default = false 
    })
    
    NoSpreadToggle:OnChanged(function()
        local player = game.Players.LocalPlayer
        local backpack = player.Backpack
        local character = player.Character
        
        if Options.NoSpreadToggle.Value then
            -- Toggle is activated - set values to 0
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:FindFirstChild("Configuration") and tool.Configuration.ClassName == "Configuration" then
                    local config = tool.Configuration
                    
                    -- Save original values if not already saved
                    if not originalValues[tool.Name] then
                        originalValues[tool.Name] = {}
                        if config:FindFirstChild("MaxSpread") then
                            originalValues[tool.Name].MaxSpread = config.MaxSpread.Value
                        end
                        if config:FindFirstChild("MinSpread") then
                            originalValues[tool.Name].MinSpread = config.MinSpread.Value
                        end
                    end
                    
                    -- Set values to 0
                    if config:FindFirstChild("MaxSpread") then
                        config.MaxSpread.Value = 0
                    end
                    if config:FindFirstChild("MinSpread") then
                        config.MinSpread.Value = 0
                    end
                end
            end
            
            -- Check Character as well (if tool is in hand)
            if character and character:FindFirstChild("Backpack") then
                for _, tool in pairs(character.Backpack:GetChildren()) do
                    if tool:FindFirstChild("Configuration") and tool.Configuration.ClassName == "Configuration" then
                        local config = tool.Configuration
                        
                        -- Save original values if not already saved
                        if not originalValues[tool.Name] then
                            originalValues[tool.Name] = {}
                            if config:FindFirstChild("MaxSpread") then
                                originalValues[tool.Name].MaxSpread = config.MaxSpread.Value
                            end
                            if config:FindFirstChild("MinSpread") then
                                originalValues[tool.Name].MinSpread = config.MinSpread.Value
                            end
                        end
                        
                        -- Set values to 0
                        if config:FindFirstChild("MaxSpread") then
                            config.MaxSpread.Value = 0
                        end
                        if config:FindFirstChild("MinSpread") then
                            config.MinSpread.Value = 0
                        end
                    end
                end
            end
            
            Fluent:Notify({
                Title = "No Spread",
                Content = "MaxSpread and MinSpread have been set to 0",
                Duration = 3
            })
        else
            -- Toggle is deactivated - restore original values
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:FindFirstChild("Configuration") and tool.Configuration.ClassName == "Configuration" and originalValues[tool.Name] then
                    local config = tool.Configuration
                    
                    -- Restore MaxSpread
                    if config:FindFirstChild("MaxSpread") and originalValues[tool.Name].MaxSpread then
                        config.MaxSpread.Value = originalValues[tool.Name].MaxSpread
                    end
                    
                    -- Restore MinSpread
                    if config:FindFirstChild("MinSpread") and originalValues[tool.Name].MinSpread then
                        config.MinSpread.Value = originalValues[tool.Name].MinSpread
                    end
                end
            end
            
            -- Check Character as well (if tool is in hand)
            if character and character:FindFirstChild("Backpack") then
                for _, tool in pairs(character.Backpack:GetChildren()) do
                    if tool:FindFirstChild("Configuration") and tool.Configuration.ClassName == "Configuration" and originalValues[tool.Name] then
                        local config = tool.Configuration
                        
                        -- Restore MaxSpread
                        if config:FindFirstChild("MaxSpread") and originalValues[tool.Name].MaxSpread then
                            config.MaxSpread.Value = originalValues[tool.Name].MaxSpread
                        end
                        
                        -- Restore MinSpread
                        if config:FindFirstChild("MinSpread") and originalValues[tool.Name].MinSpread then
                            config.MinSpread.Value = originalValues[tool.Name].MinSpread
                        end
                    end
                end
            end
            
            Fluent:Notify({
                Title = "No Spread",
                Content = "MaxSpread and MinSpread have been restored to original values",
                Duration = 3
            })
        end
    end)
    
    -- Toggle für No Headshot Cooldown
    local originalHeadshotValues = {} -- Speichert die ursprünglichen HeadshotCooldown Werte
    
    local NoHeadshotToggle = Tabs.Main:AddToggle("NoHeadshotToggle", {
        Title = "No Headshot Cooldown", 
        Description = "Sets HeadshotCooldown to 0",
        Default = false 
    })
    
    NoHeadshotToggle:OnChanged(function()
        local player = game.Players.LocalPlayer
        local backpack = player.Backpack
        local character = player.Character
        
        if Options.NoHeadshotToggle.Value then
            -- Toggle is activated - set HeadshotCooldown to 0
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:FindFirstChild("Configuration") and tool.Configuration.ClassName == "Configuration" then
                    local config = tool.Configuration
                    
                    -- Save original value if not already saved
                    if not originalHeadshotValues[tool.Name] then
                        if config:FindFirstChild("HeadshotCooldown") then
                            originalHeadshotValues[tool.Name] = config.HeadshotCooldown.Value
                        end
                    end
                    
                    -- Set HeadshotCooldown to 0
                    if config:FindFirstChild("HeadshotCooldown") then
                        config.HeadshotCooldown.Value = 0
                    end
                end
            end
            
            -- Check Character as well (if tool is in hand)
            if character and character:FindFirstChild("Backpack") then
                for _, tool in pairs(character.Backpack:GetChildren()) do
                    if tool:FindFirstChild("Configuration") and tool.Configuration.ClassName == "Configuration" then
                        local config = tool.Configuration
                        
                        -- Save original value if not already saved
                        if not originalHeadshotValues[tool.Name] then
                            if config:FindFirstChild("HeadshotCooldown") then
                                originalHeadshotValues[tool.Name] = config.HeadshotCooldown.Value
                            end
                        end
                        
                        -- Set HeadshotCooldown to 0
                        if config:FindFirstChild("HeadshotCooldown") then
                            config.HeadshotCooldown.Value = 0
                        end
                    end
                end
            end
            
            Fluent:Notify({
                Title = "No Headshot Cooldown",
                Content = "HeadshotCooldown has been set to 0",
                Duration = 3
            })
        else
            -- Toggle is deactivated - restore original HeadshotCooldown value
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:FindFirstChild("Configuration") and tool.Configuration.ClassName == "Configuration" and originalHeadshotValues[tool.Name] then
                    local config = tool.Configuration
                    
                    -- Restore HeadshotCooldown
                    if config:FindFirstChild("HeadshotCooldown") then
                        config.HeadshotCooldown.Value = originalHeadshotValues[tool.Name]
                    end
                end
            end
            
            -- Check Character as well (if tool is in hand)
            if character and character:FindFirstChild("Backpack") then
                for _, tool in pairs(character.Backpack:GetChildren()) do
                    if tool:FindFirstChild("Configuration") and tool.Configuration.ClassName == "Configuration" and originalHeadshotValues[tool.Name] then
                        local config = tool.Configuration
                        
                        -- Restore HeadshotCooldown
                        if config:FindFirstChild("HeadshotCooldown") then
                            config.HeadshotCooldown.Value = originalHeadshotValues[tool.Name]
                        end
                    end
                end
            end
            
            Fluent:Notify({
                Title = "No Headshot Cooldown",
                Content = "HeadshotCooldown has been restored to original value",
                Duration = 3
            })
        end
    end)
    
    -- Toggle für No Recoil
    local originalRecoilValues = {} -- Speichert die ursprünglichen Recoil Werte
    
    local NoRecoilToggle = Tabs.Main:AddToggle("NoRecoilToggle", {
        Title = "No Recoil", 
        Description = "Sets RecoilMax and RecoilMin to 0",
        Default = false 
    })
    
    NoRecoilToggle:OnChanged(function()
        local player = game.Players.LocalPlayer
        local backpack = player.Backpack
        local character = player.Character
        
        if Options.NoRecoilToggle.Value then
            -- Toggle is activated - set Recoil values to 0
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:FindFirstChild("Configuration") and tool.Configuration.ClassName == "Configuration" then
                    local config = tool.Configuration
                    
                    -- Save original values if not already saved
                    if not originalRecoilValues[tool.Name] then
                        originalRecoilValues[tool.Name] = {}
                        if config:FindFirstChild("RecoilMax") then
                            originalRecoilValues[tool.Name].RecoilMax = config.RecoilMax.Value
                        end
                        if config:FindFirstChild("RecoilMin") then
                            originalRecoilValues[tool.Name].RecoilMin = config.RecoilMin.Value
                        end
                    end
                    
                    -- Set Recoil values to 0
                    if config:FindFirstChild("RecoilMax") then
                        config.RecoilMax.Value = 0
                    end
                    if config:FindFirstChild("RecoilMin") then
                        config.RecoilMin.Value = 0
                    end
                end
            end
            
            -- Check Character as well (if tool is in hand)
            if character and character:FindFirstChild("Backpack") then
                for _, tool in pairs(character.Backpack:GetChildren()) do
                    if tool:FindFirstChild("Configuration") and tool.Configuration.ClassName == "Configuration" then
                        local config = tool.Configuration
                        
                        -- Save original values if not already saved
                        if not originalRecoilValues[tool.Name] then
                            originalRecoilValues[tool.Name] = {}
                            if config:FindFirstChild("RecoilMax") then
                                originalRecoilValues[tool.Name].RecoilMax = config.RecoilMax.Value
                            end
                            if config:FindFirstChild("RecoilMin") then
                                originalRecoilValues[tool.Name].RecoilMin = config.RecoilMin.Value
                            end
                        end
                        
                        -- Set Recoil values to 0
                        if config:FindFirstChild("RecoilMax") then
                            config.RecoilMax.Value = 0
                        end
                        if config:FindFirstChild("RecoilMin") then
                            config.RecoilMin.Value = 0
                        end
                    end
                end
            end
            
            Fluent:Notify({
                Title = "No Recoil",
                Content = "RecoilMax and RecoilMin have been set to 0",
                Duration = 3
            })
        else
            -- Toggle is deactivated - restore original Recoil values
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:FindFirstChild("Configuration") and tool.Configuration.ClassName == "Configuration" and originalRecoilValues[tool.Name] then
                    local config = tool.Configuration
                    
                    -- Restore RecoilMax
                    if config:FindFirstChild("RecoilMax") and originalRecoilValues[tool.Name].RecoilMax then
                        config.RecoilMax.Value = originalRecoilValues[tool.Name].RecoilMax
                    end
                    
                    -- Restore RecoilMin
                    if config:FindFirstChild("RecoilMin") and originalRecoilValues[tool.Name].RecoilMin then
                        config.RecoilMin.Value = originalRecoilValues[tool.Name].RecoilMin
                    end
                end
            end
            
            -- Check Character as well (if tool is in hand)
            if character and character:FindFirstChild("Backpack") then
                for _, tool in pairs(character.Backpack:GetChildren()) do
                    if tool:FindFirstChild("Configuration") and tool.Configuration.ClassName == "Configuration" and originalRecoilValues[tool.Name] then
                        local config = tool.Configuration
                        
                        -- Restore RecoilMax
                        if config:FindFirstChild("RecoilMax") and originalRecoilValues[tool.Name].RecoilMax then
                            config.RecoilMax.Value = originalRecoilValues[tool.Name].RecoilMax
                        end
                        
                        -- Restore RecoilMin
                        if config:FindFirstChild("RecoilMin") and originalRecoilValues[tool.Name].RecoilMin then
                            config.RecoilMin.Value = originalRecoilValues[tool.Name].RecoilMin
                        end
                    end
                end
            end
            
            Fluent:Notify({
                Title = "No Recoil",
                Content = "RecoilMax and RecoilMin have been restored to original values",
                Duration = 3
            })
        end
    end)
    
    -- Shot Cooldown Input und Toggle
    local originalShotCooldownValues = {} -- Speichert die ursprünglichen ShotCooldown Werte
    
    local ShotCooldownInput = Tabs.Main:AddInput("ShotCooldownInput", {
        Title = "Shot Cooldown",
        Default = "",
        Placeholder = "Enter cooldown value",
        Numeric = true, -- Only allows numbers
        Finished = false, -- Only calls callback when you press enter
        Callback = function(Value)
            print("Shot Cooldown Input changed:", Value)
        end
    })
    
    local ShotCooldownToggle = Tabs.Main:AddToggle("ShotCooldownToggle", {
        Title = "Apply Shot Cooldown", 
        Description = "Applies the Shot Cooldown value from the input",
        Default = false 
    })
    
    ShotCooldownToggle:OnChanged(function()
        local player = game.Players.LocalPlayer
        local backpack = player.Backpack
        local character = player.Character
        local inputValue = tonumber(ShotCooldownInput.Value) or 0
        
        if Options.ShotCooldownToggle.Value then
            -- Toggle is activated - set ShotCooldown to input value
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:FindFirstChild("Configuration") and tool.Configuration.ClassName == "Configuration" then
                    local config = tool.Configuration
                    
                    -- Save original value if not already saved
                    if not originalShotCooldownValues[tool.Name] then
                        if config:FindFirstChild("ShotCooldown") then
                            originalShotCooldownValues[tool.Name] = config.ShotCooldown.Value
                        end
                    end
                    
                    -- Set ShotCooldown to input value
                    if config:FindFirstChild("ShotCooldown") then
                        config.ShotCooldown.Value = inputValue
                    end
                end
            end
            
            -- Check Character as well (if tool is in hand)
            if character and character:FindFirstChild("Backpack") then
                for _, tool in pairs(character.Backpack:GetChildren()) do
                    if tool:FindFirstChild("Configuration") and tool.Configuration.ClassName == "Configuration" then
                        local config = tool.Configuration
                        
                        -- Save original value if not already saved
                        if not originalShotCooldownValues[tool.Name] then
                            if config:FindFirstChild("ShotCooldown") then
                                originalShotCooldownValues[tool.Name] = config.ShotCooldown.Value
                            end
                        end
                        
                        -- Set ShotCooldown to input value
                        if config:FindFirstChild("ShotCooldown") then
                            config.ShotCooldown.Value = inputValue
                        end
                    end
                end
            end
            
            Fluent:Notify({
                Title = "Shot Cooldown",
                Content = "ShotCooldown has been set to " .. inputValue,
                Duration = 3
            })
        else
            -- Toggle is deactivated - restore original ShotCooldown value
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:FindFirstChild("Configuration") and tool.Configuration.ClassName == "Configuration" and originalShotCooldownValues[tool.Name] then
                    local config = tool.Configuration
                    
                    -- Restore ShotCooldown
                    if config:FindFirstChild("ShotCooldown") then
                        config.ShotCooldown.Value = originalShotCooldownValues[tool.Name]
                    end
                end
            end
            
            -- Check Character as well (if tool is in hand)
            if character and character:FindFirstChild("Backpack") then
                for _, tool in pairs(character.Backpack:GetChildren()) do
                    if tool:FindFirstChild("Configuration") and tool.Configuration.ClassName == "Configuration" and originalShotCooldownValues[tool.Name] then
                        local config = tool.Configuration
                        
                        -- Restore ShotCooldown
                        if config:FindFirstChild("ShotCooldown") then
                            config.ShotCooldown.Value = originalShotCooldownValues[tool.Name]
                        end
                    end
                end
            end
            
            Fluent:Notify({
                Title = "Shot Cooldown",
                Content = "ShotCooldown has been restored to original value",
                Duration = 3
            })
        end
    end)
    
    -- Auto Reload Input und Toggle
    local autoReloadConnection = nil
    local lastReloadTime = 0
    
    local AutoReloadInput = Tabs.Main:AddInput("AutoReloadInput", {
        Title = "Auto Reload Cooldown", 
        Default = "1",
        Placeholder = "Enter cooldown in seconds",
        Numeric = true, -- Only allows numbers
        Finished = false, -- Only calls callback when you press enter
        Callback = function(Value)
            print("Auto Reload Cooldown Input changed:", Value)
        end
    })
    
    local AutoReloadToggle = Tabs.Main:AddToggle("AutoReloadToggle", {
        Title = "Auto Reload", 
        Description = "Automatically sends reload request",
        Default = false 
    })
    
    AutoReloadToggle:OnChanged(function()
        if Options.AutoReloadToggle.Value then
            -- Toggle is activated - start auto reload
            local cooldown = tonumber(AutoReloadInput.Value) or 1
            if cooldown < 0.1 then cooldown = 0.1 end -- Minimum 0.1 seconds
            
            autoReloadConnection = game:GetService("RunService").Heartbeat:Connect(function()
                local currentTime = tick()
                if currentTime - lastReloadTime >= cooldown then
                    local player = game.Players.LocalPlayer
                    local character = player.Character
                    
                                         if character and character:FindFirstChild("Backpack") then
                         local toolInHand = character.Backpack:FindFirstChildOfClass("Tool")
                         if toolInHand then
                             local args = {
                                 toolInHand
                             }
                             local success, error = pcall(function()
                                 game:GetService("ReplicatedStorage"):WaitForChild("WeaponsSystem"):WaitForChild("Network"):WaitForChild("WeaponReloadRequest"):FireServer(unpack(args))
                             end)
                             if success then
                                 lastReloadTime = currentTime
                             else
                                 print("Auto Reload Error:", error)
                             end
                         end
                     end
                end
            end)
            
            Fluent:Notify({
                Title = "Auto Reload",
                Content = "Auto Reload activated with " .. cooldown .. " second cooldown",
                Duration = 3
            })
        else
            -- Toggle is deactivated - stop auto reload
            if autoReloadConnection then
                autoReloadConnection:Disconnect()
                autoReloadConnection = nil
            end
            
            Fluent:Notify({
                Title = "Auto Reload",
                Content = "Auto Reload deactivated",
                Duration = 3
            })
        end
    end)

    -- ESP System
    local espEnabled = false
    local espConnections = {}
    local espObjects = {}
    
    -- ESP Main Toggle
    local ESPToggle = Tabs.ESP:AddToggle("ESPToggle", {
        Title = "ESP", 
        Description = "Enables Hitbox Highlight on all players",
        Default = false 
    })
    
    -- ESP Functions
    local function createESP(player)
        if not espEnabled or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
        
        local character = player.Character
        local humanoidRootPart = character.HumanoidRootPart
        local humanoid = character:FindFirstChild("Humanoid")
        
        if not humanoid then return end
        
        -- Create ESP Object (Highlight)
        local highlight = Instance.new("Highlight")
        highlight.FillColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
        highlight.FillTransparency = 0.3
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = character
        
        -- Set team color if available
        if player.Team then
            highlight.FillColor = player.Team.TeamColor.Color
        end
        
        espObjects[player] = highlight
    end
    
    local function removeESP(player)
        if espObjects[player] then
            espObjects[player]:Destroy()
            espObjects[player] = nil
        end
    end
    
    local function updateESP()
        if not espEnabled then return end
        
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer then
                createESP(player)
            end
        end
    end
    
    -- ESP Toggle Handler
    ESPToggle:OnChanged(function()
        espEnabled = Options.ESPToggle.Value
        
        if espEnabled then
            updateESP()
            
            -- Connect to player events
            espConnections.playerAdded = game.Players.PlayerAdded:Connect(function(player)
                if espEnabled then
                    player.CharacterAdded:Connect(function()
                        wait(1) -- Wait for character to fully load
                        createESP(player)
                    end)
                end
            end)
            
            espConnections.playerRemoving = game.Players.PlayerRemoving:Connect(function(player)
                removeESP(player)
            end)
            
            espConnections.characterAdded = game.Players.LocalPlayer.CharacterAdded:Connect(function()
                wait(1)
                updateESP()
            end)
            
            Fluent:Notify({
                Title = "ESP",
                Content = "Hitbox Highlight has been enabled",
                Duration = 3
            })
        else
            -- Disable ESP
            for _, player in pairs(game.Players:GetPlayers()) do
                removeESP(player)
            end
            
            -- Disconnect events
            for _, connection in pairs(espConnections) do
                if connection then connection:Disconnect() end
            end
            espConnections = {}
            
            Fluent:Notify({
                Title = "ESP",
                Content = "Hitbox Highlight has been disabled",
                Duration = 3
            })
        end
    end)

    -- Settings Tab bleibt unverändert
end


-- Addons:
-- SaveManager (Allows you to have a configuration system)
-- InterfaceManager (Allows you to have a interface managment system)

-- Hand the library over to our managers
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)
SaveManager:IgnoreThemeSettings()

-- You can add indexes of elements the save manager should ignore
SaveManager:SetIgnoreIndexes({})

-- use case for doing it this way:
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)


Window:SelectTab(1)

Fluent:Notify({
    Title = "Fluent",
    Content = "The script has been loaded.",
    Duration = 8
})

-- You can use the SaveManager:LoadAutoloadConfig() to load a config
-- which has been marked to be one that auto loads!
SaveManager:LoadAutoloadConfig()
