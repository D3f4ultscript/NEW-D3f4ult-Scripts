-- Load and execute KeySystem
getgenv().KeySystemAsModule = true
local KeySystem = loadstring(game:HttpGet("https://raw.githubusercontent.com/D3f4ultscript/NEW-D3f4ult-Scripts/refs/heads/main/KeySystem.lua"))()

-- Only continue if KeySystem was successful
if not KeySystem() then
    return
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

-- Get game name
local gameName = "Plant Farming"
pcall(function()
    local success, gameInfo = pcall(function()
        return MarketplaceService:GetProductInfo(game.PlaceId)
    end)
    if success and gameInfo then
        gameName = gameInfo.Name
    end
end)

-- Import the UI module with correct paths
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Create window
local Window = Fluent:CreateWindow({
    Title = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name,
    SubTitle = "by D3f4ult",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
	Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Add Changelog tab at the top
local ChangelogTab = Window:AddTab({ Title = "Changelog", Icon = "book-open" })
ChangelogTab:AddParagraph({
	Title = "New",
	Content = "Performance dropdown (Normal/Fast/Super Fast). Save/Teleport Position buttons in Misc."
})
ChangelogTab:AddParagraph({
	Title = "Changed",
	Content = "Event teleport is now working in all future events, and I removed some teleport buttons because they were useless."
})
ChangelogTab:AddParagraph({
	Title = "Note",
	Content = "If something is missing or you find any bugs, please report them on Discord."
})

-- Create tabs
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "leaf" }),
    Event = Window:AddTab({ Title = "Event", Icon = "calendar" }),
    GUIs = Window:AddTab({ Title = "GUIs", Icon = "monitor" }),
	Teleport = Window:AddTab({ Title = "Teleport", Icon = "navigation" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "server" }),
	Performance = Window:AddTab({ Title = "Performance", Icon = "activity" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

-- Variables
local isAuraFarmEnabled = false
local isAutoTpFarmEnabled = false
local isAutoSellEnabled = false
local auraFarmConnection = nil
local autoTpFarmConnection = nil
local autoSellConnection = nil
local noclipConnection = nil
local shouldStop = false
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local currentSeedType = "Carrot Seed" -- Default seed type
local playerFarm = nil -- Will store the player's farm
local inventoryThreshold = 0 -- Default inventory threshold for auto sell (changed to 0)
local guiButtons = {} -- Store references to GUI buttons
local lastAutoSellTime = 0 -- Track when the last auto sell occurred
local lastPlayerPosition = nil -- Store the player's position before teleporting
local webhookUrl = "https://discord.com/api/webhooks/1383748535979085875/4yfjv4fELmeYvsL6X7VAtpW3POdStiLvNvAB4gNkbvIP2mKvQakLNHyrMmKIRBpYcoim"
local lastEventTime = 0
local eventCooldown = 5 -- Cooldown in seconds to prevent spam

-- Character modification variables
local isCharacterFrozen = false
local isAntiAFKEnabled = false
local isTeleportEnabled = false
local isInfiniteJumpEnabled = false
local originalWalkSpeed = 16
local originalJumpPower = 50
local originalGravity = workspace.Gravity
local originalFOV = 70

-- Auto plant variables
local isAutoPlantEnabled = false
local autoPlantConnection = nil

local lastPlantPosition = nil
local isCapturing = false

-- Pet aura variables
local isPetAuraEnabled = false
local petAuraConnection = nil

-- Update character reference when character is added
localPlayer.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
end)

-- Function to find the player's farm
local function findPlayerFarm()
    if not workspace:FindFirstChild("Farm") then
        return nil
    end
    
    -- Search through all farm plots to find the player's farm
    local farmPlots = workspace.Farm:GetChildren()
    for _, plot in pairs(farmPlots) do
        if plot:FindFirstChild("Important") and 
           plot.Important:FindFirstChild("Data") and 
           plot.Important.Data:FindFirstChild("Owner") then
            
            if plot.Important.Data.Owner.Value == localPlayer.Name or 
               plot.Important.Data.Owner.Value == localPlayer.UserId then
                return plot
            end
        end
    end
    
    return nil
end

-- Function to check current inventory count
local function getInventoryCount()
    -- This is a placeholder. You'll need to implement this based on how the game tracks inventory
    -- Example implementation - check if there's a GUI element showing inventory count
    local playerGui = localPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        -- Look for inventory UI elements
        -- This is highly game-specific and will need to be adapted
        -- For example, if there's a TextLabel showing inventory count:
        for _, gui in pairs(playerGui:GetDescendants()) do
            if gui:IsA("TextLabel") and (gui.Name:find("Inventory") or gui.Text:find("Inventory")) then
                local count = tonumber(gui.Text:match("%d+"))
                if count then
                    return count
                end
            end
        end
    end
    
    -- Fallback: Count items in backpack or another game-specific method
    -- For example, if items are stored as tools in the player's backpack:
    local backpack = localPlayer:FindFirstChild("Backpack")
    if backpack then
        return #backpack:GetChildren()
    end
    
    -- If we can't determine inventory count, return a value that won't trigger auto-sell
    return 0
end

-- Cache for plant models and proximity prompts to reduce lag
local cachedPlants = {}
local lastCacheTime = 0
local cacheRefreshInterval = 3 -- Refresh cache more frequently (3 seconds)

-- Function to cache ALL plants in the game, but ONLY from the player's farm
local function cacheAllPlants()
    cachedPlants = {}
    
    -- Find player's farm first
    local playerFarm = findPlayerFarm()
    if not playerFarm then
        return
    end
    
    -- Check if the player's farm has the necessary structure
    if not playerFarm:FindFirstChild("Important") or 
       not playerFarm.Important:FindFirstChild("Plants_Physical") then
        return
    end
    
    local plants = playerFarm.Important.Plants_Physical:GetChildren()
    
    for _, model in pairs(plants) do
        if model:IsA("Model") then
            for _, part in pairs(model:GetDescendants()) do
                if part:IsA("Part") and tonumber(part.Name) ~= nil then
                    local proximityPrompt = part:FindFirstChildOfClass("ProximityPrompt")
                    if proximityPrompt then
                        table.insert(cachedPlants, {
                            part = part,
                            prompt = proximityPrompt
                        })
                    end
                end
            end
        end
    end
    
    lastCacheTime = tick()
end

-- Improved function to find and activate proximity prompts in plant models (Aura mode)
local function findAndActivateProximityPrompts()
    -- Refresh cache if needed
    if tick() - lastCacheTime > cacheRefreshInterval then
        cacheAllPlants() -- Use the function that caches all plants, but only from player's farm
    end
    
    -- If cache is empty, try to fill it
    if #cachedPlants == 0 then
        cacheAllPlants() -- Use the function that caches all plants, but only from player's farm
    end
    
    -- Use cached plants with improved batching for better performance
    local batchSize = 10 -- Increased batch size for faster processing
    local currentBatch = 0
    
    for i, plantData in ipairs(cachedPlants) do
        if shouldStop then return end
        
        if plantData.prompt and plantData.prompt.Parent then
            -- Trigger the proximity prompt
            fireproximityprompt(plantData.prompt)
            currentBatch = currentBatch + 1
            
            -- Only wait after processing a batch of prompts
            if currentBatch >= batchSize then
                task.wait(0.01) -- Very small delay between batches
                currentBatch = 0
            end
        end
    end
end

-- Function to teleport to plants and activate proximity prompts (ULTRA FAST)
local function teleportToAndActivateProximityPrompts()
    -- Refresh cache if needed
    if tick() - lastCacheTime > cacheRefreshInterval then
        cacheAllPlants()
    end
    
    -- If cache is empty, try to fill it
    if #cachedPlants == 0 then
        cacheAllPlants()
    end
    
    -- Check if we should stop before starting
    if shouldStop then return end
    
    -- Process all plants with maximum speed - no batching, no delays
    for _, plantData in pairs(cachedPlants) do
        -- Check if we should stop before each teleport
        if shouldStop then return end
        
        if plantData.part and plantData.part.Parent and plantData.prompt and plantData.prompt.Parent then
            -- Teleport directly to the prompt's position
            humanoidRootPart.CFrame = plantData.prompt.Parent.CFrame
            
            -- Immediately fire the prompt without any delay
            fireproximityprompt(plantData.prompt)
            
            -- No wait between teleports for ultra speed
        end
    end
end

-- Function to sell inventory using remote event
local function sellInventory()
    local sellRemote = ReplicatedStorage:FindFirstChild("GameEvents"):FindFirstChild("Sell_Inventory")
    if sellRemote then
        sellRemote:FireServer()
        return true
    else
        return false
    end
end

-- Function to buy seed stock
local function buySeedStock(seedType)
    local buyRemote = ReplicatedStorage:FindFirstChild("GameEvents"):FindFirstChild("BuySeedStock")
    if buyRemote then
        buyRemote:FireServer(seedType)
        return true
    else
        return false
    end
end

-- Function to teleport to sell point, sell inventory, and teleport back
local function teleportAndSellInventory()
    -- Store original position
    local originalPosition = humanoidRootPart.CFrame
    
    -- Find Steven's left leg for selling
    local sellPoint = workspace:FindFirstChild("NPCS"):FindFirstChild("Steven"):FindFirstChild("Left Leg")
    if not sellPoint then
        return false
    end
    
    -- Teleport to sell point with a better position
    humanoidRootPart.CFrame = sellPoint.CFrame + Vector3.new(0, 5, 0)
    
    -- Wait a moment for the game to register our position
    task.wait(0.3) -- Increased wait time
    
    -- Try to sell inventory multiple times to ensure it works
    local success = false
    for i = 1, 3 do -- Try up to 3 times
        success = sellInventory()
        if success then
            break
        end
        task.wait(0.2) -- Wait between attempts
    end
    
    -- Wait a moment for the sell to process
    task.wait(0.3) -- Increased wait time
    
    -- Teleport back to original position
    humanoidRootPart.CFrame = originalPosition
    
    -- Update last sell time
    lastAutoSellTime = tick()
    
    return success
end

-- Function to toggle ScreenGUI visibility and update button text
local function toggleScreenGUI(gui, buttonInstance)
    if gui and gui:IsA("ScreenGui") then
        gui.Enabled = not gui.Enabled
        return gui.Enabled
    end
    return false
end

-- Function to find specific ScreenGUIs in the player's PlayerGui
local function findSpecificGUIs()
    local specificGUIs = {}
    
    -- Check PlayerGui
    if localPlayer:FindFirstChild("PlayerGui") then
        for _, child in pairs(localPlayer.PlayerGui:GetChildren()) do
            if child:IsA("ScreenGui") then
                -- Check if this is one of the specific GUIs we want
                if child.Name == "Hud_UI" or 
                   child.Name == "Teleport_UI" or 
                   string.find(string.lower(child.Name), "shop") then
                    table.insert(specificGUIs, child)
                end
            end
        end
    end
    
    -- Check CoreGui
    for _, child in pairs(game:GetService("CoreGui"):GetChildren()) do
        if child:IsA("ScreenGui") then
            if child.Name == "Hud_UI" or 
               child.Name == "Teleport_UI" or 
               string.find(string.lower(child.Name), "shop") then
                table.insert(specificGUIs, child)
            end
        end
    end
    
    -- Check StarterGui
    for _, child in pairs(game:GetService("StarterGui"):GetChildren()) do
        if child:IsA("ScreenGui") then
            if child.Name == "Hud_UI" or 
               child.Name == "Teleport_UI" or 
               string.find(string.lower(child.Name), "shop") then
                table.insert(specificGUIs, child)
            end
        end
    end
    
    return specificGUIs
end

-- Function to enable noclip
local function enableNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
    end
    
    noclipConnection = RunService.Stepped:Connect(function()
        if character and character:IsDescendantOf(workspace) then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end)
end

-- Function to disable noclip
local function disableNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
        
        -- Restore collision
        if character and character:IsDescendantOf(workspace) then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- Function to keep character upright
local function keepCharacterUpright()
    if humanoidRootPart then
        -- Get current CFrame
        local currentCFrame = humanoidRootPart.CFrame
        
        -- Extract position
        local position = currentCFrame.Position
        
        -- Create a new CFrame with the same position but upright orientation
        local uprightCFrame = CFrame.new(position) * CFrame.Angles(0, currentCFrame:ToEulerAnglesYXZ(), 0)
        
        -- Apply the new CFrame
        humanoidRootPart.CFrame = uprightCFrame
    end
end

-- Function to stop all processes immediately
local function stopAllProcesses()
    -- Set flag to stop all ongoing operations immediately
    shouldStop = true
    
    -- Stop the aura farm loop
    if auraFarmConnection then
        auraFarmConnection:Disconnect()
        auraFarmConnection = nil
    end
    
    -- Stop the auto teleport farm loop
    if autoTpFarmConnection then
        autoTpFarmConnection:Disconnect()
        autoTpFarmConnection = nil
    end
    
    -- Stop the auto sell loop
    if autoSellConnection then
        autoSellConnection = nil
    end
    
    -- Disable noclip
    disableNoclip()
    
    -- Reset flag after cleanup
    task.wait(0.05) -- Reduced wait time for faster response
    shouldStop = false
end

-- Function to handle server hopping
local function serverHop()
    local placeId = game.PlaceId
    local servers = {}
    
    local function getServers(cursor)
        local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
        if cursor then
            url = url .. "&cursor=" .. cursor
        end
        
        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)
        
        if success and result and result.data then
            return result
        end
        return {data = {}, nextPageCursor = nil}
    end
    
    local result = getServers()
    
    for _, server in ipairs(result.data) do
        if server.playing < server.maxPlayers and server.id ~= game.JobId then
            table.insert(servers, server)
        end
    end
    
    if #servers > 0 then
        local randomServer = servers[math.random(1, #servers)]
        task.wait(1)
        TeleportService:TeleportToPlaceInstance(placeId, randomServer.id, localPlayer)
    end
end

local function rejoinSameServer()
    task.wait(1)
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, localPlayer)
end

local function findEmptyServer()
    local placeId = game.PlaceId
    local servers = {}
    local cursor = nil
    local lowestPlaying = math.huge
    local targetServer = nil
    
    for i = 1, 3 do
        local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
        if cursor then
            url = url .. "&cursor=" .. cursor
        end
        
        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)
        
        if not success or not result or not result.data then
            break
        end
        
        for _, server in ipairs(result.data) do
            if server.playing < lowestPlaying and server.id ~= game.JobId and server.playing > 0 then
                lowestPlaying = server.playing
                targetServer = server
            end
        end
        
        if lowestPlaying <= 3 then
            break
        end
        
        cursor = result.nextPageCursor
        if not cursor then
            break
        end
        
        task.wait(0.5)
    end
    
    if targetServer then
        task.wait(1)
        TeleportService:TeleportToPlaceInstance(placeId, targetServer.id, localPlayer)
    end
