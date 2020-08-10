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
	self.inst.ghost = ghost
end


function GhostlyBond:SpawnSavedGhost()
	print("spawn saved ghost")
	local ghost = SpawnSaveRecord(self.ghost_prefab)
	self.inst.ghost = ghost
	-- self.inst.components.leader:AddFollower(ghost)
	self.ghost = ghost

	-- self.ghost:RemoveFromScene()
	-- self.ghost.entity:SetParent(self.inst.entity)
	-- self.ghost.Transform:SetPosition(0, 0, 0)
end

return GhostlyBond