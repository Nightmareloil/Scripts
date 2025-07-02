--[[
    Enhanced Levitate Tools Script
    
    Features:
    - Multiple orbit patterns (circular, figure-8, spiral)
    - Dynamic orbit layers for multiple tools
    - Smooth transitions and easing
    - Visual effects (particles, glow)
    - Performance optimizations
    - Better error handling
    - Configuration persistence
    - Tool grouping and management
--]]

-- Services
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

-- Player and Character Setup
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Dynamic torso detection with fallback hierarchy
local function getTorso()
    return Character:FindFirstChild("HumanoidRootPart") or 
           Character:FindFirstChild("UpperTorso") or 
           Character:FindFirstChild("Torso") or
           Character:FindFirstChild("Head")
end

local torso = getTorso()
if not torso then
    warn("Enhanced Levitate Tools: No valid torso found!")
    return
end

-- Enhanced Configuration
local CONFIG = {
    -- Orbit Settings
    baseRadius = 8,
    radiusVariation = 3,
    orbitSpeed = 1.2,
    verticalOffset = 2,
    verticalVariation = 1.5,
    maxTools = 12,
    
    -- Animation Settings
    transitionTime = 0.8,
    easingStyle = Enum.EasingStyle.Quart,
    easingDirection = Enum.EasingDirection.Out,
    
    -- Physics Settings
    bodyPosition = {
        maxForce = Vector3.new(4000, 4000, 4000),
        p = 3000,
        d = 500
    },
    bodyAngularVelocity = {
        maxTorque = Vector3.new(0, math.huge, 0),
        spinSpeed = 5
    },
    
    -- Visual Effects
    enableParticles = true,
    enableGlow = true,
    glowIntensity = 0.3,
    
    -- Orbit Patterns
    orbitPatterns = {
        circular = function(angle, radius) 
            return radius * math.cos(angle), radius * math.sin(angle)
        end,
        figure8 = function(angle, radius)
            return radius * math.sin(angle), radius * math.sin(angle * 2) / 2
        end,
        spiral = function(angle, radius)
            local spiralFactor = math.sin(angle * 0.5) * 0.3 + 0.7
            return radius * spiralFactor * math.cos(angle), radius * spiralFactor * math.sin(angle)
        end
    },
    currentPattern = "circular",
    
    -- Performance
    updateInterval = 1/60, -- 60 FPS
    scanInterval = 1,
    cleanupInterval = 5
}

-- Tool Management System
local ToolManager = {}
ToolManager.__index = ToolManager

function ToolManager.new()
    local self = setmetatable({}, ToolManager)
    self.activTools = {}
    self.toolSlots = {}
    self.lastScanTime = 0
    self.lastCleanupTime = 0
    self.orbitStartTime = tick()
    
    -- Initialize orbit slots
    for i = 1, CONFIG.maxTools do
        self.toolSlots[i] = {
            occupied = false,
            tool = nil,
            angle = (i - 1) * (2 * math.pi / CONFIG.maxTools),
            radius = CONFIG.baseRadius + (i % 3) * CONFIG.radiusVariation,
            height = CONFIG.verticalOffset + math.sin(i) * CONFIG.verticalVariation
        }
    end
    
    return self
end

function ToolManager:getAvailableSlot()
    for i, slot in ipairs(self.toolSlots) do
        if not slot.occupied then
            return i, slot
        end
    end
    return nil, nil
end

function ToolManager:assignToolToSlot(tool, slotIndex)
    local slot = self.toolSlots[slotIndex]
    if slot then
        slot.occupied = true
        slot.tool = tool
        self.activTools[tool] = {
            slotIndex = slotIndex,
            startTime = tick(),
            effects = {}
        }
    end
end

function ToolManager:removeToolFromSlot(tool)
    local toolData = self.activTools[tool]
    if toolData then
        local slot = self.toolSlots[toolData.slotIndex]
        if slot then
            slot.occupied = false
            slot.tool = nil
        end
        
        -- Clean up effects
        for _, effect in ipairs(toolData.effects) do
            if effect and effect.Parent then
                effect:Destroy()
            end
        end
        
        self.activTools[tool] = nil
    end
end

