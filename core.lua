-- ================================ XKID CORE ================================
-- by @WTF.XKID | Core module untuk semua fitur

local Core = {}

-- ================================ SERVICES ================================
Core.Services = {
    RunService = game:GetService("RunService"),
    HttpService = game:GetService("HttpService"),
    TweenService = game:GetService("TweenService"),
    Players = game:GetService("Players"),
    UserInputService = game:GetService("UserInputService"),
    VirtualUser = pcall(function() return game:GetService("VirtualUser") end) and game:GetService("VirtualUser") or nil,
    Lighting = game:GetService("Lighting"),
    TeleportService = game:GetService("TeleportService"),
    StatsService = game:GetService("Stats"),
    CoreGui = game:GetService("CoreGui"),
    TextChatService = game:GetService("TextChatService"),
    StarterGui = game:GetService("StarterGui"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    MarketplaceService = game:GetService("MarketplaceService"),
    VirtualInputManager = pcall(function() return game:GetService("VirtualInputManager") end) and game:GetService("VirtualInputManager") or nil,
}

local LP = Core.Services.Players.LocalPlayer
local Camera = workspace.CurrentCamera
local onMobile = not Core.Services.UserInputService.KeyboardEnabled

-- ================================ EXECUTOR DETECTION ================================
Core.Executor = {
    name = "Unknown",
    has_writefile = false,
    has_readfile = false,
    has_listfiles = false,
    has_isfolder = false,
    has_makefolder = false,
}

pcall(function()
    local e = identifyexecutor and identifyexecutor() or getexecutorname and getexecutorname() or "Unknown"
    Core.Executor.name = e
end)

Core.Executor.has_writefile = type(writefile) == "function"
Core.Executor.has_readfile = type(readfile) == "function"
Core.Executor.has_listfiles = type(listfiles) == "function"
Core.Executor.has_isfolder = type(isfolder) == "function"
Core.Executor.has_makefolder = type(makefolder) == "function"

-- ================================ FPS UNLOCKER ================================
function Core.FPS.set(targetFPS)
    targetFPS = targetFPS or 120
    pcall(function() if setfpscap then setfpscap(targetFPS) end end)
    pcall(function()
        local rs = settings():GetService("Rendering")
        if rs and rs.SetTargetFrameRate then rs:SetTargetFrameRate(targetFPS) end
    end)
    pcall(function()
        local ws = game:GetService("Workspace")
        if ws and ws.SetTargetFrameRate then ws:SetTargetFrameRate(targetFPS) end
    end)
end

-- ================================ ORIGINAL LIGHTING ================================
Core.OriginalLighting = {
    ClockTime = Core.Services.Lighting.ClockTime,
    Brightness = Core.Services.Lighting.Brightness,
    Ambient = Core.Services.Lighting.Ambient,
    OutdoorAmbient = Core.Services.Lighting.OutdoorAmbient,
    GlobalShadows = Core.Services.Lighting.GlobalShadows,
    ExposureCompensation = Core.Services.Lighting.ExposureCompensation,
    FogEnd = Core.Services.Lighting.FogEnd,
}

-- ================================ HELPER FUNCTIONS ================================
function Core.Helpers.getRoot()
    return LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
end

function Core.Helpers.getHum()
    return LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
end

function Core.Helpers.getCharRoot(char)
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart or char:FindFirstChild("Head") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char:FindFirstChildWhichIsA("BasePart")
end

function Core.Helpers.getDisplayNames()
    local t = {}
    for _,p in pairs(Core.Services.Players:GetPlayers()) do 
        if p ~= LP then table.insert(t, p.DisplayName) end 
    end
    if #t == 0 then table.insert(t, "N/A") end
    return t
end

function Core.Helpers.getDisplayNamesWithSelf()
    local t = { "[Self]" }
    for _,p in pairs(Core.Services.Players:GetPlayers()) do 
        if p ~= LP then table.insert(t, p.DisplayName) end 
    end
    if #t == 1 then table.insert(t, "N/A") end
    return t
end

function Core.Helpers.findPlayerByDisplay(str)
    if str == "[Self]" then return LP end
    for _,p in pairs(Core.Services.Players:GetPlayers()) do
        if p.DisplayName == str or p.Name == str then return p end
    end
    return nil
end

function Core.Helpers.formatTime(seconds)
    local m = math.floor(seconds / 60)
    local s = seconds % 60
    return string.format("%02d:%02d", m, s)
end

function Core.Helpers.makeBar(val, maxVal, len)
    local fill = math.clamp(math.floor((val / maxVal) * len), 0, len)
    return string.rep("█", fill) .. string.rep("░", len - fill)
end

function Core.Helpers.isOnGround()
    local r = Core.Helpers.getRoot()
    if not r then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LP.Character }
    return workspace:Raycast(r.Position, Vector3.new(0, -5, 0), params) ~= nil
end

