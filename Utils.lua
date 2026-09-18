-- ============================================================
-- Utilities
-- ============================================================

Utils = Utils or {}

-- ============================================================
-- String utilities
-- ============================================================

Utils.String = Utils.String or {}

function Utils.String.IsNullOrEmpty(value)
    return value == nil
        or value == ""
end

function Utils.String.IsUsable(value)
    if issecretvalue(value) then
        return false
    end

    return not Utils.String.IsNullOrEmpty(
        value
    )
end

function Utils.String.Colorize(
    text,
    color
)
    return "|c"
        .. color
        .. tostring(text)
        .. "|r"
end

-- ============================================================
-- Execution utilities
-- ============================================================

Utils.Execution = Utils.Execution or {}

function Utils.Execution.Defer(callback)
    C_Timer.After(
        0,
        callback
    )
end

-- ============================================================
-- Table utilities
-- ============================================================

Utils.Table = Utils.Table or {}

-- ============================================================
-- Frame utilities
-- ============================================================

Utils.Frame = Utils.Frame or {}
