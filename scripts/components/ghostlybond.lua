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
	self:SetBondLevel(1)
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

	self.bondtimemult = 4

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

function GhostlyBond:OnUpdate(dt)
	if self.bondleveltimer == nil or self.pause then
		self.inst:StopUpdatingComponent(self)
		return
	end

	self.bondleveltimer = self.bondleveltimer + (dt * self.bondtimemult)
	if self.bondleveltimer >= self.bondlevelmaxtime then
		self:SetBondLevel(self.bondlevel + 1, self.bondleveltimer - self.bondlevelmaxtime)
	end
end

function GhostlyBond:SetBondTimeMultiplier(src, mult, key)
	self.externalbondtimemultipliers:SetModifier(src, mult, key)
end

function GhostlyBond:ResumeBonding()
	self.pause = false
	if self.bondleveltimer ~= nil then
		self.inst:StartUpdatingComponent(self)
	end
end

function GhostlyBond:PauseBonding()
	self.pause = true
	self.inst:StopUpdatingComponent(self)
end

function GhostlyBond:SetBondLevel(level, time, isloading)
	time = time or 0
	local prev_level = self.bondlevel
	self.bondlevel = math.min(level, self.maxbondlevel)
	self.bondleveltimer = level < self.maxbondlevel and time or nil
	if self.bondleveltimer ~= nil and not self.paused then
		self.inst:StartUpdatingComponent(self)
	end

		if self.onbondlevelchangefn ~= nil then
			self.onbondlevelchangefn(self.inst, self.ghost, level, prev_level, isloading)
		end
		self.inst:PushEvent("ghostlybond_level_change", {ghost = self.ghost, level = level, prev_level = prev_level, isloading = isloading})
end

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

function GhostlyBond:ChangeBehaviour()
	if self.ghost ~= nil and self.summoned and self.changebehaviourfn ~= nil then
		return self.changebehaviourfn(self.inst, self.ghost)
	end
	return false
end

return GhostlyBond