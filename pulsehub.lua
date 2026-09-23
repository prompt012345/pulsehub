-- Pulse Hub v0.6 - Premium Edition
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local LP = Players.LocalPlayer

local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

-- ============================================================
-- PALETTE PREMIUM
-- ============================================================
local C = {
    bg          = Color3.fromRGB(15, 15, 22),
    bgGrad      = Color3.fromRGB(22, 20, 40),
    panel       = Color3.fromRGB(20, 20, 30),
    elem        = Color3.fromRGB(28, 28, 42),
    elemHover   = Color3.fromRGB(38, 38, 56),
    accent      = Color3.fromRGB(167, 139, 250),   -- violet clair
    accentBright= Color3.fromRGB(196, 181, 253),
    accentPink  = Color3.fromRGB(236, 72, 153),    -- rose
    accentDim   = Color3.fromRGB(88, 60, 180),
    success     = Color3.fromRGB(52, 211, 153),
    danger      = Color3.fromRGB(248, 113, 113),
    txt         = Color3.fromRGB(245, 245, 250),
    txtdim      = Color3.fromRGB(142, 142, 160),
    txtfaint    = Color3.fromRGB(85, 85, 105),
}

-- ============================================================
-- HELPERS
-- ============================================================
local function corner(obj, r)
    local c = Instance.new("UICorner", obj)
    c.CornerRadius = UDim.new(0, r or 8)
    return c
end

local function stroke(obj, col, th, trans)
    local s = Instance.new("UIStroke", obj)
    s.Color = col or C.accent
    s.Thickness = th or 1
    s.Transparency = trans or 0.4
    return s
end

local function gradient(obj, c1, c2, rot)
    local g = Instance.new("UIGradient", obj)
    g.Color = ColorSequence.new(c1, c2)
    g.Rotation = rot or 0
    return g
end

local function pad(obj, t, b, l, r)
    local p = Instance.new("UIPadding", obj)
    if t then p.PaddingTop = UDim.new(0, t) end
    if b then p.PaddingBottom = UDim.new(0, b) end
    if l then p.PaddingLeft = UDim.new(0, l) end
    if r then p.PaddingRight = UDim.new(0, r) end
    return p
end

local function tween(obj, time, props)
    TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

-- ============================================================
-- NOTIFY
-- ============================================================
local Notify = {}
do
    local gui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
    gui.Name = "PulseNotify"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 999

    local c = Instance.new("Frame", gui)
    c.AnchorPoint = Vector2.new(1, 0)
    c.Position = UDim2.new(1, -20, 0, 20)
    c.Size = UDim2.new(0, 300, 1, -40)
    c.BackgroundTransparency = 1
    local l = Instance.new("UIListLayout", c)
    l.Padding = UDim.new(0, 10)
    l.HorizontalAlignment = Enum.HorizontalAlignment.Right

    function Notify:push(title, msg, dur)
        local t = Instance.new("Frame", c)
        t.Size = UDim2.new(1, 0, 0, 62)
        t.BackgroundColor3 = C.panel
        t.BackgroundTransparency = 1
        t.BorderSizePixel = 0
        corner(t, 10)
        local s = stroke(t, C.accent, 1.5, 1)
        local g = gradient(t, C.accent, C.accentPink, 45)
        g.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.85),
            NumberSequenceKeypoint.new(1, 0.95),
        })

        local accent = Instance.new("Frame", t)
        accent.Size = UDim2.new(0, 3, 1, -16)
        accent.Position = UDim2.new(0, 8, 0, 8)
        accent.BackgroundColor3 = C.accent
        accent.BorderSizePixel = 0
        accent.BackgroundTransparency = 1
        corner(accent, 2)
        local ag = gradient(accent, C.accent, C.accentPink, 90)

        local a = Instance.new("TextLabel", t)
        a.Size = UDim2.new(1, -30, 0, 22)
        a.Position = UDim2.new(0, 20, 0, 8)
        a.BackgroundTransparency = 1
        a.Text = title
        a.Font = Enum.Font.GothamBold
        a.TextSize = 13
        a.TextColor3 = C.accentBright
        a.TextXAlignment = Enum.TextXAlignment.Left
        a.TextTransparency = 1

        local b = Instance.new("TextLabel", t)
        b.Size = UDim2.new(1, -30, 0, 26)
        b.Position = UDim2.new(0, 20, 0, 30)
        b.BackgroundTransparency = 1
        b.Text = msg
        b.Font = Enum.Font.Gotham
        b.TextSize = 12
        b.TextColor3 = C.txt
        b.TextXAlignment = Enum.TextXAlignment.Left
        b.TextTransparency = 1

        tween(t, 0.25, { BackgroundTransparency = 0.05 })
        tween(s, 0.25, { Transparency = 0.3 })
        tween(accent, 0.25, { BackgroundTransparency = 0 })
        tween(a, 0.25, { TextTransparency = 0 })
        tween(b, 0.25, { TextTransparency = 0 })

        task.delay(dur or 4, function()
            tween(t, 0.3, { BackgroundTransparency = 1 })
            tween(s, 0.3, { Transparency = 1 })
            tween(accent, 0.3, { BackgroundTransparency = 1 })
            tween(a, 0.3, { TextTransparency = 1 })
            tween(b, 0.3, { TextTransparency = 1 })
            task.wait(0.35)
            t:Destroy()
        end)
    end
