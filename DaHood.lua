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
    Wallbang = false,
    FOVColor = Color3.fromRGB(255,255,0),
    FOVRainbow = false,
    FOVMode = "Middle"
}

local AimGroup = Tabs.Main:AddLeftGroupbox('Aim Settings')
AimGroup:AddToggle('Enabled', {Text = 'Enabled', Default = Settings.Enabled, Callback = function(v) Settings.Enabled = v end})
AimGroup:AddSlider('HitChance', {Text = 'Hit Chance', Default = Settings.HitChance, Min = 0, Max = 100, Rounding = 0, Callback = function(v) Settings.HitChance = v end})
AimGroup:AddInput('Prediction', {Text = 'Prediction', Default = tostring(Settings.Prediction), Numeric = true, Callback = function(v) Settings.Prediction = tonumber(v) or 0.165 end})
AimGroup:AddDropdown('TargetPart', {Text = 'Target Part', Values = {'Head','HumanoidRootPart','UpperTorso','LowerTorso'}, Default = 1, Callback = function(v) Settings.TargetPart = v end})
AimGroup:AddToggle('Wallbang', {Text = 'Da Hood Wallbang', Default = Settings.Wallbang, Callback = function(v) Settings.Wallbang = v end})

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

local function CreateRichTracer(startPos, endPos)
    if not Settings.BulletTracers then return end
    
    local distance = (startPos - endPos).Magnitude
    local tracer = Instance.new('Part')
    tracer.Size = Vector3.new(Settings.TracerWidth, Settings.TracerWidth, distance)
    tracer.CFrame = CFrame.new(startPos, endPos) * CFrame.new(0, 0, -distance/2)
    tracer.Anchored = true
    tracer.CanCollide = false
    tracer.Material = Enum.Material.Neon
    tracer.Color = Settings.TracerColor
    tracer.Transparency = 0.3
    
    if Settings.RichBullet then
        local glow = Instance.new('SurfaceGui', tracer)
        glow.Face = Enum.NormalId.Front
        glow.AlwaysOnTop = true
        glow.Adornee = tracer
        
        local frame = Instance.new('Frame', glow)
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundColor3 = Settings.TracerColor
        frame.BackgroundTransparency = 0.5
        frame.BorderSizePixel = 0
        
        local light = Instance.new('PointLight', tracer)
        light.Color = Settings.TracerColor
        light.Range = 15
        light.Brightness = 5
    end
    
    tracer.Parent = workspace
    game:GetService('Debris'):AddItem(tracer, Settings.TracerDuration)
end


local function CanHit(target)
    if not Settings.Wallbang then return true end
    
    local origin = Camera.CFrame.Position
    local direction = (target.Position - origin).Unit * 1000
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    local raycastResult = workspace:Raycast(origin, direction, raycastParams)
    if raycastResult then
        local hitPart = raycastResult.Instance
        local character = hitPart:FindFirstAncestorOfClass("Model")
        if character and character:FindFirstChildOfClass("Humanoid") then
            return true
        end
    end
    return false
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
    
    Library:Notify(string.format("Hit %s [%s] | %d | %s", name, hitPart, distance, health))
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

local VisualGroup = Tabs.Main:AddRightGroupbox('Character Visuals')
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
                    local center = Settings.FOVMode == "Middle" and Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2) or UserInputService:GetMouseLocation()
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist < closestDist and (Settings.Wallbang and CanHit(targetPart) or not Settings.Wallbang then
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
