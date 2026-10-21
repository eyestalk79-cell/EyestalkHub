
-- EYESTALK | RIVALS V7
-- LocalScript для собственного проекта Roblox Studio

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild("EYESTALK_RIVALS")
if oldGui then oldGui:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "EYESTALK_RIVALS"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 50
gui.Parent = playerGui

local RED = Color3.fromRGB(210, 35, 48)
local DARK = Color3.fromRGB(17, 17, 22)
local BUTTON = Color3.fromRGB(43, 30, 34)
local WHITE = Color3.fromRGB(245, 245, 245)

-- Неподвижное меню
local frame = Instance.new("Frame")
frame.Name = "MainMenu"
frame.Size = UDim2.fromOffset(245, 405)
frame.Position = UDim2.new(0, 12, 0.2, 0)
frame.BackgroundColor3 = DARK
frame.BorderSizePixel = 0
frame.Active = false
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = RED
stroke.Thickness = 2
stroke.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 46)
title.BackgroundColor3 = RED
title.Text = "EYESTALK | RIVALS"
title.TextColor3 = WHITE
title.Font = Enum.Font.GothamBlack
title.TextSize = 19
title.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = title

local function makeButton(text, y, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -20, 0, 38)
    b.Position = UDim2.fromOffset(10, y)
    b.BackgroundColor3 = color or BUTTON
    b.TextColor3 = WHITE
    b.Text = text
    b.TextSize = 15
    b.Font = Enum.Font.GothamBold
    b.AutoButtonColor = true
    b.Parent = frame

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 7)
    c.Parent = b

    local s = Instance.new("UIStroke")
    s.Color = RED
    s.Thickness = 1
    s.Parent = b

    return b
end

local espButton = makeButton("ESP: OFF", 55)
local crossButton = makeButton("CROSSHAIR: OFF", 99)
local hitButton = makeButton("HITS: 0", 143)
local noclipButton = makeButton("NOCLIP: OFF", 187)
local flyButton = makeButton("FLY: OFF", 231)
local upButton = makeButton("UP ▲", 275, Color3.fromRGB(40, 100, 65))
local downButton = makeButton("DOWN ▼", 319, Color3.fromRGB(130, 40, 45))

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -12, 0, 24)
status.Position = UDim2.fromOffset(6, 366)
status.BackgroundTransparency = 1
status.Text = "SYSTEM READY"
status.TextColor3 = Color3.fromRGB(220, 180, 185)
status.TextSize = 12
status.Font = Enum.Font.GothamBold
status.Parent = frame

-- Прицел
local crosshair = Instance.new("TextLabel")
crosshair.Name = "Crosshair"
crosshair.Size = UDim2.fromOffset(36, 36)
crosshair.Position = UDim2.new(0.5, -18, 0.5, -18)
crosshair.BackgroundTransparency = 1
crosshair.Text = "+"
crosshair.TextColor3 = Color3.fromRGB(255, 50, 65)
crosshair.TextSize = 35
crosshair.Font = Enum.Font.GothamBlack
crosshair.Visible = false
crosshair.Parent = gui

local espEnabled = false
local noclipEnabled = false
local flyEnabled = false
local hitCount = 0

-- ESP только игроков
local highlights = {}

local function clearHighlight(target)
    if highlights[target] then
        highlights[target]:Destroy()
        highlights[target] = nil
    end
end

local function addHighlight(target)
    if target == player or not espEnabled or not target.Character then
        return
    end

    clearHighlight(target)

    local h = Instance.new("Highlight")
    h.Name = "EYESTALK_RIVALS_ESP"
    h.Adornee = target.Character
    h.FillColor = RED
    h.OutlineColor = WHITE
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = gui
    highlights[target] = h
end

local function refreshESP()
    for _, target in ipairs(Players:GetPlayers()) do
        if target ~= player then
            if espEnabled then
                addHighlight(target)
            else
                clearHighlight(target)
            end
        end
    end
end

local function watchPlayer(target)
    target.CharacterAdded:Connect(function()
        task.wait(0.5)
        if espEnabled then addHighlight(target) end
    end)
end

for _, target in ipairs(Players:GetPlayers()) do
    if target ~= player then watchPlayer(target) end
end

Players.PlayerAdded:Connect(function(target)
    watchPlayer(target)
    task.wait(0.5)
    if espEnabled then addHighlight(target) end
end)

Players.PlayerRemoving:Connect(clearHighlight)

