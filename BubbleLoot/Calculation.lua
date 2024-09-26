-- misc calculation

local cfg = BubbleLoot_G.configuration


function BubbleLoot_G.calculation.GetPlayerItemList(playerName)

local lootList = BubbleLoot_G.storage.GetPlayerLootList(playerName)

 for index, value in pairs(lootList) do
        print(value[1].." at "..value[2].." in "..value[3])
    end


end

function BubbleLoot_G.calculation.GetPlayerScore(playerName, lootscore)

lootscore = lootscore or false;

--print("GetPlayerScore function")

local score = 0
--Check if player exist in database
if not BubbleLoot_G.storage.GetPlayerData(playerName, false) then return score end



-- First, get loot score
local lootList = BubbleLoot_G.storage.GetPlayerLootList(playerName)
	if(lootList) then
		for itemId, _ in pairs(lootList) do
			score = score +  BubbleLoot_G.calculation.GetItemScore(itemId)
		end
	end

if lootscore then return score end

-- Second, modify this loot score according to attendance
local participation = BubbleLoot_G.storage.GetPlayerParticipation(playerName)
	if(participation) then
		score = score - cfg.constant.ATTENDANCE_VALUE*participation[cfg.index.ATTENDANCE] - cfg.constant.BENCH_VALUE*participation[cfg.index.BENCH] + cfg.constant.NON_ATTENDANCE_VALUE*participation[cfg.index.NON_ATTENDANCE]
	end
	
-- Third : bonus/malus
-- TO DO 
	
return score

end

function BubbleLoot_G.calculation.GetItemScore(itemId)
	
	local ItemSlotMod = BubbleLoot_G.calculation.GetItemSlotMode(itemId)

	return ItemSlotMod
end

function BubbleLoot_G.calculation.GetItemSlotMode(itemId)

-- First, try to get item info using the item name
    local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc = GetItemInfo(itemId)
	
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
        }
		

	 if itemEquipLoc and itemName then
		local slotModValue = slotMod[itemEquipLoc]
		if slotModValue then
			return slotModValue
		else -- check if token
			itemEquipLoc = BubbleLoot_G.calculation.SearchToken(itemId)
			-- print(itemEquipLoc)
			slotModValue = slotMod[itemEquipLoc]
			if slotModValue then
				return slotModValue
			else
				print("GetItemSlotMode function : "..itemName.." doesn't have any slot mod")			
				return 0
			end
		end
	 else	
		if itemName then 
			print("GetItemSlotMode function : "..itemName.." doesn't have any itemEquipLoc")			
		else
			print("GetItemSlotMode function : should never enter here since working with item ID")
		end		
	 --[[
		slotModValue = slotMod[BubbleLoot_G.calculation.SearchToken(item)]
		if slotModValue then
			return slotModValue
		else
			return 0
		end
		--]]
	end
	
	return 0

end



function BubbleLoot_G.calculation.SearchToken(itemID)
	
	for tokenType, subListToken in pairs(cfg.tokens) do
	-- print(subListToken)
		for _, tokenID in ipairs(subListToken)do
			-- print(tokenType)
			if itemID == tokenID then
					--print(tokenType)
					--print(cfg.tokenLocation[tokenType])
					return tokenType		
			end
		end		
	end
	
	return "Not Found"


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

