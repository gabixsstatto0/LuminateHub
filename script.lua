-- language: Luau, file: LuminateBase.lua, target: Roblox (Delta Mobile)
-- Base da GUI - Luminate (Abas ajustadas + Others completa + Floating Buttons)

-- ==========================================
-- 1. SERVIÇOS DO ROBLOX
-- ==========================================
local Players           = game:GetService("Players")
local LocalPlayer       = Players.LocalPlayer
local PlayerGui         = LocalPlayer:WaitForChild("PlayerGui")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local RunService        = game:GetService("RunService")
local Workspace         = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService   = game:GetService("TextChatService")
local Camera            = Workspace.CurrentCamera

-- ==========================================
-- 2. ESTADO GLOBAL DOS BOTÕES FLUTUANTES
-- ==========================================
local floatingState = {
    locked  = false,
    hidden  = false,
}

-- ==========================================
-- 3. LIMPEZA
-- ==========================================
if PlayerGui:FindFirstChild("LuminateGUI")     then PlayerGui.LuminateGUI:Destroy()     end
if PlayerGui:FindFirstChild("LuminateFOV")     then PlayerGui.LuminateFOV:Destroy()     end
if PlayerGui:FindFirstChild("BoxESPGui")       then PlayerGui.BoxESPGui:Destroy()       end
if PlayerGui:FindFirstChild("TracersGui")      then PlayerGui.TracersGui:Destroy()      end
if PlayerGui:FindFirstChild("SkeletonESP")     then PlayerGui.SkeletonESP:Destroy()     end
if PlayerGui:FindFirstChild("LuminateNotifs")  then PlayerGui.LuminateNotifs:Destroy()  end
if PlayerGui:FindFirstChild("LuminateFloating") then PlayerGui.LuminateFloating:Destroy() end
if PlayerGui:FindFirstChild("LuminateStaffGUI") then PlayerGui.LuminateStaffGUI:Destroy() end

local function cleanupChamsFolder()
    local function tryDestroy(parent)
        if parent then
            local f = parent:FindFirstChild("RuntimeData")
            if f then f:Destroy() end
        end
    end
    if gethui then
        local ok, hui = pcall(gethui)
        if ok and hui then tryDestroy(hui) end
    end
    local ok2, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok2 and cg then tryDestroy(cg) end
end
cleanupChamsFolder()

-- ==========================================
-- 4. MÓDULO OTHERS (referência global)
-- ==========================================
local othersModule = {}

-- ==========================================
-- 5. SISTEMA DE NOTIFICAÇÃO
-- ==========================================
local NotifGui = Instance.new("ScreenGui")
NotifGui.Name = "LuminateNotifs"
NotifGui.ResetOnSpawn = false
NotifGui.IgnoreGuiInset = true
NotifGui.DisplayOrder = 100
NotifGui.Parent = PlayerGui

local NotifContainer = Instance.new("Frame")
NotifContainer.Name = "NotifContainer"
NotifContainer.AnchorPoint = Vector2.new(1, 1)
NotifContainer.Position = UDim2.new(1, -20, 1, -20)
NotifContainer.Size = UDim2.new(0, 220, 1, -40)
NotifContainer.BackgroundTransparency = 1
NotifContainer.Parent = NotifGui

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.Padding = UDim.new(0, 8)
NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
NotifLayout.Parent = NotifContainer

local NotifSound = Instance.new("Sound")
NotifSound.Name = "NotifSound"
NotifSound.SoundId = "rbxassetid://81384230198703"
NotifSound.Volume = 0.5
NotifSound.Parent = NotifGui

local soundVersion = 0
local function playNotifSound()
    soundVersion = soundVersion + 1
    local myVersion = soundVersion
    pcall(function()
        NotifSound:Stop()
        NotifSound.TimePosition = 0
        NotifSound:Play()
    end)
    task.delay(0.75, function()
        if soundVersion == myVersion then
            pcall(function() NotifSound:Stop() end)
        end
    end)
end

local notifOrder = 0
local function notify(text, duration)
    duration = duration or 5
    notifOrder = notifOrder + 1
    playNotifSound()

    local holder = Instance.new("Frame")
    holder.Name = "Holder"
    holder.Size = UDim2.new(1, 0, 0, 50)
    holder.BackgroundTransparency = 1
    holder.ClipsDescendants = true
    holder.LayoutOrder = notifOrder
    holder.Parent = NotifContainer

    local notif = Instance.new("Frame")
    notif.Name = "Notification"
    notif.Size = UDim2.new(1, 0, 1, 0)
    notif.Position = UDim2.new(1, 0, 0, 0)
    notif.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    notif.BorderSizePixel = 0
    notif.Parent = holder

    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 8)
    notifCorner.Parent = notif

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 1, -14)
    label.Position = UDim2.new(0, 10, 0, 4)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.TextSize = 12
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Top
    label.TextWrapped = true
    label.Parent = notif

    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(1, -20, 0, 3)
    barBg.Position = UDim2.new(0, 10, 1, -8)
    barBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    barBg.BorderSizePixel = 0
    barBg.Parent = notif

    local barBgCorner = Instance.new("UICorner")
    barBgCorner.CornerRadius = UDim.new(1, 0)
    barBgCorner.Parent = barBg

    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new(1, 0, 1, 0)
    barFill.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    barFill.BorderSizePixel = 0
    barFill.Parent = barBg

    local barFillCorner = Instance.new("UICorner")
    barFillCorner.CornerRadius = UDim.new(1, 0)
    barFillCorner.Parent = barFill

    TweenService:Create(notif, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0)
    }):Play()

    TweenService:Create(barFill, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 1, 0)
    }):Play()

    task.delay(duration, function()
        if not notif.Parent then return end
        TweenService:Create(notif, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 0, 0, 0)
        }):Play()
        task.delay(0.4, function()
            if holder and holder.Parent then holder:Destroy() end
        end)
    end)
end

-- ==========================================
-- 6. BASE PRINCIPAL (MainFrame)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LuminateGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 460, 0, 290)
MainFrame.Position = UDim2.new(0.5, -230, 0.5, -145)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- ==========================================
-- 7. FOV CIRCLE
-- ==========================================
local FovGui = Instance.new("ScreenGui")
FovGui.Name = "LuminateFOV"
FovGui.ResetOnSpawn = false
FovGui.IgnoreGuiInset = true
FovGui.DisplayOrder = 10
FovGui.Parent = PlayerGui

local FovCircle = Instance.new("Frame")
FovCircle.Name = "FovCircle"
FovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FovCircle.Size = UDim2.new(0, 200, 0, 200)
FovCircle.BackgroundTransparency = 1
FovCircle.Visible = false
FovCircle.Parent = FovGui

local FovCorner = Instance.new("UICorner")
FovCorner.CornerRadius = UDim.new(1, 0)
FovCorner.Parent = FovCircle

local FovStroke = Instance.new("UIStroke")
FovStroke.Thickness = 1
FovStroke.Color = Color3.fromRGB(255, 255, 255)
FovStroke.Transparency = 0.2
FovStroke.Parent = FovCircle

-- ==========================================
-- 8. SIDEBAR
-- ==========================================
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 90, 1, 0)
Sidebar.Position = UDim2.new(0, 0, 0, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
Sidebar.BorderSizePixel = 0
Sidebar.ClipsDescendants = true
Sidebar.Parent = MainFrame

local SnakeCurve = Instance.new("Frame")
SnakeCurve.Name = "SnakeCurve"
SnakeCurve.Size = UDim2.new(0, 220, 0, 220)
SnakeCurve.Position = UDim2.new(0, -90, 0, 140)
SnakeCurve.Rotation = -15
SnakeCurve.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
SnakeCurve.BorderSizePixel = 0
SnakeCurve.ZIndex = 1
SnakeCurve.Parent = Sidebar

local SnakeCorner = Instance.new("UICorner")
SnakeCorner.CornerRadius = UDim.new(1, 0)
SnakeCorner.Parent = SnakeCurve

local Logo = Instance.new("ImageLabel")
Logo.Name = "LuminateLogo"
Logo.Size = UDim2.new(0, 70, 0, 70)
Logo.Position = UDim2.new(0.5, -35, 0, 8)
Logo.BackgroundTransparency = 1
Logo.Image = "rbxassetid://91361777071114"
Logo.ScaleType = Enum.ScaleType.Fit
Logo.ImageTransparency = 0.4
Logo.ZIndex = 2
Logo.Parent = Sidebar

-- ==========================================
-- 9. createTab
-- ==========================================
local checkTweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local BOX_SIZE = 12
local TEXT_X = 22

local function createTab(name, text, imageId, posY, iconSize, offsetX, offsetY, iconTransparency, tabOffsetX, tabOffsetY)
    iconSize         = iconSize or 16
    offsetX          = offsetX or 0
    offsetY          = offsetY or 0
    iconTransparency = iconTransparency or 0
    tabOffsetX       = tabOffsetX or 0
    tabOffsetY       = tabOffsetY or 0

    local iconPosX = offsetX
    local iconPosY = math.floor((24 - iconSize) / 2) + offsetY
    local boxPosX = iconPosX + math.floor((iconSize - BOX_SIZE) / 2)
    local boxPosY = iconPosY + math.floor((iconSize - BOX_SIZE) / 2)

    local Tab = Instance.new("TextButton")
    Tab.Name = name
    Tab.Size = UDim2.new(0, 75, 0, 24)
    Tab.Position = UDim2.new(0, 12 + tabOffsetX, 0, posY + tabOffsetY)
    Tab.BackgroundTransparency = 1
    Tab.Text = ""
    Tab.ZIndex = 2
    Tab.Parent = Sidebar

    local SelectionBox = Instance.new("Frame")
    SelectionBox.Name = "SelectionBox"
    SelectionBox.Size = UDim2.new(0, BOX_SIZE, 0, BOX_SIZE)
    SelectionBox.Position = UDim2.new(0, boxPosX, 0, boxPosY)
    SelectionBox.BackgroundTransparency = 1
    SelectionBox.ClipsDescendants = true
    SelectionBox.ZIndex = 1
    SelectionBox.Parent = Tab

    local BoxCorner = Instance.new("UICorner")
    BoxCorner.CornerRadius = UDim.new(0, 3)
    BoxCorner.Parent = SelectionBox

    local TabFill = Instance.new("Frame")
    TabFill.Name = "TabFill"
    TabFill.AnchorPoint = Vector2.new(0.5, 0.5)
    TabFill.Position = UDim2.new(0.5, 0, 0.5, 0)
    TabFill.Size = UDim2.new(0, 0, 0, 0)
    TabFill.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    TabFill.BackgroundTransparency = 0.5
    TabFill.ZIndex = 1
    TabFill.Parent = SelectionBox

    local TabFillCorner = Instance.new("UICorner")
    TabFillCorner.CornerRadius = UDim.new(0, 3)
    TabFillCorner.Parent = TabFill

    local Icon = Instance.new("ImageLabel")
    Icon.Name = "Icon"
    Icon.Size = UDim2.new(0, iconSize, 0, iconSize)
    Icon.Position = UDim2.new(0, iconPosX, 0, iconPosY)
    Icon.BackgroundTransparency = 1
    Icon.Image = imageId
    Icon.ImageTransparency = iconTransparency
    Icon.ScaleType = Enum.ScaleType.Fit
    Icon.ZIndex = 2
    Icon.Parent = Tab

    local TabText = Instance.new("TextLabel")
    TabText.Name = "TabText"
    TabText.Size = UDim2.new(1, -(TEXT_X + 3), 1, 0)
    TabText.Position = UDim2.new(0, TEXT_X - tabOffsetX, 0, 0)
    TabText.BackgroundTransparency = 1
    TabText.Text = text
    TabText.TextColor3 = Color3.fromRGB(160, 160, 160)
    TabText.TextSize = 11
    TabText.Font = Enum.Font.GothamMedium
    TabText.TextXAlignment = Enum.TextXAlignment.Left
    TabText.TextYAlignment = Enum.TextYAlignment.Center
    TabText.ZIndex = 2
    TabText.Parent = Tab

    return Tab, TabFill
end

local TabRage, TabRageFill           = createTab("TabRage", "rage", "rbxassetid://109884350811016", 95, 16, 0, 0, 0.35)
local TabFarms, TabFarmsFill         = createTab("TabFarms", "farms", "rbxassetid://72483107729531", 120)
local TabVehicles, TabVehiclesFill   = createTab("TabVehicles", "vehicles", "rbxassetid://103447319422273", 145, 20, -2, -2)
local TabTeleport, TabTeleportFill   = createTab("TabTeleport", "teleport", "rbxassetid://96654326365569", 170, 22, -1, -1, 0.35, -1, -1)
local TabOthers, TabOthersFill       = createTab("TabOthers", "others", "rbxassetid://119762543918627", 195, 22, -1, -1, 0.35, -1, -1)

-- ==========================================
-- 10. createCheckbox / createButton
-- ==========================================
local function createCheckbox(parent, text, layoutOrder, onChanged)
    local Check = Instance.new("TextButton")
    Check.Size = UDim2.new(1, 0, 0, 18)
    Check.BackgroundTransparency = 1
    Check.Text = ""
    Check.LayoutOrder = layoutOrder
    Check.Parent = parent

    local Box = Instance.new("Frame")
    Box.Size = UDim2.new(0, 14, 0, 14)
    Box.Position = UDim2.new(0, 0, 0, 2)
    Box.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Box.ClipsDescendants = true
    Box.Parent = Check

    local BoxCorner = Instance.new("UICorner")
    BoxCorner.CornerRadius = UDim.new(0, 3)
    BoxCorner.Parent = Box

    local CheckMark = Instance.new("Frame")
    CheckMark.AnchorPoint = Vector2.new(0.5, 0.5)
    CheckMark.Position = UDim2.new(0.5, 0, 0.5, 0)
    CheckMark.Size = UDim2.new(0, 0, 0, 0)
    CheckMark.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    CheckMark.BackgroundTransparency = 1
    CheckMark.ZIndex = 2
    CheckMark.Parent = Box

    local CheckMarkCorner = Instance.new("UICorner")
    CheckMarkCorner.CornerRadius = UDim.new(0, 3)
    CheckMarkCorner.Parent = CheckMark

    -- Imagem animada que cresce ao ativar o checkbox
    local CheckImage = Instance.new("ImageLabel")
    CheckImage.Name = "CheckImage"
    CheckImage.AnchorPoint = Vector2.new(0.5, 0.5)
    CheckImage.Position = UDim2.new(0.5, 0, 0.5, 0)
    CheckImage.Size = UDim2.new(0, 0, 0, 0)
    CheckImage.BackgroundTransparency = 1
    CheckImage.Image = "rbxassetid://129243514173890"
    CheckImage.ScaleType = Enum.ScaleType.Fit
    CheckImage.ImageTransparency = 1
    CheckImage.ZIndex = 3
    CheckImage.Parent = Box

    local Text = Instance.new("TextLabel")
    Text.Size = UDim2.new(1, -18, 1, 0)
    Text.Position = UDim2.new(0, 18, 0, 0)
    Text.BackgroundTransparency = 1
    Text.Text = text
    Text.TextColor3 = Color3.fromRGB(200, 200, 200)
    Text.TextSize = 11
    Text.Font = Enum.Font.Gotham
    Text.TextXAlignment = Enum.TextXAlignment.Left
    Text.Parent = Check

    local imgTweenOn  = TweenInfo.new(0.45, Enum.EasingStyle.Back,  Enum.EasingDirection.Out)
    local imgTweenOff = TweenInfo.new(0.25, Enum.EasingStyle.Quad,  Enum.EasingDirection.In)

    local toggle = false
    Check.MouseButton1Click:Connect(function()
        toggle = not toggle
        if toggle then
            TweenService:Create(CheckMark,  checkTweenInfo, {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 0}):Play()
            TweenService:Create(CheckImage, imgTweenOn,     {Size = UDim2.new(0, 10, 0, 10), ImageTransparency = 0}):Play()
        else
            TweenService:Create(CheckMark,  checkTweenInfo, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}):Play()
            TweenService:Create(CheckImage, imgTweenOff,    {Size = UDim2.new(0, 0, 0, 0),  ImageTransparency = 1}):Play()
        end
        notify(text .. (toggle and " ativado" or " desativado"))
        if onChanged then onChanged(toggle) end
    end)

    return function() return toggle end
