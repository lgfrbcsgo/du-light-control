local Elements = {}

local function getSlots(unit)
    return { unit.slot1, unit.slot2, unit.slot3, unit.slot4, unit.slot5,
             unit.slot6, unit.slot7, unit.slot8, unit.slot9, unit.slot10 }
end

function Elements.getElements(unit, predicate)
    local slots = getSlots(unit)
    local elements = {}
    for _, element in pairs(slots) do
        if predicate(element) then
            table.insert(elements, element)
        end
    end
    return elements
end

function Elements.getLights(unit)
    local function predicate(element)
        return element.activate and element.deactivate and element.toggle
                and element.getState and element.getRGBColor and element.setRGBColor
    end

    return Elements.getElements(unit, predicate)
end

function Elements.getDatabases(unit)
    local function predicate(element)
        return element.setStringValue and element.getStringValue
    end

    return Elements.getElements(unit, predicate)
end

function Elements.getDatabase(unit)
    return Elements.getDatabases(unit)[1]
end

function Elements.getScreen(unit)
    local function predicate(element)
        return element.setHTML
    end

    return Elements.getElements(unit, predicate)[1]
end

function Elements.setLightState(light, state)
    if state.on then
        light.activate()
    else
        light.deactivate()
    end
    light.setRGBColor(state.r, state.g, state.b)
end

function Elements.getLightState(light)
    local on = 1 == light.isActive()
    local color = light.getColor()
    return {
        on = on,
        r = color[1],
        g = color[2],
        b = color[3],
    }
end

Elements.LIGHT_OFF = {
    on = false,
    r = 255,
    g = 255,
    b = 255,
}

Elements.LIGHT_ON = {
    on = true,
    r = 255,
    g = 255,
    b = 255,
}

return Elements
