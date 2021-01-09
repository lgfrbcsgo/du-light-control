local Elements = require("custom/light-controller/core/elements")
local Steps = require("custom/light-controller/core/steps")

local function Programmer(sequenceIterator, lights, system)
    local instance = {}

    function instance._init()
        instance._fastTravel = false
        instance._copiedStep = {}

        if sequenceIterator.isEmpty() then
            sequenceIterator.insertAfter({})
        end
    end

    function instance._saveChanges()
        local step = {}
        for index, light in pairs(lights) do
            step[index] = Elements.getLightState(light)
        end
        sequenceIterator.setStep(step)
    end

    function instance._updateLights()
        local step = sequenceIterator.getStep()
        for index, light in pairs(lights) do
            local state = step[index] or Elements.LIGHT_OFF
            Elements.setLightState(light, state)
        end
    end

    function instance.onStart()
        instance._fastTravel = false

        local _, stepNumber = sequenceIterator.getStep()
        system.print("Current step: " .. stepNumber)
        instance._updateLights()
    end

    function instance.onStop()
        instance._saveChanges()
        for _, light in pairs(lights) do
            Elements.setLightState(light, Elements.LIGHT_OFF)
        end
    end

    function instance.onNext()
        instance._saveChanges()
        if sequenceIterator.hasNext() then
            local _, stepNumber = sequenceIterator.seekNext(instance._fastTravel and 10 or 1)
            system.print("Switched to next step: " .. stepNumber)
        elseif not instance._fastTravel then
            local _, stepNumber = sequenceIterator.insertAfter({})
            system.print("Created next step: " .. stepNumber)
        end
        instance._updateLights()
    end

    function instance.onPrevious()
        instance._saveChanges()
        if sequenceIterator.hasPrevious() then
            local _, stepNumber = sequenceIterator.seekPrevious(instance._fastTravel and 10 or 1)
            system.print("Switched to previous step: " .. stepNumber)
            instance._updateLights()
        end
    end

    function instance.onInsertBefore()
        instance._saveChanges()
        local _, stepNumber = sequenceIterator.insertBefore({})
        system.print("Inserted step: " .. stepNumber)
        instance._updateLights()
    end

    function instance.onInsertAfter()
        instance._saveChanges()
        local _, stepNumber = sequenceIterator.insertAfter({})
        system.print("Inserted step: " .. stepNumber)
        instance._updateLights()
    end

    function instance.onDelete()
        sequenceIterator.delete()
        if sequenceIterator.isEmpty() then
            sequenceIterator.insertAfter({})
        end
        local _, stepNumber = sequenceIterator.getStep()
        system.print("Deleted step. Current step: " .. stepNumber)
        instance._updateLights()
    end

    function instance.onToggleFastTravel()
        instance._fastTravel = not instance._fastTravel
        if instance._fastTravel then
            system.print("Activated fast travel mode.")
        else
            system.print("Deactivated fast travel mode.")
        end
    end

    function instance.onCopy()
        instance._saveChanges()
        instance._copiedStep = sequenceIterator.getStep()
        system.print("Copied step.")
    end

    function instance.onPaste()
        sequenceIterator.setStep(instance._copiedStep)
        system.print("Pasted step.")
        instance._updateLights()
    end

    function instance.onReplace(state, replaceState)
        instance._saveChanges()

        local step = sequenceIterator.getStep()

        for i = 1, #step do
            if Steps.stateEquals(step[i], state) then
                step[i] = replaceState
            end
        end

        sequenceIterator.setStep(step)

        system.print("Replaced color.")
        instance._updateLights()
    end

    instance._init()
    return instance
end

return Programmer