-- synchronisation functions

local cfg = BubbleLoot_G.configuration

local addonName = cfg.ADDON_NAME
local prefix = cfg.PREFIX

local tempSyncList = {{},{}}

-- Create a frame to handle events
local BubbleLootSyncFrame = CreateFrame("Frame")
BubbleLootSyncFrame:RegisterEvent("CHAT_MSG_ADDON")

-- Register the addon prefix
C_ChatInfo.RegisterAddonMessagePrefix(prefix)

-- Serialize table to a string
local LibSerialize = LibStub:GetLibrary("LibSerialize")
local LibDeflate = LibStub:GetLibrary("LibDeflate")

-- Function to serialize and compress a Lua table with a type identifier
local function SerializeMessage(msgType, tbl)
    local serialized = LibSerialize:Serialize(tbl)
    local compressed = LibDeflate:CompressDeflate(serialized)
    local encoded = LibDeflate:EncodeForWoWAddonChannel(compressed)
    -- Prefix the message type with a separator so we can split it on the other end
    return msgType .. "|" .. encoded
end

-- Function to decompress and deserialize a string back into a Lua table
local function DeserializeMessage(message)
    local msgType, encodedData = strsplit("|", message, 2)
    if not msgType or not encodedData then
        print("Error: Invalid message format")
        return nil, nil
    end

    local decoded = LibDeflate:DecodeForWoWAddonChannel(encodedData)
    local decompressed = LibDeflate:DecompressDeflate(decoded)
    local success, deserializedTable = LibSerialize:Deserialize(decompressed)

    if success then
        return msgType, deserializedTable
    else
        print("Failed to deserialize table")
        return nil, nil
    end
end


-- Function to broadcast different data tables based on type
function BubbleLoot_G.sync.BroadcastDataTable(msgType, tbl, targetPlayer)
    local serializedData = SerializeMessage(msgType, tbl)
    if targetPlayer then
        -- Whisper the data to a specific player
        C_ChatInfo.SendAddonMessage(prefix, serializedData, "WHISPER", targetPlayer)
    else
        -- Broadcast to group (party/raid)
        C_ChatInfo.SendAddonMessage(prefix, serializedData, "RAID")  -- Or "PARTY" if not in a raid
    end
end

function BubbleLoot_G.sync.SendEverything()

	-- BubbleLoot_G.sync.BroadcastDataTable("RaidData", RaidData, "Zatopec")
	-- BubbleLoot_G.sync.BroadcastDataTable("PlayersData", PlayersData, "Zatopec")
	-- BubbleLoot_G.sync.BroadcastDataTable("RaidLootData", RaidLootData, "Zatopec")

end

local function registerNewData(msgType, receivedTable)

	-- Process the data based on message type
	if msgType == "RaidData" then
		RaidData = receivedTable
		print("Updated RaidData info table")
		print("Now, Raid number is "..RaidData[cfg.NUMBER_OF_RAID_DONE])
	elseif msgType == "PlayersData" then
		PlayersData = receivedTable
		print("Updated PlayersData table")
	elseif msgType == "RaidLootData" then
		RaidLootData = receivedTable
		print("Updated RaidLootData  table")
	elseif msgType == "inventory" then
		
	else
		print("Unknown data type: " .. msgType)
	end

end





local function checkSender(sender, msgType, receivedTable)

	-- Check temp list
	for _, tempTrustName in ipairs(tempSyncList[cfg.TRUST_LIST]) do
		if sender == tempTrustName then registerNewData(msgType, receivedTable) end
	end
	
	-- Check permanent list
	for _, TrustName in ipairs(SyncTrustList[cfg.TRUST_LIST]) do
		if sender == TrustName then registerNewData(msgType, receivedTable) end
	end

	
	-- send dialog box
	local syncFrameQuestion = CreateFrame("Frame", "syncFrameQuestion", UIParent, "BasicFrameTemplateWithInset")
    syncFrameQuestion:SetSize(350, 150)
    syncFrameQuestion:SetPoint("CENTER")  -- Center the frame
    syncFrameQuestion:SetMovable(true)
    syncFrameQuestion:EnableMouse(true)
    syncFrameQuestion:RegisterForDrag("LeftButton")
    syncFrameQuestion:SetScript("OnDragStart", syncFrameQuestion.StartMoving)
    syncFrameQuestion:SetScript("OnDragStop", syncFrameQuestion.StopMovingOrSizing)

    -- Title of the frame
    syncFrameQuestion.title = syncFrameQuestion:CreateFontString(nil, "OVERLAY")
    syncFrameQuestion.title:SetFontObject("GameFontHighlight")
    syncFrameQuestion.title:SetPoint("CENTER", syncFrameQuestion.TitleBg, "CENTER", 0, 0)
    syncFrameQuestion.title:SetText("Sync Request")

    -- Question text
    syncFrameQuestion.questionText = syncFrameQuestion:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    syncFrameQuestion.questionText:SetPoint("TOP", syncFrameQuestion, "TOP", 0, -40)
    syncFrameQuestion.questionText:SetText("Addon syncing, do you trust " .. sender .. "?")

	    -- Function to handle button clicks
    local function HandleButtonClick(buttonText)
        if buttonText=="Always" then
			table.insert(SyncTrustList[cfg.TRUST_LIST], sender)
			registerNewData(msgType, receivedTable)
		elseif buttonText=="Yes" then
			table.insert(tempSyncList[cfg.TRUST_LIST], sender)
			registerNewData(msgType, receivedTable)
		elseif buttonText=="No" then
			table.insert(tempSyncList[cfg.BLACK_LIST], sender)
		elseif buttonText=="Never" then
			table.insert(SyncTrustList[cfg.BLACK_LIST], sender)
		end		
		
        syncFrameQuestion:Hide()  -- Delete the frame after a button is clicked
		syncFrameQuestion:SetParent(nil)
        syncFrameQuestion = nil
    end
	
	-- Create 4 buttons
    local buttons = {}
    local buttonLabels = {"Always", "Yes", "No", "Never"}

    for i, label in ipairs(buttonLabels) do
        local button = CreateFrame("Button", nil, syncFrameQuestion, "GameMenuButtonTemplate")
        button:SetSize(70, 25)
        button:SetText(label)
        button:SetPoint("BOTTOMLEFT", syncFrameQuestion, "BOTTOMLEFT", 30 + (i - 1) * 80, 20)
        button:SetScript("OnClick", function() HandleButtonClick(label) end)
        table.insert(buttons, button)
    end

    -- Show the frame
    syncFrameQuestion:Show()
	

end


-- Event handler for receiving addon messages
local function OnEvent(self, event, receivedPrefix, message, channel, sender)

	-- check if sender is in BL
	for _, tempTrustName in ipairs(tempSyncList[cfg.BLACK_LIST]) do
		if sender == tempTrustName then return end
	end

	for _, tempTrustName in ipairs(SyncTrustList[cfg.BLACK_LIST]) do
		if sender == tempTrustName then return end
	end
	
	
	-- Deserialize and ask if the sender is not know.
    if event == "CHAT_MSG_ADDON" and receivedPrefix == prefix then
        local msgType, receivedTable = DeserializeMessage(message)
        if receivedTable then
            print("Received data of type " .. msgType .. " from " .. sender)
			checkSender(sender, msgType, receivedTable)
        end
    end
end

BubbleLootSyncFrame:SetScript("OnEvent", OnEvent)








