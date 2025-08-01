local v1 = game:GetService("Players").LocalPlayer

local function v2()
    if v1.Character then
        for _,v3 in ipairs(v1.Character:GetDescendants()) do
            if v3.Name=="HB" then v3:Destroy() end
        end
    end
end

v2()

v1.CharacterAdded:Connect(function(v4)
    v4:WaitForChild("Humanoid")
    for _,v5 in ipairs(v4:GetDescendants()) do
        if v5.Name=="HB" then v5:Destroy() end
    end
    v4.DescendantAdded:Connect(function(v6)
        if v6.Name=="HB" then v6:Destroy() end
    end)
end)
game:GetService("Lighting"):ClearAllChildren()
print("--// IndexWare LOGS: setting done")
local repo = 'https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo..'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo..'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo..'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = 'IndexWare',
    Center = true,
    AutoShow = true,
    TabPadding = 8
})

local Tabs = {
    Main = Window:AddTab('Main'),
    Settings = Window:AddTab('UI Settings')
}

local Settings = {
    Enabled = true,
    Prediction = 0.165,
    HitChance = 100,
    TargetPart = "Head",
    FOV = 100,
    ShowFOV = true,
    BulletTracers = true,
    RichBullet = true,
    HitNotify = true,
    TracerColor = Color3.new(1,0,0),
    TracerWidth = 0.2,
    TracerDuration = 0.5,
    FOVColor = Color3.fromRGB(255,255,0),
    FOVRainbow = false,
    FOVMode = "Middle"
}

local AimGroup = Tabs.Main:AddLeftGroupbox('Aim Settings')
AimGroup:AddToggle('Enabled', {Text = 'Enabled', Default = Settings.Enabled, Callback = function(v) Settings.Enabled = v end})
AimGroup:AddSlider('HitChance', {Text = 'Hit Chance', Default = Settings.HitChance, Min = 0, Max = 100, Rounding = 0, Callback = function(v) Settings.HitChance = v end})
AimGroup:AddInput('Prediction', {Text = 'Prediction', Default = tostring(Settings.Prediction), Numeric = true, Callback = function(v) Settings.Prediction = tonumber(v) or 0.165 end})
AimGroup:AddDropdown('TargetPart', {Text = 'Target Part', Values = {'Head','HumanoidRootPart','UpperTorso','LowerTorso'}, Default = 1, Callback = function(v) Settings.TargetPart = v end})

local VisualGroup = Tabs.Main:AddRightGroupbox('Visuals')
VisualGroup:AddToggle('ShowFOV', {Text = 'Show FOV', Default = Settings.ShowFOV, Callback = function(v) Settings.ShowFOV = v end})
VisualGroup:AddSlider('FOV', {Text = 'FOV Size', Default = Settings.FOV, Min = 150, Max = 1000, Rounding = 0, Callback = function(v) Settings.FOV = v end})
VisualGroup:AddDropdown('FOVMode', {Text = 'FOV Mode', Values = {'Middle','Mouse'}, Default = 1, Callback = function(v) Settings.FOVMode = v end})
VisualGroup:AddLabel('FOV Color'):AddColorPicker('FOVColor', {Default = Settings.FOVColor, Callback = function(v) Settings.FOVColor = v end})
VisualGroup:AddToggle('FOVRainbow', {Text = 'Rainbow FOV', Default = Settings.FOVRainbow, Callback = function(v) Settings.FOVRainbow = v end})
VisualGroup:AddToggle('BulletTracers', {Text = 'Bullet Tracers', Default = Settings.BulletTracers, Callback = function(v) Settings.BulletTracers = v end})
VisualGroup:AddToggle('RichBullet', {Text = 'Rich Bullet', Default = Settings.RichBullet, Callback = function(v) Settings.RichBullet = v end})
VisualGroup:AddToggle('HitNotify', {Text = 'Hit Notify', Default = Settings.HitNotify, Callback = function(v) Settings.HitNotify = v end})
VisualGroup:AddSlider('TracerWidth', {Text = 'Tracer Width', Default = Settings.TracerWidth*10, Min = 1, Max = 20, Rounding = 0, Callback = function(v) Settings.TracerWidth = v/10 end})
VisualGroup:AddSlider('TracerDuration', {Text = 'Tracer Duration', Default = Settings.TracerDuration*10, Min = 1, Max = 100, Rounding = 0, Callback = function(v) Settings.TracerDuration = v/10 end})
VisualGroup:AddLabel('Tracer Color'):AddColorPicker('TracerColor', {Default = Settings.TracerColor, Callback = function(v) Settings.TracerColor = v end})

local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService('RunService')
local UserInputService = game:GetService('UserInputService')

local FOVCircle = Drawing.new('Circle')
FOVCircle.Visible = Settings.ShowFOV
FOVCircle.Radius = Settings.FOV
FOVCircle.Color = Settings.FOVColor
FOVCircle.Thickness = 2
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
--[[
local function CreateRichTracer(startPos, endPos)
    if not Settings.BulletTracers then return end

    local TweenService = game:GetService("TweenService")
    local Debris = game:GetService("Debris")
    local RunService = game:GetService("RunService")

    local direction = (endPos - startPos).Unit
    local distance = (startPos - endPos).Magnitude
    local midPoint = (startPos + endPos) / 2 + Vector3.new(0, math.clamp(distance * 0.05, 0, 3), 0

    local tracer = Instance.new('Part')
    tracer.Size = Vector3.new(0, 0, 0)
    tracer.CFrame = CFrame.lookAt(startPos, endPos)
    tracer.Anchored = true
    tracer.CanCollide = false
    tracer.Material = Enum.Material.Neon
    tracer.Color = Settings.TracerColor
    tracer.Transparency = 1
    tracer.CastShadow = false
    tracer.Parent = workspace

    local mesh = Instance.new("SpecialMesh", tracer)
    mesh.MeshType = Enum.MeshType.Cylinder
    mesh.Scale = Vector3.new(1, 1, 0)

    local function GetBezierPosition(t)
        return startPos:Lerp(midPoint, t):Lerp(endPos:Lerp(midPoint, t), t)
    end

    local glow, light, sparkles
    if Settings.RichBullet then
        glow = Instance.new('SurfaceGui', tracer)
        glow.Face = Enum.NormalId.Top
        glow.AlwaysOnTop = true
        glow.Adornee = tracer
        glow.LightInfluence = 0
        glow.ZOffset = 1
        
        local frame = Instance.new('Frame', glow)
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundColor3 = Settings.TracerColor
        frame.BackgroundTransparency = 0.7
        frame.BorderSizePixel = 0
        
        light = Instance.new('PointLight', tracer)
        light.Color = Settings.TracerColor
        light.Range = distance/2
        light.Brightness = 0
        light.Shadows = true
        light.Enabled = true
        
        sparkles = Instance.new('ParticleEmitter', tracer)
        sparkles.LightEmission = 1
        sparkles.Texture = "rbxassetid://296874871"
        sparkles.Color = ColorSequence.new(Settings.TracerColor)
        sparkles.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.5),
            NumberSequenceKeypoint.new(1, 0)
        })
        sparkles.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1)
        })
        sparkles.Speed = NumberRange.new(2)
        sparkles.Lifetime = NumberRange.new(0.3)
        sparkles.Rate = 50
        sparkles.Rotation = NumberRange.new(0, 360)
        sparkles.EmissionDirection = Enum.NormalId.Front
        sparkles.Enabled = false

        local meshPart = Instance.new("MeshPart", tracer)
        meshPart.MeshId = "rbxassetid://9856898030"
        meshPart.TextureID = "rbxassetid://9856897896"
        meshPart.Size = Vector3.new(0.5, 0.5, 0.5)
        meshPart.CFrame = tracer.CFrame * CFrame.new(0, 0, -distance/2)
        meshPart.Anchored = true
        meshPart.CanCollide = false
        meshPart.Material = Enum.Material.Neon
        meshPart.Color = Settings.TracerColor
        meshPart.Transparency = 1
    end

    local totalDuration = Settings.TracerDuration
    local appearTime = 0.08
    local sustainTime = totalDuration * 0.3
    local fadeTime = totalDuration * 0.7

    local sizeTween = TweenService:Create(tracer, TweenInfo.new(appearTime, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = Vector3.new(Settings.TracerWidth, Settings.TracerWidth, distance)
    })

    mesh.Scale = Vector3.new(1, 1, 0)
    local meshTween = TweenService:Create(mesh, TweenInfo.new(appearTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Scale = Vector3.new(1, 1, distance * 0.1)
    })

    local fadeTween = TweenService:Create(tracer, TweenInfo.new(fadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Transparency = 1,
        Size = Vector3.new(0, 0, distance * 1.2)
    })

    local lightTween
    if light then
        lightTween = TweenService:Create(light, TweenInfo.new(totalDuration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
            Brightness = 8,
            Range = distance * 1.5
        })
    end

    local meshPartTween
    if Settings.RichBullet then
        for _,v in pairs(tracer:GetChildren()) do
            if v:IsA("MeshPart") then
                meshPartTween = TweenService:Create(v, TweenInfo.new(appearTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Transparency = 0.3,
                    Size = Vector3.new(2, 2, 2)
                })
                break
            end
        end
    end

    local connection
    local startTime = os.clock()
    connection = RunService.Heartbeat:Connect(function()
        local elapsed = os.clock() - startTime
        local progress = math.min(elapsed / appearTime, 1)
        
        if progress < 1 then
            local currentPos = GetBezierPosition(progress)
            tracer.CFrame = CFrame.lookAt(currentPos, endPos)
            if Settings.RichBullet then
                for _,v in pairs(tracer:GetChildren()) do
                    if v:IsA("MeshPart") then
                        v.CFrame = tracer.CFrame * CFrame.new(0, 0, -distance/2) * CFrame.Angles(0, elapsed * 10, 0)
                        break
                    end
                end
            end
        else
            connection:Disconnect()
        end
    end)

    sizeTween:Play()
    meshTween:Play()
    if lightTween then lightTween:Play() end
    if meshPartTween then meshPartTween:Play() end
    if sparkles then sparkles.Enabled = true end

    tracer.Transparency = 0.3
    if Settings.RichBullet then
        for _,v in pairs(tracer:GetChildren()) do
            if v:IsA("MeshPart") then
                v.Transparency = 0.3
            end
        end
    end

    delay(appearTime + sustainTime, function()
        fadeTween:Play()
        if sparkles then
            sparkles.Lifetime = NumberRange.new(0.1)
            sparkles.Rate = 5
        end
    end)

    Debris:AddItem(tracer, totalDuration)
