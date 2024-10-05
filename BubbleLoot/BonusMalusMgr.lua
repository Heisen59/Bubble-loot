
local cfg = BubbleLoot_G.configuration

-- Create an addon namespace
local BonusAddon = CreateFrame("Frame")
BonusAddon:RegisterEvent("ADDON_LOADED")

local BonusData = {}
local BonusDataPlayerName

local point, relativeTo, relativePoint, xOffset, yOffset

local function updateBonusMalusPanelPosition()
    point, relativeTo, relativePoint, xOffset, yOffset = BonusAddon.bonusPanel:GetPoint()
end


-- Function to sort the bonusData table by date
local function SortBonusesByDate()
    table.sort(BonusData, function(a, b)
        local dateA = BubbleLoot_G.calculation.ConvertToTimestamp(a[3])  -- Convert date string of bonus A to timestamp
        local dateB = BubbleLoot_G.calculation.ConvertToTimestamp(b[3])  -- Convert date string of bonus B to timestamp

        -- Compare timestamps, nil values go to the end
        if dateA and dateB then
            return dateA > dateB
        elseif dateA then
            return true  -- a comes before b if b's date is invalid
        elseif dateB then
            return false -- b comes before a if a's date is invalid
        else
            return false -- If both dates are invalid, don't change order
        end
    end)
end

-- Function to update the bonus panel with the latest data
local function UpdateBonusPanel()
        
    -- Clear existing lines
    for _, child in ipairs({BonusAddon.scrollChild:GetChildren()}) do
        child:Hide()
    end
    
    -- Create rows for each entry in bonusData
    for i, data in ipairs(BonusData) do
        
        local bonusText = data[1]
        local score = data[2]
        local date =BubbleLoot_G.calculation.ConvertDateFormat(data[3])

        -- Create a container frame for each entry
        local row = CreateFrame("Frame", nil, BonusAddon.scrollChild)
        row:SetSize(400, 60)
        row:SetPoint("TOPLEFT", 10, -60 * (i - 1))

        -- Line 1: Bonus/Malus sentence
        local bonusTextLabel = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        bonusTextLabel:SetText(bonusText)
        bonusTextLabel:SetPoint("TOPLEFT", 0, 0)

        -- Line 2: Score, Date, Edit and Remove Buttons
        -- Score and Date
        local scoreDateLabel = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        scoreDateLabel:SetText("Date: " .. date.." | Score: " .. score)
        scoreDateLabel:SetPoint("TOPLEFT", 0, -20)

        -- Edit Button
        local editButton = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        editButton:SetSize(40, 20)
        editButton:SetText("Edit")
        editButton:SetPoint("LEFT", scoreDateLabel, "RIGHT", 10, 0)
        editButton:SetScript("OnClick", function(self)
            -- Open the Add/Edit panel in edit mode
            BonusAddon:OpenAddBonusPanel(i)
        end)

        -- Delete Button
        local deleteButton = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        deleteButton:SetSize(40, 20)
        deleteButton:SetText("Del")
        deleteButton:SetPoint("LEFT", editButton, "RIGHT", 10, 0)
        deleteButton:SetScript("OnClick", function()
            -- Remove the selected bonus from the table
            table.remove(BonusData, i)

            -- let's sync it to other players
            local currentplayerDBTimeStamp = BubbleLoot_G.storage.writeLastPlayerDataBaseTimeStampGlobal()
            local localBonusTbl = {BonusDataPlayerName, nil, nil, date, true, currentplayerDBTimeStamp }
            BubbleLoot_G.sync.BroadcastDataTable(cfg.SYNC_MSG.MODIFY_BONUS_DATA, localBonusTbl)

            UpdateBonusPanel()
        end)
    end

    -- last update player panel if needed
    if BonusDataPlayerName then 
        BubbleLoot_G.gui.createLootsMgrFrame(BonusDataPlayerName, true)
    end

end

