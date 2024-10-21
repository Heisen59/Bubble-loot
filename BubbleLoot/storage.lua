-- Data storage

local cfg = BubbleLoot_G.configuration



-- get item score from DB

function BubbleLoot_G.storage.getItemScoreFromDB(playerName, itemId, recalc)

	local itemData = PlayersData[playerName].items[itemId]

	if itemData == nil then
		print("Error :"..playerName.." doesn't have the itemid "..itemId.." in his player DB !")
		return 0
	end

	local itemLink = itemData[cfg.ITEMLINK ]
	local itemScore = itemData[cfg.ITEM_SCORE]

	if itemScore == nil or itemScore == -1 or itemScore == 0 or itemScore == 0.601 or recalc then
		-- need calculation
		local calcItemScore = BubbleLoot_G.calculation.GetItemScore(itemId)

		if calcItemScore == nil then
			-- recalc and write it later
			C_Timer.After(2, function()
				BubbleLoot_G.storage.getItemScoreFromDB(playerName, itemId, recalc)
            end)

			return 0.601

		else
			-- let's write it in the DB

			if calcItemScore == 0 or calcItemScore == 0.601 then
				print("getItemScoreFromDB function : "..itemLink.." itemID "..itemId.." have a score of "..calcItemScore)
			end

			PlayersData[playerName].items[itemId][cfg.ITEM_SCORE] = calcItemScore
			return calcItemScore
		end




	else
		return itemScore
	end

end


-- Time stamp functions
local function writeLastPlayerDataBaseTimeStamp()

	local timeStamp = time()

	if BubbleLootData["PLAYERS_DATA_TIME_STAMP"] > timeStamp then
		print("playersData time stamp ERROR : the current time stamp is older than the database time stamp")
	end

	BubbleLootData["PLAYERS_DATA_TIME_STAMP"] = timeStamp

	return timeStamp

end

function BubbleLoot_G.storage.writeLastPlayerDataBaseTimeStampGlobal()
	return writeLastPlayerDataBaseTimeStamp()
end


local function getPlayerDataBaseTimeStamp()

	return BubbleLootData["PLAYERS_DATA_TIME_STAMP"]

end

local function forcePlayerDataBaseWriteTimeStamp(timeStamp)

	if BubbleLootData["PLAYERS_DATA_TIME_STAMP"] > timeStamp then
		print("playersData time stamp ERROR : the current time stamp is older than the database time stamp")
	end

	BubbleLootData["PLAYERS_DATA_TIME_STAMP"] = timeStamp

end


function BubbleLoot_G.storage.forcePlayerDataBaseWriteTimeStampGlobal(timeStamp)
	forcePlayerDataBaseWriteTimeStamp(timeStamp)
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
		
    end	
end


-- Get Number of items looted as MS or OS
function BubbleLoot_G.storage.NumberOfItemsMSOS(itemData, LootAttribType)

	-- print("NumberOfItemsMSOS debug start")
	-- print(itemData)
	-- print(itemData[cfg.NUMBER])
	
	-- print("NumberOfItemsMSOS debug end")

	if LootAttribType == 0 then -- count everything
		return itemData[cfg.NUMBER]
	else 
		local count = 0
		for _, lootData in ipairs(itemData[cfg.LOOTDATA]) do
			if lootData[2] == LootAttribType then count = count + 1 end
		end
		return count
	end

end

-- function to toogle the loot need
function BubbleLoot_G.storage.LootNeedToogle(playerName, itemLink, lootdate, forcedTimeStamp)

	if itemLink and playerName then
		local itemId = tonumber(string.match(itemLink, "item:(%d+):"))

		if(PlayersData[playerName].items[itemId]) then 
			local lootsData = PlayersData[playerName].items[itemId][cfg.LOOTDATA]
			for index, LootData in ipairs(lootsData) do
				--print(LootData[1])
				if LootData[1] == lootdate then
					-- toogle
					if LootData[2] == 1 then
						LootData[2] = 2
					elseif LootData[2] == 2 then LootData[2] = 1
					end
				end
			end
		end
	end

	-- Synchronisation functions
	-- Let's send the data to other players and the whitelist if not in raid			
	if forcedTimeStamp == nil then
		--TIme Stamp functions
		local currentplayerDBTimeStamp = writeLastPlayerDataBaseTimeStamp()

		--print("Data send "..itemLink)
		local LootNeedToogleFunctionTbl = {playerName, itemLink, lootdate, currentplayerDBTimeStamp }
		BubbleLoot_G.sync.BroadcastDataTable(cfg.SYNC_MSG.MODIFY_ITEM_NEED_IN_DATABASE, LootNeedToogleFunctionTbl)
	else			
		forcePlayerDataBaseWriteTimeStamp(forcedTimeStamp)
			return
	end


end

