-- Collection of players who /rolled.
-- Populate `BubbleLoot_G.rollerCollection`.

local cfg = BubbleLoot_G.configuration
local tau = BubbleLoot_G.configuration.tau
local Seuil = BubbleLoot_G.configuration.seuilMultiplicatif

-- Array of player rolls.
---@type Roller[]
BubbleLoot_G.rollerCollection.values = {}
-- Are `self.values` rollers to be sorted during the next `Draw`?
BubbleLoot_G.rollerCollection.isSorted = false


-- On GROUP_ROSTER_UPDATE through `BubbleLoot_G.eventFunctions.OnGroupUpdate`.
function BubbleLoot_G.rollerCollection.UpdateGroup(self)
    local groupType = BubbleLoot_G:GetGroupType()

    for _, roller in ipairs(self.values) do
        local playerInfo = BubbleLoot_G.playerInfo:Get(roller.name, groupType)
        if roller.subgroup ~= playerInfo.subgroup then -- Raid subgroup number or group type changed.
            roller:UpdateGroup(playerInfo.subgroup, playerInfo.groupTypeUnit)
        end
    end
end

-- Redraw `unitText` of the roller who changed group (or left). Maybe all after group type change.
-- Redraw `needText` of all rollers and reorder (new roller or new roll).
-- Redraw `scoreText` of all rollers and reorder (new roller or new roll).

function BubbleLoot_G.rollerCollection.SortRollers(self, method)

	if method == 1 then -- sort with player score
		table.sort(self.values, function(lhs, rhs)
			--return lhs.need < rhs.need
			return lhs.score < rhs.score
		end)
	else -- sort with rand results
		table.sort(self.values, function(lhs, rhs)
			--return lhs.need < rhs.need
			return lhs.roll < rhs.roll
		end)	
	end

end


function BubbleLoot_G.rollerCollection.Draw(self)

	--print("rollerCollection.Draw")

	--PrintCallStack()
    local currentRow = 0
    local orderChanged = false

	local threshold = 9
	
	-- set the threshold
	for index, roller in ipairs(self.values) do
		if(roller.need<threshold)then
			threshold = roller.need
		end
	end
	
	
	if not self.isSorted then
		self:SortRollers(threshold)
        orderChanged = true
        self.isSorted = true
    end
	

	local i = 1
    for index, roller in ipairs(self.values) do
		if(roller.need<threshold+1)then
			-- unit
			local unitText = nil
			if orderChanged or roller.unitChanged then
				unitText = roller:MakeUnitText()
				roller.unitChanged = false
			end
			-- need
			local needText = nil
			if orderChanged or roller.needChanged then
				needText = roller:MakeNeedText()
				roller.needChanged = false
			end
			-- score & chance
			local scoreText = nil
			local chanceText = nil
			if orderChanged or roller.scoreTextChanged then
				--print("scoreTextChanged")
				scoreText = roller:MakeScoreText()				
				chanceText = roller:MakeChanceText()
				roller.scoreTextChanged = false
			end

			-- roll
			local rollText = nil
			if orderChanged or roller.rollChanged then
				rollText = roller:MakeRollText()
				roller.rollChanged = false
			end
			
			-- write
			BubbleLoot_G.gui:WriteRow(i, unitText, needText, scoreText, chanceText, rollText, roller.name)
			currentRow = i
			i = i+1		
		end
    end

    -- Hide unused rows.
    BubbleLoot_G.gui:HideTailRows(currentRow + 1)

    return currentRow, BubbleLoot_G.gui:GetRow(currentRow).unit
end


-- set scoreTextChanged to true
function BubbleLoot_G.rollerCollection.SetScoreTextChanged(self, playerName)
	local roller = self:FindRoller(playerName)
	if roller then 
		--print("SetScoreTextChanged")
		--print(roller.name)
		--print(roller.scoreTextChanged)
		--roller:UpdateScoreChance()
		-- update score
		roller.score = BubbleLoot_G.calculation.GetPlayerScore(roller.name)
		-- recalc all cumulative chance
		self:LootChanceRoller()
		
		--print(roller.scoreTextChanged)
		
		-- redrawn the frame
		BubbleLoot_G:Draw()
	end
end

