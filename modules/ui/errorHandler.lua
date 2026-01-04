DFRL:NewDefaults('Errors', {
    enabled = {true},
    hideErrors = {false, 'checkbox', nil, nil, 'tweaks', 1, 'Hide all lua errors', nil, nil},
})

DFRL:NewMod('Errors', 1, function()
    local originalHandler = geterrorhandler()

    local callbacks = {}

    callbacks.hideErrors = function(value)
        if value then
            seterrorhandler(function() end)
        else
            seterrorhandler(originalHandler)
        end
    end

    DFRL:NewCallbacks('Errors', callbacks)
end)
