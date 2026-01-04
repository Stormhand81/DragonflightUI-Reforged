DFRL:NewDefaults("Chat", {
    enabled = {true},
    showButtons = {true, "checkbox", nil, nil, "appearance", 1, "Show or hide chat buttons", "BUG: blizzards highlight blinks at the wrong position - fix soon", nil},
    chatDarkMode = {0, "slider", {0, 1}, "showButtons", "appearance", 2, "Adjust dark mode intensity", nil, nil},
    chatColor = {{1, 1, 1}, "colour", nil, "showButtons", "appearance", 3, "Change chat color", nil, nil},
    blizzardButtons = {false, "checkbox", nil, "showButtons", "chat basic", 4, "Use original Blizzard chat buttons", nil, nil},
    fadeChat = {false, "checkbox", nil, nil, "chat basic", 5, "Fade out chat text after 10 seconds", nil, nil}

})

DFRL:NewMod("Chat", 1, function()
    local Setup = {
        tex = DFRL:GetInfoOrCons("tex"),
    }

    function Setup:ChatFrame()
        ChatFrame1Tab:SetClampedToScreen(true)
    end

    Setup:ChatFrame()

    local callbacks = {}

    callbacks.chatDarkMode = function(value)
        local intensity = DFRL:GetTempDB("Chat", "chatDarkMode")
        local chatColor = DFRL:GetTempDB("Chat", "chatColor")
        local r, g, b = chatColor[1] * (1 - intensity), chatColor[2] * (1 - intensity), chatColor[3] * (1 - intensity)
        local color = value and {r, g, b} or {1, 1, 1}

        for i = 1, 5 do
            local tab = _G["ChatFrame"..i.."Tab"]
            if tab then
                local tabLeft = _G["ChatFrame"..i.."TabLeft"]
                local tabMiddle = _G["ChatFrame"..i.."TabMiddle"]
                local tabRight = _G["ChatFrame"..i.."TabRight"]

                if tabLeft then tabLeft:SetVertexColor(color[1], color[2], color[3]) end
                if tabMiddle then tabMiddle:SetVertexColor(color[1], color[2], color[3]) end
                if tabRight then tabRight:SetVertexColor(color[1], color[2], color[3]) end
            end
        end

        if ChatFrameMenuButton then
            local normalTexture = ChatFrameMenuButton:GetNormalTexture()
            if normalTexture then
                normalTexture:SetVertexColor(color[1], color[2], color[3])
            end

            local pushedTexture = ChatFrameMenuButton:GetPushedTexture()
            if pushedTexture then
                pushedTexture:SetVertexColor(color[1], color[2], color[3])
            end
        end

        for i = 1, 5 do
            local upButton = _G["ChatFrame"..i.."UpButton"]
            local downButton = _G["ChatFrame"..i.."DownButton"]
            local bottomButton = _G["ChatFrame"..i.."BottomButton"]

            if upButton then
                local normalTexture = upButton:GetNormalTexture()
                if normalTexture then
                    normalTexture:SetVertexColor(color[1], color[2], color[3])
                end

                local pushedTexture = upButton:GetPushedTexture()
                if pushedTexture then
                    pushedTexture:SetVertexColor(color[1], color[2], color[3])
                end
            end

            if downButton then
                local normalTexture = downButton:GetNormalTexture()
                if normalTexture then
                    normalTexture:SetVertexColor(color[1], color[2], color[3])
                end

                local pushedTexture = downButton:GetPushedTexture()
                if pushedTexture then
                    pushedTexture:SetVertexColor(color[1], color[2], color[3])
                end
            end

            if bottomButton then
                local normalTexture = bottomButton:GetNormalTexture()
                if normalTexture then
                    normalTexture:SetVertexColor(color[1], color[2], color[3])
                end

                local pushedTexture = bottomButton:GetPushedTexture()
                if pushedTexture then
                    pushedTexture:SetVertexColor(color[1], color[2], color[3])
                end
            end
        end
    end

    callbacks.chatColor = function(value)
        local intensity = DFRL:GetTempDB("Chat", "chatDarkMode")
        local r, g, b = value[1] * (1 - intensity), value[2] * (1 - intensity), value[3] * (1 - intensity)

        for i = 1, 5 do
            local tab = _G["ChatFrame"..i.."Tab"]
            if tab then
                local tabLeft = _G["ChatFrame"..i.."TabLeft"]
                local tabMiddle = _G["ChatFrame"..i.."TabMiddle"]
                local tabRight = _G["ChatFrame"..i.."TabRight"]

                if tabLeft then tabLeft:SetVertexColor(r, g, b) end
                if tabMiddle then tabMiddle:SetVertexColor(r, g, b) end
                if tabRight then tabRight:SetVertexColor(r, g, b) end
            end
        end

        if ChatFrameMenuButton then
            local normalTexture = ChatFrameMenuButton:GetNormalTexture()
            if normalTexture then
                normalTexture:SetVertexColor(r, g, b)
            end

            local pushedTexture = ChatFrameMenuButton:GetPushedTexture()
            if pushedTexture then
                pushedTexture:SetVertexColor(r, g, b)
            end
        end

        for i = 1, 5 do
            local upButton = _G["ChatFrame"..i.."UpButton"]
            local downButton = _G["ChatFrame"..i.."DownButton"]
            local bottomButton = _G["ChatFrame"..i.."BottomButton"]

            if upButton then
                local normalTexture = upButton:GetNormalTexture()
                if normalTexture then
                    normalTexture:SetVertexColor(r, g, b)
                end

                local pushedTexture = upButton:GetPushedTexture()
                if pushedTexture then
                    pushedTexture:SetVertexColor(r, g, b)
                end
            end

            if downButton then
                local normalTexture = downButton:GetNormalTexture()
                if normalTexture then
                    normalTexture:SetVertexColor(r, g, b)
                end

                local pushedTexture = downButton:GetPushedTexture()
                if pushedTexture then
                    pushedTexture:SetVertexColor(r, g, b)
                end
            end

            if bottomButton then
                local normalTexture = bottomButton:GetNormalTexture()
                if normalTexture then
                    normalTexture:SetVertexColor(r, g, b)
                end

                local pushedTexture = bottomButton:GetPushedTexture()
                if pushedTexture then
                    pushedTexture:SetVertexColor(r, g, b)
                end
            end
        end
    end

    callbacks.showButtons = function(value)
        if ChatFrameMenuButton then
            if value then
                ChatFrameMenuButton:Show()
            else
                ChatFrameMenuButton:Hide()
            end
        end

        for i = 1, 5 do
            local upButton = _G["ChatFrame"..i.."UpButton"]
            local downButton = _G["ChatFrame"..i.."DownButton"]
            local bottomButton = _G["ChatFrame"..i.."BottomButton"]

            if upButton then
                if value then
                    upButton:Show()
                else
                    upButton:Hide()
                end
            end

            if downButton then
                if value then
                    downButton:Show()
                else
                    downButton:Hide()
                end
            end

            if bottomButton then
                if value then
                    bottomButton:Show()
                else
                    bottomButton:Hide()
                end
            end
        end
    end

    callbacks.blizzardButtons = function(value)
        local buttonScale = 0.8

        if value then
            if ChatFrameMenuButton then
                ChatFrameMenuButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-Chat-Up")
                ChatFrameMenuButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
                ChatFrameMenuButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-Chat-Down")
                ChatFrameMenuButton:SetScale(buttonScale)
            end

            for i = 1, 5 do
                local upButton = _G["ChatFrame"..i.."UpButton"]
                local downButton = _G["ChatFrame"..i.."DownButton"]
                local bottomButton = _G["ChatFrame"..i.."BottomButton"]

                if upButton then
                    upButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Up")
                    upButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
                    upButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Down")
                    upButton:SetScale(buttonScale)
                end

                if downButton then
                    downButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
                    downButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
                    downButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down")
                    downButton:SetScale(buttonScale)
                end

                if bottomButton then
                    bottomButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollEnd-Up")
                    bottomButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
                    bottomButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollEnd-Down")
                    bottomButton:SetScale(buttonScale)
                end
            end
        else
            local menuTexture = Setup.tex.."chat\\chat_menu"
            local upTexture = Setup.tex .. "chat\\chat_up"
            local downTexture = Setup.tex .. "chat\\chat_down"
            local downFullTexture = Setup.tex .. "chat\\chat_down_full"

            if ChatFrameMenuButton then
                ChatFrameMenuButton:SetNormalTexture(menuTexture)
                ChatFrameMenuButton:SetHighlightTexture(menuTexture)
                ChatFrameMenuButton:SetPushedTexture(menuTexture)
                ChatFrameMenuButton:SetScale(buttonScale)
            end

            for i = 1, 5 do
                local upButton = _G["ChatFrame"..i.."UpButton"]
                local downButton = _G["ChatFrame"..i.."DownButton"]
                local bottomButton = _G["ChatFrame"..i.."BottomButton"]

                if upButton then
                    upButton:SetNormalTexture(upTexture)
                    upButton:SetHighlightTexture(upTexture)
                    upButton:SetPushedTexture(upTexture)
                    upButton:SetScale(buttonScale)
                end

                if downButton then
                    downButton:SetNormalTexture(downTexture)
                    downButton:SetHighlightTexture(downTexture)
                    downButton:SetPushedTexture(downTexture)
                    downButton:SetScale(buttonScale)
                end

                if bottomButton then
                    bottomButton:SetNormalTexture(downFullTexture)
                    bottomButton:SetHighlightTexture(downFullTexture)
                    bottomButton:SetPushedTexture(downFullTexture)
                    bottomButton:SetScale(buttonScale)
                end
            end
        end

        callbacks.chatDarkMode(DFRL:GetTempDB("Chat", "chatDarkMode"))
    end

    callbacks.fadeChat = function(value)
        for i = 1, NUM_CHAT_WINDOWS do
            local f = _G["ChatFrame"..i]
            if value then
                f:SetFadeDuration(0.1)
                f:SetTimeVisible(10)
            else
                f:SetFadeDuration(3)
                f:SetTimeVisible(180)
            end
        end
    end

    -- execute callbacks
    DFRL:NewCallbacks("Chat", callbacks)
end)
