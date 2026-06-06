-- ================================ SPECTATOR MODULE ================================
-- by @WTF.XKID | Full Spectate & Self-Spectate Engine dari script asli

local Spectator = {}

-- ================================ SPECTATE ================================
function Spectator.setup(core, state, camera, userInputService, runService, onMobile)
    local Spec = {
        active = false, target = nil, mode = "third", dist = 8, origFov = 70,
        orbitYaw = 0, orbitPitch = 0, fpYaw = 0, fpPitch = 0, isSelf = false
    }
    
    local specConns = {}
    local specPan = Vector2.zero
    
    local function stopSpecLoop()
        runService:UnbindFromRenderStep("XKIDSpec")
    end
    
    local function stopSpecCapture()
        for _,c in ipairs(specConns) do c:Disconnect() end
        specConns = {}
        specPan = Vector2.zero
    end
    
    local function startSpecLoop()
        runService:BindToRenderStep("XKIDSpec", Enum.RenderPriority.Camera.Value + 1, function()
            if not Spec.active then return end
            pcall(function()
                local targetChar, targetHrp
                if Spec.isSelf then
                    targetChar = core.Services.Players.LocalPlayer.Character
                    targetHrp = core.Helpers.getCharRoot(targetChar)
                else
                    if not Spec.target or not Spec.target.Character then
                        Spec.active = false
                        stopSpecLoop()
                        stopSpecCapture()
                        camera.CameraType = Enum.CameraType.Custom
                        camera.FieldOfView = Spec.origFov
                        return
                    end
                    targetChar = Spec.target.Character
                    targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
                end
                if not targetHrp then
                    if not Spec.isSelf then
                        Spec.active = false
                        stopSpecLoop()
                        stopSpecCapture()
                        camera.CameraType = Enum.CameraType.Custom
                        camera.FieldOfView = Spec.origFov
                    end
                    return
                end
                camera.CameraType = Enum.CameraType.Scriptable
                local pan, sens = specPan, 0.3
                specPan = Vector2.zero
                if Spec.mode == "third" then
                    Spec.orbitYaw = Spec.orbitYaw + pan.X * sens
                    Spec.orbitPitch = math.clamp(Spec.orbitPitch + pan.Y * sens, -75, 75)
                    camera.CFrame = CFrame.new(
                        (CFrame.new(targetHrp.Position) * CFrame.Angles(0, math.rad(-Spec.orbitYaw), 0) * 
                         CFrame.Angles(math.rad(-Spec.orbitPitch), 0, 0) * CFrame.new(0, 0, Spec.dist)).Position,
                        targetHrp.Position + Vector3.new(0, 1, 0)
                    )
                else
                    local head = targetChar:FindFirstChild("Head")
                    local origin = head and head.Position or targetHrp.Position + Vector3.new(0, 1.5, 0)
                    Spec.fpYaw = Spec.fpYaw - pan.X * sens
                    Spec.fpPitch = math.clamp(Spec.fpPitch - pan.Y * sens, -85, 85)
                    camera.CFrame = CFrame.new(origin) * CFrame.Angles(0, math.rad(Spec.fpYaw), 0) * 
                                    CFrame.Angles(math.rad(Spec.fpPitch), 0, 0)
                end
            end)
        end)
    end
    
    local function startSpecCapture()
        -- Mouse drag untuk orbit
        table.insert(specConns, userInputService.InputChanged:Connect(function(inp)
            if not Spec.active then return end
            if inp.UserInputType == Enum.UserInputType.MouseMovement then
                Spec.orbitYaw = Spec.orbitYaw - inp.Delta.X * 0.5
                Spec.orbitPitch = math.clamp(Spec.orbitPitch - inp.Delta.Y * 0.5, -75, 75)
            end
        end))
        
        -- Touch support untuk mobile
        if onMobile then
            local specPinch, specPinchD, specTM = {}, nil, nil
            table.insert(specConns, userInputService.InputBegan:Connect(function(inp, gp)
                if gp or not Spec.active or inp.UserInputType ~= Enum.UserInputType.Touch then return end
                table.insert(specPinch, inp)
                specTM = #specPinch == 1 and inp or nil
            end))
            table.insert(specConns, userInputService.InputChanged:Connect(function(inp)
                if not Spec.active or inp.UserInputType ~= Enum.UserInputType.Touch then return end
                if #specPinch == 1 and inp == specTM then
                    specPan = specPan + Vector2.new(inp.Delta.X, inp.Delta.Y)
                elseif #specPinch >= 2 then
                    local d = (specPinch[1].Position - specPinch[2].Position).Magnitude
                    if specPinchD then
                        local diff = d - specPinchD
                        camera.FieldOfView = math.clamp(camera.FieldOfView - diff * 0.15, 10, 120)
                        if Spec.mode == "third" then
                            Spec.dist = math.clamp(Spec.dist - diff * 0.03, 3, 30)
                        end
                    end
                    specPinchD = d
                end
            end))
            table.insert(specConns, userInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType ~= Enum.UserInputType.Touch then return end
                for i,v in ipairs(specPinch) do
                    if v == inp then table.remove(specPinch, i); break end
                end
                specPinchD = nil
                specTM = #specPinch == 1 and specPinch[1] or nil
            end))
        end
    end
    
    function Spectator.toggle(v, target)
        if state.SelfSpec and state.SelfSpec.active then 
            if Spectator.toggleSelfSpec then Spectator.toggleSelfSpec(false) end
        end
        Spec.active = v
        if v then
            Spec.target = target
            Spec.isSelf = (target == core.Services.Players.LocalPlayer)
            if not Spec.target or (not Spec.isSelf and not Spec.target.Character) then
                Spec.active = false
                core.Notify("Error", "No target", 2, "circle-alert")
                return
            end
            Spec.origFov = camera.FieldOfView
            startSpecCapture()
            startSpecLoop()
            core.Notify("Spectator", "ON", 2, "eye")
        else
            stopSpecLoop()
            stopSpecCapture()
            camera.CameraType = Enum.CameraType.Custom
            camera.FieldOfView = Spec.origFov
            core.Notify("Spectator", "OFF", 1.5, "eye")
        end
    end
    
    function Spectator.setMode(isFirstPerson)
        Spec.mode = isFirstPerson and "first" or "third"
        core.Notify("Spectator", Spec.mode == "first" and "First Person" or "Third Person", 1.5, "eye")
    end
    
    function Spectator.setDistance(dist)
        Spec.dist = dist
    end
    
    function Spectator.getTargets()
        local t = { "[Self]" }
        for _,p in pairs(core.Services.Players:GetPlayers()) do 
            if p ~= core.Services.Players.LocalPlayer then 
                table.insert(t, p.DisplayName) 
            end 
        end
        return t
    end
    
    function Spectator.findTarget(str)
        if str == "[Self]" then return core.Services.Players.LocalPlayer end
        for _,p in pairs(core.Services.Players:GetPlayers()) do
            if p.DisplayName == str or p.Name == str then return p end
        end
        return nil
    end
    
    return Spectator