espButton.Activated:Connect(function()
    espEnabled = not espEnabled
    espButton.Text = "ESP: " .. (espEnabled and "ON" or "OFF")
    refreshESP()
end)

-- Прицел
crossButton.Activated:Connect(function()
    crosshair.Visible = not crosshair.Visible
    crossButton.Text = "CROSSHAIR: "
        .. (crosshair.Visible and "ON" or "OFF")
end)

-- Счётчик попаданий
local registerHit = Instance.new("BindableEvent")
registerHit.Name = "RegisterHit"
registerHit.Parent = gui

registerHit.Event:Connect(function()
    hitCount += 1
    hitButton.Text = "HITS: " .. hitCount
end)

-- Noclip с сохранением столкновений
local oldCollision = {}

local function applyNoclip()
    local character = player.Character
    if not character then return end

    if noclipEnabled then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                if oldCollision[part] == nil then
                    oldCollision[part] = part.CanCollide
                end
                part.CanCollide = false
            end
        end
    else
        for part, previous in pairs(oldCollision) do
            if part and part.Parent then
                part.CanCollide = previous
            end
        end
        table.clear(oldCollision)
    end
end

noclipButton.Activated:Connect(function()
    noclipEnabled = not noclipEnabled
    noclipButton.Text = "NOCLIP: "
        .. (noclipEnabled and "ON" or "OFF")
    applyNoclip()
end)

RunService.Stepped:Connect(function()
    if noclipEnabled then applyNoclip() end
end)

-- Полёт: мобильный джойстик + UP/DOWN
local flySpeed = 45
local verticalSpeed = 35
local verticalDirection = 0
local flyAttachment
local flyVelocity
local flyConnection
local oldAutoRotate

local function stopFly()
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end

    if flyVelocity then
        flyVelocity:Destroy()
        flyVelocity = nil
    end

    if flyAttachment then
        flyAttachment:Destroy()
        flyAttachment = nil
    end

    local character = player.Character
    local humanoid = character
        and character:FindFirstChildOfClass("Humanoid")

    if humanoid and oldAutoRotate ~= nil then
        humanoid.AutoRotate = oldAutoRotate
    end

    oldAutoRotate = nil
    verticalDirection = 0
end

local function startFly()
    stopFly()

    local character = player.Character
    local humanoid = character
        and character:FindFirstChildOfClass("Humanoid")
    local root = character
        and character:FindFirstChild("HumanoidRootPart")

    if not humanoid or not root then
        flyEnabled = false
        flyButton.Text = "FLY: OFF"
        status.Text = "CHARACTER NOT READY"
        return
    end

    oldAutoRotate = humanoid.AutoRotate
    humanoid.AutoRotate = false

    flyAttachment = Instance.new("Attachment")
    flyAttachment.Name = "EYESTALK_FlyAttachment"
    flyAttachment.Parent = root

    flyVelocity = Instance.new("LinearVelocity")
    flyVelocity.Name = "EYESTALK_FlyVelocity"
    flyVelocity.Attachment0 = flyAttachment
    flyVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    flyVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    flyVelocity.ForceLimitsEnabled = false
    flyVelocity.VectorVelocity = Vector3.zero
    flyVelocity.Parent = root

    flyConnection = RunService.Heartbeat:Connect(function()
        if not flyEnabled or not root.Parent or not humanoid.Parent then
            return
        end

        local move = humanoid.MoveDirection
        flyVelocity.VectorVelocity = Vector3.new(
            move.X * flySpeed,
            verticalDirection * verticalSpeed,
            move.Z * flySpeed
        )
    end)

    status.Text = "FLY ACTIVE"
end

flyButton.Activated:Connect(function()
    flyEnabled = not flyEnabled
    flyButton.Text = "FLY: " .. (flyEnabled and "ON" or "OFF")

    if flyEnabled then
        startFly()
    else
        stopFly()
        status.Text = "SYSTEM READY"
    end
end)

-- Кнопки высоты для планшета
upButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
        verticalDirection = 1
    end
end)

downButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
        verticalDirection = -1
    end
end)

local function releaseVertical(input)
    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
        verticalDirection = 0
    end
end

upButton.InputEnded:Connect(releaseVertical)
downButton.InputEnded:Connect(releaseVertical)

-- Возрождение персонажа
player.CharacterAdded:Connect(function()
    stopFly()
    oldCollision = {}

    task.wait(0.5)

    if flyEnabled then
        startFly()
    end

    if noclipEnabled then
        applyNoclip()
    end

    if espEnabled then
        refreshESP()
    end
end)

