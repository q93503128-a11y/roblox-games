local TweenService = game:GetService("TweenService")
local Config = require(script.Parent.Config)
local Shared = require(script.Parent.Shared)

local EnemyService = {}
EnemyService.hooks = { playerHit = function() end, fx = function() end, onDeath = function() end }

local enemies, projectiles = {}, {}
local fxFolder

local function fx()
	if not fxFolder or not fxFolder.Parent then
		local root = workspace:FindFirstChild("SlayAndLoot")
		fxFolder = root and root:FindFirstChild("FX")
		if not fxFolder and root then
			fxFolder = Instance.new("Folder"); fxFolder.Name = "FX"; fxFolder.Parent = root
		end
	end
	return fxFolder
end

local function newPart(name, size, color, parent, material)
	local p = Instance.new("Part")
	p.Name = name; p.Size = size
	p.Anchored = true; p.CanCollide = false; p.CanQuery = false
	p.Material = material or Enum.Material.SmoothPlastic
	p.Color = color
	p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

local function buildBlockRig(kind, ec)
	local m = Instance.new("Model"); m.Name = kind
	local h = ec.height
	local function body(name, size, x, y, z, color, mat)
		local p = newPart(name, size, color, m, mat)
		p.CFrame = CFrame.new(x, y, z)
		return p
	end
	local torso = body("Torso", Vector3.new(h*0.55, h*0.42, h*0.35), 0, h*0.55, 0, ec.color)
	body("Head", Vector3.new(h*0.32, h*0.30, h*0.32), 0, h*0.86, 0, ec.color)
	body("EyeL", Vector3.new(h*0.07, h*0.06, h*0.05), -h*0.08, h*0.88, -h*0.16, Color3.fromRGB(255,196,80), Enum.Material.Neon)
	body("EyeR", Vector3.new(h*0.07, h*0.06, h*0.05),  h*0.08, h*0.88, -h*0.16, Color3.fromRGB(255,196,80), Enum.Material.Neon)
	body("ArmL", Vector3.new(h*0.14, h*0.42, h*0.14), -h*0.35, h*0.55, 0, ec.accent)
	body("ArmR", Vector3.new(h*0.14, h*0.42, h*0.14),  h*0.35, h*0.55, 0, ec.accent)
	body("LegL", Vector3.new(h*0.16, h*0.36, h*0.16), -h*0.14, h*0.18, 0, ec.accent)
	body("LegR", Vector3.new(h*0.16, h*0.36, h*0.16),  h*0.14, h*0.18, 0, ec.accent)
	if kind == "Grunt" or kind == "Brute" then
		local blade = newPart("Blade", Vector3.new(h*0.07, h*0.55, h*0.16), Color3.fromRGB(196,200,208), m, Enum.Material.Metal)
		blade.CFrame = CFrame.new(h*0.44, h*0.62, -h*0.10) * CFrame.Angles(math.rad(20), 0, math.rad(-12))
	end
	m.PrimaryPart = torso
	return m
end

local function buildBossRig()
	local q = game:GetService("ServerStorage"):FindFirstChild("Quarantine")
	q = q and q:FindFirstChild("Goblin_Q")
	if not q then return nil end
	local inner = q:FindFirstChild("GoblinKing") or q
	local clone = inner:Clone()
	for _, d in ipairs(clone:GetDescendants()) do
		if d:IsA("Humanoid") or d:IsA("Animator") or d:IsA("AnimationController")
			or d:IsA("KeyframeSequence") or d:IsA("Keyframe") or d:IsA("Pose") then
			d:Destroy()
		end
	end
	for _, d in ipairs(clone:GetDescendants()) do
		if d:IsA("BasePart") then
			d.Anchored = true; d.CanCollide = false; d.CanQuery = false
		end
	end
	pcall(function() clone:ScaleTo(1.75) end)
	clone.Name = "Boss"
	return clone
end

local function makeBar(part, height)
	local gui = Instance.new("BillboardGui")
	gui.Name = "HealthBar"
	gui.Size = UDim2.fromOffset(110, 9)
	gui.StudsOffset = Vector3.new(0, height * 0.62, 0)
	gui.MaxDistance = 150
	local bg = Instance.new("Frame")
	bg.Size = UDim2.fromScale(1, 1); bg.BackgroundColor3 = Color3.fromRGB(14,14,18)
	bg.BorderSizePixel = 0; bg.Parent = gui
	local fill = Instance.new("Frame")
	fill.Name = "Fill"; fill.Size = UDim2.fromScale(1, 1)
	fill.BackgroundColor3 = Color3.fromRGB(198,62,54); fill.BorderSizePixel = 0; fill.Parent = bg
	gui.Parent = part
	return fill
end

local function place(e)
	e.model:PivotTo(CFrame.new(e.pos.X, e.pos.Y + e.pivotOffset, e.pos.Z) * CFrame.Angles(0, e.yaw, 0))
end

