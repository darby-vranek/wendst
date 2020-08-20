

PrefabFiles = {
	"wendst",
	"abby_flower",
	"abby",
	'abigail_attack_fx',
	"abigailforcefield",

}


Assets = {
	Asset( "IMAGE", "images/saveslot_portraits/wendst.tex" ),
	Asset( "ATLAS", "images/saveslot_portraits/wendst.xml" ),

	Asset( "IMAGE", "images/selectscreen_portraits/wendst.tex" ),
	Asset( "ATLAS", "images/selectscreen_portraits/wendst.xml" ),
	
	Asset( "IMAGE", "images/selectscreen_portraits/wendst.tex" ),
	Asset( "ATLAS", "images/selectscreen_portraits/wendst_silho.xml" ),
	
	Asset( "IMAGE", "bigportraits/wendst.tex" ),
	Asset( "ATLAS", "bigportraits/wendst.xml" ),
	
	Asset( "IMAGE", "minimap/wendst.tex" ),
	Asset( "ATLAS", "minimap/wendst.xml" ),

	Asset("ANIM", "anim/wendy_channel.zip"),
	Asset("ANIM", "anim/wendy_recall.zip"),
	Asset("ANIM", "anim/player_wendy_commune.zip"),
	Asset("ANIM", "anim/wendy_flower_over.zip"),
	Asset("ANIM", "anim/player_idles_wendy.zip"),
	Asset("ANIM", "anim/abigail_shield.zip"),
	Asset("ANIM", "anim/abigail_debuff_fx.zip"),

	Asset("SOUND", "sound/wendy.fsb"),    
}


local require = GLOBAL.require
local TUNING = GLOBAL.TUNING
local STRINGS = GLOBAL.STRINGS
local SPEECH_WENDY = STRINGS.CHARACTERS.WENDY
local SourceModifierList = require("sourcemodifierlist")
local ACTIONS = GLOBAL.ACTIONS
local ActionHandler = GLOBAL.ActionHandler
local FRAMES = GLOBAL.FRAMES
local TimeEvent = GLOBAL.TimeEvent
local EventHandler = GLOBAL.EventHandler
local State = GLOBAL.State
local GetString = GLOBAL.GetString
local SpawnPrefab = GLOBAL.SpawnPrefab

-- require("stategraphs/SGwendst")



STRINGS.CHARACTER_TITLES.wendst = "The Bereaved"
STRINGS.CHARACTER_NAMES.wendst = "Wendy"
STRINGS.CHARACTER_DESCRIPTIONS.wendst = "*Is haunted by her twin sister\n*Dabbles in Ectoherbology\n*Comfortable in the dark *Doesn't hit very hard"
STRINGS.CHARACTER_QUOTES.wendst = "\"Abigail? Come back! I'm not done playing with you.\""

STRINGS.CHARACTERS.WENDST = SPEECH_WENDY

table.insert(GLOBAL.CHARACTER_GENDERS.FEMALE, "wendst")

STRINGS.NAMES.ABBY_FLOWER = "Axbigail's Flower"
STRINGS.NAMES.ABBY = "Abigail"

-- dialogue

SPEECH_WENDY.ANNOUNCE_SISTURN_FULL = "Now Abigail can find her way back to me faster."
SPEECH_WENDY.ANNOUNCE_ABIGAIL_DEATH = "No... don't leave me alone again!"
SPEECH_WENDY.ANNOUNCE_ABIGAIL_RETRIEVE = "I'm sorry... it's not safe for you out here."
SPEECH_WENDY.ANNOUNCE_ABIGAIL_LOW_HEALTH = "Be careful, Abigail!"
SPEECH_WENDY.ANNOUNCE_ABIGAIL_SUMMON = 
{
	LEVEL1 = "I know you're tired, but I can't do this alone...",
	LEVEL2 = "I need your help, Abigail...",
	LEVEL3 = "You've rested in peace long enough, dear sister.",
}
SPEECH_WENDY.ANNOUNCE_GHOSTLYBOND_LEVELUP = 
{
	LEVEL2 = "You seem to have brightened up a bit, Abigail.",
	LEVEL3 = "Abigail has always been my guiding light in the darkness...",
}
SPEECH_WENDY.DESCRIBE.ABBY_FLOWER =
{
	GENERIC = "It's still so pretty.",
	LEVEL1 = "It was my sister's flower. She's gone far away.",
	LEVEL2 = "I can sense Abigail's spirit growing stronger.",
	LEVEL3 = "Abigail! Are you ready to play?",
}
SPEECH_WENDY.DESCRIBE.ABBY = {
	GENERIC= "That's my twin sister, Abigail.",
	LEVEL1 =
	-- {
		"It was so lonely without you here.",
		-- "That's my twin sister, Abigail.",
	-- },
	LEVEL2 = 
	-- {
		"We'll never be apart again.",
		-- "That's my twin sister, Abigail.",
	-- },
	LEVEL3 = 
	-- {
		"Let's play, Abigail!",
		-- "That's my twin sister, Abigail.",
	-- },
}

