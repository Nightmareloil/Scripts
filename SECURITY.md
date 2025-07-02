--!strict

--================================================
-- ENHANCED ROBLOX UI SCRIPT v2.2
-- Created by AlznDev - Fixed Target Player Dropdown
-- Compatible with all Lua executors
--================================================

-- Services (with error handling for different executors)
local function getService(serviceName)
    local success, service = pcall(function()
        return game:GetService(serviceName)
    end)
    return success and service or nil
end

local TweenService = getService("TweenService")
local Players = getService("Players")
local UserInputService = getService("UserInputService")
local ReplicatedFirst = getService("ReplicatedFirst")
local RunService = getService("RunService")
local SoundService = getService("SoundService")

-- Executor compatibility check
local function isServiceAvailable(service)
    return service ~= nil
end

-- Constants
local TWEEN_TIME = 0.2
local UI_COLORS = {
    PRIMARY = Color3.fromRGB(25, 25, 35),
    SECONDARY = Color3.fromRGB(35, 35, 50),
    ACCENT = Color3.fromRGB(100, 200, 255),
    SUCCESS = Color3.fromRGB(50, 200, 100),
    DANGER = Color3.fromRGB(255, 80, 80),
    WARNING = Color3.fromRGB(255, 200, 50),
    TEXT_PRIMARY = Color3.new(1, 1, 1),
    TEXT_SECONDARY = Color3.fromRGB(200, 200, 200),
    TRANSPARENT = Color3.fromRGB(0, 0, 0),
    BACKGROUND_DARK = Color3.fromRGB(15, 15, 25),
    ACCENT_SECONDARY = Color3.fromRGB(150, 100, 255)
}

-- Variables
local LocalPlayer = Players and Players.LocalPlayer
local PlayerGui = LocalPlayer and LocalPlayer:WaitForChild("PlayerGui", 5)
local selectedPlayer = LocalPlayer
local mainScreenGui
local mainPanel
local dropdownFrame
local dropdownButton
local isUIVisible = true
local connections = {}

-- Enhanced error handling
local function safeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("SafeCall Error: " .. tostring(result))
    end
    return success, result
end

-- Remove default loading screen (if available)
if ReplicatedFirst then
    safeCall(function()
        ReplicatedFirst:RemoveDefaultLoadingScreen()
    end)
end

-- Enhanced Utility Functions
local function playSound(soundId, volume)
    if not SoundService then return end
    
    safeCall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://" .. tostring(soundId)
        sound.Volume = volume or 0.3
        sound.Parent = SoundService
        sound:Play()
        
        -- Auto cleanup
        task.spawn(function()
            sound.Ended:Wait()
            sound:Destroy()
        end)
        
        -- Fallback cleanup
        task.delay(5, function()
            if sound and sound.Parent then
                sound:Destroy()
            end
        end)
    end)
end

local function createTween(object, properties, duration)
    if not TweenService or not object then return nil end
    
    local success, tween = safeCall(function()
        local tweenInfo = TweenInfo.new(
            duration or TWEEN_TIME,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        )
        return TweenService:Create(object, tweenInfo, properties)
    end)
    
    return success and tween or nil
end

local function addCornerRadius(parent, radius)
    if not parent then return nil end
    
    local success, corner = safeCall(function()
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, radius or 8)
        corner.Parent = parent
        return corner
    end)
    
    return success and corner or nil
end

local function addStroke(parent, color, thickness)
    if not parent then return nil end
    
    local success, stroke = safeCall(function()
        local stroke = Instance.new("UIStroke")
        stroke.Color = color or UI_COLORS.ACCENT
        stroke.Thickness = thickness or 1
        stroke.Parent = parent
        return stroke
    end)
    
    return success and stroke or nil
end