end

local function createButton(parent, text, layoutOrder)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 22)
    Btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Btn.BorderSizePixel = 0
    Btn.Text = ""
    Btn.AutoButtonColor = false
    Btn.LayoutOrder = layoutOrder
    Btn.ClipsDescendants = true
    Btn.Parent = parent

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = Btn

    local Ripple = Instance.new("Frame")
    Ripple.Name = "Ripple"
    Ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    Ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
    Ripple.Size = UDim2.new(0, 0, 0, 0)
    Ripple.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    Ripple.BackgroundTransparency = 1
    Ripple.BorderSizePixel = 0
    Ripple.ZIndex = 1
    Ripple.Parent = Btn

    local RippleCorner = Instance.new("UICorner")
    RippleCorner.CornerRadius = UDim.new(0, 4)
    RippleCorner.Parent = Ripple

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.TextSize = 11
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Center
    Label.ZIndex = 2
    Label.Parent = Btn

    local currentRippleTween
    Btn.MouseButton1Click:Connect(function()
        if currentRippleTween then currentRippleTween:Cancel() end
        Ripple.Size = UDim2.new(0, 0, 0, 0)
        Ripple.BackgroundTransparency = 0.4
        local fillTween = TweenService:Create(Ripple, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)})
        currentRippleTween = fillTween
        fillTween:Play()
        fillTween.Completed:Connect(function(state)
            if state == Enum.PlaybackState.Completed and currentRippleTween == fillTween then
                TweenService:Create(Ripple, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
            end
        end)
    end)

    return Btn
end

-- ==========================================
-- 11. HELPERS
-- ==========================================
local COORD_PESCA           = Vector3.new(-2596, 122, -3040)
local COORD_BANCO           = Vector3.new(-637, 108, -2673)
local COORD_CASSINO         = Vector3.new(-1359, 141, -4026)
local COORD_GARAGEM_PRACA   = Vector3.new(-1002, 129, -4642)
local COORD_DESMANCHE       = Vector3.new(-1973, 122, -4065)

local function getChar()
    local c = LocalPlayer.Character
    if not c then return nil, nil, nil end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    local hum = c:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return nil, nil, nil end
    return c, hrp, hum
end

local function clickBtn(guiObj)
    if guiObj then
        pcall(function()
            if typeof(firesignal) == "function" then
                firesignal(guiObj.MouseButton1Click)
            elseif guiObj.Activate then
                guiObj:Activate()
            end
        end)
        return true
    end
    return false
end

local function enviarComandoChat(msg)
    return pcall(function()
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            local channel = TextChatService:FindFirstChild("TextChannels") and TextChatService.TextChannels:FindFirstChild("RBGGeneral")
            if not channel then channel = TextChatService:FindFirstChild("TextChannels") and TextChatService.TextChannels:FindFirstChild("RBXGeneral") end
            if channel then channel:SendAsync(msg) end
        else
            local chatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
            if chatEvents and chatEvents:FindFirstChild("SayMessageRequest") then
                chatEvents.SayMessageRequest:FireServer(msg, "All")
            end
        end
    end)
end

local function firePrompt(prompt)
    if not prompt then return end
    local fn = (getfenv and getfenv()["fireproximityprompt"]) or rawget(_G, "fireproximityprompt")
    if fn then local ok = pcall(fn, prompt); if ok then return end end
    pcall(function() prompt:InputHoldBegin(); task.wait(math.max(prompt.HoldDuration or 0.1, 0.05)); prompt:InputHoldEnd() end)
end

local function teleportTo(pos, name)
    local _, root, hum = getChar()
    if not root or not hum then return end
    pcall(function() Workspace:RequestStreamAroundAsync(pos, 2) end)
    local targetPos = pos + Vector3.new(0, 3, 0)
    hum.Sit = true
    task.wait(0.1)
    root.CFrame = CFrame.new(targetPos)
    task.wait(0.2)
    hum.Sit = false
    notify("Teleportado: " .. name)
end

-- ==========================================
-- 12. FARM PEÇAS
-- ==========================================
local runningPecas = false
local pecasColetadas = 0

local function pegarRota()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    local rotasUI = playerGui and playerGui:FindFirstChild("RotasUI")
    if rotasUI then
        local bgFrame = rotasUI:FindFirstChild("BGFrame")
        local items = bgFrame and bgFrame:FindFirstChild("Items")
        local farmItem = items and items:FindFirstChild("Farm de Partes de Arma")
        if farmItem then
            clickBtn(farmItem)
            task.wait(1)
            return true
        end
    end
    return false
end

local function findActivePromptPecas()
    local bestPrompt, bestPos, bestDist = nil, nil, math.huge
    local _, root = getChar()
    if not root then return nil end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled and obj.Parent then
            local action = string.lower(obj.ActionText or "")
            local objText = string.lower(obj.ObjectText or "")
            local isBlocked = action:find("dinheiro") or objText:find("dinheiro") or action:find("interagir")
            local hasPeca = action:find("peça") or action:find("peca") or action:find("parte") or objText:find("peça") or objText:find("peca") or objText:find("parte")
            if hasPeca and not isBlocked then
                local parent = obj.Parent
                local pos
                if parent:IsA("BasePart") then pos = parent.Position
                elseif parent:IsA("Model") then
                    local ok, pivot = pcall(function() return parent:GetPivot().Position end)
                    if ok then pos = pivot end
                end
                if pos then
                    local dist = (pos - root.Position).Magnitude
                    if dist < bestDist then bestDist = dist; bestPrompt = obj; bestPos = pos end
                end
            end
        end
    end
    return bestPrompt, bestPos
end

local function runPecasLoop()
    runningPecas = true
    pecasColetadas = 0
    while runningPecas do
        local prompt, targetPos = findActivePromptPecas()
        if prompt and targetPos then
            local target = targetPos + Vector3.new(0, 2, 0)
            local _, root, hum = getChar()
            if root and hum then
                hum.Sit = true
                task.wait(0.05)
                root.CFrame = CFrame.new(target)
                task.wait(0.15)
                hum.Sit = false
                pcall(function()
                    prompt.HoldDuration = 0
                    if typeof(fireproximityprompt) == "function" then fireproximityprompt(prompt) end
                    prompt:InputHoldBegin(); prompt:InputHoldEnd()
                end)
                task.wait(1.5)
                if prompt and prompt.Parent and prompt.Enabled then
                    pcall(function() if typeof(fireproximityprompt) == "function" then fireproximityprompt(prompt) end end)
                end
                pecasColetadas += 1
            end
        else
            task.wait(0.5)
        end
        task.wait(0.1)
    end
end

local function stopPecasFarm()
    runningPecas = false
    local _, root, hum = getChar()
    if root and hum then
        hum.Sit = true
        task.wait(0.1)
        root.CFrame = CFrame.new(COORD_GARAGEM_PRACA + Vector3.new(0, 3, 0))
        task.wait(0.3)
        hum.Sit = false
    end
    enviarComandoChat("/pararfarm")
end

-- ==========================================
-- 13. FARM PESCA
-- ==========================================
local runningPesca = false
local savedPescaCFrame = nil

local function verificarVaraNoInventario()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    local invUI = playerGui and playerGui:FindFirstChild("InventoryUI")
    if not invUI then return false, nil end
    local invPessoal = invUI:FindFirstChild("InvFrame") and invUI.InvFrame:FindFirstChild("InvPessoal")
    if not invPessoal then return false, nil end
    local conteudo = invPessoal:FindFirstChild("ConteudoInv")
    if not conteudo then return false, nil end
    for _, slot in ipairs(conteudo:GetChildren()) do
        if slot.Name:find("Slot") then
            for _, desc in ipairs(slot:GetDescendants()) do
                if (desc:IsA("TextLabel") or desc:IsA("TextButton")) and string.lower(desc.Text or ""):find("vara") then
                    return true, slot
                end
            end
        end
    end
    if LocalPlayer:FindFirstChild("Backpack") and LocalPlayer.Backpack:FindFirstChild("Vara") then return true, nil end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Vara") then return true, nil end
    return false, nil
end

local function equiparVara(slotVara)
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    local invUI = playerGui and playerGui:FindFirstChild("InventoryUI")
    if invUI then
        local invPessoal = invUI:FindFirstChild("InvFrame") and invUI.InvFrame:FindFirstChild("InvPessoal")
        if slotVara then
            local btnIn = slotVara:FindFirstChild("In")
            if btnIn then clickBtn(btnIn); task.wait(0.3) end
        end
        if invPessoal then
            local xBtns = invPessoal:FindFirstChild("XBtns")
            if xBtns then
                local usarBtn = xBtns:FindFirstChild("UsarBtn")
                if usarBtn then clickBtn(usarBtn); task.wait(0.8) end
            end
        end
        local slotsContainer = invUI:FindFirstChild("SlotsContainer")
        local hotbar = slotsContainer and slotsContainer:FindFirstChild("Hotbar")
        local slots = hotbar and hotbar:FindFirstChild("Slots")
        if slots then
            for _, hSlot in ipairs(slots:GetChildren()) do
                if hSlot.Name:find("Slot") then
                    local img = hSlot:FindFirstChild("Img")
                    if img then clickBtn(img); task.wait(0.1) end
                end
            end
        end
    end
end

local function tpPesca()
    local _, root, hum = getChar()
    if not root or not hum then return end
    if not savedPescaCFrame then savedPescaCFrame = root.CFrame end
    hum.Sit = true
    task.wait(0.1)
    root.CFrame = CFrame.new(COORD_PESCA + Vector3.new(0, 3, 0))
    task.wait(0.15)
    hum.Sit = false
    task.wait(0.5)
end

local function runPescaLoop()
    while runningPesca do
        local _, root = getChar()
        if root then
            local myPos = root.Position
            local bestPrompt = nil
            local shortest = 20
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and obj.Enabled then
                    local action = string.lower(obj.ActionText or "")
                    local objText = string.lower(obj.ObjectText or "")
                    if action:find("pescar") or action:find("pesca") or action:find("fish") or objText:find("pesca") then
                        local parent = obj.Parent
                        local pos = parent:IsA("BasePart") and parent.Position or (parent:IsA("Model") and parent:GetPivot().Position)
                        if pos then
                            local dist = (pos - myPos).Magnitude
                            if dist < shortest then shortest = dist; bestPrompt = obj end
                        end
                    end
                end
            end
            if bestPrompt then
                task.wait(0.5)
                pcall(function()
                    bestPrompt.HoldDuration = 0
                    if typeof(fireproximityprompt) == "function" then fireproximityprompt(bestPrompt) end
                    bestPrompt:InputHoldBegin(); task.wait(0.1); bestPrompt:InputHoldEnd()
                end)
            end
        end
        task.wait(1)
    end
end

local function startPescaFarm()
    runningPesca = true
    task.spawn(function()
        local char = LocalPlayer.Character
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if char and char:FindFirstChild("Vara") then
            tpPesca(); task.wait(1); runPescaLoop(); return
        end
        if backpack and backpack:FindFirstChild("Vara") then
            backpack.Vara.Parent = char; task.wait(0.5); tpPesca(); task.wait(1); runPescaLoop(); return
        end
        local temVara, slotVara = verificarVaraNoInventario()
        if not temVara then
            notify("Farm pesca cancelado: você precisa comprar uma vara.", 6)
            runningPesca = false
            return
        end
        equiparVara(slotVara); task.wait(1)
        char = LocalPlayer.Character; backpack = LocalPlayer:FindFirstChild("Backpack")
        if char and char:FindFirstChild("Vara") then tpPesca(); task.wait(1); runPescaLoop()
        elseif backpack and backpack:FindFirstChild("Vara") then backpack.Vara.Parent = char; task.wait(0.5); tpPesca(); task.wait(1); runPescaLoop()
        else
            notify("Farm pesca cancelado: falha ao equipar a vara.", 6)
            runningPesca = false
        end
    end)
end

