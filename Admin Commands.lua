local A_1 = "[Successfully loaded Commands will appear in this box below.]"-----message here
local A_2 = "All"
local Event = game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest
Event:FireServer(A_1, A_2)
-- Gui to Lua
-- Version: 3.2

-- Instances:

local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local MainTextlua = Instance.new("TextLabel")
local Close = Instance.new("TextButton")
local CmdsAdmins = Instance.new("TextButton")
local CmdsAdmins_2 = Instance.new("TextButton")
local CmdsAdmins_3 = Instance.new("TextButton")
local CmdsAdmins_4 = Instance.new("TextButton")
local CmdsAdmins_5 = Instance.new("TextButton")
local CmdsAdmins_6 = Instance.new("TextButton")
local Alznher = Instance.new("ImageLabel")
local CmdsAdmins_7 = Instance.new("TextButton")
local CmdsAdmins_8 = Instance.new("TextButton")
local CmdsAdmins_9 = Instance.new("TextButton")
local CmdsAdmins_10 = Instance.new("TextButton")
local CmdsAdmins_11 = Instance.new("TextButton")
local CmdsAdmins_12 = Instance.new("TextButton")
local CmdsAdmins_13 = Instance.new("TextButton")
local CmdsAdmins_14 = Instance.new("TextButton")
local CmdsAdmins_15 = Instance.new("TextButton")
local CmdsAdmins_16 = Instance.new("TextButton")
local CmdsAdmins_17 = Instance.new("TextButton")
local CmdsAdmins_18 = Instance.new("TextButton")
local CmdsAdmins_19 = Instance.new("TextButton")
local CmdsAdmins_20 = Instance.new("TextButton")
local CmdsAdmins_21 = Instance.new("TextButton")
local CmdsAdmins_22 = Instance.new("TextButton")
local CmdsAdmins_23 = Instance.new("TextButton")

--Properties:

ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
Frame.Position = UDim2.new(0.117974557, 0, 0.258939385, 0)
Frame.Size = UDim2.new(0, 844, 0, 279)
Frame.Style = Enum.FrameStyle.RobloxRound
Frame.Active = true
Frame.Draggable = true

MainTextlua.Name = "Main Text.lua"
MainTextlua.Parent = Frame
MainTextlua.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainTextlua.BorderColor3 = Color3.fromRGB(255, 255, 255)
MainTextlua.Position = UDim2.new(-0.00881701522, 0, -0.0265225172, 0)
MainTextlua.Size = UDim2.new(0.0128193358, 795, -0.0346088745, 42)
MainTextlua.SizeConstraint = Enum.SizeConstraint.RelativeYY
MainTextlua.Font = Enum.Font.Unknown
MainTextlua.Text = "Admin Commands | UI Version 3.0.0b "
MainTextlua.TextColor3 = Color3.fromRGB(255, 255, 255)
MainTextlua.TextSize = 14.000
MainTextlua.TextWrapped = true

Close.Name = "Close"
Close.Parent = Frame
Close.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Close.Position = UDim2.new(0.955695748, 0, -0.035288129, 0)
Close.Size = UDim2.new(0, 47, 0, 41)
Close.Style = Enum.ButtonStyle.RobloxButtonDefault
Close.Font = Enum.Font.Unknown
Close.Text = "X"
Close.TextColor3 = Color3.fromRGB(170, 0, 0)
Close.TextSize = 14.000

CmdsAdmins.Name = "Cmds/Admins"
CmdsAdmins.Parent = Frame
CmdsAdmins.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CmdsAdmins.BorderColor3 = Color3.fromRGB(0, 0, 0)
CmdsAdmins.Position = UDim2.new(-0.0112947375, 0, 0.212860554, 0)
CmdsAdmins.Size = UDim2.new(0, 185, 0, 34)
CmdsAdmins.Style = Enum.ButtonStyle.RobloxButtonDefault
CmdsAdmins.Font = Enum.Font.Unknown
CmdsAdmins.Text = ";fastdupe"
CmdsAdmins.TextColor3 = Color3.fromRGB(255, 255, 255)
CmdsAdmins.TextSize = 14.000

