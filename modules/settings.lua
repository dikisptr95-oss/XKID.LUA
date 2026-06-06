-- ================================ SETTINGS MODULE ================================
-- by @WTF.XKID | Full Config Save/Load & Settings Engine dari script asli

local Settings = {}

function Settings.setup(core, state, modules)
    local HttpService = core.Services.HttpService
    
    -- ================================ SAVE CONFIGURATION ================================
    function Settings.saveConfig(cfgName)
        if not core.Executor.has_writefile then
            core.Notify("Config", "Executor tidak support save file", 2, "circle-alert")
            return false
        end
        
        pcall(function()
            if not isfolder("XKID_HUB") then 
                makefolder("XKID_HUB") 
            end
            
            local data = {
                -- Movement
                Move = {
                    ws = state.Move.ws,
                    jp = state.Move.jp,
                    flyS = state.Move.flyS,
                    autoWalkSpeed = state.Move.autoWalkSpeed
                },
                -- ESP
                ESP = {
                    tracerMode = state.ESP.tracerMode,
                    maxDrawDistance = state.ESP.maxDrawDistance,
                    highlightMode = state.ESP.highlightMode
                },
                -- Security
                Security = {
                    shiftLock = state.Security.shiftLock,
                    antiLag = state.Security.antiLag
                },
                -- Auto Like
                AutoLike = {
                    radius = state.AutoLike.radius,
                    minCD = state.AutoLike.minCD,
                    maxCD = state.AutoLike.maxCD
                },
                -- Hard Fling
                HardFling = {
                    power = state.HardFling.power,
                    mode = state.HardFling.mode
                },
                -- Self Spectate
                SelfSpec = {
                    mode = state.SelfSpec.mode,
                    radius = state.SelfSpec.radius,
                    height = state.SelfSpec.height,
                    speed = state.SelfSpec.speed
                },
                -- Custom Filter
                CustomFilter = {
                    tintR = state.CustomFilter.tintR,
                    tintG = state.CustomFilter.tintG,
                    tintB = state.CustomFilter.tintB,
                    saturation = state.CustomFilter.saturation,
                    contrast = state.CustomFilter.contrast,
                    brightness = state.CustomFilter.brightness,
                    exposure = state.CustomFilter.exposure,
                    bloomIntensity = state.CustomFilter.bloomIntensity,
                    bloomSize = state.CustomFilter.bloomSize,
                    clockTime = state.CustomFilter.clockTime,
                    dofIntensity = state.CustomFilter.dofIntensity,
                    dofDistance = state.CustomFilter.dofDistance
                }
            }
            
            writefile("XKID_HUB/" .. cfgName .. ".json", HttpService:JSONEncode(data))
            core.Notify("Config", "Saved: " .. cfgName, 2, "save")
            return true
        end)
        return false
    end
    
    -- ================================ LOAD CONFIGURATION ================================
    function Settings.loadConfig(selected)
        if selected == "No config" or selected == nil then 
            return false 
        end
        
        pcall(function()
            if core.Executor.has_readfile and isfile and isfile("XKID_HUB/" .. selected .. ".json") then
                local data = HttpService:JSONDecode(readfile("XKID_HUB/" .. selected .. ".json"))
                if data then
                    -- Load Movement
                    if data.Move then
                        state.Move.ws = data.Move.ws or 16
                        state.Move.jp = data.Move.jp or 50
                        state.Move.flyS = data.Move.flyS or 60
                        state.Move.autoWalkSpeed = data.Move.autoWalkSpeed or 16
                        local h = core.Helpers.getHum()
                        if h then
                            h.WalkSpeed = state.Move.ws
                            h.UseJumpPower = true
                            h.JumpPower = state.Move.jp
                        end
                    end
                    
                    -- Load ESP
                    if data.ESP then
                        state.ESP.tracerMode = data.ESP.tracerMode or "Bottom"
                        state.ESP.maxDrawDistance = data.ESP.maxDrawDistance or 300
                        state.ESP.highlightMode = data.ESP.highlightMode or false
                    end
                    
                    -- Load Security (Shift Lock)
                    if data.Security and data.Security.shiftLock ~= state.Security.shiftLock then
                        if modules.spectator and modules.spectator.toggleShiftLock then
                            modules.spectator.toggleShiftLock(data.Security.shiftLock)
                        end
                    end
                    
                    -- Load Auto Like
                    if data.AutoLike then
                        state.AutoLike.radius = data.AutoLike.radius or 100
                        state.AutoLike.minCD = data.AutoLike.minCD or 2
                        state.AutoLike.maxCD = data.AutoLike.maxCD or 6
                    end
                    
                    -- Load Hard Fling
                    if data.HardFling then
                        state.HardFling.power = data.HardFling.power or 5000
                        state.HardFling.mode = data.HardFling.mode or "Spin"
                    end
                    
                    -- Load Self Spec
                    if data.SelfSpec then
                        state.SelfSpec.mode = data.SelfSpec.mode or "Manual"
                        state.SelfSpec.radius = data.SelfSpec.radius or 8
                        state.SelfSpec.height = data.SelfSpec.height or 3
                        state.SelfSpec.speed = data.SelfSpec.speed or 1
                    end
                    
                    -- Load Custom Filter
                    if data.CustomFilter then
                        for k,v in pairs(data.CustomFilter) do 
                            state.CustomFilter[k] = v 
                        end
                        if modules.visuals then
                            modules.visuals.applyCustomFilter(core, state)
                        end
                    end
                    
                    core.Notify("Config", "Loaded: " .. selected, 2, "folder-open")
                    return true
                end
            end
        end)
        return false
    end
    
    -- ================================ DELETE CONFIGURATION ================================
    function Settings.deleteConfig(configName, refreshCallback)
        if configName ~= "No config" and configName ~= "" and core.Executor.has_listfiles then
            pcall(function()
                if isfile and delfile and isfile("XKID_HUB/" .. configName .. ".json") then
                    delfile("XKID_HUB/" .. configName .. ".json")
                    if refreshCallback then 
                        refreshCallback() 
                    end
                    core.Notify("Config", "Deleted: " .. configName, 2, "trash-2")
                    return true
                end
            end)
        end
        return false
    end
    
    -- ================================ GET CONFIG LIST ================================
    function Settings.getConfigList()
        local list = {}
        if core.Executor.has_isfolder and core.Executor.has_listfiles then
            pcall(function()
                if isfolder and isfolder("XKID_HUB") then
                    for _,file in ipairs(listfiles("XKID_HUB")) do
                        if file:match("%.json$") then
                            local name = file:match("([^/\\]+)%.json$")
                            if name then 
                                table.insert(list, name) 
                            end
                        end
                    end
                end
            end)
        end
        if #list == 0 then table.insert(list, "No config") end
        return list
    end
    
    -- ================================ RESET ALL SETTINGS ================================
    function Settings.resetAll()
        -- Reset Movement
        state.Move.ws = 16
        state.Move.jp = 50
        state.Move.flyS = 60
        state.Move.autoWalkSpeed = 16
        
        -- Reset ESP
        state.ESP.tracerMode = "Bottom"
        state.ESP.maxDrawDistance = 300
        state.ESP.highlightMode = false
        
        -- Reset Auto Like
        state.AutoLike.radius = 100
        state.AutoLike.minCD = 2
        state.AutoLike.maxCD = 6
        
        -- Reset Hard Fling
        state.HardFling.power = 10000
        state.HardFling.mode = "Spin"
        
        -- Reset Self Spec
        state.SelfSpec.mode = "Manual"
        state.SelfSpec.radius = 8
        state.SelfSpec.height = 3
        state.SelfSpec.speed = 1
        
        -- Reset Custom Filter
        state.CustomFilter.tintR = 255
        state.CustomFilter.tintG = 255
        state.CustomFilter.tintB = 255
        state.CustomFilter.saturation = 0
        state.CustomFilter.contrast = 0
        state.CustomFilter.brightness = 0
        state.CustomFilter.exposure = 0
        state.CustomFilter.bloomIntensity = 0
        state.CustomFilter.bloomSize = 24
        state.CustomFilter.clockTime = 14
        state.CustomFilter.dofIntensity = 0
        state.CustomFilter.dofDistance = 50
        
        -- Apply reset filter
        if modules.visuals then
            modules.visuals.applyCustomFilter(core, state)
        end
        
        -- Reset character settings
        local h = core.Helpers.getHum()
        if h then
            h.WalkSpeed = 16
            h.UseJumpPower = true
            h.JumpPower = 50
        end
        
        core.Notify("Settings", "All settings reset to default", 2, "rotate-ccw")
    end
    
    return Settings
end

return Settings