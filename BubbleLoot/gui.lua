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


-- Function to create the raid members list when right-clicking an item
function BubbleLoot_G.gui.ShowRaidMemberMenu(source, bag, slot, lootSlot)
	--print("test A")
	--print(source)
	--print(bag)
	--print(slot)
	--print(lootslot)
	--print(IsAltKeyDown())
    -- Check if the player is in a raid and holding Alt
	local test = true
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
					N = 5
					for i = 1, N do
						--local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i)
						local name = "TEST"..i
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