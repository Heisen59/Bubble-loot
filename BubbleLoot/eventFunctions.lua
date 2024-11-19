-- Functions called on events defined in `BubbleLoot_G.eventFrames`.
-- Do not use `self` (`self ~= BubbleLoot_G.eventFunctions`)
-- Populate `BubbleLoot_G.eventFunctions`.

local cfg = BubbleLoot_G.configuration

local DroppedLoot = {

    ---@type boolean
    lootWindowIsOpened = false,

    ---@type table
    LootButtonItemLinkCache = {},
};

--[[

Compatibility option

]]--



-- Function to handle the Alt+Right-Click behavior

local function OnBagnonBagClick(self, button)
	if button == "RightButton" and IsAltKeyDown() then -- 
		local bag = self:GetBag()
		local slot = self:GetID()
		BubbleLoot_G.gui.ShowItemRaidMemberMenu("bag", bag, slot, nil)
    end
end


local function OnAdiBagsBagClick(self, button)
	if button == "RightButton" and IsAltKeyDown() then
		
		-- Attempt to retrieve the bag and slot information
		local bag = self.bagId or self.bag -- Trying both
		local slot = self.slotId or self.slot

		if bag and slot then
			BubbleLoot_G.gui.ShowItemRaidMemberMenu("bag", bag, slot, nil)
		else
			print("Error: Could not retrieve bag and slot information from AdiBags item button.")
		end
	end
end


-- Hook into bag slot right-click event
function HookBagItemRightClick()

    if Bagnon then
                -- Hook when Bagnon creates new item buttons
        hooksecurefunc(Bagnon.ItemSlot, "Update", function(itemButton)
                                                -- We can't use HookScript, so we handle clicks manually
                                                itemButton:EnableMouse(true)
                                                itemButton:SetScript("OnMouseDown", function(self, button)
                                                    OnBagnonBagClick(self, button)
                                                end)
                                            end)
        return
    end

    local AceAddon = LibStub:GetLibrary("AceAddon-3.0", true)
    if AceAddon then 
        local AdiBags = LibStub("AceAddon-3.0"):GetAddon("AdiBags", true)
        if AdiBags then
            -- Register message to listen for when item buttons are updated
            AdiBags:RegisterMessage("AdiBags_UpdateButton", function(event, itemButton)
                if itemButton then
                    itemButton:EnableMouse(true)
                    itemButton:SetScript("OnMouseDown", function(self, button)
                        OnAdiBagsBagClick(self, button)
                    end)
                end
            end)
        else
            --print("Error: AdiBags addon not found.")
        end
    end

-- default 
    for bag = 0, 4 do -- Loop over the 5 bags (0 = backpack, 1-4 = regular bags)
        local numSlots = GetContainerNumSlots(bag)
        for slot = 1, numSlots do
            local itemButton = _G["ContainerFrame"..(bag + 1).."Item"..slot]

            if itemButton then
                -- Hook into the original OnClick script of each item button in the bag
                itemButton:HookScript("OnMouseDown", function(self, button)
                    if button == "RightButton" and IsAltKeyDown() then -- 
                        -- Call the function to show the raid member menu
                        BubbleLoot_G.gui.ShowItemRaidMemberMenu("bag", bag, numSlots-slot+1, nil)
                    end
                end)
            end
        end
    end
	
end


-- Hook into loot window right-click event
function BubbleLoot_G.eventFunctions.HookLootItemRightClick()
    -- This function will set up the hooks for the loot buttons
    local function SetLootButtonHooks()
        for buttonIndex = 1, LOOTFRAME_NUMBUTTONS do --GetNumLootItems()
            local lootButton = getglobal("LootButton" .. buttonIndex);--_G["LootButton"..slot]

            if (lootButton
            and lootButton:IsVisible()
            and lootButton.slot)
            then
                -- Ensure we don't hook the same button multiple times
                --if not lootButton.hookAdded then
                    --lootButton.hookAdded = true -- Flag to avoid re-adding the hook
                --print("hook added on slot "..lootButton.slot)       
                    -- Hook into the original OnClick script of each loot button
                lootButton:HookScript("OnClick", function(self, button)
                                                    if button == "RightButton" and IsAltKeyDown() then
                                                        -- Call the function to show the raid member menu
                                                        BubbleLoot_G.gui.ShowItemRaidMemberMenu("loot", nil, nil, self.slot)
                                                    end
                                                end)
                --end
            end
        end
    end

    -- Also set hooks initially when the loot frame is created
    SetLootButtonHooks()
