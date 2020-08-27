local MakePlayerCharacter = require("prefabs/player_common")
local WendyFlowerOver = require("widgets/wendyflowerover")


local assets =
{
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
    Asset("SOUND", "sound/wendy.fsb"),

    Asset("ANIM", "anim/wendy_channel.zip"),
    Asset("ANIM", "anim/wendy_channel_flower.zip"),
    Asset("ANIM", "anim/wendy_mount_channel.zip"),
    Asset("ANIM", "anim/wendy_recall.zip"),
    Asset("ANIM", "anim/wendy_recall_flower.zip"),
    Asset("ANIM", "anim/wendy_mount_recall.zip"),
    Asset("ANIM", "anim/player_wendy_commune.zip"),
    Asset("ANIM", "anim/player_wendy_mount_commune.zip"),
    Asset("ANIM", "anim/wendy_flower_over.zip"),
    Asset("ANIM", "anim/player_idles_wendy.zip"),
}

local prefabs =
{
    "abby",
    "abby_flower",
    "abigailsummonfx",
    "abigailsummonfx_mount",
    "abigailunsummonfx",
    "abigailunsummonfx_mount",
}

local start_inv =
{
    "abby_flower"
}



local function OnBondLevelDirty(inst)
    print("OnBondLevelDirty")
    if inst.HUD ~= nil and not inst:HasTag("playerghost") then
        if inst.HUD.wendyflowerover == nil then
            inst.HUD.wendyflowerover = inst.HUD.overlayroot:AddChild(WendyFlowerOver(inst))
            inst.HUD.wendyflowerover:MoveToBack()
        end
        local bond_level = inst._bondlevel
        if bond_level > 1 then
            if inst.HUD.wendyflowerover ~= nil then
                inst.HUD.wendyflowerover:Play( bond_level )
            end
        end
    end
end

-- not sure if I need this
local function OnPlayerActivated(inst)
    print("OnPlayerActivated(inst)")
    if inst.HUD.wendyflowerover == nil and inst.components.pethealthbar ~= nil then
        inst.HUD.wendyflowerover = inst.HUD.overlayroot:AddChild(WendyFlowerOver(inst))
        inst.HUD.wendyflowerover:MoveToBack()
        -- OnClientPetSkinChanged( inst )
    end
    inst:ListenForEvent("onremove", OnPlayerDeactivated)
    -- if not TheWorld.ismastersim then
    --  inst:ListenForEvent("_bondleveldirty", OnBondLevelDirty)
    -- end
end

--------------------------------------------------------------------------

-- local function OnDespawn(inst)
--     print("OnDespawn(wendy)")
--     local abigail = inst.components.ghostlybond.ghost
--     if abigail ~= nil and abigail.sg ~= nil and not abigail.inlimbo then
--         if not abigail.sg:HasStateTag("dissipate") then
--             abigail.sg:GoToState("dissipate")
--         end
--         abigail:DoTaskInTime(25 * FRAMES, abigail.Remove)
--     end
-- end

local function ondeath(inst)
    inst.components.ghostlybond:Recall()
    inst.components.ghostlybond:PauseBonding()
end

local function onresurrection(inst)
    inst.components.ghostlybond:SetBondLevel(1)
    inst.components.ghostlybond:ResumeBonding()
end

local function ghostlybond_onlevelchange(inst, ghost, level, prev_level, isloading)
    print("ghostlybond_onlevelchange")
    inst._bondlevel = level

    if not isloading and inst.components.talker ~= nil and level > 1 then
        print("talker")
        inst.components.talker:Say(GetString("wendy", "ANNOUNCE_GHOSTLYBOND_LEVELUP", "LEVEL"..tostring(level)))
        OnBondLevelDirty(inst)
    end
    print("return to ghostlybond")
end

local function ghostlybond_onsummon(inst, ghost)
    if inst.components.sanity ~= nil then
        inst.components.sanity:DoDelta(TUNING.SANITY_MED)
    end
    -- inst.sg:GoToState("summon_abigail")
end

