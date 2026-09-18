-- ============================================================
-- IDLens
-- Client
-- ============================================================

IDLens = IDLens or {}

-- ============================================================
-- Game types
-- ============================================================

IDLens.GameType = {
    RETAIL              = 1,
    CLASSIC             = 2,
    THE_BURNING_CRUSADE = 3,
    MISTS_OF_PANDARIA   = 4,
    FOREVER             = 5
}

local GameType = IDLens.GameType

-- ============================================================
-- Game detection
-- ============================================================

local function DetectGameType()
    -- --------------------------------------------------------
    -- Retail
    -- --------------------------------------------------------

    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        return GameType.RETAIL
    end

    -- --------------------------------------------------------
    -- Classic
    -- --------------------------------------------------------

    if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
        return GameType.CLASSIC
    end

    -- --------------------------------------------------------
    -- The Burning Crusade
    -- --------------------------------------------------------

    if WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC then
        return GameType.THE_BURNING_CRUSADE
    end

    -- --------------------------------------------------------
    -- Mists of Pandaria
    -- --------------------------------------------------------

    if WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC then
        return GameType.MISTS_OF_PANDARIA
    end

    -- --------------------------------------------------------
    -- Forever
    -- --------------------------------------------------------

    if WOW_PROJECT_ID == WOW_PROJECT_CAMELOT then
        return GameType.FOREVER
    end

    return nil
end

-- ============================================================
-- Regions
-- ============================================================

IDLens.Region = {
    US = "us",
    KR = "kr",
    EU = "eu",
    TW = "tw",
    CN = "cn"
}

local Region = IDLens.Region

local REGION_IDS = {
    -- --------------------------------------------------------
    -- Retail
    -- --------------------------------------------------------

    [1] = Region.US,
    [2] = Region.KR,
    [3] = Region.EU,
    [4] = Region.TW,
    [5] = Region.CN,

    -- --------------------------------------------------------
    -- Classic
    -- --------------------------------------------------------

    [41] = Region.US,
    [42] = Region.KR,
    [43] = Region.EU,
    [44] = Region.TW,
    [45] = Region.CN,

    -- --------------------------------------------------------
    -- Classic Era
    -- --------------------------------------------------------

    [81] = Region.US,
    [82] = Region.KR,
    [83] = Region.EU,
    [84] = Region.TW,
    [85] = Region.CN
}

local function DetectRegion()
    return REGION_IDS[
    GetCurrentRegion()
    ]
end

-- ============================================================
-- Client
-- ============================================================

IDLens.gameType = DetectGameType()
IDLens.region = DetectRegion()
