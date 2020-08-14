local MakePlayerCharacter = require("prefabs/player_common")
local WendyFlowerOver = require("widgets/wendyflowerover")

local assets =
{
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
    Asset("SOUND", "sound/wendy.fsb"),

    Asset("ANIM", "anim/wendy_channel.zip"),
    -- Asset("ANIM", "anim/wendy_mount_channel.zip"),
    Asset("ANIM", "anim/wendy_recall.zip"),
    -- Asset("ANIM", "anim/wendy_mount_recall.zip"),
    Asset("ANIM", "anim/player_wendy_commune.zip"),
    -- Asset("ANIM", "anim/player_wendy_mount_commune.zip"),
    Asset("ANIM", "anim/wendy_flower_over.zip"),
    Asset("ANIM", "anim/player_idles_wendy.zip"),
}

local prefabs =
{
    "abigail",
    -- "lavaarena_abigail",
    "abby_flower",
    "abigailsummonfx",
    -- "abigailsummonfx_mount",
    "abigailunsummonfx",
    -- "abigailunsummonfx_mount",
}

local start_inv =
{
    "abby_flower"
}



local function OnBondLevelDirty(inst)
    if inst.HUD ~= nil and not inst:HasTag("playerghost") then
        local bond_level = inst._bondlevel:value()
        if bond_level > 1 then
            if inst.HUD.wendyflowerover ~= nil then
                inst.HUD.wendyflowerover:Play( bond_level )
            end
        end
    end
end

-- local function OnPlayerDeactivated(inst)
--     inst:RemoveEventCallback("onremove", OnPlayerDeactivated)
--     if not TheWorld.ismastersim then
--         inst:RemoveEventCallback("_bondleveldirty", OnBondLevelDirty)
--     end
-- end

-- local function OnClientPetSkinChanged(inst)
--  if inst.HUD ~= nil and inst.HUD.wendyflowerover ~= nil then
--      local skinname = TheInventory:LookupSkinname( inst.components.pethealthbar._petskin:value() )
--      inst.HUD.wendyflowerover:SetSkin( skinname )
--  end
-- end

-- not sure if I need this
local function OnPlayerActivated(inst)
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

local function OnDespawn(inst)
    local abigail = inst.components.ghostlybond.ghost
    if abigail ~= nil and abigail.sg ~= nil and not abigail.inlimbo then
        if not abigail.sg:HasStateTag("dissipate") then
            abigail.sg:GoToState("dissipate")
        end
        abigail:DoTaskInTime(25 * FRAMES, abigail.Remove)
    end
end

local function ondeath(inst)
    inst.components.ghostlybond:Recall()
    inst.components.ghostlybond:PauseBonding()
end

local function onresurrection(inst)
    inst.components.ghostlybond:SetBondLevel(1)
    inst.components.ghostlybond:ResumeBonding()
end

local function ghostlybond_onlevelchange(inst, ghost, level, prev_level, isloading)
    inst._bondlevel:set(level)

    if not isloading and inst.components.talker ~= nil and level > 1 then
        inst.components.talker:Say(GetString("wendy", "ANNOUNCE_GHOSTLYBOND_LEVELUP", "LEVEL"..tostring(level)))
        OnBondLevelDirty(inst)
    end
end

local function ghostlybond_onsummon(inst, ghost)
    if inst.components.sanity ~= nil then
        inst.components.sanity:DoDelta(TUNING.SANITY_MED)
    end
    if inst.components.talker ~= nil then
        inst.components.talker:Say(GetString("wendy", "ANNOUNCE_ABIGAIL_SUMMON", "LEVEL"..inst.components.ghostlybond.bondlevel))
    end
end

local function ghostlybond_onrecall(inst, ghost, was_killed)
    if inst.components.sanity ~= nil then
        inst.components.sanity:DoDelta(was_killed and (-TUNING.SANITY_MED * 2) or -TUNING.SANITY_MED)
    end

    if inst.components.talker ~= nil then
        inst.components.talker:Say(GetString("wendy", was_killed and "ANNOUNCE_ABIGAIL_DEATH" or "ANNOUNCE_ABIGAIL_RETRIEVE"))
    end

    inst.components.ghostlybond.ghost.sg:GoToState("dissipate")
end

-- local function ghostlybond_changebehaviour(inst, ghost)
--  -- todo: toggle abigail between defensive and offensive
--     if ghost.is_defensive then
--         ghost:BecomeAggressive()
--     else
--         ghost:BecomeDefensive()
--     end
    
