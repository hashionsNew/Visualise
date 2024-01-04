local CoreGui = game:GetService('CoreGui')
local TweenService = game:GetService('TweenService')

local library = {}


function library.create()
    local main = game:GetObjects('rbxassetid://15868241556')[1]
    main.Parent = CoreGui

    local sections_folder = Instance.new('Folder', main.container)
    sections_folder.Name = 'sections_folder'

    local tab_module = {}

    function tab_module.create_tab(arguments) -- name: string
        arguments.name = arguments.name or 'Tab'

        local tab = game:GetObjects('rbxassetid://15868301328')[1]
        tab.name.Text = arguments.name
        tab.Parent = main.container.hold.tabs

        local left_section = game:GetObjects('rbxassetid://15868347492')[1]
        left_section.Parent = sections_folder

        local middle_section = game:GetObjects('rbxassetid://15868353701')[1]
        middle_section.Parent = sections_folder

        local right_section = game:GetObjects('rbxassetid://15868355337')[1]
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

        function functions_module.create_toggle(arguments) -- name: string, checkbox: boolean, flag: string, section: string, callback
            arguments.name = arguments.name or 'Toggle'
            arguments.checkbox = arguments.checkbox or false
            arguments.flag = arguments.flag or name
            arguments.section = arguments.section or 'left'
            arguments.callback = arguments.callback or function() end

            local toggle = game:GetObjects('15868416245')[1]
            toggle.name.Text = arguments.name
            toggle.box.BackgroundTransparency = checkbox and 0 or 1
            toggle.Parent = arguments.section == 'left' and left_section or arguments.section == 'middle' and middle_section or right_section
            
            toggle.MouseButton1Click:Connect(function()
                checkbox = not checkbox

                if checkbox then
                    TweenService:Create(toggle.box, TweenInfo.new(0.4), {BackgroundTransparency = 0}):Play()
                else
                    TweenService:Create(toggle.box, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
                end

                callback(checkbox)
            end)
        end

        return functions_module
    end

    return tab_module
end


return library
