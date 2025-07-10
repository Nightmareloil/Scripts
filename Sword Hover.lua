-- Enhanced Tool Levitation Script with Performance Optimizations and Better Error Handling

-- Services
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Player and Character references
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Head = Character:WaitForChild("Head")

-- Configuration with validation
local config = {
    hoverHeight = 10,                           -- studs above head
    spinSpeed = 20,                             -- radians per second
    bpMaxForce = Vector3.new(1e5, 1e5, 1e5),
    bpP = 50,
    bpD = 50,
    bavMaxTorque = Vector3.new(1e5, 1e5, 1e5),
    maxDistance = 100,                          -- maximum distance from player before cleanup
    updateInterval = 0.1,                       -- seconds between position updates (performance)
    enableVisualEffects = true,                 -- particle effects and glow
    enableSmoothTransitions = true,             -- smooth position transitions
    autoCleanupTime = 300,                      -- seconds before auto-cleanup (5 minutes)
    maxActiveTools = 50                         -- maximum number of active tools
}

-- State management
local activeTools = {}
local toolConnections = {}
local lastUpdateTime = 0
local isScriptActive = true

-- Utility functions
local function isValidTool(tool)
    return tool and tool:IsA("Tool") and tool:FindFirstChild("Handle") and tool.Parent == Workspace
end

local function isWithinRange(handle)
    if not (Head and Head.Parent) then return false end
    local distance = (handle.Position - Head.Position).Magnitude
    return distance <= config.maxDistance
end

local function createGlowEffect(handle)
    if not config.enableVisualEffects then return end
    
    local pointLight = handle:FindFirstChild("LevitateGlow")
    if not pointLight then
        pointLight = Instance.new("PointLight")
        pointLight.Name = "LevitateGlow"
        pointLight.Color = Color3.fromRGB(0, 255, 255)
        pointLight.Brightness = 0.5
        pointLight.Range = 10
        pointLight.Parent = handle
        
        -- Subtle pulsing effect
        local pulseInfo = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
        local pulseTween = TweenService:Create(pointLight, pulseInfo, {Brightness = 1})
        pulseTween:Play()
    end
end

local function removeGlowEffect(handle)
    local pointLight = handle:FindFirstChild("LevitateGlow")
    if pointLight then
        pointLight:Destroy()
    end
end

-- Enhanced BodyPosition creation with smooth transitions
local function updateBodyPosition(handle)
    local bp = handle:FindFirstChild("LevitatePosition")
    if not bp then
        bp = Instance.new("BodyPosition")
        bp.Name = "LevitatePosition"
        bp.MaxForce = config.bpMaxForce
        bp.P = config.bpP
        bp.D = config.bpD
        bp.Parent = handle
    end
    
    local targetPosition = Head.Position + Vector3.new(0, config.hoverHeight, 0)
    
    if config.enableSmoothTransitions then
        -- Smooth transition instead of instant teleportation
        local currentPos = bp.Position
        local distance = (targetPosition - currentPos).Magnitude
        if distance > 0.1 then
            bp.Position = currentPos:Lerp(targetPosition, math.min(distance * 0.1, 1))
        else
            bp.Position = targetPosition
        end
    else
        bp.Position = targetPosition
    end
end

-- Enhanced BodyAngularVelocity with variable spin
local function updateAngularVelocity(handle)
    local bav = handle:FindFirstChild("Spinning")
    if not bav then
        bav = Instance.new("BodyAngularVelocity")
        bav.Name = "Spinning"
        bav.MaxTorque = config.bavMaxTorque
        bav.Parent = handle
    end
    
    -- Add slight randomness to spin for more natural look
    local spinVariation = math.random(-5, 5) * 0.1
    bav.AngularVelocity = Vector3.new(0, config.spinSpeed + spinVariation, 0)
end

-- Enhanced tool processing with better error handling
local function levitateAndSpin(tool)
    if not isValidTool(tool) then return false end
    
    local handle = tool:FindFirstChild("Handle")
    if not handle then return false end
    
    -- Check if tool is still within range
    if not isWithinRange(handle) then
        unregisterTool(tool)
        return false
    end
    
    -- Setup physics properties
    if handle.CanCollide then
        handle.CanCollide = false
    end
    
    if handle.Anchored then
        handle.Anchored = false
    end
    
    -- Apply levitation and spinning
    pcall(function()
        updateBodyPosition(handle)
        updateAngularVelocity(handle)
        createGlowEffect(handle)
    end)
    
    return true
end

-- Enhanced tool registration with connection management
local function registerTool(tool)
    if not isValidTool(tool) then return end
    
    -- Check tool limit
    local toolCount = 0
    for _ in pairs(activeTools) do
        toolCount = toolCount + 1
    end
    
    if toolCount >= config.maxActiveTools then
        warn("Maximum active tools reached. Cannot register new tool.")
        return
    end
    
    activeTools[tool] = {
        registeredTime = tick(),
        lastUpdateTime = tick()
    }
    
    -- Connect to tool's AncestryChanged to detect when it's picked up
    toolConnections[tool] = tool.AncestryChanged:Connect(function()
        if tool.Parent ~= Workspace then
            unregisterTool(tool)
        end
    end)
    
    print("Registered tool for levitation:", tool.Name)
