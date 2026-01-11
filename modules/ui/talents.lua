DFRL:NewDefaults("Talents", {
    enabled = {true},
})

DFRL:NewMod("Talents", 1, function()
    local frame
    local treeFrames = {}
    local talentButtons = {}
    local branchArrays = {}
    local branchTextures = {}
    local arrowTextures = {}

    local TALENT_BRANCH_TEXTURECOORDS = {
        up = {[1] = {0.12890625, 0.25390625, 0, 0.484375}, [-1] = {0.12890625, 0.25390625, 0.515625, 1.0}},
        down = {[1] = {0, 0.125, 0, 0.484375}, [-1] = {0, 0.125, 0.515625, 1.0}},
        left = {[1] = {0.2578125, 0.3828125, 0, 0.5}, [-1] = {0.2578125, 0.3828125, 0.5, 1.0}},
        right = {[1] = {0.2578125, 0.3828125, 0, 0.5}, [-1] = {0.2578125, 0.3828125, 0.5, 1.0}},
        topright = {[1] = {0.515625, 0.640625, 0, 0.5}, [-1] = {0.515625, 0.640625, 0.5, 1.0}},
        topleft = {[1] = {0.640625, 0.515625, 0, 0.5}, [-1] = {0.640625, 0.515625, 0.5, 1.0}},
        bottomright = {[1] = {0.38671875, 0.51171875, 0, 0.5}, [-1] = {0.38671875, 0.51171875, 0.5, 1.0}},
        bottomleft = {[1] = {0.51171875, 0.38671875, 0, 0.5}, [-1] = {0.51171875, 0.38671875, 0.5, 1.0}},
        tdown = {[1] = {0.64453125, 0.76953125, 0, 0.5}, [-1] = {0.64453125, 0.76953125, 0.5, 1.0}},
        tup = {[1] = {0.7734375, 0.8984375, 0, 0.5}, [-1] = {0.7734375, 0.8984375, 0.5, 1.0}}
    }

    local TALENT_ARROW_TEXTURECOORDS = {
        top = {[1] = {0, 0.5, 0, 0.5}, [-1] = {0, 0.5, 0.5, 1.0}},
        right = {[1] = {1.0, 0.5, 0, 0.5}, [-1] = {1.0, 0.5, 0.5, 1.0}},
        left = {[1] = {0.5, 1.0, 0, 0.5}, [-1] = {0.5, 1.0, 0.5, 1.0}}
    }

    local function CreateMainFrame()
        frame = CreateFrame('Frame', 'BLF_TalentFrame', UIParent)
        frame:SetWidth(1020)
        frame:SetHeight(600)
        frame:SetFrameStrata('HIGH')
        frame:EnableMouse(true)
        frame:SetPoint('CENTER', UIParent, 'CENTER', 0, 0)
        frame:SetBackdrop({
            bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
        })
        frame:SetBackdropColor(0, 0, 0, 1)
        frame:EnableMouse(true)
        frame:SetMovable(true)
        frame:SetClampedToScreen(true)
        frame:SetScript("OnMouseDown", function() this:StartMoving() end)
        frame:SetScript("OnMouseUp", function() this:StopMovingOrSizing() end)

        local leftHeader = frame:CreateTexture(nil, 'ARTWORK')
        leftHeader:SetTexture('Interface\\AddOns\\DragonflightUI-Reforged\\media\\tex\\ui\\top_ui_header_left.tga')
        leftHeader:SetWidth(50)
        leftHeader:SetHeight(50)
        leftHeader:SetPoint('BOTTOMRIGHT', frame, 'TOPLEFT', 33, -10)

        local rightHeader = frame:CreateTexture(nil, 'ARTWORK')
        rightHeader:SetTexture('Interface\\AddOns\\DragonflightUI-Reforged\\media\\tex\\ui\\top_ui_header_right.tga')
        rightHeader:SetWidth(50)
        rightHeader:SetHeight(50)
        rightHeader:SetPoint('BOTTOMLEFT', frame, 'TOPRIGHT', -33, -11)

        for i = 1, 5 do
            local layer = i == 5 and 'BACKGROUND' or 'ARTWORK'
            local middleHeader = frame:CreateTexture(nil, layer)
            middleHeader:SetTexture('Interface\\AddOns\\DragonflightUI-Reforged\\media\\tex\\ui\\top_ui_header.tga')
            middleHeader:SetWidth(240)
            middleHeader:SetHeight(50)
            if i == 1 then
                middleHeader:SetPoint('LEFT', leftHeader, 'RIGHT', -25, -1)
            elseif i == 5 then
                middleHeader:SetPoint('LEFT', frame['middleHeader' .. (i-1)], 'RIGHT', -140, 0)
            else
                middleHeader:SetPoint('LEFT', frame['middleHeader' .. (i-1)], 'RIGHT', -17, 0)
            end
            frame['middleHeader' .. i] = middleHeader
        end

        local closeButton = CreateFrame('Button', nil, frame)
        closeButton:SetWidth(18)
        closeButton:SetHeight(18)
        closeButton:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', -10, 25)
        closeButton:SetNormalTexture('Interface\\AddOns\\DragonflightUI-Reforged\\media\\tex\\ui\\close_normal.tga')
        closeButton:SetPushedTexture('Interface\\AddOns\\DragonflightUI-Reforged\\media\\tex\\ui\\close_pushed.tga')
        closeButton:SetHighlightTexture('Interface\\AddOns\\DragonflightUI-Reforged\\media\\tex\\ui\\close_normal.tga')
        closeButton:SetScript('OnClick', function()
            pcall(PlaySound, "TalentScreenClose")
            frame:Hide()
            UpdateMicroButtons()
        end)

        local headerText = frame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
        headerText:SetText('Talents')
        headerText:SetPoint('TOP', frame, 'TOP', 0, 23)

        local pointsLeft = frame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
        pointsLeft:SetPoint('BOTTOM', frame, 'BOTTOM', 0, 20)
        frame.pointsLeft = pointsLeft

        local scaleCheckbox = DFRL.tools.CreateIndiCheckbox(frame, nil, 'Small')
        scaleCheckbox:SetPoint('BOTTOMLEFT', frame, 'BOTTOMLEFT', 50, 17)

        if not DFRL_CUR_PROFILE['TalentFrameSmall'] then DFRL_CUR_PROFILE['TalentFrameSmall'] = nil end
        scaleCheckbox:SetChecked(DFRL_CUR_PROFILE['TalentFrameSmall'])
        if DFRL_CUR_PROFILE['TalentFrameSmall'] then
            frame:SetScale(0.8)
        end

        scaleCheckbox:SetScript('OnClick', function()
            if this:GetChecked() then
                frame:SetScale(0.8)
                DFRL_CUR_PROFILE['TalentFrameSmall'] = 1
            else
                frame:SetScale(1.0)
                DFRL_CUR_PROFILE['TalentFrameSmall'] = nil
            end
        end)

        frame:Hide()
        table.insert(UISpecialFrames, 'BLF_TalentFrame')
    end

    local function CreateTreeFrames()
        local xOffsets = {0, 340, 680}
        for i = 1, 3 do
            local treeFrame = CreateFrame('Frame', nil, frame)
            treeFrame:SetWidth(300)
            treeFrame:SetHeight(500)
            treeFrame:SetPoint('TOPLEFT', frame, 'TOPLEFT', xOffsets[i] + 20, -50)
            -- debugframe(treeFrame)
            local header = treeFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
            header:SetPoint('TOP', treeFrame, 'TOP', 0, 20)

            local pointsText = treeFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
            pointsText:SetPoint('TOP', treeFrame, 'TOP', 0, 0)
            pointsText:SetTextColor(1, 1, 1)

            local branchFrame = CreateFrame('Frame', nil, treeFrame)
            branchFrame:SetAllPoints()

            local arrowFrame = CreateFrame('Frame', nil, treeFrame)
            arrowFrame:SetAllPoints()

            local bgTopLeft = treeFrame:CreateTexture(nil, 'BACKGROUND')
            bgTopLeft:SetWidth(200)
            bgTopLeft:SetHeight(300)
            bgTopLeft:SetPoint('TOPLEFT', treeFrame, 'TOPLEFT', 20, -30)

            local bgTopRight = treeFrame:CreateTexture(nil, 'BACKGROUND')
            bgTopRight:SetWidth(100)
            bgTopRight:SetHeight(300)
            bgTopRight:SetPoint('TOPRIGHT', treeFrame, 'TOPRIGHT', 20, -30)

            local bgBottomLeft = treeFrame:CreateTexture(nil, 'BACKGROUND')
            bgBottomLeft:SetWidth(200)
            bgBottomLeft:SetHeight(200)
            bgBottomLeft:SetPoint('BOTTOMLEFT', treeFrame, 'BOTTOMLEFT', 20, -30)

            local bgBottomRight = treeFrame:CreateTexture(nil, 'BACKGROUND')
            bgBottomRight:SetWidth(100)
            bgBottomRight:SetHeight(200)
            bgBottomRight:SetPoint('BOTTOMRIGHT', treeFrame, 'BOTTOMRIGHT', 20, -30)

            treeFrames[i] = {
                frame = treeFrame,
                header = header,
                pointsText = pointsText,
                branchFrame = branchFrame,
                arrowFrame = arrowFrame
            }

            local _, _, _, fileName = GetTalentTabInfo(i)
            local base = fileName and ('Interface\\TalentFrame\\' .. fileName .. '-') or 'Interface\\TalentFrame\\MageFire-'

            bgTopLeft:SetTexture(base .. 'TopLeft')
            bgTopLeft:SetAlpha(0.7)
            bgTopRight:SetTexture(base .. 'TopRight')
            bgTopRight:SetAlpha(0.7)
            bgBottomLeft:SetTexture(base .. 'BottomLeft')
            bgBottomLeft:SetAlpha(0.7)
            bgBottomRight:SetTexture(base .. 'BottomRight')
            bgBottomRight:SetAlpha(0.7)

            local borderTop = treeFrame:CreateTexture(nil, 'OVERLAY')
            borderTop:SetTexture('Interface\\Buttons\\WHITE8X8')
            -- borderTop:SetVertexColor(1,0.82,0, .4)
            borderTop:SetVertexColor(0,0,0, .4)
            borderTop:SetWidth(265)
            -- borderTop:SetHeight(2)
            borderTop:SetHeight(4)
            borderTop:SetPoint('TOPLEFT', bgTopLeft, 'TOPLEFT', 2, 0)

            local borderBottom = treeFrame:CreateTexture(nil, 'OVERLAY')
            borderBottom:SetTexture('Interface\\Buttons\\WHITE8X8')
            -- borderBottom:SetVertexColor(0,0,0, .9)
            borderBottom:SetGradientAlpha('VERTICAL', 0, 0, 0, .9, 0, 0, 0, 0)
            borderBottom:SetWidth(270)
            borderBottom:SetHeight(40)
            borderBottom:SetPoint('LEFT', bgBottomLeft, 'BOTTOMLEFT', 0, 100)

            local borderLeft = treeFrame:CreateTexture(nil, 'OVERLAY')
            borderLeft:SetTexture('Interface\\Buttons\\WHITE8X8')
            borderLeft:SetVertexColor(0,0,0, .4)
            borderLeft:SetWidth(4)
            borderLeft:SetHeight(420)
            borderLeft:SetPoint('TOPLEFT', bgTopLeft, 'TOPLEFT', 0, 0)

            local borderRight = treeFrame:CreateTexture(nil, 'OVERLAY')
            borderRight:SetTexture('Interface\\Buttons\\WHITE8X8')
            borderRight:SetVertexColor(0,0,0, .4)
            borderRight:SetWidth(4)
            borderRight:SetHeight(420)
            borderRight:SetPoint('TOPRIGHT', bgTopRight, 'TOPRIGHT', -30, 0)

            local whiteBottom = treeFrame:CreateTexture(nil, 'BACKGROUND')
            whiteBottom:SetTexture('Interface\\Buttons\\WHITE8X8')
            -- whiteBottom:SetVertexColor(0,0,0, .1)
            whiteBottom:SetGradientAlpha('VERTICAL', 0, 0, 0, 0, 0, 0, 0, .9)
            whiteBottom:SetWidth(270)
            whiteBottom:SetHeight(70)
            whiteBottom:SetPoint('TOP', borderBottom, 'BOTTOM', 0, 1)

            branchArrays[i] = {}
            branchTextures[i] = {}
            arrowTextures[i] = {}
            for tier = 1, 8 do
                branchArrays[i][tier] = {}
                for col = 1, 4 do
                    branchArrays[i][tier][col] = {id=nil, up=0, left=0, right=0, down=0, leftArrow=0, rightArrow=0, topArrow=0}
                end
            end
        end
    end

    local function CreateTalentButton(tabIndex, talentIndex, tier, column)
        local treeFrame = treeFrames[tabIndex].frame
        local button = CreateFrame('Button', nil, treeFrame)
        button:SetWidth(32)
        button:SetHeight(32)

        local x = (column - 1) * 63 + 35
        local y = -(tier - 1) * 63 - 50
        button:SetPoint('TOPLEFT', treeFrame, 'TOPLEFT', x + 10, y)

        local icon = button:CreateTexture(nil, 'ARTWORK')
        icon:SetAllPoints()

        local border = button:CreateTexture(nil, 'OVERLAY')
        border:SetTexture('Interface\\Buttons\\UI-ActionButton-Border')
        border:SetBlendMode('ADD')
        border:SetWidth(64)
        border:SetHeight(64)
        border:SetPoint('CENTER', button, 'CENTER', 0, 0)

        local hoverBorder = button:CreateTexture(nil, 'OVERLAY')
        hoverBorder:SetTexture('Interface\\Buttons\\UI-ActionButton-Border')
        hoverBorder:SetBlendMode('ADD')
        hoverBorder:SetWidth(64)
        hoverBorder:SetHeight(64)
        hoverBorder:SetPoint('CENTER', button, 'CENTER', 0, 0)
        hoverBorder:SetVertexColor(1, 0.82, 0)
        hoverBorder:Hide()

        local rankBg = button:CreateTexture(nil, 'OVERLAY')
        rankBg:SetTexture(0, 0, 0, .5)
        rankBg:SetWidth(37)
        rankBg:SetHeight(12)
        rankBg:SetPoint('TOP', button, 'BOTTOM', 0, -2)

        local rank = button:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
        rank:SetPoint('BOTTOM', button, 'BOTTOM', -0, -12)

        button.icon = icon
        button.border = border
        button.hoverBorder = hoverBorder
        button.rank = rank
        button.tabIndex = tabIndex
        button.talentIndex = talentIndex

        button:SetScript('OnClick', function()
            local _, _, talentTier, _, talentRank, talentMaxRank, _, talentMeetsPrereq = GetTalentInfo(this.tabIndex, this.talentIndex)
            local characterPoints = UnitCharacterPoints('player')
            local _, _, tabPointsSpent = GetTalentTabInfo(this.tabIndex)
            local talentTierUnlocked = ((talentTier - 1) * 5 <= tabPointsSpent)

            if talentMeetsPrereq and talentTierUnlocked and characterPoints > 0 and talentRank < talentMaxRank then
                LearnTalent(this.tabIndex, this.talentIndex)
            end
        end)

        button:SetScript('OnEnter', function()
            this.hoverBorder:Show()
            GameTooltip:SetOwner(this, 'ANCHOR_RIGHT')
            GameTooltip:SetTalent(this.tabIndex, this.talentIndex)
        end)

        button:SetScript('OnLeave', function()
            this.hoverBorder:Hide()
            GameTooltip:Hide()
        end)

        return button
    end

    local function CheckPrereqsMaxed(tabIndex, talentIndex)
        local prereqs = {GetTalentPrereqs(tabIndex, talentIndex)}
        for i = 1, table.getn(prereqs), 3 do
            local prereqTier, prereqColumn, prereqMaxed = prereqs[i], prereqs[i+1], prereqs[i+2]
            if prereqTier and prereqColumn and not prereqMaxed then
                return nil
            end
        end
        return 1
    end

    local function ResetBranches(tabIndex)
        for tier = 1, 8 do
            for col = 1, 4 do
                local node = branchArrays[tabIndex][tier][col]
                node.id = nil
                node.up = 0
                node.down = 0
                node.left = 0
                node.right = 0
                node.rightArrow = 0
                node.leftArrow = 0
                node.topArrow = 0
            end
        end
        for i = 1, table.getn(branchTextures[tabIndex]) do
            branchTextures[tabIndex][i]:Hide()
        end
        for i = 1, table.getn(arrowTextures[tabIndex]) do
            arrowTextures[tabIndex][i]:Hide()
        end
    end

    local function GetTexture(tabIndex, isBranch)
        local textures = isBranch and branchTextures[tabIndex] or arrowTextures[tabIndex]
        for i = 1, table.getn(textures) do
            if not textures[i]:IsVisible() then
                textures[i]:Show()
                return textures[i]
            end
        end
        local parent = isBranch and treeFrames[tabIndex].branchFrame or treeFrames[tabIndex].arrowFrame
        local layer = isBranch and 'ARTWORK' or 'OVERLAY'
        local texturePath = isBranch and 'Interface\\TalentFrame\\UI-TalentBranches' or 'Interface\\TalentFrame\\UI-TalentArrows'

        local texture = parent:CreateTexture(nil, layer)
        texture:SetTexture(texturePath)
        texture:SetWidth(32)
        texture:SetHeight(32)
        table.insert(textures, texture)
        texture:Show()
        return texture
    end

    local function SetBranchTexture(tabIndex, texCoords, xOffset, yOffset)
        local texture = GetTexture(tabIndex, true)
        texture:SetTexCoord(texCoords[1], texCoords[2], texCoords[3], texCoords[4])
        texture:SetPoint('TOPLEFT', treeFrames[tabIndex].branchFrame, 'TOPLEFT', xOffset+8, yOffset)
    end

    local function SetArrowTexture(tabIndex, texCoords, xOffset, yOffset)
        local texture = GetTexture(tabIndex, false)
        texture:SetTexCoord(texCoords[1], texCoords[2], texCoords[3], texCoords[4])
        texture:SetPoint('TOPLEFT', treeFrames[tabIndex].arrowFrame, 'TOPLEFT', xOffset+8, yOffset)
    end

    local function DrawTalentLines(tabIndex, buttonTier, buttonColumn, tier, column, requirementsMet)
        local reqMet = requirementsMet and 1 or -1
        if buttonColumn == column then

            for i = tier, buttonTier - 1 do
                branchArrays[tabIndex][i][buttonColumn].down = reqMet
                if (i + 1) <= (buttonTier - 1) then
                    branchArrays[tabIndex][i + 1][buttonColumn].up = reqMet
                end
            end
            branchArrays[tabIndex][buttonTier][buttonColumn].topArrow = reqMet
        elseif buttonTier == tier then

            local left = math.min(buttonColumn, column)
            local right = math.max(buttonColumn, column)
            for i = left, right - 1 do
                branchArrays[tabIndex][tier][i].right = reqMet
                branchArrays[tabIndex][tier][i+1].left = reqMet
            end
            if buttonColumn < column then
                branchArrays[tabIndex][buttonTier][buttonColumn].rightArrow = reqMet
            else
                branchArrays[tabIndex][buttonTier][buttonColumn].leftArrow = reqMet
            end
        end
    end

    local function SetTalentPrereqs(tabIndex, buttonTier, buttonColumn, forceDesaturated, tierUnlocked, ...)
        local requirementsMet
        if tierUnlocked and not forceDesaturated then
            requirementsMet = 1
        else
            requirementsMet = nil
        end

        for i = 1, arg.n, 3 do
            local tier = arg[i]
            local column = arg[i+1]
            local isLearnable = arg[i+2]
            if not isLearnable or forceDesaturated then
                requirementsMet = nil
            end
            if tier and column then
                DrawTalentLines(tabIndex, buttonTier, buttonColumn, tier, column, requirementsMet)
            end
        end
        return requirementsMet
    end

    local function DrawBranches(tabIndex)
        for tier = 1, 8 do
            for col = 1, 4 do
                local node = branchArrays[tabIndex][tier][col]
                local xOffset = (col - 1) * 63 + 35 + 2
                local yOffset = -(tier - 1) * 63 - 50 - 2

                if node.id then
                    if node.up ~= 0 then
                        SetBranchTexture(tabIndex, TALENT_BRANCH_TEXTURECOORDS['up'][node.up], xOffset, yOffset + 32)
                    end
                    if node.down ~= 0 then
                        SetBranchTexture(tabIndex, TALENT_BRANCH_TEXTURECOORDS['down'][node.down], xOffset, yOffset - 32 + 1)
                    end
                    if node.left ~= 0 then
                        SetBranchTexture(tabIndex, TALENT_BRANCH_TEXTURECOORDS['left'][node.left], xOffset - 32, yOffset)
                    end
                    if node.right ~= 0 then
                        SetBranchTexture(tabIndex, TALENT_BRANCH_TEXTURECOORDS['right'][node.right], xOffset + 32 + 1, yOffset)
                    end
                    if node.rightArrow ~= 0 then
                        SetArrowTexture(tabIndex, TALENT_ARROW_TEXTURECOORDS['right'][node.rightArrow], xOffset + 16 + 5, yOffset)
                    end
                    if node.leftArrow ~= 0 then
                        SetArrowTexture(tabIndex, TALENT_ARROW_TEXTURECOORDS['left'][node.leftArrow], xOffset - 16 - 5, yOffset)
                    end
                    if node.topArrow ~= 0 then
                        SetArrowTexture(tabIndex, TALENT_ARROW_TEXTURECOORDS['top'][node.topArrow], xOffset, yOffset + 16 + 5)
                    end
                else
                    if node.up ~= 0 and node.down ~= 0 then
                        SetBranchTexture(tabIndex, TALENT_BRANCH_TEXTURECOORDS['up'][node.up], xOffset, yOffset)
                        SetBranchTexture(tabIndex, TALENT_BRANCH_TEXTURECOORDS['down'][node.down], xOffset, yOffset - 32)
                    elseif node.left ~= 0 and node.right ~= 0 then
                        SetBranchTexture(tabIndex, TALENT_BRANCH_TEXTURECOORDS['right'][node.right], xOffset + 32, yOffset)
                        SetBranchTexture(tabIndex, TALENT_BRANCH_TEXTURECOORDS['left'][node.left], xOffset + 1, yOffset)
                    end
                end
            end
        end
    end

    local function Update()
        if not frame or not frame:IsVisible() then return end

        for tabIndex = 1, 3 do
            local name, _, pointsSpent = GetTalentTabInfo(tabIndex)
            if name then
                treeFrames[tabIndex].header:SetText(name)
                treeFrames[tabIndex].pointsText:SetText(pointsSpent .. ' points')
            end

            ResetBranches(tabIndex)

            local numTalents = GetNumTalents(tabIndex)
            for talentIndex = 1, numTalents do
                local buttonKey = tabIndex .. '_' .. talentIndex
                local button = talentButtons[buttonKey]
                if button then
                    local talentName, iconTexture, tier, column, rank, maxRank, _, _ = GetTalentInfo(tabIndex, talentIndex)
                    if talentName then
                        button.icon:SetTexture(iconTexture)
                        button.rank:SetText(rank .. '/' .. maxRank)

                        local cp1 = UnitCharacterPoints('player')
                        local tierUnlocked = ((tier - 1) * 5 <= pointsSpent)
                        local prereqsMaxed = CheckPrereqsMaxed(tabIndex, talentIndex)

                        if rank == maxRank then
                            button.border:SetVertexColor(1.0, 0.82, 0, 1.0)
                            button.icon:SetDesaturated(nil)
                        elseif rank > 0 then
                            button.border:SetVertexColor(1.0, 0.82, 0, .4)
                            button.icon:SetDesaturated(nil)
                        elseif prereqsMaxed and tierUnlocked and cp1 > 0 and rank < maxRank then
                            button.border:SetVertexColor(0.1, 1.0, 0.1, .3)
                            button.icon:SetDesaturated(nil)
                        else
                            button.border:SetVertexColor(0.5, 0.5, 0.5)
                            button.icon:SetDesaturated(1)
                        end

                        branchArrays[tabIndex][tier][column].id = talentIndex
                        local forceDesaturated
                        if UnitCharacterPoints('player') <= 0 and rank == 0 then
                            forceDesaturated = 1
                        else
                            forceDesaturated = nil
                        end
                        local tierUnlocked2
                        if (tier - 1) * 5 <= pointsSpent then
                            tierUnlocked2 = 1
                        else
                            tierUnlocked2 = nil
                        end
                        SetTalentPrereqs(tabIndex, tier, column, forceDesaturated, tierUnlocked2, GetTalentPrereqs(tabIndex, talentIndex))
                    end
                end
            end
            DrawBranches(tabIndex)
        end

        local points = UnitCharacterPoints('player')
        frame.pointsLeft:SetText('Talent Points Available: |cFFFFFFFF' .. points .. '|r')
    end

    local function CreateAllTalents()
        for tabIndex = 1, 3 do
            local numTalents = GetNumTalents(tabIndex)
            for talentIndex = 1, numTalents do
                local name, _, tier, column = GetTalentInfo(tabIndex, talentIndex)
                if name then
                    local button = CreateTalentButton(tabIndex, talentIndex, tier, column)
                    talentButtons[tabIndex .. '_' .. talentIndex] = button
                end
            end
        end
    end

    local function ToggleFrame()
        if not frame then
            CreateMainFrame()
            CreateTreeFrames()
            CreateAllTalents()
        end
        if frame:IsVisible() then
            frame:Hide()
        else
            frame:Show()
            Update()
        end
    end

    local eventFrame = CreateFrame('Frame')
    eventFrame:RegisterEvent('CHARACTER_POINTS_CHANGED')
    eventFrame:RegisterEvent('PLAYER_LEVEL_UP')
    eventFrame:SetScript('OnEvent', function()
        Update()
    end)

    -- _G['SLASH_BLFTALENTS1'] = '/ttest'
    -- _G.SlashCmdList['BLFTALENTS'] = ToggleFrame

    -- keybind hook
    _G.ToggleTalentFrame = function()
        if UnitLevel('player') < 10 then
            return
        end

        if frame and frame:IsVisible() then
            pcall(PlaySound, "TalentScreenClose")
        else
            pcall(PlaySound, "TalentScreenOpen")
        end

        ToggleFrame()
        UpdateMicroButtons()
    end

    -- micromenu pushed hook
    -- totaly bad place but cant move it elsewhere because of bad code organisation
    local originalUpdateMicroButtons = UpdateMicroButtons
    _G.UpdateMicroButtons = function()
        originalUpdateMicroButtons()
        if frame and frame:IsVisible() then
            TalentMicroButton:SetButtonState('PUSHED', 1)
        else
            TalentMicroButton:SetButtonState('NORMAL')
        end
        if DFRL and DFRL.menuframe and DFRL.menuframe:IsVisible() then
            MainMenuMicroButton:SetButtonState('PUSHED', 1)
        end
    end
end)
