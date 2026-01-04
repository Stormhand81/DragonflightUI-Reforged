setfenv(1, DFRL:GetEnv())

local Setup = {
    welcomeConfig = {
        width = 450,
        height = 400,
        timerDuration = 10,
        barWidth = 200,
        barHeight = 3,
        fadeTime = 0.4,
    },

    patchConfig = {
        width = 400,
        height = 210,
        timerDuration = 10,
        barWidth = 200,
        barHeight = 3,
        title = "|cFFFF0000Important Patch Warning|r",
        text = "Patch 2.0.11 implemented the pvp icon natively.\n\nDo not place the 'TargetingFrame' folder into\nyour WoW/Interface/ dir anymore.\nDeactivate module for Blizzard default.",
        additionalText = "",
        version = "2.0.11",
    },

    welcomeFrame = nil,
}

function Setup:TempDBForSwitching(isDarkMode)
    DFRL.tempDB = {}

    local src = isDarkMode and DFRL.profiles.darkMode or DFRL.profiles.lightMode
    if not src then return end

    for moduleName, moduleTable in pairs(src) do
        if moduleTable then
            DFRL.tempDB[moduleName] = {}
            for key, value in pairs(moduleTable) do
                if value then
                    DFRL.tempDB[moduleName][key] = value
                end
            end
        end
    end

    DFRL:TriggerAllCallbacks()
    DFRL.gui.Base:UpdateHandler()
end

function Setup:WelcomePage()
    if not self.welcomeFrame then
        self.welcomeFrame = CreateFrame("Frame", "DFRL_WelcomeFrame", UIParent)
    end
    self.welcomeFrame:SetWidth(self.welcomeConfig.width)
    self.welcomeFrame:SetHeight(self.welcomeConfig.height)
    self.welcomeFrame:SetPoint("CENTER", 0, 0)
    self.welcomeFrame:SetFrameStrata("TOOLTIP")
    self.welcomeFrame:SetToplevel(true)
    self.welcomeFrame:SetBackdrop{
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    }
    self.welcomeFrame:EnableMouse(true)

    T.GradientLine(self.welcomeFrame, "TOP", 1)
    T.GradientLine(self.welcomeFrame, "TOP", -60, nil, 200)
    T.GradientLine(self.welcomeFrame, "TOP", -290, nil, 200)
    T.GradientLine(self.welcomeFrame, "BOTTOM", -1, 3)

    local title = DFRL.tools.CreateFont(self.welcomeFrame, 18, "|cFFFFFFFFWelcome to|r |cFFFFD700Dragonflight|r: |cFFFFFFFFReforged|r |cFFFFD7002.0")
    title:SetPoint("TOP", 0, -25)

    local text = DFRL.tools.CreateFont(self.welcomeFrame, 15, "Tip:\nHold CTRL + SHIFT + ALT to move frames.\n\n\nBefore reporting bugs:\n|cffff6060Please disable all other addons|n except for Dragonflight: Reforged.|r\n\n90% of bug reports lead to conflicts with other addons.\nThank you for helping us keep bug reports accurate.\n\nEnjoy |cFFFFD700Dragonflight|r and dont forget to update. ")
    text:SetPoint("TOP", title, "BOTTOM", 0, -40)
    text:SetWidth(380)

    local okBtn = DFRL.tools.CreateButton(self.welcomeFrame, "Okay", 65, 27)
    okBtn:SetPoint("BOTTOM", 0, 60)
    okBtn:Disable()

    local menuBtn = DFRL.tools.CreateButton(self.welcomeFrame, "Menu", 65, 27)
    menuBtn:SetPoint("TOP", okBtn, "BOTTOM", 0, -10)
    menuBtn:Disable()

    local lightBtn = DFRL.tools.CreateButton(self.welcomeFrame, "Light Mode", 50, 24, true)
    lightBtn:SetPoint("RIGHT", okBtn, "LEFT", -15, -13)
    lightBtn:SetScript("OnClick", function()
        Setup:TempDBForSwitching(false)
    end)

    local darkBtn = DFRL.tools.CreateButton(self.welcomeFrame, "Dark Mode", 50, 24, true)
    darkBtn:SetPoint("LEFT", okBtn, "RIGHT", 15, -13)
    darkBtn:SetScript("OnClick", function()
        Setup:TempDBForSwitching(true)
    end)

    menuBtn:SetScript("OnClick", function()
        UIFrameFadeOut(self.welcomeFrame, self.welcomeConfig.fadeTime, 1, 0)
        local hideTimer = 0
        self.welcomeFrame:SetScript("OnUpdate", function()
            hideTimer = hideTimer + arg1
            if hideTimer >= self.welcomeConfig.fadeTime then
                self.welcomeFrame:Hide()
                self.welcomeFrame:SetScript("OnUpdate", nil)
                _G.SlashCmdList["DFRL"]()
            end
        end)
        local char = UnitName("player")
        DFRL_CUR_PROFILE[char .. "_firstRun"] = true
    end)

    okBtn:SetScript("OnClick", function()
        UIFrameFadeOut(self.welcomeFrame, self.welcomeConfig.fadeTime, 1, 0)
        local hideTimer = 0
        self.welcomeFrame:SetScript("OnUpdate", function()
            hideTimer = hideTimer + arg1
            if hideTimer >= self.welcomeConfig.fadeTime then
                self.welcomeFrame:Hide()
                self.welcomeFrame:SetScript("OnUpdate", nil)
            end
        end)
        local char = UnitName("player")
        DFRL_CUR_PROFILE[char .. "_firstRun"] = true
    end)

    local barWidth = self.welcomeConfig.barWidth
    local barHeight = self.welcomeConfig.barHeight
    local timerBar = self.welcomeFrame:CreateTexture(nil, "OVERLAY")
    timerBar:SetTexture("Interface\\Buttons\\WHITE8x8")
    timerBar:SetVertexColor(1, 0.82, 0)
    timerBar:SetPoint("BOTTOM", self.welcomeFrame, "BOTTOM", 0, 5)
    timerBar:SetWidth(barWidth)
    timerBar:SetHeight(barHeight)

    local elapsed = 0
    self.welcomeFrame:SetScript("OnUpdate", function()
        elapsed = elapsed + arg1
        if elapsed >= self.welcomeConfig.timerDuration then
            okBtn:Enable()
            menuBtn:Enable()
            timerBar:Hide()
            self.welcomeFrame:SetScript("OnUpdate", nil)
            DFRL.activeScripts["WelcomePageScript"] = false
        else
            timerBar:SetWidth(barWidth * (1 - elapsed / self.welcomeConfig.timerDuration))
            DFRL.activeScripts["WelcomePageScript"] = true
        end
    end)