-- Function to add player item data
function BubbleLoot_G.storage.AddPlayerData(playerName, itemLink, LootAttribType, itemDate, exchange, forcedTimeStamp)

	exchange = exchange or false
	LootAttribType = LootAttribType or 1
    --print("I'm in AddPlayerData")
	--print(playerName)
	--print(itemLink)

	-- do some work on itemDate :
		local forceAdd = false

		local datePattern = "(%d%d%-%d%d%-%d%d%d%d à %d%d:%d%d:%d%d)"
		local itemDateLocal
		local usedDate = date("%d-%m-%Y à %H:%M:%S")

		if itemDate ~= nil then
			itemDateLocal =  string.match(itemDate, datePattern)
			if string.find(itemDate, cfg.texts.FORCE_ADD_STR) then
				forceAdd = true
				usedDate = itemDateLocal
			end	
		end


	if itemDate == nil  or forceAdd then
	



		local instanceName, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID, instanceGroupSize = GetInstanceInfo()
		instanceName = instanceName or "None"
		
		local number = 0
		local itemScore = -1
		
		if itemLink and playerName then	
		
			local itemId = tonumber(string.match(itemLink, "item:(%d+):"))
			if itemId == nil then print("AddPlayerData error : can't extract itemId from itemLink "..itemLink) return end

			-- if needed, create a new player entry
			CreateNewPlayerEntry(playerName)

			if not PlayersData[playerName].items then
			 	print("items sublist not initialized")
			end
		
			local lootsData ={}
			
			if(PlayersData[playerName].items[itemId]) then 
			
				-- first, check if we already added this item a few minutes ago
				for _, lootData in pairs(PlayersData[playerName].items[itemId][cfg.LOOTDATA]) do 
					if BubbleLoot_G.calculation.GetDurationInHours(lootData[1], usedDate) < 0.1 then
						print("This item has been added in the database a few minutes ago ...")
						--print("Override it for debug")
						return -- we do nothing it already exist.
					end
				end

				-- item already exist
				
				-- Get and set number of looted item
				number = PlayersData[playerName].items[itemId][cfg.NUMBER]
				
				-- Get current lootsData (contains date and lootAttribType)
				lootsData = PlayersData[playerName].items[itemId][cfg.LOOTDATA]
			
				itemScore = PlayersData[playerName].items[itemId][cfg.ITEM_SCORE]
			
			
				
			end				
			
			
			number = number +1
			table.insert(lootsData,1,  {usedDate, LootAttribType})
			
			
			
			local dataItem = {itemLink, lootsData, instanceName, number, itemScore}
			
			--table.insert(PlayersData[playerName].items, dataItem)
			PlayersData[playerName].items[itemId] = dataItem
			BubbleLoot_G.storage.getItemScoreFromDB(playerName, itemId)
  
		else
			print("function AddPlayerData adding: error")	
		end
	
	else -- removeData = true
		
		if itemLink and playerName then
		
			local itemId = tonumber(string.match(itemLink, "item:(%d+):"))
			

			
						
			-- let search for the proper item to remove
			for index, LootData in ipairs(PlayersData[playerName].items[itemId][cfg.LOOTDATA]) do
				if LootData[1] == itemDateLocal then
							
					if not exchange and not forcedTimeStamp then
						BubbleLoot_G.storage.AddDeletedItemForPlayer(playerName,itemLink,LootData)
					end
					
					table.remove(PlayersData[playerName].items[itemId][cfg.LOOTDATA], index)
					break
					
				else
					print("AddPlayerData : try to remove a LootData, but can't find it")
				end
			end

			-- check if we need to remove the item and not only the loot
			
				
				if PlayersData[playerName].items[itemId][cfg.LOOTDATA][1] == nil then
					print("item "..PlayersData[playerName].items[itemId][cfg.ITEMLINK].." from player "..playerName.." is removed !")
					PlayersData[playerName]["items"][itemId] = nil
				end
			
		else
			print("function AddPlayerData deleting: error")	
		end
	
	end
	
	
			-- update LootMgrFrame
		--BubbleLoot_G.gui.createLootsMgrFrame(playerName, true)
		BubbleLoot_G.gui.createLootsMgrFrame(playerName, true)

		
		
		-- Synchronisation functions
		-- Let's send the data to other players and the whitelist if not in raid			
		if forcedTimeStamp == nil then
			--TIme Stamp functions
			local currentplayerDBTimeStamp = writeLastPlayerDataBaseTimeStamp()

			--print("Data send "..itemLink)
			local AddPlayerDataFunctionTbl = {playerName, itemLink, LootAttribType, itemDate, exchange, currentplayerDBTimeStamp }
			BubbleLoot_G.sync.BroadcastDataTable(cfg.SYNC_MSG.ADD_PLAYER_DATA_FUNCTION, AddPlayerDataFunctionTbl)
		else			
			forcePlayerDataBaseWriteTimeStamp(forcedTimeStamp)
			 return
		end

end


