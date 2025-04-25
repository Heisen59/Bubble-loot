-- Configuration.
-- Populate `BubbleLoot_G.configuration`.

local GroupType = BubbleLoot_G.GroupType

--
BubbleLoot_G.configuration.ADDON_NAME = "BubbleLoot"
BubbleLoot_G.configuration.PREFIX = "BubbleLootSync"

--
BubbleLoot_G.configuration.size = {
    EMPTY_HEIGHT = 80, -- Header and border: 30 = (5 + 15 + 10)
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
BubbleLoot_G.configuration.RAID_VALUE = 3

-- Items raid value
BubbleLoot_G.configuration.CURRENT_VALUE = 1
BubbleLoot_G.configuration.ITEMS = 2

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
    SR_DATA = "SRData",
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

BubbleLoot_G.configuration.tau = 2 --1.44
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
    LOOT_MOD_NEW_RAID = "Item nouveau raid",--"Remove",
    LOOT_SET_MSOS = "Changer +1/+2",--"set as +1/+2",
    LOOT_GIVE = "Donner au joueur",--"Give to player",
    SHOW_HIDE_MAIN_PANEL = "Montrer/cacher la fenêtre principale", --"Show/hide the main loot window",
    ML_RAND = "/rand 10000",
    PLAYERS_LIST = "Joueurs du roster",
    TOOLTIP_PLAYER_ROSTER = "clic droit sur un joueur pour faire apparaitre le menu",
    ITEM_VALUE = "Valeur",
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
"INVTYPE_CLOAK",
}


BubbleLoot_G.configuration.tokens = 
{-- head
    [227532] ={1,4, 66 },--"Chaperon incandescent"] ={1,4, 60 },
    [227755] ={1,4, 66 },-- "Heaume en écailles en fusion"] ={1,4, 60 },
    [227764] ={1,4, 66 },-- "Heaume du noyau incendié"
    [231711] ={1,4, 76 },--Draconian Hood
    [231728] ={1,4, 76 },--Ancient Helm
    [231719] ={1,4, 76 },--Primeval Helm
    [20926] ={1,4, 81 }, --Vek'nilash's Circlet
    [20930] ={1,4, 81 }, --Vek'lor's Diadem
    [233367] ={1,4, 81 }, -- péritoine intact
    [233365] ={1,4, 81 }, --Viscères intacts
    [233368] ={1,4, 81 }, --Entrailles intactes
    [236236] ={1,4, 88 }, --Naxx
    [236249] ={1,4, 88 },--Naxx
    [236241] ={1,4, 88 },--Naxx

    --Shoulders
    [227537]={1,4, 66 },-- "Protège-épaules incandescents"]={1,4, 60 }
[227752]={1,4, 66 },-- "Épaulières en écailles en fusion"]={1,4, 60 } 
[227762]={1,4, 66 },-- "Protège-épaules du noyau incendié"
[231709]={1,4, 76 },--Draconian Shoulderpads
[231726]={1,4, 76 },--Ancient Shoulderpads
[231717]={1,4, 76 },--Primeval Shoulderpads
[20932]={1,4, 81 }, -- Qiraji Bindings of Dominance
[20928]={1,4, 81 }, -- Qiraji Bindings of Command
[233371]={1,4, 81 }, -- Manchettes de souveraineté qiraji (épaux]={1,4, 60 } bottes)
[233369]={1,4, 81 }, --Manchettes de domination qiraji
[233370]={1,4, 81 }, --Manchettes de commandement qiraji
[236240]={1,4, 88 },--Naxx
[236237]={1,4, 88 },--Naxx
[236254]={1,4, 88 },--Naxx

--Chest
[227535]={1,4, 66 },-- "Robe incandescente"]={1,4, 66 },
[227758]={1,4, 66 },-- "Plastron en écailles en fusion"]={1,4, 66 },
[227766]={1,4, 66 },-- "Plastron du noyau incendié"
[231714]={1,4, 76 },--Draconian Robe
[231731]={1,4, 76 },--Ancient Chest
[231723]={1,4, 76 },--Primeval Chest
[20933]={1,4, 81 },  --Husk of the Old God
[20929]={1,4, 81 }, -- Carapace of the Old God
[233364]={1,4, 88 }, --Naxx
[233362]={1,4, 88 }, --Naxx
[233363]={1,4, 88 },--Naxx--Naxx
[236251]={1,4, 88 },--Naxx
[236242]={1,4, 88 },--Naxx
[236231]={1,4, 88 },--Naxx

----Gloves
[227533]={0.77,4, 66 },-- "Gants incandescents"]={0.77,4, 66 },
[227756]={0.77,4, 66 },-- "Gants en écailles en fusion"]={0.77,4, 66 },
[227759]={0.77,4, 66 },-- "Gants du noyau incendié"
[231712]={0.77,4, 76 },--Draconian Gloves
[231729]={0.77,4, 76 },--Ancient Gloves
[231720]={0.77,4, 76 },--Primeval Gloves
[236250]={0.77,4, 88 },--Naxx
[236233]={0.77,4, 88 },--Naxx
[236243]={0.77,4, 88 },--Naxx