end

function Setup:PatchWarning()
    local patchFrame = CreateFrame("Frame", "DFRL_WelcomeFrame", UIParent)
    patchFrame:SetWidth(self.patchConfig.width)
    patchFrame:SetHeight(self.patchConfig.height)
    patchFrame:SetPoint("TOP", 0, -5)
    patchFrame:SetBackdrop{ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background"}
    patchFrame:EnableMouse(true)

    T.GradientLine(patchFrame, "TOP", -0)
    T.GradientLine(patchFrame, "BOTTOM", 0)

    local title = DFRL.tools.CreateFont(patchFrame, 18, self.patchConfig.title)
    title:SetPoint("TOP", 0, -20)

    local fullText = self.patchConfig.text
    if self.patchConfig.additionalText ~= "" then
        fullText = fullText .. "\n\n|cFFFF0000" .. self.patchConfig.additionalText .. "|r"
    end

    local text = DFRL.tools.CreateFont(patchFrame, 15, fullText)
    text:SetPoint("TOP", title, "BOTTOM", 0, -16)
    text:SetWidth(380)

    local okBtn = DFRL.tools.CreateButton(patchFrame, "Okay", 120, 24)
    okBtn:SetPoint("BOTTOM", 0, 20)
    okBtn:Disable()

    okBtn:SetScript("OnClick", function()
        patchFrame:Hide()
        DFRL:SetTempDBNoCallback("Generic", "patchWarnVersion", self.patchConfig.version)
    end)

    local barWidth = self.patchConfig.barWidth
    local barHeight = self.patchConfig.barHeight
    local timerBar = patchFrame:CreateTexture(nil, "OVERLAY")
    timerBar:SetTexture("Interface\\Buttons\\WHITE8x8")
    timerBar:SetVertexColor(1, 0.82, 0)
    timerBar:SetPoint("BOTTOM", okBtn, "TOP", 0, 10)
    timerBar:SetWidth(barWidth)
    timerBar:SetHeight(barHeight)

    local elapsed = 0
    patchFrame:SetScript("OnUpdate", function()
        elapsed = elapsed + arg1
        if elapsed >= self.patchConfig.timerDuration then
            okBtn:Enable()
            timerBar:Hide()
            patchFrame:SetScript("OnUpdate", nil)
            DFRL.activeScripts["PatchWarningScript"] = false
        else
            timerBar:SetWidth(barWidth * (1 - elapsed / self.patchConfig.timerDuration))
            DFRL.activeScripts["PatchWarningScript"] = true
        end
    end)
end

DFRL.activeScripts["WelcomePageScript"] = false
DFRL.activeScripts["PatchWarningScript"] = false

-- init
local f = CreateFrame("Frame")
f:RegisterEvent("VARIABLES_LOADED")
f:SetScript("OnEvent", function()
    local char = UnitName("player")
    if not DFRL_CUR_PROFILE[char .. "_firstRun"] then
        Setup:WelcomePage()
    end

    -- local seenVersion = DFRL:GetTempValue("Generic", "patchWarnVersion")
    -- if seenVersion ~= Setup.patchConfig.version then
    --     -- Setup:PatchWarning()
    -- end
end)