end

-- Add section headers to the UI
local FarmingSection = Tabs.Main:AddSection("Farming")

-- Create toggle in Main tab for aura farm
local AuraToggle = Tabs.Main:AddToggle("AuraFarmToggle", {
    Title = "Aura Farm Plants",
    Default = false
})

-- Add cooldown slider for Aura Farm
local auraCooldown = 0.2
local lastAuraRun = 0
local AuraCooldownSlider = Tabs.Main:AddSlider("AuraCooldown", {
    Title = "Aura Farm Cooldown (s)",
    Default = 0.2,
    Min = 0.05,
    Max = 3,
    Rounding = 2,
    Callback = function(Value)
        auraCooldown = Value
    end
})

AuraToggle:OnChanged(function(Value)
    isAuraFarmEnabled = Value
    
    if isAuraFarmEnabled then
        lastAuraRun = 0
        auraFarmConnection = RunService.RenderStepped:Connect(function()
            if not isAuraFarmEnabled then return end

            -- Throttle by cooldown
            local now = tick()
            if now - (lastAuraRun or 0) < (auraCooldown or 0.2) then return end
            lastAuraRun = now

            local myPlot
            for _, plot in pairs(workspace.Farm:GetChildren()) do
                if plot:FindFirstChild("Important") and 
                   plot.Important:FindFirstChild("Data") and 
                   plot.Important.Data:FindFirstChild("Owner") and
                   plot.Important.Data.Owner.Value == game.Players.LocalPlayer.Name then

                    local plants = plot.Important.Plants_Physical:GetChildren()
                    for _, plant in pairs(plants) do
                        if plant:IsA("Model") then
                            for _, part in pairs(plant:GetDescendants()) do
                                if part:IsA("ProximityPrompt") then
                                    part.MaxActivationDistance = 9999999
                                    part.HoldDuration = 0
                                    part.RequiresLineOfSight = false
                                    fireproximityprompt(part)
                                end
                            end
                        end
                    end
                    break
                end
            end
        end)
    else
        if auraFarmConnection then
            auraFarmConnection:Disconnect()
            auraFarmConnection = nil
        end
    end
end)

