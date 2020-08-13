local MakePlayerCharacter = require "prefabs/player_common"
-- local TUNING = GLOBAL.TUNING


local assets = {
	Asset( "ANIM", "anim/player_basic.zip" ),
    Asset( "ANIM", "anim/player_idles_shiver.zip" ),
    Asset( "ANIM", "anim/player_actions.zip" ),
    Asset( "ANIM", "anim/player_actions_axe.zip" ),
    Asset( "ANIM", "anim/player_actions_pickaxe.zip" ),
    Asset( "ANIM", "anim/player_actions_shovel.zip" ),
    Asset( "ANIM", "anim/player_actions_blowdart.zip" ),
    Asset( "ANIM", "anim/player_actions_eat.zip" ),
    Asset( "ANIM", "anim/player_actions_item.zip" ),
    Asset( "ANIM", "anim/player_actions_uniqueitem.zip" ),
    Asset( "ANIM", "anim/player_actions_bugnet.zip" ),
    Asset( "ANIM", "anim/player_actions_fishing.zip" ),
    Asset( "ANIM", "anim/player_actions_boomerang.zip" ),
    Asset( "ANIM", "anim/player_bush_hat.zip" ),
    Asset( "ANIM", "anim/player_attacks.zip" ),
    Asset( "ANIM", "anim/player_idles.zip" ),
    Asset( "ANIM", "anim/player_rebirth.zip" ),
    Asset( "ANIM", "anim/player_jump.zip" ),
    Asset( "ANIM", "anim/player_amulet_resurrect.zip" ),
    Asset( "ANIM", "anim/player_teleport.zip" ),
    Asset( "ANIM", "anim/wilson_fx.zip" ),
    Asset( "ANIM", "anim/player_one_man_band.zip" ),
    Asset( "ANIM", "anim/shadow_hands.zip" ),
    Asset( "SOUND", "sound/sfx.fsb" ),
    Asset( "SOUND", "sound/wilson.fsb" ),
    Asset( "ANIM", "anim/beard.zip" ),

    Asset( "ANIM", "anim/wendy.zip" ),
}

local prefabs = {
    "abby",
    "abby_flower",
}

local start_inv = {
    "abby_flower",
}

-- listeners

local function ghostlybond_onrecall(inst, ghost, was_killed)
    if inst.components.sanity ~= nil then
        inst.components.sanity:DoDelta(was_killed and (-TUNING.SANITY_MED * 2) or -TUNING.SANITY_MED)
    end

    if inst.components.talker ~= nil then
        inst.components.talker:Say(GetString("wendy", was_killed and "ANNOUNCE_ABIGAIL_DEATH" or "ANNOUNCE_ABIGAIL_RETRIEVE"))
    end

    inst.components.ghostlybond.ghost.sg:GoToState("dissipate")
end

local function ghostlybond_onsummon(inst, ghost)
    if inst.components.sanity ~= nil then
        inst.components.sanity:DoDelta(TUNING.SANITY_MED)
    end

    if inst.components.talker ~= nil then
        inst.components.talker:Say(GetString("wendy", "ANNOUNCE_ABIGAIL_SUMMON", "LEVEL"..inst.components.ghostlybond.bondlevel))
    end
end

local function ghostlybond_onlevelchange(inst, ghost, level, prev_level, isloading)
    inst._bondlevel:set(level)

    if not isloading and inst.components.talker ~= nil and level > 1 then
        inst.components.talker:Say(GetString("wendy", "ANNOUNCE_GHOSTLYBOND_LEVELUP", "LEVEL"..level))
        -- that's what I'd use to do the flowerover anim
        -- OnBondLevelDirty(inst)
    end
end


local fn = function(inst)
    print("WENDST INIT")
	inst.soundsname = "wendy"
	inst.MiniMapEntity:SetIcon("wendst.tex")
    inst.AnimState:SetBuild("wendy")

    -- given that this is the default, i'm not sure that I need to include it, but I can test that later
	inst.components.health:SetMaxHealth(150)
	inst.components.hunger:SetMax(150)
	inst.components.sanity:SetMax(200)

    inst:AddTag("ghostlyfriend")

    print("adding ghostlybond")
    inst:AddComponent("ghostlybond")
    inst.components.ghostlybond.onbondlevelchangefn = ghostlybond_onlevelchange
    inst.components.ghostlybond.onrecallfn = ghostlybond_onrecall
    inst.components.ghostlybond.onsummonfn = ghostlybond_onsummon
    inst.components.ghostlybond:Init("abby", TUNING.TOTAL_DAY_TIME)
    -- inst:DoTaskInTime(0, function() inst.components.ghostlybond:Init("abby") end)
    

    

    -- inst.OnSave = onsave
    -- inst.OnLoad = onload

    -- I need to see if I can include the idle animations from DST - I should in general see if I can use those

    -- taken directly from DS wendy.lua
    inst.components.sanity.night_drain_mult = TUNING.WENDY_SANITY_MULT
    inst.components.sanity.neg_aura_mult = TUNING.WENDY_SANITY_MULT
    inst.components.combat.damagemultiplier = TUNING.WENDY_DAMAGE_MULT

end

return MakePlayerCharacter("wendst", prefabs, assets, fn, start_inv)