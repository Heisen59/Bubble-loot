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

---
---@class Plugin Mandatory plugin interface.
---@field NAME string Plugin name. No spaces (will be used by slash commands).
---@field Initialize fun(self: Plugin, mainFrame: frame, relativePoint): any Return `relativePoint`.
---@field Draw fun(self: Plugin, relativePoint): integer, any Return `addRows, relativePoint` pair.
---@field SlashCmd fun(self: Plugin, args: string)

local cfg = BubbleLoot_G.configuration

--- toggles
--Bubbleloot_G.attributionMode = false

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

-- Include in the minimap compartement. Needs to be global.
function BubbleLoot_OnAddonCompartmentClick()
    BubbleLoot_G.gui:SetVisibility(not BubbleLootData[cfg.SHOWN])
end

-- Initialize self, plugins, saved variables
function BubbleLoot_G.Initialize(self)
	--Storage data initialize
	if PlayersData == nil then -- Initialize when first loaded.
        PlayersData = {};
    end

    local relativePoint = self.gui:Initialize()
    -- Plugins initialize.
    for _, plugin in ipairs(self.plugins) do
        relativePoint = plugin:Initialize(self.gui.mainFrame, relativePoint)
    end

    -- Load saved variables.
	CancelData = CancelData or {}
	CancelData[cfg.cancelIndex.LAST_DELETED_LOOT_PLAYER_LIST] = CancelData[cfg.cancelIndex.LAST_DELETED_LOOT_PLAYER_LIST] or {}
	
	BubbleLootData = BubbleLootData or {}
	
	if BubbleLootData[cfg.SHOWN] == nil then -- Initialize when first loaded.
        BubbleLootData[cfg.SHOWN] = true;
    end
    self.gui:SetVisibility(BubbleLootData[cfg.SHOWN])
	
	if BubbleLootData[cfg.NUMBER_OF_RAID] == nil then -- Initialize when first loaded.
		BubbleLootData[cfg.NUMBER_OF_RAID] = 0;
    end
	
	-- check if major a database modification need a restructuration
	while BubbleLootData[cfg.DATA_STRUCTURE] ~= "v1.2" do
		PlayersData = MigrationToNewDataBase(PlayersData)				
	end

    -- Starting in a group?
    if IsInGroup() then
        -- As if GROUP_JOINED was triggered.
        self.eventFunctions.OnGroupJoined(self)
    end
	
    -- Plugins might have sth to say.
    self:Draw()
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
	return BubbleLootData[cfg.NUMBER_OF_RAID]
end


function BubbleLoot_G.increaseNumberOfRaid()
	BubbleLootData[cfg.NUMBER_OF_RAID] = BubbleLootData[cfg.NUMBER_OF_RAID] + 1
end

function BubbleLoot_G.setNumberOfRaid(num)
	BubbleLootData[cfg.NUMBER_OF_RAID] = num
end





--[[

	Database migration

]]--

function MigrationToNewDataBase(PlayersDataBase)
-- old not numbered database to v1.2
if BubbleLootData[cfg.DATA_STRUCTURE] == nil then

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
			
			local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc = GetItemInfo(oldItemNameOrLink)
			
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
	BubbleLootData[cfg.DATA_STRUCTURE] = "v1.2"
	return localPlayersDataBase
end




print("Data base up to date or case not yet implemented, shouldn't enter here")
return PlayersDataBase

end





