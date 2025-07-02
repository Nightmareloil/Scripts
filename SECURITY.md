--!strict

--================================================
-- ENHANCED ROBLOX UI SCRIPT v2.0
-- Created by AlznDev - Enhanced Version
--================================================

-- Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

-- Constants
local TWEEN_TIME = 0.3
local UI_COLORS = {
    PRIMARY = Color3.fromRGB(25, 25, 35),
    SECONDARY = Color3.fromRGB(35, 35, 50),
    ACCENT = Color3.fromRGB(100, 200, 255),
    SUCCESS = Color3.fromRGB(50, 200, 100),
    DANGER = Color3.fromRGB(255, 80, 80),
    WARNING = Color3.fromRGB(255, 200, 50),
    TEXT_PRIMARY = Color3.new(1, 1, 1),
    TEXT_SECONDARY = Color3.fromRGB(200, 200, 200),
    TRANSPARENT = Color3.fromRGB(0, 0, 0)
}

-- Variables
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local selectedPlayer = LocalPlayer
local mainScreenGui: ScreenGui
local mainPanel: Frame
local isUIVisible = true

-- Remove default loading screen
ReplicatedFirst:RemoveDefaultLoadingScreen()

-- Utility Functions
local function playSound(soundId: string, volume: number?)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. soundId
    sound.Volume = volume or 0.3
    sound.Parent = SoundService
    sound:Play()
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
end

