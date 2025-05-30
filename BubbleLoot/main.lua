-- Main file. Info and globals.
-- Globals: `BubbleLoot_G`, `BubbleLootShown`, `BubbleLoot_OnAddonCompartmentClick`

-- Global locals (this addon's global namespace).
BubbleLoot_G = {}
--Data storage
BubbleLoot_G.storage = {}
-- `eventFunctions.lua` namespace.
BubbleLoot_G.eventFunctions = {}
-- `eventFrames.lua` namespace.
BubbleLoot_G.eventFrames = {}
-- `configuration.lua` namespace.
BubbleLoot_G.configuration = {}
-- `gui.lua` namespace.
BubbleLoot_G.gui = {}
-- `rollerCollection.lua` namespace.
BubbleLoot_G.rollerCollection = {}
-- `roller.lua` namespace. Start by calling `New()`.
BubbleLoot_G.roller = {}
-- `playerInfo.lua` namespace.
BubbleLoot_G.playerInfo = {}
-- Container for plugin namespaces.
---@type Plugin[]
BubbleLoot_G.plugins = {}
--Items calculation
BubbleLoot_G.calculation = {}
--Syncing
BubbleLoot_G.sync = {}
--CSV
BubbleLoot_G.csv = {}

---
---@class Plugin Mandatory plugin interface.
---@field NAME string Plugin name. No spaces (will be used by slash commands).
---@field Initialize fun(self: Plugin, mainFrame: frame, relativePoint): any Return `relativePoint`.
---@field Draw fun(self: Plugin, relativePoint): integer, any Return `addRows, relativePoint` pair.
---@field SlashCmd fun(self: Plugin, args: string)

local cfg = BubbleLoot_G.configuration

--- toggles
BubbleLoot_G.IsOfficier = false

---@enum GroupTypeEnum addon user group status
BubbleLoot_G.GroupType = {
    NOGROUP = "NOGROUP",
    PARTY = "PARTY",
    RAID = "RAID",
}

---Find what kind of group is the current player in.
---@return GroupTypeEnum
function BubbleLoot_G.GetGroupType(self)
    if IsInRaid() then
        return self.GroupType.RAID
    elseif IsInGroup() then -- Any group type but raid => party.
        return self.GroupType.PARTY
    else
        return self.GroupType.NOGROUP
    end
end


-- Helping function to check if a player is a guild officer

function BubbleLoot_G.GuildRoster()
	if _G.GuildRoster then
		return _G.GuildRoster()
	else
		return C_GuildInfo.GuildRoster()
	end
end

BubbleLoot_G.GuildRoster()

function BubbleLoot_G.IsGuildOfficer(playerName)
	BubbleLoot_G.GuildRoster()
	--print(playerName)
	for i = 1, GetNumGuildMembers() do
		local name, rank, rankIndex = GetGuildRosterInfo(i)
		--print(name)
		GuildPlayerName, _ = string.match(name, "([^%-]+)%-([^%-]+)")
		if rankIndex < 6 then
			--print(GuildPlayerName)
			--print(rankIndex)
			if GuildPlayerName and (string.lower(GuildPlayerName) == string.lower(playerName) or string.lower(name)== string.lower(playerName)) then					
				return true
			end
		end
	end
	return false
end



-- Include in the minimap compartement. Needs to be global.
function BubbleLoot_OnAddonCompartmentClick()
    BubbleLoot_G.gui:SetVisibility(not BubbleLootData["SHOWN"])
end

function BubbleLoot_G.updateAverageLootScore()
	--local averageLootScore = BubbleLoot_G.calculation.getAverageLootScorePerRaid()

	BubbleLoot_G.configuration.constant[1] = RaidData[cfg.RAID_VALUE]
	BubbleLoot_G.configuration.constant[2] = RaidData[cfg.RAID_VALUE]

	--print("New average score set")

end

-- Initialize self, plugins, saved variables
function BubbleLoot_G.Initialize(self)
	-- set average score
	
	BubbleLoot_G.updateAverageLootScore()

	-- Set isOfficer
	local OwnerName, _ = UnitName("player")	
	--BubbleLoot_G.IsGuildOfficer(OwnerName)
	BubbleLoot_G.IsOfficier = BubbleLoot_G.IsGuildOfficer(OwnerName) -- BubbleLoot_G.IsGuildOfficer(OwnerName)


    local relativePoint = self.gui:Initialize()
    -- Plugins initialize.
    for _, plugin in ipairs(self.plugins) do
        relativePoint = plugin:Initialize(self.gui.mainFrame, relativePoint)
    end


	--Storage data initialize
	BubbleLoot_G.initPlayersData(false)
    -- Load saved variables.
	BubbleLoot_G.initCancelData(false)

	--Soft Reserve initialize
	BubbleLoot_G.initSRData(false)

	-- Set item raid values table
	BubbleLoot_G.initItemsRaidValuesData(false)

	-- Set autoloot table data
	BubbleLoot_G.initAutoLootData(false)
	
	BubbleLootData = BubbleLootData or {}
	
	if BubbleLootData["SHOWN"] == nil then -- Initialize when first loaded.
        BubbleLootData["SHOWN"] = true;
    end
    self.gui:SetVisibility(BubbleLootData["SHOWN"])
	
	--Time stamp
	BubbleLootData["PLAYERS_DATA_TIME_STAMP"] = BubbleLootData["PLAYERS_DATA_TIME_STAMP"] or 0

	
	-- RaidData
	BubbleLoot_G.initRaiData(false)
	
	-- check if major a database modification need a restructuration

	while BubbleLootData["DATA_STRUCTURE"] ~= "v1.2" do
		PlayersData = MigrationToNewDataBase(PlayersData)				
	end
	
	
	-- Sync trust list
	BubbleLoot_G.initSyncData(false)

    -- Starting in a group?
    if IsInGroup() then
        -- As if GROUP_JOINED was triggered.
        self.eventFunctions.OnGroupJoined(self)
    end
	
    -- Plugins might have sth to say.
    self:Draw()
end

function BubbleLoot_G.initSyncData(forced)
	if forced == true then
		SyncTrustList = {}
	else
		SyncTrustList = SyncTrustList or {}
	end

	SyncTrustList[cfg.TRUST_LIST] = SyncTrustList[cfg.TRUST_LIST] or {}
	SyncTrustList[cfg.BLACK_LIST] = SyncTrustList[cfg.BLACK_LIST] or {}

end

function BubbleLoot_G.initPlayersData(forced)
	if forced == true then
		PlayersData = {}
	else
		PlayersData = PlayersData or {}
	end
end

function BubbleLoot_G.initSRData(forced)
	if forced == true then
		SRData = {}
	else
		SRData = SRData or {}
	end
end

function  BubbleLoot_G.initRaiData(forced)

	if forced == true then
		RaidData = {}
	else
		RaidData = RaidData or {}
	end

	
	if RaidData[cfg.NUMBER_OF_RAID_DONE] == nil then -- Initialize when first loaded.
		RaidData[cfg.NUMBER_OF_RAID_DONE] = 0;
	end

	if RaidData[cfg.RAID_HISTORIC] == nil then -- Initialize when first loaded.
		RaidData[cfg.RAID_HISTORIC] = {};
	end	

	if RaidData[cfg.RAID_VALUE] == nil then -- Initialize when first loaded.
		print('init raid value')
		RaidData[cfg.RAID_VALUE] = 0.5;
	end	

end


function BubbleLoot_G.initItemsRaidValuesData(forced)
	if forced == true then
		ItemsRaidValues = {}
	else
		ItemsRaidValues = ItemsRaidValues or {}
	end

	if ItemsRaidValues[cfg.CURRENT_VALUE] == nil then
		ItemsRaidValues[cfg.CURRENT_VALUE] = 1
	end

	if ItemsRaidValues[cfg.ITEMS] == nil then
		ItemsRaidValues[cfg.ITEMS] = {}
	end


end

function BubbleLoot_G.initAutoLootData(forced)
	if forced == true then
		AutoLootData = {}
	else
		AutoLootData = AutoLootData or {}
	end
end


function BubbleLoot_G.initCancelData(forced)

	if forced == true then
		CancelData = {}
	else
		CancelData = CancelData or {}
	end

	CancelData[cfg.cancelIndex.LAST_DELETED_LOOT_PLAYER_LIST] = CancelData[cfg.cancelIndex.LAST_DELETED_LOOT_PLAYER_LIST] or {}

end

--
---@return Plugin? plugin Namespace or nil if not found.
--[[function BubbleLoot_G.FindPlugin(self, name)
    for _, plugin in ipairs(self.plugins) do
        if name == plugin.NAME then
            return plugin
        end
    end
    return nil
end--]]

--
---@return string
--[[function BubbleLoot_G.PluginsToString(self)
    if #self.plugins == 0 then
        return "No plugins"
    end
    local names = {}
    for _, plugin in ipairs(self.plugins) do
        names[#names + 1] = plugin.NAME
    end
    return "Plugins: " .. table.concat(names, ", ")
end--]]

-- Main drawing function.
function BubbleLoot_G.Draw(self)

	--print("draw")

    -- Start at 0 for header.
    local currentRow = 0

    -- Fetch data, fill, sort, write.
    local addRows, relativePoint = self.rollerCollection:Draw()
    currentRow = currentRow + addRows

    -- Plugins draw.
    --[[for _, plugin in ipairs(self.plugins) do
        addRows, relativePoint = plugin:Draw(relativePoint)
        currentRow = currentRow + addRows
    end--]]


    self.gui:SetHeight(cfg.size.EMPTY_HEIGHT + cfg.size.ROW_HEIGHT * currentRow)
end


function round2(num, numDecimalPlaces)
  return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end



--[[

Getter and setter

]]--

function BubbleLoot_G.getNumberOfRaid()
	return RaidData[cfg.NUMBER_OF_RAID_DONE]
end

function BubbleLoot_G.GetLastRaidDate()

	return RaidData[cfg.RAID_HISTORIC][1][1]

end


function BubbleLoot_G.increaseNumberOfRaid()
	RaidData[cfg.NUMBER_OF_RAID_DONE] = RaidData[cfg.NUMBER_OF_RAID_DONE] + 1
			
	local instanceName, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID, instanceGroupSize = GetInstanceInfo()
	instanceName = instanceName or "None"

	table.insert(RaidData[2],1, {date("%d-%m-%Y à %H:%M:%S"), instanceName})

end

function BubbleLoot_G.setNumberOfRaid(num)
	RaidData[cfg.NUMBER_OF_RAID_DONE] = num
end





--[[

	Database migration

]]--

function MigrationToNewDataBase(PlayersDataBase)
-- old not numbered database to v1.2
if BubbleLootData["DATA_STRUCTURE"] == nil then

	local localPlayersDataBase = {}

	for playerName, playerData in pairs(PlayersDataBase) do
		--print("player "..playerName)
		-- initialized player in localdatabase
		localPlayersDataBase[playerName] = {
			items = {},
			BonusMalus = {},
			participation = {0,0,0}
		}
		
		-- do work on Items
		for itemIndex, itemData  in ipairs(playerData.items) do
			-- old data structure : {itemName Or link, currentTime, SlotMod}
			-- new data structure : [itemId] = {itemLink, currentTime, instanceName}
			
			local oldItemNameOrLink = itemData[1]
			local oldCurrentTime = itemData[2]
			
			--print("item "..oldItemNameOrLink)
			
			local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc = C_Item.GetItemInfo(oldItemNameOrLink)
			
			if itemLink then
				local itemId = tonumber(string.match(itemLink, "item:(%d+):"))
				if(itemId) then
					localPlayersDataBase[playerName].items[itemId] = {itemLink, oldCurrentTime, ""}
				else
					print("Migration to v1.2, can't extract itemId from item link")
				end
			else
				print("Item "..oldItemNameOrLink.." for player "..playerName.." can't be imported in new database structure. Reason : can't get item info from item name (item not in cache)")
			end
			
		end
		
		-- do work on participation and malus
		localPlayersDataBase[playerName].participation = PlayersDataBase[playerName].participation
		localPlayersDataBase[playerName].BonusMalus = PlayersDataBase[playerName].BonusMalus	
	end

	print("Migration to players database v1.2 successfull")
	BubbleLootData["DATA_STRUCTURE"] = "v1.2"
	return localPlayersDataBase
end




print("Data base up to date or case not yet implemented, shouldn't enter here")
return PlayersDataBase

end






--[[

Librairy functions and compatibility options

--]]

local LibDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0", true)
EasyMenu = function(...)
    if LibDD then
        LibDD:EasyMenu(...)
    else
        _G.EasyMenu(...)
    end
end


--GetContainerNumSlots, GetContainerItemLink, GetContainerItemCooldown, GetContainerItemInfo, GetItemCooldown, PickupContainerItem, ContainerIDToInventoryID
if C_Container then
	GetContainerNumSlots = C_Container.GetContainerNumSlots
	GetContainerItemLink = C_Container.GetContainerItemLink
	GetContainerItemCooldown = C_Container.GetContainerItemCooldown
	GetItemCooldown = C_Container.GetItemCooldown
	PickupContainerItem = C_Container.PickupContainerItem
	ContainerIDToInventoryID = C_Container.ContainerIDToInventoryID
	GetContainerItemInfo = function(bag, slot)
		local info = C_Container.GetContainerItemInfo(bag, slot)
		if info then
			return info.iconFileID, info.stackCount, info.isLocked, info.quality, info.isReadable, info.hasLoot, info.hyperlink, info.isFiltered, info.hasNoValue, info.itemID, info.isBound
		else
			return
		end
	end
else
	GetContainerNumSlots, GetContainerItemLink, GetContainerItemCooldown, GetContainerItemInfo, GetItemCooldown, PickupContainerItem, ContainerIDToInventoryID =
	_G.GetContainerNumSlots, _G.GetContainerItemLink, _G.GetContainerItemCooldown, _G.GetContainerItemInfo, _G.GetItemCooldown, _G.PickupContainerItem, _G.ContainerIDToInventoryID
end


--[[

DEBUG

]]--


function PrintCallStack()
    -- Use debugstack to get the full call stack
    local stack = debugstack(3, 1, 0)  -- Adjusted to skip the current function and its immediate caller
    
    -- Print the stack trace to the chat frame
    DEFAULT_CHAT_FRAME:AddMessage("Call Stack:")
    for line in stack:gmatch("[^\r\n]+") do
        if line ~= "" then  -- Skip empty lines
            DEFAULT_CHAT_FRAME:AddMessage("  " .. line)
        end
    end
end