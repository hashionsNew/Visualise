local LocalPlayer = game:GetService('Players').LocalPlayer
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')

local modules = {
    --ui_library = loadstring(game:HttpGet(''))(),
    main = loadstring(game:HttpGet('https://raw.githubusercontent.com/hashionsNew/Visualise/main/modules/main.lua'))(),
    blade_ball = loadstring(game:HttpGet('https://raw.githubusercontent.com/hashionsNew/Visualise/main/modules/blade_ball_module.lua'))()
}

local debug_circle = Instance.new('Part', workspace)
debug_circle.Shape = Enum.PartType.Ball
debug_circle.Material = Enum.Material.ForceField
debug_circle.CanCollide = false
debug_circle.Anchored = true
debug_circle.Name = 'debug_circle'

local parried = false


RunService.Heartbeat:Connect(function()
    local ball = modules.blade_ball.get_ball()

    if not ball then
        return
    end

    local ping = modules.main.ping() / 90
    local player_hitbox = 6
    local accuracy = player_hitbox + ball.Velocity.Magnitude / 2.5 + ping
    local distance = LocalPlayer:DistanceFromCharacter(ball.Position)

    debug_circle.Position = LocalPlayer.Character.HumanoidRootPart.Position
    debug_circle.Size = Vector3.new(accuracy, accuracy, accuracy)

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
