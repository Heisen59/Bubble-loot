-- Data storage

local cfg = BubbleLoot_G.configuration


-- function to create a new entry if it doesn't exist
local function CreateNewPlayerEntry(playerName)
    if not PlayersData[playerName] then
        PlayersData[playerName] = {
            items = {},
			BonusMalus = {},
            participation = {0,0,0}
        }
    end	
end




-- Function to add player item data
function BubbleLoot_G.storage.AddPlayerData(playerName, item)
    -- Get current date and time
    local currentTime = date("%Y-%m-%d %H:%M:%S")
    local itemSlotMod = BubbleLoot_G.calculation.GetItemSlotMode(item)
	
	CreateNewPlayerEntry(playerName)
	
    -- Add items to the player's item list
    --for _, item in ipairs(items) do
		
		dataItem = {item, currentTime, itemSlotMod}
        table.insert(PlayersData[playerName].items, dataItem)
    --end
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
		
		print("Participation of all raid member increased")
		print(BubbleLoot_G.getNumberOfRaid().." number of raids so far !")
	else
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
			for index, value in ipairs(PlayersData[playerName].items) do
				print(value[1])
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
        PlayersData[playerName] = {
            items = {},
            participation = {0,0,0}
        }
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


-- function delet loot to player in database
function BubbleLoot_G.storage.DeletePlayerSpecificLoot(playerName, lootName)
	
	for index, lootData in ipairs(PlayersData[playerName].items) do
		if lootName == lootData[1] then
			--print(index)
			table.remove(PlayersData[playerName].items,index)
			return
		end
	end
	
	print("Function DeletePlayerSpecificLoot : "..playerName.." doesn't have "..lootName)


end





--[[


--]]