print("EYESTALK | RIVALS V7 loaded")
-- EYESTALK | RIVALS V7
-- LocalScript для собственного проекта Roblox Studio

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild("EYESTALK_RIVALS")
if oldGui then oldGui:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "EYESTALK_RIVALS"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 50
gui.Parent = playerGui

local RED = Color3.fromRGB(210, 35, 48)
local DARK = Color3.fromRGB(17, 17, 22)
local BUTTON = Color3.fromRGB(43, 30, 34)
local WHITE = Color3.fromRGB(245, 245, 245)

-- Неподвижное меню
local frame = Instance.new("Frame")
frame.Name = "MainMenu"
frame.Size = UDim2.fromOffset(245, 405)
frame.Position = UDim2.new(0, 12, 0.2, 0)
frame.BackgroundColor3 = DARK
frame.BorderSizePixel = 0
frame.Active = false
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = RED
stroke.Thickness = 2
stroke.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 46)
title.BackgroundColor3 = RED
title.Text = "EYESTALK | RIVALS"
title.TextColor3 = WHITE
title.Font = Enum.Font.GothamBlack
title.TextSize = 19
title.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = title

local function makeButton(text, y, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -20, 0, 38)
    b.Position = UDim2.fromOffset(10, y)
    b.BackgroundColor3 = color or BUTTON
    b.TextColor3 = WHITE
    b.Text = text
    b.TextSize = 15
    b.Font = Enum.Font.GothamBold
    b.AutoButtonColor = true
    b.Parent = frame

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 7)
    c.Parent = b

    local s = Instance.new("UIStroke")
    s.Color = RED
    s.Thickness = 1
    s.Parent = b

    return b
end

local espButton = makeButton("ESP: OFF", 55)
local crossButton = makeButton("CROSSHAIR: OFF", 99)
local hitButton = makeButton("HITS: 0", 143)
local noclipButton = makeButton("NOCLIP: OFF", 187)
local flyButton = makeButton("FLY: OFF", 231)
local upButton = makeButton("UP ▲", 275, Color3.fromRGB(40, 100, 65))
local downButton = makeButton("DOWN ▼", 319, Color3.fromRGB(130, 40, 45))

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -12, 0, 24)
status.Position = UDim2.fromOffset(6, 366)
status.BackgroundTransparency = 1
status.Text = "SYSTEM READY"
status.TextColor3 = Color3.fromRGB(220, 180, 185)
status.TextSize = 12
status.Font = Enum.Font.GothamBold
status.Parent = frame

-- Прицел
local crosshair = Instance.new("TextLabel")
crosshair.Name = "Crosshair"
crosshair.Size = UDim2.fromOffset(36, 36)
crosshair.Position = UDim2.new(0.5, -18, 0.5, -18)
crosshair.BackgroundTransparency = 1
crosshair.Text = "+"
crosshair.TextColor3 = Color3.fromRGB(255, 50, 65)
crosshair.TextSize = 35
crosshair.Font = Enum.Font.GothamBlack
crosshair.Visible = false
crosshair.Parent = gui

local espEnabled = false
local noclipEnabled = false
local flyEnabled = false
local hitCount = 0

-- ESP только игроков
local highlights = {}

local function clearHighlight(target)
    if highlights[target] then
        highlights[target]:Destroy()
        highlights[target] = nil
    end
end

local function addHighlight(target)
    if target == player or not espEnabled or not target.Character then
        return
    end

    clearHighlight(target)

    local h = Instance.new("Highlight")
    h.Name = "EYESTALK_RIVALS_ESP"
    h.Adornee = target.Character
    h.FillColor = RED
    h.OutlineColor = WHITE
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = gui
    highlights[target] = h
end

local function refreshESP()
    for _, target in ipairs(Players:GetPlayers()) do
        if target ~= player then
            if espEnabled then
                addHighlight(target)
            else
                clearHighlight(target)
            end
        end
    end
end

local function watchPlayer(target)
    target.CharacterAdded:Connect(function()
        task.wait(0.5)
        if espEnabled then addHighlight(target) end
    end)
end

for _, target in ipairs(Players:GetPlayers()) do
    if target ~= player then watchPlayer(target) end
end

Players.PlayerAdded:Connect(function(target)
    watchPlayer(target)
    task.wait(0.5)
    if espEnabled then addHighlight(target) end
end)

Players.PlayerRemoving:Connect(clearHighlight)

espButton.Activated:Connect(function()
    espEnabled = not espEnabled
    espButton.Text = "ESP: " .. (espEnabled and "ON" or "OFF")
    refreshESP()
end)

