local FRAMES = 1/30


AddStategraphState("wilson",
	State {
    name = "summon_abigail",
    tags = { "doing", "busy", "nodangle", "canrotate" },

    onenter = function(inst)
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("wendy_channel")
        inst.AnimState:PushAnimation("wendy_channel_pst", false)

        if inst.bufferedaction ~= nil then
			local flower = inst.bufferedaction.invobject
            if flower ~= nil then
                -- local skin_build = flower:GetSkinBuild()
                -- if skin_build ~= nil then
                --     inst.AnimState:OverrideItemSkinSymbol("flower", skin_build, "flower", flower.GUID, flower.AnimState:GetBuild() )
                -- else
                    inst.AnimState:OverrideSymbol("flower", flower.AnimState:GetBuild(), "flower")
                -- end
			end
            inst.sg.statemem.action = inst.bufferedaction
        end
    end,

    timeline =
    {
		TimeEvent(0 * FRAMES, function(inst)
			if inst.components.talker ~= nil and inst.components.ghostlybond ~= nil then
				inst.components.talker:Say(GetString("wendy", "ANNOUNCE_ABIGAIL_SUMMON", "LEVEL"..inst.components.ghostlybond.bondlevel))
			end
		end),
        
        -- I'm not sure if this will work, setting up sound like this, but I'll try!
        TimeEvent(6*FRAMES, function(inst) inst.SoundEmitter:PlaySound("sound/wendy/summon_pre") end),
        TimeEvent(53*FRAMES, function(inst) inst.SoundEmitter:PlaySound("sound/wendy/summon") end),

        TimeEvent(52 * FRAMES, function(inst) 
			inst.sg.statemem.fx = SpawnPrefab("abigailsummonfx")
			inst.sg.statemem.fx.entity:SetParent(inst.entity)
			inst.sg.statemem.fx.Transform:SetRotation(inst.Transform:GetRotation())
            inst.sg.statemem.fx.AnimState:SetTime(0) -- hack to force update the initial facing direction
            
            -- if inst.bufferedaction ~= nil then
            --     local flower = inst.bufferedaction.invobject
            --     if flower ~= nil then
            --         local skin_build = flower:GetSkinBuild()
            --         if skin_build ~= nil then
            --             inst.sg.statemem.fx.AnimState:OverrideItemSkinSymbol("flower", skin_build, "flower", flower.GUID, flower.AnimState:GetBuild() )
            --         end
            --     end
            -- end

            if inst.components.talker ~= nil then
				inst.components.talker:ShutUp()
			end
		end),
        TimeEvent(62 * FRAMES, function(inst) 
			if inst:PerformBufferedAction() then
				inst.sg.statemem.fx = nil
			else
                inst.sg:GoToState("idle")
			end
		end),
		TimeEvent(74 * FRAMES, function(inst) inst.sg:RemoveStateTag("busy") end),
    },

    events =
    {
        EventHandler("animqueueover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end),
    },

    onexit = function(inst)
        inst.AnimState:ClearOverrideSymbol("flower")
		if inst.sg.statemem.fx ~= nil then
			inst.sg.statemem.fx:Remove()
		end
        if inst.bufferedaction == inst.sg.statemem.action then
            inst:ClearBufferedAction()
        end
    end
}
)

AddStategraphState("wilson",
	State
    {
        name = "unsummon_abigail",
        tags = { "doing", "busy", "nodangle" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("wendy_recall")
            inst.AnimState:PushAnimation("wendy_recall_pst", false)

            if inst.bufferedaction ~= nil then
                local flower = inst.bufferedaction.invobject
                if flower ~= nil then
                    -- local skin_build = flower:GetSkinBuild()
                    -- if skin_build ~= nil then
                    --     inst.AnimState:OverrideItemSkinSymbol("flower", skin_build, "flower", flower.GUID, flower.AnimState:GetBuild() )
                    -- else
                    inst.AnimState:OverrideSymbol("flower", flower.AnimState:GetBuild(), "flower")
                    -- end
                end

                inst.sg.statemem.action = inst.bufferedaction

				inst.components.talker:Say(GetString(inst, "ANNOUNCE_ABIGAIL_RETRIEVE"), nil, nil, true)
            end
        end,

        timeline =
        {
            TimeEvent(6*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/summon_pre") end),
            TimeEvent(30*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/recall") end),
            TimeEvent(26 * FRAMES, function(inst) 
				inst.sg:RemoveStateTag("busy")

                if inst.components.talker ~= nil then
					inst.components.talker:ShutUp()
				end

                local flower = nil
                if inst.bufferedaction ~= nil then
                    flower = inst.bufferedaction.invobject
                end

				if inst:PerformBufferedAction() then
					local fx = SpawnPrefab("abigailunsummonfx")
					fx.entity:SetParent(inst.entity)
					fx.Transform:SetRotation(inst.Transform:GetRotation())
                    fx.AnimState:SetTime(0) -- hack to force update the initial facing direction
                    
                    -- if flower ~= nil then
                    --     local skin_build = flower:GetSkinBuild()
                    --     if skin_build ~= nil then
                    --         fx.AnimState:OverrideItemSkinSymbol("flower", skin_build, "flower", flower.GUID, flower.AnimState:GetBuild() )
                    --     end
                    -- end
				else
                    inst.sg:GoToState("idle")
				end
			end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.AnimState:ClearOverrideSymbol("flower")
            if inst.bufferedaction == inst.sg.statemem.action then
                inst:ClearBufferedAction()
            end
        end,
    }
)

   --  State
   --  {
   --      name = "unsummon_abigail",
   --      tags = { "doing", "busy", "nodangle" },

   --      onenter = function(inst)
   --          inst.components.locomotor:Stop()
   --          inst.AnimState:PlayAnimation("wendy_recall")
   --          inst.AnimState:PushAnimation("wendy_recall_pst", false)

   --          if inst.bufferedaction ~= nil then
   --              local flower = inst.bufferedaction.invobject
   --              if flower ~= nil then
   --                  local skin_build = flower:GetSkinBuild()
   --                  if skin_build ~= nil then
   --                      inst.AnimState:OverrideItemSkinSymbol("flower", skin_build, "flower", flower.GUID, flower.AnimState:GetBuild() )
   --                  else
   --                      inst.AnimState:OverrideSymbol("flower", flower.AnimState:GetBuild(), "flower")
   --                  end
   --              end

   --              inst.sg.statemem.action = inst.bufferedaction

			-- 	inst.components.talker:Say(GetString(inst, "ANNOUNCE_ABIGAIL_RETRIEVE"), nil, nil, true)
   --          end
   --      end,

   --      timeline =
   --      {
   --          TimeEvent(6*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/summon_pre") end),
   --          TimeEvent(30*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/recall") end),
   --          TimeEvent(26 * FRAMES, function(inst) 
			-- 	inst.sg:RemoveStateTag("busy")

   --              if inst.components.talker ~= nil then
			-- 		inst.components.talker:ShutUp()
			-- 	end

   --              local flower = nil
   --              if inst.bufferedaction ~= nil then
   --                  flower = inst.bufferedaction.invobject
   --              end

			-- 	if inst:PerformBufferedAction() then
			-- 		local fx = SpawnPrefab(inst.components.rider:IsRiding() and "abigailunsummonfx_mount" or "abigailunsummonfx")
			-- 		fx.entity:SetParent(inst.entity)
			-- 		fx.Transform:SetRotation(inst.Transform:GetRotation())
   --                  fx.AnimState:SetTime(0) -- hack to force update the initial facing direction
                    
   --                  if flower ~= nil then
   --                      local skin_build = flower:GetSkinBuild()
   --                      if skin_build ~= nil then
   --                          fx.AnimState:OverrideItemSkinSymbol("flower", skin_build, "flower", flower.GUID, flower.AnimState:GetBuild() )
   --                      end
   --                  end
			-- 	else
   --                  inst.sg:GoToState("idle")
			-- 	end
			-- end),
   --      },

   --      events =
   --      {
   --          EventHandler("animqueueover", function(inst)
   --              if inst.AnimState:AnimDone() then
   --                  inst.sg:GoToState("idle")
   --              end
   --          end),
   --      },

   --      onexit = function(inst)
   --          inst.AnimState:ClearOverrideSymbol("flower")
   --          if inst.bufferedaction == inst.sg.statemem.action then
   --              inst:ClearBufferedAction()
   --          end
   --      end,
   --  },

   --  State
   --  {
   --      name = "commune_with_abigail",
   --      tags = { "doing", "busy", "nodangle" },

   --      onenter = function(inst)
   --          inst.components.locomotor:Stop()
   --          inst.AnimState:PlayAnimation("wendy_commune_pre")
   --          inst.AnimState:PushAnimation("wendy_commune_pst", false)

   --          if inst.bufferedaction ~= nil then
			-- 	local flower = inst.bufferedaction.invobject
   --              if flower ~= nil then
   --                  local skin_build = flower:GetSkinBuild()
   --                  if skin_build ~= nil then
   --                      inst.AnimState:OverrideItemSkinSymbol("flower", skin_build, "flower", flower.GUID, flower.AnimState:GetBuild() )
   --                  else
   --                      inst.AnimState:OverrideSymbol("flower", flower.AnimState:GetBuild(), "flower")
   --                  end
			-- 	end

   --              inst.sg.statemem.action = inst.bufferedaction

   --          end
   --      end,

   --      timeline =
   --      {
   --          TimeEvent(14 * FRAMES, function(inst) 
   --              inst:PerformBufferedAction()
   --          end),

   --          TimeEvent(35 * FRAMES, function(inst) 
			-- 	inst.sg:RemoveStateTag("busy")
			-- end),
   --      },

   --      events =
   --      {
   --          EventHandler("animqueueover", function(inst)
   --              if inst.AnimState:AnimDone() then
   --                  inst.sg:GoToState("idle")
   --              end
   --          end),
   --      },

   --      onexit = function(inst)
   --          inst.AnimState:ClearOverrideSymbol("flower")
   --          if inst.bufferedaction == inst.sg.statemem.action then
   --              inst:ClearBufferedAction()
   --          end
   --      end,
   --  },


-- not sure if I need a reference to actions?
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.CASTSUMMON,
    function(inst, action)
        return action.invobject ~= nil and action.invobject:HasTag("abbby_flower") and "summon_abigail" or "castspell"
        end)
)

AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.CASTUNSUMMON,
        function(inst, action)
            return action.invobject ~= nil and action.invobject:HasTag("abby_flower") and "unsummon_abigail" or "castspell"
        end)
)


-- commenting out this one because I don't have commune set up
-- AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.COMMUNEWITHSUMMONED,
-- 	    function(inst, action)
--             return action.invobject ~= nil and action.invobject:HasTag("abby_flower") and "commune_with_abigail" or "dolongaction"
--         end),