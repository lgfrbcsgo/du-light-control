local Sequence = require("custom/light-controller/core/sequence")
local Elements = require("custom/light-controller/core/elements")

local function extractParts(parts, sequenceIterator)
    table.insert(parts, "{")
    if not sequenceIterator.isEmpty() then
        local step = sequenceIterator.getStep()
        table.insert(parts, '"' .. step .. '",')
    end
    while sequenceIterator.hasNext() do
        local step = sequenceIterator.seekNext()
        table.insert(parts, '"' .. step .. '",')
    end
    table.insert(parts, "}")
end

local function Main(unit)
    local dbs = Elements.getDatabases(unit)
    local screen = Elements.getScreen(unit)

    local parts = {}

    for _, db in pairs(dbs) do
        local sequenceIterator = Sequence.Iterator(db, Sequence.DEFAULT, true)
        extractParts(parts, sequenceIterator)
        table.insert(parts, "\n\n")
    end

    screen.setHTML(table.concat(parts))

    unit.exit()
end

return Main