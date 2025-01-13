local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()


OrionLib:MakeNotification({
    Name = "good luck with the cheat ;)",
    Content = "Welcome!",
    Image = "rbxassetid://4483345998",
    Time = 5
})


local Window = OrionLib:MakeWindow({
    Name = "Script Universal by danizera",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder =
    "AimbotConfig"
})


local players = game:GetService("Players")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local camera = game.Workspace.CurrentCamera
local localPlayer = players.LocalPlayer
local mouse = localPlayer:GetMouse()


local aimbotEnabled = false
local aimKey = Enum.KeyCode.E
local aimPart = "Head"
local aimRadius = 50
local showFov = false
local checkTeam = false
local wallCheck = false
local fpsBoostEnabled = false
local fovCircle = Drawing.new("Circle")
local fpsLabel = nil
local fpsVisible = false


fovCircle.Visible = false
fovCircle.Color = Color3.fromRGB(255, 255, 255)
fovCircle.Thickness = 1.5
fovCircle.Radius = aimRadius
fovCircle.Transparency = 1
fovCircle.Filled = false


local espEnabled = false
local espPlayers = {} --stores information about players when ESP is activated


local function toggleFPSDisplay()
    if not fpsVisible then
        fpsLabel = Drawing.new("Text")
        fpsLabel.Size = 18
        fpsLabel.Color = Color3.fromRGB(255, 255, 255)
        fpsLabel.Outline = true
        fpsLabel.Position = Vector2.new(50, 50)
        fpsLabel.Text = "FPS: 0"
        fpsLabel.Visible = true

        local lastTime = tick()
        local frameCount = 0

        runService.RenderStepped:Connect(function()
            if fpsVisible and fpsLabel then
                frameCount = frameCount + 1
                local currentTime = tick()

                if currentTime - lastTime >= 1 then
                    fpsLabel.Text = "FPS: " .. tostring(frameCount)
                    frameCount = 0
                    lastTime = currentTime
                end
            end
        end)

        fpsVisible = true
    else
        if fpsLabel then
            fpsLabel:Remove()
            fpsLabel = nil
        end
        fpsVisible = false
    end
end


local function isVisible(targetPart) --checks that the player's body part is visible to the camera
    local origin = camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit * 500
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = { localPlayer.Character }



    local raycastResult = workspace:Raycast(origin, direction, raycastParams)


    return not raycastResult or raycastResult.Instance:IsDescendantOf(targetPart.Parent)
end


local function isWallBetween(targetPart) --function that checks if there is a wall between the local player and the target
    if not wallCheck then
        return false
    end


    local origin = camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit * (targetPart.Position - origin).Magnitude
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = { localPlayer.Character, targetPart.Parent }
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

    local raycastResult = workspace:Raycast(origin, direction, raycastParams)


    return raycastResult and raycastResult.Instance ~= nil
end


