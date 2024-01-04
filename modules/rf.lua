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
    ball_reflection = game:GetObjects('rbxassetid://15871825030')[1],
    kill_effects = {
        cosmic_splash = game:GetObjects('rbxassetid://15872071996')[1]
    }
}

assets.atmosphere.Color = Color3.fromRGB(75, 80, 106)
assets.atmosphere.Decay = Color3.fromRGB(106, 112, 125)
assets.atmosphere.Haze = 0

assets.ambient.Position = Vector3.new(0, 10000, 0)
assets.ambient.Parent = debris_folder

assets.ball_reflection.ball.Position = Vector3.new(0, 10000, 0)
assets.ball_reflection.Parent = debris_folder

local ui_library = loadstring(game:HttpGet('https://raw.githubusercontent.com/hashionsNew/Visualise/main/ui_library.lua'))()
local main = ui_library.create()

local combat_tab = main.create_tab({name = 'Rage'})
combat_tab.create_label({name = 'AutoParry'})


local auto_parry_toggle = combat_tab.create_toggle({name = 'Enabled', flag = 'auto_parry', checkbox = false, section = 'left', callback = function(state: boolean)
end})


local auto_parry_accuracy_slider = combat_tab.create_slider({name = 'Accuracy', flag = 'auto_parry_accuracy', maximum = 100, minimum = 1, value = 100, section = 'left', callback = function(state: number)
end})


local world_tab = main.create_tab({name = 'World'})
world_tab.create_label({name = 'WorldTime'})


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


world_tab.create_label({name = 'Ambient'})


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


world_tab.create_label({name = 'CustomBall'})


local custom_ball_toggle = world_tab.create_toggle({name = 'Enabled', flag = 'custom_ball', checkbox = false, section = 'middle', callback = function(state: boolean)
    if not state then
        assets.ball_reflection.ball.Position = Vector3.new(0, 10000, 0)
        assets.ball_reflection.Parent = debris_folder

        local ball = modules.blade_ball_module.get_ball(false)

        if not ball then
            return
        end

        ball.Transparency = 0

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

    local ping = modules.main.ping() / 30
    local player_hitbox = 6
    local accuracy = player_hitbox + ball.Velocity.Magnitude / 3.5 + ping
    local distance = LocalPlayer:DistanceFromCharacter(ball.Position)

    if parried then
        return
    end

    if distance <= accuracy and ball:GetAttribute('target') == LocalPlayer.Name then
        modules.blade_ball.parry(nil, false)
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
        local ball = modules.blade_ball_module.get_ball(false)

        if not ball then
            return
        end

        ball.Transparency = 1
        assets.ball_reflection.ball.Position = ball.Position
    end

    if not modules.main.alive(LocalPlayer) then
        return
    end

    if ui_library.flags['ambient'] then
        assets.ambient.Position = LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 60, 0)
    end
end)
