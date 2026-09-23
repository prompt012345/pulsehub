--[[
    ═══════════════════════════════════════════════════════════════════
    PULSE HUB — LOADER GITHUB
    ═══════════════════════════════════════════════════════════════════
    Repo    : prompt012345/pulsehub
    Fichier : pulsehub.lua
    ═══════════════════════════════════════════════════════════════════
--]]

local CONFIG = {
    BASE_URL     = "https://raw.githubusercontent.com/prompt012345/pulsehub/refs/heads/main/",
    VERSION_FILE = "version.json",
    BUNDLE_FILE  = "pulsehub.lua",

    CACHE_BUNDLE  = "pulsehub_cache.lua",
    CACHE_VERSION = "pulsehub_version.txt",
    AUTO_CHECK    = true,
    FORCE_REFRESH = true,
}

local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService  = game:GetService("HttpService")
local LocalPlayer  = Players.LocalPlayer

--============================================================
-- FS HELPERS
--============================================================
local hasFS = (type(readfile) == "function"
           and type(writefile) == "function"
           and type(isfile) == "function")

local function readLocal(path)
    if not hasFS then return nil end
    local ok, content = pcall(readfile, path)
    if ok then return content end
    return nil
end

local function writeLocal(path, content)
    if not hasFS then return false end
    return pcall(writefile, path, content)
end

local function localFileExists(path)
    if not hasFS then return false end
    local ok, res = pcall(isfile, path)
    return ok and res
end

--============================================================
-- HTTP
--============================================================
local function httpGet(url)
    if type(game.HttpGet) == "function" then
        local ok, body = pcall(function()
            return game:HttpGet(url, true)
        end)
        if ok and body and #body > 0 then return body end
    end
    if type(request) == "function" then
        local ok, res = pcall(request, { Url = url, Method = "GET" })
        if ok and res and res.Body then return res.Body end
    end
    if syn and syn.request then
        local ok, res = pcall(syn.request, { Url = url, Method = "GET" })
        if ok and res and res.Body then return res.Body end
    end
    return nil
end

--============================================================
-- VERSION COMPARISON
--============================================================
local function parseVersion(v)
    local parts = {}
    for n in tostring(v):gmatch("%d+") do
        table.insert(parts, tonumber(n))
    end
    return parts
end

