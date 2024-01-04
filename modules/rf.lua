local LocalPlayer = game:GetService('Players').LocalPlayer
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local Lighting = game:GetService('Lighting')

local modules = {
    main = loadstring(game:HttpGet('https://raw.githubusercontent.com/hashionsNew/Visualise/main/modules/main.lua'))(),
    blade_ball = loadstring(game:HttpGet('https://raw.githubusercontent.com/hashionsNew/Visualise/main/modules/blade_ball_module.lua'))()
}

local parried = false

local ui_library = loadstring(game:HttpGet('https://raw.githubusercontent.com/hashionsNew/Visualise/main/ui_library.lua'))()
local main = ui_library.create()

local combat_tab = main.create_tab({name = 'Combat'})

combat_tab.create_label({name = 'AutoParry'})

local auto_parry_toggle = combat_tab.create_toggle({name = 'Enabled', flag = 'auto_parry', checkbox = false, section = 'left', callback = function(state: boolean)
end})

local auto_parry_accuracy_slider = combat_tab.create_slider({name = 'Accuracy', flag = 'auto_parry_accuracy', maximum = 100, minimum = 1, value = 100, section = 'left', callback = function(state: boolean)
end})

local world_tab = main.create_tab({name = 'World'})

world_tab.create_label({name = 'WorldTime'})

local world_time_toggle = world_tab.create_toggle({name = 'Enabled', flag = 'world_time', checkbox = false, section = 'left', callback = function(state: boolean)
    local tween_time = 0.5 + (0.5 / (Lighting.ClockTime - state))

    if state then
        TweenService:Create(Lighting, TweenInfo.new(tween_time), {ClockTime = ui_library.flags['world_time_value']})
    else
        TweenService:Create(Lighting, TweenInfo.new(tween_time), {ClockTime = 7})
    end
end})

local world_time_value_slider = world_tab.create_slider({name = 'Time', flag = 'world_time_value', maximum = 12, minimum = 0, value = 0, section = 'left', callback = function(state: boolean)
    local tween_time = 0.5 + (0.5 / (Lighting.ClockTime - state))
    
    TweenService:Create(Lighting, TweenInfo.new(tween_time), {ClockTime = state})
end})


RunService.Heartbeat:Connect(function()
    if not ui_library.flags['auto_parry'] then
        return
    end

    if not modules.main.alive(LocalPlayer) then
        return
    end

    local ball = modules.blade_ball.get_ball()

    if not ball then
        return
    end

    local ping = modules.main.ping() / 50
    local player_hitbox = 6
    local accuracy = player_hitbox + ball.Velocity.Magnitude / 3 + ping
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
