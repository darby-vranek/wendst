local assets=
{
	Asset("ANIM", "anim/examplefloatableitem.zip"),
	Asset("ATLAS", "images/inventoryimages/examplefloatableitem.xml")
}

local prefabs = {
}

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
	
	-- Check if Shipwrecked is enabled
	if IsDLCEnabled(CAPY_DLC) then
		-- Make floatable
		MakeInventoryFloatable(inst, "idle_water", "idle")
	end
	
    anim:SetBank("examplefloatableitem") -- Bank name, within the scml
    anim:SetBuild("examplefloatableitem") -- Build name, as seen in anim folder
    anim:PlayAnimation("idle")	-- Animation name
    
	-- Prevents this item from being lost
    inst:AddTag("irreplaceable")
	
    -------
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/examplefloatableitem.xml"
    
    return inst
end


return Prefab( "common/inventory/examplefloatableitem", fn, assets, prefabs) 
