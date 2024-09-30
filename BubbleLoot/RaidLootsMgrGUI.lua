
local cfg = BubbleLoot_G.configuration

-- Define the addon and main frame
local RaidLootFrame = CreateFrame("Frame", "RaidLootFrame", UIParent, "BasicFrameTemplateWithInset")
RaidLootFrame:SetSize(600, 700) -- Width, Height
RaidLootFrame:SetPoint("CENTER") -- Position in the center of the screen
RaidLootFrame.title = RaidLootFrame:CreateFontString(nil, "OVERLAY")
RaidLootFrame.title:SetFontObject("GameFontHighlightLarge")
RaidLootFrame.title:SetPoint("TOP", 0, -3)
RaidLootFrame.title:SetText("Raids History")
RaidLootFrame:SetMovable(true)  -- Make the frame movable
RaidLootFrame:EnableMouse(true) -- Enable mouse interaction for moving
RaidLootFrame:RegisterForDrag("LeftButton") -- Register left-button dragging
RaidLootFrame:SetScript("OnDragStart", RaidLootFrame.StartMoving)
RaidLootFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    -- Optionally, clamp the frame to keep it within screen bounds
    self:SetClampedToScreen(true)
end)





-- Sample Data
local raids = {}
local lootTable = {}

C_Timer.After(1,function()
    for _, raidHistoricData in pairs(RaidData[cfg.RAID_HISTORIC]) do
        local date = raidHistoricData[1]
        local name = raidHistoricData[2]
        local dateTable = BubbleLoot_G.calculation.ParseDateString(date)    
        table.insert(raids, { name = name, dateText = ("%s-%s-%s"):format(dateTable.day, dateTable.month, dateTable.year), fullDate = date })
    end


    for playerName, playerData in pairs(PlayersData) do    
        local itemsData = playerData.items
        for _, itemData in pairs(itemsData) do 
            local itemLink = itemData[cfg.ITEMLINK]        
            local lootsData = itemData[cfg.LOOTDATA]
                for _, lootData in pairs(lootsData) do 
                    local date = lootData[1]
                    local need = lootData[2]
                        for _, raid in ipairs(raids) do
                            if BubbleLoot_G.calculation.GetDurationInHours(date, raid.fullDate) < 5 then
                                lootTable[raid.dateText] = lootTable[raid.dateText] or {}
                                table.insert(lootTable[raid.dateText], {item = itemLink, player = playerName, need = need})
                            end
                        end
                end
        end
    end



end
)




-- Sort the raids by date
local function SortRaidsByDate()
    table.sort(raids, function(a, b) return a.dateText > b.dateText end)
end

-- Keep track of the current view (raid list or loot list)
local currentView = nil
local currentRaidDate = nil

-- Track loot UI elements so we can remove them explicitly
local lootElements = {}

-- Forward declare functions
local ShowRaidList, ShowLoot, RefreshView, ClearContent

-- Create scrollable content for listing raids and dates
local scrollFrame = CreateFrame("ScrollFrame", "scrollRaidLootFrame", RaidLootFrame, "UIPanelScrollFrameTemplate")
scrollFrame:SetSize(555, 640)
scrollFrame:SetPoint("TOPLEFT", 10, -50)

local RaidContentFrame = CreateFrame("Frame", "RaidContentFrame", scrollFrame)
RaidContentFrame:SetSize(560, 800)
scrollFrame:SetScrollChild(RaidContentFrame)

-- Function to clear the content frame
ClearContent = function()
    -- Remove all previous child elements from the content frame
    local children = {RaidContentFrame:GetChildren()}
    for _, child in ipairs(children) do
        child:Hide()  -- Hide the content (this keeps the buttons in memory but hides them)
        child:SetParent(nil) -- Remove from parent so it won't affect layout
    end

    -- If there are loot elements in the current view, explicitly delete them
    for _, element in ipairs(lootElements) do
        element:Hide()      -- Hide the element
        element:SetParent(nil) -- Remove from the parent frame
        element = nil       -- Free up memory
    end
    lootElements = {} -- Reset the lootElements table for a clean slate
