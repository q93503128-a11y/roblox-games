local Config = require(script.Parent.Config)

local LootService = {}

function LootService.roll(tier)
	local table_ = Config.Loot[tier] or Config.Loot[1]
	local total = 0
	for _, e in ipairs(table_) do total += e.w end
	local r = math.random() * total
	local acc = 0
	for _, e in ipairs(table_) do
		acc += e.w
		if r <= acc then
			return { id = e.id, name = e.name, rarity = e.rarity, dmg = e.dmg }
		end
	end
	return { id = table_[1].id, name = table_[1].name, rarity = table_[1].rarity, dmg = table_[1].dmg }
end

return LootService
