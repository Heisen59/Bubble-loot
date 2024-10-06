-- Define EventFrames and connect them with OnEvent functions from `BubbleLoot_G.eventFunctions`.
-- Define register helper functions.
-- Populate `BubbleLoot_G.eventFrames`.

-- CREATE EVENT FRAMES

-- The first time saved variables are accessible (they are not while built-in onLoad is run).
local addonLoaded_EventFrame = CreateFrame("Frame")
addonLoaded_EventFrame:RegisterEvent("ADDON_LOADED")
addonLoaded_EventFrame:SetScript("OnEvent", BubbleLoot_G.eventFunctions.OnLoad)

-- At each bag update
--local addonBagUpdate_EventFrame = CreateFrame("Frame")
--addonBagUpdate_EventFrame:RegisterEvent("BAG_UPDATE_DELAYED")
--addonBagUpdate_EventFrame:SetScript("OnEvent", BubbleLoot_G.eventFunctions.OnBagUpdate)

-- The current player joins a group.
local groupJoin_EventFrame = CreateFrame("Frame")
groupJoin_EventFrame:RegisterEvent("GROUP_JOINED")
groupJoin_EventFrame:SetScript("OnEvent", BubbleLoot_G.eventFunctions.OnGroupJoined)

-- The current player left a group.
local groupJoin_EventFrame = CreateFrame("Frame")
groupJoin_EventFrame:RegisterEvent("GROUP_LEFT")
groupJoin_EventFrame:SetScript("OnEvent", BubbleLoot_G.eventFunctions.OnGroupLeft)

-- Group type changed, a player changed subgroup.
local groupUpdate_EventFrame = CreateFrame("Frame")
groupUpdate_EventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
groupUpdate_EventFrame:SetScript("OnEvent", BubbleLoot_G.eventFunctions.OnGroupUpdate)

-- Listen to CHAT_MSG_EVENTS for passing.
local passing_EventFrame = CreateFrame("Frame")
passing_EventFrame:SetScript("OnEvent", BubbleLoot_G.eventFunctions.OnChatMsg)

-- Listen to CHAT_MSG_SYSTEM event and catch /rolling.
local rolling_EventFrame = CreateFrame("Frame")
rolling_EventFrame:SetScript("OnEvent", BubbleLoot_G.eventFunctions.OnSystemMsg)

-- REGISTERING AND UNREGISTERING EVENTS - HELPER FUNCTIONS.

-- All the events (channels) searched for saying "pass".
local CHAT_MSG_EVENTS = {
    "CHAT_MSG_INSTANCE_CHAT",
    "CHAT_MSG_INSTANCE_CHAT_LEADER",
    "CHAT_MSG_PARTY",
    "CHAT_MSG_PARTY_LEADER",
    "CHAT_MSG_RAID",
    "CHAT_MSG_RAID_LEADER",
    "CHAT_MSG_WHISPER",
}

function BubbleLoot_G.eventFrames.RegisterChatEvents()
    for _, event in ipairs(CHAT_MSG_EVENTS) do
        passing_EventFrame:RegisterEvent(event)
    end
    rolling_EventFrame:RegisterEvent("CHAT_MSG_SYSTEM")
end

-- Unregister events.
function BubbleLoot_G.eventFrames.UnregisterChatEvents()
    for _, event in ipairs(CHAT_MSG_EVENTS) do
        passing_EventFrame:UnregisterEvent(event)
    end
    rolling_EventFrame:UnregisterEvent("CHAT_MSG_SYSTEM")
end

-- Register solo channels for testing.
function BubbleLoot_G.eventFrames.RegisterSoloChatEvents()
    passing_EventFrame:RegisterEvent("CHAT_MSG_SAY")	
    passing_EventFrame:RegisterEvent("CHAT_MSG_WHISPER")
    rolling_EventFrame:RegisterEvent("CHAT_MSG_SYSTEM")
end



--[[
MINIMAP
]]--
-- Initialize the addon
local MyMinimap = CreateFrame("Frame")
local LDB = LibStub:GetLibrary("LibDataBroker-1.1", true)
local icon = LibStub("LibDBIcon-1.0")

-- Saved Variables for the Minimap icon
MyDB = MyDB or {}
MyDB.minimap = MyDB.minimap or { hide = false, minimapPos = 220 }

-- Create the LDB data object for the minimap button
local MyMinimapLDB = LDB:NewDataObject("MyMinimapIcon", {
    type = "data source",
    text = "Bubble Loot",
    --icon = "Interface\\Icons\\INV_Misc_Bag_08",  -- You can choose any icon
	icon = "Interface\\AddOns\\BubbleLoot\\Textures\\MinimapIcon",
    OnClick = function(self, button)
        if button == "LeftButton" then
            -- Show the context menu on left click
            ShowMinimapContextMenu()
        end
    end,
    OnTooltipShow = function(tooltip)
        tooltip:AddLine("Bubble Loot")
        tooltip:AddLine("Left-click to open options menu.")
    end,
})



-- delete data 
local selectedDB = ""

-- Create a StaticPopup dialog for confirmation

