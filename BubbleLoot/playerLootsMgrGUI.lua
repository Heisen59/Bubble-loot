-- GUI elements and manipulation.
-- Populate `BubbleLoot_G.gui`.

--[[

player loots mgr windows

--]]

local cfg = BubbleLoot_G.configuration

-- Store references to UI elements for easy updating later
local PlayerslootsFrame = {}

-- helping function
local function HexToRGB(hex)
    local r = tonumber(hex:sub(1, 2), 16) / 255
    local g = tonumber(hex:sub(3, 4), 16) / 255
    local b = tonumber(hex:sub(5, 6), 16) / 255
    return r, g, b
end

local function getRGBItemLink(itemLink)
	local colorCode = itemLink:match("|c(%x%x%x%x%x%x%x%x)")
	local r, g, b
		if colorCode then
			return HexToRGB(colorCode:sub(3))  -- We skip the first two characters (ff) which represent the alpha
		end
end

-- Function to handle dropdown selection for Loots
local function OnClickRemove(self, arg1, arg2)
    --print(arg2 .. ": removed")
	local playerName = arg1
	local itemLink = arg2[1]
	local DateRemoveItem = arg2[2]
	BubbleLoot_G.storage.AddPlayerData(playerName, itemLink, nil, DateRemoveItem)
	--UpdateLootsList(arg1)	
	BubbleLoot_G.gui.createLootsMgrFrame(arg1)
end

-- Function to handle dropdown selection for Loots
local function OnClickAddItemToNewRaidList(self, arg1, arg2)
    --print(arg2 .. ": removed")
	local playerName = arg1
	local itemLink = arg2
	BubbleLoot_G.storage.AddItemToNewRaidList(itemLink)
	--UpdateLootsList(arg1)	
	BubbleLoot_G.gui.createLootsMgrFrame(playerName)
end

-- Function to handle dropdown selection for Loots
local function OnClickChangeNeed(self, arg1, arg2)
    --print(arg2 .. ": removed")
	local playerName = arg1
	local itemLink = arg2[1]
	local lootDate = arg2[2]
	BubbleLoot_G.storage.LootNeedToogle(playerName, itemLink, lootDate)
	--UpdateLootsList(arg1)	
	BubbleLoot_G.gui.createLootsMgrFrame(arg1)
end


local function makeTextDate(lootDropDate)

local durationInHours = BubbleLoot_G.calculation.GetDurationInHours(date("%d-%m-%Y à %H:%M:%S"), lootDropDate)

if durationInHours < 20 then
	return "Today"
end

if durationInHours < 164 then
	return "This week"
end

if durationInHours < 334 then
	return "The last two week"
end

return lootDropDate

end


-- Function to create the dropdown menu for the player name
local function CreateLootDropdownMenu(playerName, itemLink, lootId, lootDropDate, lootAttribType)
	--print("CreateLootDropdownMenu")

    local dropdown = CreateFrame("Frame", "PlayerDropdownMenu", UIParent, "UIDropDownMenuTemplate")
    local menuItems  = {{
            text = itemLink,  -- loot's name as the header
            isTitle = true,  -- This makes the text non-clickable and acts as a title
            notCheckable = true,  -- Don't show a checkbox
        				} }
			


	if BubbleLoot_G.IsOfficier then

		--table.insert(menuItems,{
		--	text = cfg.texts.LOOT_MOD_NEW_RAID,
		--	func = OnClickAddItemToNewRaidList,
		--	arg1 = playerName, 
		--	arg2 = itemLink,
		--})


		table.insert(menuItems,{
				text = cfg.texts.LOOT_REMOVE,
				func = OnClickRemove,
				arg1 = playerName, 
				arg2 = {itemLink, lootDropDate},
			})	

		
		table.insert(menuItems,{
				text = cfg.texts.LOOT_SET_MSOS,
				func = OnClickChangeNeed,
				arg1 = playerName, 
				arg2 = {itemLink, lootDropDate},
			} )

		
		table.insert(menuItems,		{
				text = cfg.texts.LOOT_GIVE,
				hasArrow = true,
				menuList = {}
			})
	end

    
	
	-- Populate the player list for the "Give to player" option
	local allPlayersListFromDB = BubbleLoot_G.storage.getAllPlayersFromDB()
	
	for _, RecevingPlayer in ipairs(allPlayersListFromDB) do
		table.insert(menuItems[4].menuList, {
			text = RecevingPlayer,
			func = function() 
					
					-- print("exchange function debug start")
					-- print(lootAttribType)
					
					-- print("exchange function debug end")
					-- let's add the item to the receiver
					BubbleLoot_G.storage.AddPlayerData(RecevingPlayer, itemLink, lootAttribType, cfg.texts.FORCE_ADD_STR..lootDropDate, true)
					
					-- let's remove the item to the donnor
					BubbleLoot_G.storage.AddPlayerData(playerName, itemLink, lootAttribType, lootDropDate, true)
					
					--BubbleLoot_G.storage.playerGiveLootToPlayer(playerName, RecevingPlayer, lootId, lootDropDate, lootAttribType)
					
					print(playerName.." gave " .. itemLink .. " to " .. RecevingPlayer)									
				end
		})
	end
    
    EasyMenu(menuItems, dropdown, "cursor", 0 , 0, "MENU")