-- Create toggle for auto teleport and farm
local TpToggle = Tabs.Main:AddToggle("AutoTpFarmToggle", {
    Title = "Auto TP and Farm Plants",
    Default = false
})

-- Add cooldown slider for Auto TP farm
local tpFarmCooldown = 0.2
local lastTpRun = 0
local TpCooldownSlider = Tabs.Main:AddSlider("TpFarmCooldown", {
    Title = "TP Farm Cooldown (s)",
    Default = 0.2,
    Min = 0.05,
    Max = 3,
    Rounding = 2,
    Callback = function(Value)
        tpFarmCooldown = Value
    end
})

TpToggle:OnChanged(function(Value)
    -- Stop any existing processes first
    stopAllProcesses()
    
    isAutoTpFarmEnabled = Value
    
    if isAutoTpFarmEnabled then
        -- Save current position before starting
        lastPlayerPosition = humanoidRootPart.CFrame
        
        -- Enable noclip
        enableNoclip()
        
        -- Initial cache of plants
        cacheAllPlants()
        
        lastTpRun = 0
        -- Start the auto teleport farm loop with cooldown throttle
        autoTpFarmConnection = RunService.RenderStepped:Connect(function()
            if not isAutoTpFarmEnabled or shouldStop then
                stopAllProcesses()
                return
            end

            -- Throttle by cooldown
            local now = tick()
            if now - (lastTpRun or 0) < (tpFarmCooldown or 0.2) then return end
            lastTpRun = now
            
            teleportToAndActivateProximityPrompts()
        end)
    else
        -- Disable noclip when toggled off
        disableNoclip()
        
        -- Return to last position if we have one saved
        if lastPlayerPosition then
            -- Teleport back to original position with a height offset to avoid getting stuck
            humanoidRootPart.CFrame = lastPlayerPosition + Vector3.new(0, 10, 0) -- Increased height to 10 studs
        end
    end
end)