CmdsAdmins_2.Name = "Cmds/Admins"
CmdsAdmins_2.Parent = Frame
CmdsAdmins_2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CmdsAdmins_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
CmdsAdmins_2.Position = UDim2.new(0.441311866, 0, 0.901032567, 0)
CmdsAdmins_2.Size = UDim2.new(0, 185, 0, 34)
CmdsAdmins_2.Style = Enum.ButtonStyle.RobloxButtonDefault
CmdsAdmins_2.Font = Enum.Font.Unknown
CmdsAdmins_2.Text = "No Commands"
CmdsAdmins_2.TextColor3 = Color3.fromRGB(255, 255, 255)
CmdsAdmins_2.TextSize = 14.000

CmdsAdmins_3.Name = "Cmds/Admins"
CmdsAdmins_3.Parent = Frame
CmdsAdmins_3.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CmdsAdmins_3.BorderColor3 = Color3.fromRGB(0, 0, 0)
CmdsAdmins_3.Position = UDim2.new(-0.00892507192, 0, 0.485261977, 0)
CmdsAdmins_3.Size = UDim2.new(0, 185, 0, 34)
CmdsAdmins_3.Style = Enum.ButtonStyle.RobloxButtonDefault
CmdsAdmins_3.Font = Enum.Font.Unknown
CmdsAdmins_3.Text = ";Afk"
CmdsAdmins_3.TextColor3 = Color3.fromRGB(255, 255, 255)
CmdsAdmins_3.TextSize = 14.000

CmdsAdmins_4.Name = "Cmds/Admins"
CmdsAdmins_4.Parent = Frame
CmdsAdmins_4.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CmdsAdmins_4.BorderColor3 = Color3.fromRGB(0, 0, 0)
CmdsAdmins_4.Position = UDim2.new(0.679463565, 0, 0.313218951, 0)
CmdsAdmins_4.Size = UDim2.new(0, 185, 0, 34)
CmdsAdmins_4.Style = Enum.ButtonStyle.RobloxButtonDefault
CmdsAdmins_4.Font = Enum.Font.Unknown
CmdsAdmins_4.Text = ";re"
CmdsAdmins_4.TextColor3 = Color3.fromRGB(255, 255, 255)
CmdsAdmins_4.TextSize = 14.000

CmdsAdmins_5.Name = "Cmds/Admins"
CmdsAdmins_5.Parent = Frame
CmdsAdmins_5.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CmdsAdmins_5.BorderColor3 = Color3.fromRGB(0, 0, 0)
CmdsAdmins_5.Position = UDim2.new(0.443681538, 0, 0.592788815, 0)
CmdsAdmins_5.Size = UDim2.new(0, 185, 0, 34)
CmdsAdmins_5.Style = Enum.ButtonStyle.RobloxButtonDefault
CmdsAdmins_5.Font = Enum.Font.Unknown
CmdsAdmins_5.Text = ";fling"
CmdsAdmins_5.TextColor3 = Color3.fromRGB(255, 255, 255)
CmdsAdmins_5.TextSize = 14.000

CmdsAdmins_6.Name = "Cmds/Admins"
CmdsAdmins_6.Parent = Frame
CmdsAdmins_6.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CmdsAdmins_6.BorderColor3 = Color3.fromRGB(0, 0, 0)
CmdsAdmins_6.Position = UDim2.new(0.213823795, 0, 0.764831781, 0)
CmdsAdmins_6.Size = UDim2.new(0, 185, 0, 34)
CmdsAdmins_6.Style = Enum.ButtonStyle.RobloxButtonDefault
CmdsAdmins_6.Font = Enum.Font.Unknown
CmdsAdmins_6.Text = ";effects"
CmdsAdmins_6.TextColor3 = Color3.fromRGB(255, 255, 255)
CmdsAdmins_6.TextSize = 14.000

Alznher.Name = "Alzn/her"
Alznher.Parent = Frame
Alznher.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Alznher.BorderColor3 = Color3.fromRGB(255, 255, 255)
Alznher.Position = UDim2.new(0.917625904, 0, 0.767795265, 0)
Alznher.Size = UDim2.new(0, 76, 0, 69)
Alznher.SizeConstraint = Enum.SizeConstraint.RelativeYY
Alznher.Image = "rbxassetid://12143810274"
Alznher.ScaleType = Enum.ScaleType.Fit

