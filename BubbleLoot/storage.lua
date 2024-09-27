-- Data storage

local cfg = BubbleLoot_G.configuration


-- Helper function to parse date string and return a time table
local function ParseDateString(dateString)
    -- Example format: "23-09-2024 à 15:30:45"
    local day, month, year, hour, min, sec = string.match(dateString, "(%d+)-(%d+)-(%d+) à (%d+):(%d+):(%d+)")
    
    -- Create a table with date values
    local dateTable = {
        day = tonumber(day),
        month = tonumber(month),
        year = tonumber(year),
        hour = tonumber(hour),
        min = tonumber(min),
        sec = tonumber(sec)
    }
    
    return dateTable
end

-- Function to calculate duration between two date strings
local function GetDurationInHours(dateString1, dateString2)
    -- Parse both date strings into date tables
    local dateTable1 = ParseDateString(dateString1)
    local dateTable2 = ParseDateString(dateString2)
    
    -- Convert both date tables to Unix timestamps
    local timestamp1 = time(dateTable1)
    local timestamp2 = time(dateTable2)
    
    -- Calculate the difference in seconds
    local differenceInSeconds = math.abs(timestamp2 - timestamp1)
    
    -- Convert the difference from seconds to hours
    local differenceInHours = differenceInSeconds / 3600
    
    return differenceInHours
end

-- function to create a new entry if it doesn't exist
local function CreateNewPlayerEntry(playerName)
    if not PlayersData[playerName] then
        PlayersData[playerName] = {
            items = {},
			BonusMalus = {},
            participation = {0,0,0}
        }
		
		BubbleLoot_G.gui.RefreshParticipationWindow()
		
		BubbleLoot_G.sync.SendEverything()
    end	
end




-- Function to add player item data
function BubbleLoot_G.storage.AddPlayerData(playerName, itemLink, LootAttribType, DateRemoveItem)


	LootAttribType = LootAttribType or 1
    print("I'm in AddPlayerData")
	print(playerName)
	print(itemLink)
	
	if DateRemoveItem == nil then
	
		local instanceName, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID, instanceGroupSize = GetInstanceInfo()
		instanceName = instanceName or "None"
		
		local itemData = {}
		local number = 0
		
		if itemLink and playerName then	
		
			local itemId = tonumber(string.match(itemLink, "item:(%d+):"))
			-- if needed, create a new player entry
			CreateNewPlayerEntry(playerName)
			
			if not PlayersData[playerName].items then
			 print("items sublist not initialized")
			end
		
			
			
			if(PlayersData[playerName].items[itemId]) then 
				-- item already exist
				
				-- Get and set number of looted item
				number = PlayersData[playerName].items[itemId][cfg.NUMBER]
				
				-- Get current itemData (contains date and lootAttribType)
				itemData = PlayersData[playerName].items[itemId][cfg.LOOTDATA]
			
			
			
			
				
			end		
			
			
			number = number +1
			table.insert(itemData,1,  {date("%d-%m-%Y à %H:%M:%S"), LootAttribType})
			
			
			
			local dataItem = {itemLink, itemData, instanceName, number}
			--table.insert(PlayersData[playerName].items, dataItem)
			PlayersData[playerName].items[itemId] = dataItem
			
			

			
			-- Increase numbers of loots		
			BubbleLoot_G.storage.ModifyNumberOfRaidLoot(playerName, 1, 1)
			


		
  
		else
			print("function AddPlayerData adding: error")	
		end
	
	else -- removeData = true
		
		if itemLink and playerName then
		
			local itemId = tonumber(string.match(itemLink, "item:(%d+):"))
			
			BubbleLoot_G.storage.AddDeletedItemForPlayer(playerName, PlayersData[playerName].items[itemId])
			
			if	PlayersData[playerName].items[itemId][cfg.NUMBER] == 1 then
			
			
				if GetDurationInHours(date("%d-%m-%Y à %H:%M:%S"), PlayersData[playerName].items[itemId][cfg.LOOTDATA][1][1]) < 3 then
					local removedItemLootType = PlayersData[playerName].items[itemId][cfg.LOOTDATA][2]
					-- Increase numbers of loots		
					BubbleLoot_G.storage.ModifyNumberOfRaidLoot(playerName, removedItemLootType, -1)
				end
			
				-- only one item, we can safely delete everything
				PlayersData[playerName].items[itemId] = nil
			
			else
				-- multiple item, let's remove the proper loot
				-- let search for the proper item to remove
				for index, LootData in ipairs(PlayersData[playerName].items[itemId][cfg.LOOTDATA]) do
					if LootData[1] == DateRemoveItem then
						
						if GetDurationInHours(date("%d-%m-%Y à %H:%M:%S"), DateRemoveItem) < 3 then
							local removedItemLootType = LootData[2]
							-- Increase numbers of loots		
							BubbleLoot_G.storage.ModifyNumberOfRaidLoot(playerName, removedItemLootType, -1)
						end
												
						
						table.remove(PlayersData[playerName].items[itemId][cfg.LOOTDATA], index)
						break
						
					else
						print("AddPlayerData : try to remove a LootData, but can't find it")
					end
				end
			
			end
		
		
			
		else
			print("function AddPlayerData deleting: error")	
		end
	
	end
	
	
			-- update LootMgrFrame
		BubbleLoot_G.gui.createLootsMgrFrame(playerName, true)
			-- Synchronisation functions
		BubbleLoot_G.sync.SendEverything()