end

-- Function to refresh the UI based on current view (either raid list or loot list)
RefreshView = function()
    if currentView == "raidList" then
        ShowRaidList()
    elseif currentView == "lootList" and currentRaidDate then
        ShowLoot(currentRaidDate)
    end
end

-- Function to display loot for a specific raid
ShowLoot = function(raidDate)
    ClearContent()
    RaidLootFrame.title:SetText("Loot from " .. raidDate)
    currentView = "lootList"
    currentRaidDate = raidDate
    
    local yOffset = -25

    local loots = lootTable[raidDate] or {}
    for _, loot in ipairs(loots) do
        local lootText = RaidContentFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        lootText:SetPoint("TOPLEFT", 10, yOffset)
        lootText:SetText(loot.item .. " - Won by " .. loot.player.." as +"..loot.need)
        lootText:SetScript("OnMouseDown", function(self, button)
            if button == "RightButton" then 
                BubbleLoot_G.gui.CreateDropdownMenuGlobal(loot.player)
            end
        end)
        yOffset = yOffset - 20
        
        -- Add lootText to the lootElements table for later removal
        table.insert(lootElements, lootText)
    end



    -- Add the "Return" button to go back to the raid list
    local returnButton = CreateFrame("Button", nil, RaidContentFrame, "UIPanelButtonTemplate")
    returnButton:SetSize(100, 20)
    returnButton:SetPoint("TOPRIGHT", -10, 0)
    returnButton:SetText("Return")
    
    -- Set the script to return to the raid list when clicked
    returnButton:SetScript("OnClick", function()
        ShowRaidList()
    end)

    -- Add returnButton to lootElements table for cleanup
    table.insert(lootElements, returnButton)

end

-- Function to display raid list
-- Function to display raid list
ShowRaidList = function()

    if currentView ~= "raidList" then
        RaidLootFrame:Show()
        ClearContent()
        RaidLootFrame.title:SetText("Raid History")
        currentView = "raidList"
        currentRaidDate = nil
    elseif currentView == "raidList" then
        RaidLootFrame:Hide()
        currentView = nil
    end



    SortRaidsByDate()

    local yOffset = -10
    for _, raid in ipairs(raids) do
        local raidButton = CreateFrame("Button", nil, RaidContentFrame, "UIPanelButtonTemplate")
        raidButton:SetSize(550, 20)
        raidButton:SetPoint("TOPLEFT", 5, yOffset)
        raidButton:SetText(raid.name .. " - " .. raid.dateText)

        -- Set script for clicking the raid button to show loot
        raidButton:SetScript("OnClick", function()
            ShowLoot(raid.dateText)
        end)

        yOffset = yOffset - 30
    end
end


    -- Close button functionality
local CloseButtonRaidLootFrame = RaidLootFrame.CloseButton
CloseButtonRaidLootFrame:SetScript("OnClick", function(self)
        RaidLootFrame:Hide()
        currentView = nil
    end)

-- Example: Adding a new raid and updating the view
local function AddRaid(name, date)
    table.insert(raids, { name = name, date = date })
    RefreshView()  -- Refresh the current view when raids are updated
end

-- Adding loot to an existing raid and updating the view
local function AddLoot(raidDate, item, player)
    if not lootTable[raidDate] then
        lootTable[raidDate] = {}
    end
    table.insert(lootTable[raidDate], { item = item, player = player })
    RefreshView()  -- Refresh the current view when lootTable is updated
end

function BubbleLoot_G.gui.OpenRaidsLootWindow()
    ShowRaidList()
end

RaidLootFrame:Hide()

-- Test dynamic updates
--C_Timer.After(5, function()
--    AddRaid("Zul'Gurub", "2024-10-01")  -- Add a new raid dynamically after 5 seconds
--end)

--C_Timer.After(10, function()
--    AddLoot("2024-09-22", "Obsidian Edged Blade", "PlayerSeven")  -- Add new loot dynamically after 10 seconds
--end)