end
    --]]
--[[
local function CreateRichTracer(startPos, endPos)
    if not Settings.BulletTracers then return end

    local TweenService = game:GetService("TweenService")
    local Debris = game:GetService("Debris")
    local RunService = game:GetService("RunService")

    local direction = (endPos - startPos).Unit
    local distance = (startPos - endPos).Magnitude
    local midPoint = (startPos + endPos) / 2 + Vector3.new(0, math.clamp(distance * 0.05, 0, 3), 0)

    local tracer = Instance.new('Part')
    tracer.Size = Vector3.new(0, 0, 0)
    tracer.CFrame = CFrame.lookAt(startPos, endPos)
    tracer.Anchored = true
    tracer.CanCollide = false
    tracer.Material = Enum.Material.Neon
    tracer.Color = Settings.TracerColor
    tracer.Transparency = 1
    tracer.CastShadow = false
    tracer.Parent = workspace

    local mesh = Instance.new("SpecialMesh", tracer)
    mesh.MeshType = Enum.MeshType.Cylinder
    mesh.Scale = Vector3.new(1, 1, 0)

    local function GetBezierPosition(t)
        return startPos:Lerp(midPoint, t):Lerp(endPos:Lerp(midPoint, t), t)
    end

    local glow, light, sparkles
    if Settings.RichBullet then
        glow = Instance.new('SurfaceGui', tracer)
        glow.Face = Enum.NormalId.Top
        glow.AlwaysOnTop = true
        glow.Adornee = tracer
        glow.LightInfluence = 0
        glow.ZOffset = 1
        
        local frame = Instance.new('Frame', glow)
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundColor3 = Settings.TracerColor
        frame.BackgroundTransparency = 0.7
        frame.BorderSizePixel = 0
        
        light = Instance.new('PointLight', tracer)
        light.Color = Settings.TracerColor
        light.Range = distance/2
        light.Brightness = 0
        light.Shadows = true
        light.Enabled = true
        
        sparkles = Instance.new('ParticleEmitter', tracer)
        sparkles.LightEmission = 1
        sparkles.Texture = "rbxassetid://296874871"
        sparkles.Color = ColorSequence.new(Settings.TracerColor)
        sparkles.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.5),
            NumberSequenceKeypoint.new(1, 0)
        })
        sparkles.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1)
        })
        sparkles.Speed = NumberRange.new(2)
        sparkles.Lifetime = NumberRange.new(0.3)
        sparkles.Rate = 50
        sparkles.Rotation = NumberRange.new(0, 360)
        sparkles.EmissionDirection = Enum.NormalId.Front
        sparkles.Enabled = false

        local meshPart = Instance.new("MeshPart")
        meshPart.MeshId = "rbxassetid://9856898030"
        meshPart.TextureID = "rbxassetid://9856897896"
        meshPart.Size = Vector3.new(0.5, 0.5, 0.5)
        meshPart.CFrame = tracer.CFrame * CFrame.new(0, 0, -distance/2)
        meshPart.Anchored = true
        meshPart.CanCollide = false
        meshPart.Material = Enum.Material.Neon
        meshPart.Color = Settings.TracerColor
        meshPart.Transparency = 1
        meshPart.Parent = tracer
    end

    local totalDuration = Settings.TracerDuration
    local appearTime = 0.08
    local sustainTime = totalDuration * 0.3
    local fadeTime = totalDuration * 0.7

    local sizeTween = TweenService:Create(tracer, TweenInfo.new(appearTime, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = Vector3.new(Settings.TracerWidth, Settings.TracerWidth, distance)
    })

    local meshTween = TweenService:Create(mesh, TweenInfo.new(appearTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Scale = Vector3.new(1, 1, distance * 0.1)
    })

    local fadeTween = TweenService:Create(tracer, TweenInfo.new(fadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Transparency = 1,
        Size = Vector3.new(0, 0, distance * 1.2)
    })

    local lightTween
    if light then
        lightTween = TweenService:Create(light, TweenInfo.new(totalDuration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
            Brightness = 8,
            Range = distance * 1.5
        })
    end

    local meshPartTween
    if Settings.RichBullet then
        for _,v in pairs(tracer:GetChildren()) do
            if v:IsA("MeshPart") then
                meshPartTween = TweenService:Create(v, TweenInfo.new(appearTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Transparency = 0.3,
                    Size = Vector3.new(2, 2, 2)
                })
                break
            end
        end
    end

    local connection
    local startTime = os.clock()
    connection = RunService.Heartbeat:Connect(function()
        local elapsed = os.clock() - startTime
        local progress = math.min(elapsed / appearTime, 1)
        
        if progress < 1 then
            local currentPos = GetBezierPosition(progress)
            tracer.CFrame = CFrame.lookAt(currentPos, endPos)
            if Settings.RichBullet then
                for _,v in pairs(tracer:GetChildren()) do
                    if v:IsA("MeshPart") then
                        v.CFrame = tracer.CFrame * CFrame.new(0, 0, -distance/2) * CFrame.Angles(0, elapsed * 10, 0)
                        break
                    end
                end
            end
        else
            connection:Disconnect()
        end
    end)

    sizeTween:Play()
    meshTween:Play()
    if lightTween then lightTween:Play() end
    if meshPartTween then meshPartTween:Play() end
    if sparkles then sparkles.Enabled = true end

    tracer.Transparency = 0.3
    if Settings.RichBullet then
        for _,v in pairs(tracer:GetChildren()) do
            if v:IsA("MeshPart") then
                v.Transparency = 0.3
            end
        end
    end

    delay(appearTime + sustainTime, function()
        fadeTween:Play()
        if sparkles then
            sparkles.Lifetime = NumberRange.new(0.1)
            sparkles.Rate = 5
        end
    end)

    Debris:AddItem(tracer, totalDuration)