-- Add a label explaining why to use Auto TP
Tabs.Main:AddParagraph({
    Title = "Important Note",
    Content = "Use 'Auto TP and Farm Plants' if Aura farming doesn't work at a distance. This will teleport you to each plant to activate the prompts."
})

-- Auto Plant feature removed per request

-- Add Pets section before Buy Eggs
local PetsSection = Tabs.Main:AddSection("Pets")

-- Create toggle for pet aura collection
local PetAuraToggle = Tabs.Main:AddToggle("PetAuraToggle", {
    Title = "Aura Collect Pets",
    Default = false
})

PetAuraToggle:OnChanged(function(Value)
    isPetAuraEnabled = Value
    
    if isPetAuraEnabled then
        local myPlot
        for _, plot in pairs(workspace.Farm:GetChildren()) do
            if plot:FindFirstChild("Important") and 
               plot.Important:FindFirstChild("Data") and 
               plot.Important.Data:FindFirstChild("Owner") and
               plot.Important.Data.Owner.Value == game.Players.LocalPlayer.Name then
                myPlot = plot
                break
            end
        end
        
        if not myPlot then
            PetAuraToggle:SetValue(false)
            return
        end
        
        petAuraConnection = RunService.Heartbeat:Connect(function()
            if not isPetAuraEnabled then
                petAuraConnection:Disconnect()
                petAuraConnection = nil
                
                local objectsPhysical = myPlot.Important:FindFirstChild("Objects_Physical")
                if objectsPhysical then
                    for _, obj in pairs(objectsPhysical:GetDescendants()) do
                        if obj:IsA("ProximityPrompt") then
                            obj.MaxActivationDistance = 10
                        end
                    end
                end
                return
            end
            
            local objectsPhysical = myPlot.Important:FindFirstChild("Objects_Physical")
            if objectsPhysical then
                for _, obj in pairs(objectsPhysical:GetChildren()) do
                    if obj:IsA("Model") then
                        for _, part in pairs(obj:GetDescendants()) do
                            if part:IsA("ProximityPrompt") then
                                part.MaxActivationDistance = 10000
                                part.HoldDuration = 0
                                part.RequiresLineOfSight = false
                                fireproximityprompt(part)
                            end
                        end
                    end
                end
            end
        end)
    else
        if petAuraConnection then
            petAuraConnection:Disconnect()
            petAuraConnection = nil
        end
    end
end)

-- Add section for selling
local SellingSection = Tabs.Main:AddSection("Selling")

-- Create input for inventory threshold
local InventoryInput = Tabs.Main:AddInput("InventoryThreshold", {
    Title = "Max Inventory Items",
    Default = "0",
    Placeholder = "Enter number of items",
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        local numValue = tonumber(Value)
        if numValue and numValue >= 0 then
            inventoryThreshold = numValue
        end
    end
})

-- Create toggle for auto sell
local AutoSellToggle = Tabs.Main:AddToggle("AutoSellToggle", {
    Title = "Auto Sell Inventory",
    Default = false
})

AutoSellToggle:OnChanged(function(Value)
    isAutoSellEnabled = Value
    
    if isAutoSellEnabled then
        local checkInterval = 1
        local minSellInterval = 3
        
        autoSellConnection = coroutine.wrap(function()
            while isAutoSellEnabled and not shouldStop do
                local inventoryCount = getInventoryCount()
                
                if inventoryThreshold > 0 and inventoryCount >= inventoryThreshold and tick() - lastAutoSellTime >= minSellInterval then
                    teleportAndSellInventory()
                end
                
                task.wait(checkInterval)
                
                if not isAutoSellEnabled or shouldStop then
                    break
                end
            end
        end)()
    else
        if autoSellConnection then
            autoSellConnection = nil
        end
    end
end)

-- Create button for selling inventory
Tabs.Main:AddButton({
    Title = "Sell Inventory",
    Description = "Teleports to sell point, sells inventory, then teleports back",
    Callback = function()
        local success = teleportAndSellInventory()
        if not success then
            task.wait(0.5)
            teleportAndSellInventory()
        end
    end
})