local function stopPescaFarm()
    runningPesca = false
    local _, root, hum = getChar()
    if root and hum and savedPescaCFrame then
        hum.Sit = true; task.wait(0.1); root.CFrame = savedPescaCFrame; task.wait(0.2); hum.Sit = false
    end
    savedPescaCFrame = nil
end

-- ==========================================
-- 14. ROUBO
-- ==========================================
local runningRobbery = false
local currentRobberyType = ""
local robberyProcessedBags = {}

local function findRobberyPrompts(targetCoord)
    local list = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local act = string.lower(obj.ActionText or "")
            local objT = string.lower(obj.ObjectText or "")
            if act:find("coletar") and (objT:find("dinheiro") or objT:find("sujo")) then
                local parent = obj.Parent
                local pos = parent:IsA("BasePart") and parent.Position or (parent:IsA("Model") and parent:GetPivot().Position)
                if pos and (pos - targetCoord).Magnitude < 500 then
                    table.insert(list, {prompt = obj, pos = pos, obj = parent})
                end
            end
        end
    end
    return list
end

local function runRobbery(type)
    runningRobbery = true
    currentRobberyType = type
    robberyProcessedBags = {}
    local targetCoord = (type == "banco") and COORD_BANCO or COORD_CASSINO

    while runningRobbery do
        local allBags = findRobberyPrompts(targetCoord)
        local bags = {}
        for _, b in ipairs(allBags) do
            if not robberyProcessedBags[b.obj] then table.insert(bags, b) end
        end

        if #bags == 0 then
            if #allBags > 0 then
                robberyProcessedBags = {}
                task.wait(1)
            else
                task.wait(2)
            end
        else
            local _, root = getChar()
            if root then
                table.sort(bags, function(a, b) return (a.pos - root.Position).Magnitude < (b.pos - root.Position).Magnitude end)
            end

            for _, bag in ipairs(bags) do
                if not runningRobbery then break end
                if robberyProcessedBags[bag.obj] then continue end
                if not bag.obj.Parent then continue end

                local _, root2, hum2 = getChar()
                if root2 and hum2 then
                    hum2.Sit = true
                    task.wait(0.1)
                    root2.CFrame = CFrame.new(bag.pos + Vector3.new(0, 1.5, 0))
                    task.wait(0.2)
                    hum2.Sit = false
                    root2.AssemblyLinearVelocity = Vector3.zero
                    root2.AssemblyAngularVelocity = Vector3.zero
                    task.wait(0.5)
                    firePrompt(bag.prompt)
                    task.wait(0.3)
                    firePrompt(bag.prompt)
                    task.wait(5.5)
                end
                robberyProcessedBags[bag.obj] = true
                task.wait(0.1)
            end
        end
        task.wait(0.2)
    end
end

local function stopRobbery()
    runningRobbery = false
    robberyProcessedBags = {}
    local _, _, hum = getChar()
    if hum then hum.Sit = false end
end

-- ==========================================
-- 15. PAINEL DO MEIO
-- ==========================================
local MiddlePanel = Instance.new("Frame")
MiddlePanel.Name = "MiddlePanel"
MiddlePanel.Size = UDim2.new(0, 140, 1, -20)
MiddlePanel.Position = UDim2.new(0, 100, 0, 10)
MiddlePanel.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
MiddlePanel.BorderSizePixel = 0
MiddlePanel.ClipsDescendants = true
MiddlePanel.Parent = MainFrame

local MiddleCorner = Instance.new("UICorner")
MiddleCorner.CornerRadius = UDim.new(0, 8)
MiddleCorner.Parent = MiddlePanel

-- ==========================================
-- 15.1 RAGE
-- ==========================================
local MiddleMaskRage = Instance.new("Frame")
MiddleMaskRage.Name = "MiddleMaskRage"
MiddleMaskRage.Size = UDim2.new(0, 0, 1, -20)
MiddleMaskRage.Position = UDim2.new(0, 10, 0, 10)
MiddleMaskRage.BackgroundTransparency = 1
MiddleMaskRage.ClipsDescendants = true
MiddleMaskRage.Visible = false
MiddleMaskRage.Parent = MiddlePanel

local RageContent = Instance.new("Frame")
RageContent.Name = "RageContent"
RageContent.Size = UDim2.new(0, 120, 1, 0)
RageContent.BackgroundTransparency = 1
RageContent.Parent = MiddleMaskRage

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 10)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Parent = RageContent

local aimbotEnabled = false
local hideFov = false
local ignoreFriends = false
local sliderValue = 0
local aimMode = "None"

local function updateFovVisual()
    if not aimbotEnabled or hideFov then
        FovCircle.Visible = false
    else
        FovCircle.Visible = true
        local size = math.max(10, sliderValue * 4)
        FovCircle.Size = UDim2.new(0, size, 0, size)
    end
end

local friendsCache = {}
local function isFriend(player)
    if friendsCache[player.UserId] ~= nil then
        return friendsCache[player.UserId]
    end
    local ok, result = pcall(function()
        return LocalPlayer:IsFriendsWith(player.UserId)
    end)
    local val = ok and result == true
    friendsCache[player.UserId] = val
    return val
end

Players.PlayerRemoving:Connect(function(p)
    friendsCache[p.UserId] = nil
end)


local function getTarget()
    local cam = workspace.CurrentCamera
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local fovPixels = math.max(10, sliderValue * 4)
    local best, bestDist = nil, fovPixels

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local head = plr.Character:FindFirstChild("Head")
            local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
            if head and humanoid and humanoid.Health > 0 then
                if ignoreFriends and isFriend(plr) then
                    continue
                end
                local screenPos, onScreen = cam:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist < bestDist then
                        bestDist = dist
                        best = plr
                    end
                end
            end
        end
    end
    return best
end

RunService.RenderStepped:Connect(function(dt)
    pcall(function()
        if not aimbotEnabled or aimMode == "None" then return end
        local cam = workspace.CurrentCamera
        if not cam then return end
        local target = getTarget()
        if not target then return end
        local head = target.Character and target.Character:FindFirstChild("Head")
        if not head then return end
        local targetCF = CFrame.new(cam.CFrame.Position, head.Position)
        local alpha = aimMode == "Rage"
            and math.clamp(dt * 25, 0, 1)
            or  math.clamp(dt * 6,  0, 1)
        cam.CFrame = cam.CFrame:Lerp(targetCF, alpha)
    end)
end)

createCheckbox(RageContent, "Enable aimbot", 1, function(on)
    aimbotEnabled = on
    updateFovVisual()
end)

createCheckbox(RageContent, "Hide fov", 2, function(on)
    hideFov = on
    updateFovVisual()
end)

local SliderFrame = Instance.new("Frame")
SliderFrame.Size = UDim2.new(1, 0, 0, 28)
SliderFrame.BackgroundTransparency = 1
SliderFrame.LayoutOrder = 3
SliderFrame.Parent = RageContent

local SliderText = Instance.new("TextLabel")
SliderText.Size = UDim2.new(0.93, 0, 0, 12)
SliderText.Position = UDim2.new(0.02, 0, 0, 0)
SliderText.BackgroundTransparency = 1
SliderText.Text = "Slider"
SliderText.TextColor3 = Color3.fromRGB(150, 150, 150)
SliderText.TextSize = 11
SliderText.Font = Enum.Font.Gotham
SliderText.TextXAlignment = Enum.TextXAlignment.Left
SliderText.Parent = SliderFrame

local SliderValueText = Instance.new("TextLabel")
SliderValueText.Size = UDim2.new(0, 25, 0, 12)
SliderValueText.Position = UDim2.new(0.95, 0, 0, 0)
SliderValueText.AnchorPoint = Vector2.new(1, 0)
SliderValueText.BackgroundTransparency = 1
SliderValueText.Text = "0"
SliderValueText.TextColor3 = Color3.fromRGB(200, 200, 200)
SliderValueText.TextSize = 11
SliderValueText.Font = Enum.Font.Gotham
SliderValueText.TextXAlignment = Enum.TextXAlignment.Right
SliderValueText.Parent = SliderFrame

local BarBg = Instance.new("Frame")
BarBg.Size = UDim2.new(0.9, 0, 0, 3)
BarBg.Position = UDim2.new(0.05, 0, 0, 18)
BarBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
BarBg.Parent = SliderFrame

local BgCorner = Instance.new("UICorner")
BgCorner.CornerRadius = UDim.new(1, 0)
BgCorner.Parent = BarBg

local BarFill = Instance.new("Frame")
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
BarFill.Parent = BarBg

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(1, 0)
FillCorner.Parent = BarFill

local Knob = Instance.new("Frame")
Knob.Size = UDim2.new(0, 12, 0, 6)
Knob.Position = UDim2.new(1, -6, 0.5, -3)
Knob.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
Knob.Parent = BarFill

local KnobCorner = Instance.new("UICorner")
KnobCorner.CornerRadius = UDim.new(1, 0)
KnobCorner.Parent = Knob

local SliderHitbox = Instance.new("TextButton")
SliderHitbox.Size = UDim2.new(0.9, 0, 0, 18)
SliderHitbox.Position = UDim2.new(0.05, 0, 0, 10)
SliderHitbox.BackgroundTransparency = 1
SliderHitbox.Text = ""
SliderHitbox.ZIndex = 5
SliderHitbox.Parent = SliderFrame

local draggingSlider = false

local function updateSlider(input)
    local mouseX = input.Position.X
    local barAbsPos = BarBg.AbsolutePosition.X
    local barAbsSize = BarBg.AbsoluteSize.X
    local percentage = math.clamp((mouseX - barAbsPos) / barAbsSize, 0, 1)
    BarFill.Size = UDim2.new(percentage, 0, 1, 0)
    sliderValue = math.floor(percentage * 100)
    SliderValueText.Text = tostring(sliderValue)
    updateFovVisual()
end

SliderHitbox.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSlider = true
        updateSlider(input)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSlider = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingSlider and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        updateSlider(input)
    end
end)

local DropdownFrame = Instance.new("Frame")
DropdownFrame.Size = UDim2.new(1, 0, 0, 22)
DropdownFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
DropdownFrame.ZIndex = 5
DropdownFrame.LayoutOrder = 4
DropdownFrame.Parent = RageContent

local DropCorner = Instance.new("UICorner")
DropCorner.CornerRadius = UDim.new(0, 4)
DropCorner.Parent = DropdownFrame

local DropBtn = Instance.new("TextButton")
DropBtn.Size = UDim2.new(1, 0, 1, 0)
DropBtn.BackgroundTransparency = 1
DropBtn.Text = "  None"
DropBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
DropBtn.TextSize = 11
DropBtn.Font = Enum.Font.Gotham
DropBtn.TextXAlignment = Enum.TextXAlignment.Left
DropBtn.ZIndex = 5
DropBtn.Parent = DropdownFrame

local Arrow = Instance.new("TextLabel")
Arrow.Size = UDim2.new(0, 15, 1, 0)
Arrow.Position = UDim2.new(1, -18, 0, 0)
Arrow.BackgroundTransparency = 1
Arrow.Text = "▼"
Arrow.TextColor3 = Color3.fromRGB(200, 200, 200)
Arrow.TextSize = 8
Arrow.Rotation = 0
Arrow.ZIndex = 5
Arrow.Parent = DropdownFrame

local DropMenu = Instance.new("Frame")
DropMenu.Size = UDim2.new(1, 0, 0, 0)
DropMenu.Position = UDim2.new(0, 0, 1, 2)
DropMenu.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
DropMenu.Visible = false
DropMenu.ClipsDescendants = true
DropMenu.ZIndex = 6
DropMenu.Parent = DropdownFrame

local MenuCorner = Instance.new("UICorner")
MenuCorner.CornerRadius = UDim.new(0, 4)
MenuCorner.Parent = DropMenu

local Opt1 = Instance.new("TextButton")
Opt1.Size = UDim2.new(1, 0, 0, 20)
Opt1.BackgroundTransparency = 1
Opt1.Text = "  Legit"
Opt1.TextColor3 = Color3.fromRGB(200, 200, 200)
Opt1.TextSize = 11
Opt1.Font = Enum.Font.Gotham
Opt1.TextXAlignment = Enum.TextXAlignment.Left
Opt1.ZIndex = 6
Opt1.Parent = DropMenu

local Opt2 = Instance.new("TextButton")
Opt2.Size = UDim2.new(1, 0, 0, 20)
Opt2.Position = UDim2.new(0, 0, 0, 20)
Opt2.BackgroundTransparency = 1
Opt2.Text = "  Rage"
Opt2.TextColor3 = Color3.fromRGB(200, 200, 200)
Opt2.TextSize = 11
Opt2.Font = Enum.Font.Gotham
Opt2.TextXAlignment = Enum.TextXAlignment.Left
Opt2.ZIndex = 6
Opt2.Parent = DropMenu

local isOpen = false
local menuOpenSize = UDim2.new(1, 0, 0, 40)
local menuCloseSize = UDim2.new(1, 0, 0, 0)

DropBtn.MouseButton1Click:Connect(function()
    isOpen = not isOpen
    if isOpen then
        DropMenu.Visible = true
        TweenService:Create(DropMenu, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = menuOpenSize}):Play()
        TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 180}):Play()
    else
        local closeTween = TweenService:Create(DropMenu, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = menuCloseSize})
        closeTween:Play()
        TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
        closeTween.Completed:Connect(function()
            if not isOpen then DropMenu.Visible = false end
        end)
    end
end)

Opt1.MouseButton1Click:Connect(function()
    DropBtn.Text = "  Legit"
    aimMode = "Legit"
    isOpen = false
    TweenService:Create(DropMenu, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = menuCloseSize}):Play()
    TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
    task.delay(0.2, function() DropMenu.Visible = false end)
end)

Opt2.MouseButton1Click:Connect(function()
    DropBtn.Text = "  Rage"
    aimMode = "Rage"
    isOpen = false
    TweenService:Create(DropMenu, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = menuCloseSize}):Play()
    TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
    task.delay(0.2, function() DropMenu.Visible = false end)
end)

createCheckbox(RageContent, "Sem grudar amizades", 5, function(on)
    ignoreFriends = on
end)

