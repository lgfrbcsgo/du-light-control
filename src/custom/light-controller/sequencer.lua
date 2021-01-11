local Sequencer = require('custom/light-controller/core/sequencer')
local Elements = require("custom/light-controller/core/elements")

local function Iterator(sequence)
    local instance = {}

    function instance._init()
        instance._stepNumber = nil
        instance.seekHead()
    end

    function instance.isEmpty()
        return #sequence == 0
    end

    function instance.getStep()
        if not instance._stepNumber or not sequence[instance._stepNumber] then
            return nil, nil
        end
        return sequence[instance._stepNumber], instance._stepNumber
    end

    function instance.seekHead()
        if not instance.isEmpty() then
            instance._stepNumber = 1
        else
            instance._stepNumber = nil
        end
        return instance.getStep()
    end

    function instance.hasNext()
        return instance._stepNumber and instance._stepNumber < #sequence
    end

    function instance.seekNext()
        if instance.hasNext() then
            instance._stepNumber = instance._stepNumber + 1
        end
        return instance.getStep()
    end

    function instance.seekIntervalIndex(index)
        if not instance.isEmpty() then
            local sequenceIndex = index % #sequence
            instance._stepNumber = sequenceIndex + 1
        end
        return instance.getStep()
    end

    instance._init()
    return instance
end


local function Main(unit, sequence, intervalDuration, idleState)
    local lights = Elements.getLights(unit)
    local sequenceIterator = Iterator(sequence)

    local intervalIndex = math.ceil(unit.system.getTime() / intervalDuration)
    sequenceIterator.seekIntervalIndex(intervalIndex)

    if idleState then
        return Sequencer(sequenceIterator, lights, unit.system, intervalDuration, Elements.LIGHT_ON)
    else
        return Sequencer(sequenceIterator, lights, unit.system, intervalDuration, Elements.LIGHT_OFF)
    end
end

return Main