-- Add second sell button using remote
Tabs.Main:AddButton({
    Title = "Sell Item (In Hand)",
    Description = "Teleports to sell point, sells item in hand, then teleports back",
    Callback = function()
        local oldPos = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
        
        local sellPoint = workspace:FindFirstChild("NPCS"):FindFirstChild("Steven"):FindFirstChild("Left Leg")
        if sellPoint then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = sellPoint.CFrame + Vector3.new(0, 5, 0)
            task.wait(0.3)
            game:GetService("ReplicatedStorage").GameEvents.Sell_Item:FireServer()
            task.wait(0.3)
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = oldPos
            end
        end
})

-- Add Buy Eggs section at the bottom of Main tab
local BuyEggsSection = Tabs.Main:AddSection("Buy Eggs")
local selectedEgg = "Common Egg"
local function getEggNames()
    local names = {}
    local pg = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return names end
    local shop = pg:FindFirstChild("PetShop_UI")
    if not shop then return names end
    local sf = shop:FindFirstChild("Frame") and shop.Frame:FindFirstChild("ScrollingFrame") and shop.Frame.ScrollingFrame or nil
    if not sf then return names end
    for _, fr in ipairs(sf:GetChildren()) do
        if fr:IsA("Frame") and #fr:GetChildren() > 0 then
            table.insert(names, fr.Name)
        end
    end
    return names
end
local eggDropdown = BuyEggsSection:AddDropdown("EggSelect", {
    Title = "Select Egg",
    Values = getEggNames(),
    Default = 1,
    Multi = false,
    Callback = function(val)
        selectedEgg = val
    end
})
BuyEggsSection:AddButton({
    Title = "Buy Selected Egg",
    Description = "Buys the selected egg",
    Callback = function()
        local name = selectedEgg or "Common Egg"
        local ev = game:GetService("ReplicatedStorage").GameEvents:FindFirstChild("BuyPetEgg")
        if ev then ev:FireServer(name) end
    end
})

-- Add section for GUI toggles
-- GUIs tab: replaced with explicit buttons to enable specific ScreenGUIs
local function toggleGuiByName(guiName)
    local pg = localPlayer:FindFirstChild("PlayerGui")
    if not pg then return end
    local g = pg:FindFirstChild(guiName)
    if g and g:IsA("ScreenGui") then
        g.Enabled = not g.Enabled
    end
end

Tabs.GUIs:AddButton({
    Title = "TravelingMerchantShop_UI",
    Description = "Enable Traveling Merchant UI",
    Callback = function()
        toggleGuiByName("TravelingMerchantShop_UI")
    end
})
Tabs.GUIs:AddButton({
    Title = "CosmeticShop_UI",
    Description = "Enable Cosmetic Shop UI",
    Callback = function()
        toggleGuiByName("CosmeticShop_UI")
    end
})
Tabs.GUIs:AddButton({
    Title = "EventShop_UI",
    Description = "Enable Event Shop UI",
    Callback = function()
        toggleGuiByName("EventShop_UI")
    end
})
Tabs.GUIs:AddButton({
    Title = "GardenCoinShop_UI",
    Description = "Enable Garden Coin Shop UI",
    Callback = function()
        toggleGuiByName("GardenCoinShop_UI")
    end
})
Tabs.GUIs:AddButton({
    Title = "PetShop_UI",
    Description = "Enable Pet Shop UI",
    Callback = function()
        toggleGuiByName("PetShop_UI")
    end
})
Tabs.GUIs:AddButton({
    Title = "Shop_UI",
    Description = "Enable Shop UI",
    Callback = function()
        toggleGuiByName("Shop_UI")
    end
})

-- Add server-related buttons to Misc tab
local ServerSection = Tabs.Misc:AddSection("Server Options")

-- Server Hop button
Tabs.Misc:AddButton({
    Title = "Server Hop",
    Description = "Teleport to a different server",
    Callback = function()
        serverHop()
    end
})

-- Rejoin Same Server button
Tabs.Misc:AddButton({
    Title = "Rejoin Same Server",
    Description = "Rejoin the current server",
    Callback = function()
        rejoinSameServer()
    end
})

-- Find Empty Server button
Tabs.Misc:AddButton({
    Title = "Find Empty Server",
    Description = "Teleport to the emptiest available server",
    Callback = function()
        findEmptyServer()
    end
})

-- Initialize GUI buttons
-- GUIs tab no longer uses dynamic scanning

-- Hand the library over to our managers
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

-- Setup SaveManager
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
SaveManager:SetFolder("PlantFarmExecutor")
InterfaceManager:SetFolder("PlantFarmExecutor")

-- Build interface sections
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- Select the first tab
Window:SelectTab(1)

-- Load settings
SaveManager:LoadAutoloadConfig()

-- Cleanup when script is terminated
local scriptTerminating = false
game:GetService("CoreGui").ChildRemoved:Connect(function(child)
    if child.Name == "ScreenGui" and not scriptTerminating then
        scriptTerminating = true
        stopAllProcesses()
                    end
                end)
                
-- Function to create teleport script
local function createTeleportScript()
    return string.format([[
game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)]], game.PlaceId, game.JobId)
end

-- Function to send webhook
local function sendWebhook(eventName)
    local data = {
        content = string.format("```lua\n%s\n```", createTeleportScript())
    }
    
    local success = pcall(function()
        return game:GetService("HttpService"):RequestAsync({
            Url = webhookUrl,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = game:GetService("HttpService"):JSONEncode(data)
        })
    end)
    
    
end

-- Function to handle event detection
local function handleEventDetected(eventName)
    local currentTime = tick()
    if currentTime - lastEventTime < eventCooldown then
        return
    end
    lastEventTime = currentTime
    
    sendWebhook(eventName)
end

