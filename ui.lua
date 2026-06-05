-- ================================ XKID UI (MINIMAL WORKING) ================================
local UI = {}

function UI.create(core, modules)
    -- Load WindUI
    local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/refs/heads/main/dist/main.lua"))()
    core.WindUI = WindUI
    
    -- Override notify
    core.Notify = function(title, content, duration, icon)
        pcall(function() 
            WindUI:Notify({ Title = title, Content = content, Duration = duration or 2, Icon = icon or "bell" })
        end)
    end
    
    -- Buat window utama
    local win = WindUI:CreateWindow({
        Title = "XKID HUB",
        Size = UDim2.fromOffset(400, 500),
        Theme = "Crimson"
    })
    
    -- Tab: Informasi
    local tabInfo = win:Tab({ Title = "Info", Icon = "info" })
    local secInfo = tabInfo:Section({ Title = "Status", Box = true })
    secInfo:Paragraph({ 
        Title = "✅ XKID HUB Aktif!", 
        Desc = "Core dan UI berhasil dimuat.\nFitur akan ditambahkan bertahap." 
    })
    
    -- Tab: Character (contoh slider)
    local tabChar = win:Tab({ Title = "Character", Icon = "fingerprint" })
    local secMove = tabChar:Section({ Title = "Movement", Box = true })
    secMove:Slider({ 
        Title = "Walk Speed", 
        Value = { Min = 16, Max = 100, Default = 16 },
        Callback = function(v)
            core.State.Move.ws = v
            local hum = core.Helpers.getHum()
            if hum then hum.WalkSpeed = v end
            core.Notify("Speed", "Walk Speed: " .. v, 1, "zap")
        end
    })
    
    -- Tab: ESP (placeholder)
    local tabESP = win:Tab({ Title = "ESP", Icon = "scan-search" })
    local secESP = tabESP:Section({ Title = "Radar", Box = true })
    secESP:Toggle({ 
        Title = "Enable ESP", 
        Default = false,
        Callback = function(v)
            core.State.ESP.active = v
            core.Notify("ESP", v and "ON" or "OFF", 1.5, "radar")
        end
    })
    
    -- Auto expand semua section
    task.delay(0.5, function()
        pcall(function()
            for _,tab in pairs(win.Tabs) do
                for _,sec in ipairs(tab.Sections) do
                    if sec.Expand then sec:Expand() end
                end
            end
        end)
    end)
    
    core.Notify("System", "XKID HUB Siap!", 3, "rocket")
end

return UI