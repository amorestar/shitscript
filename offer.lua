-- FluentHub v2 (исправленная версия)
-- Файл: ajkaj_fixed.lua
-- Улучшения: fallback для Parent'а, надёжное управление коннектами, исправления dropdown/checkbox/toggle/slider,
-- дизайн под пример: контрастные панели, отступы, плавные твины.

local FluentHub = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- Icons (можно заменить на свои assetid'ы)
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
    Sidebar = Color3.fromRGB(36, 36, 36),
    Surface = Color3.fromRGB(44, 44, 44),
    SurfaceHover = Color3.fromRGB(54, 54, 54),
    Primary = Color3.fromRGB(88, 101, 242),
    PrimaryHover = Color3.fromRGB(108, 121, 255),
    Text = Color3.fromRGB(245, 245, 245),
    TextSecondary = Color3.fromRGB(180, 180, 180),
    TextTertiary = Color3.fromRGB(130, 130, 130),
    Border = Color3.fromRGB(60, 60, 60),
    ToggleOff = Color3.fromRGB(70, 70, 70)
}

-- Connection tracker (надёжно отключаем все коннекты)
local ConnectionTracker = {}
ConnectionTracker.__index = ConnectionTracker
function ConnectionTracker:New()
    return setmetatable({_connections = {}}, self)
end
function ConnectionTracker:Add(conn)
    if conn then
        table.insert(self._connections, conn)
    end
    return conn
end
function ConnectionTracker:DisconnectAll()
    for _, c in ipairs(self._connections) do
        if c and c.Disconnect then
            pcall(function() c:Disconnect() end)
        end
    end
    self._connections = {}
end

local Utility = {}

-- Tween helper (безопасный pcall на Play)
function Utility:Tween(instance, properties, duration, style, direction)
    duration = duration or 0.18
    local info = TweenInfo.new(duration, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out)
    local ok, tween = pcall(function()
        return TweenService:Create(instance, info, properties)
    end)
    if ok and tween then
        pcall(function() tween:Play() end)
    end
    return tween
end

function Utility:CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Parent = parent
    return corner
end

function Utility:CreateStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Colors.Border
    stroke.Thickness = thickness or 1
    stroke.Parent = parent
    return stroke
end

function Utility:CreateIcon(parent, iconId)
    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(1, 0, 1, 0)
    icon.BackgroundTransparency = 1
    icon.Image = iconId or ""
    icon.ImageColor3 = Colors.TextSecondary
    icon.ScaleType = Enum.ScaleType.Fit
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
    layout.Padding = UDim.new(0, padding or 8)
    layout.FillDirection = direction or Enum.FillDirection.Vertical
    layout.Parent = parent
    return layout
end

-- Dragging the main frame
function Utility:MakeDraggable(frame, connections)
    local dragging, dragInput, dragStart, startPos
    connections:Add(frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            connections:Add(input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end))
        end
    end))
    connections:Add(frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end))
    connections:Add(UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging and startPos then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end))
end

