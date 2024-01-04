local LocalPlayer = game:GetService('Players').LocalPlayer
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')

local modules = {
    main = loadstring(game:HttpGet('https://raw.githubusercontent.com/hashionsNew/Visualise/main/modules/main.lua'))(),
    blade_ball = loadstring(game:HttpGet('https://raw.githubusercontent.com/hashionsNew/Visualise/main/modules/blade_ball_module.lua'))()
}

local parried = false

local ui_library = loadstring(game:HttpGet('https://raw.githubusercontent.com/hashionsNew/Visualise/main/ui_library.lua'))()
local main = ui_library.create()

local combat_tab = main.create_tab({name = 'Combat'})

combat_tab.create_label({name = 'AutoParry'})

local auto_parry_toggle = combat_tab.create_toggle({name = 'Enabled', checkbox = false, flag = 'auto_parry', section = 'left', callback = function(state: boolean)
end})

local slider = combat_tab.create_slider({name = 'Accuracy', section = 'left', maximum = 100, minimum = 1, value = 80, callback = function(state: boolean)
end})


RunService.Heartbeat:Connect(function()
    if not ui_library.flags['auto_parry'] then
        return
    end

    if not modules.main.alive(LocalPlayer) then
        print('player is not alive')

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
