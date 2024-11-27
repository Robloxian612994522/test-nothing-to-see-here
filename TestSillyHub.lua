local Repository = "https://raw.githubusercontent.com/RectangularObject/LinoriaLib/main/"


-- Services
local VU = game:GetService("VirtualUser")
local UIS = game:GetService("UserInputService")
local Pathfinding = game:GetService("PathfindingService")

-- Variable
local HardModeActive = false
local AUS = false
local AntiGiggleVar = false
local AutoReviveVar = false

-- Library
local Library = loadstring(game:HttpGet(Repository .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(Repository .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(Repository .. "addons/SaveManager.lua"))()
local TweenService = game:GetService("TweenService")

game.Workspace:FindFirstChild(game.Players.LocalPlayer.Character):SetAttribute("Hiding", false)

-- Functions

local function JeffControl(TheJeff)
    TheJeff.HumanoidRootPart.Touched:Connect(function(Part)
        if Part.Parent.Name == game.Players.LocalPlayer.Character.Name then
            game.Players.LocalPlayer.Character.Humanoid:TakeDamage(30)
        end
    end)
end

local function JeffWalk(JeffThing)
    while true do
        wait(0.1)
        local path = Pathfinding:CreatePath()
    
        -- Calculate the destination (player's current position)
        path:ComputeAsync(JeffThing.HumanoidRootPart.Position, game.Players.LocalPlayer.Character.HumanoidRootPart.Position)
        
        -- Move the NPC along the path
        local waypoint = path:GetWaypoints()
    
        for _,v in pairs(waypoint) do
            JeffThing.Zombie:MoveTo(v.Position)
        end
        
    end
end

local function Jeff()
    local Jeff = game:GetObjects("rbxassetid://12981508700")[1]

    Jeff.Parent = game.Workspace
    Jeff.HumanoidRootPart.CFrame = CFrame.new(game.Workspace.CurrentRooms:FindFirstChild(tostring(game.ReplicatedStorage.GameData.LatestRoom.Value)).Door.Collision.Position)
    JeffControl(Jeff)
    JeffWalk(Jeff)
end

local function JeffSpawn()
    while true do
        wait(60)
        Jeff()
    end
end

local function FullBright()
    while true do
        wait(0.4)
        TweenService:Create(game.Lighting, TweenInfo.new(0.03, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false), {Ambient = Color3.new(1,1,1)}):Play()
        TweenService:Create(game.Lighting, TweenInfo.new(0.03, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false), {ColorShift_Bottom = Color3.new(1,1,1)}):Play()
        TweenService:Create(game.Lighting, TweenInfo.new(0.03, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false), {ColorShift_Top = Color3.new(1,1,1)}):Play()
        game.Lighting.Ambient = Color3.new(1,1,1)
        game.Lighting.ColorShift_Bottom = Color3.new(1,1,1)
        game.Lighting.ColorShift_Top = Color3.new(1,1,1)
    end
end

local function Speed(SpeedInput)
    game.Players.LocalPlayer.Character:SetAttribute("SpeedBoost", SpeedInput)
end

local function PlayAgain()
    game.ReplicatedStorage.RemotesFolder.PlayAgain:FireServer()
end

local function Lobby()
    game.ReplicatedStorage.RemotesFolder.Lobby:FireServer()
end

local function SpeedBypass()
    local CloneCollision = game.Players.LocalPlayer.Character:FindFirstChild("Collision"):Clone()
    CloneCollision.Parent = game.Players.LocalPlayer.Character
end

local function Gamble()
    if math.random(1,2) == 1 then
        Library:Notify("you lose now your health is set to 1 better heal up if you have bandages", 4.5)
        game.Players.LocalPlayer.Character.Humanoid.Health = 1
    else
        Library:Notify("you win! now youll get a super prize which is a useless crucifix!", 4.5)
        local Tool = game:GetObjects("rbxassetid://13872336829")[1]
         
        Tool.Parent = game.Players.LocalPlayer.Backpack
    end
end

local function AntiLag()
    for _,v in pairs(game:GetDescendants()) do
        wait(0.1)
        if v.ClassName == "Decal" or v.ClassName == "Texture" then
            v.Transparency = 1
        elseif v.ClassName == "ImageLabel" then
            v.ImageTransparency = 1
        elseif v.ClassName == "Part" then
            v.Material = Enum.Material.SmoothPlastic
        end
    end
end

-- Main Code
Library:Notify("Silly Hub is Loading... ", 4.5)
local LocalPlayer = game.Players.LocalPlayer

local ClonedCollision = LocalPlayer.Character.Collision:Clone()
ClonedCollision.Name = "_CollisionClone"
ClonedCollision.Massless = true
ClonedCollision.Parent = LocalPlayer.Character
ClonedCollision.CanCollide = false
ClonedCollision.CanQuery = false
ClonedCollision.CustomPhysicalProperties = PhysicalProperties.new(0.01, 0.7, 0, 1, 1)
if ClonedCollision:FindFirstChild("CollisionCrouch") then
    ClonedCollision.CollisionCrouch:Destroy()
end

-- UI vvv
game.Workspace:FindFirstChild(game.Players.LocalPlayer.Name):SetAttribute("CanJump", false)

local Window = Library:CreateWindow({ Title = " Silly Hub ┃ ".. LocalPlayer.Name, Center = true, AutoShow = true, TabPadding = 3, MenuFadeTime = 0.15 })
local Tabs = { General = Window:AddTab("General"), Exploit = Window:AddTab("Exploits"), ESP = Window:AddTab("ESP"), Visuals = Window:AddTab("Visuals"), Floor = Window:AddTab("Floor"), Modes = Window:AddTab("Modes"), Config = Window:AddTab("Config") }

local GeneralLeft = Tabs.General:AddLeftGroupbox("Dead Screen")
GeneralLeft:AddButton("Revive", function()
    game.ReplicatedStorage.RemotesFolder.Revive:FireServer()
end)

GeneralLeft:AddButton("Lobby", function()
    game.ReplicatedStorage.RemotesFolder.Lobby:FireServer()
end)

GeneralLeft:AddButton("Play Again", function()
    PlayAgain()
end)

local GeneralLeft2 = Tabs.General:AddLeftGroupbox("Miscellaneous")
GeneralLeft2:AddButton("Gamble (Risky)", function()
    Gamble()
end)

GeneralLeft2:AddButton("Remove Jumpscare", function()
    game.ReplicatedStorage.EntityInfo.Jumpscare:Destroy()
    game.ReplicatedStorage.EntityInfo.SpiderJumpscare:Destroy()
    game.ReplicatedStorage.RemotesFolder.Jumpscare:Destroy()
    game.ReplicatedStorage.RemotesFolder.SpiderJumpscare:Destroy()
end)


local GeneralLeft3 = Tabs.General:AddLeftGroupbox("Tools")
GeneralLeft3:AddButton("Shears", function()
    local Tool = game:GetObjects("rbxassetid://12685165702")[1]
         local Humanoid = game.Players.LocalPlayer.Character.Humanoid
         local Sound = Instance.new("Sound")
         
         Tool.Parent = game.Players.LocalPlayer.Backpack
         
         Sound.PlaybackSpeed = 1.25
         Sound.SoundId = "rbxassetid://9118823101"
         Sound.Parent = Tool
         
         Tool.Activated:Connect(function()
             local Use = Tool.Animations.use
             local UseTrack = Humanoid:LoadAnimation(Use)
         
             UseTrack:Play()
             Sound:Play()
             wait(0.25)
             Sound:Play()
             game:GetService("Players").LocalPlayer:GetMouse().Target:FindFirstAncestorOfClass("Model"):Destroy()
         end)
         
         Tool.Equipped:Connect(function()
             local Idle = Tool.Animations.idle
             local IdleTrack = Humanoid:LoadAnimation(Idle)
         
             IdleTrack:Play()
         end)
end)


local ExploitSelf = Tabs.Exploit:AddLeftGroupbox("Self")
ExploitSelf:AddToggle("Enable Jump", {
	Text = "Enable Jumping",
	Default = false, 
	Tooltip = "can make you access floor 2's jumping system",

	Callback = function(Value)
		game.Workspace:FindFirstChild(game.Players.LocalPlayer.Name):SetAttribute("CanJump", Value)
	end,
})

ExploitSelf:AddSlider("Speed", {
	Text = "Speed",
	Default = 0,
	Min = 1,
	Max = 6,
	Rounding = 1,
	Compact = false,

	Callback = function(Value)
        game.Workspace:FindFirstChild(game.Players.LocalPlayer.Name):SetAttribute("SpeedBoost", Value)
    end,
})

local Visualss = Tabs.Visuals:AddLeftGroupbox("Lighting")
Visualss:AddButton("FullBright", function()
    FullBright()
end)

local HardMode = Tabs.Floor:AddLeftGroupbox("Super Hard Mode")

HardMode:AddToggle("AutoRevive", {
	Text = "Auto Revive",
	Default = false, 
	Tooltip = "Revive everytime u die",

	Callback = function(Value)
		AutoReviveVar = Value
	end,
})

local Modes = Tabs.Modes:AddLeftGroupbox("Modes")

Modes:AddButton("Mega Hard Mode", function()
    if AUS == false then
        AUS = true
        Library:Notify("Are you sure you wanna play it cant be undo and must be in door 0 and must be in floor 1", 4.5)
        wait(1)
        Library:Notify("and its harder than Super Hard mode considered a impossible challenge click again if your sure you wanna play", 4.5)
    else
        if HardModeActive == false and game.ReplicatedStorage.GameData.LatestRoom.Value == 0 then
            JeffSpawn()
        end
    end
end)

ThemeManager:SetFolder("SillyHub")
SaveManager:SetFolder("SillyHub/DOORS")

-- Builds our config menu on the right side of our tab
SaveManager:BuildConfigSection(Tabs["UI Settings"])

-- Builds our theme menu (with plenty of built in themes) on the left side
-- NOTE: you can also call ThemeManager:ApplyToGroupbox to add it to a specific groupbox
ThemeManager:ApplyToTab(Tabs["UI Settings"])

-- You can use the SaveManager:LoadAutoloadConfig() to load a config
-- which has been marked to be one that auto loads!
SaveManager:LoadAutoloadConfig()

game.Players.LocalPlayer.Character.Humanoid.Died:Connect(function()
    if AutoReviveVar == true then
        game.ReplicatedStorage.EntityInfo.Revive:FireServer()
    end
end)

Library:Notify("Successfully loaded also hi alex :D", 4.5)
