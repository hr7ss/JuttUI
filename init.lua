-- Single-file Rayfield-style UI

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Library = {}
Library.Windows = {}

-- Create Window
function Library:CreateWindow(config)
    local selfWindow = {}
    selfWindow.Tabs = {}

    -- ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Name = config.Name or "MyUILibrary"
    gui.ResetOnSpawn = false
    gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

    -- Main Frame
    local main = Instance.new("Frame")
    main.Size = UDim2.fromOffset(500, 350)
    main.Position = UDim2.fromScale(0.5, 0.5)
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = Color3.fromRGB(25,25,25)
    main.Parent = gui

    local corner = Instance.new("UICorner", main)
    corner.CornerRadius = UDim.new(0,10)

    selfWindow.Gui = gui
    selfWindow.MainFrame = main

    -- Tab creation
    function selfWindow:CreateTab(name)
        local tab = {}
        tab.Elements = {}

        -- Tab Button
        local button = Instance.new("TextButton")
        button.Text = name
        button.Size = UDim2.fromOffset(120, 35)
        button.BackgroundColor3 = Color3.fromRGB(35,35,35)
        button.TextColor3 = Color3.new(1,1,1)
        button.Parent = main

        local corner = Instance.new("UICorner", button)
        corner.CornerRadius = UDim.new(0,5)
        tab.Button = button

        -- Content Frame
        local content = Instance.new("Frame")
        content.Size = UDim2.fromOffset(450, 300)
        content.Position = UDim2.fromOffset(25, 50)
        content.BackgroundTransparency = 1
        content.Parent = main
        tab.Content = content

        -- Add Toggle Example
        function tab:AddToggle(config)
            local toggle = Instance.new("TextButton")
            toggle.Size = UDim2.fromOffset(400, 35)
            toggle.Position = UDim2.fromOffset(25, (#self.Elements*40)+10)
            toggle.Text = config.Name
            toggle.BackgroundColor3 = Color3.fromRGB(30,30,30)
            toggle.TextColor3 = Color3.new(1,1,1)
            toggle.Parent = content

            local corner = Instance.new("UICorner", toggle)
            corner.CornerRadius = UDim.new(0,5)

            local state = false
            toggle.MouseButton1Click:Connect(function()
                state = not state
                toggle.BackgroundColor3 = state and Color3.fromRGB(0,120,255) or Color3.fromRGB(30,30,30)
                if config.Callback then
                    config.Callback(state)
                end
            end)

            table.insert(self.Elements, toggle)
        end

        table.insert(selfWindow.Tabs, tab)
        return tab
    end

    table.insert(Library.Windows, selfWindow)
    return selfWindow
end

-- Return the library
return Library

