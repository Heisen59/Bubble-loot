-- Define EventFrames and connect them with OnEvent functions from `BubbleLoot_G.eventFunctions`.
-- Define register helper functions.
-- Populate `BubbleLoot_G.eventFrames`.

-- CREATE EVENT FRAMES

-- The first time saved variables are accessible (they are not while built-in onLoad is run).
local addonLoaded_EventFrame = CreateFrame("Frame")
addonLoaded_EventFrame:RegisterEvent("ADDON_LOADED")
addonLoaded_EventFrame:SetScript("OnEvent", BubbleLoot_G.eventFunctions.OnLoad)

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


-- Function to display the context menu for the minimap button
function ShowMinimapContextMenu()
    -- Create a dropdown menu frame
    local dropdownMenu = CreateFrame("Frame", "MyAddonMinimapMenu", UIParent, "UIDropDownMenuTemplate")

    -- Initialize the dropdown menu with options
    UIDropDownMenu_Initialize(dropdownMenu, function(self, level)
        if not level then return end

        if level == 1 then
            -- Add "Option 1"
            local info = UIDropDownMenu_CreateInfo()
            info.text = "Add a participation to all players in raid"
            info.func = function() BubbleLoot_G.storage.AddRaidParticipation() end
            UIDropDownMenu_AddButton(info, level)

            -- Add "Option 2"
			info = UIDropDownMenu_CreateInfo()
            info.text = "Modify participation of a specific player"
            info.func = function()				
				BubbleLoot_G.gui.OpenInputWindow()
				end
            UIDropDownMenu_AddButton(info, level)
			
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

--[[
-- Register event when the player logs in, to set up the hooks
--addonLoaded_EventFrame:RegisterEvent("ADDON_LOADED")
addonLoaded_EventFrame:SetScript("OnEvent", function(self, event)
    if event == "ADDON_LOADED" then
		print("I'm in SetScript ADDON_LOADED")
        HookBagItemRightClick() -- Set up the hook for bag items after login
        LootFrame:HookScript("OnShow", HookLootItemRightClick) -- Set up the hook for loot items when the loot window appears
    end
end)
]]--