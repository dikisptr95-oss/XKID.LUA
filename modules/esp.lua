-- ================================ ESP MODULE ================================
-- by @WTF.XKID | Full ESP Engine dari script asli

local ESP = {}

function ESP.start(core, state, players, runService, camera, userInputService, onMobile)
    -- Inisialisasi cache jika belum ada
    if not state.ESP.cache then
        state.ESP.cache = core._XKID_ESP_CACHE or {}
        core._XKID_ESP_CACHE = state.ESP.cache
    end
    
    -- ================================ INIT PLAYER CACHE ================================
    local function initPlayerCache(player)
        if state.ESP.cache[player] then return end
        local cache = { texts = nil, tracer = nil, boxLines = {}, hl = nil, isSuspect = false, isGlitch = false, reason = "" }
        pcall(function()
            cache.texts = Drawing.new("Text")
            if cache.texts then
                cache.texts.Center = true
                cache.texts.Outline = true
                cache.texts.Font = 2
                cache.texts.Size = 13
                cache.texts.ZIndex = 2
            end
            cache.tracer = Drawing.new("Line")
            if cache.tracer then
                cache.tracer.Thickness = 1.5
                cache.tracer.ZIndex = 1
            end
            for i = 1, 4 do
                local line = Drawing.new("Line")
                if line then
                    line.Thickness = 1.5
                    line.ZIndex = 1
                    cache.boxLines[i] = line
                end
            end
        end)
        state.ESP.cache[player] = cache
    end

    -- ================================ CLEAR PLAYER CACHE ================================
    local function clearPlayerCache(player)
        local c = state.ESP.cache[player]
        if not c then return end
        pcall(function() if c.texts then c.texts:Remove() end end)
        pcall(function() if c.tracer then c.tracer:Remove() end end)
        for _,l in ipairs(c.boxLines) do pcall(function() if l then l:Remove() end end) end
        pcall(function() if c.hl then c.hl:Destroy() end end)
        state.ESP.cache[player] = nil
    end

    players.PlayerRemoving:Connect(clearPlayerCache)

    -- ================================ HELPER FUNGSI ================================
    local function getCharRoot(char)
        if not char then return nil end
        return char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart or char:FindFirstChild("Head") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char:FindFirstChildWhichIsA("BasePart")
    end

    -- ================================ ESP SORTED PLAYERS ================================
    local espsortedPlayers = {}
    task.spawn(function()
        while getgenv()._XKID_RUNNING do
            if state.ESP.active then
                local tempSorted = {}
                local myHrp = getCharRoot(core.Services.Players.LocalPlayer.Character)
                for _,p in pairs(players:GetPlayers()) do
                    if p ~= core.Services.Players.LocalPlayer and p.Character then
                        local isSus, isGlitch, reason = false, false, ""
                        for _,v in pairs(p.Character:GetChildren()) do
                            if v:IsA("BasePart") and (v.Size.X > 30 or v.Size.Y > 30 or v.Size.Z > 30) then
                                isSus = true
                                reason = "Map Blocker"
                                break
                            elseif v:IsA("Accessory") then
                                local h = v:FindFirstChild("Handle")
                                if h and h:IsA("BasePart") then
                                    if h.Size.Magnitude > 20 then
                                        isSus = true
                                        reason = "Huge Hat"
                                        break
                                    elseif h.Size.Magnitude > 10 or (h.Transparency < 0.1 and h.Material == Enum.Material.Neon) then
                                        isGlitch = true
                                        reason = "Glitch Acc"
                                    end
                                end
                            end
                        end
                        if not isSus and not isGlitch then
                            local hum = p.Character:FindFirstChildOfClass("Humanoid")
                            if hum then
                                local bws = hum:FindFirstChild("BodyWidthScale")
                                local bhs = hum:FindFirstChild("BodyHeightScale")
                                if (bws and bws.Value > 2) or (bhs and bhs.Value > 2) then
                                    isSus = true
                                    reason = "Glitch Avatar"
                                end
                            end
                        end
                        initPlayerCache(p)
                        if state.ESP.cache[p] then
                            state.ESP.cache[p].isSuspect = isSus
                            state.ESP.cache[p].isGlitch = isGlitch
                            state.ESP.cache[p].reason = reason
                        end
                        if myHrp then
                            local hrp = getCharRoot(p.Character)
                            local hum = p.Character:FindFirstChildOfClass("Humanoid")
                            if hrp and hum and hum.Health > 0 then
                                local dist = (hrp.Position - myHrp.Position).Magnitude
                                if dist <= state.ESP.maxDrawDistance then
                                    table.insert(tempSorted, { p = p, hrp = hrp, dist = dist, char = p.Character })
                                end
                            end
                        end
                    end
                end
                table.sort(tempSorted, function(a,b) return a.dist < b.dist end)
                espsortedPlayers = tempSorted
            end
            task.wait(0.5)
        end
    end)

    -- ================================ RENDER LOOP ================================
    runService.RenderStepped:Connect(function()
        if not state.ESP.active then return end
        local myHrp = getCharRoot(core.Services.Players.LocalPlayer.Character)
        if not myHrp then return end
        local vp = camera.ViewportSize
        local center = Vector2.new(vp.X / 2, vp.Y / 2)
        
        for _,c in pairs(state.ESP.cache) do
            pcall(function()
                if c.texts then c.texts.Visible = false end
                if c.tracer then c.tracer.Visible = false end
                for _,l in ipairs(c.boxLines) do if l then l.Visible = false end end
                if c.hl then c.hl.Enabled = false end
            end)
        end
        
        local hlCount = 0
        for _,data in ipairs(espsortedPlayers) do
            local player, char, hrp, dist = data.p, data.char, data.hrp, data.dist
            local c = state.ESP.cache[player]
            if not c then continue end
            local rootPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
            if not onScreen then continue end
            
            local isSus, isGlitch = c.isSuspect, c.isGlitch
            local useHl = isSus or isGlitch or state.ESP.highlightMode
            local txt = string.format("%s\n[%dm]", player.DisplayName, math.floor(dist))
            if isSus or isGlitch then txt = txt .. "\n⚠ " .. c.reason end
            
            local cColor = isSus and state.ESP.boxColor_S or (isGlitch and state.ESP.boxColor_G or state.ESP.nameColor)
            local tColor = isSus and state.ESP.tracerColor_S or (isGlitch and state.ESP.tracerColor_G or state.ESP.tracerColor_N)
            local bColor = isSus and state.ESP.boxColor_S or (isGlitch and state.ESP.boxColor_G or state.ESP.boxColor_N)
            
            pcall(function()
                if c.texts then
                    c.texts.Text = txt
                    c.texts.Color = cColor
                    c.texts.Position = Vector2.new(rootPos.X, rootPos.Y - 45)
                    c.texts.Visible = true
                end
                if state.ESP.tracerMode ~= "OFF" and c.tracer then
                    local origin = Vector2.new(vp.X / 2, vp.Y)
                    if state.ESP.tracerMode == "Center" then
                        origin = center
                    elseif state.ESP.tracerMode == "Mouse" then
                        local m = userInputService:GetMouseLocation()
                        origin = Vector2.new(m.X, m.Y)
                    end
                    c.tracer.From = origin
                    c.tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                    c.tracer.Color = tColor
                    c.tracer.Visible = true
                end
            end)
            
            if useHl and hlCount < 30 then
                hlCount = hlCount + 1
                pcall(function()
                    local top, topOn = camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0))
                    local bot, botOn = camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3.5, 0))
                    if topOn and botOn and #c.boxLines == 4 then
                        local bh = math.abs(top.Y - bot.Y)
                        local bw = bh * 0.6
                        c.boxLines[1].From = Vector2.new(rootPos.X - bw/2, top.Y)
                        c.boxLines[1].To = Vector2.new(rootPos.X + bw/2, top.Y)
                        c.boxLines[2].From = Vector2.new(rootPos.X + bw/2, top.Y)
                        c.boxLines[2].To = Vector2.new(rootPos.X + bw/2, bot.Y)
                        c.boxLines[3].From = Vector2.new(rootPos.X + bw/2, bot.Y)
                        c.boxLines[3].To = Vector2.new(rootPos.X - bw/2, bot.Y)
                        c.boxLines[4].From = Vector2.new(rootPos.X - bw/2, bot.Y)
                        c.boxLines[4].To = Vector2.new(rootPos.X - bw/2, top.Y)
                        for i = 1, 4 do c.boxLines[i].Color = bColor; c.boxLines[i].Visible = true end
                    end
                end)
                pcall(function()
                    if not c.hl or c.hl.Parent ~= char then
                        if c.hl then c.hl:Destroy() end
                        c.hl = Instance.new("Highlight", char)
                        c.hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    end
                    if c.hl then
                        c.hl.FillColor = bColor
                        c.hl.OutlineColor = Color3.new(1,1,1)
                        c.hl.Enabled = true
                    end
                end)
            end
        end
    end)
end

return ESP