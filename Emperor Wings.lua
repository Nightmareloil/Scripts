local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")

local focused = false
local animated = true
local flying = false
local sprinting = false

-- Update focus state so we don’t interfere with TextBox input
local function handleFocus()
    focused = true
end

local function handleBlur()
    focused = false
end

UIS.TextBoxFocused:Connect(handleFocus)
UIS.TextBoxFocusReleased:Connect(handleBlur)

-- Returns all sword tools from the character and backpack
local function getSwords()
    local swords = {}
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

----------------------------------------------------------------
-- Revised function: Arranges swords into two wings using wingData
-- wingData should include:
--    offset       : horizontal distance from center (for left/right)
--    height       : vertical offset
--    leftStart    : starting angle (degrees) for the left wing
--    leftEnd      : ending angle (degrees) for the left wing
--    rightStart   : starting angle (degrees) for the right wing
--    rightEnd     : ending angle (degrees) for the right wing
----------------------------------------------------------------
local function applySwordData(wingData)
    local swords = getSwords()
    local numSwords = #swords
    if numSwords == 0 then return end

    -- Determine how many swords for the left wing
    local half = math.ceil(numSwords / 2)
    
    for i, sword in ipairs(swords) do
        sword.Parent = player.Character  -- Ensure the sword is on the character, not in the backpack
        local gripCFrame
        
        if i <= half then
            -- Left wing sword
            local t = (half > 1 and (i - 1) / (half - 1)) or 0.5  -- normalized value from 0 to 1
            local base = CFrame.new(-wingData.offset, wingData.height, 0)
            -- Lerp the angle between leftStart and leftEnd
            local angle = wingData.leftStart + t * (wingData.leftEnd - wingData.leftStart)
            gripCFrame = base * CFrame.Angles(0, 0, math.rad(angle))
        else
            -- Right wing sword
            local rightCount = numSwords - half
            local j = i - half
            local t = (rightCount > 1 and (j - 1) / (rightCount - 1)) or 0.5
            local base = CFrame.new(wingData.offset, wingData.height, 0)
            local angle = wingData.rightStart + t * (wingData.rightEnd - wingData.rightStart)
            gripCFrame = base * CFrame.Angles(0, 0, math.rad(angle))
        end
        
        sword.Grip = gripCFrame
    end
end

-- Default wing data (idle)
local defaultWingData = {
    offset = 3.5,       -- How far from center
    height = 0,         -- Vertical offset (adjust as needed)
    leftStart = 20,     -- Left wing: smallest rotation (closest to the body)
    leftEnd = 70,       -- Left wing: largest rotation (furthest from the body)
    rightStart = -20,   -- Right wing: smallest rotation
    rightEnd = -70,     -- Right wing: largest rotation
}

-- Wing data applied when sprinting
local sprintWingData = {
    offset = 4,
    height = -0.5,
    leftStart = 10,
    leftEnd = 60,
    rightStart = -10,
    rightEnd = -60,
}

-- Wing data applied when flying
local flyWingData = {
    offset = 5,
    height = 1,
    leftStart = 0,
    leftEnd = 50,
    rightStart = 0,
    rightEnd = -50,
}

-- Handles key input for toggling animation states and modifying the wing shape
local function handleKeyPress(input, gameProcessed)
    if gameProcessed or focused then return end
    local key = input.KeyCode
    if key == Enum.KeyCode.G then
        animated = false
    elseif key == Enum.KeyCode.F then
        animated = not animated
        if animated then
            applySwordData(defaultWingData)
        end
    elseif key == Enum.KeyCode.LeftShift and animated then
        sprinting = not sprinting
        if sprinting then
            hum.WalkSpeed = 30
            applySwordData(sprintWingData)
        else
            hum.WalkSpeed = 8
            applySwordData(defaultWingData)
        end
    end
end

UIS.InputBegan:Connect(handleKeyPress)

-- Initial application (idle wings)
applySwordData(defaultWingData)

-- Listen for humanoid state changes to adjust wing appearance during flying
hum.StateChanged:Connect(function(oldState, newState)
    if not animated then return end

    if newState == Enum.HumanoidStateType.Freefall then
        flying = true
        applySwordData(flyWingData)
        workspace.Gravity = 50
        hum.WalkSpeed = 70
    elseif newState == Enum.HumanoidStateType.Landed then
        flying = false
        workspace.Gravity = 196.2
        if sprinting then
            hum.WalkSpeed = 30
        else
            hum.WalkSpeed = 8
            applySwordData(defaultWingData)
        end
    end
end)

-- Reset when a character respawns
player.CharacterAdded:Connect(function(newChar)
    char = newChar
    hum = char:WaitForChild("Humanoid")
    applySwordData(defaultWingData)
end)