end


function BubbleLoot_G.storage.ModifyNumberOfRaidLoot(playerName, lootType, value)

	-- first initialized if needed
	RaidLootData[playerName] = RaidLootData[playerName] or {0,0}
	RaidLootData[playerName][lootType] = RaidLootData[playerName][lootType] + value
	if RaidLootData[playerName][lootType]<0 then RaidLootData[playerName][lootType] = 0 end

end

function BubbleLoot_G.storage.GetNumberOfRaidLoot(playerName, lootType)

	RaidLootData[playerName] = RaidLootData[playerName] or {0,0}
	return RaidLootData[playerName][lootType]
	
end

function BubbleLoot_G.storage.ResetNumberOfRaidLoot()

	for index, _ in pairs(RaidLootData) do
		RaidLootData[index] = {0,0}
	end

end

-- Function to modify player participation
function BubbleLoot_G.storage.ModifyPlayerParticipation(playerName, participation)
    
	CreateNewPlayerEntry(playerName)
    PlayersData[playerName].participation = participation

end

function BubbleLoot_G.storage.AddPlayerParticipation(playerName, index)

	CreateNewPlayerEntry(playerName)
	PlayersData[playerName].participation[index] = PlayersData[playerName].participation[index] + 1

end

function BubbleLoot_G.storage.ModifyIndexPlayerParticipation(playerName, index, value)

	CreateNewPlayerEntry(playerName)	
	PlayersData[playerName].participation[index] = value

end

--Add all raiders a participation
function BubbleLoot_G.storage.AddRaidParticipation()
	-- Increase the raid counter
	if(IsInRaid()) then
		BubbleLoot_G.increaseNumberOfRaid()
		-- Loop through all raid members
		local N = GetNumGroupMembers()
		for i = 1, N do
			local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i)
			BubbleLoot_G.storage.AddPlayerParticipation(name, cfg.index.ATTENDANCE)
		end
		
		BubbleLoot_G.storage.ResetNumberOfRaidLoot()
		
		print("Participation of all raid member increased")
		print(BubbleLoot_G.getNumberOfRaid().." number of raids so far !")
		
		-- refresh participation mgr windows
		BubbleLoot_G.gui.RefreshParticipationWindow()
		
		BubbleLoot_G.sync.SendEverything()
		
	else
		BubbleLoot_G.storage.ResetNumberOfRaidLoot()
		print("Function available in raid only !")	
	end
end