-- ==========================================
-- 15.2 FARMS
-- ==========================================
local MiddleMaskFarms = Instance.new("Frame")
MiddleMaskFarms.Name = "MiddleMaskFarms"
MiddleMaskFarms.Size = UDim2.new(0, 0, 1, -20)
MiddleMaskFarms.Position = UDim2.new(0, 10, 0, 10)
MiddleMaskFarms.BackgroundTransparency = 1
MiddleMaskFarms.ClipsDescendants = true
MiddleMaskFarms.Visible = false
MiddleMaskFarms.Parent = MiddlePanel

local FarmsContent = Instance.new("Frame")
FarmsContent.Name = "FarmsContent"
FarmsContent.Size = UDim2.new(0, 120, 1, 0)
FarmsContent.BackgroundTransparency = 1
FarmsContent.Parent = MiddleMaskFarms

local ListLayoutFarms = Instance.new("UIListLayout")
ListLayoutFarms.Padding = UDim.new(0, 10)
ListLayoutFarms.SortOrder = Enum.SortOrder.LayoutOrder
ListLayoutFarms.Parent = FarmsContent

createCheckbox(FarmsContent, "Farm peças", 1, function(on)
    if on then
        if runningPecas then return end
        if pegarRota() then task.spawn(runPecasLoop) end
    else
        if runningPecas then stopPecasFarm() end
    end
end)

createCheckbox(FarmsContent, "Farm pesca", 2, function(on)
    if on then
        if runningPesca then return end
        startPescaFarm()
    else
        if runningPesca then stopPescaFarm() end
    end
end)

createCheckbox(FarmsContent, "Farm banco", 3, function(on)
    if on then
        if runningRobbery then return end
        task.spawn(function() runRobbery("banco") end)
    else
        if runningRobbery and currentRobberyType == "banco" then stopRobbery() end
    end
end)

createCheckbox(FarmsContent, "Farm cassino", 4, function(on)
    if on then
        if runningRobbery then return end
        task.spawn(function() runRobbery("cassino") end)
    else
        if runningRobbery and currentRobberyType == "cassino" then stopRobbery() end
    end
end)

-- ==========================================
-- 15.3 VEHICLES
-- ==========================================
local MiddleMaskVehicles = Instance.new("Frame")
MiddleMaskVehicles.Name = "MiddleMaskVehicles"
MiddleMaskVehicles.Size = UDim2.new(0, 0, 1, -20)
MiddleMaskVehicles.Position = UDim2.new(0, 10, 0, 10)
MiddleMaskVehicles.BackgroundTransparency = 1
MiddleMaskVehicles.ClipsDescendants = true
MiddleMaskVehicles.Visible = false
MiddleMaskVehicles.Parent = MiddlePanel

local VehiclesContent = Instance.new("Frame")
VehiclesContent.Name = "VehiclesContent"
VehiclesContent.Size = UDim2.new(0, 120, 1, 0)
VehiclesContent.BackgroundTransparency = 1
VehiclesContent.Parent = MiddleMaskVehicles

local ListLayoutVehicles = Instance.new("UIListLayout")
ListLayoutVehicles.Padding = UDim.new(0, 10)
ListLayoutVehicles.SortOrder = Enum.SortOrder.LayoutOrder
ListLayoutVehicles.Parent = VehiclesContent

local vehicleScanEnabled   = false
local spectateEnabled      = false
local spectateTargetModel  = nil
local selectedVehicleName  = nil
local vehicleMap           = {}
local vehicleRows          = {}
local VehicleListFrame     = nil

local function getSpawnedVehicles()
    local uniqueNames = {}
    local list = {}
    local _, myRoot = getChar()
    local myPos = myRoot and myRoot.Position or Vector3.zero

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("VehicleSeat") then
            local carModel = obj:FindFirstAncestorOfClass("Model")
            if carModel and not carModel:FindFirstChildOfClass("Humanoid") and carModel:IsDescendantOf(Workspace) then
                local primary = carModel.PrimaryPart or carModel:FindFirstChildWhichIsA("BasePart")
                if primary and primary:IsA("BasePart") then
                    local name = carModel.Name
                    local dist = (primary.Position - myPos).Magnitude
                    if not uniqueNames[name] then
                        uniqueNames[name] = {model = carModel, dist = dist}
                        table.insert(list, {name = name, model = carModel, dist = dist})
                    elseif dist < uniqueNames[name].dist then
                        uniqueNames[name] = {model = carModel, dist = dist}
                        for _, item in ipairs(list) do
                            if item.name == name then
                                item.model = carModel
                                item.dist = dist
                                break
                            end
                        end
                    end
                end
            end
        end
    end
    return list
end

local function createVehicleRow(name, layoutOrder)
    local row = Instance.new("TextButton")
    row.Name = name
    row.Size = UDim2.new(1, 0, 0, 20)
    row.BackgroundTransparency = 1
    row.BorderSizePixel = 0
    row.AutoButtonColor = false
    row.Text = name .. " - 0m"
    row.TextColor3 = Color3.fromRGB(160, 160, 160)
    row.TextSize = 11
    row.Font = Enum.Font.Gotham
    row.TextXAlignment = Enum.TextXAlignment.Left
    row.TextTruncate = Enum.TextTruncate.AtEnd
    row.LayoutOrder = layoutOrder
    row.ClipsDescendants = true
    row.ZIndex = 2
    row.Parent = VehicleListFrame

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 4)
    pad.Parent = row

    vehicleRows[name] = row

    row.MouseButton1Click:Connect(function()
        if selectedVehicleName == name then
            row.TextColor3 = Color3.fromRGB(160, 160, 160)
            selectedVehicleName = nil
            spectateTargetModel = nil
            if spectateEnabled then
                local _, _, hum = getChar()
                if hum then
                    local cam = workspace.CurrentCamera
                    cam.CameraType = Enum.CameraType.Custom
                    cam.CameraSubject = hum
                end
            end
        else
            if selectedVehicleName and vehicleRows[selectedVehicleName] then
                vehicleRows[selectedVehicleName].TextColor3 = Color3.fromRGB(160, 160, 160)
            end
            selectedVehicleName = name
            spectateTargetModel = vehicleMap[name]
            row.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end)
end

