-- Roblox Godbase Creator Store quarantine auditor.
-- Run only in an isolated Studio place or through a controlled Studio MCP flow.
-- This script DOES NOT execute asset code. It disables BaseScripts before scanning.

local HttpService = game:GetService("HttpService")
local Selection = game:GetService("Selection")

local SUSPICIOUS_PATTERNS = {
	{ label = "numeric-require", pattern = "require%s*%(%s*%d+%s*%)" },
	{ label = "loadstring", pattern = "loadstring%s*%(" },
	{ label = "http-get", pattern = "HttpGet%s*%(" },
	{ label = "http-service", pattern = "HttpService" },
	{ label = "insert-service-load", pattern = "LoadAsset%s*%(" },
	{ label = "getfenv", pattern = "getfenv%s*%(" },
	{ label = "setfenv", pattern = "setfenv%s*%(" },
	{ label = "require-dynamic", pattern = "require%s*%(%s*[^%\"']" },
}

local ASSET_ID_PATTERNS = {
	"rbxassetid://(%d+)",
	"https?://www%.roblox%.com/asset/%?id=(%d+)",
	"https?://create%.roblox%.com/store/asset/(%d+)",
}

local function selectedRoot(): Instance
	local selected = Selection:Get()
	if #selected ~= 1 then
		error("Select exactly one quarantined root Model/Folder before running the audit")
	end
	return selected[1]
end

local function increment(map: {[string]: number}, key: string)
	map[key] = (map[key] or 0) + 1
end

local function safeFullName(instance: Instance): string
	local ok, value = pcall(function()
		return instance:GetFullName()
	end)
	return ok and value or instance.Name
end

local root = selectedRoot()
local report = {
	schemaVersion = 1,
	generatedAtUnix = os.time(),
	root = {
		name = root.Name,
		className = root.ClassName,
		fullName = safeFullName(root),
	},
	counts = {
		totalDescendants = 0,
		classes = {},
		baseScriptsDisabled = 0,
		scripts = 0,
		localScripts = 0,
		moduleScripts = 0,
		meshParts = 0,
		parts = 0,
		decals = 0,
		textures = 0,
		sounds = 0,
		animations = 0,
		particleEmitters = 0,
		lights = 0,
		constraints = 0,
		prompts = 0,
	},
	scriptFindings = {},
	assetDependencies = {},
	warnings = {},
}

local dependencySet: {[string]: boolean} = {}

local function recordDependency(id: string, path: string, propertyName: string)
	local key = id .. "|" .. path .. "|" .. propertyName
	if dependencySet[key] then
		return
	end
	dependencySet[key] = true
	table.insert(report.assetDependencies, {
		assetId = id,
		path = path,
		property = propertyName,
	})
end

local function scanAssetString(value: any, path: string, propertyName: string)
	if type(value) ~= "string" or value == "" then
		return
	end
	for _, pattern in ASSET_ID_PATTERNS do
		for id in string.gmatch(value, pattern) do
			recordDependency(id, path, propertyName)
		end
	end
end

local function tryProperty(instance: Instance, propertyName: string)
	local ok, value = pcall(function()
		return (instance :: any)[propertyName]
	end)
	if ok then
		scanAssetString(value, safeFullName(instance), propertyName)
	end
end

local descendants = root:GetDescendants()
report.counts.totalDescendants = #descendants

for _, instance in descendants do
	increment(report.counts.classes, instance.ClassName)
	local path = safeFullName(instance)

	if instance:IsA("BaseScript") then
		local ok, err = pcall(function()
			instance.Disabled = true
		end)
		if ok then
			report.counts.baseScriptsDisabled += 1
		else
			table.insert(report.warnings, "could not disable " .. path .. ": " .. tostring(err))
		end
	end

	if instance:IsA("Script") then
		report.counts.scripts += 1
	elseif instance:IsA("LocalScript") then
		report.counts.localScripts += 1
	elseif instance:IsA("ModuleScript") then
		report.counts.moduleScripts += 1
	elseif instance:IsA("MeshPart") then
		report.counts.meshParts += 1
	elseif instance:IsA("BasePart") then
		report.counts.parts += 1
	elseif instance:IsA("Decal") then
		report.counts.decals += 1
	elseif instance:IsA("Texture") then
		report.counts.textures += 1
	elseif instance:IsA("Sound") then
		report.counts.sounds += 1
	elseif instance:IsA("Animation") then
		report.counts.animations += 1
	elseif instance:IsA("ParticleEmitter") then
		report.counts.particleEmitters += 1
	elseif instance:IsA("Light") then
		report.counts.lights += 1
	elseif instance:IsA("Constraint") then
		report.counts.constraints += 1
	elseif instance:IsA("ProximityPrompt") or instance:IsA("ClickDetector") or instance:IsA("DragDetector") then
		report.counts.prompts += 1
	end

	if instance:IsA("LuaSourceContainer") then
		local ok, source = pcall(function()
			return instance.Source
		end)
		if ok and type(source) == "string" then
			local matches = {}
			for _, rule in SUSPICIOUS_PATTERNS do
				if string.find(source, rule.pattern) then
					table.insert(matches, rule.label)
				end
			end
			for id in string.gmatch(source, "require%s*%(%s*(%d+)%s*%)") do
				recordDependency(id, path, "Source.require")
			end
			if #matches > 0 then
				table.insert(report.scriptFindings, {
					path = path,
					className = instance.ClassName,
					patterns = matches,
					sourceLength = #source,
				})
			end
		else
			table.insert(report.warnings, "Source unavailable for " .. path)
		end
	end

	-- Common content/dependency properties. Failed property reads are ignored.
	for _, propertyName in {
		"MeshId", "TextureID", "TextureId", "SoundId", "AnimationId",
		"Image", "Video", "ColorMap", "MetalnessMap", "NormalMap", "RoughnessMap",
	} do
		tryProperty(instance, propertyName)
	end
end

local scriptTotal = report.counts.scripts + report.counts.localScripts + report.counts.moduleScripts
if scriptTotal >= 20 then
	table.insert(report.warnings, "large script audit surface: " .. tostring(scriptTotal))
end
if report.counts.totalDescendants >= 5000 then
	table.insert(report.warnings, "very large instance tree: " .. tostring(report.counts.totalDescendants))
end
if #report.scriptFindings > 0 then
	table.insert(report.warnings, "suspicious source patterns require human review; patterns are signals, not proof of maliciousness")
end

local json = HttpService:JSONEncode(report)
print("GODBASE_QUARANTINE_AUDIT_BEGIN")
print(json)
print("GODBASE_QUARANTINE_AUDIT_END")
print(string.format(
	"Audit complete: %d descendants, %d script containers, %d suspicious-script findings, %d asset dependencies",
	report.counts.totalDescendants,
	scriptTotal,
	#report.scriptFindings,
	#report.assetDependencies
))

return report