-- Function to retrieve and print Player data
function BubbleLoot_G.storage.GetPlayerData(playerName, verbose)
    
	--print(PlayersData)
	CreateNewPlayerEntry(playerName)
	
	if verbose == nil then
		if PlayersData[playerName] then
			print("Player: " .. playerName)
			print("Items: ")
			for index, lootData in pairs(PlayersData[playerName].items) do
				print(lootData[cfg.ITEMLINK])
				--[[if string.find(value[1].tostring(), "[") == nil then
					local itemName = GetItemInfo(value[1])
					print(itemName)
				else
					print(value[1])
				end--]]
			end
			--print("Items: " .. table.concat(PlayersData[playerName].items, ", "))
			--print("Last updated at: " .. PlayersData[playerName].time)
		else
			print("No data found for Player " .. playerName)
		end
	end
	
	
	
	if not PlayersData[playerName] then
        CreateNewPlayerEntry(playerName)
		--print("GetPlayerData : player doesn't exist")
		return false
	else
		--print("GetPlayerData : player exist")
		return true
    end
	
end

function BubbleLoot_G.storage.GetPlayerParticipation(playerName)
    -- Store the data in the table if it doesn't exist already
    CreateNewPlayerEntry(playerName)

	return PlayersData[playerName].participation

end

function BubbleLoot_G.storage.GetPlayerLootList(playerName)

    if PlayersData[playerName] then
		return PlayersData[playerName].items
	else
		print("GetPlayerLootList : No data found for Player " .. playerName)
		return nil	        
    end

end



function BubbleLoot_G.storage.getAllPlayersFromDB()

	local PlayerList = {}

	for playerName, value in pairs(PlayersData) do
		--print(playerName)
		table.insert(PlayerList, playerName)
	end

	table.sort(PlayerList)

	return PlayerList

end

function BubbleLoot_G.storage.playerGiveLootToPlayer(donor, recipient, lootId)


	if(PlayersData[donor].items[lootId]) then
		local itemData = PlayersData[donor].items[lootId]
		
		-- BubbleLoot_G.storage.AddPlayerData(recipient, itemData[ITEMLINK], itemData[LOOT_ATTRIBUTION_TYPE])
		-- NEED TO BE MODIFIED
		print("playerGiveLootToPlayer : need modification")
		--PlayersData[recipient].items[lootId] = itemData		
		-- PlayersData[donor].items[lootId] = nil
		-- UNTIL HERE
		
		-- print(donor.." gave " .. lootId .. " to " .. recipient)
		
		-- BubbleLoot_G.storage.ModifyNumberOfRaidLoot(donor, 1, -1)
		-- BubbleLoot_G.storage.ModifyNumberOfRaidLoot(recipient, 1, 1)
		
	else
		print(donor.." doesn't have the required item "..lootId)
		return false
	end

end

--[[

	Cancel Data

--]]

function BubbleLoot_G.storage.getLastDeletedItemForPlayer(playerName)
	
	if CancelData[cfg.cancelIndex.LAST_DELETED_LOOT_PLAYER_LIST][playerName] then
		return CancelData[cfg.cancelIndex.LAST_DELETED_LOOT_PLAYER_LIST][playerName][1]
	else
		CancelData[cfg.cancelIndex.LAST_DELETED_LOOT_PLAYER_LIST][playerName] = {}
		return nil
	end
	
end

function BubbleLoot_G.storage.RestoreLastDeletedItemForPlayer(playerName)

	-- restore in PlayersData
	local itemData = CancelData[cfg.cancelIndex.LAST_DELETED_LOOT_PLAYER_LIST][playerName][1]
	

	
	local itemId = tonumber(string.match(itemData[1], "item:(%d+):"))	
	
	-- print("RestoreLastDeletedItemForPlayer start test")
	-- print(itemData[1])
	-- print(itemId)
	-- print(playerName)
	
	-- print("RestoreLastDeletedItemForPlayer end test")
	
	PlayersData[playerName].items[itemId] = itemData
	
	-- remove from CancelData
	table.remove(CancelData[cfg.cancelIndex.LAST_DELETED_LOOT_PLAYER_LIST][playerName], 1)
	
	

end


local function DeepCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            copy[k] = DeepCopy(v)  -- Recursively copy tables
        else
            copy[k] = v  -- Copy values
        end
    end
    return copy
end

function BubbleLoot_G.storage.AddDeletedItemForPlayer(playerName, itemData)

	local itemDataCopy = DeepCopy(itemData)

	table.insert(CancelData[cfg.cancelIndex.LAST_DELETED_LOOT_PLAYER_LIST][playerName],1,  itemDataCopy)

end

