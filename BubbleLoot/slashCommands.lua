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
	
	print(itemName)
	
	if playerName and itemName then
		BubbleLoot_G.storage.AddPlayerData(playerName,  itemName )
		print("Added item '" .. itemName .. "' to character '" .. playerName .. "'")
	else
		print("Usage: /bl add <characterName> <itemName>")
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


local function getItem(itemName)
	-- Parameter check.
    if not itemName then
        printError("Usage: /bl itemInfo <ItemName>")
        return
    end
	
	if itemName then
		BubbleLoot_G.calculation.GetItem(itemName)
	else
		printError("Usage: /bl itemInfo <ItemName>")
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
        BubbleLoot_G.gui:SetVisibility(not BubbleLootShown)
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
	elseif command == "itemInfo" then
		getItem(args)
	elseif command == "playerScore" then
		getPlayerScore(args)
    else
        printError(cfg.texts.SLASH_PARAMETER_ERROR)
    end
end
