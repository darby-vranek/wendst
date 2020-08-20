local assets =
{
    Asset("ANIM", "anim/abigail_flower.zip"),
    Asset("ANIM", "anim/abigail_flower_rework.zip"),

    -- Asset("INV_IMAGE", "abigail_flower_level0"),
    -- Asset("INV_IMAGE", "abigail_flower_level2"),
    -- Asset("INV_IMAGE", "abigail_flower_level3"),
    -- I'm not quite happy with this but I'll make some adjustments so that I don't have to add in the new 
    Asset("INV_IMAGE", "abigail_flower"),
    Asset("INV_IMAGE", "abigail_flower2"),
    Asset("INV_IMAGE", "abigail_flower_haunted"),

    -- Asset("INV_IMAGE", "abigail_flower_old"),        -- deprecated, left in for mods
    -- Asset("INV_IMAGE", "abigail_flower2"),           -- deprecated, left in for mods
    -- Asset("INV_IMAGE", "abigail_flower_haunted"),    -- deprecated, left in for mods
    -- Asset("INV_IMAGE", "abigail_flower_wilted"), -- deprecated, left in for mods
}

local prefabs =
{
}

local function UpdateInventoryActions(inst)
    inst:PushEvent("inventoryitem_updatetooltip")
end

local function UpdateInventoryIcon(inst, player, level)
    -- if inst._playerlink ~= player then
        -- if inst._playerlink ~= nil then
        --  inst:RemoveEventCallback("ghostlybond_level_change", inst._updateinventoryiconfn, inst._playerlink)
        -- end

        if player ~= nil and player.components.ghostlybond ~= nil then
            inst._playerlink = player
            inst:ListenForEvent("ghostlybond_level_change", inst._updateinventoryiconfn, inst._playerlink)

            UpdateInventoryActions(inst)
            if inst._inventoryactionstask == nil then
                inst._inventoryactionstask = inst:DoPeriodicTask(0.0, UpdateInventoryActions)
            end
        -- else
        --  inst._playerlink = nil

        --  if inst._inventoryactionstask ~= nil then
        --      inst._inventoryactionstask:Cancel()
        --      inst._inventoryactionstask = nil
        --  end
        end
    -- end

    level = level or (player ~= nil and player.components.ghostlybond ~= nil) and player.components.ghostlybond.bondlevel or 0
    if level == 1 then
        inst.components.inventoryitem:ChangeImageName("abigail_flower")
    elseif level == 2 then
        inst.components.inventoryitem:ChangeImageName("abigail_flower2")
    else
        inst.components.inventoryitem:ChangeImageName("abigail_flower_haunted")
    end
    inst._bond_level = level
end