-- Прицел
crossButton.Activated:Connect(function()
    crosshair.Visible = not crosshair.Visible
    crossButton.Text = "CROSSHAIR: "
        .. (crosshair.Visible and "ON" or "OFF")
end)

-- Счётчик попаданий
local registerHit = Instance.new("BindableEvent")
registerHit.Name = "RegisterHit"
registerHit.Parent = gui

registerHit.Event:Connect(function()
    hitCount += 1
    hitButton.Text = "HITS: " .. hitCount
end)

-- Noclip с сохранением столкновений
local oldCollision = {}

local function applyNoclip()
    local character = player.Character
    if not character then return end

    if noclipEnabled then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                if oldCollision[part] == nil then
                    oldCollision[part] = part.CanCollide
                end
                part.CanCollide = false
            end
        end
    else
        for part, previous in pairs(oldCollision) do
            if part and part.Parent then
                part.CanCollide = previous
            end
        end
        table.clear(oldCollision)
    end
end

noclipButton.Activated:Connect(function()
    noclipEnabled = not noclipEnabled
    noclipButton.Text = "NOCLIP: "
        .. (noclipEnabled and "ON" or "OFF")
    applyNoclip()
end)

RunService.Stepped:Connect(function()
    if noclipEnabled then applyNoclip() end
end)

-- Полёт: мобильный джойстик + UP/DOWN
local flySpeed = 45
local verticalSpeed = 35
local verticalDirection = 0
local flyAttachment
local flyVelocity
local flyConnection
local oldAutoRotate

local function stopFly()
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end

    if flyVelocity then
        flyVelocity:Destroy()
        flyVelocity = nil
    end

    if flyAttachment then
        flyAttachment:Destroy()
        flyAttachment = nil
    end

    local character = player.Character
    local humanoid = character
        and character:FindFirstChildOfClass("Humanoid")

    if humanoid and oldAutoRotate ~= nil then
        humanoid.AutoRotate = oldAutoRotate
    end

    oldAutoRotate = nil
    verticalDirection = 0
end

local function startFly()
    stopFly()

    local character = player.Character
    local humanoid = character
        and character:FindFirstChildOfClass("Humanoid")
    local root = character
        and character:FindFirstChild("HumanoidRootPart")

    if not humanoid or not root then
        flyEnabled = false
        flyButton.Text = "FLY: OFF"
        status.Text = "CHARACTER NOT READY"
        return
    end

    oldAutoRotate = humanoid.AutoRotate
    humanoid.AutoRotate = false

    flyAttachment = Instance.new("Attachment")
    flyAttachment.Name = "EYESTALK_FlyAttachment"
    flyAttachment.Parent = root

    flyVelocity = Instance.new("LinearVelocity")
    flyVelocity.Name = "EYESTALK_FlyVelocity"
    flyVelocity.Attachment0 = flyAttachment
    flyVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    flyVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    flyVelocity.ForceLimitsEnabled = false
    flyVelocity.VectorVelocity = Vector3.zero
    flyVelocity.Parent = root

    flyConnection = RunService.Heartbeat:Connect(function()
        if not flyEnabled or not root.Parent or not humanoid.Parent then
            return
        end

        local move = humanoid.MoveDirection
        flyVelocity.VectorVelocity = Vector3.new(
            move.X * flySpeed,
            verticalDirection * verticalSpeed,
            move.Z * flySpeed
        )
    end)

    status.Text = "FLY ACTIVE"
end

flyButton.Activated:Connect(function()
    flyEnabled = not flyEnabled
    flyButton.Text = "FLY: " .. (flyEnabled and "ON" or "OFF")

    if flyEnabled then
        startFly()
    else
        stopFly()
        status.Text = "SYSTEM READY"
    end
end)

-- Кнопки высоты для планшета
upButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
        verticalDirection = 1
    end
end)

downButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
        verticalDirection = -1
    end
end)

local function releaseVertical(input)
    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
        verticalDirection = 0
    end
end

upButton.InputEnded:Connect(releaseVertical)
downButton.InputEnded:Connect(releaseVertical)

