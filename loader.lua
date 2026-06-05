-- ================================ XKID HUB LOADER V3 (WINDUI FIX) ================================
repeat task.wait() until game:IsLoaded()

local BASE_URL = "https://raw.githubusercontent.com/dikisptr95-oss/XKID.LUA/main/"

-- Fungsi load module yang toleran error
local function loadModule(path, silent)
    local url = BASE_URL .. path
    local success, content = pcall(function() return game:HttpGet(url, true) end)
    if not success then
        if not silent then warn("[XKID] Gagal ambil: " .. path) end
        return nil
    end
    local func, err = loadstring(content)
    if not func then
        if not silent then warn("[XKID] Gagal compile: " .. path .. " - " .. err) end
        return nil
    end
    local execSuccess, result = pcall(func)
    if not execSuccess then
        if not silent then warn("[XKID] Gagal eksekusi: " .. path .. " - " .. result) end
        return nil
    end
    return result
end

-- Bersihkan UI lama
pcall(function()
    for _,v in pairs(game:GetService("CoreGui"):GetChildren()) do
        if v.Name:find("WindUI") or v.Name:find("XKID") then
            v:Destroy()
        end
    end
end)

-- Load core (wajib)
local core = loadModule("core.lua")
if not core then
    error("[XKID] core.lua gagal dimuat.")
end

-- Load modules (lewati yang error)
local moduleNames = {"esp", "fly", "freecam", "teleport", "spectator", "visuals", "autolike", "fling", "logger", "settings"}
local loaded = {}
for _, name in ipairs(moduleNames) do
    local mod = loadModule("modules/" .. name .. ".lua", true)
    if mod then loaded[name] = mod end
end

-- Load UI
local UI = loadModule("ui.lua")
if UI and UI.create then
    UI.create(core, loaded)
    print("[XKID] XKID HUB SIAP!")
else
    error("[XKID] ui.lua gagal dimuat")
end