-- Function to check for active events
local function checkCurrentEvents()
    local bottomUI = game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("Bottom_UI", 10)
    if not bottomUI then return end
    
    local holder = bottomUI:WaitForChild("BottomFrame", 10):WaitForChild("Holder", 10):WaitForChild("List", 10)
    if not holder then return end
    
    for _, obj in ipairs(holder:GetChildren()) do
        if obj:IsA("Frame") and obj.Visible == true then
            handleEventDetected(obj.Name)
            end
        end
        
    for _, obj in ipairs(holder:GetDescendants()) do
        if obj:IsA("Frame") and obj.Visible == true then
            handleEventDetected(obj.Name)
        end
    end
end

-- Function to monitor Bottom_UI frames and RemoteEvent
local function monitorEvents()
    local specialEvent = game:GetService("ReplicatedStorage"):WaitForChild("GameEvents", 10):WaitForChild("SpecialEventStarted", 10)
    if specialEvent then
        specialEvent.OnClientEvent:Connect(function(eventName)
            handleEventDetected(eventName or "Special Event")
        end)
    end
    
    local bottomUI = game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("Bottom_UI", 10)
    if not bottomUI then return end
    
    local holder = bottomUI:WaitForChild("BottomFrame", 10):WaitForChild("Holder", 10):WaitForChild("List", 10)
    if not holder then return end
    
    holder.DescendantAdded:Connect(function(obj)
        if obj:IsA("Frame") then
            obj:GetPropertyChangedSignal("Visible"):Connect(function()
                if obj.Visible == true then
                    handleEventDetected(obj.Name)
                end
            end)
        end
    end)
    
    holder.DescendantPropertyChanged:Connect(function(obj, prop)
        if prop == "Visible" and obj:IsA("Frame") and obj.Visible == true then
            handleEventDetected(obj.Name)
            end
        end)
end

-- Start monitoring after everything is loaded
task.spawn(function()
    task.wait(5)
    checkCurrentEvents()
    monitorEvents()
end)

-- Function to get character and humanoid
local function getCharacter()
    local char = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid")
    local rootPart = char:WaitForChild("HumanoidRootPart")
    return char, humanoid, rootPart
end

-- Character modification section in Misc tab
local CharacterSection = Tabs.Misc:AddSection("Character")
local savedPositionCFrame = nil
Tabs.Misc:AddButton({
	Title = "Save Position",
	Description = "Saves your current position",
	Callback = function()
		local _, _, rootPart = getCharacter()
		if rootPart then
			savedPositionCFrame = rootPart.CFrame
		end
	end
})
Tabs.Misc:AddButton({
	Title = "Teleport To Saved",
	Description = "Teleports to last saved position",
	Callback = function()
		local _, _, rootPart = getCharacter()
		if rootPart and savedPositionCFrame then
			rootPart.CFrame = savedPositionCFrame
		end
	end
})

-- Freeze Character Toggle
local FreezeToggle = Tabs.Misc:AddToggle("FreezeCharacter", {
    Title = "Freeze Character",
    Default = false
})

FreezeToggle:OnChanged(function(Value)
    isCharacterFrozen = Value
    local char, humanoid, rootPart = getCharacter()
    
    if isCharacterFrozen then
        -- Store original CFrame
        local originalCFrame = rootPart.CFrame
        
        -- Create the freeze connection
        if not _G.FreezeConnection then
            _G.FreezeConnection = RunService.Heartbeat:Connect(function()
                if rootPart and isCharacterFrozen then
                    rootPart.CFrame = originalCFrame
                    rootPart.Velocity = Vector3.new(0, 0, 0)
                end
            end)
        end
    else
        -- Cleanup freeze connection
        if _G.FreezeConnection then
            _G.FreezeConnection:Disconnect()
            _G.FreezeConnection = nil
            end
        end
    end)
    
-- Anti-AFK Toggle
local AntiAFKToggle = Tabs.Misc:AddToggle("AntiAFK", {
    Title = "Anti-AFK",
    Default = false
})

AntiAFKToggle:OnChanged(function(Value)
    isAntiAFKEnabled = Value
    
    if isAntiAFKEnabled then
        -- Create the anti-AFK connection
        if not _G.AntiAFKConnection then
            _G.AntiAFKConnection = RunService.Heartbeat:Connect(function()
                local VirtualUser = game:GetService("VirtualUser")
                localPlayer.Idled:Connect(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end)
            end)
        end
    else
        -- Cleanup anti-AFK connection
        if _G.AntiAFKConnection then
            _G.AntiAFKConnection:Disconnect()
            _G.AntiAFKConnection = nil
            end
        end
    end)
    
-- Teleport Toggle
local TeleportToggle = Tabs.Misc:AddToggle("Teleport", {
    Title = "Teleport (T + Left Click)",
    Default = false
})

TeleportToggle:OnChanged(function(Value)
    isTeleportEnabled = Value
    
    if isTeleportEnabled then
        -- Create teleport connections if they don't exist
        if not _G.TeleportKeyConnection then
            _G.TeleportKeyConnection = UserInputService.InputBegan:Connect(function(input)
                if input.KeyCode == Enum.KeyCode.T then
                    local mouse = localPlayer:GetMouse()
                    local char, humanoid, rootPart = getCharacter()
                    
                    -- Create visual beam to show teleport is active
                    local beam = Instance.new("Beam")
                    beam.Width0 = 0.5
                    beam.Width1 = 0.5
                    beam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
                    
                    -- Wait for mouse click
                    local connection
                    connection = mouse.Button1Down:Connect(function()
                        if rootPart then
                            local targetPos = mouse.Hit.Position
                            rootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
                        end
                        if connection then
                            connection:Disconnect()
                        end
                        if beam then
                            beam:Destroy()
        end
    end)
end
            end)
        end
    else
        -- Cleanup teleport connections
        if _G.TeleportKeyConnection then
            _G.TeleportKeyConnection:Disconnect()
            _G.TeleportKeyConnection = nil
            end
    end
end)

