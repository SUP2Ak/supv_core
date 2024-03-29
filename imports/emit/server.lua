local TriggerEvent <const>, TriggerClientEvent <const> = TriggerEvent, TriggerClientEvent
local token <const> = supv.getToken()

local function PlayEvent(_, name, source, ...)
    TriggerEvent(supv:hashEvent(name), token, ...)
end

supv.emit = setmetatable({}, {
    __call = PlayEvent
})

function supv.emit.net(name, source, ...)
    TriggerClientEvent(supv:hashEvent(name, 'client'), source, ...)
end

return supv.emit