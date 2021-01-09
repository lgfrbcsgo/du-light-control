local Elements = require("custom/light-controller/core/elements")

local function Sequencer(sequenceIterator, lights, system, intervalDuration, idleState)
    local instance = {}

    function instance._init()
        instance._nextUpdate = 0
    end

    function instance._setNextUpdate()
        local nextIntervalIndex = math.ceil(system.getTime() / intervalDuration)
        instance._nextUpdate = nextIntervalIndex * intervalDuration
    end

    function instance.onStart()
        instance._setNextUpdate()
        sequenceIterator.seekHead()
    end

    function instance.onStop()
        for _, light in pairs(lights) do
            Elements.setLightState(light, idleState)
        end
    end

    function instance.onTick()
        if instance._nextUpdate > system.getTime() then
            return
        end

        local step = {}
        if not sequenceIterator.isEmpty() then
            step = sequenceIterator.getStep()
        end

        for index, light in pairs(lights) do
            local state = step[index] or Elements.LIGHT_OFF
            Elements.setLightState(light, state)
        end

        if sequenceIterator.hasNext() then
            sequenceIterator.seekNext()
        else
            sequenceIterator.seekHead()
        end

        instance._setNextUpdate()
    end

    instance._init()
    return instance
end

return Sequencer