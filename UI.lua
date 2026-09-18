-- ============================================================
-- IDLens
-- URL UI
-- ============================================================

IDLens = IDLens or {}

local L = IDLens.L

-- ============================================================
-- Main frame
-- ============================================================

local frame = CreateFrame(
    "Frame",
    "IDLensURLFrame",
    UIParent,
    "BackdropTemplate"
)

frame:SetSize(520, 150)
frame:SetPoint("CENTER")
frame:SetFrameStrata("DIALOG")
frame:SetClampedToScreen(true)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")

frame:SetScript(
    "OnDragStart",
    function(self)
        self:StartMoving()
    end
)

frame:SetScript(
    "OnDragStop",
    function(self)
        self:StopMovingOrSizing()
    end
)

frame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",

    tile = true,

    tileSize = 32,
    edgeSize = 32,

    insets = {
        left = 11,
        right = 12,
        top = 12,
        bottom = 11
    }
})

frame:Hide()

-- ============================================================
-- Title
-- ============================================================

local title = frame:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormalLarge"
)

title:SetPoint(
    "TOP",
    0,
    -20
)

title:SetText(
    L.COPY_URL
)

-- ============================================================
-- Hint
-- ============================================================

local hint = frame:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontHighlight"
)

hint:SetPoint(
    "TOP",
    title,
    "BOTTOM",
    0,
    -8
)

hint:SetText(
    L.COPY_HINT
)

-- ============================================================
-- URL edit box
-- ============================================================

local editBox = CreateFrame(
    "EditBox",
    "IDLensURLEditBox",
    frame,
    "InputBoxTemplate"
)

editBox:SetSize(
    440,
    30
)

editBox:SetPoint(
    "TOP",
    hint,
    "BOTTOM",
    0,
    -12
)

editBox:SetAutoFocus(false)

editBox:SetScript(
    "OnEscapePressed",
    function(self)
        self:ClearFocus()
        frame:Hide()
    end
)

editBox:SetScript(
    "OnEditFocusGained",
    function(self)
        self:HighlightText()
    end
)

editBox:SetScript(
    "OnTextChanged",
    function(self, userInput)
        if not userInput then
            return
        end

        self:SetText(
            self.url or ""
        )

        self:HighlightText()
    end
)

-- ============================================================
-- Close button
-- ============================================================

local closeButton = CreateFrame(
    "Button",
    nil,
    frame,
    "UIPanelButtonTemplate"
)

closeButton:SetSize(
    90,
    24
)

closeButton:SetPoint(
    "BOTTOM",
    0,
    15
)

closeButton:SetText(
    L.CLOSE
)

closeButton:SetScript(
    "OnClick",
    function()
        editBox:ClearFocus()
        frame:Hide()
    end
)

-- ============================================================
-- Public UI API
-- ============================================================

function IDLens.ShowURL(url)
    if not Utils.String.IsUsable(url) then
        return
    end

    IDLens.Logger.Debug(
        "URL:",
        url
    )

    editBox.url = tostring(url)

    frame:Show()

    editBox:SetText(
        editBox.url
    )

    -- Do not focus the edit box during the keybinding callback.
    --
    -- Alt+W is still being processed and the W could otherwise
    -- replace the URL.

    Utils.Execution.Defer(
        function()
            if not frame:IsShown() then
                return
            end

            editBox:SetFocus()
            editBox:HighlightText()
        end
    )
end