end

-- ============================================================
-- KEYBIND
-- ============================================================
local Keybind = { binds = {} }
function Keybind:add(name, key, cb) self.binds[name] = { key = key, cb = cb } end
UIS.InputBegan:Connect(function(i, p)
    if p then return end
    for _, b in pairs(Keybind.binds) do
        if i.KeyCode == b.key then b.cb() end
    end
end)

-- ============================================================
-- ÉTAT MOBILE
-- ============================================================
local Mobile = { joystick = Vector2.new(0, 0), up = false, down = false }

-- ============================================================
-- UI PREMIUM
-- ============================================================
local UI = { tabs = {} }
do
    local gui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
    gui.Name = "PulseHub"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    UI.gui = gui

    -- ==========================================================
    -- BOUTON FLOTTANT
    -- ==========================================================
    local floatBtn = Instance.new("TextButton", gui)
    floatBtn.Size = UDim2.new(0, 60, 0, 60)
    floatBtn.Position = UDim2.new(1, -80, 1, -150)
    floatBtn.BackgroundColor3 = C.accent
    floatBtn.Text = "⚡"
    floatBtn.Font = Enum.Font.GothamBold
    floatBtn.TextSize = 26
    floatBtn.TextColor3 = C.txt
    floatBtn.BorderSizePixel = 0
    floatBtn.Active = true
    floatBtn.Draggable = true
    floatBtn.AutoButtonColor = false
    corner(floatBtn, 30)
    local fg = gradient(floatBtn, C.accent, C.accentPink, 135)
    local fs = stroke(floatBtn, C.accentBright, 2, 0.2)

    -- Pulsation douce
    task.spawn(function()
        while floatBtn.Parent do
            tween(floatBtn, 1.5, { Size = UDim2.new(0, 64, 0, 64) })
            task.wait(1.5)
            tween(floatBtn, 1.5, { Size = UDim2.new(0, 60, 0, 60) })
            task.wait(1.5)
        end
    end)

    floatBtn.MouseEnter:Connect(function()
        tween(floatBtn, 0.2, { Size = UDim2.new(0, 70, 0, 70) })
    end)
    floatBtn.MouseLeave:Connect(function()
        tween(floatBtn, 0.2, { Size = UDim2.new(0, 60, 0, 60) })
    end)

    -- ==========================================================
    -- FENÊTRE
    -- ==========================================================
    local W = isMobile and UDim2.new(0, 400, 0, 500) or UDim2.new(0, 600, 0, 440)
    local w = Instance.new("Frame", gui)
    w.Size = W
    w.Position = UDim2.new(0.5, isMobile and -200 or -300, 0.5, isMobile and -250 or -220)
    w.BackgroundColor3 = C.bg
    w.BorderSizePixel = 0
    w.Active = true
    w.Draggable = true
    w.Visible = false
    corner(w, 14)
    stroke(w, C.accent, 1.5, 0.5)
    local wg = gradient(w, C.bg, C.bgGrad, 135)
    wg.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 0.6),
    })
    UI.window = w

    -- ==========================================================
    -- BARRE DE TITRE
    -- ==========================================================
    local tb = Instance.new("Frame", w)
    tb.Size = UDim2.new(1, 0, 0, 52)
    tb.BackgroundColor3 = C.panel
    tb.BackgroundTransparency = 0.4
    tb.BorderSizePixel = 0
    corner(tb, 14)

    local tbFix = Instance.new("Frame", tb)
    tbFix.Size = UDim2.new(1, 0, 0, 14)
    tbFix.Position = UDim2.new(0, 0, 1, -14)
    tbFix.BackgroundColor3 = C.panel
    tbFix.BackgroundTransparency = 0.4
    tbFix.BorderSizePixel = 0

    -- Barre de dégradé sous le titre
    local tbg = Instance.new("Frame", w)
    tbg.Size = UDim2.new(1, -24, 0, 2)
    tbg.Position = UDim2.new(0, 12, 0, 52)
    tbg.BackgroundColor3 = C.accent
    tbg.BorderSizePixel = 0
    tbg.BackgroundTransparency = 0.3
    corner(tbg, 1)
    gradient(tbg, C.accent, C.accentPink, 0)

    -- Logo + titre
    local logoIcon = Instance.new("TextLabel", tb)
    logoIcon.Size = UDim2.new(0, 32, 0, 32)
    logoIcon.Position = UDim2.new(0, 16, 0.5, -16)
    logoIcon.BackgroundColor3 = C.accent
    logoIcon.Text = "⚡"
    logoIcon.Font = Enum.Font.GothamBold
    logoIcon.TextSize = 18
    logoIcon.TextColor3 = C.txt
    logoIcon.BorderSizePixel = 0
    corner(logoIcon, 8)
    gradient(logoIcon, C.accent, C.accentPink, 135)

    local title = Instance.new("TextLabel", tb)
    title.Size = UDim2.new(0, 200, 0, 20)
    title.Position = UDim2.new(0, 58, 0, 12)
    title.BackgroundTransparency = 1
    title.Text = "PULSE HUB"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextColor3 = C.txt
    title.TextXAlignment = Enum.TextXAlignment.Left

    local sub = Instance.new("TextLabel", tb)
    sub.Size = UDim2.new(0, 200, 0, 14)
    sub.Position = UDim2.new(0, 58, 0, 30)
    sub.BackgroundTransparency = 1
    sub.Text = "Premium Edition · v0.6"
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 10
    sub.TextColor3 = C.txtdim
    sub.TextXAlignment = Enum.TextXAlignment.Left

    -- Bouton réduire (mobile : cache en bouton flottant)
    local xb = Instance.new("TextButton", tb)
    xb.Size = UDim2.new(0, 32, 0, 32)
    xb.Position = UDim2.new(1, -48, 0.5, -16)
    xb.BackgroundColor3 = C.elem
    xb.Text = "✕"
    xb.Font = Enum.Font.GothamBold
    xb.TextSize = 14
    xb.TextColor3 = C.txtdim
    xb.BorderSizePixel = 0
    xb.AutoButtonColor = false
    corner(xb, 8)
    xb.MouseEnter:Connect(function()
        tween(xb, 0.15, { BackgroundColor3 = C.danger, TextColor3 = C.txt })
    end)
    xb.MouseLeave:Connect(function()
        tween(xb, 0.15, { BackgroundColor3 = C.elem, TextColor3 = C.txtdim })
    end)
    xb.MouseButton1Click:Connect(function()
        w.Visible = false
        floatBtn.Visible = true
    end)

    floatBtn.MouseButton1Click:Connect(function()
        w.Visible = true
        floatBtn.Visible = false
    end)

    -- ==========================================================
    -- SIDEBAR
    -- ==========================================================
    local sbW = isMobile and 120 or 150
    local sb = Instance.new("Frame", w)
    sb.Size = UDim2.new(0, sbW, 1, -54)
    sb.Position = UDim2.new(0, 0, 0, 54)
    sb.BackgroundColor3 = C.panel
    sb.BackgroundTransparency = 0.6
    sb.BorderSizePixel = 0
    local sl = Instance.new("UIListLayout", sb)
    sl.Padding = UDim.new(0, 4)
    sl.SortOrder = Enum.SortOrder.LayoutOrder
    pad(sb, 10, 10, 10, 10)

    local ct = Instance.new("Frame", w)
    ct.Size = UDim2.new(1, -sbW, 1, -54)
    ct.Position = UDim2.new(0, sbW, 0, 54)
    ct.BackgroundTransparency = 1
    ct.BorderSizePixel = 0

    -- ==========================================================
    -- FONCTION TAB (avec icônes)
    -- ==========================================================
    function UI:tab(name, icon)
        if UI.tabs[name] then return UI.tabs[name].fr end

        local btn = Instance.new("TextButton", sb)
        btn.Size = UDim2.new(1, 0, 0, 40)
        btn.BackgroundColor3 = C.elem
        btn.BackgroundTransparency = 0.7
        btn.Text = ""
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 13
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        corner(btn, 8)

        -- Indicateur à gauche (s'illumine quand actif)
        local ind = Instance.new("Frame", btn)
        ind.Size = UDim2.new(0, 3, 0, 0)
        ind.Position = UDim2.new(0, 6, 0.5, 0)
        ind.BackgroundColor3 = C.accent
        ind.BorderSizePixel = 0
        ind.BackgroundTransparency = 1
        corner(ind, 2)

        local ic = Instance.new("TextLabel", btn)
        ic.Size = UDim2.new(0, 24, 1, 0)
        ic.Position = UDim2.new(0, 14, 0, 0)
        ic.BackgroundTransparency = 1
        ic.Text = icon or "•"
        ic.Font = Enum.Font.GothamBold
        ic.TextSize = 15
        ic.TextColor3 = C.txtdim
        ic.TextXAlignment = Enum.TextXAlignment.Left

        local lbl = Instance.new("TextLabel", btn)
        lbl.Size = UDim2.new(1, -40, 1, 0)
        lbl.Position = UDim2.new(0, 40, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = name
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 13
        lbl.TextColor3 = C.txtdim
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local fr = Instance.new("ScrollingFrame", ct)
        fr.Size = UDim2.new(1, -20, 1, -20)
        fr.Position = UDim2.new(0, 10, 0, 10)
        fr.BackgroundTransparency = 1
        fr.BorderSizePixel = 0
        fr.ScrollBarThickness = 3
        fr.ScrollBarImageColor3 = C.accent
        fr.ScrollBarImageTransparency = 0.3
        fr.CanvasSize = UDim2.new(0, 0, 0, 0)
        fr.AutomaticCanvasSize = Enum.AutomaticSize.Y
        fr.Visible = false
        local ll = Instance.new("UIListLayout", fr)
        ll.Padding = UDim.new(0, 8)
        ll.SortOrder = Enum.SortOrder.LayoutOrder

        UI.tabs[name] = { fr = fr, btn = btn, ind = ind, ic = ic, lbl = lbl }

        btn.MouseEnter:Connect(function()
            if UI.tabs[name].fr.Visible then return end
            tween(btn, 0.15, { BackgroundTransparency = 0.4 })
            tween(lbl, 0.15, { TextColor3 = C.txt })
        end)
        btn.MouseLeave:Connect(function()
            if UI.tabs[name].fr.Visible then return end
            tween(btn, 0.15, { BackgroundTransparency = 0.7 })
            tween(lbl, 0.15, { TextColor3 = C.txtdim })
        end)

        btn.MouseButton1Click:Connect(function()
            for n, t in pairs(UI.tabs) do
                local active = (n == name)
                t.fr.Visible = active
                tween(t.btn, 0.2, { BackgroundTransparency = active and 0.2 or 0.7 })
                tween(t.lbl, 0.2, { TextColor3 = active and C.txt or C.txtdim })
                tween(t.ic, 0.2, { TextColor3 = active and C.accentBright or C.txtdim })
                tween(t.ind, 0.2, {
                    BackgroundTransparency = active and 0 or 1,
                    Size = UDim2.new(0, 3, 0, active and 20 or 0),
                })
            end
        end)
        return fr
    end

    function UI:default()
        local f = next(UI.tabs)
        if not f then return end
        for n, t in pairs(UI.tabs) do
            local active = (n == f)
            t.fr.Visible = active
            t.btn.BackgroundTransparency = active and 0.2 or 0.7
            t.lbl.TextColor3 = active and C.txt or C.txtdim
            t.ic.TextColor3 = active and C.accentBright or C.txtdim
            t.ind.BackgroundTransparency = active and 0 or 1
            t.ind.Size = UDim2.new(0, 3, 0, active and 20 or 0)
        end
    end

    -- ==========================================================
    -- SECTION (avec accent bar)
    -- ==========================================================
    function UI:section(parent, txt)
        local holder = Instance.new("Frame", parent)
        holder.Size = UDim2.new(1, 0, 0, 24)
        holder.BackgroundTransparency = 1

        local bar = Instance.new("Frame", holder)
        bar.Size = UDim2.new(0, 3, 0, 14)
        bar.Position = UDim2.new(0, 0, 0.5, -7)
        bar.BackgroundColor3 = C.accent
        bar.BorderSizePixel = 0
        corner(bar, 2)
        gradient(bar, C.accent, C.accentPink, 90)

        local l = Instance.new("TextLabel", holder)
        l.Size = UDim2.new(1, -14, 1, 0)
        l.Position = UDim2.new(0, 12, 0, 0)
        l.BackgroundTransparency = 1
        l.Text = string.upper(txt)
        l.Font = Enum.Font.GothamBold
        l.TextSize = 11
        l.TextColor3 = C.accentBright
        l.TextXAlignment = Enum.TextXAlignment.Left
        return holder
    end

    -- ==========================================================
    -- TOGGLE (premium)
    -- ==========================================================
    function UI:toggle(parent, txt, def, cb, opts)
        opts = opts or {}
        local r = Instance.new("Frame", parent)
        r.Size = UDim2.new(1, 0, 0, 46)
        r.BackgroundColor3 = C.elem
        r.BorderSizePixel = 0
        corner(r, 8)
        stroke(r, C.txtfaint, 1, 0.7)

        local l = Instance.new("TextLabel", r)
        l.Size = UDim2.new(1, -70, 1, 0)
        l.Position = UDim2.new(0, 14, 0, 0)
        l.BackgroundTransparency = 1
        l.Text = txt
        l.Font = Enum.Font.GothamMedium
        l.TextSize = 13
        l.TextColor3 = C.txt
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.TextTruncate = Enum.TextTruncate.AtEnd

        local tk = Instance.new("Frame", r)
        tk.Size = UDim2.new(0, 46, 0, 24)
        tk.Position = UDim2.new(1, -58, 0.5, -12)
        tk.BackgroundColor3 = C.bg
        tk.BorderSizePixel = 0
        corner(tk, 12)
        local tks = stroke(tk, C.txtfaint, 1, 0.6)

        local kn = Instance.new("Frame", tk)
        kn.Size = UDim2.new(0, 18, 0, 18)
        kn.Position = UDim2.new(0, 3, 0.5, -9)
        kn.BackgroundColor3 = C.txtdim
        kn.BorderSizePixel = 0
        corner(kn, 9)
        local kns = stroke(kn, C.txt, 1, 0.9)

        local b = Instance.new("TextButton", r)
        b.Size = UDim2.new(1, 0, 1, 0)
        b.BackgroundTransparency = 1
        b.Text = ""
        b.AutoButtonColor = false

        local st = def or false
        local function ap(v, sk)
            st = v
            tween(kn, 0.18, {
                Position = v and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
                BackgroundColor3 = v and C.accentBright or C.txtdim,
            })
            tween(tk, 0.18, {
                BackgroundColor3 = v and C.accentDim or C.bg,
            })
            tween(tks, 0.18, {
                Color = v and C.accentBright or C.txtfaint,
                Transparency = v and 0.2 or 0.6,
            })
            if not sk and cb then cb(v) end
        end
        ap(st, true)

        b.MouseEnter:Connect(function()
            tween(r, 0.15, { BackgroundColor3 = C.elemHover })
        end)
        b.MouseLeave:Connect(function()
            tween(r, 0.15, { BackgroundColor3 = C.elem })
        end)
        b.MouseButton1Click:Connect(function() ap(not st) end)

        if opts.keybind then
            Keybind:add(opts.keybind, opts.defaultKey or Enum.KeyCode.Unknown, function()
                ap(not st)
                Notify:push(opts.keybind, st and "Activé" or "Désactivé", 1.5)
            end)
        end
        return { get = function() return st end, set = ap }
    end

    -- ==========================================================
    -- SLIDER (premium avec valeur stylée)
    -- ==========================================================
    function UI:slider(parent, txt, mn, mx, def, cb)
        local r = Instance.new("Frame", parent)
        r.Size = UDim2.new(1, 0, 0, 60)
        r.BackgroundColor3 = C.elem
        r.BorderSizePixel = 0
        corner(r, 8)
        stroke(r, C.txtfaint, 1, 0.7)

        local l = Instance.new("TextLabel", r)
        l.Size = UDim2.new(1, -80, 0, 20)
        l.Position = UDim2.new(0, 14, 0, 6)
        l.BackgroundTransparency = 1
        l.Text = txt
        l.Font = Enum.Font.GothamMedium
        l.TextSize = 13
        l.TextColor3 = C.txt
        l.TextXAlignment = Enum.TextXAlignment.Left

        -- Pill pour la valeur
        local pill = Instance.new("Frame", r)
        pill.Size = UDim2.new(0, 50, 0, 22)
        pill.Position = UDim2.new(1, -62, 0, 6)
        pill.BackgroundColor3 = C.accentDim
        pill.BorderSizePixel = 0
        corner(pill, 6)
        gradient(pill, C.accent, C.accentPink, 45)
        local pillG = pill:FindFirstChildOfClass("UIGradient")
        pillG.Transparency = NumberSequence.new(0.3)

        local vl = Instance.new("TextLabel", pill)
        vl.Size = UDim2.new(1, 0, 1, 0)
        vl.BackgroundTransparency = 1
        vl.Text = tostring(def)
        vl.Font = Enum.Font.GothamBold
        vl.TextSize = 12
        vl.TextColor3 = C.txt

        local trackH = isMobile and 14 or 8
        local tk = Instance.new("Frame", r)
        tk.Size = UDim2.new(1, -28, 0, trackH)
        tk.Position = UDim2.new(0, 14, 0, 38)
        tk.BackgroundColor3 = C.bg
        tk.BorderSizePixel = 0
        corner(tk, trackH / 2)
        stroke(tk, C.txtfaint, 1, 0.7)

        local fl = Instance.new("Frame", tk)
        fl.Size = UDim2.new(0, 0, 1, 0)
        fl.BackgroundColor3 = C.accent
        fl.BorderSizePixel = 0
        corner(fl, trackH / 2)
        gradient(fl, C.accent, C.accentPink, 0)

        local knS = isMobile and 22 or 16
        local kn = Instance.new("Frame", tk)
        kn.Size = UDim2.new(0, knS, 0, knS)
        kn.Position = UDim2.new(0, -knS/2, 0.5, -knS/2)
        kn.BackgroundColor3 = C.txt
        kn.BorderSizePixel = 0
        corner(kn, knS / 2)
        local kns = stroke(kn, C.accent, 2, 0.2)

        local val = def
        local drag = false

        local function ap(v, sk)
            v = math.clamp(v, mn, mx)
            val = v
            local ra = (v - mn) / (mx - mn)
            tween(fl, 0.08, { Size = UDim2.new(ra, 0, 1, 0) })
            tween(kn, 0.08, { Position = UDim2.new(ra, -knS/2, 0.5, -knS/2) })
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
                tween(kn, 0.15, { Size = UDim2.new(0, knS + 4, 0, knS + 4),
                    Position = UDim2.new(kn.Position.X.Scale, -(knS+4)/2, 0.5, -(knS+4)/2) })
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
                tween(kn, 0.15, { Size = UDim2.new(0, knS, 0, knS) })
            end
        end)
        return { get = function() return val end, set = ap }
    end

    -- ==========================================================
    -- BOUTON (premium)
    -- ==========================================================
    function UI:button(parent, txt, cb)
        local b = Instance.new("TextButton", parent)
        b.Size = UDim2.new(1, 0, 0, 40)
        b.BackgroundColor3 = C.elem
        b.Text = txt
        b.Font = Enum.Font.GothamMedium
        b.TextSize = 13
        b.TextColor3 = C.txt
        b.BorderSizePixel = 0
        b.AutoButtonColor = false
        corner(b, 8)
        local s = stroke(b, C.txtfaint, 1, 0.7)

        b.MouseEnter:Connect(function()
            tween(b, 0.15, { BackgroundColor3 = C.accentDim })
            tween(s, 0.15, { Color = C.accentBright, Transparency = 0.3 })
        end)
        b.MouseLeave:Connect(function()
            tween(b, 0.15, { BackgroundColor3 = C.elem })
            tween(s, 0.15, { Color = C.txtfaint, Transparency = 0.7 })
        end)
        b.MouseButton1Click:Connect(function()
            if cb then cb() end
        end)
        return b
    end
end

-- ============================================================
-- MODULES
-- ============================================================

-- FLY
do
    local t = UI:tab("Movement", "✈")
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
            local jv = Mobile.joystick
            if jv.Magnitude > 0.1 then
                mv = mv + cm.CFrame.LookVector * -jv.Y
                mv = mv + cm.CFrame.RightVector * jv.X
            end
            if Mobile.up then mv = mv + Vector3.new(0,1,0) end
            if Mobile.down then mv = mv - Vector3.new(0,1,0) end
            if mv.Magnitude > 0 then mv = mv.Unit end
            vl = vl:Lerp(mv * spd, 0.15)
            bv.Velocity = vl
            bg.CFrame = cm.CFrame
        end)
    end

    UI:toggle(t, "Fly", false, function(v) if v then start() else stop() end end,
        { keybind = "Fly", defaultKey = Enum.KeyCode.F })
    UI:slider(t, "Vitesse", 20, 300, 60, function(v) spd = v end)
    LP.CharacterAdded:Connect(stop)
