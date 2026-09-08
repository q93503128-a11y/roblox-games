--!strict

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Protocol = require(ReplicatedStorage:WaitForChild("RebirthRPG"):WaitForChild("Shared"):WaitForChild("Protocol"))

local StudioSmokeHarness = {}

local ENABLE_ATTRIBUTE = "RebirthRPG_EnableSmokeHarness"
local ORIGIN_NAME = "RebirthRPG_SmokeOrigin"
local FOLDER_NAME = "_RebirthRPG_SmokeHarness"

local function stripExecutableDescendants(model: Model)
	for _, descendant in ipairs(model:GetDescendants()) do
		if descendant:IsA("Script") or descendant:IsA("LocalScript") or descendant:IsA("ModuleScript") then
			descendant:Destroy()
		end
	end
end

local function groundModel(model: Model, desiredCFrame: CFrame, ignoreInstances: { Instance })
	-- Start above the intended X/Z and raycast to the actual authored floor.
	-- This avoids assuming the R15 model pivot sits at its visual feet.
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = ignoreInstances
	raycastParams.IgnoreWater = false

	local rayOrigin = desiredCFrame.Position + Vector3.new(0, 80, 0)
	local rayResult = workspace:Raycast(rayOrigin, Vector3.new(0, -200, 0), raycastParams)
	if rayResult == nil then
		warn(string.format("[RebirthRPG] Smoke rig %s has no floor below its intended test position", model.Name))
		model:PivotTo(desiredCFrame)
		return
	end

	model:PivotTo(desiredCFrame)
	local boxCFrame, boxSize = model:GetBoundingBox()
	local visualBottomY = boxCFrame.Position.Y - boxSize.Y * 0.5
	local yCorrection = rayResult.Position.Y - visualBottomY + 0.05
	model:PivotTo(model:GetPivot() + Vector3.new(0, yCorrection, 0))
end

local function makeDebugEnemy(
	parent: Instance,
	origin: BasePart,
	enemyId: string,
	displayName: string,
	desiredCFrame: CFrame,
	scale: number
): Model
	local description = Instance.new("HumanoidDescription")
	local model = Players:CreateHumanoidModelFromDescriptionAsync(description, Enum.HumanoidRigType.R15)
	description:Destroy()

	stripExecutableDescendants(model)
	model.Archivable = true
	model.Name = displayName
	model:SetAttribute(Protocol.Attributes.EnemyId, enemyId)
	model:SetAttribute("SmokeHarness", true)
	model:ScaleTo(scale)
	groundModel(model, desiredCFrame, { parent, origin })
	model.Parent = parent

	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if humanoid ~= nil then
		humanoid.DisplayName = displayName
	end

	CollectionService:AddTag(model, Protocol.Tags.Enemy)
	return model
end

function StudioSmokeHarness.Start(): boolean
	if not RunService:IsStudio() then
		return false
	end
	if workspace:GetAttribute(ENABLE_ATTRIBUTE) ~= true then
		return false
	end

	local origin = workspace:FindFirstChild(ORIGIN_NAME, true)
	if origin == nil or not origin:IsA("BasePart") then
		warn(string.format("[RebirthRPG] Smoke harness enabled but %s BasePart is missing", ORIGIN_NAME))
		return false
	end

	local existing = workspace:FindFirstChild(FOLDER_NAME)
	if existing ~= nil then
		existing:Destroy()
	end

	local folder = Instance.new("Folder")
	folder.Name = FOLDER_NAME
	folder.Parent = workspace

	-- Studio-only validation lane, never production world art.
	-- All placement is relative to the explicit SmokeOrigin anchor.
	-- Distances deliberately keep later encounters outside their aggro ranges at test start.
	makeDebugEnemy(folder, origin, "enemy_field_a_01", "Smoke Enemy A", origin.CFrame * CFrame.new(0, 0, -16), 1.0)
	makeDebugEnemy(folder, origin, "enemy_field_b_01", "Smoke Enemy B", origin.CFrame * CFrame.new(65, 0, -16), 1.05)
	makeDebugEnemy(folder, origin, "boss_region_01", "Smoke Boss", origin.CFrame * CFrame.new(65, 0, -110), 1.45)

	print("[RebirthRPG] Studio smoke harness spawned relative to RebirthRPG_SmokeOrigin")
	return true
end

return StudioSmokeHarness
