-- GUI elements and manipulation.
-- Populate `BubbleLoot_G.gui`.

--[[

player mgr windows

--]]



-- Store references to UI elements for easy updating later
local playerRows = {}


-- Function to update the displayed player values
local function UpdatePlayerList()
    for playerName, playerData in pairs(PlayersData) do
        local row = playerRows[playerName]
        if row then
            row.valueLabel1:SetText(playerData.participation[1])
            row.valueLabel2:SetText(playerData.participation[2])
            row.valueLabel3:SetText(playerData.participation[3])
        end
    end
end


-- Function to increment the player's number
local function IncrementPlayer(playerName, index)
    PlayersData[playerName].participation[index] = PlayersData[playerName].participation[index] + 1
    UpdatePlayerList()
end

-- Function to decrement the player's number
local function DecrementPlayer(playerName, index)
	if PlayersData[playerName].participation[index] == 0 then return end
    PlayersData[playerName].participation[index] = PlayersData[playerName].participation[index] - 1
    UpdatePlayerList()
end

-- Function to handle dropdown selection for Loots and Bonus/Malus
local function OnClickLoots(self, arg1)
    --print(arg1 .. ": Loots clicked")
	BubbleLoot_G.gui.OpenPlayerLootWindow(arg1)
end

local function OnClickBonusMalus(self, arg1)
    print(arg1 .. ": Bonus/Malus clicked")
end

-- Function to create the dropdown menu for the player name
local function CreateDropdownMenu(playerName)
    local dropdown = CreateFrame("Frame", "PlayerDropdownMenu", UIParent, "UIDropDownMenuTemplate")
    local menuList = {
		{
            text = playerName,  -- Player's name as the header
            isTitle = true,  -- This makes the text non-clickable and acts as a title
            notCheckable = true,  -- Don't show a checkbox
        },
        {
            text = "Loots",
            func = OnClickLoots,
            arg1 = playerName
        },
        {
            text = "Bonus/Malus",
            func = OnClickBonusMalus,
            arg1 = playerName
        }
    }
    
    EasyMenu(menuList, dropdown, "cursor", 0 , 0, "MENU")
end



-- Create the main frame for the player list (initially hidden)
local playerMgrFrame = CreateFrame("Frame", "PlayerListFrame", UIParent, "BasicFrameTemplateWithInset")
playerMgrFrame:SetSize(400, 500)
playerMgrFrame:SetPoint("CENTER")
playerMgrFrame:SetMovable(true)  -- Make the frame movable
playerMgrFrame:EnableMouse(true) -- Enable mouse interaction for moving
playerMgrFrame:RegisterForDrag("LeftButton") -- Register left-button dragging
playerMgrFrame:SetScript("OnDragStart", playerMgrFrame.StartMoving) -- Start moving on drag
playerMgrFrame:SetScript("OnDragStop", playerMgrFrame.StopMovingOrSizing) -- Stop moving on drag end
playerMgrFrame:Hide()  -- Start hidden until the toggle button is clicked

-- Title of the frame
playerMgrFrame.title = playerMgrFrame:CreateFontString(nil, "OVERLAY")
playerMgrFrame.title:SetFontObject("GameFontHighlight")
playerMgrFrame.title:SetPoint("CENTER", playerMgrFrame.TitleBg, "CENTER", 0, 0)
playerMgrFrame.title:SetText("Participation Manager")

-- Create a header frame to hold the non-scrollable header
local headerFrame = CreateFrame("Frame", nil, playerMgrFrame)
headerFrame:SetSize(400, 30)  -- Set a fixed height for the header
headerFrame:SetPoint("TOPLEFT", playerMgrFrame, "TOPLEFT", 10, -30)

-- Create header elements with precise positioning
local headerRow = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
headerRow:SetPoint("LEFT", headerFrame, "LEFT", 20, 0)
headerRow:SetText("Player")

local dataHeader1 = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
dataHeader1:SetPoint("LEFT", headerRow, "RIGHT", 60, 0)
dataHeader1:SetText("Attendance")
dataHeader1:SetJustifyH("CENTER")

