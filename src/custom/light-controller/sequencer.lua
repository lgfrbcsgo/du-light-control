local Sequencer = require('custom/light-controller/core/sequencer')
local Elements = require("custom/light-controller/core/elements")
local Steps = require("custom/light-controller/core/steps")

local function Iterator(sequence)
    local instance = {}

    function instance._init()
        instance._stepNumber = nil
    end

    function instance.isEmpty()
        return #sequence == 0
    end

    function instance.getStep()
        if not instance._stepNumber or not sequence[instance._stepNumber] then
            return nil, nil
        end
        return Steps.unpackStep(sequence[instance._stepNumber]), instance._stepNumber
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
        return instance._stepNumber < #sequence
    end

    function instance.seekNext()
        if instance.hasNext() then
            instance._stepNumber = instance._stepNumber + 1
        end
        return instance.getStep()
    end

    instance._init()
    return instance
end


local function Main(unit, sequence, intervalDuration, idleState)
    local lights = Elements.getLights(unit)
    local sequenceIterator = Iterator(sequence)

    if idleState then
        return Sequencer(sequenceIterator, lights, unit.system, intervalDuration, Elements.LIGHT_ON)
    else
        return Sequencer(sequenceIterator, lights, unit.system, intervalDuration, Elements.LIGHT_OFF)
    end
end

return Main