--  return true
-- end

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
    -- inst.components.ghostlybond.changebehaviourfn = ghostlybond_changebehaviour
    inst.components.ghostlybond:Init("abby", TUNING.ABIGAIL_BOND_LEVELUP_TIME)

    inst.components.combat.customdamagemultfn = CustomCombatDamage

    -- inst:AddTag("elixirbrewer")

 --    if TheNet:GetServerGameMode() == "quagmire" then
 --        inst:AddTag("quagmire_grillmaster")
 --        inst:AddTag("quagmire_shopper")
    -- else
        -- inst:AddComponent("pethealthbar")
    -- end

    inst.AnimState:AddOverrideBuild("wendy_channel")

    -- inst._bondlevel = net_tinybyte(inst.GUID, "wendy._bondlevel", "_bondleveldirty")
    inst._bondlevel = inst.components.ghostlybond.bond_level

    inst.OnDespawn = OnDespawn

    -- inst:ListenForEvent("playeractivated", OnPlayerActivated)
    -- inst:ListenForEvent("playerdeactivated", OnPlayerDeactivated)
    inst:ListenForEvent("death", ondeath)

    
    -- inst:ListenForEvent("clientpetskindirty", OnClientPetSkinChanged)
end

-- local function master_postinit(inst)
    -- inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default

    -- inst.customidleanim = "idle_wendy"
    -- inst.AnimState:AddOverrideBuild("player_idles_wendy")

    -- inst.components.sanity.night_drain_mult = TUNING.WENDY_SANITY_MULT
    -- inst.components.sanity.neg_aura_mult = TUNING.WENDY_SANITY_MULT
    -- I'd like these two, but the sanity component doesn't have that built in yet and I'll have to deal with that later
    -- inst.components.sanity:AddSanityAuraImmunity("ghost")
    -- inst.components.sanity:SetPlayerGhostImmunity(true)

  --   if TheNet:GetServerGameMode() == "lavaarena" then
  --       event_server_data("lavaarena", "prefabs/wendy").master_postinit(inst, OnSave, OnLoad)
  --   elseif TheNet:GetServerGameMode() == "quagmire" then
        -- -- nothing special
  --   else
    -- inst:AddComponent("ghostlybond")
    -- inst.components.ghostlybond.onbondlevelchangefn = ghostlybond_onlevelchange
    -- inst.components.ghostlybond.onsummonfn = ghostlybond_onsummon
    -- inst.components.ghostlybond.onrecallfn = ghostlybond_onrecall
    -- inst.components.ghostlybond.changebehaviourfn = ghostlybond_changebehaviour
    
    -- inst.components.ghostlybond:Init("abby", TUNING.ABIGAIL_BOND_LEVELUP_TIME)

    -- inst.components.combat.customdamagemultfn = CustomCombatDamage

    -- inst:ListenForEvent("death", ondeath)
    -- inst:ListenForEvent("ms_becameghost", ondeath)
    -- inst:ListenForEvent("ms_respawnedfromghost", onresurrection)

    -- inst:ListenForEvent("onsisturnstatechanged", function(world, data) update_sisturn_state(inst, data.is_active) end, TheWorld)
    -- update_sisturn_state(inst)

    -- inst.components.combat.damagemultiplier = TUNING.WENDY_DAMAGE_MULT

    -- inst.OnDespawn = OnDespawn
    -- inst.OnSave = OnSave
    -- inst.OnLoad = OnLoad
    -- end
-- end

return MakePlayerCharacter("wendst", prefabs, assets, fn, start_inv)




-- local MakePlayerCharacter = require "prefabs/player_common"
-- -- local TUNING = GLOBAL.TUNING


