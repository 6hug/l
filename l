cloneref = cloneref or function(i) return i end
gethui = gethui or get_hidden_gui
getcustomasset = getcustomasset or getsynasset
getgenv = getgenv or getfenv

writefile = writefile or getgenv().writefile
makefolder = makefolder or getgenv().makefolder
readfile = readfile or getgenv().readfile
delfolder = delfolder or getgenv().delfolder
delfile = delfile or getgenv().delfile
listfiles = listfiles or getgenv().listfiles
isfolder = isfolder or getgenv().isfolder
isfile = isfile or getgenv().isfile

local NeverLose = {}

NeverLose.BuiltInRegular = Font.new('rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
NeverLose.BuiltInBold = Font.new('rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json', Enum.FontWeight.Bold, Enum.FontStyle.Normal)
NeverLose.GlobalSignals = {}
NeverLose.UnloadEnabled = false

local TweenService    = cloneref(game:GetService('TweenService'))
local UserInputService = cloneref(game:GetService('UserInputService'))
local TextService     = cloneref(game:GetService('TextService'))
local RunService      = cloneref(game:GetService('RunService'))
local Players         = cloneref(game:GetService('Players'))
local HttpService     = cloneref(game:GetService('HttpService'))
local LocalPlayer     = Players.LocalPlayer
local CoreGui         = (gethui and gethui()) or (get_hidden_gui and get_hidden_gui()) or cloneref(game:FindFirstChild('CoreGui')) or cloneref(LocalPlayer.PlayerGui)
local Mouse           = LocalPlayer:GetMouse()
local CurrentCamera   = cloneref(workspace.CurrentCamera)
local ProtectGui      = protect_gui or protectgui or (syn and syn.protect_gui) or function(s) return s end

local GlobalWindow    = Instance.new('ScreenGui')
local ManualTween     = TweenInfo.new(0.1)
local SlowyTween      = TweenInfo.new(0.175)
local VSlowTween      = TweenInfo.new(0.5, Enum.EasingStyle.Quint)
local EmptyFunction   = function() end

local Encryption = {}

NeverLose.UserProfile      = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
NeverLose.GlobalLogo       = "rbxassetid://120358385035996"
NeverLose.ImageColorMapping = "rbxassetid://4155801252"
NeverLose.IconColor        = Color3.fromRGB(255, 255, 255)
NeverLose.ScreenGui        = GlobalWindow
NeverLose.Flags            = {}
NeverLose.AccentColor      = Color3.fromRGB(78, 127, 252)
NeverLose.MainColor        = Color3.fromRGB(8, 8, 13)
NeverLose.RegisiteryColor  = {}
NeverLose.NameRegisitry    = {}
NeverLose.IsMosueOverOtherFrame = false

NeverLose.RandomString = function()
    local s = ""
    for _ = 1, 11 do
        s = s .. string.rep(string.char(math.random(1, 7)), math.random(1, 4))
    end
    return s
end

ProtectGui(GlobalWindow)
GlobalWindow.Name            = NeverLose.RandomString()
GlobalWindow.IgnoreGuiInset  = true
GlobalWindow.ZIndexBehavior  = Enum.ZIndexBehavior.Global
GlobalWindow.ResetOnSpawn    = false
GlobalWindow.Parent          = CoreGui

NeverLose.Scales = {
    Small   = UDim2.fromOffset(540, 380),
    Mobile  = UDim2.fromOffset(640, 385),
    Default = UDim2.fromOffset(640, 480),
    Large   = UDim2.fromOffset(800, 600),
}

if getcustomasset then
    local link = "https://github.com/4lpaca-pin/NeverLose/blob/main/assets/%s?raw=true"
    local dir  = 'NLAssets'
    if not isfolder(dir) then makefolder(dir) end
    pcall(function()
        if not isfile(dir .. '/logo.png') then
            writefile(dir .. '/logo.png', game:HttpGet(string.format(link, 'logo.png')))
            task.wait()
        end
        if isfile(dir .. '/logo.png') then
            NeverLose.GlobalLogo = getcustomasset(dir .. '/logo.png')
        end
    end)
    pcall(function()
        if not isfile(dir .. '/saturation_value_gradient.png') then
            writefile(dir .. '/saturation_value_gradient.png', game:HttpGet(string.format(link, 'saturation_value_gradient.png')))
            task.wait()
        end
        if isfile(dir .. '/saturation_value_gradient.png') then
            NeverLose.ImageColorMapping = getcustomasset(dir .. '/saturation_value_gradient.png')
        end
    end)
end

function NeverLose:AddSignal(s)
    if NeverLose.UnloadEnabled then
        table.insert(NeverLose.GlobalSignals, s)
    end
    return s
end

function NeverLose:AddQuery(root, name)
    table.insert(NeverLose.NameRegisitry, { Root = root, Idx = name })
end

function Encryption.new(data)
    local bytes = {}
    local seed = ((#data + 3782) % 111) + 1
    string.gsub(data, '.', function(c)
        table.insert(bytes, tostring(c:byte() + seed))
    end)
    local result = "{" .. tostring(seed + 72667) .. "}?" .. table.concat(bytes, '?')
    table.clear(bytes)
    return result
end

function Encryption.reverse(data)
    local parts    = string.split(data, '?')
    local seed     = tonumber(parts[1]:gsub('[{}]', '')) - 72667
    local chars    = {}
    for i = 2, #parts do
        table.insert(chars, string.char(tonumber(parts[i]) - seed))
    end
    local result = table.concat(chars)
    table.clear(chars)
    return result
end

do
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    NeverLose.Base64Encode = function(data)
        return ((data:gsub('.', function(x)
            local r, byte = '', x:byte()
            for i = 8, 1, -1 do r = r .. (byte % 2^i - byte % 2^(i-1) > 0 and '1' or '0') end
            return r
        end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
            if #x < 6 then return '' end
            local c = 0
            for i = 1, 6 do c = c + (x:sub(i, i) == '1' and 2^(6-i) or 0) end
            return b:sub(c+1, c+1)
        end) .. ({ '', '==', '=' })[#data % 3 + 1])
    end
    NeverLose.Base64Decode = function(data)
        data = string.gsub(data, '[^' .. b .. '=]', '')
        return (data:gsub('.', function(x)
            if x == '=' then return '' end
            local r, f = '', (b:find(x) - 1)
            for i = 6, 1, -1 do r = r .. (f % 2^i - f % 2^(i-1) > 0 and '1' or '0') end
            return r
        end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
            if #x ~= 8 then return '' end
            local c = 0
            for i = 1, 8 do c = c + (x:sub(i, i) == '1' and 2^(8-i) or 0) end
            return string.char(c)
        end))
    end
end

NeverLose.IsMouseOverFrame = function(self, Frame)
    if not Frame then return end
    local AbsPos  = Frame.AbsolutePosition
    local AbsSize = Frame.AbsoluteSize
    return Mouse.X >= AbsPos.X and Mouse.X <= AbsPos.X + AbsSize.X
       and Mouse.Y >= AbsPos.Y and Mouse.Y <= AbsPos.Y + AbsSize.Y
end

NeverLose.CreateSignal = function(self, DefaultValue)
    local cache = Instance.new('BindableEvent')
    local bind  = { Value = DefaultValue, __event = cache }
    function bind:GetValue() return bind.Value end
    function bind:SetValue(f)
        bind.Value = f
        cache:Fire(f)
    end
    function bind:Connect(f)
        local sig = cache.Event:Connect(f)
        NeverLose:AddSignal(sig)
        return sig
    end
    return bind
end

NeverLose.SetIconMode = function(self, Label, Icon)
    local useBold = string.lower(string.sub(Icon, -5)) == '-bold'
    if useBold then
        Label.Text     = Icon:sub(1, -6)
        Label.FontFace = NeverLose.BuiltInBold
    else
        Label.Text     = Icon
        Label.FontFace = NeverLose.BuiltInRegular
    end
end

function NeverLose:GetIconFont(icon)
    return string.lower(string.sub(icon, -5)) == '-bold' and NeverLose.BuiltInBold or NeverLose.BuiltInRegular
end

function NeverLose:MoreThanHalfY(Value)
    return (NeverLose.ScreenGui.AbsoluteSize.Y / 2) < Value
end

NeverLose.CreateInput = function(self, Frame, Callback)
    local Button = Instance.new('ImageButton', Frame)
    Button.ZIndex             = Frame.ZIndex + 10
    Button.Size               = UDim2.fromScale(1, 1)
    Button.BackgroundTransparency = 1
    Button.ImageTransparency  = 1
    Button.Image              = "rbxasset://textuers/translateIcon.png"
    if Callback then
        local sig = Button.MouseButton1Click:Connect(Callback)
        return Button, sig
    end
    return Button
end

NeverLose.PlayAnimate = function(Self, Info, Property)
    local t = TweenService:Create(Self, Info or TweenInfo.new(0.25), Property)
    t:Play()
    return t
end

NeverLose.Drag = function(InputFrame, MoveFrame, Speed)
    local dragToggle = false
    local dragStart, startPos
    local Tween = TweenInfo.new(Speed)
    local function updateInput(input)
        local delta    = input.Position - dragStart
        local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        NeverLose.PlayAnimate(MoveFrame, Tween, { Position = position })
    end
    NeverLose:AddSignal(InputFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = true
            dragStart  = input.Position
            startPos   = MoveFrame.Position
            local conn
            conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                    conn:Disconnect()
                end
            end)
        end
    end))
    NeverLose:AddSignal(UserInputService.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragToggle then
            updateInput(input)
        end
    end))
end

NeverLose.Rounding = function(num, dec)
    local mult = 10 ^ (dec or 0)
    return math.floor(num * mult + 0.5) / mult
end

NeverLose.ProcessParams = function(self, Params, Fixed)
    Params = Params or {}
    for i, v in next, Fixed do
        Params[i] = Params[i] or v
    end
    table.clear(Fixed)
    return Params
end

NeverLose.EnabledBlur       = true
NeverLose.BlurModuleParent  = workspace.CurrentCamera

NeverLose.GetCalculatePosition = function(planePos, planeNormal, rayOrigin, rayDirection)
    local n   = planeNormal
    local d   = rayDirection
    local v   = rayOrigin - planePos
    local num = n.x*v.x + n.y*v.y + n.z*v.z
    local den = n.x*d.x + n.y*d.y + n.z*d.z
    return rayOrigin + (-num / den) * rayDirection
end

NeverLose.CreateBlurModule = function(self, Frame, Signal)
    if not NeverLose.EnabledBlur then
        return NeverLose:AddSignal(Instance.new('BindableEvent').Event:Connect(function() return "nl" end))
    end
    local Part         = Instance.new('Part', NeverLose.BlurModuleParent)
    local DepthOfField = Instance.new('DepthOfFieldEffect', cloneref(game:GetService('Lighting')))
    local BlockMesh    = Instance.new("BlockMesh")
    BlockMesh.Parent = Part
    Part.Material        = Enum.Material.Glass
    Part.Transparency    = 1
    Part.Reflectance     = 1
    Part.CastShadow      = false
    Part.Anchored        = true
    Part.CanCollide      = false
    Part.CanQuery        = false
    Part.CollisionGroup  = NeverLose.RandomString()
    Part.Size            = Vector3.new(1,1,1) * 0.01
    Part.Color           = Color3.fromRGB(0,0,0)
    Part.Name            = NeverLose.RandomString()
    DepthOfField.Enabled        = true
    DepthOfField.FarIntensity   = 0
    DepthOfField.FocusDistance  = 0
    DepthOfField.InFocusRadius  = 1000
    DepthOfField.NearIntensity  = 1
    DepthOfField.Name           = NeverLose.RandomString()

    local function UpdateFunction()
        local active = Signal:GetValue()
        if active then
            NeverLose.PlayAnimate(DepthOfField, TweenInfo.new(0.1), { NearIntensity = 1 })
            NeverLose.PlayAnimate(Part, TweenInfo.new(0.1), { Transparency = 0.97, Size = Vector3.new(1,1,1)*0.01 })
            Part.Parent = NeverLose.BlurModuleParent
        else
            NeverLose.PlayAnimate(DepthOfField, TweenInfo.new(0.1), { NearIntensity = 0 })
            NeverLose.PlayAnimate(Part, TweenInfo.new(0.1), { Size = Vector3.zero, Transparency = 1.5 })
            Part.Parent = nil
            return false
        end
        local c0   = Frame.AbsolutePosition
        local c1   = c0 + Frame.AbsoluteSize
        local r0   = CurrentCamera:ScreenPointToRay(c0.X, c0.Y, 1)
        local r1   = CurrentCamera:ScreenPointToRay(c1.X, c1.Y, 1)
        local orig = CurrentCamera.CFrame.Position + CurrentCamera.CFrame.LookVector * (0.05 - CurrentCamera.NearPlaneZ)
        local norm = CurrentCamera.CFrame.LookVector
        local p0   = CurrentCamera.CFrame:PointToObjectSpace(NeverLose.GetCalculatePosition(orig, norm, r0.Origin, r0.Direction))
        local p1   = CurrentCamera.CFrame:PointToObjectSpace(NeverLose.GetCalculatePosition(orig, norm, r1.Origin, r1.Direction))
        BlockMesh.Offset = (p0 + p1) / 2
        BlockMesh.Scale  = (p1 - p0) / 0.0101
        Part.CFrame      = CurrentCamera.CFrame
    end

    local rbxsignal  = NeverLose:AddSignal(CurrentCamera:GetPropertyChangedSignal('CFrame'):Connect(UpdateFunction))
    local loopSignal = NeverLose:AddSignal(UserInputService.InputChanged:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1
        or Input.UserInputType == Enum.UserInputType.MouseMovement
        or Input.UserInputType == Enum.UserInputType.Touch then
            pcall(UpdateFunction)
        end
    end))
    local THREAD = task.spawn(function()
        while true do task.wait(0.1) pcall(UpdateFunction) end
    end)
    Frame.Destroying:Connect(function()
        rbxsignal:Disconnect()
        loopSignal:Disconnect()
        task.cancel(THREAD)
        Part:Destroy()
        DepthOfField:Destroy()
    end)
    return rbxsignal
end

function NeverLose:RollingEffect(parent)
    local UIGradient = Instance.new("UIGradient")
    UIGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.4),
        NumberSequenceKeypoint.new(1, 0)
    }
    UIGradient.Parent = parent
    return UIGradient
end

function NeverLose:CreateShadow(parent, RollingEffect)
    local Shadow = {}
    local strokes = {}
    local thicknesses = { 6, 5, 4, 3 }
    for _, t in ipairs(thicknesses) do
        local s = Instance.new("UIStroke")
        s.Thickness    = t
        s.Transparency = 1
        s.Parent       = parent
        table.insert(strokes, s)
    end
    local rolls, RollingEffectThread
    if RollingEffect then
        rolls = {}
        for _, s in ipairs(strokes) do
            table.insert(rolls, NeverLose:RollingEffect(s))
        end
    end
    Shadow.Render = function(self, value)
        if RollingEffectThread then
            task.cancel(RollingEffectThread)
            RollingEffectThread = nil
        end
        local trans = value and 0.9 or 1
        for _, s in ipairs(strokes) do
            NeverLose.PlayAnimate(s, SlowyTween, { Transparency = trans })
        end
        if value and RollingEffect and rolls then
            RollingEffectThread = task.spawn(function()
                local level = 20
                while true do
                    task.wait(0.025)
                    for _, r in ipairs(rolls) do
                        NeverLose.PlayAnimate(r, SlowyTween, { Rotation = r.Rotation + level })
                    end
                end
            end)
        end
    end
    return Shadow
end

function NeverLose:CreateOptionWindow(Frame, Zindex)
    Zindex = Zindex or 9
    local Window = { Signal = NeverLose:CreateSignal(false) }
    local OptionHandler    = Instance.new("Frame")
    local UICorner         = Instance.new("UICorner")
    local UIListLayout     = Instance.new("UIListLayout")
    local UIStroke         = Instance.new("UIStroke")
    local shadow           = NeverLose:CreateShadow(OptionHandler)

    OptionHandler.Name                  = NeverLose.RandomString()
    OptionHandler.Parent                = NeverLose.ScreenGui
    OptionHandler.AnchorPoint           = Vector2.new(0, 0)
    OptionHandler.BackgroundColor3      = Color3.fromRGB(20, 22, 27)
    OptionHandler.BackgroundTransparency = 0.035
    OptionHandler.BorderSizePixel       = 0
    OptionHandler.ClipsDescendants      = true
    OptionHandler.Position              = UDim2.new(255,255,255,255)
    OptionHandler.Size                  = UDim2.new(0, 220, 0, 75)
    OptionHandler.ZIndex                = Zindex + 9
    UICorner.CornerRadius    = UDim.new(0, 10)
    UICorner.Parent          = OptionHandler
    UIListLayout.Parent      = OptionHandler
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIListLayout.SortOrder   = Enum.SortOrder.LayoutOrder
    UIStroke.Transparency    = 0.65
    UIStroke.Color           = Color3.fromRGB(45, 48, 58)
    UIStroke.Parent          = OptionHandler

    NeverLose:AddSignal(UIListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
        NeverLose.PlayAnimate(OptionHandler, SlowyTween, { Size = UDim2.new(0, 220, 0, UIListLayout.AbsoluteContentSize.Y - 1) })
    end))
    NeverLose:AddSignal(OptionHandler:GetPropertyChangedSignal('BackgroundTransparency'):Connect(function()
        if OptionHandler.BackgroundTransparency > 0.9 then
            OptionHandler.Visible  = false
            UIListLayout.Parent    = nil
            OptionHandler.Parent   = nil
        else
            OptionHandler.Visible  = true
            UIListLayout.Parent    = OptionHandler
            OptionHandler.Parent   = NeverLose.ScreenGui
        end
    end))

    local FollowingThread
    local function SetPosition()
        OptionHandler.AnchorPoint = NeverLose:MoreThanHalfY(Frame.AbsolutePosition.Y + 65)
            and Vector2.new(0, 1) or Vector2.new(0, 0)
        OptionHandler.Position = UDim2.fromOffset(Frame.AbsolutePosition.X + 18, Frame.AbsolutePosition.Y + 65)
    end

    Window.SetRender = function(value)
        if FollowingThread then task.cancel(FollowingThread) FollowingThread = nil end
        if value then
            SetPosition()
            NeverLose.PlayAnimate(OptionHandler, SlowyTween, { BackgroundTransparency = 0.035 })
            NeverLose.PlayAnimate(UIStroke, SlowyTween, { Transparency = 0.65 })
            shadow:Render(true)
            OptionHandler.Parent = NeverLose.ScreenGui
            FollowingThread = task.spawn(function()
                while true do task.wait() SetPosition() end
            end)
        else
            NeverLose.PlayAnimate(OptionHandler, SlowyTween, { BackgroundTransparency = 1 })
            NeverLose.PlayAnimate(UIStroke, SlowyTween, { Transparency = 1 })
            shadow:Render(false)
        end
    end

    Window.SetRender(false)
    Window.Signal:Connect(Window.SetRender)

    local Payback     = NeverLose:RegisiterItem(OptionHandler, Window.Signal)
    Payback.Winbdow   = Window
    Payback.Root      = OptionHandler
    Payback.Signal    = Window.Signal
    return Payback
end

