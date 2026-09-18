-- ============================================================
-- IDLens
-- Core
-- ============================================================

IDLens = IDLens or {}

local ID_COLOR = "ff808080"

-- ============================================================
-- Supported tooltip types
-- ============================================================

local SUPPORTED_TYPES = {}

local function RegisterType(
    enumValue,
    databaseType
)
    if enumValue == nil then
        return
    end

    SUPPORTED_TYPES[enumValue] = {
        databaseType = databaseType
    }
end

RegisterType(
    Enum.TooltipDataType.Item,
    "item"
)

RegisterType(
    Enum.TooltipDataType.Spell,
    "spell"
)

RegisterType(
    Enum.TooltipDataType.Quest,
    "quest"
)

local UNIT_TYPE = Enum.TooltipDataType.Unit

-- ============================================================
-- Identifier helpers
-- ============================================================

local function CreateDatabaseIdentifier(
    databaseType,
    id
)
    if not id then
        return nil
    end

    return {
        kind = databaseType,
        databaseType = databaseType,
        id = id
    }
end

-- ============================================================
-- Player identifiers
-- ============================================================

local function CreatePlayerIdentifier(
    name,
    realm
)
    if not Utils.String.IsUsable(name) then
        return nil
    end

    return {
        kind = "player",
        name = name,
        realm = realm
    }
end

local function GetPlayerIdentifier(unitToken)
    if not unitToken then
        return nil
    end

    local name, realm = UnitFullName(
        unitToken
    )

    return CreatePlayerIdentifier(
        name,
        realm
    )
end

-- ============================================================
-- Unit identifiers
-- ============================================================

local function GetUnitIdentifier(
    guid,
    unitToken
)
    if not guid then
        return nil
    end

    local unitType = strsplit(
        "-",
        guid
    )

    -- --------------------------------------------------------
    -- Player
    -- --------------------------------------------------------

    if unitType == "Player" then
        return GetPlayerIdentifier(
            unitToken
        )
    end

    -- --------------------------------------------------------
    -- NPC
    -- --------------------------------------------------------

    if unitType ~= "Creature"
        and unitType ~= "Vehicle"
        and unitType ~= "Pet" then
        return nil
    end

    local npcID = C_CreatureInfo.GetCreatureID(
        guid
    )

    if not npcID then
        return nil
    end

    local identifier = CreateDatabaseIdentifier(
        "npc",
        npcID
    )

    identifier.guid = guid

    return identifier
end

-- ============================================================
-- Tooltip unit
-- ============================================================

local function GetUnitToken(data)
    if not data
        or not data.lines then
        return nil
    end

    for _, line in ipairs(data.lines) do
        if line.unitToken then
            return line.unitToken
        end
    end

    return nil
end

-- ============================================================
-- Tooltip identifier
-- ============================================================

local function GetTooltipIdentifier(data)
    if not data
        or not data.type then
        return nil
    end

    -- --------------------------------------------------------
    -- Unit
    -- --------------------------------------------------------

    if data.type == UNIT_TYPE then
        return GetUnitIdentifier(
            data.guid,
            GetUnitToken(data)
        )
    end

    -- --------------------------------------------------------
    -- Numeric database entity
    -- --------------------------------------------------------

    local typeInfo = SUPPORTED_TYPES[data.type]

    if not typeInfo
        or not data.id then
        return nil
    end

    return CreateDatabaseIdentifier(
        typeInfo.databaseType,
        data.id
    )
end

-- ============================================================
-- Tooltip title
-- ============================================================

local function AddIdentifierToTitle(
    tooltip,
    identifier
)
    if not tooltip
        or not identifier
        or not identifier.id then
        return
    end

    local tooltipName = tooltip:GetName()

    if not tooltipName then
        return
    end

    local title = _G[
    tooltipName
    .. "TextLeft1"
    ]

    if not title then
        return
    end

    local text = title:GetText()

    if not Utils.String.IsUsable(text) then
        return
    end

    local idText = "("
        .. tostring(identifier.id)
        .. ")"

    -- --------------------------------------------------------
    -- Duplication guard
    -- --------------------------------------------------------

    if text:find(
            idText,
            1,
            true
        ) then
        return
    end

    title:SetText(
        text
        .. " "
        .. Utils.String.Colorize(
            idText,
            ID_COLOR
        )
    )
end

-- ============================================================
-- Current entities
-- ============================================================
--
-- Tooltip and UI hover contexts are kept separate.
--
-- A tooltip normally has priority because it represents the
-- most specific thing currently being inspected.
-- ============================================================

local currentTooltipIdentifier = nil
local currentHoveredIdentifier = nil

-- ============================================================
-- Tooltip processing
-- ============================================================