local function createTween(object: Instance, properties: {[string]: any}, duration: number?)
    local tweenInfo = TweenInfo.new(
        duration or TWEEN_TIME,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    return TweenService:Create(object, tweenInfo, properties)
end

local function addCornerRadius(parent: GuiObject, radius: number?)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

local function addStroke(parent: GuiObject, color: Color3?, thickness: number?)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or UI_COLORS.ACCENT
    stroke.Thickness = thickness or 1
    stroke.Parent = parent
    return stroke
end

local function addGradient(parent: GuiObject, colors: {Color3}?)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(colors or {UI_COLORS.PRIMARY, UI_COLORS.SECONDARY})
    gradient.Rotation = 45
    gradient.Parent = parent
    return gradient
end

local function addHoverEffect(button: GuiButton, hoverColor: Color3?, normalColor: Color3?)
    local normal = normalColor or button.BackgroundColor3
    local hover = hoverColor or Color3.fromRGB(
        math.min(normal.R * 255 + 20, 255),
        math.min(normal.G * 255 + 20, 255),
        math.min(normal.B * 255 + 20, 255)
    ) / 255

    button.MouseEnter:Connect(function()
        createTween(button, {BackgroundColor3 = hover}, 0.2):Play()
        playSound("131961136", 0.1)
    end)

    button.MouseLeave:Connect(function()
        createTween(button, {BackgroundColor3 = normal}, 0.2):Play()
    end)
end

local function addButtonEffect(button: GuiButton)
    button.MouseButton1Down:Connect(function()
        createTween(button, {Size = button.Size - UDim2.new(0, 4, 0, 4)}, 0.1):Play()
    end)

    button.MouseButton1Up:Connect(function()
        createTween(button, {Size = button.Size + UDim2.new(0, 4, 0, 4)}, 0.1):Play()
        playSound("131961136", 0.2)
    end)
end

-- UI Creation Functions
local function createStyledButton(parent: GuiObject, name: string, text: string, position: UDim2, size: UDim2, color: Color3?): TextButton
    local button = Instance.new("TextButton")
    button.Name = name
    button.Parent = parent
    button.BackgroundColor3 = color or UI_COLORS.SECONDARY
    button.Size = size
    button.Position = position
    button.Text = text
    button.TextColor3 = UI_COLORS.TEXT_PRIMARY
    button.TextScaled = true
    button.Font = Enum.Font.GothamBold
    button.BorderSizePixel = 0

    addCornerRadius(button, 6)
    addStroke(button, UI_COLORS.ACCENT, 1)
    addHoverEffect(button)
    addButtonEffect(button)

    return button
end

local function createStyledLabel(parent: GuiObject, name: string, text: string, position: UDim2, size: UDim2): TextLabel
    local label = Instance.new("TextLabel")
    label.Name = name
    label.Parent = parent
    label.BackgroundTransparency = 1
    label.Size = size
    label.Position = position
    label.Text = text
    label.TextColor3 = UI_COLORS.TEXT_PRIMARY
    label.TextScaled = true
    label.Font = Enum.Font.Gotham
    label.TextWrapped = true

    return label
end

-- Main UI Cleanup
local function cleanupUI()
    if mainScreenGui then
        mainScreenGui:Destroy()
        mainScreenGui = nil
    end
end

-- Player Functions
local function getAllSwords(player: Player): number
    local count = 0
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and string.lower(tool.Name):find("sword") then
                count += 1
            end
        end
    end
    local character = player.Character
    if character then
        for _, tool in ipairs(character:GetChildren()) do
            if tool:IsA("Tool") and string.lower(tool.Name):find("sword") then
                count += 1
            end
        end
    end
    return count
end

local function getPlayerStats(player: Player): {[string]: any}
    local stats = {
        swords = 0,
        power = 0,
        kills = 0,
        health = 0,
        maxHealth = 0,
        walkSpeed = 16,
        jumpPower = 50
    }

    if not player then return stats end

    stats.swords = getAllSwords(player)

    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local power = leaderstats:FindFirstChild("Power")
        local kills = leaderstats:FindFirstChild("Kills")
        stats.power = power and power.Value or 0
        stats.kills = kills and kills.Value or 0
    end

    local character = player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            stats.health = math.floor(humanoid.Health)
            stats.maxHealth = math.floor(humanoid.MaxHealth)
            stats.walkSpeed = humanoid.WalkSpeed
            stats.jumpPower = humanoid.JumpPower
        end
    end

    return stats
end

local function executePlayerAction(player: Player, actionType: string)
    if not player or not player.Character then
        return false, "Player or character not found"
    end

    local backpack = LocalPlayer.Backpack
    local sword = backpack:FindFirstChild("sword")
    
    if not sword then
        return false, "Sword not found in backpack"
    end

    local targetHumanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not targetHumanoid then
        return false, "Target humanoid not found"
    end

    sword.Parent = LocalPlayer.Character
    
    local swordHandle = sword:FindFirstChild("Handle")
    if swordHandle then
        local damageEvent = swordHandle:FindFirstChild("dmg")
        damageEvent = damageEvent and damageEvent:FindFirstChild("RemoteEvent")
        
        if damageEvent then
            local damage = actionType == "god" and -math.huge or math.huge
            damageEvent:FireServer(targetHumanoid, damage)
            
            -- Move sword back to backpack
            task.wait(0.1)
            sword.Parent = backpack
            
            return true, actionType == "god" and "Player given god mode" or "Player eliminated"
        end
    end
    
    sword.Parent = backpack
    return false, "Damage event not found"
end

-- UI Creation
local function createMainUI()
    cleanupUI()

    -- Main ScreenGui
    mainScreenGui = Instance.new("ScreenGui")
    mainScreenGui.Name = "EnhancedMainUI"
    mainScreenGui.ResetOnSpawn = false
    mainScreenGui.IgnoreGuiInset = true
    mainScreenGui.Parent = PlayerGui

    -- Main Panel
    mainPanel = Instance.new("Frame")
    mainPanel.Name = "MainPanel"
    mainPanel.Parent = mainScreenGui
    mainPanel.BackgroundColor3 = UI_COLORS.PRIMARY
    mainPanel.Size = UDim2.new(0, 500, 0, 400)
    mainPanel.Position = UDim2.new(0.5, -250, 0.5, -200)
    mainPanel.AnchorPoint = Vector2.new(0.5, 0.5)
    mainPanel.BorderSizePixel = 0
    mainPanel.ClipsDescendants = true

    addCornerRadius(mainPanel, 12)
    addStroke(mainPanel, UI_COLORS.ACCENT, 2)
    addGradient(mainPanel, {UI_COLORS.PRIMARY, UI_COLORS.SECONDARY})

    -- Animated border effect
    local borderEffect = Instance.new("Frame")
    borderEffect.Name = "BorderEffect"
    borderEffect.Parent = mainPanel
    borderEffect.BackgroundTransparency = 1
    borderEffect.Size = UDim2.new(1, 0, 1, 0)
    borderEffect.Position = UDim2.new(0, 0, 0, 0)
    addCornerRadius(borderEffect, 12)
    local borderStroke = addStroke(borderEffect, UI_COLORS.ACCENT, 3)
    
    -- Animate border
    task.spawn(function()
        while borderEffect.Parent do
            local colors = {UI_COLORS.ACCENT, UI_COLORS.SUCCESS, UI_COLORS.WARNING, UI_COLORS.DANGER}
            for _, color in ipairs(colors) do
                if not borderEffect.Parent then break end
                createTween(borderStroke, {Color = color}, 1):Play()
                task.wait(1)
            end
        end
    end)

    -- Title Section
    local titleFrame = Instance.new("Frame")
    titleFrame.Name = "TitleFrame"
    titleFrame.Parent = mainPanel
    titleFrame.BackgroundColor3 = UI_COLORS.SECONDARY
    titleFrame.Size = UDim2.new(1, 0, 0, 60)
    titleFrame.Position = UDim2.new(0, 0, 0, 0)
    titleFrame.BorderSizePixel = 0
    addCornerRadius(titleFrame, 12)

    local title = createStyledLabel(titleFrame, "Title", "🗡️ ENHANCED STATS PANEL 🗡️", 
        UDim2.new(0, 10, 0, 5), UDim2.new(1, -120, 0, 30))
    title.Font = Enum.Font.GothamBold
    title.TextColor3 = UI_COLORS.ACCENT

    local subtitle = createStyledLabel(titleFrame, "Subtitle", "Created by AlznDev v2.0", 
        UDim2.new(0, 10, 0, 30), UDim2.new(1, -120, 0, 25))
    subtitle.TextColor3 = UI_COLORS.TEXT_SECONDARY
    subtitle.Font = Enum.Font.Gotham

    -- Close Button
    local closeButton = createStyledButton(titleFrame, "CloseButton", "✕", 
        UDim2.new(1, -50, 0, 5), UDim2.new(0, 40, 0, 25), UI_COLORS.DANGER)
    closeButton.MouseButton1Click:Connect(function()
        createTween(mainPanel, {Size = UDim2.new(0, 0, 0, 0)}, 0.3):Play()
        task.wait(0.3)
        mainPanel.Visible = false
        isUIVisible = false
    end)

    -- Minimize Button
    local minimizeButton = createStyledButton(titleFrame, "MinimizeButton", "—", 
        UDim2.new(1, -95, 0, 5), UDim2.new(0, 40, 0, 25), UI_COLORS.WARNING)
    minimizeButton.MouseButton1Click:Connect(function()
        if mainPanel.Size.Y.Offset > 100 then
            createTween(mainPanel, {Size = UDim2.new(0, 500, 0, 60)}, 0.3):Play()
        else
            createTween(mainPanel, {Size = UDim2.new(0, 500, 0, 400)}, 0.3):Play()
        end
    end)

    -- Player Selection Section
    local selectionFrame = Instance.new("Frame")
    selectionFrame.Name = "SelectionFrame"
    selectionFrame.Parent = mainPanel
    selectionFrame.BackgroundColor3 = UI_COLORS.SECONDARY
    selectionFrame.Size = UDim2.new(1, -20, 0, 80)
    selectionFrame.Position = UDim2.new(0, 10, 0, 70)
    selectionFrame.BorderSizePixel = 0
    addCornerRadius(selectionFrame, 8)

    local selectionLabel = createStyledLabel(selectionFrame, "SelectionLabel", "🎯 Target Player", 
        UDim2.new(0, 10, 0, 5), UDim2.new(0.5, -10, 0, 25))
    selectionLabel.Font = Enum.Font.GothamBold

    -- Profile Picture
    local profilePic = Instance.new("ImageLabel")
    profilePic.Name = "ProfilePic"
    profilePic.Parent = selectionFrame
    profilePic.BackgroundColor3 = UI_COLORS.PRIMARY
    profilePic.Size = UDim2.new(0, 60, 0, 60)
    profilePic.Position = UDim2.new(0, 10, 0, 15)
    profilePic.ScaleType = Enum.ScaleType.Crop
    addCornerRadius(profilePic, 30)
    addStroke(profilePic, UI_COLORS.ACCENT, 2)

    -- Dropdown Button
    local dropdownButton = createStyledButton(selectionFrame, "DropdownButton", LocalPlayer.Name, 
        UDim2.new(0, 80, 0, 30), UDim2.new(1, -100, 0, 35), UI_COLORS.PRIMARY)

    -- Dropdown Frame
    local dropdownFrame = Instance.new("ScrollingFrame")
    dropdownFrame.Name = "DropdownFrame"
    dropdownFrame.Parent = mainPanel
    dropdownFrame.BackgroundColor3 = UI_COLORS.SECONDARY
    dropdownFrame.Size = UDim2.new(1, -20, 0, 0)
    dropdownFrame.Position = UDim2.new(0, 10, 0, 150)
    dropdownFrame.Visible = false
    dropdownFrame.BorderSizePixel = 0
    dropdownFrame.ScrollBarThickness = 6
    dropdownFrame.ScrollBarImageColor3 = UI_COLORS.ACCENT
    addCornerRadius(dropdownFrame, 8)

    -- Stats Display Section
    local statsFrame = Instance.new("Frame")
    statsFrame.Name = "StatsFrame"
    statsFrame.Parent = mainPanel
    statsFrame.BackgroundColor3 = UI_COLORS.SECONDARY
    statsFrame.Size = UDim2.new(1, -20, 0, 120)
    statsFrame.Position = UDim2.new(0, 10, 0, 160)
    statsFrame.BorderSizePixel = 0
    addCornerRadius(statsFrame, 8)

    local statsTitle = createStyledLabel(statsFrame, "StatsTitle", "📊 Player Statistics", 
        UDim2.new(0, 10, 0, 5), UDim2.new(1, -20, 0, 25))
    statsTitle.Font = Enum.Font.GothamBold

    local statsDisplay = createStyledLabel(statsFrame, "StatsDisplay", "Loading stats...", 
        UDim2.new(0, 10, 0, 30), UDim2.new(1, -20, 0, 85))
    statsDisplay.TextYAlignment = Enum.TextYAlignment.Top

    -- Action Buttons Section
    local actionFrame = Instance.new("Frame")
    actionFrame.Name = "ActionFrame"
    actionFrame.Parent = mainPanel
    actionFrame.BackgroundColor3 = UI_COLORS.SECONDARY
    actionFrame.Size = UDim2.new(1, -20, 0, 60)
    actionFrame.Position = UDim2.new(0, 10, 0, 290)
    actionFrame.BorderSizePixel = 0
    addCornerRadius(actionFrame, 8)

    local actionTitle = createStyledLabel(actionFrame, "ActionTitle", "⚡ Quick Actions", 
        UDim2.new(0, 10, 0, 5), UDim2.new(1, -20, 0, 20))
    actionTitle.Font = Enum.Font.GothamBold

    local godButton = createStyledButton(actionFrame, "GodButton", "🛡️ God Mode", 
        UDim2.new(0, 10, 0, 25), UDim2.new(0.5, -15, 0, 30), UI_COLORS.SUCCESS)
    
    local killButton = createStyledButton(actionFrame, "KillButton", "💀 Eliminate", 
        UDim2.new(0.5, 5, 0, 25), UDim2.new(0.5, -15, 0, 30), UI_COLORS.DANGER)

    -- Status Bar
    local statusBar = Instance.new("Frame")
    statusBar.Name = "StatusBar"
    statusBar.Parent = mainPanel
    statusBar.BackgroundColor3 = UI_COLORS.PRIMARY
    statusBar.Size = UDim2.new(1, 0, 0, 30)
    statusBar.Position = UDim2.new(0, 0, 1, -30)
    statusBar.BorderSizePixel = 0

    local statusLabel = createStyledLabel(statusBar, "StatusLabel", "Press 'K' to toggle | Ready", 
        UDim2.new(0, 10, 0, 0), UDim2.new(1, -20, 1, 0))
    statusLabel.TextColor3 = UI_COLORS.TEXT_SECONDARY

    -- Functions
    local function updateProfilePic(player: Player)
        if not player then return end
        task.spawn(function()
            local success, thumbnailUrl = pcall(function()
                return Players:GetUserThumbnailAsync(player.UserId, 
                    Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
            end)
            if success and thumbnailUrl then
                profilePic.Image = thumbnailUrl
            else
                profilePic.Image = "rbxasset://textures/face.png"
            end
        end)
    end

    local function populateDropdown()
        -- Clear existing items
        for _, child in ipairs(dropdownFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        local playersList = Players:GetPlayers()
        local itemHeight = 40
        dropdownFrame.Size = UDim2.new(1, -20, 0, math.min(#playersList * itemHeight, 200))
        dropdownFrame.CanvasSize = UDim2.new(0, 0, 0, #playersList * itemHeight)

        for index, player in ipairs(playersList) do
            local item = createStyledButton(dropdownFrame, "Item_" .. player.Name, 
                player.Name .. " (ID: " .. player.UserId .. ")", 
                UDim2.new(0, 5, 0, (index - 1) * itemHeight), 
                UDim2.new(1, -10, 0, itemHeight - 5), UI_COLORS.PRIMARY)
            
            item.MouseButton1Click:Connect(function()
                selectedPlayer = player
                dropdownButton.Text = player.Name
                updateProfilePic(player)
                dropdownFrame.Visible = false
                statusLabel.Text = "Selected: " .. player.Name
                playSound("131961136", 0.3)
            end)
        end
    end

    local function showStatus(message: string, color: Color3?)
        statusLabel.Text = message
        statusLabel.TextColor3 = color or UI_COLORS.TEXT_SECONDARY
        task.wait(3)
        if statusLabel and statusLabel.Parent then
            statusLabel.TextColor3 = UI_COLORS.TEXT_SECONDARY
            statusLabel.Text = "Press 'K' to toggle | Ready"
        end
    end

    -- Event Connections
    dropdownButton.MouseButton1Click:Connect(function()
        dropdownFrame.Visible = not dropdownFrame.Visible
        if dropdownFrame.Visible then
            populateDropdown()
        end
    end)

    godButton.MouseButton1Click:Connect(function()
        if selectedPlayer then
            task.spawn(function()
                local success, message = executePlayerAction(selectedPlayer, "god")
                showStatus(message, success and UI_COLORS.SUCCESS or UI_COLORS.DANGER)
            end)
        end
    end)

    killButton.MouseButton1Click:Connect(function()
        if selectedPlayer then
            task.spawn(function()
                local success, message = executePlayerAction(selectedPlayer, "kill")
                showStatus(message, success and UI_COLORS.SUCCESS or UI_COLORS.DANGER)
            end)
        end
    end)

    -- Make UI Draggable
    local function makeDraggable(frame: GuiObject)
        local dragging = false
        local dragInput: InputObject
        local dragStart: Vector3
        local startPos: UDim2

        local function update(input: InputObject)
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end

        titleFrame.InputBegan:Connect(function(input: InputObject)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position

                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)

        titleFrame.InputChanged:Connect(function(input: InputObject)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                dragInput = input
            end
        end)

        UserInputService.InputChanged:Connect(function(input: InputObject)
            if input == dragInput and dragging then
                update(input)
            end
        end)
    end

    makeDraggable(mainPanel)

    -- Stats Update Loop
    task.spawn(function()
        while mainPanel and mainPanel.Parent do
            if selectedPlayer and selectedPlayer.Parent then
                local stats = getPlayerStats(selectedPlayer)
                local statsText = string.format(
                    "🗡️ Swords: %d\n⚡ Power: %s\n💀 Kills: %s\n❤️ Health: %d/%d\n🏃 Speed: %.1f\n🦘 Jump: %.1f",
                    stats.swords,
                    stats.power >= 1000000 and string.format("%.1fM", stats.power / 1000000) or tostring(stats.power),
                    stats.kills >= 1000000 and string.format("%.1fM", stats.kills / 1000000) or tostring(stats.kills),
                    stats.health, stats.maxHealth,
                    stats.walkSpeed, stats.jumpPower
                )
                statsDisplay.Text = statsText
            else
                statsDisplay.Text = "❌ Player not available"
            end
            task.wait(1)
        end
    end)

    -- Initialize
    updateProfilePic(selectedPlayer)
    
    -- Entry animation
    mainPanel.Size = UDim2.new(0, 0, 0, 0)
    mainPanel.Visible = true
    createTween(mainPanel, {Size = UDim2.new(0, 500, 0, 400)}, 0.5):Play()
    playSound("131961136", 0.4)
end

-- Cleanup and Event Handlers
local function handleCharacterRemoving()
    cleanupUI()
end

local function handleCharacterAdded()
    task.wait(2)
    if not mainScreenGui or not mainScreenGui.Parent then
        createMainUI()
    end
end

-- Toggle UI function
local function toggleUI()
    if mainPanel then
        isUIVisible = not isUIVisible
        mainPanel.Visible = isUIVisible
        if isUIVisible then
            createTween(mainPanel, {Size = UDim2.new(0, 500, 0, 400)}, 0.3):Play()
        else
            createTween(mainPanel, {Size = UDim2.new(0, 0, 0, 0)}, 0.3):Play()
        end
        playSound("131961136", 0.3)
    end
end

-- Input Handler
UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.K then
        toggleUI()
    end
end)

-- Connection Management
local connections = {}

local function setupConnections()
    -- Clear existing connections
    for _, connection in pairs(connections) do
        if connection then
            connection:Disconnect()
        end
    end
    connections = {}

    -- Setup new connections
    connections.characterRemoving = LocalPlayer.CharacterRemoving:Connect(handleCharacterRemoving)
    connections.characterAdded = LocalPlayer.CharacterAdded:Connect(handleCharacterAdded)
    connections.ancestryChanged = LocalPlayer.AncestryChanged:Connect(function(_, parent)
        if not parent then
            cleanupUI()
        end
    end)
end

-- Initialize
setupConnections()
createMainUI()

-- Auto-cleanup on script end
game:BindToClose(function()
    cleanupUI()
    for _, connection in pairs(connections) do
        if connection then
            connection:Disconnect()
        end
    end
end)
