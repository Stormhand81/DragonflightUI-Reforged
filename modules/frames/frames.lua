DFRL:NewDefaults("Frames", {
    enabled = {true},
})

DFRL:NewMod("Frames", 2, function()
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:SetScript("OnEvent", function()
        f:UnregisterEvent("PLAYER_ENTERING_WORLD")

        local framesToMakeMovable = {
            PlayerFrame,
            TargetFrame,
            TargetofTargetFrame,
            PartyMemberFrame1,
            PartyMemberFrame2,
            PartyMemberFrame3,
            PartyMemberFrame4,
            DFRL.mainBar,
            MultiBarBottomLeft,
            MultiBarBottomRight,
            MultiBarLeft,
            MultiBarRight,
            DFRL.newPetBar,
            DFRL.newShapeshiftBar,
            DFRL.xpBar,
            DFRL.repBar,
            DFRL.castbar,
            MainMenuBarBackpackButton,
            DFRL.microMenuContainer,
            DFRL.netStatsFrame,
            Minimap,
            DFRL.topPanel,
            DFRL.questframe,
            BuffButton0,
            BuffButton8,
            TempEnchant1,
            BuffButton16,
            BuffButton32,
            QuestTimerFrame,

            -- 3rd party
            DFRL.PWB_Panel,
        }

        local function SaveFramePosition(frame)
            local name = frame:GetName()
            if not name then return end

            local x, y = frame:GetLeft(), frame:GetTop()
            DFRL_FRAMEPOS[name] = {x = x, y = y}
        end

        local function RestoreFramePositions()
            if not DFRL_FRAMEPOS then return end
            for name, pos in pairs(DFRL_FRAMEPOS) do
                local frame = _G[name]
                if frame then
                    frame:ClearAllPoints()
                    frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", pos.x, pos.y)
                end
            end
        end

        -- grid
        local grid = CreateFrame("Frame", nil, UIParent)
        grid:SetAllPoints(UIParent)
        grid:Hide()

        -- grid lines
        local size = 1
        local line = {}

        local width = GetScreenWidth()
        local height = GetScreenHeight()

        local ratio = width / GetScreenHeight()
        local rheight = GetScreenHeight() * ratio

        local wStep = width / 64
        local hStep = rheight / 64

        -- vertical lines
        for i = 0, 64 do
            if i == 64 / 2 then
                line = grid:CreateTexture(nil, 'BORDER')
                line:SetTexture(.8, .6, 0)
            else
                line = grid:CreateTexture(nil, 'BACKGROUND')
                line:SetTexture(0, 0, 0, .2)
            end
            line:SetPoint("TOPLEFT", grid, "TOPLEFT", i*wStep - (size/2), 0)
            line:SetPoint('BOTTOMRIGHT', grid, 'BOTTOMLEFT', i*wStep + (size/2), 0)
        end

        -- horizontal lines
        for i = 1, floor(height/hStep) do
            if i == floor(height/hStep / 2) then
                line = grid:CreateTexture(nil, 'BORDER')
                line:SetTexture(.8, .6, 0)
            else
                line = grid:CreateTexture(nil, 'BACKGROUND')
                line:SetTexture(0, 0, 0, .2)
            end
            line:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -(i*hStep) + (size/2))
            line:SetPoint('BOTTOMRIGHT', grid, 'TOPRIGHT', 0, -(i*hStep + size/2))
        end

        local flag -- flag to hide/show certain elements like castbar etc.
        local function MakeFrameMovable(frame)
            if not frame then return end

            frame:EnableMouse(true)
            frame:SetMovable(true)

            local overlay = CreateFrame("Frame", nil, frame)
            overlay:SetPoint("TOPLEFT", frame, "TOPLEFT", -10, 10)
            overlay:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 10, -10)
            overlay:SetFrameStrata("TOOLTIP")
            overlay:SetFrameLevel(100)
            overlay:SetToplevel(true)
            overlay:EnableMouse(true)
            overlay:SetBackdrop({
                bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                tile = true,
                tileSize = 32,
                edgeSize = 16,
                insets = { left = 0, right = 0, top = 0, bottom = 0 }
            })
            overlay:SetBackdropColor(1, 0.82, 0, 0.5)
            overlay:SetBackdropBorderColor(1, 0.82, 0, 1)
            overlay:Hide()

            -- overlay drags the frame
            overlay:SetScript("OnMouseDown", function()
                frame:StartMoving()
            end)

            overlay:SetScript("OnMouseUp", function()
                local frameName = frame:GetName()

                -- set the actionbars movable to false
                if frameName == "MultiBarBottomLeft" or frameName == "MultiBarBottomRight" then
                    DFRL:SetTempDBNoCallback("actionbars", "movable", false)
                end
                frame:StopMovingOrSizing()
                SaveFramePosition(frame)
            end)

            local function CreateDirectionButton(dir, xOffset, yOffset, text)
                local button = CreateFrame("Button", nil, overlay, "UIPanelButtonTemplate")
                button:SetWidth(14)
                button:SetHeight(14)
                button:SetPoint(dir, overlay, dir, 0, 0)
                button:SetText(text)
                button:GetNormalTexture():SetVertexColor(0, 0, 0)
                button:GetHighlightTexture():SetVertexColor(0.3, 0.3, 0.3)
                button:GetPushedTexture():SetVertexColor(0.2, 0.2, 0.2)
                button:SetScript("OnClick", function()
                    frame:ClearAllPoints()
                    local x, y = frame:GetLeft() + xOffset, frame:GetTop() + yOffset
                    frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y)
                    SaveFramePosition(frame)
                end)
                return button
            end

            CreateDirectionButton("TOP", 0, 1, "U")
            CreateDirectionButton("LEFT", -1, 0, "L")
            CreateDirectionButton("RIGHT", 1, 0, "R")
            CreateDirectionButton("BOTTOM", 0, -1, "D")

            -- overlay visibility
            local controlFrame = CreateFrame("Frame")
            controlFrame:SetScript("OnUpdate", function()
                if (this.tick or 0) > GetTime() then return end
                this.tick = GetTime() + 0.1

                if IsControlKeyDown() and IsShiftKeyDown() and IsAltKeyDown() then
                    flag = true
                    DFRL.activeScripts["FrameControlScript"] = true

                    if DFRL.castbar then
                        DFRL.castbar:Show()
                        DFRL.castbar.bar:Hide() -- bug fix
                    end

                    FramerateLabel:Show()

                    if DFRL.netStatsFrame then
                        DFRL.netStatsFrame:Show()
                    end

                    -- BuffButton8:Show() -- doesnt work yet
                    -- TargetUnit("player")
                    -- TargetFrame:Show()

                    overlay:Show()
                    grid:Show()
                else
                    if flag == true then
                        -- ClearTarget()
                        -- TargetFrame:Hide()
                        if DFRL.castbar then
                            DFRL.castbar.bar:Show()
                            DFRL.castbar:Hide()
                        end

                        FramerateLabel:Hide()

                        if DFRL.netStatsFrame then
                            DFRL.netStatsFrame:Hide()
                        end
                        -- BuffButton8:Hide()

                        -- false to prevent from hiding again
                        flag = false
                    end
                    overlay:Hide()
                    grid:Hide()
                    frame:StopMovingOrSizing()
                    DFRL.activeScripts["FrameControlScript"] = false
                end
            end)

            frame:SetScript("OnDragStart", function()
                if IsControlKeyDown() and IsShiftKeyDown() and IsAltKeyDown() then
                    frame:StartMoving()
                end
            end)

            frame:SetScript("OnDragStop", function()
                frame:StopMovingOrSizing()
                SaveFramePosition(frame)
            end)
        end

        -- make frames from list movable
        for i = 1, table.getn(framesToMakeMovable) do
            if framesToMakeMovable[i] then
                MakeFrameMovable(framesToMakeMovable[i])
            end
        end

        -- init
        RestoreFramePositions()
    end)

    DFRL.activeScripts["FrameControlScript"] = false
end)
