
-- ================================ SETTINGS MODULE ================================
-- by @WTF.XKID | Config save/load & Settings UI

local Settings = {}

function Settings.setup(core, state, modules)
    local HttpService = core.Services.HttpService
    
    function Settings.saveConfig(cfgName)
        if not core.Executor.has_writefile then
            core.Notify("Config", "Executor tidak support save file", 2, "circle-alert")
            return
        end
        pcall(function()
            if not isfolder("XKID_HUB") then makefolder("XKID_HUB") end
            local data = {
                Move = { ws = state.Move.ws, jp = state.Move.jp, flyS = state.Move.flyS, autoWalkSpeed = state.Move.autoWalkSpeed },
                ESP = { tracerMode = state.ESP.tracerMode, maxDrawDistance = state.ESP.maxDrawDistance, highlightMode = state.ESP.highlightMode },
                Security = { shiftLock = state.Security.shiftLock, antiLag = state.Security.antiLag },
                AutoLike = { radius = state.AutoLike.radius, minCD = state.AutoLike.minCD, maxCD = state.AutoLike.maxCD },
                HardFling = { power = state.HardFling.power, mode = state.HardFling.mode },
                SelfSpec = { mode = state.SelfSpec.mode, radius = state.SelfSpec.radius, height = state.SelfSpec.height, speed = state.SelfSpec.speed },
                CustomFilter = {
                    tintR = state.CustomFilter.tintR, tintG = state.CustomFilter.tintG, tintB = state.CustomFilter.tintB,
                    saturation = state.CustomFilter.saturation, contrast = state.CustomFilter.contrast,
                    brightness = state.CustomFilter.brightness, exposure = state.CustomFilter.exposure,
                    bloomIntensity = state.CustomFilter.bloomIntensity, bloomSize = state.CustomFilter.bloomSize,
                    clockTime = state.CustomFilter.clockTime, dofIntensity = state.CustomFilter.dofIntensity,
                    dofDistance = state.CustomFilter.dofDistance
                }
            }
            writefile("XKID_HUB/" .. cfgName .. ".json", HttpService:JSONEncode(data))
            core.Notify("Config", "Saved: " .. cfgName, 2, "save")
        end)
    end
    
    function Settings.loadConfig(selected)
        if selected == "No config" then return end
        pcall(function()
            if core.Executor.has_readfile and isfile and isfile("XKID_HUB/" .. selected .. ".json") then
                local data = HttpService:JSONDecode(readfile("XKID_HUB/" .. selected .. ".json"))
                if data then
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
                    if data.ESP then
                        state.ESP.tracerMode = data.ESP.tracerMode or "Bottom"
                        state.ESP.maxDrawDistance = data.ESP.maxDrawDistance or 300
                        state.ESP.highlightMode = data.ESP.highlightMode or false
                    end
                    if data.Security and data.Security.shiftLock ~= state.Security.shiftLock then
                        if modules["modules/spectator.lua"] and modules["modules/spectator.lua"].toggleShiftLock then
                            modules["modules/spectator.lua"].toggleShiftLock(data.Security.shiftLock)
                        end
                    end
                    if data.AutoLike then
                        state.AutoLike.radius = data.AutoLike.radius or 100
                        state.AutoLike.minCD = data.AutoLike.minCD or 2
                        state.AutoLike.maxCD = data.AutoLike.maxCD or 6
                    end
                    if data.HardFling then
                        state.HardFling.power = data.HardFling.power or 5000
                        state.HardFling.mode = data.HardFling.mode or "Spin"
                    end
                    if data.SelfSpec then
                        state.SelfSpec.mode = data.SelfSpec.mode or "Manual"
                        state.SelfSpec.radius = data.SelfSpec.radius or 8
                        state.SelfSpec.height = data.SelfSpec.height or 3
                        state.SelfSpec.speed = data.SelfSpec.speed or 1
                    end
                    if data.CustomFilter then
                        for k,v in pairs(data.CustomFilter) do state.CustomFilter[k] = v end
                        if modules["modules/visuals.lua"] then
                            modules["modules/visuals.lua"].applyCustomFilter(core, state)
                        end
                    end
                    core.Notify("Config", "Loaded: " .. selected, 2, "folder-open")
                end
            end
        end)
    end
    
    function Settings.deleteConfig(configName, currentConfig, refreshCallback)
        if configName ~= "No config" and configName ~= "" and core.Executor.has_listfiles then
            pcall(function()
                if isfile and delfile and isfile("XKID_HUB/" .. configName .. ".json") then
                    delfile("XKID_HUB/" .. configName .. ".json")
                    if refreshCallback then refreshCallback() end
                    core.Notify("Config", "Deleted", 2, "trash-2")
                    return true
                end
            end)
        end
        return false
    end
    
    return Settings
end

return Settings