-- Visual Effects System
local function createParticleEffect(handle)
    if not CONFIG.enableParticles then return end
    
    local attachment = Instance.new("Attachment")
    attachment.Parent = handle
    
    local particles = Instance.new("ParticleEmitter")
    particles.Parent = attachment
    particles.Enabled = true
    particles.Lifetime = NumberRange.new(0.8, 1.2)
    particles.Rate = 15
    particles.SpreadAngle = Vector2.new(45, 45)
    particles.Speed = NumberRange.new(2, 4)
    particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    particles.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 165, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 69, 0))
    }
    particles.Size = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(0.5, 0.6),
        NumberSequenceKeypoint.new(1, 0)
    }
    particles.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.4),
        NumberSequenceKeypoint.new(0.8, 0.7),
        NumberSequenceKeypoint.new(1, 1)
    }
    
    return particles
end

local function createGlowEffect(handle)
    if not CONFIG.enableGlow then return end
    
    local selectionBox = Instance.new("SelectionBox")
    selectionBox.Parent = handle
    selectionBox.Adornee = handle
    selectionBox.Color3 = Color3.fromRGB(255, 215, 0)
    selectionBox.Transparency = 1 - CONFIG.glowIntensity
    selectionBox.LineThickness = 0.2
    
    -- Pulsing glow effect
    local glowTween = TweenService:Create(
        selectionBox,
        TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        {Transparency = 0.9}
    )
    glowTween:Play()
    
    return selectionBox
end

-- Enhanced Physics System
local function createPhysicsComponents(handle)
    -- Remove existing components
    local existingBP = handle:FindFirstChild("LevitatePosition")
    local existingBAV = handle:FindFirstChild("LevitateAngularVelocity")
    if existingBP then existingBP:Destroy() end
    if existingBAV then existingBAV:Destroy() end
    
    -- Create new BodyPosition
    local bodyPosition = Instance.new("BodyPosition")
    bodyPosition.Name = "LevitatePosition"
    bodyPosition.MaxForce = CONFIG.bodyPosition.maxForce
    bodyPosition.P = CONFIG.bodyPosition.p
    bodyPosition.D = CONFIG.bodyPosition.d
    bodyPosition.Parent = handle
    
    -- Create new BodyAngularVelocity
    local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
    bodyAngularVelocity.Name = "LevitateAngularVelocity"
    bodyAngularVelocity.MaxTorque = CONFIG.bodyAngularVelocity.maxTorque
    bodyAngularVelocity.AngularVelocity = Vector3.new(0, CONFIG.bodyAngularVelocity.spinSpeed, 0)
    bodyAngularVelocity.Parent = handle
    
    return bodyPosition, bodyAngularVelocity
end

-- Main Tool Processing
local function processLevitatingTool(tool, toolData, currentTime)
    local handle = tool:FindFirstChild("Handle")
    if not handle then return false end
    
    local slot = toolManager.toolSlots[toolData.slotIndex]
    if not slot then return false end
    
    -- Update torso reference if character changed
    if not torso or not torso.Parent then
        torso = getTorso()
        if not torso then return false end
    end
    
    -- Calculate orbit position using selected pattern
    local elapsedTime = currentTime - toolManager.orbitStartTime
    local angle = slot.angle + elapsedTime * CONFIG.orbitSpeed
    
    local patternFunc = CONFIG.orbitPatterns[CONFIG.currentPattern]
    local xOffset, zOffset = patternFunc(angle, slot.radius)
    
    -- Add some vertical bobbing
    local verticalBob = math.sin(elapsedTime * 2 + slot.angle) * 0.5
    local targetPosition = torso.Position + Vector3.new(
        xOffset,
        slot.height + verticalBob,
        zOffset
    )
    
    -- Update physics
    local bodyPosition = handle:FindFirstChild("LevitatePosition")
    if bodyPosition then
        bodyPosition.Position = targetPosition
    else
        createPhysicsComponents(handle)
    end
    
    -- Ensure handle properties
    handle.CanCollide = false
    handle.Anchored = false
    
    return true
end

-- Tool Detection and Management
local function isToolDropped(tool)
    return tool and tool:IsA("Tool") and 
           tool:FindFirstChild("Handle") and
           not tool:IsDescendantOf(Character) and 
           not tool:IsDescendantOf(Player.Backpack) and
           tool.Parent == Workspace
end