local function UpdateGroundAnimation(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
 --    local players = {}
    -- if not POPULATING then
    --  for i, v in ipairs(AllPlayers) do
    --      if v:HasTag("ghostlyfriend") and not v.replica.health:IsDead() and not v:HasTag("playerghost") and v.components.ghostlybond ~= nil and v.entity:IsVisible() and (v.sg == nil or not v.sg:HasStateTag("ghostbuild")) then
    --          local dist = v:GetDistanceSqToPoint(x, y, z)
    --          if dist < TUNING.ABIGAIL_FLOWER_PROX_DIST then
    --              table.insert(players, {player = v, dist = dist})
    --          end
    --      end
    --  end
    -- end    

    -- if #players > 1 then
    --  table.sort(players, function(a, b) return a.dist < b.dist end)
    -- end

    -- local level = players[1] ~= nil and players[1].player.components.ghostlybond.bondlevel or 0
    local level = inst._playerlink ~= nil and inst._playerlink.components.ghostlybond.bondlevel or 0
    if inst._bond_level ~= level then
        if inst._bond_level == 0 then
            inst.AnimState:PlayAnimation("level"..level.."_pre")
            inst.AnimState:PushAnimation("level"..level.."_loop", true)
            -- the sound emitter isw a bit different in the DS version - switch to that if it doesn't work right
            -- changed sound path bc it's different in DS
            inst.SoundEmitter:PlaySound("dontstarve/common/haunted_flower_LP", "floating")
        elseif inst._bond_level > 0 and level == 0 then
            inst.AnimState:PlayAnimation("level"..inst._bond_level.."_pst")
            inst.AnimState:PushAnimation("level0_loop", true)
            inst.SoundEmitter:KillSound("floating")
        else
            inst.AnimState:PlayAnimation("level"..level.."_loop", true)
            inst.SoundEmitter:PlaySound("dontstarve/common/haunted_flower_LP", "floating")
        end
    end

    inst._bond_level = level
end

local function UnlinkFromPlayer(inst)
    if inst._playerlink ~= nil then
        inst:RemoveEventCallback("ghostlybond_level_change", inst._updateinventoryiconfn, inst._playerlink)
        inst._playerlink = nil
    end

    if inst._inventoryactionstask ~= nil then
        inst._inventoryactionstask:Cancel()
        inst._inventoryactionstask = nil
    end
end

local function topocket(inst, owner)
    if inst._incontainer ~= nil then
        inst:RemoveEventCallback("onopen", inst._oncontaineropenedfn, inst._incontainer)
        inst:RemoveEventCallback("onclose", inst._oncontainerclosedfn, inst._incontainer)
        inst._incontainer = nil
    end

    owner = owner or inst.components.inventoryitem.owner
    if owner.components.container ~= nil then
        inst._incontainer = owner
        inst:ListenForEvent("onopen", inst._oncontaineropenedfn, inst._incontainer)
        inst:ListenForEvent("onclose", inst._oncontainerclosedfn, inst._incontainer)

        owner = owner.components.container.opener
    end
    UpdateInventoryIcon(inst, owner)

    if inst._ongroundupdatetask ~= nil then
        inst._ongroundupdatetask:Cancel()
        inst._ongroundupdatetask = nil
    end
end

local function toground(inst)
    UnlinkFromPlayer(inst)

    if inst._incontainer ~= nil then
        inst:RemoveEventCallback("onopen", inst._oncontaineropenedfn, inst._incontainer)
        inst:RemoveEventCallback("onclose", inst._oncontainerclosedfn, inst._incontainer)
        inst._incontainer = nil
    end

    inst._bond_level = -1 -- to force the animation to update
    UpdateGroundAnimation(inst)
    if inst._ongroundupdatetask == nil then
        inst._ongroundupdatetask = inst:DoPeriodicTask(0.5, UpdateGroundAnimation)
    end
end

-- commenting out, this doesn't seem relevant to DS
-- local function OnEntitySleep(inst)
--  if inst._ongroundupdatetask ~= nil then
--      inst._ongroundupdatetask:Cancel()
--      inst._ongroundupdatetask = nil
--  end
-- end

-- local function OnEntityWake(inst)
--  if not inst.inlimbo and inst._ongroundupdatetask == nil then
--      inst._ongroundupdatetask = inst:DoPeriodicTask(0.5, UpdateGroundAnimation, math.random()*0.5)
--  end
-- end

-- commenting out until I implement elixirs
-- local function GetElixirTarget(inst, doer, elixir)
--  return (doer ~= nil and doer.components.ghostlybond ~= nil) and doer.components.ghostlybond.ghost or nil
-- end

local function getstatus(inst)
    return inst._bond_level == 3 and "LEVEL3"
        or inst._bond_level == 2 and "LEVEL2"
        or inst._bond_level == 1 and "LEVEL1"
        or nil
end

-- skins aren't a thing in DS
-- local function OnSkinIDDirty(inst)
--  inst.skin_id = inst.flower_skin_id:value()
-- end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()

    inst.AnimState:SetBank("abigail_flower_rework")
    inst.AnimState:SetBuild("abigail_flower_rework")
    inst.AnimState:PlayAnimation("level0_loop")
    MakeInventoryPhysics(inst)

    inst.MiniMapEntity:SetIcon("abigail_flower.png")

    if IsDLCEnabled(CAPY_DLC) then
        -- Make floatable
        MakeInventoryFloatable(inst, "small", 0.15, 0.9)
    end
    

    inst:AddTag("abby_flower")
    inst:AddTag("give_dolongaction")
    -- inst:AddTag("ghostlyelixirable") -- for ghostlyelixirable component

    -- inst.entity:SetPristine()
    
    -- inst.flower_skin_id = net_hash(inst.GUID, "abi_flower_skin_id", "abiflowerskiniddirty")
    -- inst:ListenForEvent("abiflowerskiniddirty", OnSkinIDDirty)

    -- if not TheWorld.ismastersim then
    --     return inst
    -- end

    inst:AddComponent("inventoryitem")
    inst:AddComponent("lootdropper")

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("summoningitem")

    -- inst:AddComponent("ghostlyelixirable")
    -- inst.components.ghostlyelixirable.overrideapplytotargetfn = GetElixirTarget

    -- inst:AddComponent("fuel")
    -- inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

 --    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    -- inst.components.burnable.fxdata = {}
 --    inst.components.burnable:AddBurnFX("campfirefire", Vector3(0, 0, 0))
    

    -- MakeSmallPropagator(inst)
    -- MakeHauntableLaunch(inst)

    inst._updateinventoryiconfn = function(player, data) UpdateInventoryIcon(inst, player, data.level) end
    inst._oncontaineropenedfn = function(container, data) UpdateInventoryIcon(inst, data.doer) end
    inst._oncontainerclosedfn = function(container, data) UnlinkFromPlayer(inst) end

    inst:ListenForEvent("onputininventory", topocket)
    inst:ListenForEvent("ondropped", toground)

    -- inst.OnEntitySleep = OnEntitySleep
    -- inst.OnEntityWake = OnEntityWake

    inst._ongroundupdatetask = inst:DoPeriodicTask(0.5, UpdateGroundAnimation, math.random()*0.5)
    UpdateInventoryIcon(inst, nil, 0)

    return inst
end


local assets_summonfx =
{
    Asset("ANIM", "anim/wendy_channel_flower.zip"),
    -- Asset("ANIM", "anim/wendy_mount_channel_flower.zip"),
}

local assets_unsummonfx =
{
    Asset("ANIM", "anim/wendy_recall_flower.zip"),
    -- Asset("ANIM", "anim/wendy_mount_recall_flower.zip"),
}

local assets_levelupfx =
{
    Asset("ANIM", "anim/abigail_flower_change.zip"),
}

local function AlignToTarget(inst)
    local parent = inst.entity:GetParent()
    if parent ~= nil then
        inst.Transform:SetRotation(parent.Transform:GetRotation())
    end
end

local function MakeSummonFX(anim, use_anim_for_build, is_mounted)
    return function()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()

        inst:AddTag("FX")

        -- if is_mounted then
     --        inst.Transform:SetSixFaced()
        -- else
            inst.Transform:SetFourFaced()
        -- end

    
        inst.AnimState:SetBank(anim)
        if use_anim_for_build then
            inst.AnimState:SetBuild(anim)
            inst.AnimState:OverrideSymbol("flower", "abigail_flower_rework", "flower")
        else
            inst.AnimState:SetBuild("abigail_flower_rework")
        end
        inst.AnimState:PlayAnimation(anim)

        -- if is_mounted then
        --  inst:AddComponent("updatelooper")
        --  inst.components.updatelooper:AddOnWallUpdateFn(AlignToTarget)
        -- end

        -- inst.entity:SetPristine()

        -- if not TheWorld.ismastersim then
        --     return inst
        -- end

        -- inst.persists = false

        --Anim is padded with extra blank frames at the end
        inst:ListenForEvent("animover", inst.Remove)

        return inst
    end
end

return Prefab("abby_flower", fn, assets, prefabs),
    Prefab("abigailsummonfx", MakeSummonFX("wendy_channel_flower", true, false), assets_summonfx),
    -- Prefab("abigailsummonfx_mount", MakeSummonFX("wendy_mount_channel_flower", true, true), assets_summonfx),
    Prefab("abigailunsummonfx", MakeSummonFX("wendy_recall_flower", false, false), assets_unsummonfx),
    -- Prefab("abigailunsummonfx_mount", MakeSummonFX("wendy_mount_recall_flower", false, true), assets_unsummonfx),
    Prefab("abigaillevelupfx", MakeSummonFX("abigail_flower_change", false, false), assets_levelupfx)







-- {
-- 	Asset("ANIM", "anim/abigail_flower.zip"),
-- 	--Asset("SOUND", "sound/common.fsb"),
--     Asset("INV_IMAGE", "abigail_flower"),
--     Asset("INV_IMAGE", "abigail_flower2"),
--     Asset("INV_IMAGE", "abigail_flower_haunted"),

-- }
 
-- local prefabs = 
-- {
-- }

-- local function UpdateInventoryActions(inst)
--     inst:PushEvent("inventoryitem_updatetooltip")
-- end

-- local function UpdateInventoryIcon(inst, player, level)
--     if player ~= nil and player.components.ghostlybond ~= nil then
--         inst._playerlink = player
--         inst:ListenForEvent("ghostlybond_level_change", inst._updateinventoryiconfn, inst._playerlink)
--         UpdateInventoryActions(inst)
--         if inst._inventoryactionstask == nil then
--             inst._inventoryactionstask = inst:DoPeriodicTask(0.0, UpdateInventoryActions)
--         end
--     end

--     level = level or (player ~= nil and player.components.ghostlybond ~= nil) and player.components.ghostlybond.bondlevel or 0
--     if level == 1 then
--         inst.components.inventoryitem:ChangeImageName("abigail_flower")
--     else
--         inst.components.inventoryitem:ChangeImageName("abigail_flower2")
--     end
--     inst._bond_level = level
-- end













-- local function getstatus(inst)
--     if inst.components.cooldown:IsCharged() then
--         if inst.components.inventoryitem.owner then
--             return "HAUNTED_POCKET"
--         else
--             return "HAUNTED_GROUND"
--         end
--     end
	
-- 	local time_charge = inst.components.cooldown:GetTimeToCharged()
--     if time_charge < TUNING.TOTAL_DAY_TIME*.5 then
--         return "SOON"
--     elseif time_charge < TUNING.TOTAL_DAY_TIME*2 then
--         return "MEDIUM"
--     else
--         return "LONG"
--     end
    
-- end

-- local function updateimage(inst)
-- 	if inst.components.cooldown:IsCharged() then
-- 	    inst.components.inventoryitem:ChangeImageName("abigail_flower_haunted")
-- 		inst.AnimState:PlayAnimation("haunted_pre")
-- 		inst.AnimState:PushAnimation("idle_haunted_loop", true)
-- 		inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )
-- 		inst:DoTaskInTime(0, function()
-- 			if not inst.SoundEmitter:PlayingSound("loop") then
-- 				inst.SoundEmitter:PlaySound("dontstarve/common/haunted_flower_LP", "loop")
-- 			end
-- 		end)
	    
