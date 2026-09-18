-- ============================================================
-- IDLens
-- Core
-- ============================================================

IDLens = IDLens or {}

function IDLens_OpenDatabase()
    local identifier = IDLens.EntityResolver.ResolveCursor()

    if not identifier then
        IDLens.Logger.Info(
            "No supported entity is under the cursor."
        )

        return
    end

    local url = IDLens.Database.GetURL(identifier)

    if not Utils.String.IsUsable(url) then
        IDLens.Logger.Info(
            "No database page is available for this entity."
        )

        return
    end

    IDLens.ShowURL(url)
end