local function refreshVehicleList()
    if not vehicleScanEnabled or not VehicleListFrame then return end
    local vehicles = getSpawnedVehicles()
    table.sort(vehicles, function(a, b) return a.dist < b.dist end)

    local newSet = {}
    for _, v in ipairs(vehicles) do newSet[v.name] = v.model end

    local needsRebuild = false
    for name in pairs(newSet) do
        if not vehicleRows[name] then needsRebuild = true; break end
    end
    if not needsRebuild then
        for name in pairs(vehicleRows) do
            if not newSet[name] then needsRebuild = true; break end
        end
    end

    if needsRebuild then
        for _, row in pairs(vehicleRows) do
            if row and row.Parent then row:Destroy() end
        end
        vehicleRows = {}
        vehicleMap = {}
        for i, v in ipairs(vehicles) do
            vehicleMap[v.name] = v.model
            createVehicleRow(v.name, i)
        end
        if selectedVehicleName and not newSet[selectedVehicleName] then
            selectedVehicleName = nil
            spectateTargetModel = nil
            if spectateEnabled then
                local _, _, hum = getChar()
                if hum then
                    local cam = workspace.CurrentCamera
                    cam.CameraType = Enum.CameraType.Custom
                    cam.CameraSubject = hum
                end
            end
        end
    else
        for _, v in ipairs(vehicles) do
            vehicleMap[v.name] = v.model
            local row = vehicleRows[v.name]
            if row and row.Parent then
                row.Text = v.name .. " - " .. math.floor(v.dist) .. "m"
            end
        end
    end

    if VLEmptyLabel then
        VLEmptyLabel.Visible = (#vehicles == 0)
    end
end

task.spawn(function()
    while true do
        if vehicleScanEnabled then pcall(refreshVehicleList) end
        task.wait(0.25)
    end
end)

RunService.RenderStepped:Connect(function()
    pcall(function()
        if spectateEnabled and spectateTargetModel and spectateTargetModel.Parent then
            local seat = spectateTargetModel:FindFirstChildWhichIsA("VehicleSeat")
            if seat then
                local cam = workspace.CurrentCamera
                if not cam then return end
                cam.CameraType = Enum.CameraType.Custom
                cam.CameraSubject = seat
            end
        end
    end)
end)

createCheckbox(VehiclesContent, "Aba vehicles", 1, function(on)
    vehicleScanEnabled = on
    if VehicleListFrame then VehicleListFrame.Visible = on end
    if on then
        task.spawn(function() task.wait(0.05); pcall(refreshVehicleList) end)
    else
        for _, row in pairs(vehicleRows) do
            if row and row.Parent then row:Destroy() end
        end
        vehicleRows = {}; vehicleMap = {}
        selectedVehicleName = nil; spectateTargetModel = nil
        if spectateEnabled then
            local _, _, hum = getChar()
            if hum then
                local cam = workspace.CurrentCamera
                cam.CameraType = Enum.CameraType.Custom
                cam.CameraSubject = hum
            end
        end
        if VLEmptyLabel then VLEmptyLabel.Visible = true end
    end
end)

createCheckbox(VehiclesContent, "Spectar vehicle", 2, function(on)
    spectateEnabled = on
    if not on then
        local _, _, hum = getChar()
        if hum then
            local cam = workspace.CurrentCamera
            cam.CameraType = Enum.CameraType.Custom
            cam.CameraSubject = hum
        end
    end
end)

local BtnTeleportarVehicle = createButton(VehiclesContent, "Teleportar no vehicle", 3)
local BtnTpDesmanche       = createButton(VehiclesContent, "Tp no desmanche",       4)

BtnTeleportarVehicle.MouseButton1Click:Connect(function()
    if not spectateTargetModel or not spectateTargetModel.Parent then
        notify("Nenhum veículo selecionado"); return
    end
    local primary = spectateTargetModel.PrimaryPart or spectateTargetModel:FindFirstChildWhichIsA("BasePart")
    if not primary or not primary:IsA("BasePart") then
        notify("Veículo sem part primária"); return
    end
    local _, root, hum = getChar()
    if not root or not hum then return end
    pcall(function() Workspace:RequestStreamAroundAsync(primary.Position, 2) end)
    local targetPos = primary.Position + Vector3.new(0, 3, 0)
    hum.Sit = true; task.wait(0.1); root.CFrame = CFrame.new(targetPos); task.wait(0.2); hum.Sit = false
    notify("TP pro veículo")
end)

BtnTpDesmanche.MouseButton1Click:Connect(function()
    local _, root, hum = getChar()
    if not root or not hum then return end
    local targetPos = COORD_DESMANCHE + Vector3.new(0, 5, 0)
    if hum.SeatPart then
        local carModel = hum.SeatPart:FindFirstAncestorOfClass("Model")
        if carModel then
            hum.Sit = true; task.wait(0.1)
            pcall(function() carModel:PivotTo(CFrame.new(targetPos)) end)
            root.CFrame = CFrame.new(targetPos); task.wait(0.2)
            notify("Carro e jogador TP pro desmanche")
            return
        end
    end
    hum.Sit = true; task.wait(0.1); root.CFrame = CFrame.new(targetPos); task.wait(0.2); hum.Sit = false
    notify("TP pro desmanche (a pé)")
end)

-- ==========================================
-- 15.4 TELEPORT
-- ==========================================
local MiddleMaskTeleport = Instance.new("Frame")
MiddleMaskTeleport.Name = "MiddleMaskTeleport"
MiddleMaskTeleport.Size = UDim2.new(0, 0, 1, -20)
MiddleMaskTeleport.Position = UDim2.new(0, 10, 0, 10)
MiddleMaskTeleport.BackgroundTransparency = 1
MiddleMaskTeleport.ClipsDescendants = true
MiddleMaskTeleport.Visible = false
MiddleMaskTeleport.Parent = MiddlePanel

local MiddleScrollTeleport = Instance.new("ScrollingFrame")
MiddleScrollTeleport.Name = "MiddleScrollTeleport"
MiddleScrollTeleport.Size = UDim2.new(0, 120, 1, 0)
MiddleScrollTeleport.BackgroundTransparency = 1
MiddleScrollTeleport.BorderSizePixel = 0
MiddleScrollTeleport.ScrollBarThickness = 2
MiddleScrollTeleport.ScrollBarImageColor3 = Color3.fromRGB(90, 90, 90)
MiddleScrollTeleport.ScrollBarImageTransparency = 0.4
MiddleScrollTeleport.AutomaticCanvasSize = Enum.AutomaticSize.Y
MiddleScrollTeleport.CanvasSize = UDim2.new(0, 0, 0, 0)
MiddleScrollTeleport.ScrollingDirection = Enum.ScrollingDirection.Y
MiddleScrollTeleport.Parent = MiddleMaskTeleport

local ListLayoutTeleportMiddle = Instance.new("UIListLayout")
ListLayoutTeleportMiddle.Padding = UDim.new(0, 10)
ListLayoutTeleportMiddle.SortOrder = Enum.SortOrder.LayoutOrder
ListLayoutTeleportMiddle.Parent = MiddleScrollTeleport

local teleportMiddleList = {
    { name = "Banco",             pos = Vector3.new(-637, 108, -2673) },
    { name = "Cassino",           pos = Vector3.new(-1359, 141, -4026) },
    { name = "Pesca",             pos = Vector3.new(-2596, 122, -3040) },
    { name = "Mecânica",          pos = Vector3.new(-269, 122, -2903) },
    { name = "Hospital",          pos = Vector3.new(-415, 122, -4975) },
    { name = "Praça",             pos = Vector3.new(-1058, 132, -4870) },
    { name = "Garagem da praça",  pos = Vector3.new(-1002, 129, -4642) },
    { name = "Coreia",            pos = Vector3.new(-481, 122, -4080) },
}

for i, loc in ipairs(teleportMiddleList) do
    local btn = createButton(MiddleScrollTeleport, loc.name, i)
    btn.MouseButton1Click:Connect(function()
        teleportTo(loc.pos, loc.name)
    end)
end

-- ==========================================
-- 16. OTHERS (Speed + Anti-Ragdoll + Chars)
-- ==========================================
local function setupOthersTab()
    local MiddleMaskOthers = Instance.new("Frame")
    MiddleMaskOthers.Name = "MiddleMaskOthers"
    MiddleMaskOthers.Size = UDim2.new(0, 0, 1, -20)
    MiddleMaskOthers.Position = UDim2.new(0, 10, 0, 10)
    MiddleMaskOthers.BackgroundTransparency = 1
    MiddleMaskOthers.ClipsDescendants = true
    MiddleMaskOthers.Visible = false
    MiddleMaskOthers.Parent = MiddlePanel

    othersModule.MiddleMaskOthers = MiddleMaskOthers

    local OthersContent = Instance.new("Frame")
    OthersContent.Name = "OthersContent"
    OthersContent.Size = UDim2.new(0, 120, 1, 0)
    OthersContent.BackgroundTransparency = 1
    OthersContent.Parent = MiddleMaskOthers

    local OthersLayout = Instance.new("UIListLayout")
    OthersLayout.Padding = UDim.new(0, 8)
    OthersLayout.SortOrder = Enum.SortOrder.LayoutOrder
    OthersLayout.Parent = OthersContent

    local antiRagdollEnabled = false
    local motorCache = {}
    local isRagdollLocked = false

    local function setupAntiRagdoll(character)
        if not antiRagdollEnabled then return end
        local hum = character:WaitForChild("Humanoid", 5)
        if not hum then return end

        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
        hum.BreakJointsOnDeath = false
        hum.AutoRotate = true

        motorCache = {}
        for _, v in ipairs(character:GetDescendants()) do
            if v:IsA("Motor6D") then
                motorCache[v.Name] = { Part0 = v.Part0, Part1 = v.Part1, C0 = v.C0, C1 = v.C1, Parent = v.Parent }
            end
        end

        character.DescendantAdded:Connect(function(inst)
            if not antiRagdollEnabled then return end
            if inst:IsA("BallSocketConstraint") or inst:IsA("HingeConstraint") or inst:IsA("RopeConstraint") then
                task.defer(function() if inst and inst.Parent then inst:Destroy() end end)
            end
        end)

        hum.StateChanged:Connect(function(oldState, newState)
            if not antiRagdollEnabled then return end
            if newState == Enum.HumanoidStateType.Freefall or newState == Enum.HumanoidStateType.Jumping then
                isRagdollLocked = true
            elseif newState == Enum.HumanoidStateType.Landed or newState == Enum.HumanoidStateType.Running then
                if isRagdollLocked then
                    task.delay(0.2, function()
                        if hum and hum.Parent and hum:GetState() ~= Enum.HumanoidStateType.Freefall then
                            isRagdollLocked = false
                        end
                    end)
                end
            end
        end)
    end

    if LocalPlayer.Character then setupAntiRagdoll(LocalPlayer.Character) end

    LocalPlayer.CharacterAdded:Connect(function(char)
        isRagdollLocked = false
        task.wait(1)
        if antiRagdollEnabled then
            setupAntiRagdoll(char)
        end
    end)

    local speedEnabled = false
    local targetSpeed = 175
    local BASE_SPEED = 16
    local isDoingSpeedFlush = false
    local wasMoving = false

    createCheckbox(OthersContent, "Enable speed", 1, function(on)
        speedEnabled = on
        if not on then
            local _, _, hum = getChar()
            if hum then hum.WalkSpeed = BASE_SPEED end
        end
    end)

    local speedSliderFrame = Instance.new("Frame")
    speedSliderFrame.Size = UDim2.new(1, 0, 0, 28)
    speedSliderFrame.BackgroundTransparency = 1
    speedSliderFrame.LayoutOrder = 2
    speedSliderFrame.Parent = OthersContent

    local speedSliderText = Instance.new("TextLabel")
    speedSliderText.Size = UDim2.new(0.6, 0, 0, 12)
    speedSliderText.Position = UDim2.new(0.02, 0, 0, 0)
    speedSliderText.BackgroundTransparency = 1
    speedSliderText.Text = "Speed"
    speedSliderText.TextColor3 = Color3.fromRGB(150, 150, 150)
    speedSliderText.TextSize = 11
    speedSliderText.Font = Enum.Font.Gotham
    speedSliderText.TextXAlignment = Enum.TextXAlignment.Left
    speedSliderText.Parent = speedSliderFrame

    local speedSliderValueText = Instance.new("TextLabel")
    speedSliderValueText.Size = UDim2.new(0, 30, 0, 12)
    speedSliderValueText.Position = UDim2.new(0.95, 0, 0, 0)
    speedSliderValueText.AnchorPoint = Vector2.new(1, 0)
    speedSliderValueText.BackgroundTransparency = 1
    speedSliderValueText.Text = "175"
    speedSliderValueText.TextColor3 = Color3.fromRGB(200, 200, 200)
    speedSliderValueText.TextSize = 11
    speedSliderValueText.Font = Enum.Font.Gotham
    speedSliderValueText.TextXAlignment = Enum.TextXAlignment.Right
    speedSliderValueText.Parent = speedSliderFrame

    local speedBarBg = Instance.new("Frame")
    speedBarBg.Size = UDim2.new(0.9, 0, 0, 3)
    speedBarBg.Position = UDim2.new(0.05, 0, 0, 18)
    speedBarBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    speedBarBg.Parent = speedSliderFrame

    local speedBgCorner = Instance.new("UICorner")
    speedBgCorner.CornerRadius = UDim.new(1, 0)
    speedBgCorner.Parent = speedBarBg

    local speedBarFill = Instance.new("Frame")
    speedBarFill.Size = UDim2.new(0.35, 0, 1, 0)
    speedBarFill.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    speedBarFill.Parent = speedBarBg

    local speedFillCorner = Instance.new("UICorner")
    speedFillCorner.CornerRadius = UDim.new(1, 0)
    speedFillCorner.Parent = speedBarFill

    local speedKnob = Instance.new("Frame")
    speedKnob.Size = UDim2.new(0, 12, 0, 6)
    speedKnob.Position = UDim2.new(1, -6, 0.5, -3)
    speedKnob.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    speedKnob.Parent = speedBarFill

    local speedKnobCorner = Instance.new("UICorner")
    speedKnobCorner.CornerRadius = UDim.new(1, 0)
    speedKnobCorner.Parent = speedKnob

    local speedSliderHitbox = Instance.new("TextButton")
    speedSliderHitbox.Size = UDim2.new(0.9, 0, 0, 18)
    speedSliderHitbox.Position = UDim2.new(0.05, 0, 0, 10)
    speedSliderHitbox.BackgroundTransparency = 1
    speedSliderHitbox.Text = ""
    speedSliderHitbox.ZIndex = 5
    speedSliderHitbox.Parent = speedSliderFrame

    local draggingSpeedSlider = false

    local function updateSpeedSlider(input)
        local mouseX = input.Position.X
        local barAbsPos = speedBarBg.AbsolutePosition.X
        local barAbsSize = speedBarBg.AbsoluteSize.X
        local percentage = math.clamp((mouseX - barAbsPos) / barAbsSize, 0, 1)
        speedBarFill.Size = UDim2.new(percentage, 0, 1, 0)
        targetSpeed = math.floor((percentage * 499) + 1)
        speedSliderValueText.Text = tostring(targetSpeed)
    end

    speedSliderHitbox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSpeedSlider = true
            updateSpeedSlider(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSpeedSlider = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if draggingSpeedSlider and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            updateSpeedSlider(input)
        end
    end)

    createCheckbox(OthersContent, "Anti-ragdoll", 3, function(on)
        antiRagdollEnabled = on
        if on then
            if LocalPlayer.Character then setupAntiRagdoll(LocalPlayer.Character) end
        else
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.PlatformStand = false
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end
    end)

    RunService.Heartbeat:Connect(function()
        if not antiRagdollEnabled or not isRagdollLocked then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end

        hum.AutoRotate = true
        if hum.PlatformStand then
            hum.PlatformStand = false
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
        local state = hum:GetState()
        if state == Enum.HumanoidStateType.Physics or state == Enum.HumanoidStateType.Ragdoll then
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end

        for name, data in pairs(motorCache) do
            local m = data.Parent:FindFirstChild(name)
            if not m or not m:IsA("Motor6D") then
                if m then m:Destroy() end
                local newM = Instance.new("Motor6D")
                newM.Name = name
                newM.Part0 = data.Part0
                newM.Part1 = data.Part1
                newM.C0 = data.C0
                newM.C1 = data.C1
                newM.Enabled = true
                newM.Parent = data.Parent
            else
                m.Enabled = true
                if name == "RootJoint" or name == "Root" then
                    m.Transform = CFrame.new()
                    m.C0 = data.C0
                    m.C1 = data.C1
                end
            end
        end
    end)

    RunService.Heartbeat:Connect(function(dt)
        if not speedEnabled then
            wasMoving = false
            return
        end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end

        local isMoving = hum.MoveDirection.Magnitude > 0.1

        if isMoving then
            hum.WalkSpeed = targetSpeed
            if not wasMoving and not isDoingSpeedFlush then
                isDoingSpeedFlush = true
                task.spawn(function()
                    hum.Sit = true
                    task.wait()
                    hum.Sit = false
                    isDoingSpeedFlush = false
                end)
            end
        else
            hum.WalkSpeed = BASE_SPEED
        end
        wasMoving = isMoving
    end)

    local RightMaskOthers = Instance.new("Frame")
    RightMaskOthers.Name = "RightMaskOthers"
    RightMaskOthers.Size = UDim2.new(0, 0, 1, -20)
    RightMaskOthers.Position = UDim2.new(0, 10, 0, 10)
    RightMaskOthers.BackgroundTransparency = 1
    RightMaskOthers.ClipsDescendants = true
    RightMaskOthers.Visible = false
    RightMaskOthers.Parent = RightPanel

    othersModule.RightMaskOthers = RightMaskOthers

    local OthersRightContent = Instance.new("Frame")
    OthersRightContent.Name = "OthersRightContent"
    OthersRightContent.Size = UDim2.new(0, 175, 1, 0)
    OthersRightContent.BackgroundTransparency = 1
    OthersRightContent.Parent = RightMaskOthers

    local OthersRightLayout = Instance.new("UIListLayout")
    OthersRightLayout.Padding = UDim.new(0, 8)
    OthersRightLayout.SortOrder = Enum.SortOrder.LayoutOrder
    OthersRightLayout.Parent = OthersRightContent

    local charsToEquip = {"AntonellaBragLegitt", "GUEDES_VPN", "falida_85", "PECZINHO_1X"}
    for i, charName in ipairs(charsToEquip) do
        local btn = createButton(OthersRightContent, "Vestechar " .. charName, i)
        btn.MouseButton1Click:Connect(function()
            enviarComandoChat("/vestechar " .. charName)
            notify("Vestindo " .. charName)
        end)
    end

    -- ==========================================
    -- STAFF GUI
    -- ==========================================
    local staffGuiEnabled = false
    local staffGui        = nil
    local staffFrame      = nil
    local staffListFrame  = nil

    local BASE_H    = 58   -- altura base (título + sep + padding)
    local ROW_H     = 20   -- altura por linha de staff
    local GUI_W     = 185

    local function isStaffTeam(player)
        if not player.Team then return false end
        local t = string.lower(player.Team.Name)
        return t:find("staff") ~= nil or t:find("admin") ~= nil
    end

    local function buildStaffGui()
        local sg = Instance.new("ScreenGui")
        sg.Name = "LuminateStaffGUI"
        sg.ResetOnSpawn = false
        sg.IgnoreGuiInset = true
        sg.DisplayOrder = 150
        sg.Parent = PlayerGui

        local sf = Instance.new("Frame")
        sf.Name = "StaffFrame"
        sf.Size = UDim2.new(0, GUI_W, 0, BASE_H)
        sf.Position = UDim2.new(0.5, -GUI_W / 2, 0, 160)
        sf.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
        sf.BorderSizePixel = 0
        sf.ClipsDescendants = true
        sf.Parent = sg

        local sfCorner = Instance.new("UICorner")
        sfCorner.CornerRadius = UDim.new(0, 10)
        sfCorner.Parent = sf

        local sfStroke = Instance.new("UIStroke")
        sfStroke.Color = Color3.fromRGB(70, 70, 70)
        sfStroke.Thickness = 1
        sfStroke.Transparency = 0.5
        sfStroke.Parent = sf

        -- Título
        local title = Instance.new("TextLabel")
        title.Name = "Title"
        title.Size = UDim2.new(1, 0, 0, 22)
        title.Position = UDim2.new(0, 0, 0, 6)
        title.BackgroundTransparency = 1
        title.Text = "Staffs online"
        title.TextColor3 = Color3.fromRGB(215, 215, 215)
        title.TextSize = 12
        title.Font = Enum.Font.GothamBold
        title.TextXAlignment = Enum.TextXAlignment.Center
        title.Parent = sf

        -- Separador quase invisível
        local sep = Instance.new("Frame")
        sep.Name = "Sep"
        sep.Size = UDim2.new(0, GUI_W - 30, 0, 1)
        sep.Position = UDim2.new(0, 15, 0, 31)
        sep.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
        sep.BackgroundTransparency = 0.75
        sep.BorderSizePixel = 0
        sep.Parent = sf

        -- Container da lista
        local lf = Instance.new("Frame")
        lf.Name = "StaffList"
        lf.Size = UDim2.new(1, -16, 1, -40)
        lf.Position = UDim2.new(0, 8, 0, 38)
        lf.BackgroundTransparency = 1
        lf.ClipsDescendants = true
        lf.Parent = sf

        local ll = Instance.new("UIListLayout")
        ll.Padding = UDim.new(0, 2)
        ll.SortOrder = Enum.SortOrder.LayoutOrder
        ll.HorizontalAlignment = Enum.HorizontalAlignment.Center
        ll.Parent = lf

        -- Drag (arrastável pelo frame inteiro)
        local draggingSF = false
        local dragStartSF, startPosSF

        sf.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingSF  = true
                dragStartSF = input.Position
                startPosSF  = sf.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        draggingSF = false
                    end
                end)
            end
        end)

        sf.InputChanged:Connect(function(input)
            if draggingSF and (input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseMovement) then
                local d = input.Position - dragStartSF
                sf.Position = UDim2.new(
                    startPosSF.X.Scale, startPosSF.X.Offset + d.X,
                    startPosSF.Y.Scale, startPosSF.Y.Offset + d.Y
                )
            end
        end)

        return sg, sf, lf
    end

    local function updateStaffList()
        if not staffGuiEnabled or not staffListFrame then return end

        -- limpa lista anterior
        for _, child in ipairs(staffListFrame:GetChildren()) do
            if not child:IsA("UIListLayout") then child:Destroy() end
        end

        local _, myRoot = getChar()
        local myPos = myRoot and myRoot.Position or Vector3.zero

        local staffList = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if isStaffTeam(p) then
                local char = p.Character
                local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                local dist = hrp and math.floor((hrp.Position - myPos).Magnitude) or 0
                table.insert(staffList, { name = p.Name, dist = dist })
            end
        end

        table.sort(staffList, function(a, b) return a.dist < b.dist end)

        if #staffList == 0 then
            local empty = Instance.new("TextLabel")
            empty.Size = UDim2.new(1, 0, 0, 16)
            empty.BackgroundTransparency = 1
            empty.Text = "nenhum staff online"
            empty.TextColor3 = Color3.fromRGB(90, 90, 90)
            empty.TextSize = 10
            empty.Font = Enum.Font.Gotham
            empty.TextXAlignment = Enum.TextXAlignment.Center
            empty.LayoutOrder = 1
            empty.Parent = staffListFrame
        else
            for i, entry in ipairs(staffList) do
                local row = Instance.new("TextLabel")
                row.Size = UDim2.new(1, 0, 0, 18)
                row.BackgroundTransparency = 1
                row.Text = entry.name .. "  -  " .. entry.dist .. "m"
                row.TextColor3 = Color3.fromRGB(195, 195, 195)
                row.TextSize = 11
                row.Font = Enum.Font.Gotham
                row.TextXAlignment = Enum.TextXAlignment.Center
                row.LayoutOrder = i
                row.Parent = staffListFrame
            end
        end

        -- Ajusta altura com tween
        local count   = math.max(1, #staffList)
        local newH    = BASE_H + (count * ROW_H)
        TweenService:Create(staffFrame,
            TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Size = UDim2.new(0, GUI_W, 0, newH) }
        ):Play()
    end

    -- Loop de atualização de distâncias
    task.spawn(function()
        while true do
            if staffGuiEnabled then pcall(updateStaffList) end
            task.wait(1)
        end
    end)

    -- Checkbox Staffs (layout order 4, abaixo do anti-ragdoll)
    createCheckbox(OthersContent, "Staffs", 4, function(on)
        staffGuiEnabled = on
        if on then
            if not staffGui then
                staffGui, staffFrame, staffListFrame = buildStaffGui()
            end
            staffGui.Enabled = true
            pcall(updateStaffList)
        else
            if staffGui then
                staffGui.Enabled = false
            end
        end
    end)