local function isNewer(remote, localV)
    local av, bv = parseVersion(remote), parseVersion(localV)
    for i = 1, math.max(#av, #bv) do
        local x, y = av[i] or 0, bv[i] or 0
        if x > y then return true end
        if x < y then return false end
    end
    return false
end

--============================================================
-- NOTIFICATION MINI
--============================================================
local function quickNotify(title, message, color, duration)
    color = color or Color3.fromRGB(140, 90, 255)
    duration = duration or 5

    local gui = Instance.new("ScreenGui")
    gui.Name = "PulseLoaderNotify"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 999
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local box = Instance.new("Frame")
    box.AnchorPoint = Vector2.new(1, 0)
    box.Position = UDim2.new(1, -20, 0, 20)
    box.Size = UDim2.new(0, 300, 0, 0)
    box.AutomaticSize = Enum.AutomaticSize.Y
    box.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
    box.BackgroundTransparency = 0.1
    box.BorderSizePixel = 0
    box.Parent = gui

    local c = Instance.new("UICorner", box)
    c.CornerRadius = UDim.new(0, 8)

    local s = Instance.new("UIStroke", box)
    s.Color = color
    s.Thickness = 1.5
    s.Transparency = 0.3

    local accent = Instance.new("Frame", box)
    accent.Size = UDim2.new(0, 3, 1, -12)
    accent.Position = UDim2.new(0, 6, 0, 6)
    accent.BackgroundColor3 = color
    accent.BorderSizePixel = 0
    Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 2)

    local t = Instance.new("TextLabel", box)
    t.Size = UDim2.new(1, -30, 0, 22)
    t.Position = UDim2.new(0, 18, 0, 8)
    t.BackgroundTransparency = 1
    t.Text = title
    t.Font = Enum.Font.GothamBold
    t.TextSize = 13
    t.TextColor3 = color
    t.TextXAlignment = Enum.TextXAlignment.Left

    local m = Instance.new("TextLabel", box)
    m.Size = UDim2.new(1, -30, 0, 0)
    m.Position = UDim2.new(0, 18, 0, 32)
    m.AutomaticSize = Enum.AutomaticSize.Y
    m.BackgroundTransparency = 1
    m.Text = message
    m.Font = Enum.Font.Gotham
    m.TextSize = 12
    m.TextColor3 = Color3.fromRGB(220, 220, 230)
    m.TextXAlignment = Enum.TextXAlignment.Left
    m.TextWrapped = true

    task.delay(duration, function()
        TweenService:Create(box, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
        TweenService:Create(s, TweenInfo.new(0.3), { Transparency = 1 }):Play()
        TweenService:Create(t, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
        TweenService:Create(m, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
        TweenService:Create(accent, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
        task.wait(0.35)
        gui:Destroy()
    end)
end

--============================================================
-- LOGIQUE PRINCIPALE
--============================================================
local function main()
    local remoteVersionURL = CONFIG.BASE_URL .. CONFIG.VERSION_FILE
    local bundleURL        = CONFIG.BASE_URL .. CONFIG.BUNDLE_FILE

    local remoteVersion, remoteData = nil, nil
    if CONFIG.AUTO_CHECK or CONFIG.FORCE_REFRESH then
        local raw = httpGet(remoteVersionURL)
        if raw then
            local ok, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
            if ok and type(decoded) == "table" and decoded.version then
                remoteVersion = decoded.version
                remoteData    = decoded
            end
        end
    end

    local localVersion = readLocal(CONFIG.CACHE_VERSION)

    local needDownload = false
    local updateMsg    = nil

    if CONFIG.FORCE_REFRESH then
        needDownload = true
    elseif not localFileExists(CONFIG.CACHE_BUNDLE) then
        needDownload = true
    elseif remoteVersion and (not localVersion or isNewer(remoteVersion, localVersion)) then
        needDownload = true
        updateMsg = string.format("v%s → v%s", localVersion or "?", remoteVersion)
        if remoteData.changelog then
            updateMsg = updateMsg .. "\n" .. remoteData.changelog
        end
    end

    local bundleSrc = nil
    if needDownload then
        local ok, body = pcall(httpGet, bundleURL)
        if ok and body and #body > 100 then
            bundleSrc = body
            writeLocal(CONFIG.CACHE_BUNDLE, body)
            if remoteVersion then
                writeLocal(CONFIG.CACHE_VERSION, remoteVersion)
            end
            if updateMsg then
                quickNotify("⬆️  Mise à jour", updateMsg,
                    Color3.fromRGB(70, 200, 120), 6)
            end
        else
            quickNotify("⚠️  Erreur réseau",
                "Impossible de télécharger.\nUtilisation du cache local.",
                Color3.fromRGB(220, 70, 90), 5)
            bundleSrc = readLocal(CONFIG.CACHE_BUNDLE)
        end
    else
        bundleSrc = readLocal(CONFIG.CACHE_BUNDLE)
        if CONFIG.AUTO_CHECK and localVersion then
            quickNotify("✅  À jour",
                "Pulse Hub " .. localVersion .. " est la dernière version.",
                Color3.fromRGB(70, 200, 120), 3)
        end
    end

    if not bundleSrc then
        quickNotify("❌  Erreur fatale",
            "Aucune source disponible. Vérifie l'URL ou ta connexion.",
            Color3.fromRGB(220, 70, 90), 8)
        return
    end

    local fn, err = loadstring(bundleSrc, "@pulsehub")
    if not fn then
        quickNotify("❌  Erreur de syntaxe",
            "Bundle corrompu :\n" .. tostring(err),
            Color3.fromRGB(220, 70, 90), 8)
        return
    end

    _G.PulseLoader = {
        version = remoteVersion or localVersion or "?",
        source  = needDownload and "remote" or "cache",
    }

    local ok, runErr = pcall(fn)
    if not ok then
        quickNotify("❌  Erreur d'exécution",
            tostring(runErr),
            Color3.fromRGB(220, 70, 90), 8)
    end
end

task.spawn(function()
    local ok, err = pcall(main)
    if not ok then
        warn("[Pulse Loader] " .. tostring(err))
    end
end)
