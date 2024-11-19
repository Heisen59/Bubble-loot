-- Configuration.
-- Populate `BubbleLoot_G.configuration`.

local GroupType = BubbleLoot_G.GroupType

--
BubbleLoot_G.configuration.ADDON_NAME = "BubbleLoot"
BubbleLoot_G.configuration.PREFIX = "BubbleLootSync"

--
BubbleLoot_G.configuration.size = {
    EMPTY_HEIGHT = 60, -- Header and border: 30 = (5 + 15 + 10)
    ROW_HEIGHT = 20,
    FRAME_WIDTH = 440, -- Default value.
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
    WARNING = "FFFF0479",

    -- MISC.

    UNKNOWN = systemMessageColor,
    SYSTEMMSG = systemMessageColor,
}


BubbleLoot_G.configuration.index = 
{
	ATTENDANCE  	= 1,
	BENCH 			= 2,
	NON_ATTENDANCE  = 3,
}

--BubbleLoot_G.configuration.SHOWN			= 1
--BubbleLoot_G.configuration.NOT_USED 	= 2
--BubbleLoot_G.configuration.DATA_STRUCTURE 	= 3

--raidData index
BubbleLoot_G.configuration.NUMBER_OF_RAID_DONE = 1
BubbleLoot_G.configuration.RAID_HISTORIC = 2

-- Sync data index
BubbleLoot_G.configuration.TRUST_LIST = 1
BubbleLoot_G.configuration.BLACK_LIST = 2
BubbleLoot_G.configuration.SYNC_MSG = {
    RAID_DATA = "RaidData",
    PLAYERS_DATA = "PlayersData",
    RAID_AND_PLAYERS_DATA = "RaidPlayersData",
    ADD_PLAYER_DATA_FUNCTION = "AddPlayerDataFunction",
    ADD_RAID_PARTICIPATIOn = "AddRaidParticipationFunction",
    DEMOTE_PLAYER_NEED = "DemoteNeedPlayerFunction",
    MODIFY_ITEM_NEED_IN_DATABASE = "LootNeedToogleFunction",
    MODIFY_BONUS_DATA = "writeOrEditBonusFunction",
    ASK_SYNC_TO_ML = "AskSyncToML",
    CODE_RAID_BONUS = "CurrentRaid_00",
}



-- player data index

-- item data index
BubbleLoot_G.configuration.ITEMLINK = 1
BubbleLoot_G.configuration.LOOTDATA = 2
BubbleLoot_G.configuration.INSTANCE_NAME = 3
BubbleLoot_G.configuration.NUMBER = 4
BubbleLoot_G.configuration.ITEM_SCORE = 5

BubbleLoot_G.configuration.constant = 
{
	ATTENDANCE_VALUE  		= 0.60,
	BENCH_VALUE 			= 0.6,
	NON_ATTENDANCE_VALUE  	= 1,
}

--print("ATTENDANCE_VALUE set")

BubbleLoot_G.configuration.tau = 3
BubbleLoot_G.configuration.seuilMultiplicatif = 4

-- Cancel table
BubbleLoot_G.configuration.cancelIndex = 
{
	LAST_DELETED_LOOT_PLAYER_LIST = 1
}

-- Texts
BubbleLoot_G.configuration.texts = {
    -- GENERAL.

    LIST_CMDS = "Commands: show, hide, toggle, help, reset, resize, test.",
    ITEM_HEADER = "Item : ",
    UNIT_HEADER ="Joueur (class) [+1/+2]",-- "Player (class) [+1/+2]",
    NEED_HEADER = "Besoin",--"Need",
	SCORE_HEADER = "Score",
	CHANCE_HEADER = "Chance",
	ROLL_HEADER ="Lancé de dés",-- "Roll",
	UNIT_LOOT_SCORE_HEADER ="Score de loot",-- "Loot Score",
    PASS = "passe",--"pass",
	LOOT_SEND = "Distribution de ",
    LOOT_SEND_BIS = "Choisissez +1/+2/pass pour ",
    LOOT_SEND_BIS_PATERN ="Choisissez %+1/%+2/pass pour",
    FORCE_ADD_STR ="force add:", 
    ADD_RAID_PARTICIPATIOn = "Ajoute une participation aux joueurs présents",--"Add a participation to all players in raid",
    ADD_BONUS_RAID_PARTICIPATIOn = "Ajoute un bonus aux joueurs présents",--"Add a participation to all players in raid",
    SYNC_WITH_ALL_RAIDERS = "Envoyer sync avec les membres du raid",
    ASK_SYNC_WITH_ML = "Demander une synchronisation des données avec le ML",
    SHOW_ROSTER_PANEL = "Liste des joueurs",--"Show the roster panel",
    REMOVE_PLAYER = "Retirer joueur",--"Remove player",
    ADD_A_BONUS = "Ajouter Bonus",--"Add a Bonus",
    EDIT_A_BONUS = "Edit", 
    DEL_A_BONUS = "Del",
    LOOT_REMOVE = "Retirer",--"Remove",
    LOOT_SET_MSOS = "Changer +1/+2",--"set as +1/+2",
    LOOT_GIVE = "Donner au joueur",--"Give to player",
    SHOW_HIDE_MAIN_PANEL = "Montrer/cacher la fenêtre principale", --"Show/hide the main loot window",
    ML_RAND = "/rand 10000",
    PLAYERS_LIST = "Joueurs du roster",
    TOOLTIP_PLAYER_ROSTER = "clic droit sur un joueur pour faire apparaitre le menu",
    ITEM_VALUE = "Valeur d'item",
    CONFIRM_DELETE_DB ="Voulez-vous effacer %s ?", -- "Are you sure you want to delete the %s data?",
    CONFIRM = "Confirmer",
    CANCEL = "Annuler",
    SHOW_RAID_LOOT_PER_DATE = "Montrer loots de raids", --"Show raid loots per date"
    SHOW_PLAYERS_LOOTS = "Montrer les loots du joueur",
    -- LABELS BELONGING TO `GROUPTYPE`S.

    NOGROUP_LABEL = "S",
    PARTY_LABEL = "P",
    -- RAID_LABEL = <subgroup number>,

    -- ERRORS. USED BY `PRINTERROR()`.

    RESIZE_SIZE_ERROR = "cannot resize below 100%.",
    RESIZE_PARAMETER_ERROR = "resize accepts either no argument or a number above 100.",
    TEST_PARAMETER_ERROR = "test accepts either 'fill', 'solo', 'plugins' or a plugin name.",
	ADDLOOTTOPLAYER_PARAMETER_ERROR = "Usage: /bl add <characterName> <itemName or itemId> ",
	GETPLAYERDATA_PARAMETER_ERROR = "Usage: /bl get <characterName>",
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
    { "player1", 1 },
    { "player2", 9 }, -- Pass
    { "player3", 1 },
    { "player3", 2 }, -- repeated
	{ "player4", 1 },
    { "player5", 1 },
    { "player6", 2 },
    { "player7", 1 }, 
}

