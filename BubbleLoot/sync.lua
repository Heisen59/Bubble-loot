-- Synchronisation functions
local cfg = BubbleLoot_G.configuration
local prefix = cfg.PREFIX


local tempSyncList = {{},{}}
local receivedChunks = {}  -- Table to store chunks for each sender
local expectedChunks = {}  -- Track how many chunks are expected

-- Helping function to check if a player is a guild officer

function IsGuildOfficer(playerName)
    GuildRoster()
    for i = 1, GetNumGuildMembers() do
        local name, rank, rankIndex = GetGuildRosterInfo(i)
        if name and string.lower(name) == string.lower(playerName) then
            --print(rankIndex)
            if rankIndex < 6 then
                return true
            end
        end
    end
    return false
end


    -- check if sender is in BL
local function checkIfInBL(sender)
    
	for _, tempTrustName in ipairs(tempSyncList[cfg.BLACK_LIST]) do
        print(tempTrustName)
        if sender == tempTrustName then return true end
	end

	for _, tempTrustName in ipairs(SyncTrustList[cfg.BLACK_LIST]) do
        
		if sender == tempTrustName then return true end
	end

    
    return false

end

-- Create a frame to handle events
local BubbleLootSyncFrame = CreateFrame("Frame")
BubbleLootSyncFrame:RegisterEvent("CHAT_MSG_ADDON")
C_ChatInfo.RegisterAddonMessagePrefix(prefix)

-- Serialize table to a string
local LibSerialize = LibStub:GetLibrary("LibSerialize")
local LibDeflate = LibStub:GetLibrary("LibDeflate")

-- Function to serialize and compress a Lua table with a type identifier
local function SerializeMessage(msgType, tbl)
    local serialized = LibSerialize:Serialize(tbl)
    local compressed = LibDeflate:CompressDeflate(serialized)
    local encoded = LibDeflate:EncodeForWoWAddonChannel(compressed)
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

-- Function to split a string into smaller chunks
local function SplitIntoChunks(message, chunkSize)
    local chunks = {}
    for i = 1, #message, chunkSize do
        table.insert(chunks, message:sub(i, i + chunkSize - 1))
    end
    return chunks
end

-- Function to broadcast data in chunks
function BubbleLoot_G.sync.BroadcastDataTable(msgType, tbl, targetPlayer)
    
    local serializedData = SerializeMessage(msgType, tbl)
    local chunkSize = 200  -- Adjust size to leave room for sequence and flags
    local chunks = SplitIntoChunks(serializedData, chunkSize)
    local totalChunks = #chunks

    for i, chunk in ipairs(chunks) do
        local isLast = (i == totalChunks) and "1" or "0"  -- "1" if last chunk, "0" otherwise
        local chunkMessage = msgType .. "|" .. isLast .. "|" .. i .. "|" .. totalChunks .. "|" .. chunk

        if targetPlayer then
            print("Data send to "..targetPlayer)
            C_ChatInfo.SendAddonMessage(prefix, chunkMessage, "WHISPER", targetPlayer)
        else
            C_ChatInfo.SendAddonMessage(prefix, chunkMessage, "RAID")  -- Or "PARTY"
            for _, trustedPlayer in ipairs(SyncTrustList[1]) do
                C_ChatInfo.SendAddonMessage(prefix, chunkMessage, "WHISPER", trustedPlayer)
            end
        end
    end
end

-- Function to handle new data after verification
local function registerNewData(msgType, receivedTable)
    if msgType == "RaidData" then
        RaidData = receivedTable
        print("Updated RaidData info table")
    elseif msgType == "PlayersData" then
        PlayersData = receivedTable
        print("Updated PlayersData table")
    elseif msgType == cfg.SYNC_MSG.ADD_PLAYER_DATA_FUNCTION then
        print("Update PlayersData with a new loot")
        local playerName, itemLink, LootAttribType, DateRemoveItem, exchange, DBTimeStamp = receivedTable[1], receivedTable[2], receivedTable[3], receivedTable[4], receivedTable[5], receivedTable[6]
        BubbleLoot_G.storage.AddPlayerData(playerName, itemLink, LootAttribType, DateRemoveItem, exchange, DBTimeStamp)
    elseif msgType == cfg.SYNC_MSG.ADD_RAID_PARTICIPATIOn then
        print("Update raid participation")        
        BubbleLoot_G.storage.AddRaidParticipation(true)
    elseif msgType == cfg.SYNC_MSG.DEMOTE_PLAYER_NEED then
        --print("Update raid participation")     
        local playerName = receivedTable
        BubbleLoot_G.gui.DemotePlayer(playerName, true )
    else
        print("Unknown data type: " .. msgType)
    end
end


