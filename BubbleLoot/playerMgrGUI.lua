-- GUI elements and manipulation.
-- Populate `BubbleLoot_G.gui`.

--[[

player mgr windows

--]]

local cfg = BubbleLoot_G.configuration

-- Store references to UI elements for easy updating later
local playerRows = {}
local selectedPlayer = nil


-- Function to update the displayed player values
local function UpdatePlayerList()
    for playerName, playerData in pairs(PlayersData) do
        local row = playerRows[playerName]
        if row then
            row.playerScoreLabel:SetText(round2(BubbleLoot_G.calculation.GetPlayerScore(playerName), 1))
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
    BubbleLoot_G.gui.OpenBonusPanelGlobal(arg1)
end


-- Créer une frame principale
local function CreateSRItemFrame(playerName)
    local SRframe = CreateFrame("Frame", "ItemDisplayFrame", UIParent, "BasicFrameTemplateWithInset")
    SRframe:SetSize(300, 200)
    SRframe:SetPoint("CENTER")
	-- Background


    SRframe:EnableMouse(true)
    SRframe:SetMovable(true)
    SRframe:RegisterForDrag("LeftButton")
    SRframe:SetScript("OnDragStart", SRframe.StartMoving)
    SRframe:SetScript("OnDragStop", SRframe.StopMovingOrSizing)

    -- Titre de la frame
    -- Title of the frame
    SRframe.title = SRframe:CreateFontString(nil, "OVERLAY")
    SRframe.title:SetFontObject("GameFontHighlight")
    SRframe.title:SetPoint("CENTER", SRframe.TitleBg, "CENTER", 0, 0)
    SRframe.title:SetText("SR : "..playerName)

    local itemList
    -- Liste des items
    if SRData[playerName] then
         itemList = SRData[playerName][2]
    end

    if itemList ~= nil then 
        -- Créer des lignes pour chaque item
        for i, itemData in ipairs(itemList) do
            local itemName = itemData[2]
            local itemId = itemData[1]
            local itemNameBis, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = C_Item.GetItemInfo(itemId)


            local itemButton = CreateFrame("Button", "ItemButton"..i, SRframe)
            itemButton:SetPoint("TOPLEFT", 16, -40 - (i - 1) * 40)
            itemButton:SetSize(32, 32)
            if itemTexture then
                itemButton:SetNormalTexture(itemTexture)
            else
                itemButton:SetNormalTexture("Interface\\Icons\\INV_Misc_QuestionMark")
            end
            
            if itemLink then
                itemName = itemNameBis
                itemButton:SetScript("OnEnter", function(self)
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        GameTooltip:SetHyperlink(itemLink)
                        GameTooltip:Show()
                                    end)
                itemButton:SetScript("OnLeave", function()
                        GameTooltip:Hide()
                                end)
            else
                itemLink = itemName
            end

            local itemNameFontString = itemButton:CreateFontString(nil, "OVERLAY")
            itemNameFontString:SetFontObject("GameFontHighlight")
            itemNameFontString:SetPoint("LEFT", itemButton, "RIGHT", 4, 0)
            itemNameFontString:SetText(itemLink or "Unknown Item")


        end
    end

    return SRframe
end

local function OnClicklistSR(self, arg1)
    CreateSRItemFrame(arg1)
end


local function RemovePlayer(self, arg1)
    BubbleLoot_G.gui.RemovePlayerGlobal(arg1)
end


-- Create a StaticPopup dialog for confirmation

StaticPopupDialogs["CONFIRM_DELETE_PLAYER"] = {
    text = "Are you sure you want to delete %s?",
    button1 = "Confirm",
    button2 = "Cancel",
    OnAccept = function()
        -- Confirm was clicked, delete the player from the table
        BubbleLoot_G.storage.RemovePlayerGlobal(selectedPlayer)  
        BubbleLoot_G.gui.RefreshParticipationWindow()
        selectedPlayer = nil
    end,
    OnCancel = function()
        selectedPlayer = nil
        print("Player deletion canceled.")
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,  
}

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
        }, 
        {
            text = "Liste SR",
            func = OnClicklistSR,
            arg1 = playerName
        },  
    }

    if BubbleLoot_G.IsOfficier then
        table.insert(menuList, {
                                    text = cfg.texts.REMOVE_PLAYER, --WrapTextInColorCode("Remove player", cfg.colors[self.WARNING]),
                                    func = function()
                                        selectedPlayer = playerName -- Set the player you want to delete (as an example)
                                        StaticPopup_Show("CONFIRM_DELETE_PLAYER", selectedPlayer)
                                    end,            
                                }
                    )
    end

    
    EasyMenu(menuList, dropdown, "cursor", 0 , 0, "MENU")
