--------------------------------------------------
-- SERVICES & INITIAL SETUP
--------------------------------------------------
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Remove the default Roblox loading screen
ReplicatedFirst:RemoveDefaultLoadingScreen()

--------------------------------------------------
-- COOL LOADING SCREEN SETUP
--------------------------------------------------
local loadScreenGui = Instance.new("ScreenGui")
loadScreenGui.IgnoreGuiInset = true
loadScreenGui.Parent = PlayerGui

-- Fullscreen background text
local loadingTextLabel = Instance.new("TextLabel")
loadingTextLabel.Size = UDim2.new(1, 0, 1, 0)
loadingTextLabel.BackgroundColor3 = Color3.fromRGB(0, 20, 40)
loadingTextLabel.Font = Enum.Font.GothamMedium
loadingTextLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
loadingTextLabel.Text = "Loading"
loadingTextLabel.TextSize = 28
loadingTextLabel.Parent = loadScreenGui

-- Rotating loading ring
local loadingRing = Instance.new("ImageLabel")
loadingRing.Size = UDim2.new(0, 256, 0, 256)
loadingRing.BackgroundTransparency = 1
loadingRing.Image = "rbxassetid://4965945816"
loadingRing.AnchorPoint = Vector2.new(0.5, 0.5)
loadingRing.Position = UDim2.new(0.5, 0, 0.5, 0)
loadingRing.Parent = loadScreenGui

local ringTweenInfo = TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1)
local ringTween = TweenService:Create(loadingRing, ringTweenInfo, {Rotation = 360})
ringTween:Play()

-- Force the loading screen to stay for at least 5 seconds (or until game is loaded)
task.wait(5)
if not game:IsLoaded() then
    game.Loaded:Wait()
end
loadScreenGui:Destroy()

--------------------------------------------------
-- MAIN UI PANEL SETUP (Modern, Draggable, Toggleable)
--------------------------------------------------
local mainScreenGui = Instance.new("ScreenGui")
mainScreenGui.Name = "MainUI"
mainScreenGui.Parent = PlayerGui

local mainPanel = Instance.new("Frame")
mainPanel.Name = "MainPanel"
mainPanel.Parent = mainScreenGui
mainPanel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainPanel.Size = UDim2.new(0, 450, 0, 350)
mainPanel.Position = UDim2.new(0.5, -225, 0.5, -175)
mainPanel.AnchorPoint = Vector2.new(0.5, 0.5)
mainPanel.ZIndex = 1
mainPanel.Visible = true

-- Stats Title
local statsTitle = Instance.new("TextLabel")
statsTitle.Name = "StatsTitle"
statsTitle.Parent = mainPanel
statsTitle.BackgroundTransparency = 1
statsTitle.Size = UDim2.new(1, 0, 0.15, 0)
statsTitle.Position = UDim2.new(0, 0, 0, 0)
statsTitle.Text = "Stats Overview"
statsTitle.TextColor3 = Color3.new(1, 1, 1)
statsTitle.TextScaled = true
statsTitle.Font = Enum.Font.GothamBold

-- Creator Credits
local creditsLabel = Instance.new("TextLabel")
creditsLabel.Name = "CreditsLabel"
creditsLabel.Parent = mainPanel
creditsLabel.BackgroundTransparency = 1
creditsLabel.Size = UDim2.new(1, 0, 0.08, 0)
creditsLabel.Position = UDim2.new(0, 0, 0.15, 0)
creditsLabel.Text = "Created by AlznDev"
creditsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
creditsLabel.TextScaled = true
creditsLabel.Font = Enum.Font.Gotham

--------------------------------------------------
-- DROPDOWN SETUP FOR PLAYER SELECTION
--------------------------------------------------
local selectedPlayer = LocalPlayer  -- Default selected player

-- Profile Picture (player headshot)
local profilePic = Instance.new("ImageLabel")
profilePic.Name = "ProfilePic"
profilePic.Parent = mainPanel
profilePic.BackgroundTransparency = 1
profilePic.Size = UDim2.new(0, 100, 0, 100)
profilePic.Position = UDim2.new(0.05, 0, 0.45, 0)
profilePic.ScaleType = Enum.ScaleType.Fit