CmdsAdmins_7.Name = "Cmds/Admins"
CmdsAdmins_7.Parent = Frame
CmdsAdmins_7.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CmdsAdmins_7.BorderColor3 = Color3.fromRGB(0, 0, 0)
CmdsAdmins_7.Position = UDim2.new(0.215008572, 0, 0.901032507, 0)
CmdsAdmins_7.Size = UDim2.new(0, 185, 0, 34)
CmdsAdmins_7.Style = Enum.ButtonStyle.RobloxButtonDefault
CmdsAdmins_7.Font = Enum.Font.Unknown
CmdsAdmins_7.Text = "No Commands"
CmdsAdmins_7.TextColor3 = Color3.fromRGB(255, 255, 255)
CmdsAdmins_7.TextSize = 14.000

CmdsAdmins_8.Name = "Cmds/Admins"
CmdsAdmins_8.Parent = Frame
CmdsAdmins_8.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CmdsAdmins_8.BorderColor3 = Color3.fromRGB(0, 0, 0)
CmdsAdmins_8.Position = UDim2.new(0.442496717, 0, 0.280960917, 0)
CmdsAdmins_8.Size = UDim2.new(0, 185, 0, 34)
CmdsAdmins_8.Style = Enum.ButtonStyle.RobloxButtonDefault
CmdsAdmins_8.Font = Enum.Font.Unknown
CmdsAdmins_8.Text = ";Power"
CmdsAdmins_8.TextColor3 = Color3.fromRGB(255, 255, 255)
CmdsAdmins_8.TextSize = 14.000

CmdsAdmins_9.Name = "Cmds/Admins"
CmdsAdmins_9.Parent = Frame
CmdsAdmins_9.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CmdsAdmins_9.BorderColor3 = Color3.fromRGB(0, 0, 0)
CmdsAdmins_9.Position = UDim2.new(0.211454093, 0, 0.216444761, 0)
CmdsAdmins_9.Size = UDim2.new(0, 185, 0, 34)
CmdsAdmins_9.Style = Enum.ButtonStyle.RobloxButtonDefault
CmdsAdmins_9.Font = Enum.Font.Unknown
CmdsAdmins_9.Text = ";sword god"
CmdsAdmins_9.TextColor3 = Color3.fromRGB(255, 255, 255)
CmdsAdmins_9.TextSize = 14.000

CmdsAdmins_10.Name = "Cmds/Admins"
CmdsAdmins_10.Parent = Frame
CmdsAdmins_10.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CmdsAdmins_10.BorderColor3 = Color3.fromRGB(0, 0, 0)
CmdsAdmins_10.Position = UDim2.new(0.211454093, 0, 0.488846242, 0)
CmdsAdmins_10.Size = UDim2.new(0, 185, 0, 34)
CmdsAdmins_10.Style = Enum.ButtonStyle.RobloxButtonDefault
CmdsAdmins_10.Font = Enum.Font.Unknown
CmdsAdmins_10.Text = ";fly"
CmdsAdmins_10.TextColor3 = Color3.fromRGB(255, 255, 255)
CmdsAdmins_10.TextSize = 14.000

CmdsAdmins_11.Name = "Cmds/Admins"
CmdsAdmins_11.Parent = Frame
CmdsAdmins_11.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CmdsAdmins_11.BorderColor3 = Color3.fromRGB(0, 0, 0)
CmdsAdmins_11.Position = UDim2.new(-0.0112947403, 0, 0.349061251, 0)
CmdsAdmins_11.Size = UDim2.new(0, 185, 0, 34)
CmdsAdmins_11.Style = Enum.ButtonStyle.RobloxButtonDefault
CmdsAdmins_11.Font = Enum.Font.Unknown
CmdsAdmins_11.Text = ";help"
CmdsAdmins_11.TextColor3 = Color3.fromRGB(255, 255, 255)
CmdsAdmins_11.TextSize = 14.000

CmdsAdmins_12.Name = "Cmds/Admins"
CmdsAdmins_12.Parent = Frame
CmdsAdmins_12.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CmdsAdmins_12.BorderColor3 = Color3.fromRGB(0, 0, 0)
CmdsAdmins_12.Position = UDim2.new(0.680648386, 0, 0.599957287, 0)
CmdsAdmins_12.Size = UDim2.new(0, 185, 0, 34)
CmdsAdmins_12.Style = Enum.ButtonStyle.RobloxButtonDefault
CmdsAdmins_12.Font = Enum.Font.Unknown
CmdsAdmins_12.Text = ";god"
CmdsAdmins_12.TextColor3 = Color3.fromRGB(255, 255, 255)
CmdsAdmins_12.TextSize = 14.000

