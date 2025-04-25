-- GUI elements and manipulation.
-- Populate `BubbleLoot_G.gui`.

local cfg = BubbleLoot_G.configuration

--[[

Compatibility option

]]--



-- Collection of { unit, need , score} to be used to show data rows.
BubbleLoot_G.gui.rowPool = {}

BubbleLoot_G.CurrentlyRolledItemId = 0

local hooveringText = nil

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
    mainFrame:SetPoint("TOP", UIParent, "TOP", 0, -20)
    -- Mouse
    mainFrame:SetMovable(true)
    mainFrame:EnableMouse(true)
    mainFrame:SetScript("OnMouseDown", function(self_mainFrame, event)
        if event == "LeftButton" then
			if IsAltKeyDown() then
				RandomRoll(1, 10000)
			else
				self_mainFrame:StartMoving();
			end
        elseif event == "RightButton" and IsControlKeyDown() then
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


	-- ITEM ROLLED
    local itemHeader = mainFrame:CreateFontString(nil, "OVERLAY", "SystemFont_Small")
    itemHeader:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 5, -8) -- Offset right and down.
    itemHeader:SetHeight(cfg.size.ROW_HEIGHT)
    itemHeader:SetJustifyH("LEFT")
    itemHeader:SetJustifyV("TOP")
    itemHeader:SetText(cfg.texts.ITEM_HEADER)
    itemHeader:SetTextColor(hexColorToRGBA(cfg.colors.HEADER))
    self.itemHeader = itemHeader

	-- MS/OS/Pass button
	-- CrÃ©er les boutons Besoin, CupiditÃ© et Passe
	local buttons = {}
	local buttonNames = {"+1", "+2", "pass"}
	for i, name in ipairs(buttonNames) do
	   buttons[name] = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
	   buttons[name]:SetSize(40, 20)  -- Largeur, Hauteur
	   buttons[name]:SetText(name)
	   buttons[name]:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 50+ i  * 45, -8)
	   buttons[name]:SetScript("OnClick", function()  
			 -- Envoi du message dans le chat de raid
			 SendChatMessage(name, "RAID")
			 
			 --if name =="pass" then				mainFrame:Hide() end
			 if name =="+2" then				-- Send the command
				C_Timer.After(1, function()
									-- Open the Add/Edit panel in edit mode
									local editBox = ChatFrame1.editBox
									editBox:SetText("/rand") -- Set the command in the edit box
									editBox:Show() -- Make sure the edit box is shown
									editBox:SetFocus() -- Focus on the edit box
									-- Send the command
									ChatEdit_SendText(editBox) -- Sends the text as if Enter was pressed
								end)
	  		    end
	   end)
	end

	-- ITEM Rtext + icon

	-- CrÃ©er une texture pour l'icÃ´ne de l'objet
	local itemIcon = mainFrame:CreateTexture(nil, "ARTWORK")
	itemIcon:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 40, -8) -- Offset right and down.
	itemIcon:SetSize(45, 45)  -- Largeur, Hauteur
	self.itemIcon = itemIcon

	-- item text
	local itemText = mainFrame:CreateFontString(nil, "OVERLAY", "SystemFont_Small")
	itemText:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 95, -30) -- Offset right and down.
	itemText:SetHeight(cfg.size.ROW_HEIGHT)
	itemText:SetJustifyH("LEFT")
	itemText:SetJustifyV("TOP")
	itemText:SetTextColor(hexColorToRGBA(cfg.colors.HEADER))
	self.itemText = itemText

	BubbleLoot_G.gui.SetItemLinkHover(self)




	-- hide button
	local hideButton = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
	-- Create a FontString for text
	local texthide = hideButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	texthide:SetPoint("CENTER", hideButton, "CENTER")
	texthide:SetText("x")  -- Set your desired text here
	local textWidth = texthide:GetStringWidth()
	local textHeight = texthide:GetStringHeight()
	hideButton:SetSize(textWidth+20, textHeight+10)
	--rollButton:SetText(text)
	hideButton:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -8, -6)
	hideButton:SetScript("OnClick", function(self)
			BubbleLoot_G.gui:SetVisibility(false)
		end)

	if BubbleLoot_G.IsOfficier then
		local rollButton = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
		-- Create a FontString for text
		local text = rollButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		text:SetPoint("CENTER", rollButton, "CENTER")
		text:SetText(cfg.texts.ML_RAND)  -- Set your desired text here
		local textWidth = text:GetStringWidth()
		local textHeight = text:GetStringHeight()
		rollButton:SetSize(textWidth+20, textHeight+10)
		--rollButton:SetText(text)
		rollButton:SetPoint("TOPRIGHT", hideButton, "TOPLEFT", -3, 0)
		rollButton:SetScript("OnClick", function(self)
				-- Open the Add/Edit panel in edit mode
				local editBox = ChatFrame1.editBox
				editBox:SetText("/rand 10000") -- Set the command in the edit box
				editBox:Show() -- Make sure the edit box is shown
				editBox:SetFocus() -- Focus on the edit box
				-- Send the command
				ChatEdit_SendText(editBox) -- Sends the text as if Enter was pressed
			end)
	end

	local OffSetDown = -55

	-- UNIT
    local unitHeader = mainFrame:CreateFontString(nil, "OVERLAY", "SystemFont_Small")
    unitHeader:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 5, OffSetDown) -- Offset right and down.
    unitHeader:SetHeight(cfg.size.ROW_HEIGHT)
    unitHeader:SetJustifyH("LEFT")
    unitHeader:SetJustifyV("TOP")
    unitHeader:SetText(cfg.texts.UNIT_HEADER)
    unitHeader:SetTextColor(hexColorToRGBA(cfg.colors.HEADER))
    self.unitHeader = unitHeader

    -- ROLL
    local rollHeader = mainFrame:CreateFontString(nil, "OVERLAY", "SystemFont_Small")
    rollHeader:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -10, OffSetDown)
    rollHeader:SetHeight(cfg.size.ROW_HEIGHT)
    rollHeader:SetJustifyH("LEFT")
    rollHeader:SetJustifyV("TOP")
    rollHeader:SetTextColor(hexColorToRGBA(cfg.colors.HEADER))
    rollHeader:SetText(cfg.texts.ROLL_HEADER)
    self.rollHeader = rollHeader

	-- CHANCE
	local chanceHeader = mainFrame:CreateFontString(nil, "OVERLAY", "SystemFont_Small")
	chanceHeader:SetPoint("TOPRIGHT", rollHeader, "TOPLEFT", -10, 0)
	chanceHeader:SetHeight(cfg.size.ROW_HEIGHT)
	chanceHeader:SetJustifyH("LEFT")
	chanceHeader:SetJustifyV("TOP")
	chanceHeader:SetTextColor(hexColorToRGBA(cfg.colors.HEADER))
	chanceHeader:SetText(cfg.texts.CHANCE_HEADER)
	self.chanceHeader = chanceHeader

	-- SCORE
	local scoreHeader = mainFrame:CreateFontString(nil, "OVERLAY", "SystemFont_Small")
	scoreHeader:SetPoint("TOPRIGHT", chanceHeader, "TOPLEFT", -10, 0)
	scoreHeader:SetHeight(cfg.size.ROW_HEIGHT)
	scoreHeader:SetJustifyH("LEFT")
	scoreHeader:SetJustifyV("TOP")
	scoreHeader:SetTextColor(hexColorToRGBA(cfg.colors.HEADER))
	scoreHeader:SetText(cfg.texts.SCORE_HEADER)
	self.scoreHeader = scoreHeader

    -- NEED
    local needHeader = mainFrame:CreateFontString(nil, "OVERLAY", "SystemFont_Small")
    needHeader:SetPoint("TOPRIGHT", scoreHeader, "TOPLEFT", -10, 0)
    needHeader:SetHeight(cfg.size.ROW_HEIGHT)
    needHeader:SetJustifyH("LEFT")
    needHeader:SetJustifyV("TOP")
    needHeader:SetTextColor(hexColorToRGBA(cfg.colors.HEADER))
    needHeader:SetText(cfg.texts.NEED_HEADER)
    self.needHeader = needHeader

    return unitHeader -- relativePoint
