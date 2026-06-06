-- ================================ XKID HUB LOADER (DEBUG VER) ================================
repeat task.wait() until game:IsLoaded()

print("[XKID] LOADER START")

-- ================================ PASTEBIN RAW URL ================================
local PASTES = {
    core = "https://pastebin.com/raw/b8xPrDa6",
    ui = "https://pastebin.com/raw/pY1HrRS5",
    esp = "https://pastebin.com/raw/vhQQycF8",
    fly = "https://pastebin.com/raw/KgjnJ5r6",
    freecam = "https://pastebin.com/raw/JGmQfH6L",
    teleport = "https://pastebin.com/raw/dmkXvZik",
    spectator = "https://pastebin.com/raw/nrfgSKxp",
    visuals = "https://pastebin.com/raw/cDYAyy3J",
    autolike = "https://pastebin.com/raw/pEEQ8D9f",
    fling = "https://pastebin.com/raw/DSPrZJw2",
    logger = "https://pastebin.com/raw/kE5F1ExN",
    settings = "https://pastebin.com/raw/5GTf1efY",
}

-- ================================ SAFE LOADER ================================
local function loadPaste(url, name)
    print("[XKID] Loading:", name)

    local success, content = pcall(function()
        return game:HttpGet(url, true)
    end)

    if not success then
        warn("[XKID] HttpGet failed:", name, content)
        return nil
    end

    if not content or content == "" then
        warn("[XKID] Empty content:", name)
        return nil
    end

    print("[XKID] Content received:", name)

    local func, err = loadstring(content)

    if not func then
        warn("[XKID] Compile failed:", name, err)
        return nil
    end

    print("[XKID] Compiled:", name)

    local execSuccess, result = pcall(func)

    if not execSuccess then
        warn("[XKID] Execution failed:", name, result)
        return nil
    end

    print("[XKID] SUCCESS:", name)

    return result
end

-- ================================ CLEAN OLD UI ================================
pcall(function()
    for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
        if v.Name == "WindUI" or string.find(v.Name, "XKID") then
            print("[XKID] Removing old UI:", v.Name)
            v:Destroy()
        end
    end
end)

-- ================================ LOAD CORE ================================
local core = loadPaste(PASTES.core, "core")

if not core then
    error("[XKID] CORE FAILED")
end

print("[XKID] Core loaded")

-- ================================ LOAD MODULES ================================
local modules = {}

local moduleNames = {
    "esp",
    "fly",
    "freecam",
    "teleport",
    "spectator",
    "visuals",
    "autolike",
    "fling",
    "logger",
    "settings"
}

for _, name in ipairs(moduleNames) do
    local mod = loadPaste(PASTES[name], name)

    if mod then
        modules[name] = mod
        print("[XKID] Module OK:", name)
    else
        warn("[XKID] Module FAILED:", name)
    end

    task.wait(0.1)
end

-- ================================ SETUP ================================
local Camera = workspace.CurrentCamera
local UserInputService = core.Services.UserInputService
local RunService = core.Services.RunService
local onMobile = not UserInputService.KeyboardEnabled

print("[XKID] Starting setup...")

-- Spectator
pcall(function()
    if modules.spectator then
        modules.spectatorApi = modules.spectator.setup(
            core,
            core.State,
            Camera,
            UserInputService,
            RunService,
            onMobile
        )

        modules.selfspectateApi = modules.spectator.setupSelfSpectate(
            core,
            core.State,
            Camera,
            UserInputService,
            RunService,
            onMobile
        )

        print("[XKID] Spectator setup OK")
    end
end)

-- Teleport
pcall(function()
    if modules.teleport then
        modules.teleportApi = modules.teleport.setupSmartTP(core, UserInputService)
        modules.targetTPApi = modules.teleport.setupTargetTP(core, core.Services.Players)
        modules.autowalkApi = modules.teleport.setupAutoWalk(core.State, core, RunService, Camera)
        modules.coordApi = modules.teleport.setupCoordCache(core)

        print("[XKID] Teleport setup OK")
    end
end)

-- AutoLike
pcall(function()
    if modules.autolike then
        modules.autolikeApi = modules.autolike.setup(core, core.State)
        print("[XKID] AutoLike setup OK")
    end
end)

-- Fling
pcall(function()
    if modules.fling then
        modules.flingApi = modules.fling.setup(core, core.State, RunService)
        print("[XKID] Fling setup OK")
    end
end)

-- Logger
pcall(function()
    if modules.logger then
        modules.loggerApi = modules.logger.setup(core, core.State)
        print("[XKID] Logger setup OK")
    end
end)

-- Settings
pcall(function()
    if modules.settings then
        modules.settingsApi = modules.settings.setup(core, core.State, modules)
        print("[XKID] Settings setup OK")
    end
end)

-- Simple API
if modules.visuals then
    modules.visualsApi = modules.visuals
end

if modules.fly then
    modules.flyApi = modules.fly
end

if modules.freecam then
    modules.freecamApi = modules.freecam
end

if modules.esp then
    modules.espApi = modules.esp
end

print("[XKID] Module setup complete")

-- ================================ LOAD UI ================================
local UI = loadPaste(PASTES.ui, "ui")

if UI and UI.create then
    print("[XKID] Creating UI...")

    local success, err = pcall(function()
        UI.create(core, modules)
    end)

    if success then
        print("[XKID] XKID HUB V2 READY!")
    else
        warn("[XKID] UI CREATE FAILED:", err)
    end
else
    error("[XKID] UI FAILED")
end

print("[XKID] LOADER FINISH")