-- DinoHub GUI for Roblox
-- A modern, minimalist interface with advanced features

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- Variables
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local Camera = workspace.CurrentCamera
local MenuOpen = true  -- Add this variable to track menu state
local MenuToggleKey = Enum.KeyCode.RightControl  -- Default key to toggle menu

-- GUI Settings
local Settings = {
    UIName = "DinoHub",
    Theme = {
        Background = Color3.fromRGB(25, 25, 30), -- Fond plus sombre
        Accent = Color3.fromRGB(255, 128, 185), -- Rose accent
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(200, 200, 210), -- Texte secondaire plus clair
        Border = Color3.fromRGB(35, 35, 40), -- Bordures plus subtiles
        Hover = Color3.fromRGB(45, 45, 50),
        Selected = Color3.fromRGB(50, 50, 55),
        Success = Color3.fromRGB(130, 255, 160),
        Warning = Color3.fromRGB(255, 190, 105),
        Error = Color3.fromRGB(255, 115, 115)
    },
    Transparency = 0.3, -- Plus transparent pour un look plus moderne
    CornerRadius = UDim.new(0, 12), -- Coins plus arrondis
    AnimationSpeed = 0.3, -- Animations plus longues
    CategoryNames = {
        Player = "Player",
        Visuals = "Visuals",
        Target = "Target",
        Misc = "Misc"
    },
    Notifications = {
        Duration = 5,
        Position = UDim2.new(1, -20, 0, 20),
        Size = UDim2.new(0, 300, 0, 80),
        MaxNotifications = 5
    },
    SmartBar = {
        ToggleKey = Enum.KeyCode.Semicolon,
        Position = UDim2.new(0.5, -200, 0.5, -20),
        Size = UDim2.new(0, 400, 0, 40)
    }
}

-- Notification System
local NotificationSystem = {}

function NotificationSystem.new()
    local Container = Instance.new("Frame")
    Container.Name = "NotificationContainer"
    Container.Size = UDim2.new(0, 300, 1, -40)
    Container.Position = Settings.Notifications.Position
    Container.BackgroundTransparency = 1
    Container.Parent = DinoHub
    
    local Layout = Instance.new("UIListLayout")
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.VerticalAlignment = Enum.VerticalAlignment.Top
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    Layout.Padding = UDim.new(0, 10)
    Layout.Parent = Container
    
    return Container
end

function NotificationSystem.notify(container, title, message, notifType)
    local colors = {
        Success = Settings.Theme.Success,
        Warning = Settings.Theme.Warning,
        Error = Settings.Theme.Error,
        Info = Settings.Theme.Accent
    }
    
    local Notification = Instance.new("Frame")
    Notification.Name = "Notification"
    Notification.Size = UDim2.new(1, 0, 0, 80)
    Notification.BackgroundColor3 = Settings.Theme.Background
    Notification.BackgroundTransparency = Settings.Transparency - 0.3
    Notification.BorderSizePixel = 0
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = Settings.CornerRadius
    Corner.Parent = Notification
    
    local Accent = Instance.new("Frame")
    Accent.Name = "Accent"
    Accent.Size = UDim2.new(0, 4, 1, 0)
    Accent.BackgroundColor3 = colors[notifType] or colors.Info
    Accent.BorderSizePixel = 0
    Accent.Parent = Notification
    
    local AccentCorner = Instance.new("UICorner")
    AccentCorner.CornerRadius = UDim.new(0, 2)
    AccentCorner.Parent = Accent
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -20, 0, 25)
    Title.Position = UDim2.new(0, 15, 0, 5)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.Text = title
    Title.TextColor3 = Settings.Theme.Text
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Notification
    
    local Message = Instance.new("TextLabel")
    Message.Name = "Message"
    Message.Size = UDim2.new(1, -20, 0, 40)
    Message.Position = UDim2.new(0, 15, 0, 30)
    Message.BackgroundTransparency = 1
    Message.Font = Enum.Font.Gotham
    Message.Text = message
    Message.TextColor3 = Settings.Theme.SubText
    Message.TextSize = 12
    Message.TextWrapped = true
    Message.TextXAlignment = Enum.TextXAlignment.Left
    Message.Parent = Notification
    
    -- Animation
    Notification.Position = UDim2.new(1, 20, 0, 0)
    Notification.Parent = container
    
    TweenService:Create(
        Notification,
        TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        {Position = UDim2.new(0, 0, 0, 0)}
    ):Play()
    
    -- Auto remove
    task.delay(Settings.Notifications.Duration, function()
        TweenService:Create(
            Notification,
            TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {Position = UDim2.new(1, 20, 0, 0)}
        ):Play()
        
        task.wait(0.3)
        Notification:Destroy()
    end)
end

-- SmartBar System
local SmartBar = {}

function SmartBar.new()
    local Bar = Instance.new("Frame")
    Bar.Name = "SmartBar"
    Bar.Size = Settings.SmartBar.Size
    Bar.Position = Settings.SmartBar.Position
    Bar.BackgroundColor3 = Settings.Theme.Background
    Bar.BackgroundTransparency = Settings.Transparency - 0.3
    Bar.BorderSizePixel = 0
    Bar.Visible = false
    Bar.Parent = DinoHub
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = Settings.CornerRadius
    Corner.Parent = Bar
    
    local Input = Instance.new("TextBox")
    Input.Name = "Input"
    Input.Size = UDim2.new(1, -20, 1, 0)
    Input.Position = UDim2.new(0, 10, 0, 0)
    Input.BackgroundTransparency = 1
    Input.Font = Enum.Font.GothamBold
    Input.Text = ""
    Input.PlaceholderText = "Type a command..."
    Input.TextColor3 = Settings.Theme.Text
    Input.PlaceholderColor3 = Settings.Theme.SubText
    Input.TextSize = 14
    Input.Parent = Bar
    
    -- Toggle visibility with key
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Settings.SmartBar.ToggleKey then
            Bar.Visible = not Bar.Visible
            if Bar.Visible then
                Input:CaptureFocus()
            end
        end
    end)
    
    Input.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            -- Process command
            local command = Input.Text:lower()
            Input.Text = ""
            Bar.Visible = false
            
            -- Add command processing here
            if command == "fly" then
                -- Toggle fly
            elseif command == "noclip" then
                -- Toggle noclip
            end
        end
    end)
    
    return Bar
end