function NeverLose:CreateColorPicker(HandleFrame)
    local ZIndex     = HandleFrame.ZIndex
    local ColorPickerLib = {}

    local ColorPickerHandler = Instance.new("Frame")
    local UICorner           = Instance.new("UICorner")
    local UIStroke           = Instance.new("UIStroke")
    local SaViMap            = Instance.new("ImageLabel")
    local UICorner_2         = Instance.new("UICorner")
    local ColorZoneSelection = Instance.new("Frame")
    local UICorner_3         = Instance.new("UICorner")
    local UIStroke_2         = Instance.new("UIStroke")
    local ColorMap           = Instance.new("Frame")
    local UIGradient         = Instance.new("UIGradient")
    local UICorner_4         = Instance.new("UICorner")
    local ColorMapSelection  = Instance.new("Frame")
    local UIStroke_3         = Instance.new("UIStroke")
    local UICorner_5         = Instance.new("UICorner")
    local RGBLabel           = Instance.new("TextLabel")
    local UICorner_6         = Instance.new("UICorner")
    local Shadow             = NeverLose:CreateShadow(ColorPickerHandler)

    ColorPickerHandler.Name                  = NeverLose.RandomString()
    ColorPickerHandler.Parent                = NeverLose.ScreenGui
    ColorPickerHandler.AnchorPoint           = Vector2.new(0, 0)
    ColorPickerHandler.BackgroundColor3      = Color3.fromRGB(20, 22, 27)
    ColorPickerHandler.BackgroundTransparency = 0.035
    ColorPickerHandler.BorderSizePixel       = 0
    ColorPickerHandler.ClipsDescendants      = true
    ColorPickerHandler.Position              = UDim2.new(255, 0, 255, 20)
    ColorPickerHandler.Size                  = UDim2.new(0, 200, 0, 240)
    ColorPickerHandler.ZIndex                = ZIndex + 125

    NeverLose:AddSignal(ColorPickerHandler:GetPropertyChangedSignal('BackgroundTransparency'):Connect(function()
        if ColorPickerHandler.BackgroundTransparency > 0.9 then
            ColorPickerHandler.Visible = false
            ColorPickerHandler.Parent  = nil
        else
            ColorPickerHandler.Visible = true
            ColorPickerHandler.Parent  = NeverLose.ScreenGui
        end
    end))

    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent       = ColorPickerHandler
    UIStroke.Transparency = 0.65
    UIStroke.Color        = Color3.fromRGB(45, 48, 58)
    UIStroke.Parent       = ColorPickerHandler

    SaViMap.Name                  = NeverLose.RandomString()
    SaViMap.Parent                = ColorPickerHandler
    SaViMap.AnchorPoint           = Vector2.new(0.5, 0)
    SaViMap.BackgroundColor3      = Color3.fromRGB(255, 0, 4)
    SaViMap.BorderSizePixel       = 0
    SaViMap.Position              = UDim2.new(0.5, 0, 0, 5)
    SaViMap.Size                  = UDim2.new(0, 185, 0, 185)
    SaViMap.ZIndex                = ZIndex + 126
    SaViMap.Image                 = NeverLose.ImageColorMapping
    UICorner_2.CornerRadius       = UDim.new(0, 5)
    UICorner_2.Parent             = SaViMap

    ColorZoneSelection.Name                  = NeverLose.RandomString()
    ColorZoneSelection.Parent                = SaViMap
    ColorZoneSelection.AnchorPoint           = Vector2.new(0.5, 0.5)
    ColorZoneSelection.BackgroundColor3      = Color3.fromRGB(255, 255, 255)
    ColorZoneSelection.BackgroundTransparency = 1
    ColorZoneSelection.BorderSizePixel       = 0
    ColorZoneSelection.Position              = UDim2.new(0.5, 0, 0.5, 0)
    ColorZoneSelection.Size                  = UDim2.new(0, 10, 0, 10)
    ColorZoneSelection.ZIndex                = ZIndex + 127
    UICorner_3.CornerRadius = UDim.new(1, 0)
    UICorner_3.Parent       = ColorZoneSelection
    UIStroke_2.Color        = Color3.fromRGB(255, 255, 255)
    UIStroke_2.Parent       = ColorZoneSelection

    ColorMap.Name             = NeverLose.RandomString()
    ColorMap.Parent           = ColorPickerHandler
    ColorMap.AnchorPoint      = Vector2.new(0.5, 0)
    ColorMap.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ColorMap.BorderSizePixel  = 0
    ColorMap.Position         = UDim2.new(0.5, 0, 0, 200)
    ColorMap.Size             = UDim2.new(1, -15, 0, 10)
    ColorMap.ZIndex           = ZIndex + 126

    UIGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0,    Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.10, Color3.fromRGB(255, 153, 0)),
        ColorSequenceKeypoint.new(0.20, Color3.fromRGB(203, 255, 0)),
        ColorSequenceKeypoint.new(0.30, Color3.fromRGB(50, 255, 0)),
        ColorSequenceKeypoint.new(0.40, Color3.fromRGB(0, 255, 102)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.60, Color3.fromRGB(0, 101, 255)),
        ColorSequenceKeypoint.new(0.70, Color3.fromRGB(50, 0, 255)),
        ColorSequenceKeypoint.new(0.80, Color3.fromRGB(204, 0, 255)),
        ColorSequenceKeypoint.new(0.90, Color3.fromRGB(255, 0, 153)),
        ColorSequenceKeypoint.new(1,    Color3.fromRGB(255, 0, 0)),
    }
    UIGradient.Parent   = ColorMap
    UICorner_4.CornerRadius = UDim.new(0, 3)
    UICorner_4.Parent   = ColorMap

    ColorMapSelection.Name                  = NeverLose.RandomString()
    ColorMapSelection.Parent                = ColorMap
    ColorMapSelection.AnchorPoint           = Vector2.new(0.5, 0.5)
    ColorMapSelection.BackgroundColor3      = Color3.fromRGB(255, 255, 255)
    ColorMapSelection.BackgroundTransparency = 1
    ColorMapSelection.BorderSizePixel       = 0
    ColorMapSelection.Position              = UDim2.new(0, 0, 0.5, 0)
    ColorMapSelection.Size                  = UDim2.new(0, 5, 1, 0)
    ColorMapSelection.ZIndex                = ZIndex + 126
    UIStroke_3.Thickness  = 2
    UIStroke_3.Color      = Color3.fromRGB(255, 255, 255)
    UIStroke_3.Parent     = ColorMapSelection
    UICorner_5.CornerRadius = UDim.new(0, 3)
    UICorner_5.Parent     = ColorMapSelection

    RGBLabel.Name                  = NeverLose.RandomString()
    RGBLabel.Parent                = ColorPickerHandler
    RGBLabel.BackgroundColor3      = Color3.fromRGB(26, 28, 36)
    RGBLabel.BackgroundTransparency = 0.75
    RGBLabel.BorderSizePixel       = 0
    RGBLabel.Position              = UDim2.new(0, 10, 0, 217)
    RGBLabel.Size                  = UDim2.new(1, -20, 0, 15)
    RGBLabel.ZIndex                = ZIndex + 127
    RGBLabel.Font                  = Enum.Font.GothamBold
    RGBLabel.Text                  = "#FFFFFF"
    RGBLabel.TextColor3            = Color3.fromRGB(255, 255, 255)
    RGBLabel.TextSize              = 12
    RGBLabel.TextTransparency      = 0.4
    RGBLabel.TextXAlignment        = Enum.TextXAlignment.Left
    UICorner_6.CornerRadius = UDim.new(0, 4)
    UICorner_6.Parent       = RGBLabel

    ColorPickerLib.SetRender = function(value)
        if value then
            ColorPickerHandler.Position = UDim2.new(0, HandleFrame.AbsolutePosition.X + 20, 0, HandleFrame.AbsolutePosition.Y + 75)
            NeverLose.PlayAnimate(ColorPickerHandler, SlowyTween, { BackgroundTransparency = 0.035 })
            NeverLose.PlayAnimate(UIStroke,           SlowyTween, { Transparency = 0.65 })
            NeverLose.PlayAnimate(SaViMap,            SlowyTween, { BackgroundTransparency = 0, ImageTransparency = 0 })
            NeverLose.PlayAnimate(UIStroke_2,         SlowyTween, { Transparency = 0 })
            NeverLose.PlayAnimate(ColorMap,           SlowyTween, { BackgroundTransparency = 0 })
            NeverLose.PlayAnimate(UIStroke_3,         SlowyTween, { Transparency = 0 })
            NeverLose.PlayAnimate(RGBLabel,           SlowyTween, { BackgroundTransparency = 0.75, TextTransparency = 0.4 })
            Shadow:Render(true)
        else
            NeverLose.PlayAnimate(ColorPickerHandler, SlowyTween, { BackgroundTransparency = 1 })
            NeverLose.PlayAnimate(UIStroke,           SlowyTween, { Transparency = 1 })
            NeverLose.PlayAnimate(SaViMap,            SlowyTween, { BackgroundTransparency = 1, ImageTransparency = 1 })
            NeverLose.PlayAnimate(UIStroke_2,         SlowyTween, { Transparency = 1 })
            NeverLose.PlayAnimate(ColorMap,           SlowyTween, { BackgroundTransparency = 1 })
            NeverLose.PlayAnimate(UIStroke_3,         SlowyTween, { Transparency = 1 })
            NeverLose.PlayAnimate(RGBLabel,           SlowyTween, { BackgroundTransparency = 1, TextTransparency = 1 })
            Shadow:Render(false)
        end
    end

    ColorPickerLib.SetRender(false)
    ColorPickerLib.Root     = ColorPickerHandler
    ColorPickerLib.H        = 1
    ColorPickerLib.S        = 1
    ColorPickerLib.V        = 1
    ColorPickerLib.Callback = EmptyFunction
    ColorPickerLib.IsHold   = false

    function ColorPickerLib:Update()
        local color = Color3.fromHSV(self.H, self.S, self.V)
        NeverLose.PlayAnimate(ColorZoneSelection, ManualTween, { Position = UDim2.fromScale(self.S, 1 - self.V) })
        NeverLose.PlayAnimate(SaViMap,            ManualTween, { BackgroundColor3 = Color3.fromHSV(self.H, 1, 1) })
        NeverLose.PlayAnimate(ColorMapSelection,  ManualTween, { Position = UDim2.fromScale(self.H, 0.5) })
        RGBLabel.Text = "#" .. color:ToHex()
        self.Callback(color)
    end

    function ColorPickerLib:SetValue(Color)
        if typeof(Color) == 'string' then Color = Color3.fromHex(Color) end
        self.H, self.S, self.V = Color:ToHSV()
        self:Update()
    end

    NeverLose:AddSignal(ColorPickerHandler.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            ColorPickerLib.IsHold = true
        end
    end))
    NeverLose:AddSignal(ColorPickerHandler.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            ColorPickerLib.IsHold = false
        end
    end))
    NeverLose:AddSignal(ColorMap.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            ColorPickerLib.IsHold = true
            while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or ColorPickerLib.IsHold do
                task.wait()
                local y0  = ColorMap.AbsolutePosition.X
                local y1  = y0 + ColorMap.AbsoluteSize.X
                ColorPickerLib.H = (math.clamp(Mouse.X, y0, y1) - y0) / (y1 - y0)
                ColorPickerLib:Update()
            end
        end
    end))
    NeverLose:AddSignal(SaViMap.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            ColorPickerLib.IsHold = true
            while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or ColorPickerLib.IsHold do
                task.wait()
                local px = SaViMap.AbsolutePosition.X
                local sx = px + SaViMap.AbsoluteSize.X
                local py = SaViMap.AbsolutePosition.Y
                local sy = py + SaViMap.AbsoluteSize.Y
                ColorPickerLib.S = (math.clamp(Mouse.X, px, sx) - px) / (sx - px)
                ColorPickerLib.V = 1 - (math.clamp(Mouse.Y, py, sy) - py) / (sy - py)
                ColorPickerLib:Update()
            end
        end
    end))

    return ColorPickerLib
end

NeverLose.KeyEnum = {
    One = '1', Two = '2', Three = '3', Four = '4', Five = '5',
    Six = '6', Seven = '7', Eight = '8', Nine = '9', Zero = '0',
    Minus = "-", Plus = "+", BackSlash = "\\", Slash = "/",
    Period = '.', Semicolon = ';', Colon = ":",
    LeftControl = "LCtrl", RightControl = "RCtrl",
    LeftShift = "LShift", RightShift = "RShift",
    Return = "Enter", LeftBracket = "[", RightBracket = "]",
    Quote = "'", Comma = ",", Equals = "=",
    LeftSuper = "Super", RightSuper = "Super",
    LeftAlt = "LAlt", RightAlt = "RAlt", Escape = "Esc",
}
NeverLose.EnumReverse = {}
for i, v in next, NeverLose.KeyEnum do NeverLose.EnumReverse[v] = i end

function NeverLose:KeyCodeToStr(K)
    if typeof(K) == 'string' then return NeverLose.KeyEnum[K] or K end
    return NeverLose.KeyEnum[K.Name] or K.Name
end

function NeverLose:StrToKeyCode(str)
    if NeverLose.EnumReverse[str] then return Enum.KeyCode[NeverLose.EnumReverse[str]] end
    return Enum.KeyCode[str]
end

