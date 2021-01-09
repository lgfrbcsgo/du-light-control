local function NoopHandler()
    local instance = {}

    function instance.onStart() end
    function instance.onStop() end
    function instance.onUpdate() end

    function instance.onOption2() end
    function instance.onOption3() end
    function instance.onOption4() end
    function instance.onOption5() end
    function instance.onOption6() end
    function instance.onOption9() end

    function instance.onStrafeLeft() end
    function instance.onStrafeRight() end

    function instance.onInputText() end

    return instance
end

return NoopHandler