-- ================================ XKID UI (FULL TABS) ================================
local UI = {}

function UI.create(core, modules)
    local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/refs/heads/main/dist/main.lua"))()
    core.WindUI = WindUI
    
    core.Notify = function(title, content, duration, icon)
        pcall(function() WindUI:Notify({ Title = title, Content = content, Duration = duration or 2, Icon = icon or "bell" }) end)
    end
    
    local win = WindUI:CreateWindow({
        Title = "XKID HUB V2.0",
        Size = UDim2.fromOffset(380, 360),
        Theme = "Crimson",
        SideBarWidth = 150,
    })
    
    -- ========== TAB 1: INFORMASI ==========
    local tabInfo = win:Tab({ Title = "Informasi", Icon = "activity" })
    -- (isi sesuai script asli, panggil core.State dll)
    local avatarImage = "rbxthumb://type=AvatarHeadShot&id=" .. LP.UserId .. "&w=420&h=420"
    tabInfo:Paragraph({ Title = "YooWssp!!, " .. LP.DisplayName, Desc = "Executor: " .. core.Executor.name, Image = avatarImage, ImageSize = 80 })
    tabInfo:Section({ Title = "🔗 Discord" }):Button({ Title = "Copy Discord Link", Callback = function() setclipboard("https://discord.gg/...") end })
    
    -- ========== TAB 2: CHARACTER ==========
    local tabChar = win:Tab({ Title = "Character", Icon = "fingerprint" })
    -- Movement section
    local secMov = tabChar:Section({ Title = "Movement", Box = true })
    secMov:Slider({ Title = "Walk Speed", Value = { Min = 16, Max = 500, Default = 16 }, Callback = function(v) core.State.Move.ws = v; local h = core.Helpers.getHum(); if h then h.WalkSpeed = v end end })
    secMov:Slider({ Title = "Jump Power", Value = { Min = 50, Max = 500, Default = 50 }, Callback = function(v) core.State.Move.jp = v; local h = core.Helpers.getHum(); if h then h.UseJumpPower = true; h.JumpPower = v end end })
    secMov:Toggle({ Title = "Infinite Jump", Callback = function(v) -- panggil module jika ada -- end })
    -- Abilities
    local secAbi = tabChar:Section({ Title = "Abilities", Box = true })
    secAbi:Toggle({ Title = "Fly", Callback = function(v) if modules.fly and modules.fly.toggle then modules.fly.toggle(v, core.State, core) else core.Notify("Fly", v and "ON" or "OFF") end end })
    secAbi:Slider({ Title = "Fly Speed", Value = { Min = 10, Max = 300, Default = 60 }, Callback = function(v) core.State.Move.flyS = v end })
    secAbi:Toggle({ Title = "NoClip", Callback = function(v) core.State.Move.ncp = v; -- implementasi noClip -- end })
    -- Hard Fling
    local secFling = tabChar:Section({ Title = "Hard Fling", Box = true })
    secFling:Toggle({ Title = "Enable Fling", Callback = function(v) if modules.fling then if v then modules.fling.start(core.State) else modules.fling.stop() end else core.Notify("Hard Fling", v and "ON" or "OFF") end end })
    secFling:Dropdown({ Title = "Mode", Values = { "Spin", "Shake" }, Callback = function(v) core.State.HardFling.mode = v end })
    secFling:Slider({ Title = "Power", Value = { Min = 1000, Max = 50000, Default = 10000 }, Callback = function(v) core.State.HardFling.power = v end })
    
    -- ========== TAB 3: ESP ==========
    local tabESP = win:Tab({ Title = "ESP", Icon = "scan-search" })
    local secESP = tabESP:Section({ Title = "Detection", Box = true })
    secESP:Toggle({ Title = "Enable ESP", Callback = function(v) core.State.ESP.active = v; if v and modules.esp then modules.esp.start(core, core.State) end end })
    secESP:Dropdown({ Title = "Tracer Origin", Values = { "Bottom", "Center", "Mouse", "OFF" }, Callback = function(v) core.State.ESP.tracerMode = v end })
    secESP:Slider({ Title = "Max Distance", Value = { Min = 100, Max = 500, Default = 300 }, Callback = function(v) core.State.ESP.maxDrawDistance = v end })
    
    -- ========== TAB 4: TELEPORT ==========
    local tabTP = win:Tab({ Title = "Teleport", Icon = "map-pin" })
    local secTP = tabTP:Section({ Title = "Smart TP", Box = true })
    secTP:Toggle({ Title = "Smart TP", Callback = function(v) if modules.teleport then modules.teleport.toggleSmartTP(v) end end })
    -- Target teleport, save coordinates...
    
    -- ========== TAB 5: SPECTATOR ==========
    local tabSpec = win:Tab({ Title = "Spectator", Icon = "eye" })
    -- ...
    
    -- ========== TAB 6: CINEMATIC ==========
    local tabCine = win:Tab({ Title = "Cinematic", Icon = "camera" })
    -- Self-spectate, freecam...
    
    -- ========== TAB 7: VISUALS ==========
    local tabVis = win:Tab({ Title = "Visuals", Icon = "palette" })
    -- Filter presets, custom FX...
    
    -- ========== TAB 8: LOGGER ==========
    local tabLog = win:Tab({ Title = "Logger", Icon = "terminal" })
    -- Chat logger...
    
    -- ========== TAB 9: PROTECTION ==========
    local tabProt = win:Tab({ Title = "Protection", Icon = "shield" })
    -- Anti AFK, stuck fix...
    
    -- ========== TAB 10: SETTINGS ==========
    local tabSet = win:Tab({ Title = "Settings", Icon = "settings" })
    -- Config save/load, theme...
    
    -- Auto expand
    task.delay(0.5, function()
        pcall(function()
            for _,tab in pairs(win.Tabs) do
                for _,sec in ipairs(tab.Sections) do
                    if sec.Expand then sec:Expand() end
                end
            end
        end)
    end)
    
    core.Notify("System", "XKID HUB V2.0 FULL SIAP!", 3, "rocket")
end

return UI