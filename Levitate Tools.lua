--[[
    This script makes any dropped Tool orbit around your character's torso.
    Tools dropped into the Workspace (or anywhere under Workspace) will follow a circular path
    based on the configured orbitRadius and orbitSpeed, and they will also spin on their own axis.
--]]

-- Services
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

-- Player and Character references
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

-- Try to find a torso part (works for R15, R6, or even a fallback):
local torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso") or Character:FindFirstChild("HumanoidRootPart")
if not torso then
    torso = Character:WaitForChild("Head")  -- fallback if no torso exists
    warn("No torso found; defaulting orbit center to Head.")
end

-- Configuration for orbit & spinning
local config = {
    orbitRadius = 44.10,          -- Orbit radius (studs)
    orbitSpeed = 1,               -- Orbit speed (radians per second). A full circle takes roughly 2π/config.orbitSpeed seconds.
    verticalOffset = 0.2,         -- Vertical offset from the torso (studs)
    selfSpinSpeed = 20,           -- Tool's own spin speed (radians per second)

    bpMaxForce = Vector3.new(1e5, 1e5, 1e5),
    bpP = 50,
    bpD = 50,
    bavMaxTorque = Vector3.new(1e5, 1e5, 1e5)
}

-- Function to update the BodyPosition of the tool's Handle so it orbits around the torso.
local function updateBodyPosition(handle)
    local angle = tick() * config.orbitSpeed  -- time-based angle calculation
    local xOffset = config.orbitRadius * math.cos(angle)
    local zOffset = config.orbitRadius * math.sin(angle)
    local targetPos = torso.Position + Vector3.new(xOffset, config.verticalOffset, zOffset)
    
    local bp = handle:FindFirstChild("LevitatePosition")
    if not bp then
        bp = Instance.new("BodyPosition")
        bp.Name = "LevitatePosition"
        bp.MaxForce = config.bpMaxForce
        bp.P = config.bpP
        bp.D = config.bpD
        bp.Parent = handle
    end
    bp.Position = targetPos
end

-- Function to spin the tool around its own axis using BodyAngularVelocity.
local function updateAngularVelocity(handle)
    local bav = handle:FindFirstChild("Spinning")
    if not bav then
        bav = Instance.new("BodyAngularVelocity")
        bav.Name = "Spinning"
        bav.MaxTorque = config.bavMaxTorque
        bav.Parent = handle
    end
    bav.AngularVelocity = Vector3.new(0, config.selfSpinSpeed, 0)
end

-- Applies the orbit and spinning physics to a given Tool.
local function levitateAndSpin(tool)
    if not (tool and tool:IsA("Tool")) then
        return
    end

    local handle = tool:FindFirstChild("Handle")
    if not handle then
        return
    end

    -- Process the tool only if it’s not being held.
    -- (i.e. its parent isn’t the character or the Backpack)
    if tool:IsDescendantOf(Character) or tool:IsDescendantOf(Player.Backpack) then
        return
    end

    -- Disable collisions for smoother movement.
    handle.CanCollide = false
    handle.Anchored = false

    updateBodyPosition(handle)
    updateAngularVelocity(handle)
end

-- Table to keep track of active (dropped) tools.
local activeTools = {}

-- Scans all descendants in Workspace for Tools with a Handle.
local function scanForTools()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Tool") and obj:FindFirstChild("Handle") then
            -- Consider a tool as "dropped" if it is not inside the character or Backpack.
            if not obj:IsDescendantOf(Character) and not obj:IsDescendantOf(Player.Backpack) then
                activeTools[obj] = true
            else
                activeTools[obj] = nil
            end
        end
    end
end

-- Periodically scan the Workspace for dropped tools.
task.spawn(function()
    while true do
        scanForTools()
        wait(2)  -- Adjust the interval as needed for responsiveness.
    end
end)

-- Continuously update each active tool's orbit and spinning effect every frame.
RunService.RenderStepped:Connect(function()
    for tool, _ in pairs(activeTools) do
        if tool and tool.Parent and tool:FindFirstChild("Handle") then
            levitateAndSpin(tool)
        else
            activeTools[tool] = nil
        end
    end
end)
