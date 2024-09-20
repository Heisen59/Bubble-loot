-- GUI elements and manipulation.
-- Populate `BubbleLoot_G.gui`.

--[[

Attendance windows

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

-- Create the main frame for the player list (initially hidden)
local frame = CreateFrame("Frame", "PlayerListFrame", UIParent, "BasicFrameTemplateWithInset")
frame:SetSize(400, 500)
frame:SetPoint("CENTER")
frame:SetMovable(true)  -- Make the frame movable
frame:EnableMouse(true) -- Enable mouse interaction for moving
frame:RegisterForDrag("LeftButton") -- Register left-button dragging
frame:SetScript("OnDragStart", frame.StartMoving) -- Start moving on drag
frame:SetScript("OnDragStop", frame.StopMovingOrSizing) -- Stop moving on drag end
frame:Hide()  -- Start hidden until the toggle button is clicked

-- Title of the frame
frame.title = frame:CreateFontString(nil, "OVERLAY")
frame.title:SetFontObject("GameFontHighlight")
frame.title:SetPoint("CENTER", frame.TitleBg, "CENTER", 0, 0)
frame.title:SetText("Participation Manager")

-- Create a header frame to hold the non-scrollable header
local headerFrame = CreateFrame("Frame", nil, frame)
headerFrame:SetSize(400, 30)  -- Set a fixed height for the header
headerFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -30)

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

-- Create the scroll frame inside the main frame
local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", headerFrame, "BOTTOMLEFT", 0, -5)
scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 10)

-- Create the content frame that will hold all player rows
local contentFrame = CreateFrame("Frame", nil, scrollFrame)
contentFrame:SetSize(400, 1500)  -- Adjust height to fit a large number of players
scrollFrame:SetScrollChild(contentFrame)

-- Create the list of players
function BubbleLoot_G.gui.createAttendanceFrame()

-- Dynamically create player rows inside the content frame
local rowIndex = 0
for playerName, playerData in pairs(PlayersData) do
    rowIndex = rowIndex + 1
-- Player name label
    local nameLabel = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameLabel:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 20, -30 * rowIndex + 20 )
    nameLabel:SetText(playerName)
	nameLabel:SetWidth(100)  -- Set a fixed width for alignment
    nameLabel:SetJustifyH("LEFT")  -- Align text to the left

    -- Loop to create value labels and +/- buttons for each of the three numbers
    for i = 1, 3 do
        -- Value label
        local valueLabel = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        valueLabel:SetPoint("LEFT", nameLabel, "RIGHT", 30 + (i - 1) * 80, 5)
        valueLabel:SetText(playerData.participation[i])
		valueLabel:SetJustifyH("CENTER")
        playerRows[playerName] = playerRows[playerName] or {}
        playerRows[playerName]["valueLabel" .. i] = valueLabel

        -- Create "+" button
        local plusButton = CreateFrame("Button", nil, contentFrame, "UIPanelButtonTemplate")
        plusButton:SetSize(16, 16)  -- Reduce button size to 15
        plusButton:SetPoint("TOP", valueLabel, "BOTTOM", -8, 0)  -- Align horizontally
        plusButton:SetText("+")
        plusButton:SetScript("OnClick", function() IncrementPlayer(playerName, i) end)

        -- Create "-" button
        local minusButton = CreateFrame("Button", nil, contentFrame, "UIPanelButtonTemplate")
        minusButton:SetSize(16, 16)  -- Reduce button size to 15
        minusButton:SetPoint("LEFT", plusButton, "RIGHT", 0, 0)  -- Stack vertically below plus button
        minusButton:SetText("-")
        minusButton:SetScript("OnClick", function() DecrementPlayer(playerName, i) end)

        -- Store references to the buttons
        playerRows[playerName]["plusButton" .. i] = plusButton
        playerRows[playerName]["minusButton" .. i] = minusButton
    end
end

-- Update the player list on load
UpdatePlayerList()

end




function BubbleLoot_G.gui.OpenParticipationWindow()
	frame:Show()
end