end

local function lootChanged()

    --print("loot changed function")
    

    if DroppedLoot.lootWindowIsOpened == false then
        return false
    end

    local lootChanged = false;
    for buttonIndex = 1, LOOTFRAME_NUMBUTTONS do
        local buttonName = "LootButton" .. buttonIndex;
        local Button = getglobal("LootButton" .. buttonIndex);
        local itemLink = "";

        if (Button
            and Button:IsVisible()
            and Button.slot
        ) then
            
            itemLink = GetLootSlotLink(Button.slot);

            if (itemLink == nil) then
                itemLink = "";
            end
        end

        if (DroppedLoot.LootButtonItemLinkCache[buttonName] ~= itemLink) then
            --print(itemLink)
            lootChanged = true;
        end

        DroppedLoot.LootButtonItemLinkCache[buttonName] = itemLink;
    end

    return lootChanged;
end


local function checkLootChange()

   -- print("checkLootChange function")

    if lootChanged() then
        --print("loot HAS changed")
        BubbleLoot_G.eventFunctions.lootWindowOpen()
    else
        if DroppedLoot.lootWindowIsOpened == true then
            --print("recheck later ")
            C_Timer.After(1, function() checkLootChange() end)
        --else
            --print("lootWindowIsOpened is closed")
        end
    end
end

function BubbleLoot_G.eventFunctions.lootWindowOpen()
    --print("lootWindowOpen function")
    DroppedLoot.lootWindowIsOpened = true;

    --lootChanged()

    C_Timer.After(1,function() checkLootChange() end)


    BubbleLoot_G.eventFunctions.HookLootItemRightClick()

    


end




-- ADDON_LOADED
function BubbleLoot_G.eventFunctions.OnLoad(self, event, addOnName)
    if addOnName == cfg.ADDON_NAME then
		--bprint("I'm in SetScript ADDON_LOADED")

        C_Timer.After(1,function()
            --print("Bubble loot : delayed function")
                BubbleLoot_G:Initialize()
        end
        )

        
		
		--print("BubbleLoot_G.eventFunctions.OnLoad")
		-- items Hooks
		C_Timer.After(2,function()
							--print("Bubble loot : delayed function")
							HookBagItemRightClick()
						end
		) -- Set up the hook for bag items after login

        C_Timer.After(3,function()
        --LootFrame:HookScript("OnShow", BubbleLoot_G.eventFunctions.HookLootItemRightClick) -- Set up the hook for loot items when the loot window appears
        LootFrame:HookScript("OnShow", BubbleLoot_G.eventFunctions.lootWindowOpen)
        LootFrame:HookScript("OnHide", function ()   DroppedLoot.lootWindowIsOpened = false;  end)
		
		-- attendance frame
		BubbleLoot_G.gui.createAttendanceFrame()
        end
        )
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
	if text:lower() == "+1" or string.find(text:lower(), "%+1") ~= nil then
        --print("+1 found")
		-- Perform some action, e.g., print a message to the player
        --print(playerName .. " has typed +1 in the chat!")
		BubbleLoot_G.rollerCollection:Save(name, 1)
        BubbleLoot_G:Draw()
    end
	if text:lower() == "+2" or string.find(text:lower(), "%+2") ~= nil then
        --print("point 4")
		-- Perform some action, e.g., print a message to the player
        --print(playerName .. " has typed +2 in the chat!")
		BubbleLoot_G.rollerCollection:Save(name, 2)
        BubbleLoot_G:Draw()
    end
	if text:lower() == "+3" or string.find(text:lower(), "%+3") ~= nil then
		BubbleLoot_G.rollerCollection:Save(name, 3)
		BubbleLoot_G:Draw()
    end
	
    --[[
	if event == "CHAT_MSG_RAID_WARNING" then
        -- Check if the message contains "Distribution de "
        if string.find(text, cfg.texts.LOOT_SEND) then
            -- Do something when the phrase is found
			BubbleLoot_G.rollerCollection:Clear()
			BubbleLoot_G:Draw()
            return
        end
    end
    ]]--
    if event == "CHAT_MSG_RAID" or event == "CHAT_MSG_RAID_LEADER" then
        --Check if the message contains ""Choisissez +1/+2/pass pour "
        if string.find(text,cfg.texts.LOOT_SEND_BIS_PATERN) then
            -- Do something when the phrase is found
			BubbleLoot_G.rollerCollection:Clear()
			BubbleLoot_G:Draw()
            BubbleLoot_G.gui:SetVisibility(true)
            return
        end
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
