-- GUI elements and manipulation.
-- Populate `BubbleLoot_G.gui`.

local cfg = BubbleLoot_G.configuration

-- Collection of { unit, need , score} to be used to show data rows.
BubbleLoot_G.gui.rowPool = {}

-- From "AARRGGBB" to { r, g, b, a } for values between 0 and 1.
local function hexColorToRGBA(hexString)
    local t = {}
    for c in hexString:gmatch ".." do
        table.insert(t, tonumber(c, 16) / 255)
    end
    return t[2], t[3], t[4], t[1]
end

--
function BubbleLoot_G.gui.Initialize(self)
    -- MAIN_FRAME
    ---@class Frame : BackdropTemplate https://github.com/Ketho/vscode-wow-api/pull/29
    local mainFrame = CreateFrame("Frame", ("%s_MainFrame"):format(cfg.ADDON_NAME),
        UIParent, BackdropTemplateMixin and "BackdropTemplate")
    mainFrame:SetSize(cfg.size.FRAME_WIDTH, cfg.size.EMPTY_HEIGHT)
    mainFrame:SetPoint("CENTER", UIParent, 0, 0)
    -- Mouse
    mainFrame:SetMovable(true)
    mainFrame:EnableMouse(true)
    mainFrame:SetScript("OnMouseDown", function(self_mainFrame, event)
        if event == "LeftButton" then
            self_mainFrame:StartMoving();
        elseif event == "RightButton" then
            BubbleLoot_G.rollerCollection:Clear()
            BubbleLoot_G:Draw()
        end
    end)
    mainFrame:SetScript("OnMouseUp", function(self_mainFrame)
        self_mainFrame:StopMovingOrSizing()
    end)
    -- Background
    mainFrame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 3, top = 4, bottom = 3 },
    })
    mainFrame:SetBackdropColor(hexColorToRGBA(cfg.colors.BACKGROUND))
    self.mainFrame = mainFrame
    -- UNIT
    local unitHeader = mainFrame:CreateFontString(nil, "OVERLAY", "SystemFont_Small")
    unitHeader:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 5, -5) -- Offset right and down.
    unitHeader:SetHeight(cfg.size.ROW_HEIGHT)
    unitHeader:SetJustifyH("LEFT")
    unitHeader:SetJustifyV("TOP")
    unitHeader:SetText(cfg.texts.UNIT_HEADER)
    unitHeader:SetTextColor(hexColorToRGBA(cfg.colors.HEADER))
    self.unitHeader = unitHeader
    -- NEED
    local needHeader = mainFrame:CreateFontString(nil, "OVERLAY", "SystemFont_Small")
    needHeader:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -105, -5)
    needHeader:SetHeight(cfg.size.ROW_HEIGHT)
    needHeader:SetJustifyH("LEFT")
    needHeader:SetJustifyV("TOP")
    needHeader:SetTextColor(hexColorToRGBA(cfg.colors.HEADER))
    needHeader:SetText(cfg.texts.NEED_HEADER)
    self.needHeader = needHeader
	-- SCORE
    local scoreHeader = mainFrame:CreateFontString(nil, "OVERLAY", "SystemFont_Small")
    scoreHeader:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -60, -5)
    scoreHeader:SetHeight(cfg.size.ROW_HEIGHT)
    scoreHeader:SetJustifyH("LEFT")
    scoreHeader:SetJustifyV("TOP")
    scoreHeader:SetTextColor(hexColorToRGBA(cfg.colors.HEADER))
    scoreHeader:SetText(cfg.texts.SCORE_HEADER)
    self.scoreHeader = scoreHeader
	-- CHANCE
    local chanceHeader = mainFrame:CreateFontString(nil, "OVERLAY", "SystemFont_Small")
    chanceHeader:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -10, -5)
    chanceHeader:SetHeight(cfg.size.ROW_HEIGHT)
    chanceHeader:SetJustifyH("LEFT")
    chanceHeader:SetJustifyV("TOP")
    chanceHeader:SetTextColor(hexColorToRGBA(cfg.colors.HEADER))
    chanceHeader:SetText(cfg.texts.CHANCE_HEADER)
    self.chanceHeader = chanceHeader

    return unitHeader -- relativePoint
end

