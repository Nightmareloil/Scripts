-- Services
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

-- Player and Character references
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Head = Character:WaitForChild("Head")

-- Configuration
local config = {
    hoverHeight = 10,    -- studs above head
    spinSpeed = 20,      -- radians per second
    bpMaxForce = Vector3.new(1e5, 1e5, 1e5),
    bpP = 50,
    bpD = 50,
    bavMaxTorque = Vector3.new(1e5, 1e5, 1e5)
}

-- Table to keep track of active dropped tools
local activeTools = {}

-- Creates or updates BodyPosition on handle
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
    bp.Position = Head.Position + Vector3.new(0, config.hoverHeight, 0)
end

-- Creates or updates BodyAngularVelocity on handle
local function updateAngularVelocity(handle)
    local bav = handle:FindFirstChild("Spinning")
    if not bav then
        bav = Instance.new("BodyAngularVelocity")
        bav.Name = "Spinning"
        bav.MaxTorque = config.bavMaxTorque
        bav.Parent = handle
    end
    bav.AngularVelocity = Vector3.new(0, config.spinSpeed, 0)
end

-- Apply levitate and spin to tool's handle
local function levitateAndSpin(tool)
    if not (tool and tool:IsA("Tool")) then return end

    local handle = tool:FindFirstChild("Handle")
    if not handle then return end

    -- Ensure tool is dropped (parent == Workspace)
    if tool.Parent ~= Workspace then return end

    -- Disable collisions once
    if handle.CanCollide then
        handle.CanCollide = false
    end

    -- Make sure handle is not anchored so physics works
    if handle.Anchored then
        handle.Anchored = false
    end

    updateBodyPosition(handle)
    updateAngularVelocity(handle)
end

-- Add a tool to activeTools when it appears in Workspace
local function registerTool(tool)
    if tool and tool:IsA("Tool") and tool:FindFirstChild("Handle") and tool.Parent == Workspace then
        activeTools[tool] = true
    end
end

-- Remove a tool from activeTools (cleanup)
local function unregisterTool(tool)
    if activeTools[tool] then
        -- Clean up BodyPosition and BodyAngularVelocity if desired
        local handle = tool:FindFirstChild("Handle")
        if handle then
            local bp = handle:FindFirstChild("LevitatePosition")
            if bp then bp:Destroy() end
            local bav = handle:FindFirstChild("Spinning")
            if bav then bav:Destroy() end
            handle.CanCollide = true -- reset collision to default
        end
        activeTools[tool] = nil
    end
end

-- Connect to tools added or removed in Workspace
Workspace.ChildAdded:Connect(function(child)
    if child:IsA("Tool") and child:FindFirstChild("Handle") then
        registerTool(child)
    end
end)

Workspace.ChildRemoved:Connect(function(child)
    if child:IsA("Tool") then
        unregisterTool(child)
    end
end)

-- Initial scan for existing dropped tools on script start
for _, child in ipairs(Workspace:GetChildren()) do
    if child:IsA("Tool") and child:FindFirstChild("Handle") and child.Parent == Workspace then
        registerTool(child)
    end
end

-- Continuously update active tools every frame
RunService.RenderStepped:Connect(function()
    for tool in pairs(activeTools) do
        if tool and tool.Parent == Workspace and tool:FindFirstChild("Handle") then
            levitateAndSpin(tool)
        else
            unregisterTool(tool)
        end
    end
end)

-- Optional: Function to dynamically update hover height or spin speed
local function updateConfig(newHoverHeight, newSpinSpeed)
    if newHoverHeight then config.hoverHeight = newHoverHeight end
    if newSpinSpeed then config.spinSpeed = newSpinSpeed end
end

-- Example usage:
-- updateConfig(15, 30) -- change hover height to 15 studs and spin speed to 30 radians/sec
