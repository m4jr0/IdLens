-- ============================================================
-- IDLens
-- Tooltip identification and decoration
-- ============================================================

IDLens = IDLens or {}

local ID_COLOR = "ff808080"
local SUPPORTED_TYPES = {}

local function RegisterType(enumValue, databaseType)
    if enumValue ~= nil then
        SUPPORTED_TYPES[enumValue] = databaseType
    end
end

RegisterType(Enum.TooltipDataType.Item, "item")
RegisterType(Enum.TooltipDataType.Spell, "spell")
RegisterType(Enum.TooltipDataType.Quest, "quest")

local UNIT_TYPE = Enum.TooltipDataType.Unit

local function GetUnitToken(data)
    if not data or not data.lines then
        return nil
    end

    for _, line in ipairs(data.lines) do
        if line.unitToken then
            return line.unitToken
        end
    end

    return nil
end

local function GetIdentifier(data)
    if not data or data.type == nil then
        return nil
    end

    if data.type == UNIT_TYPE then
        local unitToken = GetUnitToken(data)

        return IDLens.Identifier.FromGUID(
            data.guid,
            unitToken
        )
    end

    local databaseType = SUPPORTED_TYPES[data.type]

    if not databaseType then
        return nil
    end

    return IDLens.Identifier.CreateDatabase(databaseType, data.id)
end

local function DecorateTitle(tooltip, identifier)
    if not tooltip or not identifier or not identifier.id then
        return
    end

    local tooltipName = tooltip:GetName()

    if not tooltipName then
        return
    end

    local title = _G[tooltipName .. "TextLeft1"]

    if not title then
        return
    end

    local text = title:GetText()

    if not Utils.String.IsUsable(text) then
        return
    end

    local idText = "(" .. tostring(identifier.id) .. ")"

    if text:find(idText, 1, true) then
        return
    end

    title:SetText(
        text
        .. " "
        .. Utils.String.Colorize(idText, ID_COLOR)
    )
end

local tooltipOwners = setmetatable({}, { __mode = "k" })
local hookedTooltips = setmetatable({}, { __mode = "k" })

local function ClearTooltipAssociation(tooltip)
    local owner = tooltipOwners[tooltip]

    IDLens.EntityResolver.ClearFrameIdentifier(tooltip)

    if owner then
        IDLens.EntityResolver.ClearFrameIdentifier(owner)
        tooltipOwners[tooltip] = nil
    end
end

local function AssociateWithCursor(tooltip, identifier)
    -- This permits direct inspection of mouse-enabled or pinned tooltips.
    IDLens.EntityResolver.SetFrameIdentifier(tooltip, identifier)

    if not tooltip.GetOwner then
        return
    end

    local owner = tooltip:GetOwner()

    if owner and owner ~= UIParent then
        tooltipOwners[tooltip] = owner
        IDLens.EntityResolver.SetFrameIdentifier(owner, identifier)
    end
end

local function OnTooltipData(tooltip, data)
    if not hookedTooltips[tooltip] then
        hookedTooltips[tooltip] = true
        tooltip:HookScript(
            "OnHide",
            ClearTooltipAssociation
        )
    end

    -- A recycled tooltip may have changed to an unsupported entity.
    ClearTooltipAssociation(tooltip)

    local identifier = GetIdentifier(data)

    if not identifier then
        return
    end

    AssociateWithCursor(tooltip, identifier)

    -- Decoration is an output concern, separate from cursor selection.
    DecorateTitle(tooltip, identifier)
end

TooltipDataProcessor.AddTooltipPostCall(
    TooltipDataProcessor.AllTypes,
    OnTooltipData
)