end

-- ==========================================
-- 17. ESTADO DOS ESPs
-- ==========================================
local chamsEnabled = false
local boxesEnabled = false
local tracersEnabled = false
local skeletonEnabled = false

local ChamsFolder = nil
local activeChams = {}

local function getHiddenParent()
    if gethui then
        local ok, hui = pcall(gethui)
        if ok and hui then return hui end
    end
    local ok2, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok2 and cg then return cg end
    return PlayerGui
end

local function setupChamsFolder()
    local parent = getHiddenParent()
    local old = parent:FindFirstChild("RuntimeData")
    if old then old:Destroy() end
    ChamsFolder = Instance.new("Folder")
    ChamsFolder.Name = "RuntimeData"
    ChamsFolder.Parent = parent
end
setupChamsFolder()

local function applyHighlight(player, char)
    if player == LocalPlayer then return end
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end
    if activeChams[player] then
        activeChams[player]:Destroy()
    end
    local hl = Instance.new("Highlight")
    hl.Name = tostring(math.random(100000, 999999))
    hl.Adornee = char
    hl.FillTransparency = 1
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = ChamsFolder
    activeChams[player] = hl
end

local function clearChams()
    for player, hl in pairs(activeChams) do
        if hl then hl:Destroy() end
        activeChams[player] = nil
    end
end

local function refreshChams()
    if not chamsEnabled then
        clearChams()
        return
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            applyHighlight(p, p.Character)
        end
    end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(char)
        if chamsEnabled then applyHighlight(p, char) end
    end)
    if chamsEnabled and p.Character then
        applyHighlight(p, p.Character)
    end
end)

Players.PlayerRemoving:Connect(function(p)
    if activeChams[p] then
        activeChams[p]:Destroy()
        activeChams[p] = nil
    end
end)

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        p.CharacterAdded:Connect(function(char)
            if chamsEnabled then applyHighlight(p, char) end
        end)
    end
end

local BOX_COLOR = Color3.fromRGB(255, 255, 255)
local BOX_THICKNESS = 1.5
local PADDING_Y = 10
local PADDING_X = 15

local BoxGui = Instance.new("ScreenGui")
BoxGui.Name = "BoxESPGui"
BoxGui.ResetOnSpawn = false
BoxGui.IgnoreGuiInset = true
BoxGui.Parent = PlayerGui

local espObjects = {}

local function createBoxESP(player)
    if player == LocalPlayer then return end
    local box = Instance.new("Frame")
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 0
    box.Visible = false
    box.Parent = BoxGui

    local boxStroke = Instance.new("UIStroke")
    boxStroke.Color = BOX_COLOR
    boxStroke.Thickness = BOX_THICKNESS
    boxStroke.Parent = box

    local healthBg = Instance.new("Frame")
    healthBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    healthBg.BorderSizePixel = 0
    healthBg.Visible = false
    healthBg.AnchorPoint = Vector2.new(1, 1)
    healthBg.Parent = BoxGui

    local healthFill = Instance.new("Frame")
    healthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthFill.BorderSizePixel = 0
    healthFill.AnchorPoint = Vector2.new(0, 1)
    healthFill.Position = UDim2.new(0, 0, 1, 0)
    healthFill.Size = UDim2.new(1, 0, 1, 0)
    healthFill.Parent = healthBg

    local nameLabel = Instance.new("TextLabel")
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 12
    nameLabel.TextStrokeTransparency = 0
    nameLabel.Visible = false
    nameLabel.Parent = BoxGui

    espObjects[player] = { Box = box, HealthBg = healthBg, HealthFill = healthFill, Name = nameLabel }
end

local function removeBoxESP(player)
    if espObjects[player] then
        local esp = espObjects[player]
        esp.Box:Destroy(); esp.HealthBg:Destroy(); esp.Name:Destroy()
        espObjects[player] = nil
    end
end

for _, p in pairs(Players:GetPlayers()) do createBoxESP(p) end
Players.PlayerAdded:Connect(createBoxESP)
Players.PlayerRemoving:Connect(removeBoxESP)

RunService.RenderStepped:Connect(function()
    pcall(function()
    if not boxesEnabled then return end
    for player, esp in pairs(espObjects) do
        local char = player.Character
        if char then
            local head = char:FindFirstChild("Head")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            local leftLeg = char:FindFirstChild("Left Leg") or char:FindFirstChild("LeftFoot") or char:FindFirstChild("LeftUpperLeg")
            if head and hrp and hum and leftLeg and hum.Health > 0 then
                local headPos, onScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                local legPos = Camera:WorldToViewportPoint(leftLeg.Position - Vector3.new(0, 0.5, 0))
                if onScreen and headPos.Z > 0 then
                    local height = math.abs(legPos.Y - headPos.Y) + (PADDING_Y * 2)
                    local width = (height * 0.6) + (PADDING_X * 2)
                    local boxX = headPos.X - (width / 2)
                    local boxY = headPos.Y - PADDING_Y
                    esp.Box.Position = UDim2.new(0, boxX, 0, boxY)
                    esp.Box.Size = UDim2.new(0, width, 0, height)
                    esp.Box.Visible = true
                    local healthPercent = hum.Health / hum.MaxHealth
                    esp.HealthBg.Position = UDim2.new(0, boxX - 5, 0, boxY + height)
                    esp.HealthBg.Size = UDim2.new(0, 3, 0, height)
                    esp.HealthBg.Visible = true
                    esp.HealthFill.Size = UDim2.new(1, 0, healthPercent, 0)
                    if healthPercent > 0.75 then esp.HealthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                    elseif healthPercent > 0.5 then esp.HealthFill.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
                    elseif healthPercent > 0.25 then esp.HealthFill.BackgroundColor3 = Color3.fromRGB(255, 128, 0)
                    else esp.HealthFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0) end
                    esp.Name.Position = UDim2.new(0, boxX + (width/2) - 50, 0, boxY - 20)
                    esp.Name.Size = UDim2.new(0, 100, 0, 15)
                    esp.Name.Text = player.Name
                    esp.Name.Visible = true
                else
                    esp.Box.Visible = false; esp.HealthBg.Visible = false; esp.Name.Visible = false
                end
            else
                esp.Box.Visible = false; esp.HealthBg.Visible = false; esp.Name.Visible = false
            end
        else
            esp.Box.Visible = false; esp.HealthBg.Visible = false; esp.Name.Visible = false
        end
    end
    end) -- pcall box ESP
end)

local TRACER_COLOR = Color3.fromRGB(255, 255, 255)
local THICKNESS = 1.5
local ORIGIN_OFFSET_Y = 0

local TracerGui = Instance.new("ScreenGui")
TracerGui.Name = "TracersGui"
TracerGui.ResetOnSpawn = false
TracerGui.IgnoreGuiInset = true
TracerGui.Parent = PlayerGui

local tracers = {}

local function createTracer(player)
    if player == LocalPlayer then return end
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = TRACER_COLOR
    frame.BorderSizePixel = 0
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.Visible = false
    frame.Parent = TracerGui
    tracers[player] = frame
end

local function removeTracer(player)
    if tracers[player] then
        tracers[player]:Destroy()
        tracers[player] = nil
    end
end

for _, p in pairs(Players:GetPlayers()) do createTracer(p) end
Players.PlayerAdded:Connect(createTracer)
Players.PlayerRemoving:Connect(removeTracer)

RunService.RenderStepped:Connect(function()
    pcall(function()
    if not tracersEnabled then return end
    local viewport = Camera.ViewportSize
    local origin = Vector2.new(viewport.X / 2, viewport.Y - ORIGIN_OFFSET_Y)
    for player, frame in pairs(tracers) do
        local char = player.Character
        if char then
            local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if torso and hum and hum.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(torso.Position)
                if onScreen and screenPos.Z > 0 then
                    local targetPos = Vector2.new(screenPos.X, screenPos.Y)
                    local center = (origin + targetPos) / 2
                    local distance = (targetPos - origin).Magnitude
                    local angle = math.deg(math.atan2(targetPos.Y - origin.Y, targetPos.X - origin.X))
                    frame.Position = UDim2.new(0, center.X, 0, center.Y)
                    frame.Size = UDim2.new(0, distance, 0, THICKNESS)
                    frame.Rotation = angle
                    frame.Visible = true
                else
                    frame.Visible = false
                end
            else
                frame.Visible = false
            end
        else
            frame.Visible = false
        end
    end
    end) -- pcall tracers
end)

local SKELETON_COLOR = Color3.fromRGB(255, 255, 255)
local MIN_THICKNESS = 1
local MAX_THICKNESS = 2.5

local SkeletonGui = Instance.new("ScreenGui")
SkeletonGui.Name = "SkeletonESP"
SkeletonGui.ResetOnSpawn = false
SkeletonGui.IgnoreGuiInset = true
SkeletonGui.Parent = PlayerGui

local skeletons = {}

local function createSkeleton(player)
    if player == LocalPlayer then return end
    local function makeLine()
        local f = Instance.new("Frame")
        f.BackgroundColor3 = SKELETON_COLOR
        f.BorderSizePixel = 0
        f.AnchorPoint = Vector2.new(0.5, 0.5)
        f.Visible = false
        f.Parent = SkeletonGui
        return f
    end
    skeletons[player] = {
        Spine = makeLine(), Shoulders = makeLine(), Hips = makeLine(),
        LeftArm = makeLine(), RightArm = makeLine(), LeftLeg = makeLine(), RightLeg = makeLine()
    }
end

local function removeSkeleton(player)
    if skeletons[player] then
        for _, line in pairs(skeletons[player]) do line:Destroy() end
        skeletons[player] = nil
    end
end

for _, p in pairs(Players:GetPlayers()) do createSkeleton(p) end
Players.PlayerAdded:Connect(createSkeleton)
Players.PlayerRemoving:Connect(removeSkeleton)

local function updateLine(line, p1_3D, p2_3D)
    local screen1, onScreen1 = Camera:WorldToViewportPoint(p1_3D)
    local screen2, onScreen2 = Camera:WorldToViewportPoint(p2_3D)
    if onScreen1 and onScreen2 and screen1.Z > 0 and screen2.Z > 0 then
        local v1 = Vector2.new(screen1.X, screen1.Y)
        local v2 = Vector2.new(screen2.X, screen2.Y)
        local center = (v1 + v2) / 2
        local distance = (v2 - v1).Magnitude
        local angle = math.deg(math.atan2(v2.Y - v1.Y, v2.X - v1.X))
        local thickness = math.clamp(distance * 0.015, MIN_THICKNESS, MAX_THICKNESS)
        line.Position = UDim2.new(0, center.X, 0, center.Y)
        line.Size = UDim2.new(0, distance + 2, 0, thickness)
        line.Rotation = angle
        line.Visible = true
    else
        line.Visible = false
    end
end

