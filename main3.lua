-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Library table
local Library = {}
Library.Windows = {}

-- Create Window
function Library:CreateWindow(config)
    local window = {}
    window.Tabs = {}

    -- CoreGui parent for always-on-top
    local gui = Instance.new("ScreenGui")
    gui.Name = config.Name or "MyUI"
    gui.ResetOnSpawn = false
    gui.Parent = CoreGui
    gui.DisplayOrder = 9999

    -- Main Frame
    local main = Instance.new("Frame")
    main.Size = UDim2.fromOffset(500, 350)
    main.Position = UDim2.fromScale(0.5,0.5)
    main.AnchorPoint = Vector2.new(0.5,0.5)
    main.BackgroundColor3 = Color3.fromRGB(25,25,25)
    main.BorderSizePixel = 0
    main.Parent = gui

    -- Rounded corners
    local corner = Instance.new("UICorner", main)
    corner.CornerRadius = UDim.new(0,10)

    -- Topbar for dragging
    local topbar = Instance.new("Frame")
    topbar.Size = UDim2.new(1,0,0,30)
    topbar.BackgroundTransparency = 0.3
    topbar.BackgroundColor3 = Color3.fromRGB(255,0,0)
    topbar.Parent = main
    Instance.new("UICorner", topbar).CornerRadius = UDim.new(0,10)

    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(1, 0, 0.5, 0)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    CloseButton.Parent = main

    CloseButton.MouseButton1Click:Connect(function()
        main.Visible = false
    end)

    -- Dragging
    local dragging = false
    local dragStart = Vector2.new(0,0)
    local startPos = main.Position

    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)

    topbar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = startPos + UDim2.fromOffset(delta.X, delta.Y)
        end
    end)

    -- Store references
    window.Gui = gui
    window.MainFrame = main
    window.Topbar = topbar

    -- Tab creation
    function window:CreateTab(name)
        local tab = {}
        tab.Elements = {}

        -- Tab Button
        local button = Instance.new("TextButton")
        button.Text = name
        button.Size = UDim2.fromOffset(120,35)
        button.Position = UDim2.fromOffset(10, #window.Tabs*40 + 40)
        button.BackgroundColor3 = Color3.fromRGB(35,35,35)
        button.TextColor3 = Color3.new(1,1,1)
        button.Parent = main
        Instance.new("UICorner", button).CornerRadius = UDim.new(0,5)
        tab.Button = button

        -- Content Frame
        local content = Instance.new("Frame")
        content.Size = UDim2.fromOffset(360, 280)
        content.Position = UDim2.fromOffset(130, 50)
        content.BackgroundTransparency = 1
        content.Parent = main
        tab.Content = content

        -- Add Toggle
        function tab:AddToggle(config)
            local toggle = Instance.new("TextButton")
            toggle.Size = UDim2.fromOffset(340,35)
            toggle.Position = UDim2.fromOffset(10, (#self.Elements*45))
            toggle.Text = config.Name
            toggle.BackgroundColor3 = Color3.fromRGB(30,30,30)
            toggle.TextColor3 = Color3.new(1,1,1)
            toggle.Parent = content
            Instance.new("UICorner", toggle).CornerRadius = UDim.new(0,5)

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

        -- Add Button
        function tab:AddButton(config)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.fromOffset(340,35)
            btn.Position = UDim2.fromOffset(10, (#self.Elements*45))
            btn.Text = config.Name
            btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
            btn.TextColor3 = Color3.new(1,1,1)
            btn.Parent = content
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0,5)

            btn.MouseButton1Click:Connect(function()
                if config.Callback then
                    config.Callback()
                end
            end)

            table.insert(self.Elements, btn)
        end

        table.insert(window.Tabs, tab)
        return tab
    end

    table.insert(Library.Windows, window)
    return window
end

-- Return library
return Library