local function ghostlybond_onrecall(inst, ghost, was_killed)
    print("ghostlybond_onrecall")
    if inst.components.sanity ~= nil then
        inst.components.sanity:DoDelta(was_killed and (-TUNING.SANITY_MED * 2) or -TUNING.SANITY_MED)
    end

    if inst.components.talker ~= nil then
        inst.components.talker:Say(GetString("wendy", was_killed and "ANNOUNCE_ABIGAIL_DEATH" or "ANNOUNCE_ABIGAIL_RETRIEVE"))
    end
    -- inst.sg:GoToState("unsummon_abigail")
    inst.components.ghostlybond.ghost.sg:GoToState("dissipate")
end

local function ghostlybond_changebehaviour(inst, ghost)
 -- todo: toggle abigail between defensive and offensive
    if ghost.is_defensive then
        print("ghost:BecomeAggressive()")
        ghost:BecomeAggressive()
    else
        print("ghost:BecomeDefensive()")
        ghost:BecomeDefensive()
    end
    -- inst.sg:GoToState("commune_with_abigail")
    return true
end

-- local function update_sisturn_state(inst, is_active)
--  if inst.components.ghostlybond ~= nil then
--      if is_active == nil then
--          is_active = TheWorld.components.sisturnregistry ~= nil and TheWorld.components.sisturnregistry:IsActive()
--      end
--      inst.components.ghostlybond:SetBondTimeMultiplier("sisturn", is_active and TUNING.ABIGAIL_BOND_LEVELUP_TIME_MULT or nil)
--  end
-- end

local function CustomCombatDamage(inst, target)
    return (target.components.debuffable ~= nil and target.components.debuffable:HasDebuff("abigail_vex_debuff")) and TUNING.ABIGAIL_VEX_GHOSTLYFRIEND_DAMAGE_MOD 
        or (target == inst.components.ghostlybond.ghost and target:HasTag("abby")) and 0
        or 1
end

-------------------------------------------------------------------------------
-- local function OnSave(inst, data)
--     if inst.questghost ~= nil then
--         data.questghost = inst.questghost:GetSaveRecord()
--     end
-- end

-- local function OnLoad(inst, data)
--     if data ~= nil then
--      if data.abigail ~= nil then -- retrofitting
--          inst.components.inventory:GiveItem(SpawnPrefab("abigail_flower"))
--      end

--         if data.questghost ~= nil and inst.questghost == nil then
--             local questghost = SpawnSaveRecord(data.questghost)
--             if questghost ~= nil then
--                 if inst.migrationpets ~= nil then
--                     table.insert(inst.migrationpets, questghost)
--                 end
--                 questghost.SoundEmitter:PlaySound("dontstarve/common/ghost_spawn")
--                 questghost:LinkToPlayer(inst)
--             end
--         end
--     end
-- end


local function fn(inst)
    print("WENDST INIT")
    inst.soundsname = "wendy"
    inst:SetStateGraph("SGwilson")
    inst.MiniMapEntity:SetIcon("wendst.tex")
    inst.AnimState:SetBuild("wendy")
    
    inst.components.sanity.night_drain_mult = TUNING.WENDY_SANITY_MULT
    inst.components.sanity.neg_aura_mult = TUNING.WENDY_SANITY_MULT
    inst.components.combat.damagemultiplier = TUNING.WENDY_DAMAGE_MULT

    inst:AddTag("ghostlyfriend")

    inst:AddComponent("ghostlybond")
    print("added ghostlybond")
    inst.components.ghostlybond.onbondlevelchangefn = ghostlybond_onlevelchange
    inst.components.ghostlybond.onsummonfn = ghostlybond_onsummon
    inst.components.ghostlybond.onrecallfn = ghostlybond_onrecall
    inst.components.ghostlybond.changebehaviourfn = ghostlybond_changebehaviour
    inst.components.ghostlybond:Init("abby", TUNING.ABIGAIL_BOND_LEVELUP_TIME)

    inst.components.combat.customdamagemultfn = CustomCombatDamage
    inst.AnimState:AddOverrideBuild("wendy_channel")
    inst.AnimState:AddOverrideBuild("player_idles_wendy")
    inst.AnimState:AddOverrideBuild("wendy_commune")

    -- inst._bondlevel = net_tinybyte(inst.GUID, "wendy._bondlevel", "_bondleveldirty")
    inst._bondlevel = inst.components.ghostlybond.bondlevel

    -- inst.OnDespawn = OnDespawn
    inst:ListenForEvent("death", ondeath)
end

return MakePlayerCharacter("wendst", prefabs, assets, fn, start_inv)