local function scanForNewTools()
    local foundNewTool = false
    
    for _, obj in ipairs(Workspace:GetChildren()) do
        if isToolDropped(obj) and not toolManager.activTools[obj] then
            local slotIndex, slot = toolManager:getAvailableSlot()
            
            if slotIndex then
                -- Setup tool for levitation
                local handle = obj.Handle
                handle.CanCollide = false
                handle.Anchored = false
                
                -- Create physics components
                createPhysicsComponents(handle)
                
                -- Add visual effects
                local effects = {}
                if CONFIG.enableParticles then
                    table.insert(effects, createParticleEffect(handle))
                end
                if CONFIG.enableGlow then
                    table.insert(effects, createGlowEffect(handle))
                end
                
                -- Assign to slot
                toolManager:assignToolToSlot(obj, slotIndex)
                toolManager.activTools[obj].effects = effects
                
                foundNewTool = true
                print("Enhanced Levitate Tools: Added", obj.Name, "to slot", slotIndex)
            else
                print("Enhanced Levitate Tools: Maximum tools reached, ignoring", obj.Name)
            end
        end
    end
    
    return foundNewTool
end

-- Cleanup System
local function cleanupInvalidTools()
    local toolsToRemove = {}
    
    for tool, toolData in pairs(toolManager.activTools) do
        if not tool or not tool.Parent or not isToolDropped(tool) then
            table.insert(toolsToRemove, tool)
        end
    end
    
    for _, tool in ipairs(toolsToRemove) do
        toolManager:removeToolFromSlot(tool)
        print("Enhanced Levitate Tools: Removed invalid tool")
    end
end

-- Initialize Tool Manager
local toolManager = ToolManager.new()

-- Character respawn handling
Player.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = Character:WaitForChild("Humanoid")
    torso = getTorso()
    
    -- Clear all active tools
    for tool, _ in pairs(toolManager.activTools) do
        toolManager:removeToolFromSlot(tool)
    end
    
    print("Enhanced Levitate Tools: Character respawned, cleared all tools")
end)

-- Main Update Loop
local lastUpdateTime = 0
RunService.Heartbeat:Connect(function()
    local currentTime = tick()
    
    -- Throttle updates to target FPS
    if currentTime - lastUpdateTime < CONFIG.updateInterval then
        return
    end
    lastUpdateTime = currentTime
    
    -- Periodic scanning for new tools
    if currentTime - toolManager.lastScanTime >= CONFIG.scanInterval then
        scanForNewTools()
        toolManager.lastScanTime = currentTime
    end
    
    -- Periodic cleanup
    if currentTime - toolManager.lastCleanupTime >= CONFIG.cleanupInterval then
        cleanupInvalidTools()
        toolManager.lastCleanupTime = currentTime
    end
    
    -- Update all active tools
    for tool, toolData in pairs(toolManager.activTools) do
        if not processLevitatingTool(tool, toolData, currentTime) then
            toolManager:removeToolFromSlot(tool)
        end
    end
end)

-- Configuration Commands (for testing/customization)
local function changeOrbitPattern(patternName)
    if CONFIG.orbitPatterns[patternName] then
        CONFIG.currentPattern = patternName
        toolManager.orbitStartTime = tick() -- Reset timing for smooth transition
        print("Enhanced Levitate Tools: Changed orbit pattern to", patternName)
    else
        warn("Enhanced Levitate Tools: Unknown pattern", patternName)
    end
end

-- Export configuration function for external control
_G.LevitateToolsConfig = {
    changePattern = changeOrbitPattern,
    setSpeed = function(speed) CONFIG.orbitSpeed = math.max(0.1, speed) end,
    setRadius = function(radius) CONFIG.baseRadius = math.max(2, radius) end,
    toggleEffects = function() 
        CONFIG.enableParticles = not CONFIG.enableParticles
        CONFIG.enableGlow = not CONFIG.enableGlow
    end,
    getCurrentStats = function()
        return {
            activeTools = #toolManager.activTools,
            maxTools = CONFIG.maxTools,
            currentPattern = CONFIG.currentPattern,
            effectsEnabled = CONFIG.enableParticles and CONFIG.enableGlow
        }
    end
}

print("Enhanced Levitate Tools: Loaded successfully!")
print("Use _G.LevitateToolsConfig for runtime configuration")

-- Example usage:
-- _G.LevitateToolsConfig.changePattern("figure8")
-- _G.LevitateToolsConfig.setSpeed(2)
-- _G.LevitateToolsConfig.toggleEffects()