end
--]]
--[[
local function CreateRichTracer(startPos, endPos)
    if not Settings.BulletTracers then return end

    local TweenService = game:GetService("TweenService")
    local Debris = game:GetService("Debris")
    local RunService = game:GetService("RunService")

    local direction = (endPos - startPos).Unit
    local distance = (startPos - endPos).Magnitude
    local curveHeight = math.clamp(distance * 0.1, 1, 5)
    local midPoint = (startPos + endPos) / 2 + Vector3.new(0, curveHeight, 0)

    local tracer = Instance.new('Part')
    tracer.Size = Vector3.new(0, 0, 0)
    tracer.CFrame = CFrame.lookAt(startPos, endPos)
    tracer.Anchored = true
    tracer.CanCollide = false
    tracer.Material = Enum.Material.Neon
    tracer.Color = Settings.TracerColor
    tracer.Transparency = 1
    tracer.CastShadow = false
    tracer.Parent = workspace

    local mesh = Instance.new("SpecialMesh", tracer)
    mesh.MeshType = Enum.MeshType.Cylinder
    mesh.Scale = Vector3.new(1, 1, 0)

    local function GetBezierPosition(t)
        return startPos:Lerp(midPoint, t):Lerp(endPos:Lerp(midPoint, t), t)
    end

    local glow = Instance.new('SurfaceGui', tracer)
    glow.Face = Enum.NormalId.Top
    glow.AlwaysOnTop = true
    glow.Adornee = tracer
    glow.LightInfluence = 0
    glow.ZOffset = 1
    
    local frame = Instance.new('Frame', glow)
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Settings.TracerColor
    frame.BackgroundTransparency = 0.7
    frame.BorderSizePixel = 0

    local sparkles = Instance.new('ParticleEmitter', tracer)
    sparkles.LightEmission = 1
    sparkles.Texture = "rbxassetid://296874871"
    sparkles.Color = ColorSequence.new(Settings.TracerColor)
    sparkles.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(1, 0)
    })
    sparkles.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1)
    })
    sparkles.Speed = NumberRange.new(2)
    sparkles.Lifetime = NumberRange.new(0.3)
    sparkles.Rate = 50
    sparkles.Rotation = NumberRange.new(0, 360)
    sparkles.EmissionDirection = Enum.NormalId.Front
    sparkles.Enabled = false

    local meshPart = Instance.new("MeshPart")
    meshPart.MeshId = "rbxassetid://9856898030"
    meshPart.TextureID = "rbxassetid://9856897896"
    meshPart.Size = Vector3.new(0.5, 0.5, 0.5)
    meshPart.CFrame = tracer.CFrame * CFrame.new(0, 0, -distance/2)
    meshPart.Anchored = true
    meshPart.CanCollide = false
    meshPart.Material = Enum.Material.Neon
    meshPart.Color = Settings.TracerColor
    meshPart.Transparency = 1
    meshPart.Parent = tracer

    local trail = Instance.new("Trail", tracer)
    trail.Attachment0 = Instance.new("Attachment", tracer)
    trail.Attachment1 = Instance.new("Attachment", tracer)
    trail.Color = ColorSequence.new(Settings.TracerColor)
    trail.LightEmission = 1
    trail.Transparency = NumberSequence.new(0.5)
    trail.Lifetime = 0.3
    trail.Enabled = false

    local totalDuration = Settings.TracerDuration
    local appearTime = 0.08
    local sustainTime = totalDuration * 0.3
    local fadeTime = totalDuration * 0.7

    local sizeTween = TweenService:Create(tracer, TweenInfo.new(appearTime, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = Vector3.new(Settings.TracerWidth, Settings.TracerWidth, distance)
    })

    local meshTween = TweenService:Create(mesh, TweenInfo.new(appearTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Scale = Vector3.new(1, 1, distance * 0.1)
    })

    local fadeTween = TweenService:Create(tracer, TweenInfo.new(fadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Transparency = 1,
        Size = Vector3.new(0, 0, distance * 1.2)
    })

    local meshPartTween = TweenService:Create(meshPart, TweenInfo.new(appearTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Transparency = 0.3,
        Size = Vector3.new(2, 2, 2)
    })

    local trailTween = TweenService:Create(trail, TweenInfo.new(fadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Transparency = NumberSequence.new(1)
    })

    local connection
    local startTime = os.clock()
    connection = RunService.Heartbeat:Connect(function()
        local elapsed = os.clock() - startTime
        local progress = math.min(elapsed / appearTime, 1)
        
        if progress < 1 then
            local currentPos = GetBezierPosition(progress)
            tracer.CFrame = CFrame.lookAt(currentPos, endPos)
            meshPart.CFrame = tracer.CFrame * CFrame.new(0, 0, -distance/2) * CFrame.Angles(0, elapsed * 10, 0)
        else
            connection:Disconnect()
        end
    end)

    sizeTween:Play()
    meshTween:Play()
    meshPartTween:Play()
    trailTween:Play()
    sparkles.Enabled = true
    trail.Enabled = true

    tracer.Transparency = 0.3
    meshPart.Transparency = 0.3

    delay(appearTime + sustainTime, function()
        fadeTween:Play()
        sparkles.Lifetime = NumberRange.new(0.1)
        sparkles.Rate = 5
    end)

    Debris:AddItem(tracer, totalDuration)
end
--]]
local function CreateRichTracer(startPos, endPos)
    if not Settings.BulletTracers then return end

    local TweenService = game:GetService("TweenService")
    local Debris = game:GetService("Debris")
    local RunService = game:GetService("RunService")

    local distance = (startPos - endPos).Magnitude
    local midPoint = (startPos + endPos) / 2 + Vector3.new(0, math.clamp(distance * 0.05, 0, 3), 0)

    local tracer = Instance.new('Part')
    tracer.Size = Vector3.new(Settings.TracerWidth, Settings.TracerWidth, 0)
    tracer.CFrame = CFrame.lookAt(startPos, endPos)
    tracer.Anchored = true
    tracer.CanCollide = false
    tracer.Material = Enum.Material.Neon
    tracer.Color = Settings.TracerColor
    tracer.Transparency = 1
    tracer.Parent = workspace

    local bulletHead = Instance.new("Part")
    bulletHead.Shape = Enum.PartType.Ball
    bulletHead.Size = Vector3.new(0.2, 0.2, 0.2)
    bulletHead.CFrame = CFrame.new(startPos)
    bulletHead.Anchored = true
    bulletHead.CanCollide = false
    bulletHead.Material = Enum.Material.Neon
    bulletHead.Color = Settings.TracerColor
    bulletHead.Transparency = 1
    bulletHead.Parent = workspace

    local shockwave = Instance.new("Part")
    shockwave.Shape = Enum.PartType.Ball
    shockwave.Size = Vector3.new(0.5, 0.5, 0.5)
    shockwave.CFrame = CFrame.new(endPos)
    shockwave.Anchored = true
    shockwave.CanCollide = false
    shockwave.Material = Enum.Material.Neon
    shockwave.Color = Settings.TracerColor
    shockwave.Transparency = 1
    shockwave.Parent = workspace

    local tracerAppear = TweenService:Create(tracer, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = Vector3.new(Settings.TracerWidth, Settings.TracerWidth, distance),
        Transparency = 0.3,
        CFrame = CFrame.lookAt(startPos, endPos) * CFrame.new(0, 0, -distance/2)
    })

    local tracerDisappear = TweenService:Create(tracer, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = Vector3.new(Settings.TracerWidth * 1.5, Settings.TracerWidth * 1.5, 0),
        Transparency = 1
    })

    local bulletFly = TweenService:Create(bulletHead, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
        CFrame = CFrame.new(endPos),
        Transparency = 0
    })

    local shockwaveExpand = TweenService:Create(shockwave, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(8, 8, 8),
        Transparency = 0.8
    })

    local shockwaveFade = TweenService:Create(shockwave, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Transparency = 1
    })

    tracerAppear:Play()
    bulletFly:Play()
    
    delay(0.3, function()
        shockwaveExpand:Play()
        shockwaveFade:Play()
    end)

    delay(Settings.TracerDuration - 0.3, function()
        tracerDisappear:Play()
    end)

    Debris:AddItem(tracer, Settings.TracerDuration)
    Debris:AddItem(bulletHead, 0.5)
    Debris:AddItem(shockwave, 0.6)
