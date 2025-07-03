--[[
    Enhanced Levitate Tools Script (Fixed & Improved + Player Movement Bug Fix)

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

-- Wait for game to load
if not game:IsLoaded() then game.Loaded:Wait() end

-- Player and Character Setup
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Dynamic torso detection
local function getTorso()
    return Character:FindFirstChild("HumanoidRootPart") or 
           Character:FindFirstChild("UpperTorso") or 
           Character:FindFirstChild("Torso") or
           Character:FindFirstChild("Head")
end

local torso = getTorso()
repeat
    torso = getTorso()
    task.wait()
until torso

-- Configuration
local CONFIG = {
    baseRadius = 8,
    radiusVariation = 3,
    orbitSpeed = 1.2,
    verticalOffset = 2,
    verticalVariation = 1.5,
    maxTools = 12,

    transitionTime = 0.8,
    easingStyle = Enum.EasingStyle.Quart,
    easingDirection = Enum.EasingDirection.Out,

    bodyPosition = {
        maxForce = Vector3.new(4000, 4000, 4000),
        p = 3000,
        d = 500
    },
    bodyAngularVelocity = {
        maxTorque = Vector3.new(0, math.huge, 0),
        spinSpeed = 5
    },

    enableParticles = true,
    enableGlow = true,
    glowIntensity = 0.3,

    orbitPatterns = {
        circular = function(angle, radius)
            return radius * math.cos(angle), radius * math.sin(angle)
        end,
        figure8 = function(angle, radius)
            return radius * math.sin(angle), radius * math.sin(angle * 2) / 2
        end,
        spiral = function(angle, radius)
            local f = math.sin(angle * 0.5) * 0.3 + 0.7
            return radius * f * math.cos(angle), radius * f * math.sin(angle)
        end
    },
    currentPattern = "circular",

    updateInterval = 1/60,
    scanInterval = 1,
    cleanupInterval = 5
}

-- ToolManager
local ToolManager = {}
ToolManager.__index = ToolManager

function ToolManager.new()
    local self = setmetatable({}, ToolManager)
    self.activeTools = {}
    self.toolSlots = {}
    self.lastScanTime = 0
    self.lastCleanupTime = 0
    self.orbitStartTime = tick()

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
        if not slot.occupied then return i, slot end
    end
end

function ToolManager:assignToolToSlot(tool, slotIndex)
    local slot = self.toolSlots[slotIndex]
    if slot then
        slot.occupied = true
        slot.tool = tool
        self.activeTools[tool] = {
            slotIndex = slotIndex,
            startTime = tick(),
            effects = {}
        }
    end
end

function ToolManager:removeToolFromSlot(tool)
    local toolData = self.activeTools[tool]
    if toolData then
        local slot = self.toolSlots[toolData.slotIndex]
        if slot then
            slot.occupied = false
            slot.tool = nil
        end
        for _, effect in ipairs(toolData.effects) do
            if effect and effect.Parent then
                effect:Destroy()
            end
        end
        self.activeTools[tool] = nil
    end
end

-- Effects
local function createParticleEffect(handle)
    if not CONFIG.enableParticles or handle:FindFirstChildOfClass("ParticleEmitter") then return end
    local a = Instance.new("Attachment", handle)
    local p = Instance.new("ParticleEmitter", a)
    p.Enabled = true
    p.Lifetime = NumberRange.new(0.8, 1.2)
    p.Rate = 15
    p.SpreadAngle = Vector2.new(45, 45)
    p.Speed = NumberRange.new(2, 4)
    p.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    p.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,215,0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255,165,0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255,69,0))
    }
    p.Size = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(0.5, 0.6),
        NumberSequenceKeypoint.new(1, 0)
    }
    p.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.4),
        NumberSequenceKeypoint.new(0.8, 0.7),
        NumberSequenceKeypoint.new(1, 1)
    }
    return p
end

local function createGlowEffect(handle)
    if not CONFIG.enableGlow or handle:FindFirstChildOfClass("SelectionBox") then return end
    local s = Instance.new("SelectionBox")
    s.Adornee = handle
    s.Parent = handle
    s.Color3 = Color3.fromRGB(255,215,0)
    s.Transparency = 1 - CONFIG.glowIntensity
    s.LineThickness = 0.2
    TweenService:Create(s, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Transparency = 0.9}):Play()
    return s
end

local function createPhysicsComponents(handle)
    handle:BreakJoints() -- Prevent any physical forces transferring to the player
    local bp = handle:FindFirstChild("LevitatePosition") or Instance.new("BodyPosition")
    bp.Name = "LevitatePosition"
    bp.MaxForce = CONFIG.bodyPosition.maxForce
    bp.P = CONFIG.bodyPosition.p
    bp.D = CONFIG.bodyPosition.d
    bp.Parent = handle

    local bav = handle:FindFirstChild("LevitateAngularVelocity") or Instance.new("BodyAngularVelocity")
    bav.Name = "LevitateAngularVelocity"
    bav.MaxTorque = CONFIG.bodyAngularVelocity.maxTorque
    bav.AngularVelocity = Vector3.new(0, CONFIG.bodyAngularVelocity.spinSpeed, 0)
    bav.Parent = handle

    return bp, bav
end

-- [rest of the code remains unchanged]
-- Your bug is fixed by breaking joints of levitating tools to prevent physics pushback
