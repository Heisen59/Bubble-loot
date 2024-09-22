-- GUI elements and manipulation.
-- Populate `BubbleLoot_G.gui`.

--[[

player loots mgr windows

--]]
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

-- Function to handle dropdown selection for Loots and Bonus/Malus
local function OnClickRemove(self, arg1, arg2)
    print(arg2 .. ": removed")
	BubbleLoot_G.storage.DeletePlayerSpecificLoot(arg1, arg2)
	--UpdateLootsList(arg1)	
	BubbleLoot_G.gui.createLootsMgrFrame(arg1)
end

local function OnClickB(self, arg1)
    print(arg1 .. ": B clicked")
end

-- Function to create the dropdown menu for the player name
local function CreateLootDropdownMenu(playerName, lootName, lootId)
	--print("CreateLootDropdownMenu")
    local dropdown = CreateFrame("Frame", "PlayerDropdownMenu", UIParent, "UIDropDownMenuTemplate")
    local menuList = {
		{
            text = lootName,  -- loot's name as the header
            isTitle = true,  -- This makes the text non-clickable and acts as a title
            notCheckable = true,  -- Don't show a checkbox
        },
        {
            text = "Remove",
            func = OnClickRemove,
            arg1 = playerName, 
			arg2 = lootId
        },

    }
    
    EasyMenu(menuList, dropdown, "cursor", 0 , 0, "MENU")
end


local LastFrameLevelUsed = 0
local NumberOfPlayerFrame = 0

-- Create the list of players

function BubbleLoot_G.gui.createLootsMgrFrame(playerName)

    -- Clear previous frame if it exists
    if PlayerslootsFrame[playerName] ~= nil then
        PlayerslootsFrame[playerName]:Hide()
        PlayerslootsFrame[playerName] = nil        
    end
	
	NumberOfPlayerFrame = NumberOfPlayerFrame +1
	
    -- Create the main frame for the player list
    local lootsMgrFrame = CreateFrame("Frame", "lootsListFrame", UIParent, "BasicFrameTemplateWithInset")
    lootsMgrFrame:SetSize(800, 500)
    lootsMgrFrame:SetPoint("CENTER")
    lootsMgrFrame:SetMovable(true)
    lootsMgrFrame:EnableMouse(true)
    lootsMgrFrame:RegisterForDrag("LeftButton")
    lootsMgrFrame:SetScript("OnDragStart", lootsMgrFrame.StartMoving)
    lootsMgrFrame:SetScript("OnDragStop", lootsMgrFrame.StopMovingOrSizing)
    lootsMgrFrame:SetFrameStrata("HIGH")
    lootsMgrFrame:Hide()
	
	
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

    local headerRow = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    headerRow:SetPoint("LEFT", headerFrame, "LEFT", 20, 0)
    headerRow:SetText(playerName)

    local dataHeader1 = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    dataHeader1:SetPoint("LEFT", headerRow, "RIGHT", 50, 0)
    dataHeader1:SetText("Score : " .. playerScore)

    local dataHeader2 = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    dataHeader2:SetPoint("LEFT", dataHeader1, "RIGHT", 50, 0)
    dataHeader2:SetText("Items score : " .. itemPlayerScore)

    -- Create the scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", nil, lootsMgrFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", headerFrame, "BOTTOMLEFT", 0, -5)
    scrollFrame:SetPoint("BOTTOMRIGHT", lootsMgrFrame, "BOTTOMRIGHT", -30, 10)

    -- Content frame for items
    local contentFrame = CreateFrame("Frame", nil, scrollFrame)
    contentFrame:SetSize(800, 1500)
    scrollFrame:SetScrollChild(contentFrame)

    -- Create item rows
    local rowIndex = 0
    for lootId, lootData in pairs(PlayersData[playerName].items) do
        local itemLink = lootData[1]
        local lootDropDate = lootData[2]
		local itemName = itemLink:match("%[(.+)%]")
		itemName = "["..itemName.."]"
		
        rowIndex = rowIndex + 1
        
        -- Create the item label
        local itemLabel = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        itemLabel:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 20, -30 * rowIndex + 20)
        itemLabel:SetText(itemName)
		itemLabel:SetTextColor(getRGBItemLink(itemLink))
        itemLabel:SetWidth(400)
        itemLabel:SetJustifyH("LEFT")

        -- Set mouse click handler for the item label
		itemLabel:EnableMouse(true)
        itemLabel:SetScript("OnMouseUp", function(self, button)
            if button == "RightButton" then
				--print("Frame clicked : "..button)
                CreateLootDropdownMenu(playerName, itemLink, lootId)
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

        -- Create a value label
        local valueLabel = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        valueLabel:SetPoint("LEFT", itemLabel, "RIGHT", 30, 0)
        valueLabel:SetText(lootDropDate)
        valueLabel:SetJustifyH("CENTER")
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
    end)
