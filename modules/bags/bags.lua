DFRL:NewDefaults("Bags", {
    enabled = {true},
    bagDarkMode = {0, "slider", {0, 1}, "showBags", "appearance", 1, "Adjust dark mode intensity", nil, nil},
    bagColor = {{1, 1, 1}, "colour", nil, nil, "appearance", 3, "Change bag color", nil, nil},
    showBags = {true, "checkbox", nil, nil, "appearance", 4, "Show or hide the bag frame", nil, nil},
    hoverShow = {false, "checkbox", nil, "showBags", "bag basic", 5, "Show or hide bags on mouse hover", nil, nil},
    toggleBags = {true, "checkbox", nil, "showBags", "bag basic", 6, "Show or hide the small bag slots", nil, nil},
    showToggle = {true, "checkbox", nil, "showBags", "bag basic", 7, "Show or hide the bag toggle button", nil, nil},
    bagScale = {1.5, "slider", {0.5, 2.5}, "showBags", "bag basic", 8, "Adjusts the scale of the main backpack", nil, nil},
    bagAlpha = {1, "slider", {0.1, 1}, "showBags", "bag basic", 9, "Adjusts the transparency of all bags", nil, nil},
    freeSlots = {true, "checkbox", nil, "showBags", "tweaks", 10, "Show or hide free bag slots", nil, nil},
})