-- SPEECH_WENDY.MAKE_AGGRESSIVE = "Rile Up"
-- SPEECH_WENDY.MAKE_DEFENSIVE = "Soothe"

SPEECH_WENDY.COMMUNEWITHSUMMONED = {
	MAKE_AGGRESSIVE = "Rile Up",
	MAKE_DEFENSIVE = "Soothe",
}


local total_day_time = TUNING.TOTAL_DAY_TIME
local seg_time = TUNING.SEG_TIME
-- tuning

TUNING.ABIGAIL_SPEED = 5
TUNING.ABIGAIL_HEALTH = TUNING.WILSON_HEALTH*4
TUNING.ABIGAIL_HEALTH_LEVEL1 = TUNING.WILSON_HEALTH*1
TUNING.ABIGAIL_HEALTH_LEVEL2 = TUNING.WILSON_HEALTH*2
TUNING.ABIGAIL_HEALTH_LEVEL3 = TUNING.WILSON_HEALTH*4
TUNING.ABIGAIL_FORCEFIELD_ABSORPTION = 1.0
TUNING.ABIGAIL_DAMAGE = {
	day = 15,
	dusk = 25,
	night = 40,
}
TUNING.ABIGAIL_VEX_DURATION = 2
TUNING.ABIGAIL_VEX_DAMAGE_MOD = 1.1
TUNING.ABIGAIL_VEX_GHOSTLYFRIEND_DAMAGE_MOD = 1.4

TUNING.ABIGAIL_DMG_PERIOD = 1.5
TUNING.ABIGAIL_DMG_PLAYER_PERCENT = 0.25
TUNING.ABIGAIL_FLOWER_DECAY_TIME = TUNING.TOTAL_DAY_TIME * 3

TUNING.ABIGAIL_BOND_LEVELUP_TIME = TUNING.TOTAL_DAY_TIME * 1
TUNING.ABIGAIL_BOND_LEVELUP_TIME_MULT = 4
TUNING.ABIGAIL_MAX_STAGE = 3

TUNING.ABIGAIL_LIGHTING = 
{
	{l = 0.0, r = 0.0},
	{l = 0.1, r = 0.3, i = 0.7, f = 0.5},
	{l = 0.5, r = 0.7, i = 0.6, f = 0.6},
}

TUNING.ABIGAIL_FLOWER_PROX_DIST = 6*6
TUNING.ABIGAIL_COMBAT_TARGET_DISTANCE = 15

TUNING.ABIGAIL_DEFENSIVE_MIN_FOLLOW = 1
TUNING.ABIGAIL_DEFENSIVE_MAX_FOLLOW = 5
TUNING.ABIGAIL_DEFENSIVE_MED_FOLLOW = 3

TUNING.ABIGAIL_AGGRESSIVE_MIN_FOLLOW = 3
TUNING.ABIGAIL_AGGRESSIVE_MAX_FOLLOW = 10
TUNING.ABIGAIL_AGGRESSIVE_MED_FOLLOW = 6

TUNING.DEFENSIVE_MAX_CHASE_TIME = 3
TUNING.AGGRESSIVE_MAX_CHASE_TIME = 6

TUNING.GHOSTLYELIXIR_SLOWREGEN_HEALING = 2
TUNING.GHOSTLYELIXIR_SLOWREGEN_TICK_TIME = 1
TUNING.GHOSTLYELIXIR_SLOWREGEN_DURATION = total_day_time -- 960 hp

TUNING.GHOSTLYELIXIR_FASTREGEN_HEALING = 20
TUNING.GHOSTLYELIXIR_FASTREGEN_TICK_TIME = 1
TUNING.GHOSTLYELIXIR_FASTREGEN_DURATION = seg_time -- 600 hp
TUNING.GHOSTLYELIXIR_DAMAGE_DURATION = total_day_time
TUNING.GHOSTLYELIXIR_SPEED_LOCO_MULT = 1.75
TUNING.GHOSTLYELIXIR_SPEED_DURATION = total_day_time
TUNING.GHOSTLYELIXIR_SPEED_PLAYER_GHOST_DURATION = 3
TUNING.GHOSTLYELIXIR_SHIELD_DURATION = total_day_time
TUNING.GHOSTLYELIXIR_RETALIATION_DAMAGE = 20
TUNING.GHOSTLYELIXIR_RETALIATION_DURATION = total_day_time
TUNING.GHOSTLYELIXIR_DRIP_FX_DELAY = seg_time / 2

