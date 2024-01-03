local LocalPlayer = game:GetService('Players').LocalPlayer
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local blade_ball_module = {}

local parry_attempt = ReplicatedStorage.Remotes.ParryAttempt
local parry_button_press = ReplicatedStorage.Remotes.ParryButtonPress


function blade_ball_module.get_ball()
    for _, v in workspace.Balls:GetChidlren() do
        if v:GetAttribute('realBall') then
            return v
        end
    end
end


function blade_ball_module.parry(direction: Raycast, external: boolean)
    if external then
        
    else
        parry_button_press:Fire()
    end
end


function blade_ball_module.ability(direction: Raycast)

end


return blade_ball_module