end

-- Set item header 
function BubbleLoot_G.gui.setItemHeader(self, item)
	local name, _, _, _, _, _, _, _, _, icon = C_Item.GetItemInfo(item)
	self.itemIcon:SetTexture(icon)
	self.itemText:SetText(item)
	self.itemText:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
	hooveringText = item
	--print("Je suis dans setItemHeader")
end

function BubbleLoot_G.gui.SetItemLinkHover(self)
    if self.itemText and self.itemIcon then
        -- Fonction pour gérer le survol de la souris
        local function OnEnter(self)
            GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
            GameTooltip:SetHyperlink(hooveringText) --self.GetText())
            GameTooltip:Show()
        end

        -- Fonction pour gérer la sortie de la souris
        local function OnLeave(self)
            GameTooltip:Hide()
        end

        -- Associer les fonctions aux événements de survol
        self.itemText:SetScript("OnEnter", OnEnter)
        self.itemText:SetScript("OnLeave", OnLeave) 
		self.itemIcon:SetScript("OnEnter", OnEnter)
        self.itemIcon:SetScript("OnLeave", OnLeave) 
    end
end


-- Function to handle dropdown Remove player from rollerCollection
function BubbleLoot_G.gui.DemotePlayer(playerName, isFromBroadCast )
    -- print("OnClickRemovePlayer function" )
	
	-- BubbleLoot_G.rollerCollection:Save(playerName, 9)
	BubbleLoot_G.rollerCollection:Demote(playerName)
	BubbleLoot_G:Draw()

	-- send synchro
			-- Synchronisation functions
	-- Let's send the data to other players and the whitelist if not in raid			
	if isFromBroadCast == true then
	else			
		--TIme Stamp functions
		--print("Demote need player "..playerName)
		BubbleLoot_G.sync.BroadcastDataTable(cfg.SYNC_MSG.DEMOTE_PLAYER_NEED, playerName)
	end

