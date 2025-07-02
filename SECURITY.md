--!strict

--================================================
-- ENHANCED ROBLOX UI SCRIPT v2.1 - FIXED
-- Created by AlznDev - Bug Fixed Version
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
local mainScreenGui
local mainPanel
local isUIVisible = true
local connections = {}

-- Wait for PlayerGui to be ready
if not PlayerGui then
    LocalPlayer.CharacterAdded:Wait()
    PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
end

-- Remove default loading screen safely
pcall(function()
    ReplicatedFirst:RemoveDefaultLoadingScreen()
end)

-- Utility Functions
local function playSound(soundId, volume)
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://" .. tostring(soundId)
        sound.Volume = volume or 0.3
        sound.Parent = SoundService
        sound:Play()
        sound.Ended:Connect(function()
            sound:Destroy()
        end)
    end)
end

local function createTween(object, properties, duration)
    if not object or not object.Parent then return end
    local tweenInfo = TweenInfo.new(
        duration or TWEEN_TIME,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    return TweenService:Create(object, tweenInfo, properties)
end

local function addCornerRadius(parent, radius)
    if not parent then return end
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

local function addStroke(parent, color, thickness)
    if not parent then return end
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or UI_COLORS.ACCENT
    stroke.Thickness = thickness or 1
    stroke.Parent = parent
    return stroke
end

local function addGradient(parent, colors)
    if not parent then return end
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(colors or {UI_COLORS.PRIMARY, UI_COLORS.SECONDARY})
    gradient.Rotation = 45
    gradient.Parent = parent
    return gradient
end

local function addHoverEffect(button, hoverColor, normalColor)
    if not button then return end
    local normal = normalColor or button.BackgroundColor3
    local hover = hoverColor or Color3.fromRGB(
        math.min(normal.R * 255 + 20, 255),
        math.min(normal.G * 255 + 20, 255),
        math.min(normal.B * 255 + 20, 255)
    ) / 255

    button.MouseEnter:Connect(function()
        local tween = createTween(button, {BackgroundColor3 = hover}, 0.2)
        if tween then tween:Play() end
        playSound("131961136", 0.1)
    end)

    button.MouseLeave:Connect(function()
        local tween = createTween(button, {BackgroundColor3 = normal}, 0.2)
        if tween then tween:Play() end
    end)
end

local function addButtonEffect(button)
    if not button then return end
    local originalSize = button.Size
    
    button.MouseButton1Down:Connect(function()
        local tween = createTween(button, {Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset - 4, originalSize.Y.Scale, originalSize.Y.Offset - 4)}, 0.1)
        if tween then tween:Play() end
    end)

    button.MouseButton1Up:Connect(function()
        local tween = createTween(button, {Size = originalSize}, 0.1)
        if tween then tween:Play() end
        playSound("131961136", 0.2)
    end)
end

-- UI Creation Functions
local function createStyledButton(parent, name, text, position, size, color)
    if not parent then return end
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

local function createStyledLabel(parent, name, text, position, size)
    if not parent then return end
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
    if mainScreenGui and mainScreenGui.Parent then
        mainScreenGui:Destroy()
    end
    mainScreenGui = nil
    mainPanel = nil
end

-- Player Functions
local function getAllSwords(player)
    if not player then return 0 end
    local count = 0
    
    pcall(function()
        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            for _, tool in ipairs(backpack:GetChildren()) do
                if tool:IsA("Tool") and string.lower(tool.Name):find("sword") then
                    count = count + 1
                end
            end
        end
        
        local character = player.Character
        if character then
            for _, tool in ipairs(character:GetChildren()) do
                if tool:IsA("Tool") and string.lower(tool.Name):find("sword") then
                    count = count + 1
                end
            end
        end
    end)
    
    return count
end

local function getPlayerStats(player)
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

    pcall(function()
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
    end)

    return stats
end