-- 	else
-- 		inst.AnimState:SetBloomEffectHandle( "" )
-- 		if inst.components.cooldown:GetTimeToCharged() < TUNING.TOTAL_DAY_TIME then
-- 			inst.components.inventoryitem:ChangeImageName("abigail_flower2")
-- 			inst.AnimState:PlayAnimation("idle_2")
-- 		else
-- 			inst.components.inventoryitem:ChangeImageName("abigail_flower")
-- 		    inst.AnimState:PlayAnimation("idle_1")

-- 		end
-- 	end
-- end

-- local function startcharging(inst)
-- 	updateimage(inst)
-- end

-- local function oncharged(inst)
-- 	updateimage(inst)
-- end

-- local function ondeath(inst, deadthing)
--     if inst and deadthing and inst.components.inventoryitem and inst:IsValid() and deadthing:IsValid() and inst.components.inventoryitem.owner == nil and not deadthing:HasTag("wall") and inst:GetDistanceSqToInst(deadthing) < 16*16 then
--         if inst.components.cooldown:IsCharged() then
--             GetPlayer().components.sanity:DoDelta(-TUNING.SANITY_HUGE)
--             -- local abigail = SpawnPrefab("abby")
--             -- abigail.Transform:SetPosition(inst.Transform:GetWorldPosition())
--             inst.SoundEmitter:PlaySound("dontstarve/common/ghost_spawn")
--             inst:Remove()
--         end
--     end
-- end