-- Fixed gradient function
local function addGradient(parent, colorStart, colorEnd, rotation)
    if not parent then return nil end
    
    local success, gradient = safeCall(function()
        local gradient = Instance.new("UIGradient")
        
        -- Fixed ColorSequence creation
        local startColor = colorStart or UI_COLORS.PRIMARY
        local endColor = colorEnd or UI_COLORS.SECONDARY
        
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, startColor),
            ColorSequenceKeypoint.new(1, endColor)
        })
        
        gradient.Rotation = rotation or 45
        gradient.Parent = parent
        return gradient
    end)
    
    return success and gradient or nil
end

local function addHoverEffect(button, hoverColor, normalColor)
    if not button then return end

    local normal = normalColor or button.BackgroundColor3
    local hover = hoverColor or Color3.fromRGB(
        math.min(normal.R * 255 + 20, 255),
        math.min(normal.G * 255 + 20, 255),
        math.min(normal.B * 255 + 20, 255)
    )

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

    button.MouseLeave:Connect(function()
        local tween = createTween(button, {Size = originalSize}, 0.1)
        if tween then tween:Play() end
    end)
end

-- Enhanced UI Creation Functions
local function createStyledButton(parent, name, text, position, size, color)
    if not parent then return nil end
    
    local success, button = safeCall(function()
        local button = Instance.new("TextButton")
        button.Name = name or "StyledButton"
        button.Parent = parent
        button.BackgroundColor3 = color or UI_COLORS.SECONDARY
        button.Size = size or UDim2.new(0, 100, 0, 30)
        button.Position = position or UDim2.new(0, 0, 0, 0)
        button.Text = text or ""
        button.TextColor3 = UI_COLORS.TEXT_PRIMARY
        button.TextScaled = true
        button.Font = Enum.Font.GothamBold
        button.BorderSizePixel = 0
        button.AutoButtonColor = false

        addCornerRadius(button, 6)
        addStroke(button, UI_COLORS.ACCENT, 1)
        addHoverEffect(button)
        addButtonEffect(button)

        return button
    end)
    
    return success and button or nil
end

local function createStyledLabel(parent, name, text, position, size)
    if not parent then return nil end
    
    local success, label = safeCall(function()
        local label = Instance.new("TextLabel")
        label.Name = name or "StyledLabel"
        label.Parent = parent
        label.BackgroundTransparency = 1
        label.Size = size or UDim2.new(1, 0, 0, 30)
        label.Position = position or UDim2.new(0, 0, 0, 0)
        label.Text = text or ""
        label.TextColor3 = UI_COLORS.TEXT_PRIMARY
        label.TextScaled = true
        label.Font = Enum.Font.Gotham
        label.TextWrapped = true

        return label
    end)
    
    return success and label or nil
end

-- Enhanced cleanup function
local function cleanupUI()
    -- Disconnect all connections
    for name, connection in pairs(connections) do
        if connection and typeof(connection) == "RBXScriptConnection" then
            safeCall(function()
                connection:Disconnect()
            end)
        end
    end
    connections = {}
    
    -- Cleanup UI
    if mainScreenGui then
        safeCall(function()
            mainScreenGui:Destroy()
        end)
        mainScreenGui = nil
        mainPanel = nil
        dropdownFrame = nil
        dropdownButton = nil
    end
end

