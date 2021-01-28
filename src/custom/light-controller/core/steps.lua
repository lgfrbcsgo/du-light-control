local Steps = {}

function Steps.packStateInt(state)
    local on = (state.on and 1 or 0) << 24
    local r = (math.floor(state.r) & 255) << 16
    local g = (math.floor(state.g) & 255) << 8
    local b = math.floor(state.b) & 255

    return on | r | g | b
end

function Steps.packState(state)
    return string.format("%07x", Steps.packStateInt(state))
end

function Steps.unpackState(stateStr)
    local state = tonumber(stateStr, 16)

    return {
        on = (state >> 24) == 1,
        r = (state >> 16) & 255,
        g = (state >> 8) & 255,
        b = state & 255,
    }
end

function Steps.stateEquals(stateA, stateB)
    return stateA.on == stateB.on and stateA.r == stateB.r and stateA.g == stateB.g and stateA.b == stateB.b
end

function Steps.packStep(step)
    local stateStrs = {}
    for _, state in pairs(step) do
        table.insert(stateStrs, Steps.packState(state))
    end
    return table.concat(stateStrs)
end

function Steps.unpackStep(stepStr)
    local step = {}
    for stateStr in string.gmatch(stepStr, '.......') do
        table.insert(step, Steps.unpackState(stateStr))
    end
    return step
end

return Steps
