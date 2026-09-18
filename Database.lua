-- ============================================================
-- IDLens
-- Database
-- ============================================================

IDLens = IDLens or {}
IDLens.Database = IDLens.Database or {}

-- ============================================================
-- Wowhead locale
-- ============================================================

local WOWHEAD_LOCALES = {
    enUS = "www",
    enGB = "www",

    frFR = "fr",
    deDE = "de",

    esES = "es",
    esMX = "es",

    ptBR = "pt",
    itIT = "it",

    ruRU = "ru"
}

local wowheadLocale = WOWHEAD_LOCALES[IDLens.locale]
    or "www"

-- ============================================================
-- Wowhead game database
-- ============================================================

local WOWHEAD_GAME_PATHS = {
    [IDLens.GameType.RETAIL] = false,
    [IDLens.GameType.CLASSIC] = "classic",
    [IDLens.GameType.THE_BURNING_CRUSADE] = "tbc",
    [IDLens.GameType.MISTS_OF_PANDARIA] = "mop-classic",
    [IDLens.GameType.FOREVER] = "forever"
}

-- ============================================================
-- Blizzard locale
-- ============================================================

local BLIZZARD_LOCALES = {
    enUS = "en-us",
    enGB = "en-gb",

    frFR = "fr-fr",
    deDE = "de-de",

    esES = "es-es",
    esMX = "es-mx",

    ptBR = "pt-br",
    itIT = "it-it",

    ruRU = "ru-ru"
}

local blizzardLocale = BLIZZARD_LOCALES[IDLens.locale]
    or "en-us"

-- ============================================================
-- Blizzard Armory game database
-- ============================================================

local ARMORY_GAME_PATHS = {
    [IDLens.GameType.RETAIL] = "worldsoul",
    [IDLens.GameType.CLASSIC] = "classic1x",
    [IDLens.GameType.THE_BURNING_CRUSADE] = "classicann",
    [IDLens.GameType.MISTS_OF_PANDARIA] = "classic",
    [IDLens.GameType.FOREVER] = nil
}

-- ============================================================
-- Blizzard Armory
-- ============================================================

local function BuildPlayerURL(identifier)
    if not identifier
        or not Utils.String.IsUsable(identifier.name)
        or not Utils.String.IsUsable(IDLens.region) then
        return nil
    end

    local gamePath =
        ARMORY_GAME_PATHS[IDLens.gameType]

    if not Utils.String.IsUsable(gamePath) then
        return nil
    end

    return "https://worldofwarcraft.blizzard.com"
        .. "/"
        .. blizzardLocale
        .. "/"
        .. gamePath
        .. "/"
        .. IDLens.region
        .. "/armory/character"
        .. "?q="
        .. identifier.name
end

-- ============================================================
-- Wowhead URL
-- ============================================================

local function BuildWowheadURL(identifier)
    if not identifier
        or not identifier.databaseType
        or not identifier.id then
        return nil
    end

    local baseURL = "https://www.wowhead.com"

    -- --------------------------------------------------------
    -- Game database
    -- --------------------------------------------------------

    local gamePath = WOWHEAD_GAME_PATHS[IDLens.gameType]

    if gamePath == nil then
        return nil
    end

    if gamePath then
        baseURL = baseURL
            .. "/"
            .. gamePath
    end

    -- --------------------------------------------------------
    -- Locale
    -- --------------------------------------------------------

    if wowheadLocale ~= "www" then
        baseURL = baseURL
            .. "/"
            .. wowheadLocale
    end

    -- --------------------------------------------------------
    -- Entity
    -- --------------------------------------------------------

    return baseURL
        .. "/"
        .. identifier.databaseType
        .. "="
        .. tostring(identifier.id)
end

-- ============================================================
-- Public API
-- ============================================================

function IDLens.Database.GetURL(identifier)
    if not identifier then
        return nil
    end

    if identifier.kind == "player" then
        return BuildPlayerURL(
            identifier
        )
    end

    if identifier.databaseType then
        return BuildWowheadURL(
            identifier
        )
    end

    return nil
end
