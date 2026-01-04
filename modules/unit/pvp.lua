DFRL:NewDefaults("PVPIcon", {
    enabled = { true },
    pvpDark = {false, "checkbox", nil, nil, "appearance", 1, "Use dark color for PvP icons", nil, nil},
})

DFRL:NewMod("PVPIcon", 1, function()
    local Setup = {
        allianceTexture = "Interface\\AddOns\\DragonflightUI-Reforged\\media\\tex\\unitframes\\UI-PVP-Alliance",
        hordeTexture = "Interface\\AddOns\\DragonflightUI-Reforged\\media\\tex\\unitframes\\UI-PVP-Horde"
    }

    function Setup:UpdatePvPIcon(frame, unit)
        local factionGroup = UnitFactionGroup(unit)
        local pvpIcon = _G[frame .. "PVPIcon"]
        if UnitIsPVPFreeForAll(unit) then
            pvpIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA")
        elseif factionGroup and UnitIsPVP(unit) then
            if factionGroup == "Alliance" then
                pvpIcon:SetTexture(self.allianceTexture)
            else
                pvpIcon:SetTexture(self.hordeTexture)
            end
        end
    end

    local callbacks = {}

    callbacks.pvpDark = function(value)
        local frames = {"Player", "Target"}
        for _, frame in ipairs(frames) do
            local pvpIcon = _G[frame .. "PVPIcon"]
            if pvpIcon then
                if value then
                    pvpIcon:SetVertexColor(0.1, 0.1, 0.1)
                else
                    pvpIcon:SetVertexColor(1, 1, 1)
                end
            end
        end
    end

    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:RegisterEvent("PLAYER_TARGET_CHANGED")
    f:RegisterEvent("UNIT_FACTION")
    f:SetScript("OnEvent", function()
        if event == "PLAYER_ENTERING_WORLD" then
            Setup:UpdatePvPIcon("Player", "player")
            if UnitExists("target") then
                Setup:UpdatePvPIcon("Target", "target")
            end
        elseif event == "PLAYER_TARGET_CHANGED" then
            if UnitExists("target") then
                Setup:UpdatePvPIcon("Target", "target")
            end
        elseif event == "UNIT_FACTION" then
            if arg1 == "player" then
                Setup:UpdatePvPIcon("Player", "player")
            elseif arg1 == "target" then
                Setup:UpdatePvPIcon("Target", "target")
            end
        end
    end)

    DFRL:NewCallbacks("PVPIcon", callbacks)
end)