function EnemyService.spawn(kind, worldPos, roomId, diff, centerAnchor)
	local ec = Config.Enemy[kind]
	if not ec then return nil end
	local model = (kind == "Boss") and buildBossRig() or nil
	if not model then model = buildBlockRig(kind, ec) end
	local cf, size = model:GetBoundingBox()
	local bottom = cf.Position.Y - size.Y / 2
	local e = {
		kind = kind, cfg = ec, roomId = roomId, roomCenter = centerAnchor,
		maxHp = math.floor(ec.hp * diff.hp), hp = 0,
		pos = Vector3.new(worldPos.X, worldPos.Y, worldPos.Z),
		yaw = 0, facing = Vector3.new(0,0,-1),
		state = "chase", t = 0, cd = 0.6, dead = false,
		pivotOffset = model:GetPivot().Position.Y - bottom,
		height = size.Y, attackStep = 0,
	}
	e.hp = e.maxHp
	e.model = model
	local barParent = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
	if not model.PrimaryPart then model.PrimaryPart = barParent end
	local barOff = (cf.Position.Y + size.Y / 2) - (barParent and barParent.Position.Y or cf.Position.Y) + 1.2
	e.bar = makeBar(barParent, barOff)
	model.Parent = fx()
	place(e)
	table.insert(enemies, e)
	return e
end

function EnemyService.clear()
	for _, e in ipairs(enemies) do
		if e.model and e.model.Parent then e.model:Destroy() end
	end
	enemies = {}
	for _, p in ipairs(projectiles) do
		if p.part and p.part.Parent then p.part:Destroy() end
	end
	projectiles = {}
end

function EnemyService.aliveInRoom(roomId)
	local n = 0
	for _, e in ipairs(enemies) do
		if not e.dead and e.roomId == roomId then n += 1 end
	end
	return n
end

local function killEnemy(e)
	if e.dead then return end
	e.dead = true
	if e.bar then e.bar.Parent.Parent.Enabled = false end
	if e.tele then e.tele:Destroy(); e.tele = nil end
	EnemyService.hooks.onDeath(e)
	local model = e.model
	task.spawn(function()
		for _, d in ipairs(model:GetDescendants()) do
			if d:IsA("BasePart") then
				TweenService:Create(d, TweenInfo.new(0.6), { Transparency = 0.92, Color = Color3.fromRGB(40,40,44) }):Play()
			end
		end
		task.wait(1.2)
		if model and model.Parent then model:Destroy() end
	end)
end

function EnemyService.hitArea(origin, lookDir, range, arcDeg, amount)
	local hits = 0
	for _, e in ipairs(enemies) do
		if not e.dead then
			local to = Shared.flat(e.pos - origin)
			local dist = to.Magnitude
			if dist <= range + (e.height * 0.3) then
				local ok = true
				if arcDeg < 359 and dist > 2.2 then
					ok = Shared.angleBetween(lookDir, to.Unit) <= arcDeg / 2
				end
				if ok then
					hits += 1
					EnemyService.damage(e, amount)
				end
			end
		end
	end
	return hits
end

function EnemyService.damage(e, amount)
	if e.dead then return end
	amount = math.max(1, math.floor(amount))
	e.hp -= amount
	if e.bar then
		TweenService:Create(e.bar, TweenInfo.new(0.12), { Size = UDim2.fromScale(math.clamp(e.hp / e.maxHp, 0, 1), 1) }):Play()
	end
	EnemyService.hooks.fx("hit", { pos = Vector3.new(e.pos.X, e.pos.Y + e.height * 0.55, e.pos.Z), amount = amount })
	if e.hp <= 0 then killEnemy(e) end
end

local function fireProjectile(e, targetPos)
	local p = newPart("Bolt", Vector3.new(1.5, 1.5, 1.5), Color3.fromRGB(196,150,255), fx(), Enum.Material.Neon)
	p.Shape = Enum.PartType.Ball
	p.CFrame = CFrame.new(e.pos + Vector3.new(0, e.height * 0.6, 0))
	local dir = Shared.flat(targetPos - e.pos)
	if dir.Magnitude < 0.01 then dir = Vector3.new(0, 0, -1) end
	table.insert(projectiles, { part = p, vel = dir.Unit * 52, dmg = e.cfg.dmg, life = 3.0 })
end

local function ring(e, radius, growTime)
	local t = newPart("Telegraph", Vector3.new(radius * 2, 0.3, radius * 2), Color3.fromRGB(255,70,50), fx(), Enum.Material.Neon)
	t.Shape = Enum.PartType.Cylinder
	t.Transparency = 0.7
	t.CFrame = CFrame.new(e.pos.X, 0.25, e.pos.Z) * CFrame.Angles(0, 0, math.rad(90))
	TweenService:Create(t, TweenInfo.new(growTime), { Transparency = 0.3 }):Play()
	return t
end

local function playerRoot(player)
	local char = player.Character
	return char and char:FindFirstChild("HumanoidRootPart")
end