-- Enhanced Player Functions
local function getAllSwords(player)
    if not player then return 0 end
    
    local count = 0
    
    safeCall(function()
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

    safeCall(function()
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
                stats.jumpPower = humanoid.JumpPower or humanoid.JumpHeight or 50
            end
        end
    end)

    return stats
end

-- Enhanced action execution with better error handling
local function executePlayerAction(player, actionType)
    if not player or not player.Character then
        return false, "Player or character not found"
    end

    local success, message = safeCall(function()
        local backpack = LocalPlayer.Backpack
        if not backpack then
            return false, "Local player backpack not found"
        end
        
        local sword = backpack:FindFirstChild("sword") or backpack:FindFirstChild("Sword")
        
        if not sword then
            -- Try to find any tool that might be a sword
            for _, tool in ipairs(backpack:GetChildren()) do
                if tool:IsA("Tool") and string.lower(tool.Name):find("sword") then
                    sword = tool
                    break
                end
            end
        end
        
        if not sword then
            return false, "No sword found in backpack"
        end

        local targetHumanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if not targetHumanoid then
            return false, "Target humanoid not found"
        end

        -- Equip sword
        sword.Parent = LocalPlayer.Character
        
        local swordHandle = sword:FindFirstChild("Handle")
        if swordHandle then
            local damageEvent = swordHandle:FindFirstChild("dmg")
            if damageEvent then
                damageEvent = damageEvent:FindFirstChild("RemoteEvent")
                
                if damageEvent then
                    local damage = actionType == "god" and -math.huge or math.huge
                    damageEvent:FireServer(targetHumanoid, damage)
                    
                    -- Move sword back to backpack
                    task.wait(0)
                    if sword and sword.Parent then
                        sword.Parent = backpack
                    end
                    
                    return true, actionType == "god" and "Player given god mode" or "Player eliminated"
                end
            end
        end
        
        -- Return sword to backpack if action failed
        if sword and sword.Parent then
            sword.Parent = backpack
        end
        
        return false, "Damage event not found"
    end)
    
    return success and message[1] or false, success and message[2] or "Action failed"
end

-- Enhanced UI Creation with better error handling
local function createMainUI()
    if not PlayerGui then
        warn("PlayerGui not available")
        return
    end
    
    cleanupUI()

    local success = safeCall(function()
        -- Main ScreenGui
        mainScreenGui = Instance.new("ScreenGui")
        mainScreenGui.Name = "EnhancedMainUI_" .. tick()
        mainScreenGui.ResetOnSpawn = false
        mainScreenGui.IgnoreGuiInset = true
        mainScreenGui.Parent = PlayerGui

        -- Main Panel with enhanced styling
        mainPanel = Instance.new("Frame")
        mainPanel.Name = "MainPanel"
        mainPanel.Parent = mainScreenGui
        mainPanel.BackgroundColor3 = UI_COLORS.PRIMARY
        mainPanel.Size = UDim2.new(0, 520, 0, 420)
        mainPanel.Position = UDim2.new(0.5, -260, 0.5, -210)
        mainPanel.AnchorPoint = Vector2.new(0.5, 0.5)
        mainPanel.BorderSizePixel = 0
        mainPanel.ClipsDescendants = true

        addCornerRadius(mainPanel, 15)
        addStroke(mainPanel, UI_COLORS.ACCENT, 2)
        addGradient(mainPanel, UI_COLORS.PRIMARY, UI_COLORS.BACKGROUND_DARK, 45)

        -- Enhanced border effect with safer animation
        local borderEffect = Instance.new("Frame")
        borderEffect.Name = "BorderEffect"
        borderEffect.Parent = mainPanel
        borderEffect.BackgroundTransparency = 1
        borderEffect.Size = UDim2.new(1, 0, 1, 0)
        borderEffect.Position = UDim2.new(0, 0, 0, 0)
        addCornerRadius(borderEffect, 15)
        local borderStroke = addStroke(borderEffect, UI_COLORS.ACCENT, 3)
        
        -- Safer animated border
        if borderStroke then
            task.spawn(function()
                local colors = {UI_COLORS.ACCENT, UI_COLORS.SUCCESS, UI_COLORS.WARNING, UI_COLORS.DANGER, UI_COLORS.ACCENT_SECONDARY}
                local colorIndex = 1
                
                while borderEffect.Parent and borderStroke.Parent do
                    local tween = createTween(borderStroke, {Color = colors[colorIndex]}, 1.5)
                    if tween then
                        tween:Play()
                        tween.Completed:Wait()
                    else
                        task.wait(1.5)
                    end
                    
                    colorIndex = colorIndex % #colors + 1
                    task.wait(0.5)
                end
            end)
        end

        -- Enhanced Title Section
        local titleFrame = Instance.new("Frame")
        titleFrame.Name = "TitleFrame"
        titleFrame.Parent = mainPanel
        titleFrame.BackgroundColor3 = UI_COLORS.SECONDARY
        titleFrame.Size = UDim2.new(1, 0, 0, 70)
        titleFrame.Position = UDim2.new(0, 0, 0, 0)
        titleFrame.BorderSizePixel = 0
        addCornerRadius(titleFrame, 15)
        addGradient(titleFrame, UI_COLORS.SECONDARY, UI_COLORS.PRIMARY, 90)

        local title = createStyledLabel(titleFrame, "Title", "🗡️ STATS PANEL 2025 🗡️", 
            UDim2.new(0, 15, 0, 5), UDim2.new(1, -130, 0, 35))
        if title then
            title.Font = Enum.Font.GothamBold
            title.TextColor3 = UI_COLORS.ACCENT
        end

        local subtitle = createStyledLabel(titleFrame, "Subtitle", "Created by AlznDev v2.2 - Fixed Dropdown", 
            UDim2.new(0, 15, 0, 35), UDim2.new(1, -130, 0, 30))
        if subtitle then
            subtitle.TextColor3 = UI_COLORS.TEXT_SECONDARY
            subtitle.Font = Enum.Font.Gotham
        end

        -- Enhanced Control Buttons
        local closeButton = createStyledButton(titleFrame, "CloseButton", "✕", 
            UDim2.new(1, -55, 0, 5), UDim2.new(0, 45, 0, 30), UI_COLORS.DANGER)
        if closeButton then
            closeButton.MouseButton1Click:Connect(function()
                local tween = createTween(mainPanel, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.4)
                if tween then
                    tween:Play()
                    tween.Completed:Wait()
                end
                cleanupUI()
                isUIVisible = false
            end)
        end

        local minimizeButton = createStyledButton(titleFrame, "MinimizeButton", "—", 
            UDim2.new(1, -105, 0, 5), UDim2.new(0, 45, 0, 30), UI_COLORS.WARNING)
        if minimizeButton then
            minimizeButton.MouseButton1Click:Connect(function()
                if mainPanel.Size.Y.Offset > 100 then
                    local tween = createTween(mainPanel, {Size = UDim2.new(0, 520, 0, 70)}, 0.3)
                    if tween then tween:Play() end
                else
                    local tween = createTween(mainPanel, {Size = UDim2.new(0, 520, 0, 420)}, 0.3)
                    if tween then tween:Play() end
                end
            end)
        end

        -- Player Selection Section with enhanced styling
        local selectionFrame = Instance.new("Frame")
        selectionFrame.Name = "SelectionFrame"
        selectionFrame.Parent = mainPanel
        selectionFrame.BackgroundColor3 = UI_COLORS.SECONDARY
        selectionFrame.Size = UDim2.new(1, -20, 0, 90)
        selectionFrame.Position = UDim2.new(0, 10, 0, 80)
        selectionFrame.BorderSizePixel = 0
        addCornerRadius(selectionFrame, 10)
        addStroke(selectionFrame, UI_COLORS.ACCENT, 1)

        local selectionLabel = createStyledLabel(selectionFrame, "SelectionLabel", "🎯 Target Player", 
            UDim2.new(0, 15, 0, 5), UDim2.new(0.5, -15, 0, 25))
        if selectionLabel then
            selectionLabel.Font = Enum.Font.GothamBold
            selectionLabel.TextColor3 = UI_COLORS.ACCENT
        end

        -- Enhanced Profile Picture
        local profilePic = Instance.new("ImageLabel")
        profilePic.Name = "ProfilePic"
        profilePic.Parent = selectionFrame
        profilePic.BackgroundColor3 = UI_COLORS.PRIMARY
        profilePic.Size = UDim2.new(0, 70, 0, 70)
        profilePic.Position = UDim2.new(0, 10, 0, 15)
        profilePic.ScaleType = Enum.ScaleType.Crop
        profilePic.Image = "rbxasset://textures/face.png"
        addCornerRadius(profilePic, 35)
        addStroke(profilePic, UI_COLORS.ACCENT, 2)

        -- Enhanced Dropdown Button
        dropdownButton = createStyledButton(selectionFrame, "DropdownButton", LocalPlayer and LocalPlayer.Name or "Unknown", 
            UDim2.new(0, 90, 0, 30), UDim2.new(1, -110, 0, 40), UI_COLORS.PRIMARY)

        -- FIXED: Enhanced Dropdown Frame with proper Z-Index
        dropdownFrame = Instance.new("Frame")
        dropdownFrame.Name = "DropdownFrame"
        dropdownFrame.Parent = mainScreenGui -- Parent to ScreenGui instead of mainPanel for proper layering
        dropdownFrame.BackgroundColor3 = UI_COLORS.SECONDARY
        dropdownFrame.Size = UDim2.new(0, 500, 0, 0)
        -- Position relative to the dropdown button
        dropdownFrame.Position = UDim2.new(0.5, -250, 0.5, -100)
        dropdownFrame.Visible = false
        dropdownFrame.BorderSizePixel = 0
        dropdownFrame.ZIndex = 100 -- High Z-Index to appear above other elements
        addCornerRadius(dropdownFrame, 10)
        addStroke(dropdownFrame, UI_COLORS.ACCENT, 2)

        -- Add ScrollingFrame inside the dropdown
        local scrollFrame = Instance.new("ScrollingFrame")
        scrollFrame.Name = "ScrollFrame"
        scrollFrame.Parent = dropdownFrame
        scrollFrame.BackgroundTransparency = 1
        scrollFrame.Size = UDim2.new(1, 0, 1, 0)
        scrollFrame.Position = UDim2.new(0, 0, 0, 0)
        scrollFrame.ScrollBarThickness = 8
        scrollFrame.ScrollBarImageColor3 = UI_COLORS.ACCENT
        scrollFrame.BorderSizePixel = 0
        scrollFrame.ZIndex = 101

        -- Enhanced Stats Display Section
        local statsFrame = Instance.new("Frame")
        statsFrame.Name = "StatsFrame"
        statsFrame.Parent = mainPanel
        statsFrame.BackgroundColor3 = UI_COLORS.SECONDARY
        statsFrame.Size = UDim2.new(1, -20, 0, 130)
        statsFrame.Position = UDim2.new(0, 10, 0, 180)
        statsFrame.BorderSizePixel = 0
        addCornerRadius(statsFrame, 10)
        addStroke(statsFrame, UI_COLORS.SUCCESS, 1)
        addGradient(statsFrame, UI_COLORS.SECONDARY, UI_COLORS.PRIMARY, 180)

        local statsTitle = createStyledLabel(statsFrame, "StatsTitle", "📊 Player Statistics", 
            UDim2.new(0, 15, 0, 5), UDim2.new(1, -30, 0, 25))
        if statsTitle then
            statsTitle.Font = Enum.Font.GothamBold
            statsTitle.TextColor3 = UI_COLORS.SUCCESS
        end

        local statsDisplay = createStyledLabel(statsFrame, "StatsDisplay", "Loading stats...", 
            UDim2.new(0, 15, 0, 30), UDim2.new(1, -30, 0, 95))
        if statsDisplay then
            statsDisplay.TextYAlignment = Enum.TextYAlignment.Top
            statsDisplay.Font = Enum.Font.GothamMedium
        end

        -- Enhanced Action Buttons Section
        local actionFrame = Instance.new("Frame")
        actionFrame.Name = "ActionFrame"
        actionFrame.Parent = mainPanel
        actionFrame.BackgroundColor3 = UI_COLORS.SECONDARY
        actionFrame.Size = UDim2.new(1, -20, 0, 70)
        actionFrame.Position = UDim2.new(0, 10, 0, 320)
        actionFrame.BorderSizePixel = 0
        addCornerRadius(actionFrame, 10)
        addStroke(actionFrame, UI_COLORS.WARNING, 1)

        local actionTitle = createStyledLabel(actionFrame, "ActionTitle", "⚡ Quick Actions", 
            UDim2.new(0, 15, 0, 5), UDim2.new(1, -30, 0, 25))
        if actionTitle then
            actionTitle.Font = Enum.Font.GothamBold
            actionTitle.TextColor3 = UI_COLORS.WARNING
        end

        local godButton = createStyledButton(actionFrame, "GodButton", "🛡️ God Mode", 
            UDim2.new(0, 15, 0, 30), UDim2.new(0.5, -20, 0, 35), UI_COLORS.SUCCESS)
        
        local killButton = createStyledButton(actionFrame, "KillButton", "💀 Eliminate", 
            UDim2.new(0.5, 5, 0, 30), UDim2.new(0.5, -20, 0, 35), UI_COLORS.DANGER)

        -- Enhanced Status Bar
        local statusBar = Instance.new("Frame")
        statusBar.Name = "StatusBar"
        statusBar.Parent = mainPanel
        statusBar.BackgroundColor3 = UI_COLORS.PRIMARY
        statusBar.Size = UDim2.new(1, 0, 0, 30)
        statusBar.Position = UDim2.new(0, 0, 1, -30)
        statusBar.BorderSizePixel = 0
        addGradient(statusBar, UI_COLORS.PRIMARY, UI_COLORS.BACKGROUND_DARK, 0)

        local statusLabel = createStyledLabel(statusBar, "StatusLabel", "Press 'K' to toggle | Ready ✓", 
            UDim2.new(0, 15, 0, 0), UDim2.new(1, -30, 1, 0))
        if statusLabel then
            statusLabel.TextColor3 = UI_COLORS.TEXT_SECONDARY
            statusLabel.Font = Enum.Font.GothamMedium
        end

        -- Enhanced Functions
        local function updateProfilePic(player)
            if not player or not profilePic then return end
            
            task.spawn(function()
                local success, result = safeCall(function()
                    if Players and Players.GetUserThumbnailAsync then
                        return Players:GetUserThumbnailAsync(player.UserId, 
                            Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
                    end
                    return nil
                end)
                
                if success and result then
                    profilePic.Image = result
                else
                    profilePic.Image = "rbxasset://textures/face.png"
                end
            end)
        end

        -- FIXED: Enhanced dropdown population with proper event handling
        local function populateDropdown()
            if not dropdownFrame or not scrollFrame then return end
            
            -- Clear existing items
            for _, child in ipairs(scrollFrame:GetChildren()) do
                if child:IsA("TextButton") then
                    child:Destroy()
                end
            end

            local playersList = Players and Players:GetPlayers() or {}
            local itemHeight = 40
            local maxVisibleItems = 6
            local maxHeight = math.min(#playersList * itemHeight, maxVisibleItems * itemHeight)
            
            -- Update dropdown frame size
            dropdownFrame.Size = UDim2.new(0, 500, 0, maxHeight + 10)
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #playersList * itemHeight)

            for index, player in ipairs(playersList) do
                local item = Instance.new("TextButton")
                item.Name = "PlayerItem_" .. player.Name
                item.Parent = scrollFrame
                item.BackgroundColor3 = UI_COLORS.PRIMARY
                item.Size = UDim2.new(1, -10, 0, itemHeight - 5)
                item.Position = UDim2.new(0, 5, 0, (index - 1) * itemHeight)
                item.Text = string.format("👤 %s (ID: %d)", player.Name, player.UserId)
                item.TextColor3 = UI_COLORS.TEXT_PRIMARY
                item.TextScaled = true
                item.Font = Enum.Font.GothamMedium
                item.BorderSizePixel = 0
                item.AutoButtonColor = false
                item.ZIndex = 102
                
                addCornerRadius(item, 6)
                addStroke(item, UI_COLORS.ACCENT, 1)
                
                -- Enhanced hover effect for dropdown items
                item.MouseEnter:Connect(function()
                    local tween = createTween(item, {BackgroundColor3 = UI_COLORS.SECONDARY}, 0.2)
                    if tween then tween:Play() end
                end)
                
        item.MouseLeave:Connect(function()
            local tween = createTween(item, {BackgroundColor3 = UI_COLORS.PRIMARY}, 0.2)
            if tween then tween:Play() end
        end)

        -- Select player on click
        item.MouseButton1Click:Connect(function()
            selectedPlayer = player
            if dropdownButton then
                dropdownButton.Text = player.Name
            end
            updateProfilePic(player)
            dropdownFrame.Visible = false
            playSound("131961136", 0.2)
        end)
    end
end

        -- FIXED: Enhanced dropdown toggle with proper positioning
        if dropdownButton then
            dropdownButton.MouseButton1Click:Connect(function()
                if dropdownFrame.Visible then
                    dropdownFrame.Visible = false
                else
                    populateDropdown()
                    -- Position dropdown relative to the main panel
                    local mainPanelPos = mainPanel.AbsolutePosition
                    local mainPanelSize = mainPanel.AbsoluteSize
                    dropdownFrame.Position = UDim2.new(0, mainPanelPos.X + 10, 0, mainPanelPos.Y + 250)
                    dropdownFrame.Visible = true
                end
            end)
        end

        -- Enhanced stats update function
        local function updateStats()
            if not selectedPlayer or not statsDisplay then return end
            
            local stats = getPlayerStats(selectedPlayer)
            local statusText = string.format(
                "🗡️ Swords: %d\n💪 Power: %s\n💀 Kills: %s\n❤️ Health: %d/%d\n🏃 Speed: %.1f\n🦘 Jump: %.1f",
                stats.swords,
                stats.power >= 1000000 and string.format("%.1fM", stats.power / 1000000) or 
                stats.power >= 1000 and string.format("%.1fK", stats.power / 1000) or tostring(stats.power),
                stats.kills >= 1000000 and string.format("%.1fM", stats.kills / 1000000) or 
                stats.kills >= 1000 and string.format("%.1fK", stats.kills / 1000) or tostring(stats.kills),
                stats.health,
                stats.maxHealth,
                stats.walkSpeed,
                stats.jumpPower
            )
            
            statsDisplay.Text = statusText
            
            -- Color coding based on stats
            if stats.power >= 1000000 then
                statsDisplay.TextColor3 = UI_COLORS.WARNING
            elseif stats.power >= 100000 then
                statsDisplay.TextColor3 = UI_COLORS.SUCCESS
            else
                statsDisplay.TextColor3 = UI_COLORS.TEXT_PRIMARY
            end
        end

        -- Enhanced action button handlers
        if godButton then
            godButton.MouseButton1Click:Connect(function()
                if selectedPlayer then
                    local success, message = executePlayerAction(selectedPlayer, "god")
                    if statusLabel then
                        statusLabel.Text = message .. (success and " ✓" or " ✗")
                        statusLabel.TextColor3 = success and UI_COLORS.SUCCESS or UI_COLORS.DANGER
                    end
                    playSound(success and "131961136" or "142785488", 0.3)
                end
            end)
        end

        if killButton then
            killButton.MouseButton1Click:Connect(function()
                if selectedPlayer then
                    local success, message = executePlayerAction(selectedPlayer, "kill")
                    if statusLabel then
                        statusLabel.Text = message .. (success and " ✓" or " ✗")
                        statusLabel.TextColor3 = success and UI_COLORS.SUCCESS or UI_COLORS.DANGER
                    end
                    playSound(success and "131961136" or "142785488", 0.3)
                end
            end)
        end

        -- Enhanced drag functionality
        local dragStart = nil
        local startPos = nil
        local dragging = false

        titleFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = mainPanel.Position
            end
        end)

        titleFrame.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                mainPanel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, 
                                               startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)

        titleFrame.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)

        -- Initialize with current player
        selectedPlayer = LocalPlayer
        updateProfilePic(selectedPlayer)
        
        -- Start stats update loop
        task.spawn(function()
            while mainScreenGui and mainScreenGui.Parent do
                updateStats()
                task.wait(1)
            end
        end)

        -- Close dropdown when clicking outside
        mainScreenGui.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and dropdownFrame.Visible then
                local mousePos = UserInputService:GetMouseLocation()
                local dropdownPos = dropdownFrame.AbsolutePosition
                local dropdownSize = dropdownFrame.AbsoluteSize
                
                if mousePos.X < dropdownPos.X or mousePos.X > dropdownPos.X + dropdownSize.X or
                   mousePos.Y < dropdownPos.Y or mousePos.Y > dropdownPos.Y + dropdownSize.Y then
                    dropdownFrame.Visible = false
                end
            end
        end)

        -- Entrance animation
        mainPanel.Size = UDim2.new(0, 0, 0, 0)
        mainPanel.BackgroundTransparency = 1
        
        local entranceTween = createTween(mainPanel, {
            Size = UDim2.new(0, 520, 0, 420),
            BackgroundTransparency = 0
        }, 0.6)
        
        if entranceTween then
            entranceTween:Play()
        end

        playSound("131961136", 0.4)
    end)
    
    if not success then
        warn("Failed to create main UI")
    end
