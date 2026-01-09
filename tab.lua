-- Tab.lua
local Tab = {}
Tab.__index = Tab

function Tab.new(window, name)
    local self = setmetatable({}, Tab)
    self.Window = window
    self.Name = name
    self.Elements = {}

    -- Create Tab Button
    local button = Instance.new("TextButton")
    button.Text = name
    button.Size = UDim2.fromOffset(120, 35)
    button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    button.TextColor3 = Color3.new(1,1,1)
    button.Parent = window.MainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = button

    self.Button = button

    -- Content Frame
    local content = Instance.new("Frame")
    content.Size = UDim2.fromOffset(450, 300)
    content.Position = UDim2.fromOffset(25, 50)
    content.BackgroundTransparency = 1
    content.Parent = window.MainFrame

    self.Content = content

    return self
end

-- Example: Add a toggle
function Tab:AddToggle(config)
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.fromOffset(400, 35)
    toggle.Position = UDim2.fromOffset(25, (#self.Elements * 40) + 10)
    toggle.Text = config.Name
    toggle.BackgroundColor3 = Color3.fromRGB(30,30,30)
    toggle.TextColor3 = Color3.new(1,1,1)
    toggle.Parent = self.Content

    local corner = Instance.new("UICorner")
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

return Tab