RunService.RenderStepped:Connect(function()
    pcall(function()
    if not skeletonEnabled then return end
    for player, skel in pairs(skeletons) do
        local char = player.Character
        if char then
            local head = char:FindFirstChild("Head")
            local torso = char:FindFirstChild("Torso")
            local leftArm = char:FindFirstChild("Left Arm")
            local rightArm = char:FindFirstChild("Right Arm")
            local leftLeg = char:FindFirstChild("Left Leg")
            local rightLeg = char:FindFirstChild("Right Leg")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if head and torso and leftArm and rightArm and leftLeg and rightLeg and hum and hum.Health > 0 then
                local topSpine = head.Position + Vector3.new(0, -0.5, 0)
                local bottomSpine = torso.Position + Vector3.new(0, -1.2, 0)
                local lShoulderPos = (torso.CFrame * CFrame.new(-1, 0.5, 0)).Position
                local rShoulderPos = (torso.CFrame * CFrame.new(1, 0.5, 0)).Position
                local lHipPos = (torso.CFrame * CFrame.new(-0.5, -1, 0)).Position
                local rHipPos = (torso.CFrame * CFrame.new(0.5, -1, 0)).Position
                local lHandPos = (leftArm.CFrame * CFrame.new(0, -1, 0)).Position
                local rHandPos = (rightArm.CFrame * CFrame.new(0, -1, 0)).Position
                local lFootPos = (leftLeg.CFrame * CFrame.new(0, -1.0, 0)).Position
                local rFootPos = (rightLeg.CFrame * CFrame.new(0, -1.0, 0)).Position
                updateLine(skel.Spine, topSpine, bottomSpine)
                updateLine(skel.Shoulders, lShoulderPos, rShoulderPos)
                updateLine(skel.Hips, lHipPos, rHipPos)
                updateLine(skel.LeftArm, lShoulderPos, lHandPos)
                updateLine(skel.RightArm, rShoulderPos, rHandPos)
                updateLine(skel.LeftLeg, lHipPos, lFootPos)
                updateLine(skel.RightLeg, rHipPos, rFootPos)
            else
                for _, line in pairs(skel) do line.Visible = false end
            end
        else
            for _, line in pairs(skel) do line.Visible = false end
        end
    end
    end) -- pcall skeleton
end)

-- ==========================================
-- 18. PAINEL DA DIREITA (base)
-- ==========================================
local RightPanel = Instance.new("Frame")
RightPanel.Name = "RightPanel"
RightPanel.Size = UDim2.new(0, 195, 1, -20)
RightPanel.Position = UDim2.new(0, 255, 0, 10)
RightPanel.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
RightPanel.BorderSizePixel = 0
RightPanel.ClipsDescendants = true
RightPanel.Parent = MainFrame

local RightCorner = Instance.new("UICorner")
RightCorner.CornerRadius = UDim.new(0, 8)
RightCorner.Parent = RightPanel

local RightMaskRage = Instance.new("Frame")
RightMaskRage.Name = "RightMaskRage"
RightMaskRage.Size = UDim2.new(0, 0, 1, -20)
RightMaskRage.Position = UDim2.new(0, 10, 0, 10)
RightMaskRage.BackgroundTransparency = 1
RightMaskRage.ClipsDescendants = true
RightMaskRage.Visible = false
RightMaskRage.Parent = RightPanel

local VisualsContent = Instance.new("Frame")
VisualsContent.Name = "VisualsContent"
VisualsContent.Size = UDim2.new(0, 175, 1, 0)
VisualsContent.BackgroundTransparency = 1
VisualsContent.Parent = RightMaskRage

local VisualsLayout = Instance.new("UIListLayout")
VisualsLayout.Padding = UDim.new(0, 10)
VisualsLayout.SortOrder = Enum.SortOrder.LayoutOrder
VisualsLayout.Parent = VisualsContent

createCheckbox(VisualsContent, "Esp chams", 1, function(on)
    chamsEnabled = on
    refreshChams()
end)

createCheckbox(VisualsContent, "Esp boxes", 2, function(on)
    boxesEnabled = on
    if not on then
        for _, esp in pairs(espObjects) do
            esp.Box.Visible = false; esp.HealthBg.Visible = false; esp.Name.Visible = false
        end
    end
end)

createCheckbox(VisualsContent, "Esp linhas", 3, function(on)
    tracersEnabled = on
    if not on then
        for _, frame in pairs(tracers) do frame.Visible = false end
    end
end)

createCheckbox(VisualsContent, "Esp skeleton", 4, function(on)
    skeletonEnabled = on
    if not on then
        for _, skel in pairs(skeletons) do
            for _, line in pairs(skel) do line.Visible = false end
        end
    end
end)

local RightMaskFarms = Instance.new("Frame")
RightMaskFarms.Name = "RightMaskFarms"
RightMaskFarms.Size = UDim2.new(0, 0, 1, -20)
RightMaskFarms.Position = UDim2.new(0, 10, 0, 10)
RightMaskFarms.BackgroundTransparency = 1
RightMaskFarms.ClipsDescendants = true
RightMaskFarms.Visible = false
RightMaskFarms.Parent = RightPanel

local FarmsRightContent = Instance.new("Frame")
FarmsRightContent.Name = "FarmsRightContent"
FarmsRightContent.Size = UDim2.new(0, 175, 1, 0)
FarmsRightContent.BackgroundTransparency = 1
FarmsRightContent.Parent = RightMaskFarms

local FarmsRightLayout = Instance.new("UIListLayout")
FarmsRightLayout.Padding = UDim.new(0, 10)
FarmsRightLayout.SortOrder = Enum.SortOrder.LayoutOrder
FarmsRightLayout.Parent = FarmsRightContent

local RightMaskVehicles = Instance.new("Frame")
RightMaskVehicles.Name = "RightMaskVehicles"
RightMaskVehicles.Size = UDim2.new(0, 0, 1, -20)
RightMaskVehicles.Position = UDim2.new(0, 10, 0, 10)
RightMaskVehicles.BackgroundTransparency = 1
RightMaskVehicles.ClipsDescendants = true
RightMaskVehicles.Visible = false
RightMaskVehicles.Parent = RightPanel

local VehiclesRightContent = Instance.new("Frame")
VehiclesRightContent.Name = "VehiclesRightContent"
VehiclesRightContent.Size = UDim2.new(0, 175, 1, 0)
VehiclesRightContent.BackgroundTransparency = 1
VehiclesRightContent.Parent = RightMaskVehicles

VehicleListFrame = Instance.new("ScrollingFrame")
VehicleListFrame.Name = "VehicleListFrame"
VehicleListFrame.Size = UDim2.new(1, 0, 1, 0)
VehicleListFrame.BackgroundTransparency = 1
VehicleListFrame.BorderSizePixel = 0
VehicleListFrame.ScrollBarThickness = 2
VehicleListFrame.ScrollBarImageColor3 = Color3.fromRGB(90, 90, 90)
VehicleListFrame.ScrollBarImageTransparency = 0.4
VehicleListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
VehicleListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
VehicleListFrame.ScrollingDirection = Enum.ScrollingDirection.Y
VehicleListFrame.ClipsDescendants = true
VehicleListFrame.Visible = false
VehicleListFrame.Parent = VehiclesRightContent

local VLListLayout = Instance.new("UIListLayout")
VLListLayout.Padding = UDim.new(0, 2)
VLListLayout.SortOrder = Enum.SortOrder.LayoutOrder
VLListLayout.Parent = VehicleListFrame

local VLPadding = Instance.new("UIPadding")
VLPadding.PaddingTop = UDim.new(0, 2)
VLPadding.PaddingBottom = UDim.new(0, 2)
VLPadding.Parent = VehicleListFrame

local VLEmptyLabel = Instance.new("TextLabel")
VLEmptyLabel.Name = "EmptyLabel"
VLEmptyLabel.Size = UDim2.new(1, 0, 0, 40)
VLEmptyLabel.BackgroundTransparency = 1
VLEmptyLabel.Text = "Nenhum veículo por perto"
VLEmptyLabel.TextColor3 = Color3.fromRGB(110, 110, 110)
VLEmptyLabel.TextSize = 10
VLEmptyLabel.Font = Enum.Font.Gotham
VLEmptyLabel.TextWrapped = true
VLEmptyLabel.LayoutOrder = 0
VLEmptyLabel.Parent = VehicleListFrame

local RightMaskTeleport = Instance.new("Frame")
RightMaskTeleport.Name = "RightMaskTeleport"
RightMaskTeleport.Size = UDim2.new(0, 0, 1, -20)
RightMaskTeleport.Position = UDim2.new(0, 10, 0, 10)
RightMaskTeleport.BackgroundTransparency = 1
RightMaskTeleport.ClipsDescendants = true
RightMaskTeleport.Visible = false
RightMaskTeleport.Parent = RightPanel

local RightScrollTeleport = Instance.new("ScrollingFrame")
RightScrollTeleport.Name = "RightScrollTeleport"
RightScrollTeleport.Size = UDim2.new(0, 175, 1, 0)
RightScrollTeleport.BackgroundTransparency = 1
RightScrollTeleport.BorderSizePixel = 0
RightScrollTeleport.ScrollBarThickness = 2
RightScrollTeleport.ScrollBarImageColor3 = Color3.fromRGB(90, 90, 90)
RightScrollTeleport.ScrollBarImageTransparency = 0.4
RightScrollTeleport.AutomaticCanvasSize = Enum.AutomaticSize.Y
RightScrollTeleport.CanvasSize = UDim2.new(0, 0, 0, 0)
RightScrollTeleport.ScrollingDirection = Enum.ScrollingDirection.Y
RightScrollTeleport.Parent = RightMaskTeleport

local ListLayoutTeleportRight = Instance.new("UIListLayout")
ListLayoutTeleportRight.Padding = UDim.new(0, 10)
ListLayoutTeleportRight.SortOrder = Enum.SortOrder.LayoutOrder
ListLayoutTeleportRight.Parent = RightScrollTeleport

local teleportRightList = {
    { name = "Lavagem de dinheiro",  pos = Vector3.new(-391, 143, -4000) },
    { name = "Fabricar armas",       pos = Vector3.new(-429, 122, -4002) },
    { name = "Mercado negro",        pos = Vector3.new(-362, 122, -4083) },
    { name = "Garagem do hospital",  pos = Vector3.new(-579, 122, -4739) },
    { name = "Mercadinho",           pos = Vector3.new(-1264, 131, -4965) },
    { name = "Prefeitura",           pos = Vector3.new(-786, 129, -4921) },
    { name = "Concessionária",       pos = Vector3.new(-734, 131, -4737) },
    { name = "Ammu",                 pos = Vector3.new(-780, 124, -4018) },
    { name = "Vermelhão",            pos = Vector3.new(-434, 129, -2844) },
    { name = "Antiga turquia",       pos = Vector3.new(-1794, 122, -4209) },
    { name = "França",               pos = Vector3.new(-4866, 341, -6153) },
}

for i, loc in ipairs(teleportRightList) do
    local btn = createButton(RightScrollTeleport, loc.name, i)
    btn.MouseButton1Click:Connect(function()
        teleportTo(loc.pos, loc.name)
    end)
end

-- ==========================================
-- 19. LÓGICA DAS ABAS
-- ==========================================
local isRageOpen = false
local isFarmsOpen = false
local isVehiclesOpen = false
local isTeleportOpen = false
local isOthersOpen = false

local wipeTweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local wipeCloseInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

