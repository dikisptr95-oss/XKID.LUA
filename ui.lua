-- ================================ XKID UI ================================
-- by @WTF.XKID | Full UI Window dan semua Tab dari script asli

local UI = {}

function UI.create(core, modules)
    -- ================================ LOAD WINDUI ================================
    local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/refs/heads/main/dist/main.lua"))()
    core.WindUI = WindUI
    
    -- Override notify
    core.Notify = function(title, content, duration, icon)
        pcall(function() 
            WindUI:Notify({ Title = title, Content = content, Duration = duration or 2, Icon = icon or "bell" })
        end)
    end
    
    -- Simpan modules ke core agar bisa diakses dari fungsi lain
    core.Modules = modules
    
    -- ================================ CLEANUP ================================
    core.Cleanup()
    
    -- ================================ STATE ALIAS ================================
    local State = core.State
    local LP = core.Services.Players.LocalPlayer
    local Camera = workspace.CurrentCamera
    local onMobile = not core.Services.UserInputService.KeyboardEnabled
    
    -- ================================ VARIABLES GLOBAL ================================
    local START_TIME = os.time()
    local sharedFPS = 60
    local sharedPing = 0
    
    -- FPS & PING TRACKER
    core.TrackConnection(core.Services.RunService.RenderStepped:Connect(function(dt) 
        if dt > 0 then sharedFPS = math.floor(1 / dt) end 
    end))
    
    task.spawn(function()
        while getgenv()._XKID_RUNNING do
            task.wait(1)
            pcall(function()
                local item = core.Services.StatsService.Network.ServerStatsItem["Data Ping"]
                if item then sharedPing = math.floor(item:GetValue()) end
            end)
        end
    end)
    
    task.spawn(function()
        while getgenv()._XKID_RUNNING do
            pcall(function()
                if tick() - core.LastMapCheck > 30 or not core.CachedMapName then
                    core.CachedMapName = core.Services.MarketplaceService:GetProductInfo(game.PlaceId).Name
                    core.LastMapCheck = tick()
                end
            end)
            task.wait(5)
        end
    end)
    
    -- ================================ MAIN WINDOW ================================
    local Window = WindUI:CreateWindow({
        Title = "XKID HUB V2.0", 
        Icon = "bluetooth", 
        Author = "@WTF.XKID", 
        Folder = "XKIDHub",
        Size = UDim2.fromOffset(360, 320), 
        Transparent = true, 
        Theme = "Crimson", 
        SideBarWidth = 160,
        User = { Enabled = true, Anonymous = false }, 
        Topbar = { Height = 40, ButtonsType = "Default" },
    })
    
    pcall(function() WindUI:SetFont("rbxassetid://12187376357") end)
    pcall(function() WindUI:SetNotificationLower(true) end)
    pcall(function() Window.User:SetDisplayName(LP.DisplayName); Window.User:SetUsername("@" .. LP.Name) end)
    
    Window:EditOpenButton({
        Title = "XKID V2.0", 
        Icon = "github", 
        CornerRadius = UDim.new(1, 0),
        StrokeThickness = 2, 
        StrokeColor = Color3.fromRGB(255, 70, 120),
        Enabled = true, 
        Draggable = true, 
        Scale = 0.72,
    })
    
    -- FPS Tag
    local FpsTag = Window:Tag({ Title = "FPS: -- | Ping: --", Color = Color3.fromRGB(255, 215, 0), Icon = "github" })
    task.spawn(function()
        while getgenv()._XKID_RUNNING do
            task.wait(1)
            if FpsTag and FpsTag.SetTitle then
                FpsTag:SetTitle("FPS: " .. sharedFPS .. " | Ping: " .. sharedPing .. "ms")
            end
        end
    end)
    
    -- ================================ TAB: INFORMASI ================================
    local TabInfo = Window:Tab({ Title = "Informasi", Icon = "activity" })
    
    local function getExecutor()
        pcall(function() local e = identifyexecutor(); if e and e ~= "" then return e end end)
        pcall(function() local e = getexecutorname(); if e and e ~= "" then return e end end)
        return core.Executor.name
    end
    
    local execName = getExecutor()
    local accountAge = LP.AccountAge .. " days"
    local avatarImage = "rbxthumb://type=AvatarHeadShot&id=" .. LP.UserId .. "&w=420&h=420"
    
    local afkStatusParagraph = TabInfo:Paragraph({
        Title = "YooWssp!!, " .. LP.DisplayName,
        Desc = "Executor: " .. execName .. "\nAccount Age: " .. accountAge .. "\nUserID: " .. LP.UserId .. "\nStatus: " .. (LP.MembershipType == Enum.MembershipType.Premium and "Premium" or "Normal") .. "\nAnti AFK: ON ✅",
        Image = avatarImage,
        ImageSize = 80
    })
    
    task.spawn(function()
        while getgenv()._XKID_RUNNING do
            task.wait(1)
            pcall(function()
                afkStatusParagraph:SetDesc("Executor: " .. execName .. "\nAccount Age: " .. accountAge .. "\nUserID: " .. LP.UserId .. "\nStatus: " .. (LP.MembershipType == Enum.MembershipType.Premium and "Premium" or "Normal") .. "\nAnti AFK: " .. (State.Security.afkActive and "ON ✅" or "OFF ❌"))
            end)
        end
    end)
    
    local infoParagraph = TabInfo:Paragraph({
        Title = "💀 " .. LP.DisplayName .. "\n⚡ " .. core.Helpers.makeBar(sharedFPS, 120, 10) .. " " .. sharedFPS .. " FPS\n📡 " .. core.Helpers.makeBar(math.max(1, 200 - sharedPing), 200, 10) .. " " .. sharedPing .. "ms\n🕐 " .. core.Helpers.makeBar(os.difftime(os.time(), START_TIME) % 3600, 3600, 10) .. " " .. core.Helpers.formatTime(os.difftime(os.time(), START_TIME)),
        Desc = "👤 " .. LP.DisplayName .. "\n📱 " .. (onMobile and "Mobile" or "PC") .. " | 🚀 " .. execName .. "\n\n🎮 " .. (core.CachedMapName or "Loading...") .. "\n👥 " .. core.Helpers.makeBar(#core.Services.Players:GetPlayers(), core.Services.Players.MaxPlayers, 10) .. " " .. #core.Services.Players:GetPlayers() .. "/" .. core.Services.Players.MaxPlayers .. " Players\n\n🌐 discord.gg/bzumc2u96"
    })
    
    task.spawn(function()
        while getgenv()._XKID_RUNNING do
            task.wait(1)
            pcall(function()
                infoParagraph:SetTitle("💀 " .. LP.DisplayName .. "\n⚡ " .. core.Helpers.makeBar(sharedFPS, 120, 10) .. " " .. sharedFPS .. " FPS\n📡 " .. core.Helpers.makeBar(math.max(1, 200 - sharedPing), 200, 10) .. " " .. sharedPing .. "ms\n🕐 " .. core.Helpers.makeBar(os.difftime(os.time(), START_TIME) % 3600, 3600, 10) .. " " .. core.Helpers.formatTime(os.difftime(os.time(), START_TIME)))
            end)
        end
    end)
    
    TabInfo:Section({ Title = "🔗 Discord", Icon = "message-circle", Box = true }):Button({
        Title = "Copy Discord Link",
        Desc = "discord.gg/bzumc2u96",
        Callback = function()
            pcall(function() setclipboard("https://discord.gg/bzumc2u96") end)
            core.Notify("System", "Link copied", 2, "copy")
        end
    })
    
    -- ================================ TAB: CHARACTER ================================
    local TabChar = Window:Tab({ Title = "Character", Icon = "fingerprint" })
    
    -- Refresh Character
    local function refreshCharacter()
        if State.Avatar.isRefreshing then return end
        local char = LP.Character
        local hrp = core.Helpers.getRoot()
        if not char or not hrp then
            core.Notify("Error", "Character not found", 2, "circle-alert")
            return
        end
        State.Avatar.isRefreshing = true
        local pendingRefreshCF = hrp.CFrame
        local pendingRefreshWS = State.Move.ws
        local pendingRefreshJP = State.Move.jp
        local pendingRefreshZoom = LP.CameraMaxZoomDistance
        core.Notify("Refresh", "Reloading...", 1.5, "refresh-cw")
        pcall(function() char:BreakJoints() end)
        local waited = 0
        repeat
            task.wait(0.1)
            waited = waited + 0.1
        until not LP.Character or waited > 2
        if LP.Character then
            pcall(function() LP.Character:Destroy() end)
            task.wait(0.3)
        end
        if not LP.Character then
            pcall(function() LP:LoadCharacter() end)
        end
        task.delay(12, function()
            if State.Avatar.isRefreshing then
                State.Avatar.isRefreshing = false
                core.Notify("Error", "Refresh timeout", 3, "circle-alert")
            end
        end)
        
        core.TrackConnection(LP.CharacterAdded:Connect(function(newChar)
            if not State.Avatar.isRefreshing then return end
            task.wait(0.3)
            local newHrp = newChar:FindFirstChild("HumanoidRootPart") or newChar:WaitForChild("HumanoidRootPart", 8)
            local newHum = newChar:FindFirstChildOfClass("Humanoid") or newChar:WaitForChild("Humanoid", 8)
            if newHrp and newHum then
                repeat task.wait() until newHum.Health > 0 and newHrp:IsDescendantOf(workspace)
                newHrp.CFrame = pendingRefreshCF + Vector3.new(0, 4, 0)
                newHrp.AssemblyLinearVelocity = Vector3.zero
                newHrp.AssemblyAngularVelocity = Vector3.zero
                newHum.WalkSpeed = pendingRefreshWS
                newHum.UseJumpPower = true
                newHum.JumpPower = pendingRefreshJP
                Camera.CameraSubject = newHum
                Camera.CameraType = Enum.CameraType.Custom
                pcall(function() LP.CameraMaxZoomDistance = pendingRefreshZoom end)
                core.Notify("Refresh", "Done", 2, "check-circle")
            end
            State.Avatar.isRefreshing = false
        end))
    end
    
    TabChar:Button({ Title = "Refresh Character 🔄", Desc = "Reload character like /re — no gamepass", Callback = refreshCharacter })
    
    -- Movement Section
    local secMov = TabChar:Section({ Title = "Movement", Icon = "activity", Box = true })
    secMov:Slider({ Title = "Walk Speed", Step = 1, Value = { Min = 16, Max = 500, Default = 16 }, Callback = function(v) 
        State.Move.ws = v
        local h = core.Helpers.getHum()
        if h then h.WalkSpeed = v end
    end})
    secMov:Slider({ Title = "Jump Power", Step = 1, Value = { Min = 50, Max = 500, Default = 50 }, Callback = function(v) 
        State.Move.jp = v
        local h = core.Helpers.getHum()
        if h then h.UseJumpPower = true; h.JumpPower = v end
    end})
    
    -- Infinite Jump
    local infJumpConn = nil
    secMov:Toggle({ Title = "Infinite Jump", Default = false, Callback = function(v)
        if v then
            infJumpConn = core.TrackConnection(core.Services.UserInputService.JumpRequest:Connect(function()
                local h = core.Helpers.getHum()
                if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
            end))
        else
            if infJumpConn then infJumpConn:Disconnect(); infJumpConn = nil end
        end
        core.Notify("Infinite Jump", v and "ON" or "OFF", 1.5, "arrow-big-up")
    end})
    
    -- Auto Walk
    local secAutoWalk = TabChar:Section({ Title = "Auto Walk", Icon = "play", Box = true })
    local autoWalkActive = false
    secAutoWalk:Toggle({ Title = "Auto Walk", Default = false, Callback = function(v)
        autoWalkActive = v
        if modules.teleport then
            if v then modules.teleport.startAutoWalk() else modules.teleport.stopAutoWalk() end
        else
            core.Notify("Auto Walk", v and "ON" or "OFF", 1.5, "play")
        end
    end})
    secAutoWalk:Slider({ Title = "Walk Speed", Step = 1, Value = { Min = 1, Max = 100, Default = 16 }, Callback = function(v)
        State.Move.autoWalkSpeed = v
        if autoWalkActive then
            local hum = core.Helpers.getHum()
            if hum then hum.WalkSpeed = v end
        end
    end})
    secAutoWalk:Paragraph({ Title = "Info", Desc = "Character walks forward automatically\nMove manually to override" })
    
    -- Abilities Section (Fly)
    local secAbi = TabChar:Section({ Title = "Abilities", Icon = "zap", Box = true })
    local flyToggle = false
    secAbi:Toggle({ Title = "Fly", Default = false, Callback = function(v)
        flyToggle = v
        if modules.fly then
            modules.fly.toggle(v, State, core, core.Services.RunService, core.Services.UserInputService, Camera, onMobile)
        else
            core.Notify("Fly", v and "ON (Demo)" or "OFF", 1.5, "bird")
        end
    end})
    secAbi:Slider({ Title = "Fly Speed", Step = 1, Value = { Min = 10, Max = 300, Default = 60 }, Callback = function(v) 
        State.Move.flyS = v 
    end})
    
    -- NoClip
    local noclipConn = nil
    secAbi:Toggle({ Title = "NoClip", Default = false, Callback = function(v)
        State.Move.ncp = v
        if v then
            if not noclipConn then
                noclipConn = core.TrackConnection(core.Services.RunService.Heartbeat:Connect(function()
                    if not State.Move.ncp then return end
                    local char = LP.Character
                    if char then
                        for _,p in pairs(char:GetDescendants()) do
                            if p:IsA("BasePart") then p.CanCollide = false end
                        end
                    end
                end))
            end
        else
            if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
            local char = LP.Character
            if char then
                for _,p in pairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = true end
                end
            end
        end
        core.Notify("NoClip", v and "ON" or "OFF", 1.5, "ghost")
    end})
    
    -- Hard Fling Section
    local secFling = TabChar:Section({ Title = "Hard Fling (Safe)", Icon = "rotate-cw", Box = true })
    secFling:Toggle({ Title = "Hard Fling", Default = false, Callback = function(v)
        if modules.fling then
            if v then modules.fling.start() else modules.fling.stop() end
        else
            core.Notify("Hard Fling", v and "ON (Demo)" or "OFF", 1.5, "zap")
        end
    end})
    secFling:Dropdown({ Title = "Fling Mode", Values = { "Spin", "Shake" }, Default = "Spin", Callback = function(v) 
        State.HardFling.mode = v
        if modules.fling then modules.fling.setMode(v) end
        core.Notify("Fling Mode", v, 1.5, "rotate-cw")
    end})
    secFling:Slider({ Title = "Fling Power", Step = 500, Value = { Min = 1000, Max = 50000, Default = 10000 }, Callback = function(v) 
        State.HardFling.power = v
        if modules.fling then modules.fling.setPower(v) end
    end})
    
    -- ================================ TAB: TELEPORT ================================
    local TabTP = Window:Tab({ Title = "Teleport", Icon = "map-pin-x-inside" })
    
    local secDirTP = TabTP:Section({ Title = "Direct Teleport", Icon = "map-pin", Box = true })
    local smartTPActive = false
    secDirTP:Toggle({ Title = "Smart TP", Desc = "Equip tool → tap to toggle mode → tap to TP", Default = false, Callback = function(v)
        smartTPActive = v
        if modules.teleport then
            modules.teleport.toggleSmartTP(v)
        else
            core.Notify("Smart TP", v and "ON" or "OFF", 1.5, "map-pin")
        end
    end})
    
    local secTargetTP = TabTP:Section({ Title = "Target Teleport", Icon = "crosshair", Box = true })
    local tpTarget = ""
    secTargetTP:Input({ Title = "Search Player", Placeholder = "Type name...", Callback = function(v) tpTarget = v end })
    secTargetTP:Button({ Title = "Execute TP", Desc = "Teleport to target", Callback = function()
        if modules.teleport then
            modules.teleport.teleportToTarget(tpTarget)
        else
            core.Notify("Teleport", "Module not loaded", 2, "circle-alert")
        end
    end})
    secTargetTP:Dropdown({ Title = "Player List", Values = core.Helpers.getDisplayNames(), Callback = function(v) tpTarget = tostring(v) end })
    secTargetTP:Button({ Title = "Refresh List", Callback = function() 
        core.Notify("Teleport", "List refreshed", 1.5, "map-pin") 
    end})
    
    -- Coordinates Cache
    local secCache = TabTP:Section({ Title = "Coordinates Cache", Icon = "save", Box = true })
    for i = 1, 3 do
        local idx = i
        local hc = secCache:HStack({ Columns = 2 })
        hc:Button({ Title = "💾 Save " .. idx, Callback = function()
            if modules.teleport then
                modules.teleport.saveCoord(idx)
            else
                local r = core.Helpers.getRoot()
                if r then
                    getgenv()._XKID_SAVED_LOCS = getgenv()._XKID_SAVED_LOCS or {}
                    getgenv()._XKID_SAVED_LOCS[idx] = r.CFrame
                    core.Notify("Slot " .. idx, "Saved", 1.5, "save")
                end
            end
        end})
        hc:Button({ Title = "📍 Load " .. idx, Callback = function()
            if modules.teleport then
                modules.teleport.loadCoord(idx)
            else
                local locs = getgenv()._XKID_SAVED_LOCS
                if locs and locs[idx] then
                    local r = core.Helpers.getRoot()
                    if r then r.CFrame = locs[idx]; core.Notify("Slot " .. idx, "Loaded", 1.5, "map-pin") end
                else
                    core.Notify("Slot " .. idx, "Empty", 1.5, "save")
                end
            end
        end})
    end
    
    -- ================================ TAB: SPECTATOR ================================
    local TabSpec = Window:Tab({ Title = "Spectator", Icon = "cctv" })
    
    local secZoom = TabSpec:Section({ Title = "Zoom Override", Icon = "zoom-in", Box = true })
    secZoom:Toggle({ Title = "Max Zoom Out", Default = false, Callback = function(v)
        pcall(function() LP.CameraMaxZoomDistance = v and 100000 or 400 end)
        core.Notify("Zoom", v and "Max" or "Default", 1.5, "zoom-in")
    end})
    
    local secSP = TabSpec:Section({ Title = "Spectator Mode", Icon = "eye", Box = true })
    local selectedTarget = "[Self]"
    secSP:Dropdown({ Title = "Select Target", Values = core.Helpers.getDisplayNamesWithSelf(), Callback = function(v)
        selectedTarget = tostring(v)
        if v == "[Self]" then
            core.Notify("Spectator", "Self selected", 1.5, "eye")
        else
            local p = core.Helpers.findPlayerByDisplay(v)
            if p then core.Notify("Spectator", p.DisplayName, 1.5, "eye") end
        end
    end})
    secSP:Button({ Title = "Refresh Target List", Callback = function() 
        core.Notify("Spectator", "List refreshed", 1.5, "eye") 
    end})
    
    local specActive = false
    secSP:Toggle({ Title = "Enable Spectate", Default = false, Callback = function(v)
        specActive = v
        if modules.spectator then
            local target = core.Helpers.findPlayerByDisplay(selectedTarget)
            modules.spectator.toggle(v, target)
        else
            core.Notify("Spectator", v and "ON (Demo)" or "OFF", 1.5, "eye")
        end
    end})
    
    local specFirstPerson = false
    secSP:Toggle({ Title = "First Person View", Default = false, Callback = function(v)
        specFirstPerson = v
        if modules.spectator then
            modules.spectator.setMode(v)
        else
            core.Notify("Spectator", v and "First Person" or "Third Person", 1.5, "eye")
        end
    end})
    
    secSP:Slider({ Title = "Distance", Step = 1, Value = { Min = 3, Max = 30, Default = 8 }, Callback = function(v)
        if modules.spectator then modules.spectator.setDistance(v) end
    end})
    
    -- ================================ TAB: CINEMATIC ================================
    local TabCine = Window:Tab({ Title = "Cinematic", Icon = "aperture" })
    
    local secSelfSpec = TabCine:Section({ Title = "🎥 Self-Spectate", Icon = "camera", Box = true })
    local selfSpecActive = false
    secSelfSpec:Toggle({ Title = "Enable Self-Spectate", Desc = "1-finger orbit | 2-finger zoom | Mouse right-drag", Default = false, Callback = function(v)
        selfSpecActive = v
        if modules.spectator then
            modules.spectator.toggleSelfSpec(v)
        else
            core.Notify("Self-Spectate", v and "ON (Demo)" or "OFF", 1.5, "camera")
        end
    end})
    secSelfSpec:Dropdown({ Title = "Preset Mode", Values = { "Manual", "Slow Orbit", "Vertical Swing", "Figure 8", "Cinematic Drift", "Top Down", "First Person" }, Default = "Manual", Callback = function(v)
        State.SelfSpec.mode = v
        if modules.spectator then modules.spectator.setSelfSpecMode(v) end
        core.Notify("Self-Spec", "Mode: " .. v, 1.5, "camera")
    end})
    secSelfSpec:Slider({ Title = "Distance / Radius", Step = 0.5, Value = { Min = 3, Max = 30, Default = 8 }, Callback = function(v)
        State.SelfSpec.radius = v
        State.SelfSpec.dist = v
        if modules.spectator then modules.spectator.setSelfSpecRadius(v) end
    end})
    secSelfSpec:Slider({ Title = "Height", Step = 0.5, Value = { Min = -10, Max = 20, Default = 3 }, Callback = function(v)
        State.SelfSpec.height = v
        if modules.spectator then modules.spectator.setSelfSpecHeight(v) end
    end})
    secSelfSpec:Slider({ Title = "Speed", Step = 0.1, Value = { Min = 0.1, Max = 5, Default = 1 }, Callback = function(v)
        State.SelfSpec.speed = v
        if modules.spectator then modules.spectator.setSelfSpecSpeed(v) end
    end})
    
    local secFC = TabCine:Section({ Title = "Drone Engine", Icon = "video", Box = true })
    local freecamActive = false
    secFC:Toggle({ Title = "Enable Freecam", Default = false, Callback = function(v)
        freecamActive = v
        if modules.freecam then
            modules.freecam.toggle(v, State, core, core.Services.RunService, core.Services.UserInputService, Camera)
        else
            core.Notify("Freecam", v and "ON (Demo)" or "OFF", 1.5, "video")
        end
    end})
    secFC:Slider({ Title = "Camera Speed", Step = 0.5, Value = { Min = 1, Max = 20, Default = 3 }, Callback = function(v)
        if State.Freecam then State.Freecam.speed = v end
    end})
    secFC:Slider({ Title = "Sensitivity", Step = 0.05, Value = { Min = 0.1, Max = 1.0, Default = 0.25 }, Callback = function(v)
        if State.Freecam then State.Freecam.sens = v end
    end})
    
    local secCine = TabCine:Section({ Title = "Cinematic Mode", Icon = "film", Box = true })
    secCine:Toggle({ Title = "Hide All UI", Default = false, Callback = function(v)
        if getgenv()._XKID_UI_LOADING then return end
        if v then
            State.Cinema.hideUI = true
            State.Cinema.cachedGuis = {}
            for _,gui in pairs(LP.PlayerGui:GetChildren()) do
                if gui:IsA("ScreenGui") and gui.Enabled then
                    table.insert(State.Cinema.cachedGuis, gui)
                    gui.Enabled = false
                end
            end
            pcall(function() core.Services.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false) end)
        else
            State.Cinema.hideUI = false
            for _,gui in pairs(State.Cinema.cachedGuis) do
                if gui and gui.Parent then gui.Enabled = true end
            end
            State.Cinema.cachedGuis = {}
            pcall(function() core.Services.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true) end)
        end
        core.Notify("Cinematic", v and "UI Hidden" or "UI Shown", 1.5, "film")
    end})
    
    -- ================================ TAB: VISUALS ================================
    local TabVis = Window:Tab({ Title = "Visuals", Icon = "moon-star" })
    
    local secPresets = TabVis:Section({ Title = "Presets", Icon = "palette", Box = true })
    secPresets:Dropdown({ Title = "Select Filter", Values = {
        "Default", "Custom", "Mendung HD", "Cool Blue HD", "Soft Fade HD", "Adaptif Langit HD",
        "Edgy HD", "Full Bright HD", "Soft Pastel HD", "Cinematic Soft", "Ultra HD", "Realistic",
        "Night HD", "Senja", "Cinematic Film", "Golden Hour", "Moody Blue"
    }, Default = "Default", Callback = function(v)
        if modules.visuals then
            modules.visuals.applyFilter(core, State, v)
        else
            core.Notify("Visuals", v, 1.5, "palette")
        end
    end})
    
    local secFX = TabVis:Section({ Title = "Custom FX", Icon = "sliders", Box = true })
    secFX:Slider({ Title = "Tint Red", Step = 1, Value = { Min = 0, Max = 255, Default = 255 }, Callback = function(v) 
        State.CustomFilter.tintR = v
        if modules.visuals then modules.visuals.setTint(core, State, v, State.CustomFilter.tintG, State.CustomFilter.tintB)
        else core.Notify("Visuals", "Tint R: " .. v, 1, "palette") end
    end})
    secFX:Slider({ Title = "Tint Green", Step = 1, Value = { Min = 0, Max = 255, Default = 255 }, Callback = function(v) 
        State.CustomFilter.tintG = v
        if modules.visuals then modules.visuals.setTint(core, State, State.CustomFilter.tintR, v, State.CustomFilter.tintB) end
    end})
    secFX:Slider({ Title = "Tint Blue", Step = 1, Value = { Min = 0, Max = 255, Default = 255 }, Callback = function(v) 
        State.CustomFilter.tintB = v
        if modules.visuals then modules.visuals.setTint(core, State, State.CustomFilter.tintR, State.CustomFilter.tintG, v) end
    end})
    secFX:Slider({ Title = "Saturation", Step = 0.05, Value = { Min = -1, Max = 1, Default = 0 }, Callback = function(v) 
        State.CustomFilter.saturation = v
        if modules.visuals then modules.visuals.setSaturation(core, State, v) end
    end})
    secFX:Slider({ Title = "Contrast", Step = 0.05, Value = { Min = -1, Max = 1, Default = 0 }, Callback = function(v) 
        State.CustomFilter.contrast = v
        if modules.visuals then modules.visuals.setContrast(core, State, v) end
    end})
    secFX:Slider({ Title = "Brightness", Step = 0.05, Value = { Min = -1, Max = 1, Default = 0 }, Callback = function(v) 
        State.CustomFilter.brightness = v
        if modules.visuals then modules.visuals.setBrightness(core, State, v) end
    end})
    secFX:Slider({ Title = "Bloom Intensity", Step = 0.1, Value = { Min = 0, Max = 5, Default = 0 }, Callback = function(v) 
        State.CustomFilter.bloomIntensity = v
        if modules.visuals then modules.visuals.setBloom(core, State, v, State.CustomFilter.bloomSize) end
    end})
    secFX:Slider({ Title = "Bloom Size", Step = 1, Value = { Min = 0, Max = 100, Default = 24 }, Callback = function(v) 
        State.CustomFilter.bloomSize = v
        if modules.visuals then modules.visuals.setBloom(core, State, State.CustomFilter.bloomIntensity, v) end
    end})
    secFX:Slider({ Title = "ClockTime", Step = 0.5, Value = { Min = 0, Max = 24, Default = 14 }, Callback = function(v) 
        State.CustomFilter.clockTime = v
        if modules.visuals then modules.visuals.setClockTime(core, State, v) end
    end})
    secFX:Button({ Title = "Reset Custom FX", Callback = function()
        if modules.visuals then
            modules.visuals.resetCustomFX(core, State)
        else
            core.Notify("Visuals", "FX Reset", 2, "rotate-ccw")
        end
    end})
    
    local secDOF = TabVis:Section({ Title = "Depth of Field", Icon = "focus", Box = true })
    secDOF:Slider({ Title = "Blur Intensity", Step = 0.1, Value = { Min = 0, Max = 1, Default = 0 }, Callback = function(v) 
        State.CustomFilter.dofIntensity = v
        if modules.visuals then modules.visuals.setDOF(core, State, v, State.CustomFilter.dofDistance) end
    end})
    secDOF:Slider({ Title = "Focus Distance", Step = 5, Value = { Min = 1, Max = 500, Default = 50 }, Callback = function(v) 
        State.CustomFilter.dofDistance = v
        if modules.visuals then modules.visuals.setDOF(core, State, State.CustomFilter.dofIntensity, v) end
    end})
    
    -- ================================ TAB: ESP ================================
    local TabESP = Window:Tab({ Title = "ESP", Icon = "scan-search" })
    
    local secDetect = TabESP:Section({ Title = "Detection System", Icon = "radar", Box = true })
    secDetect:Toggle({ Title = "Enable Radar", Default = false, Callback = function(v)
        State.ESP.active = v
        if modules.esp then
            modules.esp.start(core, State, core.Services.Players, core.Services.RunService, Camera, core.Services.UserInputService, onMobile)
        end
        core.Notify("ESP", v and "ON" or "OFF", 1.5, "radar")
    end})
    secDetect:Dropdown({ Title = "Tracer Origin", Values = { "Bottom", "Center", "Mouse", "OFF" }, Default = "Bottom", Callback = function(v) 
        State.ESP.tracerMode = v
        core.Notify("ESP", "Tracer: " .. v, 1.5, "radar")
    end})
    secDetect:Toggle({ Title = "Highlight Entity", Default = false, Callback = function(v) 
        State.ESP.highlightMode = v
        core.Notify("ESP", "Highlight " .. (v and "ON" or "OFF"), 1.5, "radar")
    end})
    secDetect:Slider({ Title = "Scan Distance", Step = 10, Value = { Min = 50, Max = 500, Default = 300 }, Callback = function(v) 
        State.ESP.maxDrawDistance = v 
    end})
    
    local secESPCol = TabESP:Section({ Title = "Color Config", Icon = "palette", Box = true })
    secESPCol:Dropdown({ Title = "Normal Color", Values = { "Hijau", "Merah", "Biru", "Kuning", "Ungu", "Cyan", "Orange", "Pink", "Putih", "Hitam" }, Default = "Hijau", Callback = function(v)
        if core.ColorMap[v] then
            State.ESP.tracerColor_N = core.ColorMap[v]
            State.ESP.boxColor_N = core.ColorMap[v]
        end
        core.Notify("ESP", "Normal: " .. v, 1.5, "palette")
    end})
    secESPCol:Dropdown({ Title = "Suspect Color", Values = { "Merah", "Hijau", "Biru", "Kuning", "Ungu", "Cyan", "Orange", "Pink", "Putih", "Hitam", "Crimson" }, Default = "Crimson", Callback = function(v)
        if core.ColorMap[v] then
            State.ESP.tracerColor_S = core.ColorMap[v]
            State.ESP.boxColor_S = core.ColorMap[v]
        end
        core.Notify("ESP", "Suspect: " .. v, 1.5, "palette")
    end})
    secESPCol:Dropdown({ Title = "Glitch Acc Color", Values = { "Orange", "Merah", "Hijau", "Biru", "Kuning", "Ungu", "Cyan", "Pink", "Putih", "Hitam" }, Default = "Orange", Callback = function(v)
        if core.ColorMap[v] then
            State.ESP.tracerColor_G = core.ColorMap[v]
            State.ESP.boxColor_G = core.ColorMap[v]
        end
        core.Notify("ESP", "Glitch: " .. v, 1.5, "palette")
    end})
    
    -- ================================ TAB: LOGGER ================================
    local TabLog = Window:Tab({ Title = "Logger", Icon = "square-terminal" })
    
    local secChat = TabLog:Section({ Title = "Chat Logger", Icon = "message-square", Box = true })
    local loggerActive = false
    secChat:Toggle({ Title = "Enable Logger", Default = false, Callback = function(v)
        loggerActive = v
        if modules.logger then
            if v then modules.logger.start() else modules.logger.stop() end
        else
            core.Notify("Logger", v and "ON" or "OFF", 1.5, "terminal")
        end
    end})
    
    local chatTargetLabel = secChat:Paragraph({ Title = "Targets", Desc = "None" })
    local chatTargetDrop = secChat:Dropdown({ Title = "Select Targets", Multi = true, AllowNone = true, Values = core.Helpers.getDisplayNames(), Callback = function(selected)
        if modules.logger then
            modules.logger.setTargets(selected)
        else
            State.Utility.chatTargets = {}
            if selected and typeof(selected) == "table" then
                for _,name in ipairs(selected) do
                    table.insert(State.Utility.chatTargets, tostring(name))
                end
            end
        end
        if modules.logger then
            pcall(function() chatTargetLabel:SetDesc("Tracking: " .. table.concat(selected or {}, ", ")) end)
        else
            if #State.Utility.chatTargets > 0 then
                pcall(function() chatTargetLabel:SetDesc("Tracking: " .. table.concat(State.Utility.chatTargets, ", ")) end)
            else
                pcall(function() chatTargetLabel:SetDesc("None") end)
            end
        end
    end})
    
    secChat:Button({ Title = "Clear Targets", Callback = function()
        if modules.logger then
            modules.logger.clearTargets()
        else
            State.Utility.chatTargets = {}
        end
        pcall(function() chatTargetLabel:SetDesc("None") end)
        pcall(function() chatTargetDrop:SetValues({}); task.wait(0.05); chatTargetDrop:SetValues(core.Helpers.getDisplayNames()) end)
        core.Notify("Logger", "Targets cleared", 1.5, "terminal")
    end})
    
    secChat:Button({ Title = "Refresh List", Callback = function()
        pcall(function() chatTargetDrop:Refresh(core.Helpers.getDisplayNames(), true) end)
        core.Notify("Logger", "List refreshed", 1.5, "terminal")
    end})
    
    local chatLogPanel = secChat:Paragraph({ Title = "Console", Desc = "Belum ada chat..." })
    secChat:Button({ Title = "Clear Log", Callback = function()
        if modules.logger then
            modules.logger.clearHistory()
        else
            State.Utility.chatHistory = {}
        end
        pcall(function() chatLogPanel:SetDesc("Belum ada chat...") end)
        core.Notify("Logger", "Log cleared", 1.5, "terminal")
    end})
    
    if modules.logger then
        modules.logger.setPanel(chatLogPanel)
    else
        -- Fallback logger manual
        task.spawn(function()
            local function onChat(senderName, message)
                if not State.Utility.chatLog then return end
                if #State.Utility.chatTargets == 0 then return end
                local cleanSender = senderName:lower():match("^%s*(.-)%s*$")
                for _,target in ipairs(State.Utility.chatTargets) do
                    local cleanTarget = target:lower():match("^%s*(.-)%s*$")
                    if cleanSender == cleanTarget then
                        local entry = string.format("[%s] %s: %s", os.date("%H:%M:%S"), senderName, message)
                        table.insert(State.Utility.chatHistory, entry)
                        if #State.Utility.chatHistory > 50 then table.remove(State.Utility.chatHistory, 1) end
                        core.Notify("Chat", senderName .. ": " .. message, 2, "message-circle")
                        break
                    end
                end
            end
            
            if core.Services.TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
                pcall(function()
                    core.TrackConnection(core.Services.TextChatService.MessageReceived:Connect(function(msg)
                        if msg.TextSource then onChat(msg.TextSource.Name, msg.Text) end
                    end))
                end)
            end
            
            local function connectLegacyChat(player)
                pcall(function()
                    core.TrackConnection(player.Chatted:Connect(function(msg) onChat(player.DisplayName, msg) end))
                end)
            end
            
            for _,p in pairs(core.Services.Players:GetPlayers()) do
                if p ~= LP then connectLegacyChat(p) end
            end
            core.TrackConnection(core.Services.Players.PlayerAdded:Connect(function(p) if p ~= LP then connectLegacyChat(p) end end))
        end)
        
        task.spawn(function()
            while getgenv()._XKID_RUNNING do
                task.wait(0.5)
                if State.Utility.chatLog then
                    pcall(function()
                        local t = table.concat(State.Utility.chatHistory, "\n")
                        if #t > 2000 then t = t:sub(-2000) end
                        if #t == 0 then t = "Belum ada chat..." end
                        chatLogPanel:SetDesc(t)
                    end)
                end
            end
        end)
    end
    
    -- ================================ TAB: PROTECTION ================================
    local TabProt = Window:Tab({ Title = "Protection", Icon = "shield-half" })
    
    local secProt = TabProt:Section({ Title = "Protection Protocols", Icon = "shield-check", Box = true })
    
    -- Anti AFK (menggunakan fungsi dari core)
    local antiAFKActive = false
    secProt:Toggle({ Title = "Anti AFK", Default = false, Callback = function(v)
        antiAFKActive = v
        if v then
            -- Start AFK dari core
            if not State.Security.afkActive then
                local function sendProperAntiAFK()
                    if core.Services.VirtualUser and core.Services.VirtualUser.ClickButton2 then
                        pcall(function()
                            local vp = Camera.ViewportSize
                            local center = vp and Vector2.new(vp.X / 2, vp.Y / 2) or Vector2.new(0, 0)
                            core.Services.VirtualUser:ClickButton2(center)
                            task.wait(0.1)
                        end)
                        return
                    end
                    pcall(function()
                        local cf = Camera.CFrame
                        Camera.CFrame = cf * CFrame.Angles(0, math.rad(15), 0)
                        task.wait(0.1)
                        Camera.CFrame = cf
                    end)
                end
                
                State.Security.afkActive = true
                local afkThread = task.spawn(function()
                    while State.Security.afkActive do
                        sendProperAntiAFK()
                        for i = 1, 50 do
                            if not State.Security.afkActive then break end
                            task.wait(1)
                        end
                    end
                end)
                core.TrackConnection({Disconnect = function() task.cancel(afkThread) end})
            end
            core.Notify("Anti AFK", "ON", 1.5, "shield-check")
        else
            State.Security.afkActive = false
            core.Notify("Anti AFK", "OFF", 1.5, "shield-check")
        end
    end})
    
    secProt:Button({ Title = "Stuck Fix", Desc = "Get unstuck from walls/ground", Callback = function()
        local hrp, hum = core.Helpers.getRoot(), core.Helpers.getHum()
        if hrp then
            hrp.Anchored = false
            hrp.CFrame = hrp.CFrame + Vector3.new(0, 3, 0)
        end
        if hum then
            hum.Sit = false
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
        core.Notify("Protection", "Stuck fix applied", 2, "wrench")
    end})
    
    -- Server Control
    local secSrv = TabProt:Section({ Title = "Server Control", Icon = "server", Box = true })
    secSrv:Button({ Title = "Force Rejoin", Desc = "Rejoin current server", Callback = function()
        pcall(function() core.Services.TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP) end)
        core.Notify("Server", "Rejoining...", 2, "log-in")
    end})
    secSrv:Button({ Title = "Server Hop", Desc = "Find a new server", Callback = function()
        pcall(function()
            local req = core.HttpRequest
            local res = req({
                Url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100",
                Method = "GET"
            })
            if res.StatusCode == 200 then
                local body = core.Services.HttpService:JSONDecode(res.Body)
                if body and body.data then
                    for _,v in ipairs(body.data) do
                        if v.playing > 0 and v.playing < v.maxPlayers and v.id ~= game.JobId then
                            core.Services.TeleportService:TeleportToPlaceInstance(game.PlaceId, v.id, LP)
                            core.Notify("Server", "Hopping...", 2, "shuffle")
                            return
                        end
                    end
                end
            end
        end)
    end})
    
    -- Performance
    local secPerf = TabProt:Section({ Title = "Performance", Icon = "gauge", Box = true })
    local gfxMap = { [1]="Level01",[2]="Level02",[3]="Level03",[4]="Level04",[5]="Level05",[6]="Level06",[7]="Level07",[8]="Level08",[9]="Level09",[10]="Level10" }
    secPerf:Slider({ Title = "Quality Level", Step = 1, Value = { Min = 1, Max = 10, Default = 2 }, Callback = function(v)
        if gfxMap[v] then pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel[gfxMap[v]] end) end
        core.Notify("Graphics", gfxMap[v], 1.5, "gauge")
    end})
    secPerf:Dropdown({ Title = "FPS Cap", Values = { "30","60","120","144","240","Unlimited" }, Default = "120", Callback = function(v)
        if v == "Unlimited" then
            core.FPS.set(9999)
        else
            core.FPS.set(tonumber(v))
        end
        core.Notify("Graphics", v .. " FPS", 1.5, "gauge")
    end})
    
    -- FPS Boost
    local advCache = { level = nil, shadows = true, brightness = 5, clockTime = 14, fogEnd = 100000, mats = {}, texs = {} }
    secPerf:Toggle({ Title = "FPS Boost", Default = false, Callback = function(v)
        State.Security.antiLag = v
        if v then
            pcall(function() advCache.level = settings().Rendering.QualityLevel end)
            advCache.shadows = core.Services.Lighting.GlobalShadows
            advCache.brightness = core.Services.Lighting.Brightness
            advCache.clockTime = core.Services.Lighting.ClockTime
            advCache.fogEnd = core.Services.Lighting.FogEnd
            pcall(function() settings().Rendering.QualityLevel = 1 end)
            core.Services.Lighting.GlobalShadows = false
            core.Services.Lighting.Brightness = 1
            core.Services.Lighting.FogEnd = 100000
            for _,obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    advCache.mats[obj] = obj.Material
                    obj.Material = Enum.Material.SmoothPlastic
                elseif obj:IsA("Decal") or obj:IsA("Texture") or obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                    advCache.texs[obj] = obj.Enabled
                    obj.Enabled = false
                end
            end
            core.Notify("Performance", "FPS Boost ON", 2, "zap")
        else
            pcall(function() if advCache.level then settings().Rendering.QualityLevel = advCache.level end end)
            core.Services.Lighting.GlobalShadows = advCache.shadows
            core.Services.Lighting.Brightness = advCache.brightness
            core.Services.Lighting.ClockTime = advCache.clockTime
            core.Services.Lighting.FogEnd = advCache.fogEnd
            for obj,mat in pairs(advCache.mats) do
                if obj and obj.Parent then obj.Material = mat end
            end
            for obj,enb in pairs(advCache.texs) do
                if obj and obj.Parent then obj.Enabled = enb end
            end
            advCache.mats = {}
            advCache.texs = {}
            core.Notify("Performance", "Graphics restored", 2, "zap")
        end
    end})
    
    -- Shift Lock
    local secCam = TabProt:Section({ Title = "Camera Lock", Icon = "lock", Box = true })
    local shiftLockActive = false
    local shiftLockGyro = nil
    secCam:Toggle({ Title = "Force Shift Lock", Default = false, Callback = function(v)
        shiftLockActive = v
        State.Security.shiftLock = v
        if v then
            local hrp = core.Helpers.getRoot()
            if hrp then
                if shiftLockGyro then shiftLockGyro:Destroy() end
                shiftLockGyro = Instance.new("BodyGyro", hrp)
                shiftLockGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                shiftLockGyro.P = 50000
                shiftLockGyro.D = 1000
            end
            core.TrackConnection(core.Services.RunService:BindToRenderStep("XKIDShiftLock", Enum.RenderPriority.Camera.Value + 2, function()
                if not State.Security.shiftLock then return end
                local hrp2, gyro = core.Helpers.getRoot(), shiftLockGyro
                if hrp2 and gyro and gyro.Parent == hrp2 then
                    local flatLook = Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z)
                    if flatLook.Magnitude > 0.01 then
                        gyro.CFrame = CFrame.new(hrp2.Position, hrp2.Position + flatLook)
                    end
                end
            end))
            core.Notify("Shift Lock", "ON", 1.5, "lock")
        else
            core.Services.RunService:UnbindFromRenderStep("XKIDShiftLock")
            if shiftLockGyro then shiftLockGyro:Destroy(); shiftLockGyro = nil end
            core.Notify("Shift Lock", "OFF", 1.5, "unlock")
        end
    end})
    
    -- ================================ TAB: SETTINGS ================================
    local TabSet = Window:Tab({ Title = "Settings", Icon = "panels-top-left" })
    
    local secTheme = TabSet:Section({ Title = "🎨 Theme", Icon = "palette", Box = true })
    secTheme:Dropdown({ Title = "UI Theme", Values = { "Dark","Light","Rose","Sky","Emerald","Violet","Red","Amber","Indigo","Midnight","Crimson" }, Default = "Crimson", Callback = function(v) 
        WindUI:SetTheme(v) 
    end})
    
    local secFile = TabSet:Section({ Title = "File Management", Icon = "folder", Box = true })
    local cfgName = "XKID_Config_V2"
    local currentConfig = "No config"
    
    secFile:Input({ Title = "Config Name", Value = "XKID_Config_V2", Callback = function(v) cfgName = v end })
    secFile:Button({ Title = "Save Config", Callback = function()
        if modules.settings then
            modules.settings.saveConfig(cfgName)
        else
            core.Notify("Config", "Module not loaded", 2, "circle-alert")
        end
    end})
    
    local configDrop = secFile:Dropdown({ Title = "Load Config", Values = core.GetConfigList(), Callback = function(selected)
        currentConfig = selected
        if modules.settings then
            modules.settings.loadConfig(selected)
        else
            core.Notify("Config", "Module not loaded", 2, "circle-alert")
        end
    end})
    
    secFile:Button({ Title = "Delete Config", Callback = function()
        if modules.settings then
            modules.settings.deleteConfig(currentConfig, function()
                pcall(function() configDrop:Refresh(core.GetConfigList(), true) end)
            end)
        else
            core.Notify("Config", "Module not loaded", 2, "circle-alert")
        end
    end})
    
    secFile:Button({ Title = "Refresh Files", Callback = function()
        pcall(function() configDrop:Refresh(core.GetConfigList(), true) end)
        core.Notify("Config", "Files refreshed", 1.5, "folder")
    end})
    
    secFile:Button({ Title = "Reset All Settings", Callback = function()
        if modules.settings then
            modules.settings.resetAll()
        else
            core.Notify("Settings", "Module not loaded", 2, "circle-alert")
        end
    end})
    
    -- Auto Like Section di Settings
    local secLike = TabSet:Section({ Title = "Auto Like (Smart)", Icon = "heart", Box = true })
    local autoLikeActive = false
    secLike:Toggle({ Title = "Auto Like", Default = false, Callback = function(v)
        autoLikeActive = v
        if modules.autolike then
            if v then modules.autolike.start() else modules.autolike.stop() end
        else
            core.Notify("Auto Like", v and "ON (Demo)" or "OFF", 1.5, "heart")
        end
    end})
    secLike:Slider({ Title = "Like Radius", Desc = "0 = all", Step = 10, Value = { Min = 0, Max = 500, Default = 100 }, Callback = function(v) 
        State.AutoLike.radius = v
        if modules.autolike then modules.autolike.setRadius(v) end
    end})
    secLike:Slider({ Title = "Min Cooldown", Step = 0.5, Value = { Min = 0.5, Max = 10, Default = 2 }, Callback = function(v) 
        State.AutoLike.minCD = v
        if modules.autolike then modules.autolike.setMinCooldown(v) end
    end})
    secLike:Slider({ Title = "Max Cooldown", Step = 0.5, Value = { Min = 1, Max = 15, Default = 6 }, Callback = function(v) 
        State.AutoLike.maxCD = v
        if modules.autolike then modules.autolike.setMaxCooldown(v) end
    end})
    
    local autoLikeInfo = secLike:Paragraph({ Title = "Info", Desc = "Total likes sent: 0" })
    task.spawn(function()
        while getgenv()._XKID_RUNNING do
            task.wait(2)
            pcall(function() 
                local count = State.AutoLike.count
                if modules.autolike then count = modules.autolike.getCount() end
                autoLikeInfo:SetDesc("Total likes sent: " .. count) 
            end)
        end
    end)
    
    -- ================================ AUTO EXPAND ALL SECTIONS ================================
    task.delay(0.5, function()
        pcall(function()
            for _,tab in pairs(Window.Tabs) do
                for _,section in ipairs(tab.Sections) do
                    if section.Expand then
                        section:Expand()
                    end
                end
            end
            core.Notify("System", "All sections expanded", 2, "maximize-2")
        end)
    end)
    
    -- ================================ INITIAL SETTINGS ================================
    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level02 end)
    core.FPS.set(120)
    
    -- ================================ AUTO START ANTI AFK ================================
    task.spawn(function()
        task.wait(0.5)
        if modules.settings then
            -- Auto start anti AFK (opsional)
        end
        task.wait(2)
        getgenv()._XKID_UI_LOADING = false
        core.Notify("System", "XKID V2.0 AKTIF — Ready", 3, "rocket")
    end)
end

return UI