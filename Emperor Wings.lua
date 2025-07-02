--[[
    Enhanced Emperor Wings System
    
    Features:
    - Dynamic wing animations with smooth transitions
    - Multiple wing configurations and flight modes    
    - Visual effects (particles, glows, trails)
    - Advanced flight physics with realistic controls
    - Wing flapping animations
    - Sound effects system
    - Customizable keybinds and settings
    - Performance optimization
    - Enhanced UI feedback
--]]

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")

-- Player Setup
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Enhanced Configuration System
local CONFIG = {
    -- Wing Physics
    wingData = {
        idle = {
            offset = 3.5,
            height = 0.2,
            leftStart = 25,
            leftEnd = 75,
            rightStart = -25,
            rightEnd = -75,
            flapIntensity = 0,
            transitionTime = 0.8
        },
        sprint = {
            offset = 4.2,
            height = -0.3,
            leftStart = 15,
            leftEnd = 65,
            rightStart = -15,
            rightEnd = -65,
            flapIntensity = 0.3,
            transitionTime = 0.5
        },
        flight = {
            offset = 5.5,
            height = 1.2,
            leftStart = -5,
            leftEnd = 55,
            rightStart = 5,
            rightEnd = -55,
            flapIntensity = 0.8,
            transitionTime = 0.6
        },
        glide = {
            offset = 6,
            height = 0.8,
            leftStart = 0,
            leftEnd = 45,
            rightStart = 0,
            rightEnd = -45,
            flapIntensity = 0.2,
            transitionTime = 0.7
        },
        combat = {
            offset = 3,
            height = 0.5,
            leftStart = 35,
            leftEnd = 85,
            rightStart = -35,
            rightEnd = -85,
            flapIntensity = 0.1,
            transitionTime = 0.3
        }
    },
    
    -- Movement Settings
    movement = {
        walkSpeed = 16,
        sprintSpeed = 35,
        flightSpeed = 85,
        glideSpeed = 50,
        jumpPower = 50,
        flightJumpPower = 200,
        gravity = {
            normal = 196.2,
            flight = 45,
            glide = 80
        }
    },
    
    -- Animation Settings
    animation = {
        flapFrequency = 3.5,
        flapAmplitude = 15,
        transitionEasing = Enum.EasingStyle.Quart,
        transitionDirection = Enum.EasingDirection.Out,
        idleSwayAmount = 5,
        idleSwaySpeed = 1.2
    },
    
    -- Visual Effects
    effects = {
        enableParticles = true,
        enableGlow = true,
        enableTrails = true,
        enableScreenEffects = true,
        particleIntensity = 1,
        glowIntensity = 0.4,
        trailLength = 2
    },
    
    -- Controls
    keybinds = {
        toggleWings = Enum.KeyCode.F,
        sprint = Enum.KeyCode.LeftShift,
        flight = Enum.KeyCode.Space,
        glide = Enum.KeyCode.G,
        combatMode = Enum.KeyCode.C,
        resetWings = Enum.KeyCode.R
    },
    
    -- Performance
    maxSwords = 20,
    updateFrequency = 60,
    effectUpdateFrequency = 30
}

-- Enhanced Wing Manager Class
local WingManager = {}
WingManager.__index = WingManager

function WingManager.new()
    local self = setmetatable({}, WingManager)
    
    -- State Management
    self.isActive = true
    self.currentMode = "idle"
    self.isFlying = false
    self.isSprinting = false
    self.isGliding = false
    self.isCombatMode = false
    self.focused = false
    
    -- Animation State
    self.flapTime = 0
    self.idleTime = 0
    self.transitionTweens = {}
    self.currentWingPositions = {}
    
    -- Effects
    self.effects = {}
    self.sounds = {}
    
    -- Performance
    self.lastUpdate = 0
    self.lastEffectUpdate = 0
    
    self:initializeEffects()
    self:initializeSounds()
    self:setupInputHandling()
    
    return self