-- Function to check sender and display sync trust dialog
local function checkSender(sender, msgType, receivedTable)

    -- this data comes from me, discard it
    local playerName, playerRealm = UnitName("player")
    local senderPlayerName, senderPlayerRealm = string.match(sender, "([^%-]+)%-([^%-]+)")

    if senderPlayerName == playerName then        
        print("discard")
        return
    end
  
    for _, tempTrustName in ipairs(tempSyncList[cfg.TRUST_LIST]) do
        if sender == tempTrustName then registerNewData(msgType, receivedTable) return end
    end

    

    for _, TrustName in ipairs(SyncTrustList[cfg.TRUST_LIST]) do
        if sender == TrustName then registerNewData(msgType, receivedTable) return end
    end

    
--print("here")
    if not IsGuildOfficer(sender) then return end
    --print("Debug : Secured transfer from guildOfficer desactivated, players still have to get permission to write")
--print("and here")
    

    -- Create sync trust dialog
    local syncFrameQuestion = CreateFrame("Frame", "syncFrameQuestion", UIParent, "BasicFrameTemplateWithInset")
    syncFrameQuestion:SetSize(350, 150)
    syncFrameQuestion:SetPoint("CENTER")
    syncFrameQuestion:SetMovable(true)
    syncFrameQuestion:EnableMouse(true)
    syncFrameQuestion:RegisterForDrag("LeftButton")
    syncFrameQuestion:SetScript("OnDragStart", syncFrameQuestion.StartMoving)
    syncFrameQuestion:SetScript("OnDragStop", syncFrameQuestion.StopMovingOrSizing)

    syncFrameQuestion.title = syncFrameQuestion:CreateFontString(nil, "OVERLAY")
    syncFrameQuestion.title:SetFontObject("GameFontHighlight")
    syncFrameQuestion.title:SetPoint("CENTER", syncFrameQuestion.TitleBg, "CENTER", 0, 0)
    syncFrameQuestion.title:SetText("Sync Request")

    syncFrameQuestion.questionText = syncFrameQuestion:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    syncFrameQuestion.questionText:SetPoint("TOP", syncFrameQuestion, "TOP", 0, -40)
    syncFrameQuestion.questionText:SetText("Addon syncing, do you trust " .. sender .. "?")

    local function HandleButtonClick(buttonText)
        if buttonText == "Always" then
            table.insert(SyncTrustList[cfg.TRUST_LIST], sender)  
            registerNewData(msgType, receivedTable)
        elseif buttonText == "Yes" then
            table.insert(tempSyncList[cfg.TRUST_LIST], sender)
            registerNewData(msgType, receivedTable)
        elseif buttonText == "No" then
            table.insert(tempSyncList[cfg.BLACK_LIST], sender)
        elseif buttonText == "Never" then
            table.insert(SyncTrustList[cfg.BLACK_LIST], sender)
        end
        syncFrameQuestion:Hide()
        syncFrameQuestion:SetParent(nil)
        syncFrameQuestion = nil
    end

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

    syncFrameQuestion:Show()

end

-- Function to reassemble chunks
local function ReassembleChunks(sender, msgType, totalChunks)
    if #receivedChunks[sender] == totalChunks then
        local completeMessage = table.concat(receivedChunks[sender])
        receivedChunks[sender] = nil
        expectedChunks[sender] = nil

        -- Process the reassembled message
        local msgType, receivedTable = DeserializeMessage(completeMessage)
        if receivedTable then
            checkSender(sender, msgType, receivedTable)
        else
            print("Error: Failed to process reassembled message "..msgType.." from " .. sender)
        end
    else
        print("Error: Missing chunks"..msgType.." from sender " .. sender)
    end
end

-- Function to handle chunked messages
local function HandleChunkedMessage(sender, msgType, isLast, chunkIndex, totalChunks, chunkData)
    -- Debugging outputs
    --print("Received chunk from " .. sender .. " with msgType "..msgType.." : " .. chunkIndex .. "/" .. totalChunks)
    
    if not receivedChunks[sender] then
        receivedChunks[sender] = {}
        expectedChunks[sender] = totalChunks
    end

    receivedChunks[sender][tonumber(chunkIndex)] = chunkData

    if isLast == "1" then
        ReassembleChunks(sender, msgType, totalChunks)
    end
end




-- Event handler for receiving addon messages
local function OnEvent(self, event, receivedPrefix, message, channel, sender)

    -- Deserialize and ask if the sender is not know.
    if event == "CHAT_MSG_ADDON" and receivedPrefix == prefix then
                    
        -- check if sender is in BL
        if checkIfInBL(sender) then return end
    
        local msgType, isLast, chunkIndex, totalChunks, chunkData = strsplit("|", message, 5)
        if chunkData then
            HandleChunkedMessage(sender, msgType, isLast, chunkIndex, tonumber(totalChunks), chunkData)
        end
    end
end

BubbleLootSyncFrame:SetScript("OnEvent", OnEvent)
