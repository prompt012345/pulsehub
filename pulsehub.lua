-- Pulse Hub v0.4 compact
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local LP = Players.LocalPlayer

local Notify = {}
do
    local gui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
    gui.Name = "PulseNotify"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    local c = Instance.new("Frame", gui)
    c.AnchorPoint = Vector2.new(1, 0)
    c.Position = UDim2.new(1, -20, 0, 20)
    c.Size = UDim2.new(0, 280, 1, -40)
    c.BackgroundTransparency = 1
    local l = Instance.new("UIListLayout", c)
    l.Padding = UDim.new(0, 8)
    l.HorizontalAlignment = Enum.HorizontalAlignment.Right
    function Notify:push(title, msg, dur)
        local t = Instance.new("Frame", c)
        t.Size = UDim2.new(1, 0, 0, 56)
        t.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
        t.BackgroundTransparency = 0.1
        t.BorderSizePixel = 0
        Instance.new("UICorner", t).CornerRadius = UDim.new(0, 8)
        local s = Instance.new("UIStroke", t)
        s.Color = Color3.fromRGB(140, 90, 255)
        s.Thickness = 1.5
        local a = Instance.new("TextLabel", t)
        a.Size = UDim2.new(1, -20, 0, 20)
        a.Position = UDim2.new(0, 12, 0, 6)
        a.BackgroundTransparency = 1
        a.Text = title
        a.Font = Enum.Font.GothamBold
        a.TextSize = 13
        a.TextColor3 = Color3.fromRGB(140, 90, 255)
        a.TextXAlignment = Enum.TextXAlignment.Left
        local b = Instance.new("TextLabel", t)
        b.Size = UDim2.new(1, -20, 0, 24)
        b.Position = UDim2.new(0, 12, 0, 26)
        b.BackgroundTransparency = 1
        b.Text = msg
        b.Font = Enum.Font.Gotham
        b.TextSize = 12
        b.TextColor3 = Color3.fromRGB(220, 220, 230)
        b.TextXAlignment = Enum.TextXAlignment.Left
        task.delay(dur or 4, function() t:Destroy() end)
    end
end

local Keybind = { binds = {} }
function Keybind:add(name, key, cb) self.binds[name] = { key = key, cb = cb } end
UIS.InputBegan:Connect(function(i, p)
    if p then return end
    for _, b in pairs(Keybind.binds) do
        if i.KeyCode == b.key then b.cb() end
    end
end)