-- local function topocket(inst)
--     inst.SoundEmitter:KillAllSounds()
-- end

-- local function toground(inst)
--     if inst.components.cooldown:IsCharged() then
--         inst.SoundEmitter:PlaySound("dontstarve/common/haunted_flower_LP", "loop")
--     end
--     inst:DoTaskInTime(0.5,function() updateimage(inst) end)
-- end

-- local function fn(Sim)
-- 	local inst = CreateEntity()
-- 	local trans = inst.entity:AddTransform()
-- 	local anim = inst.entity:AddAnimState()
--     local sound = inst.entity:AddSoundEmitter()
--     anim:SetBank("abigail_flower")
--     anim:SetBuild("abigail_flower")
--     anim:PlayAnimation("idle1")
--     MakeInventoryPhysics(inst)
--     inst:AddTag("irreplaceable")
    
--     local minimap = inst.entity:AddMiniMapEntity()
--     minimap:SetIcon( "abigail_flower.png" )
    

--     inst:AddComponent("inventoryitem")
--     -----------------------------------
    
--     inst:AddComponent("inspectable")
--     inst.components.inspectable.getstatus = getstatus

--     --inst.components.inventoryitem:ChangeImageName("heat_rock"..tostring(range))
--     inst:AddComponent("cooldown")
--     inst.components.cooldown.cooldown_duration = TUNING.TOTAL_DAY_TIME + math.random()*TUNING.TOTAL_DAY_TIME*2
--     inst.components.cooldown.onchargedfn = oncharged
--     inst.components.cooldown.startchargingfn = startcharging
--     inst.components.cooldown:StartCharging()
    
