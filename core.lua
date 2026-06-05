-- ================================ XKID CORE (FIXED) ================================
local Core = {}

-- IMPORTANT
Core.Helpers = {}
Core.FPS = {}

-- ================================ SERVICES ================================
Core.Services = {
    Players = game:GetService("Players"),
    UserInputService = game:GetService("UserInputService"),
    RunService = game:GetService("RunService"),
    Lighting = game:GetService("Lighting"),
    CoreGui = game:GetService("CoreGui"),
    HttpService = game:GetService("HttpService"),
}

-- ================================ HELPERS ================================
function Core.Helpers.getRoot()
    local char = Core.Services.Players.LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

function Core.Helpers.getHum()
    local char = Core.Services.Players.LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

-- ================================ STATE ================================
Core.State = {
    Move = {
        ws = 16,
        jp = 50
    },

    ESP = {
        active = false
    }
}

-- ================================ NOTIFY ================================
Core.Notify = function(title, content, duration, icon)
    print(string.format("[XKID] %s: %s", tostring(title), tostring(content)))
end

-- ================================ FPS ================================
function Core.FPS.set(target)
    pcall(function()
        if setfpscap then
            setfpscap(target or 120)
        end
    end)
end

-- ================================ RETURN ================================
return Core