-- local assets = {
--     Asset("SOUND", "sound/wendy.fsb"),

-- 	Asset( "ANIM", "anim/player_basic.zip" ),
--     Asset( "ANIM", "anim/player_idles_shiver.zip" ),
--     Asset( "ANIM", "anim/player_actions.zip" ),
--     Asset( "ANIM", "anim/player_actions_axe.zip" ),
--     Asset( "ANIM", "anim/player_actions_pickaxe.zip" ),
--     Asset( "ANIM", "anim/player_actions_shovel.zip" ),
--     Asset( "ANIM", "anim/player_actions_blowdart.zip" ),
--     Asset( "ANIM", "anim/player_actions_eat.zip" ),
--     Asset( "ANIM", "anim/player_actions_item.zip" ),
--     Asset( "ANIM", "anim/player_actions_uniqueitem.zip" ),
--     Asset( "ANIM", "anim/player_actions_bugnet.zip" ),
--     Asset( "ANIM", "anim/player_actions_fishing.zip" ),
--     Asset( "ANIM", "anim/player_actions_boomerang.zip" ),
--     Asset( "ANIM", "anim/player_bush_hat.zip" ),
--     Asset( "ANIM", "anim/player_attacks.zip" ),
--     Asset( "ANIM", "anim/player_idles.zip" ),
--     Asset( "ANIM", "anim/player_rebirth.zip" ),
--     Asset( "ANIM", "anim/player_jump.zip" ),
--     Asset( "ANIM", "anim/player_amulet_resurrect.zip" ),
--     Asset( "ANIM", "anim/player_teleport.zip" ),
--     Asset( "ANIM", "anim/wilson_fx.zip" ),
--     Asset( "ANIM", "anim/player_one_man_band.zip" ),
--     Asset( "ANIM", "anim/shadow_hands.zip" ),
--     Asset( "SOUND", "sound/sfx.fsb" ),
--     Asset( "SOUND", "sound/wilson.fsb" ),
--     Asset( "ANIM", "anim/beard.zip" ),

--     Asset("ANIM", "anim/wendy_flower_over.zip"),
--     Asset("ANIM", "anim/player_wendy_commune.zip"),
--     Asset("ANIM", "anim/wendy_recall.zip"),
--     Asset("ANIM", "anim/wendy_channel.zip"),

--     Asset( "ANIM", "anim/wendy.zip" ),
-- }

-- local prefabs = {
--     "abby",
--     "abby_flower",
--     "abigailsummonfx",
--     "abigailunsummonfx",
-- }

-- local start_inv = {
--     "abby_flower",
-- }

-- -- listeners

-- local function ghostlybond_onrecall(inst, ghost, was_killed)
--     if inst.components.sanity ~= nil then
--         inst.components.sanity:DoDelta(was_killed and (-TUNING.SANITY_MED * 2) or -TUNING.SANITY_MED)
--     end

--     if inst.components.talker ~= nil then
--         inst.components.talker:Say(GetString("wendy", was_killed and "ANNOUNCE_ABIGAIL_DEATH" or "ANNOUNCE_ABIGAIL_RETRIEVE"))
--     end

--     inst.components.ghostlybond.ghost.sg:GoToState("dissipate")
-- end

-- local function ghostlybond_onsummon(inst, ghost)
--     if inst.components.sanity ~= nil then
--         inst.components.sanity:DoDelta(TUNING.SANITY_MED)
--     end

--     if inst.components.talker ~= nil then
--         inst.components.talker:Say(GetString("wendy", "ANNOUNCE_ABIGAIL_SUMMON", "LEVEL"..inst.components.ghostlybond.bondlevel))
--     end
-- end

-- local function ghostlybond_onlevelchange(inst, ghost, level, prev_level, isloading)
--     inst._bondlevel:set(level)

--     if not isloading and inst.components.talker ~= nil and level > 1 then
--         inst.components.talker:Say(GetString("wendy", "ANNOUNCE_GHOSTLYBOND_LEVELUP", "LEVEL"..level))
--         -- that's what I'd use to do the flowerover anim
--         -- OnBondLevelDirty(inst)
--     end
-- end


-- local fn = function(inst)
--     print("WENDST INIT")
-- 	inst.soundsname = "wendy"
-- 	inst.MiniMapEntity:SetIcon("wendst.tex")
--     inst.AnimState:SetBuild("wendy")

--     -- given that this is the default, i'm not sure that I need to include it, but I can test that later
-- 	inst.components.health:SetMaxHealth(150)
-- 	inst.components.hunger:SetMax(150)
-- 	inst.components.sanity:SetMax(200)

--     inst:AddTag("ghostlyfriend")

--     print("adding ghostlybond")
--     inst:AddComponent("ghostlybond")
--     inst.components.ghostlybond.onbondlevelchangefn = ghostlybond_onlevelchange
--     inst.components.ghostlybond.onrecallfn = ghostlybond_onrecall
--     inst.components.ghostlybond.onsummonfn = ghostlybond_onsummon
--     inst.components.ghostlybond:Init("abby", TUNING.TOTAL_DAY_TIME)
--     -- inst:DoTaskInTime(0, function() inst.components.ghostlybond:Init("abby") end)
    

    

--     -- inst.OnSave = onsave
--     -- inst.OnLoad = onload

--     -- I need to see if I can include the idle animations from DST - I should in general see if I can use those

--     -- taken directly from DS wendy.lua
--     inst.components.sanity.night_drain_mult = TUNING.WENDY_SANITY_MULT
--     inst.components.sanity.neg_aura_mult = TUNING.WENDY_SANITY_MULT
--     inst.components.combat.damagemultiplier = TUNING.WENDY_DAMAGE_MULT

-- end

-- return MakePlayerCharacter("wendst", prefabs, assets, fn, start_inv)