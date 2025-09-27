local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local torso = character:WaitForChild("HumanoidRootPart")

-- Wait for game to load
if not game:IsLoaded() then game.Loaded:Wait() end

-- Collect tools from Workspace on the ground
local tools = {}
local function collectTools()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Tool") and not obj.Parent:FindFirstChild("Humanoid") then
            table.insert(tools, obj)
        end
    end
end
collectTools()

if #tools == 0 then
    warn("No tools found in Workspace!")
    return
end

-- Configuration
local CONFIG = {
    maxTools = 12,
    baseRadius = 8,
    radiusVariation = 3,
    orbitSpeed = 1.2,
    verticalOffset = 2,
    verticalVariation = 1.5,
    spinSpeed = 5, -- From BodyAngularVelocity in the provided script
    transitionTime = 0.8,
    updateInterval = 1/60,
    bodyPosition = {
        maxForce = Vector3.new(4000, 4000, 4000),
        p = 3000,
        d = 500
    }
}

-- Disable inventory pickup
local function disableToolPickup()
    for _, tool in pairs(tools) do
        if tool:IsA("Tool") then
            tool.Equipped:Connect(function()
                tool.Parent = Workspace -- Force back to Workspace if equipped
            end)
            if tool:FindFirstChild("Handle") then
                tool.Handle.Anchored = false -- Allow movement but prevent pickup interference
            end
        end
    end
end
disableToolPickup()

-- Initialize tool data and physics components
local toolData = {}
for i, tool in ipairs(tools) do
    if tool:FindFirstChild("Handle") and #toolData < CONFIG.maxTools then
        local handle = tool.Handle
        handle.CanCollide = false
        handle.Anchored = false

        -- Create physics components
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
            height = height
        }

        -- Tween to initial position
        local x = math.sin(baseAngle) * radius
        local z = math.cos(baseAngle) * radius
        local y = height
        local targetPos = torso.Position + Vector3.new(x, y, z)
        local tweenInfo = TweenInfo.new(CONFIG.transitionTime, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        local tween = TweenService:Create(handle, tweenInfo, {Position = targetPos})
        tween:Play()
        tween.Completed:Connect(function()
            bp.Position = targetPos
        end)
    end
end

-- Update tool positions for orbiting
local lastUpdate = 0
RunService.Heartbeat:Connect(function(deltaTime)
    local now = tick()
    if now - lastUpdate < CONFIG.updateInterval then return end
    lastUpdate = now

    for tool, data in pairs(toolData) do
        if tool.Parent and tool:FindFirstChild("Handle") and tool:FindFirstChild("BodyPosition") then
            local t = now * CONFIG.orbitSpeed
            local angle = data.angle + t
            local x = math.sin(angle) * data.radius
            local z = math.cos(angle) * data.radius
            local y = data.height + math.sin(t * 2 + data.angle) * 0.5
            local targetPos = torso.Position + Vector3.new(x, y, z)

            tool.BodyPosition.Position = targetPos
        else
            toolData[tool] = nil
            if tool:FindFirstChild("BodyPosition") then tool.BodyPosition:Destroy() end
            if tool:FindFirstChild("BodyAngularVelocity") then tool.BodyAngularVelocity:Destroy() end
        end
    end
end)

-- Handle character respawn
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    torso = character:WaitForChild("HumanoidRootPart")
    tools = {}
    toolData = {}
    collectTools()
    disableToolPickup()
    for i, tool in ipairs(tools) do
        if tool:FindFirstChild("Handle") and #toolData < CONFIG.maxTools then
            local handle = tool.Handle
            handle.CanCollide = false
            handle.Anchored = false
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
                height = height
            }
            local x = math.sin(baseAngle) * radius
            local z = math.cos(baseAngle) * radius
            local y = height
            local targetPos = torso.Position + Vector3.new(x, y, z)
            local tweenInfo = TweenInfo.new(CONFIG.transitionTime, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            local tween = TweenService:Create(handle, tweenInfo, {Position = targetPos})
            tween:Play()
            tween.Completed:Connect(function()
                bp.Position = targetPos
            end)
        end
    end
end)