end

-- ================================ SELF-SPECTATE ================================
function Spectator.setupSelfSpectate(core, state, camera, userInputService, runService, onMobile)
    local SS = state.SelfSpec
    
    local ssPinch, ssPinchD, ssTM, ssPan = {}, nil, nil, Vector2.zero
    local ssConns = {}
    
    local function stopSSGesture()
        for _,c in ipairs(ssConns) do c:Disconnect() end
        ssConns = {}
        ssTM = nil; ssPinch = {}; ssPinchD = nil; ssPan = Vector2.zero
    end
    
    local function startSSGesture()
        table.insert(ssConns, userInputService.InputBegan:Connect(function(inp, gp)
            if gp or not SS.active or inp.UserInputType ~= Enum.UserInputType.Touch then return end
            table.insert(ssPinch, inp)
            ssTM = #ssPinch == 1 and inp or nil
        end))
        table.insert(ssConns, userInputService.InputChanged:Connect(function(inp)
            if not SS.active or inp.UserInputType ~= Enum.UserInputType.Touch then return end
            if #ssPinch == 1 and inp == ssTM then
                ssPan = ssPan + Vector2.new(inp.Delta.X, inp.Delta.Y)
            elseif #ssPinch >= 2 then
                local d = (ssPinch[1].Position - ssPinch[2].Position).Magnitude
                if ssPinchD then
                    local diff = d - ssPinchD
                    camera.FieldOfView = math.clamp(camera.FieldOfView - diff * 0.15, 10, 120)
                    SS.radius = math.clamp(SS.radius - diff * 0.03, 3, 30)
                end
                ssPinchD = d
            end
        end))
        table.insert(ssConns, userInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType ~= Enum.UserInputType.Touch then return end
            for i,v in ipairs(ssPinch) do
                if v == inp then table.remove(ssPinch, i); break end
            end
            ssPinchD = nil
            ssTM = #ssPinch == 1 and ssPinch[1] or nil
        end))
    end
    
    local function startSelfSpecLoop()
        runService:BindToRenderStep("XKIDSelfSpec", Enum.RenderPriority.Camera.Value + 1, function()
            if not SS.active then return end
            pcall(function()
                local targetChar = core.Services.Players.LocalPlayer.Character
                local targetHrp = core.Helpers.getCharRoot(targetChar)
                if not targetHrp then return end
                camera.CameraType = Enum.CameraType.Scriptable
                local pan, sens = ssPan, onMobile and 0.2 or 0.3
                ssPan = Vector2.zero
                if SS.mode == "First Person" then
                    local head = targetChar:FindFirstChild("Head")
                    local origin = head and head.Position or targetHrp.Position + Vector3.new(0, 1.5, 0)
                    SS.fpYaw = SS.fpYaw - pan.X * sens
                    SS.fpPitch = math.clamp(SS.fpPitch - pan.Y * sens, -85, 85)
                    camera.CFrame = CFrame.new(origin) * CFrame.Angles(0, math.rad(SS.fpYaw), 0) * 
                                    CFrame.Angles(math.rad(SS.fpPitch), 0, 0)
                else
                    if #ssPinch == 0 and pan.Magnitude < 0.01 then
                        local dt = 0.016
                        if SS.mode == "Slow Orbit" then
                            SS.orbitYaw = SS.orbitYaw + dt * 25 * SS.speed
                        elseif SS.mode == "Vertical Swing" then
                            SS.orbitPitch = 20 + math.sin(tick() * SS.speed * 1.5) * 40
                            SS.orbitYaw = SS.orbitYaw + dt * 10 * SS.speed
                        elseif SS.mode == "Figure 8" then
                            SS.orbitYaw = math.sin(tick() * SS.speed * 0.8) * 80
                            SS.orbitPitch = 20 + math.sin(tick() * SS.speed * 1.2) * 35
                        elseif SS.mode == "Cinematic Drift" then
                            SS.orbitYaw = SS.orbitYaw + dt * 15 * SS.speed
                            SS.orbitPitch = 20 + math.sin(tick() * SS.speed * 0.7) * 15
                        elseif SS.mode == "Top Down" then
                            SS.orbitPitch = -75
                            SS.orbitYaw = SS.orbitYaw + dt * 8 * SS.speed
                        end
                    end
                    SS.orbitYaw = SS.orbitYaw + pan.X * sens
                    SS.orbitPitch = math.clamp(SS.orbitPitch + pan.Y * sens, -75, 75)
                    local h = (SS.mode == "Top Down") and 15 or (SS.height or 3)
                    camera.CFrame = CFrame.new(
                        (CFrame.new(targetHrp.Position + Vector3.new(0, h, 0)) * 
                         CFrame.Angles(0, math.rad(-SS.orbitYaw), 0) * 
                         CFrame.Angles(math.rad(-SS.orbitPitch), 0, 0) * 
                         CFrame.new(0, 0, SS.radius)).Position,
                        targetHrp.Position + Vector3.new(0, h, 0)
                    )
                end
            end)
        end)
    end
    
    local function stopSelfSpecLoop()
        runService:UnbindFromRenderStep("XKIDSelfSpec")
        camera.CameraType = Enum.CameraType.Custom
        camera.FieldOfView = SS.origFov
        SS.active = false
        SS.orbitYaw = 0; SS.orbitPitch = 20; SS.fpYaw = 0; SS.fpPitch = 0
        SS.radius = 8; SS.height = 3; ssPan = Vector2.zero
    end
    
    function Spectator.toggleSelfSpec(v)
        if v then
            -- Matikan fitur lain yang konflik
            if state.Fly and state.Fly.active then
                if core.Modules and core.Modules.fly then
                    core.Modules.fly.stop(state, core)
                end
            end
            if state.Freecam and state.Freecam.active then
                if core.Modules and core.Modules.freecam then
                    core.Modules.freecam.stop(state, core, runService, camera)
                end
            end
            SS.active = true
            SS.origFov = camera.FieldOfView
            SS.orbitYaw = 0; SS.orbitPitch = 20; SS.fpYaw = 0; SS.fpPitch = 0
            SS.radius = SS.radius or 8; SS.height = SS.height or 3
            startSSGesture()
            startSelfSpecLoop()
            core.Notify("Self-Spectate", "ON — " .. (SS.mode or "Manual"), 2, "camera")
        else
            SS.active = false
            stopSSGesture()
            stopSelfSpecLoop()
            core.Notify("Self-Spectate", "OFF", 1.5, "camera")
        end
    end
    
    function Spectator.setSelfSpecMode(mode)
        SS.mode = mode
        core.Notify("Self-Spec", "Mode: " .. mode, 1.5, "camera")
    end
    
    function Spectator.setSelfSpecRadius(radius)
        SS.radius = radius
    end
    
    function Spectator.setSelfSpecHeight(height)
        SS.height = height
    end
    
    function Spectator.setSelfSpecSpeed(speed)
        SS.speed = speed
    end
    
    return Spectator
end

return Spectator