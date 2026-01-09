-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Library table
local Library = {}
Library.Windows = {}

----------------------------------------------------------------
-- Field positions (edit / extend these for your game)
----------------------------------------------------------------
local FieldPositions = {
    -- You measured this one:
    ["Dandelion Field"] = CFrame.new(-31.7417526, 3.99718046, 217.373293),
    ["Clover Field"]     = CFrame.new(152.238403, -4.55984797e-08, 0),
    ["Spider Field"]     = CFrame.new(0, 0, 0),
    ["Bamboo Field"]     = CFrame.new(0, 0, 0),
    ["Strawberry Field"] = CFrame.new(-87.5589981, 3.99718094, 117.598518)

    -- Add the rest of your 23 fields here:
    -- ["Sunflower Field"]  = CFrame.new(0, 0, 0),
    -- ["Rose Field"]       = CFrame.new(0, 0, 0),
    -- ...
}
Library.FieldPositions = FieldPositions

-- Optional helper
function Library:GetFieldCFrame(name)
    return FieldPositions[name]
end

----------------------------------------------------------------
-- Create Window
----------------------------------------------------------------
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
    main.Position = UDim2.fromScale(0.5, 0.5)
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = gui

    -- Rounded corners
    local corner = Instance.new("UICorner", main)
    corner.CornerRadius = UDim.new(0, 10)

    -- Topbar for dragging
    local topbar = Instance.new("Frame")
    topbar.Size = UDim2.new(1, 0, 0, 30)
    topbar.BackgroundTransparency = 0.3
    topbar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    topbar.Parent = main
    Instance.new("UICorner", topbar).CornerRadius = UDim.new(0, 10)

    ----------------------------------------------------------------
    -- Arrow button + roll up / down
    ----------------------------------------------------------------
    local openSize = main.Size
    local collapsedSize = UDim2.new(
        openSize.X.Scale,
        openSize.X.Offset,
        0,
        topbar.Size.Y.Offset + 10
    )

    local isOpen = true

    local ArrowButton = Instance.new("TextButton")
    ArrowButton.Name = "ToggleArrow"
    ArrowButton.Size = UDim2.fromOffset(24, 24)
    ArrowButton.AnchorPoint = Vector2.new(1, 0.5)
    ArrowButton.Position = UDim2.new(1, -10, 0.5, 0)
    ArrowButton.BackgroundTransparency = 1
    ArrowButton.Text = "˄"
    ArrowButton.TextColor3 = Color3.new(1, 1, 1)
    ArrowButton.Font = Enum.Font.GothamBold
    ArrowButton.TextSize = 16
    ArrowButton.Parent = topbar

    local windowTweenInfo = TweenInfo.new(
        0.25,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )

    local function toggleWindow()
        isOpen = not isOpen
        local targetSize = isOpen and openSize or collapsedSize
        TweenService:Create(main, windowTweenInfo, { Size = targetSize }):Play()
        ArrowButton.Text = isOpen and "˄" or "˅"
    end

    ArrowButton.MouseButton1Click:Connect(toggleWindow)

    ----------------------------------------------------------------
    -- Dragging
    ----------------------------------------------------------------
    local dragging = false
    local dragStart = Vector2.new(0, 0)
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

    ----------------------------------------------------------------
    -- Tab creation
    ----------------------------------------------------------------
    function window:CreateTab(name)
        local tab = {}
        tab.Elements = {}

        -- Tab Button
        local button = Instance.new("TextButton")
        button.Text = name
        button.Size = UDim2.fromOffset(120, 35)
        button.Position = UDim2.fromOffset(10, 40 + (#window.Tabs * 40))
        button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        button.TextColor3 = Color3.new(1, 1, 1)
        button.Parent = main
        Instance.new("UICorner", button).CornerRadius = UDim.new(0, 5)
        tab.Button = button

        -- Content Frame
        local content = Instance.new("Frame")
        content.Size = UDim2.fromOffset(360, 280)
        content.Position = UDim2.fromOffset(130, 50)
        content.BackgroundTransparency = 1
        content.Parent = main
        tab.Content = content

        -- Padding for uniform margins
        local contentPadding = Instance.new("UIPadding")
        contentPadding.PaddingLeft = UDim.new(0, 10)
        contentPadding.PaddingRight = UDim.new(0, 10)
        contentPadding.Parent = content

        -- Vertical layout
        local layout = Instance.new("UIListLayout")
        layout.FillDirection = Enum.FillDirection.Vertical
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 10)
        layout.Parent = content
        tab.Layout = layout

        local function registerElement(inst)
            inst.LayoutOrder = #tab.Elements + 1
            table.insert(tab.Elements, inst)
        end

        ------------------------------------------------------------
        -- Add Toggle
        ------------------------------------------------------------
        function tab:AddToggle(config)
            local toggle = Instance.new("TextButton")
            toggle.Size = UDim2.new(1, 0, 0, 35)
            toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            toggle.TextColor3 = Color3.new(1, 1, 1)
            toggle.Font = Enum.Font.Gotham
            toggle.TextSize = 14
            toggle.Text = config.Name
            toggle.Parent = content
            Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 5)

            local state = false
            toggle.MouseButton1Click:Connect(function()
                state = not state
                toggle.BackgroundColor3 = state and Color3.fromRGB(0, 120, 255)
                    or Color3.fromRGB(30, 30, 30)
                if config.Callback then
                    config.Callback(state)
                end
            end)

            registerElement(toggle)
        end

        ------------------------------------------------------------
        -- Add Button
        ------------------------------------------------------------
        function tab:AddButton(config)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 35)
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 14
            btn.Text = config.Name
            btn.Parent = content
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

            btn.MouseButton1Click:Connect(function()
                if config.Callback then
                    config.Callback()
                end
            end)

            registerElement(btn)
        end

        ------------------------------------------------------------
        -- Add Selector (scrollable dropdown)
        ------------------------------------------------------------
        function tab:AddSelector(config)
            local labelText = config.Name or "Select"
            local options = config.Options or {}
            local currentIndex = 1

            -- Container
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, 0, 0, 35)
            container.BackgroundTransparency = 1
            container.AutomaticSize = Enum.AutomaticSize.Y
            container.Parent = content

            -- Header
            local header = Instance.new("TextButton")
            header.Size = UDim2.new(1, 0, 0, 35)
            header.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            header.TextColor3 = Color3.new(1, 1, 1)
            header.Font = Enum.Font.Gotham
            header.TextSize = 14
            header.TextXAlignment = Enum.TextXAlignment.Left
            header.Parent = container
            Instance.new("UICorner", header).CornerRadius = UDim.new(0, 5)

            local padding = Instance.new("UIPadding")
            padding.PaddingLeft = UDim.new(0, 8)
            padding.Parent = header

            local arrow = Instance.new("TextLabel")
            arrow.Size = UDim2.fromOffset(20, 35)
            arrow.AnchorPoint = Vector2.new(1, 0)
            arrow.Position = UDim2.new(1, -4, 0, 0)
            arrow.BackgroundTransparency = 1
            arrow.Text = "˅"
            arrow.TextColor3 = Color3.new(1, 1, 1)
            arrow.Font = Enum.Font.GothamBold
            arrow.TextSize = 16
            arrow.Parent = header

            -- Scrollable dropdown list
            local listFrame = Instance.new("ScrollingFrame")
            listFrame.Size = UDim2.new(1, 0, 0, 0)
            listFrame.Position = UDim2.fromOffset(0, 35)
            listFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            listFrame.BorderSizePixel = 0
            listFrame.Visible = false
            listFrame.ClipsDescendants = true
            listFrame.ScrollBarThickness = 4
            listFrame.ScrollingDirection = Enum.ScrollingDirection.Y
            listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
            listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
            listFrame.Parent = container
            Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 5)

            local layoutList = Instance.new("UIListLayout")
            layoutList.FillDirection = Enum.FillDirection.Vertical
            layoutList.SortOrder = Enum.SortOrder.LayoutOrder
            layoutList.Padding = UDim.new(0, 2)
            layoutList.Parent = listFrame

            local itemHeight = 24
            local maxVisibleHeight = 150

            local function updateHeaderText()
                local current = options[currentIndex]
                if current then
                    header.Text = string.format("%s: %s", labelText, tostring(current))
                else
                    header.Text = labelText .. ": (none)"
                end
            end

            local dropdownTweenInfo = TweenInfo.new(
                0.15,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            )

            local open = false
            local currentTween

            local function getDropdownHeight()
                local total = #options * (itemHeight + layoutList.Padding.Offset)
                return math.min(total, maxVisibleHeight)
            end

            local function setOpen(state)
                if open == state then return end
                open = state
                arrow.Text = open and "˄" or "˅"

                if currentTween then
                    currentTween:Cancel()
                    currentTween = nil
                end

                if open then
                    listFrame.Visible = true
                    currentTween = TweenService:Create(
                        listFrame,
                        dropdownTweenInfo,
                        { Size = UDim2.new(1, 0, 0, getDropdownHeight()) }
                    )
                    currentTween:Play()
                else
                    currentTween = TweenService:Create(
                        listFrame,
                        dropdownTweenInfo,
                        { Size = UDim2.new(1, 0, 0, 0) }
                    )
                    currentTween.Completed:Connect(function()
                        if not open then
                            listFrame.Visible = false
                        end
                    end)
                    currentTween:Play()
                end
            end

            -- Option buttons
            for i, opt in ipairs(options) do
                local optBtn = Instance.new("TextButton")
                optBtn.Size = UDim2.new(1, -8, 0, itemHeight)
                optBtn.Position = UDim2.fromOffset(4, 0)
                optBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                optBtn.TextColor3 = Color3.new(1, 1, 1)
                optBtn.Font = Enum.Font.Gotham
                optBtn.TextSize = 14
                optBtn.Text = tostring(opt)
                optBtn.Parent = listFrame

                local optPadding = Instance.new("UIPadding")
                optPadding.PaddingLeft = UDim.new(0, 8)
                optPadding.Parent = optBtn

                optBtn.MouseButton1Click:Connect(function()
                    currentIndex = i
                    updateHeaderText()
                    if config.Callback then
                        config.Callback(options[currentIndex], currentIndex)
                    end
                    setOpen(false)
                end)
            end

            header.MouseButton1Click:Connect(function()
                setOpen(not open)
            end)

            updateHeaderText()
            registerElement(container)

            return {
                Get = function()
                    return options[currentIndex], currentIndex
                end,
                Set = function(valueOrIndex)
                    if typeof(valueOrIndex) == "number" then
                        if valueOrIndex >= 1 and valueOrIndex <= #options then
                            currentIndex = valueOrIndex
                            updateHeaderText()
                        end
                    else
                        for i, v in ipairs(options) do
                            if v == valueOrIndex then
                                currentIndex = i
                                updateHeaderText()
                                break
                            end
                        end
                    end
                end,
                Header = header,
                ListFrame = listFrame,
            }
        end

        table.insert(window.Tabs, tab)
        return tab
    end

    table.insert(Library.Windows, window)
    return window
end

-- Return library
return Library
