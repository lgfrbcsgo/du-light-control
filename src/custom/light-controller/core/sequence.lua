local Steps = require("custom/light-controller/core/steps")

local NEXT_KEY = "__NEXT_KEY__"
local HEAD = "__HEAD"
local NEXT = "__NEXT"
local PREVIOUS = "__PREVIOUS"

local function generateNextKey(db)
    local nextKey = db.getIntValue(NEXT_KEY)
    db.setIntValue(NEXT_KEY, nextKey + 1)
    return tostring(nextKey)
end

local Sequence = {}

function Sequence.Iterator(db, sequenceName, raw)
    local instance = {}

    function instance._init()
        instance._stepNumber = nil
        instance._currentPointer = nil
        instance.seekHead()
    end

    function instance._getHeadPointer()
        local headPointer = db.getStringValue(sequenceName .. HEAD)
        if headPointer == "" then
            return nil
        end
        return headPointer
    end

    function instance._setHeadPointer(headPointer)
        db.setStringValue(sequenceName .. HEAD, headPointer)
    end

    function instance._getNextPointer(itemPointer)
        itemPointer = itemPointer or instance._currentPointer
        local nextPointer = itemPointer and db.getStringValue(itemPointer .. NEXT)
        if nextPointer == "" then
            return nil
        end
        return nextPointer
    end

    function instance._setNextPointer(nextPointer, itemPointer)
        itemPointer = itemPointer or instance._currentPointer
        if itemPointer ~= nil then
            db.setStringValue(itemPointer .. NEXT, nextPointer)
        end
    end

    function instance._getPreviousPointer(itemPointer)
        itemPointer = itemPointer or instance._currentPointer
        local previousPointer = itemPointer and db.getStringValue(itemPointer .. PREVIOUS)
        if previousPointer == "" then
            return nil
        end
        return previousPointer
    end

    function instance._setPreviousPointer(previousPointer, itemPointer)
        itemPointer = itemPointer or instance._currentPointer
        if itemPointer ~= nil then
            db.setStringValue(itemPointer .. PREVIOUS, previousPointer)
        end
    end

    function instance.isEmpty()
        return instance._currentPointer == nil
    end

    function instance.seekHead()
        instance._currentPointer = instance._getHeadPointer()
        if instance._currentPointer ~= nil then
            instance._stepNumber = 1
        else
            instance._stepNumber = nil
        end
        return instance.getStep()
    end

    function instance.hasNext()
        return instance._getNextPointer() ~= nil
    end

    function instance.seekNext(steps)
        for _ = 1, steps or 1 do
            if not instance.hasNext() then
                break
            end
            instance._currentPointer = instance._getNextPointer()
            instance._stepNumber = instance._stepNumber + 1
        end
        return instance.getStep()
    end

    function instance.hasPrevious()
        return instance._getPreviousPointer() ~= nil
    end

    function instance.seekPrevious(steps)
        for _ = 1, steps or 1 do
            if not instance.hasPrevious() then
                break
            end
            instance._currentPointer = instance._getPreviousPointer()
            instance._stepNumber = instance._stepNumber - 1
        end
        return instance.getStep()
    end

    function instance.getStep()
        if instance.isEmpty() then
            return nil, nil
        end
        local step = db.getStringValue(instance._currentPointer)
        if not raw then
            step = Steps.unpackStep(step)
        end
        return step, instance._stepNumber
    end

    function instance.setStep(step)
        if instance.isEmpty() then
            return
        end
        if not raw then
            step = Steps.packStep(step)
        end
        db.setStringValue(instance._currentPointer, step)
    end

    function instance.delete()
        if instance.isEmpty() then
            return
        end

        local nextPointer = instance._getNextPointer()
        local previousPointer = instance._getPreviousPointer()

        if previousPointer ~= nil then
            instance._setNextPointer(nextPointer, previousPointer)
        end

        if nextPointer ~= nil then
            instance._setPreviousPointer(previousPointer, nextPointer)
            if previousPointer == nil then
                instance._setHeadPointer(nextPointer)
            end
        end

        if nextPointer ~= nil then
            instance._currentPointer = nextPointer
            return instance.getStep()
        elseif previousPointer ~= nil then
            return instance.seekPrevious()  -- since we're not deleting any keys, we can just go to the previous step
        else
            instance._setHeadPointer(nil)
            return instance.seekHead()
        end
    end

    function instance.insertBefore(step)
        local pointer = generateNextKey(db)

        if not raw then
            step = Steps.packStep(step)
        end

        db.setStringValue(pointer, step)

        if instance.hasPrevious() then
            instance._setPreviousPointer(instance._getPreviousPointer(), pointer)
            instance._setNextPointer(pointer, instance._getPreviousPointer())
        else
            instance._setHeadPointer(pointer)
        end

        if not instance.isEmpty() then
            instance._setPreviousPointer(pointer, instance._currentPointer)
            instance._setNextPointer(instance._currentPointer, pointer)
            instance._currentPointer = pointer
            return instance.getStep()
        else
            instance._setHeadPointer(pointer)
            return instance.seekHead()
        end
    end

    function instance.insertAfter(step)
        local pointer = generateNextKey(db)

        if not raw then
            step = Steps.packStep(step)
        end

        db.setStringValue(pointer, step)

        if instance.hasNext() then
            instance._setNextPointer(instance._getNextPointer(), pointer)
            instance._setPreviousPointer(pointer, instance._getNextPointer())
        end

        if not instance.isEmpty() then
            instance._setPreviousPointer(instance._currentPointer, pointer)
            instance._setNextPointer(pointer, instance._currentPointer)
            return instance.seekNext()
        else
            instance._setHeadPointer(pointer)
            return instance.seekHead()
        end
    end

    instance._init()
    return instance
end

Sequence.DEFAULT = "default"

return Sequence