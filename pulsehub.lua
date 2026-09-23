--[[
    ═══════════════════════════════════════════════════════════
    PULSE HUB — BUNDLE v0.3.0
    ═══════════════════════════════════════════════════════════
    Tout-en-un. Colle ce fichier dans ton exécuteur et exécute.
    
    Contrôles :
      RightShift : toggle UI
      F : Fly       J : Inf Jump    N : Noclip
      B : Fullbright X : ESP         C : Aimbot
      T : TP souris
--]]

--============================================================
-- SERVICES GLOBAUX
--============================================================
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Lighting         = game:GetService("Lighting")
local HttpService      = game:GetService("HttpService")
local LocalPlayer      = Players.LocalPlayer

--============================================================
-- ÉTAT GLOBAL
--============================================================
local Pulse = {
    version = "0.3.0",
    modules = {},
    tabs    = {},
}

_G.Pulse = Pulse

--============================================================
-- ═══════════════════════════════════════════════════════════
-- CORE / CONFIG
-- ═══════════════════════════════════════════════════════════
--============================================================
local function setupConfig(Pulse)
    local Config = {}
    local PATH = "pulsehub_config.json"
    local memory = {}
    local hasFS = (type(writefile) == "function" and type(readfile) == "function"
                   and type(isfile) == "function")

    if hasFS and isfile(PATH) then
        local ok, raw = pcall(readfile, PATH)
        if ok and raw then
            local ok2, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
            if ok2 and type(decoded) == "table" then memory = decoded end
        end
    end

    local function save()
        if not hasFS then return end
        pcall(function()
            writefile(PATH, HttpService:JSONEncode(memory))
        end)
    end

    function Config:get(key, default)
        local v = memory[key]
        if v == nil then return default end
        return v
    end
    function Config:set(key, value)
        memory[key] = value
        save()
    end
    function Config:clear() memory = {} save() end

    return Config
end

--============================================================
-- ═══════════════════════════════════════════════════════════
-- CORE / NOTIFY
-- ═══════════════════════════════════════════════════════════
--============================================================
local function setupNotify(Pulse)
    local Notify = {}

    local gui = Instance.new("ScreenGui")
    gui.Name = "PulseNotify"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 999
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local container = Instance.new("Frame")
    container.AnchorPoint = Vector2.new(1, 0)
    container.Position = UDim2.new(1, -20, 0, 20)
    container.Size = UDim2.new(0, 300, 1, -40)
    container.BackgroundTransparency = 1
    container.Parent = gui

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    layout.Parent = container

    local function createToast(title, message, duration)
        local toast = Instance.new("Frame")
        toast.Size = UDim2.new(1, 0, 0, 60)
        toast.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
        toast.BackgroundTransparency = 1
        toast.BorderSizePixel = 0
        toast.Parent = container

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 8)
        c.Parent = toast

        local s = Instance.new("UIStroke")
        s.Color = Color3.fromRGB(140, 90, 255)
        s.Thickness = 1.5
        s.Transparency = 1
        s.Parent = toast

        local accent = Instance.new("Frame")
        accent.Size = UDim2.new(0, 3, 1, -12)
        accent.Position = UDim2.new(0, 6, 0, 6)
        accent.BackgroundColor3 = Color3.fromRGB(140, 90, 255)
        accent.BackgroundTransparency = 1
        accent.BorderSizePixel = 0
        accent.Parent = toast
        local ac = Instance.new("UICorner")
        ac.CornerRadius = UDim.new(0, 2)
        ac.Parent = accent

        local titleLbl = Instance.new("TextLabel")
        titleLbl.Size = UDim2.new(1, -30, 0, 22)
        titleLbl.Position = UDim2.new(0, 18, 0, 6)
        titleLbl.BackgroundTransparency = 1
        titleLbl.Text = title
        titleLbl.Font = Enum.Font.GothamBold
        titleLbl.TextSize = 13
        titleLbl.TextColor3 = Color3.fromRGB(140, 90, 255)
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.TextTransparency = 1
        titleLbl.Parent = toast

        local msgLbl = Instance.new("TextLabel")
        msgLbl.Size = UDim2.new(1, -30, 0, 26)
        msgLbl.Position = UDim2.new(0, 18, 0, 28)
        msgLbl.BackgroundTransparency = 1
        msgLbl.Text = message
        msgLbl.Font = Enum.Font.Gotham
        msgLbl.TextSize = 12
        msgLbl.TextColor3 = Color3.fromRGB(220, 220, 230)
        msgLbl.TextXAlignment = Enum.TextXAlignment.Left
        msgLbl.TextWrapped = true
        msgLbl.TextTransparency = 1
        msgLbl.Parent = toast

        local ti = TweenInfo.new(0.25)
        TweenService:Create(toast, ti, { BackgroundTransparency = 0.1 }):Play()
        TweenService:Create(s, ti, { Transparency = 0.3 }):Play()
        TweenService:Create(accent, ti, { BackgroundTransparency = 0 }):Play()
        TweenService:Create(titleLbl, ti, { TextTransparency = 0 }):Play()
        TweenService:Create(msgLbl, ti, { TextTransparency = 0 }):Play()

        task.delay(duration or 4, function()
            local to = TweenInfo.new(0.3)
            TweenService:Create(toast, to, { BackgroundTransparency = 1 }):Play()
            TweenService:Create(s, to, { Transparency = 1 }):Play()
            TweenService:Create(accent, to, { BackgroundTransparency = 1 }):Play()
            TweenService:Create(titleLbl, to, { TextTransparency = 1 }):Play()
            TweenService:Create(msgLbl, to, { TextTransparency = 1 }):Play()
            task.wait(0.35)
            toast:Destroy()
        end)
    end

    function Notify:push(title, message, duration)
        createToast(title or "Pulse", message or "", duration)
    end

    return Notify
