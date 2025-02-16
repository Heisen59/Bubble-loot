-- misc calculation

local cfg = BubbleLoot_G.configuration


function BubbleLoot_G.calculation.GetPlayerItemList(playerName)

local itemsList = BubbleLoot_G.storage.GetPlayerLootList(playerName) or {}

 for index, value in pairs(itemsList) do
        print(value[1].." at "..value[2].." in "..value[3])
    end


end

function BubbleLoot_G.calculation.GetPlayerBonus(playerName)

	local playerBonus = PlayersData[playerName].BonusMalus or {}
	local score = 0

	for _, BonusData in ipairs(playerBonus) do 
		if BonusData[2] ~= nil then
			score = score + BonusData[2]
		end
	end

	return score

end


function BubbleLoot_G.calculation.GetItemMultiplier(itemId)

	local multiplier = ItemsRaidValues[cfg.ITEMS][itemId]

	if multiplier == nil then return 1 end

	return multiplier
end


function BubbleLoot_G.calculation.GetPlayerScore(playerName, lootscore)

	--print("Get loot score player")
	lootscore = lootscore or false;

	--print("GetPlayerScore function")

	local score = 0
	--Check if player exist in database
	if not BubbleLoot_G.storage.GetPlayerData(playerName, false) then return score end



	-- First, get loot score
	local itemsList = BubbleLoot_G.storage.GetPlayerLootList(playerName)
		if(itemsList) then
			for itemId, itemData in pairs(itemsList) do
				NumberOfItemsLooted = BubbleLoot_G.storage.NumberOfItemsMSOS(itemData, 1) -- only count MS items
				--print(NumberOfItemsLooted)
				local multiplier = BubbleLoot_G.calculation.GetItemMultiplier(itemId)
				score = score +  NumberOfItemsLooted * BubbleLoot_G.storage.getItemScoreFromDB(playerName, itemId, true)*multiplier
			end
		end

	if lootscore then return score end

	-- Second, modify this loot score according to attendance
	local participation = BubbleLoot_G.storage.GetPlayerParticipation(playerName)
		if(participation) then
			score = score - RaidData[cfg.RAID_VALUE]*participation[cfg.index.ATTENDANCE] - RaidData[cfg.RAID_VALUE]*participation[cfg.index.BENCH] + cfg.constant.NON_ATTENDANCE_VALUE*participation[cfg.index.NON_ATTENDANCE]
		end
		
	-- Third : bonus/malus
	score = score - BubbleLoot_G.calculation.GetPlayerBonus(playerName)
		


	return score

end

local function getRarityModifier(index)
	local rarityModifiers = {
		-- Assuming rarity is a number from 1 (common) to 5 (legendary)
		[0] = 3.5, -- Poor
		[1] = 3, -- Common
		[2] = 2.5, -- Uncommon
		[3] = 1.76, -- Rare
		[4] = 1.6, -- Epic
		[5] = 1.4, -- Legendary
	}

return rarityModifiers[index]

end

function BubbleLoot_G.calculation.GetItemScore(itemId)
	

	local ItemSlotMod, itemLevel,  RarityModifier = BubbleLoot_G.calculation.GetItemScoreInfo(itemId)


	if itemLevel == nil then itemLevel = 0 end
	if RarityModifier == nil then RarityModifier = 0 end
	if ItemSlotMod == nil then ItemSlotMod = 0 end

	

	-- Calculate score for this item
    return ItemSlotMod --/ 60 --normalized by 60


	-- return ItemSlotMod
end




function BubbleLoot_G.calculation.GetItemScoreInfo(itemId)

	local ItemSlotMod, itemLevel,  RarityModifier
	-- print(itemId)
	