CmdsAdmins_13.Name = "Cmds/Admins"
CmdsAdmins_13.Parent = Frame
CmdsAdmins_13.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CmdsAdmins_13.BorderColor3 = Color3.fromRGB(0, 0, 0)
CmdsAdmins_13.Position = UDim2.new(-0.00892511941, 0, 0.757663429, 0)
CmdsAdmins_13.Size = UDim2.new(0, 185, 0, 34)
CmdsAdmins_13.Style = Enum.ButtonStyle.RobloxButtonDefault
CmdsAdmins_13.Font = Enum.Font.Unknown
CmdsAdmins_13.Text = ";Discord"
CmdsAdmins_13.TextColor3 = Color3.fromRGB(255, 255, 255)
CmdsAdmins_13.TextSize = 14.000

CmdsAdmins_14.Name = "Cmds/Admins"
CmdsAdmins_14.Parent = Frame
CmdsAdmins_14.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CmdsAdmins_14.BorderColor3 = Color3.fromRGB(0, 0, 0)
CmdsAdmins_14.Position = UDim2.new(0.443681568, 0, 0.438666999, 0)
CmdsAdmins_14.Size = UDim2.new(0, 185, 0, 34)
CmdsAdmins_14.Style = Enum.ButtonStyle.RobloxButtonDefault
CmdsAdmins_14.Font = Enum.Font.Unknown
CmdsAdmins_14.Text = ";Neptune"
CmdsAdmins_14.TextColor3 = Color3.fromRGB(255, 255, 255)
CmdsAdmins_14.TextSize = 14.000

CmdsAdmins_15.Name = "Cmds/Admins"
CmdsAdmins_15.Parent = Frame
CmdsAdmins_15.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CmdsAdmins_15.BorderColor3 = Color3.fromRGB(0, 0, 0)
CmdsAdmins_15.Position = UDim2.new(0.680648386, 0, 0.750495017, 0)
CmdsAdmins_15.Size = UDim2.new(0, 185, 0, 34)
CmdsAdmins_15.Style = Enum.ButtonStyle.RobloxButtonDefault
CmdsAdmins_15.Font = Enum.Font.Unknown
CmdsAdmins_15.Text = ";rj"
CmdsAdmins_15.TextColor3 = Color3.fromRGB(255, 255, 255)
CmdsAdmins_15.TextSize = 14.000

CmdsAdmins_16.Name = "Cmds/Admins"
CmdsAdmins_16.Parent = Frame
CmdsAdmins_16.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CmdsAdmins_16.BorderColor3 = Color3.fromRGB(0, 0, 0)
CmdsAdmins_16.Position = UDim2.new(-0.0112947412, 0, 0.897448301, 0)
CmdsAdmins_16.Size = UDim2.new(0, 185, 0, 34)
CmdsAdmins_16.Style = Enum.ButtonStyle.RobloxButtonDefault
CmdsAdmins_16.Font = Enum.Font.Unknown
CmdsAdmins_16.Text = "No Commands"
CmdsAdmins_16.TextColor3 = Color3.fromRGB(255, 255, 255)
CmdsAdmins_16.TextSize = 14.000

CmdsAdmins_17.Name = "Cmds/Admins"
CmdsAdmins_17.Parent = Frame
CmdsAdmins_17.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CmdsAdmins_17.BorderColor3 = Color3.fromRGB(0, 0, 0)
CmdsAdmins_17.Position = UDim2.new(0.211454093, 0, 0.352645457, 0)
CmdsAdmins_17.Size = UDim2.new(0, 185, 0, 34)
CmdsAdmins_17.Style = Enum.ButtonStyle.RobloxButtonDefault
CmdsAdmins_17.Font = Enum.Font.Unknown
CmdsAdmins_17.Text = ";utg"
CmdsAdmins_17.TextColor3 = Color3.fromRGB(255, 255, 255)
CmdsAdmins_17.TextSize = 14.000

CmdsAdmins_18.Name = "Cmds/Admins"
CmdsAdmins_18.Parent = Frame
CmdsAdmins_18.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CmdsAdmins_18.BorderColor3 = Color3.fromRGB(0, 0, 0)
CmdsAdmins_18.Position = UDim2.new(-0.00892507192, 0, 0.621462762, 0)
CmdsAdmins_18.Size = UDim2.new(0, 185, 0, 34)
CmdsAdmins_18.Style = Enum.ButtonStyle.RobloxButtonDefault
CmdsAdmins_18.Font = Enum.Font.Unknown
CmdsAdmins_18.Text = ";kill all"
CmdsAdmins_18.TextColor3 = Color3.fromRGB(255, 255, 255)
CmdsAdmins_18.TextSize = 14.000

