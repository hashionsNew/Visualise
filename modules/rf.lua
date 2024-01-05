local LocalPlayer = game:GetService('Players').LocalPlayer
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local TweenService = game:GetService('TweenService')
local RunService = game:GetService('RunService')
local Lighting = game:GetService('Lighting')

local debris_folder = Instance.new('Folder', ReplicatedStorage)
debris_folder.Name = 'debris_folder'

local parried = false

local modules = {
    main = loadstring(game:HttpGet('https://raw.githubusercontent.com/hashionsNew/Visualise/main/modules/main.lua'))(),
    blade_ball = loadstring(game:HttpGet('https://raw.githubusercontent.com/hashionsNew/Visualise/main/modules/blade_ball_module.lua'))()
}

local assets = {
    atmosphere = Instance.new('Atmosphere', Lighting),
    ambient = game:GetObjects('rbxassetid://15870529331')[1],
    ball_reflection = game:GetObjects('rbxassetid://15872743417')[1],
    kill_effects = {
        cosmic_splash = game:GetObjects('rbxassetid://15872071996')[1]
    },
    debug_sphere = game:GetObjects('rbxassetid://15873671236')[1],
    trail = game:GetObjects('rbxassetid://15878111905')[1],
    jump_circle = {
        orbs = game:GetObjects('rbxassetid://15878148376')[1]
    }
}

assets.atmosphere.Color = Color3.fromRGB(75, 80, 106)
assets.atmosphere.Decay = Color3.fromRGB(106, 112, 125)
assets.atmosphere.Haze = 0

assets.ambient.Position = Vector3.new(0, 10000, 0)
assets.ambient.Parent = debris_folder

assets.ball_reflection:MoveTo(Vector3.new(0, 10000, 0))
assets.ball_reflection.Parent = debris_folder

assets.kill_effects.cosmic_splash.Parent = debris_folder

assets.debug_sphere.Position = Vector3.new(0, 10000, 0)
assets.debug_sphere.Parent = debris_folder

assets.trail.Parent = debris_folder

assets.jump_circle.orbs.Parent = debris_folder

local ui_library = loadstring(game:HttpGet('https://raw.githubusercontent.com/hashionsNew/Visualise/main/ui_library.lua'))()
local main = ui_library.create()

local combat_tab = main.create_tab({name = 'Rage'})
combat_tab.create_label({name = 'AutoParry', section = 'left'})


local auto_parry_toggle = combat_tab.create_toggle({name = 'Enabled', flag = 'auto_parry', checkbox = false, section = 'left', callback = function(state: boolean)
end})


local auto_parry_accuracy_slider = combat_tab.create_slider({name = 'Accuracy', flag = 'auto_parry_accuracy', maximum = 100, minimum = 1, value = 100, section = 'left', callback = function(state: number)
end})


local world_tab = main.create_tab({name = 'World'})
world_tab.create_label({name = 'WorldTime', section = 'left'})


local world_time_toggle = world_tab.create_toggle({name = 'Enabled', flag = 'world_time', checkbox = false, section = 'left', callback = function(state: boolean)
    if state then
        TweenService:Create(Lighting, TweenInfo.new(0.5), {ClockTime = ui_library.flags['world_time_value']}):Play()
    else
        TweenService:Create(Lighting, TweenInfo.new(0.5), {ClockTime = 7}):Play()
    end
end})


local world_time_value_slider = world_tab.create_slider({name = 'Time', flag = 'world_time_value', maximum = 12, minimum = 0, value = 0, section = 'left', callback = function(state: number)
    TweenService:Create(Lighting, TweenInfo.new(0.5), {ClockTime = state}):Play()
end})


world_tab.create_label({name = 'Ambient', section = 'left'})


local ambient_toggle = world_tab.create_toggle({name = 'Enabled', flag = 'ambient', checkbox = false, section = 'left', callback = function(state: boolean)
    if not state then
        assets.ambient.Position = Vector3.new(0, 10000, 0)
        assets.ambient.Parent = debris_folder

        TweenService:Create(assets.atmosphere, TweenInfo.new(0.5), {Haze = 0}):Play()
        
        return
    end

    assets.ambient.Parent = workspace
    TweenService:Create(assets.atmosphere, TweenInfo.new(0.5), {Haze = 10}):Play()
end})


local atmosphere_slider = world_tab.create_slider({name = 'Atmosphere', flag = 'atmosphere', maximum = 1, minimum = 0, value = 0.6, section = 'left', callback = function(state: number)
    TweenService:Create(assets.atmosphere, TweenInfo.new(0.5), {Density = state}):Play()
end})


world_tab.create_label({name = 'CustomBall', section = 'middle'})


local custom_ball_toggle = world_tab.create_toggle({name = 'Enabled', flag = 'custom_ball', checkbox = false, section = 'middle', callback = function(state: boolean)
    if not state then
        assets.ball_reflection:MoveTo(Vector3.new(0, 10000, 0))
        assets.ball_reflection.Parent = debris_folder

        local ball = modules.blade_ball.get_ball(false)

        if not ball then
            return
        end

        ball.Transparency = 0

        return
    end

    assets.ball_reflection.Parent = workspace
end})


world_tab.create_label({name = 'KillEffect', section = 'right'})


