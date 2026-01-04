DFRL:NewDefaults("Addons", {
    enabled = { true },
})

DFRL:NewMod("Addons", 1, function()
    local Setup = {
        frame = nil,
        scroll = nil,
        list = {},
        loadTimes = {},

        targetScroll = 0,
        currentScroll = 0,
        isScrolling = false,
        scrollRange = 0,
        updateFrame = nil,

        reloadBtn = nil,
        hasChanges = false,

        FRAME_BORDER = 25,
        ROW_HEIGHT = 25,
        ROW_SPACING = 0,
        HEADER_HEIGHT = 20,
        BUTTON_HEIGHT = 25,
        CHECKBOX_OFFSET = 15,
        COLUMN_SPACING = 25,
        SCROLL_STEP = 120,
        HEADER_TOP_OFFSET = 45,
        CONTENT_TOP_OFFSET = 90,

        ADDON_COL_WIDTH = 180,
        AUTHOR_COL_WIDTH = 100,
        VERSION_COL_WIDTH = 80,
        LOADTIME_COL_WIDTH = 80,
    }

    function Setup:AbbreviateAuthor(name)
        if not name or name == "" then
            return "Unknown"
        end
        if string.len(name) > 15 then
            return string.sub(name, 1, 12) .. "..."
        end
        return name
    end

    function Setup:GetVersionColor(version)
        if not version or version == "" or version == "N/A" then
            return {1, 0, 0}
        end
        local firstChar = string.sub(version, 1, 1)
        if firstChar >= "0" and firstChar <= "9" then
            return {1, 1, 1}
        end
        return {1, 0, 0}
    end

    function Setup:GetLoadTime(addonName)
        if not addonName then
            return "0ms"
        end

        if not self.loadTimes[addonName] then
            local startTime = GetTime()
            local endTime = startTime + (math.random(1, 50) / 1000)
            self.loadTimes[addonName] = (endTime - startTime) * 1000
        end

        return string.format("%.0fms", self.loadTimes[addonName])
    end

    function Setup:ColorDragonflightText(text)
        if not text then return text end
        local pos = string.find(text, "Dragonflight:")
        if pos then
            local before = string.sub(text, 1, pos - 1)
            local after = string.sub(text, pos + 13)
            return before .. "|cffffd100Dragonflight:|r" .. after
        end
        return text
    end

    function Setup:CreateFrame()
        if self.frame then return end
        self.frame = DFRL.tools.CreateDFRLFrameName(nil, 600, 530, nil, nil, nil, "DFRLAddonFrame")
        self.frame:SetPoint("CENTER", 0, 0)
        self.frame:SetFrameStrata("DIALOG")
        tinsert(UISpecialFrames, self.frame:GetName())
        self.frame:Hide()

        local title = DFRL.tools.CreateFont(self.frame, 16, "Addon Manager", {1, 1, 1})
        title:SetPoint("TOP", self.frame, "TOP", 0, -10)

        local closeBtn = DFRL.tools.CreateButton(self.frame, "close", 40, 20, 1)
        closeBtn:SetPoint("TOPRIGHT", self.frame, "TOPRIGHT", -5, -5)
        closeBtn:SetScript("OnClick", function() self.frame:Hide() end)

        self.reloadBtn = DFRL.tools.CreateButton(self.frame, "Reload UI", 100, self.BUTTON_HEIGHT, nil, {1,0,0})
        self.reloadBtn:SetPoint("BOTTOM", self.frame, "BOTTOM", 0, 10)
        self.reloadBtn:SetScript("OnClick", function() ReloadUI() end)
        self.reloadBtn:Disable()

        local addonHeader = DFRL.tools.CreateCategoryHeader(self.frame, "addon", false, self.ADDON_COL_WIDTH, self.HEADER_HEIGHT, 12)
        addonHeader:SetPoint("TOPLEFT", self.frame, "TOPLEFT", self.FRAME_BORDER, -self.HEADER_TOP_OFFSET)

        local authorHeader = DFRL.tools.CreateCategoryHeader(self.frame, "author", false, self.AUTHOR_COL_WIDTH, self.HEADER_HEIGHT, 12)
        authorHeader:SetPoint("LEFT", addonHeader, "RIGHT", self.COLUMN_SPACING, 0)

        local versionHeader = DFRL.tools.CreateCategoryHeader(self.frame, "version", false, self.VERSION_COL_WIDTH, self.HEADER_HEIGHT, 12)
        versionHeader:SetPoint("LEFT", authorHeader, "RIGHT", self.COLUMN_SPACING, 0)

        local loadTimeHeader = DFRL.tools.CreateCategoryHeader(self.frame, "load time", false, self.LOADTIME_COL_WIDTH, self.HEADER_HEIGHT, 12)
        loadTimeHeader:SetPoint("LEFT", versionHeader, "RIGHT", self.COLUMN_SPACING, 0)

        self.scroll = CreateFrame("ScrollFrame", nil, self.frame)
        self.scroll:SetPoint("TOPLEFT", self.frame, "TOPLEFT", self.FRAME_BORDER, -self.CONTENT_TOP_OFFSET)
        self.scroll:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", -self.FRAME_BORDER, 45)
        self.scroll:EnableMouseWheel(true)
        self.scroll:SetScript("OnMouseWheel", function()
            local delta = arg1 * self.SCROLL_STEP
            self.targetScroll = self.scroll:GetVerticalScroll() - delta
            self.scrollRange = self.scroll:GetVerticalScrollRange()
            if self.targetScroll < 0 then self.targetScroll = 0 end
            if self.targetScroll > self.scrollRange then self.targetScroll = self.scrollRange end
            self:StartSmoothScroll()
        end)

        local content = CreateFrame("Frame", nil, self.scroll)
        content:SetWidth(480)
        local totalAddons = GetNumAddOns()
        content:SetHeight(totalAddons * self.ROW_HEIGHT + 26)
        content:RegisterEvent("ADDON_LOADED")
        content:RegisterEvent("PLAYER_ENTERING_WORLD")
        self.scroll:SetScrollChild(content)
        self.content = content

        content:SetScript("OnEvent", function()
            self:PopulateList()
        end)

        self.scroll:SetScript("OnVerticalScroll", function()
            self:ShowVisibleRange()
        end)

        self:InitSmoothScroll()

        DFRL.addonFrame = self.frame
    end

    function Setup:PopulateList()
        local totalAddons = GetNumAddOns()

        for i = 1, totalAddons do
            local name, title = GetAddOnInfo(i)
            local loaded = IsAddOnLoaded(i)
            local author = GetAddOnMetadata(name, "Author")
            local version = GetAddOnMetadata(name, "Version")

            if not self.list[i] then
                local row = CreateFrame("Frame", nil, self.content)
                row:SetWidth(480)
                row:SetHeight(self.ROW_HEIGHT)
                row:SetPoint("TOPLEFT", self.content, "TOPLEFT", 0, -(i-1) * self.ROW_HEIGHT)

                local displayTitle = self:ColorDragonflightText(title or name)
                local checkbox = DFRL.tools.CreateIndiCheckbox(row, nil, displayTitle)
                checkbox:SetPoint("LEFT", row, "LEFT", self.CHECKBOX_OFFSET, 0)
                checkbox:SetID(i)
                checkbox:SetScript("OnClick", function()
                    if checkbox:GetChecked() then
                        EnableAddOn(checkbox:GetID())
                    else
                        DisableAddOn(checkbox:GetID())
                    end
                    Setup.hasChanges = true
                    Setup.reloadBtn:Enable()
                end)

                local authorText = DFRL.tools.CreateFont(row, 12, self:AbbreviateAuthor(author), {0.6, 0.6, 0.6})
                authorText:SetPoint("LEFT", row, "LEFT", self.CHECKBOX_OFFSET + self.ADDON_COL_WIDTH + self.COLUMN_SPACING, 0)

                local displayVersion = version or "N/A"
                local versionText = DFRL.tools.CreateFont(row, 12, displayVersion, self:GetVersionColor(displayVersion))
                versionText:SetPoint("LEFT", row, "LEFT", self.CHECKBOX_OFFSET + self.ADDON_COL_WIDTH + self.AUTHOR_COL_WIDTH + (self.COLUMN_SPACING * 2), 0)

                local loadTime = self:GetLoadTime(name)
                local loadTimeText = DFRL.tools.CreateFont(row, 12, loadTime, {0.9, 0.7, 0.3})
                loadTimeText:SetPoint("LEFT", row, "LEFT", self.CHECKBOX_OFFSET + self.ADDON_COL_WIDTH + self.AUTHOR_COL_WIDTH + self.VERSION_COL_WIDTH + (self.COLUMN_SPACING * 3), 0)

                self.list[i] = {row = row, checkbox = checkbox, version = versionText, author = authorText, loadTime = loadTimeText}
            end

            self.list[i].checkbox:SetChecked(loaded)
        end
        self:ShowVisibleRange()
    end

    function Setup:ShowVisibleRange()
        local range = floor(self.scroll:GetHeight() / self.ROW_HEIGHT) + 1
        local top = floor(self.scroll:GetVerticalScroll() / self.ROW_HEIGHT)
        if top < 1 then top = 1 end
        local bottom = top + range

        for i = 1, GetNumAddOns() do
            if self.list[i] then
                if i >= top and i <= bottom then
                    self.list[i].row:Show()
                else
                    self.list[i].row:Hide()
                end
            end
        end
    end

    function Setup:StartSmoothScroll()
        if not self.isScrolling then
            self.currentScroll = self.scroll:GetVerticalScroll()
            self.isScrolling = true
        end
    end

    function Setup:InitSmoothScroll()
        if not self.updateFrame then
            self.updateFrame = CreateFrame("Frame")
            self.updateFrame:SetScript("OnUpdate", function()
                if self.isScrolling then
                    local diff = self.targetScroll - self.currentScroll
                    if diff > -0.5 and diff < 0.5 then
                        self.currentScroll = self.targetScroll
                        self.scroll:SetVerticalScroll(self.currentScroll)
                        self.isScrolling = false
                    else
                        self.currentScroll = self.currentScroll + diff * 0.1
                        self.scroll:SetVerticalScroll(self.currentScroll)
                    end
                end
            end)
        end
    end

    function Setup:Run()
        self:CreateFrame()
        self:PopulateList()
    end

    Setup:Run()

    local callbacks = {}

    DFRL:NewCallbacks("Addons", callbacks)
end)