local function openTab(tabName)
    if tabName ~= "Rage" and isRageOpen then
        isRageOpen = false
        TweenService:Create(TabRageFill, checkTweenInfo, {Size = UDim2.new(0, 0, 0, 0)}):Play()
        local cl = TweenService:Create(MiddleMaskRage, wipeCloseInfo, {Size = UDim2.new(0, 0, 1, -20)})
        local cr = TweenService:Create(RightMaskRage, wipeCloseInfo, {Size = UDim2.new(0, 0, 1, -20)})
        cl:Play(); cr:Play()
        cl.Completed:Connect(function() if not isRageOpen then MiddleMaskRage.Visible = false end end)
        cr.Completed:Connect(function() if not isRageOpen then RightMaskRage.Visible = false end end)
    end
    if tabName ~= "Farms" and isFarmsOpen then
        isFarmsOpen = false
        TweenService:Create(TabFarmsFill, checkTweenInfo, {Size = UDim2.new(0, 0, 0, 0)}):Play()
        local cl = TweenService:Create(MiddleMaskFarms, wipeCloseInfo, {Size = UDim2.new(0, 0, 1, -20)})
        local cr = TweenService:Create(RightMaskFarms, wipeCloseInfo, {Size = UDim2.new(0, 0, 1, -20)})
        cl:Play(); cr:Play()
        cl.Completed:Connect(function() if not isFarmsOpen then MiddleMaskFarms.Visible = false end end)
        cr.Completed:Connect(function() if not isFarmsOpen then RightMaskFarms.Visible = false end end)
    end
    if tabName ~= "Vehicles" and isVehiclesOpen then
        isVehiclesOpen = false
        TweenService:Create(TabVehiclesFill, checkTweenInfo, {Size = UDim2.new(0, 0, 0, 0)}):Play()
        local cl = TweenService:Create(MiddleMaskVehicles, wipeCloseInfo, {Size = UDim2.new(0, 0, 1, -20)})
        local cr = TweenService:Create(RightMaskVehicles, wipeCloseInfo, {Size = UDim2.new(0, 0, 1, -20)})
        cl:Play(); cr:Play()
        cl.Completed:Connect(function() if not isVehiclesOpen then MiddleMaskVehicles.Visible = false end end)
        cr.Completed:Connect(function() if not isVehiclesOpen then RightMaskVehicles.Visible = false end end)
    end
    if tabName ~= "Teleport" and isTeleportOpen then
        isTeleportOpen = false
        TweenService:Create(TabTeleportFill, checkTweenInfo, {Size = UDim2.new(0, 0, 0, 0)}):Play()
        local cl = TweenService:Create(MiddleMaskTeleport, wipeCloseInfo, {Size = UDim2.new(0, 0, 1, -20)})
        local cr = TweenService:Create(RightMaskTeleport, wipeCloseInfo, {Size = UDim2.new(0, 0, 1, -20)})
        cl:Play(); cr:Play()
        cl.Completed:Connect(function() if not isTeleportOpen then MiddleMaskTeleport.Visible = false end end)
        cr.Completed:Connect(function() if not isTeleportOpen then RightMaskTeleport.Visible = false end end)
    end
    if tabName ~= "Others" and isOthersOpen then
        isOthersOpen = false
        TweenService:Create(TabOthersFill, checkTweenInfo, {Size = UDim2.new(0, 0, 0, 0)}):Play()
        local mm = othersModule.MiddleMaskOthers
        local rm = othersModule.RightMaskOthers
        if mm then
            local cl = TweenService:Create(mm, wipeCloseInfo, {Size = UDim2.new(0, 0, 1, -20)})
            cl:Play()
            cl.Completed:Connect(function() if not isOthersOpen then mm.Visible = false end end)
        end
        if rm then
            local cr = TweenService:Create(rm, wipeCloseInfo, {Size = UDim2.new(0, 0, 1, -20)})
            cr:Play()
            cr.Completed:Connect(function() if not isOthersOpen then rm.Visible = false end end)
        end
    end

    if tabName == "Rage" then
        isRageOpen = true
        TweenService:Create(TabRageFill, checkTweenInfo, {Size = UDim2.new(1, 0, 1, 0)}):Play()
        MiddleMaskRage.Visible = true
        RightMaskRage.Visible = true
        TweenService:Create(MiddleMaskRage, wipeTweenInfo, {Size = UDim2.new(1, -20, 1, -20)}):Play()
        TweenService:Create(RightMaskRage, wipeTweenInfo, {Size = UDim2.new(1, -20, 1, -20)}):Play()
    elseif tabName == "Farms" then
        isFarmsOpen = true
        TweenService:Create(TabFarmsFill, checkTweenInfo, {Size = UDim2.new(1, 0, 1, 0)}):Play()
        MiddleMaskFarms.Visible = true
        RightMaskFarms.Visible = true
        TweenService:Create(MiddleMaskFarms, wipeTweenInfo, {Size = UDim2.new(1, -20, 1, -20)}):Play()
        TweenService:Create(RightMaskFarms, wipeTweenInfo, {Size = UDim2.new(1, -20, 1, -20)}):Play()
    elseif tabName == "Vehicles" then
        isVehiclesOpen = true
        TweenService:Create(TabVehiclesFill, checkTweenInfo, {Size = UDim2.new(1, 0, 1, 0)}):Play()
        MiddleMaskVehicles.Visible = true
        RightMaskVehicles.Visible = true
        TweenService:Create(MiddleMaskVehicles, wipeTweenInfo, {Size = UDim2.new(1, -20, 1, -20)}):Play()
        TweenService:Create(RightMaskVehicles, wipeTweenInfo, {Size = UDim2.new(1, -20, 1, -20)}):Play()
    elseif tabName == "Teleport" then
        isTeleportOpen = true
        TweenService:Create(TabTeleportFill, checkTweenInfo, {Size = UDim2.new(1, 0, 1, 0)}):Play()
        MiddleMaskTeleport.Visible = true
        RightMaskTeleport.Visible = true
        TweenService:Create(MiddleMaskTeleport, wipeTweenInfo, {Size = UDim2.new(1, -20, 1, -20)}):Play()
        TweenService:Create(RightMaskTeleport, wipeTweenInfo, {Size = UDim2.new(1, -20, 1, -20)}):Play()
    else
        isOthersOpen = true
        TweenService:Create(TabOthersFill, checkTweenInfo, {Size = UDim2.new(1, 0, 1, 0)}):Play()
        local mm = othersModule.MiddleMaskOthers
        local rm = othersModule.RightMaskOthers
        if mm then
            mm.Visible = true
            TweenService:Create(mm, wipeTweenInfo, {Size = UDim2.new(1, -20, 1, -20)}):Play()
        end
        if rm then
            rm.Visible = true
            TweenService:Create(rm, wipeTweenInfo, {Size = UDim2.new(1, -20, 1, -20)}):Play()
        end
    end
end

local function closeTab(tabName)
    if tabName == "Rage" then
        isRageOpen = false
        TweenService:Create(TabRageFill, checkTweenInfo, {Size = UDim2.new(0, 0, 0, 0)}):Play()
        local cl = TweenService:Create(MiddleMaskRage, wipeCloseInfo, {Size = UDim2.new(0, 0, 1, -20)})
        local cr = TweenService:Create(RightMaskRage, wipeCloseInfo, {Size = UDim2.new(0, 0, 1, -20)})
        cl:Play(); cr:Play()
        cl.Completed:Connect(function() if not isRageOpen then MiddleMaskRage.Visible = false end end)
        cr.Completed:Connect(function() if not isRageOpen then RightMaskRage.Visible = false end end)
    elseif tabName == "Farms" then
        isFarmsOpen = false
        TweenService:Create(TabFarmsFill, checkTweenInfo, {Size = UDim2.new(0, 0, 0, 0)}):Play()
        local cl = TweenService:Create(MiddleMaskFarms, wipeCloseInfo, {Size = UDim2.new(0, 0, 1, -20)})
        local cr = TweenService:Create(RightMaskFarms, wipeCloseInfo, {Size = UDim2.new(0, 0, 1, -20)})
        cl:Play(); cr:Play()
        cl.Completed:Connect(function() if not isFarmsOpen then MiddleMaskFarms.Visible = false end end)
        cr.Completed:Connect(function() if not isFarmsOpen then RightMaskFarms.Visible = false end end)
    elseif tabName == "Vehicles" then
        isVehiclesOpen = false
        TweenService:Create(TabVehiclesFill, checkTweenInfo, {Size = UDim2.new(0, 0, 0, 0)}):Play()
        local cl = TweenService:Create(MiddleMaskVehicles, wipeCloseInfo, {Size = UDim2.new(0, 0, 1, -20)})
        local cr = TweenService:Create(RightMaskVehicles, wipeCloseInfo, {Size = UDim2.new(0, 0, 1, -20)})
        cl:Play(); cr:Play()
        cl.Completed:Connect(function() if not isVehiclesOpen then MiddleMaskVehicles.Visible = false end end)
        cr.Completed:Connect(function() if not isVehiclesOpen then RightMaskVehicles.Visible = false end end)
    elseif tabName == "Teleport" then
        isTeleportOpen = false
        TweenService:Create(TabTeleportFill, checkTweenInfo, {Size = UDim2.new(0, 0, 0, 0)}):Play()
        local cl = TweenService:Create(MiddleMaskTeleport, wipeCloseInfo, {Size = UDim2.new(0, 0, 1, -20)})
        local cr = TweenService:Create(RightMaskTeleport, wipeCloseInfo, {Size = UDim2.new(0, 0, 1, -20)})
        cl:Play(); cr:Play()
        cl.Completed:Connect(function() if not isTeleportOpen then MiddleMaskTeleport.Visible = false end end)
        cr.Completed:Connect(function() if not isTeleportOpen then RightMaskTeleport.Visible = false end end)
    else
        isOthersOpen = false
        TweenService:Create(TabOthersFill, checkTweenInfo, {Size = UDim2.new(0, 0, 0, 0)}):Play()
        local mm = othersModule.MiddleMaskOthers
        local rm = othersModule.RightMaskOthers
        if mm then
            local cl = TweenService:Create(mm, wipeCloseInfo, {Size = UDim2.new(0, 0, 1, -20)})
            cl:Play()
            cl.Completed:Connect(function() if not isOthersOpen then mm.Visible = false end end)
        end
        if rm then
            local cr = TweenService:Create(rm, wipeCloseInfo, {Size = UDim2.new(0, 0, 1, -20)})
            cr:Play()
            cr.Completed:Connect(function() if not isOthersOpen then rm.Visible = false end end)
        end
    end
end

TabRage.MouseButton1Click:Connect(function()
    if isRageOpen then closeTab("Rage") else openTab("Rage") end
end)

TabFarms.MouseButton1Click:Connect(function()
    if isFarmsOpen then closeTab("Farms") else openTab("Farms") end
end)

TabVehicles.MouseButton1Click:Connect(function()
    if isVehiclesOpen then closeTab("Vehicles") else openTab("Vehicles") end
end)

TabTeleport.MouseButton1Click:Connect(function()
    if isTeleportOpen then closeTab("Teleport") else openTab("Teleport") end
end)

TabOthers.MouseButton1Click:Connect(function()
    if isOthersOpen then closeTab("Others") else openTab("Others") end
end)

-- ==========================================
-- 20. DRAG MOBILE (com trava do lock)
-- ==========================================
local dragging = false
local dragStart, startPos

local function isOverSlider(input)
    local mouse = input.Position
    local sPos = SliderHitbox.AbsolutePosition
    local sSize = SliderHitbox.AbsoluteSize
    return mouse.X >= sPos.X and mouse.X <= sPos.X + sSize.X and
           mouse.Y >= sPos.Y and mouse.Y <= sPos.Y + sSize.Y
end

local function isOverScroll(input)
    if not isTeleportOpen then return false end
    local mouse = input.Position
    local scrolls = { MiddleScrollTeleport, RightScrollTeleport }
    for _, scroll in ipairs(scrolls) do
        if scroll and scroll.Parent then
            local absPos = scroll.AbsolutePosition
            local absSize = scroll.AbsoluteSize
            if mouse.X >= absPos.X and mouse.X <= absPos.X + absSize.X and
               mouse.Y >= absPos.Y and mouse.Y <= absPos.Y + absSize.Y then
                return true
            end
        end
    end
    return false
end

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
    if floatingState.locked then return end
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        if isOverSlider(input) or isOverScroll(input) then return end
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if floatingState.locked then
        dragging = false
        return
    end
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        if dragging then update(input) end
    end
end)

-- ==========================================
-- 21. SETUP DA ABA OTHERS
-- ==========================================
setupOthersTab()

-- ==========================================
-- 22. BOTÕES FLUTUANTES (toggle + lock) E CHAT COMMANDS
-- ==========================================
local function setupFloatingButtons()
    local floatGui = Instance.new("ScreenGui")
    floatGui.Name = "LuminateFloating"
    floatGui.ResetOnSpawn = false
    floatGui.IgnoreGuiInset = true
    floatGui.DisplayOrder = 200
    floatGui.Parent = PlayerGui

    local container = Instance.new("Frame")
    container.Name = "ButtonContainer"
    container.Size = UDim2.new(0, 64, 0, 62)
    container.Position = UDim2.new(0, 10, 0, 120)
    container.BackgroundTransparency = 1
    container.Parent = floatGui

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 6)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = container

    local function makeFloatButton(text, order, onClick)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 28)
        btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        btn.BorderSizePixel = 0
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.LayoutOrder = order
        btn.ClipsDescendants = true
        btn.Parent = container

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = btn

        local gradient = Instance.new("UIGradient")
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(230, 230, 230)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(95, 95, 95)),
        })
        gradient.Rotation = 45
        gradient.Parent = btn

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(255, 255, 255)
        stroke.Thickness = 1
        stroke.Transparency = 0.5
        stroke.Parent = btn

        local ripple = Instance.new("Frame")
        ripple.Name = "Ripple"
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ripple.BackgroundTransparency = 1
        ripple.BorderSizePixel = 0
        ripple.ZIndex = 1
        ripple.Parent = btn

        local rippleCorner = Instance.new("UICorner")
        rippleCorner.CornerRadius = UDim.new(0, 6)
        rippleCorner.Parent = ripple

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(25, 25, 25)
        label.TextSize = 10
        label.Font = Enum.Font.GothamBold
        label.ZIndex = 2
        label.Parent = btn

        local currentTween
        btn.MouseButton1Click:Connect(function()
            if currentTween then currentTween:Cancel() end
            ripple.Size = UDim2.new(0, 0, 0, 0)
            ripple.BackgroundTransparency = 0.4
            local fillTween = TweenService:Create(ripple, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)})
            currentTween = fillTween
            fillTween:Play()
            fillTween.Completed:Connect(function(state)
                if state == Enum.PlaybackState.Completed and currentTween == fillTween then
                    TweenService:Create(ripple, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
                end
            end)
            if onClick then onClick() end
        end)

        return btn, label
    end

    makeFloatButton("toggle", 1, function()
        MainFrame.Visible = not MainFrame.Visible
    end)

    local lockBtn, lockLabel = makeFloatButton("lock", 2, function()
        floatingState.locked = not floatingState.locked
        if floatingState.locked then
            lockLabel.Text = "unlock"
            notify("GUI travada")
        else
            lockLabel.Text = "lock"
            notify("GUI destravada")
        end
    end)

    -- ==========================================
    -- FIX: chat listener com pcall em message.Text
    -- para evitar "attempt to index nil with 'Text'"
    -- ==========================================
    local function onChatMessage(text)
        if type(text) ~= "string" then return end
        local lower = string.lower(text)
        if lower == "!esconder" then
            if not floatingState.hidden then
                floatingState.hidden = true
                MainFrame.Visible = false
                container.Visible = false
                notify("GUI escondida. Digite !aparecer pra voltar.")
            end
        elseif lower == "!aparecer" then
            if floatingState.hidden then
                floatingState.hidden = false
                MainFrame.Visible = true
                container.Visible = true
                notify("GUI de volta!")
            end
        end
    end

    -- API nova: pcall em message e em message.Text separadamente
    pcall(function()
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            TextChatService.MessageReceived:Connect(function(message)
                if not message then return end
                if not message.TextSource then return end
                if message.TextSource.UserId ~= LocalPlayer.UserId then return end
                local ok, txt = pcall(function() return message.Text end)
                if ok and txt then onChatMessage(txt) end
            end)
        end
    end)

    -- Fallback API antiga
    pcall(function()
        local chatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        if chatEvents then
            local onMessageDoneFiltering = chatEvents:FindFirstChild("OnMessageDoneFiltering")
            if onMessageDoneFiltering then
                onMessageDoneFiltering.OnClientEvent:Connect(function(data)
                    if not data then return end
                    if data.SpeakerUserId ~= LocalPlayer.UserId then return end
                    local ok, txt = pcall(function() return data.Message end)
                    if ok and txt then onChatMessage(txt) end
                end)
            end
        end
    end)
end

setupFloatingButtons()
