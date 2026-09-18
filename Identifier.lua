-- ============================================================
-- IDLens
-- Entity identifiers
-- ============================================================

IDLens = IDLens or {}
IDLens.Identifier = IDLens.Identifier or {}

local Identifier = IDLens.Identifier

function Identifier.CreateDatabase(databaseType, id)
    if not Utils.String.IsUsable(databaseType)
        or not Utils.String.IsUsable(id) then
        return nil
    end

    id = tonumber(id)

    if not id then
        return nil
    end

    return {
        kind = databaseType,
        databaseType = databaseType,
        id = id
    }
end

function Identifier.CreatePlayer(name, realm)
    if not Utils.String.IsUsable(name) then
        return nil
    end

    if not Utils.String.IsUsable(realm) then
        realm = nil
    end

    return {
        kind = "player",
        name = name,
        realm = realm
    }
end

function Identifier.FromGUID(guid, unitToken)
    if not Utils.String.IsUsable(guid) then
        return nil
    end

    local unitType = strsplit("-", guid)

    if unitType == "Player" then
        if not Utils.String.IsUsable(unitToken) then
            return nil
        end

        local name, realm = UnitFullName(unitToken)

        return Identifier.CreatePlayer(name, realm)
    end

    if unitType ~= "Creature"
        and unitType ~= "Vehicle"
        and unitType ~= "Pet" then
        return nil
    end

    local npcID = C_CreatureInfo.GetCreatureID(guid)
    local identifier = Identifier.CreateDatabase("npc", npcID)

    if identifier then
        identifier.guid = guid
    end

    return identifier
end

function Identifier.FromUnit(unitToken)
    if not Utils.String.IsUsable(unitToken)
        or not UnitExists(unitToken) then
        return nil
    end

    return Identifier.FromGUID(
        UnitGUID(unitToken),
        unitToken
    )
end

local LINK_TYPES = {
    item = "item",
    spell = "spell",
    quest = "quest"
}

function Identifier.FromHyperlink(link)
    if not Utils.String.IsUsable(link) then
        return nil
    end

    local linkData = link:match(
        "|H([^|]+)|h"
    ) or link

    local linkType, payload = linkData:match(
        "^([^:]+):([^:]+)"
    )

    if not linkType
        or not payload then
        return nil
    end

    -- --------------------------------------------------------
    -- Player
    -- --------------------------------------------------------

    if linkType == "player" then
        local name, realm = payload:match(
            "^([^-]+)%-(.+)$"
        )

        if not name then
            name = payload
        end

        return Identifier.CreatePlayer(
            name,
            realm
        )
    end

    -- --------------------------------------------------------
    -- Numeric database entity
    -- --------------------------------------------------------

    local databaseType = LINK_TYPES[linkType]

    if not databaseType then
        return nil
    end

    local id = tonumber(payload)

    if not id then
        return nil
    end

    return Identifier.CreateDatabase(
        databaseType,
        id
    )
end
