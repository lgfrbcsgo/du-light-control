local Sequence = require("custom/light-controller/core/sequence")
local Elements = require("custom/light-controller/core/elements")

local function generateStepCode(parts, step)
    table.insert(parts, "{")
    for _, state in pairs(step) do
        local stateStr = string.format("{on=%s,r=%d,g=%d,b=%d},", state.on, state.r, state.g, state.b)
        table.insert(parts, stateStr)
    end
    table.insert(parts, "},")
end

local function generateSequenceCode(parts, sequenceIterator)
    table.insert(parts, "{")
    if not sequenceIterator.isEmpty() then
        local step = sequenceIterator.getStep()
        generateStepCode(parts, step)
    end
    while sequenceIterator.hasNext() do
        local step = sequenceIterator.seekNext()
        generateStepCode(parts, step)
    end
    table.insert(parts, "}")
end

local function Main(unit)
    local dbs = Elements.getDatabases(unit)
    local screen = Elements.getScreen(unit)

    local parts = {}

    for _, db in pairs(dbs) do
        local sequenceIterator = Sequence.Iterator(db, Sequence.DEFAULT, true)
        generateSequenceCode(parts, sequenceIterator)
        table.insert(parts, "\n\n")
    end

    screen.setHTML(table.concat(parts))

    unit.exit()
end

return Main