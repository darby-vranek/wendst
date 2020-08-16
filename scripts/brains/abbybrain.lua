require "behaviours/follow"
require "behaviours/wander"


local AbbyBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local MIN_FOLLOW = 4
local MAX_FOLLOW = 11
local MED_FOLLOW = 6
local WANDER_TIMING = {minwaittime = 6, randwaittime = 6}
local MAX_WANDER_DIST = 10
local MAX_CHASE_TIME = 6


-- local fs
local function GetLeader(inst)
    return inst.components.follower.leader
end

local function GetLeaderPos(inst)
    return inst.components.follower.leader:GetPosition()
end

local function DefensiveCanFight(inst)
    local target = inst.components.combat.target
    if target ~= nil and not inst.auratest(inst, target) then
        inst.components.combat:GiveUp()
        return false
    end

    if inst:IsWithinDefensiveRange() then
        return true
    elseif inst._playerlink ~= nil and target ~= nil then
        inst.components.combat:GiveUp()
    end
    return false 
end

local MAX_AGGRESSIVE_FIGHT_DSQ = math.pow(TUNING.ABIGAIL_COMBAT_TARGET_DISTANCE + 2, 2)

local function AggressiveCanFight(inst)
    local target = inst.components.combat.target
    if target ~= nil and not inst.auratest(inst, target) then
        inst.components.combat:GiveUp()
        return false
    end
    if inst._playerlink then
        if inst:GetDistanceSqToInst(inst._playerlink) < MAX_AGGRESSIVE_FIGHT_DSQ then
            return true
        elseif target ~= nil then
            inst.components.combat:GiveUp()
        end
    end
    return false
end



local function GetFaceTargetFn(inst)
    return inst.components.follower.leader
end

local function KeepFaceTargetFn(inst, target)
    return inst.components.follower.leader == target
end

-- function AbbyBrain:OnStart()

--     local root = PriorityNode(
--     {
-- 		ChaseAndAttack(self.inst, MAX_CHASE_TIME),
-- 		Follow(self.inst, function() return self.inst.components.follower.leader end, MIN_FOLLOW, MED_FOLLOW, MAX_FOLLOW, true),
-- 		--FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
--         Wander(self.inst, function() return Point(GetPlayer().Transform:GetWorldPosition()) end , MAX_WANDER_DIST)        
--     }, .5)
        
--     self.bt = BT(self.i  nst, root)
         
-- end

function AbbyBrain:OnStart()
    local defensive_mode = WhileNode(function() return self.inst.is_defensive end, "DefensiveMove", 
    PriorityNode({
        -- dance,
        -- watch_game,
        
        WhileNode(function() return DefensiveCanFight(self.inst) end, "CanFight",
            ChaseAndAttack(self.inst, TUNING.DEfFENSIVE_MAX_CHASE_TIME)),
        
        Follow(self.inst, function() return self.inst.components.follower.leader end, 
                TUNING.ABIGAIL_DEFENSIVE_MIN_FOLLOW, TUNING.ABIGAIL_DEFENSIVE_MED_FOLLOW, TUNING.ABIGAIL_DEFENSIVE_MAX_FOLLOW, true),
        -- FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
        Wander(self.inst, nil, nil, WANDER_TIMING),
    }, .25)
)


    local aggressive_mode = PriorityNode({

        WhileNode(function() return AggressiveCanFight(self.inst) end, "CanFight",
            ChaseAndAttack(self.inst, TUNING.AGGRESSIVE_MAX_CHASE_TIME)),
        -- FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
        Follow(self.inst, function() return self.inst.components.follower.leader end,
                TUNING.ABIGAIL_AGGRESSIVE_MIN_FOLLOW, TUNING.ABIGAIL_AGGRESSIVE_MED_FOLLOW, TUNING.ABIGAIL_AGGRESSIVE_MAX_FOLLOW, true),
        -- FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
        Wander(self.inst),
    }, .25)

    local root = PriorityNode({
        defensive_mode,
        aggressive_mode,
    }, .25)

    self.bt = BT(self.inst, root)
end


return AbbyBrain