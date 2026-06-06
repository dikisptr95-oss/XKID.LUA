-- ================================ FLY MODULE ================================
-- by @WTF.XKID | Full Fly Engine dari script asli

local Fly = {}

function Fly.toggle(active, state, core, runService, userInputService, camera, onMobile)
    if not active then
        -- MATIKAN FLY
        state.Fly.active = false
        if state.Fly.bv then state.Fly.bv:Destroy() end
        if state.Fly.bg then state.Fly.bg:Destroy() end
        state.Fly.bv = nil
        state.Fly.bg = nil
        
        local hum = core.Helpers.getHum()
        if hum then
            hum.PlatformStand = false
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            hum.WalkSpeed = state.Move.ws
            hum.UseJumpPower = true
            hum.JumpPower = state.Move.jp
        end
        
        core.Notify("Fly", "OFF", 1.5, "bird")
        return
    end
    
    -- NYALAKAN FLY
    local hrp = core.Helpers.getRoot()
    local hum = core.Helpers.getHum()
    if not hrp or not hum then return end
    
    state.Fly.active = true
    hum.PlatformStand = true
    
    -- Variabel lokal untuk fly
    local flyVel = Vector3.zero
    local flyMoveTouch, flyMoveSt, flyJoy = nil, nil, Vector2.zero
    local flyConns = {}
    local keysHeld = {}
    
    -- ================================ FLY CONTROLS ================================
    -- Keyboard PC
    local function startFlyCapture()
        table.insert(flyConns, userInputService.InputBegan:Connect(function(inp, gp)
            if gp then return end
            local k = inp.KeyCode
            if k == Enum.KeyCode.W or k == Enum.KeyCode.A or k == Enum.KeyCode.S or k == Enum.KeyCode.D or k == Enum.KeyCode.E or k == Enum.KeyCode.Q then
                keysHeld[k] = true
            end
        end))
        
        table.insert(flyConns, userInputService.InputEnded:Connect(function(inp)
            keysHeld[inp.KeyCode] = nil
        end))
        
        -- Touch mobile
        if onMobile then
            table.insert(flyConns, userInputService.InputBegan:Connect(function(inp, gp)
                if gp or inp.UserInputType ~= Enum.UserInputType.Touch then return end
                if inp.Position.X <= camera.ViewportSize.X / 2 then
                    if not flyMoveTouch then
                        flyMoveTouch = inp
                        flyMoveSt = inp.Position
                    end
                end
            end))
            
            table.insert(flyConns, userInputService.TouchMoved:Connect(function(inp)
                if inp == flyMoveTouch and flyMoveSt then
                    local dx = inp.Position.X - flyMoveSt.X
                    local dy = inp.Position.Y - flyMoveSt.Y
                    local function ad(v,d,m)
                        if math.abs(v) < d then return 0 end
                        return math.clamp((v - math.sign(v) * d) / (m - d), -1, 1)
                    end
                    flyJoy = Vector2.new(ad(dx, 25, 80), ad(dy, 20, 80))
                end
            end))
            
            table.insert(flyConns, userInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType ~= Enum.UserInputType.Touch then return end
                if inp == flyMoveTouch then
                    flyMoveTouch = nil
                    flyMoveSt = nil
                    flyJoy = Vector2.zero
                end
            end))
        end
        
        state.Fly._keys = keysHeld
    end
    
    local function stopFlyCapture()
        for _,c in ipairs(flyConns) do c:Disconnect() end
        flyConns = {}
        flyMoveTouch = nil
        flyMoveSt = nil
        flyJoy = Vector2.zero
        state.Fly._keys = {}
    end
    
    -- Buat BodyVelocity dan BodyGyro
    state.Fly.bv = Instance.new("BodyVelocity", hrp)
    state.Fly.bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    
    state.Fly.bg = Instance.new("BodyGyro", hrp)
    state.Fly.bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    state.Fly.bg.P = 50000
    
    startFlyCapture()
    
    -- Fungsi deteksi ground
    local function isOnGround()
        local r = core.Helpers.getRoot()
        if not r then return false end
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = { core.Services.Players.LocalPlayer.Character }
        return workspace:Raycast(r.Position, Vector3.new(0, -5, 0), params) ~= nil
    end
    
    -- Render loop fly
    runService:BindToRenderStep("XKIDFly", Enum.RenderPriority.Camera.Value + 1, function()
        if not state.Fly.active then return end
        local r = core.Helpers.getRoot()
        if not r then return end
        
        local camCF = camera.CFrame
        local spd = state.Move.flyS
        local move = Vector3.zero
        local keys = state.Fly._keys or {}
        
        if onMobile then
            move = camCF.LookVector * (-flyJoy.Y) + camCF.RightVector * flyJoy.X
        else
            if keys[Enum.KeyCode.W] then move = move + camCF.LookVector end
            if keys[Enum.KeyCode.S] then move = move - camCF.LookVector end
            if keys[Enum.KeyCode.D] then move = move + camCF.RightVector end
            if keys[Enum.KeyCode.A] then move = move - camCF.RightVector end
            if keys[Enum.KeyCode.E] then move = move + Vector3.new(0,1,0) end
            if keys[Enum.KeyCode.Q] then move = move - Vector3.new(0,1,0) end
        end
        
        if move.Magnitude > 0 then
            flyVel = flyVel:Lerp(move.Unit * spd, 0.15)
        else
            flyVel = flyVel:Lerp(isOnGround() and Vector3.zero or Vector3.new(0, -0.8, 0), 0.08)
        end
        
        if state.Fly.bv and state.Fly.bv.Parent then
            state.Fly.bv.Velocity = flyVel
        end
        if state.Fly.bg and state.Fly.bg.Parent then
            state.Fly.bg.CFrame = CFrame.new(r.Position, r.Position + camCF.LookVector)
        end
    end)
    
    core.Notify("Fly", "ON", 2, "bird")
end

-- Fungsi untuk stop fly dari luar
function Fly.stop(state, core)
    if state.Fly.active then
        state.Fly.active = false
        if state.Fly.bv then state.Fly.bv:Destroy() end
        if state.Fly.bg then state.Fly.bg:Destroy() end
        state.Fly.bv = nil
        state.Fly.bg = nil
        
        local hum = core.Helpers.getHum()
        if hum then
            hum.PlatformStand = false
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            hum.WalkSpeed = state.Move.ws
            hum.UseJumpPower = true
            hum.JumpPower = state.Move.jp
        end
        
        core.Notify("Fly", "OFF", 1.5, "bird")
    end
end

return Fly