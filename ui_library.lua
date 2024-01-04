local LocalPlayer = game:GetService('Players').LocalPlayer
local CoreGui = game:GetService('CoreGui')
local TweenService = game:GetService('TweenService')
local UserInputService = game:GetService('UserInputService')

local mouse = LocalPlayer:GetMouse()

local library = {}
library.flags = {}


function library.create()
    local main = game:GetObjects('rbxassetid://15868241556')[1]
    main.Parent = CoreGui

    UserInputService.InputBegin:Connect(function(input: InputObject, process: boolean)
        if process then
            return
        end

        if input.KeyCode == Enum.KeyCode.J then
            main.Enabled = not main.Enabled
        end
    end)

    local sections_folder = Instance.new('Folder', main.container)
    sections_folder.Name = 'sections_folder'

    local tab_module = {}

    function tab_module.create_tab(arguments) -- name: string
        arguments.name = arguments.name or 'Tab'

        local tab = game:GetObjects('rbxassetid://15868301328')[1]
        tab.name.Text = arguments.name
        tab.Parent = main.container.hold.tabs

        local left_section = game:GetObjects('rbxassetid://15868347492')[1]
        left_section.Visible = false
        left_section.Parent = sections_folder

        local middle_section = game:GetObjects('rbxassetid://15868353701')[1]
        middle_section.Visible = false
        middle_section.Parent = sections_folder

        local right_section = game:GetObjects('rbxassetid://15868355337')[1]
        right_section.Visible = false
        right_section.Parent = sections_folder

        tab.MouseButton1Click:Connect(function()
            for _, v in sections_folder:GetChildren() do
                if v:IsA('ScrollingFrame') then
                    v.Visible = false
                end
            end

            for _, v in main.container.hold.tabs:GetChildren() do
                if v.Name == 'tab' then
                    TweenService:Create(v.name, TweenInfo.new(0.4), {TextColor3 = Color3.fromRGB(134, 131, 132)}):Play()
                end
            end

            TweenService:Create(tab.name, TweenInfo.new(0.4), {TextColor3 = Color3.fromRGB(224, 224, 224)}):Play()

            left_section.Visible = true
            middle_section.Visible = true
            right_section.Visible = true
        end)

        local functions_module = {}
        
        function functions_module.create_label(arguments) -- name: string
            arguments.name = arguments.name or 'Label'
            arguments.section = arguments.section or 'left'

            local label = game:GetObjects('rbxassetid://15869093874')[1]
            label.Text = arguments.name
            label.Parent = arguments.section == 'left' and left_section or arguments.section == 'middle' and middle_section or right_section
        end

        function functions_module.create_toggle(arguments) -- name: string, checkbox: boolean, flag: string, section: string, callback: function
            arguments.name = arguments.name or 'Toggle'
            arguments.checkbox = arguments.checkbox or false
            arguments.flag = arguments.flag or name
            arguments.section = arguments.section or 'left'
            arguments.callback = arguments.callback or function() end

            library.flags[arguments.flag] = arguments.checkbox

            local toggle = game:GetObjects('rbxassetid://15868949832')[1]
            toggle.name.Text = arguments.name
            toggle.box.BackgroundTransparency = checkbox and 0 or 1
            toggle.Parent = arguments.section == 'left' and left_section or arguments.section == 'middle' and middle_section or right_section
            
            toggle.MouseButton1Click:Connect(function()
                arguments.checkbox = not arguments.checkbox
                library.flags[arguments.flag] = arguments.checkbox

                if arguments.checkbox then
                    TweenService:Create(toggle.box, TweenInfo.new(0.4), {BackgroundTransparency = 0}):Play()
                else
                    TweenService:Create(toggle.box, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
                end

                arguments.callback(arguments.checkbox)
            end)
        end

        function functions_module.create_slider(arguments) -- name: string, section: string, maximum: number, minimum: number, value: number, flag: string, callback: function
            arguments.name = arguments.name or 'Slider'
            arguments.section = arguments.section or 'left'
            arguments.maximum = arguments.maximum or 10
            arguments.minimum = arguments.minimum or 1
            arguments.value = arguments.value or arguments.maximum / 2
            arguments.flag = arguments.flag or arguments.name
            arguments.callback = arguments.callback or function() end

            library.flags[arguments.flag] = arguments.value

            local slider = game:GetObjects('rbxassetid://15869121143')[1]
            slider.name.Text = arguments.name
            slider.Parent = arguments.section == 'left' and left_section or arguments.section == 'middle' and middle_section or right_section

            slider.box.hitbox.MouseButton1Click:Connect(function()
                local mouse_position = UserInputService:GetMouseLocation().X
                local slider_size = slider.box.hitbox.AbsoluteSize.X
                local slider_position = slider.box.hitbox.AbsolutePosition.X
                local percent = math.clamp((mouse_position - slider_position), 0, 180)
                
                slider.box.inner.Size = UDim2.new(percent / 180, 0, 1, 0)

                local return_value = (((arguments.maximum - arguments.minimum) / 180) * slider.box.inner.AbsoluteSize.X) + arguments.minimum
                local a = math.floor(return_value)
                local c = string.len(a) + 2

                slider.amout.Text = tostring(string.sub(return_value, 1, c))
                library.flags[arguments.flag] = arguments.value

                arguments.callback(tonumber(string.sub(return_value, 1, c)))

                connection_start = mouse.Move:Connect(function()
                    local mouse_position = UserInputService:GetMouseLocation().X
                    local slider_size = slider.box.hitbox.AbsoluteSize.X
                    local slider_position = slider.box.hitbox.AbsolutePosition.X
                    local percent = math.clamp((mouse_position - slider_position), 0, 180)
                    
                    slider.box.inner.Size = UDim2.new(percent / 180, 0, 1, 0)
    
                    local return_value = (((arguments.maximum - arguments.minimum) / 180) * slider.box.inner.AbsoluteSize.X) + arguments.minimum
                    local a = math.floor(return_value)
                    local c = string.len(a) + 2
    
                    slider.amout.Text = tostring(string.sub(return_value, 1, c))
                    library.flags[arguments.flag] = arguments.value
    
                    arguments.callback(tonumber(string.sub(return_value, 1, c)))
                end)

                connection_end = UserInputService.InputEnded:Connect(function(input: InputObject)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        connection_start:Disconnect()
                        connection_end:Disconnect()
                    end
                end)
            end)
        end

        return functions_module
    end

    return tab_module
end


return library
