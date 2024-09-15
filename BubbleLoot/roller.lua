-- Store info about individual rollers.
-- `roller = { name, characterText, subgroup, unitChanged, need, repeated, rollChanged }`.
-- Populate `BubbleLoot_G.rollerCollection`.

local cfg = BubbleLoot_G.configuration

---Represents an individual roller. Create by `BubbleLoot_G.roller:New()`.
---@class Roller
---@field name string full name (will include server)
---@field characterText string name, brackets, class (colored) - the unchanging parts.
---@field subgroup string
---@field groupTypeUnit string
---@field unitChanged boolean has unit info changed since the last draw?
---@field need integer
---@field repeated boolean has the player needed multiple times?
---@field needChanged boolean has the need changed since the last draw?
---@field UpdateNeed fun(self: Roller, need: integer)
---@field UpdateGroup fun(self: Roller, subgroup: string, groupTypeUnit: GroupTypeEnum)
---@field MakeUnitText fun(self: Roller) -> string
---@field MakeNeedText fun(self: Roller) -> string


-- Methods of the roller "instance".
local methods = {}

-- Update need and set connected flags.
function methods.UpdateNeed(self, need)
    self.repeated = true
    self.need = need
    self.needChanged = true
end

-- Update raid subgroup or group state.
function methods.UpdateGroup(self, subgroup, groupTypeUnit)
    self.subgroup = subgroup
    self.groupTypeUnit = groupTypeUnit
    self.unitChanged = true
end

--
function methods.MakeUnitText(self)
    local subgroupText = WrapTextInColorCode(self.subgroup, cfg.colors[self.groupTypeUnit])
    return ("%s[%s]"):format(self.characterText, subgroupText)
end

--
function methods.MakeNeedText(self)
	--print(self.need)
    if self.need == 9 then
        return WrapTextInColorCode(cfg.texts.PASS, cfg.colors.PASS)
	elseif self.need == 1 then
		return self.ColorTextIfMulti("+1", self.repeated)
	elseif self.need == 2 then
		return self.ColorTextIfMulti("+2", self.repeated)
	else
		return self.ColorTextIfMulti("Other", self.repeated)
	end
end

function methods.MakeScoreText(self)
	--return round2(BubbleLoot_G.calculation.GetPlayerScore(self.name),2)
	return round2(self.score,2)
end


function methods.ColorTextIfMulti(text, multi)
	if(multi) then
		return WrapTextInColorCode(text, cfg.colors.MULTINEED)
	else
		return text
	end
end

--
local function MakeCharacterText(name, class, classFilename)
    local classColour
    local classColourMixin = RAID_CLASS_COLORS[classFilename]
    if classColourMixin == nil then
        classColour = cfg.colors.UNKNOWN
    else
        classColour = classColourMixin.colorStr
    end
    local classText = WrapTextInColorCode(class, classColour)
    return ("%s (%s)"):format(name, classText)
end

---Create new "instance" of the Roller.
---@param name string
---@param need integer
---@param playerInfo PlayerInfo
---@return Roller
function BubbleLoot_G.roller.New(name, need, playerInfo)
    local characterText = MakeCharacterText(name, playerInfo.class, playerInfo.classFilename)
    -- Add fields.
    local roller = {
        name = name,
        characterText = characterText,
        subgroup = playerInfo.subgroup,
        groupTypeUnit = playerInfo.groupTypeUnit,
        unitChanged = true,
        need = need,
        repeated = false,
        needChanged = true,
		score = BubbleLoot_G.calculation.GetPlayerScore(name),
		chance = 0,
		cumulative_chance = 0,
    }
    -- Add methods.
    for funcName, func in pairs(methods) do
        roller[funcName] = func
    end

    return roller
end
