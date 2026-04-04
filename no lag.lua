local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ── NO LAG BUTTON ────────────────────────────────────────────────────────────
local lagGui = Instance.new("ScreenGui")
lagGui.Name = "NoLagBtn"
lagGui.ResetOnSpawn = false
lagGui.Parent = PlayerGui

local lagBtn = Instance.new("TextButton")
lagBtn.Size = UDim2.new(0, 90, 0, 28)
lagBtn.Position = UDim2.new(0.5, -45, 0, 8)
lagBtn.BackgroundColor3 = Color3.fromRGB(25, 35, 55)
lagBtn.Text = "⚡ no lag"
lagBtn.Font = Enum.Font.GothamBold
lagBtn.TextSize = 12
lagBtn.TextColor3 = Color3.fromRGB(130, 180, 255)
lagBtn.AutoButtonColor = false
lagBtn.BorderSizePixel = 0
lagBtn.Parent = lagGui
Instance.new("UICorner", lagBtn).CornerRadius = UDim.new(0, 8)
local lagStroke = Instance.new("UIStroke", lagBtn)
lagStroke.Color = Color3.fromRGB(80, 130, 220)
lagStroke.Thickness = 1
lagStroke.Transparency = 0.4

local lagApplied = false
lagBtn.MouseButton1Click:Connect(function()
    if lagApplied then return end
    lagApplied = true

    local Lighting = game.Lighting
    local Terrain = workspace:FindFirstChildWhichIsA("Terrain")
    if Terrain then
        Terrain.WaterWaveSize = 0
        Terrain.WaterWaveSpeed = 0
        Terrain.WaterReflectance = 0
        Terrain.WaterTransparency = 1
    end
    Lighting.Brightness = 2
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9000000000
    Lighting.FogStart = 9000000000
    for _, descendant in pairs(game:GetDescendants()) do
        if descendant:IsA("BasePart") then
            descendant.CastShadow = false
            descendant.Material = "Plastic"
            descendant.Reflectance = 0
            descendant.BackSurface = "SmoothNoOutlines"
            descendant.BottomSurface = "SmoothNoOutlines"
            descendant.FrontSurface = "SmoothNoOutlines"
            descendant.LeftSurface = "SmoothNoOutlines"
            descendant.RightSurface = "SmoothNoOutlines"
            descendant.TopSurface = "SmoothNoOutlines"
        end
    end
    for _, effect in pairs(Lighting:GetDescendants()) do
        if effect:IsA("PostEffect") then effect.Enabled = false end
    end
    RunService.Heartbeat:Connect(function()
        local Plots = workspace:FindFirstChild("Plots")
        if Plots then
            for _, Plot in ipairs(Plots:GetChildren()) do
                if Plot:IsA("Model") and Plot:FindFirstChild("Decorations") then
                    for _, Part in ipairs(Plot.Decorations:GetDescendants()) do
                        if Part:IsA("BasePart") then Part.Transparency = 0.8 end
                    end
                end
            end
        end
    end)
    workspace.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("ForceField") then
            RunService.Heartbeat:Wait()
            descendant:Destroy()
        end
    end)

    lagBtn.Text = "✓ applied"
    lagBtn.TextColor3 = Color3.fromRGB(80, 220, 140)
    lagStroke.Color = Color3.fromRGB(80, 220, 140)
    task.wait(2)
    lagGui:Destroy()
end)
-- ── END NO LAG ───────────────────────────────────────────────────────────────

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

-- Auto on/off with steal
LocalPlayer:GetAttributeChangedSignal("Stealing"):Connect(function()
    local isStealing = LocalPlayer:GetAttribute("Stealing")
    if isStealing and not active then
        -- auto activate
        active = true
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
            local stealing = LocalPlayer:GetAttribute("Stealing")
            if stealing then
                local vel = hrp.AssemblyLinearVelocity
                local horiz = Vector3.new(vel.X, 0, vel.Z)
                if horiz.Magnitude > 0.5 then
                    local boosted = horiz.Unit * SPEED
                    hrp.AssemblyLinearVelocity = Vector3.new(boosted.X, vel.Y, boosted.Z)
                end
            else
                if moveDir.Magnitude > 0 then
                    local dir = Vector3.new(moveDir.X, 0, moveDir.Z) * SPEED
                    local lerped = hrp.AssemblyLinearVelocity:Lerp(Vector3.new(dir.X, hrp.AssemblyLinearVelocity.Y, dir.Z), 0.45)
                    hrp.AssemblyLinearVelocity = lerped
                end
            end
        end)
    elseif not isStealing and active then
        -- auto deactivate when steal ends
        active = false
        toggleBtn.Text = "OFF"
        TweenService:Create(toggleBtn, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(45, 85, 160)}):Play()
        TweenService:Create(btnStroke, TweenInfo.new(0.25), {Color = Color3.fromRGB(80, 130, 220)}):Play()
        if heartbeatConn then heartbeatConn:Disconnect(); heartbeatConn = nil end
    end
end)