end
local function ShowHitNotification(target)
    if not Settings.HitNotify or not target or not target.Parent then return end
    
    local player = Players:GetPlayerFromCharacter(target.Parent)
    if not player then return end
    
    local name = player.DisplayName or player.Name
    local distance = math.floor((target.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
    local hitPart = target.Name
    local humanoid = target.Parent:FindFirstChildOfClass("Humanoid")
    local health = humanoid and string.format("%d/%d", math.floor(humanoid.Health), math.floor(humanoid.MaxHealth)) or "N/A"
    
    local currentItem = "None"
    if LocalPlayer.Character then
        local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool then
            currentItem = tool.Name
        end
    end
    
    local gunHitSound = Instance.new("Sound")
    gunHitSound.SoundId = "rbxassetid://4817809188"
    gunHitSound.Volume = 1
    gunHitSound.Parent = workspace
    gunHitSound:Play()
    
    Library:Notify(string.format("Hit %s [%s] | Distance %d | Health %s | Item: %s", name, hitPart, distance, health, currentItem))
end
Settings.RichShader = false
Settings.BloomIntensity = 1
Settings.BloomSize = 8
Settings.BloomThreshold = 0.9
Settings.ColorCorrection = false
Settings.Saturation = 1
Settings.Contrast = 1
Settings.TransparentCharacter = false
Settings.TransparencyAmount = 0.7
Settings.RemoveFaces = true
Settings.ForceFieldMaterial = false

local LightGroup = Tabs.Main:AddLeftGroupbox('Lighting')
LightGroup:AddToggle('RichShader', {Text = 'Rich Shader', Default = Settings.RichShader, Callback = function(v) 
    Settings.RichShader = v
    UpdateLightingEffects()
end})
LightGroup:AddSlider('BloomIntensity', {Text = 'Bloom Intensity', Default = Settings.BloomIntensity * 10, Min = 1, Max = 20, Rounding = 0, Callback = function(v)
    Settings.BloomIntensity = v/10
    UpdateLightingEffects()
end})
LightGroup:AddSlider('BloomSize', {Text = 'Bloom Size', Default = Settings.BloomSize, Min = 1, Max = 24, Rounding = 0, Callback = function(v)
    Settings.BloomSize = v
    UpdateLightingEffects()
end})
LightGroup:AddToggle('ColorCorrection', {Text = 'Color Correction', Default = Settings.ColorCorrection, Callback = function(v)
    Settings.ColorCorrection = v
    UpdateLightingEffects()
end})

local VisualGroup = Tabs.Main:AddRightGroupbox('Transparent')
VisualGroup:AddToggle('TransparentCharacter', {Text = 'Transparent Character', Default = Settings.TransparentCharacter, Callback = function(v)
    Settings.TransparentCharacter = v
    UpdateCharacterVisuals()
end})
VisualGroup:AddSlider('TransparencyAmount', {Text = 'Transparency', Default = Settings.TransparencyAmount * 10, Min = 1, Max = 10, Rounding = 0, Callback = function(v)
    Settings.TransparencyAmount = v/10
    UpdateCharacterVisuals()
end})
VisualGroup:AddToggle('RemoveFaces', {Text = 'Remove Faces', Default = Settings.RemoveFaces, Callback = function(v)
    Settings.RemoveFaces = v
    UpdateCharacterVisuals()
end})
VisualGroup:AddToggle('ForceFieldMaterial', {Text = 'ForceField Material', Default = Settings.ForceFieldMaterial, Callback = function(v)
    Settings.ForceFieldMaterial = v
    UpdateCharacterVisuals()
end})

local bloomEffect
local colorCorrectionEffect

local function UpdateLightingEffects()
    if Settings.RichShader then
        if not bloomEffect then
            bloomEffect = Instance.new("BloomEffect")
            bloomEffect.Name = "RichShader_Bloom"
            bloomEffect.Parent = game.Lighting
        end
        bloomEffect.Intensity = Settings.BloomIntensity
        bloomEffect.Size = Settings.BloomSize
        bloomEffect.Threshold = Settings.BloomThreshold
        bloomEffect.Enabled = true
        
        if Settings.ColorCorrection then
            if not colorCorrectionEffect then
                colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
                colorCorrectionEffect.Name = "RichShader_ColorCorrection"
                colorCorrectionEffect.Parent = game.Lighting
            end
            colorCorrectionEffect.Saturation = Settings.Saturation
            colorCorrectionEffect.Contrast = Settings.Contrast
            colorCorrectionEffect.Enabled = true
        elseif colorCorrectionEffect then
            colorCorrectionEffect.Enabled = false
        end
    else
        if bloomEffect then bloomEffect.Enabled = false end
        if colorCorrectionEffect then colorCorrectionEffect.Enabled = false end
    end
end

local function UpdateCharacterVisuals()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            for _, part in ipairs(player.Character:GetDescendants()) do
                if part:IsA('BasePart') and part.Name ~= "HumanoidRootPart" then
                    if Settings.ForceFieldMaterial then
                        part.Material = Enum.Material.ForceField
                    else
                        part.Material = Enum.Material.Plastic
                    end
                    
                    if Settings.TransparentCharacter then
                        part.Transparency = Settings.TransparencyAmount
                    else
                        part.Transparency = 0
                    end
                    
                    if Settings.RemoveFaces then
                        for _, decal in ipairs(part:GetChildren()) do
                            if decal:IsA('Decal') then
                                decal:Destroy()
                            end
                        end
                    end
                end
            end
        end
    end
end

local function OnCharacterAdded(character)
    UpdateCharacterVisuals()
    character.DescendantAdded:Connect(function(part)
        if part:IsA('BasePart') then
            UpdateCharacterVisuals()
        end
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    player.CharacterAdded:Connect(OnCharacterAdded)
    if player.Character then
        OnCharacterAdded(player.Character)
    end
end

UpdateLightingEffects()
UpdateCharacterVisuals()

local function GetTarget()
    if not LocalPlayer.Character then return nil end
    
    local closest = nil
    local closestDist = Settings.FOV
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local targetPart = player.Character:FindFirstChild(Settings.TargetPart)
            
            if humanoid and humanoid.Health > 0 and targetPart then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local center = Settings.FOVMode == "Middle" 
                        and Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2) 
                        or UserInputService:GetMouseLocation()
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    
                    if dist < closestDist then
                        closestDist = dist
                        closest = targetPart
                    end
                end
            end
        end
    end
    
    return closest
end

local function AutoShoot()
    while task.wait(0.1) do
        if LocalPlayer.Character then
            local tool = LocalPlayer.Character:FindFirstChildOfClass('Tool')
            if tool then
                local target = GetTarget()
                if target and math.random(1,100) <= Settings.HitChance then
                    local pos = target.Position + target.Velocity * Settings.Prediction
                    
                    if LocalPlayer.Character:FindFirstChild('HumanoidRootPart') then
                        CreateRichTracer(LocalPlayer.Character.HumanoidRootPart.Position, pos)
                    end
                    
                    ShowHitNotification(target)
                    tool:Activate()
                end
            end
        end
    end
end

local OriginalIndex
OriginalIndex = hookmetamethod(game, '__index', function(t, k)
    if not Settings.Enabled then return OriginalIndex(t, k) end
    if t:IsA('Mouse') and (k == 'Hit' or k == 'Target') then
        local target = GetTarget()
        if target and math.random(1,100) <= Settings.HitChance then
            local pos = target.Position + target.Velocity * Settings.Prediction
            return k == 'Hit' and CFrame.new(pos) or target
        end
    end
    return OriginalIndex(t, k)
end)

coroutine.wrap(AutoShoot)()

local rainbowCounter = 0
RunService.RenderStepped:Connect(function(deltaTime)
    if Settings.FOVRainbow then
        rainbowCounter = (rainbowCounter + deltaTime * 2) % 1
        FOVCircle.Color = Color3.fromHSV(rainbowCounter, 1, 1)
    else
        FOVCircle.Color = Settings.FOVColor
    end
    
    local center = Settings.FOVMode == "Middle" and Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2) or UserInputService:GetMouseLocation()
    FOVCircle.Position = center
    FOVCircle.Visible = Settings.ShowFOV
    FOVCircle.Radius = Settings.FOV
end)
--[[
local ESPGroup = Tabs.Visuals:AddRightGroupbox('ESP Settings')
ESPGroup:AddToggle('EnableESP', {Text = 'Enable ESP', Default = false})
ESPGroup:AddToggle('ShowNames', {Text = 'Names', Default = true})
ESPGroup:AddToggle('ShowBoxes', {Text = 'Boxes', Default = true})
ESPGroup:AddToggle('ShowTracers', {Text = 'Tracers', Default = true})
ESPGroup:AddToggle('ShowHealth', {Text = 'Health', Default = true})
ESPGroup:AddToggle('ShowDistance', {Text = 'Distance', Default = true})
ESPGroup:AddToggle('ShowWeapon', {Text = 'Item', Default = true})
--ESPGroup:AddToggle('ShowSkeleton', {Text = 'Skeleton', Default = false})
ESPGroup:AddToggle('ShowFilled', {Text = 'Filled', Default = false})
ESPGroup:AddToggle('ShowOutOfView', {Text = 'OOV Arrows', Default = true})

local ColorsGroup = Tabs.Visuals:AddRightGroupbox('Colors')
ColorsGroup:AddLabel('Box Color'):AddColorPicker('BoxColor', {Default = Color3.new(1,0,0)})
ColorsGroup:AddLabel('Name Color'):AddColorPicker('NameColor', {Default = Color3.new(1,1,1)})
ColorsGroup:AddLabel('Tracer Color'):AddColorPicker('TracerColor', {Default = Color3.new(1,1,1)})
ColorsGroup:AddLabel('Health Color'):AddColorPicker('HealthColor', {Default = Color3.new(0,1,0)})
ColorsGroup:AddLabel('Distance Color'):AddColorPicker('DistanceColor', {Default = Color3.new(1,1,1)})
ColorsGroup:AddLabel('Weapon Color'):AddColorPicker('WeaponColor', {Default = Color3.new(1,0.5,0)})
--ColorsGroup:AddLabel('Skeleton Color'):AddColorPicker('SkeletonColor', {Default = Color3.new(1,1,1)})
ColorsGroup:AddLabel('OOV Color'):AddColorPicker('OOVColor', {Default = Color3.new(1,0,0)})

local SettingsGroup = Tabs.Visuals:AddRightGroupbox('Settings')
SettingsGroup:AddSlider('TextSize', {Text = 'Text Size', Default = 14, Min = 8, Max = 24, Rounding = 0})
SettingsGroup:AddSlider('BoxTransparency', {Text = 'Box Transparency', Default = 0, Min = 0, Max = 1, Rounding = 2})
SettingsGroup:AddSlider('TracerThickness', {Text = 'Tracer Thickness', Default = 1, Min = 1, Max = 5, Rounding = 0})
SettingsGroup:AddSlider('ArrowSize', {Text = 'Arrow Size', Default = 15, Min = 5, Max = 30, Rounding = 0})
SettingsGroup:AddSlider('MaxDistance', {Text = 'Max Distance', Default = 1000, Min = 100, Max = 5000, Rounding = 0})

local ESP = {
    Objects = {},
    Connections = {},
    Drawings = {}
}

local function CreateESP(player)
    local drawings = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Health = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Weapon = Drawing.new("Text"),
        Tracer = Drawing.new("Line"),
        OOVArrow = Drawing.new("Triangle")
    }

    drawings.Box.Visible = false
    drawings.Name.Visible = false
    drawings.Health.Visible = false
    drawings.Distance.Visible = false
    drawings.Weapon.Visible = false
    drawings.Tracer.Visible = false
    drawings.OOVArrow.Visible = false

    drawings.Box.Thickness = 1
    drawings.Tracer.Thickness = 1
    drawings.Name.Size = 14
    drawings.Health.Size = 14
    drawings.Distance.Size = 14
    drawings.Weapon.Size = 14

    ESP.Drawings[player] = drawings

    local connection
    connection = player.CharacterAdded:Connect(function(character)
        task.wait(0.5)
        ESP.Drawings[player].Character = character
    end)

    table.insert(ESP.Connections, connection)
end

local function UpdateESP()
    for player, drawings in pairs(ESP.Drawings) do
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character.HumanoidRootPart
            local head = player.Character:FindFirstChild("Head")
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")

            if rootPart and head and humanoid then
                local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude

                if distance <= Settings.MaxDistance then
                    if onScreen then
                        local boxSize = Vector2.new(2000 / distance, 3000 / distance)
                        local boxPos = Vector2.new(screenPos.X - boxSize.X / 2, screenPos.Y - boxSize.Y / 2)

                        if Settings.ShowBoxes then
                            drawings.Box.Visible = true
                            drawings.Box.Position = boxPos
                            drawings.Box.Size = boxSize
                            drawings.Box.Color = Settings.BoxColor
                            drawings.Box.Transparency = Settings.BoxTransparency
                            drawings.Box.Filled = Settings.ShowFilled
                        else
                            drawings.Box.Visible = false
                        end

                        if Settings.ShowNames then
                            drawings.Name.Visible = true
                            drawings.Name.Position = Vector2.new(screenPos.X, boxPos.Y - 20)
                            drawings.Name.Text = player.Name
                            drawings.Name.Color = Settings.NameColor
                            drawings.Name.Size = Settings.TextSize
                        else
                            drawings.Name.Visible = false
                        end

                        if Settings.ShowHealth then
                            drawings.Health.Visible = true
                            drawings.Health.Position = Vector2.new(screenPos.X, boxPos.Y + boxSize.Y + 5)
                            drawings.Health.Text = "HP: "..math.floor(humanoid.Health).."/"..math.floor(humanoid.MaxHealth)
                            drawings.Health.Color = Settings.HealthColor
                            drawings.Health.Size = Settings.TextSize
                        else
                            drawings.Health.Visible = false
                        end

                        if Settings.ShowDistance then
                            drawings.Distance.Visible = true
                            drawings.Distance.Position = Vector2.new(screenPos.X, boxPos.Y + boxSize.Y + 25)
                            drawings.Distance.Text = math.floor(distance).." studs"
                            drawings.Distance.Color = Settings.DistanceColor
                            drawings.Distance.Size = Settings.TextSize
                        else
                            drawings.Distance.Visible = false
                        end

                        if Settings.ShowTracers then
                            drawings.Tracer.Visible = true
                            drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                            drawings.Tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                            drawings.Tracer.Color = Settings.TracerColor
                            drawings.Tracer.Thickness = Settings.TracerThickness
                        else
                            drawings.Tracer.Visible = false
                        end

                        if Settings.ShowWeapon then
                            local weapon = "None"
                            for _, tool in pairs(player.Character:GetChildren()) do
                                if tool:IsA("Tool") then
                                    weapon = tool.Name
                                    break
                                end
                            end
                            drawings.Weapon.Visible = true
                            drawings.Weapon.Position = Vector2.new(screenPos.X, boxPos.Y + boxSize.Y + 45)
                            drawings.Weapon.Text = weapon
                            drawings.Weapon.Color = Settings.WeaponColor
                            drawings.Weapon.Size = Settings.TextSize
                        else
                            drawings.Weapon.Visible = false
                        end

                        drawings.OOVArrow.Visible = false
                    elseif Settings.ShowOutOfView then
                        local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                        local dir = (Vector2.new(screenPos.X, screenPos.Y) - center
                        local angle = math.atan2(dir.Y, dir.X)
                        local arrowSize = Settings.ArrowSize

                        drawings.OOVArrow.Visible = true
                        drawings.OOVArrow.PointA = center + Vector2.new(math.cos(angle) * arrowSize, math.sin(angle) * arrowSize)
                        drawings.OOVArrow.PointB = center + Vector2.new(math.cos(angle + 0.5) * arrowSize/2, math.sin(angle + 0.5) * arrowSize/2)
                        drawings.OOVArrow.PointC = center + Vector2.new(math.cos(angle - 0.5) * arrowSize/2, math.sin(angle - 0.5) * arrowSize/2)
                        drawings.OOVArrow.Color = Settings.OOVColor
                        drawings.OOVArrow.Filled = true
                    end
                else
                    for _, drawing in pairs(drawings) do
                        drawing.Visible = false
                    end
                end
            end
        else
            for _, drawing in pairs(drawings) do
                drawing.Visible = false
            end
        end
    end
end

local function ClearAllESP()
    for _, drawings in pairs(ESP.Drawings) do
        for _, drawing in pairs(drawings) do
            drawing:Remove()
        end
    end
    ESP.Drawings = {}
end

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    CreateESP(player)
end)

Players.PlayerRemoving:Connect(function(player)
    if ESP.Drawings[player] then
        for _, drawing in pairs(ESP.Drawings[player]) do
            drawing:Remove()
        end
        ESP.Drawings[player] = nil
    end
end)

RunService.RenderStepped:Connect(UpdateESP)
--]]
--[[
local ESPGroup = Tabs.Visuals:AddLeftGroupbox('Skeleton ESP')
ESPGroup:AddToggle('EnableSkeleton', {Text = 'Enable Skeleton', Default = false})
ESPGroup:AddToggle('ShowHead', {Text = 'Show Head', Default = true})
ESPGroup:AddToggle('ShowLimbs', {Text = 'Show Limbs', Default = true})
ESPGroup:AddToggle('ShowTorso', {Text = 'Show Torso', Default = true})
ESPGroup:AddSlider('Thickness', {Text = 'Line Thickness', Default = 1, Min = 1, Max = 5, Rounding = 0})
ESPGroup:AddLabel('Bone Color'):AddColorPicker('BoneColor', {Default = Color3.new(1,1,1)})
ESPGroup:AddSlider('MaxDistance', {Text = 'Max Distance', Default = 1000, Min = 100, Max = 5000, Rounding = 0})

local Skeleton = {
    Connections = {},
    Drawings = {},
    Bones = {
        Head = {"Head", "UpperTorso"},
        LeftArm = {"LeftUpperArm", "LeftLowerArm", "LeftHand"},
        RightArm = {"RightUpperArm", "RightLowerArm", "RightHand"},
        LeftLeg = {"LeftUpperLeg", "LeftLowerLeg", "LeftFoot"},
        RightLeg = {"RightUpperLeg", "RightLowerLeg", "RightFoot"},
        Torso = {"UpperTorso", "LowerTorso"}
    }
}

local function CreateSkeleton(player)
    local drawings = {}
    for boneGroup, parts in pairs(Skeleton.Bones) do
        for i = 1, #parts - 1 do
            local line = Drawing.new("Line")
            line.Visible = false
            line.Thickness = 1
            line.Color = Color3.new(1,1,1)
            table.insert(drawings, line)
        end
    end
    Skeleton.Drawings[player] = drawings

    local connection
    connection = player.CharacterAdded:Connect(function(character)
        task.wait(0.5)
        Skeleton.Drawings[player].Character = character
    end)
    table.insert(Skeleton.Connections, connection)
end

local function UpdateSkeleton()
    for player, drawings in pairs(Skeleton.Drawings) do
        if player and player.Character then
            local character = player.Character
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")

            if humanoid and humanoid.Health > 0 and rootPart then
                local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
                if distance <= Settings.MaxDistance then
                    local lineIndex = 1
                    
                    for boneGroup, parts in pairs(Skeleton.Bones) do
                        if (boneGroup == "Head" and Settings.ShowHead) or
                           (boneGroup:find("Arm") and Settings.ShowLimbs) or
                           (boneGroup:find("Leg") and Settings.ShowLimbs) or
                           (boneGroup == "Torso" and Settings.ShowTorso) then
                            
                            for i = 1, #parts - 1 do
                                local part1 = character:FindFirstChild(parts[i])
                                local part2 = character:FindFirstChild(parts[i+1])
                                
                                if part1 and part2 then
                                    local pos1, vis1 = Camera:WorldToViewportPoint(part1.Position)
                                    local pos2, vis2 = Camera:WorldToViewportPoint(part2.Position)
                                    
                                    if vis1 and vis2 then
                                        drawings[lineIndex].From = Vector2.new(pos1.X, pos1.Y)
                                        drawings[lineIndex].To = Vector2.new(pos2.X, pos2.Y)
                                        drawings[lineIndex].Color = Settings.BoneColor
                                        drawings[lineIndex].Thickness = Settings.Thickness
                                        drawings[lineIndex].Visible = true
                                        lineIndex = lineIndex + 1
                                    end
                                end
                            end
                        end
                    end
                    
                    for i = lineIndex, #drawings do
                        drawings[i].Visible = false
                    end
                else
                    for _, line in pairs(drawings) do
                        line.Visible = false
                    end
                end
            else
                for _, line in pairs(drawings) do
                    line.Visible = false
                end
            end
        else
            for _, line in pairs(drawings) do
                line.Visible = false
            end
        end
    end
end

local function ClearSkeleton()
    for _, drawings in pairs(Skeleton.Drawings) do
        for _, line in pairs(drawings) do
            line:Remove()
        end
    end
    Skeleton.Drawings = {}
end

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateSkeleton(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    CreateSkeleton(player)
end)

Players.PlayerRemoving:Connect(function(player)
    if Skeleton.Drawings[player] then
        for _, line in pairs(Skeleton.Drawings[player]) do
            line:Remove()
        end
        Skeleton.Drawings[player] = nil
    end
end)

RunService.RenderStepped:Connect(UpdateSkeleton)
--]]
--[[
local ESPTab = Window:AddTab('Drawing')

local LeftGroup = ESPTab:AddLeftGroupbox('Main')
local EnableToggle = LeftGroup:AddToggle('ESPEnabled', {Text = 'Enable', Default = false})

local RightGroup = ESPTab:AddRightGroupbox('Settings')
local BoxToggle = RightGroup:AddToggle('ShowBox', {Text = 'Show Box', Default = true})
local NameToggle = RightGroup:AddToggle('ShowName', {Text = 'Show Name', Default = true})
local BoxColor = RightGroup:AddLabel('Box Color'):AddColorPicker('BoxColor', {Default = Color3.new(1,0,0)})
local TextColor = RightGroup:AddLabel('Text Color'):AddColorPicker('TextColor', {Default = Color3.new(1,1,1)})
local ThicknessSlider = RightGroup:AddSlider('BoxThickness', {Text = 'Box Thickness', Default = 1, Min = 1, Max = 3, Rounding = 0})
local TextSizeSlider = RightGroup:AddSlider('TextSize', {Text = 'Text Size', Default = 14, Min = 8, Max = 20, Rounding = 0})
local DistanceSlider = RightGroup:AddSlider('MaxDistance', {Text = 'Max Distance', Default = 1000, Min = 100, Max = 5000, Rounding = 0})

local ESPData = {
    Active = false,
    BoxVisible = true,
    NameVisible = true,
    BoxColor = Color3.new(1,0,0),
    TextColor = Color3.new(1,1,1),
    BoxThickness = 1,
    TextSize = 14,
    MaxDistance = 1000
}

local PlayerDrawings = {}

local function UpdateSettings()
    ESPData.Active = EnableToggle.Value
    ESPData.BoxVisible = BoxToggle.Value
    ESPData.NameVisible = NameToggle.Value
    ESPData.BoxColor = BoxColor.Value
    ESPData.TextColor = TextColor.Value
    ESPData.BoxThickness = ThicknessSlider.Value
    ESPData.TextSize = TextSizeSlider.Value
    ESPData.MaxDistance = DistanceSlider.Value
end

local function CreateESP(player)
    if PlayerDrawings[player] then return end

    local drawings = {
        Box = Drawing.new('Square'),
        Name = Drawing.new('Text'),
        Character = nil,
        Humanoid = nil
    }

    PlayerDrawings[player] = drawings

    local function SetupCharacter(character)
        drawings.Character = character
        drawings.Humanoid = character:WaitForChild('Humanoid')
    end

    if player.Character then
        SetupCharacter(player.Character)
    end

    player.CharacterAdded:Connect(SetupCharacter)
end

local function RemoveESP(player)
    if not PlayerDrawings[player] then return end

    for _, drawing in pairs(PlayerDrawings[player]) do
        if typeof(drawing) == 'Drawing' then
            drawing:Remove()
        end
    end

    PlayerDrawings[player] = nil
end

local function UpdateDrawings()
    if not ESPData.Active then
        for _, drawings in pairs(PlayerDrawings) do
            drawings.Box.Visible = false
            drawings.Name.Visible = false
        end
        return
    end

    for player, drawings in pairs(PlayerDrawings) do
        if drawings.Character and drawings.Humanoid and drawings.Humanoid.Health > 0 then
            local rootPart = drawings.Character:FindFirstChild('HumanoidRootPart')
            if rootPart then
                local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position)
                local distance = (rootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude

                if onScreen and distance <= ESPData.MaxDistance then
                    local boxSize = Vector2.new(2000 / distance, 3000 / distance)
                    local boxPos = Vector2.new(screenPos.X - boxSize.X/2, screenPos.Y - boxSize.Y/2)

                    drawings.Box.Visible = ESPData.BoxVisible
                    if ESPData.BoxVisible then
                        drawings.Box.Position = boxPos
                        drawings.Box.Size = boxSize
                        drawings.Box.Color = ESPData.BoxColor
                        drawings.Box.Thickness = ESPData.BoxThickness
                        drawings.Box.Filled = false
                    end

                    drawings.Name.Visible = ESPData.NameVisible
                    if ESPData.NameVisible then
                        drawings.Name.Position = Vector2.new(screenPos.X, boxPos.Y - 20)
                        drawings.Name.Text = player.Name
                        drawings.Name.Color = ESPData.TextColor
                        drawings.Name.Size = ESPData.TextSize
                        drawings.Name.Outline = true
                    end
                else
                    drawings.Box.Visible = false
                    drawings.Name.Visible = false
                end
            end
        else
            drawings.Box.Visible = false
            drawings.Name.Visible = false
        end
    end
end

game:GetService('Players').PlayerAdded:Connect(CreateESP)
game:GetService('Players').PlayerRemoving:Connect(RemoveESP)

for _, player in pairs(game:GetService('Players'):GetPlayers()) do
    if player ~= game.Players.LocalPlayer then
        CreateESP(player)
    end
end

game:GetService('RunService').RenderStepped:Connect(function()
    UpdateSettings()
    UpdateDrawings()
end)

RunService.RenderStepped:Connect(UpdateESP)
--]]
--[[
local ESPLib = {
    Objects = {},
    Enabled = false,
    Settings = {
        Box = true,
        Name = true,
        Health = true,
        Distance = true,
        TeamCheck = false,
        Color = Color3.new(1, 0, 0),
        MaxDistance = 1000,
        RefreshRate = 100,
        Transparency = 0
    }
}

function ESPLib:Init()
    game:GetService("RunService").RenderStepped:Connect(function()
        if not self.Enabled then return end
        self:Update()
    end)
end

function ESPLib:Toggle(state)
    self.Enabled = state
    if not state then
        self:Clear()
    end
end

function ESPLib:Clear()
    for _, obj in pairs(self.Objects) do
        for _, drawing in pairs(obj) do
            drawing:Remove()
        end
    end
    self.Objects = {}
end

function ESPLib:Update()
    local camera = workspace.CurrentCamera
    local localPlayer = game:GetService("Players").LocalPlayer
    
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player == localPlayer then continue end
        if not player.Character then continue end
        if not player.Character:FindFirstChild("HumanoidRootPart") then continue end
        if self.Settings.TeamCheck and player.Team == localPlayer.Team then continue end

        local rootPart = player.Character.HumanoidRootPart
        local distance = (rootPart.Position - camera.CFrame.Position).Magnitude
        if distance > self.Settings.MaxDistance then continue end

        local screenPos, onScreen = camera:WorldToViewportPoint(rootPart.Position)
        if not onScreen then continue end

        if not self.Objects[player] then
            self.Objects[player] = {
                Box = Drawing.new("Square"),
                Name = Drawing.new("Text"),
                Health = Drawing.new("Text"),
                Distance = Drawing.new("Text")
            }
        end

        local esp = self.Objects[player]
        
        if self.Settings.Box then
            esp.Box.Visible = true
            esp.Box.Color = self.Settings.Color
            esp.Box.Thickness = 2
            esp.Box.Size = Vector2.new(100, 200)
            esp.Box.Position = Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(50, 100)
            esp.Box.Filled = false
            esp.Box.Transparency = 1 - self.Settings.Transparency
        else
            esp.Box.Visible = false
        end

        if self.Settings.Name then
            esp.Name.Visible = true
            esp.Name.Color = self.Settings.Color
            esp.Name.Size = 18
            esp.Name.Text = player.Name
            esp.Name.Position = Vector2.new(screenPos.X, screenPos.Y - 120)
            esp.Name.Center = true
            esp.Name.Outline = true
        else
            esp.Name.Visible = false
        end

        if self.Settings.Health then
            esp.Health.Visible = true
            esp.Health.Color = Color3.new(0, 1, 0)
            esp.Health.Size = 16
            esp.Health.Text = "Health: "..math.floor(player.Character.Humanoid.Health)
            esp.Health.Position = Vector2.new(screenPos.X, screenPos.Y - 100)
            esp.Health.Center = true
            esp.Health.Outline = true
        else
            esp.Health.Visible = false
        end

        if self.Settings.Distance then
            esp.Distance.Visible = true
            esp.Distance.Color = Color3.new(1, 1, 1)
            esp.Distance.Size = 16
            esp.Distance.Text = math.floor(distance).."studs"
            esp.Distance.Position = Vector2.new(screenPos.X, screenPos.Y - 80)
            esp.Distance.Center = true
            esp.Distance.Outline = true
        else
            esp.Distance.Visible = false
        end
    end
end

local ESPToggle = ESPGroup:AddToggle('ESPToggle', {
    Text = 'Enable',
    Default = false,
    Callback = function(state)
        ESPLib:Toggle(state)
    end
})

local ESPColor = ESPToggle:AddColorPicker('ESPColor', {
    Default = Color3.new(1, 0, 0),
    Callback = function(color)
        ESPLib.Settings.Color = color
    end
})

ESPToggle:OnChanged(function(state)
    ESPLib.Settings.Enabled = state
end)

ESPGroup:AddToggle('ESPBox', {
    Text = 'Box ESP',
    Default = true,
    Callback = function(state)
        ESPLib.Settings.Box = state
    end
})

ESPGroup:AddToggle('ESPName', {
    Text = 'Name ESP',
    Default = true,
    Callback = function(state)
        ESPLib.Settings.Name = state
    end
})

ESPGroup:AddToggle('ESPHealth', {
    Text = 'Health ESP',
    Default = true,
    Callback = function(state)
        ESPLib.Settings.Health = state
    end
})

ESPGroup:AddToggle('ESPDistance', {
    Text = 'Distance ESP',
    Default = true,
    Callback = function(state)
        ESPLib.Settings.Distance = state
    end
})
ESPGroup:AddToggle('ESPTeamCheck', {
    Text = 'Team Check',
    Default = false,
    Callback = function(state)
        ESPLib.Settings.TeamCheck = state
    end
})
ESPGroup:AddSlider('ESPDistanceLimit', {
    Text = 'Max Distance',
    Default = 1000,
    Min = 0,
    Max = 5000,
    Rounding = 0,
    Callback = function(value)
        ESPLib.Settings.MaxDistance = value
    end
})

ESPGroup:AddSlider('ESPRefreshRate', {
    Text = 'Refresh Rate (ms)',
    Default = 100,
    Min = 16,
    Max = 1000,
    Rounding = 0,
    Callback = function(value)
        ESPLib.Settings.RefreshRate = value
    end
})

ESPGroup:AddSlider('ESPTransparency', {
    Text = 'Transparency',
    Default = 0,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(value)
        ESPLib.Settings.Transparency = value
    end
})

ESPLib:Init()
--]]
local ESP = {
    Enabled = false,
    Objects = {},
    Connections = {},
    Settings = {
        Box = true,
        Name = true,
        HealthBar = true,
        TeamCheck = false,
        Color = Color3.new(1, 0, 0),
        MaxDistance = 1000,
        RefreshRate = 16,
        Outline = true
    }
}

