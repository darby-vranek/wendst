local SummoningItem = Class(function(self, inst)
    self.inst = inst
end)

function SummoningItem:CollectInventoryActions(doer, actions)
	-- print('registering summoning item')
	if doer:HasTag("ghostfriend_notsummoned") then
		table.insert(actions, ACTIONS.CASTSUMMON)
	elseif doer:HasTag("ghostfriend_summoned") then
		table.insert(actions, ACTIONS.COMMUNEWITHSUMMONED)
	end
end

function SummoningItem:CollectUseActions(doer, target, actions)
	-- print("collect use actions")
	if doer.components.ghostlybond ~= nil and target:HasTag("abby") then
		table.insert(actions, ACTIONS.CASTUNSUMMON)
	end
end

return SummoningItem