end

-- Sound System
function WingManager:initializeSounds()
    self.sounds = {
        wingFlap = self:createSound("rbxasset://sounds/impact_water.mp3", 0.3),
        takeoff = self:createSound("rbxasset://sounds/electronicpingshort.wav", 0.5),
        landing = self:createSound("rbxasset://sounds/impact_generic.mp3", 0.4),
        modeSwitch = self:createSound("rbxasset://sounds/switch.mp3", 0.2)
    }
end

function WingManager:createSound(soundId, volume)
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = volume
    sound.Parent = RootPart
    return sound
end

function WingManager:playSound(soundName)
    local sound = self.sounds[soundName]
    if sound and not sound.IsPlaying then
        sound:Play()
    end
end

-- Visual Effects System
function WingManager:initializeEffects()
    if not CONFIG.effects.enableParticles then return end
    
    -- Wing particle effects
    self.effects.leftWingParticles = self:createWingParticles("Left")
    self.effects.rightWingParticles = self:createWingParticles("Right")
    
    -- Aura effect
    if CONFIG.effects.enableGlow then
        self.effects.aura = self:createAuraEffect()
    end
end

function WingManager:createWingParticles(side)
    local attachment = Instance.new("Attachment")
    attachment.Name = side .. "WingAttachment"
    attachment.Parent = RootPart
    
    local particles = Instance.new("ParticleEmitter")
    particles.Parent = attachment
    particles.Enabled = false
    particles.Lifetime = NumberRange.new(1.5, 2.5)
    particles.Rate = 25
    particles.SpreadAngle = Vector2.new(30, 30)
    particles.Speed = NumberRange.new(3, 8)
    particles.Texture = "rbxasset://textures/particles/fire_main.dds"
    
    -- Dynamic color based on mode
    particles.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(135, 206, 250)),  -- Light blue
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(70, 130, 180)), -- Steel blue
        ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 112))     -- Midnight blue
    }
    
    particles.Size = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.2),
        NumberSequenceKeypoint.new(0.5, 0.8),
        NumberSequenceKeypoint.new(1, 0)
    }
    
    particles.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(0.7, 0.6),
        NumberSequenceKeypoint.new(1, 1)
    }
    
    return particles
end

function WingManager:createAuraEffect()
    local selectionBox = Instance.new("SelectionBox")
    selectionBox.Parent = RootPart
    selectionBox.Adornee = RootPart
    selectionBox.Color3 = Color3.fromRGB(135, 206, 250)
    selectionBox.Transparency = 1 - CONFIG.effects.glowIntensity
    selectionBox.LineThickness = 0.15
    
    return selectionBox
end

-- Enhanced Tool Management
function WingManager:getSwords()
    local swords = {}
    
    -- Get tools from character
    for _, item in pairs(Character:GetChildren()) do
        if item:IsA("Tool") and #swords < CONFIG.maxSwords then
            table.insert(swords, item)
        end
    end
    
    -- Get tools from backpack
    for _, item in pairs(Player.Backpack:GetChildren()) do
        if item:IsA("Tool") and #swords < CONFIG.maxSwords then
            table.insert(swords, item)
        end
    end
    
    return swords
end

-- Advanced Wing Positioning with Smooth Transitions
function WingManager:applySwordConfiguration(wingData, instant)
    local swords = self:getSwords()
    local numSwords = #swords
    if numSwords == 0 then return end
    
    -- Clear existing tweens
    for _, tween in pairs(self.transitionTweens) do
        if tween then tween:Cancel() end
    end
    self.transitionTweens = {}
    
    local half = math.ceil(numSwords / 2)
    
    for i, sword in ipairs(swords) do
        sword.Parent = Character -- Ensure sword is equipped
        
        local targetCFrame = self:calculateSwordPosition(i, half, numSwords, wingData)
        
        if instant then
            sword.Grip = targetCFrame
            self.currentWingPositions[sword] = targetCFrame
        else
            -- Smooth transition
            local tweenInfo = TweenInfo.new(
                wingData.transitionTime or 0.8,
                CONFIG.animation.transitionEasing,
                CONFIG.animation.transitionDirection
            )
            
            local startCFrame = sword.Grip
            local tween = TweenService:Create(sword, tweenInfo, {Grip = targetCFrame})
            
            tween:Play()
            table.insert(self.transitionTweens, tween)
            
            tween.Completed:Connect(function()
                self.currentWingPositions[sword] = targetCFrame
            end)
        end
    end
