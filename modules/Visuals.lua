-- ================================ VISUALS MODULE ================================
-- by @WTF.XKID | Filter Visual & Presets

local Visuals = {}

-- ================================ FILTER PRESETS ================================
Visuals.PRESETS = {
    Mendung_HD = { tint = Color3.fromRGB(180,185,200), sat = -0.3, con = 0.1, bri = -0.15, bloomI = 0.05, bloomS = 24, time = 10, lightB = 0.7 },
    Cool_Blue_HD = { tint = Color3.fromRGB(180,200,255), sat = 0.1, con = 0.15, bri = 0.05, bloomI = 0.2, bloomS = 24, time = 12, lightB = 1.2 },
    Soft_Fade_HD = { tint = Color3.fromRGB(255,240,235), sat = -0.1, con = -0.05, bri = 0.1, bloomI = 0.4, bloomS = 35, time = 15, lightB = 1.3 },
    Adaptif_Langit_HD = { tint = Color3.new(1,1,1), sat = 0.15, con = 0.2, bri = 0.05, bloomI = 0.15, bloomS = 24, time = 13, lightB = 1.5 },
    Edgy_HD = { tint = Color3.fromRGB(200,195,210), sat = -0.5, con = 0.4, bri = -0.1, bloomI = 0.3, bloomS = 20, time = 8, lightB = 0.8 },
    Full_Bright_HD = { tint = Color3.new(1,1,1), sat = 0, con = 0, bri = 0, bloomI = 0, bloomS = 24, time = 12, lightB = 3, shadow = false, ambient = Color3.new(1,1,1), outdoor = Color3.new(1,1,1) },
    Soft_Pastel_HD = { tint = Color3.fromRGB(255,240,245), sat = -0.05, con = 0.05, bri = 0, bloomI = 0.3, bloomS = 24, time = 8, lightB = 1 },
    Cinematic_Soft = { tint = Color3.new(1,1,1), sat = 0.1, con = 0.15, bri = 0.05, bloomI = 0.2, bloomS = 24, time = 17, lightB = 1 },
    Ultra_HD = { tint = Color3.new(1,1,1), sat = 0.2, con = 0.3, bri = 0, bloomI = 0.2, bloomS = 24, time = 14, lightB = 1 },
    Realistic = { tint = Color3.new(1,1,1), sat = 0.1, con = 0.2, bri = 0, bloomI = 0.15, bloomS = 24, time = 15, lightB = 1 },
    Night_HD = { tint = Color3.fromRGB(200,200,255), sat = 0.1, con = 0.2, bri = 0, bloomI = 0.15, bloomS = 24, time = 1, lightB = 1 },
    Senja = { tint = Color3.fromRGB(255,180,120), sat = 0.2, con = 0.1, bri = 0.05, bloomI = 0.5, bloomS = 40, time = 17.5, lightB = 1 },
    Cinematic_Film = { tint = Color3.fromRGB(200,210,230), sat = -0.15, con = 0.25, bri = -0.05, bloomI = 0.15, bloomS = 20, time = 16, lightB = 1 },
    Golden_Hour = { tint = Color3.fromRGB(255,200,100), sat = 0.1, con = 0.15, bri = 0.1, bloomI = 0.4, bloomS = 35, time = 17.5, lightB = 1 },
    Moody_Blue = { tint = Color3.fromRGB(150,170,255), sat = 0.05, con = 0.2, bri = -0.1, bloomI = 0.1, bloomS = 24, time = 2, lightB = 1 },
}

-- ================================ HELPER FUNCTIONS ================================
local function resetFilterOnly(lighting)
    for _,v in pairs(lighting:GetChildren()) do
        if v.Name == "_XKID_FILTER" then v:Destroy() end
    end
end

local function resetDOFOnly(lighting)
    for _,v in pairs(lighting:GetChildren()) do
        if v.Name == "_XKID_DOF" then v:Destroy() end
    end
end

-- ================================ APPLY CUSTOM FILTER ================================
function Visuals.applyCustomFilter(core, state)
    local lighting = core.Services.Lighting
    resetFilterOnly(lighting)
    
    lighting.Brightness = core.OriginalLighting.Brightness
    lighting.Ambient = core.OriginalLighting.Ambient
    lighting.OutdoorAmbient = core.OriginalLighting.OutdoorAmbient
    lighting.GlobalShadows = core.OriginalLighting.GlobalShadows
    lighting.ExposureCompensation = state.CustomFilter.exposure
    
    local cc = Instance.new("ColorCorrectionEffect", lighting)
    cc.Name = "_XKID_FILTER"
    cc.TintColor = Color3.fromRGB(state.CustomFilter.tintR, state.CustomFilter.tintG, state.CustomFilter.tintB)
    cc.Saturation = state.CustomFilter.saturation
    cc.Contrast = state.CustomFilter.contrast
    cc.Brightness = state.CustomFilter.brightness
    
    local bloom = Instance.new("BloomEffect", lighting)
    bloom.Name = "_XKID_FILTER"
    bloom.Intensity = state.CustomFilter.bloomIntensity
    bloom.Size = state.CustomFilter.bloomSize
    
    lighting.ClockTime = state.CustomFilter.clockTime
    
    resetDOFOnly(lighting)
    if state.CustomFilter.dofIntensity > 0 then
        local dof = Instance.new("DepthOfFieldEffect", lighting)
        dof.Name = "_XKID_DOF"
        dof.FarIntensity = state.CustomFilter.dofIntensity
        dof.FocusDistance = state.CustomFilter.dofDistance
    end
