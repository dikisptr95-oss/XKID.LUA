-- ================================ FREECAM MODULE ================================
-- by @WTF.XKID | Full Freecam Engine dari script asli

local Freecam = {}

function Freecam.toggle(active, state, core, runService, userInputService, camera)
    if not active then
        -- MATIKAN FREECAM
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
    
    -- NYALAKAN FREECAM
    if state.Freecam then
        -- Bersihkan dulu jika sudah ada
        runService:UnbindFromRenderStep("XKIDFreecam")
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
    
    -- Variabel lokal
    local I_CamVel, I_YawVel, I_PitchVel, I_RollVel, heightVelocity = Vector3.zero, 0, 0, 0, 0
    local fcMoveTouch, fcMoveSt, fcJoy = nil, nil, Vector2.zero
    local fcRotTouch, fcRotLast = nil, nil
    local fcKeysHeld = {}
    local fcConns = {}
    
    -- UI Buttons untuk freecam (akan dibuat oleh ui.lua nanti)
    -- Di sini kita hanya siapkan fungsi, UI button akan diintegrasikan di ui.lua
    local FC_UI_Btns = { up = false, down = false, rollLeft = false, rollRight = false, zoomIn = false, zoomOut = false }
    
    -- ================================ FREECAM CAPTURE ================================
    local function startFreecamCapture()
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
        
        table.insert(fcConns, userInputService.InputChanged:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseMovement and state.Freecam._mouseRot then
                I_YawVel = I_YawVel - inp.Delta.X * state.Freecam.sens * 120
                I_PitchVel = I_PitchVel - inp.Delta.Y * state.Freecam.sens * 120
            end
        end))
        
        -- Touch support
        table.insert(fcConns, userInputService.InputBegan:Connect(function(inp, gp)
            if gp or inp.UserInputType ~= Enum.UserInputType.Touch then return end
            if inp.Position.X > camera.ViewportSize.X / 2 then
                if not fcRotTouch then
                    fcRotTouch = inp
                    fcRotLast = inp.Position
                end
            else
                if not fcMoveTouch then
                    fcMoveTouch = inp
                    fcMoveSt = inp.Position
                    fcJoy = Vector2.zero
                end
            end
        end))
        
        table.insert(fcConns, userInputService.TouchMoved:Connect(function(inp)
            if inp == fcRotTouch and fcRotLast then
                local dx = inp.Position.X - fcRotLast.X
                local dy = inp.Position.Y - fcRotLast.Y
                fcRotLast = inp.Position
                I_YawVel = I_YawVel - dx * state.Freecam.sens * 80
                I_PitchVel = I_PitchVel - dy * state.Freecam.sens * 80
            end
            if inp == fcMoveTouch and fcMoveSt then
                local dx = inp.Position.X - fcMoveSt.X
                local dy = inp.Position.Y - fcMoveSt.Y
                local function ad(v,d,m)
                    if math.abs(v) < d then return 0 end
                    return math.clamp((v - math.sign(v) * d) / (m - d), -1, 1)
                end
                fcJoy = Vector2.new(ad(dx, 15, 70), ad(dy, 15, 70))
            end
        end))
        
        table.insert(fcConns, userInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType ~= Enum.UserInputType.Touch then return end
            if inp == fcRotTouch then
                fcRotTouch = nil
                fcRotLast = nil
            end
            if inp == fcMoveTouch then
                fcMoveTouch = nil
                fcMoveSt = nil
                fcJoy = Vector2.zero
            end
        end))
    end
    
    local function stopFreecamCapture()
        for _,c in ipairs(fcConns) do c:Disconnect() end
        fcConns = {}
        fcKeysHeld = {}
        state.Freecam._mouseRot = false
        userInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
    
    -- ================================ FREECAM LOOP ================================
    local function startFreecamLoop()
        runService:BindToRenderStep("XKIDFreecam", Enum.RenderPriority.Camera.Value + 1, function(dt)
            if not state.Freecam.active then return end
            camera.CameraType = Enum.CameraType.Scriptable
            local safeDt = math.clamp(dt, 0.001, 0.05)
            
            I_YawVel = I_YawVel * math.max(0, 1 - safeDt * 14)
            I_PitchVel = I_PitchVel * math.max(0, 1 - safeDt * 14)
            state.Freecam.yawDeg = state.Freecam.yawDeg + I_YawVel * safeDt
            state.Freecam.pitchDeg = math.clamp(state.Freecam.pitchDeg + I_PitchVel * safeDt, -80, 80)
            
            local rollTarget = 0
            if FC_UI_Btns.rollLeft then rollTarget = -100
            elseif FC_UI_Btns.rollRight then rollTarget = 100 end
            I_RollVel = I_RollVel + (rollTarget - I_RollVel) * math.clamp(safeDt * 5, 0, 1)
            state.Freecam.rollDeg = math.clamp(state.Freecam.rollDeg + I_RollVel * safeDt, -100, 100)
            
            local camCF = CFrame.new(state.Freecam.pos) * CFrame.Angles(0, math.rad(state.Freecam.yawDeg), 0) * CFrame.Angles(math.rad(state.Freecam.pitchDeg), 0, 0)
            
            local joyX, joyY = fcJoy.X, fcJoy.Y
            if not (userInputService.KeyboardEnabled == false) then
                if fcKeysHeld[Enum.KeyCode.W] then joyY = joyY - 1 end
                if fcKeysHeld[Enum.KeyCode.S] then joyY = joyY + 1 end
                if fcKeysHeld[Enum.KeyCode.D] then joyX = joyX + 1 end
                if fcKeysHeld[Enum.KeyCode.A] then joyX = joyX - 1 end
            end
            
            local rawMove = Vector2.new(joyX, joyY)
            if rawMove.Magnitude > 1 then rawMove = rawMove.Unit end
            I_CamVel = I_CamVel:Lerp((camCF.LookVector * (-rawMove.Y) + camCF.RightVector * rawMove.X) * (state.Freecam.speed * 60), math.clamp(safeDt * 3.5, 0, 1))
            
            local heightTarget = 0
            if fcKeysHeld[Enum.KeyCode.E] or FC_UI_Btns.up then heightTarget = state.Freecam.speed * 60 end
            if fcKeysHeld[Enum.KeyCode.Q] or FC_UI_Btns.down then heightTarget = -state.Freecam.speed * 60 end
            
            if heightTarget == 0 then
                heightVelocity = heightVelocity * math.max(0, 1 - safeDt * 10)
            else
                heightVelocity = heightVelocity + (heightTarget - heightVelocity) * math.clamp(safeDt * 3, 0, 1)
            end
            
            if FC_UI_Btns.zoomIn then camera.FieldOfView = math.clamp(camera.FieldOfView - 1.2, 10, 120) end
            if FC_UI_Btns.zoomOut then camera.FieldOfView = math.clamp(camera.FieldOfView + 1.2, 10, 120) end
            
            state.Freecam.pos = state.Freecam.pos + (I_CamVel + Vector3.new(0, heightVelocity, 0)) * safeDt
            camera.CFrame = CFrame.new(state.Freecam.pos) * CFrame.Angles(0, math.rad(state.Freecam.yawDeg), 0) * CFrame.Angles(math.rad(state.Freecam.pitchDeg), 0, 0) * CFrame.Angles(0, 0, math.rad(state.Freecam.rollDeg))
        end)
    end
    
    startFreecamCapture()
    startFreecamLoop()
    
    -- Simpan referensi ke UI buttons agar bisa diakses dari ui.lua
    state.Freecam.UIButtons = FC_UI_Btns
    state.Freecam.stopCapture = stopFreecamCapture
    state.Freecam.stopLoop = function()
        runService:UnbindFromRenderStep("XKIDFreecam")
        stopFreecamCapture()
    end
    
    core.Notify("Freecam", "ON", 2, "video")
end

-- Fungsi untuk stop freecam dari luar
function Freecam.stop(state, core, runService, camera)
    if state.Freecam and state.Freecam.active then
        if state.Freecam.stopLoop then state.Freecam.stopLoop() end
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
        state.Freecam.active = false
        core.Notify("Freecam", "OFF", 1.5, "video")
    end
end

return Freecam