require "stategraphs/SGghost"

-- local assets =
-- {
-- 	Asset("ANIM", "anim/ghost.zip"),
-- 	Asset("ANIM", "anim/ghost_wendy_build.zip"),
-- 	Asset("SOUND", "sound/ghost.fsb"),
-- }

-- local prefabs = 
-- {
-- }

local assets =
{
    Asset("ANIM", "anim/player_ghost_withhat.zip"),
    Asset("ANIM", "anim/ghost_abigail_build.zip"),
    Asset("ANIM", "anim/ghost_abigail.zip"),
    Asset("SOUND", "sound/ghost.fsb"),
}

local prefabs = 
{
    "abigail_attack_fx",
    "abigail_attack_fx_ground",
    "abigail_retaliation",
    "abigailforcefield",
    "abigaillevelupfx",
    "abigail_vex_debuff",
}
 
-- commenting this out for now because I haven't written abbybrain
-- require "brains/abbybrain"
require "brains/abigailbrain"

local function UpdateGhostlyBondLevel(inst, level)
    local max_health = level == 3 and TUNING.ABIGAIL_HEALTH_LEVEL3
                    or level == 2 and TUNING.ABIGAIL_HEALTH_LEVEL2
                    or TUNING.ABIGAIL_HEALTH_LEVEL1

    local health_comp = inst.components.health
    if health_comp ~= nil then
        if health_comp:IsDead() then
            health_comp.maxhealth = max_health
        else
            local health_percent = health_comp:GetPercent()
            health_comp:SetMaxHealth(max_health)
            health_comp:SetPercent(health_percent, true)
        end

        if inst._playerlink ~= nil and inst._playerlink.components.pethealthbar ~= nil then
            inst._playerlink.components.pethealthbar:SetMaxHealth(max_health)
        end
    end

    local light_vals = TUNING.ABIGAIL_LIGHTING[level] or TUNING.ABIGAIL_LIGHTING[1]
    if light_vals.r ~= 0 then
        inst.Light:Enable(not inst.inlimbo)
        inst.Light:SetRadius(light_vals.r)
        inst.Light:SetIntensity(light_vals.i)
        inst.Light:SetFalloff(light_vals.f)
    else
        inst.Light:Enable(false)
    end
    inst.AnimState:SetLightOverride(light_vals.l)
end
















local function Retarget(inst)

    local newtarget = FindEntity(inst, 20, function(guy)
            return  guy.components.combat and 
                    inst.components.combat:CanTarget(guy) and
                    (guy.components.combat.target == GetPlayer() or GetPlayer().components.combat.target == guy)
    end)

    return newtarget
end

local function OnAttacked(inst, data)
    --print(inst, "OnAttacked")
    local attacker = data.attacker

    if attacker and attacker:HasTag("player") then
        inst.components.health:SetVal(0)
    else
        inst.components.combat:SetTarget(attacker)
    end
end

local function auratest(inst, target)

    if target == GetPlayer() then return false end

    local leader = inst.components.follower.leader
    if target.components.combat.target and ( target.components.combat.target == inst or target.components.combat.target == leader) then return true end
    if inst.components.combat.target == target then return true end

    if leader then
        if leader == target then return false end
        if target.components.follower and target.components.follower.leader == leader then return false end
    end

    return (target:HasTag("monster") or target:HasTag("prey")) and inst.components.combat:CanTarget(target)
end

local function updatedamage(inst)
    if GetClock():IsDay() then
        inst.components.combat.defaultdamage = .5*TUNING.ABIGAIL_DAMAGE_PER_SECOND 
    elseif GetClock():IsNight() then
        inst.components.combat.defaultdamage = 2*TUNING.ABIGAIL_DAMAGE_PER_SECOND     
    elseif GetClock():IsDusk() then
        inst.components.combat.defaultdamage = TUNING.ABIGAIL_DAMAGE_PER_SECOND 
    end
end

local function DoAppear(sg)
    sg:GoToState("appear")
end
   


local function fn(Sim)
    print("abby.fn")
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
    local light = inst.entity:AddLight()

    MakeGhostPhysics(inst, 1, .5)
    
    light:SetIntensity(.6)
    light:SetRadius(.5)
    light:SetFalloff(.6)
    light:Enable(true)
    light:SetColour(180/255, 195/255, 225/255)
    
    local brain = require "brains/abigailbrain"
    inst:SetBrain(brain)
    
    anim:SetBank("ghost")
    anim:SetBuild("ghost_wendy_build")
    anim:SetBloomEffectHandle( "shaders/anim.ksh" )
    anim:PlayAnimation("idle", true)
    --inst.AnimState:SetMultColour(1,1,1,.6)
    
    inst:AddTag("character")
    inst:AddTag("scarytoprey")
    inst:AddTag("girl")
    inst:AddTag("ghost")
    inst:AddTag("noauradamage")
    inst:AddTag("notraptrigger")
    inst:AddTag("abby")

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = TUNING.ABIGAIL_SPEED*.5
    inst.components.locomotor.runspeed = TUNING.ABIGAIL_SPEED
    
    inst:SetStateGraph("SGghost")
    inst.sg.OnStart = DoAppear

    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.ABIGAIL_HEALTH)
    inst.components.health:StartRegen(1, 1)

	inst:AddComponent("combat")
    inst.components.combat.defaultdamage = TUNING.ABIGAIL_DAMAGE_PER_SECOND
    inst.components.combat.playerdamagepercent = TUNING.ABIGAIL_DMG_PLAYER_PERCENT
    inst.components.combat:SetRetargetFunction(3, Retarget)

    inst:AddComponent("aura")
    inst.components.aura.radius = 3
    inst.components.aura.tickperiod = 1
    inst.components.aura.ignoreallies = true
    inst.components.aura.auratestfn = auratest
    
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({"abigail_flower"})
    ------------------    
    
    inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_girl_howl_LP", "howl")
    
    inst:AddComponent("follower")
	local player = GetPlayer()
	if player and player.components.leader then
		player.components.leader:AddFollower(inst)
	end
    
	--inst:ListenForEvent( "daytime", function(tgi, data) inst.components.health:SetVal(0) end, GetWorld())
    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent( "dusktime", function() updatedamage(inst) end , GetWorld())
    inst:ListenForEvent( "daytime", function() updatedamage(inst) end , GetWorld())
    inst:ListenForEvent( "nighttime", function() updatedamage(inst) end , GetWorld())
    updatedamage(inst)
    return inst
end

return Prefab( "common/monsters/abby", fn, assets, prefabs ) 