local UI = { tabs = {} }
do
    local C = {
        bg = Color3.fromRGB(18, 18, 24),
        panel = Color3.fromRGB(24, 24, 32),
        elem = Color3.fromRGB(34, 34, 46),
        accent = Color3.fromRGB(140, 90, 255),
        dim = Color3.fromRGB(80, 55, 150),
        txt = Color3.fromRGB(230, 230, 240),
        txtdim = Color3.fromRGB(150, 150, 165),
    }
    local gui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
    gui.Name = "PulseHub"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    UI.gui = gui

    local w = Instance.new("Frame", gui)
    w.Size = UDim2.new(0, 520, 0, 380)
    w.Position = UDim2.new(0.5, -260, 0.5, -190)
    w.BackgroundColor3 = C.bg
    w.BorderSizePixel = 0
    w.Active = true
    w.Draggable = true
    Instance.new("UICorner", w).CornerRadius = UDim.new(0, 12)
    local ws = Instance.new("UIStroke", w)
    ws.Color = C.accent
    ws.Thickness = 1.5
    ws.Transparency = 0.3

    local tb = Instance.new("Frame", w)
    tb.Size = UDim2.new(1, 0, 0, 42)
    tb.BackgroundColor3 = C.panel
    tb.BorderSizePixel = 0
    Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel", tb)
    title.Size = UDim2.new(1, -60, 1, 0)
    title.Position = UDim2.new(0, 16, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "PULSE HUB  v0.4"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextColor3 = C.accent
    title.TextXAlignment = Enum.TextXAlignment.Left

    local xb = Instance.new("TextButton", tb)
    xb.Size = UDim2.new(0, 30, 0, 30)
    xb.Position = UDim2.new(1, -40, 0.5, -15)
    xb.BackgroundColor3 = C.elem
    xb.Text = "x"
    xb.Font = Enum.Font.GothamBold
    xb.TextSize = 18
    xb.TextColor3 = C.txtdim
    xb.BorderSizePixel = 0
    Instance.new("UICorner", xb).CornerRadius = UDim.new(0, 6)
    xb.MouseButton1Click:Connect(function() gui.Enabled = false end)

    local sb = Instance.new("Frame", w)
    sb.Size = UDim2.new(0, 130, 1, -42)
    sb.Position = UDim2.new(0, 0, 0, 42)
    sb.BackgroundColor3 = C.panel
    sb.BorderSizePixel = 0
    local sl = Instance.new("UIListLayout", sb)
    sl.Padding = UDim.new(0, 4)
    Instance.new("UIPadding", sb).PaddingTop = UDim.new(0, 8)

    local ct = Instance.new("Frame", w)
    ct.Size = UDim2.new(1, -130, 1, -42)
    ct.Position = UDim2.new(0, 130, 0, 42)
    ct.BackgroundColor3 = C.bg
    ct.BorderSizePixel = 0

    function UI:tab(name)
        local btn = Instance.new("TextButton", sb)
        btn.Size = UDim2.new(1, -16, 0, 34)
        btn.BackgroundColor3 = C.elem
        btn.BackgroundTransparency = 0.5
        btn.Text = "  " .. name
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 13
        btn.TextColor3 = C.txt
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.BorderSizePixel = 0
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        local fr = Instance.new("ScrollingFrame", ct)
        fr.Size = UDim2.new(1, -20, 1, -20)
        fr.Position = UDim2.new(0, 10, 0, 10)
        fr.BackgroundTransparency = 1
        fr.BorderSizePixel = 0
        fr.ScrollBarThickness = 4
        fr.CanvasSize = UDim2.new(0, 0, 0, 0)
        fr.AutomaticCanvasSize = Enum.AutomaticSize.Y
        fr.Visible = false
        local ll = Instance.new("UIListLayout", fr)
        ll.Padding = UDim.new(0, 6)

        UI.tabs[name] = { fr = fr, btn = btn }

        btn.MouseButton1Click:Connect(function()
            for n, t in pairs(UI.tabs) do
                t.fr.Visible = (n == name)
                t.btn.BackgroundTransparency = (n == name) and 0 or 0.5
                t.btn.TextColor3 = (n == name) and C.accent or C.txt
            end
        end)
        return fr
    end

    function UI:default()
        local f = next(UI.tabs)
        if f then
            UI.tabs[f].fr.Visible = true
            UI.tabs[f].btn.BackgroundTransparency = 0
            UI.tabs[f].btn.TextColor3 = C.accent
        end
    end

    function UI:section(parent, txt)
        local l = Instance.new("TextLabel", parent)
        l.Size = UDim2.new(1, 0, 0, 22)
        l.BackgroundTransparency = 1
        l.Text = string.upper(txt)
        l.Font = Enum.Font.GothamBold
        l.TextSize = 11
        l.TextColor3 = C.accent
        l.TextXAlignment = Enum.TextXAlignment.Left
        return l
    end

    function UI:toggle(parent, txt, def, cb, opts)
        opts = opts or {}
        local r = Instance.new("Frame", parent)
        r.Size = UDim2.new(1, 0, 0, 38)
        r.BackgroundColor3 = C.elem
        r.BackgroundTransparency = 0.3
        r.BorderSizePixel = 0
        Instance.new("UICorner", r).CornerRadius = UDim.new(0, 6)

        local l = Instance.new("TextLabel", r)
        l.Size = UDim2.new(1, -60, 1, 0)
        l.Position = UDim2.new(0, 12, 0, 0)
        l.BackgroundTransparency = 1
        l.Text = txt
        l.Font = Enum.Font.Gotham
        l.TextSize = 13
        l.TextColor3 = C.txt
        l.TextXAlignment = Enum.TextXAlignment.Left

        local tk = Instance.new("Frame", r)
        tk.Size = UDim2.new(0, 40, 0, 20)
        tk.Position = UDim2.new(1, -52, 0.5, -10)
        tk.BackgroundColor3 = C.bg
        tk.BorderSizePixel = 0
        Instance.new("UICorner", tk).CornerRadius = UDim.new(0, 10)

        local kn = Instance.new("Frame", tk)
        kn.Size = UDim2.new(0, 16, 0, 16)
        kn.Position = UDim2.new(0, 2, 0.5, -8)
        kn.BackgroundColor3 = C.txtdim
        kn.BorderSizePixel = 0
        Instance.new("UICorner", kn).CornerRadius = UDim.new(0, 8)

        local b = Instance.new("TextButton", r)
        b.Size = UDim2.new(1, 0, 1, 0)
        b.BackgroundTransparency = 1
        b.Text = ""

        local st = def or false
        local function ap(v, sk)
            st = v
            kn.Position = v and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            kn.BackgroundColor3 = v and C.accent or C.txtdim
            tk.BackgroundColor3 = v and C.dim or C.bg
            if not sk and cb then cb(v) end
        end
        ap(st, true)
        b.MouseButton1Click:Connect(function() ap(not st) end)

        if opts.keybind then
            Keybind:add(opts.keybind, opts.defaultKey or Enum.KeyCode.Unknown, function()
                ap(not st)
                Notify:push(opts.keybind, st and "ON" or "OFF", 1.5)
            end)
        end
        return { get = function() return st end, set = ap }
    end

    function UI:slider(parent, txt, mn, mx, def, cb)
        local r = Instance.new("Frame", parent)
        r.Size = UDim2.new(1, 0, 0, 54)
        r.BackgroundColor3 = C.elem
        r.BackgroundTransparency = 0.3
        r.BorderSizePixel = 0
        Instance.new("UICorner", r).CornerRadius = UDim.new(0, 6)

        local l = Instance.new("TextLabel", r)
        l.Size = UDim2.new(1, -60, 0, 20)
        l.Position = UDim2.new(0, 12, 0, 4)
        l.BackgroundTransparency = 1
        l.Text = txt
        l.Font = Enum.Font.Gotham
        l.TextSize = 13
        l.TextColor3 = C.txt
        l.TextXAlignment = Enum.TextXAlignment.Left

        local vl = Instance.new("TextLabel", r)
        vl.Size = UDim2.new(0, 50, 0, 20)
        vl.Position = UDim2.new(1, -58, 0, 4)
        vl.BackgroundTransparency = 1
        vl.Text = tostring(def)
        vl.Font = Enum.Font.GothamBold
        vl.TextSize = 13
        vl.TextColor3 = C.accent
        vl.TextXAlignment = Enum.TextXAlignment.Right

        local tk = Instance.new("Frame", r)
        tk.Size = UDim2.new(1, -24, 0, 8)
        tk.Position = UDim2.new(0, 12, 0, 36)
        tk.BackgroundColor3 = C.bg
        tk.BorderSizePixel = 0
        Instance.new("UICorner", tk).CornerRadius = UDim.new(0, 4)

        local fl = Instance.new("Frame", tk)
        fl.Size = UDim2.new(0, 0, 1, 0)
        fl.BackgroundColor3 = C.accent
        fl.BorderSizePixel = 0
        Instance.new("UICorner", fl).CornerRadius = UDim.new(0, 4)

        local kn = Instance.new("Frame", tk)
        kn.Size = UDim2.new(0, 14, 0, 14)
        kn.Position = UDim2.new(0, -7, 0.5, -7)
        kn.BackgroundColor3 = C.txt
        kn.BorderSizePixel = 0
        Instance.new("UICorner", kn).CornerRadius = UDim.new(0, 7)

        local val = def
        local drag = false

        local function ap(v, sk)
            v = math.clamp(v, mn, mx)
            val = v
            local ra = (v - mn) / (mx - mn)
            fl.Size = UDim2.new(ra, 0, 1, 0)
            kn.Position = UDim2.new(ra, -7, 0.5, -7)
            vl.Text = tostring(math.floor(v * 10 + 0.5) / 10)
            if not sk and cb then cb(v) end
        end
        ap(def, true)

        local function fx(x)
            local rl = (x - tk.AbsolutePosition.X) / tk.AbsoluteSize.X
            ap(mn + math.clamp(rl, 0, 1) * (mx - mn))
        end

        tk.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
                drag = true
                fx(i.Position.X)
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if drag and (i.UserInputType == Enum.UserInputType.MouseMovement
            or i.UserInputType == Enum.UserInputType.Touch) then
                fx(i.Position.X)
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
                drag = false
            end
        end)
        return { get = function() return val end, set = ap }
    end

    function UI:button(parent, txt, cb)
        local b = Instance.new("TextButton", parent)
        b.Size = UDim2.new(1, 0, 0, 34)
        b.BackgroundColor3 = C.elem
        b.BackgroundTransparency = 0.3
        b.Text = txt
        b.Font = Enum.Font.Gotham
        b.TextSize = 13
        b.TextColor3 = C.txt
        b.BorderSizePixel = 0
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        b.MouseButton1Click:Connect(cb or function() end)
        return b
    end

    UIS.InputBegan:Connect(function(i, p)
        if p then return end
        if i.KeyCode == Enum.KeyCode.RightShift then
            gui.Enabled = not gui.Enabled
        end
    end)