function NeverLose:RegisiterHandler(Handler, Signal)
    local handle  = {}
    local ZINdex  = Handler.ZIndex

    function handle:AddToggle(Config)
        Config = NeverLose:ProcessParams(Config, { Default = false, Flag = nil, Callback = EmptyFunction })
        local Toggle    = Instance.new("Frame")
        local UICorner  = Instance.new("UICorner")
        local Circle    = Instance.new("Frame")
        local UICorner2 = Instance.new("UICorner")

        Toggle.Name                  = NeverLose.RandomString()
        Toggle.Parent                = Handler
        Toggle.BackgroundColor3      = Color3.fromRGB(10, 13, 21)
        Toggle.BorderSizePixel       = 0
        Toggle.ClipsDescendants      = true
        Toggle.Size                  = UDim2.new(0, 30, 0, 18)
        Toggle.ZIndex                = ZINdex + 13
        Toggle.LayoutOrder           = -(#Handler:GetChildren() + 5)
        UICorner.CornerRadius        = UDim.new(1, 0)
        UICorner.Parent              = Toggle

        Circle.Name                  = NeverLose.RandomString()
        Circle.Parent                = Toggle
        Circle.AnchorPoint           = Vector2.new(0.5, 0.5)
        Circle.BackgroundColor3      = Color3.fromRGB(255, 255, 255)
        Circle.BackgroundTransparency = 0.5
        Circle.BorderSizePixel       = 0
        Circle.Position              = UDim2.new(0.3, 0, 0.5, 0)
        Circle.Size                  = UDim2.new(0, 16, 0, 16)
        Circle.ZIndex                = ZINdex + 14
        UICorner2.CornerRadius       = UDim.new(1, 0)
        UICorner2.Parent             = Circle

        local ToggleLib = { Root = Toggle }

        ToggleLib.SetUI = function(value)
            if value then
                NeverLose.PlayAnimate(Toggle, SlowyTween, { BackgroundTransparency = 0, BackgroundColor3 = NeverLose.AccentColor })
                NeverLose.PlayAnimate(Circle, SlowyTween, { BackgroundColor3 = Color3.fromRGB(255,255,255), BackgroundTransparency = 0, Position = UDim2.new(0.7, 0, 0.5, 0) })
            else
                NeverLose.PlayAnimate(Toggle, SlowyTween, { BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(10,13,21) })
                NeverLose.PlayAnimate(Circle, SlowyTween, { BackgroundColor3 = Color3.fromRGB(255,255,255), BackgroundTransparency = 0.5, Position = UDim2.new(0.3, 0, 0.5, 0) })
            end
        end
        ToggleLib.SetVisible = function(value)
            if value then
                ToggleLib.SetUI(Config.Default)
            else
                NeverLose.PlayAnimate(Toggle, SlowyTween, { BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(10,13,21) })
                NeverLose.PlayAnimate(Circle, SlowyTween, { BackgroundColor3 = Color3.fromRGB(255,255,255), BackgroundTransparency = 1, Position = UDim2.new(0.3, 0, 0.5, 0) })
            end
        end
        ToggleLib.SetUI(Config.Default)
        ToggleLib.SetVisible(Signal:GetValue())
        NeverLose:CreateInput(Toggle, function()
            Config.Default = not Config.Default
            ToggleLib.SetUI(Config.Default)
            Config.Callback(Config.Default)
        end)
        ToggleLib.Signal = Signal:Connect(ToggleLib.SetVisible)
        function ToggleLib:GetValue() return Config.Default end
        function ToggleLib:SetValue(v)
            Config.Default = v
            if Signal:GetValue() then ToggleLib.SetUI(Config.Default) end
            Config.Callback(Config.Default)
        end
        if Config.Flag then NeverLose.Flags[Config.Flag] = ToggleLib end
        return ToggleLib
    end

    function handle:AddSlider(Config)
        Config = NeverLose:ProcessParams(Config, {
            Default = 50, Min = 0, Max = 10, Type = "", Rounding = 0,
            Nums = {}, Flag = nil, Size = 125, Callback = EmptyFunction,
        })
        local SliderLib = {}
        SliderLib.GetSize = function()
            return (Config.Default - Config.Min) / (Config.Max - Config.Min)
        end
        local FullNumSize = TextService:GetTextSize(
            string.rep("0", Config.Rounding + #tostring(Config.Max) + 1) .. tostring(Config.Type),
            10, Enum.Font.GothamMedium, Vector2.new(math.huge, math.huge))
        SliderLib.MaximumSize = FullNumSize.X
        if Config.Nums then
            local nszie = 0
            for _, ns in next, Config.Nums do
                local sz = TextService:GetTextSize(string.rep("m", #tostring(ns)), 10, Enum.Font.GothamMedium, Vector2.new(math.huge, math.huge))
                if nszie < sz.X then nszie = sz.X end
            end
            if SliderLib.MaximumSize < nszie then SliderLib.MaximumSize = nszie end
        end
        local boxSize = 2
        local Slider       = Instance.new("Frame")
        local UICorner     = Instance.new("UICorner")
        local ValueFrame   = Instance.new("Frame")
        local UICorner2    = Instance.new("UICorner")
        local UIStroke     = Instance.new("UIStroke")
        local ValueLabel   = Instance.new("TextBox")
        local SlideMain    = Instance.new("Frame")
        local SlideFrame   = Instance.new("Frame")
        local UICorner3    = Instance.new("UICorner")
        local SlideMoving  = Instance.new("Frame")
        local UICorner4    = Instance.new("UICorner")
        local Thumb        = Instance.new("Frame")
        local UICorner5    = Instance.new("UICorner")

        Slider.Name                  = NeverLose.RandomString()
        Slider.Parent                = Handler
        Slider.BackgroundColor3      = Color3.fromRGB(26, 28, 36)
        Slider.BackgroundTransparency = 1
        Slider.BorderSizePixel       = 0
        Slider.Size                  = UDim2.new(0, Config.Size, 0, 18)
        Slider.ZIndex                = ZINdex + 13
        Slider.LayoutOrder           = -(#Handler:GetChildren() + 5)
        UICorner.CornerRadius        = UDim.new(0, 4)
        UICorner.Parent              = Slider

        ValueFrame.Name                  = NeverLose.RandomString()
        ValueFrame.Parent                = Slider
        ValueFrame.AnchorPoint           = Vector2.new(1, 0)
        ValueFrame.BackgroundColor3      = Color3.fromRGB(26, 28, 36)
        ValueFrame.BorderSizePixel       = 0
        ValueFrame.ClipsDescendants      = true
        ValueFrame.Position              = UDim2.new(1, 0, 0, 0)
        ValueFrame.Size                  = UDim2.new(0, SliderLib.MaximumSize + boxSize, 0, 18)
        ValueFrame.ZIndex                = ZINdex + 13
        UICorner2.CornerRadius           = UDim.new(0, 4)
        UICorner2.Parent                 = ValueFrame
        UIStroke.Transparency            = 0.65
        UIStroke.Color                   = Color3.fromRGB(45, 48, 58)
        UIStroke.Parent                  = ValueFrame

        ValueLabel.Name                  = NeverLose.RandomString()
        ValueLabel.Parent                = ValueFrame
        ValueLabel.AnchorPoint           = Vector2.new(0.5, 0.5)
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.BorderSizePixel       = 0
        ValueLabel.Position              = UDim2.new(0.5, 0, 0.5, 0)
        ValueLabel.Size                  = UDim2.new(1, 0, 1, 0)
        ValueLabel.ZIndex                = ZINdex + 14
        ValueLabel.Font                  = Enum.Font.GothamMedium
        ValueLabel.Text                  = tostring(Config.Default) .. tostring(Config.Type)
        ValueLabel.TextColor3            = Color3.fromRGB(255, 255, 255)
        ValueLabel.TextSize              = 10
        ValueLabel.ClearTextOnFocus      = false
        ValueLabel.TextTransparency      = 0.35

        SlideMain.Name                   = NeverLose.RandomString()
        SlideMain.Parent                 = Slider
        SlideMain.AnchorPoint            = Vector2.new(0, 0.5)
        SlideMain.BackgroundTransparency = 1
        SlideMain.BorderSizePixel        = 0
        SlideMain.Position               = UDim2.new(0, 0, 0.5, 0)
        SlideMain.Size                   = UDim2.new(1, -(SliderLib.MaximumSize + 11), 0, 18)
        SlideMain.ZIndex                 = ZINdex + 13

        SlideFrame.Name                  = NeverLose.RandomString()
        SlideFrame.Parent                = SlideMain
        SlideFrame.AnchorPoint           = Vector2.new(0, 0.5)
        SlideFrame.BackgroundColor3      = Color3.fromRGB(30, 29, 36)
        SlideFrame.BorderSizePixel       = 0
        SlideFrame.Position              = UDim2.new(0, 0, 0.5, 0)
        SlideFrame.Size                  = UDim2.new(1, 0, 0, 5)
        SlideFrame.ZIndex                = ZINdex + 13
        UICorner3.CornerRadius           = UDim.new(1, 0)
        UICorner3.Parent                 = SlideFrame

        SlideMoving.Name                 = NeverLose.RandomString()
        SlideMoving.Parent               = SlideFrame
        SlideMoving.BackgroundColor3     = NeverLose.AccentColor
        SlideMoving.BorderSizePixel      = 0
        SlideMoving.Size                 = UDim2.new(SliderLib.GetSize(), 0, 1, 0)
        SlideMoving.ZIndex               = ZINdex + 14
        UICorner4.CornerRadius           = UDim.new(1, 0)
        UICorner4.Parent                 = SlideMoving

        Thumb.Parent                     = SlideMoving
        Thumb.AnchorPoint                = Vector2.new(1, 0.5)
        Thumb.BackgroundColor3           = Color3.fromRGB(255, 255, 255)
        Thumb.BorderSizePixel            = 0
        Thumb.Position                   = UDim2.new(1, 5, 0.5, 0)
        Thumb.Size                       = UDim2.new(0, 10, 0, 10)
        Thumb.ZIndex                     = ZINdex + 15
        UICorner5.CornerRadius           = UDim.new(1, 0)
        UICorner5.Parent                 = Thumb

        local function LoadText()
            ValueLabel.Text = Config.Nums[Config.Default]
                or tostring(Config.Default) .. tostring(Config.Type)
        end

        ValueLabel.FocusLost:Connect(function()
            local out = NeverLose:ParseInput(ValueLabel.Text, true)
            if out then
                local value = NeverLose.Rounding(math.clamp(out, Config.Min, Config.Max), Config.Rounding)
                if value then
                    Config.Default = value
                    TweenService:Create(SlideMoving, ManualTween, { Size = UDim2.new(SliderLib.GetSize(), 0, 1, 0) }):Play()
                    LoadText()
                    Config.Callback(Config.Default)
                    return
                end
            end
            LoadText()
        end)

        SliderLib.SetRender = function(value)
            if value then
                NeverLose.PlayAnimate(ValueFrame,  SlowyTween, { BackgroundTransparency = 0, Size = UDim2.new(0, SliderLib.MaximumSize + boxSize, 0, 18) })
                NeverLose.PlayAnimate(UIStroke,    SlowyTween, { Transparency = 0.65 })
                NeverLose.PlayAnimate(ValueLabel,  SlowyTween, { TextTransparency = 0.35 })
                NeverLose.PlayAnimate(SlideFrame,  SlowyTween, { BackgroundTransparency = 0 })
                NeverLose.PlayAnimate(SlideMoving, SlowyTween, { BackgroundTransparency = 0, Size = UDim2.new(SliderLib.GetSize(), 0, 1, 0) })
                NeverLose.PlayAnimate(Thumb,       SlowyTween, { BackgroundTransparency = 0 })
            else
                NeverLose.PlayAnimate(ValueFrame,  SlowyTween, { BackgroundTransparency = 1 })
                NeverLose.PlayAnimate(UIStroke,    SlowyTween, { Transparency = 1 })
                NeverLose.PlayAnimate(ValueLabel,  SlowyTween, { TextTransparency = 1 })
                NeverLose.PlayAnimate(SlideFrame,  SlowyTween, { BackgroundTransparency = 1 })
                NeverLose.PlayAnimate(SlideMoving, SlowyTween, { BackgroundTransparency = 1, Size = UDim2.new(0, 0, 1, 0) })
                NeverLose.PlayAnimate(Thumb,       SlowyTween, { BackgroundTransparency = 1 })
            end
        end
        SliderLib.SetRender(Signal:GetValue())
        SliderLib.Signal = Signal:Connect(SliderLib.SetRender)

        local IsHold = false
        local function Update(Input)
            local scale = math.clamp((Input.Position.X - SlideMain.AbsolutePosition.X) / SlideMain.AbsoluteSize.X, 0, 1)
            Config.Default = NeverLose.Rounding(((Config.Max - Config.Min) * scale) + Config.Min, Config.Rounding)
            TweenService:Create(SlideMoving, ManualTween, { Size = UDim2.new(SliderLib.GetSize(), 0, 1, 0) }):Play()
            LoadText()
            Config.Callback(Config.Default)
        end

        SlideMain.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                IsHold = true
                Update(Input)
            end
        end)
        SlideMain.InputEnded:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                if not (UserInputService.TouchEnabled and NeverLose:IsMouseOverFrame(nil, SlideMain)) then
                    IsHold = false
                end
            end
        end)
        UserInputService.InputChanged:Connect(function(Input)
            if IsHold and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                if UserInputService.TouchEnabled and not NeverLose:IsMouseOverFrame(nil, SlideMain) then
                    IsHold = false
                else
                    Update(Input)
                end
            end
        end)

        function SliderLib:GetValue() return Config.Default end
        function SliderLib:SetValue(v)
            Config.Default = v
            if Signal:GetValue() then
                NeverLose.PlayAnimate(SlideMoving, SlowyTween, { BackgroundTransparency = 0, Size = UDim2.new(SliderLib.GetSize(), 0, 1, 0) })
            end
            LoadText()
            Config.Callback(Config.Default)
        end
        if Config.Flag then NeverLose.Flags[Config.Flag] = SliderLib end
        return SliderLib
    end

    function handle:AddOption(GearIcon)
        local Option   = Instance.new("Frame")
        local Icon     = Instance.new("TextLabel")
        local UICorner = Instance.new("UICorner")

        Option.Name                  = NeverLose.RandomString()
        Option.Parent                = Handler
        Option.BackgroundColor3      = Color3.fromRGB(39, 40, 49)
        Option.BackgroundTransparency = 1
        Option.BorderSizePixel       = 0
        Option.ClipsDescendants      = true
        Option.Size                  = UDim2.new(0, 20, 0, 18)
        Option.ZIndex                = ZINdex + 13
        Option.LayoutOrder           = -(#Handler:GetChildren() + 5)

        Icon.Name                  = NeverLose.RandomString()
        Icon.Parent                = Option
        Icon.AnchorPoint           = Vector2.new(0.5, 0.5)
        Icon.BackgroundTransparency = 1
        Icon.BorderSizePixel       = 0
        Icon.Position              = UDim2.new(0.5, 0, 0.5, 0)
        Icon.Size                  = UDim2.new(1, 0, 1, 0)
        Icon.ZIndex                = ZINdex + 14
        Icon.FontFace              = NeverLose.BuiltInBold
        Icon.Text                  = (GearIcon == 1 and 'gear') or (GearIcon == 2 and 'chevron-large-right') or "three-dots-horizontal"
        Icon.TextColor3            = Color3.fromRGB(223, 223, 223)
        Icon.TextSize              = 16
        Icon.TextTransparency      = 0.4
        Icon.TextWrapped           = true
        UICorner.CornerRadius      = UDim.new(0, 4)
        UICorner.Parent            = Option

        local Window       = NeverLose:CreateOptionWindow(Option, ZINdex + 13)
        local reciveSignal

        Window.SetRender = function(value)
            NeverLose.PlayAnimate(Icon, SlowyTween, { TextTransparency = value and 0.4 or 1 })
        end
        Window.SetRender(Signal:GetValue())
        Signal:Connect(Window.SetRender)

        local bthg = NeverLose:CreateInput(Option, function()
            if reciveSignal then reciveSignal:Disconnect() reciveSignal = nil end
            Window.Signal:SetValue(true)
            reciveSignal = UserInputService.InputBegan:Connect(function(Input)
                if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch)
                and not NeverLose:IsMouseOverFrame(nil, Window.Root) and not NeverLose:IsMouseOverFrame(nil, Option) then
                    if reciveSignal then reciveSignal:Disconnect() reciveSignal = nil end
                    Window.Signal:SetValue(false)
                end
            end)
        end)

        NeverLose:AddSignal(bthg.MouseEnter:Connect(function()
            NeverLose.PlayAnimate(Option, SlowyTween, { BackgroundTransparency = 0.5 })
            NeverLose.PlayAnimate(Icon,   SlowyTween, { TextTransparency = 0.25 })
        end))
        NeverLose:AddSignal(bthg.MouseLeave:Connect(function()
            NeverLose.PlayAnimate(Option, SlowyTween, { BackgroundTransparency = 1 })
            NeverLose.PlayAnimate(Icon,   SlowyTween, { TextTransparency = 0.4 })
        end))
        return Window
    end

    function handle:AddColorPicker(Config)
        Config = NeverLose:ProcessParams(Config, { Default = Color3.fromRGB(255,255,255), Callback = EmptyFunction })
        if typeof(Config.Default) == 'string' then
            Config.Default = Color3.fromHex(Config.Default:gsub('#', ''))
        end
        local ColorPickerLib = {}
        local ColorPicker    = Instance.new("Frame")
        local UICorner       = Instance.new("UICorner")
        local UIStroke       = Instance.new("UIStroke")
        local ImageLabel     = Instance.new("ImageLabel")
        local UICorner2      = Instance.new("UICorner")

        ColorPicker.Name                  = NeverLose.RandomString()
        ColorPicker.Parent                = Handler
        ColorPicker.BackgroundColor3      = Config.Default
        ColorPicker.BorderSizePixel       = 0
        ColorPicker.ClipsDescendants      = true
        ColorPicker.Size                  = UDim2.new(0, 18, 0, 18)
        ColorPicker.ZIndex                = ZINdex + 13
        UICorner.CornerRadius             = UDim.new(0, 4)
        UICorner.Parent                   = ColorPicker
        UIStroke.Transparency             = 0.65
        UIStroke.Color                    = Color3.fromRGB(45, 48, 58)
        UIStroke.Parent                   = ColorPicker

        ImageLabel.Parent                 = ColorPicker
        ImageLabel.BackgroundTransparency = 1
        ImageLabel.BorderSizePixel        = 0
        ImageLabel.Size                   = UDim2.new(1, 0, 1, 0)
        ImageLabel.ZIndex                 = ZINdex + 11
        ImageLabel.Image                  = "rbxasset://textures/meshPartFallback.png"
        ImageLabel.ImageTransparency      = 0.9
        ImageLabel.ScaleType              = Enum.ScaleType.Crop
        UICorner2.CornerRadius            = UDim.new(0, 4)
        UICorner2.Parent                  = ImageLabel

        local BackendM = NeverLose:CreateColorPicker(ColorPicker)
        BackendM:SetValue(Config.Default)
        BackendM.Callback = function(color)
            ColorPicker.BackgroundColor3 = color
            Config.Default = color
            Config.Callback(color)
        end

        local signal
        NeverLose:CreateInput(ColorPicker, function()
            if signal then signal:Disconnect() signal = nil end
            BackendM.SetRender(true)
            signal = UserInputService.InputBegan:Connect(function(Input)
                if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch)
                and not NeverLose:IsMouseOverFrame(nil, ColorPicker) and not NeverLose:IsMouseOverFrame(nil, BackendM.Root) then
                    if signal then signal:Disconnect() signal = nil end
                    BackendM.SetRender(false)
                end
            end)
        end)

        ColorPickerLib.SetRender = function(value)
            local t = value and 0 or 1
            NeverLose.PlayAnimate(ColorPicker, SlowyTween, { BackgroundTransparency = t })
            NeverLose.PlayAnimate(UIStroke,    SlowyTween, { Transparency = value and 0.65 or 1 })
            NeverLose.PlayAnimate(ImageLabel,  SlowyTween, { ImageTransparency = value and 0.9 or 1 })
        end
        ColorPickerLib.SetRender(Signal:GetValue())
        Signal:Connect(ColorPickerLib.SetRender)
        function ColorPickerLib:GetValue() return Config.Default end
        function ColorPickerLib:SetValue(v) Config.Default = v BackendM:SetValue(v) end
        if Config.Flag then NeverLose.Flags[Config.Flag] = ColorPickerLib end
        return ColorPickerLib
    end

    function handle:AddKeybind(Config)
        Config = NeverLose:ProcessParams(Config, { Default = nil, Blacklist = {}, Callback = EmptyFunction, Flag = nil })
        local KeybindLib = {}
        local Keybind    = Instance.new("Frame")
        local UICorner   = Instance.new("UICorner")
        local UIStroke   = Instance.new("UIStroke")
        local ValueLabel = Instance.new("TextLabel")

        Keybind.Name                  = NeverLose.RandomString()
        Keybind.Parent                = Handler
        Keybind.BackgroundColor3      = Color3.fromRGB(26, 28, 36)
        Keybind.BorderSizePixel       = 0
        Keybind.ClipsDescendants      = true
        Keybind.Size                  = UDim2.new(0, 45, 0, 18)
        Keybind.ZIndex                = ZINdex + 13
        UICorner.CornerRadius         = UDim.new(0, 4)
        UICorner.Parent               = Keybind
        UIStroke.Transparency         = 0.65
        UIStroke.Color                = Color3.fromRGB(45, 48, 58)
        UIStroke.Parent               = Keybind

        ValueLabel.Name               = NeverLose.RandomString()
        ValueLabel.Parent             = Keybind
        ValueLabel.AnchorPoint        = Vector2.new(0.5, 0.5)
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.BorderSizePixel    = 0
        ValueLabel.ClipsDescendants   = true
        ValueLabel.Position           = UDim2.new(0.5, 0, 0.5, 0)
        ValueLabel.Size               = UDim2.new(1, 0, 1, 0)
        ValueLabel.ZIndex             = ZINdex + 14
        ValueLabel.Font               = Enum.Font.GothamMedium
        ValueLabel.Text               = NeverLose:KeyCodeToStr(Config.Default or "None")
        ValueLabel.TextColor3         = Color3.fromRGB(255, 255, 255)
        ValueLabel.TextSize           = 10
        ValueLabel.TextTransparency   = 0.5

        KeybindLib.SetRender = function(value)
            NeverLose.PlayAnimate(Keybind,     SlowyTween, { BackgroundTransparency = value and 0 or 1 })
            NeverLose.PlayAnimate(UIStroke,    SlowyTween, { Transparency = value and 0.65 or 1 })
            NeverLose.PlayAnimate(ValueLabel,  SlowyTween, { TextTransparency = value and 0.5 or 1 })
        end
        function KeybindLib:Update()
            local size = TextService:GetTextSize(ValueLabel.Text, ValueLabel.TextSize, ValueLabel.Font, Vector2.new(math.huge, math.huge))
            NeverLose.PlayAnimate(Keybind, SlowyTween, { Size = UDim2.new(0, size.X + 7, 0, 18) })
        end

        local function IsBlacklist(v)
            return Config.Blacklist and (Config.Blacklist[v] or table.find(Config.Blacklist, v))
        end
        KeybindLib:Update()
        KeybindLib.SetRender(Signal:GetValue())
        Signal:Connect(KeybindLib.SetRender)

        local IsBinding = false
        NeverLose:CreateInput(Keybind, function()
            if IsBinding then return end
            IsBinding = true
            ValueLabel.Text = "..."
            KeybindLib:Update()
            local Selected
            while not Selected do
                local Key = UserInputService.InputBegan:Wait()
                if Key.KeyCode ~= Enum.KeyCode.Unknown and not IsBlacklist(Key.KeyCode) and not IsBlacklist(Key.KeyCode.Name) then
                    Selected = Key.KeyCode
                elseif Key.UserInputType == Enum.UserInputType.MouseButton1 and not IsBlacklist(Enum.UserInputType.MouseButton1) and not IsBlacklist("M1B") then
                    Selected = "M1B"
                elseif Key.UserInputType == Enum.UserInputType.MouseButton2 and not IsBlacklist(Enum.UserInputType.MouseButton2) and not IsBlacklist("M2B") then
                    Selected = "M2B"
                end
            end
            IsBinding = false
            local KeyName = typeof(Selected) == "string" and Selected or Selected.Name
            Config.Default = KeyName
            ValueLabel.Text = NeverLose:KeyCodeToStr(KeyName)
            KeybindLib:Update()
            Config.Callback(KeyName)
        end)

        function KeybindLib:GetValue() return Config.Default end
        function KeybindLib:SetValue(v)
            Config.Default = v
            ValueLabel.Text = NeverLose:KeyCodeToStr(v)
            self:Update()
            Config.Callback(Config.Default)
        end
        if Config.Flag then NeverLose.Flags[Config.Flag] = KeybindLib end
        return KeybindLib
    end

    function handle:AddTextInput(Config)
        Config = NeverLose:ProcessParams(Config, {
            Default = "", Placeholder = "Placeholder", Callback = print,
            Flag = nil, Size = 100, Numeric = false,
        })
        local TextBoxLib = {}
        local TextInput  = Instance.new("Frame")
        local UICorner   = Instance.new("UICorner")
        local UIStroke   = Instance.new("UIStroke")
        local TextBox    = Instance.new("TextBox")

        TextInput.Name                  = NeverLose.RandomString()
        TextInput.Parent                = Handler
        TextInput.BackgroundColor3      = Color3.fromRGB(26, 28, 36)
        TextInput.BorderSizePixel       = 0
        TextInput.ClipsDescendants      = true
        TextInput.Size                  = UDim2.new(0, Config.Size, 0, 18)
        TextInput.ZIndex                = ZINdex + 13
        UICorner.CornerRadius           = UDim.new(0, 4)
        UICorner.Parent                 = TextInput
        UIStroke.Transparency           = 0.65
        UIStroke.Color                  = Color3.fromRGB(45, 48, 58)
        UIStroke.Parent                 = TextInput

        TextBox.Parent                  = TextInput
        TextBox.AnchorPoint             = Vector2.new(0, 0.5)
        TextBox.BackgroundTransparency  = 1
        TextBox.BorderSizePixel         = 0
        TextBox.Position                = UDim2.new(0, 5, 0.5, 0)
        TextBox.Size                    = UDim2.new(1, -5, 0, 17)
        TextBox.ZIndex                  = ZINdex + 14
        TextBox.ClearTextOnFocus        = false
        TextBox.Font                    = Enum.Font.GothamMedium
        TextBox.PlaceholderText         = Config.Placeholder
        TextBox.Text                    = tostring(Config.Default)
        TextBox.TextColor3              = Color3.fromRGB(255, 255, 255)
        TextBox.TextSize                = 11
        TextBox.TextTransparency        = 0.35
        TextBox.TextXAlignment          = Enum.TextXAlignment.Left

        TextBoxLib.SetRender = function(value)
            NeverLose.PlayAnimate(TextInput, SlowyTween, { BackgroundTransparency = value and 0 or 1 })
            NeverLose.PlayAnimate(UIStroke,  SlowyTween, { Transparency = value and 0.65 or 1 })
            NeverLose.PlayAnimate(TextBox,   SlowyTween, { TextTransparency = value and 0.35 or 1 })
        end

        NeverLose:AddSignal(TextBox:GetPropertyChangedSignal('Text'):Connect(function()
            if Config.Numeric then TextBox.Text = string.gsub(TextBox.Text, '[^0-9.]', '') end
            local out = NeverLose:ParseInput(TextBox.Text, Config.Numeric)
            if out then Config.Default = out Config.Callback(out) end
        end))
        TextBoxLib.SetRender(Signal:GetValue())
        Signal:Connect(TextBoxLib.SetRender)
        function TextBoxLib:GetValue() return Config.Default end
        function TextBoxLib:SetValue(v) Config.Default = v TextBox.Text = tostring(v) Config.Callback(v) end
        if Config.Flag then NeverLose.Flags[Config.Flag] = TextBoxLib end
        return TextBoxLib
    end

    function handle:AddDropdown(Config)
        Config = NeverLose:ProcessParams(Config, {
            Default = nil, Values = {}, Multi = false, Callback = EmptyFunction,
            AutoUpdate = false, Flag = nil, Size = 100,
        })
        Config.Default = NeverLose.ProcessDropdown(Config.Default)

        local Dropdown      = Instance.new("Frame")
        local DropdownIcon  = Instance.new("TextLabel")
        local UICorner      = Instance.new("UICorner")
        local UIStroke      = Instance.new("UIStroke")
        local BasedLabel    = Instance.new("TextLabel")

        Dropdown.Name                  = NeverLose.RandomString()
        Dropdown.Parent                = Handler
        Dropdown.BackgroundColor3      = Color3.fromRGB(26, 28, 36)
        Dropdown.BorderSizePixel       = 0
        Dropdown.ClipsDescendants      = true
        Dropdown.Size                  = UDim2.new(0, Config.Size, 0, 18)
        Dropdown.ZIndex                = ZINdex + 13

        DropdownIcon.Name              = NeverLose.RandomString()
        DropdownIcon.Parent            = Dropdown
        DropdownIcon.AnchorPoint       = Vector2.new(1, 0.5)
        DropdownIcon.BackgroundTransparency = 1
        DropdownIcon.BorderSizePixel   = 0
        DropdownIcon.Position          = UDim2.new(1, -2, 0.5, 0)
        DropdownIcon.Size              = UDim2.new(0, 18, 0, 18)
        DropdownIcon.ZIndex            = ZINdex + 14
        DropdownIcon.FontFace          = NeverLose.BuiltInBold
        DropdownIcon.Text              = "chevron-small-down"
        DropdownIcon.TextColor3        = Color3.fromRGB(223, 223, 223)
        DropdownIcon.TextSize          = 16
        DropdownIcon.TextTransparency  = 0.25
        DropdownIcon.TextWrapped       = true
        UICorner.CornerRadius          = UDim.new(0, 4)
        UICorner.Parent                = Dropdown
        UIStroke.Transparency          = 0.65
        UIStroke.Color                 = Color3.fromRGB(45, 48, 58)
        UIStroke.Parent                = Dropdown

        BasedLabel.Name                = NeverLose.RandomString()
        BasedLabel.Parent              = Dropdown
        BasedLabel.AnchorPoint         = Vector2.new(0, 0.5)
        BasedLabel.BackgroundTransparency = 1
        BasedLabel.BorderSizePixel     = 0
        BasedLabel.ClipsDescendants    = true
        BasedLabel.Position            = UDim2.new(0, 5, 0.5, 0)
        BasedLabel.Size                = UDim2.new(1, -25, 0, 15)
        BasedLabel.ZIndex              = ZINdex + 14
        BasedLabel.Font                = Enum.Font.GothamMedium
        BasedLabel.Text                = NeverLose.ParseDropdown(Config.Default)
        BasedLabel.TextColor3          = Color3.fromRGB(255, 255, 255)
        BasedLabel.TextSize            = 12
        BasedLabel.TextTransparency    = 0.5
        BasedLabel.TextXAlignment      = Enum.TextXAlignment.Left
        do
            local UIGradient = Instance.new("UIGradient")
            UIGradient.Transparency = NumberSequence.new{
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(0.85, 0.23),
                NumberSequenceKeypoint.new(1, 1),
            }
            UIGradient.Parent = BasedLabel
        end

        NeverLose:AddSignal(Dropdown.MouseEnter:Connect(function()
            NeverLose.PlayAnimate(BasedLabel, SlowyTween, { TextTransparency = 0.2 })
        end))
        NeverLose:AddSignal(Dropdown.MouseLeave:Connect(function()
            NeverLose.PlayAnimate(BasedLabel, SlowyTween, { TextTransparency = 0.5 })
        end))

        local DropdownLib = { OpenSignal = NeverLose:CreateSignal(false), Signals = {}, Refuse = {} }

        DropdownLib.SetRender = function(value)
            NeverLose.PlayAnimate(Dropdown,      SlowyTween, { BackgroundTransparency = value and 0 or 1 })
            NeverLose.PlayAnimate(DropdownIcon,  SlowyTween, { TextTransparency = value and 0.25 or 1 })
            NeverLose.PlayAnimate(UIStroke,      SlowyTween, { Transparency = value and 0.65 or 1 })
            NeverLose.PlayAnimate(BasedLabel,    SlowyTween, { TextTransparency = value and 0.5 or 1 })
        end
        DropdownLib.SetRender(Signal:GetValue())
        Signal:Connect(DropdownLib.SetRender)
        DropdownLib.ExtentSize = 0

        do
            local DropdownHandler    = Instance.new("Frame")
            local UICorner2          = Instance.new("UICorner")
            local UIStroke2          = Instance.new("UIStroke")
            local DropdownScrollFrame = Instance.new("ScrollingFrame")
            local UIListLayout       = Instance.new("UIListLayout")
            local Shadow             = NeverLose:CreateShadow(DropdownHandler)

            DropdownHandler.Name                  = NeverLose.RandomString()
            DropdownHandler.Parent                = NeverLose.ScreenGui
            DropdownHandler.AnchorPoint           = Vector2.new(0.5, 0)
            DropdownHandler.BackgroundColor3      = Color3.fromRGB(20, 22, 27)
            DropdownHandler.BackgroundTransparency = 0.5
            DropdownHandler.BorderSizePixel       = 0
            DropdownHandler.ClipsDescendants      = true
            DropdownHandler.Position              = UDim2.new(255,255,255,255)
            DropdownHandler.Size                  = UDim2.new(0, 125, 0, 50)
            DropdownHandler.ZIndex                = ZINdex + 125
            DropdownLib.BlockRoot                 = DropdownHandler

            NeverLose:AddSignal(DropdownHandler:GetPropertyChangedSignal('BackgroundTransparency'):Connect(function()
                if DropdownHandler.BackgroundTransparency > 0.9 then
                    DropdownHandler.Visible = false
                    DropdownHandler.Parent  = nil
                else
                    DropdownHandler.Visible = true
                    DropdownHandler.Parent  = NeverLose.ScreenGui
                end
            end))

            UICorner2.CornerRadius    = UDim.new(0, 10)
            UICorner2.Parent          = DropdownHandler
            UIStroke2.Transparency    = 0.65
            UIStroke2.Color           = Color3.fromRGB(45, 48, 58)
            UIStroke2.Parent          = DropdownHandler

            DropdownScrollFrame.Name               = NeverLose.RandomString()
            DropdownScrollFrame.Parent             = DropdownHandler
            DropdownScrollFrame.Active             = true
            DropdownScrollFrame.AnchorPoint        = Vector2.new(0.5, 0.5)
            DropdownScrollFrame.BackgroundTransparency = 1
            DropdownScrollFrame.BorderSizePixel    = 0
            DropdownScrollFrame.Position           = UDim2.new(0.5, 0, 0.5, 0)
            DropdownScrollFrame.Size               = UDim2.new(1, -5, 1, -5)
            DropdownScrollFrame.ZIndex             = ZINdex + 127
            DropdownScrollFrame.ScrollBarThickness = 0
            DropdownLib.RootItem                   = DropdownScrollFrame

            UIListLayout.Parent             = DropdownScrollFrame
            UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            UIListLayout.SortOrder          = Enum.SortOrder.LayoutOrder

            NeverLose:AddSignal(UIListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
                DropdownScrollFrame.CanvasSize = UDim2.fromOffset(0, UIListLayout.AbsoluteContentSize.Y)
                NeverLose.PlayAnimate(DropdownHandler, SlowyTween, {
                    Size = UDim2.new(0, (Dropdown.AbsoluteSize.X + 5) + DropdownLib.ExtentSize, 0, math.min(UIListLayout.AbsoluteContentSize.Y + 5, 250))
                })
            end))

            local function SetPosition()
                DropdownHandler.AnchorPoint = NeverLose:MoreThanHalfY(Dropdown.AbsolutePosition.Y + 85)
                    and Vector2.new(0.5, 1) or Vector2.new(0.5, 0)
                DropdownHandler.Position = UDim2.fromOffset(
                    Dropdown.AbsolutePosition.X + (DropdownHandler.AbsoluteSize.X / 2),
                    Dropdown.AbsolutePosition.Y + 85)
            end

            DropdownLib.SetFrameRender = function(value)
                DropdownLib.OpenSignal:SetValue(value)
                if value then
                    Shadow:Render(true)
                    DropdownHandler.Size = UDim2.new(0, (Dropdown.AbsoluteSize.X + 5) + DropdownLib.ExtentSize, 0, math.min(UIListLayout.AbsoluteContentSize.Y + 5, 250))
                    SetPosition()
                    NeverLose.PlayAnimate(DropdownHandler, SlowyTween, { BackgroundTransparency = 0.035 })
                    if Config.AutoUpdate then DropdownLib:Generate() end
                else
                    NeverLose.PlayAnimate(DropdownHandler, SlowyTween, { BackgroundTransparency = 1 })
                    Shadow:Render(false)
                end
            end
            DropdownLib.SetFrameRender(false)
        end

        local SecureSignal
        NeverLose:CreateInput(Dropdown, function()
            if SecureSignal then SecureSignal:Disconnect() SecureSignal = nil end
            DropdownLib.SetFrameRender(true)
            NeverLose.IsMosueOverOtherFrame = true
            SecureSignal = UserInputService.InputBegan:Connect(function(Input)
                if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch)
                and not NeverLose:IsMouseOverFrame(nil, DropdownLib.BlockRoot) and not NeverLose:IsMouseOverFrame(nil, Dropdown) then
                    if SecureSignal then SecureSignal:Disconnect() SecureSignal = nil end
                    NeverLose.IsMosueOverOtherFrame = false
                    DropdownLib.SetFrameRender(false)
                end
            end)
        end)

        DropdownLib.IsMatch = function(v1)
            if typeof(Config.Default) == 'table' then
                return Config.Default[v1] or table.find(Config.Default, v1)
            end
            return Config.Default == v1
        end

        function DropdownLib:Generate()
            for _, v in next, DropdownLib.RootItem:GetChildren() do
                if v:IsA('Frame') then v:Destroy() end
            end
            for _, v in next, DropdownLib.Signals do v:Disconnect() end
            table.clear(DropdownLib.Signals)
            table.clear(DropdownLib.Refuse)

            for _, Value in next, Config.Values do
                local ItemFrame  = Instance.new("Frame")
                local ItemLabel  = Instance.new("TextLabel")
                local UICornerI  = Instance.new("UICorner")

                ItemFrame.Name                  = NeverLose.RandomString()
                ItemFrame.Parent                = DropdownLib.RootItem
                ItemFrame.BackgroundColor3      = Color3.fromRGB(29, 31, 38)
                ItemFrame.BackgroundTransparency = 1
                ItemFrame.BorderSizePixel       = 0
                ItemFrame.Size                  = UDim2.new(1, 0, 0, 25)
                ItemFrame.ZIndex                = ZINdex + 1258

                ItemLabel.Name                  = NeverLose.RandomString()
                ItemLabel.Parent                = ItemFrame
                ItemLabel.BackgroundTransparency = 1
                ItemLabel.BorderSizePixel       = 0
                ItemLabel.Position              = UDim2.new(0, 15, 0, 4)
                ItemLabel.Size                  = UDim2.new(0, 1, 0, 15)
                ItemLabel.ZIndex                = ZINdex + 1258
                ItemLabel.Font                  = Enum.Font.GothamMedium
                ItemLabel.Text                  = tostring(Value)
                ItemLabel.TextColor3            = Color3.fromRGB(255, 255, 255)
                ItemLabel.TextSize              = 13
                ItemLabel.TextTransparency      = 0.2
                ItemLabel.TextXAlignment        = Enum.TextXAlignment.Left
                UICornerI.CornerRadius          = UDim.new(0, 10)
                UICornerI.Parent                = ItemFrame

                local sizetext = TextService:GetTextSize(ItemLabel.Text, ItemLabel.TextSize, ItemLabel.Font, Vector2.new(math.huge, math.huge))
                DropdownLib.ExtentSize = math.max(DropdownLib.ExtentSize, sizetext.X)

                local MIcon, MarkItem

                if Config.Multi then
                    local Icon = Instance.new("TextLabel")
                    Icon.Parent                = ItemFrame
                    Icon.AnchorPoint           = Vector2.new(0, 0.5)
                    Icon.BackgroundTransparency = 1
                    Icon.BorderSizePixel       = 0
                    Icon.Position              = UDim2.new(0, 5, 0.5, 0)
                    Icon.Size                  = UDim2.new(0, 20, 0, 20)
                    Icon.ZIndex                = ZINdex + 1259
                    Icon.FontFace              = NeverLose.BuiltInBold
                    Icon.Text                  = "check"
                    Icon.TextColor3            = Color3.fromRGB(223, 223, 223)
                    Icon.TextSize              = 18
                    Icon.TextTransparency      = 1
                    Icon.TextWrapped           = true
                    MIcon = Icon
                    MarkItem = function()
                        if DropdownLib.IsMatch(Value) then
                            NeverLose.PlayAnimate(ItemLabel, VSlowTween, { TextTransparency = 0.2, Position = UDim2.new(0, 30, 0, 4) })
                            NeverLose.PlayAnimate(Icon,      VSlowTween, { TextTransparency = 0.25 })
                        else
                            NeverLose.PlayAnimate(Icon,      SlowyTween, { TextTransparency = 1 })
                            NeverLose.PlayAnimate(ItemLabel, VSlowTween, { TextTransparency = 0.5, Position = UDim2.new(0, 15, 0, 4) })
                        end
                    end
                else
                    MarkItem = function()
                        NeverLose.PlayAnimate(ItemLabel, SlowyTween, { TextTransparency = DropdownLib.IsMatch(Value) and 0.2 or 0.5 })
                    end
                end

                MarkItem()
                table.insert(DropdownLib.Refuse, MarkItem)

                table.insert(DropdownLib.Signals, ItemFrame.MouseEnter:Connect(function()
                    NeverLose.PlayAnimate(ItemFrame, SlowyTween, { BackgroundTransparency = 0.1 })
                end))
                table.insert(DropdownLib.Signals, ItemFrame.MouseLeave:Connect(function()
                    NeverLose.PlayAnimate(ItemFrame, SlowyTween, { BackgroundTransparency = 1 })
                end))
                table.insert(DropdownLib.Signals, DropdownLib.OpenSignal:Connect(function(val)
                    if val then
                        MarkItem()
                    else
                        NeverLose.PlayAnimate(ItemLabel, SlowyTween, { TextTransparency = 1 })
                        if MIcon then NeverLose.PlayAnimate(MIcon, SlowyTween, { TextTransparency = 1 }) end
                    end
                end))

                if Config.Multi then
                    local _, sig = NeverLose:CreateInput(ItemFrame, function()
                        Config.Default[Value] = not Config.Default[Value]
                        MarkItem()
                        BasedLabel.Text = NeverLose.ParseDropdown(Config.Default)
                        Config.Callback(Config.Default)
                    end)
                    table.insert(DropdownLib.Signals, sig)
                else
                    local _, sig = NeverLose:CreateInput(ItemFrame, function()
                        Config.Default = Value
                        for _, fn in next, DropdownLib.Refuse do task.spawn(fn) end
                        BasedLabel.Text = NeverLose.ParseDropdown(Config.Default)
                        Config.Callback(Config.Default)
                    end)
                    table.insert(DropdownLib.Signals, sig)
                end
            end
        end

        DropdownLib:Generate()
        function DropdownLib:GetValue() return Config.Default end
        function DropdownLib:SetValue(v)
            Config.Default = v
            BasedLabel.Text = NeverLose.ParseDropdown(v)
            for _, fn in next, DropdownLib.Refuse do task.spawn(fn) end
            Config.Callback(v)
        end
        function DropdownLib:SetValues(a)
            Config.Values = a
            if not Config.AutoUpdate then self:Generate() end
        end
        if Config.Flag then NeverLose.Flags[Config.Flag] = DropdownLib end
        return DropdownLib
    end

    return handle
