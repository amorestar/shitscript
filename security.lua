local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Утилиты
local function Tween(obj, props, duration)
    duration = duration or 0.2
    local tween = TweenService:Create(obj, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    tween:Play()
    return tween
end

local function MakeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Создание основного окна
function Library:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "KarpwareUI"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    if gethui then
        ScreenGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = game.CoreGui
    else
        ScreenGui.Parent = game.CoreGui
    end
    
    -- Главный фрейм
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 700, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 6)
    MainCorner.Parent = MainFrame
    
    -- Заголовок
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 6)
    TitleCorner.Parent = TitleBar
    
    local TitleFix = Instance.new("Frame")
    TitleFix.Size = UDim2.new(1, 0, 0, 6)
    TitleFix.Position = UDim2.new(0, 0, 1, -6)
    TitleFix.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    TitleFix.BorderSizePixel = 0
    TitleFix.Parent = TitleBar
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(0, 200, 1, 0)
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title or "Karpware 6.1.0"
    TitleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    TitleLabel.TextSize = 14
    TitleLabel.Font = Enum.Font.GothamMedium
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar
    
    local SubTitle = Instance.new("TextLabel")
    SubTitle.Name = "SubTitle"
    SubTitle.Size = UDim2.new(0, 200, 0, 15)
    SubTitle.Position = UDim2.new(0, 15, 0, 22)
    SubTitle.BackgroundTransparency = 1
    SubTitle.Text = "EXECUTOR | UNIVERSAL"
    SubTitle.TextColor3 = Color3.fromRGB(120, 120, 120)
    SubTitle.TextSize = 10
    SubTitle.Font = Enum.Font.Gotham
    SubTitle.TextXAlignment = Enum.TextXAlignment.Left
    SubTitle.Parent = TitleBar
    
    -- Кнопка закрытия
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "Close"
    CloseButton.Size = UDim2.new(0, 40, 0, 40)
    CloseButton.Position = UDim2.new(1, -40, 0, 0)
    CloseButton.BackgroundTransparency = 1
    CloseButton.Text = "+"
    CloseButton.TextColor3 = Color3.fromRGB(150, 150, 150)
    CloseButton.TextSize = 24
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Rotation = 45
    CloseButton.Parent = TitleBar
    
    CloseButton.MouseEnter:Connect(function()
        Tween(CloseButton, {TextColor3 = Color3.fromRGB(255, 255, 255)})
    end)
    
    CloseButton.MouseLeave:Connect(function()
        Tween(CloseButton, {TextColor3 = Color3.fromRGB(150, 150, 150)})
    end)
    
    CloseButton.MouseButton1Click:Connect(function()
        Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
        wait(0.3)
        ScreenGui:Destroy()
    end)
    
    MakeDraggable(MainFrame, TitleBar)
    
    -- Боковое меню
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 200, 1, -40)
    Sidebar.Position = UDim2.new(0, 0, 0, 40)
    Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, -10, 1, -10)
    TabContainer.Position = UDim2.new(0, 5, 0, 5)
    TabContainer.BackgroundTransparency = 1
    TabContainer.BorderSizePixel = 0
    TabContainer.ScrollBarThickness = 4
    TabContainer.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
    TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabContainer.Parent = Sidebar
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, 5)
    TabLayout.Parent = TabContainer
    
    TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 10)
    end)
    
    -- Область контента
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1, -210, 1, -50)
    ContentArea.Position = UDim2.new(0, 205, 0, 45)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = MainFrame
    
    local Window = {
        MainFrame = MainFrame,
        Sidebar = Sidebar,
        ContentArea = ContentArea,
        TabContainer = TabContainer,
        CurrentTab = nil,
        Tabs = {}
    }
    
    function Window:CreateTab(name, icon)
        local TabButton = Instance.new("TextButton")
        TabButton.Name = name
        TabButton.Size = UDim2.new(1, 0, 0, 40)
        TabButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        TabButton.BackgroundTransparency = 1
        TabButton.BorderSizePixel = 0
        TabButton.Text = ""
        TabButton.AutoButtonColor = false
        TabButton.Parent = TabContainer
        
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 4)
        TabCorner.Parent = TabButton
        
        local IconLabel = Instance.new("TextLabel")
        IconLabel.Name = "Icon"
        IconLabel.Size = UDim2.new(0, 30, 0, 30)
        IconLabel.Position = UDim2.new(0, 10, 0.5, -15)
        IconLabel.BackgroundTransparency = 1
        IconLabel.Text = icon or "⚙"
        IconLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        IconLabel.TextSize = 16
        IconLabel.Font = Enum.Font.GothamBold
        IconLabel.Parent = TabButton
        
        local NameLabel = Instance.new("TextLabel")
        NameLabel.Name = "Name"
        NameLabel.Size = UDim2.new(1, -50, 1, 0)
        NameLabel.Position = UDim2.new(0, 45, 0, 0)
        NameLabel.BackgroundTransparency = 1
        NameLabel.Text = name
        NameLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        NameLabel.TextSize = 13
        NameLabel.Font = Enum.Font.Gotham
        NameLabel.TextXAlignment = Enum.TextXAlignment.Left
        NameLabel.Parent = TabButton
        
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = name .. "Content"
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.ScrollBarThickness = 4
        TabContent.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabContent.Visible = false
        TabContent.Parent = ContentArea
        
        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Padding = UDim.new(0, 10)
        ContentLayout.Parent = TabContent
        
        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 10)
        end)
        
        local Tab = {
            Button = TabButton,
            Content = TabContent,
            Icon = IconLabel,
            Name = NameLabel,
            Sections = {}
        }
        
        TabButton.MouseEnter:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(TabButton, {BackgroundTransparency = 0.7})
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(TabButton, {BackgroundTransparency = 1})
            end
        end)
        
        TabButton.MouseButton1Click:Connect(function()
            Window:SelectTab(Tab)
        end)
        
        table.insert(Window.Tabs, Tab)
        
        if #Window.Tabs == 1 then
            Window:SelectTab(Tab)
        end
        
        function Tab:CreateSection(title)
            local Section = Instance.new("Frame")
            Section.Name = title
            Section.Size = UDim2.new(1, -10, 0, 40)
            Section.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            Section.BackgroundTransparency = 0.3
            Section.BorderSizePixel = 0
            Section.Parent = TabContent
            
            local SectionCorner = Instance.new("UICorner")
            SectionCorner.CornerRadius = UDim.new(0, 6)
            SectionCorner.Parent = Section
            
            local SectionTitle = Instance.new("TextLabel")
            SectionTitle.Name = "Title"
            SectionTitle.Size = UDim2.new(1, -20, 0, 30)
            SectionTitle.Position = UDim2.new(0, 15, 0, 5)
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.Text = title
            SectionTitle.TextColor3 = Color3.fromRGB(180, 180, 180)
            SectionTitle.TextSize = 13
            SectionTitle.Font = Enum.Font.GothamMedium
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            SectionTitle.Parent = Section
            
            local ElementContainer = Instance.new("Frame")
            ElementContainer.Name = "Elements"
            ElementContainer.Size = UDim2.new(1, 0, 1, -35)
            ElementContainer.Position = UDim2.new(0, 0, 0, 35)
            ElementContainer.BackgroundTransparency = 1
            ElementContainer.Parent = Section
            
            local ElementLayout = Instance.new("UIListLayout")
            ElementLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ElementLayout.Padding = UDim.new(0, 5)
            ElementLayout.Parent = ElementContainer
            
            ElementLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Section.Size = UDim2.new(1, -10, 0, ElementLayout.AbsoluteContentSize.Y + 45)
            end)
            
            local SectionObj = {
                Frame = Section,
                Container = ElementContainer,
                Elements = {}
            }
            
            function SectionObj:AddToggle(text, default, callback)
                local Toggle = Instance.new("Frame")
                Toggle.Name = "Toggle"
                Toggle.Size = UDim2.new(1, -20, 0, 35)
                Toggle.BackgroundTransparency = 1
                Toggle.Parent = ElementContainer
                
                local ToggleLabel = Instance.new("TextLabel")
                ToggleLabel.Size = UDim2.new(1, -60, 1, 0)
                ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
                ToggleLabel.BackgroundTransparency = 1
                ToggleLabel.Text = text
                ToggleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                ToggleLabel.TextSize = 12
                ToggleLabel.Font = Enum.Font.Gotham
                ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                ToggleLabel.Parent = Toggle
                
                local ToggleButton = Instance.new("TextButton")
                ToggleButton.Name = "Button"
                ToggleButton.Size = UDim2.new(0, 45, 0, 24)
                ToggleButton.Position = UDim2.new(1, -50, 0.5, -12)
                ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                ToggleButton.BorderSizePixel = 0
                ToggleButton.Text = ""
                ToggleButton.AutoButtonColor = false
                ToggleButton.Parent = Toggle
                
                local ButtonCorner = Instance.new("UICorner")
                ButtonCorner.CornerRadius = UDim.new(1, 0)
                ButtonCorner.Parent = ToggleButton
                
                local ToggleCircle = Instance.new("Frame")
                ToggleCircle.Name = "Circle"
                ToggleCircle.Size = UDim2.new(0, 18, 0, 18)
                ToggleCircle.Position = UDim2.new(0, 3, 0.5, -9)
                ToggleCircle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
                ToggleCircle.BorderSizePixel = 0
                ToggleCircle.Parent = ToggleButton
                
                local CircleCorner = Instance.new("UICorner")
                CircleCorner.CornerRadius = UDim.new(1, 0)
                CircleCorner.Parent = ToggleCircle
                
                local toggled = default or false
                
                local function UpdateToggle()
                    if toggled then
                        Tween(ToggleButton, {BackgroundColor3 = Color3.fromRGB(90, 140, 220)}, 0.15)
                        Tween(ToggleCircle, {Position = UDim2.new(1, -21, 0.5, -9), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}, 0.15)
                    else
                        Tween(ToggleButton, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}, 0.15)
                        Tween(ToggleCircle, {Position = UDim2.new(0, 3, 0.5, -9), BackgroundColor3 = Color3.fromRGB(80, 80, 80)}, 0.15)
                    end
                    if callback then
                        callback(toggled)
                    end
                end
                
                ToggleButton.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    UpdateToggle()
                end)
                
                UpdateToggle()
                
                return {
                    SetValue = function(self, value)
                        toggled = value
                        UpdateToggle()
                    end
                }
            end
            
            function SectionObj:AddSlider(text, min, max, default, callback)
                local Slider = Instance.new("Frame")
                Slider.Name = "Slider"
                Slider.Size = UDim2.new(1, -20, 0, 50)
                Slider.BackgroundTransparency = 1
                Slider.Parent = ElementContainer
                
                local SliderLabel = Instance.new("TextLabel")
                SliderLabel.Size = UDim2.new(0.5, 0, 0, 20)
                SliderLabel.Position = UDim2.new(0, 10, 0, 0)
                SliderLabel.BackgroundTransparency = 1
                SliderLabel.Text = text
                SliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                SliderLabel.TextSize = 12
                SliderLabel.Font = Enum.Font.Gotham
                SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                SliderLabel.Parent = Slider
                
                local ValueLabel = Instance.new("TextLabel")
                ValueLabel.Size = UDim2.new(0, 50, 0, 20)
                ValueLabel.Position = UDim2.new(1, -55, 0, 0)
                ValueLabel.BackgroundTransparency = 1
                ValueLabel.Text = tostring(default) .. "%"
                ValueLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
                ValueLabel.TextSize = 11
                ValueLabel.Font = Enum.Font.Gotham
                ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
                ValueLabel.Parent = Slider
                
                local SliderBack = Instance.new("Frame")
                SliderBack.Name = "Back"
                SliderBack.Size = UDim2.new(1, -20, 0, 6)
                SliderBack.Position = UDim2.new(0, 10, 0, 30)
                SliderBack.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                SliderBack.BorderSizePixel = 0
                SliderBack.Parent = Slider
                
                local BackCorner = Instance.new("UICorner")
                BackCorner.CornerRadius = UDim.new(1, 0)
                BackCorner.Parent = SliderBack
                
                local SliderFill = Instance.new("Frame")
                SliderFill.Name = "Fill"
                SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                SliderFill.BackgroundColor3 = Color3.fromRGB(90, 140, 220)
                SliderFill.BorderSizePixel = 0
                SliderFill.Parent = SliderBack
                
                local FillCorner = Instance.new("UICorner")
                FillCorner.CornerRadius = UDim.new(1, 0)
                FillCorner.Parent = SliderFill
                
                local SliderButton = Instance.new("TextButton")
                SliderButton.Size = UDim2.new(1, 0, 1, 0)
                SliderButton.BackgroundTransparency = 1
                SliderButton.Text = ""
                SliderButton.Parent = SliderBack
                
                local value = default
                local dragging = false
                
                local function UpdateSlider(input)
                    local pos = math.clamp((input.Position.X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X, 0, 1)
                    value = math.floor(min + (max - min) * pos)
                    
                    SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                    ValueLabel.Text = tostring(value) .. "%"
                    
                    if callback then
                        callback(value)
                    end
                end
                
                SliderButton.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        UpdateSlider(input)
                    end
                end)
                
                SliderButton.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        UpdateSlider(input)
                    end
                end)
                
                return {
                    SetValue = function(self, val)
                        value = math.clamp(val, min, max)
                        local pos = (value - min) / (max - min)
                        SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                        ValueLabel.Text = tostring(value) .. "%"
                        if callback then callback(value) end
                    end
                }
            end
            
            function SectionObj:AddButton(text, callback)
                local Button = Instance.new("TextButton")
                Button.Name = "Button"
                Button.Size = UDim2.new(1, -20, 0, 35)
                Button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                Button.BackgroundTransparency = 0.3
                Button.BorderSizePixel = 0
                Button.Text = text
                Button.TextColor3 = Color3.fromRGB(200, 200, 200)
                Button.TextSize = 12
                Button.Font = Enum.Font.Gotham
                Button.AutoButtonColor = false
                Button.Parent = ElementContainer
                
                local ButtonCorner = Instance.new("UICorner")
                ButtonCorner.CornerRadius = UDim.new(0, 4)
                ButtonCorner.Parent = Button
                
                local Icon = Instance.new("Frame")
                Icon.Size = UDim2.new(0, 20, 0, 3)
                Icon.Position = UDim2.new(1, -25, 0.5, -1.5)
                Icon.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
                Icon.BorderSizePixel = 0
                Icon.Parent = Button
                
                local IconCorner = Instance.new("UICorner")
                IconCorner.CornerRadius = UDim.new(1, 0)
                IconCorner.Parent = Icon
                
                Button.MouseEnter:Connect(function()
                    Tween(Button, {BackgroundTransparency = 0})
                end)
                
                Button.MouseLeave:Connect(function()
                    Tween(Button, {BackgroundTransparency = 0.3})
                end)
                
                Button.MouseButton1Click:Connect(function()
                    if callback then
                        callback()
                    end
                end)
            end
            
            function SectionObj:AddDropdown(text, options, default, callback)
                local Dropdown = Instance.new("Frame")
                Dropdown.Name = "Dropdown"
                Dropdown.Size = UDim2.new(1, -20, 0, 35)
                Dropdown.BackgroundTransparency = 1
                Dropdown.ClipsDescendants = true
                Dropdown.Parent = ElementContainer
                
                local DropdownButton = Instance.new("TextButton")
                DropdownButton.Size = UDim2.new(1, 0, 0, 35)
                DropdownButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                DropdownButton.BackgroundTransparency = 0.3
                DropdownButton.BorderSizePixel = 0
                DropdownButton.Text = ""
                DropdownButton.AutoButtonColor = false
                DropdownButton.Parent = Dropdown
                
                local DropCorner = Instance.new("UICorner")
                DropCorner.CornerRadius = UDim.new(0, 4)
                DropCorner.Parent = DropdownButton
                
                local DropLabel = Instance.new("TextLabel")
                DropLabel.Size = UDim2.new(1, -50, 1, 0)
                DropLabel.Position = UDim2.new(0, 10, 0, 0)
                DropLabel.BackgroundTransparency = 1
                DropLabel.Text = text
                DropLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                DropLabel.TextSize = 12
                DropLabel.Font = Enum.Font.Gotham
                DropLabel.TextXAlignment = Enum.TextXAlignment.Left
                DropLabel.Parent = DropdownButton
                
                local DropValue = Instance.new("TextLabel")
                DropValue.Size = UDim2.new(0, 100, 1, 0)
                DropValue.Position = UDim2.new(1, -110, 0, 0)
                DropValue.BackgroundTransparency = 1
                DropValue.Text = default or options[1] or "None"
                DropValue.TextColor3 = Color3.fromRGB(150, 150, 150)
                DropValue.TextSize = 11
                DropValue.Font = Enum.Font.Gotham
                DropValue.TextXAlignment = Enum.TextXAlignment.Right
                DropValue.Parent = DropdownButton
                
                local DropIcon = Instance.new("TextLabel")
                DropIcon.Size = UDim2.new(0, 20, 0, 20)
                DropIcon.Position = UDim2.new(1, -25, 0.5, -10)
                DropIcon.BackgroundTransparency = 1
                DropIcon.Text = "▼"
                DropIcon.TextColor3 = Color3.fromRGB(150, 150, 150)
                DropIcon.TextSize = 10
                DropIcon.Font = Enum.Font.Gotham
                DropIcon.Parent = DropdownButton
                
                local OptionsFrame = Instance.new("Frame")
                OptionsFrame.Name = "Options"
                OptionsFrame.Size = UDim2.new(1, 0, 0, 0)
                OptionsFrame.Position = UDim2.new(0, 0, 0, 40)
                OptionsFrame.BackgroundTransparency = 1
                OptionsFrame.Parent = Dropdown
                
                local OptionsLayout = Instance.new("UIListLayout")
                OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
                OptionsLayout.Padding = UDim.new(0, 2)
                OptionsLayout.Parent = OptionsFrame
                
                local opened = false
                local selected = default or options[1]
                
                for _, option in ipairs(options) do
                    local OptionButton = Instance.new("TextButton")
                    OptionButton.Size = UDim2.new(1, 0, 0, 30)
                    OptionButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                    OptionButton.BackgroundTransparency = 0.3
                    OptionButton.BorderSizePixel = 0
                    OptionButton.Text = option
                    OptionButton.TextColor3 = Color3.fromRGB(180, 180, 180)
                    OptionButton.TextSize = 11
                    OptionButton.Font = Enum.Font.Gotham
                    OptionButton.AutoButtonColor = false
                    OptionButton.Parent = OptionsFrame
                    
                    local OptCorner = Instance.new("UICorner")
                    OptCorner.CornerRadius = UDim.new(0, 4)
                    OptCorner.Parent = OptionButton
                    
                    OptionButton.MouseEnter:Connect(function()
                        Tween(OptionButton, {BackgroundTransparency = 0})
                    end)
                    
                    OptionButton.MouseLeave:Connect(function()
                        Tween(OptionButton, {BackgroundTransparency = 0.3})
                    end)
                    
                    OptionButton.MouseButton1Click:Connect(function()
                        selected = option
                        DropValue.Text = option
                        opened = false
                        Tween(Dropdown, {Size = UDim2.new(1, -20, 0, 35)}, 0.2)
                        Tween(DropIcon, {Rotation = 0}, 0.2)
                        if callback then
                            callback(option)
                        end
                    end)
                end
                
                DropdownButton.MouseButton1Click:Connect(function()
                    opened = not opened
                    if opened then
                        local contentHeight = #options * 32
                        Tween(Dropdown, {Size = UDim2.new(1, -20, 0, 35 + contentHeight + 5)}, 0.2)
                        Tween(DropIcon, {Rotation = 180}, 0.2)
                    else
                        Tween(Dropdown, {Size = UDim2.new(1, -20, 0, 35)}, 0.2)
                        Tween(DropIcon, {Rotation = 0}, 0.2)
                    end
                end)
                
                return {
                    SetValue = function(self, value)
                        selected = value
                        DropValue.Text = value
                        if callback then callback(value) end
                    end
                }
            end
            
            function SectionObj:AddTextbox(text, placeholder, callback)
                local Textbox = Instance.new("Frame")
                Textbox.Name = "Textbox"
                Textbox.Size = UDim2.new(1, -20, 0, 35)
                Textbox.BackgroundTransparency = 1
                Textbox.Parent = ElementContainer
                
                local TextboxLabel = Instance.new("TextLabel")
                TextboxLabel.Size = UDim2.new(0.4, 0, 1, 0)
                TextboxLabel.Position = UDim2.new(0, 10, 0, 0)
                TextboxLabel.BackgroundTransparency = 1
                TextboxLabel.Text = text
                TextboxLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                TextboxLabel.TextSize = 12
                TextboxLabel.Font = Enum.Font.Gotham
                TextboxLabel.TextXAlignment = Enum.TextXAlignment.Left
                TextboxLabel.Parent = Textbox
                
                local TextboxInput = Instance.new("TextBox")
                TextboxInput.Size = UDim2.new(0.55, 0, 0, 28)
                TextboxInput.Position = UDim2.new(0.43, 0, 0.5, -14)
                TextboxInput.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                TextboxInput.BackgroundTransparency = 0.3
                TextboxInput.BorderSizePixel = 0
                TextboxInput.Text = ""
                TextboxInput.PlaceholderText = placeholder or ""
                TextboxInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
                TextboxInput.TextColor3 = Color3.fromRGB(200, 200, 200)
                TextboxInput.TextSize = 11
                TextboxInput.Font = Enum.Font.Gotham
                TextboxInput.ClearTextOnFocus = false
                TextboxInput.Parent = Textbox
                
                local InputCorner = Instance.new("UICorner")
                InputCorner.CornerRadius = UDim.new(0, 4)
                InputCorner.Parent = TextboxInput
                
                TextboxInput.Focused:Connect(function()
                    Tween(TextboxInput, {BackgroundTransparency = 0}, 0.15)
                end)
                
                TextboxInput.FocusLost:Connect(function(enter)
                    Tween(TextboxInput, {BackgroundTransparency = 0.3}, 0.15)
                    if enter and callback then
                        callback(TextboxInput.Text)
                    end
                end)
                
                return {
                    SetValue = function(self, value)
                        TextboxInput.Text = value
                    end
                }
            end
            
            function SectionObj:AddLabel(text)
                local Label = Instance.new("TextLabel")
                Label.Name = "Label"
                Label.Size = UDim2.new(1, -20, 0, 25)
                Label.BackgroundTransparency = 1
                Label.Text = text
                Label.TextColor3 = Color3.fromRGB(150, 150, 150)
                Label.TextSize = 11
                Label.Font = Enum.Font.Gotham
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.TextWrapped = true
                Label.Parent = ElementContainer
                
                return {
                    SetText = function(self, newText)
                        Label.Text = newText
                    end
                }
            end
            
            table.insert(Tab.Sections, SectionObj)
            return SectionObj
        end
        
        return Tab
    end
    
    function Window:SelectTab(tab)
        if Window.CurrentTab == tab then return end
        
        for _, t in ipairs(Window.Tabs) do
            t.Content.Visible = false
            Tween(t.Button, {BackgroundTransparency = 1})
            Tween(t.Icon, {TextColor3 = Color3.fromRGB(150, 150, 150)})
            Tween(t.Name, {TextColor3 = Color3.fromRGB(150, 150, 150)})
        end
        
        tab.Content.Visible = true
        Tween(tab.Button, {BackgroundTransparency = 0.7})
        Tween(tab.Icon, {TextColor3 = Color3.fromRGB(255, 255, 255)})
        Tween(tab.Name, {TextColor3 = Color3.fromRGB(255, 255, 255)})
        
        Window.CurrentTab = tab
    end
    
    -- Анимация появления
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    Tween(MainFrame, {Size = UDim2.new(0, 700, 0, 500)}, 0.4)
    
    return Window
end

return Library