-- Slash commands and the called functions.
-- Populate no namespace.

local cfg = BubbleLoot_G.configuration

--
local function printError(msg)
    local text = ("%s: %s"):format(cfg.ADDON_NAME, msg)
    print(WrapTextInColorCode(text, cfg.colors.SYSTEMMSG))
end

-- Print ingame help.
local function Help(args)
    local title = C_AddOns.GetAddOnMetadata(cfg.ADDON_NAME, "title")
    local version = C_AddOns.GetAddOnMetadata(cfg.ADDON_NAME, "version")
    print(title .. " v" .. version .. ".");
    for _, line in ipairs(cfg.texts.HELP_LINES) do
        print(line)
    end
end

-- Clear UI.
local function Clear(args)
    BubbleLoot_G.rollerCollection:Clear()
    BubbleLoot_G:Draw()
end

-- Main frame width change.
local function Resize(args)
    local percentage
    -- Parameter check.
    if args == nil then -- No parameter -> default.
        percentage = 100
    else
        percentage = tonumber(args)
        if percentage == nil then -- Not a number.
            printError(cfg.texts.RESIZE_PARAMETER_ERROR)
            return
        elseif percentage < 100 then
            printError(cfg.texts.RESIZE_SIZE_ERROR)
            return
        end
    end

    BubbleLoot_G.gui:SetWidth(cfg.size.FRAME_WIDTH * (percentage / 100))
end

-- No need to be part of a group for this to work.
local function Test(args)
    -- Parameter check.
    if not args then
        printError(cfg.texts.TEST_PARAMETER_ERROR)
        return
    end
    local subCommand, subArgs = strsplit(" ", args, 2)

    -- Fill `rollerCollection` by artificial values.
    if subCommand == "fill" then
        BubbleLoot_G.rollerCollection:Fill()
        BubbleLoot_G:Draw()

    -- No need to be part of a group for this to work.
    elseif subCommand == "solo" then
        BubbleLoot_G.eventFrames.RegisterSoloChatEvents()
	elseif subCommand == "OS" then
		BubbleLoot_G.rollerCollection:FillOS()
        BubbleLoot_G:Draw()
	else
	end
	--[[
    -- List loaded plugins.
    elseif subCommand == "plugins" then
        print(BubbleLoot_G:PluginsToString())

    -- is plugin test being called?
    else
        local plugin = BubbleLoot_G:FindPlugin(subCommand)
        if plugin ~= nil then
            plugin:SlashCmd(subArgs)
        else
            printError(cfg.texts.TEST_PARAMETER_ERROR)
        end
    end--]]
end

-- No need to be part of a group for this to work.
local function addItemToPlayer(args)
    -- Parameter check.
    if not args then
        printError(cfg.texts.ADDLOOTTOPLAYER_PARAMETER_ERROR)
        return
    end
	
	local playerName, itemName = args:match("^(%S+)%s(.+)$")
	
	--print(itemName)
	
	
	local item, itemLink,_,_,_,_,_,_,_  = GetItemInfo(itemName)
		
	if playerName and itemLink then
		BubbleLoot_G.storage.AddPlayerData(playerName,  itemLink )
		print("Added item '" .. item .. "' to character '" .. playerName .. "'")
	else
		if playerName and itemName then
			print("function addItemToPlayer can't get the itemlink from name : itemName "..itemName)
		else
			print("Usage: /bl add <characterName> <itemName>")
		end
	end

end


local function getPlayerData(playerName)
    -- Parameter check.
    if not playerName then
        printError(cfg.texts.GETPLAYERDATA_PARAMETER_ERROR)
        return
    end
		
	if playerName then
		BubbleLoot_G.storage.GetPlayerData(playerName)
	else
		print("Usage: /bl get <characterName>")
	end

end


local function getPlayerScore(playerName)
	-- Parameter check.
    if not playerName then
        printError("Usage: /bl playerScore <playerName>")
        return
    end
	
	if playerName then
		local score = BubbleLoot_G.calculation.GetPlayerScore(playerName)
		print(score)
	else
		printError("Usage: /bl playerScore <playerName>")
	end
	
end

local function sendData(playerName)
	
	--Broadcast everything
	BubbleLoot_G.sync.BroadcastDataTable("RaidData", RaidData, playerName)
	BubbleLoot_G.sync.BroadcastDataTable("PlayersData", PlayersData, playerName)
	BubbleLoot_G.sync.BroadcastDataTable("RaidLootData", RaidLootData, playerName)
	
end

-- Slash commands.
SLASH_BUBBLELOOT1 = '/bubbleloot'
SLASH_BUBBLELOOT2 = '/bl'
SlashCmdList["BUBBLELOOT"] = function(msg, editbox)
    local command, args = strsplit(" ", msg, 2)

    if command == "" then
        print(cfg.texts.LIST_CMDS)
    elseif command == "show" then
        BubbleLoot_G.gui:SetVisibility(true)
    elseif command == "hide" then
        BubbleLoot_G.gui:SetVisibility(false)
    elseif command == "toggle" then
        BubbleLoot_G.gui:SetVisibility(not BubbleLootData[cfg.SHOWN])
    elseif command == "help" then
        Help()
    elseif command == "reset" then
        Clear(args)
    elseif command == "resize" then
        Resize(args)
    elseif command == "test" then
        Test(args)
	elseif command == "add" then
		addItemToPlayer(args)
	elseif command == "get" then
		getPlayerData(args)
	elseif command == "playerScore" then
		getPlayerScore(args)
	elseif command == "send" then
		sendData(args)
    else
        printError(cfg.texts.SLASH_PARAMETER_ERROR)
    end
end
