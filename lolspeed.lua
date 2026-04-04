local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local SPEED = 11
local active = false
local heartbeatConn = nil

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VelocityController"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Name = "Container"
frame.Size = UDim2.new(0, 145, 0, 52)
frame.Position = UDim2.new(0.05, 0, 0.78, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 35, 55)
frame.BorderSizePixel = 0
frame.Parent = screenGui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

-- Draggable
local dragging, dragStart, startPos
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
frame.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Shadow
local shadow = Instance.new("ImageLabel")
shadow.Size = UDim2.new(1, 24, 1, 24)
shadow.Position = UDim2.new(0, -12, 0, -8)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://6015897843"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.6
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(49, 49, 450, 450)
shadow.ZIndex = 0
shadow.Parent = frame

-- Toggle button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleButton"
toggleBtn.Size = UDim2.new(1, -60, 1, -8)
toggleBtn.Position = UDim2.new(0, 4, 0, 4)
toggleBtn.BackgroundColor3 = Color3.fromRGB(45, 85, 160)
toggleBtn.Text = "OFF"
toggleBtn.Font = Enum.Font.GothamBlack
toggleBtn.TextColor3 = Color3.fromRGB(220, 230, 255)
toggleBtn.TextSize = 16
toggleBtn.AutoButtonColor = false
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = frame
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 9)

local btnStroke = Instance.new("UIStroke", toggleBtn)
btnStroke.Thickness = 1.5
btnStroke.Color = Color3.fromRGB(80, 130, 220)
btnStroke.Transparency = 0.3

-- Speed display (locked at 12, not editable)
local speedBox = Instance.new("TextLabel")
speedBox.Name = "SpeedDisplay"
speedBox.Size = UDim2.new(0, 48, 1, -8)
speedBox.Position = UDim2.new(1, -52, 0, 4)
speedBox.BackgroundColor3 = Color3.fromRGB(18, 25, 40)
speedBox.Text = tostring(SPEED)
speedBox.Font = Enum.Font.GothamBold
speedBox.TextColor3 = Color3.fromRGB(130, 180, 255)
speedBox.TextSize = 14
speedBox.BorderSizePixel = 0
speedBox.Parent = frame
Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 9)

local speedStroke = Instance.new("UIStroke", speedBox)
speedStroke.Thickness = 1
speedStroke.Color = Color3.fromRGB(50, 70, 110)

-- Toggle logic
toggleBtn.MouseButton1Click:Connect(function()
    active = not active

    if active then
        toggleBtn.Text = "ON"
        TweenService:Create(toggleBtn, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(55, 180, 120)}):Play()
        TweenService:Create(btnStroke, TweenInfo.new(0.25), {Color = Color3.fromRGB(80, 220, 140)}):Play()

        if heartbeatConn then heartbeatConn:Disconnect() end
        heartbeatConn = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum then return end

            local moveDir = hum.MoveDirection
            local isStealing = LocalPlayer:GetAttribute("Stealing")

            -- During a steal the game zeroes MoveDirection, so use existing horizontal direction
            if isStealing then
                local vel = hrp.AssemblyLinearVelocity
                local horiz = Vector3.new(vel.X, 0, vel.Z)
                if horiz.Magnitude > 0.5 then
                    local boosted = horiz.Unit * SPEED
                    hrp.AssemblyLinearVelocity = Vector3.new(boosted.X, vel.Y, boosted.Z)
                else
                    -- No horizontal movement during steal — still apply full speed
                    hrp.AssemblyLinearVelocity = Vector3.new(vel.X, vel.Y, vel.Z)
                end
            else
                -- Normal movement
                if moveDir.Magnitude > 0 then
                    local dir = Vector3.new(moveDir.X, 0, moveDir.Z) * SPEED
                    hrp.AssemblyLinearVelocity = Vector3.new(
                        hrp.AssemblyLinearVelocity:Lerp(Vector3.new(dir.X, hrp.AssemblyLinearVelocity.Y, dir.Z), 0.45).X,
                        hrp.AssemblyLinearVelocity.Y,
                        hrp.AssemblyLinearVelocity:Lerp(Vector3.new(dir.X, hrp.AssemblyLinearVelocity.Y, dir.Z), 0.45).Z
                    )
                end
            end
        end)
    else
        toggleBtn.Text = "OFF"
        TweenService:Create(toggleBtn, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(45, 85, 160)}):Play()
        TweenService:Create(btnStroke, TweenInfo.new(0.25), {Color = Color3.fromRGB(80, 130, 220)}):Play()
        if heartbeatConn then heartbeatConn:Disconnect(); heartbeatConn = nil end
    end
end)

-- Hover effects
toggleBtn.MouseEnter:Connect(function()
    TweenService:Create(toggleBtn, TweenInfo.new(0.15), {Size = UDim2.new(1, -58, 1, -6)}):Play()
end)
toggleBtn.MouseLeave:Connect(function()
    TweenService:Create(toggleBtn, TweenInfo.new(0.15), {Size = UDim2.new(1, -60, 1, -8)}):Play()
end)

-- Reset on respawn
LocalPlayer.CharacterAdded:Connect(function()
    if heartbeatConn then heartbeatConn:Disconnect(); heartbeatConn = nil end
    active = false
    toggleBtn.Text = "OFF"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(45, 85, 160)
end)
