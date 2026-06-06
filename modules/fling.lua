-- ================================ HARD FLING MODULE ================================
-- by @WTF.XKID | Full Hard Fling Engine dari script asli

local Fling = {}

function Fling.setup(core, state, runService)
    local hardFlingConn = nil
    local hardFlingRampConn = nil
    local hardFlingBAV = nil
    
    -- ================================ START HARD FLING ================================
    function Fling.start()
        if state.HardFling.active then return end
        
        state.HardFling.active = true
        state.Move.ncp = true  -- Aktifkan noclip otomatis
        state.HardFling.currentPower = 0
        state.HardFling.rampUpActive = true
        
        local hrp = core.Helpers.getRoot()
        if hrp then
            hardFlingBAV = Instance.new("BodyAngularVelocity", hrp)
            hardFlingBAV.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            hardFlingBAV.P = 100000
        end
        
        -- Ramp up power gradually
        local rampStart = tick()
        hardFlingRampConn = runService.Heartbeat:Connect(function()
            if not state.HardFling.rampUpActive then return end
            local t = math.clamp((tick() - rampStart) / 2, 0, 1)
            state.HardFling.currentPower = state.HardFling.power * t
            if t >= 1 then
                state.HardFling.currentPower = state.HardFling.power
                state.HardFling.rampUpActive = false
            end
        end)
        
        -- Main fling loop
        hardFlingConn = runService.Heartbeat:Connect(function()
            if not state.HardFling.active then return end
            
            local r = core.Helpers.getRoot()
            if not r then return end
            
            if state.HardFling.mode == "Spin" then
                if hardFlingBAV and hardFlingBAV.Parent then
                    hardFlingBAV.AngularVelocity = Vector3.new(0, state.HardFling.currentPower, 0)
                end
            elseif state.HardFling.mode == "Shake" then
                if hardFlingBAV and hardFlingBAV.Parent then
                    local shakeX = (math.random() - 0.5) * state.HardFling.currentPower * 0.5
                    local shakeY = (math.random() - 0.5) * state.HardFling.currentPower * 0.3
                    local shakeZ = (math.random() - 0.5) * state.HardFling.currentPower * 0.5
                    hardFlingBAV.AngularVelocity = Vector3.new(shakeX, shakeY, shakeZ)
                end
            end
            
            -- NoClip effect
            local char = core.Services.Players.LocalPlayer.Character
            if char then
                for _,p in pairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then
                        p.CanCollide = false
                    end
                end
            end
        end)
        
        core.Notify("Hard Fling", "ON — " .. state.HardFling.mode, 2, "zap")
    end
    
    -- ================================ STOP HARD FLING ================================
    function Fling.stop()
        if not state.HardFling.active then return end
        
        state.HardFling.active = false
        state.HardFling.rampUpActive = false
        state.HardFling.currentPower = 0
        
        if hardFlingConn then
            hardFlingConn:Disconnect()
            hardFlingConn = nil
        end
        
        if hardFlingRampConn then
            hardFlingRampConn:Disconnect()
            hardFlingRampConn = nil
        end
        
        if hardFlingBAV then
            hardFlingBAV:Destroy()
            hardFlingBAV = nil
        end
        
        -- Reset velocity
        local r = core.Helpers.getRoot()
        if r then
            pcall(function()
                r.AssemblyAngularVelocity = Vector3.zero
                r.AssemblyLinearVelocity = Vector3.zero
            end)
        end
        
        -- Reset noclip
        local char = core.Services.Players.LocalPlayer.Character
        if char then
            for _,p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.CanCollide = true
                end
            end
        end
        
        core.Notify("Hard Fling", "OFF", 1.5, "zap")
    end
    
    -- ================================ SET FLING MODE ================================
    function Fling.setMode(mode)
        state.HardFling.mode = mode
        core.Notify("Fling Mode", mode, 1.5, "rotate-cw")
    end
    
    -- ================================ SET FLING POWER ================================
    function Fling.setPower(power)
        state.HardFling.power = power
        core.Notify("Fling Power", power, 1.5, "zap")
    end
    
    -- ================================ TOGGLE FLING ================================
    function Fling.toggle()
        if state.HardFling.active then
            Fling.stop()
        else
            Fling.start()
        end
    end
    
    -- ================================ IS ACTIVE ================================
    function Fling.isActive()
        return state.HardFling.active
    end
    
    return Fling
end

return Fling