function ESP:Init()
    self.Connections.playerAdded = game:GetService("Players").PlayerAdded:Connect(function(player)
        self:TrackPlayer(player)
    end)

    self.Connections.playerRemoving = game:GetService("Players").PlayerRemoving:Connect(function(player)
        self:RemovePlayer(player)
    end)

    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player ~= game:GetService("Players").LocalPlayer then
            self:TrackPlayer(player)
        end
    end

    self.Connections.renderStep = game:GetService("RunService").RenderStepped:Connect(function()
        if not self.Enabled then return end
        self:Update()
    end)
end

function ESP:TrackPlayer(player)
    self.Connections[player] = player.CharacterAdded:Connect(function(character)
        if self.Objects[player] then
            self:RemovePlayer(player)
        end
        self:CreateESP(player, character)
    end)

    if player.Character then
        self:CreateESP(player, player.Character)
    end
end

function ESP:RemovePlayer(player)
    if self.Objects[player] then
        for _, drawing in pairs(self.Objects[player]) do
            drawing:Remove()
        end
        self.Objects[player] = nil
    end

    if self.Connections[player] then
        self.Connections[player]:Disconnect()
        self.Connections[player] = nil
    end
end

function ESP:CreateESP(player, character)
    if not character:FindFirstChild("HumanoidRootPart") then return end

    self.Objects[player] = {
        BoxOutline = Drawing.new("Square"),
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        HealthBarOutline = Drawing.new("Square"),
        HealthBar = Drawing.new("Square"),
        HealthBarBackground = Drawing.new("Square")
    }

    local esp = self.Objects[player]

    esp.BoxOutline.Visible = false
    esp.BoxOutline.Thickness = 3
    esp.BoxOutline.Filled = false
    esp.BoxOutline.ZIndex = 1

    esp.Box.Visible = false
    esp.Box.Thickness = 1
    esp.Box.Filled = false
    esp.Box.ZIndex = 2

    esp.Name.Visible = false
    esp.Name.Size = 18
    esp.Name.Center = true
    esp.Name.Outline = self.Settings.Outline
    esp.Name.ZIndex = 3

    esp.HealthBarOutline.Visible = false
    esp.HealthBarOutline.Filled = false
    esp.HealthBarOutline.Thickness = 2
    esp.HealthBarOutline.ZIndex = 1

    esp.HealthBarBackground.Visible = false
    esp.HealthBarBackground.Filled = true
    esp.HealthBarBackground.Color = Color3.new(0, 0, 0)
    esp.HealthBarBackground.Transparency = 0.5
    esp.HealthBarBackground.ZIndex = 2

    esp.HealthBar.Visible = false
    esp.HealthBar.Filled = true
    esp.HealthBar.ZIndex = 3