local dataHeader2 = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
dataHeader2:SetPoint("LEFT", dataHeader1, "RIGHT", 25, 0)
dataHeader2:SetText("Bench")
dataHeader2:SetJustifyH("CENTER")

local dataHeader3 = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
dataHeader3:SetPoint("LEFT", dataHeader2, "RIGHT", 35, 0)
dataHeader3:SetText("Absence")
dataHeader3:SetJustifyH("CENTER")


scrollFrame = nil
contentFrame = nil

-- Create the list of players
function BubbleLoot_G.gui.createAttendanceFrame(refresh)

if refresh == true and contentFrame~= nil and scrollFrame~= nil then

	UpdatePlayerList()

	contentFrame:Hide()
	contentFrame:SetParent(nil)
	contentFrame = nil
	
	scrollFrame:Hide()
	scrollFrame:SetParent(nil)
	scrollFrame = nil

	--return
end

-- Create the scroll frame inside the main frame
scrollFrame = CreateFrame("ScrollFrame", nil, playerMgrFrame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", headerFrame, "BOTTOMLEFT", 0, -5)
scrollFrame:SetPoint("BOTTOMRIGHT", playerMgrFrame, "BOTTOMRIGHT", -30, 10)

-- Create the content frame that will hold all player rows
contentFrame = CreateFrame("Frame", nil, scrollFrame)
contentFrame:SetSize(400, 1500)  -- Adjust height to fit a large number of players
scrollFrame:SetScrollChild(contentFrame)


-- sort PlayersData
			
local SortPlayersData = {}
for k in pairs(PlayersData) do
    table.insert(SortPlayersData, k)
end

table.sort(SortPlayersData)

-- Dynamically create player rows inside the content frame
local rowIndex = 0
for _, playerName in pairs(SortPlayersData) do

	playerData = PlayersData[playerName]

    rowIndex = rowIndex + 1
-- Player name label
    local nameLabel = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameLabel:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 20, -30 * rowIndex + 20 )
    nameLabel:SetText(playerName)
	nameLabel:SetWidth(100)  -- Set a fixed width for alignment
    nameLabel:SetJustifyH("LEFT")  -- Align text to the left
    -- Add mouse click handler to show dropdown
    nameLabel:SetScript("OnMouseDown", function()
        CreateDropdownMenu(playerName)
    end)

    -- Loop to create value labels and +/- buttons for each of the three numbers
    for i = 1, 3 do
        -- Value label
        local valueLabel = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        valueLabel:SetPoint("LEFT", nameLabel, "RIGHT", 30 + (i - 1) * 80, 5)
        valueLabel:SetText(playerData.participation[i])
		valueLabel:SetJustifyH("CENTER")
        playerRows[playerName] = playerRows[playerName] or {}
        playerRows[playerName]["valueLabel" .. i] = valueLabel

		-- Create "-" button
        local minusButton = CreateFrame("Button", nil, contentFrame, "UIPanelButtonTemplate")
        minusButton:SetSize(16, 16)  -- Reduce button size to 15
		minusButton:SetPoint("TOP", valueLabel, "BOTTOM", -8, 0)  -- Align horizontally
        minusButton:SetText("-")
        minusButton:SetScript("OnClick", function() DecrementPlayer(playerName, i) end)
	
        -- Create "+" button
        local plusButton = CreateFrame("Button", nil, contentFrame, "UIPanelButtonTemplate")
        plusButton:SetSize(16, 16)  -- Reduce button size to 15
        plusButton:SetPoint("LEFT", minusButton, "RIGHT", 0, 0)  -- Stack vertically below plus button
        plusButton:SetText("+")
        plusButton:SetScript("OnClick", function() IncrementPlayer(playerName, i) end)



        -- Store references to the buttons
        playerRows[playerName]["plusButton" .. i] = plusButton
        playerRows[playerName]["minusButton" .. i] = minusButton
    end
end

-- Update the player list on load
--UpdatePlayerList()

end


function BubbleLoot_G.gui.RefreshParticipationWindow()
	BubbleLoot_G.gui.createAttendanceFrame(true)
end


function BubbleLoot_G.gui.OpenParticipationWindow()
	playerMgrFrame:Show()
end





