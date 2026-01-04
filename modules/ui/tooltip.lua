DFRL:NewDefaults("Tooltip", {
    enabled = {true},
    toolTipMouse = {false, "checkbox", nil, nil, "tweaks", 1, "Show the tooltip above your cursor", nil, nil},
    toolTipX = {0, "slider", {-400, 200, 15}, nil, "tweaks", 2, "Adjust X offset of the tooltip", nil, nil},
    toolTipY = {0, "slider", {-200, 200, 15}, nil, "tweaks", 3, "Adjust Y offset of the tooltip", nil, nil},
})

DFRL:NewMod("Tooltip", 1, function()
    local Setup = {
        xOffset = 0,
        yOffset = 0
    }

    -- callbacks
    local callbacks = {}

    callbacks.toolTipMouse = function(value)
        if value then
            GameTooltip:SetScript("OnUpdate", function()
                if GameTooltip:IsShown() then
                    local x, y = GetCursorPosition()
                    local scale = GameTooltip:GetEffectiveScale()
                    GameTooltip:ClearAllPoints()
                    GameTooltip:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", (x / scale) + Setup.xOffset, (y / scale) + Setup.yOffset)
                end
            end)
        else
            GameTooltip:SetScript("OnUpdate", nil)
        end
    end

    callbacks.toolTipX = function(value)
        Setup.xOffset = value
    end

    callbacks.toolTipY = function(value)
        Setup.yOffset = value
    end

    -- execute  callbacks
    DFRL:NewCallbacks("Tooltip", callbacks)
end)
