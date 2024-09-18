-- Main file. Info and globals.
-- Globals: `BubbleLoot_G`, `BubbleLootShown`, `BubbleLoot_OnAddonCompartmentClick`

-- Global locals (this addon's global namespace).
BubbleLoot_G = {}
-- `eventFunctions.lua` namespace.
BubbleLoot_G.eventFunctions = {}
-- `eventFrames.lua` namespace.
BubbleLoot_G.eventFrames = {}
-- `configuration.lua` namespace.
BubbleLoot_G.configuration = {}
-- `gui.lua` namespace.
BubbleLoot_G.gui = {}
-- `rollerCollection.lua` namespace.
BubbleLoot_G.rollerCollection = {}
-- `roller.lua` namespace. Start by calling `New()`.
BubbleLoot_G.roller = {}
-- `playerInfo.lua` namespace.
BubbleLoot_G.playerInfo = {}
-- Container for plugin namespaces.
---@type Plugin[]
BubbleLoot_G.plugins = {}
--Data storage
BubbleLoot_G.storage = {}
--Items calculation
BubbleLoot_G.calculation = {}

---
---@class Plugin Mandatory plugin interface.
---@field NAME string Plugin name. No spaces (will be used by slash commands).
---@field Initialize fun(self: Plugin, mainFrame: frame, relativePoint): any Return `relativePoint`.
---@field Draw fun(self: Plugin, relativePoint): integer, any Return `addRows, relativePoint` pair.
---@field SlashCmd fun(self: Plugin, args: string)

local cfg = BubbleLoot_G.configuration


--- toggles
--Bubbleloot_G.attributionMode = false

---@enum GroupTypeEnum addon user group status
BubbleLoot_G.GroupType = {
    NOGROUP = "NOGROUP",
    PARTY = "PARTY",
    RAID = "RAID",
}

---Find what kind of group is the current player in.
---@return GroupTypeEnum
function BubbleLoot_G.GetGroupType(self)
    if IsInRaid() then
        return self.GroupType.RAID
    elseif IsInGroup() then -- Any group type but raid => party.
        return self.GroupType.PARTY
    else
        return self.GroupType.NOGROUP
    end
end

-- Include in the minimap compartement. Needs to be global.
function BubbleLoot_OnAddonCompartmentClick()
    BubbleLoot_G.gui:SetVisibility(not BubbleLootShown)
end

-- Initialize self, plugins, saved variables
function BubbleLoot_G.Initialize(self)
    local relativePoint = self.gui:Initialize()
    -- Plugins initialize.
    for _, plugin in ipairs(self.plugins) do
        relativePoint = plugin:Initialize(self.gui.mainFrame, relativePoint)
    end

    -- Load saved variables.
    if BubbleLootShown == nil then -- Initialize when first loaded.
        BubbleLootShown = true;
    end
    self.gui:SetVisibility(BubbleLootShown)

    -- Starting in a group?
    if IsInGroup() then
        -- As if GROUP_JOINED was triggered.
        self.eventFunctions.OnGroupJoined(self)
    end
	
	--Storage data initialize
	if PlayersData == nil then -- Initialize when first loaded.
        PlayersData = {};
    end

    -- Plugins might have sth to say.
    self:Draw()
end

--
---@return Plugin? plugin Namespace or nil if not found.
--[[function BubbleLoot_G.FindPlugin(self, name)
    for _, plugin in ipairs(self.plugins) do
        if name == plugin.NAME then
            return plugin
        end
    end
    return nil
end--]]

--
---@return string
--[[function BubbleLoot_G.PluginsToString(self)
    if #self.plugins == 0 then
        return "No plugins"
    end
    local names = {}
    for _, plugin in ipairs(self.plugins) do
        names[#names + 1] = plugin.NAME
    end
    return "Plugins: " .. table.concat(names, ", ")
end--]]

-- Main drawing function.
function BubbleLoot_G.Draw(self)
    -- Start at 0 for header.
    local currentRow = 0

    -- Fetch data, fill, sort, write.
    local addRows, relativePoint = self.rollerCollection:Draw()
    currentRow = currentRow + addRows

    -- Plugins draw.
    --[[for _, plugin in ipairs(self.plugins) do
        addRows, relativePoint = plugin:Draw(relativePoint)
        currentRow = currentRow + addRows
    end--]]


    self.gui:SetHeight(cfg.size.EMPTY_HEIGHT + cfg.size.ROW_HEIGHT * currentRow)
end


function round2(num, numDecimalPlaces)
  return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end








--[[
MINIMAP
]]--
-- Initialize the addon
local MyAddon = CreateFrame("Frame")
local LDB = LibStub:GetLibrary("LibDataBroker-1.1", true)
local icon = LibStub("LibDBIcon-1.0")

-- Saved Variables for the Minimap icon
MyAddonDB = MyAddonDB or {}

-- Create the LDB data object for the minimap button
local MyAddonLDB = LDB:NewDataObject("MyAddonMinimapIcon", {
    type = "data source",
    text = "Bubble Loot",
    icon = "Interface\\Icons\\INV_Misc_Bag_08",  -- You can choose any icon
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
            info.func = function() print("Option not implemented yet") end
            UIDropDownMenu_AddButton(info, level)

            -- Add "Option 2"
			--[[
            info = UIDropDownMenu_CreateInfo()
            info.text = "Option 2"
            info.func = function() print("Place holder") end
            UIDropDownMenu_AddButton(info, level)
			--]]
        end
    end)

    -- Show the dropdown menu at the cursor position
    ToggleDropDownMenu(1, nil, dropdownMenu, "cursor", 0, 0)
end

-- Register event when the player logs in to set up the minimap icon
MyAddon:RegisterEvent("PLAYER_LOGIN")
MyAddon:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        -- Minimap icon settings
        icon:Register("MyAddonMinimapIcon", MyAddonLDB, MyAddonDB.minimap or {})
    end
end)


