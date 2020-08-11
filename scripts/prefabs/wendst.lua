local MakePlayerCharacter = require "prefabs/player_common"


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

local function onsave(inst, data)
    print("save")
    -- data.ghostlybond = inst.components.ghostlybond
    -- return {
    --     ghostlybond = inst.components.ghostlybond
    --     -- ghost = inst.components.ghostlybond.ghost ~= nil and inst.components.ghostlybond.ghost:GetSaveRecord() or nil,
    -- }
end

local onload = function(inst, data)
    print("loaded wendy")
    inst:AddComponent("ghostlybond")
    if data == nil then
        inst.components.ghostlybond:Init("abby")
        print('init abby complete')
    end
    -- print(data == nil)
    -- print("adding ghostlybond")
    -- inst:AddComponent("ghostlybond")
    -- inst.components.ghostlybond:Init("abby")


    -- if data.ghostlybond ~= nil then
    --     print("loaded ghostlybond")
    --     print(data.ghostlybond)
    --     -- inst.components.ghostlybond = data.ghostlybond
    --     inst:AddComponent(data.ghostlybond)
    --     inst.components.ghostlybond:Init("abby")
    -- else
    --     print("adding ghostlybond")
    --     inst:AddComponent("ghostlybond")
    --     inst.components.ghostlybond:Init("abby")
    -- end

    -- if inst.components.ghostlybond ~= nil then
    --     print("ghostlybond found")
    -- else
    --     print("adding ghostlybond")
    --     inst:AddComponent("ghostlybond")
    --     inst.components.ghostlybond:Init("abby")
    -- end

    -- if data.ghost ~= nil then
    --     inst.ghostlybond.spawnghosttask:Cancel()
    --     inst.components.ghostlybond.spawnghosttask = nil
    --     print("ghost found")
    --     inst.components.ghostlybond:InitSaved(data.ghost)
    -- else
    --     print("no ghost found")
    --     inst.components.ghostlybond:Init("abby")
    -- end

    -- if data.ghost ~= nil then
    --     print("saved ghost found")
    --     inst.components.ghostlybond.spawnghosttask:Cancel()
    --     inst.components.ghostlybond.spawnghosttask = nil
        
    -- else
    
    -- end
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

    print("adding ghostlybond")
    inst:AddComponent("ghostlybond")
    inst.components.ghostlybond:Init("abby")
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