local kill_effect_toggle = world_tab.create_toggle({name = 'Enabled', flag = 'kill_effect', checkbox = false, section = 'right', callback = function(state: boolean)
end})


world_tab.create_label({name = 'JumpCircle', section = 'right'})


local jump_circle_toggle = world_tab.create_toggle({name = 'Enabled', flag = 'jump_circle', checkbox = false, section = 'right', callback = function(state: boolean)
    if not state then
        return
    end
end})


RunService.Heartbeat:Connect(function()
    if not ui_library.flags['auto_parry'] then
        return
    end

    if not modules.main.alive(LocalPlayer) then
        return
    end

    local ball = modules.blade_ball.get_ball(true)

    if not ball then
        return
    end

    local ping = modules.main.ping() / 50
    local player_hitbox = 6
    local accuracy = player_hitbox + ball.Velocity.Magnitude / 3 + ping
    local distance = LocalPlayer:DistanceFromCharacter(ball.Position)

    --[[local sorted_players = {}

    for _, v in workspace.Alive:GetChildren() do
        if v.Name ~= LocalPlayer.Name then
            table.insert(sorted_players, v)
        end
    end

    if #sorted_players > 1 then
        table.sort(sorted_players, function(player_0, player_1)
            local player_0_distance = LocalPlayer:DistanceFromCharacter(player_0.HumanoidRootPart.Position)
            local player_1_distance = LocalPlayer:DistanceFromCharacter(player_1.HumanoidRootPart.Position)

            return player_0_distance > player_1_distance
        end)
    end

    if LocalPlayer:DistanceFromCharacter(sorted_players[1].HumanoidRootPart.Position) <= spam_distance then
        modules.blade_ball.parry(nil, true)

        print('spamming')

        return
    end]]

    if parried then
        return
    end

    if distance <= accuracy and ball:GetAttribute('target') == LocalPlayer.Name then
        modules.blade_ball.parry(nil, true)
        parried = true
    
        ball:GetAttributeChangedSignal('target'):Connect(function()
            parried = false
        end)
    
        local last_parry = tick()
    
        task.spawn(function()
            repeat
                RunService.Heartbeat:Wait()
            until (tick() - last_parry) >= 2 or not parried
    
            parried = false
        end)
    end
end)


RunService.RenderStepped:Connect(function()
    if ui_library.flags['custom_ball'] then
        local ball = modules.blade_ball.get_ball(false)

        if not ball then
            return
        end

        for _, v in workspace.Balls:GetChildren() do
            local hightlight = v:FindFirstChildOfClass('Highlight')

            if hightlight then
                hightlight:Destroy()
            end
        end

        ball.Transparency = 1
        assets.ball_reflection:MoveTo(ball.Position)
    end

    if not modules.main.alive(LocalPlayer) then
        return
    end

    if ui_library.flags['ambient'] then
        assets.ambient.Position = LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 60, 0)
    end
end)


for _, v in game:GetService('Players'):GetPlayers() do
    if not modules.main.alive(v) then
        return
    end

    v.Character.Humanoid.Died:Connect(function()
        if not ui_library.flags['kill_effect'] then
            return
        end

        local kill_effect_clone = assets.kill_effects.cosmic_splash.main:Clone()
        kill_effect_clone.Parent = v.Character.HumanoidRootPart

        for _, particle in kill_effect_clone:GetChildren() do
            if particle:IsA('ParticleEmitter') then
                particle:Emit(particle:GetAttribute('EmitCount'))
            end
        end
    end)
end


game:GetService('Players').PlayerAdded:Connect(function(player: Player)
    if player == LocalPlayer then
        return
    end

    player.CharacterAdded:Connect(function(character: any)
        repeat
            task.wait()
        until modules.main.alive(player) or character == nil

        character.Humanoid.Died:Connect(function()
            if not ui_library.flags['kill_effect'] then
                return
            end

            local kill_effect_clone = assets.kill_effects.cosmic_splash.main:Clone()
            kill_effect_clone.Parent = character.HumanoidRootPart
    
            for _, particle in kill_effect_clone:GetChildren() do
                if particle:IsA('ParticleEmitter') then
                    particle:Emit(particle:GetAttribute('EmitCount'))
                end
            end
        end)
    end)
end)


LocalPlayer.CharacterAdded:Connect(function(character: any)
    repeat
        task.wait()
    until modules.main.alive(player) or character == nil

    character.Humanoid.Jumping:Connect(function()
        print(1)

        local jump_circle_clone = assets.jump_circle.orbs:Clone()
        jump_circle_clone.Position = character.HumanoidRootPart.Position - Vector3.new(0, 3, 0)
        jump_circle_clone.Parent = workspace.Terrain

        jump_circle_clone:Emit(50)
    end)
end)


task.spawn(function()
    repeat
        task.wait()
    until modules.main.alive(LocalPlayer)

    LocalPlayer.Character.Humanoid.Jumping:Connect(function()
        print(2)

        local jump_circle_clone = assets.jump_circle.orbs:Clone()
        jump_circle_clone.Position = character.HumanoidRootPart.Position - Vector3.new(0, 3, 0)
        jump_circle_clone.Parent = workspace.Terrain

        jump_circle_clone:Emit(50)
    end)
end)