function BubbleLoot_G.storage.GetNumberOfRaidLoot(playerName, lootType, DeltaT)

	local number = 0

	for _, itemData in pairs(PlayersData[playerName].items) do
		local lootsData = itemData[cfg.LOOTDATA]		
		for _, lootData in ipairs(lootsData) do
			if lootData[2] == lootType and BubbleLoot_G.calculation.GetDurationInHoursFromCurrentTime(lootData[1]) < DeltaT then
				
				number =  number + 1
			end
		end
		
	end

	return number

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
function BubbleLoot_G.storage.AddRaidParticipation(isFromBroadCast)
	-- Increase the raid counter
	if(IsInRaid() or true) then
		BubbleLoot_G.increaseNumberOfRaid()
		-- Loop through all raid members
		local N = GetNumGroupMembers()
		for i = 1, N do
			local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i)
			BubbleLoot_G.storage.AddPlayerParticipation(name, cfg.index.ATTENDANCE)
		end
		
		--BubbleLoot_G.storage.ResetNumberOfRaidLoot()
		
		print("Participation of all raid member increased")
		print(BubbleLoot_G.getNumberOfRaid().." number of raids so far !")
		
		-- refresh participation mgr windows
		BubbleLoot_G.gui.RefreshParticipationWindow()
				
		
	else
		--BubbleLoot_G.storage.ResetNumberOfRaidLoot()
		print("Function available in raid only !")	
	end

		-- Synchronisation functions
	-- Let's send the data to other players and the whitelist if not in raid			
	if isFromBroadCast == true then
	else			
		--TIme Stamp functions
		print("Boadcast Add raid participation")
		BubbleLoot_G.sync.BroadcastDataTable(cfg.SYNC_MSG.ADD_RAID_PARTICIPATIOn, 0)
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


--[[

	Cancel Data

--]]

function BubbleLoot_G.storage.getLastDeletedItemLinkForPlayer(playerName)
	
	if CancelData[cfg.cancelIndex.LAST_DELETED_LOOT_PLAYER_LIST][playerName] ~=nil and CancelData[cfg.cancelIndex.LAST_DELETED_LOOT_PLAYER_LIST][playerName][1] then
		return CancelData[cfg.cancelIndex.LAST_DELETED_LOOT_PLAYER_LIST][playerName][1][1]
	else
		--CancelData[cfg.cancelIndex.LAST_DELETED_LOOT_PLAYER_LIST][playerName] = {}
		return nil
	end
	
end

function BubbleLoot_G.storage.RestoreLastDeletedItemForPlayer(playerName)

	-- restore in PlayersData
	local itemCancelData = CancelData[cfg.cancelIndex.LAST_DELETED_LOOT_PLAYER_LIST][playerName][1]
	local itemLink = itemCancelData[1]
	local lootData = itemCancelData[2]
	local LootAttribType = lootData[2]
	local itemDate = cfg.texts.FORCE_ADD_STR..lootData[1]

	
	local itemId = tonumber(string.match(itemLink, "item:(%d+):"))	
	
	BubbleLoot_G.storage.AddPlayerData(playerName, itemLink, LootAttribType, itemDate)
	-- print("RestoreLastDeletedItemForPlayer start test")
	-- print(itemData[1])
	-- print(itemId)
	-- print(playerName)
	
	-- print("RestoreLastDeletedItemForPlayer end test")
		
	-- remove from CancelData
	table.remove(CancelData[cfg.cancelIndex.LAST_DELETED_LOOT_PLAYER_LIST][playerName], 1)
	
	

end


local function DeepCopy(original)
    local copy = {}
	if original == nil then
		return nil
	end
    for k, v in pairs(original) do
        if type(v) == "table" then
            copy[k] = DeepCopy(v)  -- Recursively copy tables
        else
            copy[k] = v  -- Copy values
        end
    end
    return copy
end

function BubbleLoot_G.storage.AddDeletedItemForPlayer(playerName, itemLink, lootData)

	CancelData[cfg.cancelIndex.LAST_DELETED_LOOT_PLAYER_LIST][playerName] = CancelData[cfg.cancelIndex.LAST_DELETED_LOOT_PLAYER_LIST][playerName] or {}
	table.insert(CancelData[cfg.cancelIndex.LAST_DELETED_LOOT_PLAYER_LIST][playerName],1,  {itemLink, lootData})

end

function BubbleLoot_G.storage.RemovePlayerGlobal(playerName)

	PlayersData[playerName] = nil

end



function BubbleLoot_G.storage.CleanPlayersDataBase()

for playerName, playerInfo in pairs(PlayersData) do
	for itemId, itemInfo in pairs(playerInfo["items"]) do
		if itemInfo[cfg.LOOTDATA][1] == nil then
			print("item "..itemInfo[cfg.ITEMLINK].." from player "..playerName.." is removed !")
			PlayersData[playerName]["items"][itemId] = nil
		end
	end
end



end




