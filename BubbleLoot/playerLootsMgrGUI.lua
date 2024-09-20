-- GUI elements and manipulation.
-- Populate `BubbleLoot_G.gui`.

--[[

player loots mgr windows

--]]
-- Store references to UI elements for easy updating later
local PlayerslootsFrame = {}

local test = nil

-- Function to update the displayed player values
local function UpdateLootsList(playerName)

	print("UpdateLootsList")
	
	if PlayerslootsFrame[playerName] ~= nil then
		-- Hide the frame
		PlayerslootsFrame[playerName]:Hide()
		-- Remove the frame from its parent and delete it
		PlayerslootsFrame[playerName]:SetParent(nil)
		PlayerslootsFrame[playerName] = nil
	end
	
	BubbleLoot_G.gui.createLootsMgrFrame(playerName)
		
end

-- Function to handle dropdown selection for Loots and Bonus/Malus
local function OnClickRemove(self, arg1, arg2)
    print(arg2 .. ": removed")
	BubbleLoot_G.storage.DeletePlayerSpecificLoot(arg1, arg2)
	UpdateLootsList(arg1)	
end

local function OnClickB(self, arg1)
    print(arg1 .. ": B clicked")
end

-- Function to create the dropdown menu for the player name
local function CreateLootDropdownMenu(playerName, lootName)
    local dropdown = CreateFrame("Frame", "PlayerDropdownMenu", UIParent, "UIDropDownMenuTemplate")
    local menuList = {
		{
            text = lootName,  -- Player's name as the header
            isTitle = true,  -- This makes the text non-clickable and acts as a title
            notCheckable = true,  -- Don't show a checkbox
        },
        {
            text = "Remove",
            func = OnClickRemove,
            arg1 = playerName, 
			arg2 = lootName
        },

    }
    
    EasyMenu(menuList, dropdown, "cursor", 0 , 0, "MENU")
end


local LastFrameLevelUsed = 0

-- Create the list of players
function BubbleLoot_G.gui.createLootsMgrFrame(playerName)




local lootsRows = PlayerslootsRows[playerName]




-- Create the main frame for the player list (initially hidden)
local lootsMgrFrame = CreateFrame("Frame", "lootsListFrame", UIParent, "BasicFrameTemplateWithInset")
lootsMgrFrame:SetSize(800, 500)
lootsMgrFrame:SetPoint("CENTER")
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
local headerRow = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
headerRow:SetPoint("LEFT", headerFrame, "LEFT", 20, 0)
headerRow:SetText(playerName)

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
for index, lootData in ipairs(PlayersData[playerName].items) do
	local itemName = lootData[1]
	local lootDropDate = lootData[2]
    rowIndex = rowIndex + 1
-- Player name label
    local itemLabel = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    itemLabel:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 20, -30 * rowIndex + 20 )
    itemLabel:SetText(itemName)
	itemLabel:SetWidth(400)  -- Set a fixed width for alignment
    itemLabel:SetJustifyH("LEFT")  -- Align text to the left
    -- Add mouse click handler to show dropdown
    itemLabel:SetScript("OnMouseDown", function()
        CreateLootDropdownMenu(playerName, itemName)
    end)

    -- Loop to create value labels and +/- buttons for each of the three numbers
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

function BubbleLoot_G.gui.OpenPlayerLootWindow(playerName)
	BubbleLoot_G.gui.createLootsMgrFrame(playerName)
	

	
--	lootsMgrFrame:Show()
end