-- Create the main GUI
local function CreateDinoHub()
    -- Create the ScreenGui
    local DinoHub = Instance.new("ScreenGui")
    DinoHub.Name = Settings.UIName
    DinoHub.ResetOnSpawn = false
    DinoHub.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Create the main frame with blur effect
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 700, 0, 450) -- Plus grand pour plus d'espace
    MainFrame.Position = UDim2.new(0.5, -350, 0.5, -225)
    MainFrame.BackgroundColor3 = Settings.Theme.Background
    MainFrame.BackgroundTransparency = Settings.Transparency
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = DinoHub
    
    -- Add blur effect
    local Blur = Instance.new("BlurEffect")
    Blur.Size = 0
    Blur.Parent = MainFrame
    
    -- Create the top bar with gradient
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 45) -- Plus grand pour plus d'espace
    TopBar.BackgroundColor3 = Settings.Theme.Background
    TopBar.BackgroundTransparency = 0.2
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame
    
    -- Add gradient to top bar
    local TopGradient = Instance.new("UIGradient")
    TopGradient.Rotation = 90
    TopGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 45, 50)),
        ColorSequenceKeypoint.new(1, Settings.Theme.Background)
    })
    TopGradient.Parent = TopBar
    
    -- Create corner for the top bar
    local TopBarCorner = Instance.new("UICorner")
    TopBarCorner.CornerRadius = UDim.new(0, 12)
    TopBarCorner.Parent = TopBar
    
    -- Title text with gradient
    local TitleText = Instance.new("TextLabel")
    TitleText.Name = "TitleText"
    TitleText.Size = UDim2.new(0, 200, 1, 0)
    TitleText.Position = UDim2.new(0, 15, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Font = Enum.Font.GothamBold
    TitleText.Text = Settings.UIName
    TitleText.TextColor3 = Settings.Theme.Accent
    TitleText.TextSize = 24 -- Plus grand
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TopBar
    
    -- Add gradient to title text
    local TitleGradient = Instance.new("UIGradient")
    TitleGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Settings.Theme.Accent),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 150, 200))
    })
    TitleGradient.Parent = TitleText
    
    -- Close button with hover effect
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 35, 0, 35) -- Plus grand
    CloseButton.Position = UDim2.new(1, -45, 0, 5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
    CloseButton.BackgroundTransparency = 0.3
    CloseButton.BorderSizePixel = 0
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "×" -- Symbole plus élégant
    CloseButton.TextColor3 = Settings.Theme.Text
    CloseButton.TextSize = 20
    CloseButton.Parent = TopBar
    
    -- Create corner for the close button
    local CloseButtonCorner = Instance.new("UICorner")
    CloseButtonCorner.CornerRadius = UDim.new(0, 8)
    CloseButtonCorner.Parent = CloseButton
    
    -- Add hover effect to close button
    CloseButton.MouseEnter:Connect(function()
        TweenService:Create(
            CloseButton,
            TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {BackgroundTransparency = 0}
        ):Play()
    end)
    
    CloseButton.MouseLeave:Connect(function()
        TweenService:Create(
            CloseButton,
            TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {BackgroundTransparency = 0.3}
        ):Play()
    end)
    
    -- Sidebar with gradient
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 120, 1, -45) -- Plus large
    Sidebar.Position = UDim2.new(0, 0, 0, 45)
    Sidebar.BackgroundColor3 = Settings.Theme.Border
    Sidebar.BackgroundTransparency = 0.7
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    
    -- Add gradient to sidebar
    local SidebarGradient = Instance.new("UIGradient")
    SidebarGradient.Rotation = 90
    SidebarGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 45)),
        ColorSequenceKeypoint.new(1, Settings.Theme.Background)
    })
    SidebarGradient.Parent = Sidebar
    
    -- Create corner for the sidebar
    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 12)
    SidebarCorner.Parent = Sidebar
    
    -- Content container with padding
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -130, 1, -55)
    ContentContainer.Position = UDim2.new(0, 125, 0, 50)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.BorderSizePixel = 0
    ContentContainer.Parent = MainFrame
    
    -- Add padding to content container
    local ContentPadding = Instance.new("UIPadding")
    ContentPadding.PaddingLeft = UDim.new(0, 15)
    ContentPadding.PaddingRight = UDim.new(0, 15)
    ContentPadding.PaddingTop = UDim.new(0, 15)
    ContentPadding.PaddingBottom = UDim.new(0, 15)
    ContentPadding.Parent = ContentContainer
    
    -- Create tabs and sidebar buttons
    local Tabs = {}
    local Categories = {"Player", "Visuals", "Target", "Misc"}
    
    for i, category in ipairs(Categories) do
        -- Create sidebar button with modern design
        local ButtonFrame = Instance.new("Frame")
        ButtonFrame.Name = category .. "ButtonFrame"
        ButtonFrame.Size = UDim2.new(1, 0, 0, 45) -- Plus grand
        ButtonFrame.Position = UDim2.new(0, 0, 0, (i - 1) * 50) -- Plus d'espace
        ButtonFrame.BackgroundTransparency = 1
        ButtonFrame.Parent = Sidebar
        
        local Button = Instance.new("TextButton")
        Button.Name = category .. "Button"
        Button.Size = UDim2.new(1, -20, 1, 0)
        Button.Position = UDim2.new(0, 10, 0, 0)
        Button.BackgroundTransparency = 1
        Button.BorderSizePixel = 0
        Button.Text = ""
        Button.Parent = ButtonFrame
        
        -- Button text label with gradient
        local ButtonText = Instance.new("TextLabel")
        ButtonText.Name = "Text"
        ButtonText.Size = UDim2.new(1, -10, 1, 0)
        ButtonText.Position = UDim2.new(0, 10, 0, 0)
        ButtonText.BackgroundTransparency = 1
        ButtonText.Font = Enum.Font.GothamBold
        ButtonText.Text = Settings.CategoryNames[category]
        ButtonText.TextColor3 = Settings.Theme.SubText
        ButtonText.TextSize = 16 -- Plus grand
        ButtonText.TextXAlignment = Enum.TextXAlignment.Left
        ButtonText.Parent = Button
        
        -- Add gradient to button text
        local ButtonTextGradient = Instance.new("UIGradient")
        ButtonTextGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Settings.Theme.SubText),
            ColorSequenceKeypoint.new(1, Settings.Theme.Text)
        })
        ButtonTextGradient.Parent = ButtonText
        
        -- Indicator with animation
        local Indicator = Instance.new("Frame")
        Indicator.Name = "Indicator"
        Indicator.Size = UDim2.new(0, 3, 0, 25) -- Plus épais
        Indicator.Position = UDim2.new(0, 0, 0.5, -12.5)
        Indicator.BackgroundColor3 = Settings.Theme.Accent
        Indicator.BackgroundTransparency = 1
        Indicator.BorderSizePixel = 0
        Indicator.Parent = ButtonFrame
        
        -- Add corner to indicator
        local IndicatorCorner = Instance.new("UICorner")
        IndicatorCorner.CornerRadius = UDim.new(0, 1.5)
        IndicatorCorner.Parent = Indicator
        
        -- Hover effect with animation
        local HoverEffect = Instance.new("Frame")
        HoverEffect.Name = "HoverEffect"
        HoverEffect.Size = UDim2.new(1, -4, 1, -8)
        HoverEffect.Position = UDim2.new(0, 2, 0, 4)
        HoverEffect.BackgroundColor3 = Settings.Theme.Selected
        HoverEffect.BackgroundTransparency = 1
        HoverEffect.BorderSizePixel = 0
        HoverEffect.ZIndex = 0
        HoverEffect.Parent = ButtonFrame
        
        local HoverCorner = Instance.new("UICorner")
        HoverCorner.CornerRadius = UDim.new(0, 8)
        HoverCorner.Parent = HoverEffect
        
        -- Create content tab with modern design
        local Tab = Instance.new("ScrollingFrame")
        Tab.Name = category .. "Tab"
        Tab.Size = UDim2.new(1, 0, 1, 0)
        Tab.BackgroundTransparency = 1
        Tab.BorderSizePixel = 0
        Tab.ScrollBarThickness = 4
        Tab.ScrollBarImageColor3 = Settings.Theme.Accent
        Tab.ScrollBarImageTransparency = 0.5
        Tab.Visible = i == 1
        Tab.Parent = ContentContainer
        
        -- Tab layout with more spacing
        local TabLayout = Instance.new("UIListLayout")
        TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
        TabLayout.Padding = UDim.new(0, 15) -- Plus d'espace
        TabLayout.Parent = Tab
        
        -- Button click event with smooth animations
        Button.MouseButton1Click:Connect(function()
            for _, tabData in pairs(Tabs) do
                if tabData.Tab ~= Tab then
                    tabData.Tab.Visible = false
                    TweenService:Create(
                        tabData.ButtonText,
                        TweenInfo.new(Settings.AnimationSpeed, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                        {TextColor3 = Settings.Theme.SubText}
                    ):Play()
                    TweenService:Create(
                        tabData.Indicator,
                        TweenInfo.new(Settings.AnimationSpeed, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                        {BackgroundTransparency = 1}
                    ):Play()
                    TweenService:Create(
                        tabData.HoverEffect,
                        TweenInfo.new(Settings.AnimationSpeed, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                        {BackgroundTransparency = 1}
                    ):Play()
                end
            end
            
            Tab.Visible = true
            TweenService:Create(
                ButtonText,
                TweenInfo.new(Settings.AnimationSpeed, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                {TextColor3 = Settings.Theme.Accent}
            ):Play()
            
            TweenService:Create(
                Indicator,
                TweenInfo.new(Settings.AnimationSpeed, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                {BackgroundTransparency = 0}
            ):Play()
            
            TweenService:Create(
                HoverEffect,
                TweenInfo.new(Settings.AnimationSpeed, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                {BackgroundTransparency = 0.8}
            ):Play()
        end)
        
        -- Hover effects with smooth animations
        Button.MouseEnter:Connect(function()
            if Tab.Visible then return end
            TweenService:Create(
                HoverEffect,
                TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                {BackgroundTransparency = 0.9}
            ):Play()
            
            TweenService:Create(
                ButtonText,
                TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                {TextColor3 = Settings.Theme.Text}
            ):Play()
        end)
        
        Button.MouseLeave:Connect(function()
            if Tab.Visible then return end
            TweenService:Create(
                HoverEffect,
                TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                {BackgroundTransparency = 1}
            ):Play()
            
            TweenService:Create(
                ButtonText,
                TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                {TextColor3 = Settings.Theme.SubText}
            ):Play()
        end)
        
        -- Add to the tabs table
        Tabs[category] = {
            Tab = Tab,
            Button = Button,
            ButtonText = ButtonText,
            Indicator = Indicator,
            HoverEffect = HoverEffect
        }
        
        -- Set initial selected tab with animation
        if i == 1 then
            ButtonText.TextColor3 = Settings.Theme.Accent
            Indicator.BackgroundTransparency = 0
            HoverEffect.BackgroundTransparency = 0.8
        end
    end
    
    -- Close button functionality with animation
    CloseButton.MouseButton1Click:Connect(function()
        TweenService:Create(
            MainFrame,
            TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}
        ):Play()
        
        TweenService:Create(
            Blur,
            TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {Size = 0}
        ):Play()
        
        wait(0.3)
        DinoHub:Destroy()
    end)
    
    return DinoHub, Tabs
end

-- Create UI elements functions
local UI = {}

-- Create a section
function UI.CreateSection(tab, title)
    local Section = Instance.new("Frame")
    Section.Name = title .. "Section"
    Section.Size = UDim2.new(1, 0, 0, 40)
    Section.BackgroundTransparency = 1
    Section.BorderSizePixel = 0
    Section.AutomaticSize = Enum.AutomaticSize.Y
    Section.Parent = tab
    
    -- Section title
    local SectionTitle = Instance.new("TextLabel")
    SectionTitle.Name = "Title"
    SectionTitle.Size = UDim2.new(1, -20, 0, 30)
    SectionTitle.Position = UDim2.new(0, 10, 0, 5)
    SectionTitle.BackgroundTransparency = 1
    SectionTitle.Font = Enum.Font.GothamBold
    SectionTitle.Text = title
    SectionTitle.TextColor3 = Settings.Theme.Accent
    SectionTitle.TextSize = 16
    SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    SectionTitle.Parent = Section
    
    -- Section content
    local SectionContent = Instance.new("Frame")
    SectionContent.Name = "Content"
    SectionContent.Size = UDim2.new(1, -20, 0, 0)
    SectionContent.Position = UDim2.new(0, 10, 0, 35)
    SectionContent.BackgroundTransparency = 1
    SectionContent.BorderSizePixel = 0
    SectionContent.AutomaticSize = Enum.AutomaticSize.Y
    SectionContent.Parent = Section
    
    -- Content layout
    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Padding = UDim.new(0, 10)
    ContentLayout.Parent = SectionContent
    
    -- Content padding
    local ContentPadding = Instance.new("UIPadding")
    ContentPadding.PaddingBottom = UDim.new(0, 10)
    ContentPadding.Parent = SectionContent
    
    -- Add separator line
    local Separator = Instance.new("Frame")
    Separator.Name = "Separator"
    Separator.Size = UDim2.new(1, -40, 0, 1)
    Separator.Position = UDim2.new(0, 20, 1, 10)
    Separator.BackgroundColor3 = Settings.Theme.Border
    Separator.BorderSizePixel = 0
    Separator.Parent = Section
    
    -- Add gradient to separator
    local Gradient = Instance.new("UIGradient")
    Gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.8),
        NumberSequenceKeypoint.new(0.5, 0.5),
        NumberSequenceKeypoint.new(1, 0.8)
    })
    Gradient.Parent = Separator
    
    return SectionContent
end

-- Create a checkbox
function UI.CreateCheckbox(parent, title, callback)
    local Checkbox = Instance.new("Frame")
    Checkbox.Name = title .. "Checkbox"
    Checkbox.Size = UDim2.new(1, 0, 0, 30)
    Checkbox.BackgroundTransparency = 1
    Checkbox.BorderSizePixel = 0
    Checkbox.Parent = parent
    
    -- Checkbox title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -60, 1, 0)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.Gotham
    Title.Text = title
    Title.TextColor3 = Settings.Theme.Text
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Checkbox
    
    -- Checkbox box
    local Box = Instance.new("Frame")
    Box.Name = "Box"
    Box.Size = UDim2.new(0, 20, 0, 20)
    Box.Position = UDim2.new(1, -30, 0.5, -10)
    Box.BackgroundColor3 = Settings.Theme.Border
    Box.BorderSizePixel = 0
    Box.Parent = Checkbox
    
    -- Create corner for the box
    local BoxCorner = Instance.new("UICorner")
    BoxCorner.CornerRadius = UDim.new(0, 4)
    BoxCorner.Parent = Box
    
    -- Checkbox check
    local Check = Instance.new("Frame")
    Check.Name = "Check"
    Check.Size = UDim2.new(0, 12, 0, 12)
    Check.Position = UDim2.new(0.5, -6, 0.5, -6)
    Check.BackgroundColor3 = Settings.Theme.Accent
    Check.BorderSizePixel = 0
    Check.BackgroundTransparency = 1
    Check.Parent = Box
    
    -- Create corner for the check
    local CheckCorner = Instance.new("UICorner")
    CheckCorner.CornerRadius = UDim.new(0, 3)
    CheckCorner.Parent = Check
    
    -- Hit box
    local Button = Instance.new("TextButton")
    Button.Name = "Button"
    Button.Size = UDim2.new(1, 0, 1, 0)
    Button.BackgroundTransparency = 1
    Button.Text = ""
    Button.Parent = Checkbox
    
    -- Functionality
    local Checked = false
    
    local function UpdateCheckbox()
        Checked = not Checked
        
        TweenService:Create(
            Check,
            TweenInfo.new(Settings.AnimationSpeed, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {BackgroundTransparency = Checked and 0 or 1}
        ):Play()
        
        if callback then
            callback(Checked)
        end
    end
    
    Button.MouseButton1Click:Connect(UpdateCheckbox)
    
    return {
        Instance = Checkbox,
        Set = function(value)
            if Checked ~= value then
                UpdateCheckbox()
            end
        end
    }
end

-- Create a slider
function UI.CreateSlider(parent, title, min, max, default, callback)
    local Slider = Instance.new("Frame")
    Slider.Name = title .. "Slider"
    Slider.Size = UDim2.new(1, 0, 0, 50)
    Slider.BackgroundTransparency = 1
    Slider.BorderSizePixel = 0
    Slider.Parent = parent
    
    -- Slider title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, 0, 0, 20)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.Gotham
    Title.Text = title
    Title.TextColor3 = Settings.Theme.Text
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Slider
    
    -- Value display
    local ValueDisplay = Instance.new("TextLabel")
    ValueDisplay.Name = "Value"
    ValueDisplay.Size = UDim2.new(0, 50, 0, 20)
    ValueDisplay.Position = UDim2.new(1, -50, 0, 0)
    ValueDisplay.BackgroundTransparency = 1
    ValueDisplay.Font = Enum.Font.GothamBold
    ValueDisplay.Text = tostring(default)
    ValueDisplay.TextColor3 = Settings.Theme.Accent
    ValueDisplay.TextSize = 14
    ValueDisplay.TextXAlignment = Enum.TextXAlignment.Right
    ValueDisplay.Parent = Slider
    
    -- Slider bar background
    local SliderBar = Instance.new("Frame")
    SliderBar.Name = "SliderBar"
    SliderBar.Size = UDim2.new(1, 0, 0, 8)
    SliderBar.Position = UDim2.new(0, 0, 0, 30)
    SliderBar.BackgroundColor3 = Settings.Theme.Border
    SliderBar.BorderSizePixel = 0
    SliderBar.Parent = Slider
    
    -- Create corner for the slider bar
    local SliderBarCorner = Instance.new("UICorner")
    SliderBarCorner.CornerRadius = UDim.new(0, 4)
    SliderBarCorner.Parent = SliderBar
    
    -- Slider fill
    local SliderFill = Instance.new("Frame")
    SliderFill.Name = "SliderFill"
    SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Settings.Theme.Accent
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBar
    
    -- Create corner for the slider fill
    local SliderFillCorner = Instance.new("UICorner")
    SliderFillCorner.CornerRadius = UDim.new(0, 4)
    SliderFillCorner.Parent = SliderFill
    
    -- Slider knob
    local SliderKnob = Instance.new("Frame")
    SliderKnob.Name = "SliderKnob"
    SliderKnob.Size = UDim2.new(0, 16, 0, 16)
    SliderKnob.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
    SliderKnob.BackgroundColor3 = Settings.Theme.Text
    SliderKnob.BorderSizePixel = 0
    SliderKnob.ZIndex = 2
    SliderKnob.Parent = SliderBar
    
    -- Create corner for the slider knob
    local SliderKnobCorner = Instance.new("UICorner")
    SliderKnobCorner.CornerRadius = UDim.new(0.5, 0)
    SliderKnobCorner.Parent = SliderKnob
    
    -- Hit box
    local Button = Instance.new("TextButton")
    Button.Name = "Button"
    Button.Size = UDim2.new(1, 0, 1, 10)
    Button.Position = UDim2.new(0, 0, 0, -5)
    Button.BackgroundTransparency = 1
    Button.Text = ""
    Button.Parent = SliderBar
    
    -- Functionality
    local Value = default
    
    local function UpdateSlider(input)
        local sizeX = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
        Value = math.floor(min + ((max - min) * sizeX))
        ValueDisplay.Text = tostring(Value)
        
        TweenService:Create(
            SliderFill,
            TweenInfo.new(Settings.AnimationSpeed, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {Size = UDim2.new(sizeX, 0, 1, 0)}
        ):Play()
        
        TweenService:Create(
            SliderKnob,
            TweenInfo.new(Settings.AnimationSpeed, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {Position = UDim2.new(sizeX, -8, 0.5, -8)}
        ):Play()
        
        if callback then
            callback(Value)
        end
    end
    
    Button.MouseButton1Down:Connect(function()
        local Connection
        Connection = RunService.RenderStepped:Connect(function()
            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                UpdateSlider({Position = Vector2.new(Mouse.X, Mouse.Y)})
            else
                Connection:Disconnect()
            end
        end)
    end)
    
    return {
        Instance = Slider,
        Set = function(value)
            Value = math.clamp(value, min, max)
            ValueDisplay.Text = tostring(Value)
            local sizeX = (Value - min) / (max - min)
            
            SliderFill.Size = UDim2.new(sizeX, 0, 1, 0)
            SliderKnob.Position = UDim2.new(sizeX, -8, 0.5, -8)
            
            if callback then
                callback(Value)
            end
        end
    }
end

-- Create a keybind button
function UI.CreateKeybind(parent, title, default, callback)
    local Keybind = Instance.new("Frame")
    Keybind.Name = title .. "Keybind"
    Keybind.Size = UDim2.new(1, 0, 0, 30)
    Keybind.BackgroundTransparency = 1
    Keybind.BorderSizePixel = 0
    Keybind.Parent = parent
    
    -- Keybind title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -80, 1, 0)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.Gotham
    Title.Text = title
    Title.TextColor3 = Settings.Theme.Text
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Keybind
    
    -- Key display
    local KeyDisplay = Instance.new("TextButton")
    KeyDisplay.Name = "KeyDisplay"
    KeyDisplay.Size = UDim2.new(0, 70, 0, 24)
    KeyDisplay.Position = UDim2.new(1, -70, 0.5, -12)
    KeyDisplay.BackgroundColor3 = Settings.Theme.Border
    KeyDisplay.BorderSizePixel = 0
    KeyDisplay.Font = Enum.Font.GothamBold
    KeyDisplay.Text = default or "None"
    KeyDisplay.TextColor3 = Settings.Theme.Text
    KeyDisplay.TextSize = 12
    KeyDisplay.Parent = Keybind
    
    -- Create corner for the key display
    local KeyDisplayCorner = Instance.new("UICorner")
    KeyDisplayCorner.CornerRadius = UDim.new(0, 4)
    KeyDisplayCorner.Parent = KeyDisplay
    
    -- Functionality
    local CurrentKey = default
    local Listening = false
    
    KeyDisplay.MouseButton1Click:Connect(function()
        Listening = true
        KeyDisplay.Text = "..."
        KeyDisplay.TextColor3 = Settings.Theme.Accent
    end)
    
    UserInputService.InputBegan:Connect(function(input)
        if Listening and input.UserInputType == Enum.UserInputType.Keyboard then
            Listening = false
            CurrentKey = input.KeyCode.Name
            KeyDisplay.Text = CurrentKey
            KeyDisplay.TextColor3 = Settings.Theme.Text
            
            if callback then
                callback(input.KeyCode)
            end
        elseif not Listening and CurrentKey and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == CurrentKey then
            if callback then
                callback(input.KeyCode)
            end
        end
    end)
    
    return {
        Instance = Keybind,
        Set = function(key)
            CurrentKey = key.Name
            KeyDisplay.Text = CurrentKey
        end
    }
end

-- Create a button
function UI.CreateButton(parent, title, callback)
    local Button = Instance.new("Frame")
    Button.Name = title .. "Button"
    Button.Size = UDim2.new(1, 0, 0, 36)
    Button.BackgroundTransparency = 1
    Button.BorderSizePixel = 0
    Button.Parent = parent
    
    -- Button background
    local ButtonBG = Instance.new("TextButton")
    ButtonBG.Name = "ButtonBG"
    ButtonBG.Size = UDim2.new(1, 0, 1, 0)
    ButtonBG.BackgroundColor3 = Settings.Theme.Border
    ButtonBG.BorderSizePixel = 0
    ButtonBG.Font = Enum.Font.GothamBold
    ButtonBG.Text = title
    ButtonBG.TextColor3 = Settings.Theme.Text
    ButtonBG.TextSize = 14
    ButtonBG.Parent = Button
    
    -- Create corner for the button background
    local ButtonBGCorner = Instance.new("UICorner")
    ButtonBGCorner.CornerRadius = UDim.new(0, 6)
    ButtonBGCorner.Parent = ButtonBG
    
    -- Functionality
    ButtonBG.MouseButton1Click:Connect(function()
        -- Click effect
        TweenService:Create(
            ButtonBG,
            TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {BackgroundColor3 = Settings.Theme.Accent}
        ):Play()
        
        if callback then
            callback()
        end
        
        wait(0.1)
        
        TweenService:Create(
            ButtonBG,
            TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {BackgroundColor3 = Settings.Theme.Border}
        ):Play()
    end)
    
    -- Hover effect
    ButtonBG.MouseEnter:Connect(function()
        TweenService:Create(
            ButtonBG,
            TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {BackgroundColor3 = Settings.Theme.Border}
        ):Play()
    end)
    
    return Button
end

-- Initialize the DinoHub GUI
local function Initialize()
    local DinoHub, Tabs = CreateDinoHub()
    
    -- Initialize notification system
    local NotificationContainer = NotificationSystem.new()
    
    -- Initialize SmartBar
    local CommandBar = SmartBar.new()
    
    -- Add opening animation
    DinoHub.MainFrame.Size = UDim2.new(0, 0, 0, 0)
    DinoHub.MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    TweenService:Create(
        DinoHub.MainFrame,
        TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        {
            Size = UDim2.new(0, 700, 0, 450),
            Position = UDim2.new(0.5, -350, 0.5, -225)
        }
    ):Play()
    
    -- Add blur effect animation
    local Blur = Instance.new("BlurEffect")
    Blur.Size = 0
    Blur.Parent = DinoHub.MainFrame
    
    TweenService:Create(
        Blur,
        TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        {Size = 10}
    ):Play()
    
    -- Player Tab
    local PlayerTab = Tabs["Player"].Tab
    
    -- General section in Player tab
    local GeneralSection = UI.CreateSection(PlayerTab, "Movement")
    
    -- Walk Speed slider
    local WalkSpeedSlider = UI.CreateSlider(GeneralSection, "Walk Speed", 16, 500, 16, function(value)
        if Player.Character and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid.WalkSpeed = value
        end
    end)
    
    -- Jump Power slider
    local JumpPowerSlider = UI.CreateSlider(GeneralSection, "Jump Power", 50, 500, 50, function(value)
        if Player.Character and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid.JumpPower = value
        end
    end)
    
    -- Fly section
    local FlySection = UI.CreateSection(PlayerTab, "Flight")
    
    -- Variables for fly
    local Flying = false
    local FlySpeed = 10
    local MaxFlySpeed = 200
    
    -- Fly speed slider
    local FlySpeedSlider = UI.CreateSlider(FlySection, "Fly Speed", 10, 200, 10, function(value)
        FlySpeed = value
    end)
    
    -- Fly checkbox
    local FlyCheckbox = UI.CreateCheckbox(FlySection, "Fly", function(state)
        Flying = state
        
        if state then
            -- Enable fly
            local Character = Player.Character
            if not Character then return end
            
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            local HRP = Character:FindFirstChild("HumanoidRootPart")
            if not Humanoid or not HRP then return end
            
            -- Remove existing fly instances if they exist
            if HRP:FindFirstChild("FlyBodyGyro") then
                HRP.FlyBodyGyro:Destroy()
            end
            if HRP:FindFirstChild("FlyBodyVelocity") then
                HRP.FlyBodyVelocity:Destroy()
            end
            
            local FlyBG = Instance.new("BodyGyro")
            FlyBG.Name = "FlyBodyGyro"
            FlyBG.P = 9e4
            FlyBG.maxTorque = Vector3.new(9e9, 9e9, 9e9)
            FlyBG.cframe = HRP.CFrame
            FlyBG.Parent = HRP
            
            local FlyBV = Instance.new("BodyVelocity")
            FlyBV.Name = "FlyBodyVelocity"
            FlyBV.velocity = Vector3.new(0, 0.1, 0)
            FlyBV.maxForce = Vector3.new(9e9, 9e9, 9e9)
            FlyBV.Parent = HRP
            
            Humanoid.PlatformStand = true
            
            -- Create fly connection
            if _G.FlyConnection then
                _G.FlyConnection:Disconnect()
            end
            
            _G.FlyConnection = RunService.Heartbeat:Connect(function()
                if not Flying then
                    _G.FlyConnection:Disconnect()
                    return
                end
                
                if not Character or not Character.Parent or not HRP or not Humanoid or Humanoid.Health <= 0 then
                    Flying = false
                    FlyCheckbox.Set(false)
                    _G.FlyConnection:Disconnect()
                    return
                end
                
                FlyBG.cframe = CFrame.new(HRP.Position, HRP.Position + Camera.CFrame.LookVector)
                
                local Direction = Vector3.new()
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    Direction = Direction + (Camera.CFrame.LookVector * FlySpeed)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    Direction = Direction - (Camera.CFrame.LookVector * FlySpeed)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    Direction = Direction - (Camera.CFrame.RightVector * FlySpeed)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    Direction = Direction + (Camera.CFrame.RightVector * FlySpeed)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    Direction = Direction + Vector3.new(0, FlySpeed, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    Direction = Direction - Vector3.new(0, FlySpeed, 0)
                end
                
                FlyBV.velocity = Direction
            end)
            
            -- Add character removal detection
            if _G.CharacterRemovedConnection then
                _G.CharacterRemovedConnection:Disconnect()
            end
            
            _G.CharacterRemovedConnection = Player.CharacterRemoving:Connect(function()
                Flying = false
                FlyCheckbox.Set(false)
                if _G.FlyConnection then
                    _G.FlyConnection:Disconnect()
                end
            end)
            
        else
            -- Disable fly
            if _G.FlyConnection then
                _G.FlyConnection:Disconnect()
            end
            
            local Character = Player.Character
            if Character then
                local Humanoid = Character:FindFirstChildOfClass("Humanoid")
                local HRP = Character:FindFirstChild("HumanoidRootPart")
                
                if HRP then
                    if HRP:FindFirstChild("FlyBodyGyro") then
                        HRP.FlyBodyGyro:Destroy()
                    end
                    if HRP:FindFirstChild("FlyBodyVelocity") then
                        HRP.FlyBodyVelocity:Destroy()
                    end
                end
                
                if Humanoid then
                    Humanoid.PlatformStand = false
                end
            end
        end
    end)
    
    -- Noclip section
    local MiscSection = UI.CreateSection(PlayerTab, "Misc")
    
    -- Noclip checkbox
    local NoclipCheckbox = UI.CreateCheckbox(MiscSection, "Noclip", function(state)
        if state then
            -- Enable noclip
            local NoclipConnection
            NoclipConnection = RunService.Stepped:Connect(function()
                if Player.Character then
                    for _, part in pairs(Player.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                else
                    NoclipConnection:Disconnect()
                    NoclipCheckbox.Set(false)
                end
            end)
        else
            -- Disable noclip
            for _, part in pairs(Player.Character:GetDescendants()) do
                if part:IsA("BasePart") and not part.CanCollide then
                    part.CanCollide = true
                end
            end
        end
    end)
    
    -- Infinite Jump checkbox
    local InfiniteJumpCheckbox = UI.CreateCheckbox(MiscSection, "Infinite Jump", function(state)
        if state then
            -- Enable infinite jump
            local InfJumpConnection
            InfJumpConnection = UserInputService.JumpRequest:Connect(function()
                if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
                    Player.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
                else
                    InfJumpConnection:Disconnect()
                    InfiniteJumpCheckbox.Set(false)
                end
            end)
        else
            -- Infinite jump is disconnected automatically when toggled off
        end
    end)
    
    -- Initialize other tabs with placeholders
    local VisualTab = Tabs["Visuals"].Tab
    
    -- ESP Section
    local ESPSection = UI.CreateSection(VisualTab, "ESP")
    
    -- Variables for ESP
    local ESPEnabled = false
    local ESPBoxes = false
    local ESPNames = false
    local ESPDistance = false
    local ESPHealth = false
    local ESPTeamColor = false
    local ESPColor = Settings.Theme.Accent -- Rose pink by default
    local ESPTransparency = 0.5
    local ESPRange = 1000
    local ESPFontSize = 14
    local ESPBoxThickness = 1
    
    -- Table to store ESP objects
    local ESPObjects = {}
    
    -- Function to create ESP objects for a player
    local function CreateESPObject(player)
        if ESPObjects[player] then return end
        
        -- Create ESP objects using Drawing library
        local Box = Drawing.new("Square")
        Box.Thickness = ESPBoxThickness
        Box.Filled = false
        Box.Visible = false
        Box.Color = ESPColor
        Box.Transparency = 1
        
        local Name = Drawing.new("Text")
        Name.Center = true
        Name.Size = ESPFontSize
        Name.Outline = true
        Name.Visible = false
        Name.Color = ESPColor
        
        local Distance = Drawing.new("Text")
        Distance.Center = true
        Distance.Size = ESPFontSize
        Distance.Outline = true
        Distance.Visible = false
        Distance.Color = ESPColor
        
        local HealthBar = Drawing.new("Square")
        HealthBar.Thickness = 1
        HealthBar.Filled = true
        HealthBar.Visible = false
        HealthBar.Color = Color3.fromRGB(0, 255, 0)
        
        local HealthBarBG = Drawing.new("Square")
        HealthBarBG.Thickness = 1
        HealthBarBG.Filled = true
        HealthBarBG.Visible = false
        HealthBarBG.Color = Color3.fromRGB(255, 0, 0)
        
        ESPObjects[player] = {
            Box = Box,
            Name = Name,
            Distance = Distance,
            HealthBar = HealthBar,
            HealthBarBG = HealthBarBG
        }
    end
    
    -- Function to remove ESP objects for a player
    local function RemoveESPObject(player)
        local objects = ESPObjects[player]
        if objects then
            for _, object in pairs(objects) do
                object:Remove()
            end
            ESPObjects[player] = nil
        end
    end
    
    -- Function to update ESP
    local function UpdateESP()
        for player, objects in pairs(ESPObjects) do
            if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid") then
                local character = player.Character
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                local hrp = character:FindFirstChild("HumanoidRootPart")
                local head = character:FindFirstChild("Head")
                
                if not head then continue end
                
                local distance = (hrp.Position - Camera.CFrame.Position).Magnitude
                if distance > ESPRange then
                    objects.Box.Visible = false
                    objects.Name.Visible = false
                    objects.Distance.Visible = false
                    objects.HealthBar.Visible = false
                    objects.HealthBarBG.Visible = false
                    continue
                end
                
                local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if not onScreen then
                    objects.Box.Visible = false
                    objects.Name.Visible = false
                    objects.Distance.Visible = false
                    objects.HealthBar.Visible = false
                    objects.HealthBarBG.Visible = false
                    continue
                end
                
                -- Calculate box size based on distance
                local size = 1 / (distance * 0.1) * 1000
                local boxSize = Vector2.new(size * 0.7, size)
                
                -- Update box
                if ESPBoxes then
                    objects.Box.Visible = true
                    objects.Box.Size = boxSize
                    objects.Box.Position = Vector2.new(screenPos.X - boxSize.X / 2, screenPos.Y - boxSize.Y / 2)
                    objects.Box.Color = ESPTeamColor and player.TeamColor.Color or ESPColor
                else
                    objects.Box.Visible = false
                end
                
                -- Update name
                if ESPNames then
                    objects.Name.Visible = true
                    objects.Name.Position = Vector2.new(screenPos.X, screenPos.Y - boxSize.Y / 2 - 5)
                    objects.Name.Text = player.DisplayName
                    objects.Name.Color = ESPTeamColor and player.TeamColor.Color or ESPColor
                else
                    objects.Name.Visible = false
                end
                
                -- Update distance
                if ESPDistance then
                    objects.Distance.Visible = true
                    objects.Distance.Position = Vector2.new(screenPos.X, screenPos.Y + boxSize.Y / 2 + 2)
                    objects.Distance.Text = string.format("%.0f", distance)
                    objects.Distance.Color = ESPTeamColor and player.TeamColor.Color or ESPColor
                else
                    objects.Distance.Visible = false
                end
                
                -- Update health bar
                if ESPHealth then
                    local healthPercent = humanoid.Health / humanoid.MaxHealth
                    local barHeight = boxSize.Y
                    local barWidth = 3
                    local barPosition = Vector2.new(screenPos.X + boxSize.X / 2 + 2, screenPos.Y - boxSize.Y / 2)
                    
                    objects.HealthBarBG.Visible = true
                    objects.HealthBarBG.Size = Vector2.new(barWidth, barHeight)
                    objects.HealthBarBG.Position = barPosition
                    
                    objects.HealthBar.Visible = true
                    objects.HealthBar.Size = Vector2.new(barWidth, barHeight * healthPercent)
                    objects.HealthBar.Position = Vector2.new(barPosition.X, barPosition.Y + barHeight * (1 - healthPercent))
                    objects.HealthBar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                else
                    objects.HealthBar.Visible = false
                    objects.HealthBarBG.Visible = false
                end
            else
                objects.Box.Visible = false
                objects.Name.Visible = false
                objects.Distance.Visible = false
                objects.HealthBar.Visible = false
                objects.HealthBarBG.Visible = false
            end
        end
    end
    
    -- ESP Settings
    local ESPCheckbox = UI.CreateCheckbox(ESPSection, "Enable ESP", function(state)
        ESPEnabled = state
        if state then
            -- Create ESP objects for all players
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= Player then
                    CreateESPObject(player)
                end
            end
            
            -- Create ESP connection
            if _G.ESPConnection then
                _G.ESPConnection:Disconnect()
            end
            
            _G.ESPConnection = RunService.RenderStepped:Connect(UpdateESP)
            
            -- Handle new players
            if _G.ESPPlayerAdded then
                _G.ESPPlayerAdded:Disconnect()
            end
            
            _G.ESPPlayerAdded = Players.PlayerAdded:Connect(function(player)
                if player ~= Player then
                    CreateESPObject(player)
                end
            end)
            
            -- Handle players leaving
            if _G.ESPPlayerRemoving then
                _G.ESPPlayerRemoving:Disconnect()
            end
            
            _G.ESPPlayerRemoving = Players.PlayerRemoving:Connect(function(player)
                RemoveESPObject(player)
            end)
            
        else
            -- Disable ESP
            if _G.ESPConnection then
                _G.ESPConnection:Disconnect()
            end
            if _G.ESPPlayerAdded then
                _G.ESPPlayerAdded:Disconnect()
            end
            if _G.ESPPlayerRemoving then
                _G.ESPPlayerRemoving:Disconnect()
            end
            
            -- Remove all ESP objects
            for player, _ in pairs(ESPObjects) do
                RemoveESPObject(player)
            end
        end
    end)
    
    -- ESP Features
    local ESPBoxesCheckbox = UI.CreateCheckbox(ESPSection, "Show Boxes", function(state)
        ESPBoxes = state
    end)
    
    local ESPNamesCheckbox = UI.CreateCheckbox(ESPSection, "Show Names", function(state)
        ESPNames = state
    end)
    
    local ESPDistanceCheckbox = UI.CreateCheckbox(ESPSection, "Show Distance", function(state)
        ESPDistance = state
    end)
    
    local ESPHealthCheckbox = UI.CreateCheckbox(ESPSection, "Show Health", function(state)
        ESPHealth = state
    end)
    
    local ESPTeamColorCheckbox = UI.CreateCheckbox(ESPSection, "Use Team Colors", function(state)
        ESPTeamColor = state
    end)
    
    -- ESP Range Slider
    local ESPRangeSlider = UI.CreateSlider(ESPSection, "ESP Range", 100, 2000, 1000, function(value)
        ESPRange = value
    end)
    
    -- Lighting Section
    local LightingSection = UI.CreateSection(VisualTab, "Lighting")
    
    -- Variables for lighting
    local FullbrightEnabled = false
    local OriginalAmbient
    local OriginalBrightness
    local OriginalClockTime
    local OriginalFogEnd
    local OriginalGlobalShadows
    
    -- Fullbright checkbox
    local FullbrightCheckbox = UI.CreateCheckbox(LightingSection, "Fullbright", function(state)
        FullbrightEnabled = state
        
        local lighting = game:GetService("Lighting")
        
        if state then
            -- Store original lighting values
            OriginalAmbient = lighting.Ambient
            OriginalBrightness = lighting.Brightness
            OriginalClockTime = lighting.ClockTime
            OriginalFogEnd = lighting.FogEnd
            OriginalGlobalShadows = lighting.GlobalShadows
            
            -- Apply fullbright
            lighting.Ambient = Color3.fromRGB(255, 255, 255)
            lighting.Brightness = 2
            lighting.ClockTime = 14
            lighting.FogEnd = 100000
            lighting.GlobalShadows = false
            
            -- Create fullbright connection
            if _G.FullbrightConnection then
                _G.FullbrightConnection:Disconnect()
            end
            
            _G.FullbrightConnection = RunService.RenderStepped:Connect(function()
                if not FullbrightEnabled then
                    _G.FullbrightConnection:Disconnect()
                    return
                end
                
                lighting.Ambient = Color3.fromRGB(255, 255, 255)
                lighting.Brightness = 2
                lighting.ClockTime = 14
                lighting.FogEnd = 100000
                lighting.GlobalShadows = false
            end)
            
        else
            -- Restore original lighting
            if _G.FullbrightConnection then
                _G.FullbrightConnection:Disconnect()
            end
            
            lighting.Ambient = OriginalAmbient
            lighting.Brightness = OriginalBrightness
            lighting.ClockTime = OriginalClockTime
            lighting.FogEnd = OriginalFogEnd
            lighting.GlobalShadows = OriginalGlobalShadows
        end
    end)
    
    -- Other Visual Features Section
    local OtherSection = UI.CreateSection(VisualTab, "Other")
    
    -- Variables for other visual features
    local NoFogEnabled = false
    local OriginalFog
    
    -- No Fog checkbox
    local NoFogCheckbox = UI.CreateCheckbox(OtherSection, "No Fog", function(state)
        NoFogEnabled = state
        
        local lighting = game:GetService("Lighting")
        
        if state then
            -- Store original fog
            OriginalFog = lighting.FogEnd
            
            -- Remove fog
            lighting.FogEnd = 100000
            
            -- Create no fog connection
            if _G.NoFogConnection then
                _G.NoFogConnection:Disconnect()
            end
            
            _G.NoFogConnection = RunService.RenderStepped:Connect(function()
                if not NoFogEnabled then
                    _G.NoFogConnection:Disconnect()
                    return
                end
                
                lighting.FogEnd = 100000
            end)
            
        else
            -- Restore original fog
            if _G.NoFogConnection then
                _G.NoFogConnection:Disconnect()
            end
            
            lighting.FogEnd = OriginalFog
        end
    end)
    
    -- Zoom Distance Slider
    local ZoomDistanceSlider = UI.CreateSlider(OtherSection, "Zoom Distance", 10, 1000, 400, function(value)
        Player.CameraMaxZoomDistance = value
    end)
    
    -- Field of View Slider
    local FOVSlider = UI.CreateSlider(OtherSection, "Field of View", 70, 120, 70, function(value)
        Camera.FieldOfView = value
    end)
    
    -- Target Tab
    local TargetTab = Tabs["Target"].Tab
    
    -- Variables for targeting system
    local SelectedTarget = nil
    local ViewingTarget = false
    local FollowingTarget = false
    local FollowDistance = 5
    local SittingOnHead = false
    
    -- Current Target Display
    local CurrentTargetSection = UI.CreateSection(TargetTab, "Current Target")
    local CurrentTargetLabel = Instance.new("TextLabel")
    CurrentTargetLabel.Size = UDim2.new(1, 0, 0, 35)
    CurrentTargetLabel.BackgroundTransparency = 1
    CurrentTargetLabel.Font = Enum.Font.GothamBold
    CurrentTargetLabel.TextColor3 = Settings.Theme.Accent
    CurrentTargetLabel.TextSize = 16
    CurrentTargetLabel.Text = "No Target Selected"
    CurrentTargetLabel.Parent = CurrentTargetSection
    
    -- Add gradient to current target label
    local CurrentTargetGradient = Instance.new("UIGradient")
    CurrentTargetGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Settings.Theme.Accent),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 150, 200))
    })
    CurrentTargetGradient.Parent = CurrentTargetLabel
    
    -- Target Selection Section
    local TargetSelectionSection = UI.CreateSection(TargetTab, "Target Selection")
    
    -- Variables for closest target system
    local ScanningForTarget = false
    local MaxTargetDistance = 100
    local ScanInterval = 0.1
    
    -- Quick search box with modern design
    local SearchBox = Instance.new("Frame")
    SearchBox.Name = "SearchBox"
    SearchBox.Size = UDim2.new(1, 0, 0, 35)
    SearchBox.BackgroundColor3 = Settings.Theme.Border
    SearchBox.BackgroundTransparency = 0.5
    SearchBox.BorderSizePixel = 0
    SearchBox.Parent = TargetSelectionSection
    
    local SearchBoxCorner = Instance.new("UICorner")
    SearchBoxCorner.CornerRadius = UDim.new(0, 8)
    SearchBoxCorner.Parent = SearchBox
    
    local SearchInput = Instance.new("TextBox")
    SearchInput.Name = "SearchInput"
    SearchInput.Size = UDim2.new(1, -20, 1, 0)
    SearchInput.Position = UDim2.new(0, 10, 0, 0)
    SearchInput.BackgroundTransparency = 1
    SearchInput.Font = Enum.Font.Gotham
    SearchInput.PlaceholderText = "Search player by name or display name..."
    SearchInput.Text = ""
    SearchInput.TextColor3 = Settings.Theme.Text
    SearchInput.PlaceholderColor3 = Settings.Theme.SubText
    SearchInput.TextSize = 14
    SearchInput.TextXAlignment = Enum.TextXAlignment.Left
    SearchInput.Parent = SearchBox
    
    -- Quick search results with modern design
    local SearchResults = Instance.new("Frame")
    SearchResults.Name = "SearchResults"
    SearchResults.Size = UDim2.new(1, 0, 0, 0)
    SearchResults.BackgroundTransparency = 1
    SearchResults.AutomaticSize = Enum.AutomaticSize.Y
    SearchResults.Visible = false
    SearchResults.Parent = TargetSelectionSection
    
    local ResultsLayout = Instance.new("UIListLayout")
    ResultsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ResultsLayout.Padding = UDim.new(0, 8)
    ResultsLayout.Parent = SearchResults
    
    -- Target scan settings
    local ScanSettingsSection = UI.CreateSection(TargetTab, "Scan Settings")
    
    -- Max Distance Slider
    local MaxDistanceSlider = UI.CreateSlider(ScanSettingsSection, "Max Target Distance", 10, 500, 100, function(value)
        MaxTargetDistance = value
    end)
    
    -- Select Closest button
    local SelectClosestButton = UI.CreateButton(ScanSettingsSection, "Select Closest Player", function()
        local Character = Player.Character
        if not Character or not Character:FindFirstChild("HumanoidRootPart") then 
            NotificationSystem.notify(NotificationContainer, "Error", "You need to be spawned to select a target", "Error")
            return 
        end
        
        local HRP = Character.HumanoidRootPart
        local ClosestPlayer = nil
        local ClosestDistance = MaxTargetDistance
        
        for _, target in pairs(Players:GetPlayers()) do
            if target ~= Player then
                local TargetCharacter = target.Character
                if TargetCharacter and TargetCharacter:FindFirstChild("HumanoidRootPart") then
                    local TargetHRP = TargetCharacter.HumanoidRootPart
                    local Distance = (TargetHRP.Position - HRP.Position).Magnitude
                    
                    if Distance < ClosestDistance then
                        -- Check if target is alive
                        local Humanoid = TargetCharacter:FindFirstChildOfClass("Humanoid")
                        if Humanoid and Humanoid.Health > 0 then
                            ClosestDistance = Distance
                            ClosestPlayer = target
                        end
                    end
                end
            end
        end
        
        -- Update selected target if we found one
        if ClosestPlayer then
            SelectedTarget = ClosestPlayer
            CurrentTargetLabel.Text = string.format("Current Target: %s (@%s)", ClosestPlayer.DisplayName, ClosestPlayer.Name)
            NotificationSystem.notify(NotificationContainer, "Target Selected", string.format("Now targeting %s (%.1f studs away)", ClosestPlayer.DisplayName, ClosestDistance), "Success")
        else
            SelectedTarget = nil
            CurrentTargetLabel.Text = "No Target Selected"
            NotificationSystem.notify(NotificationContainer, "No Target Found", "No players found within range", "Warning")
        end
    end)
    
    -- Search functionality
    local function UpdateSearch()
        SearchResults.Visible = false
        for _, child in pairs(SearchResults:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        local searchText = SearchInput.Text:lower()
        if searchText == "" then return end
        
        local matches = {}
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Player then
                local name = player.Name:lower()
                local displayName = player.DisplayName:lower()
                if name:find(searchText) or displayName:find(searchText) then
                    table.insert(matches, player)
                end
            end
        end
        
        if #matches > 0 then
            SearchResults.Visible = true
            for _, player in pairs(matches) do
                local ResultButton = Instance.new("TextButton")
                ResultButton.Size = UDim2.new(1, 0, 0, 35)
                ResultButton.BackgroundColor3 = Settings.Theme.Border
                ResultButton.BackgroundTransparency = 0.7
                ResultButton.BorderSizePixel = 0
                ResultButton.Font = Enum.Font.Gotham
                ResultButton.Text = string.format("%s (@%s)", player.DisplayName, player.Name)
                ResultButton.TextColor3 = Settings.Theme.Text
                ResultButton.TextSize = 14
                ResultButton.Parent = SearchResults
                
                local ResultCorner = Instance.new("UICorner")
                ResultCorner.CornerRadius = UDim.new(0, 8)
                ResultCorner.Parent = ResultButton
                
                -- Add hover effect
                ResultButton.MouseEnter:Connect(function()
                    TweenService:Create(
                        ResultButton,
                        TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                        {BackgroundTransparency = 0.5}
                    ):Play()
                end)
                
                ResultButton.MouseLeave:Connect(function()
                    TweenService:Create(
                        ResultButton,
                        TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                        {BackgroundTransparency = 0.7}
                    ):Play()
                end)
                
                ResultButton.MouseButton1Click:Connect(function()
                    SelectedTarget = player
                    CurrentTargetLabel.Text = string.format("Current Target: %s (@%s)", player.DisplayName, player.Name)
                    SearchResults.Visible = false
                    SearchInput.Text = ""
                end)
            end
        end
    end
    
    SearchInput:GetPropertyChangedSignal("Text"):Connect(UpdateSearch)
    
    -- Target Actions Section
    local TargetActionsSection = UI.CreateSection(TargetTab, "Target Actions")
    
    -- View Target
    local ViewTargetCheckbox = UI.CreateCheckbox(TargetActionsSection, "View Target", function(state)
        ViewingTarget = state
        
        if state and SelectedTarget then
            local ViewConnection
            ViewConnection = RunService.RenderStepped:Connect(function()
                if not ViewingTarget or not SelectedTarget or not SelectedTarget.Character then
                    ViewConnection:Disconnect()
                    Camera.CameraSubject = Player.Character
                    return
                end
                
                Camera.CameraSubject = SelectedTarget.Character
            end)
        else
            Camera.CameraSubject = Player.Character
        end
    end)
    
    -- Sit on Head
    local SitOnHeadCheckbox = UI.CreateCheckbox(TargetActionsSection, "Sit on Head", function(state)
        SittingOnHead = state
        
        if state and SelectedTarget and SelectedTarget.Character then
            local Character = Player.Character
            local TargetHead = SelectedTarget.Character:FindFirstChild("Head")
            
            if Character and TargetHead then
                local Humanoid = Character:FindFirstChildOfClass("Humanoid")
                if Humanoid then
                    -- Create the sit connection
                    if _G.SitConnection then
                        _G.SitConnection:Disconnect()
                    end
                    
                    _G.SitConnection = RunService.Heartbeat:Connect(function()
                        if not SittingOnHead or not SelectedTarget or not SelectedTarget.Character then
                            if _G.SitConnection then
                                _G.SitConnection:Disconnect()
                            end
                            SittingOnHead = false
                            SitOnHeadCheckbox:Set(false)
                            return
                        end
                        
                        local TargetHead = SelectedTarget.Character:FindFirstChild("Head")
                        if TargetHead and Character and Character:FindFirstChild("HumanoidRootPart") then
                            Humanoid.Sit = true
                            Character.HumanoidRootPart.CFrame = TargetHead.CFrame * CFrame.new(0, 2, 0)
                        end
                    end)
                    
                    -- Add character removal detection
                    if _G.SitCharacterRemovedConnection then
                        _G.SitCharacterRemovedConnection:Disconnect()
                    end
                    
                    _G.SitCharacterRemovedConnection = Player.CharacterRemoving:Connect(function()
                        SittingOnHead = false
                        SitOnHeadCheckbox:Set(false)
                        if _G.SitConnection then
                            _G.SitConnection:Disconnect()
                        end
                    end)
                end
            end
        else
            if _G.SitConnection then
                _G.SitConnection:Disconnect()
            end
            if Player.Character then
                local Character = Player.Character
                local Humanoid = Character:FindFirstChildOfClass("Humanoid")
                local HRP = Character:FindFirstChild("HumanoidRootPart")
                
                if Humanoid and HRP then
                    -- Safely reposition the player before unsitting
                    local currentPos = HRP.Position
                    
                    -- First, move the player up to avoid collision issues
                    HRP.CFrame = CFrame.new(currentPos.X, currentPos.Y + 10, currentPos.Z)
                    HRP.Velocity = Vector3.new(0, 0, 0)
                    HRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    
                    -- Re-enable collisions
                    for _, part in pairs(Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = true
                        end
                    end
                    
                    -- Wait a short moment for physics to stabilize
                    task.wait(0.1)
                    
                    -- Now disable sitting
                    Humanoid.Sit = false
                    
                    -- Do a raycast to find safe ground position
                    local raycastResult = workspace:Raycast(HRP.Position, Vector3.new(0, -100, 0))
                    if raycastResult then
                        -- Smoothly move to ground position
                        local targetY = raycastResult.Position.Y + 5
                        local startY = HRP.Position.Y
                        local duration = 0.3
                        local startTime = tick()
                        
                        while tick() - startTime < duration do
                            local alpha = (tick() - startTime) / duration
                            local newY = startY + (targetY - startY) * alpha
                            HRP.CFrame = CFrame.new(HRP.Position.X, newY, HRP.Position.Z)
                            task.wait()
                        end
                        
                        HRP.CFrame = CFrame.new(HRP.Position.X, targetY, HRP.Position.Z)
                    end
                end
            end
        end
    end)
    
    -- Backpack mode
    local BackpackMode = false
    local BackpackCheckbox = UI.CreateCheckbox(TargetActionsSection, "Backpack", function(state)
        BackpackMode = state
        
        if state and SelectedTarget and SelectedTarget.Character then
            local Character = Player.Character
            local TargetHRP = SelectedTarget.Character:FindFirstChild("HumanoidRootPart")
            
            if Character and TargetHRP then
                local Humanoid = Character:FindFirstChildOfClass("Humanoid")
                if Humanoid then
                    -- Create the backpack connection
                    if _G.BackpackConnection then
                        _G.BackpackConnection:Disconnect()
                    end
                    
                    _G.BackpackConnection = RunService.Heartbeat:Connect(function()
                        if not BackpackMode or not SelectedTarget or not SelectedTarget.Character then
                            if _G.BackpackConnection then
                                _G.BackpackConnection:Disconnect()
                            end
                            BackpackMode = false
                            BackpackCheckbox:Set(false)
                            return
                        end
                        
                        local TargetHRP = SelectedTarget.Character:FindFirstChild("HumanoidRootPart")
                        if TargetHRP and Character and Character:FindFirstChild("HumanoidRootPart") then
                            Humanoid.Sit = true
                            -- Position behind the target, slightly higher, and rotated to face backward
                            Character.HumanoidRootPart.CFrame = TargetHRP.CFrame * CFrame.new(0, 0.5, 1) * CFrame.Angles(0, math.rad(180), 0)
                        end
                    end)
                    
                    -- Add character removal detection
                    if _G.BackpackCharacterRemovedConnection then
                        _G.BackpackCharacterRemovedConnection:Disconnect()
                    end
                    
                    _G.BackpackCharacterRemovedConnection = Player.CharacterRemoving:Connect(function()
                        BackpackMode = false
                        BackpackCheckbox:Set(false)
                        if _G.BackpackConnection then
                            _G.BackpackConnection:Disconnect()
                        end
                    end)
                end
            end
        else
            if _G.BackpackConnection then
                _G.BackpackConnection:Disconnect()
            end
            if Player.Character then
                local Character = Player.Character
                local Humanoid = Character:FindFirstChildOfClass("Humanoid")
                local HRP = Character:FindFirstChild("HumanoidRootPart")
                
                if Humanoid and HRP then
                    -- Safely reposition the player before unsitting
                    local currentPos = HRP.Position
                    
                    -- First, move the player up to avoid collision issues
                    HRP.CFrame = CFrame.new(currentPos.X, currentPos.Y + 10, currentPos.Z)
                    HRP.Velocity = Vector3.new(0, 0, 0)
                    HRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    
                    -- Re-enable collisions
                    for _, part in pairs(Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = true
                        end
                    end
                    
                    -- Wait a short moment for physics to stabilize
                    task.wait(0.1)
                    
                    -- Now disable sitting
                    Humanoid.Sit = false
                    
                    -- Do a raycast to find safe ground position
                    local raycastResult = workspace:Raycast(HRP.Position, Vector3.new(0, -100, 0))
                    if raycastResult then
                        -- Smoothly move to ground position
                        local targetY = raycastResult.Position.Y + 5
                        local startY = HRP.Position.Y
                        local duration = 0.3
                        local startTime = tick()
                        
                        while tick() - startTime < duration do
                            local alpha = (tick() - startTime) / duration
                            local newY = startY + (targetY - startY) * alpha
                            HRP.CFrame = CFrame.new(HRP.Position.X, newY, HRP.Position.Z)
                            task.wait()
                        end
                        
                        HRP.CFrame = CFrame.new(HRP.Position.X, targetY, HRP.Position.Z)
                    end
                end
            end
        end
    end)
    
    -- Follow Target
    local FollowTargetCheckbox = UI.CreateCheckbox(TargetActionsSection, "Follow Target", function(state)
        FollowingTarget = state
        
        if state and SelectedTarget then
            local FollowConnection
            FollowConnection = RunService.Heartbeat:Connect(function()
                if not FollowingTarget or not SelectedTarget or not SelectedTarget.Character or not Player.Character then
                    FollowConnection:Disconnect()
                    return
                end
                
                local TargetHRP = SelectedTarget.Character:FindFirstChild("HumanoidRootPart")
                local CharacterHRP = Player.Character:FindFirstChild("HumanoidRootPart")
                
                if TargetHRP and CharacterHRP then
                    local Distance = (TargetHRP.Position - CharacterHRP.Position).Magnitude
                    
                    if Distance > FollowDistance then
                        local Direction = (TargetHRP.Position - CharacterHRP.Position).Unit
                        local TargetPosition = TargetHRP.Position - (Direction * FollowDistance)
                        
                        CharacterHRP.CFrame = CFrame.new(CharacterHRP.Position, TargetHRP.Position)
                        Player.Character:FindFirstChildOfClass("Humanoid"):MoveTo(TargetPosition)
                    end
                end
            end)
        end
    end)
    
    -- Follow Distance Slider
    local FollowDistanceSlider = UI.CreateSlider(TargetActionsSection, "Follow Distance", 2, 20, 5, function(value)
        FollowDistance = value
    end)
    
    -- Teleport to Target
    local TeleportButton = UI.CreateButton(TargetActionsSection, "Teleport to Target", function()
        if SelectedTarget and SelectedTarget.Character then
            local TargetHRP = SelectedTarget.Character:FindFirstChild("HumanoidRootPart")
            local CharacterHRP = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
            
            if TargetHRP and CharacterHRP then
                CharacterHRP.CFrame = TargetHRP.CFrame * CFrame.new(0, 0, 3)
            end
        end
    end)
    
    -- Update current target display
    RunService.Heartbeat:Connect(function()
        if SelectedTarget and SelectedTarget.Parent then
            CurrentTargetLabel.Text = string.format("Current Target: %s (@%s)", SelectedTarget.DisplayName, SelectedTarget.Name)
        else
            CurrentTargetLabel.Text = "No Target Selected"
            SelectedTarget = nil
            
            if ViewingTarget then
                ViewTargetCheckbox:Set(false)
            end
            
            if FollowingTarget then
                FollowTargetCheckbox:Set(false)
            end
            
            if SittingOnHead then
                SittingOnHead = false
                SitOnHeadCheckbox:Set(false)
                if Player.Character then
                    local Humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
                    if Humanoid then
                        Humanoid.Sit = false
                    end
                end
            end
        end
    end)
    
    local MiscTab = Tabs["Misc"].Tab
    local CreditsSection = UI.CreateSection(MiscTab, "Credits")
    
    -- Add Movement section for Click to TP
    local MovementSection = UI.CreateSection(MiscTab, "Movement")
    
    -- Variables for Click to TP
    local ClickToTPEnabled = false
    local ClickToTPKey = Enum.KeyCode.X -- Default key
    
    -- Click to TP Checkbox
    local ClickToTPCheckbox = UI.CreateCheckbox(MovementSection, "Click to TP", function(state)
        ClickToTPEnabled = state
    end)
    
    -- Click to TP Keybind
    local ClickToTPKeybind = UI.CreateKeybind(MovementSection, "Click to TP Key", "X", function(key)
        ClickToTPKey = key
    end)
    
    -- Click to TP Logic
    Mouse.Button1Down:Connect(function()
        if ClickToTPEnabled and UserInputService:IsKeyDown(ClickToTPKey) then
            local Character = Player.Character
            if Character and Character:FindFirstChild("HumanoidRootPart") then
                Character.HumanoidRootPart.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
            end
        end
    end)
    
    -- Add Menu Settings section
    local MenuSection = UI.CreateSection(MiscTab, "Menu Settings")
    
    -- Add Menu Toggle Keybind
    local MenuToggleKeybind = UI.CreateKeybind(MenuSection, "Toggle Menu Key", "RightControl", function(key)
        MenuToggleKey = key
    end)
    
    UI.CreateButton(CreditsSection, "DinoHub v1.0", function() end)
    
    -- Add menu toggle functionality with animation
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == MenuToggleKey then
            MenuOpen = not MenuOpen
            
            if MenuOpen then
                DinoHub.MainFrame.Visible = true
                DinoHub.MainFrame.Size = UDim2.new(0, 0, 0, 0)
                DinoHub.MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
                
                TweenService:Create(
                    DinoHub.MainFrame,
                    TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                    {
                        Size = UDim2.new(0, 700, 0, 450),
                        Position = UDim2.new(0.5, -350, 0.5, -225)
                    }
                ):Play()
                
                TweenService:Create(
                    Blur,
                    TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                    {Size = 10}
                ):Play()
            else
                TweenService:Create(
                    DinoHub.MainFrame,
                    TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                    {
                        Size = UDim2.new(0, 0, 0, 0),
                        Position = UDim2.new(0.5, 0, 0.5, 0)
                    }
                ):Play()
                
                TweenService:Create(
                    Blur,
                    TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                    {Size = 0}
                ):Play()
                
                wait(0.3)
                DinoHub.MainFrame.Visible = false
            end
        end
    end)
    
    -- Parent the GUI to CoreGui or PlayerGui
    if syn and syn.protect_gui then
        syn.protect_gui(DinoHub)
        DinoHub.Parent = game:GetService("CoreGui")
    elseif gethui then
        DinoHub.Parent = gethui()
    else
        DinoHub.Parent = Player:WaitForChild("PlayerGui")
    end
    
    -- Show welcome notification
    NotificationSystem.notify(NotificationContainer, "DinoHub Loaded", "Press ; to open command bar", "Success")
    
    -- Return interface elements
    return {
        GUI = DinoHub,
        Tabs = Tabs,
        Notify = function(title, message, type)
            NotificationSystem.notify(NotificationContainer, title, message, type)
        end
    }
end

-- Run the script
return Initialize()