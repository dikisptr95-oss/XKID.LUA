-- ================================ LOGGER MODULE ================================
-- by @WTF.XKID | Full Chat Logger Engine dari script asli

local Logger = {}

function Logger.setup(core, state)
    local chatLogPanel = nil
    
    -- ================================ INTERNAL: ON CHAT ================================
    local function onChat(senderName, message)
        if not state.Utility.chatLog then return end
        if #state.Utility.chatTargets == 0 then return end
        
        local cleanSender = senderName:lower():match("^%s*(.-)%s*$")
        for _,target in ipairs(state.Utility.chatTargets) do
            local cleanTarget = target:lower():match("^%s*(.-)%s*$")
            if cleanSender == cleanTarget then
                local entry = string.format("[%s] %s: %s", os.date("%H:%M:%S"), senderName, message)
                table.insert(state.Utility.chatHistory, entry)
                if #state.Utility.chatHistory > 50 then 
                    table.remove(state.Utility.chatHistory, 1) 
                end
                core.Notify("Chat", senderName .. ": " .. message, 2, "message-circle")
                break
            end
        end
        Logger.updatePanel()
    end
    
    -- ================================ SETUP CHAT LISTENERS ================================
    local function setupListeners()
        -- TextChatService (modern)
        if core.Services.TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            pcall(function()
                core.TrackConnection(core.Services.TextChatService.MessageReceived:Connect(function(msg)
                    if msg.TextSource then 
                        onChat(msg.TextSource.Name, msg.Text) 
                    end
                end))
            end)
        end
        
        -- Legacy chat
        local function connectLegacyChat(player)
            pcall(function()
                core.TrackConnection(player.Chatted:Connect(function(msg) 
                    onChat(player.DisplayName, msg) 
                end))
            end)
        end
        
        for _,p in pairs(core.Services.Players:GetPlayers()) do
            if p ~= core.Services.Players.LocalPlayer then 
                connectLegacyChat(p) 
            end
        end
        
        core.TrackConnection(core.Services.Players.PlayerAdded:Connect(function(p) 
            if p ~= core.Services.Players.LocalPlayer then 
                connectLegacyChat(p) 
            end
        end))
    end
    
    -- ================================ START LOGGER ================================
    function Logger.start()
        state.Utility.chatLog = true
        core.Notify("Logger", "ON", 1.5, "terminal")
    end
    
    -- ================================ STOP LOGGER ================================
    function Logger.stop()
        state.Utility.chatLog = false
        core.Notify("Logger", "OFF", 1.5, "terminal")
    end
    
    -- ================================ SET TARGETS ================================
    function Logger.setTargets(selected)
        state.Utility.chatTargets = {}
        if selected and typeof(selected) == "table" then
            for _,name in ipairs(selected) do
                table.insert(state.Utility.chatTargets, tostring(name))
            end
        end
        if #state.Utility.chatTargets > 0 then
            core.Notify("Logger", "Tracking " .. #state.Utility.chatTargets .. " target(s)", 1.5, "terminal")
        end
    end
    
    -- ================================ CLEAR TARGETS ================================
    function Logger.clearTargets()
        state.Utility.chatTargets = {}
        core.Notify("Logger", "Targets cleared", 1.5, "terminal")
    end
    
    -- ================================ CLEAR HISTORY ================================
    function Logger.clearHistory()
        state.Utility.chatHistory = {}
        if chatLogPanel then
            pcall(function() chatLogPanel:SetDesc("Belum ada chat...") end)
        end
        core.Notify("Logger", "History cleared", 1.5, "terminal")
    end
    
    -- ================================ GET HISTORY ================================
    function Logger.getHistory()
        return state.Utility.chatHistory
    end
    
    -- ================================ SET PANEL ================================
    function Logger.setPanel(panel)
        chatLogPanel = panel
        Logger.updatePanel()
    end
    
    -- ================================ UPDATE PANEL ================================
    function Logger.updatePanel()
        if chatLogPanel and state.Utility.chatLog then
            pcall(function()
                local t = table.concat(state.Utility.chatHistory, "\n")
                if #t > 2000 then t = t:sub(-2000) end
                if #t == 0 then t = "Belum ada chat..." end
                chatLogPanel:SetDesc(t)
            end)
        end
    end
    
    -- ================================ GET TARGET LIST ================================
    function Logger.getAvailableTargets()
        local targets = {}
        for _,p in pairs(core.Services.Players:GetPlayers()) do
            if p ~= core.Services.Players.LocalPlayer then
                table.insert(targets, p.DisplayName)
            end
        end
        if #targets == 0 then table.insert(targets, "N/A") end
        return targets
    end
    
    -- ================================ IS LOGGER ACTIVE ================================
    function Logger.isActive()
        return state.Utility.chatLog
    end
    
    -- Setup listeners saat module di-load
    setupListeners()
    
    return Logger
end

return Logger