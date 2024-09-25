-- Functions called on events defined in `BubbleLoot_G.eventFrames`.
-- Do not use `self` (`self ~= BubbleLoot_G.eventFunctions`)
-- Populate `BubbleLoot_G.eventFunctions`.

local cfg = BubbleLoot_G.configuration


--[[

Compatibility option

]]--

local GetContainerNumSlots, GetContainerItemLink, GetContainerItemCooldown, GetContainerItemInfo, GetItemCooldown, PickupContainerItem, ContainerIDToInventoryID
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





-- Hook into bag slot right-click event
function HookBagItemRightClick()
    for bag = 0, 4 do -- Loop over the 5 bags (0 = backpack, 1-4 = regular bags)
        local numSlots = GetContainerNumSlots(bag)
        for slot = 1, numSlots do
            local itemButton = _G["ContainerFrame"..(bag + 1).."Item"..slot]

            if itemButton then
                -- Hook into the original OnClick script of each item button in the bag
                itemButton:HookScript("OnMouseDown", function(self, button)
                    if button == "RightButton" and IsAltKeyDown() then -- 
                        -- Call the function to show the raid member menu
                        BubbleLoot_G.gui.ShowRaidMemberMenu("bag", bag, numSlots-slot+1, nil)
                    end
                end)
            end
        end
    end
end

-- Hook into loot window right-click event
function HookLootItemRightClick()
    for slot = 1, GetNumLootItems() do
        local lootButton = _G["LootButton"..slot]

        if lootButton then
            -- Hook into the original OnClick script of each loot button
            lootButton:HookScript("OnMouseDown", function(self, button)
                if button == "RightButton" and IsAltKeyDown() then --button == "RightButton" and
                    -- Call the function to show the raid member menu
                    BubbleLoot_G.gui.ShowRaidMemberMenu("loot", nil, nil, slot)
                end
            end)
        end
    end
end


-- ADDON_LOADED
function BubbleLoot_G.eventFunctions.OnLoad(self, event, addOnName)
    if addOnName == cfg.ADDON_NAME then
		--bprint("I'm in SetScript ADDON_LOADED")
        BubbleLoot_G:Initialize()
		
		-- items Hooks
		C_Timer.After(3,function()
							print("delayed function")
							HookBagItemRightClick()
						end
		) -- Set up the hook for bag items after login
        LootFrame:HookScript("OnShow", HookLootItemRightClick) -- Set up the hook for loot items when the loot window appears
		
		-- attendance frame
		BubbleLoot_G.gui.createAttendanceFrame()
    end
end

-- GROUP_JOINED
function BubbleLoot_G.eventFunctions.OnGroupJoined(self, event)
    BubbleLoot_G.eventFrames.RegisterChatEvents()
end

-- GROUP_LEFT
function BubbleLoot_G.eventFunctions.OnGroupLeft(self, event)
    BubbleLoot_G.eventFrames.UnregisterChatEvents()
end

-- GROUP_ROSTER_UPDATE
function BubbleLoot_G.eventFunctions.OnGroupUpdate(self, event)
    BubbleLoot_G.rollerCollection:UpdateGroup()
    BubbleLoot_G:Draw()
end

-- CHAT_MSG_EVENTS
-- Look for "pass" in the group channels.
function BubbleLoot_G.eventFunctions.OnChatMsg(self, event, text, playerName)
    local name, server = strsplit("-", playerName)
	--print("point 1")
    if text:lower() == "pass" then
		--print("point 2")
        BubbleLoot_G.rollerCollection:Save(name, 9)
        BubbleLoot_G:Draw()
    end
	if text:lower() == "+1" then
        --print("point 3")
		-- Perform some action, e.g., print a message to the player
        --print(playerName .. " has typed +1 in the chat!")
		BubbleLoot_G.rollerCollection:Save(name, 1)
        BubbleLoot_G:Draw()
    end
	if text:lower() == "+2" then
        --print("point 4")
		-- Perform some action, e.g., print a message to the player
        --print(playerName .. " has typed +2 in the chat!")
		BubbleLoot_G.rollerCollection:Save(name, 2)
        BubbleLoot_G:Draw()
    end
	if text:lower() == "+3" then
		BubbleLoot_G.rollerCollection:Save(name, 3)
		BubbleLoot_G:Draw()
    end
	
end

-- CHAT_MSG_SYSTEM
-- Look for "/roll" in system messages from ML
function BubbleLoot_G.eventFunctions.OnSystemMsg(self, event, text)
	
    if string.find(text, "obtient") ~= nil then
		local name, roll, minRoll, maxRoll = text:match("^(.+) obtient un (%d+) %((%d+)%-(%d+)%).$")

        minRoll = tonumber(minRoll)
        maxRoll = tonumber(maxRoll)
        if (minRoll == 1 and maxRoll == 100) then
			--print("test On sysMsg")
            BubbleLoot_G.rollerCollection:Save(name,nil, tonumber(roll))
            BubbleLoot_G:Draw()
        end
		
		if(minRoll == 1 and maxRoll == 10000 and name == UnitName("player")) then
			BubbleLoot_G.calculation.getTheWinner(tonumber(roll))
		end
		
    end
end
