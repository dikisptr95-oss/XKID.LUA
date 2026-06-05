-- ================================ XKID DIAGNOSIS ================================
print("=== MEMULAI DIAGNOSIS XKID HUB ===")

local BASE_URL = "https://raw.githubusercontent.com/dikisptr95-oss/XKID.LUA/main/"

-- Fungsi untuk menguji file
local function testFile(path, isRequired)
    print(">>> Menguji: " .. path)
    local url = BASE_URL .. path
    local success, content = pcall(function() return game:HttpGet(url, true) end)
    if not success then
        warn("❌ GAGAL mengambil file: " .. path .. " | Error: " .. tostring(content))
        return false
    end

    local func, compileErr = loadstring(content)
    if not func then
        warn("❌ GAGAL mengkompilasi file: " .. path .. " | Error: " .. tostring(compileErr))
        return false
    end

    local execSuccess, result = pcall(func)
    if not execSuccess then
        warn("❌ GAGAL mengeksekusi file: " .. path .. " | Error: " .. tostring(result))
        return false
    end

    print("✅ BERHASIL: " .. path)
    return result
end

-- 1. Test core.lua
local core = testFile("core.lua", true)
if not core then
    error("❌ DIAGNOSIS BERHENTI: core.lua gagal dimuat.")
end

-- 2. Test ui.lua (tanpa modules dulu)
local UI = testFile("ui.lua", true)
if not UI then
    error("❌ DIAGNOSIS BERHENTI: ui.lua gagal dimuat.")
end

-- 3. Test semua modules (opsional)
local moduleNames = {"esp", "fly", "freecam", "teleport", "spectator", "visuals", "autolike", "fling", "logger", "settings"}
local modulesOkay = true
for _, name in ipairs(moduleNames) do
    local mod = testFile("modules/" .. name .. ".lua", false)
    if not mod then
        modulesOkay = false
        print("⚠️ Module " .. name .. " dilewati karena error.")
    end
    task.wait() -- jeda biar tidak overload
end

-- 4. Jika semua aman, coba buat UI
if core and UI and UI.create then
    print(">>> Mencoba membuat UI...")
    local createSuccess, createErr = pcall(function()
        UI.create(core, {}) -- modules dikosongkan dulu untuk meminimalisir error
    end)
    if createSuccess then
        print("✅ UI BERHASIL DIBUAT! Window XKID HUB seharusnya muncul.")
    else
        warn("❌ GAGAL membuat UI: " .. tostring(createErr))
    end
else
    warn("❌ UI.create tidak ditemukan.")
end

print("=== DIAGNOSIS SELESAI ===")