end

-- FLY
do
    local t = UI:tab("Movement")
    UI:section(t, "Fly")
    local spd = 60
    local bv, bg, cn, vl = nil, nil, nil, Vector3.zero

    local function stop()
        if cn then cn:Disconnect() cn = nil end
        if bv then bv:Destroy() bv = nil end
        if bg then bg:Destroy() bg = nil end
        local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if h then h.PlatformStand = false end
    end

    local function start()
        local ch = LP.Character
        if not ch then return end
        local r = ch:FindFirstChild("HumanoidRootPart")
        local h = ch:FindFirstChildOfClass("Humanoid")
        if not r or not h then return end
        h.PlatformStand = true
        bv = Instance.new("BodyVelocity", r)
        bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bg = Instance.new("BodyGyro", r)
        bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        bg.P = 1e4
        bg.D = 500
        bg.CFrame = r.CFrame
        cn = RunService.RenderStepped:Connect(function()
            local c = LP.Character
            if not c then stop() return end
            local rt = c:FindFirstChild("HumanoidRootPart")
            if not rt then return end
            local cm = workspace.CurrentCamera
            local mv = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then mv = mv + cm.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then mv = mv - cm.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then mv = mv + cm.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then mv = mv - cm.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then mv = mv + Vector3.new(0,1,0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then mv = mv - Vector3.new(0,1,0) end
            if mv.Magnitude > 0 then mv = mv.Unit end
            vl = vl:Lerp(mv * spd, 0.15)
            bv.Velocity = vl
            bg.CFrame = cm.CFrame
        end)
    end

    UI:toggle(t, "Fly", false, function(v) if v then start() else stop() end end,
        { keybind = "Fly", defaultKey = Enum.KeyCode.F })
    UI:slider(t, "Fly Speed", 20, 300, 60, function(v) spd = v end)
    LP.CharacterAdded:Connect(stop)
end

-- SPEED + JUMP
do
    local t = UI:tab("Player")
    UI:section(t, "Vitesse")
    UI:slider(t, "WalkSpeed", 8, 250, 16, function(v)
        local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = v end
    end)
    UI:section(t, "Saut")
    local ij = false
    UI:toggle(t, "Infinite Jump", false, function(v) ij = v end,
        { keybind = "IJ", defaultKey = Enum.KeyCode.J })
    UIS.JumpRequest:Connect(function()
        if ij then
            local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end)
    UI:section(t, "Actions")
    UI:button(t, "Reset", function()
        local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if h then h.Health = 0 end
    end)
    UI:button(t, "Rejoin", function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
    end)
end

-- NOCLIP
do
    local t = UI:tab("Movement")
    UI:section(t, "Collisions")
    local cn = nil
    UI:toggle(t, "Noclip", false, function(v)
        if v then
            cn = RunService.Stepped:Connect(function()
                local ch = LP.Character
                if not ch then return end
                for _, p in ipairs(ch:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end)
        else
            if cn then cn:Disconnect() cn = nil end
        end
    end, { keybind = "Noclip", defaultKey = Enum.KeyCode.N })
end

-- FULLBRIGHT
do
    local t = UI:tab("Visuals")
    UI:section(t, "Eclairage")
    local sv = nil
    UI:toggle(t, "Fullbright", false, function(v)
        if v then
            sv = { Lighting.Brightness, Lighting.Ambient, Lighting.OutdoorAmbient, Lighting.FogEnd, Lighting.GlobalShadows }
            Lighting.Brightness = 3
            Lighting.Ambient = Color3.fromRGB(210, 210, 210)
            Lighting.OutdoorAmbient = Color3.fromRGB(210, 210, 210)
            Lighting.FogEnd = 1e5
            Lighting.GlobalShadows = false
        elseif sv then
            Lighting.Brightness = sv[1]
            Lighting.Ambient = sv[2]
            Lighting.OutdoorAmbient = sv[3]
            Lighting.FogEnd = sv[4]
            Lighting.GlobalShadows = sv[5]
            sv = nil
        end
    end, { keybind = "FB", defaultKey = Enum.KeyCode.B })
end

UI:default()
Notify:push("Pulse Hub", "v0.4 charge - RightShift UI", 6)
print("[Pulse Hub] v0.4 OK")
