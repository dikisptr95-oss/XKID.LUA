-- ================================ XKID HUB LOADER ================================
-- Repository: https://github.com/dikisptr95-oss/XKID.LUA

repeat task.wait() until game:IsLoaded()

local BASE_URL = "https://raw.githubusercontent.com/dikisptr95-oss/XKID.LUA/main/"

local function loadModule(path)
    local url = BASE_URL .. path
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if not success then
        warn("[XKID] Gagal load: " .. path .. " | Error: " .. tostring(result))
        return nil
    end
    return result
end

print("[XKID] Loading Core...")
local core = loadModule("core.lua")
if not core then return error("Core gagal dimuat") end

local modules = {
    "modules/esp.lua",
    "modules/fly.lua",
    "modules/freecam.lua",
    "modules/teleport.lua",
}

local loadedModules = {}
for _, modulePath in ipairs(modules) do
    print("[XKID] Loading " .. modulePath .. "...")
    local mod = loadModule(modulePath)
    if mod then loadedModules[modulePath] = mod end
    task.wait()
end

print("[XKID] Loading UI...")
local UI = loadModule("ui.lua")

if UI and UI.create then
    UI.create(core, loadedModules)
    print("[XKID] XKID HUB V2.0 Siap!")
else
    error("[XKID] UI gagal dimuat")
end