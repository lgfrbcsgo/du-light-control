local Sequence = require("custom/light-controller/core/sequence")
local Elements = require("custom/light-controller/core/elements")
local Steps = require("custom/light-controller/core/steps")

local function generateStepCode(step)
    local parts = {}
    for _, state in pairs(step) do
        local stateStr = string.format("0x%x", Steps.packStateInt(state))
        table.insert(parts, stateStr)
    end
    return string.format("{%s}", table.concat(parts, ","))
end

local function generateSequenceCode(sequenceIterator)
    local parts = {}
    if not sequenceIterator.isEmpty() then
        local step = sequenceIterator.getStep()
        table.insert(parts, generateStepCode(step))
    end
    while sequenceIterator.hasNext() do
        local step = sequenceIterator.seekNext()
        table.insert(parts, generateStepCode(step))
    end
    return string.format("{%s}", table.concat(parts, ","))
end

local function Main(unit)
    local dbs = Elements.getDatabases(unit)
    local screen = Elements.getScreen(unit)

    parts = {}
    for _, db in pairs(dbs) do
        local sequenceIterator = Sequence.Iterator(db, Sequence.DEFAULT, true)
        table.insert(parts, generateSequenceCode(sequenceIterator))
    end
    screen.setHTML(table.concat(parts, "\n\n"))

    unit.exit()
end

return Main