end

function ESP:Update()
    local camera = workspace.CurrentCamera
    local localPlayer = game:GetService("Players").LocalPlayer

    for player, esp in pairs(self.Objects) do
        if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not player.Character:FindFirstChild("Humanoid") then
            esp.BoxOutline.Visible = false
            esp.Box.Visible = false
            esp.Name.Visible = false
            esp.HealthBarOutline.Visible = false
            esp.HealthBar.Visible = false
            esp.HealthBarBackground.Visible = false
            continue
        end

        if self.Settings.TeamCheck and player.Team == localPlayer.Team then
            esp.BoxOutline.Visible = false
            esp.Box.Visible = false
            esp.Name.Visible = false
            esp.HealthBarOutline.Visible = false
            esp.HealthBar.Visible = false
            esp.HealthBarBackground.Visible = false
            continue
        end

        local rootPart = player.Character.HumanoidRootPart
        local distance = (rootPart.Position - camera.CFrame.Position).Magnitude

        if distance > self.Settings.MaxDistance then
            esp.BoxOutline.Visible = false
            esp.Box.Visible = false
            esp.Name.Visible = false
            esp.HealthBarOutline.Visible = false
            esp.HealthBar.Visible = false
            esp.HealthBarBackground.Visible = false
            continue
        end

        local screenPos, onScreen = camera:WorldToViewportPoint(rootPart.Position)

        if not onScreen then
            esp.BoxOutline.Visible = false
            esp.Box.Visible = false
            esp.Name.Visible = false
            esp.HealthBarOutline.Visible = false
            esp.HealthBar.Visible = false
            esp.HealthBarBackground.Visible = false
            continue
        end

        local character = player.Character
        local humanoid = character.Humanoid
        local head = character:FindFirstChild("Head")
        local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")

        if not head or not torso then continue end

        local headPos = camera:WorldToViewportPoint(head.Position)
        local torsoPos = camera:WorldToViewportPoint(torso.Position)

        local height = (headPos.Y - torsoPos.Y) * 2
        local width = height * 0.5

        local boxPosition = Vector2.new(torsoPos.X - width / 2, torsoPos.Y - height / 2)
        local boxSize = Vector2.new(width, height)

        esp.BoxOutline.Visible = self.Settings.Box and self.Enabled
        esp.BoxOutline.Position = boxPosition - Vector2.new(1, 1)
        esp.BoxOutline.Size = boxSize + Vector2.new(2, 2)
        esp.BoxOutline.Color = Color3.new(0, 0, 0)

        esp.Box.Visible = self.Settings.Box and self.Enabled
        esp.Box.Position = boxPosition
        esp.Box.Size = boxSize
        esp.Box.Color = self.Settings.Color

        esp.Name.Visible = self.Settings.Name and self.Enabled
        esp.Name.Position = Vector2.new(torsoPos.X, boxPosition.Y - 20)
        esp.Name.Text = player.Name
        esp.Name.Color = self.Settings.Color

        local healthPercent = humanoid.Health / humanoid.MaxHealth
        local healthBarHeight = boxSize.Y * healthPercent
        local healthBarPosition = boxPosition - Vector2.new(6, 0)
        local healthBarSize = Vector2.new(3, boxSize.Y)

        esp.HealthBarOutline.Visible = self.Settings.HealthBar and self.Enabled
        esp.HealthBarOutline.Position = healthBarPosition - Vector2.new(1, 1)
        esp.HealthBarOutline.Size = healthBarSize + Vector2.new(2, 2)
        esp.HealthBarOutline.Color = Color3.new(0, 0, 0)

        esp.HealthBarBackground.Visible = self.Settings.HealthBar and self.Enabled
        esp.HealthBarBackground.Position = healthBarPosition
        esp.HealthBarBackground.Size = healthBarSize

        esp.HealthBar.Visible = self.Settings.HealthBar and self.Enabled
        esp.HealthBar.Position = healthBarPosition + Vector2.new(0, boxSize.Y - healthBarHeight)
        esp.HealthBar.Size = Vector2.new(3, healthBarHeight)
        esp.HealthBar.Color = Color3.new(1 - healthPercent, healthPercent, 0)

        continue
    end
