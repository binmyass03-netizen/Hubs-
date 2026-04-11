-- FPS Display Script (Delta/Roblox Compatible)

local fakeBaseFPS = 320
local variance = 15

local label = Drawing.new("Text")
label.Size = 18
label.Color = Color3.fromRGB(0, 255, 0)
label.Position = Vector2.new(10, 10)
label.Outline = true
label.Visible = true

local function getFakeHighFPS()
    local t = tick()
    local wave = math.floor(math.abs(math.sin(t * 2.3) * variance))
    return fakeBaseFPS + wave
end

game:GetService("RunService").RenderStepped:Connect(function()
    local fps = getFakeHighFPS()
    label.Text = "FPS: " .. tostring(fps)
end)
