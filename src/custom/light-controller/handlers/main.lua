local ProgrammerHandler = require("custom/light-controller/handlers/programmer")
local SequencerHandler = require("custom/light-controller/handlers/sequencer")
local Elements = require("custom/light-controller/core/elements")

local function Main(unit, intervalDuration)
    local instance = {}

    function instance._init()
        instance._handlerIndex = 0
        instance._handlers = {ProgrammerHandler(unit), SequencerHandler(unit, intervalDuration, Elements.LIGHT_OFF)}
    end

    function instance._currentHandler()
        return instance._handlers[instance._handlerIndex % #instance._handlers + 1]
    end

    function instance._switchHandler()
        instance._handlerIndex = instance._handlerIndex + 1
        return instance._currentHandler()
    end

    function instance.onStart()
        instance._currentHandler().onStart()
    end

    function instance.onStop()
        instance._currentHandler().onStop()
    end

    function instance.onUpdate()
        instance._currentHandler().onUpdate()
    end

    function instance.onOption1()
        instance._currentHandler().onStop()
        local nextHandler = instance._switchHandler()
        nextHandler.onStart()
    end

    function instance.onOption2()
        instance._currentHandler().onOption2()
    end

    function instance.onOption3()
        instance._currentHandler().onOption3()
    end

    function instance.onOption4()
        instance._currentHandler().onOption4()
    end

    function instance.onOption5()
        instance._currentHandler().onOption5()
    end

    function instance.onOption6()
        instance._currentHandler().onOption6()
    end

    function instance.onOption9()
        instance._currentHandler().onOption9()
    end

    function instance.onStrafeLeft()
        instance._currentHandler().onStrafeLeft()
    end

    function instance.onStrafeRight()
        instance._currentHandler().onStrafeRight()
    end

    function instance.onInputText(text)
        instance._currentHandler().onInputText(text)
    end

    instance._init()
    return instance
end

return Main