-- Handle FontStrings needed for listing rolling players.
-- Uses as few rows as possible (recycles the old ones).
-- Return i-th row (create if necessary). Zero gives headers.
function BubbleLoot_G.gui.GetRow(self, i)
    if i == 0 then
        return { unit = self.unitHeader, need = self.needHeader, score = self.scoreHeader, chance = self.chanceHeader }
    end

    local row = self.rowPool[i]
    if row then
        row.unit:Show()
        row.need:Show()
		row.score:Show()
		row.chance:Show()
    else
        local unit = self.mainFrame:CreateFontString(nil, "OVERLAY", "GameTooltipText")
        local need = self.mainFrame:CreateFontString(nil, "OVERLAY", "GameTooltipText")		
        local score = self.mainFrame:CreateFontString(nil, "OVERLAY", "GameTooltipText")
		local chance = self.mainFrame:CreateFontString(nil, "OVERLAY", "GameTooltipText")

        local parents = self:GetRow(i - 1)
        unit:SetPoint("TOPLEFT", parents.unit, "BOTTOMLEFT")
        need:SetPoint("TOPLEFT", parents.need, "BOTTOMLEFT")		
        score:SetPoint("TOPLEFT", parents.score, "BOTTOMLEFT")
		chance:SetPoint("TOPLEFT", parents.chance, "BOTTOMLEFT")

        unit:SetHeight(cfg.size.ROW_HEIGHT)
        need:SetHeight(cfg.size.ROW_HEIGHT)		
        score:SetHeight(cfg.size.ROW_HEIGHT)
		chance:SetHeight(cfg.size.ROW_HEIGHT)

        row = { unit = unit, need = need, score = score, chance = chance }
        tinsert(self.rowPool, row)
    end

    return row
end

-- Write character name and their need to the given row index. Skip `nil`.
function BubbleLoot_G.gui.WriteRow(self, i, unitText, needText, scoreText, chanceText)
    local row = self:GetRow(i)
    if unitText ~= nil then
        row.unit:SetText(unitText)
    end
    if needText ~= nil then		
		row.need:SetText(needText)
    end
	if scoreText ~= nil then		
		row.score:SetText(scoreText)
    end
	if chanceText ~= nil then		
		row.chance:SetText(chanceText)
    end
end

-- Hide all rows with index equal or greater than the parameter.
function BubbleLoot_G.gui.HideTailRows(self, fromIndex)
    while fromIndex <= #self.rowPool do
        local row = self:GetRow(fromIndex)
        row.unit:Hide()
        row.need:Hide()
		row.score:Hide()
		row.chance:Hide()
        fromIndex = fromIndex + 1
    end
end

-- Show or hide the GUI.
function BubbleLoot_G.gui.SetVisibility(self, bool)
    BubbleLootShown = bool
    self.mainFrame:SetShown(bool)
end

function BubbleLoot_G.gui.SetWidth(self, width)
    self.mainFrame:SetWidth(width)
end

function BubbleLoot_G.gui.SetHeight(self, height)
    self.mainFrame:SetHeight(height)
end



-- Function to give loot to the selected player
local function GiveLootToPlayer(lootSlot, playerName)
    -- Find the raid index for the player
    for i = 1, GetNumGroupMembers() do
        local name = GetRaidRosterInfo(i)
        if name == playerName then
            -- Assign the loot to the player
            GiveMasterLoot(lootSlot, i)
            --print("Gave loot from slot " .. lootSlot .. " to " .. playerName)
            return
        end
    end
    print("Player " .. playerName .. " not found in raid.")
end

