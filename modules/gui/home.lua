DFRL:NewDefaults("Gui-home", {
    enabled = {true},

})

DFRL:NewMod("Gui-home", 3, function()
    --=================
    -- SETUP
    --=================
    local Base = DFRL.gui.Base
    local Setup = {
        font = DFRL:GetInfoOrCons("font"),
        PULSE_UPDATE_INTERVAL = 0.005,
        PULSE_ALPHA_STEP = 0.02,
        PULSE_MIN_ALPHA = 0.1,
        HOME_FADE_TIME = 0.1,
        HOME_STAY_TIME = 0.3,
        HOME_PAUSE_TIME = 0.01,
        HOME_TEXTS = {"Dragonflight", "UI", "Reforged"},

        HOME_PULSE_SPEED = 1.3,
        HOME_MIN_ALPHA = 0.5,
        HOME_MAX_ALPHA = 1.0,

        logoTex = nil,
        logoText = nil,
        leftLine = nil,
        rightLine = nil,
        logoStarted = false,
    }

    function Setup:Logo()
        local panel = Base.scrollChildren[1]
        local frame = CreateFrame("Frame", nil, panel)
        frame:SetWidth(150)
        frame:SetHeight(150)
        frame:SetPoint("TOP", panel, "TOP", 0, -150)

        Setup.logoText = DFRL.tools.CreateFont(frame, 14, Setup.HOME_TEXTS[1], {1, 1, 1}, "CENTER")
        Setup.logoText:SetPoint("CENTER", frame, "CENTER", 0, 0)
        Setup.logoText:SetTextColor(1, 1, 1, 0)

        Setup.logoTex = frame:CreateTexture()
        Setup.logoTex:SetAllPoints(frame)
        Setup.logoTex:SetTexture(DFRL:GetInfoOrCons("tex") .. "gui\\dfrl_logo")
        Setup.logoTex:SetAlpha(0)

        local accumulatedTime = 0
        local cur = 1
        local phase = "fadein"
        local logo = false
        local done = false
        local pulseTime = 0
        local wasVisible = Base.mainFrame:IsShown() and Base.selectedTab == 1
        DFRL.activeScripts["GUI HomeAnimation"] = wasVisible

        local updateScript = function()
            if (this.tick or 0) > GetTime() then return end
            this.tick = GetTime() + Setup.PULSE_UPDATE_INTERVAL

            local isVisible = Base.mainFrame:IsShown() and Base.selectedTab == 1

            if isVisible ~= wasVisible then
                DFRL.activeScripts["GUI HomeAnimation"] = isVisible
                wasVisible = isVisible
            end

            if not isVisible then return end

            accumulatedTime = accumulatedTime + Setup.PULSE_UPDATE_INTERVAL
            local t = accumulatedTime

            if logo then
                if not done then
                    local a = t / Setup.HOME_FADE_TIME
                    if a >= 1 then
                        a = 1
                        done = true
                        pulseTime = accumulatedTime
                    end
                    Setup.logoTex:SetAlpha(a)
                else
                    local pt = accumulatedTime - pulseTime
                    local p = (math.sin(pt * math.pi * 2 * Setup.HOME_PULSE_SPEED + math.pi/2) + 1) / 2
                    Setup.logoTex:SetAlpha(Setup.HOME_MIN_ALPHA + p * (Setup.HOME_MAX_ALPHA - Setup.HOME_MIN_ALPHA))
                end

            else
                if phase == "fadein" then
                    local a = t / Setup.HOME_FADE_TIME
                    if a >= 1 then
                        a = 1
                        phase = "stay"
                        accumulatedTime = 0
                    end
                    if cur == 1 or cur == 3 then
                        Setup.logoText:SetTextColor(1, 0.82, 0, a)
                    else
                        Setup.logoText:SetTextColor(1, 1, 1, a)
                    end
                elseif phase == "stay" then
                    if t >= Setup.HOME_STAY_TIME then
                        phase = "fadeout"
                        accumulatedTime = 0
                    end
                elseif phase == "fadeout" then
                    local a = 1 - (t / Setup.HOME_FADE_TIME)
                    if a <= 0 then
                        a = 0
                        phase = "pause"
                        accumulatedTime = 0
                    end
                    if cur == 1 or cur == 3 then
                        Setup.logoText:SetTextColor(1, 0.82, 0, a)
                    else
                        Setup.logoText:SetTextColor(1, 1, 1, a)
                    end
                elseif phase == "pause" then
                    if t >= Setup.HOME_PAUSE_TIME then
                        cur = cur + 1
                        if cur > 3 then
                            Setup.logoText:Hide()
                            logo = true
                            Setup.logoStarted = true
                            accumulatedTime = 0
                        else
                            Setup.logoText:SetText(Setup.HOME_TEXTS[cur])
                            if cur == 3 then
                                Setup.logoText:SetFont(Setup.font .. "BigNoodleTitling.ttf", 40, "OUTLINE")
                            end
                            phase = "fadein"
                            accumulatedTime = 0
                        end
                    end
                end
            end
        end

        local animationFrame = CreateFrame("Frame")
        animationFrame:SetScript("OnUpdate", updateScript)
        DFRL.activeScripts["GUI HomeAnimation"] = true

        panel:EnableMouseWheel(true)
        panel:SetScript("OnMouseWheel", function() end)
    end

    function Setup:Lines()
        if DFRL.activeScripts["GUI LinesAnimation"] then return end

        local panel = Base.scrollChildren[1]

        Setup.leftLine = panel:CreateTexture(nil, "OVERLAY")
        Setup.leftLine:SetTexture("Interface\\Buttons\\WHITE8x8")
        Setup.leftLine:SetPoint("TOPLEFT", panel, "TOPLEFT", 50, -225)
        Setup.leftLine:SetWidth(2)
        Setup.leftLine:SetHeight(1)
        Setup.leftLine:SetAlpha(1)

        Setup.rightLine = panel:CreateTexture(nil, "OVERLAY")
        Setup.rightLine:SetTexture("Interface\\Buttons\\WHITE8x8")
        Setup.rightLine:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -50, -225)
        Setup.rightLine:SetWidth(2)
        Setup.rightLine:SetHeight(1)
        Setup.rightLine:SetAlpha(1)

        local time = 0
        local done = false
        local wasVisible = Base.mainFrame:IsShown() and Base.selectedTab == 1
        DFRL.activeScripts["GUI LinesAnimation"] = wasVisible

        local script = function()
            if (this.tick or 0) > GetTime() then return end
            this.tick = GetTime() + Setup.PULSE_UPDATE_INTERVAL

            local isVisible = Base.mainFrame:IsShown() and Base.selectedTab == 1

            if isVisible ~= wasVisible then
                DFRL.activeScripts["GUI LinesAnimation"] = isVisible
                wasVisible = isVisible
            end

            if not isVisible or done then return end

            time = time + Setup.PULSE_UPDATE_INTERVAL
            local prog = time / 0.5
            if prog >= 1 then
                prog = 1
                done = true
            end
            local width = 2 + prog * 150
            Setup.leftLine:SetWidth(width)
            Setup.rightLine:SetWidth(width)
        end

        CreateFrame("Frame"):SetScript("OnUpdate", script)
    end

    Setup:Logo()
    Setup:Lines()

    DFRL.gui.Home = Setup
end)