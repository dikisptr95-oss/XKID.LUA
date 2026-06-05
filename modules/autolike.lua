-- ================================ AUTO LIKE MODULE ================================
-- by @WTF.XKID

local AutoLike = {}

function AutoLike.setup(core, state)
    local function getLikeRemotes()
        local remotes = core.Services.ReplicatedStorage:FindFirstChild("Remotes")
        if not remotes then return nil, nil end
        return remotes:FindFirstChild("GetLikeDataRemote"), remotes:FindFirstChild("LikePlayerEvent")
    end
    
    local function likeRandomPlayer()
        local _, likePlayer = getLikeRemotes()
        if not likePlayer then return false, "Remote not found" end
        local myRoot = core.Helpers.getRoot()
        local targets = {}
        for _,p in pairs(core.Services.Players:GetPlayers()) do
            if p ~= core.Services.Players.LocalPlayer then
                if state.AutoLike.radius > 0 and myRoot then
                    local theirRoot = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                    if theirRoot then
                        local dist = (theirRoot.Position - myRoot.Position).Magnitude
                        if dist <= state.AutoLike.radius then
                            table.insert(targets, p)
                        end
                    end
                else
                    table.insert(targets, p)
                end
            end
        end
        if #targets == 0 then return false, "No players in range" end
        local target
        if #targets == 1 then
            target = targets[1]
        else
            repeat
                target = targets[math.random(1, #targets)]
            until target ~= state.AutoLike.lastTarget or #targets <= 1
        end
        state.AutoLike.lastTarget = target
        local success = pcall(function() likePlayer:FireServer(target) end)
        if success then
            state.AutoLike.count = state.AutoLike.count + 1
            return true, target.DisplayName
        end
        return false, "Failed"
    end
    
    function AutoLike.start()
        if state.AutoLike.active then return end
        state.AutoLike.active = true
        state.AutoLike.thread = task.spawn(function()
            while state.AutoLike.active and getgenv()._XKID_RUNNING do
                local ok, result = likeRandomPlayer()
                if ok then
                    core.Notify("Auto Like", result .. " | Total: " .. state.AutoLike.count, 1.5, "heart")
                end
                local cd = math.random(state.AutoLike.minCD * 10, state.AutoLike.maxCD * 10) / 10
                task.wait(cd)
            end
            state.AutoLike.thread = nil
        end)
        core.Notify("Auto Like", "ON", 2, "heart")
    end
    
    function AutoLike.stop()
        state.AutoLike.active = false
        if state.AutoLike.thread then
            task.cancel(state.AutoLike.thread)
            state.AutoLike.thread = nil
        end
        core.Notify("Auto Like", "OFF", 1.5, "heart")
    end
    
    function AutoLike.getCount()
        return state.AutoLike.count
    end
    
    return AutoLike
end

return AutoLike