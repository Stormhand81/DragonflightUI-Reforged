local function PlayMenuSound(open)
    if open then
        if SOUNDKIT and SOUNDKIT.IG_MAINMENU_OPEN then
            PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
        else
            PlaySound("igMainMenuOpen")
        end
    else
        if SOUNDKIT and SOUNDKIT.IG_MAINMENU_CLOSE then
            PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE)
        else
            PlaySound("igMainMenuClose")
        end
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function()
    if not GameMenuFrame then return end

    -- evita som duplicado caso o Blizzard já toque em algum build
    local lastState = GameMenuFrame:IsShown()

    GameMenuFrame:HookScript("OnShow", function()
        if lastState ~= true then
            PlayMenuSound(true)
            lastState = true
        end
    end)

    GameMenuFrame:HookScript("OnHide", function()
        if lastState ~= false then
            PlayMenuSound(false)
            lastState = false
        end
    end)
end)