-- ================================ GLOBAL STATE ================================
Core.State = {
    Move = { ws = 16, jp = 50, ncp = false, infJ = false, flyS = 60, autoWalk = false, autoWalkSpeed = 16 },
    Fly = { active = false, bv = nil, bg = nil, _keys = {} },
    HardFling = { active = false, power = 10000, mode = "Spin", currentPower = 0, rampUpActive = false },
    Security = { afkActive = false, shiftLock = false, shiftLockGyro = nil, antiLag = false },
    Cinema = { hideUI = false, cachedGuis = {} },
    Avatar = { isRefreshing = false },
    Utility = { chatLog = false, chatTargets = {}, chatHistory = {} },
    AutoLike = { active = false, thread = nil, lastTarget = nil, count = 0, radius = 100, minCD = 2, maxCD = 6 },
    CustomFilter = { tintR = 255, tintG = 255, tintB = 255, saturation = 0, contrast = 0, brightness = 0, exposure = 0, bloomIntensity = 0, bloomSize = 24, clockTime = 14, dofIntensity = 0, dofDistance = 50 },
    SelfSpec = { active = false, mode = "Manual", dist = 8, height = 3, orbitYaw = 0, orbitPitch = 20, fpYaw = 0, fpPitch = 0, fov = 70, origFov = 70, roll = 0, radius = 8, speed = 1 },
    ESP = { active = false, cache = {}, tracerMode = "Bottom", maxDrawDistance = 300, highlightMode = false, 
            boxColor_N = Color3.fromRGB(0,255,150), boxColor_S = Color3.fromRGB(220,20,60), boxColor_G = Color3.fromRGB(255,165,0),
            tracerColor_N = Color3.fromRGB(0,200,255), tracerColor_S = Color3.fromRGB(220,20,60), tracerColor_G = Color3.fromRGB(255,165,0),
            nameColor = Color3.fromRGB(255,255,255) },
}

Core.ColorMap = {
    Merah = Color3.fromRGB(255,0,0), Hijau = Color3.fromRGB(0,255,0), Biru = Color3.fromRGB(0,0,255),
    Kuning = Color3.fromRGB(255,255,0), Ungu = Color3.fromRGB(255,0,255), Cyan = Color3.fromRGB(0,255,255),
    Orange = Color3.fromRGB(255,165,0), Pink = Color3.fromRGB(255,105,180), Putih = Color3.fromRGB(255,255,255),
    Hitam = Color3.fromRGB(0,0,0), Crimson = Color3.fromRGB(220,20,60),
}

-- ================================ GLOBAL VARS ================================
Core.StartTime = os.time()
Core.SharedFPS = 60
Core.SharedPing = 0
Core.CachedMapName = nil
Core.LastMapCheck = 0

-- ================================ CONNECTION TRACKER ================================
Core.Connections = {}
function Core.TrackConnection(conn)
    table.insert(Core.Connections, conn)
    return conn
end

-- ================================ HTTP REQUEST ================================
function Core.HttpRequest(options)
    local syn_req = syn and syn.request
    local fluxus_req = fluxus and fluxus.request
    local http_req = http and http.request
    local request_func = http_request or request or syn_req or fluxus_req or http_req
    
    if not request_func then
        local httpService = Core.Services.HttpService
        return {
            StatusCode = 200,
            Body = httpService:GetAsync(options.Url, true),
            Success = true
        }
    end
    return request_func(options)
end

-- ================================ NOTIFY WRAPPER ================================
function Core.Notify(title, content, duration, icon)
    pcall(function() 
        if Core.WindUI then
            Core.WindUI:Notify({ Title = title, Content = content, Duration = duration or 2, Icon = icon or "bell" })
        end
    end)
end

-- ================================ GET CONFIG LIST ================================
function Core.GetConfigList()
    local list = {}
    if Core.Executor.has_isfolder and Core.Executor.has_listfiles then
        pcall(function()
            if isfolder and isfolder("XKID_HUB") then
                for _,file in ipairs(listfiles("XKID_HUB")) do
                    if file:match("%.json$") then
                        local name = file:match("([^/\\]+)%.json$")
                        if name then table.insert(list, name) end
                    end
                end
            end
        end)
    end
    if #list == 0 then table.insert(list, "No config") end
    return list
end

-- ================================ CLEANUP OLD INSTANCE ================================
function Core.Cleanup()
    if getgenv()._XKID_RUNNING then 
        getgenv()._XKID_RUNNING = false
        task.wait(0.5) 
    end
    
    if getgenv()._XKID_ESP_CACHE then
        for _,c in pairs(getgenv()._XKID_ESP_CACHE) do
            pcall(function()
                if c.texts then c.texts:Remove() end
                if c.tracer then c.tracer:Remove() end
                if c.boxLines then for _,l in ipairs(c.boxLines) do l:Remove() end end
                if c.hl then c.hl:Destroy() end
            end)
        end
    end
    getgenv()._XKID_ESP_CACHE = {}
    
    if getgenv()._XKID_LOADED then
        pcall(function()
            for _,v in pairs(Core.Services.CoreGui:GetChildren()) do
                if v.Name == "WindUI" or v.Name == "XKID_FreecamUI" or v.Name == "XKID_SelfSpecUI" or v.Name == "XKID_FlyUI" then
                    v:Destroy()
                end
            end
            for _,v in pairs(Core.Services.Lighting:GetChildren()) do
                if v.Name == "_XKID_FILTER" or v.Name == "_XKID_DOF" then v:Destroy() end
            end
            if getgenv()._XKID_CONNS then
                for _,c in pairs(getgenv()._XKID_CONNS) do pcall(function() c:Disconnect() end) end
            end
        end)
        pcall(function() Core.Services.RunService:UnbindFromRenderStep("XKIDFreecam") end)
        pcall(function() Core.Services.RunService:UnbindFromRenderStep("XKIDFly") end)
        pcall(function() Core.Services.RunService:UnbindFromRenderStep("XKIDSpec") end)
        pcall(function() Core.Services.RunService:UnbindFromRenderStep("XKIDSelfSpec") end)
        pcall(function() Core.Services.RunService:UnbindFromRenderStep("XKIDShiftLock") end)
        pcall(function() Core.Services.RunService:UnbindFromRenderStep("XKIDAutoWalk") end)
    end
end

-- ================================ TRACKING VARS UNTUK CLEANUP ================================
getgenv()._XKID_LOADED = true
getgenv()._XKID_RUNNING = true
getgenv()._XKID_CONNS = {}
getgenv()._XKID_ESP_CACHE = Core.State.ESP.cache

-- ================================ RETURN CORE ================================
return Core