BubbleLoot_G.configuration.testFillOS = {
    { "player1", 2 },
    { "player2", 2 },
    { "player3", 2 },
    { "player3", 2 }, -- repeated
	{ "player4", 2 },
    { "player5", 2 },
    { "player6", 2 },
    { "player7", 9 }, 
}

BubbleLoot_G.configuration.tokenLocation = 
{
"INVTYPE_HEAD",
"INVTYPE_SHOULDER",
"INVTYPE_CHEST",
"INVTYPE_HAND",
"INVTYPE_WRIST",
"INVTYPE_WAIST",
"INVTYPE_LEGS",
"INVTYPE_FEET",
}

BubbleLoot_G.configuration.tokens = 
{["INVTYPE_HEAD"] = 
{-- head
227532,--"Chaperon incandescent",
227755,-- "Heaume en écailles en fusion",
227764,-- "Heaume du noyau incendié"
231711,--Draconian Hood
231728,--Ancient Helm
231719,--Primeval Helm
},
["INVTYPE_SHOULDER"] = 
{--Shoulders
227537,-- "Protège-épaules incandescents",
227752,-- "Épaulières en écailles en fusion", 
227762,-- "Protège-épaules du noyau incendié"
231709,--Draconian Shoulderpads
231726,--Ancient Shoulderpads
231717,--Primeval Shoulderpads
},
["INVTYPE_CHEST"] = 
{--Chest
227535,-- "Robe incandescente",
227758,-- "Plastron en écailles en fusion",
227766,-- "Plastron du noyau incendié"
231714,--Draconian Robe
231731,--Ancient Chest
231723,--Primeval Chest
},
["INVTYPE_HAND"] = 
{--Gloves
227533,-- "Gants incandescents",
227756,-- "Gants en écailles en fusion",
227759,-- "Gants du noyau incendié"
231712,--Draconian Gloves
231729,--Ancient Gloves
231720,--Primeval Gloves
},
["INVTYPE_WRIST"] = 
{--Wrist
227531,-- "Manchettes incandescentes",
227750,-- "Manchettes en écailles en fusion",
227760,-- "Manchettes du noyau incendié"
231707,--Draconian Bindings
231724,--Ancient Bindings
231715,--Primeval Bindings
},
["INVTYPE_WAIST"] = 
{--Waist
227530,-- "Ceinture incandescente",
227751,-- "Ceinture en écailles en fusion",
227761,-- "Ceinture du noyau incendié"
231708,--Draconian Belt
231725,--Ancient Belt
231716,--Primeval Belt
},
["INVTYPE_LEGS"] = 
{--Legs
227534,-- "Jambières incandescentes",
227754,-- "Jambières en écailles en fusion",
227763,-- "Jambières du noyau incendié"
231710,--Draconian Leggings
231727,--Ancient Leggings
231718,--Primeval Leggings
},
["INVTYPE_FEET"] = 
{--Boots
227536,-- "Bottes incandescentes",
227757,-- "Bottes en écailles en fusion",
227765,-- "Bottes du noyau incendié"
231713,--Draconian Boots
231730, --Ancient Boots
231721,--Primeval Boots
},
["INVTYPE_2HWEAPON"] = 
{--2H weapon
231722,-- "Faux du Chaos épuisée",
230904, --Parchemin : SEENECS ED UEF
231814, --Cœur chromatique
},
["INVTYPE_WEAPONMAINHAND"] = 
{--1H weapon
231882,--Reçu de l’engin de suppression
231452, --Sang du Porteur de Lumière
229352,--Informations recueillies
},
["INVTYPE_TRINKET"] = 
{--Trinket
229906,--Écaille de bronze ternie
},
["INVTYPE_SHIELD"] = 
{--SHIELD
231995, --Scorie d’élémentium durcie
231378,--Disque doré chatoyant
},
["INVTYPE_NECK"] = 
{
19003, -- Tête de Nefarian (neck, ring or offhand, all have the same slotmod value)
18423, -- Tête d'Ony
},
["INVTYPE_SPECIFIC"] = 
{
    18564, -- liens du cherchevents
    18563, -- liens du cherchevents
},
}



