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
    spinSpeed = 8,
    transitionTime = 0.8,
    updateInterval = 1/60,
    bodyPosition = {
        maxForce = Vector3.new(15000, 15000, 15000),
        p = 8000,
        d = 800
    },
    teleportDistanceThreshold = 100,
    teleportTweenTime = 0.5
}

-- 10 Unique, Working Rotation Modes
local rotationModes = {
    -- Mode 1: Classic Horizontal Circle
    function(data, t, torsoPos)
        local angle = data.angle + t
        local x = math.sin(angle) * data.radius
        local z = math.cos(angle) * data.radius
        local y = data.height
        return torsoPos + Vector3.new(x, y, z)
    end,
    
    -- Mode 2: Vertical Wave Circle
    function(data, t, torsoPos)
        local angle = data.angle + t
        local x = math.sin(angle) * data.radius
        local z = math.cos(angle) * data.radius
        local y = data.height + math.sin(t * 3 + data.angle) * 3
        return torsoPos + Vector3.new(x, y, z)
    end,
    
    -- Mode 3: Expanding/Contracting Pulse
    function(data, t, torsoPos)
        local angle = data.angle + t
        local pulse = 1 + math.sin(t * 2) * 0.5
        local x = math.sin(angle) * data.radius * pulse
        local z = math.cos(angle) * data.radius * pulse
        local y = data.height
        return torsoPos + Vector3.new(x, y, z)
    end,
    
    -- Mode 4: Vertical Circle (Ferris Wheel)
    function(data, t, torsoPos)
        local angle = data.angle + t
        local x = math.sin(angle) * data.radius
        local y = data.height + math.cos(angle) * data.radius
        local z = 0
        return torsoPos + Vector3.new(x, y, z)
    end,
    
    -- Mode 5: Tilted Diagonal Orbit
    function(data, t, torsoPos)
        local angle = data.angle + t
        local x = math.sin(angle) * data.radius
        local y = data.height + math.sin(angle) * data.radius * 0.5
        local z = math.cos(angle) * data.radius
        return torsoPos + Vector3.new(x, y, z)
    end,
    
    -- Mode 6: Figure Eight (Lemniscate)
    function(data, t, torsoPos)
        local angle = data.angle + t
        local scale = data.radius * 0.7
        local denom = 1 + math.sin(angle) * math.sin(angle)
        local x = scale * math.cos(angle) / denom
        local z = scale * math.sin(angle) * math.cos(angle) / denom
        local y = data.height
        return torsoPos + Vector3.new(x, y, z)
    end,
    
    -- Mode 7: Rising Spiral
    function(data, t, torsoPos)
        local angle = data.angle + t * 2
        local heightCycle = math.sin(t * 0.5) * 5
        local x = math.sin(angle) * data.radius
        local z = math.cos(angle) * data.radius
        local y = data.height + heightCycle
        return torsoPos + Vector3.new(x, y, z)
    end,
    
    -- Mode 8: Star Pattern (5 Points)
    function(data, t, torsoPos)
        local angle = (data.angle + t) % (2 * math.pi)
        local points = 5
        local pointAngle = math.floor(angle / (2 * math.pi / points)) * (2 * math.pi / points)
        local nextPointAngle = pointAngle + (2 * math.pi / points)
        local progress = (angle - pointAngle) / (2 * math.pi / points)
        
        local r1 = data.radius
        local r2 = data.radius * 0.4
        
        local x1 = math.sin(pointAngle) * r1
        local z1 = math.cos(pointAngle) * r1
        local x2 = math.sin(pointAngle + math.pi / points) * r2
        local z2 = math.cos(pointAngle + math.pi / points) * r2
        
        local x, z
        if progress < 0.5 then
            local p = progress * 2
            x = x1 + (x2 - x1) * p
            z = z1 + (z2 - z1) * p
        else
            local p = (progress - 0.5) * 2
            local x3 = math.sin(nextPointAngle) * r1
            local z3 = math.cos(nextPointAngle) * r1
            x = x2 + (x3 - x2) * p
            z = z2 + (z3 - z2) * p
        end
        
        local y = data.height
        return torsoPos + Vector3.new(x, y, z)
    end,
    
    -- Mode 9: Elliptical Orbit
    function(data, t, torsoPos)
        local angle = data.angle + t
        local x = math.sin(angle) * data.radius * 1.5
        local z = math.cos(angle) * data.radius * 0.6
        local y = data.height + math.sin(t * 2) * 1
        return torsoPos + Vector3.new(x, y, z)
    end,
    
    -- Mode 10: Chaotic Wobble
    function(data, t, torsoPos)
        local angle = data.angle + t
        local wobbleX = math.sin(t * 4 + data.angle) * 2
        local wobbleZ = math.cos(t * 3.5 + data.angle) * 2
        local x = math.sin(angle) * data.radius + wobbleX
        local z = math.cos(angle) * data.radius + wobbleZ
        local y = data.height + math.sin(t * 5 + data.angle) * 2.5
        return torsoPos + Vector3.new(x, y, z)
    end
}