end

NeverLose.ProcessDropdown = function(value)
    if typeof(value) == 'table' then
        local data = {}
        for i, v in next, value do
            if typeof(v) == 'boolean' and typeof(i) ~= 'number' then
                data[i] = v
            else
                data[v] = true
            end
        end
        return data
    end
    return value
end

NeverLose.ParseDropdown = function(value)
    if not value then return 'Select' end
    if typeof(value) == 'table' then
        local x = {}
        if #value > 0 then
            for _, v in next, value do table.insert(x, tostring(v)) end
        else
            for i, v in next, value do if v == true then table.insert(x, tostring(i)) end end
        end
        local out = table.concat(x, ' , ')
        table.clear(x)
        return (out:byte() and out) or 'Select'
    end
    return tostring(value or 'Select')
end

function NeverLose:ParseInput(Value, Numeric)
    if not Value then return Numeric and nil or "" end
    if Numeric then
        local out = string.gsub(tostring(Value), '[^0-9.%-]', '')
        return tonumber(out)
    end
    return Value
end

function NeverLose:CreateToolTips(Container, Name, Content)
    local Tooltips        = Instance.new("Frame")
    local UICorner        = Instance.new("UICorner")
    local UIStroke        = Instance.new("UIStroke")
    local TooltipName     = Instance.new("TextLabel")
    local TooltipContent  = Instance.new("TextLabel")
    local Shadow          = NeverLose:CreateShadow(Tooltips)

    Tooltips.Name                  = NeverLose.RandomString()
    Tooltips.BackgroundColor3      = Color3.fromRGB(20, 22, 27)
    Tooltips.BackgroundTransparency = 0.075
    Tooltips.BorderSizePixel       = 0
    Tooltips.ClipsDescendants      = true
    Tooltips.Position              = UDim2.new(255,255,255,255)
    Tooltips.Size                  = UDim2.new(0,0,0,0)
    Tooltips.ZIndex                = 130
    UICorner.CornerRadius          = UDim.new(0, 10)
    UICorner.Parent                = Tooltips
    UIStroke.Transparency          = 0.65
    UIStroke.Color                 = Color3.fromRGB(45, 48, 58)
    UIStroke.Parent                = Tooltips

    TooltipName.Name               = NeverLose.RandomString()
    TooltipName.Parent             = Tooltips
    TooltipName.BackgroundTransparency = 1
    TooltipName.BorderSizePixel    = 0
    TooltipName.Position           = UDim2.new(0, 15, 0, 5)
    TooltipName.Size               = UDim2.new(0, 1, 0, 20)
    TooltipName.ZIndex             = 132
    TooltipName.Font               = Enum.Font.GothamBold
    TooltipName.Text               = Name
    TooltipName.TextColor3         = Color3.fromRGB(255, 255, 255)
    TooltipName.TextSize           = 15
    TooltipName.TextXAlignment     = Enum.TextXAlignment.Left

    TooltipContent.Name            = NeverLose.RandomString()
    TooltipContent.Parent          = Tooltips
    TooltipContent.BackgroundTransparency = 1
    TooltipContent.BorderSizePixel = 0
    TooltipContent.Position        = UDim2.new(0, 15, 0, 30)
    TooltipContent.Size            = UDim2.new(0, 1, 0, 15)
    TooltipContent.ZIndex          = 132
    TooltipContent.Font            = Enum.Font.GothamBold
    TooltipContent.Text            = Content
    TooltipContent.TextColor3      = Color3.fromRGB(255, 255, 255)
    TooltipContent.TextSize        = 12
    TooltipContent.TextTransparency = 0.65
    TooltipContent.TextXAlignment  = Enum.TextXAlignment.Left
    TooltipContent.TextYAlignment  = Enum.TextYAlignment.Top

    local ToolTip = {}

    ToolTip.Update = function()
        local sn = TextService:GetTextSize(TooltipName.Text, TooltipName.TextSize, TooltipName.Font, Vector2.new(math.huge, math.huge))
        local sc = TextService:GetTextSize(TooltipContent.Text, TooltipContent.TextSize, TooltipContent.Font, Vector2.new(math.huge, math.huge))
        NeverLose.PlayAnimate(Tooltips, SlowyTween, { Size = UDim2.new(0, math.max(sn.X, sc.X) + 65, 0, sn.Y + sc.Y + 30) })
    end

    NeverLose:AddSignal(Tooltips:GetPropertyChangedSignal('BackgroundTransparency'):Connect(function()
        if Tooltips.BackgroundTransparency > 0.9 then
            Tooltips.Visible = false
            Tooltips.Parent  = nil
        else
            Tooltips.Visible = true
            Tooltips.Parent  = NeverLose.ScreenGui
        end
    end))

    ToolTip.SetRender = function(value)
        if value then
            Tooltips.Position = UDim2.fromOffset(Container.AbsolutePosition.X + Container.AbsoluteSize.X, Container.AbsolutePosition.Y + Container.AbsoluteSize.Y + 25)
            NeverLose.PlayAnimate(Tooltips,       SlowyTween, { BackgroundTransparency = 0.075 })
            NeverLose.PlayAnimate(UIStroke,       SlowyTween, { Transparency = 0.65 })
            NeverLose.PlayAnimate(TooltipName,    SlowyTween, { TextTransparency = 0 })
            NeverLose.PlayAnimate(TooltipContent, SlowyTween, { TextTransparency = 0.65 })
            ToolTip.Update()
            Shadow:Render(true)
        else
            NeverLose.PlayAnimate(Tooltips,       SlowyTween, { BackgroundTransparency = 1 })
            NeverLose.PlayAnimate(UIStroke,       SlowyTween, { Transparency = 1 })
            NeverLose.PlayAnimate(TooltipName,    SlowyTween, { TextTransparency = 1 })
            NeverLose.PlayAnimate(TooltipContent, SlowyTween, { TextTransparency = 1 })
            Shadow:Render(false)
        end
    end

    ToolTip.SetRender(false)
    ToolTip.Update()

    local DelayThread
    NeverLose:AddSignal(Container.MouseEnter:Connect(function()
        if DelayThread then task.cancel(DelayThread) end
        DelayThread = task.delay(1, ToolTip.SetRender, true)
    end))
    NeverLose:AddSignal(Container.MouseLeave:Connect(function()
        if DelayThread then task.cancel(DelayThread) DelayThread = nil end
        ToolTip.SetRender(false)
        ToolTip.Update()
    end))
    return ToolTip
end

function NeverLose:RegisiterItem(Frame, Signel)
    local idx        = {}
    local LayerIndex = Frame.ZIndex

    function idx:AddLabel(Name, Warp)
        local BasedFrame   = Instance.new("Frame")
        local BasedLabel   = Instance.new("TextLabel")
        local LineFrame    = Instance.new("Frame")
        local BasedHandler = Instance.new("Frame")
        local UIListLayout = Instance.new("UIListLayout")
        local UICorner     = Instance.new("UICorner")

        BasedFrame.Name                  = NeverLose.RandomString()
        BasedFrame.Parent                = Frame
        BasedFrame.BackgroundColor3      = Color3.fromRGB(25, 27, 33)
        BasedFrame.BackgroundTransparency = 1
        BasedFrame.BorderSizePixel       = 0
        BasedFrame.Size                  = UDim2.new(1, 0, 0, 30)
        BasedFrame.ZIndex                = LayerIndex + 8
        NeverLose:AddQuery(BasedFrame, Name)

        BasedLabel.Name                  = NeverLose.RandomString()
        BasedLabel.Parent                = BasedFrame
        BasedLabel.BackgroundTransparency = 1
        BasedLabel.BorderSizePixel       = 0
        BasedLabel.Position              = UDim2.new(0, 11, 0, 6)
        BasedLabel.Size                  = UDim2.new(0, 1, 0, 15)
        BasedLabel.ZIndex                = LayerIndex + 9
        BasedLabel.Font                  = Enum.Font.GothamMedium
        BasedLabel.Text                  = Name
        BasedLabel.TextColor3            = Color3.fromRGB(255, 255, 255)
        BasedLabel.TextSize              = 13
        BasedLabel.TextTransparency      = 0.35
        BasedLabel.TextXAlignment        = Enum.TextXAlignment.Left

        LineFrame.Name                   = NeverLose.RandomString()
        LineFrame.Parent                 = BasedFrame
        LineFrame.AnchorPoint            = Vector2.new(0.5, 1)
        LineFrame.BackgroundColor3       = Color3.fromRGB(45, 48, 58)
        LineFrame.BackgroundTransparency = 0.65
        LineFrame.BorderSizePixel        = 0
        LineFrame.Position               = UDim2.new(0.5, 0, 1, 0)
        LineFrame.Size                   = UDim2.new(1, -20, 0, 1)
        LineFrame.ZIndex                 = LayerIndex + 11

        BasedHandler.Name                = NeverLose.RandomString()
        BasedHandler.Parent              = BasedFrame
        BasedHandler.AnchorPoint         = Vector2.new(1, 0)
        BasedHandler.BackgroundTransparency = 1
        BasedHandler.BorderSizePixel     = 0
        BasedHandler.Position            = UDim2.new(1, -11, 0, 2)
        BasedHandler.Size                = UDim2.new(1, -20, 0, 25)
        BasedHandler.ZIndex              = LayerIndex + 12

        UIListLayout.Parent              = BasedHandler
        UIListLayout.FillDirection       = Enum.FillDirection.Horizontal
        UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        UIListLayout.SortOrder           = Enum.SortOrder.LayoutOrder
        UIListLayout.VerticalAlignment   = Enum.VerticalAlignment.Center
        UIListLayout.Padding             = UDim.new(0, 5)
        UICorner.CornerRadius            = UDim.new(0, 10)
        UICorner.Parent                  = BasedFrame

        local function UpdateWarp()
            local size = TextService:GetTextSize(BasedLabel.Text, BasedLabel.TextSize, BasedLabel.Font, Vector2.new(math.huge, math.huge))
            NeverLose.PlayAnimate(BasedFrame, SlowyTween, { Size = UDim2.new(1, 0, 0, size.Y + 13) })
            BasedLabel.Size            = UDim2.new(1, -35, 1, 0)
            BasedLabel.TextYAlignment  = Enum.TextYAlignment.Top
        end
        if Warp then UpdateWarp() end

        local handle = NeverLose:RegisiterHandler(BasedHandler, Signel)
        handle.Root  = BasedFrame

        handle.SetRender = function(value)
            NeverLose.PlayAnimate(BasedLabel, SlowyTween, { TextTransparency = value and 0.35 or 1 })
            NeverLose.PlayAnimate(LineFrame,  SlowyTween, { BackgroundTransparency = value and 0.65 or 1 })
        end
        function handle:SetVisible(val) BasedFrame.Visible = val end

        NeverLose:AddSignal(BasedFrame.MouseEnter:Connect(function()
            NeverLose.PlayAnimate(BasedFrame,  SlowyTween, { BackgroundTransparency = 0.35 })
            NeverLose.PlayAnimate(BasedLabel,  SlowyTween, { TextTransparency = 0.25 })
        end))
        NeverLose:AddSignal(BasedFrame.MouseLeave:Connect(function()
            NeverLose.PlayAnimate(BasedFrame,  SlowyTween, { BackgroundTransparency = 1 })
            NeverLose.PlayAnimate(BasedLabel,  SlowyTween, { TextTransparency = 0.35 })
        end))
        function handle:SetText(t)
            local old = BasedLabel.Text
            BasedLabel.Text = t
            if Warp and old ~= t then UpdateWarp() end
        end
        function handle:ToolTip(Content)
            handle.ToolTip = NeverLose:CreateToolTips(BasedFrame, Name, Content)
            return handle
        end
        handle.SetRender(Signel:GetValue())
        Signel:Connect(handle.SetRender)
        return handle
    end

    function idx:AddButton(Config)
        Config = NeverLose:ProcessParams(Config, {
            Icon = 'chevron-large-left', Name = "Button", Callback = EmptyFunction, ToolTip = nil,
        })
        local Button       = {}
        local ButtonFrame  = Instance.new("Frame")
        local BasedLabel   = Instance.new("TextLabel")
        local LineFrame    = Instance.new("Frame")
        local UICorner     = Instance.new("UICorner")
        local Icon         = Instance.new("TextLabel")

        NeverLose:AddQuery(ButtonFrame, Config.Name)
        ButtonFrame.Name                  = NeverLose.RandomString()
        ButtonFrame.Parent                = Frame
        ButtonFrame.BackgroundColor3      = Color3.fromRGB(25, 27, 33)
        ButtonFrame.BackgroundTransparency = 1
        ButtonFrame.BorderSizePixel       = 0
        ButtonFrame.Size                  = UDim2.new(1, 0, 0, 30)
        ButtonFrame.ZIndex                = LayerIndex + 8

        BasedLabel.Name                   = NeverLose.RandomString()
        BasedLabel.Parent                 = ButtonFrame
        BasedLabel.BackgroundTransparency = 1
        BasedLabel.BorderSizePixel        = 0
        BasedLabel.Position               = UDim2.new(0, 35, 0, 6)
        BasedLabel.Size                   = UDim2.new(0, 1, 0, 15)
        BasedLabel.ZIndex                 = LayerIndex + 9
        BasedLabel.Font                   = Enum.Font.GothamMedium
        BasedLabel.Text                   = Config.Name
        BasedLabel.TextColor3             = Color3.fromRGB(255, 255, 255)
        BasedLabel.TextSize               = 13
        BasedLabel.TextTransparency       = 0.2
        BasedLabel.TextXAlignment         = Enum.TextXAlignment.Left

        LineFrame.Name                    = NeverLose.RandomString()
        LineFrame.Parent                  = ButtonFrame
        LineFrame.AnchorPoint             = Vector2.new(0.5, 1)
        LineFrame.BackgroundColor3        = Color3.fromRGB(45, 48, 58)
        LineFrame.BackgroundTransparency  = 0.65
        LineFrame.BorderSizePixel         = 0
        LineFrame.Position                = UDim2.new(0.5, 0, 1, 0)
        LineFrame.Size                    = UDim2.new(1, -20, 0, 1)
        LineFrame.ZIndex                  = LayerIndex + 11
        UICorner.CornerRadius             = UDim.new(0, 10)
        UICorner.Parent                   = ButtonFrame

        Icon.Name                         = NeverLose.RandomString()
        Icon.Parent                       = ButtonFrame
        Icon.BackgroundTransparency       = 1
        Icon.BorderSizePixel              = 0
        Icon.Position                     = UDim2.new(0, 11, 0, 5)
        Icon.Size                         = UDim2.new(0, 18, 0, 18)
        Icon.ZIndex                       = LayerIndex + 9
        Icon.FontFace                     = NeverLose.BuiltInBold
        Icon.Text                         = Config.Icon
        Icon.TextColor3                   = Color3.fromRGB(223, 223, 223)
        Icon.TextSize                     = 16
        Icon.TextTransparency             = 0.25
        Icon.TextWrapped                  = true

        function Button:SetText(t) BasedLabel.Text = t end
        function Button:SetIcon(t) Icon.Text = t end

        local bth = NeverLose:CreateInput(ButtonFrame, function() Config.Callback() end)
        NeverLose:AddSignal(bth.MouseEnter:Connect(function()
            NeverLose.PlayAnimate(ButtonFrame, SlowyTween, { BackgroundTransparency = 0.35 })
        end))
        NeverLose:AddSignal(bth.MouseLeave:Connect(function()
            NeverLose.PlayAnimate(ButtonFrame, SlowyTween, { BackgroundTransparency = 1 })
        end))

        Button.SetRender = function(value)
            NeverLose.PlayAnimate(BasedLabel, SlowyTween, { TextTransparency = value and 0.2 or 1 })
            NeverLose.PlayAnimate(LineFrame,  SlowyTween, { BackgroundTransparency = value and 0.65 or 1 })
            NeverLose.PlayAnimate(Icon,       SlowyTween, { TextTransparency = value and 0.25 or 1 })
        end
        if Config.ToolTip then
            Button.ToolTip = NeverLose:CreateToolTips(ButtonFrame, Config.Name, Config.ToolTip)
        end
        Button.SetRender(Signel:GetValue())
        Signel:Connect(Button.SetRender)
        return Button
    end

    return idx