-- Infinite Jump Toggle
local InfiniteJumpToggle = Tabs.Misc:AddToggle("InfiniteJump", {
    Title = "Infinite Jump",
    Default = false
})

InfiniteJumpToggle:OnChanged(function(Value)
    isInfiniteJumpEnabled = Value
    
    if isInfiniteJumpEnabled then
        -- Create infinite jump connection
        if not _G.InfiniteJumpConnection then
            _G.InfiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
                local char, humanoid = getCharacter()
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end
    else
        -- Cleanup infinite jump connection
        if _G.InfiniteJumpConnection then
            _G.InfiniteJumpConnection:Disconnect()
            _G.InfiniteJumpConnection = nil
        end
    end
end)

-- WalkSpeed Slider
local WalkSpeedSlider = Tabs.Misc:AddSlider("WalkSpeed", {
    Title = "Walk Speed",
    Default = 16,
    Min = 16,
    Max = 500,
    Rounding = 0,
    Callback = function(Value)
        local char, humanoid = getCharacter()
        if humanoid then
            humanoid.WalkSpeed = Value
        end
    end
})

-- JumpPower Slider
local JumpPowerSlider = Tabs.Misc:AddSlider("JumpPower", {
    Title = "Jump Power",
    Default = 50,
    Min = 50,
    Max = 500,
    Rounding = 0,
    Callback = function(Value)
        local char, humanoid = getCharacter()
        if humanoid then
            humanoid.JumpPower = Value
        end
    end
})

-- Gravity Slider
local GravitySlider = Tabs.Misc:AddSlider("Gravity", {
    Title = "Gravity",
    Default = workspace.Gravity,
    Min = 0,
    Max = 500,
    Rounding = 0,
    Callback = function(Value)
        workspace.Gravity = Value
    end
})

-- FOV Slider
local FOVSlider = Tabs.Misc:AddSlider("FOV", {
    Title = "Field of View",
    Default = 70,
    Min = 30,
    Max = 120,
    Rounding = 0,
    Callback = function(Value)
        local Camera = workspace.CurrentCamera
        if Camera then
            Camera.FieldOfView = Value
        end
    end
})

-- Reset Character Button
Tabs.Misc:AddButton({
    Title = "Reset Character",
    Description = "Reset all character modifications",
    Callback = function()
        local char, humanoid = getCharacter()
        if humanoid then
            -- Reset all modifications
            humanoid.WalkSpeed = originalWalkSpeed
            humanoid.JumpPower = originalJumpPower
            workspace.Gravity = originalGravity
            local Camera = workspace.CurrentCamera
            if Camera then
                Camera.FieldOfView = originalFOV
            end
            
            -- Reset all toggles
            FreezeToggle:SetValue(false)
            AntiAFKToggle:SetValue(false)
            TeleportToggle:SetValue(false)
            InfiniteJumpToggle:SetValue(false)
            
            -- Reset all sliders
            WalkSpeedSlider:SetValue(originalWalkSpeed)
            JumpPowerSlider:SetValue(originalJumpPower)
            GravitySlider:SetValue(originalGravity)
            FOVSlider:SetValue(originalFOV)
        end
    end
})

-- Character Added connection to maintain settings
localPlayer.CharacterAdded:Connect(function(char)
    local humanoid = char:WaitForChild("Humanoid")
    
    -- Reapply settings when character respawns
    if humanoid then
        humanoid.WalkSpeed = WalkSpeedSlider:GetValue()
        humanoid.JumpPower = JumpPowerSlider:GetValue()
    end
end)

-- Add Performance section after Misc section
local PerformanceSection = Tabs.Performance:AddSection("Performance")
local function setPerformanceNormal()
    local lighting = game:GetService("Lighting")
    lighting.GlobalShadows = true
    lighting.Brightness = 2
    lighting.FogEnd = 100000
    for _, v in pairs(lighting:GetChildren()) do
        if v:IsA("PostEffect") then v.Enabled = true end
    end
    settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
    settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Default
    workspace.InterpolationThrottling = Enum.InterpolationThrottlingMode.Default
    for _, v in pairs(workspace:GetDescendants()) do
        if (v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("MeshPart") or v:IsA("CornerWedgePart") or v:IsA("TrussPart")) then
            v.CastShadow = true
        end
        if v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 0 end
        if v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = true end
        if v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then v.Enabled = true end
        if v:IsA("MeshPart") then v.RenderFidelity = Enum.RenderFidelity.Automatic end
    end
    if lighting:FindFirstChild("Atmosphere") then lighting.Atmosphere.Density = 0.35 end
    if lighting:FindFirstChild("Clouds") then lighting.Clouds.Enabled = true end
end
local function setPerformanceFast()
    local lighting = game:GetService("Lighting")
    lighting.GlobalShadows = false
    lighting.Brightness = 1
    lighting.FogEnd = 9e9
    for _, v in pairs(lighting:GetChildren()) do
        if v:IsA("PostEffect") then v.Enabled = false end
    end
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level02
    settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Enabled
    workspace.InterpolationThrottling = Enum.InterpolationThrottlingMode.Enabled
    for _, v in pairs(workspace:GetDescendants()) do
        if (v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("MeshPart") or v:IsA("CornerWedgePart") or v:IsA("TrussPart")) then
            v.CastShadow = false
        end
        if v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 0.5 end
        if v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = false end
        if v:IsA("MeshPart") then v.RenderFidelity = Enum.RenderFidelity.Performance end
    end
    if lighting:FindFirstChild("Atmosphere") then lighting.Atmosphere.Density = 0 end
    if lighting:FindFirstChild("Clouds") then lighting.Clouds.Enabled = false end