end


-- Function to handle dropdown Remove player from rollerCollection
function OnClickDemotePlayer(self, playerName )
    -- print("OnClickRemovePlayer function" )
		BubbleLoot_G.gui.DemotePlayer(playerName, false )

end

-- Function to handle dropdown Send current to player
local function OnClickSendToPlayer(self, arg1)
    print("OnClickSendToPlayer function not implemented yet" )
	local playerName = arg1


end

-- Function to handle open the player loot pannel
local function OnClickOpenPlayerLootPannel(self, arg1)

	-- print("OnClickOpenPlayerLootPannel")
	BubbleLoot_G.gui.OpenPlayerLootWindow(arg1)
end

-- Handle the creation of dropdown menu to manage players need during the attribution.
local function CreateManageNeedDropdownMenu(playerName)
	
	local dropdown = CreateFrame("Frame", "ManageNeedDropdownMenu", UIParent, "UIDropDownMenuTemplate")
	local menuItems  = {
			{
				text = playerName,  -- loot's name as the header
				isTitle = true,  -- This makes the text non-clickable and acts as a title
				notCheckable = true,  -- Don't show a checkbox
			},
			{
				text = "Demote player need",
				func = OnClickDemotePlayer,
				arg1 = playerName,
			},
			{
				text = "Open loot pannel",
				func = OnClickOpenPlayerLootPannel,
				arg1 = playerName,
			}
		}
		
	EasyMenu(menuItems, dropdown, "cursor", 0 , 0, "MENU")
end