end


local LastFrameLevelUsed = 0
local NumberOfPlayerFrame = 0
local LastPlayerLootTypeFilterUsed = {}


-- Create the list of players
function BubbleLoot_G.gui.createLootsMgrFrame(playerName, refresh)





LastPlayerLootTypeFilterUsed[playerName] = LastPlayerLootTypeFilterUsed[playerName] or 1

-- refresh only if already exist
if refresh==true and PlayerslootsFrame[playerName]==nil then
	return
end

    -- Clear previous frame if it exists
local point, relativeTo, relativePoint, xOffset, yOffset
if PlayerslootsFrame[playerName] ~= nil then
	point, relativeTo, relativePoint, xOffset, yOffset = PlayerslootsFrame[playerName]:GetPoint()
	
	-- Hide the frame
	PlayerslootsFrame[playerName]:Hide()
	-- Remove the frame from its parent and delete it
	PlayerslootsFrame[playerName]:SetParent(nil)
	PlayerslootsFrame[playerName] = nil		
	
end
	
	NumberOfPlayerFrame = NumberOfPlayerFrame +1
	
	-- Last deleted item
	local LastDeletedItemLink = BubbleLoot_G.storage.getLastDeletedItemLinkForPlayer(playerName)
	
	
	
    -- Create the main frame for the player list
    local lootsMgrFrame = CreateFrame("Frame", "lootsListFrame", UIParent, "BasicFrameTemplateWithInset")
    lootsMgrFrame:SetSize(850, 500)
	lootsMgrFrame:SetPoint(point or "CENTER", relativeTo or UIParent , relativePoint or "CENTER", xOffset or (20*NumberOfPlayerFrame), yOffset or (-20*NumberOfPlayerFrame))
    lootsMgrFrame:SetMovable(true)
    lootsMgrFrame:EnableMouse(true)
    lootsMgrFrame:RegisterForDrag("LeftButton")
    lootsMgrFrame:SetScript("OnDragStart", lootsMgrFrame.StartMoving)
    lootsMgrFrame:SetScript("OnDragStop", lootsMgrFrame.StopMovingOrSizing)
    lootsMgrFrame:SetFrameStrata("HIGH")
    lootsMgrFrame:Hide()
	LastFrameLevelUsed = LastFrameLevelUsed + 4 
	lootsMgrFrame:SetFrameLevel(LastFrameLevelUsed)
	
	--local alreadyPutOnTop = false
	lootsMgrFrame:SetScript("OnDragStart", function(self)
		self:StartMoving()
			if LastFrameLevelUsed ==0 then LastFrameLevelUsed = self:GetFrameLevel() end
		
		--if not alreadyPutOnTop then
			LastFrameLevelUsed = LastFrameLevelUsed + 4
			self:SetFrameLevel(LastFrameLevelUsed) -- Bring the frame to the top of its current strata		
			--alreadyPutOnTop = true
		--end
	end)

    -- Title of the frame
    lootsMgrFrame.title = lootsMgrFrame:CreateFontString(nil, "OVERLAY")
    lootsMgrFrame.title:SetFontObject("GameFontHighlight")
    lootsMgrFrame.title:SetPoint("CENTER", lootsMgrFrame.TitleBg, "CENTER", 0, 0)
    lootsMgrFrame.title:SetText("Loots Manager")
	
    -- Create a header frame to hold the non-scrollable header
    local headerFrame = CreateFrame("Frame", nil, lootsMgrFrame)
    headerFrame:SetSize(800, 30)
    headerFrame:SetPoint("TOPLEFT", lootsMgrFrame, "TOPLEFT", 10, -30)

    -- Header elements
    local playerScore = BubbleLoot_G.calculation.GetPlayerScore(playerName)
    local itemPlayerScore = BubbleLoot_G.calculation.GetPlayerScore(playerName, true)
	local playerBonus = BubbleLoot_G.calculation.GetPlayerBonus(playerName)

    local headerRow = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    headerRow:SetPoint("LEFT", headerFrame, "LEFT", 20, 0)
    headerRow:SetText(playerName)

	local dataHeader0 = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    dataHeader0:SetPoint("LEFT", headerRow, "RIGHT", 50, 0)
    dataHeader0:SetText("Bonus : " .. round2(playerBonus, 1))
	dataHeader0:SetSize(80, 30)

    local dataHeader1 = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    dataHeader1:SetPoint("LEFT", dataHeader0, "RIGHT", 50, 0)
    dataHeader1:SetText("Score : " .. round2(playerScore, 1))
	dataHeader1:SetSize(80, 30)

    local dataHeader2 = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    dataHeader2:SetPoint("LEFT", dataHeader1, "RIGHT", 50, 0)
    dataHeader2:SetText("Items score : " .. round2(itemPlayerScore, 1))
	dataHeader2:SetSize(120, 30)
	
	local dataHeader3 = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    dataHeader3:SetPoint("LEFT", dataHeader2, "RIGHT", -100, -35)
    dataHeader3:SetText("Date")
	
	local dataHeader4 = CreateFrame("Button", "ToggleMSOSButton", headerFrame, "UIPanelButtonTemplate") --headerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    dataHeader4:SetPoint("LEFT", dataHeader3, "RIGHT", 140, 0)
	dataHeader4:SetSize(60, 30)
    dataHeader4:SetText("MS/OS")
	-- Set mouse click handler for the item label
	dataHeader4:EnableMouse(true)
	dataHeader4:SetScript("OnMouseUp", function(self, button)
											if button == "LeftButton" then
												-- print(LastPlayerLootTypeFilterUsed[playerName])
												 if LastPlayerLootTypeFilterUsed[playerName] == 0 then
													LastPlayerLootTypeFilterUsed[playerName] = 1
												elseif LastPlayerLootTypeFilterUsed[playerName] ==1 then
													LastPlayerLootTypeFilterUsed[playerName] = 2
												else
													LastPlayerLootTypeFilterUsed[playerName] = 0
												end
												BubbleLoot_G.gui.createLootsMgrFrame(playerName)			
											end
										end)

	local dataHeader5 = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	dataHeader5:SetPoint("LEFT", dataHeader4, "RIGHT", 25, 0)
	dataHeader5:SetText(cfg.texts.ITEM_VALUE)

	
	if LastDeletedItemLink then
	
		local CancelButtonHeader3 = CreateFrame("Button", "CancelButton", headerFrame, "UIPanelButtonTemplate")
		CancelButtonHeader3:SetSize(200, 30)
		CancelButtonHeader3:SetPoint("LEFT", dataHeader2, "RIGHT", 30, 0)
		CancelButtonHeader3:SetText(LastDeletedItemLink) --("Cancel last deleted item")
		CancelButtonHeader3:EnableMouse(true)
		CancelButtonHeader3:Show()
		CancelButtonHeader3:SetScript("OnClick", function(self)
													BubbleLoot_G.storage.RestoreLastDeletedItemForPlayer(playerName)
													BubbleLoot_G.gui.createLootsMgrFrame(playerName)
												end)
		
		CancelButtonHeader3:SetScript("OnEnter", function(self)
											GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
											GameTooltip:SetText("Cancel Last Deleted Item")
											GameTooltip:Show()
										end)
		CancelButtonHeader3:SetScript("OnLeave", function(self)
											GameTooltip:Hide()
										end)										

		--local CancelItemLinkHeader4 = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		--CancelItemLinkHeader4:SetPoint("LEFT", CancelButtonHeader3, "RIGHT", 20, 0)
		--CancelItemLinkHeader4:SetText(LastDeletedItemLink)
		--CancelItemLinkHeader4:Show()
	
	end
	
	
    -- Create the scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", nil, lootsMgrFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", headerFrame, "BOTTOMLEFT", 0, -45)
    scrollFrame:SetPoint("BOTTOMRIGHT", lootsMgrFrame, "BOTTOMRIGHT", -30, 10)

    -- Content frame for items
    local contentFrame = CreateFrame("Frame", nil, scrollFrame)
    contentFrame:SetSize(800, 1500)
    scrollFrame:SetScrollChild(contentFrame)

    -- Create item rows
	-- sort item by date
	-- Sort the raids by date
