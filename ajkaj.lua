local FluentHub = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local LucideIcons = {
    Home = "rbxassetid://10723434711",
    Settings = "rbxassetid://10734950309",
    User = "rbxassetid://10734929157",
    Search = "rbxassetid://10734898629",
    Bell = "rbxassetid://10709790948",
    Star = "rbxassetid://10734896629",
    Lock = "rbxassetid://10747372992",
    Check = "rbxassetid://10709813281",
    X = "rbxassetid://10747384394",
    ChevronRight = "rbxassetid://10709818534",
    ChevronDown = "rbxassetid://10709818534",
    Info = "rbxassetid://10723434711",
    Target = "rbxassetid://10723434711",
    Shield = "rbxassetid://10723407389",
    Eye = "rbxassetid://10734896629",
    Grid = "rbxassetid://10723407389",
    Crosshair = "rbxassetid://10723434711"
}

local Colors = {
    Background = Color3.fromRGB(30, 30, 30),
    Sidebar = Color3.fromRGB(42, 42, 42),
    Surface = Color3.fromRGB(50, 50, 50),
    SurfaceHover = Color3.fromRGB(60, 60, 60),
    Primary = Color3.fromRGB(88, 101, 242),
    PrimaryHover = Color3.fromRGB(108, 121, 255),
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 180),
    TextTertiary = Color3.fromRGB(120, 120, 120),
    Border = Color3.fromRGB(60, 60, 60),
    ToggleOff = Color3.fromRGB(70, 70, 70)
}

local ConnectionTracker = {}
ConnectionTracker.__index = ConnectionTracker

function ConnectionTracker:New()
    return setmetatable({_connections = {}}, self)
end

function ConnectionTracker:Add(connection)
    table.insert(self._connections, connection)
    return connection
end

function ConnectionTracker:DisconnectAll()
    for _, conn in ipairs(self._connections) do
        if conn and conn.Connected then
            conn:Disconnect()
        end
    end
    self._connections = {}
end

local Utility = {}

function Utility:Tween(instance, properties, duration, style, direction)
    local info = TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, info, properties)
    tween:Play()
    return tween
end

function Utility:CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 4)
    corner.Parent = parent
    return corner
end

function Utility:CreateStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Colors.Border
    stroke.Thickness = thickness or 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

function Utility:CreateIcon(parent, iconId)
    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(1, 0, 1, 0)
    icon.BackgroundTransparency = 1
    icon.Image = iconId
    icon.ImageColor3 = Colors.TextSecondary
    icon.Parent = parent
    return icon
end

function Utility:CreatePadding(parent, values)
    local padding = Instance.new("UIPadding")
    if type(values) == "number" then
        padding.PaddingTop = UDim.new(0, values)
        padding.PaddingBottom = UDim.new(0, values)
        padding.PaddingLeft = UDim.new(0, values)
        padding.PaddingRight = UDim.new(0, values)
    else
        padding.PaddingTop = UDim.new(0, values.Top or 0)
        padding.PaddingBottom = UDim.new(0, values.Bottom or 0)
        padding.PaddingLeft = UDim.new(0, values.Left or 0)
        padding.PaddingRight = UDim.new(0, values.Right or 0)
    end
    padding.Parent = parent
    return padding
end

function Utility:CreateListLayout(parent, padding, direction)
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, padding or 6)
    layout.FillDirection = direction or Enum.FillDirection.Vertical
    layout.Parent = parent
    return layout
end

function Utility:MakeDraggable(frame, connections)
    local dragging, dragInput, dragStart, startPos
    
    connections:Add(frame.InputBegan:Connect(function(input)
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
    end))
    
    connections:Add(frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end))
    
    connections:Add(UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end))
end