-- Возрождение персонажа
player.CharacterAdded:Connect(function()
    stopFly()
    oldCollision = {}

    task.wait(0.5)

    if flyEnabled then
        startFly()
    end

    if noclipEnabled then
        applyNoclip()
    end

-- EYESTALK | RIVALS V7
-- LocalScript для собственного проекта Roblox Studio

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild("EYESTALK_RIVALS")
if oldGui then oldGui:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "EYESTALK_RIVALS"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 50
gui.Parent = playerGui

local RED = Color3.fromRGB(210, 35, 48)
local DARK = Color3.fromRGB(17, 17, 22)
local BUTTON = Color3.fromRGB(43, 30, 34)
local WHITE = Color3.fromRGB(245, 245, 245)

-- Неподвижное меню
local frame = Instance.new("Frame")
frame.Name = "MainMenu"
frame.Size = UDim2.fromOffset(245, 405)
frame.Position = UDim2.new(0, 12, 0.2, 0)
frame.BackgroundColor3 = DARK
frame.BorderSizePixel = 0
frame.Active = false
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = RED
stroke.Thickness = 2
stroke.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 46)
title.BackgroundColor3 = RED
title.Text = "EYESTALK | RIVALS"
title.TextColor3 = WHITE
title.Font = Enum.Font.GothamBlack
title.TextSize = 19
title.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = title

local function makeButton(text, y, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -20, 0, 38)
    b.Position = UDim2.fromOffset(10, y)
    b.BackgroundColor3 = color or BUTTON
    b.TextColor3 = WHITE
    b.Text = text
    b.TextSize = 15
    b.Font = Enum.Font.GothamBold
    b.AutoButtonColor = true
    b.Parent = frame

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 7)
    c.Parent = b

    local s = Instance.new("UIStroke")
    s.Color = RED
    s.Thickness = 1
    s.Parent = b

    return b
end

local espButton = makeButton("ESP: OFF", 55)
local crossButton = makeButton("CROSSHAIR: OFF", 99)
local hitButton = makeButton("HITS: 0", 143)
local noclipButton = makeButton("NOCLIP: OFF", 187)
local flyButton = makeButton("FLY: OFF", 231)
local upButton = makeButton("UP ▲", 275, Color3.fromRGB(40, 100, 65))
local downButton = makeButton("DOWN ▼", 319, Color3.fromRGB(130, 40, 45))

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -12, 0, 24)
status.Position = UDim2.fromOffset(6, 366)
status.BackgroundTransparency = 1
status.Text = "SYSTEM READY"
status.TextColor3 = Color3.fromRGB(220, 180, 185)
status.TextSize = 12
status.Font = Enum.Font.GothamBold
status.Parent = frame

-- Прицел
local crosshair = Instance.new("TextLabel")
crosshair.Name = "Crosshair"
crosshair.Size = UDim2.fromOffset(36, 36)
crosshair.Position = UDim2.new(0.5, -18, 0.5, -18)
crosshair.BackgroundTransparency = 1
crosshair.Text = "+"
crosshair.TextColor3 = Color3.fromRGB(255, 50, 65)
crosshair.TextSize = 35
crosshair.Font = Enum.Font.GothamBlack
crosshair.Visible = false
crosshair.Parent = gui

local espEnabled = false
local noclipEnabled = false
local flyEnabled = false
local hitCount = 0

-- ESP только игроков
local highlights = {}

local function clearHighlight(target)
    if highlights[target] then
        highlights[target]:Destroy()
        highlights[target] = nil
    end
end

local function addHighlight(target)
    if target == player or not espEnabled or not target.Character then
        return
    end

    clearHighlight(target)

    local h = Instance.new("Highlight")
    h.Name = "EYESTALK_RIVALS_ESP"
    h.Adornee = target.Character
    h.FillColor = RED
    h.OutlineColor = WHITE
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = gui
    highlights[target] = h
end

local function refreshESP()
    for _, target in ipairs(Players:GetPlayers()) do
        if target ~= player then
            if espEnabled then
                addHighlight(target)
            else
                clearHighlight(target)
            end
        end
    end
end

local function watchPlayer(target)
    target.CharacterAdded:Connect(function()
        task.wait(0.5)
        if espEnabled then addHighlight(target) end
    end)
end

for _, target in ipairs(Players:GetPlayers()) do
    if target ~= player then watchPlayer(target) end
end

Players.PlayerAdded:Connect(function(target)
    watchPlayer(target)
    task.wait(0.5)
    if espEnabled then addHighlight(target) end
end)

Players.PlayerRemoving:Connect(clearHighlight)

espButton.Activated:Connect(function()
    espEnabled = not espEnabled
    espButton.Text = "ESP: " .. (espEnabled and "ON" or "OFF")
    refreshESP()
end)