end

function WingManager:calculateSwordPosition(index, half, total, wingData)
    local isLeftWing = index <= half
    local t, base, angleStart, angleEnd
    
    if isLeftWing then
        t = (half > 1 and (index - 1) / (half - 1)) or 0.5
        base = CFrame.new(-wingData.offset, wingData.height, 0)
        angleStart, angleEnd = wingData.leftStart, wingData.leftEnd
    else
        local rightCount = total - half
        local j = index - half
        t = (rightCount > 1 and (j - 1) / (rightCount - 1)) or 0.5
        base = CFrame.new(wingData.offset, wingData.height, 0)
        angleStart, angleEnd = wingData.rightStart, wingData.rightEnd
    end
    
    local baseAngle = angleStart + t * (angleEnd - angleStart)
    
    -- Add flapping animation
    local flapOffset = 0
    if wingData.flapIntensity > 0 then
        flapOffset = math.sin(self.flapTime * CONFIG.animation.flapFrequency) * 
                    CONFIG.animation.flapAmplitude * wingData.flapIntensity
    end
    
    -- Add idle sway
    local idleSway = math.sin(self.idleTime * CONFIG.animation.idleSwaySpeed + index) * 
                    CONFIG.animation.idleSwayAmount * (1 - wingData.flapIntensity)
    
    local finalAngle = baseAngle + flapOffset + idleSway
    return base * CFrame.Angles(0, 0, math.rad(finalAngle))
end

-- Mode Management System
function WingManager:setMode(mode, instant)
    if not CONFIG.wingData[mode] or self.currentMode == mode then return end
    
    local oldMode = self.currentMode
    self.currentMode = mode
    local wingData = CONFIG.wingData[mode]
    
    -- Update movement properties
    self:updateMovementProperties(mode)
    
    -- Update visual effects
    self:updateEffects(mode)
    
    -- Apply wing configuration
    self:applySwordConfiguration(wingData, instant)
    
    -- Play transition sound
    self:playSound("modeSwitch")
    
    print("Emperor Wings: Switched from", oldMode, "to", mode)
end

function WingManager:updateMovementProperties(mode)
    local movement = CONFIG.movement
    
    if mode == "sprint" then
        Humanoid.WalkSpeed = movement.sprintSpeed
        Workspace.Gravity = movement.gravity.normal
    elseif mode == "flight" then
        Humanoid.WalkSpeed = movement.flightSpeed
        Humanoid.JumpPower = movement.flightJumpPower
        Workspace.Gravity = movement.gravity.flight
    elseif mode == "glide" then
        Humanoid.WalkSpeed = movement.glideSpeed
        Workspace.Gravity = movement.gravity.glide
    else -- idle
        Humanoid.WalkSpeed = movement.walkSpeed
        Humanoid.JumpPower = movement.jumpPower
        Workspace.Gravity = movement.gravity.normal
    end
end

