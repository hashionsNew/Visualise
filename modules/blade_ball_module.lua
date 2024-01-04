local LocalPlayer = game:GetService('Players').LocalPlayer
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local blade_ball_module = {}

local net = ReplicatedStorage.Packages._Index['sleitnick_net@0.1.0'].net

local parry_attempt = ReplicatedStorage.Remotes.ParryAttempt
local parry_button_press = ReplicatedStorage.Remotes.ParryButtonPress
local ability_button_press = ReplicatedStorage.Remotes.AbilityButtonPress


function blade_ball_module.get_ball(real_ball: boolean)
    for _, v in workspace.Balls:GetChildren() do
        if v:GetAttribute('realBall') == real_ball then
            return v
        end
    end
end


function blade_ball_module.parry(direction: Raycast, external: boolean)
    if external then
        parry_attempt:FireServer(unpack({
            [1] = 0.5,
            [2] = CFrame.new(Vector3.zero, Vector3.zero),
            [3] = {
                ["Player_0"] = Vector3.zero
            },
            [4] = {
                [1] = 0,
                [2] = 0
            }
        }))
    else
        parry_button_press:Fire()
    end
end


function blade_ball_module.ability()
    ability_button_press:Fire()
end


function blade_ball_module.claim_playtime_rewards()
    for _ = 1, 6 do
        net['RF/ClaimPlaytimeReward']:InvokeServer(_)        
    end
end


return blade_ball_module