-- Handle FontStrings needed for listing rolling players.
-- Uses as few rows as possible (recycles the old ones).
-- Return i-th row (create if necessary). Zero gives headers.
function BubbleLoot_G.gui.GetRow(self, i)
    if i == 0 then
        return { unit = self.unitHeader, need = self.needHeader, score = self.scoreHeader, chance = self.chanceHeader, roll = self.rollHeader }
    end

    local row = self.rowPool[i]
    if row then
        row.unit:Show()
        row.need:Show()
		row.score:Show()
		row.chance:Show()
		row.roll:Show()
    else
        local unit = self.mainFrame:CreateFontString(nil, "OVERLAY", "GameTooltipText")
        local need = self.mainFrame:CreateFontString(nil, "OVERLAY", "GameTooltipText")		
        local score = self.mainFrame:CreateFontString(nil, "OVERLAY", "GameTooltipText")
		local chance = self.mainFrame:CreateFontString(nil, "OVERLAY", "GameTooltipText")
		local roll = self.mainFrame:CreateFontString(nil, "OVERLAY", "GameTooltipText")

        local parents = self:GetRow(i - 1)
        unit:SetPoint("TOPLEFT", parents.unit, "BOTTOMLEFT")
        need:SetPoint("TOP", parents.need, "BOTTOM")		
        score:SetPoint("TOP", parents.score, "BOTTOM")
		chance:SetPoint("TOP", parents.chance, "BOTTOM")
		roll:SetPoint("TOP", parents.roll, "BOTTOM")
	
        unit:SetHeight(cfg.size.ROW_HEIGHT)
        need:SetHeight(cfg.size.ROW_HEIGHT)		
        score:SetHeight(cfg.size.ROW_HEIGHT)
		chance:SetHeight(cfg.size.ROW_HEIGHT)
		roll:SetHeight(cfg.size.ROW_HEIGHT)

        row = { unit = unit, need = need, score = score, chance = chance, roll = roll }
        tinsert(self.rowPool, row)
    end

    return row
end

-- Write character name and their need to the given row index. Skip `nil`.
function BubbleLoot_G.gui.WriteRow(self, i, unitText, needText, scoreText, chanceText, rollText, rollerName)
    local row = self:GetRow(i)
    if unitText ~= nil then
        row.unit:SetText(unitText)
				-- Set mouse click handler for the item label
		row.unit:EnableMouse(true)
		row.unit:SetScript("OnMouseUp", function(self, button)
			if button == "RightButton" then
				-- print("Frame clicked : "..button)
				 CreateManageNeedDropdownMenu(rollerName)
			end
		end)
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
	if rollText ~= nil then		
		row.roll:SetText(rollText)
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
		row.roll:Hide()
        fromIndex = fromIndex + 1
    end
end

-- Show or hide the GUI.
function BubbleLoot_G.gui.SetVisibility(self, bool)
    BubbleLootData["SHOWN"] = bool
    self.mainFrame:SetShown(bool)
end

function BubbleLoot_G.gui.ToggleVisibility(self)
	BubbleLootData["SHOWN"] = not BubbleLootData["SHOWN"]
	self.mainFrame:SetShown(BubbleLootData["SHOWN"])
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
		local name = GetMasterLootCandidate(lootSlot, i)
		if name == playerName then
			-- Assign the loot to the player
			GiveMasterLoot(lootSlot, i)
			--print("Gave loot from slot " .. lootSlot .. " to " .. playerName)
			return
		end
	end
	print("Player " .. playerName .. " not found in raid.")
end	


-- countdown function
local function SendCountdownToRaidChat(itemLink)
    if IsInRaid() or true then  -- Ensure you're in a raid		

        local countdown = { "5", "4", "3", "2", "1" }
        local delay = 10  -- Start delay at 0 seconds
		local channel = "RAID" --"RAID" "SAY" RAID_WARNING

		--SendChatMessage("Now chose +1/+2/+3/pass for "..itemLink.." and /rand if +2/+3. You have "..(delay+5).."s !", channel)
		SendChatMessage(cfg.texts.LOOT_SEND..itemLink, "RAID_WARNING")-- "RAID_WARNING")
		SendChatMessage(cfg.texts.LOOT_SEND_BIS..itemLink.." et /rand si +2. Vous avez "..(delay+5).."s !", channel)
	
        -- Loop through the countdown table
        for i, number in ipairs(countdown) do
            C_Timer.After(delay, function()
                SendChatMessage(number, channel)
            end)
            delay = delay + 1  -- Increment delay for each number
        end

        -- Send "GO!" at the end of the countdown
        C_Timer.After(delay, function()
            SendChatMessage("Time's up!", channel)
        end)
    else		
        print("You are not in a raid group.")
    end