-- wrist
[227531]={0.5625,4, 66 },-- "Manchettes incandescentes"]={0.5625,4, 66 },
[227750]={0.5625,4, 66 },-- "Manchettes en écailles en fusion"]={0.5625,4, 66 },
[227760]={0.5625,4, 66 },-- "Manchettes du noyau incendié"
[231707]={0.5625,4, 76 },--Draconian Bindings
[231724]={0.5625,4, 76 },--Ancient Bindings
[231715]={0.5625,4, 76 },--Primeval Bindings
[236245]={0.5625,4, 88 },--Naxx
[236247]={0.5625,4, 88 },--Naxx
[236235]={0.5625,4, 88 },--Naxx

--Waist
[227530]={0.77,4, 66 },-- "Ceinture incandescente"]={0.77,4, 66 },
[227751]={0.77,4, 66 },-- "Ceinture en écailles en fusion"]={0.77,4, 66 },
[227761]={0.77,4, 66 },-- "Ceinture du noyau incendié"
[231708]={0.77,4, 76 },--Draconian Belt
[231725]={0.77,4, 76 },--Ancient Belt
[231716]={0.77,4, 76 },--Primeval Belt
[236244]={0.77,4, 88 },--Naxx
[236232]={0.77,4, 88 },--Naxx
[236252]={0.77,4, 88 },--Naxx

--legs
[227534]={1,4, 66 },-- "Jambières incandescentes"]={1,4, 66 },
[227754]={1,4, 66 },-- "Jambières en écailles en fusion"]={1,4, 66 },
[227763]={1,4, 66 },-- "Jambières du noyau incendié"
[231710]={1,4, 76 },--Draconian Leggings
[231727]={1,4, 76 },--Ancient Leggings
[231718]={1,4, 76 },--Primeval Leggings
[20927]={1,4, 81 }, --Ouro's Intact Hide
[20931]={1,4, 81 }, --Skin of the Great Sandworm
[236238]={1,4, 88 },--Naxx
[236246]={1,4, 88 },--Naxx
[236253]={1,4, 88 },--Naxx

--feet
[227536]={1,4, 66 },-- "Bottes incandescentes"]={1,4, 66 },
[227757]={1,4, 66 },-- "Bottes en écailles en fusion"]={1,4, 66 },
[227765]={1,4, 66 },-- "Bottes du noyau incendié"
[231713]={1,4, 76 },--Draconian Boots
[231730]={1,4, 76 }, --Ancient Boots
[231721]={1,4, 76 },--Primeval Boots
[236248]={1,4, 88 },--Naxx
[236239]={1,4, 88 },--Naxx
[236234]={1,4, 88 },--Naxx

--2H weap
[231722]={2,4, 79 },-- "Faux du Chaos épuisée"]={2,4, 66 },
[230904]={2,4, 79 }, --Parchemin : SEENECS ED UEF
[231814]={2,4, 79 }, --Cœur chromatique

--1h weap
[231882]={1,4, 79 },--Reçu de l’engin de suppression
[231452]={1,4, 79 }, --Sang du Porteur de Lumière
[229352]={1,4, 79 },--Informations recueillies
[20886]={1,4, 70 }, -- Manche à pointes qiraji
[20890]={1,4, 70 }, -- Manche orné qiraji

--Trinket
[229906]={0.7,4, 76 },--Écaille de bronze ternie
[236350]={0.7,4, 90 }, --naxx

--SHIELD
[231995]={0.5625,4, 79 }, --Scorie d’élémentium durcie
[231378]={0.5625,4, 79 },--Disque doré chatoyant

--neck
[19003]={0.5625,4, 83 }, -- Tête de Nefarian (neck]={0.5625,4, 66 }, ring or offhand]={0.5625,4, 66 }, all have the same slotmod value)
[18423]={0.5625,4, 74 }, -- Tête d'Ony
[235048]={0.5625,4, 77 }, -- Tête d'Ossirian

--specific
[235046]={1,4, 79 }, -- arme impériale qiraji
[235045]={1,4, 79 }, --Tenue de parade impériale qiraji

--INVTYPE_CLOAK or similar
[20885]={0.5625,4, 67 }, -- Drapé martial qiraji
[20889]={0.5625,4, 67 }, -- Drapé royal qiraji
[20888]={0.5625,4, 65 }, --Anneau de cérémonie qiraji
[20884]={0.5625,4, 65 }, --Anneau de magistrat qiraji
[21221]={0.5625,4, 88 }, -- Eye of C-Thun

--ring
[237381]={0.5625,4, 92 },--Naxx

-- null values, recipe, books, enchant...
[235513]={0,4, 0 }, --char qiraji
[235512]={0,4, 0 }, --char qiraji
[235514]={0,4, 0 },
[21281]={0,4, 0 }, 
[21304]={0,4, 0 },
[21298]={0,4, 0 }, 
[21288]={0,4, 0 }, 
[21285]={0,4, 0 }, 
[21296]={0,4, 0 }, 
[21297]={0,4, 0 }, 
[21294]={0,4, 0 },
[21299]={0,4, 0 },
[21289]={0,4, 0 },
[234435]={0,4, 0 }, 
[234242]={0,4, 0 }, 
[234221]={0,4, 0 },
[234265]={0,4, 0 },


}




