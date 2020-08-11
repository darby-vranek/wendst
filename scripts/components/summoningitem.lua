local SummoningItem = Class(function(self, inst)
    self.inst = inst
end)

function SummoningItem:CollectInventoryActions(doer, actions)
	-- print('registering summoning item')
	-- if doer.components.ghostlybond ~= nil then
	table.insert(actions, ACTIONS.CASTSUMMON)
	-- end
end

function SummoningItem:CollectUseActions(doer, target, actions)
	-- print("collect use actions")
	if target:HasTag("abby") then
		table.insert(actions, ACTIONS.CASTUNSUMMON)
	end
end

return SummoningItem