-- ================================ XKID HUB LOADER ================================
-- Repository: https://github.com/dikisptr95-oss/XKID.LUA
-- Cara pakai: loadstring(game:HttpGet("https://raw.githubusercontent.com/dikisptr95-oss/XKID.LUA/main/loader.lua"))()

repeat task.wait() until game:IsLoaded()

-- ================================ KONFIGURASI ================================
local BASE_URL = "https://raw.githubusercontent.com/dikisptr95-oss/XKID.LUA/main/"

-- ================================ FUNGSI LOAD MODULE ================================
local function loadModule(path)
    local url = BASE_URL .. path
    local success, result = pcall(function()
        print("[XKID] Mengambil: " .. url)
        local content = game:HttpGet(url, true)
        return loadstring(content)
    end)
    if not success then
        warn("[XKID] Gagal ambil " .. path .. ": " .. tostring(result))
        return nil, result
    end
    local execSuccess, execResult = pcall(result)
    if not execSuccess then
        warn("[XKID] Gagal eksekusi " .. path .. ": " .. tostring(execResult))
        return nil, execResult
    end
    return execResult
end

-- ================================ CLEANUP SEBELUM LOAD ================================
pcall(function()
    for _,v in pairs(game:GetService("CoreGui"):GetChildren()) do
        if v.Name == "WindUI" or v.Name:find("XKID") then
            v:Destroy()
        end
    end
end)

-- ================================ LOAD CORE ================================
print("[XKID] Memuat core.lua...")
local core = loadModule("core.lua")
if not core then
    error("[XKID] Gagal memuat core.lua. Pastikan file ada di repository.")
end
print("[XKID] Core berhasil dimuat!")

-- ================================ LOAD SEMUA MODULES ================================
local modules = {
    esp = "modules/esp.lua",
    fly = "modules/fly.lua",
    freecam = "modules/freecam.lua",
    teleport = "modules/teleport.lua",
    spectator = "modules/spectator.lua",
    visuals = "modules/visuals.lua",
    autolike = "modules/autolike.lua",
    fling = "modules/fling.lua",
    logger = "modules/logger.lua",
    settings = "modules/settings.lua",
}

local loadedModules = {}

for name, path in pairs(modules) do
    print("[XKID] Memuat " .. path .. "...")
    local mod = loadModule(path)
    if mod then
        loadedModules[name] = mod
        print("[XKID] ✓ " .. name .. " berhasil")
    else
        warn("[XKID] ✗ " .. name .. " gagal dimuat")
    end
    task.wait()
end

-- ================================ SETUP MODULES YANG MEMERLUKAN INISIALISASI ================================
local Camera = workspace.CurrentCamera
local UserInputService = core.Services.UserInputService
local RunService = core.Services.RunService
local onMobile = not UserInputService.KeyboardEnabled

-- Setup spectator
if loadedModules.spectator then
    loadedModules.spectatorApi = loadedModules.spectator.setup(core, core.State, Camera, UserInputService, RunService, onMobile)
    loadedModules.selfspectateApi = loadedModules.spectator.setupSelfSpectate(core, core.State, Camera, UserInputService, RunService, onMobile)
end

-- Setup teleport
if loadedModules.teleport then
    loadedModules.teleportApi = loadedModules.teleport.setupSmartTP(core, UserInputService)
    loadedModules.autowalkApi = loadedModules.teleport.setupAutoWalk(core.State, core, RunService, Camera)
end

-- Setup autolike
if loadedModules.autolike then
    loadedModules.autolikeApi = loadedModules.autolike.setup(core, core.State)
end

-- Setup fling
if loadedModules.fling then
    loadedModules.flingApi = loadedModules.fling.setup(core, core.State, RunService)
end

-- Setup logger
if loadedModules.logger then
    loadedModules.loggerApi = loadedModules.logger.setup(core, core.State)
end

-- Setup settings
if loadedModules.settings then
    loadedModules.settingsApi = loadedModules.settings.setup(core, core.State, loadedModules)
end

-- ================================ LOAD UI ================================
print("[XKID] Memuat ui.lua...")
local UI = loadModule("ui.lua")

if UI and UI.create then
    UI.create(core, loadedModules)
    print("[XKID] ========================================")
    print("[XKID] XKID HUB V2.0 SIAP DIGUNAKAN!")
    print("[XKID] ========================================")
else
    error("[XKID] Gagal memuat UI. Pastikan ui.lua ada di repository.")
end