end

-- ================================ APPLY FILTER BY NAME ================================
function Visuals.applyFilter(core, state, filterName)
    local lighting = core.Services.Lighting
    
    resetFilterOnly(lighting)
    resetDOFOnly(lighting)
    lighting.ClockTime = core.OriginalLighting.ClockTime
    lighting.Brightness = core.OriginalLighting.Brightness
    lighting.Ambient = core.OriginalLighting.Ambient
    lighting.OutdoorAmbient = core.OriginalLighting.OutdoorAmbient
    lighting.GlobalShadows = core.OriginalLighting.GlobalShadows
    lighting.ExposureCompensation = core.OriginalLighting.ExposureCompensation
    
    if filterName == "Default" then
        state.CustomFilter.tintR = 255; state.CustomFilter.tintG = 255; state.CustomFilter.tintB = 255
        state.CustomFilter.saturation = 0; state.CustomFilter.contrast = 0; state.CustomFilter.brightness = 0
        state.CustomFilter.exposure = 0; state.CustomFilter.bloomIntensity = 0; state.CustomFilter.bloomSize = 24
        state.CustomFilter.clockTime = 14; state.CustomFilter.dofIntensity = 0; state.CustomFilter.dofDistance = 50
        core.Notify("Visuals", "Default", 1.5, "palette")
        return
    end
    
    if filterName == "Custom" then
        Visuals.applyCustomFilter(core, state)
        core.Notify("Visuals", "Custom FX", 1.5, "palette")
        return
    end
    
    local key = filterName:gsub(" ", "_"):gsub(" HD", "_HD")
    local preset = Visuals.PRESETS[key]
    if preset then
        lighting.ClockTime = preset.time or 14
        lighting.Brightness = preset.lightB or 1
        lighting.ExposureCompensation = preset.exp or 0
        lighting.GlobalShadows = preset.shadow ~= false
        if preset.ambient then lighting.Ambient = preset.ambient end
        if preset.outdoor then lighting.OutdoorAmbient = preset.outdoor end
        
        local cc = Instance.new("ColorCorrectionEffect", lighting)
        cc.Name = "_XKID_FILTER"
        cc.TintColor = preset.tint
        cc.Saturation = preset.sat or 0
        cc.Contrast = preset.con or 0
        cc.Brightness = preset.bri or 0
        
        local bloom = Instance.new("BloomEffect", lighting)
        bloom.Name = "_XKID_FILTER"
        bloom.Intensity = preset.bloomI or 0
        bloom.Size = preset.bloomS or 24
        
        if preset.dofI and preset.dofI > 0 then
            local dof = Instance.new("DepthOfFieldEffect", lighting)
            dof.Name = "_XKID_DOF"
            dof.FarIntensity = preset.dofI
            dof.FocusDistance = preset.dofD or 50
        end
        
        state.CustomFilter.tintR = preset.tint.R * 255
        state.CustomFilter.tintG = preset.tint.G * 255
        state.CustomFilter.tintB = preset.tint.B * 255
        state.CustomFilter.saturation = preset.sat or 0
        state.CustomFilter.contrast = preset.con or 0
        state.CustomFilter.brightness = preset.bri or 0
        state.CustomFilter.exposure = preset.exp or 0
        state.CustomFilter.bloomIntensity = preset.bloomI or 0
        state.CustomFilter.bloomSize = preset.bloomS or 24
        state.CustomFilter.clockTime = preset.time or 14
        state.CustomFilter.dofIntensity = preset.dofI or 0
        state.CustomFilter.dofDistance = preset.dofD or 50
        
        core.Notify("Visuals", filterName, 2, "palette")
    else
        core.Notify("Visuals", "Filter not found: " .. filterName, 2, "circle-alert")
    end
end

-- ================================ RESET CUSTOM FX ================================
function Visuals.resetCustomFX(core, state)
    state.CustomFilter.tintR = 255; state.CustomFilter.tintG = 255; state.CustomFilter.tintB = 255
    state.CustomFilter.saturation = 0; state.CustomFilter.contrast = 0; state.CustomFilter.brightness = 0
    state.CustomFilter.exposure = 0; state.CustomFilter.bloomIntensity = 0; state.CustomFilter.bloomSize = 24
    state.CustomFilter.clockTime = 14; state.CustomFilter.dofIntensity = 0; state.CustomFilter.dofDistance = 50
    Visuals.applyCustomFilter(core, state)
    core.Notify("Visuals", "FX Reset", 2, "rotate-ccw")
end

-- ================================ GET PRESET LIST ================================
function Visuals.getPresetList()
    return {
        "Default", "Custom", "Mendung HD", "Cool Blue HD", "Soft Fade HD", "Adaptif Langit HD",
        "Edgy HD", "Full Bright HD", "Soft Pastel HD", "Cinematic Soft", "Ultra HD", "Realistic",
        "Night HD", "Senja", "Cinematic Film", "Golden Hour", "Moody Blue"
    }
end

return Visuals