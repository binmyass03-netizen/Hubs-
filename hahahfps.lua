-- hahahfps - Delta/Roblox Compatible

local fakeBaseFPS = 320
local variance = 15

local screenSize = workspace.CurrentCamera.ViewportSize

local label = Drawing.new("Text")
label.Size = 18
label.Color = Color3.fromRGB(0, 255, 0)
label.Position = Vector2.new(screenSize.X / 2 - 40, screenSize.Y / 2)
label.Outline = true
label.Visible = true

local function getFakeHighFPS()
    local t = tick()
    local wave = math.floor(math.abs(math.sin(t * 2.3) * variance))
    return fakeBaseFPS + wave
end

game:GetService("RunService").RenderStepped:Connect(function()
    local fps = getFakeHighFPS()
    label.Text = "hahahfps: " .. tostring(fps)
end)
