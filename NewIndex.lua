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
VisualGroup:AddSlider('FOV', {Text = 'FOV Size', Default = Settings.FOV, Min = 10, Max = 500, Rounding = 0, Callback = function(v) Settings.FOV = v end})
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

local v1 = game:GetService("TweenService")
local v2 = game:GetService("RunService")

local function CreateRichTracer(v3, v4)
    if not Settings.BulletTracers then return end
    
    local v5 = (v4 - v3).Magnitude
    local v6 = Instance.new('Part')
    v6.Size = Vector3.new(Settings.TracerWidth/3, Settings.TracerWidth/3, 0.1)
    v6.CFrame = CFrame.new(v3, v4)
    v6.Anchored = true
    v6.CanCollide = false
    v6.Material = Enum.Material.Neon
    v6.Color = Settings.TracerColor
    v6.Transparency = 0.3

    local v19 = Instance.new('MeshPart')
    v19.MeshId = "rbxassetid://3726303787"
    v19.TextureId = "rbxassetid://3726303793"
    v19.Size = Vector3.new(Settings.TracerWidth*2, Settings.TracerWidth*2, Settings.TracerWidth*2)
    v19.CFrame = v6.CFrame * CFrame.new(0, 0, -0.5)
    v19.Anchored = true
    v19.CanCollide = false
    v19.Color = Settings.TracerColor
    v19.Transparency = 0.5
    v19.Parent = workspace

    local v7 = Instance.new("Trail", v6)
    v7.Color = ColorSequence.new(Settings.TracerColor)
    v7.LightEmission = 1
    v7.Lifetime = Settings.TracerDuration * 0.3
    v7.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(1, 1)
    })
    local v8 = Instance.new("Attachment", v6)
    local v9 = Instance.new("Attachment", v6)
    v8.Position = Vector3.new(0, 0, 0.5)
    v9.Position = Vector3.new(0, 0, -0.5)
    v7.Attachment0 = v8
    v7.Attachment1 = v9

    local v10 = v1:Create(v6, TweenInfo.new(Settings.TracerDuration * 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(Settings.TracerWidth, Settings.TracerWidth, v5),
        CFrame = CFrame.new(v3, v4) * CFrame.new(0, 0, -v5/2),
        Transparency = 0.7
    })

    local v20 = v1:Create(v19, TweenInfo.new(Settings.TracerDuration * 0.15, Enum.EasingStyle.Quad), {
        CFrame = CFrame.new(v3, v4) * CFrame.new(0, 0, -v5/2 - 0.5),
        Transparency = 0.8
    })
    
    local v11 = v1:Create(v6, TweenInfo.new(Settings.TracerDuration * 0.85, Enum.EasingStyle.Linear), {
        Transparency = 1
    })

    local v21 = v1:Create(v19, TweenInfo.new(Settings.TracerDuration * 0.85, Enum.EasingStyle.Linear), {
        Transparency = 1
    })

    if Settings.RichBullet then
        local v13 = Instance.new('SurfaceGui', v6)
        v13.Face = Enum.NormalId.Top
        v13.AlwaysOnTop = true
        v13.Adornee = v6
        
        local v14 = Instance.new('Frame', v13)
        v14.Size = UDim2.new(1, 0, 1, 0)
        v14.BackgroundColor3 = Settings.TracerColor
        v14.BackgroundTransparency = 0.5
        v14.BorderSizePixel = 0
        
        local v15 = Instance.new('PointLight', v6)
        v15.Color = Settings.TracerColor
        v15.Range = 15
        v15.Brightness = 5
        v15.Shadows = true
        
        local v16 = Instance.new('Beam', v6)
        v16.FaceCamera = true
        v16.Color = ColorSequence.new(Settings.TracerColor)
        v16.Width0 = 0.2
        v16.Width1 = 0.2
        v16.Texture = "rbxassetid://446111271"
        v16.TextureSpeed = 1
        v16.LightEmission = 1
        v16.Attachment0 = v8
        v16.Attachment1 = v9
        
        local v17 = 0
        local v18 = v2.RenderStepped:Connect(function()
            v17 = v17 + 0.1
            v19.CFrame = v19.CFrame * CFrame.Angles(0, 0.1, 0)
        end)
        
        game:GetService('Debris'):AddItem(v18, Settings.TracerDuration)
    end
    
    v6.Parent = workspace
    v10:Play()
    v20:Play()
    v11:Play()
    v21:Play()
    game:GetService('Debris'):AddItem(v6, Settings.TracerDuration)
    game:GetService('Debris'):AddItem(v19, Settings.TracerDuration)
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
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://160432334"  
    sound.Volume = 0.75
    sound.Parent = workspace
    sound:Play()
    Library:Notify(string.format("Hit %s [%s] | Distance %d | Health %s", name, hitPart, distance, health))
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

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
ThemeManager:ApplyToTab(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