end

function ESP:Toggle(state)
    self.Enabled = state
    if not state then
        for _, esp in pairs(self.Objects) do
            esp.BoxOutline.Visible = false
            esp.Box.Visible = false
            esp.Name.Visible = false
            esp.HealthBarOutline.Visible = false
            esp.HealthBar.Visible = false
            esp.HealthBarBackground.Visible = false
        end
    end
end

function ESP:Destroy()
    for _, connection in pairs(self.Connections) do
        connection:Disconnect()
    end

    for _, esp in pairs(self.Objects) do
        for _, drawing in pairs(esp) do
            drawing:Remove()
        end
    end

    table.clear(self.Connections)
    table.clear(self.Objects)
end

ESP:Init()
local ESPGroup = Tabs.Main:AddLeftGroupbox('Drawing Visuals')
local ESPToggle = ESPGroup:AddToggle('ESPToggle', {
    Text = 'Enable ESP',
    Default = false,
    Callback = function(state)
        ESP:Toggle(state)
    end
})

local ESPColor = ESPToggle:AddColorPicker('ESPColor', {
    Default = Color3.new(1, 0, 0),
    Callback = function(color)
        ESP.Settings.Color = color
    end
})

ESPGroup:AddToggle('ESPBox', {
    Text = 'Box ESP',
    Default = true,
    Callback = function(state)
        ESP.Settings.Box = state
    end
})

ESPGroup:AddToggle('ESPName', {
    Text = 'Name ESP',
    Default = true,
    Callback = function(state)
        ESP.Settings.Name = state
    end
})

ESPGroup:AddToggle('ESPHealthBar', {
    Text = 'Health Bar',
    Default = true,
    Callback = function(state)
        ESP.Settings.HealthBar = state
    end
})

ESPGroup:AddToggle('ESPTeamCheck', {
    Text = 'Team Check',
    Default = false,
    Callback = function(state)
        ESP.Settings.TeamCheck = state
    end
})

ESPGroup:AddSlider('ESPDistanceLimit', {
    Text = 'Max Distance',
    Default = 1000,
    Min = 0,
    Max = 5000,
    Rounding = 0,
    Callback = function(value)
        ESP.Settings.MaxDistance = value
    end
})

ESPGroup:AddSlider('ESPRefreshRate', {
    Text = 'Refresh Rate (ms)',
    Default = 16,
    Min = 16,
    Max = 1000,
    Rounding = 0,
    Callback = function(value)
        ESP.Settings.RefreshRate = value
    end
})
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
ThemeManager:ApplyToTab(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
