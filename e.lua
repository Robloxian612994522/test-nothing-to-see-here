local Pathfind = game:GetService("PathfindingService")
local Input = game:GetService("VirtualUser")
local camera = game.Workspace.CurrentCamera

local startRoom = Vector3.new(256.24, -0.50, -50.02)

local startroom2 = Vector3.new(233.62 -0.47 -47.87)

local RoomBlacklist = {50, 100}

local CurrentRoom = game.ReplicatedStorage.GameData.LatestRoom

local getpaths = {}

wait(1)
if CurrentRoom.Value == 0 then
    table.insert(getpaths, CurrentRoom + 1, game.Workspace.CurrentRooms[CurrentRoom.Value].PathfindNodes)
    game.Players.LocalPlayer.Character.Humanoid.WalkToPoint = startRoom
    wait(2)
    game.Players.LocalPlayer.Character.Humanoid.Jump = true
    game.Players.LocalPlayer.Character.Humanoid.WalkToPoint = startroom2
    wait(2)
    game.Players.LocalPlayer.Character.Humanoid.Jump = true
    Input:SetKeyDown(Enum.KeyCode.E.Name)
    wait(2)
    Input:SetKeyUp(Enum.KeyCode.E.Name)
    game.Players.LocalPlayer.Character.Humanoid.Jump = true
    game.Players.LocalPlayer.Character.Humanoid.WalkToPoint = startRoom
    wait(3.5)
    game.Players.LocalPlayer.Character.Humanoid.Jump = true
    game.Players.LocalPlayer.Character.Humanoid.WalkToPoint = game.Workspace.CurrentRooms[CurrentRoom.Value].Door.Collision.Position
    Input:SetKeyDown(Enum.KeyCode.E.Name)
    wait(4)
    Input:SetKeyUp(Enum.KeyCode.E.Name)
end

game.Workspace.CurrentRooms.ChildAdded:Connect(function()
    if CurrentRoom.Value ~= 0 and CurrentRoom.Value ~= RoomBlacklist[1] and CurrentRoom.Value ~= RoomBlacklist[2] then
        local Folder = table.getn(getpaths[CurrentRoom.Value + 1])
        for _, v in pairs(Folder:GetChildren()) do
            game.Players.LocalPlayer.Character.Humanoid.WalkToPoint = v.Position
        end
    end
end)
