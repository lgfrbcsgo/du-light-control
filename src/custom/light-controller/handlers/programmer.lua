local NoopHandler = require("custom/light-controller/handlers/noop")
local Programmer = require("custom/light-controller/core/programmer")
local Elements = require("custom/light-controller/core/elements")
local Sequence = require("custom/light-controller/core/sequence")

local function ProgrammerHandler(unit)
    local sequenceIterator = Sequence.Iterator(Elements.getDatabase(unit), Sequence.DEFAULT)
    local lights = Elements.getLights(unit)

    local programmer = Programmer(sequenceIterator, lights, unit.system)
    local instance = NoopHandler()

    function instance.onStart()
        unit.system.print()
        unit.system.print("Programming mode")
        unit.system.print(unit.system.getActionKeyName("option1") .. " to switch into playback mode")
        unit.system.print(unit.system.getActionKeyName("option2") .. " to toggle fast travel mode")
        unit.system.print(unit.system.getActionKeyName("option3") .. " to insert a new step before the current step")
        unit.system.print(unit.system.getActionKeyName("option4") .. " to insert a new step after the current step")
        unit.system.print(unit.system.getActionKeyName("option5") .. " to copy the current step")
        unit.system.print(unit.system.getActionKeyName("option6") .. " to paste the copied step into the current step")
        unit.system.print(unit.system.getActionKeyName("option9") .. " to delete the current step")
        unit.system.print(unit.system.getActionKeyName("strafeleft") .. " to switch to the previous step")
        unit.system.print(unit.system.getActionKeyName("straferight") .. " to switch to the next step. Creates a new step when the end of the sequence is reached.")
        unit.system.print()
        unit.system.print("Write 'replace 255,255,255 with 255,0,0' to replace the color of all lights with that color.")
        unit.system.print("Type '!' before a color to match lights which are currently off.")
        unit.system.print()

        programmer.onStart()
    end

    instance.onStop = programmer.onStop

    instance.onOption2 = programmer.onToggleFastTravel

    instance.onOption3 = programmer.onInsertBefore
    instance.onOption4 = programmer.onInsertAfter

    instance.onOption5 = programmer.onCopy
    instance.onOption6 = programmer.onPaste

    instance.onOption9 = programmer.onDelete

    instance.onStrafeLeft = programmer.onPrevious
    instance.onStrafeRight = programmer.onNext

    function instance.onInputText(text)
        local pattern = "replace (!?) ?(%d+), ?(%d+), ?(%d+) with (!?) ?(%d+), ?(%d+), ?(%d+)"
        local off, r, g, b, replaceOff, replaceR, replaceG, replaceB = string.match(text, pattern)

        if not (off and r and g and b and replaceOff and replaceR and replaceG and replaceB) then
            return
        end

        local state = {
            on = off ~= "!",
            r = math.min(tonumber(r), 255),
            g = math.min(tonumber(g), 255),
            b = math.min(tonumber(b), 255),
        }
        local replaceState = {
            on = replaceOff ~= "!",
            r = math.min(tonumber(replaceR), 255),
            g = math.min(tonumber(replaceG), 255),
            b = math.min(tonumber(replaceB), 255),
        }

        programmer.onReplace(state, replaceState)
    end

    return instance
end

return ProgrammerHandler