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
    baseRadius = 15, -- Increased to move tools farther away
    radiusVariation = 5, -- Adjusted variation
    orbitSpeed = 1.2,
    verticalOffset = 2,
    verticalVariation = 1.5,
    spinSpeed = 5, -- Old spin speed restored
    transitionTime = 0.8,
    updateInterval = 1/60,
    bodyPosition = {
        maxForce = Vector3.new(12000, 12000, 12000), -- Increased for better following
        p = 6000, -- Adjusted for smoother control
        d = 1000 -- Adjusted for less damping issues
    },
    teleportDistanceThreshold = 50, -- Increased threshold
    teleportTweenTime = 0.3
}

-- Rotation Modes
local rotationModes = {
    -- Mode 1: Basic Horizontal Circle
    function(data, t, torsoPos)
        local angle = data.angle + t
        local x = math.sin(angle) * data.radius
        local z = math.cos(angle) * data.radius
        local y = data.height + math.sin(t * 2 + data.angle) * 0.5
        return torsoPos + Vector3.new(x, y, z)
    end,
    -- Mode 2: Reverse Horizontal Circle
    function(data, t, torsoPos)
        local angle = data.angle - t
        local x = math.sin(angle) * data.radius
        local z = math.cos(angle) * data.radius
        local y = data.height + math.sin(t * 2 + data.angle) * 0.5
        return torsoPos + Vector3.new(x, y, z)
    end,
    -- Mode 3: Elliptical Horizontal
    function(data, t, torsoPos)
        local angle = data.angle + t
        local x = math.sin(angle) * data.radius * 1.5
        local z = math.cos(angle) * data.radius * 0.75
        local y = data.height + math.sin(t * 2 + data.angle) * 0.5
        return torsoPos + Vector3.new(x, y, z)
    end,
    -- Mode 4: Vertical Circle
    function(data, t, torsoPos)
        local angle = data.angle + t
        local x = math.sin(angle) * data.radius
        local y = data.height + math.cos(angle) * data.radius
        local z = math.sin(t * 0.5 + data.angle) * 2
        return torsoPos + Vector3.new(x, y, z)
    end,
    -- Mode 5: Wavy Orbit
    function(data, t, torsoPos)
        local angle = data.angle + t
        local x = math.sin(angle) * data.radius + math.sin(t * 3) * 2
        local z = math.cos(angle) * data.radius + math.cos(t * 3) * 2
        local y = data.height + math.sin(t * 2 + data.angle) * 1.5
        return torsoPos + Vector3.new(x, y, z)
    end,
    -- Mode 6: Figure Eight
    function(data, t, torsoPos)
        local angle = data.angle + t
        local scale = data.radius / math.sqrt(2)
        local denom = (math.sin(angle) ^ 2 + 1)
        local x = scale * math.cos(angle) / denom
        local z = scale * math.cos(angle) * math.sin(angle) / denom
        local y = data.height + math.sin(t * 1.5 + data.angle) * 1
        return torsoPos + Vector3.new(x, y, z)
    end,
    -- Mode 7: Spiral Orbit
    function(data, t, torsoPos)
        local angle = data.angle + t * 2
        local r = data.radius * (1 + 0.1 * math.sin(t / 2))
        local x = math.sin(angle) * r
        local z = math.cos(angle) * r
        local y = data.height + (t % (2 * math.pi)) / 2
        return torsoPos + Vector3.new(x, y, z)
    end,
    -- Mode 8: Bouncing Vertical Line
    function(data, t, torsoPos)
        local angle = data.angle
        local x = math.sin(angle) * data.radius
        local z = math.cos(angle) * (data.radius / 2)
        local y = data.height + math.abs(math.sin(t * 3 + data.angle)) * (data.verticalVariation * 2)
        return torsoPos + Vector3.new(x, y, z)
    end,
    -- Mode 9: Random Jitter Orbit
    function(data, t, torsoPos)
        local angle = data.angle + t
        local jitter = math.random(-1, 1) * 0.5
        local x = math.sin(angle + jitter) * data.radius
        local z = math.cos(angle + jitter) * data.radius
        local y = data.height + math.sin(t * 2 + data.angle + jitter) * 1.5
        return torsoPos + Vector3.new(x, y, z)
    end,
    -- Mode 10: Heart Shape Orbit
    function(data, t, torsoPos)
        local angle = data.angle + t
        local theta = angle % (2 * math.pi)
        local x = data.radius * (math.sin(theta) ^ 3)
        local z = data.radius * (13 * math.cos(theta) / 16 - 5 * math.cos(2 * theta) / 16 - 2 * math.cos(3 * theta) / 16 - math.cos(4 * theta) / 16)
        local y = data.height + math.sin(t + data.angle) * 0.5
        return torsoPos + Vector3.new(x, y, z)
    end
}