local function OnTooltipData(
    tooltip,
    data
)
    if not tooltip
        or not data then
        return
    end

    local identifier = GetTooltipIdentifier(
        data
    )

    if not identifier then
        return
    end

    AddIdentifierToTitle(
        tooltip,
        identifier
    )

    -- --------------------------------------------------------
    -- Database binding target
    -- --------------------------------------------------------
    --
    -- Only GameTooltip controls the tooltip identifier used by
    -- the keybinding.
    -- --------------------------------------------------------

    if tooltip == GameTooltip then
        currentTooltipIdentifier = identifier
    end
end

-- ============================================================
-- Objective Tracker quests
-- ============================================================

local hookedQuestBlocks = {}

local function GetQuestIDFromBlock(block)
    if not block then
        return nil
    end

    -- --------------------------------------------------------
    -- Forever / modern tracker
    -- --------------------------------------------------------
    --
    -- Keep the tracker-specific representation isolated here.
    --
    -- If Forever changes how quest blocks expose their ID,
    -- this is the only function that should need changing.
    -- --------------------------------------------------------

    if block.questID then
        return block.questID
    end

    if block.id then
        return block.id
    end

    return nil
end

local function SetHoveredQuest(block)
    local questID = GetQuestIDFromBlock(
        block
    )

    if not questID then
        currentHoveredIdentifier = nil

        return
    end

    currentHoveredIdentifier = CreateDatabaseIdentifier(
        "quest",
        questID
    )
end

local function ClearHoveredQuest(block)
    if not currentHoveredIdentifier then
        return
    end

    local questID = GetQuestIDFromBlock(
        block
    )

    if not questID
        or currentHoveredIdentifier.id == questID then
        currentHoveredIdentifier = nil
    end
end

local function HookQuestBlock(block)
    if not block
        or hookedQuestBlocks[block] then
        return
    end

    local headerButton = block.HeaderButton

    if not headerButton then
        return
    end

    hookedQuestBlocks[block] = true

    headerButton:HookScript(
        "OnEnter",
        function()
            SetHoveredQuest(
                block
            )
        end
    )

    headerButton:HookScript(
        "OnLeave",
        function()
            ClearHoveredQuest(
                block
            )
        end
    )
end

local function ScanQuestTracker()
    if not QuestObjectiveTracker
        or not QuestObjectiveTracker.ContentsFrame then
        return
    end

    local contentsFrame =
        QuestObjectiveTracker.ContentsFrame

    local children = {
        contentsFrame:GetChildren()
    }

    for _, child in ipairs(children) do
        HookQuestBlock(
            child
        )
    end
end

-- ============================================================
-- Objective Tracker updates
-- ============================================================
--
-- Tracker blocks are recycled and can be created when quests
-- are added, removed, tracked or refreshed.
--
-- Scan after relevant quest updates and hook newly-created
-- blocks. Existing blocks are ignored by HookQuestBlock.
-- ============================================================

local questTrackerDriver = CreateFrame(
    "Frame"
)

questTrackerDriver:RegisterEvent(
    "PLAYER_ENTERING_WORLD"
)

questTrackerDriver:RegisterEvent(
    "QUEST_LOG_UPDATE"
)

questTrackerDriver:SetScript(
    "OnEvent",
    function()
        Utils.Execution.Defer(
            ScanQuestTracker
        )
    end
)

-- ============================================================
-- Current identifier
-- ============================================================

local function GetCurrentIdentifier()
    if currentTooltipIdentifier then
        return currentTooltipIdentifier
    end

    if currentHoveredIdentifier then
        return currentHoveredIdentifier
    end

    return nil
end

-- ============================================================
-- Database binding
-- ============================================================

function IDLens_OpenDatabase()
    local identifier = GetCurrentIdentifier()

    if not identifier then
        IDLens.Logger.Info(
            "No supported entity is currently active."
        )

        return
    end

    local url = IDLens.Database.GetURL(
        identifier
    )

    if not Utils.String.IsUsable(url) then
        IDLens.Logger.Info(
            "No database page is available for this entity."
        )

        return
    end

    IDLens.ShowURL(
        url
    )
end

-- ============================================================
-- Tooltip cleanup
-- ============================================================

GameTooltip:HookScript(
    "OnHide",
    function()
        currentTooltipIdentifier = nil
    end
)

-- ============================================================
-- Register tooltip processor
-- ============================================================

TooltipDataProcessor.AddTooltipPostCall(
    TooltipDataProcessor.AllTypes,
    OnTooltipData
)

-- ============================================================
-- Initial Objective Tracker scan
-- ============================================================

Utils.Execution.Defer(
    ScanQuestTracker
)