local modeNames = {
    "Classic Horizontal Circle",
    "Vertical Wave Circle",
    "Expanding/Contracting Pulse",
    "Vertical Circle (Ferris Wheel)",
    "Tilted Diagonal Orbit",
    "Figure Eight (Lemniscate)",
    "Rising Spiral",
    "Star Pattern (5 Points)",
    "Elliptical Orbit",
    "Chaotic Wobble"
}

local currentRotationMode = 1

-- Disable pickup completely
local function disableToolPickup(tool)
    if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
        local handle = tool.Handle
        handle.CanCollide = false
        handle.Anchored = false
        handle.CanTouch = false
        
        -- Prevent picking up the tool
        tool.CanBeDropped = false
        pcall(function()
            tool.RequiresHandle = false
        end)
        
        pcall(function()
            handle:SetNetworkOwner(player)
        end)
        
        -- Continuously prevent tool from being equipped
        tool.Equipped:Connect(function()
            task.wait()
            if tool.Parent == character then
                tool.Parent = Workspace
            end
        end)
        
        -- Keep tool in workspace
        tool.Changed:Connect(function(prop)
            if prop == "Parent" and tool.Parent == character then
                task.wait()
                tool.Parent = Workspace
            end
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
            
            -- Create BodyAngularVelocity for spinning
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

-- Continuous protection against pickup
RunService.Heartbeat:Connect(function()
    for tool, data in pairs(toolData) do
        if tool.Parent == character then
            -- If tool somehow gets equipped, immediately drop it back to workspace
            tool.Parent = Workspace
        end
    end
end)

-- Update loop
local lastUpdate = 0
RunService.Heartbeat:Connect(function(deltaTime)
    local now = os.clock()
    if now - lastUpdate < CONFIG.updateInterval then return end
    lastUpdate = now
    
    for tool, data in pairs(toolData) do
        if tool.Parent and tool:FindFirstChild("Handle") and data.bodyPosition and not data.teleporting then
            local success, err = pcall(function()
                local t = now * CONFIG.orbitSpeed
                local targetPos = rotationModes[currentRotationMode](data, t, torso.Position)
                data.bodyPosition.Position = targetPos
                
                -- Update spinning
                if spinEnabled then
                    data.bodyAngularVelocity.AngularVelocity = Vector3.new(0, CONFIG.spinSpeed, 0)
                else
                    data.bodyAngularVelocity.AngularVelocity = Vector3.new(0, 0, 0)
                end
            end)
            
            if not success then
                warn("Error in rotation mode " .. currentRotationMode .. ": " .. tostring(err))
            end
        else
            -- Cleanup if tool is gone
            if not tool.Parent or not tool:FindFirstChild("Handle") then
                if data.bodyPosition then pcall(function() data.bodyPosition:Destroy() end) end
                if data.bodyAngularVelocity then pcall(function() data.bodyAngularVelocity:Destroy() end) end
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
        -- Teleport ALL tools to orbit, regardless of distance
        local teleportCount = 0
        for tool, data in pairs(toolData) do
            if tool:FindFirstChild("Handle") and data.bodyPosition then
                local handle = tool.Handle
                teleportCount = teleportCount + 1
                
                data.teleporting = true
                
                -- Calculate target position
                local t = os.clock() * CONFIG.orbitSpeed
                local targetPos = rotationModes[currentRotationMode](data, t, torso.Position)
                
                -- Method 1: Destroy and recreate BodyPosition for instant effect
                if data.bodyPosition then
                    data.bodyPosition:Destroy()
                end
                if data.bodyAngularVelocity then
                    data.bodyAngularVelocity:Destroy()
                end
                
                -- Reset handle physics
                handle.Anchored = true
                handle.CFrame = CFrame.new(targetPos)
                handle.Velocity = Vector3.new(0, 0, 0)
                handle.RotVelocity = Vector3.new(0, 0, 0)
                handle.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                handle.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                
                task.wait(0.05)
                handle.Anchored = false
                
                -- Recreate BodyPosition
                local bp = Instance.new("BodyPosition", handle)
                bp.MaxForce = CONFIG.bodyPosition.maxForce
                bp.P = CONFIG.bodyPosition.p
                bp.D = CONFIG.bodyPosition.d
                bp.Position = targetPos
                
                -- Recreate BodyAngularVelocity
                local bav = Instance.new("BodyAngularVelocity", handle)
                bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                bav.AngularVelocity = spinEnabled and Vector3.new(0, CONFIG.spinSpeed, 0) or Vector3.new(0, 0, 0)
                
                -- Update data references
                data.bodyPosition = bp
                data.bodyAngularVelocity = bav
                data.teleporting = false
                
                -- Set network ownership
                pcall(function()
                    handle:SetNetworkOwner(player)
                end)
            end
        end
        
        print("Teleported " .. teleportCount .. " tools to orbit positions")
        
    elseif input.KeyCode == Enum.KeyCode.V then
        local oldMode = currentRotationMode
        repeat
            currentRotationMode = math.random(1, #rotationModes)
        until currentRotationMode ~= oldMode or #rotationModes == 1
        
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

print("Tool Orbit Script Loaded!")
print("Controls: Z = Toggle Spin | X = Teleport Tools | V = Change Rotation Mode")
print("Current Mode: " .. modeNames[currentRotationMode])
