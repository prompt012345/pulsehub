--[[
    ═══════════════════════════════════════════════════════════════════
    ⚡ PULSE HUB · v3.0 · Ultimate Edition
    ═══════════════════════════════════════════════════════════════════
    github.com/prompt012345/pulsehub
    ─────────────────────────────────────────────────────────────────
    Modules (17) :
      Movement : Fly · Noclip · Infinite Jump
      Player   : WalkSpeed · JumpPower · Teleport · Actions
      Visuals  : Invisibilité · Fullbright · ESP+Armes
                 Skin Changer · Texture Simplifier · Vortex
      Camera   : Free Cam
      Combat   : Aimbot · Trigger Bot · Aimbot Proximité (priorité armes)
      Utility  : Info serveur
    ─────────────────────────────────────────────────────────────────
    Contrôles : RightShift = UI · Chaque module a son keybind
    ═══════════════════════════════════════════════════════════════════
--]]

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UIS              = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Lighting         = game:GetService("Lighting")
local TeleportService  = game:GetService("TeleportService")
local HttpService      = game:GetService("HttpService")
local AssetService     = game:GetService("AssetService")
local LP               = Players.LocalPlayer

local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

-- ═══════════════════════════════════════════════════════════════════
-- PALETTE
-- ═══════════════════════════════════════════════════════════════════
local C = {
    bg          = Color3.fromRGB(12, 12, 18),
    bgGrad      = Color3.fromRGB(24, 18, 42),
    panel       = Color3.fromRGB(18, 18, 28),
    panelLight  = Color3.fromRGB(26, 26, 38),
    elem        = Color3.fromRGB(30, 30, 44),
    elemHover   = Color3.fromRGB(42, 42, 60),
    accent      = Color3.fromRGB(167, 139, 250),
    accentBright= Color3.fromRGB(196, 181, 253),
    accentPink  = Color3.fromRGB(236, 72, 153),
    accentCyan  = Color3.fromRGB(34, 211, 238),
    accentDim   = Color3.fromRGB(88, 60, 180),
    success     = Color3.fromRGB(52, 211, 153),
    warn        = Color3.fromRGB(251, 191, 36),
    danger      = Color3.fromRGB(248, 113, 113),
    txt         = Color3.fromRGB(245, 245, 250),
    txtdim      = Color3.fromRGB(142, 142, 160),
    txtfaint    = Color3.fromRGB(75, 75, 95),
}

-- ═══════════════════════════════════════════════════════════════════
-- HELPERS
-- ═══════════════════════════════════════════════════════════════════
local function corner(o, r)
    local c = Instance.new("UICorner", o)
    c.CornerRadius = UDim.new(0, r or 8)
    return c
end
local function stroke(o, col, th, tr)
    local s = Instance.new("UIStroke", o)
    s.Color = col or C.accent
    s.Thickness = th or 1
    s.Transparency = tr or 0.4
    return s
end
local function grad(o, c1, c2, rot)
    local g = Instance.new("UIGradient", o)
    g.Color = ColorSequence.new(c1, c2)
    g.Rotation = rot or 0
    return g
end
local function pad(o, t, b, l, r)
    local p = Instance.new("UIPadding", o)
    if t then p.PaddingTop = UDim.new(0, t) end
    if b then p.PaddingBottom = UDim.new(0, b) end
    if l then p.PaddingLeft = UDim.new(0, l) end
    if r then p.PaddingRight = UDim.new(0, r) end
    return p
