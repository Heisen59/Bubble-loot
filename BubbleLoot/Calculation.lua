-- misc calculation

local cfg = BubbleLoot_G.configuration


function BubbleLoot_G.calculation.GetPlayerItemList(playerName)

local lootList = BubbleLoot_G.storage.GetPlayerLootList(playerName)

 for index, value in ipairs(lootList) do
        print("Item " .. index .. ": " .. value)
    end


end

function BubbleLoot_G.calculation.GetPlayerScore(playerName)

local score = 0
--Check if player exist in database
if not BubbleLoot_G.storage.GetPlayerData(playerName, false) then return score end

-- First, get loot score
local lootList = BubbleLoot_G.storage.GetPlayerLootList(playerName)
	if(lootList) then
		for index, value in ipairs(lootList) do
			local itemName = GetItemInfo(value[1])
			if(itemName) then
				score = score +  BubbleLoot_G.calculation.GetItemScore(itemName)
			end
		end
	end

-- Second, modify this loot score according to attendance
local participation = BubbleLoot_G.storage.GetPlayerParticipation(playerName)
	if(participation) then
		score = score - cfg.constant.ATTENDANCE_VALUE*participation[cfg.index.ATTENDANCE] - cfg.constant.BENCH_VALUE*participation[cfg.index.BENCH] + cfg.constant.NON_ATTENDANCE_VALUE*participation[cfg.index.NON_ATTENDANCE]
	end
	
return score

end

function BubbleLoot_G.calculation.GetItemScore(item)

-- First, try to get item info using the item name
    local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc = GetItemInfo(item)

	 if itemEquipLoc and itemName then
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
		return slotMod[itemEquipLoc]
	 else
		return 0
	end

end

-- Function to get item equip location and ilevel
function BubbleLoot_G.calculation.GetItem(item)
		--print(item)
-- First, try to get item info using the item name
    local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc = GetItemInfo(item)

	
-- Check if the item was found
    if itemEquipLoc and itemName then
	        -- Use WoW's global table to translate the equip location code to a human-readable string
        local equipLocations = {
            ["INVTYPE_HEAD"] = "Head",
            ["INVTYPE_NECK"] = "Neck",
            ["INVTYPE_SHOULDER"] = "Shoulder",
            ["INVTYPE_BODY"] = "Shirt",
            ["INVTYPE_CHEST"] = "Chest",
            ["INVTYPE_ROBE"] = "Chest (Robe)",
            ["INVTYPE_WAIST"] = "Waist",
            ["INVTYPE_LEGS"] = "Legs",
            ["INVTYPE_FEET"] = "Feet",
            ["INVTYPE_WRIST"] = "Wrist",
            ["INVTYPE_HAND"] = "Hands",
            ["INVTYPE_FINGER"] = "Finger",
            ["INVTYPE_TRINKET"] = "Trinket",
            ["INVTYPE_CLOAK"] = "Back",
            ["INVTYPE_WEAPON"] = "One-Hand Weapon",
            ["INVTYPE_SHIELD"] = "Off-Hand Shield",
            ["INVTYPE_2HWEAPON"] = "Two-Hand Weapon",
            ["INVTYPE_WEAPONMAINHAND"] = "Main Hand Weapon",
            ["INVTYPE_WEAPONOFFHAND"] = "Off-Hand Weapon",
            ["INVTYPE_HOLDABLE"] = "Held in Off-Hand",
            ["INVTYPE_RANGED"] = "Ranged Weapon",
            ["INVTYPE_THROWN"] = "Thrown Weapon",
            ["INVTYPE_RANGEDRIGHT"] = "Ranged Weapon",
            ["INVTYPE_RELIC"] = "Relic",
            ["INVTYPE_TABARD"] = "Tabard",
            ["INVTYPE_BAG"] = "Bag",
            ["INVTYPE_QUIVER"] = "Quiver",
        }
		
		        -- Get the human-readable equip location
        local equipLocString = equipLocations[itemEquipLoc]
		-- If a location was found, print it to the chat
        if equipLocString then
            DEFAULT_CHAT_FRAME:AddMessage(itemName .." (ilvl "..itemLevel..")" .." can be equipped in the " .. equipLocString .. " slot.")
        else
            DEFAULT_CHAT_FRAME:AddMessage("Equip location for " .. itemName .. " is unknown.")
        end
	else
	-- If the item wasn't found, inform the player
	DEFAULT_CHAT_FRAME:AddMessage("Item '" .. item .. "' not found.")
    end
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

	print("the winner is "..winner)


end

