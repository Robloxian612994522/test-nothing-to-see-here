--[[ 

        __  __  _____ _      _ _                          
        |  \/  |/ ____| |    (_) |                         
        | \  / | (___ | |     _| |__  _ __ __ _ _ __ _   _ 
        | |\/| |\___ \| |    | | '_ \| '__/ _` | '__| | | |
        | |  | |____) | |____| | |_) | | | (_| | |  | |_| |
        |_|  |_|_____/|______|_|_.__/|_|  \__,_|_|   \__, |
                                                    __/ |
                                                    |___/ 
                        Mobile UI Library 
    MSHUB Discord Server: discord.gg/mshub

    Made by mstudio45
    Thanks for using the library!
--]]

-- Services
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Mouse = Players.LocalPlayer:GetMouse()

-- Variables
local Viewport = workspace.CurrentCamera.ViewportSize

-- Library
local Library = {
    MainScreenGui = nil,
	MainScreenGuiFrame = nil,
    UnLoadCallback = function() end, -- can be set 
    Functions = {}
}

-- Functions
function Library.Functions.Validate(Values, options)
	for i,v in pairs(Values) do
		if options[i] == nil then
			options[i] = v
		end
	end

	return options
end

function Library.Functions.has_property(instance, property)
	local clone = instance:Clone()
	clone:ClearAllChildren()

	return (pcall(function()
		return clone[property]
	end))
end
function Library.Functions.from_hex(hex)
	if typeof(hex) == "string" then
		local r, g, b = string.match(hex, "^#?(%w%w)(%w%w)(%w%w)$")
		return Color3.fromRGB(tonumber(r, 16),
			tonumber(g, 16), tonumber(b, 16))
	else
		return hex
	end
end
function Library.Functions.to_hex(color)
	if typeof(color) == "Color3" then
		return string.format("#%02X%02X%02X", color.R * 0xFF,
			color.G * 0xFF, color.B * 0xFF)
	else
		return color
	end
end

function Library.Functions.Tween(object, goal, Callback, tweeninfo)
	local tween = TweenService:Create(object, tweeninfo or TweenInfo.new(.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), goal)
	tween.Completed:Connect(Callback or function() end)
	tween:Play()
end
function Library.Functions.ResizeScrollingFrame(ScrollingFrame, UiListUiGrid, offset)
	ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UiListUiGrid.AbsoluteContentSize.Y + offset or 10) 
end
function Library.Functions.getAbsoluteSize(frame)
	local totalSize = Vector2.new()

	for _, Child in pairs(frame:GetChildren()) do
		if Child:IsA("GuiBase2d") then
			totalSize = totalSize + Child.AbsoluteSize
		end
	end

	return totalSize
end

function Library.Functions.RandomString()
    local length = math.random(10,20)
    local array = {}
    for i = 1, length do 
        array[i] = string.char(math.random(32, 126)) 
    end
    return table.concat(array)
end

function Library.Functions.removeSpaces(str)
	if str then
		local newStr = str:gsub(" ", "")
		return newStr
	end
end

function Library:CreateWindow(options)
	options = Library.Functions.Validate({
		Name = "MSLibrary",
		Themeable = false
	}, options or {})

    local GUI = {
		CurrentTab = nil,
		CanDrag = false,
		Minimized = false,
        Closing = false,
		TotalTabs = 1,
        OriginalFrameSize = UDim2.new(0, 500, 0, 300),
	}

    -- Main Frame
    do
        -- StarterGui.Lib
        GUI["1"] = Instance.new("ScreenGui");
        GUI["1"]["ZIndexBehavior"] = Enum.ZIndexBehavior.Sibling;
        GUI["1"]["Name"] = Library.Functions.RandomString()
		if get_hidden_gui or gethui then
			local HIDEUI = get_hidden_gui or gethui
			GUI["1"]["Parent"] = HIDEUI()
		elseif (not is_sirhurt_closure) and (syn and syn.protect_gui) then
			syn.protect_gui(GUI["1"])
			GUI["1"]["Parent"] = game:GetService("CoreGui")
		elseif game:GetService("CoreGui"):FindFirstChild('RobloxGui') then
			GUI["1"]["Parent"] = game:GetService("CoreGui").RobloxGui
		else
			GUI["1"]["Parent"] = game:GetService("CoreGui")
		end
        Library.MainScreenGui = GUI["1"]

        -- StarterGui.Lib.main
        GUI["2"] = Instance.new("Frame", GUI["1"]);
        GUI["2"]["ZIndex"] = 1000000000;
        GUI["2"]["BorderSizePixel"] = 0;
        GUI["2"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
        GUI["2"]["BackgroundTransparency"] = 1;
        GUI["2"]["Size"] = UDim2.new(0, 500, 0, 300);
        GUI["2"]["BorderColor3"] = Color3.fromRGB(255, 255, 255);
        GUI["2"]["Position"] = UDim2.new(0, 432, 0, 280);
        GUI["2"]["Name"] = [[main]];
        Library.MainScreenGuiFrame = GUI["2"]
        GUI.OriginalFrameSize = GUI["2"]["Size"]

        -- StarterGui.Lib.main.TopBar
        GUI["3"] = Instance.new("Frame", GUI["2"]);
        GUI["3"]["ZIndex"] = 5000;
        GUI["3"]["BorderSizePixel"] = 0;
        GUI["3"]["BackgroundColor3"] = Color3.fromRGB(66, 66, 66);
        GUI["3"]["Size"] = UDim2.new(0, 500, 0, 30);
        GUI["3"]["BorderColor3"] = Color3.fromRGB(255, 255, 255);
        GUI["3"]["Name"] = [[TopBar]];

        -- StarterGui.Lib.main.TopBar.UICorner
        GUI["4"] = Instance.new("UICorner", GUI["3"]);
        GUI["4"]["CornerRadius"] = UDim.new(0, 6);

        -- StarterGui.Lib.main.TopBar.Title
        GUI["5"] = Instance.new("TextLabel", GUI["3"]);
        GUI["5"]["TextWrapped"] = true;
        GUI["5"]["ZIndex"] = 50001;
        GUI["5"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
        GUI["5"]["TextXAlignment"] = Enum.TextXAlignment.Left;
        GUI["5"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
        GUI["5"]["TextSize"] = 24;
        GUI["5"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
        GUI["5"]["Size"] = UDim2.new(0, 200, 0, 30);
        GUI["5"]["Text"] = options["Name"];
        GUI["5"]["Name"] = [[Title]];
        GUI["5"]["BackgroundTransparency"] = 1;

        -- StarterGui.Lib.main.TopBar.Title.UIPadding
        GUI["6"] = Instance.new("UIPadding", GUI["5"]);
        GUI["6"]["PaddingLeft"] = UDim.new(0, 5);

        -- StarterGui.Lib.main.TopBar.ExitBtn
        GUI["7"] = Instance.new("ImageButton", GUI["3"]);
        GUI["7"]["ZIndex"] = 2;
        GUI["7"]["BorderSizePixel"] = 0;
        GUI["7"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
        GUI["7"]["AnchorPoint"] = Vector2.new(1, 0.5);
        GUI["7"]["Image"] = [[rbxassetid://3926305904]];
        GUI["7"]["ImageRectSize"] = Vector2.new(24, 24);
        GUI["7"]["Size"] = UDim2.new(0, 22, 0, 22);
        GUI["7"]["Name"] = [[ExitBtn]];
        GUI["7"]["ImageRectOffset"] = Vector2.new(284, 4);
        GUI["7"]["Position"] = UDim2.new(0, 496, 0, 15);
        GUI["7"]["BackgroundTransparency"] = 1;

        -- StarterGui.Lib.main.TopBar.Minimize
        GUI["8"] = Instance.new("ImageButton", GUI["3"]);
        GUI["8"]["ZIndex"] = 2;
        GUI["8"]["BorderSizePixel"] = 0;
        GUI["8"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
        GUI["8"]["AnchorPoint"] = Vector2.new(1, 0.5);
        GUI["8"]["Image"] = [[rbxassetid://6764432408]];
        GUI["8"]["ImageRectSize"] = Vector2.new(50, 50);
        GUI["8"]["Size"] = UDim2.new(0, 22, 0, 22);
        GUI["8"]["Name"] = [[Minimize]];
        GUI["8"]["ImageRectOffset"] = Vector2.new(50, 550);
        GUI["8"]["Position"] = UDim2.new(0, 470, 0, 15);
        GUI["8"]["BackgroundTransparency"] = 1;

        -- StarterGui.Lib.main.TopBar.Line
        GUI["9"] = Instance.new("Frame", GUI["3"]);
        GUI["9"]["ZIndex"] = 2;
        GUI["9"]["BorderSizePixel"] = 0;
        GUI["9"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
        GUI["9"]["AnchorPoint"] = Vector2.new(0, 1);
        GUI["9"]["Size"] = UDim2.new(0, 500, 0, 1);
        GUI["9"]["Position"] = UDim2.new(0, 0, 0, 30);
        GUI["9"]["Name"] = [[Line]];

        -- StarterGui.Lib.main.TopBar.UIGradient
        GUI["a"] = Instance.new("UIGradient", GUI["3"]);
        GUI["a"]["Rotation"] = 90;
        GUI["a"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(221, 221, 221)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(255, 255, 255))};

        -- StarterGui.Lib.main.TopBar.Corner
        GUI["b"] = Instance.new("Frame", GUI["3"]);
        GUI["b"]["ZIndex"] = 5000;
        GUI["b"]["BorderSizePixel"] = 0;
        GUI["b"]["BackgroundColor3"] = Color3.fromRGB(66, 66, 66);
        GUI["b"]["Size"] = UDim2.new(0, 8, 0, 9);
        GUI["b"]["BorderColor3"] = Color3.fromRGB(255, 255, 255);
        GUI["b"]["Position"] = UDim2.new(0, 491, 0, 19);
        GUI["b"]["Name"] = [[Corner]];

        -- StarterGui.Lib.main.TopBar.Corner
        GUI["c"] = Instance.new("Frame", GUI["3"]);
        GUI["c"]["ZIndex"] = 5000;
        GUI["c"]["BorderSizePixel"] = 0;
        GUI["c"]["BackgroundColor3"] = Color3.fromRGB(66, 66, 66);
        GUI["c"]["Size"] = UDim2.new(0, 8, 0, 9);
        GUI["c"]["BorderColor3"] = Color3.fromRGB(255, 255, 255);
        GUI["c"]["Position"] = UDim2.new(0, 0, 0, 19);
        GUI["c"]["Name"] = [[Corner]];

        -- StarterGui.Lib.main.DropShadowHolder
        GUI["16"] = Instance.new("Frame", GUI["2"]);
        GUI["16"]["ZIndex"] = -2;
        GUI["16"]["BorderSizePixel"] = 0;
        GUI["16"]["BackgroundTransparency"] = 1;
        GUI["16"]["Size"] = UDim2.new(0, 500, 0, 300);
        GUI["16"]["Name"] = [[DropShadowHolder]];

        -- StarterGui.Lib.main.DropShadowHolder.DropShadow
        GUI["17"] = Instance.new("ImageLabel", GUI["16"]);
        GUI["17"]["ZIndex"] = 0;
        GUI["17"]["BorderSizePixel"] = 0;
        GUI["17"]["SliceCenter"] = Rect.new(49, 49, 450, 450);
        GUI["17"]["ScaleType"] = Enum.ScaleType.Slice;
        GUI["17"]["ImageColor3"] = Color3.fromRGB(0, 0, 0);
        GUI["17"]["ImageTransparency"] = 0.5;
        GUI["17"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
        GUI["17"]["Image"] = [[rbxassetid://6014261993]];
        GUI["17"]["Size"] = UDim2.new(0, 547, 0, 347);
        GUI["17"]["Name"] = [[DropShadow]];
        GUI["17"]["BackgroundTransparency"] = 1;
        GUI["17"]["Position"] = UDim2.new(0, 250, 0, 150);

        -- StarterGui.Lib.main.Content
        GUI["18"] = Instance.new("Frame", GUI["2"]);
        GUI["18"]["BorderSizePixel"] = 0;
        GUI["18"]["BackgroundColor3"] = Color3.fromRGB(54, 54, 54);
        GUI["18"]["Size"] = UDim2.new(0, 500, 0, 208);
        GUI["18"]["BorderColor3"] = Color3.fromRGB(255, 255, 255);
        GUI["18"]["Position"] = UDim2.new(0, 0, 0, 92);
        GUI["18"]["Name"] = [[Content]];

        -- StarterGui.Lib.main.Content.UICorner
        GUI["19"] = Instance.new("UICorner", GUI["18"]);
        GUI["19"]["CornerRadius"] = UDim.new(0, 6);

        -- StarterGui.Lib.main.Content.Corners
        GUI["1a"] = Instance.new("Frame", GUI["18"]);
        GUI["1a"]["BorderSizePixel"] = 0;
        GUI["1a"]["BackgroundColor3"] = Color3.fromRGB(54, 54, 54);
        GUI["1a"]["Size"] = UDim2.new(0, 500, 0, 17);
        GUI["1a"]["Name"] = [[Corners]];
    end

    -- Navigation
    do
        -- StarterGui.Lib.main.Navigation
        GUI["d"] = Instance.new("Frame", GUI["2"]);
        GUI["d"]["BorderSizePixel"] = 0;
        GUI["d"]["BackgroundColor3"] = Color3.fromRGB(54, 54, 54);
        GUI["d"]["Size"] = UDim2.new(0, 500, 0, 62);
        GUI["d"]["BorderColor3"] = Color3.fromRGB(255, 255, 255);
        GUI["d"]["Position"] = UDim2.new(0, 0, 0, 30);
        GUI["d"]["Name"] = [[Navigation]];

        -- StarterGui.Lib.main.Navigation.ButtonHolder
        GUI["e"] = Instance.new("ScrollingFrame", GUI["d"]);
        GUI["e"]["Active"] = true;
        GUI["e"]["ScrollingDirection"] = Enum.ScrollingDirection.X;
        GUI["e"]["BorderSizePixel"] = 0;
        GUI["e"]["CanvasSize"] = UDim2.new(0, 0, 0, 0);
        GUI["e"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
        GUI["e"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
        GUI["e"]["AutomaticCanvasSize"] = Enum.AutomaticSize.XY;
        GUI["e"]["BackgroundTransparency"] = 1;
        GUI["e"]["Size"] = UDim2.new(0, 500, 0, 40);
        GUI["e"]["ScrollBarImageColor3"] = Color3.fromRGB(0, 0, 0);
        GUI["e"]["BorderColor3"] = Color3.fromRGB(255, 255, 255);
        GUI["e"]["ScrollBarThickness"] = 0;
        GUI["e"]["Position"] = UDim2.new(0, 250, 0, 31);
        GUI["e"]["Name"] = [[ButtonHolder]];

        -- StarterGui.Lib.main.Navigation.ButtonHolder.UIListLayout
        GUI["f"] = Instance.new("UIListLayout", GUI["e"]);
        GUI["f"]["VerticalAlignment"] = Enum.VerticalAlignment.Center;
        GUI["f"]["FillDirection"] = Enum.FillDirection.Horizontal;
        GUI["f"]["Padding"] = UDim.new(0, 7);
        GUI["f"]["SortOrder"] = Enum.SortOrder.LayoutOrder;

        -- StarterGui.Lib.main.Navigation.ButtonHolder.UIPadding
        GUI["10"] = Instance.new("UIPadding", GUI["e"]);
        GUI["10"]["PaddingTop"] = UDim.new(0, 2);
        GUI["10"]["PaddingBottom"] = UDim.new(0, 2);
        GUI["10"]["PaddingLeft"] = UDim.new(0, 10);
    end

    -- Main Frame Logic
    do
        task.spawn(function()
			local gui = Library.MainScreenGuiFrame
			local dragging
			local dragInput
			local dragStart
			local startPos
			local function update(input)
				local delta = input.Position - dragStart
				pcall(function()
					gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)-- gui:TweenPosition(UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y), 'Out', 'Linear', 0);
				end)
			end
			gui.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					dragStart = input.Position
					startPos = gui.Position

					input.Changed:Connect(function()
						if input.UserInputState == Enum.UserInputState.End then
							dragging = false
						end
					end)
				end
			end)
			gui.InputChanged:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
					dragInput = input
				end
			end)
			UIS.InputChanged:Connect(function(input)
				if input == dragInput and dragging then
					update(input)
				end
			end)
		end)

        Library.unload = function()
            if GUI.Closing == true then
                return
            end

            GUI.Closing = true
            task.spawn(function()
                task.wait(.265)
                GUI["2"]["Visible"] = false
                GUI["18"]["Visible"] = false
                GUI["d"]["Visible"] = false
            end)

            Library.Functions.Tween(GUI["2"], {Size = GUI.OriginalFrameSize}, function()
                Library.Functions.Tween(GUI["2"], {Size = UDim2.new(GUI.OriginalFrameSize.X.Scale, GUI.OriginalFrameSize.X.Offset, GUI.OriginalFrameSize.Y.Scale, GUI["3"]["Size"].Y.Offset)}, function()
                    Library.Functions.Tween(GUI["2"], {Size = UDim2.new(0, 0, 0, GUI["3"]["Size"].Y.Offset)}, function()
                        if GUI["1"] ~= nil then
                            GUI["1"]:Destroy()
                            GUI["1"] = nil
                        end
        
                        if typeof(Library.UnLoadCallback) == "function" then
                            Library.UnLoadCallback()
                        end
        
                        warn("Unloaded")
                        GUI.Closing = false
                    end, TweenInfo.new(.35, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut))
                end, TweenInfo.new(.35, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut))
            end, TweenInfo.new(.35, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut))
        end
        Library.ToggleUI = function() GUI["2"].Visible = not GUI["2"].Visible end
        Library.ShowUI = function() GUI["2"].Visible = true end
        Library.HideUI = function() GUI["2"].Visible = false end

        Library.MinimizeUI = function()
            if GUI.Minimized == false then
                task.spawn(function()
                    task.wait(.265)
                    GUI["2"]["Visible"] = true
                    GUI["18"]["Visible"] = true
                    GUI["d"]["Visible"] = true
                end)

                Library.Functions.Tween(GUI["2"], {Size = UDim2.new(GUI.OriginalFrameSize.X.Scale, GUI.OriginalFrameSize.X.Offset, GUI.OriginalFrameSize.Y.Scale, GUI.OriginalFrameSize.Y.Offset)}, function()
                    GUI.Minimized = true
                end, TweenInfo.new(.35, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut))
            end
        end
        Library.UnMinimizeUI = function()
            if GUI.Minimized == true then
                task.spawn(function()
                    task.wait(.265)
                    GUI["2"]["Visible"] = false
                    GUI["18"]["Visible"] = false
                    GUI["d"]["Visible"] = false
                end)

                Library.Functions.Tween(GUI["2"], {Size = UDim2.new(GUI.OriginalFrameSize.X.Scale, GUI.OriginalFrameSize.X.Offset, GUI.OriginalFrameSize.Y.Scale, GUI["3"]["Size"].Y.Offset)}, function()
                    GUI.Minimized = false
                end, TweenInfo.new(.35, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut))
            end
        end
        Library.ToggleMinimizeUI = function()
            if GUI.Minimized == true then
                Library.UnMinimizeUI()
            elseif GUI.Minimized == false then
                Library.MinimizeUI()
            end
        end

        -- Exit Button
        do
            GUI["7"].MouseButton1Click:Connect(function()
                Library.unload()
            end)
        end

        -- Minimize
        do
            GUI["8"].MouseButton1Click:Connect(function()
                Library.ToggleMinimizeUI()
            end)
        end
    end

    -- Notifications
	local Notifications = {}
    do
        -- Render
        do
            -- StarterGui.Lib.Notifications
            Notifications["6a"] = Instance.new("Frame", GUI["1"]);
            Notifications["6a"]["ZIndex"] = 0;
            Notifications["6a"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
            Notifications["6a"]["BackgroundTransparency"] = 1;
            Notifications["6a"]["Size"] = UDim2.new(0, 300, 0, 767);
            Notifications["6a"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
            Notifications["6a"]["Position"] = UDim2.new(0, 1047, 0, -11);
            Notifications["6a"]["Name"] = [[Notifications]];

            -- StarterGui.Lib.Notifications.UIListLayout
            Notifications["6b"] = Instance.new("UIListLayout", Notifications["6a"]);
            Notifications["6b"]["VerticalAlignment"] = Enum.VerticalAlignment.Bottom;
            Notifications["6b"]["HorizontalAlignment"] = Enum.HorizontalAlignment.Center;
            Notifications["6b"]["Padding"] = UDim.new(0, 10);
            Notifications["6b"]["SortOrder"] = Enum.SortOrder.LayoutOrder;
        end

        function Notifications:Notify(options)
            options = Library.Functions.Validate({
                Title = "Notification",
                Text = "Text",
                Time = 10
            }, options or {})

            local Notification = {
                Closed = false
            }

            -- Render
            do
                 -- StarterGui.Lib.Notifications.Normal
                Notification["6c"] = Instance.new("Frame", Notifications["6a"]);
                Notification["6c"]["BackgroundColor3"] = Color3.fromRGB(54, 54, 54);
                Notification["6c"]["Size"] = UDim2.new(0, 0, 0, 0);
                Notification["6c"]["Position"] = UDim2.new(0, 0, 0, 511);
                Notification["6c"]["Name"] = [[Normal]];

                -- StarterGui.Lib.Notification.Normal.UICorner
                Notification["6d"] = Instance.new("UICorner", Notification["6c"]);
                Notification["6d"]["CornerRadius"] = UDim.new(0, 6);

                -- StarterGui.Lib.Notification.Normal.UIStroke
                Notification["6e"] = Instance.new("UIStroke", Notification["6c"]);
                Notification["6e"]["Color"] = Color3.fromRGB(255, 255, 255);

                -- StarterGui.Lib.Notification.Normal.TopBar
                Notification["6f"] = Instance.new("Frame", Notification["6c"]);
                Notification["6f"]["ZIndex"] = 5000;
                Notification["6f"]["BorderSizePixel"] = 0;
                Notification["6f"]["BackgroundColor3"] = Color3.fromRGB(66, 66, 66);
                Notification["6f"]["Size"] = UDim2.new(0, 300, 0, 30);
                Notification["6f"]["BorderColor3"] = Color3.fromRGB(255, 255, 255);
                Notification["6f"]["Name"] = [[TopBar]];

                -- StarterGui.Lib.Notification.Normal.TopBar.Title
                Notification["70"] = Instance.new("TextLabel", Notification["6f"]);
                Notification["70"]["TextWrapped"] = true;
                Notification["70"]["ZIndex"] = 50001;
                Notification["70"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
                Notification["70"]["TextXAlignment"] = Enum.TextXAlignment.Left;
                Notification["70"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
                Notification["70"]["TextSize"] = 24;
                Notification["70"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
                Notification["70"]["Size"] = UDim2.new(0, 300, 0, 30);
                Notification["70"]["Text"] = options["Title"];
                Notification["70"]["Name"] = [[Title]];
                Notification["70"]["BackgroundTransparency"] = 1;

                -- StarterGui.Lib.Notification.Normal.TopBar.Title.UIPadding
                Notification["71"] = Instance.new("UIPadding", Notification["70"]);
                Notification["71"]["PaddingLeft"] = UDim.new(0, 5);

                -- StarterGui.Lib.Notification.Normal.TopBar.ExitBtn
                Notification["72"] = Instance.new("ImageButton", Notification["6f"]);
                Notification["72"]["ZIndex"] = 231032109;
                Notification["72"]["BorderSizePixel"] = 0;
                Notification["72"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
                Notification["72"]["AnchorPoint"] = Vector2.new(1, 0.5);
                Notification["72"]["Image"] = [[rbxassetid://3926305904]];
                Notification["72"]["ImageRectSize"] = Vector2.new(24, 24);
                Notification["72"]["Size"] = UDim2.new(0, 22, 0, 22);
                Notification["72"]["Name"] = [[ExitBtn]];
                Notification["72"]["ImageRectOffset"] = Vector2.new(284, 4);
                Notification["72"]["Position"] = UDim2.new(0, 292, 0, 14);
                Notification["72"]["BackgroundTransparency"] = 1;

                -- StarterGui.Lib.Notification.Normal.TopBar.Line
                Notification["73"] = Instance.new("Frame", Notification["6f"]);
                Notification["73"]["ZIndex"] = 2;
                Notification["73"]["BorderSizePixel"] = 0;
                Notification["73"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
                Notification["73"]["AnchorPoint"] = Vector2.new(0, 1);
                Notification["73"]["Size"] = UDim2.new(0, 300, 0, 1);
                Notification["73"]["Position"] = UDim2.new(0, 0, 0, 30);
                Notification["73"]["Name"] = [[Line]];

                -- StarterGui.Lib.Notification.Normal.TopBar.UIGradient
                Notification["74"] = Instance.new("UIGradient", Notification["6f"]);
                Notification["74"]["Rotation"] = 90;
                Notification["74"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(221, 221, 221)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(255, 255, 255))};

                -- StarterGui.Lib.Notification.Normal.TopBar.UICorner
                Notification["75"] = Instance.new("UICorner", Notification["6f"]);
                Notification["75"]["CornerRadius"] = UDim.new(0, 6);

                -- StarterGui.Lib.Notification.Normal.Text
                Notification["76"] = Instance.new("TextLabel", Notification["6c"]);
                Notification["76"]["TextWrapped"] = true;
                Notification["76"]["TextYAlignment"] = Enum.TextYAlignment.Top;
                Notification["76"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
                Notification["76"]["TextXAlignment"] = Enum.TextXAlignment.Left;
                Notification["76"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
                Notification["76"]["TextSize"] = 19;
                Notification["76"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
                Notification["76"]["AutomaticSize"] = Enum.AutomaticSize.Y;
                Notification["76"]["Size"] = UDim2.new(0, 280, 0, 79);
                Notification["76"]["Name"] = options["Text"];
                Notification["76"]["BackgroundTransparency"] = 1;
                Notification["76"]["Position"] = UDim2.new(0, 9, 0, 38);

                -- StarterGui.Lib.Notification.Normal.Text.UIPadding
                Notification["77"] = Instance.new("UIPadding", Notification["76"]);
                Notification["77"]["PaddingRight"] = UDim.new(0, 4);
                Notification["77"]["PaddingLeft"] = UDim.new(0, 4);
            end

            function Open()
                if Notification["6c"] ~= nil then
                    Notification["6c"]:TweenSize(UDim2.new(0, 300, 0, 123), "Out", "Linear", 0.2)
                end
            end
            function Close()
                if Notification["6c"] ~= nil and Notification.Closed == false then
                    Notification["6c"]:TweenSize(UDim2.new(0, 0, 0, 0), "Out", "Linear", 0.2)
                    Notification.Closed = true
                    task.wait(0.225)
                    Notification["6c"]:Destroy()
                end
            end

            Open()
            Notification["72"].MouseButton1Click:Connect(Close)
            task.wait(options["Time"])
            Close()
        end

        function Notifications:ConfirmNotify(options)
            options = Library.Functions.Validate({
                Title = "Confirm Notification",
                Text = "Text",
                Time = 10,
                Callback = function(State) end
            }, options or {})

            local Notification = {
                Closed = false
            }

            -- Render
            do
                -- StarterGui.Lib.Notifications.Confirm
                Notifications["78"] = Instance.new("Frame", Notifications["6a"]);
                Notifications["78"]["BackgroundColor3"] = Color3.fromRGB(54, 54, 54);
                Notifications["78"]["Size"] = UDim2.new(0, 300, 0, 123);
                Notifications["78"]["Position"] = UDim2.new(0, 0, 0, 643);
                Notifications["78"]["Name"] = [[Confirm]];

                -- StarterGui.Lib.Notifications.Confirm.UICorner
                Notifications["79"] = Instance.new("UICorner", Notifications["78"]);
                Notifications["79"]["CornerRadius"] = UDim.new(0, 6);

                -- StarterGui.Lib.Notifications.Confirm.UIStroke
                Notifications["7a"] = Instance.new("UIStroke", Notifications["78"]);
                Notifications["7a"]["Color"] = Color3.fromRGB(255, 255, 255);

                -- StarterGui.Lib.Notifications.Confirm.Text
                Notifications["7b"] = Instance.new("TextLabel", Notifications["78"]);
                Notifications["7b"]["TextWrapped"] = true;
                Notifications["7b"]["TextYAlignment"] = Enum.TextYAlignment.Top;
                Notifications["7b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
                Notifications["7b"]["TextXAlignment"] = Enum.TextXAlignment.Left;
                Notifications["7b"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
                Notifications["7b"]["TextSize"] = 19;
                Notifications["7b"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
                Notifications["7b"]["AutomaticSize"] = Enum.AutomaticSize.Y;
                Notifications["7b"]["Size"] = UDim2.new(0, 280, 0, 79);
                Notifications["7b"]["Name"] = options["Text"];
                Notifications["7b"]["BackgroundTransparency"] = 1;
                Notifications["7b"]["Position"] = UDim2.new(0, 9, 0, 38);

                -- StarterGui.Lib.Notifications.Confirm.Text.UIPadding
                Notifications["7c"] = Instance.new("UIPadding", Notifications["7b"]);
                Notifications["7c"]["PaddingRight"] = UDim.new(0, 4);
                Notifications["7c"]["PaddingLeft"] = UDim.new(0, 4);

                -- StarterGui.Lib.Notifications.Confirm.TopBar
                Notifications["7d"] = Instance.new("Frame", Notifications["78"]);
                Notifications["7d"]["ZIndex"] = 5000;
                Notifications["7d"]["BorderSizePixel"] = 0;
                Notifications["7d"]["BackgroundColor3"] = Color3.fromRGB(66, 66, 66);
                Notifications["7d"]["Size"] = UDim2.new(0, 300, 0, 30);
                Notifications["7d"]["BorderColor3"] = Color3.fromRGB(255, 255, 255);
                Notifications["7d"]["Name"] = [[TopBar]];

                -- StarterGui.Lib.Notifications.Confirm.TopBar.Title
                Notifications["7e"] = Instance.new("TextLabel", Notifications["7d"]);
                Notifications["7e"]["TextWrapped"] = true;
                Notifications["7e"]["ZIndex"] = 50001;
                Notifications["7e"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
                Notifications["7e"]["TextXAlignment"] = Enum.TextXAlignment.Left;
                Notifications["7e"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
                Notifications["7e"]["TextSize"] = 24;
                Notifications["7e"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
                Notifications["7e"]["Size"] = UDim2.new(0, 300, 0, 30);
                Notifications["7e"]["Text"] = options["Title"];
                Notifications["7e"]["Name"] = [[Title]];
                Notifications["7e"]["BackgroundTransparency"] = 1;

                -- StarterGui.Lib.Notifications.Confirm.TopBar.Title.UIPadding
                Notifications["7f"] = Instance.new("UIPadding", Notifications["7e"]);
                Notifications["7f"]["PaddingLeft"] = UDim.new(0, 5);

                -- StarterGui.Lib.Notifications.Confirm.TopBar.Cancel
                Notifications["80"] = Instance.new("ImageButton", Notifications["7d"]);
                Notifications["80"]["ZIndex"] = 231032109;
                Notifications["80"]["BorderSizePixel"] = 0;
                Notifications["80"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
                Notifications["80"]["AnchorPoint"] = Vector2.new(1, 0.5);
                Notifications["80"]["Image"] = [[rbxassetid://3926305904]];
                Notifications["80"]["ImageRectSize"] = Vector2.new(24, 24);
                Notifications["80"]["Size"] = UDim2.new(0, 22, 0, 22);
                Notifications["80"]["Name"] = [[Cancel]];
                Notifications["80"]["ImageRectOffset"] = Vector2.new(284, 4);
                Notifications["80"]["Position"] = UDim2.new(0, 292, 0, 14);
                Notifications["80"]["BackgroundTransparency"] = 1;

                -- StarterGui.Lib.Notifications.Confirm.TopBar.Line
                Notifications["81"] = Instance.new("Frame", Notifications["7d"]);
                Notifications["81"]["ZIndex"] = 2;
                Notifications["81"]["BorderSizePixel"] = 0;
                Notifications["81"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
                Notifications["81"]["AnchorPoint"] = Vector2.new(0, 1);
                Notifications["81"]["Size"] = UDim2.new(0, 300, 0, 1);
                Notifications["81"]["Position"] = UDim2.new(0, 0, 0, 30);
                Notifications["81"]["Name"] = [[Line]];

                -- StarterGui.Lib.Notifications.Confirm.TopBar.UIGradient
                Notifications["82"] = Instance.new("UIGradient", Notifications["7d"]);
                Notifications["82"]["Rotation"] = 90;
                Notifications["82"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(221, 221, 221)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(255, 255, 255))};

                -- StarterGui.Lib.Notifications.Confirm.TopBar.UICorner
                Notifications["83"] = Instance.new("UICorner", Notifications["7d"]);
                Notifications["83"]["CornerRadius"] = UDim.new(0, 6);

                -- StarterGui.Lib.Notifications.Confirm.TopBar.Confirm
                Notifications["84"] = Instance.new("ImageButton", Notifications["7d"]);
                Notifications["84"]["ZIndex"] = 231032109;
                Notifications["84"]["BorderSizePixel"] = 0;
                Notifications["84"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
                Notifications["84"]["AnchorPoint"] = Vector2.new(1, 0.5);
                Notifications["84"]["Image"] = [[rbxassetid://3926305904]];
                Notifications["84"]["ImageRectSize"] = Vector2.new(36, 36);
                Notifications["84"]["Size"] = UDim2.new(0, 22, 0, 22);
                Notifications["84"]["Name"] = [[Confirm]];
                Notifications["84"]["ImageRectOffset"] = Vector2.new(644, 204);
                Notifications["84"]["Position"] = UDim2.new(0, 270, 0, 14);
                Notifications["84"]["BackgroundTransparency"] = 1;
            end

            function Open()
                if Notification["6c"] ~= nil then
                    Notification["6c"]:TweenSize(UDim2.new(0, 300, 0, 123), "Out", "Linear", 0.2)
                end
            end
            function Close()
                if Notification["6c"] ~= nil and Notification.Closed == false then
                    Notification["6c"]:TweenSize(UDim2.new(0, 0, 0, 0), "Out", "Linear", 0.2)
                    Notification.Closed = true
                    task.wait(0.225)
                    Notification["6c"]:Destroy()
                end
            end

            Open()

            Notifications["80"].MouseButton1Click:Connect(function()
                Close()
                options.Callback(false)
            end)
            Notifications["84"].MouseButton1Click:Connect(function()
                Close()
                options.Callback(true)
            end)

            task.wait(options["Time"])
            Close();options.Callback(false)
        end
    end
    Library.Notifications = Notifications

    function GUI:CreateTab(options)
		options = Library.Functions.Validate({
			Name = "Preview Tab",
			Icon = "",
			IconOffset = Vector2.new(0, 0),
			IconSize =  Vector2.new(0, 0),
			ShowAsLast = false,
			ShowAsFirst = false,
		}, options or {})

		local Tab = {
			Hover = false,
			Active = false
		}

		if options.Name:match("__themedesigner") then
		else
			if GUI.CurrentTab == nil and options.Icon == "" then
				options.Icon = "rbxassetid://10888331510"
			end
		end

        -- Render
        do
            Tab["11"] = Instance.new("TextButton", GUI["d"]);
            Tab["11"]["TextXAlignment"] = Enum.TextXAlignment.Left;
            Tab["11"]["BackgroundColor3"] = Color3.fromRGB(84, 84, 84);
            Tab["11"]["TextSize"] = 14;
            Tab["11"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
            Tab["11"]["TextColor3"] = Color3.fromRGB(201, 201, 201);
            Tab["11"]["Size"] = UDim2.new(0, 80, 0, 32);
            Tab["11"]["LayoutOrder"] = 999999;
            Tab["11"]["Name"] = Library.Functions.removeSpaces(options["Name"]);
            Tab["11"]["Text"] = options["Name"];
            Tab["11"]["Position"] = UDim2.new(0, 0, 0, 5);
            Tab["12"] = Instance.new("UIPadding", Tab["11"]);
            Tab["12"]["PaddingLeft"] = UDim.new(0, 28);
            Tab["13"] = Instance.new("ImageLabel", Tab["11"]);
            Tab["13"]["BorderSizePixel"] = 0;
            Tab["13"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
            Tab["13"]["ImageColor3"] = Color3.fromRGB(201, 201, 201);
            Tab["13"]["AnchorPoint"] = Vector2.new(0, 0.5);
            Tab["13"]["Image"] = options["Icon"];
            Tab["13"]["ImageRectSize"] = options["IconSize"];
            Tab["13"]["Size"] = UDim2.new(0, 20, 0, 20);
            Tab["13"]["Name"] = [[Image]];
            Tab["13"]["ImageRectOffset"] = options["IconOffset"];
            Tab["13"]["BackgroundTransparency"] = 1;
            Tab["13"]["Position"] = UDim2.new(0, -24, 0, 16);
            Tab["14"] = Instance.new("UICorner", Tab["11"]);
            Tab["15"] = Instance.new("UIStroke", Tab["11"]);
            Tab["15"]["Color"] = Color3.fromRGB(140, 140, 140);
            Tab["15"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;

            -- StarterGui.Lib.main.Content.TabTemplate
            Tab["1b"] = Instance.new("ScrollingFrame", GUI["18"]);
            Tab["1b"]["BorderSizePixel"] = 0;
            Tab["1b"]["CanvasSize"] = UDim2.new(0, 0, 0, 0);
            Tab["1b"]["BackgroundColor3"] = Color3.fromRGB(49, 49, 49);
            Tab["1b"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
            Tab["1b"]["AutomaticCanvasSize"] = Enum.AutomaticSize.XY;
            Tab["1b"]["BackgroundTransparency"] = 1;
            Tab["1b"]["Size"] = UDim2.new(0, 500, 0, 203);
            Tab["1b"]["Selectable"] = false;
            Tab["1b"]["ScrollBarThickness"] = 0;
            Tab["1b"]["Position"] = UDim2.new(0, 250, 0, 104);
            Tab["1b"]["Name"] = [[TabTemplate]];
            Tab["1b"]["SelectionGroup"] = false;

            -- StarterGui.Lib.main.Content.TabTemplate.UIListLayout
            Tab["1c"] = Instance.new("UIListLayout", Tab["1b"]);
            Tab["1c"]["HorizontalAlignment"] = Enum.HorizontalAlignment.Center;
            Tab["1c"]["Padding"] = UDim.new(0, 6);
            Tab["1c"]["SortOrder"] = Enum.SortOrder.LayoutOrder;

            -- StarterGui.Lib.main.Content.TabTemplate.UIPadding
            Tab["68"] = Instance.new("UIPadding", Tab["1b"]);
            Tab["68"]["PaddingTop"] = UDim.new(0, 1);
            Tab["68"]["PaddingRight"] = UDim.new(0, 1);
            Tab["68"]["PaddingBottom"] = UDim.new(0, 1);
            Tab["68"]["PaddingLeft"] = UDim.new(0, 1);
        end

        -- Methods
		function Tab:Activate()
			if Tab.Active == false then
				if GUI.CurrentTab ~= nil then
					GUI.CurrentTab:Deactivate()
				end

				Tab.Active = true
				Tab["1b"].Visible = true
				GUI.CurrentTab = Tab
			end
		end

		function Tab:Deactivate()
			if Tab.Active == true then
				Tab.Active = false
				Tab.Hover = false
				Tab["1b"].Visible = false
			end
		end

        -- Logic
		do
			Tab["11"].MouseButton1Click:Connect(function()
				Tab:Activate()
			end)

			if options.Name:match("__themedesigner") then 
            else
				if GUI.CurrentTab == nil then
					Tab:Activate()
				end
			end
		end

        function Tab:CreateSection(options)
			options = Library.Functions.Validate({
				Name = "Preview Section"
			}, options or {})

			local Section = {
				Hover = false,
				Active = false,
				ResizeFunc = nil
			}

            -- Render
            do
                -- StarterGui.Lib.main.Content.TabTemplate.SectionFrame
                Section["1d"] = Instance.new("Frame", Tab["1b"]);
                Section["1d"]["BorderSizePixel"] = 0;
                Section["1d"]["BackgroundColor3"] = Color3.fromRGB(60, 60, 60);
                Section["1d"]["Size"] = UDim2.new(0, 475, 0, 519);
                Section["1d"]["Position"] = UDim2.new(0, 13, 0, -325);
                Section["1d"]["Name"] = Library.Functions.removeSpaces(options["Name"]);

                -- StarterGui.Lib.main.Content.TabTemplate.SectionFrame.UIStroke
                Section["1e"] = Instance.new("UIStroke", Section["1d"]);
                Section["1e"]["Color"] = Color3.fromRGB(255, 255, 255);

                -- StarterGui.Lib.main.Content.TabTemplate.SectionFrame.UIListLayout
                Section["1f"] = Instance.new("UIListLayout", Section["1d"]);
                Section["1f"]["HorizontalAlignment"] = Enum.HorizontalAlignment.Center;
                Section["1f"]["Padding"] = UDim.new(0, 8);
                Section["1f"]["SortOrder"] = Enum.SortOrder.LayoutOrder;

                -- StarterGui.Lib.main.Content.TabTemplate.SectionFrame.UIPadding
                Section["20"] = Instance.new("UIPadding", Section["1d"]);
                Section["20"]["PaddingTop"] = UDim.new(0, 10);
                Section["20"]["PaddingRight"] = UDim.new(0, 1);
                Section["20"]["PaddingBottom"] = UDim.new(0, 1);
                Section["20"]["PaddingLeft"] = UDim.new(0, 1);

                -- StarterGui.Lib.main.Content.TabTemplate.SectionFrame.UICorner
                Section["21"] = Instance.new("UICorner", Section["1d"]);
                Section["21"]["CornerRadius"] = UDim.new(0, 4);

                -- StarterGui.Lib.main.Content.TabTemplate.SectionTitle
                Section["65"] = Instance.new("Frame", Section["1b"]);
                Section["65"]["BackgroundColor3"] = Color3.fromRGB(92, 0, 0);
                Section["65"]["BackgroundTransparency"] = 1;
                Section["65"]["LayoutOrder"] = -999999999;
                Section["65"]["Size"] = UDim2.new(0, 475, 0, 20);
                Section["65"]["Position"] = UDim2.new(0, 1, 0, 0);
                Section["65"]["Name"] = Library.Functions.removeSpaces(options["Name"]).."Title";

                -- StarterGui.Lib.main.Content.TabTemplate.SectionTitle.Title
                Section["66"] = Instance.new("TextLabel", Section["65"]);
                Section["66"]["TextWrapped"] = true;
                Section["66"]["RichText"] = true;
                Section["66"]["TextYAlignment"] = Enum.TextYAlignment.Top;
                Section["66"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
                Section["66"]["TextXAlignment"] = Enum.TextXAlignment.Left;
                Section["66"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
                Section["66"]["TextSize"] = 14;
                Section["66"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
                Section["66"]["Size"] = UDim2.new(0, 475, 0, 8);
                Section["66"]["Text"] = options["Name"];
                Section["66"]["Name"] = [[Title]];
                Section["66"]["BackgroundTransparency"] = 1;

                -- StarterGui.Lib.main.Content.TabTemplate.SectionTitle.UIPadding
                Section["67"] = Instance.new("UIPadding", Section["65"]);
                Section["67"]["PaddingTop"] = UDim.new(0, 6);
                Section["67"]["PaddingBottom"] = UDim.new(0, 6);

                -- StarterGui.Lib.main.Content.TabTemplate.InvisMiddleSection
                Section["64"] = Instance.new("Frame", Tab["1b"]);
                Section["64"]["BorderSizePixel"] = 0;
                Section["64"]["BackgroundTransparency"] = 1;
                Section["64"]["Size"] = UDim2.new(0, 500, 0, 5);
                Section["64"]["Name"] = [[InvisMiddleSection]];
            end
        end

        return Tab
    end

    return GUI
end

return Library