function FluentHub:CreateWindow(config)
    config = config or {}
    local windowTitle = config.Title or "Karpinware"
    local windowSize = config.Size or UDim2.new(0, 680, 0, 500)
    local windowConnections = ConnectionTracker:New()
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FluentHub_" .. HttpService:GenerateGUID(false)
    screenGui.Parent = CoreGui
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = Colors.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    Utility:CreateCorner(mainFrame, 6)
    
    Utility:MakeDraggable(mainFrame, windowConnections)
    
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 32)
    header.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0, 150, 1, 0)
    titleLabel.Position = UDim2.new(0, 12, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = windowTitle
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 13
    titleLabel.TextColor3 = Colors.Text
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = header
    
    local versionLabel = Instance.new("TextLabel")
    versionLabel.Size = UDim2.new(0, 50, 1, 0)
    versionLabel.Position = UDim2.new(0, 95, 0, 0)
    versionLabel.BackgroundTransparency = 1
    versionLabel.Text = "6.1.0"
    versionLabel.Font = Enum.Font.Gotham
    versionLabel.TextSize = 11
    versionLabel.TextColor3 = Colors.TextTertiary
    versionLabel.TextXAlignment = Enum.TextXAlignment.Left
    versionLabel.Parent = header
    
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 32, 0, 32)
    closeButton.Position = UDim2.new(1, -32, 0, 0)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "×"
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 18
    closeButton.TextColor3 = Colors.TextSecondary
    closeButton.AutoButtonColor = false
    closeButton.Parent = header
    
    windowConnections:Add(closeButton.MouseButton1Click:Connect(function()
        Utility:Tween(mainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
        task.wait(0.2)
        windowConnections:DisconnectAll()
        screenGui:Destroy()
    end))
    
    windowConnections:Add(closeButton.MouseEnter:Connect(function()
        closeButton.TextColor3 = Colors.Text
    end))
    
    windowConnections:Add(closeButton.MouseLeave:Connect(function()
        closeButton.TextColor3 = Colors.TextSecondary
    end))
    
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(1, 0, 1, -32)
    container.Position = UDim2.new(0, 0, 0, 32)
    container.BackgroundTransparency = 1
    container.Parent = mainFrame
    
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 140, 1, 0)
    sidebar.BackgroundColor3 = Colors.Sidebar
    sidebar.BorderSizePixel = 0
    sidebar.Parent = container
    
    local sidebarContent = Instance.new("Frame")
    sidebarContent.Size = UDim2.new(1, 0, 1, -50)
    sidebarContent.BackgroundTransparency = 1
    sidebarContent.Parent = sidebar
    
    Utility:CreateListLayout(sidebarContent, 4)
    Utility:CreatePadding(sidebarContent, {Top = 8, Bottom = 8, Left = 8, Right = 8})
    
    local userProfile = Instance.new("Frame")
    userProfile.Name = "UserProfile"
    userProfile.Size = UDim2.new(1, 0, 0, 50)
    userProfile.Position = UDim2.new(0, 0, 1, -50)
    userProfile.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    userProfile.BorderSizePixel = 0
    userProfile.Parent = sidebar
    
    local profileDivider = Instance.new("Frame")
    profileDivider.Size = UDim2.new(1, 0, 0, 1)
    profileDivider.BackgroundColor3 = Colors.Border
    profileDivider.BorderSizePixel = 0
    profileDivider.Parent = userProfile
    
    local profileIcon = Instance.new("Frame")
    profileIcon.Size = UDim2.new(0, 28, 0, 28)
    profileIcon.Position = UDim2.new(0, 8, 0.5, -14)
    profileIcon.BackgroundColor3 = Colors.Primary
    profileIcon.BorderSizePixel = 0
    profileIcon.Parent = userProfile
    Utility:CreateCorner(profileIcon, 14)
    
    local profileImage = Utility:CreateIcon(profileIcon, LucideIcons.User)
    profileImage.ImageColor3 = Colors.Text
    Utility:CreatePadding(profileIcon, 6)
    
    local localPlayer = Players.LocalPlayer
    local profileName = Instance.new("TextLabel")
    profileName.Size = UDim2.new(1, -76, 0, 14)
    profileName.Position = UDim2.new(0, 42, 0.5, -7)
    profileName.BackgroundTransparency = 1
    profileName.Text = localPlayer and localPlayer.Name or "Player"
    profileName.Font = Enum.Font.GothamMedium
    profileName.TextSize = 11
    profileName.TextColor3 = Colors.Text
    profileName.TextXAlignment = Enum.TextXAlignment.Left
    profileName.TextTruncate = Enum.TextTruncate.AtEnd
    profileName.Parent = userProfile
    
    local profileSettings = Instance.new("TextButton")
    profileSettings.Size = UDim2.new(0, 20, 0, 20)
    profileSettings.Position = UDim2.new(1, -26, 0.5, -10)
    profileSettings.BackgroundTransparency = 1
    profileSettings.Text = ""
    profileSettings.AutoButtonColor = false
    profileSettings.Parent = userProfile
    
    local settingsIcon = Utility:CreateIcon(profileSettings, LucideIcons.Settings)
    Utility:CreatePadding(profileSettings, 3)
    
    windowConnections:Add(profileSettings.MouseEnter:Connect(function()
        settingsIcon.ImageColor3 = Colors.Text
    end))
    
    windowConnections:Add(profileSettings.MouseLeave:Connect(function()
        settingsIcon.ImageColor3 = Colors.TextSecondary
    end))
    
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -140, 1, 0)
    contentFrame.Position = UDim2.new(0, 140, 0, 0)
    contentFrame.BackgroundColor3 = Colors.Background
    contentFrame.BorderSizePixel = 0
    contentFrame.ScrollBarThickness = 4
    contentFrame.ScrollBarImageColor3 = Colors.Border
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentFrame.Parent = container
    
    local contentContainer = Instance.new("Frame")
    contentContainer.Size = UDim2.new(1, -24, 0, 0)
    contentContainer.Position = UDim2.new(0, 12, 0, 12)
    contentContainer.BackgroundTransparency = 1
    contentContainer.Parent = contentFrame
    
    local leftColumn = Instance.new("Frame")
    leftColumn.Name = "LeftColumn"
    leftColumn.Size = UDim2.new(0.48, 0, 1, 0)
    leftColumn.BackgroundTransparency = 1
    leftColumn.Parent = contentContainer
    
    local rightColumn = Instance.new("Frame")
    rightColumn.Name = "RightColumn"
    rightColumn.Size = UDim2.new(0.48, 0, 1, 0)
    rightColumn.Position = UDim2.new(0.52, 0, 0, 0)
    rightColumn.BackgroundTransparency = 1
    rightColumn.Parent = contentContainer
    
    local leftLayout = Utility:CreateListLayout(leftColumn, 8)
    local rightLayout = Utility:CreateListLayout(rightColumn, 8)
    
    local function UpdateCanvasSize()
        local leftHeight = leftLayout.AbsoluteContentSize.Y
        local rightHeight = rightLayout.AbsoluteContentSize.Y
        local maxHeight = math.max(leftHeight, rightHeight)
        contentContainer.Size = UDim2.new(1, -24, 0, maxHeight + 24)
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, maxHeight + 36)
    end
    
    leftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvasSize)
    rightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvasSize)
    
    local tabs = {}
    local currentTab = nil
    local elementCounter = 0
    
    local Window = {}
    
    function Window:CreateTab(config)
        config = config or {}
        local tabName = config.Name or "Tab"
        local tabIcon = config.Icon or LucideIcons.Home
        local tabConnections = ConnectionTracker:New()
        
        local tabButton = Instance.new("TextButton")
        tabButton.Name = tabName
        tabButton.Size = UDim2.new(1, 0, 0, 32)
        tabButton.BackgroundColor3 = Colors.Sidebar
        tabButton.BackgroundTransparency = 1
        tabButton.Text = ""
        tabButton.AutoButtonColor = false
        tabButton.Parent = sidebarContent
        Utility:CreateCorner(tabButton, 4)
        
        local iconFrame = Instance.new("Frame")
        iconFrame.Size = UDim2.new(0, 18, 0, 18)
        iconFrame.Position = UDim2.new(0, 8, 0.5, -9)
        iconFrame.BackgroundTransparency = 1
        iconFrame.Parent = tabButton
        
        local tabIconImg = Utility:CreateIcon(iconFrame, tabIcon)
        
        local tabLabel = Instance.new("TextLabel")
        tabLabel.Size = UDim2.new(1, -34, 1, 0)
        tabLabel.Position = UDim2.new(0, 32, 0, 0)
        tabLabel.BackgroundTransparency = 1
        tabLabel.Text = tabName
        tabLabel.Font = Enum.Font.GothamMedium
        tabLabel.TextSize = 12
        tabLabel.TextColor3 = Colors.TextSecondary
        tabLabel.TextXAlignment = Enum.TextXAlignment.Left
        tabLabel.Parent = tabButton
        
        local tabData = {
            LeftColumn = leftColumn,
            RightColumn = rightColumn,
            Elements = {},
            Button = tabButton,
            Label = tabLabel,
            Icon = tabIconImg,
            Connections = tabConnections
        }
        
        local function SelectTab()
            for _, tab in pairs(tabs) do
                Utility:Tween(tab.Button, {BackgroundTransparency = 1})
                Utility:Tween(tab.Label, {TextColor3 = Colors.TextSecondary})
                tab.Icon.ImageColor3 = Colors.TextSecondary
                for _, elem in pairs(tab.Elements) do
                    elem.Visible = false
                end
            end
            
            Utility:Tween(tabButton, {BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(55, 55, 55)})
            Utility:Tween(tabLabel, {TextColor3 = Colors.Text})
            tabIconImg.ImageColor3 = Colors.Primary
            
            for _, elem in pairs(tabData.Elements) do
                elem.Visible = true
            end
            
            currentTab = tabData
            UpdateCanvasSize()
        end
        
        tabConnections:Add(tabButton.MouseButton1Click:Connect(SelectTab))
        
        tabConnections:Add(tabButton.MouseEnter:Connect(function()
            if currentTab ~= tabData then
                Utility:Tween(tabButton, {BackgroundTransparency = 0.7, BackgroundColor3 = Color3.fromRGB(50, 50, 50)})
            end
        end))
        
        tabConnections:Add(tabButton.MouseLeave:Connect(function()
            if currentTab ~= tabData then
                Utility:Tween(tabButton, {BackgroundTransparency = 1})
            end
        end))
        
        table.insert(tabs, tabData)
        
        if #tabs == 1 then
            SelectTab()
        end
        
        local Tab = {}
        
        function Tab:CreateToggle(config)
            config = config or {}
            local toggleName = config.Name or "Toggle"
            local toggleDefault = config.Default or false
            local toggleCallback = config.Callback or function() end
            
            elementCounter = elementCounter + 1
            local targetColumn = (elementCounter % 2 == 1) and leftColumn or rightColumn
            
            local toggleFrame = Instance.new("Frame")
            toggleFrame.Size = UDim2.new(1, 0, 0, 36)
            toggleFrame.BackgroundColor3 = Colors.Surface
            toggleFrame.BorderSizePixel = 0
            toggleFrame.Visible = currentTab == tabData
            toggleFrame.Parent = targetColumn
            Utility:CreateCorner(toggleFrame, 4)
            
            table.insert(tabData.Elements, toggleFrame)
            
            local toggleLabel = Instance.new("TextLabel")
            toggleLabel.Size = UDim2.new(1, -58, 1, 0)
            toggleLabel.Position = UDim2.new(0, 10, 0, 0)
            toggleLabel.BackgroundTransparency = 1
            toggleLabel.Text = toggleName
            toggleLabel.Font = Enum.Font.GothamMedium
            toggleLabel.TextSize = 12
            toggleLabel.TextColor3 = Colors.Text
            toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            toggleLabel.Parent = toggleFrame
            
            local toggleButton = Instance.new("TextButton")
            toggleButton.Size = UDim2.new(0, 38, 0, 20)
            toggleButton.Position = UDim2.new(1, -46, 0.5, -10)
            toggleButton.BackgroundColor3 = Colors.ToggleOff
            toggleButton.Text = ""
            toggleButton.AutoButtonColor = false
            toggleButton.Parent = toggleFrame
            Utility:CreateCorner(toggleButton, 10)
            
            local toggleCircle = Instance.new("Frame")
            toggleCircle.Size = UDim2.new(0, 16, 0, 16)
            toggleCircle.Position = UDim2.new(0, 2, 0.5, -8)
            toggleCircle.BackgroundColor3 = Colors.Background
            toggleCircle.BorderSizePixel = 0
            toggleCircle.Parent = toggleButton
            Utility:CreateCorner(toggleCircle, 8)
            
            local isToggled = toggleDefault
            
            local function UpdateToggle(instant)
                local duration = instant and 0 or 0.15
                if isToggled then
                    Utility:Tween(toggleButton, {BackgroundColor3 = Colors.Primary}, duration)
                    Utility:Tween(toggleCircle, {Position = UDim2.new(0, 20, 0.5, -8)}, duration)
                else
                    Utility:Tween(toggleButton, {BackgroundColor3 = Colors.ToggleOff}, duration)
                    Utility:Tween(toggleCircle, {Position = UDim2.new(0, 2, 0.5, -8)}, duration)
                end
                task.spawn(toggleCallback, isToggled)
            end
            
            tabConnections:Add(toggleButton.MouseButton1Click:Connect(function()
                isToggled = not isToggled
                UpdateToggle()
            end))
            
            UpdateToggle(true)
            UpdateCanvasSize()
            
            return toggleFrame
        end
        
        function Tab:CreateSlider(config)
            config = config or {}
            local sliderName = config.Name or "Slider"
            local sliderMin = config.Min or 0
            local sliderMax = config.Max or 100
            local sliderDefault = config.Default or 50
            local sliderIncrement = config.Increment or 1
            local sliderCallback = config.Callback or function() end
            local sliderSuffix = config.Suffix or "%"
            
            elementCounter = elementCounter + 1
            local targetColumn = (elementCounter % 2 == 1) and leftColumn or rightColumn
            
            local sliderFrame = Instance.new("Frame")
            sliderFrame.Size = UDim2.new(1, 0, 0, 48)
            sliderFrame.BackgroundColor3 = Colors.Surface
            sliderFrame.BorderSizePixel = 0
            sliderFrame.Visible = currentTab == tabData
            sliderFrame.Parent = targetColumn
            Utility:CreateCorner(sliderFrame, 4)
            
            table.insert(tabData.Elements, sliderFrame)
            
            local sliderLabel = Instance.new("TextLabel")
            sliderLabel.Size = UDim2.new(0.6, 0, 0, 18)
            sliderLabel.Position = UDim2.new(0, 10, 0, 8)
            sliderLabel.BackgroundTransparency = 1
            sliderLabel.Text = sliderName
            sliderLabel.Font = Enum.Font.GothamMedium
            sliderLabel.TextSize = 12
            sliderLabel.TextColor3 = Colors.Text
            sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            sliderLabel.Parent = sliderFrame
            
            local valueDisplay = Instance.new("Frame")
            valueDisplay.Size = UDim2.new(0, 42, 0, 18)
            valueDisplay.Position = UDim2.new(1, -50, 0, 8)
            valueDisplay.BackgroundColor3 = Colors.Background
            valueDisplay.BorderSizePixel = 0
            valueDisplay.Parent = sliderFrame
            Utility:CreateCorner(valueDisplay, 3)
            
            local valueLabel = Instance.new("TextLabel")
            valueLabel.Size = UDim2.new(1, 0, 1, 0)
            valueLabel.BackgroundTransparency = 1
            valueLabel.Text = tostring(sliderDefault) .. sliderSuffix
            valueLabel.Font = Enum.Font.GothamBold
            valueLabel.TextSize = 11
            valueLabel.TextColor3 = Colors.TextSecondary
            valueLabel.Parent = valueDisplay
            
            local sliderTrack = Instance.new("Frame")
            sliderTrack.Size = UDim2.new(1, -20, 0, 4)
            sliderTrack.Position = UDim2.new(0, 10, 1, -14)
            sliderTrack.BackgroundColor3 = Colors.Background
            sliderTrack.BorderSizePixel = 0
            sliderTrack.Parent = sliderFrame
            Utility:CreateCorner(sliderTrack, 2)
            
            local sliderFill = Instance.new("Frame")
            sliderFill.Size = UDim2.new((sliderDefault - sliderMin) / (sliderMax - sliderMin), 0, 1, 0)
            sliderFill.BackgroundColor3 = Colors.Primary
            sliderFill.BorderSizePixel = 0
            sliderFill.Parent = sliderTrack
            Utility:CreateCorner(sliderFill, 2)
            
            local sliderThumb = Instance.new("Frame")
            sliderThumb.Size = UDim2.new(0, 10, 0, 10)
            sliderThumb.Position = UDim2.new((sliderDefault - sliderMin) / (sliderMax - sliderMin), -5, 0.5, -5)
            sliderThumb.BackgroundColor3 = Colors.Text
            sliderThumb.BorderSizePixel = 0
            sliderThumb.ZIndex = 2
            sliderThumb.Parent = sliderTrack
            Utility:CreateCorner(sliderThumb, 5)
            
            local sliderButton = Instance.new("TextButton")
            sliderButton.Size = UDim2.new(1, 0, 1, 8)
            sliderButton.Position = UDim2.new(0, 0, 0, -4)
            sliderButton.BackgroundTransparency = 1
            sliderButton.Text = ""
            sliderButton.AutoButtonColor = false
            sliderButton.Parent = sliderTrack
            
            local draggingSlider = false
            
            local function UpdateSlider(input)
                local pos = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
                local rawValue = sliderMin + (sliderMax - sliderMin) * pos
                local value = math.floor(rawValue / sliderIncrement + 0.5) * sliderIncrement
                value = math.clamp(value, sliderMin, sliderMax)
                
                sliderFill.Size = UDim2.new((value - sliderMin) / (sliderMax - sliderMin), 0, 1, 0)
                sliderThumb.Position = UDim2.new((value - sliderMin) / (sliderMax - sliderMin), -5, 0.5, -5)
                valueLabel.Text = tostring(value) .. sliderSuffix
                task.spawn(sliderCallback, value)
            end
            
            tabConnections:Add(sliderButton.MouseButton1Down:Connect(function()
                draggingSlider = true
                Utility:Tween(sliderThumb, {Size = UDim2.new(0, 12, 0, 12)}, 0.1)
            end))
            
            tabConnections:Add(UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSlider = false
                    Utility:Tween(sliderThumb, {Size = UDim2.new(0, 10, 0, 10)}, 0.1)
                end
            end))
            
            tabConnections:Add(UserInputService.InputChanged:Connect(function(input)
                if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
                    UpdateSlider(input)
                end
            end))
            
            UpdateCanvasSize()
            
            return sliderFrame
        end
        
        function Tab:CreateDropdown(config)
            config = config or {}
            local dropdownName = config.Name or "Dropdown"
            local dropdownOptions = config.Options or {"Option 1", "Option 2", "Option 3"}
            local dropdownDefault = config.Default or dropdownOptions[1]
            local dropdownCallback = config.Callback or function() end
            
            elementCounter = elementCounter + 1
            local targetColumn = (elementCounter % 2 == 1) and leftColumn or rightColumn
            
            local isOpen = false
            local currentValue = dropdownDefault
            
            local dropdownFrame = Instance.new("Frame")
            dropdownFrame.Size = UDim2.new(1, 0, 0, 36)
            dropdownFrame.BackgroundColor3 = Colors.Surface
            dropdownFrame.BorderSizePixel = 0
            dropdownFrame.Visible = currentTab == tabData
            dropdownFrame.ClipsDescendants = false
            dropdownFrame.ZIndex = 10
            dropdownFrame.Parent = targetColumn
            Utility:CreateCorner(dropdownFrame, 4)
            
            table.insert(tabData.Elements, dropdownFrame)
            
            local dropdownButton = Instance.new("TextButton")
            dropdownButton.Size = UDim2.new(1, 0, 0, 36)
            dropdownButton.BackgroundTransparency = 1
            dropdownButton.Text = ""
            dropdownButton.AutoButtonColor = false
            dropdownButton.ZIndex = 11
            dropdownButton.Parent = dropdownFrame
            
            local dropdownLabel = Instance.new("TextLabel")
            dropdownLabel.Size = UDim2.new(1, -54, 0, 14)
            dropdownLabel.Position = UDim2.new(0, 10, 0, 4)
            dropdownLabel.BackgroundTransparency = 1
            dropdownLabel.Text = dropdownName
            dropdownLabel.Font = Enum.Font.Gotham
            dropdownLabel.TextSize = 10
            dropdownLabel.TextColor3 = Colors.TextTertiary
            dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
            dropdownLabel.ZIndex = 11
            dropdownLabel.Parent = dropdownFrame
            
            local selectedLabel = Instance.new("TextLabel")
            selectedLabel.Size = UDim2.new(1, -54, 0, 14)
            selectedLabel.Position = UDim2.new(0, 10, 0, 18)
            selectedLabel.BackgroundTransparency = 1
            selectedLabel.Text = currentValue
            selectedLabel.Font = Enum.Font.GothamMedium
            selectedLabel.TextSize = 12
            selectedLabel.TextColor3 = Colors.Text
            selectedLabel.TextXAlignment = Enum.TextXAlignment.Left
            selectedLabel.TextTruncate = Enum.TextTruncate.AtEnd
            selectedLabel.ZIndex = 11
            selectedLabel.Parent = dropdownFrame
            
            local settingsIconFrame = Instance.new("Frame")
            settingsIconFrame.Size = UDim2.new(0, 18, 0, 18)
            settingsIconFrame.Position = UDim2.new(1, -28, 0.5, -9)
            settingsIconFrame.BackgroundTransparency = 1
            settingsIconFrame.ZIndex = 11
            settingsIconFrame.Parent = dropdownFrame
            
            local settingsIcon = Utility:CreateIcon(settingsIconFrame, LucideIcons.Settings)
            settingsIcon.ZIndex = 11
            
            local optionsContainer = Instance.new("Frame")
            optionsContainer.Size = UDim2.new(1, 0, 0, 0)
            optionsContainer.Position = UDim2.new(0, 0, 0, 40)
            optionsContainer.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            optionsContainer.BorderSizePixel = 0
            optionsContainer.Visible = false
            optionsContainer.ClipsDescendants = true
            optionsContainer.ZIndex = 100
            optionsContainer.Parent = dropdownFrame
            Utility:CreateCorner(optionsContainer, 4)
            Utility:CreateStroke(optionsContainer, Colors.Border)
            
            local optionsScroll = Instance.new("ScrollingFrame")
            optionsScroll.Size = UDim2.new(1, 0, 1, 0)
            optionsScroll.BackgroundTransparency = 1
            optionsScroll.BorderSizePixel = 0
            optionsScroll.ScrollBarThickness = 3
            optionsScroll.ScrollBarImageColor3 = Colors.Border
            optionsScroll.ZIndex = 100
            optionsScroll.Parent = optionsContainer
            
            local optionsList = Utility:CreateListLayout(optionsScroll, 2)
            Utility:CreatePadding(optionsScroll, 4)
            
            for _, option in ipairs(dropdownOptions) do
                local optionButton = Instance.new("TextButton")
                optionButton.Size = UDim2.new(1, 0, 0, 28)
                optionButton.BackgroundColor3 = option == currentValue and Colors.Primary or Colors.Surface
                optionButton.BackgroundTransparency = option == currentValue and 0.85 or 1
                optionButton.Text = ""
                optionButton.AutoButtonColor = false
                optionButton.ZIndex = 100
                optionButton.Parent = optionsScroll
                Utility:CreateCorner(optionButton, 4)
                
                local optionLabel = Instance.new("TextLabel")
                optionLabel.Size = UDim2.new(1, -30, 1, 0)
                optionLabel.Position = UDim2.new(0, 8, 0, 0)
                optionLabel.BackgroundTransparency = 1
                optionLabel.Text = option
                optionLabel.Font = Enum.Font.GothamMedium
                optionLabel.TextSize = 11
                optionLabel.TextColor3 = Colors.Text
                optionLabel.TextXAlignment = Enum.TextXAlignment.Left
                optionLabel.ZIndex = 100
                optionLabel.Parent = optionButton
                
                if option == currentValue then
                    local checkFrame = Instance.new("Frame")
                    checkFrame.Size = UDim2.new(0, 12, 0, 12)
                    checkFrame.Position = UDim2.new(1, -18, 0.5, -6)
                    checkFrame.BackgroundTransparency = 1
                    checkFrame.ZIndex = 100
                    checkFrame.Parent = optionButton
                    
                    local checkIcon = Utility:CreateIcon(checkFrame, LucideIcons.Check)
                    checkIcon.ImageColor3 = Colors.Primary
                    checkIcon.ZIndex = 100
                end
                
                tabConnections:Add(optionButton.MouseButton1Click:Connect(function()
                    currentValue = option
                    selectedLabel.Text = option
                    
                    for _, child in ipairs(optionsScroll:GetChildren()) do
                        if child:IsA("TextButton") then
                            Utility:Tween(child, {BackgroundTransparency = 1})
                            for _, subChild in ipairs(child:GetChildren()) do
                                if subChild.Name == "Frame" and subChild:FindFirstChild("ImageLabel") then
                                    subChild:Destroy()
                                end
                            end
                        end
                    end
                    
                    Utility:Tween(optionButton, {BackgroundTransparency = 0.85, BackgroundColor3 = Colors.Primary})
                    
                    local checkFrame = Instance.new("Frame")
                    checkFrame.Size = UDim2.new(0, 12, 0, 12)
                    checkFrame.Position = UDim2.new(1, -18, 0.5, -6)
                    checkFrame.BackgroundTransparency = 1
                    checkFrame.ZIndex = 100
                    checkFrame.Parent = optionButton
                    
                    local checkIcon = Utility:CreateIcon(checkFrame, LucideIcons.Check)
                    checkIcon.ImageColor3 = Colors.Primary
                    checkIcon.ZIndex = 100
                    
                    isOpen = false
                    Utility:Tween(optionsContainer, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                    Utility:Tween(dropdownFrame, {Size = UDim2.new(1, 0, 0, 36)}, 0.2)
                    task.wait(0.2)
                    optionsContainer.Visible = false
                    UpdateCanvasSize()
                    
                    task.spawn(dropdownCallback, option)
                end))
                
                tabConnections:Add(optionButton.MouseEnter:Connect(function()
                    if option ~= currentValue then
                        Utility:Tween(optionButton, {BackgroundTransparency = 0.5, BackgroundColor3 = Colors.Surface})
                    end
                end))
                
                tabConnections:Add(optionButton.MouseLeave:Connect(function()
                    if option ~= currentValue then
                        Utility:Tween(optionButton, {BackgroundTransparency = 1})
                    end
                end))
            end
            
            optionsList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                optionsScroll.CanvasSize = UDim2.new(0, 0, 0, optionsList.AbsoluteContentSize.Y + 8)
            end)
            
            tabConnections:Add(dropdownButton.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                
                if isOpen then
                    optionsContainer.Visible = true
                    local targetHeight = math.min(#dropdownOptions * 30 + 8, 120)
                    Utility:Tween(optionsContainer, {Size = UDim2.new(1, 0, 0, targetHeight)}, 0.2)
                    Utility:Tween(dropdownFrame, {Size = UDim2.new(1, 0, 0, 36 + targetHeight + 4)}, 0.2)
                else
                    Utility:Tween(optionsContainer, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                    Utility:Tween(dropdownFrame, {Size = UDim2.new(1, 0, 0, 36)}, 0.2)
                    task.wait(0.2)
                    optionsContainer.Visible = false
                end
                UpdateCanvasSize()
            end))
            
            tabConnections:Add(dropdownButton.MouseEnter:Connect(function()
                Utility:Tween(dropdownFrame, {BackgroundColor3 = Colors.SurfaceHover})
            end))
            
            tabConnections:Add(dropdownButton.MouseLeave:Connect(function()
                Utility:Tween(dropdownFrame, {BackgroundColor3 = Colors.Surface})
            end))
            
            UpdateCanvasSize()
            
            return dropdownFrame
        end
        
        function Tab:CreateButton(config)
            config = config or {}
            local buttonName = config.Name or "Button"
            local buttonCallback = config.Callback or function() end
            
            elementCounter = elementCounter + 1
            local targetColumn = (elementCounter % 2 == 1) and leftColumn or rightColumn
            
            local buttonFrame = Instance.new("Frame")
            buttonFrame.Size = UDim2.new(1, 0, 0, 36)
            buttonFrame.BackgroundColor3 = Colors.Surface
            buttonFrame.BorderSizePixel = 0
            buttonFrame.Visible = currentTab == tabData
            buttonFrame.Parent = targetColumn
            Utility:CreateCorner(buttonFrame, 4)
            
            table.insert(tabData.Elements, buttonFrame)
            
            local button = Instance.new("TextButton")
            button.Size = UDim2.new(1, 0, 1, 0)
            button.BackgroundTransparency = 1
            button.Text = ""
            button.AutoButtonColor = false
            button.Parent = buttonFrame
            
            local buttonLabel = Instance.new("TextLabel")
            buttonLabel.Size = UDim2.new(1, -40, 1, 0)
            buttonLabel.Position = UDim2.new(0, 10, 0, 0)
            buttonLabel.BackgroundTransparency = 1
            buttonLabel.Text = buttonName
            buttonLabel.Font = Enum.Font.GothamMedium
            buttonLabel.TextSize = 12
            buttonLabel.TextColor3 = Colors.Text
            buttonLabel.TextXAlignment = Enum.TextXAlignment.Left
            buttonLabel.Parent = buttonFrame
            
            local chevronFrame = Instance.new("Frame")
            chevronFrame.Size = UDim2.new(0, 14, 0, 14)
            chevronFrame.Position = UDim2.new(1, -22, 0.5, -7)
            chevronFrame.BackgroundTransparency = 1
            chevronFrame.Parent = buttonFrame
            
            local chevronIcon = Utility:CreateIcon(chevronFrame, LucideIcons.ChevronRight)
            
            tabConnections:Add(button.MouseButton1Click:Connect(function()
                Utility:Tween(buttonFrame, {BackgroundColor3 = Colors.Primary}, 0.1)
                task.wait(0.1)
                Utility:Tween(buttonFrame, {BackgroundColor3 = Colors.Surface}, 0.1)
                task.spawn(buttonCallback)
            end))
            
            tabConnections:Add(button.MouseEnter:Connect(function()
                Utility:Tween(buttonFrame, {BackgroundColor3 = Colors.SurfaceHover})
            end))
            
            tabConnections:Add(button.MouseLeave:Connect(function()
                Utility:Tween(buttonFrame, {BackgroundColor3 = Colors.Surface})
            end))
            
            UpdateCanvasSize()
            
            return buttonFrame
        end
        
        function Tab:CreateLabel(text)
            elementCounter = elementCounter + 1
            local targetColumn = (elementCounter % 2 == 1) and leftColumn or rightColumn
            
            local labelFrame = Instance.new("Frame")
            labelFrame.Size = UDim2.new(1, 0, 0, 28)
            labelFrame.BackgroundColor3 = Colors.Surface
            labelFrame.BorderSizePixel = 0
            labelFrame.Visible = currentTab == tabData
            labelFrame.Parent = targetColumn
            Utility:CreateCorner(labelFrame, 4)
            
            table.insert(tabData.Elements, labelFrame)
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -20, 1, 0)
            label.Position = UDim2.new(0, 10, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = text
            label.Font = Enum.Font.GothamMedium
            label.TextSize = 12
            label.TextColor3 = Colors.Text
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextWrapped = true
            label.Parent = labelFrame
            
            UpdateCanvasSize()
            
            return labelFrame
        end
        
        return Tab
    end
    
    Utility:Tween(mainFrame, {Size = windowSize}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    Window.Destroy = function()
        windowConnections:DisconnectAll()
        for _, tab in pairs(tabs) do
            if tab.Connections then
                tab.Connections:DisconnectAll()
            end
        end
        screenGui:Destroy()
    end
    
    return Window
end

return FluentHub