end
local function tw(o, time, props)
    TweenService:Create(o, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end
local function char() return LP.Character end
local function hum()
    local c = char()
    return c and c:FindFirstChildOfClass("Humanoid")
end
local function root()
    local c = char()
    return c and c:FindFirstChild("HumanoidRootPart")
end

-- ═══════════════════════════════════════════════════════════════════
-- DÉTECTION D'ARME (global)
-- ═══════════════════════════════════════════════════════════════════
local WEAPON_KEYWORDS = {
    "sword","knife","gun","pistol","rifle","shotgun","bow","arrow",
    "axe","blade","weapon","sniper","smg","lmg","carbine","revolver",
    "dagger","katana","scythe","spear","hammer","mace","club","stick",
    "bomb","grenade","launcher","rpg","bazooka","crossbow",
    "épée","couteau","pistolet","fusil","arc","hache","lame","arme",
    "fronde","marteau","bâton",
}
local DAMAGE_KEYS = {
    "damage","dmg","hit","attack","power","hurt","dégâts","degats","puissance",
}

local function isWeaponTool(tool)
    if not tool or not tool:IsA("Tool") then return false end
    if not tool:FindFirstChild("Handle") then return false end
    local lower = string.lower(tool.Name)
    for _, kw in ipairs(WEAPON_KEYWORDS) do
        if string.find(lower, kw) then return true end
    end
    for _, child in ipairs(tool:GetDescendants()) do
        local cn = string.lower(child.Name)
        for _, key in ipairs(DAMAGE_KEYS) do
            if string.find(cn, key) then
                if child:IsA("NumberValue") or child:IsA("IntValue") then
                    if child.Value > 0 then return true end
                else
                    return true
                end
            end
        end
    end
    for _, child in ipairs(tool:GetDescendants()) do
        if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
            local cn = string.lower(child.Name)
            if string.find(cn, "damage") or string.find(cn, "hit") then
                return true
            end
        end
    end
    if tool:GetAttribute("CanBeDropped") == false then return true end
    return false
end

local function playerHasWeapon(c)
    if not c then return false end
    for _, child in ipairs(c:GetChildren()) do
        if child:IsA("Tool") and isWeaponTool(child) then return true end
    end
    return false
end

local function getWeapon(c)
    if not c then return nil end
    for _, child in ipairs(c:GetChildren()) do
        if child:IsA("Tool") and isWeaponTool(child) then return child end
    end
    return nil
end

-- Cache pour optimiser
local weaponCache, weaponCacheTime = {}, {}
local WEAPON_CACHE_DURATION = 0.5
local function playerHasWeaponCached(pl, c)
    local now = os.clock()
    local last = weaponCacheTime[pl]
    if last and now - last < WEAPON_CACHE_DURATION then
        return weaponCache[pl] or false
    end
    local has = playerHasWeapon(c)
    weaponCache[pl] = has
    weaponCacheTime[pl] = now
    return has
end

-- ═══════════════════════════════════════════════════════════════════
-- NOTIFICATIONS
-- ═══════════════════════════════════════════════════════════════════
local Notify = {}
do
    local gui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
    gui.Name = "PulseNotify"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 9999
    local cont = Instance.new("Frame", gui)
    cont.AnchorPoint = Vector2.new(1, 0)
    cont.Position = UDim2.new(1, -20, 0, 20)
    cont.Size = UDim2.new(0, 320, 1, -40)
    cont.BackgroundTransparency = 1
    local ll = Instance.new("UIListLayout", cont)
    ll.Padding = UDim.new(0, 10)
    ll.HorizontalAlignment = Enum.HorizontalAlignment.Right

    function Notify:push(title, msg, dur, col)
        col = col or C.accent
        local t = Instance.new("Frame", cont)
        t.Size = UDim2.new(1, 0, 0, 68)
        t.BackgroundColor3 = C.panel
        t.BackgroundTransparency = 0.05
        t.BorderSizePixel = 0
        corner(t, 10)
        local s = stroke(t, col, 1.5, 0.3)

        local accent = Instance.new("Frame", t)
        accent.Size = UDim2.new(0, 3, 1, -20)
        accent.Position = UDim2.new(0, 9, 0, 10)
        accent.BackgroundColor3 = col
        accent.BorderSizePixel = 0
        corner(accent, 2)

        local ico = Instance.new("TextLabel", t)
        ico.Size = UDim2.new(0, 26, 0, 26)
        ico.Position = UDim2.new(0, 22, 0, 12)
        ico.BackgroundTransparency = 1
        ico.Text = "⚡"
        ico.Font = Enum.Font.GothamBold
        ico.TextSize = 16
        ico.TextColor3 = col
        ico.TextXAlignment = Enum.TextXAlignment.Left

        local a = Instance.new("TextLabel", t)
        a.Size = UDim2.new(1, -60, 0, 20)
        a.Position = UDim2.new(0, 50, 0, 12)
        a.BackgroundTransparency = 1
        a.Text = title
        a.Font = Enum.Font.GothamBold
        a.TextSize = 13
        a.TextColor3 = col
        a.TextXAlignment = Enum.TextXAlignment.Left

        local b = Instance.new("TextLabel", t)
        b.Size = UDim2.new(1, -60, 0, 26)
        b.Position = UDim2.new(0, 50, 0, 32)
        b.BackgroundTransparency = 1
        b.Text = msg
        b.Font = Enum.Font.Gotham
        b.TextSize = 12
        b.TextColor3 = C.txt
        b.TextXAlignment = Enum.TextXAlignment.Left

        local pr = Instance.new("Frame", t)
        pr.Size = UDim2.new(1, -18, 0, 2)
        pr.Position = UDim2.new(0, 9, 1, -4)
        pr.BackgroundColor3 = col
        pr.BorderSizePixel = 0
        corner(pr, 1)
        tw(pr, dur or 4, { Size = UDim2.new(0, 0, 0, 2) })

        task.delay(dur or 4, function()
            tw(t, 0.3, { BackgroundTransparency = 1 })
            task.wait(0.35)
            t:Destroy()
        end)
    end
end

-- ═══════════════════════════════════════════════════════════════════
-- KEYBINDS
-- ═══════════════════════════════════════════════════════════════════
local Keybind = { binds = {} }
function Keybind:add(name, key, cb)
    self.binds[name] = { key = key, cb = cb }
end
UIS.InputBegan:Connect(function(i, p)
    if p then return end
    for _, b in pairs(Keybind.binds) do
        if i.KeyCode == b.key then pcall(b.cb) end
    end
end)

-- ═══════════════════════════════════════════════════════════════════
-- ÉTAT GLOBAL
-- ═══════════════════════════════════════════════════════════════════
local State = {
    mobile = { joystick = Vector2.new(0, 0), up = false, down = false },
}

-- ═══════════════════════════════════════════════════════════════════
-- UI PRINCIPALE
-- ═══════════════════════════════════════════════════════════════════
local UI = { tabs = {} }
do
    local gui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
    gui.Name = "PulseHub"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    UI.gui = gui

    -- Bouton flottant
    local floatBtn = Instance.new("TextButton", gui)
    floatBtn.Size = UDim2.new(0, 62, 0, 62)
    floatBtn.Position = UDim2.new(1, -84, 1, -160)
    floatBtn.BackgroundColor3 = C.accent
    floatBtn.Text = "⚡"
    floatBtn.Font = Enum.Font.GothamBold
    floatBtn.TextSize = 28
    floatBtn.TextColor3 = C.txt
    floatBtn.BorderSizePixel = 0
    floatBtn.Active = true
    floatBtn.Draggable = true
    floatBtn.AutoButtonColor = false
    corner(floatBtn, 31)
    grad(floatBtn, C.accent, C.accentPink, 135)
    stroke(floatBtn, C.accentBright, 2, 0.2)

    task.spawn(function()
        while floatBtn.Parent do
            tw(floatBtn, 1.8, { Size = UDim2.new(0, 66, 0, 66) })
            task.wait(1.8)
            tw(floatBtn, 1.8, { Size = UDim2.new(0, 62, 0, 62) })
            task.wait(1.8)
        end
    end)

    -- Fenêtre
    local w = Instance.new("Frame", gui)
    w.Size = isMobile and UDim2.new(0, 420, 0, 540) or UDim2.new(0, 640, 0, 460)
    w.Position = UDim2.new(0.5, isMobile and -210 or -320, 0.5, isMobile and -270 or -230)
    w.BackgroundColor3 = C.bg
    w.BorderSizePixel = 0
    w.Active = true
    w.Draggable = true
    w.Visible = false
    corner(w, 14)
    stroke(w, C.accent, 1.5, 0.5)
    UI.window = w

    -- Barre de titre
    local tb = Instance.new("Frame", w)
    tb.Size = UDim2.new(1, 0, 0, 54)
    tb.BackgroundColor3 = C.panel
    tb.BackgroundTransparency = 0.3
    tb.BorderSizePixel = 0
    corner(tb, 14)

    local tbFix = Instance.new("Frame", tb)
    tbFix.Size = UDim2.new(1, 0, 0, 14)
    tbFix.Position = UDim2.new(0, 0, 1, -14)
    tbFix.BackgroundColor3 = C.panel
    tbFix.BackgroundTransparency = 0.3
    tbFix.BorderSizePixel = 0

    local tbg = Instance.new("Frame", w)
    tbg.Size = UDim2.new(1, -24, 0, 2)
    tbg.Position = UDim2.new(0, 12, 0, 54)
    tbg.BackgroundColor3 = C.accent
    tbg.BorderSizePixel = 0
    tbg.BackgroundTransparency = 0.2
    corner(tbg, 1)
    grad(tbg, C.accent, C.accentPink, 0)

    local logoBox = Instance.new("Frame", tb)
    logoBox.Size = UDim2.new(0, 36, 0, 36)
    logoBox.Position = UDim2.new(0, 16, 0.5, -18)
    logoBox.BackgroundColor3 = C.accent
    logoBox.BorderSizePixel = 0
    corner(logoBox, 9)
    grad(logoBox, C.accent, C.accentPink, 135)

    local logoIcon = Instance.new("TextLabel", logoBox)
    logoIcon.Size = UDim2.new(1, 0, 1, 0)
    logoIcon.BackgroundTransparency = 1
    logoIcon.Text = "⚡"
    logoIcon.Font = Enum.Font.GothamBold
    logoIcon.TextSize = 20
    logoIcon.TextColor3 = C.txt

    local title = Instance.new("TextLabel", tb)
    title.Size = UDim2.new(0, 250, 0, 22)
    title.Position = UDim2.new(0, 62, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "PULSE HUB"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 17
    title.TextColor3 = C.txt
    title.TextXAlignment = Enum.TextXAlignment.Left

    local sub = Instance.new("TextLabel", tb)
    sub.Size = UDim2.new(0, 250, 0, 14)
    sub.Position = UDim2.new(0, 62, 0, 30)
    sub.BackgroundTransparency = 1
    sub.Text = "Ultimate Edition · v3.0 · " .. (isMobile and "Mobile" or "PC")
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 10
    sub.TextColor3 = C.txtdim
    sub.TextXAlignment = Enum.TextXAlignment.Left

    local statusDot = Instance.new("Frame", tb)
    statusDot.Size = UDim2.new(0, 8, 0, 8)
    statusDot.Position = UDim2.new(1, -110, 0, 23)
    statusDot.BackgroundColor3 = C.success
    statusDot.BorderSizePixel = 0
    corner(statusDot, 4)

    local statusLbl = Instance.new("TextLabel", tb)
    statusLbl.Size = UDim2.new(0, 50, 0, 14)
    statusLbl.Position = UDim2.new(1, -98, 0, 20)
    statusLbl.BackgroundTransparency = 1
    statusLbl.Text = "EN LIGNE"
    statusLbl.Font = Enum.Font.GothamBold
    statusLbl.TextSize = 9
    statusLbl.TextColor3 = C.success
    statusLbl.TextXAlignment = Enum.TextXAlignment.Left

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
    xb.MouseEnter:Connect(function() tw(xb, 0.15, { BackgroundColor3 = C.danger, TextColor3 = C.txt }) end)
    xb.MouseLeave:Connect(function() tw(xb, 0.15, { BackgroundColor3 = C.elem, TextColor3 = C.txtdim }) end)
    xb.MouseButton1Click:Connect(function()
        w.Visible = false
        floatBtn.Visible = true
    end)

    floatBtn.MouseButton1Click:Connect(function()
        w.Visible = true
        floatBtn.Visible = false
    end)

    -- Sidebar
    local sbW = isMobile and 130 or 160
    local sb = Instance.new("Frame", w)
    sb.Size = UDim2.new(0, sbW, 1, -56)
    sb.Position = UDim2.new(0, 0, 0, 56)
    sb.BackgroundColor3 = C.panel
    sb.BackgroundTransparency = 0.5
    sb.BorderSizePixel = 0
    local sl = Instance.new("UIListLayout", sb)
    sl.Padding = UDim.new(0, 5)
    sl.SortOrder = Enum.SortOrder.LayoutOrder
    pad(sb, 10, 10, 10, 10)

    local ct = Instance.new("Frame", w)
    ct.Size = UDim2.new(1, -sbW, 1, -56)
    ct.Position = UDim2.new(0, sbW, 0, 56)
    ct.BackgroundTransparency = 1
    ct.BorderSizePixel = 0

    -- Tab function (retourne existant si déjà créé)
    function UI:tab(name, icon)
        if UI.tabs[name] then return UI.tabs[name].fr end

        local btn = Instance.new("TextButton", sb)
        btn.Size = UDim2.new(1, 0, 0, 42)
        btn.BackgroundColor3 = C.elem
        btn.BackgroundTransparency = 0.7
        btn.Text = ""
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        corner(btn, 9)

        local ind = Instance.new("Frame", btn)
        ind.Size = UDim2.new(0, 3, 0, 0)
        ind.Position = UDim2.new(0, 6, 0.5, 0)
        ind.BackgroundColor3 = C.accent
        ind.BorderSizePixel = 0
        ind.BackgroundTransparency = 1
        corner(ind, 2)

        local ic = Instance.new("TextLabel", btn)
        ic.Size = UDim2.new(0, 26, 1, 0)
        ic.Position = UDim2.new(0, 14, 0, 0)
        ic.BackgroundTransparency = 1
        ic.Text = icon or "•"
        ic.Font = Enum.Font.GothamBold
        ic.TextSize = 16
        ic.TextColor3 = C.txtdim
        ic.TextXAlignment = Enum.TextXAlignment.Left

        local lbl = Instance.new("TextLabel", btn)
        lbl.Size = UDim2.new(1, -44, 1, 0)
        lbl.Position = UDim2.new(0, 44, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = name
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 13
        lbl.TextColor3 = C.txtdim
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local fr = Instance.new("ScrollingFrame", ct)
        fr.Size = UDim2.new(1, -22, 1, -22)
        fr.Position = UDim2.new(0, 11, 0, 11)
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
            tw(btn, 0.15, { BackgroundTransparency = 0.4 })
            tw(lbl, 0.15, { TextColor3 = C.txt })
        end)
        btn.MouseLeave:Connect(function()
            if UI.tabs[name].fr.Visible then return end
            tw(btn, 0.15, { BackgroundTransparency = 0.7 })
            tw(lbl, 0.15, { TextColor3 = C.txtdim })
        end)

        btn.MouseButton1Click:Connect(function()
            for n, t in pairs(UI.tabs) do
                local a = (n == name)
                t.fr.Visible = a
                tw(t.btn, 0.2, { BackgroundTransparency = a and 0.2 or 0.7 })
                tw(t.lbl, 0.2, { TextColor3 = a and C.txt or C.txtdim })
                tw(t.ic, 0.2, { TextColor3 = a and C.accentBright or C.txtdim })
                tw(t.ind, 0.2, {
                    BackgroundTransparency = a and 0 or 1,
                    Size = UDim2.new(0, 3, 0, a and 22 or 0),
                })
            end
        end)
        return fr
    end

    function UI:default()
        local f = next(UI.tabs)
        if not f then return end
        for n, t in pairs(UI.tabs) do
            local a = (n == f)
            t.fr.Visible = a
            t.btn.BackgroundTransparency = a and 0.2 or 0.7
            t.lbl.TextColor3 = a and C.txt or C.txtdim
            t.ic.TextColor3 = a and C.accentBright or C.txtdim
            t.ind.BackgroundTransparency = a and 0 or 1
            t.ind.Size = UDim2.new(0, 3, 0, a and 22 or 0)
        end
    end

    function UI:section(parent, txt)
        local holder = Instance.new("Frame", parent)
        holder.Size = UDim2.new(1, 0, 0, 26)
        holder.BackgroundTransparency = 1

        local bar = Instance.new("Frame", holder)
        bar.Size = UDim2.new(0, 3, 0, 16)
        bar.Position = UDim2.new(0, 0, 0.5, -8)
        bar.BackgroundColor3 = C.accent
        bar.BorderSizePixel = 0
        corner(bar, 2)
        grad(bar, C.accent, C.accentPink, 90)

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

    function UI:toggle(parent, txt, def, cb, opts)
        opts = opts or {}
        local r = Instance.new("Frame", parent)
        r.Size = UDim2.new(1, 0, 0, 48)
        r.BackgroundColor3 = C.elem
        r.BorderSizePixel = 0
        corner(r, 9)
        local rs = stroke(r, C.txtfaint, 1, 0.75)

        local l = Instance.new("TextLabel", r)
        l.Size = UDim2.new(1, -130, 1, 0)
        l.Position = UDim2.new(0, 14, 0, 0)
        l.BackgroundTransparency = 1
        l.Text = txt
        l.Font = Enum.Font.GothamMedium
        l.TextSize = 13
        l.TextColor3 = C.txt
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.TextTruncate = Enum.TextTruncate.AtEnd

        if opts.keybind then
            local kb = Instance.new("TextLabel", r)
            kb.Size = UDim2.new(0, 26, 0, 20)
            kb.Position = UDim2.new(1, -96, 0.5, -10)
            kb.BackgroundColor3 = C.bg
            kb.BorderSizePixel = 0
            kb.Text = opts.keyName or "?"
            kb.Font = Enum.Font.GothamBold
            kb.TextSize = 10
            kb.TextColor3 = C.txtdim
            corner(kb, 5)
            stroke(kb, C.txtfaint, 1, 0.6)
        end

        local tk = Instance.new("Frame", r)
        tk.Size = UDim2.new(0, 48, 0, 26)
        tk.Position = UDim2.new(1, -60, 0.5, -13)
        tk.BackgroundColor3 = C.bg
        tk.BorderSizePixel = 0
        corner(tk, 13)
        local tks = stroke(tk, C.txtfaint, 1, 0.6)

        local kn = Instance.new("Frame", tk)
        kn.Size = UDim2.new(0, 20, 0, 20)
        kn.Position = UDim2.new(0, 3, 0.5, -10)
        kn.BackgroundColor3 = C.txtdim
        kn.BorderSizePixel = 0
        corner(kn, 10)
        stroke(kn, C.txt, 1, 0.9)

        local b = Instance.new("TextButton", r)
        b.Size = UDim2.new(1, 0, 1, 0)
        b.BackgroundTransparency = 1
        b.Text = ""
        b.AutoButtonColor = false

        local st = def or false
        local function ap(v, sk)
            st = v
            tw(kn, 0.18, {
                Position = v and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10),
                BackgroundColor3 = v and C.accentBright or C.txtdim,
            })
            tw(tk, 0.18, { BackgroundColor3 = v and C.accentDim or C.bg })
            tw(tks, 0.18, { Color = v and C.accentBright or C.txtfaint })
            if not sk and cb then pcall(cb, v) end
        end
        ap(st, true)

        b.MouseEnter:Connect(function()
            tw(r, 0.15, { BackgroundColor3 = C.elemHover })
            tw(rs, 0.15, { Color = C.accent, Transparency = 0.5 })
        end)
        b.MouseLeave:Connect(function()
            tw(r, 0.15, { BackgroundColor3 = C.elem })
            tw(rs, 0.15, { Color = C.txtfaint, Transparency = 0.75 })
        end)
        b.MouseButton1Click:Connect(function() ap(not st) end)

        if opts.keybind then
            Keybind:add(opts.keybind, opts.defaultKey or Enum.KeyCode.Unknown, function()
                ap(not st)
                Notify:push(opts.keybind, st and "✓ Activé" or "✕ Désactivé", 2,
                    st and C.success or C.danger)
            end)
        end
        return { get = function() return st end, set = ap }
    end

    function UI:slider(parent, txt, mn, mx, def, cb)
        local r = Instance.new("Frame", parent)
        r.Size = UDim2.new(1, 0, 0, 62)
        r.BackgroundColor3 = C.elem
        r.BorderSizePixel = 0
        corner(r, 9)
        stroke(r, C.txtfaint, 1, 0.75)

        local l = Instance.new("TextLabel", r)
        l.Size = UDim2.new(1, -80, 0, 20)
        l.Position = UDim2.new(0, 14, 0, 6)
        l.BackgroundTransparency = 1
        l.Text = txt
        l.Font = Enum.Font.GothamMedium
        l.TextSize = 13
        l.TextColor3 = C.txt
        l.TextXAlignment = Enum.TextXAlignment.Left

        local pill = Instance.new("Frame", r)
        pill.Size = UDim2.new(0, 52, 0, 22)
        pill.Position = UDim2.new(1, -66, 0, 5)
        pill.BackgroundColor3 = C.accentDim
        pill.BorderSizePixel = 0
        corner(pill, 6)
        grad(pill, C.accent, C.accentPink, 45)

        local vl = Instance.new("TextLabel", pill)
        vl.Size = UDim2.new(1, 0, 1, 0)
        vl.BackgroundTransparency = 1
        vl.Text = tostring(def)
        vl.Font = Enum.Font.GothamBold
        vl.TextSize = 12
        vl.TextColor3 = C.txt

        local trackH = isMobile and 16 or 10
        local tk = Instance.new("Frame", r)
        tk.Size = UDim2.new(1, -28, 0, trackH)
        tk.Position = UDim2.new(0, 14, 0, 40)
        tk.BackgroundColor3 = C.bg
        tk.BorderSizePixel = 0
        corner(tk, trackH / 2)
        stroke(tk, C.txtfaint, 1, 0.7)

        local fl = Instance.new("Frame", tk)
        fl.Size = UDim2.new(0, 0, 1, 0)
        fl.BackgroundColor3 = C.accent
        fl.BorderSizePixel = 0
        corner(fl, trackH / 2)
        grad(fl, C.accent, C.accentPink, 0)

        local knS = isMobile and 24 or 18
        local kn = Instance.new("Frame", tk)
        kn.Size = UDim2.new(0, knS, 0, knS)
        kn.Position = UDim2.new(0, -knS/2, 0.5, -knS/2)
        kn.BackgroundColor3 = C.txt
        kn.BorderSizePixel = 0
        corner(kn, knS / 2)
        stroke(kn, C.accent, 2, 0.2)

        local val = def
        local drag = false

        local function ap(v, sk)
            v = math.clamp(v, mn, mx)
            val = v
            local ra = (v - mn) / (mx - mn)
            tw(fl, 0.06, { Size = UDim2.new(ra, 0, 1, 0) })
            tw(kn, 0.06, { Position = UDim2.new(ra, -knS/2, 0.5, -knS/2) })
            vl.Text = tostring(math.floor(v * 10 + 0.5) / 10)
            if not sk and cb then pcall(cb, v) end
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
        b.Size = UDim2.new(1, 0, 0, 42)
        b.BackgroundColor3 = C.elem
        b.Text = txt
        b.Font = Enum.Font.GothamMedium
        b.TextSize = 13
        b.TextColor3 = C.txt
        b.BorderSizePixel = 0
        b.AutoButtonColor = false
        corner(b, 9)
        local s = stroke(b, C.txtfaint, 1, 0.75)

        b.MouseEnter:Connect(function()
            tw(b, 0.15, { BackgroundColor3 = C.accentDim })
            tw(s, 0.15, { Color = C.accentBright, Transparency = 0.3 })
        end)
        b.MouseLeave:Connect(function()
            tw(b, 0.15, { BackgroundColor3 = C.elem })
            tw(s, 0.15, { Color = C.txtfaint, Transparency = 0.75 })
        end)
        b.MouseButton1Click:Connect(function()
            if cb then pcall(cb) end
        end)
        return b
    end

    UIS.InputBegan:Connect(function(i, p)
        if p then return end
        if i.KeyCode == Enum.KeyCode.RightShift then
            w.Visible = not w.Visible
            floatBtn.Visible = not w.Visible
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════
-- MODULE : FLY
-- ═══════════════════════════════════════════════════════════════════
do
    local t = UI:tab("Movement", "✈")
    UI:section(t, "Vol")

    local spd = 65
    local bv, bg, cn, vl = nil, nil, nil, Vector3.zero

    local function stop()
        if cn then cn:Disconnect() cn = nil end
        if bv then bv:Destroy() bv = nil end
        if bg then bg:Destroy() bg = nil end
        local h = hum()
        if h then h.PlatformStand = false end
    end

    local function start()
        local c = char()
        if not c then return end
        local r = c:FindFirstChild("HumanoidRootPart")
        local h = c:FindFirstChildOfClass("Humanoid")
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
            local cc = char()
            if not cc then stop() return end
            local rt = cc:FindFirstChild("HumanoidRootPart")
            if not rt then return end
            local cm = workspace.CurrentCamera
            local mv = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then mv = mv + cm.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then mv = mv - cm.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then mv = mv + cm.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then mv = mv - cm.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then mv = mv + Vector3.new(0,1,0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then mv = mv - Vector3.new(0,1,0) end
            local jv = State.mobile.joystick
            if jv.Magnitude > 0.1 then
                mv = mv + cm.CFrame.LookVector * -jv.Y
                mv = mv + cm.CFrame.RightVector * jv.X
            end
            if State.mobile.up then mv = mv + Vector3.new(0,1,0) end
            if State.mobile.down then mv = mv - Vector3.new(0,1,0) end
            if mv.Magnitude > 0 then mv = mv.Unit end
            vl = vl:Lerp(mv * spd, 0.15)
            bv.Velocity = vl
            bg.CFrame = cm.CFrame
        end)
    end

    UI:toggle(t, "Fly", false, function(v) if v then start() else stop() end end,
        { keybind = "Fly", defaultKey = Enum.KeyCode.F, keyName = "F" })
    UI:slider(t, "Vitesse de vol", 20, 300, 65, function(v) spd = v end)
    LP.CharacterAdded:Connect(stop)
end

-- ═══════════════════════════════════════════════════════════════════
-- MODULE : NOCLIP
-- ═══════════════════════════════════════════════════════════════════
do
    local t = UI:tab("Movement")
    UI:section(t, "Collisions")
    local cn = nil
    UI:toggle(t, "Noclip", false, function(v)
        if v then
            cn = RunService.Stepped:Connect(function()
                local c = char()
                if not c then return end
                for _, p in ipairs(c:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end)
        else
            if cn then cn:Disconnect() cn = nil end
        end
    end, { keybind = "Noclip", defaultKey = Enum.KeyCode.N, keyName = "N" })
end

-- ═══════════════════════════════════════════════════════════════════
-- MODULE : INFINITE JUMP
-- ═══════════════════════════════════════════════════════════════════
do
    local t = UI:tab("Movement")
    UI:section(t, "Saut")
    local ij = false
    UI:toggle(t, "Infinite Jump", false, function(v) ij = v end,
        { keybind = "IJ", defaultKey = Enum.KeyCode.J, keyName = "J" })
    UIS.JumpRequest:Connect(function()
        if ij then
            local h = hum()
            if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════
-- MODULE : WALKSPEED
-- ═══════════════════════════════════════════════════════════════════
do
    local t = UI:tab("Player", "👤")
    UI:section(t, "Vitesse")
    UI:slider(t, "WalkSpeed", 8, 300, 16, function(v)
        local h = hum()
        if h then h.WalkSpeed = v end
    end)
    LP.CharacterAdded:Connect(function(c)
        task.wait(0.5)
        local h = c:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = 16 end
    end)
end

-- ═══════════════════════════════════════════════════════════════════
-- MODULE : JUMP POWER
-- ═══════════════════════════════════════════════════════════════════
do
    local t = UI:tab("Player")
    UI:section(t, "Puissance de saut")
    UI:slider(t, "JumpPower", 50, 400, 50, function(v)
        local h = hum()
        if h then
            h.UseJumpPower = true
            h.JumpPower = v
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════
-- MODULE : INVISIBILITÉ
-- ═══════════════════════════════════════════════════════════════════
do
    local t = UI:tab("Visuals", "◐")
    UI:section(t, "Invisibilité")

    local inv = false
    local saved = {}
    local savedDecor = {}

    local function apply()
        local c = char()
        if not c then return end
        saved, savedDecor = {}, {}
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then
                saved[p] = {
                    Transparency = p.Transparency,
                    LocalTransparencyModifier = p.LocalTransparencyModifier,
                    CanCollide = p.CanCollide,
                }
                p.Transparency = 1
                p.LocalTransparencyModifier = 1
                p.CanCollide = false
            end
        end
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("Accessory") or p:IsA("Decal") or p:IsA("BillboardGui") then
                savedDecor[p] = p.Transparency or 0
                pcall(function() p.Transparency = 1 end)
            end
        end
        local h = c:FindFirstChildOfClass("Humanoid")
        if h then
            h.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            h.NameDisplayDistance = 0
            h.HealthDisplayDistance = 0
        end
    end

    local function restore()
        local c = char()
        if not c then return end
        for p, props in pairs(saved) do
            if p and p.Parent then
                p.Transparency = props.Transparency
                p.LocalTransparencyModifier = props.LocalTransparencyModifier
                p.CanCollide = props.CanCollide
            end
        end
        for p, tr in pairs(savedDecor) do
            if p and p.Parent then
                pcall(function() p.Transparency = tr end)
            end
        end
        local h = c:FindFirstChildOfClass("Humanoid")
        if h then
            h.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
            h.NameDisplayDistance = 100
            h.HealthDisplayDistance = 100
        end
        saved, savedDecor = {}, {}
    end

    UI:toggle(t, "Invisible", false, function(v)
        inv = v
        if v then apply() else restore() end
    end, { keybind = "Invisible", defaultKey = Enum.KeyCode.I, keyName = "I" })

    LP.CharacterAdded:Connect(function()
        task.wait(0.6)
        if inv then apply() end
    end)
end

-- ═══════════════════════════════════════════════════════════════════
-- MODULE : FULLBRIGHT
-- ═══════════════════════════════════════════════════════════════════
do
    local t = UI:tab("Visuals")
    UI:section(t, "Éclairage")
    local sv = nil
    UI:toggle(t, "Fullbright", false, function(v)
        if v then
            sv = { Lighting.Brightness, Lighting.Ambient, Lighting.OutdoorAmbient,
                   Lighting.FogEnd, Lighting.GlobalShadows, Lighting.ClockTime }
            Lighting.Brightness = 3
            Lighting.Ambient = Color3.fromRGB(220, 220, 220)
            Lighting.OutdoorAmbient = Color3.fromRGB(220, 220, 220)
            Lighting.FogEnd = 1e6
            Lighting.GlobalShadows = false
            Lighting.ClockTime = 14
        elseif sv then
            Lighting.Brightness = sv[1]
            Lighting.Ambient = sv[2]
            Lighting.OutdoorAmbient = sv[3]
            Lighting.FogEnd = sv[4]
            Lighting.GlobalShadows = sv[5]
            Lighting.ClockTime = sv[6]
            sv = nil
        end
    end, { keybind = "FB", defaultKey = Enum.KeyCode.B, keyName = "B" })
end

-- ═══════════════════════════════════════════════════════════════════
-- MODULE : ESP + DÉTECTION ARMES
-- ═══════════════════════════════════════════════════════════════════
do
    local t = UI:tab("Visuals")
    UI:section(t, "ESP Joueurs")

    local state = {
        enabled      = false,
        box          = true,
        name         = true,
        dist         = true,
        health       = true,
        maxDist      = 500,
        teamCheck    = true,
        weaponDetect = true,
        weaponColor  = Color3.fromRGB(255, 30, 30),
        weaponGlow   = true,
        showWeapon   = true,
    }

    local dr = {}
    local hasD = Drawing and Drawing.new
    local pulse = 0

    local function cleanup(pl)
        if not dr[pl] then return end
        for _, o in pairs(dr[pl]) do
            if o and o.Remove then pcall(function() o:Remove() end) end
        end
        dr[pl] = nil
    end

    local function colorFor(pl, weapon)
        if state.weaponDetect and weapon then
            if state.weaponGlow then
                local intensity = 0.5 + math.abs(math.sin(pulse)) * 0.5
                return state.weaponColor:Lerp(Color3.fromRGB(255, 150, 150), intensity * 0.4)
            end
            return state.weaponColor
        end
        if state.teamCheck and pl.Team and LP.Team and pl.Team == LP.Team then
            return C.success
        end
        return C.accent
    end

    local cn
    local function start()
        if not hasD then
            Notify:push("ESP", "Drawing API indisponible", 4, C.danger)
            return
        end
        cn = RunService.RenderStepped:Connect(function(dt)
            pulse = pulse + dt * 4

            local cm = workspace.CurrentCamera
            local myRoot = root()
            if not myRoot then
                for p in pairs(dr) do cleanup(p) end
                return
            end
            local myPos = myRoot.Position

            for _, pl in ipairs(Players:GetPlayers()) do
                if pl == LP then continue end
                local c = pl.Character
                local h = c and c:FindFirstChildOfClass("Humanoid")
                local r = c and c:FindFirstChild("HumanoidRootPart")
                local hd = c and c:FindFirstChild("Head")

                if not (h and r and h.Health > 0) then
                    cleanup(pl)
                    continue
                end

                local d = (r.Position - myPos).Magnitude
                if d > state.maxDist then cleanup(pl) continue end

                local sp, onScr = cm:WorldToViewportPoint(r.Position)
                if not onScr then
                    if dr[pl] then
                        for _, o in pairs(dr[pl]) do o.Visible = false end
                    end
                    continue
                end

                local weapon = nil
                if state.weaponDetect then
                    weapon = getWeapon(c)
                end

                if not dr[pl] then
                    dr[pl] = {}
                    if state.box then
                        dr[pl].box = Drawing.new("Square")
                        dr[pl].box.Thickness = 2
                        dr[pl].box.Filled = false
                    end
                    if state.name then
                        dr[pl].name = Drawing.new("Text")
                        dr[pl].name.Size = 14
                        dr[pl].name.Center = true
                        dr[pl].name.Outline = true
                    end
                    if state.dist then
                        dr[pl].dist = Drawing.new("Text")
                        dr[pl].dist.Size = 12
                        dr[pl].dist.Center = true
                        dr[pl].dist.Outline = true
                    end
                    if state.health then
                        dr[pl].hb = Drawing.new("Square")
                        dr[pl].hb.Filled = true
                        dr[pl].hf = Drawing.new("Square")
                        dr[pl].hf.Filled = true
                    end
                    if state.showWeapon then
                        dr[pl].weapon = Drawing.new("Text")
                        dr[pl].weapon.Size = 11
                        dr[pl].weapon.Center = true
                        dr[pl].weapon.Outline = true
                    end
                    dr[pl].warn = Drawing.new("Text")
                    dr[pl].warn.Size = 16
                    dr[pl].warn.Center = true
                    dr[pl].warn.Outline = true
                end

                local headPos = hd and hd.Position or (r.Position + Vector3.new(0, 1.5, 0))
                local top = cm:WorldToViewportPoint(headPos + Vector3.new(0, 1, 0))
                local bot = cm:WorldToViewportPoint(r.Position - Vector3.new(0, 3, 0))

                local height = math.abs(top.Y - bot.Y)
                local width = height * 0.55
                local col = colorFor(pl, weapon)

                if dr[pl].box then
                    dr[pl].box.Size = Vector2.new(width, height)
                    dr[pl].box.Position = Vector2.new(sp.X - width/2, top.Y)
                    dr[pl].box.Color = col
                    dr[pl].box.Thickness = weapon and 2.5 or 1.5
                    dr[pl].box.Visible = true
                end

                if dr[pl].hb and dr[pl].hf then
                    local hr = math.clamp(h.Health / h.MaxHealth, 0, 1)
                    local bx = sp.X - width/2 - 6
                    dr[pl].hb.Size = Vector2.new(3, height)
                    dr[pl].hb.Position = Vector2.new(bx, top.Y)
                    dr[pl].hb.Color = Color3.fromRGB(30, 30, 30)
                    dr[pl].hb.Visible = true
                    dr[pl].hf.Size = Vector2.new(3, height * hr)
                    dr[pl].hf.Position = Vector2.new(bx, top.Y + height * (1 - hr))
                    dr[pl].hf.Color = C.success:Lerp(C.danger, 1 - hr)
                    dr[pl].hf.Visible = true
                end

                if dr[pl].name then
                    dr[pl].name.Position = Vector2.new(sp.X, top.Y - 18)
                    dr[pl].name.Text = pl.Name
                    dr[pl].name.Color = col
                    dr[pl].name.Visible = true
                end
                if dr[pl].dist then
                    dr[pl].dist.Position = Vector2.new(sp.X, bot.Y + 4)
                    dr[pl].dist.Text = string.format("[%d studs]", math.floor(d))
                    dr[pl].dist.Color = col
                    dr[pl].dist.Visible = true
                end
                if dr[pl].weapon then
                    if weapon and state.showWeapon then
                        dr[pl].weapon.Position = Vector2.new(sp.X, bot.Y + 20)
                        dr[pl].weapon.Text = "⚔ " .. weapon.Name
                        dr[pl].weapon.Color = state.weaponColor
                        dr[pl].weapon.Visible = true
                    else
                        dr[pl].weapon.Visible = false
                    end
                end
                if dr[pl].warn then
                    if weapon then
                        dr[pl].warn.Position = Vector2.new(sp.X + width/2 + 10, top.Y)
                        dr[pl].warn.Text = "⚠"
                        dr[pl].warn.Color = state.weaponColor
                        dr[pl].warn.Visible = true
                    else
                        dr[pl].warn.Visible = false
                    end
                end
            end
        end)
    end

    local function stop()
        if cn then cn:Disconnect() cn = nil end
        for p in pairs(dr) do cleanup(p) end
    end

    UI:toggle(t, "ESP Joueurs", false, function(v)
        state.enabled = v
        if v then start() else stop() end
    end, { keybind = "ESP", defaultKey = Enum.KeyCode.X, keyName = "X" })

    UI:toggle(t, "  Boîte", true, function(v) state.box = v end)
    UI:toggle(t, "  Pseudonyme", true, function(v) state.name = v end)
    UI:toggle(t, "  Distance", true, function(v) state.dist = v end)
    UI:toggle(t, "  Barre de vie", true, function(v) state.health = v end)
    UI:toggle(t, "  Team check", true, function(v) state.teamCheck = v end)

    UI:section(t, "Détection d'armes")
    UI:toggle(t, "🔴 Détection d'arme (rouge)", true, function(v) state.weaponDetect = v end)
    UI:toggle(t, "  Effet de pulsation", true, function(v) state.weaponGlow = v end)
    UI:toggle(t, "  Afficher nom de l'arme", true, function(v) state.showWeapon = v end)
    UI:slider(t, "  Distance max ESP", 50, 2000, 500, function(v) state.maxDist = v end)

    Players.PlayerRemoving:Connect(cleanup)
end

-- ═══════════════════════════════════════════════════════════════════
-- MODULE : FREE CAM
-- ═══════════════════════════════════════════════════════════════════
do
    local t = UI:tab("Camera", "📷")
    UI:section(t, "Caméra libre")

    local spd = 1.5
    local active = false
    local camPos, camRot, cn = nil, nil, nil

    local function stop()
        active = false
        if cn then cn:Disconnect() cn = nil end
        local c = char()
        if c then
            workspace.CurrentCamera.CameraSubject = c:FindFirstChildOfClass("Humanoid")
            workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
        end
    end

    local function start()
        local cm = workspace.CurrentCamera
        camPos = cm.CFrame.Position
        camRot = cm.CFrame
        active = true
        cn = RunService.RenderStepped:Connect(function(dt)
            if not active then return end
            local speed = spd * 30 * dt
            if UIS:IsKeyDown(Enum.KeyCode.W) then camPos = camPos + camRot.LookVector * speed end
            if UIS:IsKeyDown(Enum.KeyCode.S) then camPos = camPos - camRot.LookVector * speed end
            if UIS:IsKeyDown(Enum.KeyCode.A) then camPos = camPos - camRot.RightVector * speed end
            if UIS:IsKeyDown(Enum.KeyCode.D) then camPos = camPos + camRot.RightVector * speed end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then camPos = camPos + Vector3.new(0, speed, 0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then camPos = camPos - Vector3.new(0, speed, 0) end
            cm.CFrame = CFrame.new(camPos) * (camRot - camRot.Position)
            cm.CameraType = Enum.CameraType.Scriptable
        end)
    end

    UIS.InputChanged:Connect(function(i)
        if not active then return end
        if i.UserInputType == Enum.UserInputType.MouseMovement then
            camRot = workspace.CurrentCamera.CFrame
        end
    end)

    UI:toggle(t, "Free Cam", false, function(v)
        if v then start() else stop() end
    end, { keybind = "FreeCam", defaultKey = Enum.KeyCode.P, keyName = "P" })
    UI:slider(t, "Sensibilité", 0.5, 5, 1.5, function(v) spd = v end)
end

-- ═══════════════════════════════════════════════════════════════════
-- MODULE : AIMBOT
-- ═══════════════════════════════════════════════════════════════════
do
    local t = UI:tab("Combat", "🎯")
    UI:section(t, "Aimbot")

    local state = {
        enabled = false,
        hold = false,
        fov = 130,
        smooth = 0.25,
        part = "Head",
        teamCheck = true,
        wallCheck = true,
        showFov = true,
        maxDist = 1000,
    }

    local hasD = Drawing and Drawing.new
    local fovCircle
    if hasD then
        fovCircle = Drawing.new("Circle")
        fovCircle.Thickness = 1.5
        fovCircle.NumSides = 64
        fovCircle.Filled = false
        fovCircle.Color = C.accentPink
        fovCircle.Transparency = 1
        fovCircle.Visible = false
    end

    local function isTeam(pl)
        if not state.teamCheck then return false end
        if not pl.Team or not LP.Team then return false end
        return pl.Team == LP.Team
    end

    local function getPart(c)
        if state.part == "Head" then return c:FindFirstChild("Head") end
        if state.part == "Torso" then
            return c:FindFirstChild("UpperTorso")
                or c:FindFirstChild("Torso")
                or c:FindFirstChild("HumanoidRootPart")
        end
        local cm = workspace.CurrentCamera
        local bp, bd = nil, math.huge
        for _, p in ipairs(c:GetChildren()) do
            if p:IsA("BasePart") then
                local d = (p.Position - cm.CFrame.Position).Magnitude
                if d < bd then bp, bd = p, d end
            end
        end
        return bp
    end

    local function visible(part)
        if not state.wallCheck then return true end
        if not part then return false end
        local cm = workspace.CurrentCamera
        local o = cm.CFrame.Position
        local dir = part.Position - o
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = { LP.Character }
        local res = workspace:Raycast(o, dir, params)
        return res == nil or res.Instance:IsDescendantOf(part.Parent)
    end

    local function find()
        local cm = workspace.CurrentCamera
        local myRoot = root()
        if not myRoot then return nil end
        local myPos = myRoot.Position
        local mouse = UIS:GetMouseLocation()
        local mp = Vector2.new(mouse.X, mouse.Y)
        local best, bestSc = nil, math.huge

        for _, pl in ipairs(Players:GetPlayers()) do
            if pl == LP then continue end
            if isTeam(pl) then continue end
            local c = pl.Character
            local h = c and c:FindFirstChildOfClass("Humanoid")
            local r = c and c:FindFirstChild("HumanoidRootPart")
            if not (h and r and h.Health > 0) then continue end
            local d = (r.Position - myPos).Magnitude
            if d > state.maxDist then continue end
            local part = getPart(c)
            if not part then continue end
            local sp, onScr = cm:WorldToViewportPoint(part.Position)
            if not onScr then continue end
            local sc = (Vector2.new(sp.X, sp.Y) - mp).Magnitude
            if sc > state.fov then continue end
            if not visible(part) then continue end
            if sc < bestSc then best, bestSc = { part = part }, sc end
        end
        return best
    end

    local cn
    local activeFlag = false
    local function start()
        activeFlag = true
        if not cn then
            cn = RunService.RenderStepped:Connect(function()
                if not activeFlag then return end
                local cm = workspace.CurrentCamera
                local tgt = find()
                if not tgt then return end
                local goal = CFrame.new(cm.CFrame.Position, tgt.part.Position)
                if state.smooth >= 0.99 then
                    cm.CFrame = goal
                else
                    cm.CFrame = cm.CFrame:Lerp(goal, 1 - state.smooth)
                end
            end)
        end
    end

    local function stop()
        activeFlag = false
    end

    if hasD then
        RunService.RenderStepped:Connect(function()
            if not fovCircle then return end
            if not state.enabled or not state.showFov
               or (state.hold and not activeFlag) then
                fovCircle.Visible = false
                return
            end
            local m = UIS:GetMouseLocation()
            fovCircle.Position = Vector2.new(m.X, m.Y)
            fovCircle.Radius = state.fov
            fovCircle.Color = C.accentPink
            fovCircle.Visible = true
        end)
    end

    UIS.InputBegan:Connect(function(i, p)
        if p then return end
        if i.UserInputType == Enum.UserInputType.MouseButton2
           and state.enabled and state.hold then
            start()
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton2 and state.hold then
            stop()
        end
    end)

    UI:toggle(t, "Aimbot", false, function(v)
        state.enabled = v
        if not v then stop() elseif not state.hold then start() end
    end, { keybind = "Aimbot", defaultKey = Enum.KeyCode.C, keyName = "C" })
    UI:toggle(t, "  Mode HOLD (clic droit)", false, function(v)
        state.hold = v
        if state.enabled and not v then start() else stop() end
    end)
    UI:slider(t, "  FOV", 20, 400, 130, function(v) state.fov = v end)
    UI:slider(t, "  Lissage", 0, 0.95, 0.25, function(v) state.smooth = v end)

    -- Barre de distance avec affichage live
    local distText = Instance.new("TextLabel", t)
    distText.Size = UDim2.new(1, 0, 0, 22)
    distText.BackgroundTransparency = 1
    distText.Text = "  Activation à : " .. state.maxDist .. " studs"
    distText.Font = Enum.Font.GothamBold
    distText.TextSize = 12
    distText.TextColor3 = C.accentBright
    distText.TextXAlignment = Enum.TextXAlignment.Left

    UI:slider(t, "  Distance (studs)", 30, 2000, state.maxDist, function(v)
        state.maxDist = v
        distText.Text = "  Activation à : " .. v .. " studs"
    end)

    UI:toggle(t, "  Team check", true, function(v) state.teamCheck = v end)
    UI:toggle(t, "  Wall check", true, function(v) state.wallCheck = v end)
    UI:toggle(t, "  Afficher cercle FOV", true, function(v) state.showFov = v end)

    UI:section(t, "Cible")
    UI:button(t, "Tête", function()
        state.part = "Head"
        Notify:push("Aimbot", "Cible : Tête", 1.5, C.success)
    end)
    UI:button(t, "Torse", function()
        state.part = "Torso"
        Notify:push("Aimbot", "Cible : Torse", 1.5, C.success)
    end)
end

-- ═══════════════════════════════════════════════════════════════════
-- MODULE : TRIGGER BOT
-- ═══════════════════════════════════════════════════════════════════
do
    local t = UI:tab("Combat")
    UI:section(t, "Trigger Bot")

    local state = {
        enabled     = false,
        delay       = 0.05,
        range       = 500,
        hitboxSize  = 30,
        teamCheck   = true,
        wallCheck   = true,
        headOnly    = false,
        showHitbox  = true,
        bypassJump  = true,
    }

    local fireMethod = "unknown"
    if type(mouse1click) == "function" then fireMethod = "mouse1click"
    elseif type(mouse1down) == "function" and type(mouse1up) == "function" then fireMethod = "mouse1down_up"
    elseif type(mousemove) == "function" then fireMethod = "VirtualInputManager" end

    local function fireClick()
        if fireMethod == "mouse1click" then
            pcall(mouse1click)
        elseif fireMethod == "mouse1down_up" then
            pcall(mouse1down)
            task.wait(0.01)
            pcall(mouse1up)
        elseif fireMethod == "VirtualInputManager" then
            pcall(function()
                local vim = game:GetService("VirtualInputManager")
                vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                task.wait(0.01)
                vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end)
        end
    end

    local hasD = Drawing and Drawing.new
    local hitboxCircle
    if hasD and state.showHitbox then
        hitboxCircle = Drawing.new("Circle")
        hitboxCircle.Thickness = 1
        hitboxCircle.NumSides = 32
        hitboxCircle.Filled = false
        hitboxCircle.Color = C.accentPink
        hitboxCircle.Transparency = 0.6
        hitboxCircle.Visible = false
    end

    local function isTeam(pl)
        if not state.teamCheck then return false end
        if not pl.Team or not LP.Team then return false end
        return pl.Team == LP.Team
    end

    local function isVisible(part)
        if not state.wallCheck then return true end
        if not part then return false end
        local cm = workspace.CurrentCamera
        local o = cm.CFrame.Position
        local dir = part.Position - o
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = { LP.Character }
        local res = workspace:Raycast(o, dir, params)
        return res == nil or res.Instance:IsDescendantOf(part.Parent)
    end

    local function getTargetUnderCrosshair()
        local cm = workspace.CurrentCamera
        local mouse = UIS:GetMouseLocation()
        local mousePos = Vector2.new(mouse.X, mouse.Y)
        local half = state.hitboxSize / 2
        local myRoot = root()
        if not myRoot then return nil end
        local myPos = myRoot.Position
        local best, bestDist = nil, math.huge

        for _, pl in ipairs(Players:GetPlayers()) do
            if pl == LP then continue end
            if isTeam(pl) then continue end
            local c = pl.Character
            local h = c and c:FindFirstChildOfClass("Humanoid")
            local r = c and c:FindFirstChild("HumanoidRootPart")
            if not (h and r and h.Health > 0) then continue end
            local dist = (r.Position - myPos).Magnitude
            if dist > state.range then continue end

            local parts = {}
            if state.headOnly then
                local hd = c:FindFirstChild("Head")
                if hd then table.insert(parts, hd) end
            else
                local hd = c:FindFirstChild("Head")
                local tor = c:FindFirstChild("UpperTorso") or c:FindFirstChild("Torso")
                local legs = c:FindFirstChild("LowerTorso")
                if hd then table.insert(parts, hd) end
                if tor then table.insert(parts, tor) end
                if legs then table.insert(parts, legs) end
                if #parts == 0 then table.insert(parts, r) end
            end

            for _, part in ipairs(parts) do
                local sp, onScr = cm:WorldToViewportPoint(part.Position)
                if not onScr then continue end
                local screenPos = Vector2.new(sp.X, sp.Y)
                local delta = (screenPos - mousePos).Magnitude
                if delta <= half then
                    if not isVisible(part) then continue end
                    if delta < bestDist then
                        best, bestDist = { player = pl, part = part, dist = dist }, delta
                    end
                    break
                end
            end
        end
        return best
    end

    local cn
    local lastFire = 0

    local function start()
        cn = RunService.RenderStepped:Connect(function()
            if hitboxCircle then
                if state.showHitbox and state.enabled then
                    local m = UIS:GetMouseLocation()
                    hitboxCircle.Position = Vector2.new(m.X, m.Y)
                    hitboxCircle.Radius = state.hitboxSize / 2
                    hitboxCircle.Visible = true
                else
                    hitboxCircle.Visible = false
                end
            end

            if not state.enabled then return end

            if state.bypassJump then
                local h = hum()
                if h then
                    local st = h:GetState()
                    if st == Enum.HumanoidStateType.Jumping
                    or st == Enum.HumanoidStateType.Freefall then
                        return
                    end
                end
            end

            if os.clock() - lastFire < state.delay then return end
            local tgt = getTargetUnderCrosshair()
            if not tgt then return end
            fireClick()
            lastFire = os.clock()
            if hitboxCircle then hitboxCircle.Color = C.success end
        end)
    end

    local function stop()
        if cn then cn:Disconnect() cn = nil end
        if hitboxCircle then hitboxCircle.Visible = false end
    end

    UI:toggle(t, "Trigger Bot", false, function(v)
        state.enabled = v
        if v then
            start()
            Notify:push("Trigger", "Méthode : " .. fireMethod, 3, C.success)
        else
            stop()
            Notify:push("Trigger", "Désactivé", 2, C.warn)
        end
    end, { keybind = "Trigger", defaultKey = Enum.KeyCode.H, keyName = "H" })

    UI:slider(t, "  Délai entre tirs", 0.01, 0.5, 0.05, function(v) state.delay = v end)
    UI:slider(t, "  Taille zone curseur", 5, 100, 30, function(v) state.hitboxSize = v end)
    UI:slider(t, "  Portée max", 50, 2000, 500, function(v) state.range = v end)

    UI:toggle(t, "  Tirer tête uniquement", false, function(v) state.headOnly = v end)
    UI:toggle(t, "  Cercle visuel", true, function(v)
        state.showHitbox = v
        if hitboxCircle then hitboxCircle.Visible = v and state.enabled end
    end)
    UI:toggle(t, "  Team check", true, function(v) state.teamCheck = v end)
    UI:toggle(t, "  Wall check", true, function(v) state.wallCheck = v end)
    UI:toggle(t, "  Ne pas tirer en saut", true, function(v) state.bypassJump = v end)
end

-- ═══════════════════════════════════════════════════════════════════
-- MODULE : AIMBOT PROXIMITÉ (auto + priorité armes)
-- ═══════════════════════════════════════════════════════════════════
do
    local t = UI:tab("Combat")
    UI:section(t, "Aimbot Proximité")

    local state = {
        enabled         = false,
        range           = 15,
        smooth          = 0.35,
        part            = "Head",
        teamCheck       = true,
        wallCheck       = false,
        visibleOnly     = true,
        showRange       = true,
        targetDot       = true,
        prioritizeArmed = false,
        armedRangeBonus = 0,
    }

    local rangePart = Instance.new("Part")
    rangePart.Name = "PulseAimRange"
    rangePart.Shape = Enum.PartType.Cylinder
    rangePart.Size = Vector3.new(0.1, state.range * 2, state.range * 2)
    rangePart.Anchored = true
    rangePart.CanCollide = false
    rangePart.CanQuery = false
    rangePart.CanTouch = false
    rangePart.Material = Enum.Material.ForceField
    rangePart.Color = C.accent
    rangePart.Transparency = 1
    rangePart.Parent = workspace

    local targetMark = Instance.new("Part")
    targetMark.Shape = Enum.PartType.Ball
    targetMark.Size = Vector3.new(0.5, 0.5, 0.5)
    targetMark.Anchored = true
    targetMark.CanCollide = false
    targetMark.CanQuery = false
    targetMark.CanTouch = false
    targetMark.Material = Enum.Material.Neon
    targetMark.Color = C.accentPink
    targetMark.Transparency = 1
    targetMark.Parent = workspace

    local function isAlive(c)
        if not c then return false end
        local h = c:FindFirstChildOfClass("Humanoid")
        return h and h.Health > 0
    end

    local function isTeam(pl)
        if not state.teamCheck then return false end
        if not pl.Team or not LP.Team then return false end
        return pl.Team == LP.Team
    end

    local function visibleFromCam(part)
        if not state.wallCheck then return true end
        if not part then return false end
        local cm = workspace.CurrentCamera
        local o = cm.CFrame.Position
        local dir = part.Position - o
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = { LP.Character }
        local res = workspace:Raycast(o, dir, params)
        return res == nil or res.Instance:IsDescendantOf(part.Parent)
    end

    local function findClosest()
        local myRoot = root()
        if not myRoot then return nil end
        local myPos = myRoot.Position
        local maxRange = state.range + state.armedRangeBonus

        local bestArmed, bestArmedDist = nil, math.huge
        local bestNormal, bestNormalDist = nil, math.huge

        for _, pl in ipairs(Players:GetPlayers()) do
            if pl == LP then continue end
            if isTeam(pl) then continue end
            local c = pl.Character
            if not isAlive(c) then continue end
            local r = c:FindFirstChild("HumanoidRootPart")
            if not r then continue end

            local d = (r.Position - myPos).Magnitude
            if d > maxRange then continue end

            local target
            if state.part == "Head" then
                target = c:FindFirstChild("Head")
            elseif state.part == "Torso" then
                target = c:FindFirstChild("UpperTorso") or c:FindFirstChild("Torso") or r
            else
                target = r
            end
            if not target then continue end

            if state.visibleOnly then
                local _, onScr = workspace.CurrentCamera:WorldToViewportPoint(target.Position)
                if not onScr then continue end
            end
            if not visibleFromCam(target) then continue end

            local armed = false
            if state.prioritizeArmed then
                armed = playerHasWeaponCached(pl, c)
            end

            if armed then
                if d < bestArmedDist then
                    bestArmed, bestArmedDist = { player = pl, part = target, dist = d, armed = true }, d
                end
            else
                if d < bestNormalDist then
                    bestNormal, bestNormalDist = { player = pl, part = target, dist = d, armed = false }, d
                end
            end
        end

        if state.prioritizeArmed and bestArmed then return bestArmed end
        if not bestArmed then return bestNormal end
        if not bestNormal then return bestArmed end
        return (bestArmedDist <= bestNormalDist) and bestArmed or bestNormal
    end

    local cn
    local function start()
        cn = RunService.RenderStepped:Connect(function()
            local myRoot = root()
            if rangePart then
                if myRoot and state.showRange then
                    rangePart.CFrame = CFrame.new(myRoot.Position - Vector3.new(0, 3, 0))
                        * CFrame.Angles(0, 0, math.rad(90))
                    rangePart.Transparency = 0.92
                else
                    rangePart.Transparency = 1
                end
            end

            local tgt = findClosest()
            if not tgt then
                if targetMark then targetMark.Transparency = 1 end
                return
            end

            if targetMark then
                targetMark.Position = tgt.part.Position
                targetMark.Transparency = 0.2
                if tgt.armed then
                    targetMark.Color = Color3.fromRGB(255, 30, 30)
                    targetMark.Size = Vector3.new(0.8, 0.8, 0.8)
                else
                    targetMark.Color = C.accentPink
                    targetMark.Size = Vector3.new(0.5, 0.5, 0.5)
                end
            end

            local cm = workspace.CurrentCamera
            local goal = CFrame.new(cm.CFrame.Position, tgt.part.Position)
            if state.smooth >= 0.99 then
                cm.CFrame = goal
            else
                cm.CFrame = cm.CFrame:Lerp(goal, 1 - state.smooth)
            end
        end)
    end

    local function stop()
        if cn then cn:Disconnect() cn = nil end
        if rangePart then rangePart.Transparency = 1 end
        if targetMark then targetMark.Transparency = 1 end
    end

    UI:toggle(t, "Aimbot Proximité", false, function(v)
        state.enabled = v
        if v then
            start()
            Notify:push("Aimbot", "Auto-aim · " .. state.range .. " studs", 3, C.success)
        else
            stop()
            Notify:push("Aimbot", "Désactivé", 2, C.warn)
        end
    end, { keybind = "AutoAim", defaultKey = Enum.KeyCode.G, keyName = "G" })

    local rangeText = Instance.new("TextLabel", t)
    rangeText.Size = UDim2.new(1, 0, 0, 24)
    rangeText.BackgroundTransparency = 1
    rangeText.Text = "  Distance d'activation : " .. state.range .. " studs"
    rangeText.Font = Enum.Font.GothamBold
    rangeText.TextSize = 12
    rangeText.TextColor3 = C.accentBright
    rangeText.TextXAlignment = Enum.TextXAlignment.Left

    local rangeSlider
    rangeSlider = UI:slider(t, "Rayon (studs)", 5, 150, state.range, function(v)
        state.range = v
        rangeText.Text = "  Distance d'activation : " .. v .. " studs"
        if rangePart then
            rangePart.Size = Vector3.new(0.1, v * 2, v * 2)
        end
    end)

    -- Boutons rapides
    local quickRow = Instance.new("Frame", t)
    quickRow.Size = UDim2.new(1, 0, 0, 34)
    quickRow.BackgroundTransparency = 1

    local function mkQuick(txt, val, xPos, wPct)
        local b = Instance.new("TextButton", quickRow)
        b.Size = UDim2.new(wPct, -6, 1, 0)
        b.Position = UDim2.new(xPos, 0, 0, 0)
        b.BackgroundColor3 = C.elem
        b.Text = txt
        b.Font = Enum.Font.GothamBold
        b.TextSize = 11
        b.TextColor3 = C.txt
        b.BorderSizePixel = 0
        corner(b, 6)
        stroke(b, C.txtfaint, 1, 0.7)
        b.MouseButton1Click:Connect(function()
            state.range = val
            rangeSlider.set(val)
            rangeText.Text = "  Distance d'activation : " .. val .. " studs"
            if rangePart then
                rangePart.Size = Vector3.new(0.1, val * 2, val * 2)
            end
            Notify:push("Aimbot", "Distance : " .. val .. " studs", 1.5, C.success)
        end)
    end
    mkQuick("10", 10, 0, 0.2)
    mkQuick("15", 15, 0.2, 0.2)
    mkQuick("30", 30, 0.4, 0.2)
    mkQuick("60", 60, 0.6, 0.2)
    mkQuick("100", 100, 0.8, 0.2)

    UI:slider(t, "  Lissage", 0, 0.95, 0.35, function(v) state.smooth = v end)

    UI:section(t, "Priorité des cibles")
    UI:toggle(t, "🎯 Prioriser les joueurs armés", false, function(v)
        state.prioritizeArmed = v
        if v then
            Notify:push("Aimbot", "Priorité : joueurs ARMÉS", 2, C.danger)
        else
            Notify:push("Aimbot", "Priorité : le plus proche", 2, C.accent)
        end
    end, { keybind = "AimPriority", defaultKey = Enum.KeyCode.B, keyName = "B" })
    UI:slider(t, "  Bonus portée armés", 0, 30, 0, function(v) state.armedRangeBonus = v end)

    UI:section(t, "Options")
    UI:toggle(t, "  Cercle de portée", true, function(v)
        state.showRange = v
    end)
    UI:toggle(t, "  Marqueur cible", true, function(v) state.targetDot = v end)
    UI:toggle(t, "  Team check", true, function(v) state.teamCheck = v end)
    UI:toggle(t, "  Wall check", false, function(v) state.wallCheck = v end)
    UI:toggle(t, "  Visible à l'écran", true, function(v) state.visibleOnly = v end)

    UI:section(t, "Cible visée")
    UI:button(t, "Tête (headshot)", function()
        state.part = "Head"
        Notify:push("Aimbot", "Cible : Head", 1.5, C.success)
    end)
    UI:button(t, "Torse", function()
        state.part = "Torso"
        Notify:push("Aimbot", "Cible : Torso", 1.5, C.success)
    end)

    LP.CharacterAdded:Connect(function()
        task.wait(0.5)
        if state.enabled and not cn then start() end
    end)
end

-- ═══════════════════════════════════════════════════════════════════
-- MODULE : SKIN CHANGER
-- ═══════════════════════════════════════════════════════════════════
do
    local t = UI:tab("Visuals")
    UI:section(t, "Skin Changer")

    local PRESETS = {
        neon = { name = "Neon", color = Color3.fromRGB(0,255,255), material = Enum.Material.Neon, reflectance = 0, transparency = 0, size = 1 },
        ghost = { name = "Ghost", color = Color3.fromRGB(200,200,255), material = Enum.Material.ForceField, reflectance = 0, transparency = 0.6, size = 1 },
        inferno = { name = "Inferno", color = Color3.fromRGB(255,80,0), material = Enum.Material.Neon, reflectance = 0.3, transparency = 0, size = 1 },
        ice = { name = "Ice", color = Color3.fromRGB(150,220,255), material = Enum.Material.Ice, reflectance = 0.5, transparency = 0.2, size = 1 },
        gold = { name = "Gold", color = Color3.fromRGB(255,215,0), material = Enum.Material.Metal, reflectance = 0.8, transparency = 0, size = 1 },
        shadow = { name = "Shadow", color = Color3.fromRGB(20,20,30), material = Enum.Material.SmoothPlastic, reflectance = 0, transparency = 0.3, size = 1 },
        rainbow = { name = "Rainbow", color = "rainbow", material = Enum.Material.Neon, reflectance = 0, transparency = 0, size = 1 },
        giant = { name = "Giant", color = Color3.fromRGB(255,100,200), material = Enum.Material.Neon, reflectance = 0, transparency = 0, size = 2 },
        tiny = { name = "Tiny", color = Color3.fromRGB(100,255,150), material = Enum.Material.Neon, reflectance = 0, transparency = 0, size = 0.5 },
    }

    local state = { enabled = false, currentPreset = "none", saved = {} }
    local RAINBOW_SPEED = 2
    local rainbowConn = nil
    local currentHue = 0

    local function getBodyParts()
        local c = char()
        if not c then return {} end
        local parts = {}
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then
                local isTool = false
                local parent = p.Parent
                while parent and parent ~= c do
                    if parent:IsA("Tool") then isTool = true break end
                    parent = parent.Parent
                end
                if not isTool then table.insert(parts, p) end
            end
        end
        return parts
    end

    local function saveProps(part)
        if state.saved[part] then return end
        state.saved[part] = {
            Color = part.Color,
            Material = part.Material,
            Reflectance = part.Reflectance,
            Transparency = part.Transparency,
            Size = part.Size,
        }
    end

    local function restoreAll()
        for part, props in pairs(state.saved) do
            if part and part.Parent then
                pcall(function()
                    part.Color = props.Color
                    part.Material = props.Material
                    part.Reflectance = props.Reflectance
                    part.Transparency = props.Transparency
                    part.Size = props.Size
                end)
            end
        end
        state.saved = {}
        if rainbowConn then rainbowConn:Disconnect() rainbowConn = nil end
    end

    local function applyPreset(key)
        restoreAll()
        local p = PRESETS[key]
        if not p then return end

        for _, part in ipairs(getBodyParts()) do
            saveProps(part)
            if p.material then pcall(function() part.Material = p.material end) end
            if p.reflectance then pcall(function() part.Reflectance = p.reflectance end) end
            if p.transparency then pcall(function() part.Transparency = p.transparency end) end
            if p.color == "rainbow" then
                if not rainbowConn then
                    rainbowConn = RunService.RenderStepped:Connect(function(dt)
                        currentHue = (currentHue + dt * RAINBOW_SPEED) % 1
                        local col = Color3.fromHSV(currentHue, 1, 1)
                        for _, pt in ipairs(getBodyParts()) do
                            pcall(function() pt.Color = col end)
                        end
                    end)
                end
            elseif p.color then
                pcall(function() part.Color = p.color end)
            end
            if p.size and p.size ~= 1 then
                local orig = state.saved[part].Size
                pcall(function()
                    part.Size = Vector3.new(orig.X * p.size, orig.Y * p.size, orig.Z * p.size)
                end)
            end
        end
        Notify:push("Skin", "Preset : " .. p.name, 2, C.accentBright)
    end

    UI:toggle(t, "Skin Changer", false, function(v)
        state.enabled = v
        if not v then
            restoreAll()
            state.currentPreset = "none"
            Notify:push("Skin", "Restauré", 2, C.warn)
        end
    end, { keybind = "Skin", defaultKey = Enum.KeyCode.K, keyName = "K" })

    local presetOrder = {
        { "neon", "💠 Neon", "ghost", "👻 Ghost" },
        { "inferno", "🔥 Inferno", "ice", "❄ Ice" },
        { "gold", "🥇 Gold", "shadow", "🌑 Shadow" },
        { "rainbow", "🌈 Rainbow", "giant", "🔺 Giant" },
        { "tiny", "🔻 Tiny", "none", "↺ Normal" },
    }

    for _, row in ipairs(presetOrder) do
        local r = Instance.new("Frame", t)
        r.Size = UDim2.new(1, 0, 0, 34)
        r.BackgroundTransparency = 1
        local k1, l1, k2, l2 = row[1], row[2], row[3], row[4]

        local function mkBtn(btn, key, label, xPos)
            local b = Instance.new("TextButton", r)
            b.Size = UDim2.new(0.5, -4, 1, 0)
            b.Position = UDim2.new(xPos, 0, 0, 0)
            b.BackgroundColor3 = C.elem
            b.Text = label
            b.Font = Enum.Font.GothamBold
            b.TextSize = 11
            b.TextColor3 = C.txt
            b.BorderSizePixel = 0
            b.AutoButtonColor = false
            corner(b, 6)
            stroke(b, C.txtfaint, 1, 0.7)
            b.MouseButton1Click:Connect(function()
                if not state.enabled then
                    Notify:push("Skin", "Active d'abord le module", 2, C.warn)
                    return
                end
                if key == "none" then
                    restoreAll()
                    state.currentPreset = "none"
                    Notify:push("Skin", "Normal", 1.5, C.accent)
                else
                    state.currentPreset = key
                    applyPreset(key)
                end
            end)
        end
        mkBtn(nil, k1, l1, 0)
        mkBtn(nil, k2, l2, 0.5)
    end

    UI:button(t, "↺  Restaurer le skin normal", function()
        restoreAll()
        state.currentPreset = "none"
        Notify:push("Skin", "Skin normal restauré", 2, C.success)
    end)

    LP.CharacterAdded:Connect(function()
        task.wait(0.5)
        if state.enabled and state.currentPreset ~= "none" then
            applyPreset(state.currentPreset)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════
-- MODULE : TEXTURE SIMPLIFIER
-- ═══════════════════════════════════════════════════════════════════
do
    local t = UI:tab("Visuals")
    UI:section(t, "Simplificateur de textures")

    local state = {
        enabled = false,
        targetMode = "character",
        sampleSize = 16,
        saved = {},
        analyzed = 0,
        running = false,
    }

    local BASE_COLORS = {
        { name = "rouge",  c = Color3.fromRGB(220, 40, 40) },
        { name = "orange", c = Color3.fromRGB(240, 130, 40) },
        { name = "jaune",  c = Color3.fromRGB(240, 220, 50) },
        { name = "vert",   c = Color3.fromRGB(60, 200, 80) },
        { name = "cyan",   c = Color3.fromRGB(50, 200, 220) },
        { name = "bleu",   c = Color3.fromRGB(50, 100, 220) },
        { name = "violet", c = Color3.fromRGB(150, 70, 220) },
        { name = "rose",   c = Color3.fromRGB(230, 100, 180) },
        { name = "marron", c = Color3.fromRGB(140, 90, 50) },
        { name = "beige",  c = Color3.fromRGB(220, 200, 170) },
        { name = "gris",   c = Color3.fromRGB(130, 130, 130) },
        { name = "noir",   c = Color3.fromRGB(30, 30, 30) },
        { name = "blanc",  c = Color3.fromRGB(240, 240, 240) },
    }

    local function nearestBase(color)
        local best, bestDist = nil, math.huge
        for _, entry in ipairs(BASE_COLORS) do
            local dr = color.R - entry.c.R
            local dg = color.G - entry.c.G
            local db = color.B - entry.c.B
            local dist = dr*dr + dg*dg + db*db
            if dist < bestDist then best, bestDist = entry, dist end
        end
        return best
    end

    local hasEditableImage = pcall(function()
        AssetService:CreateEditableImage({ Size = Vector2.new(2, 2) })
    end)

    local function analyzeTexture(textureId)
        if not hasEditableImage then return nil end
        if type(textureId) ~= "string" then return nil end
        if not string.find(textureId, "rbxassetid://") then return nil end
        if type(buffer) ~= "table" then return nil end

        local size = state.sampleSize
        local ok, dominant = pcall(function()
            local ei = AssetService:CreateEditableImage({ Size = Vector2.new(size, size) })
            ei:DrawImage(Vector2.new(0, 0), Vector2.new(size, size), textureId)
            local pixels = ei:ReadPixels(Vector2.new(0, 0), Vector2.new(size, size))
            local counts = {}
            local total = size * size
            for i = 0, total - 1 do
                local r = buffer.readu8(pixels, i * 4 + 0)
                local g = buffer.readu8(pixels, i * 4 + 1)
                local b = buffer.readu8(pixels, i * 4 + 2)
                local a = buffer.readu8(pixels, i * 4 + 3)
                if a > 128 then
                    local col = Color3.fromRGB(r, g, b)
                    local base = nearestBase(col)
                    if base then
                        counts[base.name] = (counts[base.name] or 0) + 1
                    end
                end
            end
            local bestName, bestCount = nil, 0
            for name, count in pairs(counts) do
                if count > bestCount then bestName, bestCount = name, count end
            end
            ei:Destroy()
            if not bestName then return nil end
            for _, entry in ipairs(BASE_COLORS) do
                if entry.name == bestName then return entry.c end
            end
            return nil
        end)
        if ok and dominant then
            state.analyzed = state.analyzed + 1
            return dominant
        end
        return nil
    end

    local function processDecal(d)
        local tid = d.Texture
        if not tid or tid == "" then return end
        if not state.saved[d] then state.saved[d] = { type = "decal", Color = d.Color3 } end
        local col = analyzeTexture(tid)
        if col then
            d.Transparency = 1
            local parent = d.Parent
            if parent and parent:IsA("BasePart") then
                if not state.saved[parent] then
                    state.saved[parent] = { type = "part", Color = parent.Color, Material = parent.Material }
                end
                parent.Color = col
                parent.Material = Enum.Material.SmoothPlastic
            end
        end
    end

    local function processTextureObject(tex)
        local tid = tex.Texture
        if not tid or tid == "" then return end
        if not state.saved[tex] then state.saved[tex] = { type = "decal", Color = tex.Color3 } end
        local col = analyzeTexture(tid)
        if col then
            tex.Transparency = 1
            local parent = tex.Parent
            if parent and parent:IsA("BasePart") then
                if not state.saved[parent] then
                    state.saved[parent] = { type = "part", Color = parent.Color, Material = parent.Material }
                end
                parent.Color = col
                parent.Material = Enum.Material.SmoothPlastic
            end
        end
    end

    local function simplify(rootObj)
        if not rootObj then return 0 end
        local count = 0
        for _, obj in ipairs(rootObj:GetDescendants()) do
            if obj:IsA("Decal") then
                processDecal(obj); count = count + 1
            elseif obj:IsA("Texture") then
                processTextureObject(obj); count = count + 1
            end
        end
        return count
    end

    local function restoreAll()
        for obj, props in pairs(state.saved) do
            if obj and obj.Parent then
                if props.type == "decal" then
                    pcall(function() obj.Color3 = props.Color; obj.Transparency = 0 end)
                elseif props.type == "part" then
                    pcall(function() obj.Color = props.Color; obj.Material = props.Material end)
                end
            end
        end
        state.saved = {}
        state.analyzed = 0
    end

    local cn
    local function start()
        if not hasEditableImage then
            Notify:push("Textures", "EditableImage indisponible", 5, C.danger)
            return
        end
        if state.running then return end
        state.running = true
        cn = RunService.Heartbeat:Connect(function()
            if not state.enabled then return end
            if state.targetMode == "character" then
                local c = char()
                if c then simplify(c) end
            else
                simplify(workspace)
            end
        end)
        Notify:push("Textures", "Analyse en cours...", 2, C.accent)
    end

    local function stop()
        if cn then cn:Disconnect() cn = nil end
        state.running = false
    end

    UI:toggle(t, "🎨 Simplifier les textures", false, function(v)
        state.enabled = v
        if v then
            start()
            task.delay(1, function()
                Notify:push("Textures", state.analyzed .. " analysée(s)", 3, C.success)
            end)
        else
            stop()
            restoreAll()
            Notify:push("Textures", "Restauré", 2, C.warn)
        end
    end, { keybind = "TexSimpl", defaultKey = Enum.KeyCode.O, keyName = "O" })

    UI:section(t, "Cible")
    UI:button(t, "👤 Personnage uniquement", function()
        state.targetMode = "character"
        Notify:push("Textures", "Cible : perso", 1.5, C.accent)
    end)
    UI:button(t, "🌍 Toute la map (⚠ lourd)", function()
        state.targetMode = "map"
        Notify:push("Textures", "Cible : map (lag possible)", 2, C.warn)
    end)

    UI:slider(t, "Précision analyse", 4, 32, 16, function(v) state.sampleSize = v end)

    UI:button(t, "↺  Restaurer les textures", function()
        restoreAll()
        Notify:push("Textures", "Restauré", 2, C.success)
    end)

    LP.CharacterAdded:Connect(function()
        task.wait(0.8)
        if state.enabled then
            local c = char()
            if c then simplify(c) end
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════
-- MODULE : VORTEX TROU NOIR
-- ═══════════════════════════════════════════════════════════════════
do
    local t = UI:tab("Visuals")
    UI:section(t, "Vortex Trou Noir")

    local state = {
        enabled = false,
        radius = 40,
        ringCount = 3,
        ringTilt = 15,
        spinSpeed = 1.5,
        orbitDistance = 8,
        color = Color3.fromRGB(120, 50, 220),
        showRings = true,
        showCore = true,
        maxObjects = 60,
        saved = {},
        attached = {},
        ringParts = {},
    }

    local vortexFolder = Instance.new("Folder", workspace)
    vortexFolder.Name = "PulseVortex"

    local function isLoose(part)
        if not part or not part:IsA("BasePart") then return false end
        if part.Anchored then return false end
        if part == root() then return false end
        if part:FindFirstAncestorOfClass("Tool") then return false end
        local model = part:FindFirstAncestorOfClass("Model")
        if model and Players:GetPlayerFromCharacter(model) then return false end
        return true
    end

    local function createRing(radius, tilt, color)
        local ring = Instance.new("Part", vortexFolder)
        ring.Name = "VortexRing"
        ring.Shape = Enum.PartType.Cylinder
        ring.Size = Vector3.new(0.3, radius * 2, radius * 2)
        ring.Anchored = true
        ring.CanCollide = false
        ring.CanQuery = false
        ring.CanTouch = false
        ring.Material = Enum.Material.Neon
        ring.Color = color
        ring.Transparency = 0.6
        local light = Instance.new("PointLight", ring)
        light.Color = color
        light.Range = 12
        light.Brightness = 2
        return ring
    end

    local core = Instance.new("Part", vortexFolder)
    core.Name = "VortexCore"
    core.Shape = Enum.PartType.Ball
    core.Size = Vector3.new(3, 3, 3)
    core.Anchored = true
    core.CanCollide = false
    core.CanQuery = false
    core.CanTouch = false
    core.Material = Enum.Material.Neon
    core.Color = Color3.fromRGB(10, 5, 25)
    core.Transparency = 1
    local coreLight = Instance.new("PointLight", core)
    coreLight.Color = state.color
    coreLight.Range = 25
    coreLight.Brightness = 4

    local halo = Instance.new("Part", vortexFolder)
    halo.Shape = Enum.PartType.Ball
    halo.Size = Vector3.new(5, 5, 5)
    halo.Anchored = true
    halo.CanCollide = false
    halo.CanQuery = false
    halo.CanTouch = false
    halo.Material = Enum.Material.ForceField
    halo.Color = state.color
    halo.Transparency = 1

    local function attachPart(part)
        if state.attached[part] then return end
        state.saved[part] = {
            Anchored = part.Anchored,
            CFrame = part.CFrame,
            CanCollide = part.CanCollide,
        }
        part.Anchored = false
        part.CanCollide = false
        part:SetAttribute("PulseVortex", true)

        local bp = Instance.new("BodyPosition", part)
        bp.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bp.P = 15000
        bp.D = 800

        local bg = Instance.new("BodyGyro", part)
        bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        bg.P = 1e4
        bg.D = 500

        state.attached[part] = {
            bp = bp, bg = bg,
            angle = math.random() * math.pi * 2,
            radius = state.orbitDistance + math.random() * 3 - 1.5,
            tilt = math.random(-state.ringTilt, state.ringTilt),
            speedMul = 0.8 + math.random() * 0.4,
        }
    end

    local function detachPart(part)
        local data = state.attached[part]
        if not data then return end
        if data.bp then data.bp:Destroy() end
        if data.bg then data.bg:Destroy() end
        part:SetAttribute("PulseVortex", nil)
        local sv = state.saved[part]
        if sv and part.Parent then
            part.Anchored = sv.Anchored
            part.CanCollide = sv.CanCollide
        end
        state.attached[part] = nil
        state.saved[part] = nil
    end

    local pulse = 0

    local function updateRingVisuals(dt)
        local r = root()
        if not r then
            for _, ring in ipairs(state.ringParts) do ring.Transparency = 1 end
            core.Transparency = 1
            halo.Transparency = 1
            return
        end
        local center = r.Position
        pulse = pulse + dt * state.spinSpeed * 2

        core.CFrame = CFrame.new(center)
        local pulseScale = 1 + math.sin(pulse * 2) * 0.1
        core.Size = Vector3.new(3 * pulseScale, 3 * pulseScale, 3 * pulseScale)
        core.Transparency = state.showCore and 0.15 or 1
        halo.CFrame = CFrame.new(center)
        halo.Transparency = state.showCore and 0.85 or 1
        halo.Size = Vector3.new(5 * pulseScale, 5 * pulseScale, 5 * pulseScale)

        for i, ring in ipairs(state.ringParts) do
            local phase = pulse + i * (math.pi * 2 / #state.ringParts)
            local tilt = math.rad(state.ringTilt * (i % 2 == 0 and 1 or -1))
            ring.CFrame = CFrame.new(center) * CFrame.Angles(tilt, phase, 0)
            local ringPulse = 1 + math.sin(pulse * 2 + i) * 0.05
            local baseRadius = state.orbitDistance + i * 2.5
            ring.Size = Vector3.new(0.3, baseRadius * 2 * ringPulse, baseRadius * 2 * ringPulse)
            if state.showRings then
                ring.Transparency = 0.5 + math.sin(pulse * 3 + i) * 0.15
            else
                ring.Transparency = 1
            end
            local hue = (pulse * 0.1 + i * 0.15) % 1
            ring.Color = state.color:Lerp(Color3.fromHSV(hue, 1, 1), 0.3)
        end
    end

    local function updateAttachedObjects(dt)
        local r = root()
        if not r then return end
        local center = r.Position

        local toDetach = {}
        for part in pairs(state.attached) do
            if not part or not part.Parent then
                table.insert(toDetach, part)
            end
        end
        for _, p in ipairs(toDetach) do
            state.attached[p] = nil
            state.saved[p] = nil
        end

        for part, data in pairs(state.attached) do
            if part and part.Parent then
                data.angle = data.angle + dt * state.spinSpeed * data.speedMul
                local dist = data.radius + math.sin(pulse + data.angle) * 0.5
                local tiltRad = math.rad(data.tilt)
                local offset = Vector3.new(
                    math.cos(data.angle) * dist,
                    math.sin(data.angle * 2) * 1.5 + math.sin(tiltRad) * dist * 0.5,
                    math.sin(data.angle) * dist
                )
                local goal = center + offset
                if data.bp and data.bp.Parent then data.bp.Position = goal end
                if data.bg and data.bg.Parent then data.bg.CFrame = CFrame.new(goal, center) end
            end
        end
    end

    local function findAndAttach()
        local r = root()
        if not r then return end
        local center = r.Position
        local count = 0
        for _ in pairs(state.attached) do count = count + 1 end
        if count >= state.maxObjects then return end

        for _, obj in ipairs(workspace:GetDescendants()) do
            if count >= state.maxObjects then break end
            if obj:IsA("BasePart") and isLoose(obj) and not obj:GetAttribute("PulseVortex") then
                local dist = (obj.Position - center).Magnitude
                if dist <= state.radius and dist > 2 then
                    attachPart(obj)
                    count = count + 1
                end
            end
        end
    end

    local updateConn, spawnRunning = nil, false

    local function start()
        if updateConn then return end
        for _, ring in ipairs(state.ringParts) do ring:Destroy() end
        state.ringParts = {}
        for i = 1, state.ringCount do
            local radius = state.orbitDistance + i * 2.5
            local ring = createRing(radius, state.ringTilt * (i % 2 == 0 and 1 or -1), state.color)
            table.insert(state.ringParts, ring)
        end

        updateConn = RunService.RenderStepped:Connect(function(dt)
            updateRingVisuals(dt)
            updateAttachedObjects(dt)
        end)

        if not spawnRunning then
            spawnRunning = true
            task.spawn(function()
                while state.enabled do
                    pcall(findAndAttach)
                    task.wait(0.5)
                end
                spawnRunning = false
            end)
        end

        Notify:push("Vortex", "Activé · rayon " .. state.radius, 3, C.accent)
    end

    local function stop()
        if updateConn then updateConn:Disconnect() updateConn = nil end

        for part in pairs(state.attached) do
            if part and part.Parent then detachPart(part) end
        end
        for part in pairs(state.saved) do
            if part and part.Parent then
                pcall(function()
                    local sv = state.saved[part]
                    part.Anchored = sv.Anchored
                    part.CFrame = sv.CFrame
                    part.CanCollide = sv.CanCollide
                end)
            end
        end
        state.saved = {}
        state.attached = {}

        for _, ring in ipairs(state.ringParts) do
            pcall(function() ring:Destroy() end)
        end
        state.ringParts = {}
        core.Transparency = 1
        halo.Transparency = 1

        Notify:push("Vortex", "Désactivé", 2, C.warn)
    end

    UI:toggle(t, "🌀 Vortex Trou Noir", false, function(v)
        state.enabled = v
        if v then start() else stop() end
    end, { keybind = "Vortex", defaultKey = Enum.KeyCode.V, keyName = "V" })

    UI:slider(t, "  Rayon", 10, 200, 40, function(v) state.radius = v end)
    UI:slider(t, "  Vitesse rotation", 0.5, 6, 1.5, function(v) state.spinSpeed = v end)
    UI:slider(t, "  Distance orbite", 4, 30, 8, function(v)
        state.orbitDistance = v
        if state.enabled then
            for i, ring in ipairs(state.ringParts) do
                local r = v + i * 2.5
                ring.Size = Vector3.new(0.3, r * 2, r * 2)
            end
        end
    end)
    UI:slider(t, "  Nombre d'anneaux", 1, 8, 3, function(v)
        state.ringCount = math.floor(v)
    end)

    UI:toggle(t, "  Afficher anneaux", true, function(v) state.showRings = v end)
    UI:toggle(t, "  Afficher sphère", true, function(v) state.showCore = v end)

    UI:button(t, "💥  Libérer les objets", function()
        for part in pairs(state.attached) do
            if part and part.Parent then detachPart(part) end
        end
        Notify:push("Vortex", "Objets libérés", 2, C.success)
    end)
end

-- ═══════════════════════════════════════════════════════════════════
-- MODULE : TELEPORT + UTILITAIRE
-- ═══════════════════════════════════════════════════════════════════
do
    local t = UI:tab("Utility", "⚙")
    UI:section(t, "Téléportation")

    local targets = {}
    local curTarget = nil

    local function refresh()
        targets = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP then table.insert(targets, p.Name) end
        end
    end
    refresh()

    local targetBtn = Instance.new("TextButton", t)
    targetBtn.Size = UDim2.new(1, 0, 0, 40)
    targetBtn.BackgroundColor3 = C.elem
    targetBtn.Text = "Cible : aucun"
    targetBtn.Font = Enum.Font.Gotham
    targetBtn.TextSize = 12
    targetBtn.TextColor3 = C.txt
    targetBtn.BorderSizePixel = 0
    corner(targetBtn, 8)
    stroke(targetBtn, C.txtfaint, 1, 0.7)

    local idx = 0
    targetBtn.MouseButton1Click:Connect(function()
        refresh()
        if #targets == 0 then
            Notify:push("TP", "Aucun joueur", 2, C.warn)
            return
        end
        idx = idx % #targets + 1
        curTarget = targets[idx]
        targetBtn.Text = "Cible : " .. curTarget
    end)

    UI:button(t, "→  TP vers le joueur", function()
        if not curTarget then
            Notify:push("TP", "Sélectionne une cible", 2, C.warn)
            return
        end
        local pl = Players:FindFirstChild(curTarget)
        local r = pl and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")
        if r then
            local myR = root()
            if myR then
                myR.CFrame = CFrame.new(r.Position + Vector3.new(0, 3, 0))
                Notify:push("TP", "Téléporté vers " .. curTarget, 2, C.success)
            end
        else
            Notify:push("TP", "Introuvable ou mort", 2, C.danger)
        end
    end, { keybind = "TPPlayer", defaultKey = Enum.KeyCode.T, keyName = "T" })

    UI:button(t, "🖱  TP vers la souris", function()
        local m = LP:GetMouse()
        if m and m.Hit then
            local myR = root()
            if myR then
                myR.CFrame = CFrame.new(m.Hit.Position + Vector3.new(0, 3, 0))
                Notify:push("TP", "Téléporté", 1.5, C.success)
            end
        end
    end)

    UI:section(t, "Actions")
    UI:button(t, "↻  Reset personnage", function()
        local h = hum()
        if h then h.Health = 0 end
    end)
    UI:button(t, "⟳  Rejoindre le serveur", function()
        TeleportService:Teleport(game.PlaceId, LP)
    end)

    UI:section(t, "Informations")
    local function addInfo(txt)
        local l = Instance.new("TextLabel", t)
        l.Size = UDim2.new(1, 0, 0, 26)
        l.BackgroundColor3 = C.elem
        l.BackgroundTransparency = 0.5
        l.Text = "  " .. txt
        l.Font = Enum.Font.Gotham
        l.TextSize = 11
        l.TextColor3 = C.txt
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.BorderSizePixel = 0
        corner(l, 6)
    end
    addInfo("👤 Joueur : " .. LP.Name)
    addInfo("🎮 Place ID : " .. game.PlaceId)
    addInfo("👥 Joueurs : " .. #Players:GetPlayers())
    addInfo("📱 Plateforme : " .. (isMobile and "Mobile" or "PC"))
end

-- ═══════════════════════════════════════════════════════════════════
-- CONTRÔLES MOBILES
-- ═══════════════════════════════════════════════════════════════════
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
    grad(joyKnob, C.accent, C.accentPink, 135)

    local tid = nil
    local jc = Vector2.new(0, 0)
    local JR = 45

    local function updateJoy(p)
        local d = Vector2.new(p.X, p.Y) - jc
        local m = d.Magnitude
        if m > JR then d = d.Unit * JR end
        joyKnob.Position = UDim2.new(0.5, d.X - 30, 0.5, d.Y - 30)
        State.mobile.joystick = d / JR
    end
    local function resetJoy()
        State.mobile.joystick = Vector2.new(0, 0)
        joyKnob.Position = UDim2.new(0.5, -30, 0.5, -30)
        tid = nil
    end

    joyBase.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch
        or i.UserInputType == Enum.UserInputType.MouseButton1 then
            tid = i
            jc = Vector2.new(
                joyBase.AbsolutePosition.X + joyBase.AbsoluteSize.X / 2,
                joyBase.AbsolutePosition.Y + joyBase.AbsoluteSize.Y / 2
            )
            updateJoy(i.Position)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if tid and i == tid then updateJoy(i.Position) end
    end)
    UIS.InputEnded:Connect(function(i)
        if tid and i == tid then resetJoy() end
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

    upBtn.MouseButton1Down:Connect(function() State.mobile.up = true end)
    upBtn.MouseButton1Up:Connect(function() State.mobile.up = false end)
    upBtn.MouseLeave:Connect(function() State.mobile.up = false end)
    downBtn.MouseButton1Down:Connect(function() State.mobile.down = true end)
    downBtn.MouseButton1Up:Connect(function() State.mobile.down = false end)
    downBtn.MouseLeave:Connect(function() State.mobile.down = false end)

    task.spawn(function()
        while task.wait(0.2) do
            local h = hum()
            local show = h and h.PlatformStand
            joyBase.Visible = show or false
            upBtn.Visible = show or false
            downBtn.Visible = show or false
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════
-- LANCEMENT
-- ═══════════════════════════════════════════════════════════════════
UI:default()
task.wait(0.5)
Notify:push("Pulse Hub", "Chargé · " .. (isMobile and "Mobile" or "PC") .. " · v3.0", 4, C.accent)
task.wait(0.3)
Notify:push("Astuce", isMobile and "Bouton ⚡ pour l'UI" or "RightShift pour l'UI", 5, C.accentCyan)
print("[Pulse Hub] v3.0 · " .. (isMobile and "Mobile" or "PC") .. " · Ready")