local function strike(e, player)
	local ec = e.cfg
	local hrp = playerRoot(player)
	if not hrp then return end
	if e.kind == "Caster" then
		fireProjectile(e, hrp.Position)
		return
	end
	local to = Shared.flat(hrp.Position - e.pos)
	local dist = to.Magnitude
	local ang = dist > 0.6 and Shared.angleBetween(e.facing, to.Unit) or 0

	if e.kind == "Boss" and e.attackStep == 2 then
		if dist <= 19 then EnemyService.hooks.playerHit(ec.dmg * 1.2, e.pos) end
		EnemyService.hooks.fx("slam", { pos = e.pos, radius = 19 })
		return
	end
	if e.kind == "Boss" and e.attackStep == 3 then
		if dist <= 9 then EnemyService.hooks.playerHit(ec.dmg * 1.1, e.pos) end
		return
	end
	if e.kind == "Brute" then
		if dist <= 13 then EnemyService.hooks.playerHit(ec.dmg * 1.15, e.pos) end
		EnemyService.hooks.fx("slam", { pos = e.pos, radius = 13 })
		return
	end
	if dist <= ec.range + 2.5 and ang <= 75 then
		EnemyService.hooks.playerHit(ec.dmg, e.pos)
		EnemyService.hooks.fx("enemyHit", { pos = e.pos })
	end
end

local function windupTime(e)
	if e.kind == "Boss" then
		if e.attackStep == 2 then return 1.3 end
		if e.attackStep == 3 then return 0.8 end
		return 0.9
	end
	return e.cfg.windup
end

local function updateEnemy(e, dt, player)
	if e.dead then return end
	local hrp = playerRoot(player)
	local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if not hrp or not hum or hum.Health <= 0 then
		e.state = "idle"
		return
	end
	local target = Shared.flat(hrp.Position)
	local delta = target - e.pos
	local dist = delta.Magnitude
	local dir = dist > 0.01 and delta / dist or Vector3.new(0, 0, -1)
	e.facing = dir
	e.yaw = Shared.yawTo(e.pos, target)
	if e.cd > 0 then e.cd -= dt end

	local ec = e.cfg

	if e.state == "chase" or e.state == "idle" then
		e.state = "chase"
		if e.kind == "Caster" then
			if dist < 20 then
				e.pos -= dir * ec.speed * dt
			elseif dist > 34 then
				e.pos += dir * ec.speed * dt
			end
			if dist <= 36 and e.cd <= 0 then
				e.state = "windup"; e.t = 0
			end
		else
			if dist > ec.range * 0.75 then
				e.pos += dir * ec.speed * dt
			end
			if dist <= ec.range + 1.5 and e.cd <= 0 then
				e.state = "windup"; e.t = 0
				if e.kind == "Boss" then
					e.attackStep = (e.attackStep % 3) + 1
					if e.attackStep == 2 then e.tele = ring(e, 19, 1.3) end
				elseif e.kind == "Brute" then
					e.tele = ring(e, 13, 1.15)
				end
			end
		end
	elseif e.state == "windup" then
		e.t += dt
		local wu = windupTime(e)
		if e.kind == "Caster" then
			-- track the player during windup so the shot is readable, not homing
			e.yaw = Shared.yawTo(e.pos, target)
		end
		if e.t >= wu then
			strike(e, player)
			if e.tele then e.tele:Destroy(); e.tele = nil end
			if e.kind == "Boss" and e.attackStep == 3 then
				e.state = "dash"; e.t = 0; e.dashDir = dir
			else
				e.state = "recover"; e.t = 0
			end
		end
	elseif e.state == "dash" then
		e.t += dt
		e.pos += e.dashDir * (26 / 0.3) * dt
		if e.t >= 0.3 then e.state = "recover"; e.t = 0 end
	elseif e.state == "recover" then
		e.t += dt
		if e.t >= ec.recover then
			e.state = "chase"; e.cd = ec.cooldown
		end
	end

	-- stay inside the room footprint
	local center = e.roomCenter and Shared.anchorXZ(e.roomCenter)
	if center then
		local off = Shared.flat(e.pos - center)
		local limit = 27
		if off.Magnitude > limit then
			off = off.Unit * limit
			e.pos = center + off
		end
	end
	place(e)
end

local function updateProjectiles(dt, player)
	local hrp = playerRoot(player)
	local keep = {}
	for _, pr in ipairs(projectiles) do
		if pr.part and pr.part.Parent then
			pr.life -= dt
			pr.part.CFrame = pr.part.CFrame + pr.vel * dt
			local hit = false
			if hrp and (pr.part.Position - hrp.Position).Magnitude < 3.4 then
				EnemyService.hooks.playerHit(pr.dmg, pr.part.Position)
				hit = true
			end
			if hit or pr.life <= 0 then
				pr.part:Destroy()
			else
				table.insert(keep, pr)
			end
		end
	end
	projectiles = keep
end

function EnemyService.update(dt, player)
	updateProjectiles(dt, player)
	for _, e in ipairs(enemies) do
		updateEnemy(e, dt, player)
	end
end

return EnemyService