end

function BubbleLoot_G.gui.CreateDropdownMenuGlobal(playerName)

    CreateDropdownMenu(playerName)

end



-- Create the main frame for the player list (initially hidden)
local playerMgrFrame = CreateFrame("Frame", "PlayerListFrame", UIParent, "BasicFrameTemplateWithInset")
playerMgrFrame:SetSize(500, 500)
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
playerMgrFrame.title:SetText(cfg.texts.PLAYERS_LIST)

-- Create a header frame to hold the non-scrollable header
local headerFrame = CreateFrame("Frame", nil, playerMgrFrame)
headerFrame:SetSize(400, 30)  -- Set a fixed height for the header
headerFrame:SetPoint("TOPLEFT", playerMgrFrame, "TOPLEFT", 10, -30)

-- Create header elements with precise positioning
local headerRow = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
headerRow:SetPoint("LEFT", headerFrame, "LEFT", 20, 0)
headerRow:SetText("Player")

local dataHeader0 = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
dataHeader0:SetPoint("LEFT", headerRow, "RIGHT", 80, 0)
dataHeader0:SetText("Score")
dataHeader0:SetJustifyH("CENTER")

local dataHeader1 = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
dataHeader1:SetPoint("LEFT", dataHeader0, "RIGHT", 60, 0)
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



-- Function to display the tooltip
local function ShowTooltip(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")  -- Attach the tooltip to the frame
    GameTooltip:SetText(cfg.texts.TOOLTIP_PLAYER_ROSTER, 1, 1, 1, 1, true)  -- Set the tooltip text
    GameTooltip:Show()  -- Show the tooltip
end

-- Function to hide the tooltip
local function HideTooltip(self)
    GameTooltip:Hide()  -- Hide the tooltip when the mouse leaves the frame
end

-- Attach the OnEnter and OnLeave scripts to the frame
playerMgrFrame:SetScript("OnEnter", ShowTooltip)  -- Show the tooltip on mouseover
playerMgrFrame:SetScript("OnLeave", HideTooltip)  -- Hide the tooltip when the mouse leaves



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
    local playerNameLabel = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    playerNameLabel:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 20, -30 * rowIndex + 20 )
    playerNameLabel:SetText(playerName)
	playerNameLabel:SetWidth(100)  -- Set a fixed width for alignment
    playerNameLabel:SetJustifyH("LEFT")  -- Align text to the left
    -- Add mouse click handler to show dropdown
    playerNameLabel:SetScript("OnMouseDown", function()
        CreateDropdownMenu(playerName)
    end)

    -- add player score
    local playerScore =round2(BubbleLoot_G.calculation.GetPlayerScore(playerName), 1)
    local playerScoreLabel = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    playerScoreLabel:SetPoint("LEFT", playerNameLabel, "RIGHT", 20, 0 )
    playerScoreLabel:SetText(playerScore)
	playerScoreLabel:SetWidth(100)  -- Set a fixed width for alignment
    playerScoreLabel:SetJustifyH("LEFT")  -- Align text to the left

    playerRows[playerName] = playerRows[playerName] or {}
    playerRows[playerName]["playerScoreLabel"] = playerScoreLabel

    -- Loop to create value labels and +/- buttons for each of the three numbers
    for i = 1, 3 do
        -- Value label
        local valueLabel = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        valueLabel:SetPoint("LEFT", playerScoreLabel, "RIGHT", 30 + (i - 1) * 80, 5)
        valueLabel:SetText(playerData.participation[i])
		valueLabel:SetJustifyH("CENTER")
        playerRows[playerName] = playerRows[playerName] or {}
        playerRows[playerName]["valueLabel" .. i] = valueLabel

        if BubbleLoot_G.IsOfficier then
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
        end


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





