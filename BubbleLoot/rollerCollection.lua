-- Collection of players who /rolled.
-- Populate `BubbleLoot_G.rollerCollection`.

local cfg = BubbleLoot_G.configuration
local tau = BubbleLoot_G.configuration.tau

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

function BubbleLoot_G.rollerCollection.Draw(self)
    local currentRow = 0
    local orderChanged = false

    if not self.isSorted then
        table.sort(self.values, function(lhs, rhs)
            --return lhs.need < rhs.need
			return lhs.score < rhs.score
        end)

        orderChanged = true
        self.isSorted = true
    end

	local threshold = 9
	
	-- set the threshold
	for index, roller in ipairs(self.values) do
		if(roller.need<threshold)then
			threshold = roller.need
		end
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
			-- roll
			local needText = nil
			if orderChanged or roller.rollChanged then
				needText = roller:MakeNeedText()
				roller.rollChanged = false
			end
			-- score
			local scoreText = nil
			if orderChanged or roller.rollChanged then
				scoreText = roller:MakeScoreText()
				roller.scoreTextChanged = false
			end
			
			-- write
			BubbleLoot_G.gui:WriteRow(i, unitText, needText, scoreText)
			currentRow = i
			i = i+1		
		end
    end

    -- Hide unused rows.
    BubbleLoot_G.gui:HideTailRows(currentRow + 1)

    return currentRow, BubbleLoot_G.gui:GetRow(currentRow).unit
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
	
	-- first, compute brut chance
	for _, roller in ipairs(self.values) do
		if(roller.need == 1) then
			roller.chance =	2^(roller.score/tau)	
			chance_sum = chance_sum + roller.chance
		else
			roller.chance = 0
		end
	end
	
	-- then normalized this chance to 10000 and compute cumulative chances
	local last_roller_chance = 0
	for _, roller in ipairs(self.values) do
		roller.chance =	roller.chance*10000/chance_sum
		roller.cumulative_chance = roller.chance+last_roller_chance
		last_roller_chance=roller.cumulative_chance
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
function BubbleLoot_G.rollerCollection.Save(self, name, need)
    local roller = self:FindRoller(name)
    if roller ~= nil then
        roller:UpdateNeed(need)
    else
        local groupType = BubbleLoot_G:GetGroupType()
        local playerInfo = BubbleLoot_G.playerInfo:Get(name, groupType)
        roller = BubbleLoot_G.roller.New(name, need, playerInfo)
        table.insert(self.values, roller)
    end
    self.isSorted = false
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
