local NoopHandler = require("custom/light-controller/handlers/noop")
local Sequencer = require("custom/light-controller/core/sequencer")
local Elements = require("custom/light-controller/core/elements")
local Sequence = require("custom/light-controller/core/sequence")

local function SequencerHandler(unit, intervalDuration, idleState)
    local sequenceIterator = Sequence.Iterator(Elements.getDatabase(unit), Sequence.DEFAULT)
    local lights = Elements.getLights(unit)

    local sequencer = Sequencer(sequenceIterator, lights, unit.system, intervalDuration, idleState)
    local instance = NoopHandler()

    function instance.onStart()
        unit.system.print()
        unit.system.print("Playback mode")
        unit.system.print(unit.system.getActionKeyName("option1") .. " to switch into programming mode")
        unit.system.print()

        sequenceIterator.seekHead()
        sequencer.onStart()
    end

    instance.onUpdate = sequencer.onTick
    instance.onStop = sequencer.onStop

    return instance
end

return SequencerHandler