-- Function to create the main bonus panel
function BonusAddon:CreateBonusPanel(playerName)
    -- Create main panel
    local bonusPanel = CreateFrame("Frame", "BonusPanel", UIParent, "BasicFrameTemplateWithInset")
    bonusPanel:SetSize(500, 400)
    --bonusPanel:SetPoint("CENTER")
    bonusPanel:SetPoint(point or "CENTER", relativeTo or UIParent , relativePoint or "CENTER", xOffset or 0, yOffset or 0)
    bonusPanel:SetFrameLevel(25)
    bonusPanel:SetMovable(true)
    bonusPanel:EnableMouse(true)
    bonusPanel:RegisterForDrag("LeftButton")
    bonusPanel:SetScript("OnDragStart", function(self) self:StartMoving() end)
    bonusPanel:SetScript("OnDragStop", function(self)updateBonusMalusPanelPosition() self:StopMovingOrSizing() end)
    bonusPanel.title = bonusPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    bonusPanel.title:SetPoint("CENTER", bonusPanel.TitleBg, "CENTER", 0, 0)
    bonusPanel.title:SetText(playerName.." Bonus / Malus")

    -- Scroll Frame and Scroll Child
    local scrollFrame = CreateFrame("ScrollFrame", nil, bonusPanel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(460, 300)
    scrollFrame:SetPoint("TOPLEFT", 10, -30)

    -- Make the scrollChild globally accessible for updating
    BonusAddon.scrollChild = CreateFrame("Frame")
    BonusAddon.scrollChild:SetSize(460, 800)  -- Arbitrary large size to allow scrolling
    scrollFrame:SetScrollChild(BonusAddon.scrollChild)

    -- Add Bonus Button
    local addButton = CreateFrame("Button", nil, bonusPanel, "UIPanelButtonTemplate")
    addButton:SetSize(120, 30)  -- Make sure the button is large enough
    addButton:SetText("Add a Bonus")
    addButton:SetPoint("BOTTOM", 0, 10)  -- Set to bottom center of the panel
    addButton:SetScript("OnClick", function()
        print("click new bonus")
        BonusAddon:OpenAddBonusPanel(nil)  -- Pass nil for new bonus (not editing)
    end)


    -- Update the scroll child with data
    UpdateBonusPanel()

    -- Store the reference to the panel
    self.bonusPanel = bonusPanel
end


-- Function to create the "Add/Edit Bonus" panel
function BonusAddon:OpenAddBonusPanel(editIndex)    
    -- Create the frame if it doesn't exist yet
    if not self.addBonusPanel then       
        local addBonusPanel = CreateFrame("Frame", "AddBonusPanel", UIParent, "BasicFrameTemplateWithInset")
        addBonusPanel:SetSize(300, 200)
        addBonusPanel:SetPoint("CENTER")
        addBonusPanel:SetFrameLevel(30)
        addBonusPanel:SetMovable(true)
        addBonusPanel:EnableMouse(true)
        addBonusPanel:RegisterForDrag("LeftButton")
        addBonusPanel:SetScript("OnDragStart", function(self) self:StartMoving() end)
        addBonusPanel:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
        addBonusPanel.title = addBonusPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
        addBonusPanel.title:SetPoint("CENTER", addBonusPanel.TitleBg, "CENTER", 0, 0)
        addBonusPanel.title:SetText("Add/Edit Bonus")

        -- Input field for bonus text
        local bonusInput = CreateFrame("EditBox", nil, addBonusPanel, "InputBoxTemplate")
        bonusInput:SetSize(200, 30)
        bonusInput:SetPoint("TOP", 0, -40)
        bonusInput:SetAutoFocus(false)

        -- Input field for score
        local scoreInput = CreateFrame("EditBox", nil, addBonusPanel, "InputBoxTemplate")
        scoreInput:SetSize(200, 30)
        scoreInput:SetPoint("TOP", bonusInput, "BOTTOM", 0, -20)
        scoreInput:SetAutoFocus(false)

        -- Save Button
        local saveButton = CreateFrame("Button", nil, addBonusPanel, "UIPanelButtonTemplate")
        saveButton:SetSize(80, 30)
        saveButton:SetText("Save")
        saveButton:SetPoint("BOTTOM", 0, 20)
        saveButton:SetScript("OnClick", function()
            local bonusText = bonusInput:GetText()
            local score = tonumber(scoreInput:GetText())
            local date = date("%d-%m-%Y à %H:%M:%S")

            if bonusText and score then
                if self.editIndex ~= nil then
                    -- Editing an existing bonus
                    print("Editing")
                    BonusData[self.editIndex] = {bonusText, score, date}
                else
                    -- Adding a new bonus
                    print("Adding")
                    table.insert(BonusData, 1, {bonusText, score, date})
                end

                -- Sync it with other players
                local currentplayerDBTimeStamp = BubbleLoot_G.storage.writeLastPlayerDataBaseTimeStampGlobal()
                local localBonusTbl = {BonusDataPlayerName, bonusText, score, date, false, currentplayerDBTimeStamp}
                BubbleLoot_G.sync.BroadcastDataTable(cfg.SYNC_MSG.MODIFY_BONUS_DATA, localBonusTbl)

                UpdateBonusPanel()
                addBonusPanel:Hide()
            else
                print("Invalid input, please enter a valid bonus and score.")
            end
        end)

        self.addBonusPanel = addBonusPanel
        self.addBonusPanel.bonusInput = bonusInput
        self.addBonusPanel.scoreInput = scoreInput
    end

    -- Store editIndex in the frame for later use
    self.editIndex = editIndex

    -- Reset input fields for new entry or fill them for editing
    if editIndex then
        self.addBonusPanel.bonusInput:SetText(BonusData[editIndex][1])
        self.addBonusPanel.scoreInput:SetText(tostring(BonusData[editIndex][2]))
    else
        self.addBonusPanel.bonusInput:SetText("")
        self.addBonusPanel.scoreInput:SetText("")
    end

    -- Show the panel
    self.addBonusPanel:Show()
end


function BubbleLoot_G.storage.writeOrEditBonus(playerName, bonusText, score, date, remove, currentplayerDBTimeStamp)

    local bonusDataTable = PlayersData[playerName].BonusMalus or {}

    for _, bonus in ipairs(bonusDataTable) do 
        if bonus[3] == date then -- we edit 
            if remove then
                bonus = nil
            else
                bonus = {bonusText, score, date}  
            end
            UpdateBonusPanel()            
            BubbleLoot_G.storage.forcePlayerDataBaseWriteTimeStampGlobal(currentplayerDBTimeStamp)
            return
        end
    end

    -- if we reach it, it means we didn't find a bonus to edit

    table.insert(bonusDataTable,1, {bonusText, score, date})
    UpdateBonusPanel()
    BubbleLoot_G.storage.forcePlayerDataBaseWriteTimeStampGlobal(currentplayerDBTimeStamp)
end




function BubbleLoot_G.gui.OpenBonusPanelGlobal(playerName)
    -- Check if a bonus panel already exists and hide it
    if BonusAddon.bonusPanel then
        BonusAddon.bonusPanel:Hide()
    end
    

    BonusData = PlayersData[playerName].BonusMalus or {}
    BonusDataPlayerName = playerName
    --SortBonusesByDate()
    BonusAddon:CreateBonusPanel(playerName)
end
