local function setsummoned(self)
	print("setsummoned")
	if self.summoned then
		self.inst:AddTag("ghostfriend_summoned")
	else
		self.inst:RemoveTag("ghostfriend_summoned")
	end
end

local function setnotsummoned(self)
	print("setnotsummoned")
	if self.notsummoned then
		self.inst:AddTag("ghostfriend_notsummoned")
	else
		self.inst:RemoveTag("ghostfriend_notsummoned")
	end
end

local function _ghost_onremove(self)
	print("_ghost_onremove")
	self.ghost = nil
	self:SpawnGhost()
end

local function _ghost_death(self)
	print("_ghost_death")
	-- self:SetBondLevel(1)
	self:Recall(true)
end


local GhostlyBond = Class(function(self, inst)
	print("ghostlybond constructor")
	self.inst = inst
	self.ghost = nil
	self.ghost_prefab = nil

	self.bondleveltimer = nil
	self.bondlevelmaxtime = nil
	self.paused = false

	self.bondlevel = 1
	self.maxbondlevel = 3

	self._ghost_onremove = function(ghost) _ghost_onremove(self) end
	self._ghost_death = function(ghost) _ghost_death(self, ghost) end

	-- this seems to be a DST only thing
	-- self.externalbondtimemultipliers = SourceModifierList(self.inst)

	inst:StartUpdatingComponent(self)
end,
nil,
{
	notsummoned = setnotsummoned,
	summoned = setsummoned,
})

function GhostlyBond:OnRemoveEntity()
	self.summoned = false
	self.notsummoned = false

	-- hack to remove ghosts when spawned due to session state reconstruction for autosave snapshots
	if self.ghost ~= nil and self.ghost.spawntime == GetTime() then
		self.inst:RemoveEventCallback("onremove", self._ghost_onremove, self.ghost)
		self.ghost:Remove()
	end
end

function GhostlyBond:OnSave()
	print("saved")
	return {
		ghost = self.ghost ~= nil and self.ghost:GetSaveRecord() or nil,
		ghostinlimbo = self.ghost ~= nil and self.ghost.inlimbo or nil,
	}
end

function GhostlyBond:OnLoad(data)
	print("GhostlyBond:OnLoad")
	print(self.ghost == nil)
	if data ~= nil then
		print("GhostlyBond:OnLoad | data ~= nil")
		if data.ghost ~= nil then
			print("GhostlyBond:OnLoad | data.ghost ~= nil")
			print(data.ghost.prefab)
			self.spawnghosttask:Cancel()
			self.spawnghosttask = nil
			-- local ghost = SpawnSaveRecord(data.ghost)
			-- self.ghost = ghost
			-- print(ghost)
			-- print(ghost.prefab)
		end
	end
end

-- bondlevel stuff goes here



-- end bondlevel stuff

function GhostlyBond:Init(ghost_prefab, bond_levelup_time)
	print("GhostlyBond:Init("..ghost_prefab..")")
	self.bondleveltimer = 0
	self.bondlevelmaxtime = bond_levelup_time
	self.ghost_prefab = ghost_prefab
 
	self.spawnghosttask = self.inst:DoTaskInTime(1, function() self:SpawnGhost() end)
end


function GhostlyBond:SpawnGhost()
	print("GhostlyBond:SpawnGhost()")
	local ghost = SpawnPrefab(self.ghost_prefab)
	self.ghost = ghost

	self.inst:ListenForEvent("onremove", self._ghost_onremove, ghost)
    self.inst:ListenForEvent("death", self._ghost_death, ghost)

    self:RecallComplete()
end

-- summoning stuff

function GhostlyBond:Summon(summoningitem)
	if self.ghost ~= nil and self.notsummoned then
		self.ghost.entity:SetParent(nil)
		self.ghost.Transform:SetPosition(self.inst.Transform:GetWorldPosition())
		self.ghost:ReturnToScene()

		self.notsummoned = false
		self.summoned = true

		if self.onsummonfn ~= nil then
			self.onsummonfn(self.inst, self.ghost)
		end

		return true
	end

	return false
end

function GhostlyBond:SummonComplete()
	self.notsummoned = false
	self.summoned = true

	if self.onsummoncompletefn ~= nil then
		self.onsummoncompletefn(self.inst, self.ghost)
	end
end

function GhostlyBond:Recall(was_killed)
	if self.ghost ~= nil and self.summoned and not self.inst.sg:HasStateTag("dissipate") then
		self.summoned = false

		if self.onrecallfn ~= nil then
			self.onrecallfn(self.inst, self.ghost, was_killed)
		end

		return true
	end
end

function GhostlyBond:RecallComplete()
    self.ghost:RemoveFromScene()
	self.ghost.entity:SetParent(self.inst.entity)
	self.ghost.Transform:SetPosition(0, 0, 0)

	self.summoned = false
	self.notsummoned = true

	if self.onrecallcompletefn ~= nil then
		self.onrecallcompletefn(self.inst, self.ghost)
	end
end


return GhostlyBond