end
local function setPerformanceSuperFast()
    local lighting = game:GetService("Lighting")
    lighting.GlobalShadows = false
    lighting.FogEnd = 9e9
    lighting.Brightness = 0
    for _, v in pairs(lighting:GetChildren()) do
        if v:IsA("PostEffect") then v.Enabled = false end
    end
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
    workspace.InterpolationThrottling = Enum.InterpolationThrottlingMode.Disabled
    for _, v in pairs(workspace:GetDescendants()) do
        if (v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("MeshPart") or v:IsA("CornerWedgePart") or v:IsA("TrussPart")) then
            v.Material = Enum.Material.Plastic
            v.Reflectance = 0
            v.CastShadow = false
        end
        if v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1 end
        if v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = false end
        if v:IsA("Explosion") then v.BlastPressure = 1 v.BlastRadius = 1 end
        if v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then v.Enabled = false end
        if v:IsA("MeshPart") then v.RenderFidelity = Enum.RenderFidelity.Performance end
    end
    if lighting:FindFirstChild("Atmosphere") then lighting.Atmosphere.Density = 0 end
    if lighting:FindFirstChild("Clouds") then lighting.Clouds.Enabled = false end
end
Tabs.Performance:AddDropdown("PerformanceMode", {
    Title = "Performance Mode",
    Values = {"Normal", "Fast", "Super Fast"},
    Default = 1,
    Multi = false,
    Callback = function(v)
        if v == "Normal" then setPerformanceNormal() elseif v == "Fast" then setPerformanceFast() elseif v == "Super Fast" then setPerformanceSuperFast() end
    end
})

local function tryFirePrompt(obj)
    if obj and obj:IsA("ProximityPrompt") then
        obj.MaxActivationDistance = 999999
        obj.HoldDuration = 0
        obj.RequiresLineOfSight = false
        fireproximityprompt(obj)
    end
end
local function toggleIfGuiOpen(names)
    local pg = localPlayer:FindFirstChild("PlayerGui")
    if not pg then return false end
    local toggled = false
    for _, n in ipairs(names) do
        local g = pg:FindFirstChild(n)
        if g and g:IsA("ScreenGui") and g.Enabled then
            g.Enabled = false
            toggled = true
        end
    end
    return toggled
end

Tabs.Event:AddButton({
    Title = "Fall Festival Seeds UI",
    Description = "Open Seeds UI",
    Callback = function()
        if not toggleIfGuiOpen({"EventShop_UI"}) then
            local ok, prompt = pcall(function()
                return workspace.Interaction.UpdateItems["Fall Festival"].FallPlatform.Elijah.Head.FaceCenterAttachment.FallSeedShopProximityPrompt
            end)
            if ok then tryFirePrompt(prompt) end
        end
    end
})
Tabs.Event:AddButton({
    Title = "Fall Festival Pets UI",
    Description = "Open Pets UI",
    Callback = function()
        if not toggleIfGuiOpen({"PetShop_UI"}) then
            local ok, prompt = pcall(function()
                return workspace.Interaction.UpdateItems["Fall Festival"].FallPlatform.Avery.Head.FaceCenterAttachment.FallPetShopProximityPrompt
            end)
            if ok then tryFirePrompt(prompt) end
        end
    end
})
Tabs.Event:AddButton({
    Title = "Fall Festival Gears UI",
    Description = "Open Gears UI",
    Callback = function()
        if not toggleIfGuiOpen({"Shop_UI"}) then
            local ok, prompt = pcall(function()
                return workspace.Interaction.UpdateItems["Fall Festival"].FallPlatform.Danielle.Head.FaceCenterAttachment.FallGearShopProximityPrompt
            end)
            if ok then tryFirePrompt(prompt) end
        end
    end
})
Tabs.Event:AddButton({
    Title = "Fall Festivals Cosmetics UI",
    Description = "Open Cosmetics UI",
    Callback = function()
        if not toggleIfGuiOpen({"CosmeticShop_UI"}) then
            local ok, prompt = pcall(function()
                return workspace.Interaction.UpdateItems["Fall Festival"].FallPlatform.Liam.Head.FaceCenterAttachment.FallCosmeticShopProximityPrompt
            end)
            if ok then tryFirePrompt(prompt) end
        end
    end
})

-- Add Shop Teleports section to Teleport tab
local ShopTeleportsSection = Tabs.Teleport:AddSection("Teleports")

-- Event Button (Cooking Event)
Tabs.Teleport:AddButton({
    Title = "Event",
    Description = "Teleports to Event",
    Callback = function()
        local part = nil
        pcall(function()
            part = workspace.BasePlate.TopBaseplate
        end)
        if part and part.CFrame then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0, 50, 0)
        end
    end
})

-- Pet Shop Button (2 studs in front)
ShopTeleportsSection:AddButton({
    Title = "Pets/Gear/Cosmetics Shop",
    Description = "Teleports to Pets/Gears/Cosmetics",
    Callback = function()
        local target = nil
        pcall(function()
            target = workspace.Tutorial_Points.Tutorial_Point_3
        end)
        if target and target.CFrame then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = target.CFrame * CFrame.new(0, 2, -2)
        end
    end
})

-- Seed Shop Button (teleport to Tutorial Point 1)
ShopTeleportsSection:AddButton({
	Title = "Seed Shop",
	Description = "Teleports to Seed Shop",
	Callback = function()
		local target = nil
		pcall(function()
			target = workspace.Tutorial_Points.Tutorial_Point_1
		end)
		if target and target.CFrame then
			game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = target.CFrame
		end
	end
})

-- Sell Button (teleport to Tutorial Point 2)
ShopTeleportsSection:AddButton({
	Title = "Sell",
	Description = "Teleports to Sell",
	Callback = function()
		local target = nil
		pcall(function()
			target = workspace.Tutorial_Points.Tutorial_Point_2
		end)
		if target and target.CFrame then
			game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = target.CFrame
		end
	end
})

-- Final single UI loaded notification
 