-- First, try to get item info using the item name
    local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc = C_Item.GetItemInfo(itemId)


	
	-- print(itemName)
	
		local slotMod = {
            ["INVTYPE_HEAD"] = 1,
            ["INVTYPE_NECK"] = 0.5625,
            ["INVTYPE_SHOULDER"] = 1,
            ["INVTYPE_BODY"] = 0,
            ["INVTYPE_CHEST"] = 1,
            ["INVTYPE_ROBE"] = 1,
            ["INVTYPE_WAIST"] = 0.77,
            ["INVTYPE_LEGS"] = 1,
            ["INVTYPE_FEET"] = 1,
            ["INVTYPE_WRIST"] = 0.5625,
            ["INVTYPE_HAND"] = 0.77,
            ["INVTYPE_FINGER"] = 0.5625,
            ["INVTYPE_TRINKET"] = 0.7,
            ["INVTYPE_CLOAK"] = 0.5625,
            ["INVTYPE_WEAPON"] = 1,
            ["INVTYPE_SHIELD"] = 0.5625,
            ["INVTYPE_2HWEAPON"] = 2,
            ["INVTYPE_WEAPONMAINHAND"] = 1,
            ["INVTYPE_WEAPONOFFHAND"] = 0.5625,
            ["INVTYPE_HOLDABLE"] = 0.5625,
            ["INVTYPE_RANGED"] = 0.3164,
            ["INVTYPE_THROWN"] = 0.3164,
            ["INVTYPE_RANGEDRIGHT"] = 0.3164,
            ["INVTYPE_RELIC"] = 0.3164,
            ["INVTYPE_TABARD"] = 0,
            ["INVTYPE_BAG"] = 0,
            ["INVTYPE_QUIVER"] = 0,
			["INVTYPE_ZERO"] = 0,
        }

		
		

	 if itemEquipLoc and itemName  then
		local slotModValue = slotMod[itemEquipLoc]
		if slotModValue then
			ItemSlotMod = slotModValue
		else -- check if token
			local tokenInfo = BubbleLoot_G.calculation.SearchToken(itemId, itemName)
			
			if tokenInfo == nil then
				print("GetItemSlotMode function : "..itemName.."["..itemId.."] doesn't have any info")	
				ItemSlotMod = 0
				itemLevel =  0
				itemRarity = 0
			else
				ItemSlotMod = 	tokenInfo[1]
				itemLevel = tokenInfo[3]
				itemRarity = tokenInfo[2]				
			end
		end
	 else	
		if itemName then 
			print("GetItemSlotMode function : "..itemName.."["..itemId.."] doesn't have any itemEquipLoc")			
		else
			--print(itemId)
			print("GetItemSlotMode function : item".."["..itemId.."]  not in cache. Wait for server response.")			
		end		
	 --[[
		slotModValue = slotMod[BubbleLoot_G.calculation.SearchToken(item)]
		if slotModValue then
			return slotModValue
		else
			return 0
		end
		--]]
		ItemSlotMod = 0
		itemLevel =  0
		itemRarity = 0
	end
	
	local RarityModifier = getRarityModifier(itemRarity)

	return ItemSlotMod, itemLevel,  RarityModifier

end




function BubbleLoot_G.calculation.SearchToken(itemID, itemName)
	-- print("enter Search token for "..itemName)
	local itemInfo = cfg.tokens[itemID]
	if itemInfo == nil then return nil end
	-- print("itemId "..itemID.." ,"..itemInfo[1].." ,"..itemInfo[2].." ,"..itemInfo[3])
	return itemInfo
end



-- Get the winner from ML /rand 1000 roll
function BubbleLoot_G.calculation.getTheWinner(roll)

	--print("getTheWinner :point A")
	
-- first, is there any +1 rollers
	if not BubbleLoot_G.rollerCollection:IsMsRoller() then
		--print("There is no MS need in this roll")
		return nil
	end

	--print("getTheWinner :point B")
-- second, compute all loot chance for MS and get the winner
	BubbleLoot_G.rollerCollection:LootChanceRoller()
	--print("getTheWinner :point C")
	
-- third, return the winner
	local winner = BubbleLoot_G.rollerCollection:getTheWinner(roll-1)

	--print("the winner is "..winner)
	if IsInRaid() then
		SendChatMessage("Ze Winner est "..winner, "RAID_WARNING")
	else
		print("the winner is "..winner)
	end


end



--[[

Other calculations

--]]

-- Helper function to parse date string and return a time table
function BubbleLoot_G.calculation.ParseDateString(dateString)
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


