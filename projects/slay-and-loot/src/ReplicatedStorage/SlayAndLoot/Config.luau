local Config = {}

Config.Difficulty = {
	Normal = { name = "Normal", hp = 1.0, dmg = 1.0, gold = 1.0, xp = 1.0, tier = 1, color = Color3.fromRGB(143,166,196) },
	Hard   = { name = "Hard",   hp = 2.2, dmg = 1.8, gold = 1.7, xp = 1.8, tier = 2, color = Color3.fromRGB(224,112,63) },
}

Config.Player = {
	maxHP = 120,
	baseDamage = 10,
	walkSpeed = 16,
}

Config.Combo = {
	{ mul = 1.00, range = 9.5,  arc = 115,  cd = 0.44, hitAt = 0.13 },
	{ mul = 1.15, range = 9.5,  arc = 120,  cd = 0.42, hitAt = 0.13 },
	{ mul = 2.00, range = 11.0, arc = 150, cd = 0.66, hitAt = 0.18 },
}
Config.Dash  = { distance = 24, duration = 0.20, cd = 1.5, invuln = 0.32 }
Config.Skill = { mul = 2.6, range = 17, cd = 6.5, hitAt = 0.22 }

Config.Enemy = {
	Grunt  = { hp = 45,  dmg = 9,  speed = 11,  range = 6.5, windup = 0.55, recover = 0.75, cooldown = 1.5,
	           gold = 6,  xp = 10,  height = 4.6, color = Color3.fromRGB(96,140,72),  accent = Color3.fromRGB(58,88,44) },
	Caster = { hp = 36,  dmg = 11, speed = 8,   range = 34,  windup = 0.85, recover = 1.10, cooldown = 2.4,
	           gold = 8,  xp = 14,  height = 4.4, color = Color3.fromRGB(110,96,150), accent = Color3.fromRGB(70,58,102) },
	Brute  = { hp = 240, dmg = 18, speed = 7.5, range = 8.5, windup = 1.15, recover = 1.30, cooldown = 2.2,
	           gold = 25, xp = 45,  height = 6.4, color = Color3.fromRGB(120,84,60),  accent = Color3.fromRGB(74,50,34) },
	Boss   = { hp = 700, dmg = 14, speed = 8,  range = 12,  windup = 0.90, recover = 1.00, cooldown = 1.8,
	           gold = 120, xp = 200, height = 8.0, color = Color3.fromRGB(150,60,60), accent = Color3.fromRGB(90,34,34) },
}

Config.Rarity = {
	Common    = Color3.fromRGB(184,190,199),
	Uncommon  = Color3.fromRGB(95,191,106),
	Rare      = Color3.fromRGB(74,143,224),
	Epic      = Color3.fromRGB(164,91,224),
	Legendary = Color3.fromRGB(224,163,63),
}

Config.Loot = {
	[1] = {
		{ id = "iron",   name = "Iron Blade",      rarity = "Common",    dmg = 4,  w = 50 },
		{ id = "steel",  name = "Steel Falchion",  rarity = "Uncommon",  dmg = 9,  w = 30 },
		{ id = "ember",  name = "Ember Edge",      rarity = "Rare",      dmg = 15, w = 15 },
		{ id = "dawn",   name = "Dawnbreaker",     rarity = "Epic",      dmg = 23, w = 5 },
	},
	[2] = {
		{ id = "hollow", name = "Hollowfang",      rarity = "Uncommon",  dmg = 16, w = 40 },
		{ id = "void",   name = "Voidsteel Cleaver", rarity = "Rare",    dmg = 24, w = 35 },
		{ id = "ashen",  name = "Ashen Kingsblade", rarity = "Epic",     dmg = 34, w = 20 },
		{ id = "star",   name = "Starfall Greatsword", rarity = "Legendary", dmg = 48, w = 5 },
	},
}

-- room order + spawn layout, all relative to named anchors
Config.Rooms = {
	{
		id = "A", label = "Ruined Hall", center = "RoomA_Center", radius = 30,
		gateIn = "RoomA_Entry",  gateInAxis = "Z", gateInW = 14, gateInH = 9,
		gateOut = "RoomA_ClearGate", gateOutAxis = "X", gateOutW = 14, gateOutH = 9,
		spawns = {
			{ kind = "Grunt", off = Vector3.new(-13, 0, -10) },
			{ kind = "Grunt", off = Vector3.new( 13, 0, -10) },
			{ kind = "Grunt", off = Vector3.new(  0, 0, -18) },
		},
	},
	{
		id = "B", label = "Flooded Vault", center = "RoomB_Center", radius = 34,
		gateIn = "RoomB_Entry",  gateInAxis = "Z", gateInW = 14, gateInH = 10,
		gateOut = "RoomB_ClearGate", gateOutAxis = "X", gateOutW = 14, gateOutH = 10,
		spawns = {
			{ kind = "Grunt",  off = Vector3.new(-10, 0, -6) },
			{ kind = "Grunt",  off = Vector3.new( 10, 0, -6) },
			{ kind = "Caster", off = Vector3.new( -8, 4, -25) },
			{ kind = "Caster", off = Vector3.new(  8, 4, -25) },
		},
	},
	{
		id = "C", label = "Deep Vault", center = "RoomC_Center", radius = 34,
		gateIn = "RoomC_Entry",  gateInAxis = "X", gateInW = 14, gateInH = 10,
		gateOut = "RoomC_NorthGate", gateOutAxis = "Z", gateOutW = 14, gateOutH = 10,
		spawns = {
			{ kind = "Brute", off = Vector3.new(  0, 0, -12) },
			{ kind = "Grunt", off = Vector3.new(-18, 0,   4) },
			{ kind = "Grunt", off = Vector3.new( 18, 0,   4) },
		},
	},
	{
		id = "Boss", label = "Goblin King", center = "BossArena_Center", radius = 40,
		gateIn = "BossArena_Entry", gateInAxis = "Z", gateInW = 14, gateInH = 10,
		gateOut = "Boss_NorthGate", gateOutAxis = "Z", gateOutW = 16, gateOutH = 14,
		spawns = {
			{ kind = "Boss", off = Vector3.new(0, 0, -18) },
		},
	},
}

Config.Travel = {
	startAt = "RoomA_Entry",
	hubAt = "HubCenter",
}

return Config