local modeNames = {
    "Basic Horizontal Circle",
    "Reverse Horizontal Circle",
    "Elliptical Horizontal",
    "Vertical Circle",
    "Wavy Orbit",
    "Figure Eight",
    "Spiral Orbit",
    "Bouncing Vertical Line",
    "Random Jitter Orbit",
    "Heart Shape Orbit"
}

local currentRotationMode = 1 -- Start with mode 1

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
            local bp = Instance.new("BodyPosition", handle)
            bp.MaxForce = CONFIG.bodyPosition.maxForce
            bp.P = CONFIG.bodyPosition.p
            bp.D = CONFIG.bodyPosition.d
            local bav = Instance.new("BodyAngularVelocity", handle)
            bav.MaxTorque = Vector3.new(0, math.huge, 0)
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
            local t = os.clock() * CONFIG.orbitSpeed
            local targetPos = rotationModes[currentRotationMode](toolData[tool], t, torso.Position)
            local tweenInfo = TweenInfo.new(CONFIG.transitionTime, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            local tween = TweenService:Create(handle, tweenInfo, {Position = targetPos})
            bp.MaxForce = Vector3.new(0, 0, 0) -- Disable during initial tween
            tween:Play()
            tween.Completed:Connect(function()
                bp.Position = targetPos
                bp.MaxForce = CONFIG.bodyPosition.maxForce
            end)
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
            data.bodyAngularVelocity.AngularVelocity = spinEnabled and Vector3.new(0, CONFIG.spinSpeed, 0) or Vector3.new(0, 0, 0)
        else
            if data.bodyPosition then data.bodyPosition:Destroy() end
            if data.bodyAngularVelocity then data.bodyAngularVelocity:Destroy() end
            toolData[tool] = nil
        end
    end
end)

-- Input handling
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.KeyCode == Enum.KeyCode.Z then
        spinEnabled = not spinEnabled
    elseif input.KeyCode == Enum.KeyCode.X then
        for tool, data in pairs(toolData) do
            if tool:FindFirstChild("Handle") and data.bodyPosition then
                local handle = tool.Handle
                local t = os.clock() * CONFIG.orbitSpeed
                local targetPos = rotationModes[currentRotationMode](data, t, torso.Position)
                local currentDist = (handle.Position - targetPos).Magnitude
                if currentDist > CONFIG.teleportDistanceThreshold then
                    data.teleporting = true
                    local tweenInfo = TweenInfo.new(CONFIG.teleportTweenTime, Enum.EasingStyle.Linear)
                    local tween = TweenService:Create(handle, tweenInfo, {Position = targetPos})
                    data.bodyPosition.MaxForce = Vector3.new(0, 0, 0) -- Disable BodyPosition during tween to prevent interference
                    tween:Play()
                    tween.Completed:Connect(function()
                        data.bodyPosition.Position = targetPos
                        data.bodyPosition.MaxForce = CONFIG.bodyPosition.maxForce
                        data.teleporting = false
                    end)
                end
            end
        end
    elseif input.KeyCode == Enum.KeyCode.V then
        currentRotationMode = math.random(1, #rotationModes)
        print("Switched to rotation mode: " .. modeNames[currentRotationMode])
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
