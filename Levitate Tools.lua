-- Injectable Executor Script
-- Keys:
-- Z: Toggle tool spinning
-- X: Teleport far tools to orbit positions
-- V: Change to a random rotation mode (10 different modes)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local torso = character:WaitForChild("HumanoidRootPart")

-- Wait for game to load
repeat task.wait() until game:IsLoaded()

-- Collect tools from Workspace
local tools = {}
local function collectTools()
    tools = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Tool") and obj.Parent == Workspace then
            table.insert(tools, obj)
        end
    end
end
collectTools()
if #tools == 0 then
    warn("No tools found in Workspace!")
end

-- Configuration
local CONFIG = {
    maxTools = 12,
    baseRadius = 15,
    radiusVariation = 5,
    orbitSpeed = 1.2,
    verticalOffset = 2,
    verticalVariation = 1.5,
    spinSpeed = 8, -- Improved spin speed
    transitionTime = 0.8,
    updateInterval = 1/60,
    bodyPosition = {
        maxForce = Vector3.new(15000, 15000, 15000),
        p = 8000,
        d = 800
    },
    teleportDistanceThreshold = 100, -- Increased to work at longer distances
    teleportTweenTime = 0.5
}

-- 10 Unique Rotation Modes
local rotationModes = {
    -- Mode 1: Classic Circle
    function(data, t, torsoPos)
        local angle = data.angle + t
        local x = math.sin(angle) * data.radius
        local z = math.cos(angle) * data.radius
        local y = data.height
        return torsoPos + Vector3.new(x, y, z)
    end,
    
    -- Mode 2: Wave Circle (vertical sine wave)
    function(data, t, torsoPos)
        local angle = data.angle + t
        local x = math.sin(angle) * data.radius
        local z = math.cos(angle) * data.radius
        local y = data.height + math.sin(t * 3 + data.angle) * 3
        return torsoPos + Vector3.new(x, y, z)
    end,
    
    -- Mode 3: Double Helix
    function(data, t, torsoPos)
        local angle = data.angle + t * 1.5
        local radius = data.radius + math.sin(t + data.angle * 2) * 3
        local x = math.sin(angle) * radius
        local z = math.cos(angle) * radius
        local y = data.height + math.sin(t * 2) * 4
        return torsoPos + Vector3.new(x, y, z)
    end,
    
    -- Mode 4: Tilted Orbit (45 degree angle)
    function(data, t, torsoPos)
        local angle = data.angle + t
        local x = math.sin(angle) * data.radius
        local y = data.height + math.cos(angle) * data.radius * 0.7
        local z = math.cos(angle) * data.radius * 0.7
        return torsoPos + Vector3.new(x, y, z)
    end,
    
    -- Mode 5: Pulsing Orbit
    function(data, t, torsoPos)
        local angle = data.angle + t
        local pulse = 1 + math.sin(t * 2) * 0.4
        local x = math.sin(angle) * data.radius * pulse
        local z = math.cos(angle) * data.radius * pulse
        local y = data.height
        return torsoPos + Vector3.new(x, y, z)
    end,
    
    -- Mode 6: Lemniscate (Infinity Symbol)
    function(data, t, torsoPos)
        local angle = data.angle + t
        local scale = data.radius * 0.8
        local x = scale * math.cos(angle) / (1 + math.sin(angle)^2)
        local z = scale * math.cos(angle) * math.sin(angle) / (1 + math.sin(angle)^2)
        local y = data.height + math.sin(t * 0.5) * 2
        return torsoPos + Vector3.new(x, y, z)
    end,
    
    -- Mode 7: Tornado Spiral
    function(data, t, torsoPos)
        local angle = data.angle + t * 2
        local heightCycle = (t * 0.5) % (2 * math.pi)
        local radius = data.radius * (1 - heightCycle / (2 * math.pi) * 0.6)
        local x = math.sin(angle) * radius
        local z = math.cos(angle) * radius
        local y = data.height + heightCycle * 3
        return torsoPos + Vector3.new(x, y, z)
    end,
    
    -- Mode 8: Square Orbit
    function(data, t, torsoPos)
        local angle = (data.angle + t) % (2 * math.pi)
        local side = math.floor(angle / (math.pi / 2))
        local progress = (angle % (math.pi / 2)) / (math.pi / 2)
        local r = data.radius
        local x, z = 0, 0
        
        if side == 0 then
            x = -r + progress * 2 * r
            z = r
        elseif side == 1 then
            x = r
            z = r - progress * 2 * r
        elseif side == 2 then
            x = r - progress * 2 * r
            z = -r
        else
            x = -r
            z = -r + progress * 2 * r
        end
        
        local y = data.height + math.sin(t * 2) * 1.5
        return torsoPos + Vector3.new(x, y, z)
    end,
    
    -- Mode 9: Butterfly Wings
    function(data, t, torsoPos)
        local angle = data.angle + t
        local r = data.radius
        local x = r * math.sin(angle) * (math.exp(math.cos(angle)) - 2 * math.cos(4 * angle) - math.sin(angle / 12)^5) * 0.1
        local z = r * math.cos(angle) * (math.exp(math.cos(angle)) - 2 * math.cos(4 * angle) - math.sin(angle / 12)^5) * 0.1
        local y = data.height + math.sin(t + data.angle) * 2
        return torsoPos + Vector3.new(x, y, z)
    end,
    
    -- Mode 10: Zigzag Orbit
    function(data, t, torsoPos)
        local angle = data.angle + t
        local x = math.sin(angle) * data.radius
        local z = math.cos(angle) * data.radius
        local zigzag = math.floor(t * 2) % 2 == 0 and 1 or -1
        local y = data.height + zigzag * 3
        return torsoPos + Vector3.new(x, y, z)
    end
}