end

function NeverLose:CreateWindow(Config)
    Config = NeverLose:ProcessParams(Config, {
        Logo        = NeverLose.GlobalLogo,
        Name        = "Neverlose",
        Content     = "Counter-Strike 2",
        Size        = UDim2.new(0, 640, 0, 480),
        ConfigFolder = "NeverLoseConfigs",
        Keybind     = "End",
    })

    local Window = {
        Logo         = Config.Logo,
        Name         = Config.Name,
        Content      = Config.Content,
        Size         = Config.Size,
        ConfigFolder = Config.ConfigFolder,
        Signal       = NeverLose:CreateSignal(true),
        Tabs         = {},
        CurrentTab   = 1,
        Keybind      = Config.Keybind,
    }

    NeverLose.GlobalLogo = Window.Logo
    local Logging = NeverLose:CreateLogger()
    if not isfolder(Window.ConfigFolder) then makefolder(Window.ConfigFolder) end

    local WindowFrame      = Instance.new("Frame")
    local UICorner         = Instance.new("UICorner")
    local LeftMenuFrame    = Instance.new("Frame")
    local HeadFrame        = Instance.new("Frame")
    local LogoImage        = Instance.new("ImageLabel")
    local UICorner_2       = Instance.new("UICorner")
    local WindowName       = Instance.new("TextLabel")
    local WindowContent    = Instance.new("TextLabel")
    local LineFrame        = Instance.new("Frame")
    local LeftScrollingFrame = Instance.new("ScrollingFrame")
    local UIListLayout     = Instance.new("UIListLayout")
    local RightMenuFrame   = Instance.new("Frame")
    local UIStroke         = Instance.new("UIStroke")
    local UICorner_4       = Instance.new("UICorner")
    local RightHeader      = Instance.new("Frame")
    local LineFrame_3      = Instance.new("Frame")
    local ConfigFrame      = Instance.new("Frame")
    local UIStroke_2       = Instance.new("UIStroke")
    local UICorner_5       = Instance.new("UICorner")
    local ConfigIcon       = Instance.new("TextLabel")
    local LineFrame_4      = Instance.new("Frame")
    local ConfigName       = Instance.new("TextLabel")
    local ConfigBthIcon    = Instance.new("TextLabel")
    local SearchFrame      = Instance.new("Frame")
    local SearchIcon       = Instance.new("TextLabel")
    local SearchBox        = Instance.new("TextBox")
    local TabContainer     = Instance.new("Frame")

    WindowFrame.Name                  = NeverLose.RandomString()
    WindowFrame.Parent                = NeverLose.ScreenGui
    WindowFrame.AnchorPoint           = Vector2.new(0.5, 0.5)
    WindowFrame.BackgroundColor3      = Color3.fromRGB(8, 8, 13)
    WindowFrame.BackgroundTransparency = 0.055
    WindowFrame.BorderSizePixel       = 0
    WindowFrame.ClipsDescendants      = true
    WindowFrame.Position              = UDim2.new(255, 0, 255, 0)
    WindowFrame.Size                  = Window.Size
    WindowFrame.Active                = true
    if not NeverLose.EnabledBlur then WindowFrame.BackgroundTransparency = 0.0255 end

    NeverLose:AddSignal(WindowFrame:GetPropertyChangedSignal('BackgroundTransparency'):Connect(function()
        if WindowFrame.BackgroundTransparency > 0.9 then
            WindowFrame.Visible = false
            WindowFrame.Parent  = nil
        else
            WindowFrame.Visible = true
            WindowFrame.Parent  = NeverLose.ScreenGui
        end
    end))

    Window.SetRender = function(self, value)
        if value then
            NeverLose.PlayAnimate(WindowFrame,   SlowyTween, { BackgroundTransparency = NeverLose.EnabledBlur and 0.055 or 0.0255, Size = Window.Size })
            NeverLose.PlayAnimate(LogoImage,     SlowyTween, { ImageTransparency = 0 })
            NeverLose.PlayAnimate(WindowName,    SlowyTween, { TextTransparency = 0 })
            NeverLose.PlayAnimate(WindowContent, SlowyTween, { TextTransparency = 0.65 })
            NeverLose.PlayAnimate(LineFrame,     SlowyTween, { BackgroundTransparency = 0.65 })
            NeverLose.PlayAnimate(RightMenuFrame, SlowyTween, { BackgroundTransparency = 0.6 })
            NeverLose.PlayAnimate(UIStroke,      SlowyTween, { Transparency = 0.65 })
            NeverLose.PlayAnimate(LineFrame_3,   SlowyTween, { BackgroundTransparency = 0.65 })
            NeverLose.PlayAnimate(ConfigFrame,   SlowyTween, { BackgroundTransparency = 0.75 })
            NeverLose.PlayAnimate(UIStroke_2,    SlowyTween, { Transparency = 0.65 })
            NeverLose.PlayAnimate(ConfigIcon,    SlowyTween, { TextTransparency = 0.25 })
            NeverLose.PlayAnimate(LineFrame_4,   SlowyTween, { BackgroundTransparency = 0.65 })
            NeverLose.PlayAnimate(ConfigName,    SlowyTween, { TextTransparency = 0.35 })
            NeverLose.PlayAnimate(ConfigBthIcon, SlowyTween, { TextTransparency = 0.25 })
            NeverLose.PlayAnimate(SearchIcon,    SlowyTween, { TextTransparency = 0.25 })
            NeverLose.PlayAnimate(SearchBox,     SlowyTween, { TextTransparency = 0.35 })
            Window.Shadow:Render(true)
        else
            NeverLose.PlayAnimate(WindowFrame,   SlowyTween, { BackgroundTransparency = 1, Size = Window.Size + UDim2.fromOffset(-15, -15) })
            NeverLose.PlayAnimate(LogoImage,     SlowyTween, { ImageTransparency = 1 })
            NeverLose.PlayAnimate(WindowName,    SlowyTween, { TextTransparency = 1 })
            NeverLose.PlayAnimate(WindowContent, SlowyTween, { TextTransparency = 1 })
            NeverLose.PlayAnimate(LineFrame,     SlowyTween, { BackgroundTransparency = 1 })
            NeverLose.PlayAnimate(RightMenuFrame, SlowyTween, { BackgroundTransparency = 1 })
            NeverLose.PlayAnimate(UIStroke,      SlowyTween, { Transparency = 1 })
            NeverLose.PlayAnimate(LineFrame_3,   SlowyTween, { BackgroundTransparency = 1 })
            NeverLose.PlayAnimate(ConfigFrame,   SlowyTween, { BackgroundTransparency = 1 })
            NeverLose.PlayAnimate(UIStroke_2,    SlowyTween, { Transparency = 1 })
            NeverLose.PlayAnimate(ConfigIcon,    SlowyTween, { TextTransparency = 1 })
            NeverLose.PlayAnimate(LineFrame_4,   SlowyTween, { BackgroundTransparency = 1 })
            NeverLose.PlayAnimate(ConfigName,    SlowyTween, { TextTransparency = 1 })
            NeverLose.PlayAnimate(ConfigBthIcon, SlowyTween, { TextTransparency = 1 })
            NeverLose.PlayAnimate(SearchIcon,    SlowyTween, { TextTransparency = 1 })
            NeverLose.PlayAnimate(SearchBox,     SlowyTween, { TextTransparency = 1 })
            Window.Shadow:Render(false)
        end
    end

    Window.Shadow = NeverLose:CreateShadow(WindowFrame)
    Window.Shadow:Render(false)

    task.delay(0.25, function()
        WindowFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        Window:SetRender(true)
        NeverLose:AddSignal(Window.Signal:Connect(function(...) Window:SetRender(...) end))
    end)

    if NeverLose.EnabledBlur then NeverLose:CreateBlurModule(WindowFrame, Window.Signal) end

    do
        local DragFrame = Instance.new("Frame")
        DragFrame.Parent                = WindowFrame
        DragFrame.BackgroundTransparency = 1
        DragFrame.BorderSizePixel       = 0
        DragFrame.Size                  = UDim2.new(1, 0, 0, 50)
        DragFrame.ZIndex                = 7
        NeverLose.Drag(DragFrame, WindowFrame, 0.15)
    end

    UICorner.Parent = WindowFrame

    LeftMenuFrame.Name                  = NeverLose.RandomString()
    LeftMenuFrame.Parent                = WindowFrame
    LeftMenuFrame.BackgroundTransparency = 1
    LeftMenuFrame.BorderSizePixel       = 0
    LeftMenuFrame.Size                  = UDim2.new(0, 175, 1, 0)

    HeadFrame.Name                      = NeverLose.RandomString()
    HeadFrame.Parent                    = LeftMenuFrame
    HeadFrame.BackgroundTransparency    = 1
    HeadFrame.BorderSizePixel           = 0
    HeadFrame.Size                      = UDim2.new(1, 0, 0, 50)
    HeadFrame.ZIndex                    = 7

    LogoImage.Name                      = NeverLose.RandomString()
    LogoImage.Parent                    = HeadFrame
    LogoImage.AnchorPoint               = Vector2.new(0, 0.5)
    LogoImage.BackgroundTransparency    = 1
    LogoImage.BorderSizePixel           = 0
    LogoImage.Position                  = UDim2.new(0, 10, 0.5, 0)
    LogoImage.Size                      = UDim2.new(0, 35, 0, 35)
    LogoImage.ZIndex                    = 7
    LogoImage.Image                     = Window.Logo
    LogoImage.ImageColor3               = NeverLose.IconColor
    UICorner_2.CornerRadius             = UDim.new(0, 7)
    UICorner_2.Parent                   = LogoImage

    WindowName.Name                     = NeverLose.RandomString()
    WindowName.Parent                   = HeadFrame
    WindowName.BackgroundTransparency   = 1
    WindowName.BorderSizePixel          = 0
    WindowName.Position                 = UDim2.new(0, 55, 0, 4)
    WindowName.Size                     = UDim2.new(0, 200, 0, 25)
    WindowName.ZIndex                   = 7
    WindowName.Font                     = Enum.Font.GothamBold
    WindowName.Text                     = Window.Name
    WindowName.TextColor3               = Color3.fromRGB(255, 255, 255)
    WindowName.TextSize                 = 18
    WindowName.TextXAlignment           = Enum.TextXAlignment.Left

    WindowContent.Name                  = NeverLose.RandomString()
    WindowContent.Parent                = HeadFrame
    WindowContent.BackgroundTransparency = 1
    WindowContent.BorderSizePixel       = 0
    WindowContent.Position              = UDim2.new(0, 55, 0, 25)
    WindowContent.Size                  = UDim2.new(0, 200, 0, 15)
    WindowContent.ZIndex                = 7
    WindowContent.Font                  = Enum.Font.GothamBold
    WindowContent.Text                  = Window.Content
    WindowContent.TextColor3            = Color3.fromRGB(255, 255, 255)
    WindowContent.TextSize              = 9
    WindowContent.TextTransparency      = 0.65
    WindowContent.TextXAlignment        = Enum.TextXAlignment.Left

    LineFrame.Name                      = NeverLose.RandomString()
    LineFrame.Parent                    = HeadFrame
    LineFrame.AnchorPoint               = Vector2.new(0.5, 1)
    LineFrame.BackgroundColor3          = Color3.fromRGB(45, 48, 58)
    LineFrame.BackgroundTransparency    = 0.65
    LineFrame.BorderSizePixel           = 0
    LineFrame.Position                  = UDim2.new(0.5, 0, 1, 0)
    LineFrame.Size                      = UDim2.new(1, -10, 0, 1)
    LineFrame.ZIndex                    = 5

    LeftScrollingFrame.Name             = NeverLose.RandomString()
    LeftScrollingFrame.Parent           = LeftMenuFrame
    LeftScrollingFrame.Active           = true
    LeftScrollingFrame.AnchorPoint      = Vector2.new(0.5, 0)
    LeftScrollingFrame.BackgroundTransparency = 1
    LeftScrollingFrame.BorderSizePixel  = 0
    LeftScrollingFrame.Position         = UDim2.new(0.5, 0, 0, 60)
    LeftScrollingFrame.Size             = UDim2.new(1, -10, 1, -60)
    LeftScrollingFrame.ZIndex           = 7
    LeftScrollingFrame.ScrollBarThickness = 0

    UIListLayout.Parent                 = LeftScrollingFrame
    UIListLayout.HorizontalAlignment    = Enum.HorizontalAlignment.Center
    UIListLayout.SortOrder              = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding                = UDim.new(0, 5)

    NeverLose:AddSignal(UIListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
        LeftScrollingFrame.CanvasSize = UDim2.fromOffset(0, UIListLayout.AbsoluteContentSize.Y + 1)
    end))

    RightMenuFrame.Name                 = NeverLose.RandomString()
    RightMenuFrame.Parent               = WindowFrame
    RightMenuFrame.BackgroundColor3     = Color3.fromRGB(8, 8, 13)
    RightMenuFrame.BackgroundTransparency = 0.6
    RightMenuFrame.BorderSizePixel      = 0
    RightMenuFrame.ClipsDescendants     = true
    RightMenuFrame.Position             = UDim2.new(0, 176, 0, 0)
    RightMenuFrame.Size                 = UDim2.new(1, -176, 1, 0)
    RightMenuFrame.ZIndex               = 8
    UIStroke.Transparency               = 0.65
    UIStroke.Color                      = Color3.fromRGB(45, 48, 58)
    UIStroke.Parent                     = RightMenuFrame
    UICorner_4.CornerRadius             = UDim.new(0, 13)
    UICorner_4.Parent                   = RightMenuFrame

    RightHeader.Name                    = NeverLose.RandomString()
    RightHeader.Parent                  = RightMenuFrame
    RightHeader.BackgroundTransparency  = 1
    RightHeader.BorderSizePixel         = 0
    RightHeader.Size                    = UDim2.new(1, 0, 0, 50)
    RightHeader.ZIndex                  = 9

    LineFrame_3.Name                    = NeverLose.RandomString()
    LineFrame_3.Parent                  = RightHeader
    LineFrame_3.AnchorPoint             = Vector2.new(0.5, 1)
    LineFrame_3.BackgroundColor3        = Color3.fromRGB(45, 48, 58)
    LineFrame_3.BackgroundTransparency  = 0.65
    LineFrame_3.BorderSizePixel         = 0
    LineFrame_3.Position                = UDim2.new(0.5, 0, 1, 0)
    LineFrame_3.Size                    = UDim2.new(1, -10, 0, 1)
    LineFrame_3.ZIndex                  = 9

    ConfigFrame.Name                    = NeverLose.RandomString()
    ConfigFrame.Parent                  = RightHeader
    ConfigFrame.AnchorPoint             = Vector2.new(0, 0.5)
    ConfigFrame.BackgroundColor3        = Color3.fromRGB(13, 17, 22)
    ConfigFrame.BackgroundTransparency  = 0.75
    ConfigFrame.BorderSizePixel         = 0
    ConfigFrame.Position                = UDim2.new(0, 10, 0.5, 0)
    ConfigFrame.Size                    = UDim2.new(0, 115, 0, 30)
    ConfigFrame.ZIndex                  = 9
    UIStroke_2.Transparency             = 0.65
    UIStroke_2.Color                    = Color3.fromRGB(45, 48, 58)
    UIStroke_2.Parent                   = ConfigFrame
    UICorner_5.CornerRadius             = UDim.new(0, 4)
    UICorner_5.Parent                   = ConfigFrame

    ConfigIcon.Name                     = NeverLose.RandomString()
    ConfigIcon.Parent                   = ConfigFrame
    ConfigIcon.AnchorPoint              = Vector2.new(0, 0.5)
    ConfigIcon.BackgroundTransparency   = 1
    ConfigIcon.BorderSizePixel          = 0
    ConfigIcon.Position                 = UDim2.new(0, 2, 0.5, 0)
    ConfigIcon.Size                     = UDim2.new(0, 25, 0, 25)
    ConfigIcon.ZIndex                   = 9
    ConfigIcon.FontFace                 = NeverLose.BuiltInBold
    ConfigIcon.Text                     = "pencil-square"
    ConfigIcon.TextColor3               = Color3.fromRGB(223, 223, 223)
    ConfigIcon.TextSize                 = 16
    ConfigIcon.TextTransparency         = 0.25
    ConfigIcon.TextWrapped              = true

    LineFrame_4.Name                    = NeverLose.RandomString()
    LineFrame_4.Parent                  = ConfigFrame
    LineFrame_4.BackgroundColor3        = Color3.fromRGB(45, 48, 58)
    LineFrame_4.BackgroundTransparency  = 0.65
    LineFrame_4.BorderSizePixel         = 0
    LineFrame_4.Position                = UDim2.new(0, 30, 0, 0)
    LineFrame_4.Size                    = UDim2.new(0, 1, 1, 0)

    ConfigName.Name                     = NeverLose.RandomString()
    ConfigName.Parent                   = ConfigFrame
    ConfigName.AnchorPoint              = Vector2.new(0, 0.5)
    ConfigName.BackgroundTransparency   = 1
    ConfigName.BorderSizePixel          = 0
    ConfigName.Position                 = UDim2.new(0, 40, 0.5, 0)
    ConfigName.Size                     = UDim2.new(1, -7, 0, 15)
    ConfigName.ZIndex                   = 9
    ConfigName.Font                     = Enum.Font.GothamMedium
    ConfigName.Text                     = "Default"
    ConfigName.TextColor3               = Color3.fromRGB(255, 255, 255)
    ConfigName.TextSize                 = 12
    ConfigName.TextTransparency         = 0.35
    ConfigName.TextXAlignment           = Enum.TextXAlignment.Left

    ConfigBthIcon.Name                  = NeverLose.RandomString()
    ConfigBthIcon.Parent                = ConfigFrame
    ConfigBthIcon.AnchorPoint           = Vector2.new(1, 0.5)
    ConfigBthIcon.BackgroundTransparency = 1
    ConfigBthIcon.BorderSizePixel       = 0
    ConfigBthIcon.Position              = UDim2.new(1, -2, 0.5, 0)
    ConfigBthIcon.Size                  = UDim2.new(0, 25, 0, 25)
    ConfigBthIcon.ZIndex                = 9
    ConfigBthIcon.FontFace              = NeverLose.BuiltInBold
    ConfigBthIcon.Text                  = "chevron-small-down"
    ConfigBthIcon.TextColor3            = Color3.fromRGB(223, 223, 223)
    ConfigBthIcon.TextSize              = 16
    ConfigBthIcon.TextTransparency      = 0.25
    ConfigBthIcon.TextWrapped           = true

    SearchFrame.Name                    = NeverLose.RandomString()
    SearchFrame.Parent                  = RightHeader
    SearchFrame.AnchorPoint             = Vector2.new(1, 0.5)
    SearchFrame.BackgroundTransparency  = 1
    SearchFrame.BorderSizePixel         = 0
    SearchFrame.ClipsDescendants        = true
    SearchFrame.Position                = UDim2.new(1, -10, 0.5, 0)
    SearchFrame.Size                    = UDim2.new(0, 30, 0, 30)
    SearchFrame.ZIndex                  = 12

    SearchIcon.Name                     = NeverLose.RandomString()
    SearchIcon.Parent                   = SearchFrame
    SearchIcon.AnchorPoint              = Vector2.new(0, 0.5)
    SearchIcon.BackgroundTransparency   = 1
    SearchIcon.BorderSizePixel          = 0
    SearchIcon.Position                 = UDim2.new(0, 2, 0.5, 0)
    SearchIcon.Size                     = UDim2.new(0, 25, 0, 25)
    SearchIcon.ZIndex                   = 12
    SearchIcon.FontFace                 = NeverLose.BuiltInBold
    SearchIcon.Text                     = "magnifying-glass"
    SearchIcon.TextColor3               = Color3.fromRGB(223, 223, 223)
    SearchIcon.TextSize                 = 14
    SearchIcon.TextTransparency         = 0.45
    SearchIcon.TextWrapped              = true

    SearchBox.Name                      = NeverLose.RandomString()
    SearchBox.Parent                    = SearchFrame
    SearchBox.AnchorPoint               = Vector2.new(0, 0.5)
    SearchBox.BackgroundTransparency    = 1
    SearchBox.BorderSizePixel           = 0
    SearchBox.Position                  = UDim2.new(0, 35, 0.5, 0)
    SearchBox.Size                      = UDim2.new(1, -35, 0, 25)
    SearchBox.ZIndex                    = 12
    SearchBox.ClearTextOnFocus          = false
    SearchBox.Font                      = Enum.Font.GothamMedium
    SearchBox.PlaceholderText           = "Search"
    SearchBox.Text                      = ""
    SearchBox.TextColor3                = Color3.fromRGB(255, 255, 255)
    SearchBox.TextSize                  = 13
    SearchBox.TextTransparency          = 1
    SearchBox.TextXAlignment            = Enum.TextXAlignment.Left

    TabContainer.Name                   = NeverLose.RandomString()
    TabContainer.Parent                 = RightMenuFrame
    TabContainer.BackgroundTransparency = 1
    TabContainer.BorderSizePixel        = 0
    TabContainer.ClipsDescendants       = true
    TabContainer.Position               = UDim2.new(0, 0, 0, 50)
    TabContainer.Size                   = UDim2.new(1, 0, 1, -50)
    TabContainer.ZIndex                 = 5

    do
        Window.Searching = false
        local Input = NeverLose:CreateInput(SearchIcon, function()
            Window.Searching = not Window.Searching
            if Window.Searching then
                NeverLose.PlayAnimate(SearchFrame, VSlowTween, { Size = UDim2.new(0, 220, 0, 30) })
                NeverLose.PlayAnimate(SearchIcon,  SlowyTween, { TextTransparency = 0.25 })
                NeverLose.PlayAnimate(SearchBox,   VSlowTween, { TextTransparency = 0.35 })
            else
                NeverLose.PlayAnimate(SearchFrame, VSlowTween, { Size = UDim2.new(0, 30, 0, 30) })
                NeverLose.PlayAnimate(SearchIcon,  SlowyTween, { TextTransparency = 0.45 })
                NeverLose.PlayAnimate(SearchBox,   SlowyTween, { TextTransparency = 1 })
                SearchBox.Text = ""
            end
        end)

        local lastThread
        NeverLose:AddSignal(SearchBox:GetPropertyChangedSignal('Text'):Connect(function()
            if not SearchBox.Text:byte() then
                for _, v in next, NeverLose.NameRegisitry do v.Root.Visible = true end
                return
            end
            if lastThread then task.cancel(lastThread) end
            lastThread = task.delay(0.2, function()
                if SearchBox.Text:byte() then
                    for _, v in next, NeverLose.NameRegisitry do
                        v.Root.Visible = string.find(string.lower(v.Idx), string.lower(SearchBox.Text), 1, true) ~= nil
                    end
                end
            end)
        end))

        NeverLose:AddSignal(Input.MouseEnter:Connect(function()
            NeverLose.PlayAnimate(SearchIcon, SlowyTween, { TextTransparency = 0.25 })
        end))
        NeverLose:AddSignal(Input.MouseLeave:Connect(function()
            NeverLose.PlayAnimate(SearchIcon, SlowyTween, { TextTransparency = Window.Searching and 0.25 or 0.45 })
        end))
    end

    function Window:AddTabLabel(Name)
        local TabLabel = Instance.new("TextLabel")
        TabLabel.Name                  = NeverLose.RandomString()
        TabLabel.Parent                = LeftScrollingFrame
        TabLabel.BackgroundTransparency = 1
        TabLabel.BorderSizePixel       = 0
        TabLabel.Size                  = UDim2.new(1, -7, 0, 15)
        TabLabel.ZIndex                = 8
        TabLabel.Font                  = Enum.Font.GothamMedium
        TabLabel.Text                  = Name
        TabLabel.TextColor3            = Color3.fromRGB(255, 255, 255)
        TabLabel.TextSize              = 11
        TabLabel.TextTransparency      = 0.5
        TabLabel.TextXAlignment        = Enum.TextXAlignment.Left
        local function SetRender(val)
            NeverLose.PlayAnimate(TabLabel, SlowyTween, { TextTransparency = val and 0.5 or 1 })
        end
        SetRender(Window.Signal:GetValue())
        return Window.Signal:Connect(SetRender)
    end

    function Window:AddTab(Config)
        Config = NeverLose:ProcessParams(Config, { Icon = "crosshairs", Name = "Tab", Type = "Double" })
        local Tab = { Signal = NeverLose:CreateSignal(false) }

        local TabButton       = Instance.new("Frame")
        local UICorner_t      = Instance.new("UICorner")
        local TabIcon         = Instance.new("TextLabel")
        local TabContentLabel = Instance.new("TextLabel")

        Tab.Idx = TabButton
        TabButton.Name                  = NeverLose.RandomString()
        TabButton.Parent                = LeftScrollingFrame
        TabButton.BackgroundColor3      = Color3.fromRGB(41, 45, 49)
        TabButton.BackgroundTransparency = 0.5
        TabButton.BorderSizePixel       = 0
        TabButton.Size                  = UDim2.new(1, -1, 0, 30)
        TabButton.ZIndex                = 8
        UICorner_t.CornerRadius         = UDim.new(0, 6)
        UICorner_t.Parent               = TabButton

        TabIcon.Name                    = NeverLose.RandomString()
        TabIcon.Parent                  = TabButton
        TabIcon.AnchorPoint             = Vector2.new(0, 0.5)
        TabIcon.BackgroundTransparency  = 1
        TabIcon.BorderSizePixel         = 0
        TabIcon.Position                = UDim2.new(0, 2, 0.5, 0)
        TabIcon.Size                    = UDim2.new(0, 25, 0, 25)
        TabIcon.ZIndex                  = 9
        TabIcon.FontFace                = NeverLose.BuiltInBold
        TabIcon.Text                    = Config.Icon
        TabIcon.TextColor3              = NeverLose.AccentColor
        TabIcon.TextSize                = 16
        TabIcon.TextWrapped             = true

        TabContentLabel.Name            = NeverLose.RandomString()
        TabContentLabel.Parent          = TabButton
        TabContentLabel.AnchorPoint     = Vector2.new(0, 0.5)
        TabContentLabel.BackgroundTransparency = 1
        TabContentLabel.BorderSizePixel = 0
        TabContentLabel.Position        = UDim2.new(0, 30, 0.5, 0)
        TabContentLabel.Size            = UDim2.new(1, -7, 0, 15)
        TabContentLabel.ZIndex          = 9
        TabContentLabel.Font            = Enum.Font.GothamMedium
        TabContentLabel.Text            = Config.Name
        TabContentLabel.TextColor3      = Color3.fromRGB(255, 255, 255)
        TabContentLabel.TextSize        = 12
        TabContentLabel.TextXAlignment  = Enum.TextXAlignment.Left

        local TabFrame    = Instance.new("Frame")
        local LeftScroll  = Instance.new("ScrollingFrame")
        local UIListL     = Instance.new("UIListLayout")
        local RightScroll = Instance.new("ScrollingFrame")
        local UIListL2    = Instance.new("UIListLayout")

        TabFrame.Name                   = NeverLose.RandomString()
        TabFrame.Parent                 = TabContainer
        TabFrame.AnchorPoint            = Vector2.new(0.5, 0.5)
        TabFrame.BackgroundTransparency = 1
        TabFrame.BorderSizePixel        = 0
        TabFrame.ClipsDescendants       = true
        TabFrame.Position               = UDim2.new(0.5, 0, 0.5, 0)
        TabFrame.Size                   = UDim2.new(1, 0, 1, 0)
        TabFrame.Visible                = true

        LeftScroll.Name                 = NeverLose.RandomString()
        LeftScroll.Parent               = TabFrame
        LeftScroll.Active               = true
        LeftScroll.AnchorPoint          = Vector2.new(0.5, 0.5)
        LeftScroll.BackgroundTransparency = 1
        LeftScroll.BorderSizePixel      = 0
        LeftScroll.ClipsDescendants     = false
        LeftScroll.Position             = UDim2.new(0.25, 0, 0.5, 0)
        LeftScroll.Size                 = UDim2.new(0.5, 0, 1, -5)
        LeftScroll.ScrollBarThickness   = 0
        UIListL.Parent                  = LeftScroll
        UIListL.HorizontalAlignment     = Enum.HorizontalAlignment.Right
        UIListL.SortOrder               = Enum.SortOrder.LayoutOrder
        UIListL.Padding                 = UDim.new(0, 5)
        NeverLose:AddSignal(UIListL:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
            LeftScroll.CanvasSize = UDim2.fromOffset(0, UIListL.AbsoluteContentSize.Y + 1)
        end))

        RightScroll.Name                = NeverLose.RandomString()
        RightScroll.Parent              = TabFrame
        RightScroll.Active              = true
        RightScroll.AnchorPoint         = Vector2.new(0.5, 0.5)
        RightScroll.BackgroundTransparency = 1
        RightScroll.BorderSizePixel     = 0
        RightScroll.ClipsDescendants    = false
        RightScroll.Position            = UDim2.new(0.75, 0, 0.5, 0)
        RightScroll.Size                = UDim2.new(0.5, 0, 1, -5)
        RightScroll.ScrollBarThickness  = 0
        UIListL2.Parent                 = RightScroll
        UIListL2.SortOrder              = Enum.SortOrder.LayoutOrder
        UIListL2.Padding                = UDim.new(0, 5)

        if Config.Type == "Single" then
            UIListL2:Destroy()
            RightScroll:Destroy()
            RightScroll  = LeftScroll
            UIListL2     = UIListL
            LeftScroll.Size     = UDim2.new(1, 0, 1, -5)
            LeftScroll.Position = UDim2.new(0.5, 0, 0.5, 0)
        else
            NeverLose:AddSignal(UIListL2:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
                RightScroll.CanvasSize = UDim2.fromOffset(0, UIListL2.AbsoluteContentSize.Y + 1)
            end))
        end

        NeverLose:AddSignal(TabIcon:GetPropertyChangedSignal('TextTransparency'):Connect(function()
            if TabIcon.TextTransparency > 0.4 then
                UIListL.Parent  = nil
                UIListL2.Parent = nil
                TabFrame.Visible = false
                TabFrame.Parent  = nil
            else
                UIListL.Parent  = LeftScroll
                UIListL2.Parent = RightScroll
                TabFrame.Visible = true
                TabFrame.Parent  = TabContainer
            end
        end))

        Tab.SetValue = function(value)
            Tab.Signal:SetValue(value)
            if value then
                NeverLose.PlayAnimate(TabButton,       SlowyTween, { BackgroundTransparency = 0.5 })
                NeverLose.PlayAnimate(TabIcon,         SlowyTween, { TextTransparency = 0, TextColor3 = NeverLose.AccentColor })
                NeverLose.PlayAnimate(TabContentLabel, SlowyTween, { TextTransparency = 0 })
            else
                NeverLose.PlayAnimate(TabButton,       SlowyTween, { BackgroundTransparency = 1 })
                NeverLose.PlayAnimate(TabIcon,         SlowyTween, { TextTransparency = 0.5, TextColor3 = Color3.fromRGB(252,252,252) })
                NeverLose.PlayAnimate(TabContentLabel, SlowyTween, { TextTransparency = 0.5 })
            end
        end

        table.insert(Window.Tabs, Tab)
        Tab.SetValue(Window.Tabs[Window.CurrentTab] == Tab)

        local over = NeverLose:CreateInput(TabButton, function()
            for i, v in next, Window.Tabs do
                if v.Idx == TabButton then v.SetValue(true) Window.CurrentTab = i
                else v.SetValue(false) end
            end
        end)

        NeverLose:AddSignal(over.MouseEnter:Connect(function()
            NeverLose.PlayAnimate(TabButton, SlowyTween, { BackgroundTransparency = Window.Tabs[Window.CurrentTab] == Tab and 0.5 or 0.8 })
        end))
        NeverLose:AddSignal(over.MouseLeave:Connect(function()
            NeverLose.PlayAnimate(TabButton, SlowyTween, { BackgroundTransparency = Window.Tabs[Window.CurrentTab] == Tab and 0.5 or 1 })
        end))

        Window.Signal:Connect(function(value)
            if value then
                Tab.SetValue(Window.Tabs[Window.CurrentTab] == Tab)
            else
                Tab.SetValue(false)
                NeverLose.PlayAnimate(TabButton,       SlowyTween, { BackgroundTransparency = 1 })
                NeverLose.PlayAnimate(TabIcon,         SlowyTween, { TextTransparency = 1 })
                NeverLose.PlayAnimate(TabContentLabel, SlowyTween, { TextTransparency = 1 })
            end
        end)

        function Tab:AddSection(Config)
            Config = NeverLose:ProcessParams(Config, { Name = "SECTION", Position = 'left' })

            local SectionFrame   = Instance.new("Frame")
            local SectionLabel   = Instance.new("TextLabel")
            local SectionHandler = Instance.new("Frame")
            local UIStroke_s     = Instance.new("UIStroke")
            local UICorner_s     = Instance.new("UICorner")
            local UIListLayout_s = Instance.new("UIListLayout")

            SectionFrame.Name                  = NeverLose.RandomString()
            SectionFrame.Parent                = (string.lower(Config.Position) == 'left' and LeftScroll) or RightScroll
            SectionFrame.BackgroundTransparency = 1
            SectionFrame.BorderSizePixel       = 0
            SectionFrame.ClipsDescendants      = true
            SectionFrame.Size                  = UDim2.new(1, -5, 0, 0)
            SectionFrame.ZIndex                = 9

            SectionLabel.Name                  = NeverLose.RandomString()
            SectionLabel.Parent                = SectionFrame
            SectionLabel.AnchorPoint           = Vector2.new(0.5, 0)
            SectionLabel.BackgroundTransparency = 1
            SectionLabel.BorderSizePixel       = 0
            SectionLabel.Position              = UDim2.new(0.5, 0, 0, 0)
            SectionLabel.Size                  = UDim2.new(1, -35, 0, 15)
            SectionLabel.ZIndex                = 9
            SectionLabel.Font                  = Enum.Font.GothamMedium
            SectionLabel.Text                  = Config.Name
            SectionLabel.TextColor3            = Color3.fromRGB(255, 255, 255)
            SectionLabel.TextSize              = 11
            SectionLabel.TextTransparency      = 0.5
            SectionLabel.TextXAlignment        = Enum.TextXAlignment.Left

            SectionHandler.Name                = NeverLose.RandomString()
            SectionHandler.Parent              = SectionFrame
            SectionHandler.AnchorPoint         = Vector2.new(0.5, 0)
            SectionHandler.BackgroundColor3    = Color3.fromRGB(20, 22, 27)
            SectionHandler.BackgroundTransparency = 0.5
            SectionHandler.BorderSizePixel     = 0
            SectionHandler.ClipsDescendants    = true
            SectionHandler.Position            = UDim2.new(0.5, 0, 0, 20)
            SectionHandler.Size                = UDim2.new(1, -10, 1, -21)
            SectionHandler.ZIndex              = 9
            UIStroke_s.Transparency            = 0.65
            UIStroke_s.Color                   = Color3.fromRGB(45, 48, 58)
            UIStroke_s.Parent                  = SectionHandler
            UICorner_s.CornerRadius            = UDim.new(0, 10)
            UICorner_s.Parent                  = SectionHandler
            UIListLayout_s.Parent              = SectionHandler
            UIListLayout_s.HorizontalAlignment = Enum.HorizontalAlignment.Center
            UIListLayout_s.SortOrder           = Enum.SortOrder.LayoutOrder

            UIListLayout_s:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
                if UIListLayout_s.AbsoluteContentSize.Y <= 1 then
                    NeverLose.PlayAnimate(SectionFrame, VSlowTween, { Size = UDim2.new(1, -5, 0, 0) })
                else
                    NeverLose.PlayAnimate(SectionFrame, VSlowTween, { Size = UDim2.new(1, -5, 0, UIListLayout_s.AbsoluteContentSize.Y + 19.5) })
                end
            end)

            local Section = NeverLose:RegisiterItem(SectionHandler, Tab.Signal)
            Section.SetRender = function(value)
                NeverLose.PlayAnimate(SectionLabel,   SlowyTween, { TextTransparency = value and 0.5 or 1 })
                NeverLose.PlayAnimate(SectionHandler, SlowyTween, { BackgroundTransparency = value and 0.5 or 1 })
                NeverLose.PlayAnimate(UIStroke_s,     SlowyTween, { Transparency = value and 0.65 or 1 })
            end
            Section.SetRender(Tab.Signal:GetValue())
            Tab.Signal:Connect(Section.SetRender)
            return Section
        end

        return Tab
    end

    function Window:_InitConfig()
        local ConfigSignal = NeverLose:CreateSignal(false)
        local ConfigLib    = { Signals = {} }

        local ConfigMenu     = Instance.new("Frame")
        local UICorner_c     = Instance.new("UICorner")
        local UIListLayout_c = Instance.new("UIListLayout")
        local UIStroke_c     = Instance.new("UIStroke")
        local InputFrame     = Instance.new("Frame")
        local BasedLabel     = Instance.new("TextLabel")
        local LineFrame_c    = Instance.new("Frame")
        local BasedHandler   = Instance.new("Frame")
        local UIListLayout2  = Instance.new("UIListLayout")
        local TextInput      = Instance.new("Frame")
        local UICorner_c2    = Instance.new("UICorner")
        local UIStroke_c2    = Instance.new("UIStroke")
        local TextBox        = Instance.new("TextBox")
        local LoadConfig     = Instance.new("Frame")
        local Icon           = Instance.new("TextLabel")
        local UICorner_c3    = Instance.new("UICorner")
        local UICorner_c4    = Instance.new("UICorner")
        local shadow         = NeverLose:CreateShadow(ConfigMenu)

        ConfigLib.SetRender = function(value)
            if value then
                ConfigMenu.Position = UDim2.fromOffset(ConfigFrame.AbsolutePosition.X + 110, ConfigFrame.AbsolutePosition.Y + 96)
                NeverLose.PlayAnimate(ConfigMenu,   SlowyTween, { BackgroundTransparency = 0.035 })
                NeverLose.PlayAnimate(UIStroke_c,   SlowyTween, { Transparency = 0.65 })
                NeverLose.PlayAnimate(BasedLabel,   SlowyTween, { TextTransparency = 0.2 })
                NeverLose.PlayAnimate(UIStroke_c2,  SlowyTween, { Transparency = 0.65 })
                NeverLose.PlayAnimate(LineFrame_c,  SlowyTween, { BackgroundTransparency = 0.65 })
                NeverLose.PlayAnimate(TextInput,    SlowyTween, { BackgroundTransparency = 0 })
                NeverLose.PlayAnimate(TextBox,      SlowyTween, { TextTransparency = 0.35 })
                NeverLose.PlayAnimate(Icon,         SlowyTween, { TextTransparency = 0.35 })
                NeverLose.PlayAnimate(ConfigBthIcon, SlowyTween, { Rotation = 180 })
                shadow:Render(true)
            else
                NeverLose.PlayAnimate(ConfigBthIcon, SlowyTween, { Rotation = 0 })
                NeverLose.PlayAnimate(ConfigMenu,   SlowyTween, { BackgroundTransparency = 1 })
                NeverLose.PlayAnimate(UIStroke_c,   SlowyTween, { Transparency = 1 })
                NeverLose.PlayAnimate(UIStroke_c2,  SlowyTween, { Transparency = 1 })
                NeverLose.PlayAnimate(BasedLabel,   SlowyTween, { TextTransparency = 1 })
                NeverLose.PlayAnimate(LineFrame_c,  SlowyTween, { BackgroundTransparency = 1 })
                NeverLose.PlayAnimate(TextInput,    SlowyTween, { BackgroundTransparency = 1 })
                NeverLose.PlayAnimate(TextBox,      SlowyTween, { TextTransparency = 1 })
                NeverLose.PlayAnimate(Icon,         SlowyTween, { TextTransparency = 1 })
                shadow:Render(false)
            end
        end

        NeverLose:AddSignal(ConfigMenu:GetPropertyChangedSignal('BackgroundTransparency'):Connect(function()
            if ConfigMenu.BackgroundTransparency > 0.9 then
                ConfigMenu.Visible   = false
                UIListLayout_c.Parent = nil
                ConfigMenu.Parent    = nil
            else
                ConfigMenu.Visible   = true
                UIListLayout_c.Parent = ConfigMenu
                ConfigMenu.Parent    = NeverLose.ScreenGui
            end
        end))

        ConfigMenu.Name                  = NeverLose.RandomString()
        ConfigMenu.Parent                = NeverLose.ScreenGui
        ConfigMenu.AnchorPoint           = Vector2.new(0.5, 0)
        ConfigMenu.BackgroundColor3      = Color3.fromRGB(20, 22, 27)
        ConfigMenu.BackgroundTransparency = 0.035
        ConfigMenu.BorderSizePixel       = 0
        ConfigMenu.ClipsDescendants      = true
        ConfigMenu.Position              = UDim2.new(255,255,255,255)
        ConfigMenu.Size                  = UDim2.new(0, 220, 0, 110)
        ConfigMenu.ZIndex                = 151
        UICorner_c.CornerRadius          = UDim.new(0, 10)
        UICorner_c.Parent                = ConfigMenu
        UIListLayout_c.Parent            = ConfigMenu
        UIListLayout_c.HorizontalAlignment = Enum.HorizontalAlignment.Center
        UIListLayout_c.SortOrder         = Enum.SortOrder.LayoutOrder
        UIListLayout_c.Padding           = UDim.new(0, 4)
        UIStroke_c.Transparency          = 0.65
        UIStroke_c.Color                 = Color3.fromRGB(45, 48, 58)
        UIStroke_c.Parent                = ConfigMenu

        InputFrame.Name                  = NeverLose.RandomString()
        InputFrame.Parent                = ConfigMenu
        InputFrame.BackgroundColor3      = Color3.fromRGB(25, 27, 33)
        InputFrame.BackgroundTransparency = 1
        InputFrame.BorderSizePixel       = 0
        InputFrame.Size                  = UDim2.new(1, 0, 0, 30)
        InputFrame.ZIndex                = 154

        BasedLabel.Name                  = NeverLose.RandomString()
        BasedLabel.Parent                = InputFrame
        BasedLabel.BackgroundTransparency = 1
        BasedLabel.BorderSizePixel       = 0
        BasedLabel.Position              = UDim2.new(0, 11, 0, 6)
        BasedLabel.Size                  = UDim2.new(0, 1, 0, 15)
        BasedLabel.ZIndex                = 154
        BasedLabel.Font                  = Enum.Font.GothamMedium
        BasedLabel.Text                  = "Config"
        BasedLabel.TextColor3            = Color3.fromRGB(255, 255, 255)
        BasedLabel.TextSize              = 13
        BasedLabel.TextTransparency      = 0.2
        BasedLabel.TextXAlignment        = Enum.TextXAlignment.Left

        LineFrame_c.Name                 = NeverLose.RandomString()
        LineFrame_c.Parent               = InputFrame
        LineFrame_c.AnchorPoint          = Vector2.new(0.5, 1)
        LineFrame_c.BackgroundColor3     = Color3.fromRGB(45, 48, 58)
        LineFrame_c.BackgroundTransparency = 0.65
        LineFrame_c.BorderSizePixel      = 0
        LineFrame_c.Position             = UDim2.new(0.5, 0, 1, 0)
        LineFrame_c.Size                 = UDim2.new(1, -20, 0, 1)
        LineFrame_c.ZIndex               = 154

        BasedHandler.Name                = NeverLose.RandomString()
        BasedHandler.Parent              = InputFrame
        BasedHandler.AnchorPoint         = Vector2.new(1, 0)
        BasedHandler.BackgroundTransparency = 1
        BasedHandler.BorderSizePixel     = 0
        BasedHandler.Position            = UDim2.new(1, -11, 0, 2)
        BasedHandler.Size                = UDim2.new(1, -20, 0, 25)
        BasedHandler.ZIndex              = 154
        UIListLayout2.Parent             = BasedHandler
        UIListLayout2.FillDirection      = Enum.FillDirection.Horizontal
        UIListLayout2.HorizontalAlignment = Enum.HorizontalAlignment.Right
        UIListLayout2.SortOrder          = Enum.SortOrder.LayoutOrder
        UIListLayout2.VerticalAlignment  = Enum.VerticalAlignment.Center
        UIListLayout2.Padding            = UDim.new(0, 5)

        NeverLose:AddSignal(UIListLayout_c:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
            NeverLose.PlayAnimate(ConfigMenu, SlowyTween, {
                Size = UDim2.new(0, 220, 0, UIListLayout_c.AbsoluteContentSize.Y + (#ConfigLib.Signals > 0 and 5 or 0))
            })
        end))

        TextInput.Name                   = NeverLose.RandomString()
        TextInput.Parent                 = BasedHandler
        TextInput.BackgroundColor3       = Color3.fromRGB(26, 28, 36)
        TextInput.BorderSizePixel        = 0
        TextInput.ClipsDescendants       = true
        TextInput.Size                   = UDim2.new(0, 100, 0, 18)
        TextInput.ZIndex                 = 154
        UICorner_c2.CornerRadius         = UDim.new(0, 4)
        UICorner_c2.Parent               = TextInput
        UIStroke_c2.Transparency         = 0.65
        UIStroke_c2.Color                = Color3.fromRGB(45, 48, 58)
        UIStroke_c2.Parent               = TextInput

        TextBox.Parent                   = TextInput
        TextBox.AnchorPoint              = Vector2.new(0, 0.5)
        TextBox.BackgroundTransparency   = 1
        TextBox.BorderSizePixel          = 0
        TextBox.Position                 = UDim2.new(0, 5, 0.5, 0)
        TextBox.Size                     = UDim2.new(1, -5, 0, 17)
        TextBox.ZIndex                   = 154
        TextBox.ClearTextOnFocus         = false
        TextBox.Font                     = Enum.Font.GothamMedium
        TextBox.PlaceholderText          = "Config Name ..."
        TextBox.Text                     = ""
        TextBox.TextColor3               = Color3.fromRGB(255, 255, 255)
        TextBox.TextSize                 = 11
        TextBox.TextTransparency         = 0.35
        TextBox.TextXAlignment           = Enum.TextXAlignment.Left

        LoadConfig.Name                  = NeverLose.RandomString()
        LoadConfig.Parent                = BasedHandler
        LoadConfig.BackgroundColor3      = Color3.fromRGB(39, 40, 49)
        LoadConfig.BackgroundTransparency = 1
        LoadConfig.BorderSizePixel       = 0
        LoadConfig.ClipsDescendants      = true
        LoadConfig.Size                  = UDim2.new(0, 20, 0, 18)
        LoadConfig.ZIndex                = 153

        Icon.Name                        = NeverLose.RandomString()
        Icon.Parent                      = LoadConfig
        Icon.AnchorPoint                 = Vector2.new(0.5, 0.5)
        Icon.BackgroundTransparency      = 1
        Icon.BorderSizePixel             = 0
        Icon.Position                    = UDim2.new(0.5, 0, 0.5, 0)
        Icon.Size                        = UDim2.new(1, 0, 1, 0)
        Icon.ZIndex                      = 153
        Icon.FontFace                    = NeverLose.BuiltInBold
        Icon.Text                        = "plus-large"
        Icon.TextColor3                  = Color3.fromRGB(223, 223, 223)
        Icon.TextSize                    = 16
        Icon.TextTransparency            = 0.35
        Icon.TextWrapped                 = true
        UICorner_c3.CornerRadius         = UDim.new(0, 4)
        UICorner_c3.Parent               = LoadConfig
        UICorner_c4.CornerRadius         = UDim.new(0, 10)
        UICorner_c4.Parent               = InputFrame

        local OpenButton = Instance.new("TextButton")
        local UICorner_ob = Instance.new("UICorner")
        OpenButton.Name                  = NeverLose.RandomString()
        OpenButton.Parent                = ConfigFrame
        OpenButton.AnchorPoint           = Vector2.new(0, 0.5)
        OpenButton.BackgroundTransparency = 1
        OpenButton.BorderSizePixel       = 0
        OpenButton.Position              = UDim2.new(0, 31, 0.5, 0)
        OpenButton.Size                  = UDim2.new(1, -31, 1, 0)
        OpenButton.ZIndex                = 10
        OpenButton.Font                  = Enum.Font.SourceSans
        OpenButton.Text                  = ""
        OpenButton.TextColor3            = Color3.fromRGB(0, 0, 0)
        OpenButton.TextSize              = 14
        UICorner_ob.CornerRadius         = UDim.new(0, 4)
        UICorner_ob.Parent               = OpenButton

        ConfigLib.SetRender(false)
        ConfigSignal:Connect(ConfigLib.SetRender)
        ConfigLib.UnsafeThread   = nil
        ConfigLib.SelectedConfig = "Default"

        local function UpdateSize()
            local size = TextService:GetTextSize(ConfigName.Text, ConfigName.TextSize, ConfigName.Font, Vector2.new(math.huge, math.huge))
            NeverLose.PlayAnimate(ConfigFrame, SlowyTween, { Size = UDim2.fromOffset(size.X + 75, 30) })
        end
        UpdateSize()

        function ConfigLib:GetData(performance)
            local ikc = {}
            local cd  = 0
            for Flag, v in next, NeverLose.Flags do
                if v and v.GetValue then
                    local data = v:GetValue()
                    if typeof(data) == 'Color3' then
                        table.insert(ikc, { Idx = Flag, Value = data:ToHex() })
                    else
                        table.insert(ikc, { Idx = Flag, Value = data })
                    end
                end
                if performance and cd % 35 == 1 then task.wait() end
                cd += 1
            end
            return NeverLose.Base64Encode(Encryption.new(HttpService:JSONEncode(ikc)))
        end

        function ConfigLib:LoadData(data)
            local coded = HttpService:JSONDecode(Encryption.reverse(NeverLose.Base64Decode(data)))
            for _, v in next, coded do
                if v.Idx and NeverLose.Flags[v.Idx] then
                    task.spawn(function() NeverLose.Flags[v.Idx]:SetValue(v.Value) end)
                end
            end
        end

        function ConfigLib:RefreshConfig()
            if not isfolder(Window.ConfigFolder) then makefolder(Window.ConfigFolder) end
            if not isfile(Window.ConfigFolder .. '/Default') then
                writefile(Window.ConfigFolder .. '/Default', ConfigLib:GetData())
            end
            for _, v in next, ConfigMenu:GetChildren() do
                if v:GetAttribute('ConfigItem') then v:Destroy() end
            end
            for _, v in next, ConfigLib.Signals do v:Disconnect() end
            table.clear(ConfigLib.Signals)

            local ConfigList = {}
            for _, v in next, listfiles(Window.ConfigFolder) do
                table.insert(ConfigList, string.sub(v, #Window.ConfigFolder + 2))
            end

            for _, ConfigNameStr in next, ConfigList do
                local ConfigItemFrame = Instance.new("Frame")
                local BasedHandler_i  = Instance.new("Frame")
                local UIListLayout_i  = Instance.new("UIListLayout")
                local DeleteConfig    = Instance.new("Frame")
                local Icon_d          = Instance.new("TextLabel")
                local UICorner_d      = Instance.new("UICorner")
                local LoadConfig_i    = Instance.new("Frame")
                local Icon_l          = Instance.new("TextLabel")
                local UICorner_l      = Instance.new("UICorner")
                local UICorner_i      = Instance.new("UICorner")
                local BasedLabel_i    = Instance.new("TextLabel")
                local UIStroke_i      = Instance.new("UIStroke")

                ConfigItemFrame.Name                  = NeverLose.RandomString()
                ConfigItemFrame.Parent                = ConfigMenu
                ConfigItemFrame.BackgroundColor3      = Color3.fromRGB(21, 20, 27)
                ConfigItemFrame.BorderSizePixel       = 0
                ConfigItemFrame.Size                  = UDim2.new(1, -10, 0, 30)
                ConfigItemFrame.ZIndex                = 153
                ConfigItemFrame:SetAttribute('ConfigItem', true)

                BasedHandler_i.Name                   = NeverLose.RandomString()
                BasedHandler_i.Parent                 = ConfigItemFrame
                BasedHandler_i.AnchorPoint            = Vector2.new(1, 0)
                BasedHandler_i.BackgroundTransparency = 1
                BasedHandler_i.BorderSizePixel        = 0
                BasedHandler_i.Position               = UDim2.new(1, -11, 0, 2)
                BasedHandler_i.Size                   = UDim2.new(1, -20, 0, 25)
                BasedHandler_i.ZIndex                 = 153
                UIListLayout_i.Parent                 = BasedHandler_i
                UIListLayout_i.FillDirection          = Enum.FillDirection.Horizontal
                UIListLayout_i.HorizontalAlignment    = Enum.HorizontalAlignment.Right
                UIListLayout_i.SortOrder              = Enum.SortOrder.LayoutOrder
                UIListLayout_i.VerticalAlignment      = Enum.VerticalAlignment.Center
                UIListLayout_i.Padding                = UDim.new(0, 5)

                DeleteConfig.Name                     = NeverLose.RandomString()
                DeleteConfig.Parent                   = BasedHandler_i
                DeleteConfig.BackgroundColor3         = Color3.fromRGB(39, 40, 49)
                DeleteConfig.BackgroundTransparency   = 1
                DeleteConfig.BorderSizePixel          = 0
                DeleteConfig.ClipsDescendants         = true
                DeleteConfig.Size                     = UDim2.new(0, 20, 0, 18)
                DeleteConfig.ZIndex                   = 153
                Icon_d.Name                           = NeverLose.RandomString()
                Icon_d.Parent                         = DeleteConfig
                Icon_d.AnchorPoint                    = Vector2.new(0.5, 0.5)
                Icon_d.BackgroundTransparency         = 1
                Icon_d.BorderSizePixel                = 0
                Icon_d.Position                       = UDim2.new(0.5, 0, 0.5, 0)
                Icon_d.Size                           = UDim2.new(1, 0, 1, 0)
                Icon_d.ZIndex                         = 153
                Icon_d.FontFace                       = NeverLose.BuiltInBold
                Icon_d.Text                           = "trash-can"
                Icon_d.TextColor3                     = Color3.fromRGB(223, 223, 223)
                Icon_d.TextSize                       = 16
                Icon_d.TextTransparency               = 0.4
                Icon_d.TextWrapped                    = true
                UICorner_d.CornerRadius               = UDim.new(0, 4)
                UICorner_d.Parent                     = DeleteConfig

                LoadConfig_i.Name                     = NeverLose.RandomString()
                LoadConfig_i.Parent                   = BasedHandler_i
                LoadConfig_i.BackgroundColor3         = Color3.fromRGB(39, 40, 49)
                LoadConfig_i.BackgroundTransparency   = 1
                LoadConfig_i.BorderSizePixel          = 0
                LoadConfig_i.ClipsDescendants         = true
                LoadConfig_i.Size                     = UDim2.new(0, 20, 0, 18)
                LoadConfig_i.ZIndex                   = 153
                Icon_l.Name                           = NeverLose.RandomString()
                Icon_l.Parent                         = LoadConfig_i
                Icon_l.AnchorPoint                    = Vector2.new(0.5, 0.5)
                Icon_l.BackgroundTransparency         = 1
                Icon_l.BorderSizePixel                = 0
                Icon_l.Position                       = UDim2.new(0.5, 0, 0.5, 0)
                Icon_l.Size                           = UDim2.new(1, 0, 1, 0)
                Icon_l.ZIndex                         = 153
                Icon_l.FontFace                       = NeverLose.BuiltInBold
                Icon_l.Text                           = "arrow-right-from-portrait-rectangle"
                Icon_l.TextColor3                     = Color3.fromRGB(223, 223, 223)
                Icon_l.TextSize                       = 16
                Icon_l.TextTransparency               = 0.4
                Icon_l.TextWrapped                    = true
                UICorner_l.CornerRadius               = UDim.new(0, 4)
                UICorner_l.Parent                     = LoadConfig_i
                UICorner_i.CornerRadius               = UDim.new(0, 5)
                UICorner_i.Parent                     = ConfigItemFrame

                BasedLabel_i.Name                     = NeverLose.RandomString()
                BasedLabel_i.Parent                   = ConfigItemFrame
                BasedLabel_i.BackgroundTransparency   = 1
                BasedLabel_i.BorderSizePixel          = 0
                BasedLabel_i.Position                 = UDim2.new(0, 11, 0, 7)
                BasedLabel_i.Size                     = UDim2.new(0, 1, 0, 15)
                BasedLabel_i.ZIndex                   = 153
                BasedLabel_i.Font                     = Enum.Font.GothamMedium
                BasedLabel_i.Text                     = ConfigNameStr
                BasedLabel_i.TextColor3               = Color3.fromRGB(255, 255, 255)
                BasedLabel_i.TextSize                 = 13
                BasedLabel_i.TextTransparency         = 0.2
                BasedLabel_i.TextXAlignment           = Enum.TextXAlignment.Left
                UIStroke_i.Transparency               = 0.5
                UIStroke_i.Color                      = Color3.fromRGB(45, 48, 58)
                UIStroke_i.Parent                     = ConfigItemFrame

                local function Render(rst)
                    NeverLose.PlayAnimate(ConfigItemFrame, SlowyTween, { BackgroundTransparency = rst and 0 or 1 })
                    NeverLose.PlayAnimate(Icon_d,          SlowyTween, { TextTransparency = rst and 0.4 or 1 })
                    NeverLose.PlayAnimate(Icon_l,          SlowyTween, { TextTransparency = rst and 0.4 or 1 })
                    NeverLose.PlayAnimate(BasedLabel_i,    SlowyTween, { TextTransparency = rst and 0.2 or 1 })
                    NeverLose.PlayAnimate(UIStroke_i,      SlowyTween, { Transparency = rst and 0.5 or 1 })
                end
                Render(ConfigSignal:GetValue())
                table.insert(ConfigLib.Signals, ConfigSignal:Connect(Render))
                table.insert(ConfigLib.Signals, ConfigItemFrame.MouseEnter:Connect(function()
                    NeverLose.PlayAnimate(UIStroke_i, SlowyTween, { Transparency = 0.25 })
                end))
                table.insert(ConfigLib.Signals, ConfigItemFrame.MouseLeave:Connect(function()
                    NeverLose.PlayAnimate(UIStroke_i, SlowyTween, { Transparency = 0.5 })
                end))

                local deleter, dsig = NeverLose:CreateInput(DeleteConfig, function()
                    if ConfigNameStr == "Default" then
                        Logging.new("trash-can", "You can't delete default config!", 3.5)
                        return
                    end
                    delfile(Window.ConfigFolder .. '/' .. ConfigNameStr)
                    UpdateSize()
                    ConfigLib:RefreshConfig()
                    Logging.new("trash-can", 'Deleted ' .. ConfigNameStr, 3.5)
                end)
                local _, lsig = NeverLose:CreateInput(LoadConfig_i, function()
                    local path = Window.ConfigFolder .. '/' .. ConfigNameStr
                    if isfile(path) then
                        ConfigLib:LoadData(readfile(path))
                        ConfigLib.SelectedConfig = ConfigNameStr
                        ConfigName.Text          = ConfigNameStr
                        UpdateSize()
                        ConfigLib:RefreshConfig()
                        Logging.new("folder", 'Loaded ' .. ConfigNameStr, 3.5)
                    end
                end)
                table.insert(ConfigLib.Signals, dsig)
                table.insert(ConfigLib.Signals, lsig)
                table.insert(ConfigLib.Signals, deleter.MouseEnter:Connect(function()
                    NeverLose.PlayAnimate(Icon_d, SlowyTween, { TextTransparency = 0.2, TextColor3 = Color3.fromRGB(223,125,125) })
                end))
                table.insert(ConfigLib.Signals, deleter.MouseLeave:Connect(function()
                    NeverLose.PlayAnimate(Icon_d, SlowyTween, { TextTransparency = 0.4, TextColor3 = Color3.fromRGB(223,223,223) })
                end))
                table.insert(ConfigLib.Signals, LoadConfig_i.MouseEnter:Connect(function()
                    NeverLose.PlayAnimate(Icon_l, SlowyTween, { TextTransparency = 0.2, TextColor3 = NeverLose.AccentColor })
                end))
                table.insert(ConfigLib.Signals, LoadConfig_i.MouseLeave:Connect(function()
                    NeverLose.PlayAnimate(Icon_l, SlowyTween, { TextTransparency = 0.4, TextColor3 = Color3.fromRGB(223,223,223) })
                end))
            end
            table.clear(ConfigList)
        end

        task.delay(1, function()
            if ConfigLib.SelectedConfig == "Default" then
                local path = Window.ConfigFolder .. '/Default'
                if isfile(path) then
                    ConfigLib:LoadData(readfile(path))
                    ConfigLib.SelectedConfig = "Default"
                    ConfigName.Text          = "Default"
                    UpdateSize()
                    ConfigLib:RefreshConfig()
                    Logging.new("folder", "Loaded Default Config", 3.5)
                    task.spawn(function()
                        while true do
                            task.wait(5.75)
                            if isfile(path) and ConfigLib.SelectedConfig == "Default" then
                                writefile(Window.ConfigFolder .. '/Default', ConfigLib:GetData(true))
                            end
                        end
                    end)
                end
            end
        end)

        local hoverWrite = NeverLose:CreateInput(ConfigIcon, function()
            local path = Window.ConfigFolder .. '/' .. (ConfigLib.SelectedConfig or "Default")
            if isfile(path) then
                writefile(path, ConfigLib:GetData())
                Logging.new("folder", 'Saved ' .. tostring(ConfigLib.SelectedConfig), 3.5)
            end
        end)
        NeverLose:AddSignal(hoverWrite.MouseEnter:Connect(function()
            NeverLose.PlayAnimate(ConfigIcon, SlowyTween, { TextTransparency = 0.1 })
        end))
        NeverLose:AddSignal(hoverWrite.MouseLeave:Connect(function()
            NeverLose.PlayAnimate(ConfigIcon, SlowyTween, { TextTransparency = 0.25 })
        end))

        local mv = NeverLose:CreateInput(LoadConfig, function()
            local name = TextBox.Text
            if name and name:byte() and not name:find('/', 1, true) and not name:find('\\', 1, true) then
                name = string.sub(name, 1, 24)
                writefile(Window.ConfigFolder .. '/' .. name, ConfigLib:GetData())
                ConfigLib.SelectedConfig = name
                ConfigName.Text          = name
                Logging.new("folder", 'Created ' .. name, 3.5)
                TextBox.Text = ""
                UpdateSize()
                ConfigLib:RefreshConfig()
            end
        end)
        NeverLose:AddSignal(mv.MouseEnter:Connect(function() NeverLose.PlayAnimate(Icon, SlowyTween, { TextTransparency = 0.1 }) end))
        NeverLose:AddSignal(mv.MouseLeave:Connect(function() NeverLose.PlayAnimate(Icon, SlowyTween, { TextTransparency = 0.35 }) end))

        ConfigLib:RefreshConfig()

        OpenButton.MouseButton1Click:Connect(function()
            if ConfigLib.UnsafeThread then ConfigLib.UnsafeThread:Disconnect() ConfigLib.UnsafeThread = nil end
            ConfigSignal:SetValue(true)
            ConfigLib.UnsafeThread = UserInputService.InputBegan:Connect(function(Input)
                if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch)
                and not NeverLose:IsMouseOverFrame(nil, ConfigMenu) then
                    if ConfigLib.UnsafeThread then ConfigLib.UnsafeThread:Disconnect() ConfigLib.UnsafeThread = nil end
                    ConfigSignal:SetValue(false)
                end
            end)
        end)
        return ConfigLib
    end

    Window:_InitConfig()

    NeverLose:AddSignal(UserInputService.InputBegan:Connect(function(value, ISTYPING)
        if not ISTYPING and (value.KeyCode == Window.Keybind or value.KeyCode.Name == Window.Keybind) then
            Window:ToggleInterface()
        end
    end))

    function Window:ToggleInterface()
        Window.Signal:SetValue(not Window.Signal:GetValue())
    end

    function Window:SetSize(newsize)
        Window.Size = newsize
        if Window.Signal:GetValue() then
            NeverLose.PlayAnimate(WindowFrame, VSlowTween, { Size = Window.Size })
        end
    end

    Window:SetRender(false)
    return Window
end

function NeverLose:CreateNotification()
    if NeverLose.__Notification_Cache then return NeverLose.__Notification_Cache end

    local Notifier    = {}
    local Notification = Instance.new("Frame")
    local UIListLayout = Instance.new("UIListLayout")

    Notification.Name                  = NeverLose.RandomString()
    Notification.Parent                = NeverLose.ScreenGui
    Notification.AnchorPoint           = Vector2.new(1, 0)
    Notification.BackgroundTransparency = 1
    Notification.BorderSizePixel       = 0
    Notification.Position              = UDim2.new(1, -25, 0, 25)
    Notification.Size                  = UDim2.new(0, 25, 0, 25)
    UIListLayout.Parent                = Notification
    UIListLayout.HorizontalAlignment   = Enum.HorizontalAlignment.Right
    UIListLayout.SortOrder             = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding               = UDim.new(0, 0)

    NeverLose.__Notification_Cache = Notifier

    function Notifier.new(Config)
        Config = NeverLose:ProcessParams(Config, {
            Title = "Notification", Content = "Hello World!",
            Logo = NeverLose.GlobalLogo or "rbxasset://textures/ui/VerifiedBadgeNameIcon.png", Duration = 5,
        })

        local ContainerFrame  = Instance.new("Frame")
        local NotifyFrame     = Instance.new("Frame")
        local UICorner_n      = Instance.new("UICorner")
        local UIStroke_n      = Instance.new("UIStroke")
        local LogoImage_n     = Instance.new("ImageLabel")
        local UICorner_n2     = Instance.new("UICorner")
        local NotifyName      = Instance.new("TextLabel")
        local NotifyContent   = Instance.new("TextLabel")
        local shadow          = NeverLose:CreateShadow(NotifyFrame, true)

        ContainerFrame.Name                  = NeverLose.RandomString()
        ContainerFrame.Parent                = Notification
        ContainerFrame.BackgroundTransparency = 1
        ContainerFrame.BorderSizePixel       = 0
        ContainerFrame.Size                  = UDim2.new(0, 0, 0, 100)

        NotifyFrame.Name                     = NeverLose.RandomString()
        NotifyFrame.Parent                   = ContainerFrame
        NotifyFrame.AnchorPoint              = Vector2.new(1, 0)
        NotifyFrame.BackgroundColor3         = Color3.fromRGB(20, 22, 27)
        NotifyFrame.BackgroundTransparency   = 0.075
        NotifyFrame.BorderSizePixel          = 0
        NotifyFrame.ClipsDescendants         = true
        NotifyFrame.Position                 = UDim2.new(0, 750, 0, 0)
        NotifyFrame.Size                     = UDim2.new(0, 220, 0, 55)
        NotifyFrame.ZIndex                   = 130
        UICorner_n.CornerRadius              = UDim.new(0, 10)
        UICorner_n.Parent                    = NotifyFrame
        UIStroke_n.Transparency              = 0.65
        UIStroke_n.Color                     = Color3.fromRGB(45, 48, 58)
        UIStroke_n.Parent                    = NotifyFrame

        LogoImage_n.Name                     = NeverLose.RandomString()
        LogoImage_n.Parent                   = NotifyFrame
        LogoImage_n.AnchorPoint              = Vector2.new(0, 0.5)
        LogoImage_n.BackgroundTransparency   = 1
        LogoImage_n.BorderSizePixel          = 0
        LogoImage_n.Position                 = UDim2.new(0, 10, 0.5, 0)
        LogoImage_n.Size                     = UDim2.new(0, 35, 0, 35)
        LogoImage_n.ZIndex                   = 131
        LogoImage_n.Image                    = Config.Logo
        LogoImage_n.ImageColor3              = NeverLose.IconColor
        UICorner_n2.CornerRadius             = UDim.new(0, 7)
        UICorner_n2.Parent                   = LogoImage_n

        NotifyName.Name                      = NeverLose.RandomString()
        NotifyName.Parent                    = NotifyFrame
        NotifyName.BackgroundTransparency    = 1
        NotifyName.BorderSizePixel           = 0
        NotifyName.Position                  = UDim2.new(0, 50, 0, 7)
        NotifyName.Size                      = UDim2.new(0, 200, 0, 20)
        NotifyName.ZIndex                    = 132
        NotifyName.Font                      = Enum.Font.GothamBold
        NotifyName.Text                      = Config.Title
        NotifyName.TextColor3                = Color3.fromRGB(255, 255, 255)
        NotifyName.TextSize                  = 17
        NotifyName.TextXAlignment            = Enum.TextXAlignment.Left

        NotifyContent.Name                   = NeverLose.RandomString()
        NotifyContent.Parent                 = NotifyFrame
        NotifyContent.BackgroundTransparency = 1
        NotifyContent.BorderSizePixel        = 0
        NotifyContent.Position               = UDim2.new(0, 50, 0, 28)
        NotifyContent.Size                   = UDim2.new(0, 200, 0, 15)
        NotifyContent.ZIndex                 = 132
        NotifyContent.Font                   = Enum.Font.GothamBold
        NotifyContent.Text                   = Config.Content
        NotifyContent.TextColor3             = Color3.fromRGB(255, 255, 255)
        NotifyContent.TextSize               = 12
        NotifyContent.TextTransparency       = 0.65
        NotifyContent.TextXAlignment         = Enum.TextXAlignment.Left

        local s1 = TextService:GetTextSize(NotifyName.Text,    NotifyName.TextSize,    NotifyName.Font,    Vector2.new(math.huge, math.huge))
        local s2 = TextService:GetTextSize(NotifyContent.Text, NotifyContent.TextSize, NotifyContent.Font, Vector2.new(math.huge, math.huge))
        NotifyFrame.Size = UDim2.new(0, math.max(s1.X, s2.X) + 65, 0, 55)

        shadow:Render(true)
        NeverLose.PlayAnimate(NotifyFrame, VSlowTween, { Position = UDim2.new(1, 0, 0, 0) })
        ContainerFrame.Size = UDim2.new(0, 0, 0, 65)

        task.delay(Config.Duration or 5, function()
            shadow:Render(false)
            NeverLose.PlayAnimate(NotifyFrame,   SlowyTween, { BackgroundTransparency = 1 })
            NeverLose.PlayAnimate(UIStroke_n,    SlowyTween, { Transparency = 1 })
            NeverLose.PlayAnimate(LogoImage_n,   SlowyTween, { ImageTransparency = 1 })
            NeverLose.PlayAnimate(NotifyName,    SlowyTween, { TextTransparency = 1 })
            NeverLose.PlayAnimate(NotifyContent, SlowyTween, { TextTransparency = 1 })
            task.wait(0.125)
            NeverLose.PlayAnimate(ContainerFrame, SlowyTween, { Size = UDim2.new(0, 0, 0, 0) })
            task.wait(0.125)
            ContainerFrame:Destroy()
        end)
    end

    return Notifier
end

function NeverLose:CreateLogger()
    if NeverLose.__LogSystem then return NeverLose.__LogSystem end

    local Logging      = {}
    local Log          = Instance.new("Frame")
    local UIListLayout = Instance.new("UIListLayout")

    Log.Name                  = NeverLose.RandomString()
    Log.Parent                = NeverLose.ScreenGui
    Log.BackgroundTransparency = 1
    Log.BorderSizePixel       = 0
    Log.Position              = UDim2.new(0, 25, 0, 5 + math.abs(NeverLose.ScreenGui.AbsolutePosition.Y))
    Log.Size                  = UDim2.new(0, 25, 0, 25)
    UIListLayout.Parent       = Log
    UIListLayout.SortOrder    = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding      = UDim.new(0, 12)

    NeverLose.__LogSystem = Logging

    function Logging.new(IconStr, Message, Duration)
        Duration = Duration or 3
        Message  = Message  or "Log"
        IconStr  = IconStr  or "crosshairs"

        local LogFrame   = Instance.new("Frame")
        local UICorner_l = Instance.new("UICorner")
        local UIStroke_l = Instance.new("UIStroke")
        local LogContent = Instance.new("TextLabel")
        local Line       = Instance.new("Frame")
        local UICorner_l2 = Instance.new("UICorner")
        local Icon       = Instance.new("TextLabel")
        local Shadow     = NeverLose:CreateShadow(LogFrame, true)

        LogFrame.Name                  = NeverLose.RandomString()
        LogFrame.Parent                = Log
        LogFrame.AnchorPoint           = Vector2.new(0.5, 0)
        LogFrame.BackgroundColor3      = Color3.fromRGB(20, 22, 27)
        LogFrame.BackgroundTransparency = 1
        LogFrame.BorderSizePixel       = 0
        LogFrame.ClipsDescendants      = true
        LogFrame.Position              = UDim2.new(0,0,0,0)
        LogFrame.Size                  = UDim2.new(0, 0, 0, 20)
        LogFrame.ZIndex                = 130
        UICorner_l.CornerRadius        = UDim.new(0, 4)
        UICorner_l.Parent              = LogFrame
        UIStroke_l.Transparency        = 1
        UIStroke_l.Color               = Color3.fromRGB(45, 48, 58)
        UIStroke_l.Parent              = LogFrame

        LogContent.Name                = NeverLose.RandomString()
        LogContent.Parent              = LogFrame
        LogContent.BackgroundTransparency = 1
        LogContent.BorderSizePixel     = 0
        LogContent.Position            = UDim2.new(0, 25, 0, 2)
        LogContent.Size                = UDim2.new(0, 200, 0, 15)
        LogContent.ZIndex              = 132
        LogContent.Font                = Enum.Font.GothamBold
        LogContent.Text                = Message
        LogContent.TextColor3          = Color3.fromRGB(255, 255, 255)
        LogContent.TextSize            = 12
        LogContent.TextTransparency    = 1
        LogContent.TextXAlignment      = Enum.TextXAlignment.Left

        Line.Name                      = NeverLose.RandomString()
        Line.Parent                    = LogFrame
        Line.AnchorPoint               = Vector2.new(0, 0.5)
        Line.BackgroundColor3          = NeverLose.AccentColor
        Line.BackgroundTransparency    = 1
        Line.BorderSizePixel           = 0
        Line.Position                  = UDim2.new(0, -2, 0.5, 0)
        Line.Size                      = UDim2.new(0, 5, 1, 0)
        Line.ZIndex                    = 131
        UICorner_l2.CornerRadius       = UDim.new(0, 4)
        UICorner_l2.Parent             = Line

        Icon.Name                      = NeverLose.RandomString()
        Icon.Parent                    = LogFrame
        Icon.BackgroundTransparency    = 1
        Icon.BorderSizePixel           = 0
        Icon.Position                  = UDim2.new(0, 7, 0, 3)
        Icon.Size                      = UDim2.new(0, 15, 0, 15)
        Icon.ZIndex                    = 133
        Icon.FontFace                  = NeverLose.BuiltInBold
        Icon.Text                      = IconStr
        Icon.TextColor3                = Color3.fromRGB(223, 223, 223)
        Icon.TextSize                  = 13
        Icon.TextTransparency          = 1
        Icon.TextWrapped               = true

        local size = TextService:GetTextSize(LogContent.Text, LogContent.TextSize, LogContent.Font, Vector2.new(math.huge, math.huge))
        NeverLose.PlayAnimate(LogFrame, SlowyTween, { Size = UDim2.new(0, size.X + 35, 0, 20), BackgroundTransparency = 0.075 })

        task.delay(0.15, function()
            Shadow:Render(true)
            NeverLose.PlayAnimate(UIStroke_l, SlowyTween, { Transparency = 0.65 })
            NeverLose.PlayAnimate(LogContent, SlowyTween, { TextTransparency = 0.25 })
            NeverLose.PlayAnimate(Line,       SlowyTween, { BackgroundTransparency = 0 })
            NeverLose.PlayAnimate(Icon,       SlowyTween, { TextTransparency = 0.25 })
            task.wait(Duration + 0.1)
            Shadow:Render(false)
            NeverLose.PlayAnimate(LogFrame,   SlowyTween, { BackgroundTransparency = 1 })
            NeverLose.PlayAnimate(UIStroke_l, SlowyTween, { Transparency = 1 })
            NeverLose.PlayAnimate(LogContent, SlowyTween, { TextTransparency = 1 })
            NeverLose.PlayAnimate(Line,       SlowyTween, { BackgroundTransparency = 1 })
            NeverLose.PlayAnimate(Icon,       SlowyTween, { TextTransparency = 1 })
            task.wait(0.25)
            LogFrame:Destroy()
        end)
    end

    return Logging
end

function NeverLose:CreateIndicator()
    local IndicatorFrame = Instance.new("Frame")
    local UIListLayout   = Instance.new("UIListLayout")

    IndicatorFrame.Name                  = NeverLose.RandomString()
    IndicatorFrame.Parent                = NeverLose.ScreenGui
    IndicatorFrame.AnchorPoint           = Vector2.new(0, 0.5)
    IndicatorFrame.BackgroundTransparency = 1
    IndicatorFrame.BorderSizePixel       = 0
    IndicatorFrame.Position              = UDim2.new(0, 15, 0.5, 0)
    IndicatorFrame.Size                  = UDim2.new(0, 100, 0, 100)
    IndicatorFrame.ZIndex                = 15
    UIListLayout.Parent                  = IndicatorFrame
    UIListLayout.SortOrder               = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding                 = UDim.new(0, 10)

    local Indicators = {
        Color = {
            Red   = Color3.fromRGB(255, 102, 105),
            Green = Color3.fromRGB(135, 255, 143),
            White = Color3.fromRGB(186, 186, 186),
        },
        Root = IndicatorFrame,
    }

    function Indicators.new(Config)
        Config = NeverLose:ProcessParams(Config, { Name = "Indicator", Icon = 'crosshairs', Color = 'Red' })
        local Indicator = { CurrentColor = Config.Color, Visible = false }

        local IndicatorItem  = Instance.new("Frame")
        local UICorner_i     = Instance.new("UICorner")
        local Line           = Instance.new("Frame")
        local UICorner_i2    = Instance.new("UICorner")
        local UIGradient_i   = Instance.new("UIGradient")
        local Icon           = Instance.new("TextLabel")
        local Content        = Instance.new("TextLabel")
        local Shadow         = NeverLose:CreateShadow(IndicatorItem)

        IndicatorItem.Name                  = NeverLose.RandomString()
        IndicatorItem.BackgroundColor3      = Color3.fromRGB(8, 8, 13)
        IndicatorItem.BackgroundTransparency = 1
        IndicatorItem.BorderSizePixel       = 0
        IndicatorItem.ClipsDescendants      = true
        IndicatorItem.Size                  = UDim2.new(0, 85, 0, 40)
        IndicatorItem.ZIndex                = 16
        IndicatorItem.Visible               = false

        IndicatorItem:GetPropertyChangedSignal('BackgroundTransparency'):Connect(function()
            if IndicatorItem.BackgroundTransparency > 0.9 then
                IndicatorItem.Parent  = nil
                IndicatorItem.Visible = false
            else
                IndicatorItem.Parent  = IndicatorFrame
                IndicatorItem.Visible = true
            end
        end)

        UICorner_i.CornerRadius  = UDim.new(0, 25)
        UICorner_i.Parent        = IndicatorItem

        Line.Name                = NeverLose.RandomString()
        Line.Parent              = IndicatorItem
        Line.AnchorPoint         = Vector2.new(0, 0.5)
        Line.BackgroundColor3    = Color3.fromRGB(186, 186, 186)
        Line.BackgroundTransparency = 1
        Line.BorderSizePixel     = 0
        Line.Position            = UDim2.new(0, 2, 0.5, 0)
        Line.Size                = UDim2.new(0, 3, 0.65, 0)
        Line.ZIndex              = 17
        UICorner_i2.CornerRadius = UDim.new(0, 25)
        UICorner_i2.Parent       = Line
        UIGradient_i.Rotation    = 90
        UIGradient_i.Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.5, 0),
            NumberSequenceKeypoint.new(1, 1),
        }
        UIGradient_i.Parent      = Line

        Icon.Name                = NeverLose.RandomString()
        Icon.Parent              = IndicatorItem
        Icon.AnchorPoint         = Vector2.new(0, 0.5)
        Icon.BackgroundTransparency = 1
        Icon.BorderSizePixel     = 0
        Icon.Position            = UDim2.new(0, 10, 0.5, 0)
        Icon.Size                = UDim2.new(0, 25, 0, 25)
        Icon.ZIndex              = 17
        Icon.FontFace            = NeverLose.BuiltInBold
        Icon.Text                = Config.Icon
        Icon.TextColor3          = Color3.fromRGB(186, 186, 186)
        Icon.TextSize            = 21
        Icon.TextTransparency    = 1
        Icon.TextWrapped         = true

        Content.Name             = NeverLose.RandomString()
        Content.Parent           = IndicatorItem
        Content.AnchorPoint      = Vector2.new(0, 0.5)
        Content.BackgroundTransparency = 1
        Content.BorderSizePixel  = 0
        Content.Position         = UDim2.new(0, 40, 0.5, 0)
        Content.Size             = UDim2.new(1, -40, 0, 25)
        Content.ZIndex           = 17
        Content.Font             = Enum.Font.GothamBold
        Content.Text             = Config.Name
        Content.TextColor3       = Color3.fromRGB(186, 186, 186)
        Content.TextSize         = 20
        Content.TextTransparency = 1
        Content.TextXAlignment   = Enum.TextXAlignment.Left

        Indicator.Update = function()
            local text = TextService:GetTextSize(Content.Text, Content.TextSize, Content.Font, Vector2.new(math.huge, math.huge))
            NeverLose.PlayAnimate(IndicatorItem, SlowyTween, { Size = UDim2.new(0, text.X + 60, 0, 40) })
        end

        Indicator.SetRender = function(self, value)
            Indicator.Visible = value
            local color = Indicators.Color[Indicator.CurrentColor]
            if value then
                NeverLose.PlayAnimate(IndicatorItem, SlowyTween, { BackgroundTransparency = 0.2 })
                NeverLose.PlayAnimate(Line,          SlowyTween, { BackgroundTransparency = 0, BackgroundColor3 = color })
                NeverLose.PlayAnimate(Icon,          VSlowTween, { TextTransparency = 0.25, TextColor3 = color })
                NeverLose.PlayAnimate(Content,       VSlowTween, { TextTransparency = 0.2,  TextColor3 = color })
                Shadow:Render(true)
            else
                NeverLose.PlayAnimate(IndicatorItem, SlowyTween, { BackgroundTransparency = 1 })
                NeverLose.PlayAnimate(Line,          SlowyTween, { BackgroundTransparency = 1, BackgroundColor3 = color })
                NeverLose.PlayAnimate(Icon,          VSlowTween, { TextTransparency = 1, TextColor3 = color })
                NeverLose.PlayAnimate(Content,       VSlowTween, { TextTransparency = 1, TextColor3 = color })
                Shadow:Render(false)
            end
            Indicator.Update()
        end

        Indicator.Update()
        Indicator:SetRender(false)

        function Indicator:SetColor(new_color)
            self.CurrentColor = new_color
            if self.Visible then self:SetRender(true) end
        end
        function Indicator:SetText(name)
            Config.Name  = name
            Content.Text = name
            self.Update()
        end
        return Indicator
    end

    return Indicators
end

function NeverLose:Unload()
    if not NeverLose.UnloadEnabled then return end
    NeverLose.ScreenGui:Destroy()
    for _, v in next, NeverLose.GlobalSignals do pcall(v.Disconnect, v) end
end

return NeverLose