StaticPopupDialogs["CONFIRM_DELETE_DATABASE"] = {
    text = "Are you sure you want to delete the %s data?",
    button1 = "Confirm",
    button2 = "Cancel",
    OnAccept = function()
        -- Confirm was clicked, delete the player from the table
        if selectedDB=="playersDB" then
            BubbleLoot_G.initPlayersData(true)
        elseif selectedDB=="raidDB" then
            BubbleLoot_G.initRaiData(true)
        elseif selectedDB == "cancelDB" then
            BubbleLoot_G.initCancelData(true)
        elseif selectedDB == "syncDB" then
            BubbleLoot_G.initSyncData(true)
        end
        selectedDB = ""
    end,
    OnCancel = function()
        selectedDB = ""
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,  
}


-- Function to display the context menu for the minimap button
function ShowMinimapContextMenu()
    -- Create a dropdown menu frame
    local dropdownMenu = CreateFrame("Frame", "MyAddonMinimapMenu", UIParent, "UIDropDownMenuTemplate")

    -- Initialize the dropdown menu with options
    UIDropDownMenu_Initialize(dropdownMenu, function(self, level, menuList)
        if not level then return end

        if level == 1 then
			-- Add toggle main loot window
			local info = UIDropDownMenu_CreateInfo()
            info.text = "Show/hide the main loot window"
            info.func = function()				
				BubbleLoot_G.gui:ToggleVisibility()
				end
            UIDropDownMenu_AddButton(info, level)
		
            -- Add a participation to all raiders
            info = UIDropDownMenu_CreateInfo()
            info.text = "Add a participation to all players in raid"
            info.func = function() BubbleLoot_G.storage.AddRaidParticipation() end
            UIDropDownMenu_AddButton(info, level)

            -- Add Modify a player's data
			info = UIDropDownMenu_CreateInfo()
            info.text = "Modify a specific player's data"
            info.func = function()				
				BubbleLoot_G.gui.OpenParticipationWindow()
				end
            UIDropDownMenu_AddButton(info, level)
			
			-- Add Check raid player's loot (per date)
			info = UIDropDownMenu_CreateInfo()
            info.text = "Show raid loots per date"
            info.func = function()				
				BubbleLoot_G.gui.OpenRaidsLootWindow()
				end
            UIDropDownMenu_AddButton(info, level)


            -- Add reset menu
            info = UIDropDownMenu_CreateInfo()
            info.text = "Reset database"
            info.hasArrow = true -- This tells the menu item to create a submenu
            info.notCheckable = true
            info.menuList = "RESET_SUBMENU" -- Assigns a name to the submenu
            UIDropDownMenu_AddButton(info, level)
			
        elseif level == 2 then
            if menuList == "RESET_SUBMENU" then                
                
                -- Add a menu entry to reset the player database
                local info = UIDropDownMenu_CreateInfo()
                info.text = "player database"
                info.hasArrow = false -- This tells the menu item to create a submenu
                info.notCheckable = false
                info.func = function()				
                    selectedDB = "playersDB" -- Set the player you want to delete (as an example)
                    StaticPopup_Show("CONFIRM_DELETE_DATABASE", "players")
                    end
                UIDropDownMenu_AddButton(info, level)

                -- Add a menu entry to reset the raid database
                info = UIDropDownMenu_CreateInfo()
                info.text = "raid database"
                info.hasArrow = false -- This tells the menu item to create a submenu
                info.notCheckable = false
                info.func = function()				
                    selectedDB = "raidDB" -- Set the player you want to delete (as an example)
                    StaticPopup_Show("CONFIRM_DELETE_DATABASE", "raid")
                    end
                UIDropDownMenu_AddButton(info, level)

                -- Add a menu entry to reset the cancel data
                info = UIDropDownMenu_CreateInfo()
                info.text = "sync data"
                info.hasArrow = false -- This tells the menu item to create a submenu
                info.notCheckable = false
                info.func = function()		
                    selectedDB = "syncDB" -- Set the player you want to delete (as an example)
                    StaticPopup_Show("CONFIRM_DELETE_DATABASE", "sync")	                    
                    end
                UIDropDownMenu_AddButton(info, level)

                -- Add a menu entry to reset the cancel data
                info = UIDropDownMenu_CreateInfo()
                info.text = "cancel data"
                info.hasArrow = false -- This tells the menu item to create a submenu
                info.notCheckable = false
                info.func = function()		
                    selectedDB = "cancelDB" -- Set the player you want to delete (as an example)
                    StaticPopup_Show("CONFIRM_DELETE_DATABASE", "cancel")	                    
                    end
                UIDropDownMenu_AddButton(info, level)


            end
			
        end
    end)


    -- Show the dropdown menu at the cursor position
    ToggleDropDownMenu(1, nil, dropdownMenu, "cursor", 0, 0)
	
end





-- Register event when the player logs in to set up the minimap icon
MyMinimap:RegisterEvent("PLAYER_LOGIN")
MyMinimap:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        -- Minimap icon settings
        if not MyDB.minimap.hide then
            icon:Register("MyMinimapIcon", MyMinimapLDB, MyDB.minimap)
        end
    end
end)