CmdsAdmins_19.Name = "Cmds/Admins"
CmdsAdmins_19.Parent = Frame
CmdsAdmins_19.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CmdsAdmins_19.BorderColor3 = Color3.fromRGB(0, 0, 0)
CmdsAdmins_19.Position = UDim2.new(0.680648386, 0, 0.901032507, 0)
CmdsAdmins_19.Size = UDim2.new(0, 185, 0, 34)
CmdsAdmins_19.Style = Enum.ButtonStyle.RobloxButtonDefault
CmdsAdmins_19.Font = Enum.Font.Unknown
CmdsAdmins_19.Text = ";god giver"
CmdsAdmins_19.TextColor3 = Color3.fromRGB(255, 255, 255)
CmdsAdmins_19.TextSize = 14.000

CmdsAdmins_20.Name = "Cmds/Admins"
CmdsAdmins_20.Parent = Frame
CmdsAdmins_20.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CmdsAdmins_20.BorderColor3 = Color3.fromRGB(0, 0, 0)
CmdsAdmins_20.Position = UDim2.new(0.680648386, 0, 0.456588149, 0)
CmdsAdmins_20.Size = UDim2.new(0, 185, 0, 34)
CmdsAdmins_20.Style = Enum.ButtonStyle.RobloxButtonDefault
CmdsAdmins_20.Font = Enum.Font.Unknown
CmdsAdmins_20.Text = ";gui"
CmdsAdmins_20.TextColor3 = Color3.fromRGB(255, 255, 255)
CmdsAdmins_20.TextSize = 14.000

CmdsAdmins_21.Name = "Cmds/Admins"
CmdsAdmins_21.Parent = Frame
CmdsAdmins_21.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CmdsAdmins_21.BorderColor3 = Color3.fromRGB(0, 0, 0)
CmdsAdmins_21.Position = UDim2.new(0.442496777, 0, 0.743326545, 0)
CmdsAdmins_21.Size = UDim2.new(0, 185, 0, 34)
CmdsAdmins_21.Style = Enum.ButtonStyle.RobloxButtonDefault
CmdsAdmins_21.Font = Enum.Font.Unknown
CmdsAdmins_21.Text = ";speed me 100"
CmdsAdmins_21.TextColor3 = Color3.fromRGB(255, 255, 255)
CmdsAdmins_21.TextSize = 14.000

CmdsAdmins_22.Name = "Cmds/Admins"
CmdsAdmins_22.Parent = Frame
CmdsAdmins_22.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CmdsAdmins_22.BorderColor3 = Color3.fromRGB(0, 0, 0)
CmdsAdmins_22.Position = UDim2.new(0.679463625, 0, 0.148344398, 0)
CmdsAdmins_22.Size = UDim2.new(0, 185, 0, 34)
CmdsAdmins_22.Style = Enum.ButtonStyle.RobloxButtonDefault
CmdsAdmins_22.Font = Enum.Font.Unknown
CmdsAdmins_22.Text = ";farm"
CmdsAdmins_22.TextColor3 = Color3.fromRGB(255, 255, 255)
CmdsAdmins_22.TextSize = 14.000

CmdsAdmins_23.Name = "Cmds/Admins"
CmdsAdmins_23.Parent = Frame
CmdsAdmins_23.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CmdsAdmins_23.BorderColor3 = Color3.fromRGB(0, 0, 0)
CmdsAdmins_23.Position = UDim2.new(0.213823736, 0, 0.625046968, 0)
CmdsAdmins_23.Size = UDim2.new(0, 185, 0, 34)
CmdsAdmins_23.Style = Enum.ButtonStyle.RobloxButtonDefault
CmdsAdmins_23.Font = Enum.Font.Unknown
CmdsAdmins_23.Text = ";crasher"
CmdsAdmins_23.TextColor3 = Color3.fromRGB(255, 255, 255)
CmdsAdmins_23.TextSize = 14.000

-- Scripts:

local function HSSFAQ_fake_script() -- Close.LocalScript 
	local script = Instance.new('LocalScript', Close)

	script.Parent.MouseButton1Click:Connect(function()
		script.Parent.Parent.Visible = false
	end)
end
coroutine.wrap(HSSFAQ_fake_script)()
