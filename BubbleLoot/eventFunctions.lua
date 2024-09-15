-- Functions called on events defined in `BubbleLoot_G.eventFrames`.
-- Do not use `self` (`self ~= BubbleLoot_G.eventFunctions`)
-- Populate `BubbleLoot_G.eventFunctions`.

local cfg = BubbleLoot_G.configuration

-- ADDON_LOADED
function BubbleLoot_G.eventFunctions.OnLoad(self, event, addOnName)
    if addOnName == cfg.ADDON_NAME then
        BubbleLoot_G:Initialize()
    end
end

-- GROUP_JOINED
function BubbleLoot_G.eventFunctions.OnGroupJoined(self, event)
    BubbleLoot_G.eventFrames.RegisterChatEvents()
end

-- GROUP_LEFT
function BubbleLoot_G.eventFunctions.OnGroupLeft(self, event)
    BubbleLoot_G.eventFrames.UnregisterChatEvents()
end

-- GROUP_ROSTER_UPDATE
function BubbleLoot_G.eventFunctions.OnGroupUpdate(self, event)
    BubbleLoot_G.rollerCollection:UpdateGroup()
    BubbleLoot_G:Draw()
end

-- CHAT_MSG_EVENTS
-- Look for "pass" in the group channels.
function BubbleLoot_G.eventFunctions.OnChatMsg(self, event, text, playerName)
    local name, server = strsplit("-", playerName)
	--print("point 1")
    if text:lower() == "pass" then
		--print("point 2")
        BubbleLoot_G.rollerCollection:Save(name, 9)
        BubbleLoot_G:Draw()
    end
	if text:lower() == "+1" then
        --print("point 3")
		-- Perform some action, e.g., print a message to the player
        --print(playerName .. " has typed +1 in the chat!")
		BubbleLoot_G.rollerCollection:Save(name, 1)
        BubbleLoot_G:Draw()
    end
	if text:lower() == "+2" then
        --print("point 4")
		-- Perform some action, e.g., print a message to the player
        --print(playerName .. " has typed +2 in the chat!")
		BubbleLoot_G.rollerCollection:Save(name, 2)
        BubbleLoot_G:Draw()
    end
	if text:lower() == "+3" then
		BubbleLoot_G.rollerCollection:Save(name, 3)
		BubbleLoot_G:Draw()
    end
	
end

-- CHAT_MSG_SYSTEM
-- Look for "/roll" in system messages from ML
function BubbleLoot_G.eventFunctions.OnSystemMsg(self, event, text)
	
    if string.find(text, "obtient") ~= nil then
		local name, roll, minRoll, maxRoll = text:match("^(.+) obtient un (%d+) %((%d+)%-(%d+)%).$")

        minRoll = tonumber(minRoll)
        maxRoll = tonumber(maxRoll)
        if (minRoll == 1 and maxRoll == 100) then
            --BubbleLoot_G.rollerCollection:Save(name, tonumber(roll))
            --BubbleLoot_G:Draw()
        end
		
		if(minRoll == 1 and maxRoll == 10000 and name == UnitName("player")) then
			BubbleLoot_G.calculation.getTheWinner(tonumber(roll))
		end
		
    end
end