-- Function to create the raid members list when right-clicking an item
function BubbleLoot_G.gui.ShowRaidMemberMenu(source, bag, slot, lootSlot)
	--print("test A")
	--print(source)
	--print(bag)
	--print(slot)
	--print(lootslot)
	--print(IsAltKeyDown())
    -- Check if the player is in a raid and holding Alt
	local test = false
    if IsAltKeyDown() and (IsInRaid() or test) then
        -- Get the item name based on the source (bag or loot window)
        local itemName
        if source == "bag" then
            local itemLink = C_Container and C_Container.GetContainerItemLink(bag, slot) or GetContainerItemLink(bag, slot)
            if itemLink then
                itemName = itemLink:match("%[(.+)%]") -- Extracts the item name from the link
            end
        elseif source == "loot" then
            local itemLink = GetLootSlotLink(lootSlot)
            if itemLink then
                itemName = itemLink:match("%[(.+)%]") -- Extracts the item name from the link
            end
        end
		
        -- Create the dropdown menu
        local dropdownMenu = CreateFrame("Frame", "MyAddonRaidMenu", UIParent, "UIDropDownMenuTemplate")

        -- Initialize the dropdown menu
        UIDropDownMenu_Initialize(dropdownMenu, function(self, level, menuList)
            if not level then return end
            
			
			if level == 1 then
			
				-- Add the "Bubble Loot" title at the top
                local info = UIDropDownMenu_CreateInfo()
                info.text = "Bubble Loot"
                info.isTitle = true -- This marks it as a title
                info.notCheckable = true -- This makes sure the title cannot be checked
                UIDropDownMenu_AddButton(info, level)
			
                -- Add a main menu entry called "All Raid"
                local info = UIDropDownMenu_CreateInfo()
                info.text = "All Raid"
                info.hasArrow = true -- This tells the menu item to create a submenu
                info.notCheckable = true
                info.menuList = "ALL_RAID_SUBMENU" -- Assigns a name to the submenu
                UIDropDownMenu_AddButton(info, level)
				-- Add a main menu entry called "+1 only"
                info = UIDropDownMenu_CreateInfo()
                info.text = "Only +1"
                info.hasArrow = true -- This tells the menu item to create a submenu
                info.notCheckable = true
                info.menuList = "MS_RAID_SUBMENU" -- Assigns a name to the submenu
                UIDropDownMenu_AddButton(info, level)
				
            elseif level == 2 then
				if menuList == "ALL_RAID_SUBMENU" then
					-- Loop through all raid members
					local N = GetNumGroupMembers()
					--N = 5
					for i = 1, N do
						local name, rank, subgroup, plevel, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i)
						--local name = "TEST"..i
						if name then
							-- Create a menu item for each raid member
							local info = UIDropDownMenu_CreateInfo()
							info.text = name
							info.func = function()
											if itemName then
												BubbleLoot_G.storage.AddPlayerData(name, itemName)
												if UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") then
													-- Send the message to the RAID_WARNING channel
													SendChatMessage(name.." has win "..itemName, "RAID_WARNING")
												else 
													SendChatMessage(name.." has win "..itemName, "RAID")
													-- print(name.." has win "..itemName)
													-- print("You must be a raid leader or assistant to send a raid warning.")
												end
												if source == "loot" and lootSlot then
												GiveLootToPlayer(lootSlot, name) -- Send the loot to the selected player
												end
											else
												print("ShowRaidMemberMenu : can't get the item name")
											end
										end
							UIDropDownMenu_AddButton(info, level)
						end
					end
				elseif menuList == "MS_RAID_SUBMENU" then
					-- Loop through all raid members
					local MS_Rollers = BubbleLoot_G.rollerCollection:getMS_Rollers()
					if MS_Rollers then
						local N = table.getn(MS_Rollers)
						for i = 1, N do
							--local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i)
							local name = MS_Rollers[i]
							if name then
								-- Create a menu item for each raid member
								local info = UIDropDownMenu_CreateInfo()
								info.text = name
								info.func = function()
												if itemName then
													BubbleLoot_G.storage.AddPlayerData(name, itemName)
													if UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") then
														-- Send the message to the RAID_WARNING channel
														SendChatMessage(name.." has win "..itemName, "RAID_WARNING")
													else 
														SendChatMessage(name.." has win "..itemName, "RAID")
														-- print(name.." has win "..itemName)
														-- print("You must be a raid leader or assistant to send a raid warning.")
													end
													if source == "loot" and lootSlot then
														GiveLootToPlayer(lootSlot, name) -- Send the loot to the selected player
													end
												else
													print("ShowRaidMemberMenu : can't get the item name")
												end
											end
								UIDropDownMenu_AddButton(info, level)
							end
						end
					end
				
				end
			end
			
        end) -- close UIDropDownMenu_Initialize

        -- Show the dropdown menu near the cursor
        ToggleDropDownMenu(1, nil, dropdownMenu, "cursor", 3, 3)
    end
end









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




function BubbleLoot_G.gui.OpenInputWindow()
--BubbleLoot_G.gui.createAttendanceFrame()
	frame:Show()
end