function BubbleLoot_G.calculation.GetDurationInHoursFromCurrentTime(dateString1)
	local dateString2 = date("%d-%m-%Y à %H:%M:%S")

	-- Parse both date strings into date tables
	local dateTable1 = BubbleLoot_G.calculation.ParseDateString(dateString1)
	local dateTable2 = BubbleLoot_G.calculation.ParseDateString(dateString2)
	
	-- Convert both date tables to Unix timestamps
	local timestamp1 = time(dateTable1)
	local timestamp2 = time(dateTable2)
	
	-- Calculate the difference in seconds
	local differenceInSeconds = math.abs(timestamp2 - timestamp1)
	
	-- Convert the difference from seconds to hours
	local differenceInHours = differenceInSeconds / 3600
	
	return differenceInHours
end

-- Function to calculate duration between two date strings
function BubbleLoot_G.calculation.GetDurationInHours(dateString1, dateString2)
    -- Parse both date strings into date tables
    local dateTable1 = BubbleLoot_G.calculation.ParseDateString(dateString1)
    local dateTable2 = BubbleLoot_G.calculation.ParseDateString(dateString2)
    
    -- Convert both date tables to Unix timestamps
    local timestamp1 = time(dateTable1)
    local timestamp2 = time(dateTable2)
    
    -- Calculate the difference in seconds
    local differenceInSeconds = math.abs(timestamp2 - timestamp1)
    
    -- Convert the difference from seconds to hours
    local differenceInHours = differenceInSeconds / 3600
    
    return differenceInHours
end


-- Function to convert date format
function BubbleLoot_G.calculation.ConvertDateFormat(dateStr)
    -- Use pattern matching to extract day, month, year
    local day, month, year = dateStr:match("(%d%d)-(%d%d)-(%d%d%d%d)")
    
    if day and month and year then
        -- Create a table to represent the time structure
        local timeTable = {
            day = tonumber(day),
            month = tonumber(month),
            year = tonumber(year),
            hour = 0,  -- Default time (not needed for final format)
            min = 0,
            sec = 0
        }

        -- Format to the desired format "%Y-%m-%d"
        local newDateFormat = date("%Y-%m-%d", time(timeTable))
        return newDateFormat
    end

    -- Return original if parsing fails
    return dateStr
end

-- Function to convert date string to a timestamp
function BubbleLoot_G.calculation.ConvertToTimestamp(dateStr)
	--print(dateStr)
    -- Use pattern matching to extract day, month, year, hour, min, sec
    local day, month, year, hour, min, sec = dateStr:match("(%d%d)-(%d%d)-(%d%d%d%d) à (%d%d):(%d%d):(%d%d)")

    if day and month and year and hour and min and sec then
        -- Create a table to represent the time structure
        local timeTable = {
            day = tonumber(day),
            month = tonumber(month),
            year = tonumber(year),
            hour = tonumber(hour),
            min = tonumber(min),
            sec = tonumber(sec)
        }

        -- Convert to a Unix timestamp (seconds since epoch)
        return time(timeTable)
    end

    return nil  -- Return nil if the date format is invalid
end



-- function to calculate the average item score per raid and per players
function BubbleLoot_G.calculation.getAverageLootScorePerRaid()

	local N_participation = 0
	local TotalLootScore = 0

	for playerName, playerData in pairs(PlayersData) do
		local playerParticipation = playerData["participation"][1]
		if playerParticipation >0 then
			N_participation = N_participation + playerData["participation"][1]
			for itemId, itemData in pairs(playerData["items"]) do
				for _, lootData in ipairs(itemData[cfg.LOOTDATA]) do
					if lootData[2] == 1 then
						local multiplier = BubbleLoot_G.calculation.GetItemMultiplier(itemId)
						local itemScore = multiplier*BubbleLoot_G.storage.getItemScoreFromDB(playerName, itemId)
						TotalLootScore = TotalLootScore + itemScore 
					end
				end
			end
		end
	end

	return TotalLootScore/N_participation


end


-- function to calculate the average item score per raid and per players
	function BubbleLoot_G.calculation.getAverageLootScore()


		local N_player = 0
		local TotalScore = 0


	
		for playerName, playerData in pairs(PlayersData) do
			local playerParticipation = playerData["participation"][1]
			if playerParticipation >0 then
				N_player = N_player + 1
				TotalScore = TotalScore + BubbleLoot_G.calculation.GetPlayerScore(playerName)
			end
		end
	
		return TotalScore/N_player
	
	
	end