-- Extract key-value pairs
	local sortedItems = {}
	for key, value in pairs(PlayersData[playerName].items) do
		table.insert(sortedItems, {key = key, value = value})
	end

   	table.sort(sortedItems, function(a,b) return BubbleLoot_G.calculation.ConvertToTimestamp(a.value[cfg.LOOTDATA][1][1])> BubbleLoot_G.calculation.ConvertToTimestamp(b.value[cfg.LOOTDATA][1][1]) end)

    local rowIndex = 0
    for _, keyValue in pairs(sortedItems) do
		local lootId = keyValue.key
		local itemData = keyValue.value
        local itemLink = itemData[cfg.ITEMLINK]
		local itemName = itemLink:match("%[(.+)%]")
		itemName = "["..itemName.."]"
        
		for i, lootData in ipairs(itemData[cfg.LOOTDATA]) do
			
			local continue = true
			
			if LastPlayerLootTypeFilterUsed[playerName] ~= 0 then
				if lootData[2] ~= LastPlayerLootTypeFilterUsed[playerName] then 
					continue = false
				end
			end
				
			if 	continue then 
			
				local lootDropDate = lootData[1] -- last date
				local lootDropDateText = makeTextDate(lootDropDate)
				local lootAttribType = lootData[2]
				
				-- print(lootAttribType)
				
				local MSOS = ""
				if lootData[2] == 1 then MSOS = "+1" else MSOS = "+2" end
				local multiplier = BubbleLoot_G.calculation.GetItemMultiplier(lootId)
				local itemScore = string.format("%.2f", multiplier*BubbleLoot_G.storage.getItemScoreFromDB(playerName, lootId)) 


				rowIndex = rowIndex + 1
				
				-- Create the item label
				local itemLabel = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
				itemLabel:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 20, -30 * rowIndex + 20)
				itemLabel:SetText(itemName)
				itemLabel:SetTextColor(getRGBItemLink(itemLink))
				itemLabel:SetWidth(300)
				itemLabel:SetJustifyH("LEFT")

				-- Set mouse click handler for the item label
				itemLabel:EnableMouse(true)
				itemLabel:SetScript("OnMouseUp", function(self, button)
					if button == "RightButton" then
						--print("Frame clicked : "..button)
						CreateLootDropdownMenu(playerName, itemLink, lootId, lootDropDate, lootAttribType)
					end
				end)
				itemLabel:SetScript("OnEnter", function(self)
					GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
					GameTooltip:SetHyperlink(itemLink)
					GameTooltip:Show()
				end)
				itemLabel:SetScript("OnLeave", function(self)
					GameTooltip:Hide()
				end)

				-- Create a date label
				local valueLabel = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
				valueLabel:SetPoint("LEFT", itemLabel, "RIGHT", 30, 0)
				valueLabel:SetText(lootDropDateText)
				valueLabel:SetJustifyH("CENTER")
				valueLabel:SetWidth(200)
				
							-- Create a date label
				local valueLabe2 = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
				valueLabe2:SetPoint("LEFT", valueLabel, "RIGHT", 70, 0)
				valueLabe2:SetText(MSOS)
				valueLabe2:SetJustifyH("CENTER")

				local valueLabe3 = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
				valueLabe3:SetPoint("LEFT", valueLabe2, "RIGHT", 70, 0)
				valueLabe3:SetText(itemScore)
				valueLabe3:SetJustifyH("CENTER")
				
			end
		end
			
    end

    -- Show the loot manager frame
    lootsMgrFrame:Show()
    PlayerslootsFrame[playerName] = lootsMgrFrame

    -- Close button functionality
    local CloseButton = lootsMgrFrame.CloseButton
    CloseButton:SetScript("OnClick", function(self)
        lootsMgrFrame:Hide()
        lootsMgrFrame:SetParent(nil)
        lootsMgrFrame = nil
		NumberOfPlayerFrame = NumberOfPlayerFrame-1
		if NumberOfPlayerFrame == 0 then LastFrameLevelUsed = 0 end
		
		-- Remove the frame from its parent and delete it
		PlayerslootsFrame[playerName] = nil	
		
    end)
end



function BubbleLoot_G.gui.OpenPlayerLootWindow(playerName)
	
	BubbleLoot_G.gui.createLootsMgrFrame(playerName, 0, 0)
	

	
--	lootsMgrFrame:Show()
end





