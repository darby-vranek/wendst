local GhostlyBond = Class(function(self, inst)
	print("ghostlybond constructor")
	self.inst = inst
	self.ghost_prefab = nil
	self.ghost = nil
end)

function GhostlyBond:Init(ghost_prefab)
	print("init ghost")
	self.ghost_prefab = ghost_prefab
	self.spawnghosttask = self.inst:DoTaskInTime(0, function() self:SpawnGhost() end)
end

function GhostlyBond:InitSaved(ghost_data)
	self.ghost_prefab = ghost_data
	self.spawnsavedghosttask = self.inst:DoTaskInTime(0, function() self:SpawnSavedGhost() end)
end

function GhostlyBond:SpawnGhost()
	print("spawn ghost")
	local ghost = SpawnPrefab(self.ghost_prefab)
	self.ghost = ghost
end

function GhostlyBond:OnLoad(data)
	print("load ghostlybond")
	if data.ghost ~= nil then
		self.spawnghosttask:Cancel()
		self.spawnghosttask = nil

		local ghost = SpawnSaveRecord(data.ghost)
		self.ghost = ghost
	end
end

function GhostlyBond:OnSave()
	print("saved")
	return {
		ghost = self.ghost ~= nil and self.ghost:GetSaveRecord() or nil,
		ghostinlimbo = self.ghost ~= nil and self.ghost.inlimbo or nil,
	}
end


-- function GhostlyBond:SpawnSavedGhost()
-- 	print("spawn saved ghost")
-- 	local ghost = SpawnSaveRecord(self.ghost_prefab)
-- 	self.inst.ghost = ghost
-- 	-- self.inst.components.leader:AddFollower(ghost)
-- 	self.ghost = ghost

-- 	-- self.ghost:RemoveFromScene()
-- 	-- self.ghost.entity:SetParent(self.inst.entity)
-- 	-- self.ghost.Transform:SetPosition(0, 0, 0)
-- end

return GhostlyBond