--[[

-- Function to create and display the input window
function BubbleLoot_G.gui.OpenInputWindow()
    -- Create the frame for the input window
    local inputWindow = CreateFrame("Frame", "ParticipationInputWindow", UIParent, "BasicFrameTemplateWithInset")
    inputWindow:SetSize(560, 160)  -- Width, Height
    inputWindow:SetPoint("CENTER", UIParent, "CENTER")  -- Position at the center of the screen

    -- Set the title for the frame
    inputWindow.title = inputWindow:CreateFontString(nil, "OVERLAY")
    inputWindow.title:SetFontObject("GameFontHighlightLarge")
    inputWindow.title:SetPoint("CENTER", inputWindow.TitleBg, "CENTER", 5, 0)
    inputWindow.title:SetText("Participation")

    -- Create the input box
    local inputBox = CreateFrame("EditBox", nil, inputWindow, "InputBoxTemplate")
    inputBox:SetSize(180, 30)  -- Width, Height
    inputBox:SetPoint("CENTER", inputWindow, "CENTER", 0, 20)  -- Center of the window
    inputBox:SetAutoFocus(true)  -- Automatically focus on the box when opened
    inputBox:SetMaxLetters(50)  -- Maximum number of characters allowed
	inputBox:SetText("Player name")
	
	
	-- Create a add attendance button
    local AddAttendanceButton = CreateFrame("Button", nil, inputWindow, "GameMenuButtonTemplate")
    AddAttendanceButton:SetSize(180, 30)  -- Width, Height
    AddAttendanceButton:SetPoint("BOTTOMLEFT", inputWindow, "BOTTOMLEFT", 10, 40)
    AddAttendanceButton:SetText("Add Attendance")
    AddAttendanceButton:SetNormalFontObject("GameFontNormal")
    AddAttendanceButton:SetHighlightFontObject("GameFontHighlight")
	
	-- Create a Remove attendance button
    local RemoveAttendanceButton = CreateFrame("Button", nil, inputWindow, "GameMenuButtonTemplate")
    RemoveAttendanceButton:SetSize(180, 30)  -- Width, Height
    RemoveAttendanceButton:SetPoint("BOTTOMLEFT", inputWindow, "BOTTOMLEFT", 10, 10)
    RemoveAttendanceButton:SetText("Remove Attendance")
    RemoveAttendanceButton:SetNormalFontObject("GameFontNormal")
    RemoveAttendanceButton:SetHighlightFontObject("GameFontHighlight")
    
	-- Create a add bench button
    local AddBenchButton = CreateFrame("Button", nil, inputWindow, "GameMenuButtonTemplate")
    AddBenchButton:SetSize(180, 30)  -- Width, Height
    AddBenchButton:SetPoint("BOTTOMLEFT", inputWindow, "BOTTOMLEFT", 190, 40)
    AddBenchButton:SetText("Add Bench")
    AddBenchButton:SetNormalFontObject("GameFontNormal")
    AddBenchButton:SetHighlightFontObject("GameFontHighlight")
	
	-- Create a Remove bench button
    local RemoveBenchButton = CreateFrame("Button", nil, inputWindow, "GameMenuButtonTemplate")
    RemoveBenchButton:SetSize(180, 30)  -- Width, Height
    RemoveBenchButton:SetPoint("BOTTOMLEFT", inputWindow, "BOTTOMLEFT", 190, 10)
    RemoveBenchButton:SetText("Remove Bench")
    RemoveBenchButton:SetNormalFontObject("GameFontNormal")
    RemoveBenchButton:SetHighlightFontObject("GameFontHighlight")
	
	-- Create a add absence button
    local AddAbsenceButton = CreateFrame("Button", nil, inputWindow, "GameMenuButtonTemplate")
    AddAbsenceButton:SetSize(180, 30)  -- Width, Height
    AddAbsenceButton:SetPoint("BOTTOMLEFT", inputWindow, "BOTTOMLEFT", 370, 40)
    AddAbsenceButton:SetText("Add Bench")
    AddAbsenceButton:SetNormalFontObject("GameFontNormal")
    AddAbsenceButton:SetHighlightFontObject("GameFontHighlight")
	
	-- Create a Remove absence button
    local RemoveAbsenceButton = CreateFrame("Button", nil, inputWindow, "GameMenuButtonTemplate")
    RemoveAbsenceButton:SetSize(180, 30)  -- Width, Height
    RemoveAbsenceButton:SetPoint("BOTTOMLEFT", inputWindow, "BOTTOMLEFT", 370, 10)
    RemoveAbsenceButton:SetText("Remove Bench")
    RemoveAbsenceButton:SetNormalFontObject("GameFontNormal")
    RemoveAbsenceButton:SetHighlightFontObject("GameFontHighlight")


    -- Define AddAttendanceButton button behavior
    AddAttendanceButton:SetScript("OnClick", function()
        local inputText = inputBox:GetText()
        print("Entered text:", inputText)  -- Print the input text to the chat window or handle as needed
        inputWindow:Hide()  -- Hide the window after confirmation
    end)

    -- Define close button behavior
    RemoveAttendanceButton:SetScript("OnClick", function()
        inputWindow:Hide()  -- Hide the window without saving
    end)

    -- Show the window
    inputWindow:Show()
end


--]]