local function updateProfilePic(player)
    if player then
        local success, thumb = pcall(function()
            return Players:GetUserThumbnailAsync(player.UserId,
                Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        end)
        if success and thumb then
            profilePic.Image = thumb
        else
            profilePic.Image = "rbxassetid://1234567890"  -- Fallback image
        end
    else
        warn("updateProfilePic: Player is nil")
    end
end

updateProfilePic(LocalPlayer)

-- Dropdown Button for Player Selection
local dropdownButton = Instance.new("TextButton")
dropdownButton.Name = "DropdownButton"
dropdownButton.Parent = mainPanel
dropdownButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
dropdownButton.Size = UDim2.new(0.8, 0, 0.1, 0)
dropdownButton.Position = UDim2.new(0.1, 0, 0.25, 0)
dropdownButton.Text = LocalPlayer.Name
dropdownButton.TextColor3 = Color3.new(1, 1, 1)
dropdownButton.TextScaled = true
dropdownButton.Font = Enum.Font.Gotham

-- Dropdown Frame (hidden by default)
local dropdownFrame = Instance.new("Frame")
dropdownFrame.Name = "DropdownFrame"
dropdownFrame.Parent = mainPanel
dropdownFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
dropdownFrame.Size = UDim2.new(0.8, 0, 0, 0)  -- Height set dynamically
dropdownFrame.Position = UDim2.new(0.1, 0, 0.35, 0)
dropdownFrame.Visible = false

local function populateDropdown()
    for _, child in ipairs(dropdownFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    local playersList = Players:GetPlayers()
    local itemHeight = 30
    dropdownFrame.Size = UDim2.new(0.8, 0, 0, #playersList * itemHeight)
    for index, plr in ipairs(playersList) do
        local item = Instance.new("TextButton")
        item.Name = "Item_" .. plr.Name
        item.Parent = dropdownFrame
        item.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        item.Size = UDim2.new(1, 0, 0, itemHeight)
        item.Position = UDim2.new(0, 0, 0, (index - 1) * itemHeight)
        item.Text = plr.Name
        item.TextColor3 = Color3.new(1, 1, 1)
        item.TextScaled = true
        item.Font = Enum.Font.Gotham
        item.MouseButton1Click:Connect(function()
            selectedPlayer = plr
            dropdownButton.Text = plr.Name
            updateProfilePic(selectedPlayer)
            dropdownFrame.Visible = false
        end)
    end
end

dropdownButton.MouseButton1Click:Connect(function()
    dropdownFrame.Visible = not dropdownFrame.Visible
    if dropdownFrame.Visible then
        populateDropdown()
    end
end)

--------------------------------------------------
-- GOD MODE BUTTON SETUP
--------------------------------------------------

-- Local function to activate god mode
local function godPlayer(player)
    -- Check if the player has a sword in their backpack
    local backpack = game.Players.LocalPlayer.Backpack
    local sword = backpack:FindFirstChild("sword")
    
    -- Check if the sword exists and the target player is valid
    if sword and player and player.Character then
        local targetHumanoid = player.Character:FindFirstChild("Humanoid")
        
        -- Ensure the target has a humanoid and health greater than 0
        if targetHumanoid and targetHumanoid.Health > 0 then
            -- Equip sword to the character and deal damage to the target
            sword.Parent = game.Players.LocalPlayer.Character
            local swordHandle = sword:FindFirstChild("Handle")
            
            if swordHandle then
                -- Fire the damage event, applying an extremely high negative value to simulate god mode
                local damageEvent = swordHandle:FindFirstChild("dmg") and swordHandle.dmg:FindFirstChild("RemoteEvent")
                if damageEvent then
                    damageEvent:FireServer(targetHumanoid, -math.huge)
                    print("God mode activated on " .. player.Name)
                else
                    warn("Damage event not found on sword handle")
                end
            end

            -- Return the sword to the backpack after the action
            sword.Parent = backpack
        else
            warn("Target does not have a humanoid or has no health.")
        end
    else
        warn("Sword or player character is missing.")
    end
end

-- Ensure the 'godButton' is created and set up after defining its event connection
local godButton = Instance.new("TextButton")
godButton.Name = "GodButton"
godButton.Parent = mainPanel
godButton.BackgroundColor3 = Color3.fromRGB(30, 130, 30)
godButton.Size = UDim2.new(0.35, 0, 0.1, 0)
godButton.Position = UDim2.new(0.1, 0, 0.8, 0)
godButton.Text = "God Player"
godButton.TextColor3 = Color3.new(1, 1, 1)
godButton.TextScaled = true
godButton.Font = Enum.Font.GothamBold

godButton.MouseButton1Click:Connect(function()
    if selectedPlayer then
        godPlayer(selectedPlayer)
    else
        warn("No player selected for god mode.")
    end
end)

--------------------------------------------------
-- KILL BUTTON SETUP
--------------------------------------------------

-- Function to handle killing the selected player
local function killPlayer(player)
    if player and player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health > 0 then
            local backpack = game.Players.LocalPlayer.Backpack
            local sword = backpack:FindFirstChild("sword")

            if sword then
                sword.Parent = game.Players.LocalPlayer.Character
                local swordHandle = sword:FindFirstChild("Handle")
                if swordHandle then
                    local damageEvent = swordHandle:FindFirstChild("dmg") and swordHandle.dmg:FindFirstChild("RemoteEvent")
                    if damageEvent then
                        damageEvent:FireServer(humanoid, math.huge)
                        print(player.Name .. " has been killed using sword.")
                    else
                        warn("Damage event not found on sword handle.")
                    end
                else
                    warn("Sword does not have a handle.")
                end
            else
                warn("Sword not found in Backpack.")
            end

            if sword then
                sword.Parent = backpack
            end
        else
            warn("Target does not have a valid humanoid or is already dead.")
        end
    else
        warn("Invalid player or player character.")
    end
end

-- Create the kill button
local killButton = Instance.new("TextButton")
killButton.Name = "KillButton"
killButton.Parent = mainPanel
killButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
killButton.Size = UDim2.new(0.35, 0, 0.1, 0)
killButton.Position = UDim2.new(0.55, 0, 0.8, 0)
killButton.Text = "Kill Player"
killButton.TextColor3 = Color3.new(1, 1, 1)
killButton.TextScaled = true
killButton.Font = Enum.Font.GothamBold

-- Connect the kill button AFTER it's created
killButton.MouseButton1Click:Connect(function()
    if selectedPlayer then
        killPlayer(selectedPlayer)
    else
        warn("No player selected for killing.")
    end
end)


--------------------------------------------------
-- OTHER UI ELEMENTS
--------------------------------------------------
local statsLabel = Instance.new("TextLabel")
statsLabel.Name = "StatsLabel"
statsLabel.Parent = mainPanel
statsLabel.BackgroundTransparency = 1
statsLabel.Size = UDim2.new(0.55, 0, 0.35, 0)
statsLabel.Position = UDim2.new(0.4, 0, 0.45, 0)
statsLabel.Text = "Gathering Stats..."
statsLabel.TextColor3 = Color3.new(1, 1, 1)
statsLabel.TextScaled = true
statsLabel.Font = Enum.Font.Gotham
statsLabel.TextWrapped = true

local noteLabel = Instance.new("TextLabel")
noteLabel.Name = "NoteLabel"
noteLabel.Parent = mainPanel
noteLabel.BackgroundTransparency = 1
noteLabel.Size = UDim2.new(1, 0, 0.1, 0)
noteLabel.Position = UDim2.new(0, 0, 0.9, 0)
noteLabel.Text = "Press 'K' to toggle panel"
noteLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
noteLabel.TextScaled = true
noteLabel.Font = Enum.Font.Gotham

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Parent = mainPanel
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.TextScaled = true
closeButton.Font = Enum.Font.GothamBold
closeButton.MouseButton1Click:Connect(function()
    mainPanel.Visible = false
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.K then
        mainPanel.Visible = not mainPanel.Visible
    end
end)

--------------------------------------------------
-- MAKE THE MAIN PANEL DRAGGABLE
--------------------------------------------------
local function makeDraggable(frame)
    local dragging = false
    local dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                     startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    frame.InputBegan:Connect(function(input)
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
    frame.InputChanged:Connect(function(input)
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

--------------------------------------------------
-- DYNAMIC STATS UPDATE LOGIC (No Game Passes)
--------------------------------------------------
local function getAllSwords(player)
    local count = 0
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                count = count + 1
            end
        end
    end
    local character = player.Character
    if character then
        for _, tool in ipairs(character:GetChildren()) do
            if tool:IsA("Tool") then
                count = count + 1
            end
        end
    end
    return count
end

spawn(function()
    while true do
        wait(1)
        local player = selectedPlayer
        local ls = player:FindFirstChild("leaderstats")
        local power = (ls and ls:FindFirstChild("Power") and ls.Power.Value) or 0
        local kills = (ls and ls:FindFirstChild("Kills") and ls.Kills.Value) or 0
        local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        local health = (humanoid and humanoid.Health) or 0
        local swordCount = getAllSwords(player)

        local statsStr = string.format(
            "Sword Count: %d\nPower: %d\nKills: %d\nHealth: %d",
            swordCount, power, kills, math.floor(health)
        )
        statsLabel.Text = statsStr
    end
end)