end

-- Enhanced cleanup with proper connection management
local function unregisterTool(tool)
    if not activeTools[tool] then return end
    
    -- Clean up connections
    if toolConnections[tool] then
        toolConnections[tool]:Disconnect()
        toolConnections[tool] = nil
    end
    
    -- Clean up physics objects and effects
    local handle = tool:FindFirstChild("Handle")
    if handle then
        local bp = handle:FindFirstChild("LevitatePosition")
        if bp then bp:Destroy() end
        
        local bav = handle:FindFirstChild("Spinning")
        if bav then bav:Destroy() end
        
        removeGlowEffect(handle)
        
        -- Reset physics properties
        handle.CanCollide = true
    end
    
    activeTools[tool] = nil
    print("Unregistered tool from levitation:", tool.Name)
end

-- Character respawn handling
local function onCharacterAdded(newCharacter)
    Character = newCharacter
    Head = Character:WaitForChild("Head")
    
    -- Clear all active tools when character respawns
    for tool in pairs(activeTools) do
        unregisterTool(tool)
    end
    
    print("Character respawned, cleared active tools")
end

-- Cleanup function for script shutdown
local function cleanup()
    isScriptActive = false
    
    for tool in pairs(activeTools) do
        unregisterTool(tool)
    end
    
    for _, connection in pairs(toolConnections) do
        if connection then
            connection:Disconnect()
        end
    end
    
    print("Tool levitation script cleaned up")
end

-- Enhanced configuration update with validation
local function updateConfig(newConfig)
    if type(newConfig) ~= "table" then
        warn("Invalid configuration provided")
        return false
    end
    
    for key, value in pairs(newConfig) do
        if config[key] ~= nil then
            if type(value) == type(config[key]) then
                config[key] = value
                print("Updated config:", key, "=", value)
            else
                warn("Invalid type for config key:", key)
            end
        else
            warn("Unknown config key:", key)
        end
    end
    
    return true
end

-- Auto-cleanup for old tools
local function performAutoCleanup()
    local currentTime = tick()
    local cleanedCount = 0
    
    for tool, data in pairs(activeTools) do
        if currentTime - data.registeredTime > config.autoCleanupTime then
            unregisterTool(tool)
            cleanedCount = cleanedCount + 1
        end
    end
    
    if cleanedCount > 0 then
        print("Auto-cleanup removed", cleanedCount, "old tools")
    end
end

-- Event connections
Workspace.ChildAdded:Connect(function(child)
    if isScriptActive and child:IsA("Tool") and child:FindFirstChild("Handle") then
        wait(0.1) -- Small delay to ensure tool is fully loaded
        registerTool(child)
    end
end)

Workspace.ChildRemoved:Connect(function(child)
    if child:IsA("Tool") then
        unregisterTool(child)
    end
end)

-- Character respawn handling
Player.CharacterAdded:Connect(onCharacterAdded)

-- Enhanced main update loop with performance optimization
local updateConnection
updateConnection = RunService.Heartbeat:Connect(function()
    if not isScriptActive then
        updateConnection:Disconnect()
        return
    end
    
    local currentTime = tick()
    
    -- Throttle updates for performance
    if currentTime - lastUpdateTime < config.updateInterval then
        return
    end
    
    lastUpdateTime = currentTime
    
    -- Update active tools
    for tool in pairs(activeTools) do
        if not levitateAndSpin(tool) then
            -- Tool cleanup will be handled by levitateAndSpin if needed
        else
            activeTools[tool].lastUpdateTime = currentTime
        end
    end
    
    -- Perform auto-cleanup every 60 seconds
    if currentTime % 60 < config.updateInterval then
        performAutoCleanup()
    end
end)

-- Initial scan for existing tools
wait(1) -- Wait for everything to load
for _, child in ipairs(Workspace:GetChildren()) do
    if child:IsA("Tool") and child:FindFirstChild("Handle") then
        registerTool(child)
    end
end

-- Cleanup on script removal
game:GetService("Players").PlayerRemoving:Connect(function(player)
    if player == Player then
        cleanup()
    end
end)

-- Public API for external control
_G.ToolLevitation = {
    updateConfig = updateConfig,
    cleanup = cleanup,
    getActiveToolCount = function()
        local count = 0
        for _ in pairs(activeTools) do
            count = count + 1
        end
        return count
    end,
    toggleScript = function(enabled)
        isScriptActive = enabled
        if not enabled then
            cleanup()
        end
    end
}

print("Enhanced Tool Levitation Script loaded successfully!")
print("Active tools will hover", config.hoverHeight, "studs above your head")
print("Use _G.ToolLevitation to control the script programmatically")

-- Example usage:
-- _G.ToolLevitation.updateConfig({hoverHeight = 15, spinSpeed = 30})
-- _G.ToolLevitation.toggleScript(false) -- disable script
-- print("Active tools:", _G.ToolLevitation.getActiveToolCount())