--
---@return Roller? plugin Instance or nil if not found.
function BubbleLoot_G.rollerCollection.FindRoller(self, name)
    for _, roller in ipairs(self.values) do
        if name == roller.name then
            return roller
        end
    end
    return nil
end

-- return +1 rollers collection
function BubbleLoot_G.rollerCollection.IsMsRoller(self)

	for _, roller in ipairs(self.values) do
		if roller.need == 1 then return true end
	end
	
	return false
	
end

function BubbleLoot_G.rollerCollection.LootChanceRoller(self)

	local chance_sum = 0
	--print(self)
	--print("LootChanceRoller")

	-- first, set the highest score, rollers must already be sorted
	local HighestChance = 0
	for _, roller in ipairs(self.values) do
		--print(roller.name)
		--print(roller.need)
		--print(roller.score)
		if(roller.need == 1) then
			local score = roller.score
			--if roller.score>-2 then score = roller.score else score = -2 end
			roller.chance =	tau^(-score)
		else
			roller.chance = 0
		end

		if HighestChance < roller.chance then HighestChance = roller.chance end

	end


	-- then, compute cummulative chances
	for _, roller in ipairs(self.values) do		

		if roller.chance*Seuil < HighestChance then roller.chance = 0 end -- we remove the lowest chance.		
		chance_sum = chance_sum + roller.chance

	end
	
	if chance_sum == 0 then return end
	
	-- then normalized this chance to 10000 and compute cumulative chances
	local last_roller_chance = 0
	for _, roller in ipairs(self.values) do
		roller.chance =	roller.chance*10000/chance_sum
		roller.cumulative_chance = roller.chance+last_roller_chance
		last_roller_chance=roller.cumulative_chance

		-- need a refresh
		roller.scoreTextChanged = true

	end		
	
end

function BubbleLoot_G.rollerCollection.getTheWinner(self, value)
	for _, roller in ipairs(self.values) do
		if roller.cumulative_chance>value then 
			return roller.name 
		end
	end
	
	return "no winner"

end


-- Update `roller` (if exists) or create a new one.
function BubbleLoot_G.rollerCollection.Save(self, name, need, roll)

	--print("+1 save")

	local roller = self:FindRoller(name)

	--print(roller)
    
    if roller ~= nil then
        roller:UpdateNeed(need)
		roller:UpdateRoll(roll)
		--print(need)
		--print(roll)

		
		self.isSorted = false
		self:LootChanceRoller()
		roller:UpdateSR()
		
    else
		if need ~= nil then
			local groupType = BubbleLoot_G:GetGroupType()
			local playerInfo = BubbleLoot_G.playerInfo:Get(name, groupType)
			roller = BubbleLoot_G.roller.New(name, need, playerInfo)
			table.insert(self.values, roller)
			self.isSorted = false
			self:LootChanceRoller()
			roller:UpdateSR()
		end
    end

	

end

-- Update `roller` to increase its need (we want to remove it from the roller.
function BubbleLoot_G.rollerCollection.Demote(self, name)
	--print(name)
	local roller = self:FindRoller(name)
    
    if roller ~= nil then
        roller:UpdateNeed(roller.need +1)
		
		self.isSorted = false
		self:LootChanceRoller()
		
    else
		print("rollerCollection.Remove : the roller SHOULD exist")
    end
end


function BubbleLoot_G.rollerCollection. get_Rollers(self)

	local listOfMS_Rollers = {}

	for _, roller in ipairs(self.values) do
		if roller.need == 1 then
			table.insert(listOfMS_Rollers, roller.name)
		end
	end

	if #listOfMS_Rollers == 0 then
		for _, roller in ipairs(self.values) do
			table.insert(listOfMS_Rollers, roller.name)
		end
	end

	return listOfMS_Rollers
	
end


-- Fill test values.
function BubbleLoot_G.rollerCollection.Fill(self)
    for _, val in pairs(cfg.testFill) do
        self:Save(unpack(val))
    end
end

function BubbleLoot_G.rollerCollection.FillOS(self)
    for _, val in pairs(cfg.testFillOS) do
        self:Save(unpack(val))
    end
end

--
function BubbleLoot_G.rollerCollection.Clear(self)
    self.values = {}
end
