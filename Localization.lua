-- ============================================================
-- IDLens
-- Localization
-- ============================================================

IDLens = IDLens or {}
IDLens.locale = GetLocale()

-- ============================================================
-- Localization
-- ============================================================

local LOCALIZATION = {
    enUS = {
        COPY_URL = "Copy URL",
        COPY_HINT = "Press Ctrl+C to copy the URL.",
        CLOSE = "Close",
        BINDING_OPEN = "Open database page"
    },

    enGB = {
        COPY_URL = "Copy URL",
        COPY_HINT = "Press Ctrl+C to copy the URL.",
        CLOSE = "Close",
        BINDING_OPEN = "Open database page"
    },

    frFR = {
        COPY_URL = "Copier l'URL",
        COPY_HINT = "Appuyez sur Ctrl+C pour copier l'URL.",
        CLOSE = "Fermer",
        BINDING_OPEN = "Ouvrir la page de base de données"
    },

    deDE = {
        COPY_URL = "URL kopieren",
        COPY_HINT = "Drücke Strg+C, um die URL zu kopieren.",
        CLOSE = "Schließen",
        BINDING_OPEN = "Datenbankseite öffnen"
    },

    esES = {
        COPY_URL = "Copiar URL",
        COPY_HINT = "Pulsa Ctrl+C para copiar la URL.",
        CLOSE = "Cerrar",
        BINDING_OPEN = "Abrir página de base de datos"
    },

    esMX = {
        COPY_URL = "Copiar URL",
        COPY_HINT = "Presiona Ctrl+C para copiar la URL.",
        CLOSE = "Cerrar",
        BINDING_OPEN = "Abrir página de base de datos"
    },

    ptBR = {
        COPY_URL = "Copiar URL",
        COPY_HINT = "Pressione Ctrl+C para copiar a URL.",
        CLOSE = "Fechar",
        BINDING_OPEN = "Abrir página do banco de dados"
    },

    itIT = {
        COPY_URL = "Copia URL",
        COPY_HINT = "Premi Ctrl+C per copiare l'URL.",
        CLOSE = "Chiudi",
        BINDING_OPEN = "Apri pagina del database"
    },

    ruRU = {
        COPY_URL = "Копировать URL",
        COPY_HINT = "Нажмите Ctrl+C, чтобы скопировать URL.",
        CLOSE = "Закрыть",
        BINDING_OPEN = "Открыть страницу базы данных"
    }
}

IDLens.L = LOCALIZATION[IDLens.locale]
    or LOCALIZATION.enUS

-- ============================================================
-- Blizzard keybinding localization
-- ============================================================

BINDING_HEADER_IDLENS = "IDLens"
BINDING_NAME_IDLENS_OPEN_DATABASE = IDLens.L.BINDING_OPEN
