-- ================================ FREECAM MODULE ================================
-- by @WTF.XKID

local Freecam = {}

function Freecam.toggle(active, state, core, runService, userInputService, camera)
    if not active then
        if state.Freecam then
            runService:UnbindFromRenderStep("XKIDFreecam")
            camera.CameraType = Enum.CameraType.Custom
            if state.Freecam.wasAnchored then
                local hrp = core.Helpers.getRoot()
                if hrp then hrp.Anchored = false end
            end
            local hum = core.Helpers.getHum()
            if hum then
                hum.WalkSpeed = state.Freecam.savedWalkSpeed or 16
                hum.JumpPower = state.Freecam.savedJumpPower or 50
            end
            camera.FieldOfView = state.Freecam.origFov or 70
        end
        core.Notify("Freecam", "OFF", 1.5, "video")
        return
    end
    
    state.Freecam = state.Freecam or {}
    state.Freecam.active = true
    state.Freecam.pos = camera.CFrame.Position
    state.Freecam.yawDeg = 0
    state.Freecam.pitchDeg = 0
    state.Freecam.rollDeg = 0
    state.Freecam.speed = state.Freecam.speed or 3
    state.Freecam.sens = state.Freecam.sens or 0.25
    
    local hum = core.Helpers.getHum()
    local hrp = core.Helpers.getRoot()
    if hum then
        state.Freecam.savedWalkSpeed = hum.WalkSpeed
        state.Freecam.savedJumpPower = hum.JumpPower
        hum.WalkSpeed = 0
        hum.JumpPower = 0
    end
    if hrp then
        hrp.Anchored = true
        state.Freecam.wasAnchored = true
    end
    state.Freecam.origFov = camera.FieldOfView
    
    local fcKeysHeld = {}
    local I_CamVel, I_YawVel, I_PitchVel, I_RollVel, heightVelocity = Vector3.zero, 0, 0, 0, 0
    local fcConns = {}
    
    table.insert(fcConns, userInputService.InputBegan:Connect(function(inp, gp)
        if gp then return end
        fcKeysHeld[inp.KeyCode] = true
        if inp.UserInputType == Enum.UserInputType.MouseButton2 then
            state.Freecam._mouseRot = true
            userInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
        end
    end))
    table.insert(fcConns, userInputService.InputEnded:Connect(function(inp)
        fcKeysHeld[inp.KeyCode] = false
        if inp.UserInputType == Enum.UserInputType.MouseButton2 then
            state.Freecam._mouseRot = false
            userInputService.MouseBehavior = Enum.MouseBehavior.Default
        end
    end))
    
    runService:BindToRenderStep("XKIDFreecam", Enum.RenderPriority.Camera.Value + 1, function(dt)
        if not state.Freecam.active then return end
        camera.CameraType = Enum.CameraType.Scriptable
        local safeDt = math.clamp(dt, 0.001, 0.05)
        
        if state.Freecam._mouseRot then
            local delta = userInputService:GetMouseDelta()
            state.Freecam.yawDeg = state.Freecam.yawDeg - delta.X * state.Freecam.sens
            state.Freecam.pitchDeg = math.clamp(state.Freecam.pitchDeg - delta.Y * state.Freecam.sens, -80, 80)
        end
        
        local move = Vector3.zero
        if fcKeysHeld[Enum.KeyCode.W] then move = move - Vector3.new(0,0,1) end
        if fcKeysHeld[Enum.KeyCode.S] then move = move + Vector3.new(0,0,1) end
        if fcKeysHeld[Enum.KeyCode.D] then move = move + Vector3.new(1,0,0) end
        if fcKeysHeld[Enum.KeyCode.A] then move = move - Vector3.new(1,0,0) end
        if fcKeysHeld[Enum.KeyCode.E] then move = move + Vector3.new(0,1,0) end
        if fcKeysHeld[Enum.KeyCode.Q] then move = move - Vector3.new(0,1,0) end
        
        if move.Magnitude > 0 then move = move.Unit * state.Freecam.speed * 60 end
        state.Freecam.pos = state.Freecam.pos + CFrame.new(state.Freecam.pos) * move * safeDt
        camera.CFrame = CFrame.new(state.Freecam.pos) * CFrame.Angles(0, math.rad(state.Freecam.yawDeg), 0) * CFrame.Angles(math.rad(state.Freecam.pitchDeg), 0, 0)
    end)
    
    core.Notify("Freecam", "ON", 2, "video")
end

return Freecam