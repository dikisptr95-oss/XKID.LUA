-- ================================ XKID CORE (MINIMAL WORKING) ================================
local Core = {}

-- Services
Core.Services = {
    Players = game:GetService("Players"),
    UserInputService = game:GetService("UserInputService"),
    RunService = game:GetService("RunService"),
    Lighting = game:GetService("Lighting"),
    CoreGui = game:GetService("CoreGui"),
    HttpService = game:GetService("HttpService"),
}

-- Helper sederhana
function Core.Helpers.getRoot()
    local char = Core.Services.Players.LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

function Core.Helpers.getHum()
    local char = Core.Services.Players.LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

-- State minimal
Core.State = {
    Move = { ws = 16, jp = 50 },
    ESP = { active = false },
}

-- Notify wrapper (akan terhubung ke WindUI nanti)
Core.Notify = function(title, content, duration, icon)
    print(string.format("[XKID] %s: %s", title, content))
end

-- FPS unlocker
function Core.FPS.set(target)
    pcall(function() if setfpscap then setfpscap(target or 120) end end)
end

-- ⚠️ PENTING: RETURN CORE
return Core