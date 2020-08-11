PrefabFiles = {
	"wendst",
    "abby_flower",
    "abby"
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
}


local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS


STRINGS.CHARACTER_TITLES.wendst = "The Bereaved"
STRINGS.CHARACTER_NAMES.wendst = "Wendy"
STRINGS.CHARACTER_DESCRIPTIONS.wendst = "*Is haunted by her twin sister\n*Dabbles in Ectoherbology\n*Comfortable in the dark *Doesn't hit very hard"
STRINGS.CHARACTER_QUOTES.wendst = "\"Abigail? Come back! I'm not done playing with you.\""
STRINGS.CHARACTERS.WENDST = STRINGS.CHARACTERS.WENDY
table.insert(GLOBAL.CHARACTER_GENDERS.FEMALE, "wendst")


STRINGS.NAMES.ABBY_FLOWER = "Abigail's Flower"
STRINGS.CHARACTERS.WENDST.DESCRIBE.ABBY_FLOWER = {
    GENERIC ="It's still so pretty.",
    LONG = "It was my sister's flower. She's gone far away.",
    MEDIUM = "I can sense Abigail's spirit growing stronger.",
    SOON = "Abigail! Are you ready to play?",
    HAUNTED_POCKET = "Abigail is ready to play, but she needs some space.",
    HAUNTED_GROUND = "I need to show Abigail how to play.",
}

-- actions

local castsummon = function(act)
    print('castsummon')
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

AddAction(act_castsummon)
AddAction(act_castunsummon)


AddMinimapAtlas("minimap/wendst.xml")
AddModCharacter("wendst")