end

-- Enhanced Input Handling
local function setupInputHandling()
    if not UserInputService then return end
    
    local connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.K then
            if isUIVisible then
                if mainScreenGui then
                    local tween = createTween(mainPanel, {
                        Size = UDim2.new(0, 0, 0, 0),
                        BackgroundTransparency = 1
                    }, 0.4)
                    if tween then
                        tween:Play()
                        tween.Completed:Wait()
                    end
                    cleanupUI()
                end
                isUIVisible = false
            else
                createMainUI()
                isUIVisible = true
            end
        end
    end)
    
    connections["InputHandler"] = connection
end

-- Enhanced Player Added/Removed Events
local function setupPlayerEvents()
    if not Players then return end
    
    connections["PlayerAdded"] = Players.PlayerAdded:Connect(function(player)
        task.wait(1) -- Wait for player to fully load
        if mainScreenGui and mainScreenGui.Parent then
            -- Could refresh dropdown here if needed
        end
    end)
    
    connections["PlayerRemoving"] = Players.PlayerRemoving:Connect(function(player)
        if selectedPlayer == player then
            selectedPlayer = LocalPlayer
        end
    end)
end

-- Enhanced Error Recovery
local function setupErrorRecovery()
    task.spawn(function()
        while true do
            task.wait(5)
            
            -- Check if UI still exists and is functional
            if isUIVisible and (not mainScreenGui or not mainScreenGui.Parent) then
                warn("UI was destroyed unexpectedly, attempting recovery...")
                task.wait(1)
                createMainUI()
            end
        end
    end)
end

-- Main Initialization
local function initialize()
    -- Check for required services
    if not LocalPlayer then
        warn("LocalPlayer not found")
        return
    end
    
    if not PlayerGui then
        warn("PlayerGui not found")
        return
    end
    
    -- Setup everything
    setupInputHandling()
    setupPlayerEvents()
    setupErrorRecovery()
    
    -- Create initial UI
    createMainUI()
    
    -- Success notification
    task.wait(1)
    if mainScreenGui and mainScreenGui.Parent then
        playSound("131961136", 0.5)
    end
end

-- Launch with error handling
safeCall(initialize)

-- Cleanup on script end
script.AncestryChanged:Connect(function()
    if not script.Parent then
        cleanupUI()
    end
end)