function WingManager:updateEffects(mode)
    if not CONFIG.effects.enableParticles then return end
    
    local intensity = CONFIG.wingData[mode].flapIntensity
    
    -- Update particle effects
    if self.effects.leftWingParticles then
        self.effects.leftWingParticles.Enabled = intensity > 0
        self.effects.leftWingParticles.Rate = math.max(5, intensity * 50)
    end
    
    if self.effects.rightWingParticles then
        self.effects.rightWingParticles.Enabled = intensity > 0
        self.effects.rightWingParticles.Rate = math.max(5, intensity * 50)
    end
    
    -- Update aura effect
    if self.effects.aura then
        local targetTransparency = 1 - (CONFIG.effects.glowIntensity * intensity)
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad)
        TweenService:Create(self.effects.aura, tweenInfo, {Transparency = targetTransparency}):Play()
    end
end

-- Enhanced Input System
function WingManager:setupInputHandling()
    -- Focus handling
    UserInputService.TextBoxFocused:Connect(function() self.focused = true end)
    UserInputService.TextBoxFocusReleased:Connect(function() self.focused = false end)
    
    -- Key input handling
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed or self.focused or not self.isActive then return end
        
        self:handleKeyPress(input.KeyCode)
    end)
    
    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if gameProcessed or self.focused or not self.isActive then return end
        
        self:handleKeyRelease(input.KeyCode)
    end)
    
    -- Humanoid state changes
    Humanoid.StateChanged:Connect(function(oldState, newState)
        self:handleStateChange(oldState, newState)
    end)
end

function WingManager:handleKeyPress(keyCode)
    local keybinds = CONFIG.keybinds
    
    if keyCode == keybinds.toggleWings then
        self.isActive = not self.isActive
        if self.isActive then
            self:setMode("idle", false)
        else
            self:clearAllEffects()
        end
        
    elseif keyCode == keybinds.sprint and self.isActive then
        self.isSprinting = true
        if not self.isFlying then
            self:setMode("sprint")
        end
        
    elseif keyCode == keybinds.flight and self.isActive then
        if not self.isFlying then
            self.isFlying = true
            self:setMode("flight")
            self:playSound("takeoff")
        end
        
    elseif keyCode == keybinds.glide and self.isActive then
        if not self.isGliding then
            self.isGliding = true
            self:setMode("glide")
        end
        
    elseif keyCode == keybinds.combatMode and self.isActive then
        self.isCombatMode = not self.isCombatMode
        if self.isCombatMode then
            self:setMode("combat")
        else
            self:setMode("idle")
        end
        
    elseif keyCode == keybinds.resetWings and self.isActive then
        self:resetToIdle()
    end
end

function WingManager:handleKeyRelease(keyCode)
    local keybinds = CONFIG.keybinds
    
    if keyCode == keybinds.sprint then
        self.isSprinting = false
        if not self.isFlying and not self.isCombatMode then
            self:setMode("idle")
        end
        
    elseif keyCode == keybinds.glide then
        self.isGliding = false
        if not self.isFlying and not self.isCombatMode then
            self:setMode("idle")
        end
    end
end

function WingManager:handleStateChange(oldState, newState)
    if not self.isActive then return end
    
    if newState == Enum.HumanoidStateType.Freefall and not self.isFlying then
        self.isFlying = true
        self:setMode("flight")
        self:playSound("takeoff")
        
    elseif newState == Enum.HumanoidStateType.Landed then
        if self.isFlying then
            self.isFlying = false
            self:playSound("landing")
            
            if self.isSprinting then
                self:setMode("sprint")
            elseif self.isCombatMode then
                self:setMode("combat")
            else
                self:setMode("idle")
            end
        end
    end
end

-- Utility Functions
function WingManager:resetToIdle()
    self.isFlying = false
    self.isSprinting = false
    self.isGliding = false
    self.isCombatMode = false
    self:setMode("idle")
end

function WingManager:clearAllEffects()
    for _, effect in pairs(self.effects) do
        if effect and effect.Enabled ~= nil then
            effect.Enabled = false
        end
    end
end

