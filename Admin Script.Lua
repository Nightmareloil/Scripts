-- Solex Sword Simulator Admin Commands Script
local chatEvent = game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest
local player = game.Players.LocalPlayer

-- Utility Functions
local function sendChatMessage(message)
    chatEvent:FireServer(message, "All")
end

local function teleportToPlace(placeId)
    local teleportService = game:GetService("TeleportService")
    teleportService:Teleport(placeId, player)
end

local function activateFarm(farm)
    while _G.farm do
        wait()
        if farm then
            for _ = 1, 10 do
                local sword = player.Character:FindFirstChild("sword") or player.Backpack:FindFirstChild("sword")
                if sword then
                    sword.Handle.up.RemoteEvent:FireServer()
                end
            end
        end
    end
end

-- Command Functions
local commands = {
    [";cmds"] = function()
        sendChatMessage("[Admin commands are available in the Solex Community Server. Please check there for more details.]")
    end,
    
    [";credits"] = function()
        sendChatMessage("[Script developed by Cyvex and VoidXD.]")
    end,
    
    [";fastdupe"] = function()
        -- Dupe command logic
    end,
    
    [";sword god"] = function()
        -- Sword god command logic
    end,
    
    [";power view"] = function()
        -- Power view GUI logic
    end,
    
    [";farm"] = function()
        _G.farm = true
        activateFarm(_G.farm)
    end,
    
    [";unfarm"] = function()
        _G.farm = false
    end,
    
    [";speed me 100"] = function()
        player.Character.Humanoid.WalkSpeed += 100
    end,
    
    [";speed me 50"] = function()
        player.Character.Humanoid.WalkSpeed += 50
    end,
    
    [";re"] = function()
        player.Character.Humanoid.Health = 0
    end,
    
    [";afk"] = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/KazeOnTop/Rice-Anti-Afk/main/Wind", true))()
    end,
    
    [";gui"] = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/icuck/Sword-Simulator-GUI/master/main.lua", true))()
    end,
    
    [";god"] = function()
        local sword = player.Character:FindFirstChild("sword") or player.Backpack:FindFirstChild("sword")
        if sword then
            sword.Handle.dmg.RemoteEvent:FireServer(player.Character.Humanoid, -math.huge)
        end
        while wait() do
            player.Character.Humanoid.Health = math.huge
            if player.Character:FindFirstChild("pvp") then
                player.Character.pvp:Destroy()
            end
        end
    end,
    
    [";rj"] = function()
        teleportToPlace(game.PlaceId)
    end
}

-- Listen for Chat Commands
player.Chatted:Connect(function(msg)
    if commands[msg] then
        commands[msg]()
    else
        sendChatMessage("[Invalid command. Type ;cmds for a list of available commands.]")
    end
end)