local function executePlayerAction(player, actionType)
    if not player or not player.Character then
        return false, "Player or character not found"
    end

    local success, result = pcall(function()
        local targetHumanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if not targetHumanoid then
            return false, "Target humanoid not found"
        end

        -- Try to find sword in backpack first
        local backpack = LocalPlayer.Backpack
        local sword = nil
        
        -- Look for any tool that might be a sword
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and (string.lower(tool.Name):find("sword") or tool.Name:lower() == "sword") then
                sword = tool
                break
            end
        end
        
        -- If no sword in backpack, check character
        if not sword and LocalPlayer.Character then
            for _, tool in pairs(LocalPlayer.Character:GetChildren()) do
                if tool:IsA("Tool") and (string.lower(tool.Name):find("sword") or tool.Name:lower() == "sword") then
                    sword = tool
                    break
                end
            end
        end
        
        if not sword then
            return false, "No sword found! Make sure you have a sword equipped."
        end

        -- Move sword to character if it's in backpack
        if sword.Parent == backpack then
            sword.Parent = LocalPlayer.Character
        end
        
        task.wait(0.1) -- Small delay to ensure sword is equipped
        
        local swordHandle = sword:FindFirstChild("Handle")
        if swordHandle then
            -- Look for damage remote in different possible locations
            local damageEvent = nil
            
            -- Common damage event locations
            local possiblePaths = {
                swordHandle:FindFirstChild("dmg"),
                swordHandle:FindFirstChild("Damage"),
                swordHandle:FindFirstChild("RemoteEvent"),
                sword:FindFirstChild("RemoteEvent"),
                sword:FindFirstChild("dmg")
            }
            
            for _, path in pairs(possiblePaths) do
                if path then
                    if path:IsA("RemoteEvent") then
                        damageEvent = path
                        break
                    elseif path:FindFirstChild("RemoteEvent") then
                        damageEvent = path:FindFirstChild("RemoteEvent")
                        break
                    end
                end
            end
            
            if damageEvent and damageEvent:IsA("RemoteEvent") then
                local damage = actionType == "god" and -math.huge or math.huge
                
                -- Try different remote event call patterns
                local success = pcall(function()
                    damageEvent:FireServer(targetHumanoid, damage)
                end)
                
                if not success then
                    -- Try alternative calling method
                    success = pcall(function()
                        damageEvent:FireServer(player.Character, damage)
                    end)
                end
                
                if not success then
                    -- Try another alternative
                    success = pcall(function()
                        damageEvent:FireServer(damage, targetHumanoid)
                    end)
                end
                
                -- Move sword back to backpack after a short delay
                task.wait(0.2)
                if sword and sword.Parent == LocalPlayer.Character then
                    sword.Parent = backpack
                end
                
                if success then
                    return true, actionType == "god" and "✅ Player given god mode!" or "✅ Player eliminated!"
                else
                    return false, "❌ Failed to execute action - RemoteEvent call failed"
                end
            else
                -- Move sword back if no damage event found
                if sword and sword.Parent == LocalPlayer.Character then
                    sword.Parent = backpack
                end
                return false, "❌ Damage event not found in sword"
            end
        else
            return false, "❌ Sword handle not found"
        end
    end)
    
    if success then
        return result
    else
        return false, "❌ Error: " .. tostring(result)
    end
end