end


-- Function to attempt trading the item with the selected player
local function AttemptTradeWithPlayer(playerName, bag, slot)
	
    -- Check if the player is close enough to trade
    if CheckInteractDistance(playerName, 2) then
			
        -- Open trade window
        InitiateTrade(playerName)
        
		-- Pick up the item and place it in the trade window
		PickupContainerItem(bag, slot)  
		--ClickTradeButton(1) -- Put it in the first trade slot
        
    else
        print(playerName .. " is too far away to trade.")
    end
end

-- Main Attribution function
local MainAttributionFunction = function(itemLink, itemName, playerName, source, lootSlot, bag, slot, LootAttribType)		
	-- print("Je suis dans MainAttributionFunction with LootAttribType "..LootAttribType)
	if itemLink then
		BubbleLoot_G.storage.AddPlayerData(playerName, itemLink, LootAttribType)
		if UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") then
			-- Send the message to the RAID_WARNING channel
			SendChatMessage(playerName.." a gagné "..itemName, "RAID_WARNING")
		else 
			SendChatMessage(playerName.." a gagné "..itemName, "RAID")
			-- print("You must be a raid leader or assistant to send a raid warning.")
		end
		if source == "loot" and lootSlot then
			GiveLootToPlayer(lootSlot, playerName) -- Send the loot to the selected player
		end
		if source == "bag" and bag and slot then
			AttemptTradeWithPlayer(playerName, bag, slot)
		end
		
	else
		print("ShowItemRaidMemberMenu : can't get the item link")
	end
end


local function AddPlayerToItemAutoLoot(player, itemLink)
	--local itemName =itemLink:match("%[(.-)%]")
	local itemId = tonumber(itemLink:match("Hitem:(%d+)"))

	local oldPlayer = AutoLootData[itemId]
	if oldPlayer then print("Remplace "..oldPlayer.." par "..player.." pour l'item "..itemLink) else print("Ajout de "..player.." pour l'item "..itemLink) end

	AutoLootData[itemId] = player

end


local function RemovePlayerToAutoLoot(itemLink)

	
	local itemId = tonumber(itemLink:match("Hitem:(%d+)"))
	print(itemLink.." retiré de l'autoloot")
	AutoLootData[itemId] = nil
end

local function GetAutoLootInfoText(itemLink)

	local itemId = tonumber(itemLink:match("Hitem:(%d+)"))
	local player = AutoLootData[itemId]

	if player then 	return "Autoloot pour "..player else return "Pas d'AutoLoot" end

end