local function isInFov(screenPoint) --function that defines the point where the FOV will be on the screen
    local mousePos = Vector2.new(mouse.X, mouse.Y)
    local distance = (mousePos - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
    return distance <= fovCircle.Radius
end


local function isInFrontOfCamera(targetPart) --check if there is an object in front of the camera
    local toTarget = (targetPart.Position - camera.CFrame.Position).Unit
    local dotProduct = camera.CFrame.LookVector:Dot(toTarget)
    return dotProduct > 0
end


local function isOnSameTeam(player) --checks if the local player and the other player are on the same team
    if checkTeam then
        return player.Team == localPlayer.Team
    end
    return false
end


local function getClosestPlayer() --finds and returns the player closest to the local player, ignoring the local player and focusing only on the others
    local closestPlayer = nil
    local shortestDistance = aimRadius


    for _, player in pairs(players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild(aimPart) then
            local targetPart = player.Character[aimPart]
            local screenPoint = camera:WorldToViewportPoint(targetPart.Position)


            if isInFov(screenPoint) and isInFrontOfCamera(targetPart) and not isOnSameTeam(player) then
                local distance = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude


                if not wallCheck or (isVisible(targetPart) and not isWallBetween(targetPart)) then
                    if distance < shortestDistance then
                        closestPlayer = player
                        shortestDistance = distance
                    end
                end
            end
        end
    end

    return closestPlayer
end


local function aimAt(target) --responsible for aiming the camera at the other player
    if target and target.Character and target.Character:FindFirstChild(aimPart) then
        local targetPart = target.Character[aimPart]
        camera.CFrame = CFrame.new(camera.CFrame.Position, targetPart.Position)
    end
end


local function setAimbotKey()
    OrionLib:MakeNotification({
        Name = "Key configuration",
        Content = "Press any key for Aimbot bind!",
        Image = "rbxassetid://4483345998",
        Time = 5
    })


    local connection
    connection = userInputService.InputBegan:Connect(function(input)
        aimKey = input.KeyCode
        OrionLib:MakeNotification({
            Name = "Key set",
            Content = "Key set up: " .. tostring(aimKey.Name),
            Image = "rbxassetid://4483345998",
            Time = 3
        })
        connection:Disconnect()
    end)
end


userInputService.InputBegan:Connect(function(input)
    if input.KeyCode == aimKey then
        aimbotEnabled = not aimbotEnabled
        OrionLib:MakeNotification({
            Name = "Aimbot",
            Content = "Aimbot " .. (aimbotEnabled and "Enabled" or "Disabled"),
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
end)


runService.RenderStepped:Connect(function()
    local offset = Vector2.new(0, 36)
    fovCircle.Position = Vector2.new(mouse.X, mouse.Y) + offset
    fovCircle.Visible = showFov



    if aimbotEnabled then
        local closestPlayer = getClosestPlayer()
        if closestPlayer then
            aimAt(closestPlayer)
        end
    end
end)


local function applyFPSBoost()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    game:GetService("Lighting").GlobalShadows = false
    game:GetService("Lighting").FogEnd = 9e9
    game:GetService("Workspace").Terrain.WaterWaveSize = 0
    game:GetService("Workspace").Terrain.WaterTransparency = 1


    for _, desc in pairs(workspace:GetDescendants()) do
        if desc:IsA("BasePart") then
            desc.Material = Enum.Material.SmoothPlastic
            desc.CastShadow = false
        elseif desc:IsA("Decal") or desc:IsA("Texture") then
            desc.Transparency = 1
        elseif desc:IsA("ParticleEmitter") or desc:IsA("Trail") then
            desc.Enabled = false
        end
    end
end


local function monitorNewObjects() --monitors new rendered objects in the game
    workspace.DescendantAdded:Connect(function(desc)
        if fpsBoostEnabled then
            if desc:IsA("BasePart") then
                desc.Material = Enum.Material.SmoothPlastic
                desc.CastShadow = false
            elseif desc:IsA("Decal") or desc:IsA("Texture") then
                desc.Transparency = 1
            elseif desc:IsA("ParticleEmitter") or desc:IsA("Trail") then
                desc.Enabled = false
            end
        end
    end)
end


local function toggleFPSBoost(state)
    fpsBoostEnabled = state

    if fpsBoostEnabled then
        applyFPSBoost()
        monitorNewObjects()


        local fpsBoostLoop = coroutine.create(function()
            while fpsBoostEnabled do
                applyFPSBoost()
                wait(5) --applies fps boost every 5 seconds
            end
        end)
        coroutine.resume(fpsBoostLoop)

        OrionLib:MakeNotification({
            Name = "FPS Boost",
            Content = "FPS Boost Enabled!",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    else
        settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        game:GetService("Lighting").GlobalShadows = true


        for _, desc in pairs(workspace:GetDescendants()) do
            if desc:IsA("BasePart") then
                desc.Material = Enum.Material.Plastic
                desc.CastShadow = true
            elseif desc:IsA("Decal") or desc:IsA("Texture") then
                desc.Transparency = 0
            elseif desc:IsA("ParticleEmitter") or desc:IsA("Trail") then
                desc.Enabled = true
            end
        end

        OrionLib:MakeNotification({
            Name = "FPS Boost",
            Content = "FPS Boost Disabled!",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
end

local espMaxDistance = 1000

local function getDistanceBetween(pos1, pos2)
    return (pos1 - pos2).Magnitude
end


local function createESP(player)
    local espBox = Drawing.new("Square")
    local espName = Drawing.new("Text")
    local espHealthBar = Drawing.new("Line")


    espBox.Thickness = 2
    espBox.Filled = false
    espBox.Transparency = 1
    espBox.Visible = false


    espName.Size = 14
    espName.Outline = true
    espName.Center = true
    espName.Visible = false


    espHealthBar.Thickness = 2
    espHealthBar.Transparency = 1
    espHealthBar.Visible = false

    espPlayers[player] = { espBox, espName, espHealthBar }


    runService.RenderStepped:Connect(function()
        if espEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            local rootPart = player.Character.HumanoidRootPart
            local humanoid = player.Character.Humanoid


            if humanoid.Health > 0 then
                local position, onScreen = camera:WorldToViewportPoint(rootPart.Position)


                local distance = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") and
                    getDistanceBetween(localPlayer.Character.HumanoidRootPart.Position, rootPart.Position) or math.huge


                if onScreen and distance <= espMaxDistance then
                    local boxSize = Vector2.new(4 / position.Z * 300, 6 / position.Z * 500)
                    local boxPosition = Vector2.new(position.X - boxSize.X / 2, position.Y - boxSize.Y / 2)


                    local espColor = player.TeamColor.Color


                    espBox.Color = espColor
                    espName.Color = espColor


                    if espBoxesEnabled then
                        espBox.Size = boxSize
                        espBox.Position = boxPosition
                        espBox.Visible = true
                    else
                        espBox.Visible = false
                    end


                    if espNamesEnabled then
                        espName.Text = string.format("%s\n[%d Studs]", player.Name, math.floor(distance))
                        espName.Position = Vector2.new(boxPosition.X + boxSize.X / 2, boxPosition.Y - 20)
                        espName.Visible = true
                    else
                        espName.Visible = false
                    end


                    if espHealthBarsEnabled then
                        local healthRatio = humanoid.Health / humanoid.MaxHealth
                        local barHeight = boxSize.Y * healthRatio


                        espHealthBar.Color = Color3.fromRGB(255 * (1 - healthRatio), 255 * healthRatio, 0)

                        espHealthBar.From = Vector2.new(boxPosition.X - 6, boxPosition.Y + boxSize.Y)
                        espHealthBar.To = Vector2.new(boxPosition.X - 6, boxPosition.Y + boxSize.Y - barHeight)
                        espHealthBar.Visible = true
                    else
                        espHealthBar.Visible = false
                    end
                else
                    espBox.Visible = false
                    espName.Visible = false
                    espHealthBar.Visible = false
                end
            else
                espBox.Visible = false
                espName.Visible = false
                espHealthBar.Visible = false
            end
        else
            espBox.Visible = false
            espName.Visible = false
            espHealthBar.Visible = false
        end
    end)
end


local function toggleESP(state)
    espEnabled = state


    if espEnabled then
        for _, player in pairs(players:GetPlayers()) do
            if player ~= localPlayer then
                createESP(player)
            end
        end


        players.PlayerAdded:Connect(function(player)
            if player ~= localPlayer then
                createESP(player)
            end
        end)
    else
        for _, objects in pairs(espPlayers) do
            for _, drawing in pairs(objects) do
                drawing:Remove()
            end
        end
        espPlayers = {}
    end
end


local ESPTab = Window:MakeTab({
    Name = "ESP",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local ESPSection = ESPTab:AddSection({
    Name = "ESP settings"
})


ESPSection:AddToggle({
    Name = "Enable ESP",
    Default = false,
    Callback = function(Value)
        toggleESP(Value)
        OrionLib:MakeNotification({
            Name = "ESP",
            Content = "ESP " .. (Value and "Enabled" or "Disabled"),
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})


ESPSection:AddToggle({
    Name = "Show boxes",
    Default = false,
    Callback = function(Value)
        espBoxesEnabled = Value
        OrionLib:MakeNotification({
            Name = "Boxes",
            Content = "Boxes " .. (Value and "Enabled" or "Disabled"),
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})


ESPSection:AddToggle({
    Name = "Show names",
    Default = false,
    Callback = function(Value)
        espNamesEnabled = Value
        OrionLib:MakeNotification({
            Name = "Names",
            Content = "Names " .. (Value and "Enabled" or "Disabled"),
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})


ESPSection:AddToggle({
    Name = "Show Health Bars",
    Default = false,
    Callback = function(Value)
        espHealthBarsEnabled = Value
        OrionLib:MakeNotification({
            Name = "Health Bars",
            Content = "Health Bars " .. (Value and "Enabled" or "Disabled"),
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})


ESPSection:AddSlider({
    Name = "Maximum ESP distance",
    Min = 100,
    Max = 1000,
    Default = 1000,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 100,
    ValueName = "Studs",
    Callback = function(Value)
        espMaxDistance = Value
    end
})


local AimbotTab = Window:MakeTab({
    Name = "Aimbot",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local AimbotSection = AimbotTab:AddSection({
    Name = "Aimbot settings"
})


AimbotSection:AddToggle({
    Name = "Enable Aimbot",
    Default = false,
    Callback = function(Value)
        aimbotEnabled = Value
        OrionLib:MakeNotification({
            Name = "Aimbot",
            Content = "Aimbot " .. (aimbotEnabled and "Enabled" or "Disabled"),
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})

AimbotSection:AddSlider({
    Name = "FOV Aimbot",
    Min = 10,
    Max = 500,
    Default = 50,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 10,
    ValueName = "FOV",
    Callback = function(Value)
        aimRadius = Value
        fovCircle.Radius = Value
    end
})

AimbotSection:AddToggle({
    Name = "Show FOV",
    Default = false,
    Callback = function(Value)
        showFov = Value
    end
})

AimbotSection:AddDropdown({
    Name = "Body part",
    Default = "Head",
    Options = { "Head", "Torso", "HumanoidRootPart" },
    Callback = function(Value)
        aimPart = Value
    end
})



AimbotSection:AddToggle({
    Name = "Check Team",
    Default = false,
    Callback = function(Value)
        checkTeam = Value
        OrionLib:MakeNotification({
            Name = "Check Team",
            Content = "Check Team " .. (checkTeam and "Enabled" or "Disabled"),
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})


AimbotSection:AddToggle({
    Name = "Wall check",
    Default = false,
    Callback = function(Value)
        wallCheck = Value
        OrionLib:MakeNotification({
            Name = "WallCheck",
            Content = "Wall check " .. (wallCheck and "Enabled" or "Disabled"),
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})




AimbotSection:AddButton({
    Name = "Choose Aimbot Key",
    Callback = function()
        setAimbotKey()
    end
})


local SettingsTab = Window:MakeTab({
    Name = "Settings",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local SettingsSection = SettingsTab:AddSection({
    Name = "General Settings"
})


SettingsSection:AddToggle({
    Name = "FPS Boost",
    Default = false,
    Callback = function(Value)
        fpsBoostEnabled = Value
        toggleFPSBoost(fpsBoostEnabled)
    end
})


SettingsSection:AddToggle({
    Name = "Show FPS",
    Default = true,
    Callback = function(Value)
        toggleFPSDisplay()
    end
})



OrionLib:Init()