-- Main Update Loop
function WingManager:update()
    local currentTime = tick()
    
    -- Throttle main updates
    if currentTime - self.lastUpdate < (1 / CONFIG.updateFrequency) then
        return
    end
    self.lastUpdate = currentTime
    
    if not self.isActive then return end
    
    -- Update animation times
    self.flapTime = self.flapTime + (currentTime - (self.lastUpdate - (1 / CONFIG.updateFrequency)))
    self.idleTime = self.idleTime + (currentTime - (self.lastUpdate - (1 / CONFIG.updateFrequency)))
    
    -- Update wing positions with current animation
    local wingData = CONFIG.wingData[self.currentMode]
    if wingData then
        self:applySwordConfiguration(wingData, true)
    end
    
    -- Update effects less frequently
    if currentTime - self.lastEffectUpdate >= (1 / CONFIG.effects.effectUpdateFrequency) then
        self:updateEffectPositions()
        self.lastEffectUpdate = currentTime
    end
end

function WingManager:updateEffectPositions()
    -- Update particle attachment positions
    if self.effects.leftWingParticles then
        local leftAttachment = self.effects.leftWingParticles.Parent
        leftAttachment.Position = Vector3.new(-CONFIG.wingData[self.currentMode].offset, 
                                             CONFIG.wingData[self.currentMode].height, 0)
    end
    
    if self.effects.rightWingParticles then
        local rightAttachment = self.effects.rightWingParticles.Parent
        rightAttachment.Position = Vector3.new(CONFIG.wingData[self.currentMode].offset, 
                                              CONFIG.wingData[self.currentMode].height, 0)
    end
end

-- Character Respawn Handling
function WingManager:handleCharacterRespawn(newCharacter)
    Character = newCharacter
    Humanoid = Character:WaitForChild("Humanoid")
    RootPart = Character:WaitForChild("HumanoidRootPart")
    
    -- Reinitialize effects and sounds
    self:initializeEffects()
    self:initializeSounds()
    
    -- Reset state
    self:resetToIdle()
    self.isActive = true
    
    -- Reapply initial configuration
    task.wait(1) -- Wait for character to fully load
    self:setMode("idle", true)
end

-- Initialize Wing Manager
local wingManager = WingManager.new()

-- Connect main update loop
RunService.Heartbeat:Connect(function()
    wingManager:update()
end)

-- Handle character respawn
Player.CharacterAdded:Connect(function(newCharacter)
    wingManager:handleCharacterRespawn(newCharacter)
end)

-- Initialize wings
wingManager:setMode("idle", true)

-- Global Configuration Interface
_G.EmperorWingsConfig = {
    setMode = function(mode) wingManager:setMode(mode) end,
    toggleWings = function() 
        wingManager.isActive = not wingManager.isActive 
        if not wingManager.isActive then wingManager:clearAllEffects() end
    end,
    setSpeed = function(mode, speed) 
        if CONFIG.movement[mode .. "Speed"] then
            CONFIG.movement[mode .. "Speed"] = math.max(5, speed)
        end
    end,
    setEffectIntensity = function(intensity)
        CONFIG.effects.particleIntensity = math.clamp(intensity, 0, 2)
        CONFIG.effects.glowIntensity = math.clamp(intensity * 0.4, 0, 1)
    end,
    getCurrentStatus = function()
        return {
            active = wingManager.isActive,
            mode = wingManager.currentMode,
            flying = wingManager.isFlying,
            sprinting = wingManager.isSprinting,
            swordCount = #wingManager:getSwords()
        }
    end,
    resetWings = function() wingManager:resetToIdle() end
}

print("Enhanced Emperor Wings: Loaded successfully!")
print("Controls:")
print("F - Toggle Wings | Shift - Sprint | Space - Flight")
print("G - Glide | C - Combat Mode | R - Reset")
print("Use _G.EmperorWingsConfig for advanced configuration")

-- Example usage:
-- _G.EmperorWingsConfig.setMode("flight")
-- _G.EmperorWingsConfig.setSpeed("flight", 120)
-- _G.EmperorWingsConfig.setEffectIntensity(1.5)
