local Shared = {}

function Shared.anchor(name)
	local anc = workspace:FindFirstChild("SlayAndLoot")
	anc = anc and anc:FindFirstChild("Anchors")
	if not anc then return nil end
	local a = anc:FindFirstChild("Anchor_"..name)
	return a and a.Position or nil
end

function Shared.anchorXZ(name)
	local p = Shared.anchor(name)
	if not p then return nil end
	return Vector3.new(p.X, 0, p.Z)
end

function Shared.flat(v)
	return Vector3.new(v.X, 0, v.Z)
end

function Shared.yawTo(from, to)
	local d = Shared.flat(to - from)
	if d.Magnitude < 0.001 then return 0 end
	return math.atan2(-d.X, -d.Z)
end

function Shared.angleBetween(a, b)
	local d = a:Dot(b)
	d = math.clamp(d, -1, 1)
	return math.deg(math.acos(d))
end

return Shared