-- Function to create the raid members list when right-clicking an item
function BubbleLoot_G.gui.ShowItemRaidMemberMenu(source, bag, slot, lootSlot)
	local LootAttribType = 0 -- 1=> MS / 2=> OS / 3 => DEZ
	
	--print("test A")
	--print(source)
	--print(bag)
	--print(slot)
	--print(lootslot)
	--print(IsAltKeyDown())
    -- Check if the player is in a raid and holding Alt
	local test = true
    if IsInRaid() or test then
        -- Get the item name based on the source (bag or loot window)
        local itemName
		local itemID
		local itemLink 
        if source == "bag" then
            itemLink = GetContainerItemLink(bag, slot) 
        elseif source == "loot" then
            itemLink = GetLootSlotLink(lootSlot)
        end
	
		if itemLink then
			itemName = itemLink:match("%[(.+)%]") -- Extracts the item name from the link
			itemID = tonumber(string.match(itemLink, "item:(%d+):"))
		else
			return
		end
		
				
        -- Create the dropdown menu
        local dropdownMenu = CreateFrame("Frame", "MyAddonRaidMenu", UIParent, "UIDropDownMenuTemplate")

        -- Initialize the dropdown menu
        UIDropDownMenu_Initialize(dropdownMenu, function(self, level, menuList)
			
            if not level then return end
            
			
			if level == 1 then
			
				-- Add the "Bubble Loot" title at the top
                local info = UIDropDownMenu_CreateInfo()
                info.text = itemLink
                info.isTitle = true -- This marks it as a title
                info.notCheckable = true -- This makes sure the title cannot be checked
                UIDropDownMenu_AddButton(info, level)
								
				-- Add a main menu entry called Proposer au raid
                info = UIDropDownMenu_CreateInfo()
                info.text = "Proposer au raid"
                info.hasArrow = false -- This tells the menu item to create a submenu
                info.notCheckable = false
				info.func = function()
								--BubbleLoot_G.rollerCollection:Clear()
								-- BubbleLoot_G:Draw()
								SendCountdownToRaidChat(itemLink)
							end
                UIDropDownMenu_AddButton(info, level)
				
								
				-- Add main menu entry called +1
				info = UIDropDownMenu_CreateInfo()
                info.text = "+1"
                info.hasArrow = true -- This tells the menu item to create a submenu
                info.notCheckable = true
                info.menuList = "MS_SUBMENU" -- Assigns a name to the submenu
                UIDropDownMenu_AddButton(info, level)
				
				-- Add main menu entry called +2
				info = UIDropDownMenu_CreateInfo()
                info.text = "+2"
                info.hasArrow = true -- This tells the menu item to create a submenu
                info.notCheckable = true
                info.menuList = "OS_SUBMENU" -- Assigns a name to the submenu
                UIDropDownMenu_AddButton(info, level)

				-- Add main menu entry called autoloot
				info = UIDropDownMenu_CreateInfo()
				info.text = "autoloot"
				info.hasArrow = true -- This tells the menu item to create a submenu
				info.notCheckable = true
				info.menuList = "AUTOLOOT_SUBMENU" -- Assigns a name to the submenu
				UIDropDownMenu_AddButton(info, level)
				
				-- Add main menu entry called dez
				--[[
				info = UIDropDownMenu_CreateInfo()
                info.text = "dez"
                info.hasArrow = true -- This tells the menu item to create a submenu
                info.notCheckable = true
                info.menuList = "DEZ_SUBMENU" -- Assigns a name to the submenu
                UIDropDownMenu_AddButton(info, level)
				--]]
				
			elseif level == 2 then
				if menuList == "MS_SUBMENU" then
					LootAttribType = 1
					
					--Add Title +1
					local info = UIDropDownMenu_CreateInfo()
					info.text = "+1"
					info.isTitle = true -- This marks it as a title
					info.notCheckable = true -- This makes sure the title cannot be checked
					UIDropDownMenu_AddButton(info, level)
					
					
					-- Add a main menu entry called "All Raid"
					info = UIDropDownMenu_CreateInfo()
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
					info.menuList = "MS_ONLY_RAID_SUBMENU" -- Assigns a name to the submenu
					UIDropDownMenu_AddButton(info, level)
				
				elseif menuList == "OS_SUBMENU" then
					LootAttribType = 2
					
					--Add Title +2					
					local info = UIDropDownMenu_CreateInfo()
					info.text = "+2"
					info.isTitle = true -- This marks it as a title
					info.notCheckable = true -- This makes sure the title cannot be checked
					UIDropDownMenu_AddButton(info, level)
					
					-- Add a main menu entry called "All Raid"
					info = UIDropDownMenu_CreateInfo()
					info.text = "All Raid"
					info.hasArrow = true -- This tells the menu item to create a submenu
					info.notCheckable = true
					info.menuList = "ALL_RAID_SUBMENU" -- Assigns a name to the submenu
					UIDropDownMenu_AddButton(info, level)
					-- Add a main menu entry called "+1 only"
					info = UIDropDownMenu_CreateInfo()
					info.text = "Only +2"
					info.hasArrow = true -- This tells the menu item to create a submenu
					info.notCheckable = true
					info.menuList = "MS_ONLY_RAID_SUBMENU" -- Assigns a name to the submenu
					UIDropDownMenu_AddButton(info, level)
				elseif menuList == "AUTOLOOT_SUBMENU" then
					
					
					--Add Title +2					
					local info = UIDropDownMenu_CreateInfo()
					info.text = GetAutoLootInfoText(itemLink)
					info.isTitle = true -- This marks it as a title
					info.notCheckable = true -- This makes sure the title cannot be checked
					UIDropDownMenu_AddButton(info, level)
					
					-- Add a main menu entry called "All Raid"
					info = UIDropDownMenu_CreateInfo()
					info.text = "Choisir joueur"
					info.hasArrow = true -- This tells the menu item to create a submenu
					info.notCheckable = true
					info.menuList = "ALL_RAID_SUBMENU_AUTOLOOT" -- Assigns a name to the submenu
					UIDropDownMenu_AddButton(info, level)

					-- Add a main menu entry called "effacer"
					info = UIDropDownMenu_CreateInfo()
					info.text = "Effacer"
					info.hasArrow = false -- This tells the menu item to create a submenu
					info.notCheckable = false
					info.func = function() RemovePlayerToAutoLoot(itemLink)	end -- add function to clear the item from the autoloot data
					UIDropDownMenu_AddButton(info, level)
				--[[
				elseif menuList == "DEZ_SUBMENU" then
					LootAttribType = 3
					print("LootAttribType "..LootAttribType)
					-- Add a main menu entry called "All Raid"
					info = UIDropDownMenu_CreateInfo()
					info.text = "All Raid"
					info.hasArrow = true -- This tells the menu item to create a submenu
					info.notCheckable = true
					info.menuList = "ALL_RAID_SUBMENU" -- Assigns a name to the submenu
					UIDropDownMenu_AddButton(info, level)
					-- Add a main menu entry called "+1 only"
					info = UIDropDownMenu_CreateInfo()
					info.text = "Only +2"
					info.hasArrow = true -- This tells the menu item to create a submenu
					info.notCheckable = true
					info.menuList = "MS_ONLY_RAID_SUBMENU" -- Assigns a name to the submenu
					UIDropDownMenu_AddButton(info, level)
					--]]
				end
				
            elseif level == 3 then
				if menuList == "ALL_RAID_SUBMENU" then
					-- Loop through all raid members
					local N = GetNumGroupMembers()
					--N = 5
					for i = 1, N do
						local playerName, rank, subgroup, plevel, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i)
						--local playerName = "TEST"..i
						if playerName then
							-- Create a menu item for each raid member
							local info = UIDropDownMenu_CreateInfo()
							info.text = playerName
							info.func = function()	MainAttributionFunction(itemLink, itemName, playerName, source, lootSlot, bag, slot, LootAttribType) end
							UIDropDownMenu_AddButton(info, level)
						end
					end
				elseif menuList == "MS_ONLY_RAID_SUBMENU" then
					-- Loop through all raid members
					local MS_Rollers = BubbleLoot_G.rollerCollection:get_Rollers()
					if MS_Rollers then
						for _, playerName in ipairs(MS_Rollers) do
							if playerName then
								-- Create a menu item for each raid member
								local info = UIDropDownMenu_CreateInfo()
								info.text = playerName
								info.func = function() MainAttributionFunction(itemLink, itemName, playerName, source, lootSlot, bag, slot, LootAttribType)	end											
								UIDropDownMenu_AddButton(info, level)
							end
						end
					end
				elseif menuList == "ALL_RAID_SUBMENU_AUTOLOOT" then
					
					-- Loop through all raid members
					local N = GetNumGroupMembers()
					--N = 5
					for i = 1, N do
						local playerName, rank, subgroup, plevel, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i)
						--local playerName = "TEST"..i
						if playerName then
							-- Create a menu item for each raid member
							local info = UIDropDownMenu_CreateInfo()
							info.text = playerName
							info.func = function() print(itemLink)	AddPlayerToItemAutoLoot(playerName, itemLink) end -- Add function to add this player to the item autoloot
							UIDropDownMenu_AddButton(info, level)
						end
					end			
				end
			end			
        end) -- close UIDropDownMenu_Initialize

        -- Show the dropdown menu near the cursor
        ToggleDropDownMenu(1, nil, dropdownMenu, "cursor", 3, 3)
    end
end









