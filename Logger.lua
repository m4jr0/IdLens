-- ============================================================
-- IDLens
-- Logger
-- ============================================================

IDLens = IDLens or {}
IDLens.Logger = IDLens.Logger or {}

-- ============================================================
-- Configuration
-- ============================================================

local DEBUG_ENABLED = false

-- ============================================================
-- Colors
-- ============================================================

local COLORS = {
    PREFIX  = "ffffd100",
    INFO    = "ffffffff",
    SUCCESS = "ff40c040",
    WARNING = "ffffa500",
    ERROR   = "ffff4040",
    DEBUG   = "ff808080"
}

-- ============================================================
-- Helpers
-- ============================================================

local function BuildPrefix()
    return Utils.String.Colorize(
        "IDLens:",
        COLORS.PREFIX
    )
end

local function Print(
    color,
    ...
)
    local parts = {}

    for index = 1, select("#", ...) do
        parts[index] = tostring(
            select(
                index,
                ...
            )
        )
    end

    local message = table.concat(
        parts,
        " "
    )

    DEFAULT_CHAT_FRAME:AddMessage(
        BuildPrefix()
        .. " "
        .. Utils.String.Colorize(
            message,
            color
        )
    )
end

-- ============================================================
-- Public API
-- ============================================================

function IDLens.Logger.Info(...)
    Print(
        COLORS.INFO,
        ...
    )
end

function IDLens.Logger.Success(...)
    Print(
        COLORS.SUCCESS,
        ...
    )
end

function IDLens.Logger.Warning(...)
    Print(
        COLORS.WARNING,
        ...
    )
end

function IDLens.Logger.Error(...)
    Print(
        COLORS.ERROR,
        ...
    )
end

function IDLens.Logger.Debug(...)
    if not DEBUG_ENABLED then
        return
    end

    Print(
        COLORS.DEBUG,
        "[Debug]",
        ...
    )
end