end

--[[


function BubbleLoot_G.gui.createLootsMgrFrame(playerName)

local point, relativeTo, relativePoint, xOffset, yOffset
if PlayerslootsFrame[playerName] ~= nil then
	point, relativeTo, relativePoint, xOffset, yOffset = PlayerslootsFrame[playerName]:GetPoint()
	
	-- Hide the frame
	PlayerslootsFrame[playerName]:Hide()
	-- Remove the frame from its parent and delete it
	PlayerslootsFrame[playerName]:SetParent(nil)
	PlayerslootsFrame[playerName] = nil		
	
end


--local lootsRows = PlayerslootsRows[playerName]




-- Create the main frame for the player list (initially hidden)
local lootsMgrFrame = CreateFrame("Frame", "lootsListFrame", UIParent, "BasicFrameTemplateWithInset")
lootsMgrFrame:SetSize(800, 500)
lootsMgrFrame:SetPoint(point or "CENTER", relativeTo or UIParent , relativePoint or "CENTER", xOffset or 0, yOffset or 0)
lootsMgrFrame:SetMovable(true)  -- Make the frame movable
lootsMgrFrame:EnableMouse(true) -- Enable mouse interaction for moving
lootsMgrFrame:RegisterForDrag("LeftButton") -- Register left-button dragging
lootsMgrFrame:SetScript("OnDragStart", lootsMgrFrame.StartMoving) -- Start moving on drag
lootsMgrFrame:SetScript("OnDragStop", lootsMgrFrame.StopMovingOrSizing) -- Stop moving on drag end
lootsMgrFrame:Hide()  -- Start hidden until the toggle button is clicked
-- Set the frame to appear on top of other frames when dragged
lootsMgrFrame:SetFrameStrata("HIGH") -- This ensures the frame is on a high layer

-- When dragging starts, bring the frame to the top within its layer
local alreadyPutOnTop = false
lootsMgrFrame:SetScript("OnDragStart", function(self)
    self:StartMoving()
		if LastFrameLevelUsed ==0 then LastFrameLevelUsed = self:GetFrameLevel() end
    
	if not alreadyPutOnTop then
		LastFrameLevelUsed = LastFrameLevelUsed + 4
		self:SetFrameLevel(LastFrameLevelUsed) -- Bring the frame to the top of its current strata		
		alreadyPutOnTop = true
	end
end)

-- Title of the frame
lootsMgrFrame.title = lootsMgrFrame:CreateFontString(nil, "OVERLAY")
lootsMgrFrame.title:SetFontObject("GameFontHighlight")
lootsMgrFrame.title:SetPoint("CENTER", lootsMgrFrame.TitleBg, "CENTER", 0, 0)
lootsMgrFrame.title:SetText("Loots Manager")


-- Update the player list on load
--UpdateLootsList(playerName)


-- Create a header frame to hold the non-scrollable header
local headerFrame = CreateFrame("Frame", nil, lootsMgrFrame)
headerFrame:SetSize(800, 30)  -- Set a fixed height for the header
headerFrame:SetPoint("TOPLEFT", lootsMgrFrame, "TOPLEFT", 10, -30)

-- Create header elements with precise positioning
local playerScore = BubbleLoot_G.calculation.GetPlayerScore(playerName)
local itemPlayerScore = BubbleLoot_G.calculation.GetPlayerScore(playerName, true)

local headerRow = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
headerRow:SetPoint("LEFT", headerFrame, "LEFT", 20, 0)
headerRow:SetText(playerName)

local dataHeader1 = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
dataHeader1:SetPoint("LEFT", headerRow, "RIGHT", 50, 0)
dataHeader1:SetText("Score : "..playerScore)
dataHeader1:SetJustifyH("CENTER")

local dataHeader2 = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
dataHeader2:SetPoint("LEFT", dataHeader1, "RIGHT", 50, 0)
dataHeader2:SetText("Items score : "..itemPlayerScore)
dataHeader2:SetJustifyH("CENTER")

-- Create the scroll frame inside the main frame
local scrollFrame = CreateFrame("ScrollFrame", nil, lootsMgrFrame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", headerFrame, "BOTTOMLEFT", 0, -5)
scrollFrame:SetPoint("BOTTOMRIGHT", lootsMgrFrame, "BOTTOMRIGHT", -30, 10)

-- Create the content frame that will hold all player rows
local contentFrame = CreateFrame("Frame", nil, scrollFrame)
contentFrame:SetSize(800, 1500)  -- Adjust height to fit a large number of players
scrollFrame:SetScrollChild(contentFrame)

-- Dynamically create player rows inside the content frame
local rowIndex = 0
for lootId, lootData in pairs(PlayersData[playerName].items) do
	local itemLink = lootData[1]
	local lootDropDate = lootData[2]
	
	--print(itemLink)
	
    rowIndex = rowIndex + 1
-- Player name label
    local itemLabel = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    itemLabel:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 20, -30 * rowIndex + 20 )
    itemLabel:SetText(itemLink)
	itemLabel:SetWidth(400)  -- Set a fixed width for alignment
    itemLabel:SetJustifyH("LEFT")  -- Align text to the left
    -- Add mouse click handler to show dropdown
	itemLabel:EnableMouse(true)
    itemLabel:SetScript("OnMouseUp", function(self, button)
		print("SetScript OnMouseUp")
		if button == "RightButton" then
			CreateLootDropdownMenu(playerName, itemLink, lootId)
		end
    end)

    -- Loop to create value labels 
    for i = 1, 1 do
        -- Value label
        local valueLabel = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        valueLabel:SetPoint("LEFT", itemLabel, "RIGHT", 30 + (i - 1) * 80, 5)
        valueLabel:SetText(lootDropDate)
		valueLabel:SetJustifyH("CENTER")
        --lootsRows[itemName] = lootsRows[itemName] or {}
        --lootsRows[itemName]["valueLabel" .. i] = valueLabel

    end
end

	lootsMgrFrame:Show()
	
	-- Save the frame to be reset later
	PlayerslootsFrame[playerName] = lootsMgrFrame
	
	local CloseButton = lootsMgrFrame.CloseButton  -- Reference to the existing close button

-- Set the script for when the close button is clicked
	CloseButton:SetScript("OnClick", function(self)
		-- Hide the frame
		lootsMgrFrame:Hide()
		-- Remove the frame from its parent and delete it
		lootsMgrFrame:SetParent(nil)
		lootsMgrFrame = nil
	end)

end


--]]



function BubbleLoot_G.gui.OpenPlayerLootWindow(playerName)
	BubbleLoot_G.gui.createLootsMgrFrame(playerName, 0, 0)
	

	
--	lootsMgrFrame:Show()
end





