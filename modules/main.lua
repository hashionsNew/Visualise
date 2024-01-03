local LocalPlayer = game:GetService('Players').LocalPlayer
local PerformanceStats = game:GetService('Stats').PerformanceStats

local main_module = {}


function main_module.alive(player)
    if player and player.Character then
        if player.Character:FindFirstChild('HumanoidRootPart') and player.Character:FindFirstChild('Humanoid') and player.Character.Humanoid.Health > 0 then
            return true
        end
    end
end


function main_module.ping()
    return PerformanceStats.Ping:GetValue()
end


return main_module