DFRL:NewMod("Bags", 1, function()
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:SetScript("OnEvent", function()
        f:UnregisterEvent("PLAYER_ENTERING_WORLD")

        local Setup = {
            texpath = "Interface\\AddOns\\DragonflightUI-Reforged\\media\\tex\\bags\\",
            fontpath = "Interface\\AddOns\\DragonflightUI-Reforged\\media\\fnt\\",

            bagToggleButton = nil,

            appearance = {
                scale = 1.5,
                alpha = 1.0,
                bagDarkMode = false,
            },

            iconSize = 20,
            slotSize = 30.5,
        }

        function Setup:MainBag()
            local texture = self.texpath .. "bigbag"
            local highlight = self.texpath .. "bigbagHighlight"

            MainMenuBarBackpackButton:ClearAllPoints()
            MainMenuBarBackpackButton:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -5, 36)
            MainMenuBarBackpackButton:SetClampedToScreen(true)

            MainMenuBarBackpackButton:SetScale(DFRL:GetTempDB("Bags", "bagScale"))
            SetItemButtonTexture(MainMenuBarBackpackButton, texture)
            MainMenuBarBackpackButton:SetHighlightTexture(highlight)
            MainMenuBarBackpackButton:SetPushedTexture(highlight)
            if MainMenuBarBackpackButton.SetCheckedTexture then
                MainMenuBarBackpackButton:SetCheckedTexture(highlight)
            end

            MainMenuBarBackpackButtonNormalTexture:Hide()
            MainMenuBarBackpackButtonNormalTexture:SetTexture()

            if not MainMenuBarBackpackButton.Border then
                local cutout = self.texpath .. "bagslotCutout"
                local border = MainMenuBarBackpackButton:CreateTexture("DragonflightUIBigBagBorder")
                border:SetTexture(cutout)
                border:SetWidth(30)
                border:SetHeight(30)
                border:SetPoint("TOPLEFT", MainMenuBarBackpackButton, "TOPLEFT", 0, 0)
                border:SetPoint("BOTTOMRIGHT", MainMenuBarBackpackButton, "BOTTOMRIGHT", 0, 0)
                MainMenuBarBackpackButton.Border = border
            end
        end

        function Setup:SmallBags()
            local bagAtlas = self.texpath .. "bagslots2x"
            CharacterBag0Slot:SetPoint("RIGHT", MainMenuBarBackpackButton, "LEFT", -16, 0)

            for i = 1, 3 do
                local gap = 0
                _G["CharacterBag" .. i .. "Slot"]:SetPoint("RIGHT", _G["CharacterBag" .. (i - 1) .. "Slot"], "LEFT", -gap, 0)
            end

            for i = 0, 3 do
                local slot = _G["CharacterBag" .. i .. "Slot"]
                slot:SetScale(1)
                slot:SetWidth(30)
                slot:SetHeight(30)
                local size = self.slotSize

                local normal = slot:GetNormalTexture()
                normal:SetTexture(bagAtlas)
                normal:SetTexCoord(0.576172, 0.695312, 0.5, 0.976562)
                normal:SetWidth(size)
                normal:SetHeight(size)
                normal:SetPoint("CENTER", 2, -1)
                normal:SetDrawLayer("BACKGROUND", 0)

                local highlight = slot:GetHighlightTexture()
                highlight:SetTexture(bagAtlas)
                highlight:SetTexCoord(0.699219, 0.818359, 0.0078125, 0.484375)
                highlight:SetWidth(size)
                highlight:SetHeight(size)
                highlight:ClearAllPoints()
                highlight:SetPoint("CENTER", 2, -1)

                local checked = slot:GetCheckedTexture()
                if checked then
                    checked:SetTexture(bagAtlas)
                    checked:SetTexCoord(0.699219, 0.818359, 0.0078125, 0.484375)
                    checked:SetWidth(size)
                    checked:SetHeight(size)
                    checked:ClearAllPoints()
                    checked:SetPoint("CENTER", 2, -1)
                end

                local pushed = slot:GetPushedTexture()
                pushed:SetTexture(bagAtlas)
                pushed:SetTexCoord(0.576172, 0.695312, 0.5, 0.976562)
                pushed:SetWidth(size)
                pushed:SetHeight(size)
                pushed:ClearAllPoints()
                pushed:SetPoint("CENTER", 2, -1)
                pushed:SetDrawLayer("BORDER", 1)

                local iconTexture = _G["CharacterBag" .. i .. "SlotIconTexture"]
                iconTexture:ClearAllPoints()
                iconTexture:SetPoint("CENTER", 0, 0)
                iconTexture:SetWidth(self.iconSize)
                iconTexture:SetHeight(self.iconSize + 1)
                iconTexture:SetDrawLayer("BORDER", 2)

                if not slot.Border then
                    local border = slot:CreateTexture("DragonflightUIBagBorder" .. i)
                    border:SetTexture(bagAtlas)
                    border:SetTexCoord(0.576172, 0.695312, 0.0078125, 0.484375)
                    border:SetWidth(size)
                    border:SetHeight(size)
                    border:SetPoint("CENTER", 2, -1)
                    slot.Border = border
                end
            end
        end

        function Setup:KeyRing()
            if not KeyRingButton then return end
            local bagAtlas = self.texpath .. "bagslots2x"
            KeyRingButton:SetWidth(30)
            KeyRingButton:SetHeight(30)
            KeyRingButton:ClearAllPoints()
            KeyRingButton:SetPoint("RIGHT", CharacterBag3Slot, "LEFT", 0, 0)
            KeyRingButton:SetScale(1)
            local size = self.slotSize

            local normal = KeyRingButton:GetNormalTexture()
            normal:SetTexture(bagAtlas)
            normal:SetTexCoord(0.822266, 0.941406, 0.0078125, 0.484375)
            normal:SetWidth(size)
            normal:SetHeight(size)
            normal:ClearAllPoints()
            normal:SetPoint("CENTER", 2, -1)
            normal:SetDrawLayer("BORDER", 1)

            local highlight = KeyRingButton:GetHighlightTexture()
            highlight:SetTexture(bagAtlas)
            highlight:SetTexCoord(0.699219, 0.818359, 0.0078125, 0.484375)
            highlight:SetWidth(size)
            highlight:SetHeight(size)
            highlight:ClearAllPoints()
            highlight:SetPoint("CENTER", 2, -1)

            local pushed = KeyRingButton:GetPushedTexture()
            pushed:SetTexture(bagAtlas)
            pushed:SetTexCoord(0.699219, 0.818359, 0.0078125, 0.484375)
            pushed:SetWidth(size)
            pushed:SetHeight(size)
            pushed:ClearAllPoints()
            pushed:SetPoint("CENTER", 2, -1)
            pushed:SetDrawLayer("OVERLAY", 7)

            if not KeyRingButton.Icon then
                local icon = KeyRingButton:CreateTexture("KeyRingIconTexture")
                icon:SetTexture(self.texpath .. "KeyRing-Bag-Icon")
                icon:SetWidth(self.iconSize + 0.5)
                icon:SetHeight(self.iconSize + 0.5)
                icon:SetPoint("CENTER", 0, 0)
                icon:SetDrawLayer("ARTWORK", 2)
                KeyRingButton.Icon = icon
            end

            if not KeyRingButton.Border then
                local border = KeyRingButton:CreateTexture("KeyRingBorder")
                border:SetTexture(bagAtlas)
                border:SetTexCoord(0.699219, 0.818359, 0.5, 0.976562)
                border:SetWidth(size)
                border:SetHeight(size)
                border:SetPoint("CENTER", 2, -1)
                border:SetDrawLayer("OVERLAY", 1)
                KeyRingButton.Border = border
            end
        end

        function Setup:BagToggleButton()
            local bagToggleButton = CreateFrame("Button", "DFRLBagToggleButton", UIParent)
            bagToggleButton:SetWidth(28)
            bagToggleButton:SetHeight(17)
            bagToggleButton:SetScale(0.8)
            bagToggleButton:ClearAllPoints()
            bagToggleButton:SetPoint("RIGHT", MainMenuBarBackpackButton, "LEFT", 9, 0)

            local expandTexture = self.texpath .. "expand"
            bagToggleButton:SetNormalTexture(expandTexture)
            bagToggleButton:SetPushedTexture(expandTexture)
            bagToggleButton:SetHighlightTexture(expandTexture)

            bagToggleButton:GetNormalTexture():SetTexCoord(0, 1, 0, 1)
            bagToggleButton:GetHighlightTexture():SetTexCoord(0, 1, 0, 1)
            bagToggleButton:GetPushedTexture():SetTexCoord(0, 1, 0, 1)

            DFRL.bagToggleButton = bagToggleButton
            bagToggleButton:SetScript("OnClick", function()
                local currentValue = DFRL:GetTempDB("Bags", "toggleBags")
                DFRL:SetTempDB("Bags", "toggleBags", not currentValue)
            end)
        end

        function Setup:UpdateBagSlotIcons()
            for i = 0, 3 do
                local iconTexture = _G["CharacterBag" .. i .. "SlotIconTexture"]
                local bagID = i + 1
                local texture = GetInventoryItemTexture("player", ContainerIDToInventoryID(bagID))

                if texture then
                    SetPortraitToTexture(iconTexture, texture)
                    iconTexture:Show()
                else
                    iconTexture:Hide()
                end
            end
        end

        function Setup:UpdateKeyRingButtonVisibility()
            local toggleBagsValue = DFRL:GetTempDB("Bags", "toggleBags")
            local showBagsValue = DFRL:GetTempDB("Bags", "showBags")

            if KeyRingButton then
                if not toggleBagsValue or not showBagsValue or not HasKey() then
                    KeyRingButton:Hide()
                else
                    KeyRingButton:Show()
                end
            end
        end

        function Setup:KeyRingHook()
            hooksecurefunc("MainMenuBar_UpdateKeyRing", function()
                local toggleBagsValue = DFRL:GetTempDB("Bags", "toggleBags")
                local hideBagsValue = DFRL:GetTempDB("Bags", "showBags")

                if not toggleBagsValue and hideBagsValue and KeyRingButton then
                    KeyRingButton:Hide()
                end
                if not toggleBagsValue and not hideBagsValue and KeyRingButton then
                    KeyRingButton:Hide()
                end
                if toggleBagsValue and hideBagsValue and KeyRingButton then
                    KeyRingButton:Hide()
                end
            end, true)
        end

        function Setup:Run()
            self:MainBag()
            self:SmallBags()
            self:KeyRing()
            self:BagToggleButton()
            self:UpdateBagSlotIcons()
            self:UpdateKeyRingButtonVisibility()
            self:KeyRingHook()
        end

        Setup:Run()

        local callbacks = {}

        callbacks.bagDarkMode = function(value)
            local intensity = DFRL:GetTempDB("Bags", "bagDarkMode")
            local bagColor = DFRL:GetTempDB("Bags", "bagColor")
            local r, g, b = bagColor[1] * (1 - intensity), bagColor[2] * (1 - intensity), bagColor[3] * (1 - intensity)
            local color = value and {r, g, b} or {1, 1, 1}

            MainMenuBarBackpackButton.Border:SetVertexColor(color[1], color[2], color[3])

            for i = 0, 3 do
                local slot = _G["CharacterBag" .. i .. "Slot"]
                slot.Border:SetVertexColor(color[1], color[2], color[3])
                local normal = slot:GetNormalTexture()
                normal:SetVertexColor(color[1], color[2], color[3])
                local pushed = slot:GetPushedTexture()
                pushed:SetVertexColor(color[1], color[2], color[3])
            end

            if DFRL.bagToggleButton then
                DFRL.bagToggleButton:GetNormalTexture():SetVertexColor(color[1], color[2], color[3])
                DFRL.bagToggleButton:GetHighlightTexture():SetVertexColor(color[1], color[2], color[3])
                DFRL.bagToggleButton:GetPushedTexture():SetVertexColor(color[1], color[2], color[3])
            end

            if KeyRingButton then
                KeyRingButton.Border:SetVertexColor(color[1], color[2], color[3])
                local normal = KeyRingButton:GetNormalTexture()
                normal:SetVertexColor(color[1], color[2], color[3])
                local pushed = KeyRingButton:GetPushedTexture()
                pushed:SetVertexColor(color[1], color[2], color[3])
            end
        end

        callbacks.bagColor = function(value)
            local intensity = DFRL:GetTempDB("Bags", "bagDarkMode")
            local r, g, b = value[1] * (1 - intensity), value[2] * (1 - intensity), value[3] * (1 - intensity)

            MainMenuBarBackpackButton.Border:SetVertexColor(r, g, b)

            for i = 0, 3 do
                local slot = _G["CharacterBag" .. i .. "Slot"]
                slot.Border:SetVertexColor(r, g, b)
                slot:GetNormalTexture():SetVertexColor(r, g, b)
                slot:GetPushedTexture():SetVertexColor(r, g, b)
            end

            if DFRL.bagToggleButton then
                DFRL.bagToggleButton:GetNormalTexture():SetVertexColor(r, g, b)
                DFRL.bagToggleButton:GetHighlightTexture():SetVertexColor(r, g, b)
                DFRL.bagToggleButton:GetPushedTexture():SetVertexColor(r, g, b)
            end

            if KeyRingButton then
                KeyRingButton.Border:SetVertexColor(r, g, b)
                KeyRingButton:GetNormalTexture():SetVertexColor(r, g, b)
                KeyRingButton:GetPushedTexture():SetVertexColor(r, g, b)
            end
        end

        callbacks.toggleBags = function(value)
            -- show/hide only if bags not hidden
            local bagHideValue = DFRL:GetTempDB("Bags", "showBags")

            for i = 0, 3 do
                local slot = _G["CharacterBag" .. i .. "Slot"]
                if value and bagHideValue then
                    slot:Show()
                else
                    slot:Hide()
                end
            end

            -- KeyRingButton
            if KeyRingButton then
                if value and bagHideValue then
                    if HasKey() then
                        KeyRingButton:Show()
                    else
                        KeyRingButton:Hide()
                    end
                else
                    KeyRingButton:Hide()
                end
            end

            -- update
            if value then
                -- normal
                DFRL.bagToggleButton:GetNormalTexture():SetTexCoord(0, 1, 0, 1)
                DFRL.bagToggleButton:GetHighlightTexture():SetTexCoord(0, 1, 0, 1)
                DFRL.bagToggleButton:GetPushedTexture():SetTexCoord(0, 1, 0, 1)
            else
                -- flipped
                DFRL.bagToggleButton:GetNormalTexture():SetTexCoord(1, 0, 0, 1)
                DFRL.bagToggleButton:GetHighlightTexture():SetTexCoord(1, 0, 0, 1)
                DFRL.bagToggleButton:GetPushedTexture():SetTexCoord(1, 0, 0, 1)
            end
        end

        callbacks.bagScale = function(value)
            MainMenuBarBackpackButton:SetScale(value)
            DFRL.bagToggleButton:SetScale(value / 1.8)
        end

        callbacks.bagAlpha = function(value)
            MainMenuBarBackpackButton:SetAlpha(value)

            for i = 0, 3 do
                _G["CharacterBag" .. i .. "Slot"]:SetAlpha(value)
            end

            if KeyRingButton then
                KeyRingButton:SetAlpha(value)
            end

            DFRL.bagToggleButton:SetAlpha(value)
        end

        callbacks.showBags = function (value)
            if value then
                MainMenuBarBackpackButton:Show()
                DFRL.bagToggleButton:Show()

                local toggleBagsValue = DFRL:GetTempDB("Bags", "toggleBags")
                if toggleBagsValue then
                    for i = 0, 3 do
                        _G["CharacterBag" .. i .. "Slot"]:Show()
                    end

                    if KeyRingButton then
                        if HasKey() then
                            KeyRingButton:Show()
                        else
                            KeyRingButton:Hide()
                        end
                    end

                else
                    -- keep character bags hidden if toggleBags is false
                    for i = 0, 3 do
                        _G["CharacterBag" .. i .. "Slot"]:Hide()
                    end

                    if KeyRingButton then
                        KeyRingButton:Hide()
                    end
                end

                callbacks.bagAlpha(DFRL:GetTempDB("Bags", "bagAlpha"))
            else
                MainMenuBarBackpackButton:Hide()

                for i = 0, 3 do
                    _G["CharacterBag" .. i .. "Slot"]:Hide()
                end

                KeyRingButton:Hide()
                DFRL.bagToggleButton:Hide()
            end
        end

        callbacks.freeSlots = function(value)
            if value then
                if not MainMenuBarBackpackButton.FreeSlotsText then
                    local text = MainMenuBarBackpackButton:CreateFontString(nil, "OVERLAY")
                    text:SetFont(Setup.fontpath .. "Myriad-Pro.ttf", 10, "OUTLINE")
                    text:SetPoint("TOP", MainMenuBarBackpackButton, "BOTTOM", 0, 2)
                    text:SetTextColor(1, 1, 1)
                    MainMenuBarBackpackButton.FreeSlotsText = text
                end
                MainMenuBarBackpackButton.FreeSlotsText:Show()

                local function GetBagFreeAndTotal()
                    local free = 0
                    local total = 0
                    for bag = 0, NUM_BAG_SLOTS do
                        local numSlots = GetContainerNumSlots(bag)
                        total = total + numSlots
                        for slot = 1, numSlots do
                            local texture = GetContainerItemInfo(bag, slot)
                            if not texture then
                                free = free + 1
                            end
                        end
                    end
                    return free, total
                end

                local free, total = GetBagFreeAndTotal()
                MainMenuBarBackpackButton.FreeSlotsText:SetText(free .. " / " .. total)

                if not MainMenuBarBackpackButton.FreeSlotsUpdater then
                    local updater = CreateFrame("Frame")
                    updater:RegisterEvent("BAG_UPDATE")
                    updater:SetScript("OnEvent", function()
                        local freeSlots, totalSlots = GetBagFreeAndTotal()
                        MainMenuBarBackpackButton.FreeSlotsText:SetText(freeSlots .. " / " .. totalSlots)
                    end)
                    MainMenuBarBackpackButton.FreeSlotsUpdater = updater
                end
            else
                if MainMenuBarBackpackButton.FreeSlotsText then
                    MainMenuBarBackpackButton.FreeSlotsText:Hide()
                end
            end
        end

        callbacks.showToggle = function(value)
            if value then
                DFRL.bagToggleButton:Show()
            else
                DFRL.bagToggleButton:Hide()
            end
        end

        callbacks.hoverShow = function(value)
            local function SetBagAlpha(alpha)
                MainMenuBarBackpackButton:SetAlpha(alpha)
                local toggleBags = DFRL:GetTempDB("Bags", "toggleBags")
                for i = 0, 3 do
                    local slot = _G["CharacterBag" .. i .. "Slot"]
                    if toggleBags then
                        slot:SetAlpha(alpha)
                    else
                        slot:SetAlpha(0)
                    end
                end
                if KeyRingButton then
                    if toggleBags and HasKey() then
                        KeyRingButton:SetAlpha(alpha)
                    else
                        KeyRingButton:SetAlpha(0)
                    end
                end
                if DFRL.bagToggleButton and DFRL:GetTempDB("Bags", "showToggle") then
                    DFRL.bagToggleButton:SetAlpha(alpha)
                end
            end

            if value then
                local function FadeIn(frame)
                    UIFrameFadeIn(frame, 0.5, 0, 1)
                end
                local function FadeOut(frame)
                    UIFrameFadeOut(frame, 0.5, 1, 0)
                end

                local function OnEnter()
                    FadeIn(MainMenuBarBackpackButton)
                    local toggleBags = DFRL:GetTempDB("Bags", "toggleBags")
                    for i = 0, 3 do
                        local slot = _G["CharacterBag" .. i .. "Slot"]
                        if toggleBags then FadeIn(slot) else slot:SetAlpha(0) end
                    end
                    if KeyRingButton then
                        if toggleBags and HasKey() then FadeIn(KeyRingButton) else KeyRingButton:SetAlpha(0) end
                    end
                    if DFRL.bagToggleButton and DFRL:GetTempDB("Bags", "showToggle") then FadeIn(DFRL.bagToggleButton) end
                end

                local function OnLeave()
                    FadeOut(MainMenuBarBackpackButton)
                    local toggleBags = DFRL:GetTempDB("Bags", "toggleBags")
                    for i = 0, 3 do
                        local slot = _G["CharacterBag" .. i .. "Slot"]
                        if toggleBags then FadeOut(slot) else slot:SetAlpha(0) end
                    end
                    if KeyRingButton then
                        if toggleBags and HasKey() then FadeOut(KeyRingButton) else KeyRingButton:SetAlpha(0) end
                    end
                    if DFRL.bagToggleButton and DFRL:GetTempDB("Bags", "showToggle") then FadeOut(DFRL.bagToggleButton) end
                end

                MainMenuBarBackpackButton:SetScript("OnEnter", OnEnter)
                MainMenuBarBackpackButton:SetScript("OnLeave", OnLeave)
                for i = 0, 3 do
                    local slot = _G["CharacterBag" .. i .. "Slot"]
                    slot:SetScript("OnEnter", OnEnter)
                    slot:SetScript("OnLeave", OnLeave)
                end
                if KeyRingButton then
                    KeyRingButton:SetScript("OnEnter", OnEnter)
                    KeyRingButton:SetScript("OnLeave", OnLeave)
                end
                if DFRL.bagToggleButton then
                    DFRL.bagToggleButton:SetScript("OnEnter", OnEnter)
                    DFRL.bagToggleButton:SetScript("OnLeave", OnLeave)
                end
                OnLeave()
            else
                MainMenuBarBackpackButton:SetScript("OnEnter", nil)
                MainMenuBarBackpackButton:SetScript("OnLeave", nil)
                for i = 0, 3 do
                    local slot = _G["CharacterBag" .. i .. "Slot"]
                    slot:SetScript("OnEnter", nil)
                    slot:SetScript("OnLeave", nil)
                end
                if KeyRingButton then
                    KeyRingButton:SetScript("OnEnter", nil)
                    KeyRingButton:SetScript("OnLeave", nil)
                end
                if DFRL.bagToggleButton then
                    DFRL.bagToggleButton:SetScript("OnEnter", nil)
                    DFRL.bagToggleButton:SetScript("OnLeave", nil)
                end

                callbacks.bagAlpha(DFRL:GetTempDB("Bags", "bagAlpha"))
                callbacks.toggleBags(DFRL:GetTempDB("Bags", "toggleBags"))
            end
        end

        local orig = _G.SetItemButtonCount
        _G.SetItemButtonCount = function(button, count)
            orig(button, count)
            if button.isBag and count and count > 0 then
                local countFrame = _G[button:GetName().."Count"]
                if countFrame then
                    countFrame:SetDrawLayer("ARTWORK")
                end
            end
        end

        local f2 = CreateFrame("Frame")
        f2:RegisterEvent("BAG_UPDATE")
        f2:SetScript("OnEvent", function()
            Setup:UpdateBagSlotIcons()
            Setup:UpdateKeyRingButtonVisibility()
        end)

        -- execute callbacks
        DFRL:NewCallbacks("Bags", callbacks)
    end)
end)
