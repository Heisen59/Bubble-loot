-- synchronisation functions

local cfg = BubbleLoot_G.configuration

local addonName = cfg.ADDON_NAME
local prefix = cfg.PREFIX


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
local function BroadcastDataTable(msgType, tbl, targetPlayer)
    local serializedData = SerializeMessage(msgType, tbl)
    if targetPlayer then
        -- Whisper the data to a specific player
        C_ChatInfo.SendAddonMessage(prefix, serializedData, "WHISPER", targetPlayer)
    else
        -- Broadcast to group (party/raid)
        C_ChatInfo.SendAddonMessage(prefix, serializedData, "RAID")  -- Or "PARTY" if not in a raid
    end
end

-- Event handler for receiving addon messages
local function OnEvent(self, event, receivedPrefix, message, channel, sender)
    if event == "CHAT_MSG_ADDON" and receivedPrefix == prefix then
        local msgType, receivedTable = DeserializeMessage(message)
        if receivedTable then
            print("Received data of type " .. msgType .. " from " .. sender)

            -- Process the data based on message type
            if msgType == "playerInfo" then
                playerInfoTable = receivedTable
                print("Updated player info table")
            elseif msgType == "questProgress" then
                questProgressTable = receivedTable
                print("Updated quest progress table")
            elseif msgType == "inventory" then
                inventoryTable = receivedTable
                print("Updated inventory table")
            else
                print("Unknown data type: " .. msgType)
            end
        end
    end
end

BubbleLootSyncFrame:SetScript("OnEvent", OnEvent)








