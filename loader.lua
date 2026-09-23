--[[
    Pulse Hub — Loader GitHub
    Charge le bundle depuis le repo et l'exécute.
--]]

local CONFIG = {
    BASE_URL     = "https://raw.githubusercontent.com/TON_USER/pulse-hub/main/",
    BUNDLE_FILE  = "pulse.lua",
    CACHE_FILE   = "pulse_cache.lua",
}

-- Récupère l'URL du bundle
local bundleURL = CONFIG.BASE_URL .. CONFIG.BUNDLE_FILE

-- Essaie de lire le cache local d'abord
local hasFS = (type(readfile) == "function" and type(writefile) == "function")
local bundleSrc = nil

if hasFS then
    local ok, cached = pcall(readfile, CONFIG.CACHE_FILE)
    if ok and cached and #cached > 100 then
        bundleSrc = cached
    end
end

-- Télécharge si pas de cache
if not bundleSrc then
    local ok, body = pcall(function()
        return game:HttpGet(bundleURL)
    end)
    if ok and body and #body > 100 then
        bundleSrc = body
        if hasFS then
            pcall(writefile, CONFIG.CACHE_FILE, body)
        end
    end
end

if not bundleSrc then
    warn("[Pulse Loader] Impossible de charger le bundle.")
    return
end

-- Exécute
local fn, err = loadstring(bundleSrc, "@pulse_bundle")
if not fn then
    warn("[Pulse Loader] Erreur de syntaxe : " .. tostring(err))
    return
end

local ok, runErr = pcall(fn)
if not ok then
    warn("[Pulse Loader] Erreur d'exécution : " .. tostring(runErr))
end