-- UI Creation
local function createMainUI()
    cleanupUI()

    -- Check if PlayerGui exists
    if not PlayerGui then
        warn("PlayerGui not found!")
        return
    end

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
    if title then
        title.Font = Enum.Font.GothamBold
        title.TextColor3 = UI_COLORS.ACCENT
    end

    local subtitle = createStyledLabel(titleFrame, "Subtitle", "Created by AlznDev v2.1 - Fixed", 
        UDim2.new(0, 10, 0, 30), UDim2.new(1, -120, 0, 25))
    if subtitle then
        subtitle.TextColor3 = UI_COLORS.TEXT_SECONDARY
        subtitle.Font = Enum.Font.Gotham
    end

    -- Close Button
    local closeButton = createStyledButton(titleFrame, "CloseButton", "✕", 
        UDim2.new(1, -50, 0, 5), UDim2.new(0, 40, 0, 25), UI_COLORS.DANGER)
    if closeButton then
        closeButton.MouseButton1Click:Connect(function()
            local tween = createTween(mainPanel, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
            if tween then tween:Play() end
            task.wait(0.3)
            if mainPanel then
                mainPanel.Visible = false
            end
            isUIVisible = false
        end)
    end

    -- Minimize Button
    local minimizeButton = createStyledButton(titleFrame, "MinimizeButton", "—", 
        UDim2.new(1, -95, 0, 5), UDim2.new(0, 40, 0, 25), UI_COLORS.WARNING)
    if minimizeButton then
        minimizeButton.MouseButton1Click:Connect(function()
            if mainPanel and mainPanel.Size.Y.Offset > 100 then
                local tween = createTween(mainPanel, {Size = UDim2.new(0, 500, 0, 60)}, 0.3)
                if tween then tween:Play() end
            elseif mainPanel then
                local tween = createTween(mainPanel, {Size = UDim2.new(0, 500, 0, 400)}, 0.3)
                if tween then tween:Play() end
            end
        end)
    end

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
    if selectionLabel then
        selectionLabel.Font = Enum.Font.GothamBold
    end

    -- Profile Picture
    local profilePic = Instance.new("ImageLabel")
    profilePic.Name = "ProfilePic"
    profilePic.Parent = selectionFrame
    profilePic.BackgroundColor3 = UI_COLORS.PRIMARY
    profilePic.Size = UDim2.new(0, 60, 0, 60)
    profilePic.Position = UDim2.new(0, 10, 0, 15)
    profilePic.ScaleType = Enum.ScaleType.Crop
    profilePic.Image = "rbxasset://textures/face.png"
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
    if statsTitle then
        statsTitle.Font = Enum.Font.GothamBold
    end

    local statsDisplay = createStyledLabel(statsFrame, "StatsDisplay", "Loading stats...", 
        UDim2.new(0, 10, 0, 30), UDim2.new(1, -20, 0, 85))
    if statsDisplay then
        statsDisplay.TextYAlignment = Enum.TextYAlignment.Top
    end

    -- Action Buttons Section
    local actionFrame = Instance.new("Frame")
    actionFrame.Name = "ActionFrame"
    actionFrame.Parent = mainPanel
    actionFrame.BackgroundColor3 = UI_COLORS.SECONDARY
    actionFrame.Size = UDim2.new(1, -20, 0, 80)
    actionFrame.Position = UDim2.new(0, 10, 0, 290)
    actionFrame.BorderSizePixel = 0
    actionFrame.Visible = true
    addCornerRadius(actionFrame, 8)

    local actionTitle = createStyledLabel(actionFrame, "ActionTitle", "⚡ Quick Actions", 
        UDim2.new(0, 10, 0, 5), UDim2.new(1, -20, 0, 20))
    if actionTitle then
        actionTitle.Font = Enum.Font.GothamBold
    end

    local godButton = createStyledButton(actionFrame, "GodButton", "🛡️ God Mode", 
        UDim2.new(0, 10, 0, 30), UDim2.new(0.48, -5, 0, 40), UI_COLORS.SUCCESS)
    
    local killButton = createStyledButton(actionFrame, "KillButton", "💀 Eliminate", 
        UDim2.new(0.52, 5, 0, 30), UDim2.new(0.48, -5, 0, 40), UI_COLORS.DANGER)

    -- Status Bar
    local statusBar = Instance.new("Frame")
    statusBar.Name = "StatusBar"
    statusBar.Parent = mainPanel
    statusBar.BackgroundColor3 = UI_COLORS.PRIMARY
    statusBar.Size = UDim2.new(1, 0, 0, 30)
    statusBar.Position = UDim2.new(0, 0, 0, 370)
    statusBar.BorderSizePixel = 0

    local statusLabel = createStyledLabel(statusBar, "StatusLabel", "Press 'K' to toggle | Ready", 
        UDim2.new(0, 10, 0, 0), UDim2.new(1, -20, 1, 0))
    if statusLabel then
        statusLabel.TextColor3 = UI_COLORS.TEXT_SECONDARY
    end

    -- Functions
    local function updateProfilePic(player)
        if not player or not profilePic then return end
        task.spawn(function()
            local success, thumbnailUrl = pcall(function()
                return Players:GetUserThumbnailAsync(player.UserId, 
                    Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
            end)
            if success and thumbnailUrl and profilePic then
                profilePic.Image = thumbnailUrl
            elseif profilePic then
                profilePic.Image = "rbxasset://textures/face.png"
            end
        end)
    end

    local function populateDropdown()
        if not dropdownFrame then return end
        
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
            
            if item then
                item.MouseButton1Click:Connect(function()
                    selectedPlayer = player
                    if dropdownButton then
                        dropdownButton.Text = player.Name
                    end
                    updateProfilePic(player)
                    dropdownFrame.Visible = false
                    if statusLabel then
                        statusLabel.Text = "Selected: " .. player.Name
                    end
                    playSound("131961136", 0.3)
                end)
            end
        end
    end

    local function showStatus(message, color)
        if statusLabel and statusLabel.Parent then
            statusLabel.Text = message
            statusLabel.TextColor3 = color or UI_COLORS.TEXT_SECONDARY
            task.spawn(function()
                task.wait(3)
                if statusLabel and statusLabel.Parent then
                    statusLabel.TextColor3 = UI_COLORS.TEXT_SECONDARY
                    statusLabel.Text = "Press 'K' to toggle | Ready"
                end
            end)
        end
    end

    -- Event Connections
    if dropdownButton then
        dropdownButton.MouseButton1Click:Connect(function()
            if dropdownFrame then
                dropdownFrame.Visible = not dropdownFrame.Visible
                if dropdownFrame.Visible then
                    populateDropdown()
                end
            end
        end)
    end

    if godButton then
        godButton.MouseButton1Click:Connect(function()
            if selectedPlayer then
                task.spawn(function()
                    local success, message = executePlayerAction(selectedPlayer, "god")
                    showStatus(message, success and UI_COLORS.SUCCESS or UI_COLORS.DANGER)
                end)
            end
        end)
    end

    if killButton then
        killButton.MouseButton1Click:Connect(function()
            if selectedPlayer then
                task.spawn(function()
                    local success, message = executePlayerAction(selectedPlayer, "kill")
                    showStatus(message, success and UI_COLORS.SUCCESS or UI_COLORS.DANGER)
                end)
            end
        end)
    end

    -- Make UI Draggable
    local function makeDraggable(frame)
        if not frame or not titleFrame then return end
        
        local dragging = false
        local dragInput
        local dragStart
        local startPos

        local function update(input)
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end

        titleFrame.InputBegan:Connect(function(input)
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

        titleFrame.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                dragInput = input
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                update(input)
            end
        end)
    end

    makeDraggable(mainPanel)

    -- Stats Update Loop
    task.spawn(function()
        while mainPanel and mainPanel.Parent and statsDisplay do
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
    local tween = createTween(mainPanel, {Size = UDim2.new(0, 500, 0, 400)}, 0.5)
    if tween then tween:Play() end
    playSound("131961136", 0.4)
end

-- Toggle UI function
local function toggleUI()
    if mainPanel then
        isUIVisible = not isUIVisible
        mainPanel.Visible = isUIVisible
        if isUIVisible then
            local tween = createTween(mainPanel, {Size = UDim2.new(0, 500, 0, 400)}, 0.3)
            if tween then tween:Play() end
        else
            local tween = createTween(mainPanel, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
            if tween then tween:Play() end
        end
        playSound("131961136", 0.3)
    end
end

-- Input Handler
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.K then
        toggleUI()
    end
end)

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

-- Connection Management (continued from your script)
connections[#connections + 1] = LocalPlayer.CharacterRemoving:Connect(handleCharacterRemoving)
connections[#connections + 1] = LocalPlayer.CharacterAdded:Connect(handleCharacterAdded)

-- Player Events
connections[#connections + 1] = Players.PlayerAdded:Connect(function(player)
    -- Update dropdown when new player joins
    task.wait(1)
    if dropdownFrame and dropdownFrame.Visible then
        populateDropdown()
    end
end)

connections[#connections + 1] = Players.PlayerRemoving:Connect(function(player)
    -- Update dropdown when player leaves
    if dropdownFrame and dropdownFrame.Visible then
        populateDropdown()
    end
    
    -- Reset selected player if they left
    if selectedPlayer == player then
        selectedPlayer = LocalPlayer
        if dropdownButton then
            dropdownButton.Text = LocalPlayer.Name
        end
        updateProfilePic(LocalPlayer)
    end
end)

-- Error Handling and Recovery
local function safeExecute(func, errorMessage)
    local success, result = pcall(func)
    if not success then
        warn(errorMessage or "Script Error:", result)
        return false, result
    end
    return true, result
end

-- Periodic UI Health Check
task.spawn(function()
    while true do
        task.wait(5)
        if not mainScreenGui or not mainScreenGui.Parent then
            -- UI was destroyed, recreate it
            task.wait(1)
            safeExecute(createMainUI, "Failed to recreate UI")
        end
    end
end)

-- Initial UI Creation
task.spawn(function()
    -- Wait for everything to load
    if LocalPlayer.Character then
        task.wait(2)
    else
        LocalPlayer.CharacterAdded:Wait()
        task.wait(2)
    end
    
    -- Create the main UI
    safeExecute(createMainUI, "Failed to create initial UI")
end)

-- Cleanup on script termination
game:BindToClose(function()
    for _, connection in ipairs(connections) do
        if connection then
            connection:Disconnect()
        end
    end
    cleanupUI()
end)

-- Status Message
print("🗡️ Enhanced Roblox UI Script v2.1 - Fixed Version Loaded!")
print("📋 Press 'K' to toggle the UI")
print("🛠️ Created by AlznDev - Bug Fixed Version")
print("✅ Script initialization complete!")

-- End of Script
