-- ================================ UI MODULE ================================
-- by @WTF.XKID

local UI = {}

function UI.create(core, modules)
    -- ================================ LOAD WINDUI ================================
    local WindUI = (function()
        local s,r = pcall(function() 
            return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))() 
        end)
        if s then return r else error("Failed to load WindUI") end
    end)()
    
    core.WindUI = WindUI
    
    -- ================================ CLEANUP OLD ================================
    pcall(function()
        for _,v in pairs(core.Services.CoreGui:GetChildren()) do
            if v.Name == "WindUI" or v.Name == "XKID_FreecamUI" or v.Name == "XKID_SelfSpecUI" then
                v:Destroy()
            end
        end
    end)
    
    -- ================================ NOTIFY WRAPPER ================================
    local function notify(title, content, duration, icon)
        pcall(function() WindUI:Notify({ Title = title, Content = content, Duration = duration or 2, Icon = icon or "bell" }) end)
    end
    
    -- ================================ CREATE WINDOW ================================
    local Window = WindUI:CreateWindow({
        Title = "XKID HUB V2.0", Icon = "bluetooth", Author = "@WTF.XKID", Folder = "XKIDHub",
        Size = UDim2.fromOffset(360, 320), Transparent = true, Theme = "Crimson", SideBarWidth = 160,
        User = { Enabled = true, Anonymous = false }, Topbar = { Height = 40, ButtonsType = "Default" },
    })
    
    pcall(function() WindUI:SetFont("rbxassetid://12187376357") end)
    pcall(function() Window.User:SetDisplayName(core.Services.Players.LocalPlayer.DisplayName) end)
    
    Window:EditOpenButton({
        Title = "XKID V2.0", Icon = "github", CornerRadius = UDim.new(1, 0),
        StrokeThickness = 2, StrokeColor = Color3.fromRGB(255, 70, 120),
        Enabled = true, Draggable = true, Scale = 0.72,
    })
    
    -- FPS Tag
    local FpsTag = Window:Tag({ Title = "FPS: -- | Ping: --", Color = Color3.fromRGB(255, 215, 0), Icon = "github" })
    task.spawn(function()
        while getgenv()._XKID_RUNNING do
            task.wait(1)
            pcall(function() FpsTag:SetTitle("FPS: " .. core.SharedFPS .. " | Ping: " .. core.SharedPing .. "ms") end)
        end
    end)
    
    -- ================================ TAB: INFORMASI ================================
    local TabInfo = Window:Tab({ Title = "Informasi", Icon = "activity" })
    
    local avatarImage = "rbxthumb://type=AvatarHeadShot&id=" .. core.Services.Players.LocalPlayer.UserId .. "&w=420&h=420"
    TabInfo:Paragraph({
        Title = "YooWssp!!, " .. core.Services.Players.LocalPlayer.DisplayName,
        Desc = "Executor: " .. core.Executor.name .. "\nAnti AFK: ON ✅",
        Image = avatarImage,
        ImageSize = 80
    })
    
    TabInfo:Section({ Title = "🔗 Discord", Icon = "message-circle", Box = true }):Button({
        Title = "Copy Discord Link",
        Callback = function() pcall(function() setclipboard("https://discord.gg/bzumc2u96") end); notify("System", "Link copied", 2, "copy") end
    })
    
    -- ================================ TAB: CHARACTER ================================
    local TabChar = Window:Tab({ Title = "Character", Icon = "fingerprint" })
    
    -- Movement Section
    local secMov = TabChar:Section({ Title = "Movement", Box = true })
    secMov:Slider({ Title = "Walk Speed", Step = 1, Value = { Min = 16, Max = 500, Default = 16 }, Callback = function(v) 
        core.State.Move.ws = v
        local h = core.Helpers.getHum()
        if h then h.WalkSpeed = v end
    end})
    secMov:Slider({ Title = "Jump Power", Step = 1, Value = { Min = 50, Max = 500, Default = 50 }, Callback = function(v) 
        core.State.Move.jp = v
        local h = core.Helpers.getHum()
        if h then h.UseJumpPower = true; h.JumpPower = v end
    end})
    
    -- Abilities Section
    local secAbi = TabChar:Section({ Title = "Abilities", Box = true })
    local flyToggle = false
    secAbi:Toggle({ Title = "Fly", Default = false, Callback = function(v) 
        flyToggle = v
        modules["modules/fly.lua"].toggle(v, core.State, core, core.Services.RunService, core.Services.UserInputService, workspace.CurrentCamera, not core.Services.UserInputService.KeyboardEnabled)
    end})
    secAbi:Slider({ Title = "Fly Speed", Step = 1, Value = { Min = 10, Max = 300, Default = 60 }, Callback = function(v) core.State.Move.flyS = v end })
    
    -- NoClip
    local noclipConn = nil
    secAbi:Toggle({ Title = "NoClip", Default = false, Callback = function(v)
        core.State.Move.ncp = v
        if v then
            if not noclipConn then
                noclipConn = core.TrackConnection(core.Services.RunService.Heartbeat:Connect(function()
                    if not core.State.Move.ncp then return end
                    local char = core.Services.Players.LocalPlayer.Character
                    if char then
                        for _,p in pairs(char:GetDescendants()) do
                            if p:IsA("BasePart") then p.CanCollide = false end
                        end
                    end
                end))
            end
        else
            if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
            local char = core.Services.Players.LocalPlayer.Character
            if char then
                for _,p in pairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = true end
                end
            end
        end
        notify("NoClip", v and "ON" or "OFF", 1.5, "ghost")
    end})
    
    -- ================================ TAB: ESP ================================
    local TabESP = Window:Tab({ Title = "ESP", Icon = "scan-search" })
    local secDetect = TabESP:Section({ Title = "Detection System", Box = true })
    secDetect:Toggle({ Title = "Enable Radar", Default = false, Callback = function(v)
        core.State.ESP.active = v
        if v then
            modules["modules/esp.lua"].start(core, core.State, core.Services.Players, core.Services.RunService, workspace.CurrentCamera, core.Services.UserInputService, not core.Services.UserInputService.KeyboardEnabled)
        end
        notify("ESP", v and "ON" or "OFF", 1.5, "radar")
    end})
    secDetect:Dropdown({ Title = "Tracer Origin", Values = { "Bottom", "Center", "Mouse", "OFF" }, Default = "Bottom", Callback = function(v) 
        core.State.ESP.tracerMode = v
        notify("ESP", "Tracer: " .. v, 1.5, "radar")
    end})
    
    -- ================================ AUTO EXPAND ================================
    task.delay(0.5, function()
        pcall(function()
            for _,tab in pairs(Window.Tabs) do
                for _,section in ipairs(tab.Sections) do
                    if section.Expand then section:Expand() end
                end
            end
        end)
    end)
    
    -- ================================ INIT ================================
    core.FPS.set(120)
    getgenv()._XKID_RUNNING = true
    getgenv()._XKID_UI_LOADING = false
    
    notify("System", "XKID V2.0 AKTIF — Ready", 3, "rocket")
end

return UI