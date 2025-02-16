-- Configuration.
-- Populate `RaidRolls_G.configuration`.

local GroupType = RaidRolls_G.GroupType

--
RaidRolls_G.configuration.ADDON_NAME = "RaidRolls"

--
RaidRolls_G.configuration.size = {
    EMPTY_HEIGHT = 30, -- Header and border: 30 = (5 + 15 + 10)
    ROW_HEIGHT = 20,
    FRAME_WIDTH = 220, -- Default value.
}

local systemMessageColor = "FFFFFF00"
-- All colors used as `AARRGGBB` string.
RaidRolls_G.configuration.colors = {
    -- GROUP TYPE

    [GroupType.NOGROUP] = systemMessageColor,
    [GroupType.PARTY] = "FFAAA7FF",
    [GroupType.RAID] = "FFFF7D00",

    -- GUI

    BACKGROUND = "B2333333",     -- RGBA = { 0.2, 0.2, 0.2, 0.7 }
    HEADER = systemMessageColor, -- RGBA = { 1.0, 1.0, 0.0, 1.0 }
    MASTERLOOTER = "FFFF0000",
    MULTIROLL = "FFFF0000",
    PASS = "FF00CCFF",

    -- MISC.

    UNKNOWN = systemMessageColor,
    SYSTEMMSG = systemMessageColor,
}

-- Texts
RaidRolls_G.configuration.texts = {
    -- GENERAL.

    LIST_CMDS = "Commands: show, hide, toggle, help, reset, resize, test.",
    UNIT_HEADER = "Player (class)[subgroup]",
    ROLL_HEADER = "Roll",
    PASS = "pass",

    -- LABELS BELONGING TO `GROUPTYPE`S.

    NOGROUP_LABEL = "S",
    PARTY_LABEL = "P",
    -- RAID_LABEL = <subgroup number>,

    -- ERRORS. USED BY `PRINTERROR()`.

    RESIZE_SIZE_ERROR = "cannot resize below 100%.",
    RESIZE_PARAMETER_ERROR = "resize accepts either no argument or a number above 100.",
    TEST_PARAMETER_ERROR = "test accepts either 'fill', 'solo', 'plugins' or a plugin name.",
    SLASH_PARAMETER_ERROR = "unknown command. Run '/rr' for available commands.",

    -- HELP LINES.

    HELP_LINES = {
        "Slash Commands '/raidrolls' (or '/rr'):",
        "  /rr - Commands list.",
        "  /rr (show | hide | toggle) - UI visibility.",
        "  /rr help - Uroboros!",
        "  /rr reset - Erase all rolls (same as right-clicking the window).",
        "  /rr resize [<percentage>] - Change the width to <percentage> of default.",
        "  /rr test (fill | solo | plugins | <plugin name> [args])",
    },
}

-- Pairs of name and roll.
RaidRolls_G.configuration.testFill = {
    { "player1", 20 },
    { "player2", 0 },
    { "player3", 4 },
    { "player3", 99 }, -- repeated
}
