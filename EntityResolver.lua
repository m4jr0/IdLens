-- ============================================================
-- IDLens
-- Entity resolver
-- ============================================================

IDLens = IDLens or {}
IDLens.EntityResolver = IDLens.EntityResolver or {}

local EntityResolver = IDLens.EntityResolver
local frameProviders = setmetatable({}, { __mode = "k" })
local frameIdentifiers = setmetatable({}, { __mode = "k" })

function EntityResolver.RegisterFrame(frame, provider)
    if frame and type(provider) == "function" then
        frameProviders[frame] = provider
    end
end

function EntityResolver.SetFrameIdentifier(frame, identifier)
    if frame then
        frameIdentifiers[frame] = identifier
    end
end

function EntityResolver.ClearFrameIdentifier(frame, identifier)
    if not frame then
        return
    end

    if identifier == nil
        or frameIdentifiers[frame] == identifier then
        frameIdentifiers[frame] = nil
    end
end

local function ResolveFrame(frame)
    local visited = {}

    while frame and not visited[frame] do
        visited[frame] = true

        local identifier = frameIdentifiers[frame]

        if identifier then
            return identifier
        end

        local provider = frameProviders[frame]

        if provider then
            local success, result = pcall(provider, frame)

            if success and result then
                return result
            end
        end

        if not frame.GetParent then
            break
        end

        frame = frame:GetParent()
    end

    return nil
end

local function GetMouseFocusList()
    if type(GetMouseFoci) == "function" then
        local foci = GetMouseFoci()

        if type(foci) == "table" then
            return foci
        end
    end

    if type(GetMouseFocus) == "function" then
        local focus = GetMouseFocus()

        if focus then
            return { focus }
        end
    end

    return {}
end

function EntityResolver.ResolveCursor()
    -- UI is resolved first so it cannot select a world unit behind it.
    for _, focus in ipairs(GetMouseFocusList()) do
        local identifier = ResolveFrame(focus)

        if identifier then
            identifier.source = "ui"
            return identifier
        end
    end

    local identifier = IDLens.Identifier.FromUnit("mouseover")

    if identifier then
        identifier.source = "world"
    end

    return identifier
end

local hookedChatFrames = setmetatable({}, { __mode = "k" })

local function HookChatFrame(chatFrame)
    if not chatFrame or hookedChatFrames[chatFrame] then
        return
    end

    hookedChatFrames[chatFrame] = true

    chatFrame:HookScript(
        "OnHyperlinkEnter",
        function(self, link)
            EntityResolver.SetFrameIdentifier(
                self,
                IDLens.Identifier.FromHyperlink(link)
            )
        end
    )

    chatFrame:HookScript(
        "OnHyperlinkLeave",
        function(self)
            EntityResolver.ClearFrameIdentifier(self)
        end
    )
end

for index = 1, NUM_CHAT_WINDOWS or 0 do
    HookChatFrame(_G["ChatFrame" .. index])
end