--     inst:ListenForEvent("daytime", function() updateimage(inst) end, GetWorld())
--     inst:ListenForEvent("dusktime", function() updateimage(inst) end, GetWorld())
--     inst:ListenForEvent("nighttime", function() updateimage(inst) end, GetWorld())
    

--     inst:ListenForEvent("entity_death", function(world, data) ondeath(inst, data.inst) end, GetWorld())

--     inst:ListenForEvent("onputininventory", topocket)
--     inst:ListenForEvent("ondropped", toground)    

--     inst:AddComponent("characterspecific")
--     inst.components.characterspecific:SetOwner("wendst")


--     inst:DoTaskInTime(0, function() 
-- 		-- if GetPlayer() or GetPlayer().prefab ~= "wendst" then inst:Remove() end 
		
-- 		-- for k,v in pairs(Ents) do
-- 		-- 	if v.prefab == "abby" then
-- 		-- 		v:Remove()
-- 		-- 	end
-- 		-- end
		
-- 		updateimage(inst)
-- 	end)

--     inst:AddComponent("summoningitem")
--     inst.UpdateInventoryActions = function(inst)
--         inst:PushEvent("inventoryitem_updatetooltip")
--     end
--     inst:UpdateInventoryActions()

--     return inst
-- end

-- return Prefab( "common/abby_flower", fn, assets, prefabs) 