end

-- PLAYER
do
    local t = UI:tab("Player", "👤")
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
    UI:button(t, "↻  Reset personnage", function()
        local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if h then h.Health = 0 end
    end)
    UI:button(t, "⟳  Rejoindre le serveur", function()
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
    local t = UI:tab("Visuals", "◐")
    UI:section(t, "Éclairage")
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

-- ============================================================
-- CONTRÔLES MOBILES
-- ============================================================
if isMobile then
    local gui = UI.gui

    local joyBase = Instance.new("Frame", gui)
    joyBase.Size = UDim2.new(0, 140, 0, 140)
    joyBase.Position = UDim2.new(0, 30, 1, -170)
    joyBase.BackgroundColor3 = Color3.fromRGB(30, 34, 46)
    joyBase.BackgroundTransparency = 0.4
    joyBase.BorderSizePixel = 0
    joyBase.Active = true
    joyBase.Visible = false
    corner(joyBase, 70)
    stroke(joyBase, C.accent, 2, 0.3)

    local joyKnob = Instance.new("Frame", joyBase)
    joyKnob.Size = UDim2.new(0, 60, 0, 60)
    joyKnob.Position = UDim2.new(0.5, -30, 0.5, -30)
    joyKnob.BackgroundColor3 = C.accent
    joyKnob.BackgroundTransparency = 0.05
    joyKnob.BorderSizePixel = 0
    corner(joyKnob, 30)
    gradient(joyKnob, C.accent, C.accentPink, 135)

    local joyTouchId = nil
    local joyCenter = Vector2.new(0, 0)
    local JOY_RADIUS = 45

    local function updateJoy(pos)
        local d = Vector2.new(pos.X, pos.Y) - joyCenter
        local m = d.Magnitude
        if m > JOY_RADIUS then d = d.Unit * JOY_RADIUS end
        joyKnob.Position = UDim2.new(0.5, d.X - 30, 0.5, d.Y - 30)
        Mobile.joystick = d / JOY_RADIUS
    end
    local function resetJoy()
        Mobile.joystick = Vector2.new(0, 0)
        joyKnob.Position = UDim2.new(0.5, -30, 0.5, -30)
        joyTouchId = nil
    end

    joyBase.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch
        or i.UserInputType == Enum.UserInputType.MouseButton1 then
            joyTouchId = i
            joyCenter = Vector2.new(
                joyBase.AbsolutePosition.X + joyBase.AbsoluteSize.X / 2,
                joyBase.AbsolutePosition.Y + joyBase.AbsoluteSize.Y / 2
            )
            updateJoy(i.Position)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if joyTouchId and i == joyTouchId then updateJoy(i.Position) end
    end)
    UIS.InputEnded:Connect(function(i)
        if joyTouchId and i == joyTouchId then resetJoy() end
    end)

    local function mkBtn(txt, pos)
        local b = Instance.new("TextButton", gui)
        b.Size = UDim2.new(0, 60, 0, 60)
        b.Position = pos
        b.BackgroundColor3 = Color3.fromRGB(30, 34, 46)
        b.BackgroundTransparency = 0.2
        b.Text = txt
        b.Font = Enum.Font.GothamBold
        b.TextSize = 24
        b.TextColor3 = C.accentBright
        b.BorderSizePixel = 0
        b.Visible = false
        b.AutoButtonColor = false
        corner(b, 30)
        stroke(b, C.accent, 1.5, 0.3)
        return b
    end

    local upBtn = mkBtn("▲", UDim2.new(1, -90, 1, -240))
    local downBtn = mkBtn("▼", UDim2.new(1, -90, 1, -170))

    upBtn.MouseButton1Down:Connect(function() Mobile.up = true end)
    upBtn.MouseButton1Up:Connect(function() Mobile.up = false end)
    upBtn.MouseLeave:Connect(function() Mobile.up = false end)
    downBtn.MouseButton1Down:Connect(function() Mobile.down = true end)
    downBtn.MouseButton1Up:Connect(function() Mobile.down = false end)
    downBtn.MouseLeave:Connect(function() Mobile.down = false end)

    task.spawn(function()
        while task.wait(0.2) do
            local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            local show = h and h.PlatformStand
            joyBase.Visible = show or false
            upBtn.Visible = show or false
            downBtn.Visible = show or false
        end
    end)
end

UI:default()
Notify:push("Pulse Hub", isMobile and "Mode mobile · v0.6" or "v0.6 · RightShift pour ouvrir", 5)
print("[Pulse Hub] v0.6 OK - Mobile: " .. tostring(isMobile))
