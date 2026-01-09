-- init.lua
-- Main library entry point
local Library = {}

-- Require modules
local WindowModule = require(script:WaitForChild("Window"))
local TabModule = require(script:WaitForChild("Tab"))

-- Function to create a new window
function Library:CreateWindow(config)
    local window = WindowModule.new(config)
    window.TabModule = TabModule -- allow window to create tabs
    return window
end

return Library
