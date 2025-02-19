local Noclipif = false

local Repository = "https://raw.githubusercontent.com/RectangularObject/LinoriaLib/main/"

local Library = loadstring(game:HttpGet(Repository .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(Repository .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(Repository .. "addons/SaveManager.lua"))()

Library:Notify("Silly Hub is Loading... ", 4.5)

local Player = game.Players.LocalPlayer

local Window = Library:CreateWindow({ Title = " Silly Hub ┃ Dandy World", Center = true, AutoShow = true, TabPadding = 3, MenuFadeTime = 0.15 })
local Tabs = { General = Window:AddTab("General"), Exploit = Window:AddTab("Exploits"), misc = Window:AddTab("Misc"), Config = Window:AddTab("Config") }

Library:Notify("Welcome to Silly Hub ", 4.5)

local GeneralLeft = Tabs.General:AddLeftGroupbox("Basics")
GeneralLeft:AddButton("Speed", function()
    Player.Character.Humanoid.WalkSpeed = 30
end)

GeneralLeft:AddToggle("Noclip", {
	Text = "Noclip",
	Default = false, 
	Tooltip = "Noclip throught walls and box and other stuffs",

	Callback = function(Value)
		Noclipif = Value
        if Value == true then
            for _,v in pairs(game.Workspace.CurrrentRoom:GetChildren()) do
                for _,e in pairs(v.Walls:GetDescendants()) do
                    e.CanCollide = false
                end

                for _,e in pairs(v.walls:GetDescendants()) do
                    e.CanCollide = false
                end
            end
        end
	end,
})

game.Workspace.CurrentRoom.ChildAdded:Connect(function(v)
    if Noclipif == true then
        for _,e in pairs(v.Walls:GetDescendants()) do
            if e.Parent == "Wall" then
                e.CanCollide = false
            end
        end

        for _,c in pairs(v.FreeArea:GetDescendants()) do
        c.CanCollide = false
        end
    end
end)

