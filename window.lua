-- Window.lua
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Window = {}
Window.__index = Window

function Window.new(config)
    local self = setmetatable({}, Window)
    self.Tabs = {}

    -- Create ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Name = config.Name or "MyUILibrary"
    gui.ResetOnSpawn = false
    gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.fromOffset(500, 350)
    mainFrame.Position = UDim2.fromScale(0.5, 0.5)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    mainFrame.Parent = gui

    -- Rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = mainFrame

    -- Store references
    self.Gui = gui
    self.MainFrame = mainFrame

    return self
end

-- Create a tab (delegates to Tab module)
function Window:CreateTab(name)
    if not self.TabModule then
        warn("Tab module not found")
        return
    end

    local tab = self.TabModule.new(self, name)
    table.insert(self.Tabs, tab)
    return tab
end

return Window
