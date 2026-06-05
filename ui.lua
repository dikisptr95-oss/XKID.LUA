-- ================================ XKID UI (FULL VERSION) ================================
local UI = {}

function UI.create(core, modules)
    -- Load WindUI (menggunakan URL yang sudah terbukti berhasil)
    local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/refs/heads/main/dist/main.lua"))()
    core.WindUI = WindUI
    
    -- Override notify
    core.Notify = function(title, content, duration, icon)
        pcall(function() 
            WindUI:Notify({ Title = title, Content = content, Duration = duration or 2, Icon = icon or "bell" })
        end)
    end
    
    -- ================================ CREATE MAIN WINDOW ================================
    local win = WindUI:CreateWindow({
        Title = "XKID HUB V2.0",
        Size = UDim2.fromOffset(380, 340),
        Theme = "Crimson",
        SideBarWidth = 150,
    })
    
    -- ================================ TAB: CHARACTER ================================
    local tabChar = win:Tab({ Title = "Character", Icon = "fingerprint" })
    
    local secMove = tabChar:Section({ Title = "Movement", Box = true })
    secMove:Slider({ Title = "Walk Speed", Step = 1, Value = { Min = 16, Max = 300, Default = 16 }, Callback = function(v)
        core.State.Move.ws = v
        local h = core.Helpers.getHum()
        if h then h.WalkSpeed = v end
        core.Notify("Speed", "Walk Speed: " .. v, 1, "zap")
    end})
    secMove:Slider({ Title = "Jump Power", Step = 1, Value = { Min = 50, Max = 300, Default = 50 }, Callback = function(v)
        core.State.Move.jp = v
        local h = core.Helpers.getHum()
        if h then h.UseJumpPower = true; h.JumpPower = v end
    end})
    
    -- Fly (akan terhubung ke modules.fly nanti)
    local secAbi = tabChar:Section({ Title = "Abilities", Box = true })
    local flyToggle = false
    secAbi:Toggle({ Title = "Fly", Default = false, Callback = function(v)
        flyToggle = v
        if modules.fly and modules.fly.toggle then
            modules.fly.toggle(v, core.State, core, core.Services.RunService, core.Services.UserInputService, workspace.CurrentCamera, false)
        else
            core.Notify("Fly", v and "ON (Demo)" or "OFF", 1.5, "bird")
        end
    end})
    secAbi:Slider({ Title = "Fly Speed", Step = 5, Value = { Min = 30, Max = 200, Default = 60 }, Callback = function(v) 
        core.State.Move.flyS = v 
    end})
    
    -- NoClip
    local noclipConn = nil
    secAbi:Toggle({ Title = "NoClip", Default = false, Callback = function(v)
        core.State.Move.ncp = v
        if v then
            noclipConn = core.Services.RunService.Heartbeat:Connect(function()
                if not core.State.Move.ncp then return end
                local char = core.Services.Players.LocalPlayer.Character
                if char then
                    for _,p in pairs(char:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = false end
                    end
                end
            end)
        else
            if noclipConn then noclipConn:Disconnect() end
            local char = core.Services.Players.LocalPlayer.Character
            if char then
                for _,p in pairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = true end
                end
            end
        end
        core.Notify("NoClip", v and "ON" or "OFF", 1.5, "ghost")
    end})
    
    -- Hard Fling (akan terhubung ke modules.fling nanti)
    local secFling = tabChar:Section({ Title = "Hard Fling", Box = true })
    local flingActive = false
    secFling:Toggle({ Title = "Enable Fling", Default = false, Callback = function(v)
        flingActive = v
        if modules.fling and modules.fling.toggle then
            modules.fling.toggle(v, core.State, core, core.Services.RunService)
        else
            core.Notify("Hard Fling", v and "ON (Demo)" or "OFF", 1.5, "zap")
        end
    end})
    secFling:Dropdown({ Title = "Fling Mode", Values = { "Spin", "Shake" }, Default = "Spin", Callback = function(v) 
        core.State.HardFling.mode = v 
        if modules.fling and modules.fling.setMode then modules.fling.setMode(v) end
    end})
    secFling:Slider({ Title = "Fling Power", Step = 500, Value = { Min = 1000, Max = 30000, Default = 10000 }, Callback = function(v) 
        core.State.HardFling.power = v
        if modules.fling and modules.fling.setPower then modules.fling.setPower(v) end
    end})
    
    -- ================================ TAB: ESP ================================
    local tabESP = win:Tab({ Title = "ESP", Icon = "scan-search" })
    
    local secDetect = tabESP:Section({ Title = "Radar", Box = true })
    secDetect:Toggle({ Title = "Enable ESP", Default = false, Callback = function(v)
        core.State.ESP.active = v
        if modules.esp and modules.esp.start then
            modules.esp.start(core, core.State, core.Services.Players, core.Services.RunService, workspace.CurrentCamera, core.Services.UserInputService, false)
        end
        core.Notify("ESP", v and "ON" or "OFF", 1.5, "radar")
    end})
    secDetect:Dropdown({ Title = "Tracer Origin", Values = { "Bottom", "Center", "OFF" }, Default = "Bottom", Callback = function(v)
        core.State.ESP.tracerMode = v
    end})
    secDetect:Slider({ Title = "Max Distance", Step = 25, Value = { Min = 100, Max = 500, Default = 300 }, Callback = function(v)
        core.State.ESP.maxDrawDistance = v
    end})
    
    -- ================================ TAB: PROTECTION ================================
    local tabProt = win:Tab({ Title = "Protection", Icon = "shield-half" })
    
    local secProt = tabProt:Section({ Title = "Protection", Box = true })
    local afkActive = false
    secProt:Toggle({ Title = "Anti AFK", Default = false, Callback = function(v)
        afkActive = v
        if modules.protection and modules.protection.toggleAFK then
            modules.protection.toggleAFK(v)
        else
            core.Notify("Anti AFK", v and "ON (Demo)" or "OFF", 1.5, "shield-check")
        end
    end})
    secProt:Button({ Title = "Stuck Fix", Callback = function()
        local hrp = core.Helpers.getRoot()
        if hrp then
            hrp.CFrame = hrp.CFrame + Vector3.new(0, 3, 0)
            core.Notify("Stuck Fix", "Applied", 1.5, "wrench")
        end
    end})
    
    -- ================================ TAB: AUTO LIKE ================================
    local tabLike = win:Tab({ Title = "Auto Like", Icon = "heart" })
    
    local secLike = tabLike:Section({ Title = "Auto Like", Box = true })
    local autoLikeActive = false
    secLike:Toggle({ Title = "Auto Like", Default = false, Callback = function(v)
        autoLikeActive = v
        if modules.autolike and modules.autolike.toggle then
            modules.autolike.toggle(v, core, core.State)
        else
            core.Notify("Auto Like", v and "ON (Demo)" or "OFF", 1.5, "heart")
        end
    end})
    secLike:Slider({ Title = "Min Cooldown", Step = 0.5, Value = { Min = 1, Max = 10, Default = 2 }, Callback = function(v) 
        core.State.AutoLike.minCD = v 
    end})
    secLike:Slider({ Title = "Max Cooldown", Step = 0.5, Value = { Min = 2, Max = 15, Default = 6 }, Callback = function(v) 
        core.State.AutoLike.maxCD = v 
    end})
    
    local likeCountLabel = secLike:Paragraph({ Title = "Info", Desc = "Total likes: 0" })
    task.spawn(function()
        while true do
            task.wait(2)
            pcall(function() likeCountLabel:SetDesc("Total likes: " .. (core.State.AutoLike.count or 0)) end)
        end
    end)
    
    -- ================================ TAB: VISUALS ================================
    local tabVis = win:Tab({ Title = "Visuals", Icon = "moon-star" })
    
    local secFilter = tabVis:Section({ Title = "Filters", Box = true })
    secFilter:Dropdown({ Title = "Select Filter", Values = { "Default", "Mendung HD", "Cool Blue HD", "Full Bright HD", "Night HD" }, Default = "Default", Callback = function(v)
        if modules.visuals and modules.visuals.apply then
            modules.visuals.apply(v, core, core.State)
        else
            core.Notify("Visuals", v, 1.5, "palette")
        end
    end})
    
    -- Auto expand sections
    task.delay(0.5, function()
        pcall(function()
            for _,tab in pairs(win.Tabs) do
                for _,sec in ipairs(tab.Sections) do
                    if sec.Expand then sec:Expand() end
                end
            end
        end)
    end)
    
    core.Notify("System", "XKID HUB V2.0 FULL SIAP!", 3, "rocket")
end

return UI