-- Создаём окно
function FluentHub:CreateWindow(config)
    config = config or {}
    local windowTitle = config.Title or "Karpinware"
    local windowSize = config.Size or UDim2.new(0, 680, 0, 520)
    local windowConnections = ConnectionTracker:New()

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FluentHub_" .. HttpService:GenerateGUID(false)
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false

    -- Fallback: используем CoreGui если доступен, иначе PlayerGui
    local parentSuccess, parent = pcall(function() return CoreGui end)
    if parentSuccess and parent then
        screenGui.Parent = CoreGui
    else
        local playerGui = Players.LocalPlayer and Players.LocalPlayer:FindFirstChild("PlayerGui")
        if playerGui then
            screenGui.Parent = playerGui
        else
            -- последний resort
            screenGui.Parent = game:GetService("StarterGui")
        end
    end

    -- Main window frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 6, 0, 6) -- сначала маленький, расправится твином
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = Colors.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    Utility:CreateCorner(mainFrame, 8)
    Utility:CreateStroke(mainFrame, Colors.Border, 1)

    Utility:MakeDraggable(mainFrame, windowConnections)

    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 36)
    header.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
    header.BorderSizePixel = 0
    header.Parent = mainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0, 220, 1, 0)
    titleLabel.Position = UDim2.new(0, 12, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = windowTitle
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.TextColor3 = Colors.Text
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = header

    local versionLabel = Instance.new("TextLabel")
    versionLabel.Size = UDim2.new(0, 60, 1, 0)
    versionLabel.Position = UDim2.new(0, 240, 0, 0)
    versionLabel.BackgroundTransparency = 1
    versionLabel.Text = "6.1.0"
    versionLabel.Font = Enum.Font.Gotham
    versionLabel.TextSize = 11
    versionLabel.TextColor3 = Colors.TextTertiary
    versionLabel.TextXAlignment = Enum.TextXAlignment.Left
    versionLabel.Parent = header

    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 36, 0, 36)
    closeButton.Position = UDim2.new(1, -36, 0, 0)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "✕"
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 18
    closeButton.TextColor3 = Colors.TextSecondary
    closeButton.AutoButtonColor = false
    closeButton.Parent = header

    windowConnections:Add(closeButton.MouseButton1Click:Connect(function()
        Utility:Tween(mainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        task.delay(0.18, function()
            windowConnections:DisconnectAll()
            pcall(function() screenGui:Destroy() end)
        end)
    end))

    windowConnections:Add(closeButton.MouseEnter:Connect(function()
        closeButton.TextColor3 = Colors.Text
    end))
    windowConnections:Add(closeButton.MouseLeave:Connect(function()
        closeButton.TextColor3 = Colors.TextSecondary
    end))

    -- Container (sidebar + content)
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(1, 0, 1, -36)
    container.Position = UDim2.new(0, 0, 0, 36)
    container.BackgroundTransparency = 1
    container.Parent = mainFrame

    -- Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 150, 1, 0)
    sidebar.BackgroundColor3 = Colors.Sidebar
    sidebar.BorderSizePixel = 0
    sidebar.Parent = container
    Utility:CreateCorner(sidebar, 8)
    Utility:CreateStroke(sidebar, Color3.fromRGB(20,20,20), 1)

    -- Sidebar content holder (для табов)
    local sidebarContent = Instance.new("Frame")
    sidebarContent.Size = UDim2.new(1, 0, 1, -80)
    sidebarContent.BackgroundTransparency = 1
    sidebarContent.Parent = sidebar
    Utility:CreatePadding(sidebarContent, {Top = 12, Left = 10, Right = 10})
    local sidebarList = Utility:CreateListLayout(sidebarContent, 6)

    -- Profile (внизу сайдбара)
    local userProfile = Instance.new("Frame")
    userProfile.Name = "UserProfile"
    userProfile.Size = UDim2.new(1, 0, 0, 64)
    userProfile.Position = UDim2.new(0, 0, 1, -64)
    userProfile.BackgroundTransparency = 1
    userProfile.Parent = sidebar

    local profileBg = Instance.new("Frame")
    profileBg.Size = UDim2.new(1, -16, 1, -12)
    profileBg.Position = UDim2.new(0, 8, 0, 8)
    profileBg.BackgroundColor3 = Color3.fromRGB(28,28,28)
    profileBg.BorderSizePixel = 0
    profileBg.Parent = userProfile
    Utility:CreateCorner(profileBg, 8)
    Utility:CreateStroke(profileBg, Colors.Border, 1)

    local profileIcon = Instance.new("Frame")
    profileIcon.Size = UDim2.new(0, 36, 0, 36)
    profileIcon.Position = UDim2.new(0, 8, 0.5, -18)
    profileIcon.BackgroundColor3 = Colors.Primary
    profileIcon.BorderSizePixel = 0
    profileIcon.Parent = profileBg
    Utility:CreateCorner(profileIcon, 18)
    Utility:CreateIcon(profileIcon, LucideIcons.User).ImageColor3 = Colors.Text

    local localPlayer = Players.LocalPlayer
    local profileName = Instance.new("TextLabel")
    profileName.Size = UDim2.new(1, -60, 0, 18)
    profileName.Position = UDim2.new(0, 56, 0.5, -20)
    profileName.BackgroundTransparency = 1
    profileName.Text = localPlayer and localPlayer.Name or "Player"
    profileName.Font = Enum.Font.Gotham
    profileName.TextSize = 12
    profileName.TextColor3 = Colors.Text
    profileName.TextXAlignment = Enum.TextXAlignment.Left
    profileName.Parent = profileBg

    local profileSub = Instance.new("TextLabel")
    profileSub.Size = UDim2.new(1, -60, 0, 16)
    profileSub.Position = UDim2.new(0, 56, 0.5, 0)
    profileSub.BackgroundTransparency = 1
    profileSub.Text = "biggaboy212" -- можно заменить
    profileSub.Font = Enum.Font.Gotham
    profileSub.TextSize = 10
    profileSub.TextColor3 = Colors.TextTertiary
    profileSub.TextXAlignment = Enum.TextXAlignment.Left
    profileSub.Parent = profileBg

    -- Content area
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -150, 1, 0)
    contentFrame.Position = UDim2.new(0, 150, 0, 0)
    contentFrame.BackgroundColor3 = Colors.Background
    contentFrame.BorderSizePixel = 0
    contentFrame.ScrollBarThickness = 6
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

    local leftLayout = Utility:CreateListLayout(leftColumn, 10)
    local rightLayout = Utility:CreateListLayout(rightColumn, 10)

    local function UpdateCanvasSize()
        local leftHeight = leftLayout.AbsoluteContentSize.Y
        local rightHeight = rightLayout.AbsoluteContentSize.Y
        local maxHeight = math.max(leftHeight, rightHeight)
        contentContainer.Size = UDim2.new(1, -24, 0, maxHeight + 24)
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, maxHeight + 36)
    end

    -- Подписываемся на изменение размеров контента
    leftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvasSize)
    rightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvasSize)

    -- Tabs storage
    local tabs = {}
    local currentTab = nil
    local elementCounter = 0

    local Window = {}

    function Window:CreateTab(config)
        config = config or {}
        local tabName = config.Name or "Tab"
        local tabIcon = config.Icon or LucideIcons.Home
        local tabConnections = ConnectionTracker:New()

        -- Tab button в сайдбаре
        local tabButton = Instance.new("TextButton")
        tabButton.Name = tabName
        tabButton.Size = UDim2.new(1, 0, 0, 36)
        tabButton.BackgroundTransparency = 1
        tabButton.Text = ""
        tabButton.AutoButtonColor = false
        tabButton.Parent = sidebarContent
        Utility:CreateCorner(tabButton, 6)

        local iconFrame = Instance.new("Frame")
        iconFrame.Size = UDim2.new(0, 20, 0, 20)
        iconFrame.Position = UDim2.new(0, 8, 0.5, -10)
        iconFrame.BackgroundTransparency = 1
        iconFrame.Parent = tabButton

        local tabIconImg = Utility:CreateIcon(iconFrame, tabIcon)

        local tabLabel = Instance.new("TextLabel")
        tabLabel.Size = UDim2.new(1, -44, 1, 0)
        tabLabel.Position = UDim2.new(0, 36, 0, 0)
        tabLabel.BackgroundTransparency = 1
        tabLabel.Text = tabName
        tabLabel.Font = Enum.Font.Gotham
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

        local function DeselectTabVisual(tab)
            Utility:Tween(tab.Button, {BackgroundTransparency = 1}, 0.12)
            Utility:Tween(tab.Label, {TextColor3 = Colors.TextSecondary}, 0.12)
            tab.Icon.ImageColor3 = Colors.TextSecondary
            for _, elem in pairs(tab.Elements) do
                if elem and elem:IsA("Instance") then
                    elem.Visible = false
                end
            end
        end

        local function SelectTabVisual()
            -- deselect others
            for _, t in pairs(tabs) do
                DeselectTabVisual(t)
            end
            -- select this tab
            Utility:Tween(tabButton, {BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(50,50,50)}, 0.14)
            Utility:Tween(tabLabel, {TextColor3 = Colors.Text}, 0.14)
            tabIconImg.ImageColor3 = Colors.Primary
            for _, elem in pairs(tabData.Elements) do
                if elem and elem:IsA("Instance") then
                    elem.Visible = true
                end
            end
            currentTab = tabData
            UpdateCanvasSize()
        end

        tabConnections:Add(tabButton.MouseButton1Click:Connect(SelectTabVisual))
        tabConnections:Add(tabButton.MouseEnter:Connect(function()
            if currentTab ~= tabData then
                Utility:Tween(tabButton, {BackgroundTransparency = 0.7, BackgroundColor3 = Color3.fromRGB(48,48,48)}, 0.12)
            end
        end))
        tabConnections:Add(tabButton.MouseLeave:Connect(function()
            if currentTab ~= tabData then
                Utility:Tween(tabButton, {BackgroundTransparency = 1}, 0.12)
            end
        end))

        table.insert(tabs, tabData)
        if #tabs == 1 then
            -- сразу выбираем первый таб
            SelectTabVisual()
        end

        -- Tab API
        local Tab = {}

        function Tab:CreateToggle(config)
            config = config or {}
            local toggleName = config.Name or "Toggle"
            local toggleDefault = config.Default or false
            local toggleCallback = config.Callback or function() end

            elementCounter = elementCounter + 1
            local targetColumn = (elementCounter % 2 == 1) and leftColumn or rightColumn

            local toggleFrame = Instance.new("Frame")
            toggleFrame.Size = UDim2.new(1, 0, 0, 40)
            toggleFrame.BackgroundColor3 = Colors.Surface
            toggleFrame.BorderSizePixel = 0
            toggleFrame.Visible = (currentTab == tabData)
            toggleFrame.Parent = targetColumn
            Utility:CreateCorner(toggleFrame, 6)
            Utility:CreatePadding(toggleFrame, 6)
            table.insert(tabData.Elements, toggleFrame)

            local toggleLabel = Instance.new("TextLabel")
            toggleLabel.Size = UDim2.new(1, -78, 1, 0)
            toggleLabel.Position = UDim2.new(0, 8, 0, 0)
            toggleLabel.BackgroundTransparency = 1
            toggleLabel.Text = toggleName
            toggleLabel.Font = Enum.Font.Gotham
            toggleLabel.TextSize = 12
            toggleLabel.TextColor3 = Colors.Text
            toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            toggleLabel.Parent = toggleFrame

            local toggleButton = Instance.new("ImageButton")
            toggleButton.Size = UDim2.new(0, 44, 0, 24)
            toggleButton.Position = UDim2.new(1, -52, 0.5, -12)
            toggleButton.BackgroundColor3 = Colors.ToggleOff
            toggleButton.BorderSizePixel = 0
            toggleButton.AutoButtonColor = false
            toggleButton.Parent = toggleFrame
            Utility:CreateCorner(toggleButton, 12)

            local toggleCircle = Instance.new("Frame")
            toggleCircle.Size = UDim2.new(0, 18, 0, 18)
            toggleCircle.Position = UDim2.new(0, 3, 0.5, -9)
            toggleCircle.BackgroundColor3 = Colors.Background
            toggleCircle.BorderSizePixel = 0
            toggleCircle.Parent = toggleButton
            Utility:CreateCorner(toggleCircle, 9)

            local isToggled = toggleDefault
            local function UpdateToggle(instant)
                local dur = instant and 0 or 0.14
                if isToggled then
                    Utility:Tween(toggleButton, {BackgroundColor3 = Colors.Primary}, dur)
                    Utility:Tween(toggleCircle, {Position = UDim2.new(0, 23, 0.5, -9)}, dur)
                else
                    Utility:Tween(toggleButton, {BackgroundColor3 = Colors.ToggleOff}, dur)
                    Utility:Tween(toggleCircle, {Position = UDim2.new(0, 3, 0.5, -9)}, dur)
                end
                -- callback в отдельном потоке
                task.spawn(function() pcall(toggleCallback, isToggled) end)
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
            local sliderDefault = math.clamp(config.Default or sliderMin, sliderMin, sliderMax)
            local sliderIncrement = config.Increment or 1
            local sliderCallback = config.Callback or function() end
            local sliderSuffix = config.Suffix or ""

            elementCounter = elementCounter + 1
            local targetColumn = (elementCounter % 2 == 1) and leftColumn or rightColumn

            local sliderFrame = Instance.new("Frame")
            sliderFrame.Size = UDim2.new(1, 0, 0, 56)
            sliderFrame.BackgroundColor3 = Colors.Surface
            sliderFrame.BorderSizePixel = 0
            sliderFrame.Visible = (currentTab == tabData)
            sliderFrame.Parent = targetColumn
            Utility:CreateCorner(sliderFrame, 6)
            Utility:CreatePadding(sliderFrame, {Top=8, Left=8, Right=8, Bottom=8})
            table.insert(tabData.Elements, sliderFrame)

            local sliderLabel = Instance.new("TextLabel")
            sliderLabel.Size = UDim2.new(0.6, 0, 0, 18)
            sliderLabel.Position = UDim2.new(0, 2, 0, 0)
            sliderLabel.BackgroundTransparency = 1
            sliderLabel.Text = sliderName
            sliderLabel.Font = Enum.Font.Gotham
            sliderLabel.TextSize = 12
            sliderLabel.TextColor3 = Colors.Text
            sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            sliderLabel.Parent = sliderFrame

            local valueDisplay = Instance.new("Frame")
            valueDisplay.Size = UDim2.new(0, 56, 0, 18)
            valueDisplay.Position = UDim2.new(1, -58, 0, 0)
            valueDisplay.BackgroundColor3 = Colors.Background
            valueDisplay.BorderSizePixel = 0
            valueDisplay.Parent = sliderFrame
            Utility:CreateCorner(valueDisplay, 4)

            local valueLabel = Instance.new("TextLabel")
            valueLabel.Size = UDim2.new(1, -6, 1, 0)
            valueLabel.Position = UDim2.new(0, 4, 0, 0)
            valueLabel.BackgroundTransparency = 1
            valueLabel.Text = tostring(sliderDefault) .. sliderSuffix
            valueLabel.Font = Enum.Font.GothamBold
            valueLabel.TextSize = 11
            valueLabel.TextColor3 = Colors.TextSecondary
            valueLabel.TextXAlignment = Enum.TextXAlignment.Right
            valueLabel.Parent = valueDisplay

            local sliderTrack = Instance.new("Frame")
            sliderTrack.Size = UDim2.new(1, -16, 0, 6)
            sliderTrack.Position = UDim2.new(0, 8, 1, -18)
            sliderTrack.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
            sliderTrack.BorderSizePixel = 0
            sliderTrack.Parent = sliderFrame
            Utility:CreateCorner(sliderTrack, 4)

            local sliderFill = Instance.new("Frame")
            local fraction = (sliderDefault - sliderMin) / math.max(1, (sliderMax - sliderMin))
            sliderFill.Size = UDim2.new(fraction, 0, 1, 0)
            sliderFill.BackgroundColor3 = Colors.Primary
            sliderFill.BorderSizePixel = 0
            sliderFill.Parent = sliderTrack
            Utility:CreateCorner(sliderFill, 4)

            local sliderThumb = Instance.new("Frame")
            sliderThumb.Size = UDim2.new(0, 14, 0, 14)
            sliderThumb.Position = UDim2.new(fraction, -7, 0.5, -7)
            sliderThumb.BackgroundColor3 = Colors.Text
            sliderThumb.BorderSizePixel = 0
            sliderThumb.ZIndex = 2
            sliderThumb.Parent = sliderTrack
            Utility:CreateCorner(sliderThumb, 7)

            local sliderButton = Instance.new("TextButton")
            sliderButton.Size = UDim2.new(1, 0, 1, 0)
            sliderButton.BackgroundTransparency = 1
            sliderButton.Text = ""
            sliderButton.AutoButtonColor = false
            sliderButton.Parent = sliderTrack

            local draggingSlider = false
            local function UpdateSliderFromInput(input)
                local absPos = sliderTrack.AbsolutePosition
                local absSize = sliderTrack.AbsoluteSize
                local posX = math.clamp((input.Position.X - absPos.X) / absSize.X, 0, 1)
                local rawValue = sliderMin + (sliderMax - sliderMin) * posX
                local value = math.floor(rawValue / sliderIncrement + 0.5) * sliderIncrement
                value = math.clamp(value, sliderMin, sliderMax)
                local frac = (value - sliderMin) / math.max(1, (sliderMax - sliderMin))
                sliderFill.Size = UDim2.new(frac, 0, 1, 0)
                sliderThumb.Position = UDim2.new(frac, -7, 0.5, -7)
                valueLabel.Text = tostring(value) .. sliderSuffix
                task.spawn(function() pcall(sliderCallback, value) end)
            end

            tabConnections:Add(sliderButton.MouseButton1Down:Connect(function()
                draggingSlider = true
                Utility:Tween(sliderThumb, {Size = UDim2.new(0, 18, 0, 18)}, 0.08)
            end))
            tabConnections:Add(UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSlider = false
                    Utility:Tween(sliderThumb, {Size = UDim2.new(0, 14, 0, 14)}, 0.08)
                end
            end))
            tabConnections:Add(UserInputService.InputChanged:Connect(function(input)
                if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
                    UpdateSliderFromInput(input)
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
            dropdownFrame.Size = UDim2.new(1, 0, 0, 40)
            dropdownFrame.BackgroundColor3 = Colors.Surface
            dropdownFrame.BorderSizePixel = 0
            dropdownFrame.Visible = (currentTab == tabData)
            dropdownFrame.ClipsDescendants = true
            dropdownFrame.Parent = targetColumn
            Utility:CreateCorner(dropdownFrame, 6)
            table.insert(tabData.Elements, dropdownFrame)

            local dropdownButton = Instance.new("TextButton")
            dropdownButton.Size = UDim2.new(1, 0, 0, 40)
            dropdownButton.BackgroundTransparency = 1
            dropdownButton.Text = ""
            dropdownButton.AutoButtonColor = false
            dropdownButton.Parent = dropdownFrame

            local dropdownLabel = Instance.new("TextLabel")
            dropdownLabel.Size = UDim2.new(1, -48, 0, 14)
            dropdownLabel.Position = UDim2.new(0, 10, 0, 6)
            dropdownLabel.BackgroundTransparency = 1
            dropdownLabel.Text = dropdownName
            dropdownLabel.Font = Enum.Font.Gotham
            dropdownLabel.TextSize = 10
            dropdownLabel.TextColor3 = Colors.TextTertiary
            dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
            dropdownLabel.Parent = dropdownFrame

            local selectedLabel = Instance.new("TextLabel")
            selectedLabel.Size = UDim2.new(1, -48, 0, 16)
            selectedLabel.Position = UDim2.new(0, 10, 0, 18)
            selectedLabel.BackgroundTransparency = 1
            selectedLabel.Text = tostring(currentValue)
            selectedLabel.Font = Enum.Font.GothamBold
            selectedLabel.TextSize = 12
            selectedLabel.TextColor3 = Colors.Text
            selectedLabel.TextXAlignment = Enum.TextXAlignment.Left
            selectedLabel.TextTruncate = Enum.TextTruncate.AtEnd
            selectedLabel.Parent = dropdownFrame

            local arrowFrame = Instance.new("Frame")
            arrowFrame.Size = UDim2.new(0, 18, 0, 18)
            arrowFrame.Position = UDim2.new(1, -28, 0.5, -9)
            arrowFrame.BackgroundTransparency = 1
            arrowFrame.Parent = dropdownFrame
            Utility:CreateIcon(arrowFrame, LucideIcons.ChevronDown)

            local optionsContainer = Instance.new("Frame")
            optionsContainer.Size = UDim2.new(1, 0, 0, 0)
            optionsContainer.Position = UDim2.new(0, 0, 0, 42)
            optionsContainer.BackgroundColor3 = Color3.fromRGB(40,40,40)
            optionsContainer.BorderSizePixel = 0
            optionsContainer.Visible = false
            optionsContainer.ClipsDescendants = true
            optionsContainer.Parent = dropdownFrame
            Utility:CreateCorner(optionsContainer, 6)
            Utility:CreateStroke(optionsContainer, Colors.Border, 1)

            local optionsScroll = Instance.new("ScrollingFrame")
            optionsScroll.Size = UDim2.new(1, 0, 1, 0)
            optionsScroll.BackgroundTransparency = 1
            optionsScroll.BorderSizePixel = 0
            optionsScroll.ScrollBarThickness = 5
            optionsScroll.ScrollBarImageColor3 = Colors.Border
            optionsScroll.Parent = optionsContainer

            local optionsList = Utility:CreateListLayout(optionsScroll, 4)
            Utility:CreatePadding(optionsScroll, 6)

            local function refreshOptionsVisuals()
                for _, child in ipairs(optionsScroll:GetChildren()) do
                    if child:IsA("TextButton") then
                        child.BackgroundTransparency = (child:GetAttribute("OptionValue") == currentValue) and 0.12 or 1
                        child.BackgroundColor3 = (child:GetAttribute("OptionValue") == currentValue) and Colors.Primary or Colors.Surface
                        -- remove old check if any
                        if child:FindFirstChild("Check") then child.Check:Destroy() end
                        if child:GetAttribute("OptionValue") == currentValue then
                            local check = Instance.new("ImageLabel")
                            check.Name = "Check"
                            check.Size = UDim2.new(0, 14, 0, 14)
                            check.Position = UDim2.new(1, -20, 0.5, -7)
                            check.BackgroundTransparency = 1
                            check.Image = LucideIcons.Check
                            check.ImageColor3 = Colors.Text
                            check.Parent = child
                        end
                    end
                end
            end

            for _, option in ipairs(dropdownOptions) do
                local optionButton = Instance.new("TextButton")
                optionButton.Size = UDim2.new(1, 0, 0, 28)
                optionButton.BackgroundColor3 = Colors.Surface
                optionButton.BackgroundTransparency = (option == currentValue) and 0.12 or 1
                optionButton.Text = ""
                optionButton.AutoButtonColor = false
                optionButton.Parent = optionsScroll
                Utility:CreateCorner(optionButton, 4)
                optionButton:SetAttribute("OptionValue", option)

                local optionLabel = Instance.new("TextLabel")
                optionLabel.Size = UDim2.new(1, -28, 1, 0)
                optionLabel.Position = UDim2.new(0, 8, 0, 0)
                optionLabel.BackgroundTransparency = 1
                optionLabel.Text = option
                optionLabel.Font = Enum.Font.Gotham
                optionLabel.TextSize = 11
                optionLabel.TextColor3 = Colors.Text
                optionLabel.TextXAlignment = Enum.TextXAlignment.Left
                optionLabel.Parent = optionButton

                tabConnections:Add(optionButton.MouseButton1Click:Connect(function()
                    currentValue = option
                    selectedLabel.Text = option
                    refreshOptionsVisuals()
                    -- close
                    isOpen = false
                    Utility:Tween(optionsContainer, {Size = UDim2.new(1, 0, 0, 0)}, 0.14)
                    Utility:Tween(dropdownFrame, {Size = UDim2.new(1, 0, 0, 40)}, 0.14)
                    task.delay(0.14, function()
                        optionsContainer.Visible = false
                        UpdateCanvasSize()
                    end)
                    task.spawn(function() pcall(dropdownCallback, option) end)
                end))

                tabConnections:Add(optionButton.MouseEnter:Connect(function()
                    if option ~= currentValue then
                        Utility:Tween(optionButton, {BackgroundTransparency = 0.6, BackgroundColor3 = Colors.Surface}, 0.08)
                    end
                end))
                tabConnections:Add(optionButton.MouseLeave:Connect(function()
                    if option ~= currentValue then
                        Utility:Tween(optionButton, {BackgroundTransparency = 1}, 0.08)
                    end
                end))
            end

            optionsList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                optionsScroll.CanvasSize = UDim2.new(0, 0, 0, optionsList.AbsoluteContentSize.Y + 6)
            end)

            tabConnections:Add(dropdownButton.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                if isOpen then
                    optionsContainer.Visible = true
                    local targetHeight = math.min(#dropdownOptions * 32 + 8, 160)
                    Utility:Tween(optionsContainer, {Size = UDim2.new(1, 0, 0, targetHeight)}, 0.16)
                    Utility:Tween(dropdownFrame, {Size = UDim2.new(1, 0, 0, 40 + targetHeight + 6)}, 0.16)
                else
                    Utility:Tween(optionsContainer, {Size = UDim2.new(1, 0, 0, 0)}, 0.14)
                    Utility:Tween(dropdownFrame, {Size = UDim2.new(1, 0, 0, 40)}, 0.14)
                    task.delay(0.14, function() optionsContainer.Visible = false end)
                end
                UpdateCanvasSize()
            end))

            tabConnections:Add(dropdownButton.MouseEnter:Connect(function()
                Utility:Tween(dropdownFrame, {BackgroundColor3 = Colors.SurfaceHover}, 0.08)
            end))
            tabConnections:Add(dropdownButton.MouseLeave:Connect(function()
                Utility:Tween(dropdownFrame, {BackgroundColor3 = Colors.Surface}, 0.08)
            end))

            -- initial visuals
            task.spawn(refreshOptionsVisuals)
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
            buttonFrame.Size = UDim2.new(1, 0, 0, 40)
            buttonFrame.BackgroundColor3 = Colors.Surface
            buttonFrame.BorderSizePixel = 0
            buttonFrame.Visible = (currentTab == tabData)
            buttonFrame.Parent = targetColumn
            Utility:CreateCorner(buttonFrame, 6)
            Utility:CreatePadding(buttonFrame, 6)
            table.insert(tabData.Elements, buttonFrame)

            local button = Instance.new("TextButton")
            button.Size = UDim2.new(1, 0, 1, 0)
            button.BackgroundTransparency = 1
            button.Text = ""
            button.AutoButtonColor = false
            button.Parent = buttonFrame

            local buttonLabel = Instance.new("TextLabel")
            buttonLabel.Size = UDim2.new(1, -40, 1, 0)
            buttonLabel.Position = UDim2.new(0, 8, 0, 0)
            buttonLabel.BackgroundTransparency = 1
            buttonLabel.Text = buttonName
            buttonLabel.Font = Enum.Font.Gotham
            buttonLabel.TextSize = 12
            buttonLabel.TextColor3 = Colors.Text
            buttonLabel.TextXAlignment = Enum.TextXAlignment.Left
            buttonLabel.Parent = buttonFrame

            local chevronFrame = Instance.new("Frame")
            chevronFrame.Size = UDim2.new(0, 14, 0, 14)
            chevronFrame.Position = UDim2.new(1, -24, 0.5, -7)
            chevronFrame.BackgroundTransparency = 1
            chevronFrame.Parent = buttonFrame
            Utility:CreateIcon(chevronFrame, LucideIcons.ChevronRight)

            tabConnections:Add(button.MouseButton1Click:Connect(function()
                Utility:Tween(buttonFrame, {BackgroundColor3 = Colors.Primary}, 0.1)
                task.delay(0.09, function()
                    Utility:Tween(buttonFrame, {BackgroundColor3 = Colors.Surface}, 0.12)
                end)
                task.spawn(function() pcall(buttonCallback) end)
            end))

            tabConnections:Add(button.MouseEnter:Connect(function()
                Utility:Tween(buttonFrame, {BackgroundColor3 = Colors.SurfaceHover}, 0.08)
            end))
            tabConnections:Add(button.MouseLeave:Connect(function()
                Utility:Tween(buttonFrame, {BackgroundColor3 = Colors.Surface}, 0.08)
            end))

            UpdateCanvasSize()
            return buttonFrame
        end

        function Tab:CreateLabel(text)
            elementCounter = elementCounter + 1
            local targetColumn = (elementCounter % 2 == 1) and leftColumn or rightColumn

            local labelFrame = Instance.new("Frame")
            labelFrame.Size = UDim2.new(1, 0, 0, 36)
            labelFrame.BackgroundColor3 = Colors.Surface
            labelFrame.BorderSizePixel = 0
            labelFrame.Visible = (currentTab == tabData)
            labelFrame.Parent = targetColumn
            Utility:CreateCorner(labelFrame, 6)
            Utility:CreatePadding(labelFrame, 8)
            table.insert(tabData.Elements, labelFrame)

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -16, 1, 0)
            label.Position = UDim2.new(0, 8, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = text or ""
            label.Font = Enum.Font.Goham
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

    -- Open animation
    Utility:Tween(mainFrame, {Size = windowSize}, 0.26, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    Window.Destroy = function()
        windowConnections:DisconnectAll()
        for _, tab in pairs(tabs) do
            if tab.Connections then tab.Connections:DisconnectAll() end
        end
        pcall(function() screenGui:Destroy() end)
    end

    return Window
end

return FluentHub
