-- ============================================================
-- IDLens
-- Objective Tracker integration
-- ============================================================

IDLens = IDLens or {}

local hookedQuestBlocks = setmetatable({}, { __mode = "k" })

local function GetQuestID(block)
    if not block then
        return nil
    end

    return block.questID or block.id
end

local function HookQuestBlock(block)
    if not block
        or hookedQuestBlocks[block]
        or not block.HeaderButton then
        return
    end

    hookedQuestBlocks[block] = true

    IDLens.EntityResolver.RegisterFrame(
        block.HeaderButton,
        function()
            return IDLens.Identifier.CreateDatabase(
                "quest",
                GetQuestID(block)
            )
        end
    )
end

local function ScanQuestTracker()
    if not QuestObjectiveTracker
        or not QuestObjectiveTracker.ContentsFrame then
        return
    end

    for _, child in ipairs({
        QuestObjectiveTracker.ContentsFrame:GetChildren()
    }) do
        HookQuestBlock(child)
    end
end

local driver = CreateFrame("Frame")

driver:RegisterEvent("PLAYER_ENTERING_WORLD")
driver:RegisterEvent("QUEST_LOG_UPDATE")

driver:SetScript(
    "OnEvent",
    function()
        Utils.Execution.Defer(ScanQuestTracker)
    end
)

Utils.Execution.Defer(ScanQuestTracker)
