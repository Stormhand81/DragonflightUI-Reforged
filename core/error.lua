local error_counts = {}
local max_errors = 2

local function GetAddonName(msg)
    local start = string.find(msg, 'AddOns\\')
    if start then
        local path = string.sub(msg, start + 7)
        local end_pos = string.find(path, '\\')
        if end_pos then
            return string.sub(path, 1, end_pos - 1)
        end
    end
    return 'UNKNOWN'
end

local function FormatErrorMessage(addon, msg, throttled)
    if throttled then
        return '|cffff0000DFRL: Error: |cffffffff[|cffffffffSource: |cffff0000' .. addon .. '|cffffffff] : [|cffff0000ERROR SPAM THROTTLED|cffffffff]'
    else
        return '|cffff0000DFRL: Error: |cffffffff[|cffffffffSource: |cffff0000' .. addon .. '|cffffffff] : |cffffffff' .. (msg or 'nil')
    end
end

local function ErrorHandler(msg)
    local addon = GetAddonName(msg)

    if not error_counts[msg] then
        error_counts[msg] = 1
        DEFAULT_CHAT_FRAME:AddMessage(FormatErrorMessage(addon, msg, false))
    else
        error_counts[msg] = error_counts[msg] + 1
        if error_counts[msg] <= max_errors then
            DEFAULT_CHAT_FRAME:AddMessage(FormatErrorMessage(addon, msg, false))
        elseif error_counts[msg] == max_errors + 1 then
            DEFAULT_CHAT_FRAME:AddMessage(FormatErrorMessage(addon, msg, true))
        end
    end
end

seterrorhandler(ErrorHandler)

local f = CreateFrame'Frame'
f:RegisterEvent'ADDON_LOADED'
f:SetScript('OnEvent', function()
    seterrorhandler(ErrorHandler)
end)