-- Collection of players who /rolled.
-- Populate `BubbleLoot_G.rollerCollection`.

local cfg = BubbleLoot_G.configuration

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
-- Redraw `RollText` of all rollers and reorder (new roller or new roll).
function BubbleLoot_G.rollerCollection.Draw(self)
    local currentRow = 0
    local orderChanged = false

    if not self.isSorted then
        table.sort(self.values, function(lhs, rhs)
            return lhs.roll > rhs.roll
        end)

        orderChanged = true
        self.isSorted = true
    end

    for index, roller in ipairs(self.values) do
        -- unit
        local unitText = nil
        if orderChanged or roller.unitChanged then
            unitText = roller:MakeUnitText()
            roller.unitChanged = false
        end
        -- roll
        local rollText = nil
        if orderChanged or roller.rollChanged then
            rollText = roller:MakeRollText()
            roller.rollChanged = false
        end
        -- write
        BubbleLoot_G.gui:WriteRow(index, unitText, rollText)
        currentRow = index
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

-- Update `roller` (if exists) or create a new one.
function BubbleLoot_G.rollerCollection.Save(self, name, roll)
    local roller = self:FindRoller(name)
    if roller ~= nil then
        roller:UpdateRoll(roll)
    else
        local groupType = BubbleLoot_G:GetGroupType()
        local playerInfo = BubbleLoot_G.playerInfo:Get(name, groupType)
        roller = BubbleLoot_G.roller.New(name, roll, playerInfo)
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

--
function BubbleLoot_G.rollerCollection.Clear(self)
    self.values = {}
end