local modeNames = {
    "Classic Circle",
    "Wave Circle",
    "Double Helix",
    "Tilted Orbit",
    "Pulsing Orbit",
    "Lemniscate (Infinity)",
    "Tornado Spiral",
    "Square Orbit",
    "Butterfly Wings",
    "Zigzag Orbit"
}

local currentRotationMode = 1

-- Disable pickup
local function disableToolPickup(tool)
    if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
        local handle = tool.Handle
        handle.CanCollide = false
        handle.Anchored = false
        handle.CanTouch = false
        pcall(function()
            handle:SetNetworkOwner(player)
        end)
    end
end

-- Initialize tools
local toolData = {}
local spinEnabled = true

local function initializeTools()
    toolData = {}
    for i, tool in ipairs(tools) do
        if #toolData < CONFIG.maxTools and tool:FindFirstChild("Handle") then
            disableToolPickup(tool)
            local handle = tool.Handle
            
            -- Create BodyPosition
            local bp = Instance.new("BodyPosition", handle)
            bp.MaxForce = CONFIG.bodyPosition.maxForce
            bp.P = CONFIG.bodyPosition.p
            bp.D = CONFIG.bodyPosition.d
            
            -- Create improved BodyAngularVelocity for spinning
            local bav = Instance.new("BodyAngularVelocity", handle)
            bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            bav.AngularVelocity = Vector3.new(0, CONFIG.spinSpeed, 0)
            
            local baseAngle = (i - 1) * (2 * math.pi / CONFIG.maxTools)
            local radius = CONFIG.baseRadius + (i % 3) * CONFIG.radiusVariation
            local height = CONFIG.verticalOffset + math.sin(i) * CONFIG.verticalVariation
            
            toolData[tool] = {
                angle = baseAngle,
                radius = radius,
                height = height,
                verticalVariation = CONFIG.verticalVariation,
                bodyPosition = bp,
                bodyAngularVelocity = bav,
                teleporting = false
            }
            
            -- Initial positioning
            local t = os.clock() * CONFIG.orbitSpeed
            local targetPos = rotationModes[currentRotationMode](toolData[tool], t, torso.Position)
            bp.Position = targetPos
        end
    end
end
initializeTools()

-- Update loop
local lastUpdate = 0
RunService.Heartbeat:Connect(function(deltaTime)
    local now = os.clock()
    if now - lastUpdate < CONFIG.updateInterval then return end
    lastUpdate = now
    
    for tool, data in pairs(toolData) do
        if tool.Parent and tool:FindFirstChild("Handle") and data.bodyPosition and not data.teleporting then
            local t = now * CONFIG.orbitSpeed
            local targetPos = rotationModes[currentRotationMode](data, t, torso.Position)
            data.bodyPosition.Position = targetPos
            
            -- Update spinning
            if spinEnabled then
                data.bodyAngularVelocity.AngularVelocity = Vector3.new(0, CONFIG.spinSpeed, 0)
            else
                data.bodyAngularVelocity.AngularVelocity = Vector3.new(0, 0, 0)
            end
        else
            -- Cleanup if tool is gone
            if not tool.Parent or not tool:FindFirstChild("Handle") then
                if data.bodyPosition then data.bodyPosition:Destroy() end
                if data.bodyAngularVelocity then data.bodyAngularVelocity:Destroy() end
                toolData[tool] = nil
            end
        end
    end
end)

-- Input handling
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    
    if input.KeyCode == Enum.KeyCode.Z then
        spinEnabled = not spinEnabled
        print("Tool spinning: " .. (spinEnabled and "ON" or "OFF"))
        
    elseif input.KeyCode == Enum.KeyCode.X then
        -- Teleport tools that are far away
        local teleportCount = 0
        for tool, data in pairs(toolData) do
            if tool:FindFirstChild("Handle") and data.bodyPosition then
                local handle = tool.Handle
                local t = os.clock() * CONFIG.orbitSpeed
                local targetPos = rotationModes[currentRotationMode](data, t, torso.Position)
                local currentDist = (handle.Position - torso.Position).Magnitude
                
                -- Check if tool is beyond threshold distance from player
                if currentDist > CONFIG.teleportDistanceThreshold then
                    data.teleporting = true
                    teleportCount = teleportCount + 1
                    
                    -- Disable BodyPosition during teleport
                    data.bodyPosition.MaxForce = Vector3.new(0, 0, 0)
                    
                    -- Instant teleport to target position
                    handle.CFrame = CFrame.new(targetPos)
                    
                    -- Re-enable BodyPosition after brief delay
                    task.wait(0.1)
                    data.bodyPosition.Position = targetPos
                    data.bodyPosition.MaxForce = CONFIG.bodyPosition.maxForce
                    data.teleporting = false
                end
            end
        end
        
        if teleportCount > 0 then
            print("Teleported " .. teleportCount .. " tools to orbit")
        else
            print("No tools need teleporting")
        end
        
    elseif input.KeyCode == Enum.KeyCode.V then
        currentRotationMode = math.random(1, #rotationModes)
        print("Switched to: " .. modeNames[currentRotationMode])
    end
end)

-- Handle respawn
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    torso = character:WaitForChild("HumanoidRootPart")
    collectTools()
    initializeTools()
end)
print("Controls: Z = Toggle Spin | X = Teleport Tools | V = Change Rotation Mode")