-- stategraphs

-- local sgsummon = State
-- {
-- 	name = "summon_abigail",
-- 	tags = { "doing", "busy", "nodangle", "canrotate" },

-- 	onenter = function(inst)
-- 		inst.components.locomotor:Stop()
-- 		inst.AnimState:PlayAnimation("wendy_channel")
-- 		inst.AnimState:PushAnimation("wendy_channel_pst", false)

-- 		if inst.bufferedaction ~= nil then
-- 			local flower = inst.bufferedaction.invobject
-- 			if flower ~= nil then
-- 				inst.AnimState:OverrideSymbol("flower", flower.AnimState:GetBuild(), "flower")
-- 			end

-- 			inst.sg.statemem.action = inst.bufferedaction
-- 		end
-- 	end,

-- 	timeline =
-- 	{
-- 		TimeEvent(0 * FRAMES, function(inst)
-- 			if inst.components.talker ~= nil and inst.components.ghostlybond ~= nil then
-- 				inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_ABIGAIL_SUMMON", "LEVEL"..tostring(math.max(inst.components.ghostlybond.bondlevel, 1))), nil, nil, true)
-- 			end
-- 		end),
		
-- 		TimeEvent(6*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/summon_pre") end),
-- 		TimeEvent(53*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/summon") end),

-- 		TimeEvent(52 * FRAMES, function(inst) 
-- 			inst.sg.statemem.fx = SpawnPrefab("abigailsummonfx")
-- 			inst.sg.statemem.fx.entity:SetParent(inst.entity)
-- 			inst.sg.statemem.fx.Transform:SetRotation(inst.Transform:GetRotation())
-- 			inst.sg.statemem.fx.AnimState:SetTime(0) -- hack to force update the initial facing direction

-- 			if inst.components.talker ~= nil then
-- 				inst.components.talker:ShutUp()
-- 			end
-- 		end),
-- 		TimeEvent(62 * FRAMES, function(inst) 
-- 			if inst:PerformBufferedAction() then
-- 				inst.sg.statemem.fx = nil
-- 			else
-- 				inst.sg:GoToState("idle")
-- 			end
-- 		end),
-- 		TimeEvent(74 * FRAMES, function(inst) inst.sg:RemoveStateTag("busy") end),
-- 	},

-- 	events =
-- 	{
-- 		EventHandler("animqueueover", function(inst)
-- 			if inst.AnimState:AnimDone() then
-- 				inst.sg:GoToState("idle")
-- 			end
-- 		end),
-- 	},

-- 	onexit = function(inst)
-- 		inst.AnimState:ClearOverrideSymbol("flower")
-- 		if inst.sg.statemem.fx ~= nil then
-- 			inst.sg.statemem.fx:Remove()
-- 		end
-- 		if inst.bufferedaction == inst.sg.statemem.action then
-- 			inst:ClearBufferedAction()
-- 		end
-- 	end,
-- }

-- actions


local castsummon = function(act)
	-- print('castsummon')
	if act.invobject ~= nil and act.invobject.components.summoningitem and act.doer ~= nil and act.doer.components.ghostlybond ~= nil then
	 return act.doer.components.ghostlybond:Summon(act.invobject.components.summoningitem.inst)
	end
	print("castsummon")
end

local castunsummon = function(act)
	if act.invobject ~= nil and act.invobject.components.summoningitem and act.doer ~= nil and act.doer.components.ghostlybond ~= nil then
	 print("action - castunsummon")
	 return act.doer.components.ghostlybond:Recall(false)
	end
	print("castunsummon")
end

local communewithsummoned = function(act)
	print("commune act")
	if act.invobject ~= nil and act.invobject.components.summoningitem and act.doer ~= nil and act.doer.components.ghostlybond ~= nil then
		return act.doer.components.ghostlybond:ChangeBehaviour()
	end
end

local communewithsummonedstrfn = function(act)
	print("communestr")
	if act.doer:HasTag("has_aggressive_follower") then
		print("make defensive")
		return "MAKE_DEFENSIVE"
	else
		print("make aggressive")
		return "MAKE_AGGRESSIVE"
	end
end

-- 


local act_castsummon = {
	id="CASTSUMMON",
	instant=true,
	rmb=true,
	mount_enabled=true,
	priority=3,
	fn=castsummon,
	str="Summon",
}

local act_castunsummon = {
	id="CASTUNSUMMON",
	instant=true,
	mount_enabledd=true,
	priority=3,
	fn=castunsummon,
	str="Recall",
}

local act_communewithsummoned = {
	id="COMMUNEWITHSUMMONED",
	instant=true,
	mount_enabledd=true,
	priority=3,
	fn=communewithsummoned,
	strfn=communewithsummonedstrfn,
	str="Commune",
}



AddAction(act_castsummon)
AddAction(act_castunsummon)
AddAction(act_communewithsummoned)

AddComponentPostInit("combat",
	function(self, inst)
		self.externaldamagemultipliers = SourceModifierList(self.inst)
		self.externaldamagetakenmultipliers = SourceModifierList(self.inst)
	end
	)
AddComponentPostInit("health",
	function(self, inst)
		self.externalabsorbmodifiers = SourceModifierList(inst, 0, SourceModifierList.additive)

	end)



AddStategraphState("wilson", State{
	name = "summon_abigail",
	tags = { "doing", "busy", "nodangle", "canrotate" },

	onenter = function(inst)
		inst.components.locomotor:Stop()
		inst.AnimState:PlayAnimation("wendy_channel")
		inst.AnimState:PushAnimation("wendy_channel_pst", false)

		if inst.bufferedaction ~= nil then
			local flower = inst.bufferedaction.invobject
			if flower ~= nil then
				inst.AnimState:OverrideSymbol("flower", flower.AnimState:GetBuild(), "flower")
			end

			inst.sg.statemem.action = inst.bufferedaction
		end
	end,

	timeline =
	{
		TimeEvent(0 * FRAMES, function(inst)
			if inst.components.talker ~= nil and inst.components.ghostlybond ~= nil then
				inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_ABIGAIL_SUMMON", "LEVEL"..inst.components.ghostlybond.bondlevel))
			end
		end),
		
		TimeEvent(6*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/beefalo/puke_out") end),
		TimeEvent(53*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/beefalo/saddle/shake_off") end),

		TimeEvent(52 * FRAMES, function(inst) 
			inst.sg.statemem.fx = SpawnPrefab("abigailsummonfx")
			inst.sg.statemem.fx.entity:SetParent(inst.entity)
			inst.sg.statemem.fx.Transform:SetRotation(inst.Transform:GetRotation())
			inst.sg.statemem.fx.AnimState:SetTime(0) -- hack to force update the initial facing direction

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
	end,
})
AddStategraphState("wilson", State{
	name = "commune_with_abigail",
    tags = { "doing", "busy", "nodangle" },

    onenter = function(inst)
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("wendy_commune_pre")
        inst.AnimState:PushAnimation("wendy_commune_pst", false)

   --      if inst.buffer edaction ~= nil then
			-- local flower = inst.bufferedaction.invobject
   --          if flower ~= nil then
   --              inst.AnimState:OverrideSymbol("flower", flower.AnimState:GetBuild(), "flower")
			-- end

   --          inst.sg.statemem.action = inst.bufferedaction

   --      end
		if inst.bufferedaction ~= nil then
			local flower = inst.bufferedaction.invobject
            if flower ~= nil then
                inst.AnimState:OverrideSymbol("flower", flower.AnimState:GetBuild(), "flower")
				end

                inst.sg.statemem.action = inst.bufferedaction

            end
    end,

    timeline =
    {
        TimeEvent(14 * FRAMES, function(inst) 
            inst:PerformBufferedAction()
        end),

        TimeEvent(35 * FRAMES, function(inst) 
			inst.sg:RemoveStateTag("busy")
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
})
AddStategraphState("wilson", State{
    name = "unsummon_abigail",
    tags = { "doing", "busy", "nodangle" },

    onenter = function(inst)
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("wendy_recall")
        inst.AnimState:PushAnimation("wendy_recall_pst", false)

        if inst.bufferedaction ~= nil then
            local flower = inst.bufferedaction.invobject
            if flower ~= nil then
                local skin_build = flower:GetSkinBuild()
                if skin_build ~= nil then
                    inst.AnimState:OverrideItemSkinSymbol("flower", skin_build, "flower", flower.GUID, flower.AnimState:GetBuild() )
                else
                    inst.AnimState:OverrideSymbol("flower", flower.AnimState:GetBuild(), "flower")
                end
            end

            inst.sg.statemem.action = inst.bufferedaction

			inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_ABIGAIL_RETRIEVE"))
        end
    end,

    timeline =
    {
        TimeEvent(6*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/beefalo/positive") end),
        TimeEvent(30*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/beefalo/beg") end),
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
})

AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.CASTSUMMON,
	function(inst, action)
		print("summon action handler")
		return action.invobject ~= nil and action.invobject:HasTag("abigail_flower") and "summon_abigail" or "castspell"
	end))


AddMinimapAtlas("minimap/wendst.xml")
AddModCharacter("wendst")