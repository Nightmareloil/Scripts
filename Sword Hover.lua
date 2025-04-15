--[[ 
    This script levitates and spins any dropped tool (e.g. swords) that is in the Workspace.
    It scans every 3 seconds for Tools whose direct parent is the Workspace, ensuring that
    tools in a player's inventory remain unaffected.
--]]

-- Services
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

-- Player and Character references
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Head = Character:WaitForChild("Head")

-- Configuration table for dynamic settings.
local config = {
    hoverHeight = 10,    -- How high above the head to levitate the tool.
    spinSpeed = 20,      -- Angular velocity (radians per second) for spinning.
    bpMaxForce = Vector3.new(1e5, 1e5, 1e5),
    bpP = 50,
    bpD = 50,
    bavMaxTorque = Vector3.new(1e5, 1e5, 1e5)
}

-- Function to create or update a BodyPosition for levitating the tool's Handle.
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

-- Function to create or update a BodyAngularVelocity for spinning the tool's Handle.
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

-- Applies the levitation and spinning physics to a given Tool.
local function levitateAndSpin(tool)
    if not (tool and tool:IsA("Tool")) then
        return
    end

    local handle = tool:FindFirstChild("Handle")
    if not handle then
        return
    end

    -- Only update if the tool is on the ground (i.e. its parent is exactly Workspace).
    if tool.Parent ~= Workspace then
        return
    end

    -- Disable collisions on the handle so it moves smoothly.
    handle.CanCollide = false
    handle.Anchored = false

    updateBodyPosition(handle)
    updateAngularVelocity(handle)
end

-- Table to keep track of active (dropped) tools.
local activeTools = {}

-- This routine scans the Workspace every 3 seconds for dropped Tools.
task.spawn(function()
    while true do
        -- Look over each direct child of the Workspace.
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj:IsA("Tool") and obj:FindFirstChild("Handle") then
                -- Only register the tool if its parent is Workspace (i.e. it's on the ground)
                if obj.Parent == Workspace then
                    activeTools[obj] = true
                else
                    activeTools[obj] = nil
                end
            end
        end
        wait(3)
    end
end)

-- Continuously update each active tool’s levitation/spinning effect each frame.
RunService.RenderStepped:Connect(function()
    for tool, _ in pairs(activeTools) do
        -- Ensure the tool is still valid and in the Workspace.
        if tool and tool.Parent == Workspace and tool:FindFirstChild("Handle") then
            levitateAndSpin(tool)
        else
            activeTools[tool] = nil
        end
    end
end)

--[[
    Below are a couple of examples of how you might adjust the hover height dynamically:
    config.hoverHeight = 50  -- Set levitation height to 50 studs.
    config.hoverHeight = 10  -- Change levitation height to 10 studs.
--]]