-- Прицел
crossButton.Activated:Connect(function()
    crosshair.Visible = not crosshair.Visible
    crossButton.Text = "CROSSHAIR: "
        .. (crosshair.Visible and "ON" or "OFF")
end)

-- Счётчик попаданий
local registerHit = Instance.new("BindableEvent")
registerHit.Name = "RegisterHit"
registerHit.Parent = gui

registerHit.Event:Connect(function()
    hitCount += 1
    hitButton.Text = "HITS: " .. hitCount
end)

-- Noclip с сохранением столкновений
local oldCollision = {}

local function applyNoclip()
    local character = player.Character
    if not character then return end

    if noclipEnabled then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                if oldCollision[part] == nil then
                    oldCollision[part] = part.CanCollide
                end
                part.CanCollide = false
            end
        end
    else
        for part, previous in pairs(oldCollision) do
            if part and part.Parent then
                part.CanCollide = previous
            end
        end
        table.clear(oldCollision)
    end
end

noclipButton.Activated:Connect(function()
    noclipEnabled = not noclipEnabled
    noclipButton.Text = "NOCLIP: "
        .. (noclipEnabled and "ON" or "OFF")
    applyNoclip()
end)

RunService.Stepped:Connect(function()
    if noclipEnabled then applyNoclip() end
end)

-- Полёт: мобильный джойстик + UP/DOWN
local flySpeed = 45
local verticalSpeed = 35
local verticalDirection = 0
local flyAttachment
local flyVelocity
local flyConnection
local oldAutoRotate

local function stopFly()
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end

    if flyVelocity then
        flyVelocity:Destroy()
        flyVelocity = nil
    end

    if flyAttachment then
        flyAttachment:Destroy()
        flyAttachment = nil
    end

    local character = player.Character
    local humanoid = character
        and character:FindFirstChildOfClass("Humanoid")

    if humanoid and oldAutoRotate ~= nil then
        humanoid.AutoRotate = oldAutoRotate
    end

    oldAutoRotate = nil
    verticalDirection = 0
end

local function startFly()
    stopFly()

    local character = player.Character
    local humanoid = character
        and character:FindFirstChildOfClass("Humanoid")
    local root = character
        and character:FindFirstChild("HumanoidRootPart")

    if not humanoid or not root then
        flyEnabled = false
        flyButton.Text = "FLY: OFF"
        status.Text = "CHARACTER NOT READY"
        return
    end

    oldAutoRotate = humanoid.AutoRotate
    humanoid.AutoRotate = false

    flyAttachment = Instance.new("Attachment")
    flyAttachment.Name = "EYESTALK_FlyAttachment"
    flyAttachment.Parent = root

    flyVelocity = Instance.new("LinearVelocity")
    flyVelocity.Name = "EYESTALK_FlyVelocity"
    flyVelocity.Attachment0 = flyAttachment
    flyVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    flyVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    flyVelocity.ForceLimitsEnabled = false
    flyVelocity.VectorVelocity = Vector3.zero
    flyVelocity.Parent = root

    flyConnection = RunService.Heartbeat:Connect(function()
        if not flyEnabled or not root.Parent or not humanoid.Parent then
            return
        end

        local move = humanoid.MoveDirection
        flyVelocity.VectorVelocity = Vector3.new(
            move.X * flySpeed,
            verticalDirection * verticalSpeed,
            move.Z * flySpeed
        )
    end)

    status.Text = "FLY ACTIVE"
end

flyButton.Activated:Connect(function()
    flyEnabled = not flyEnabled
    flyButton.Text = "FLY: " .. (flyEnabled and "ON" or "OFF")

    if flyEnabled then
        startFly()
    else
        stopFly()
        status.Text = "SYSTEM READY"
    end
end)

-- Кнопки высоты для планшета
upButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
        verticalDirection = 1
    end
end)

downButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
        verticalDirection = -1
    end
end)

local function releaseVertical(input)
    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
        verticalDirection = 0
    end
end

upButton.InputEnded:Connect(releaseVertical)
downButton.InputEnded:Connect(releaseVertical)

-- Возрождение персонажа
player.CharacterAdded:Connect(function()
    stopFly()
    oldCollision = {}

    task.wait(0.5)

    if flyEnabled then
        startFly()
    end

    if noclipEnabled then
        applyNoclip()
    end

    if espEnabled then
        refreshESP()
    end
end)

print("EYESTALK | RIVALS V7 loaded")
    
    if espEnabled then
        refreshESP()
    end
end)

print("EYESTALK | RIVALS V7 loaded")
