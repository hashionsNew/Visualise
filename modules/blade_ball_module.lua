local LocalPlayer = game:GetService('Players').LocalPlayer
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local blade_ball_module = {}


function blade_ball_module.get_ball()
    for _, v in workspace.Balls:GetChidlren() do
        if v:GetAttribute('realBall') then
            return v
        end
    end
end


function blade_ball_module.parry(direction: Raycast)

end


function blade_ball_module.ability(direction: Raycast)

end


return blade_ball_module
