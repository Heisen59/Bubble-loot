-- Configuration.
-- Populate `BubbleLoot_G.configuration`.

local GroupType = BubbleLoot_G.GroupType

--
BubbleLoot_G.configuration.ADDON_NAME = "BubbleLoot"

--
BubbleLoot_G.configuration.size = {
    EMPTY_HEIGHT = 30, -- Header and border: 30 = (5 + 15 + 10)
    ROW_HEIGHT = 20,
    FRAME_WIDTH = 250, -- Default value.
}

local systemMessageColor = "FFFFFF00"
-- All colors used as `AARRGGBB` string.
BubbleLoot_G.configuration.colors = {
    -- GROUP TYPE

    [GroupType.NOGROUP] = systemMessageColor,
    [GroupType.PARTY] = "FFAAA7FF",
    [GroupType.RAID] = "FFFF7D00",

    -- GUI

    BACKGROUND = "B2333333",     -- RGBA = { 0.2, 0.2, 0.2, 0.7 }
    HEADER = systemMessageColor, -- RGBA = { 1.0, 1.0, 0.0, 1.0 }
    MASTERLOOTER = "FFFF0000",
    MULTINEED = "FFFF0000",
    PASS = "FF00CCFF",

    -- MISC.

    UNKNOWN = systemMessageColor,
    SYSTEMMSG = systemMessageColor,
}

-- Texts
BubbleLoot_G.configuration.texts = {
    -- GENERAL.

    LIST_CMDS = "Commands: show, hide, toggle, help, reset, resize, test.",
    UNIT_HEADER = "Player (class)[subgroup]",
    NEED_HEADER = "Need",
	SCORE_HEADER = "Score",
	UNIT_LOOT_SCORE_HEADER = "Loot Score",
    PASS = "pass",

    -- LABELS BELONGING TO `GROUPTYPE`S.

    NOGROUP_LABEL = "S",
    PARTY_LABEL = "P",
    -- RAID_LABEL = <subgroup number>,

    -- ERRORS. USED BY `PRINTERROR()`.

    RESIZE_SIZE_ERROR = "cannot resize below 100%.",
    RESIZE_PARAMETER_ERROR = "resize accepts either no argument or a number above 100.",
    TEST_PARAMETER_ERROR = "test accepts either 'fill', 'solo', 'plugins' or a plugin name.",
    SLASH_PARAMETER_ERROR = "unknown command. Run '/bl' for available commands.",

    -- HELP LINES.

    HELP_LINES = {
        "Slash Commands '/bubbleloot' (or '/bl'):",
        "  /bl - Commands list.",
        "  /bl (show | hide | toggle) - UI visibility.",
        "  /bl help - Uroboros!",
        "  /bl reset - Erase all rolls (same as right-clicking the window).",
        "  /bl resize [<percentage>] - Change the width to <percentage> of default.",
        "  /bl test (fill | solo | plugins | <plugin name> [args])",
    },
}

-- Pairs of name and roll.
BubbleLoot_G.configuration.testFill = {
    { "player1", 20 },
    { "player2", 0 },
    { "player3", 4 },
    { "player3", 99 }, -- repeated
}
