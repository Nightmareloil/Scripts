local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local UIS = game:GetService("UserInputService")
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")

local focused = false
local animated = true
local flying = false
local sprinting = false

local function handleFocus()
    focused = true
end

local function handleBlur()
    focused = false
end

UIS.TextBoxFocused:Connect(handleFocus)
UIS.TextBoxFocusReleased:Connect(handleBlur)

local function getSwords()
    local swords = {}
    -- Grab swords in the character and the backpack
    for _, tool in pairs(player.Character:GetChildren()) do
        if tool:IsA("Tool") then
            table.insert(swords, tool)
        end
    end
    for _, tool in pairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            table.insert(swords, tool)
        end
    end
    return swords
end

-- Handles key input for toggling movement and animation
local function handleKeyPress(input, gameProcessed)
    if gameProcessed or focused then return end

    local key = input.KeyCode
    if key == Enum.KeyCode.G then
        animated = false
    elseif key == Enum.KeyCode.F then
        animated = not animated
        if animated then
            applySwordData({angle = 0.5, value = 0.5})
        end
    elseif key == Enum.KeyCode.LeftShift and animated then
        sprinting = not sprinting
        if sprinting then
            hum.WalkSpeed = 30
            applySwordData({angle = 1.57, value = 0.7})
        else
            hum.WalkSpeed = 8
            applySwordData({angle = 0.5, value = 0.5})
        end
    end
end

UIS.InputBegan:Connect(handleKeyPress)

local function applySwordData(wingData)
    local swords = getSwords()
    local half = math.floor(#swords / 2)
    
    -- Apply sword positions to create the wings
    for i, sword in ipairs(swords) do
        sword.Parent = player.Backpack
        sword.Grip = CFrame.new(-3.5, 0, 0) * CFrame.Angles(math.pi, 0, 0)
        
        local angleAdjustment = (wingData.angle / half) * i + wingData.value
        if i > half then
            angleAdjustment = -angleAdjustment
        end

        sword.Grip = sword.Grip * CFrame.Angles(angleAdjustment, math.pi / 2, 0)
        sword.Grip = sword.Grip * CFrame.new(1.7, 0, 0)
        sword.Parent = player.Character
    end
end

-- Initial application of sword positions when animation is on
applySwordData({angle = 0.5, value = 0.5})

-- Humanoid state changes: fly, land, and walking state management
hum.StateChanged:Connect(function(_, newState)
    if not animated then return end

    if newState == Enum.HumanoidStateType.Freefall then
        flying = true
        applySwordData({angle = 1.57, value = 0.7})
        workspace.Gravity = 50
        hum.WalkSpeed = 70
    elseif newState == Enum.HumanoidStateType.Landed then
        flying = false
        workspace.Gravity = 196.2
        if sprinting then
            hum.WalkSpeed = 30
        else
            hum.WalkSpeed = 8
            applySwordData({angle = 0.5, value = 0.5})
        end
    end
end)

-- Listen for character respawn to reset animations and swords
player.CharacterAdded:Connect(function(newChar)
    char = newChar
    hum = char:WaitForChild("Humanoid")
    -- Reset any state-related behavior here
    applySwordData({angle = 0.5, value = 0.5})
end)
