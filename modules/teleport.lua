-- ================================ TELEPORT MODULE ================================
-- by @WTF.XKID | Full Teleport Engine dari script asli

local Teleport = {}

-- ================================ SMART TP ================================
function Teleport.setupSmartTP(core, userInputService)
    local TeleportState = { clickConn = nil, clickActive = false, toolActive = false, tool = nil }
    
    local function executeTP()
        local hrp = core.Helpers.getRoot()
        if not hrp then return end
        local m = core.Services.Players.LocalPlayer:GetMouse()
        if m.Hit then
            hrp.CFrame = CFrame.new(m.Hit.Position + Vector3.new(0, 3.5, 0))
            hrp.AssemblyLinearVelocity = Vector3.zero
        end
    end
    
    function Teleport.toggleSmartTP(v)
        TeleportState.clickActive = v
        if v then
            pcall(function()
                local tool = Instance.new("Tool")
                tool.Name = "TP Tool"
                tool.RequiresHandle = false
                tool.Parent = core.Services.Players.LocalPlayer.Backpack
                TeleportState.tool = tool
                TeleportState.toolActive = false
                tool.Activated:Connect(function() TeleportState.toolActive = not TeleportState.toolActive end)
            end)
            TeleportState.clickConn = core.TrackConnection(userInputService.InputBegan:Connect(function(inp, gp)
                if gp then return end
                if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    if TeleportState.toolActive then
                        executeTP()
                        TeleportState.toolActive = false
                    end
                end
            end))
            core.Notify("Smart TP", "ON", 2, "map-pin")
        else
            if TeleportState.clickConn then TeleportState.clickConn:Disconnect() end
            if TeleportState.tool then TeleportState.tool:Destroy() end
            core.Notify("Smart TP", "OFF", 1.5, "map-pin")
        end
    end
    
    return Teleport
end

-- ================================ TARGET TELEPORT ================================
function Teleport.setupTargetTP(core, players)
    local function findPlayerByDisplay(str, currentLP)
        if str == "[Self]" then return currentLP end
        for _,p in pairs(players:GetPlayers()) do
            if p.DisplayName == str or p.Name == str then return p end
        end
        return nil
    end
    
    function Teleport.teleportToTarget(targetName)
        pcall(function()
            if targetName == "" then
                core.Notify("Teleport", "Input target!", 2, "circle-alert")
                return
            end
            local target = findPlayerByDisplay(targetName, core.Services.Players.LocalPlayer)
            if not target or not target.Parent or not target.Character then
                core.Notify("Teleport", "Invalid Target", 2, "circle-alert")
                return
            end
            local tHrp = core.Helpers.getCharRoot(target.Character)
            local myHrp = core.Helpers.getRoot()
            if not tHrp or not myHrp then return end
            myHrp.CFrame = tHrp.CFrame * CFrame.new(0, 0, 3) + Vector3.new(0, 2, 0)
            core.Notify("Teleport", target.DisplayName, 2, "map-pin")
        end)
    end
    
    return Teleport
end

-- ================================ AUTO WALK ================================
function Teleport.setupAutoWalk(state, core, runService, camera)
    function Teleport.startAutoWalk()
        runService:UnbindFromRenderStep("XKIDAutoWalk")
        state.Move.autoWalk = true
        local hum = core.Helpers.getHum()
        if hum then hum.WalkSpeed = state.Move.autoWalkSpeed end
        runService:BindToRenderStep("XKIDAutoWalk", Enum.RenderPriority.Character.Value + 1, function()
            if not state.Move.autoWalk then return end
            local hrp = core.Helpers.getRoot()
            local hum = core.Helpers.getHum()
            if not hrp or not hum then return end
            if hum.MoveDirection.Magnitude > 0.1 then return end
            local camDir = camera.CFrame.LookVector
            local moveDir = Vector3.new(camDir.X, 0, camDir.Z).Unit
            hrp.CFrame = hrp.CFrame + moveDir * (state.Move.autoWalkSpeed / 60)
        end)
        core.Notify("Auto Walk", "ON", 1.5, "play")
    end
    
    function Teleport.stopAutoWalk()
        runService:UnbindFromRenderStep("XKIDAutoWalk")
        state.Move.autoWalk = false
        local hum = core.Helpers.getHum()
        if hum then hum.WalkSpeed = state.Move.ws end
        core.Notify("Auto Walk", "OFF", 1.5, "play")
    end
    
    return Teleport
end

-- ================================ COORDINATES CACHE ================================
function Teleport.setupCoordCache(core)
    local SavedLocs = {}
    
    function Teleport.saveCoord(slot)
        local r = core.Helpers.getRoot()
        if not r then 
            core.Notify("Slot " .. slot, "Failed - No character", 1.5, "circle-alert")
            return false
        end
        SavedLocs[slot] = r.CFrame
        core.Notify("Slot " .. slot, "Saved", 1.5, "save")
        return true
    end
    
    function Teleport.loadCoord(slot)
        if not SavedLocs[slot] then
            core.Notify("Slot " .. slot, "Empty", 1.5, "save")
            return false
        end
        local r = core.Helpers.getRoot()
        if not r then return false end
        r.CFrame = SavedLocs[slot]
        core.Notify("Slot " .. slot, "Loaded", 1.5, "map-pin")
        return true
    end
    
    function Teleport.getSavedCoords()
        return SavedLocs
    end
    
    return Teleport
end

return Teleport