end

--============================================================
-- ═══════════════════════════════════════════════════════════
-- CORE / KEYBIND
-- ═══════════════════════════════════════════════════════════
--============================================================
local function setupKeybind(Pulse)
    local Keybind = {}
    Keybind.binds = {}
    Keybind.capturing = nil

    local function keyName(key)
        if typeof(key) == "EnumItem" then
            local n = key.Name
            n = n:gsub("KeyCode.", ""):gsub("^Left", "L-"):gsub("^Right", "R-")
            return n
        end
        return "?"
    end
    Keybind.keyName = keyName

    function Keybind:register(name, defaultKey, callback)
        local savedName = Pulse.Config:get("keybind." .. name, nil)
        local key = defaultKey
        if savedName then
            local ok, resolved = pcall(function() return Enum.KeyCode[savedName] end)
            if ok and resolved then key = resolved end
        end
        Keybind.binds[name] = { key = key, callback = callback, listeners = {} }
        return {
            setKey = function(self, newKey)
                Keybind.binds[name].key = newKey
                Pulse.Config:set("keybind." .. name, newKey.Name)
                for _, fn in ipairs(Keybind.binds[name].listeners) do pcall(fn, newKey) end
            end,
            getKey = function() return Keybind.binds[name].key end,
            onChange = function(self, fn) table.insert(Keybind.binds[name].listeners, fn) end,
            trigger = function()
                if Keybind.binds[name].callback then Keybind.binds[name].callback() end
            end,
        }
    end

    function Keybind:startCapture(name, onCaptured)
        Keybind.capturing = { name = name, onCaptured = onCaptured }
    end

    UserInputService.InputBegan:Connect(function(input, processed)
        if Keybind.capturing then
            if input.UserInputType == Enum.UserInputType.Keyboard
               or input.UserInputType == Enum.UserInputType.Gamepad1 then
                local name = Keybind.capturing.name
                local cb = Keybind.capturing.onCaptured
                local bind = Keybind.binds[name]
                if bind then
                    bind.key = input.KeyCode
                    Pulse.Config:set("keybind." .. name, input.KeyCode.Name)
                    for _, fn in ipairs(bind.listeners) do pcall(fn, input.KeyCode) end
                end
                if cb then cb(input.KeyCode) end
                Keybind.capturing = nil
            end
            return
        end
        if processed then return end
        for _, bind in pairs(Keybind.binds) do
            if input.KeyCode == bind.key and bind.callback then pcall(bind.callback) end
        end
    end)

    return Keybind
end

--============================================================
-- ═══════════════════════════════════════════════════════════
-- CORE / UI
-- ═══════════════════════════════════════════════════════════
--============================================================
local function setupUI(Pulse)
    local UI = {}
    UI.tabs = {}

    UI.Theme = {
        bg        = Color3.fromRGB(18, 18, 24),
        bgPanel   = Color3.fromRGB(24, 24, 32),
        bgElement = Color3.fromRGB(34, 34, 46),
        accent    = Color3.fromRGB(140, 90, 255),
        accentDim = Color3.fromRGB(80, 55, 150),
        text      = Color3.fromRGB(230, 230, 240),
        textDim   = Color3.fromRGB(150, 150, 165),
        font      = Enum.Font.Gotham,
        fontBold  = Enum.Font.GothamBold,
    }
    local T = UI.Theme

    local function corner(o, r)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, r or 8)
        c.Parent = o
        return c
    end
    local function stroke(o, color, th)
        local s = Instance.new("UIStroke")
        s.Color = color or T.accent
        s.Thickness = th or 1
        s.Transparency = 0.3
        s.Parent = o
        return s
    end
    local function pad(o, p)
        local u = Instance.new("UIPadding")
        u.PaddingTop = UDim.new(0, p)
        u.PaddingBottom = UDim.new(0, p)
        u.PaddingLeft = UDim.new(0, p)
        u.PaddingRight = UDim.new(0, p)
        u.Parent = o
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "PulseHub"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    UI.gui = gui

    local window = Instance.new("Frame")
    window.Size = UDim2.new(0, 560, 0, 400)
    window.Position = UDim2.new(0.5, -280, 0.5, -200)
    window.BackgroundColor3 = T.bg
    window.BorderSizePixel = 