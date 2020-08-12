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
local SPEECH_WENDY = STRINGS.CHARACTERS.WENDY


STRINGS.CHARACTER_TITLES.wendst = "The Bereaved"
STRINGS.CHARACTER_NAMES.wendst = "Wendy"
STRINGS.CHARACTER_DESCRIPTIONS.wendst = "*Is haunted by her twin sister\n*Dabbles in Ectoherbology\n*Comfortable in the dark *Doesn't hit very hard"
STRINGS.CHARACTER_QUOTES.wendst = "\"Abigail? Come back! I'm not done playing with you.\""

STRINGS.CHARACTERS.WENDST = SPEECH_WENDY

table.insert(GLOBAL.CHARACTER_GENDERS.FEMALE, "wendst")

STRINGS.NAMES.ABBY_FLOWER = "Abigail's Flower"
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
SPEECH_WENDY.DESCRIBE.ABBY =
{
    GENERIC= "That's my twin sister, Abigail.",
    LEVEL1 =
    {
        "It was so lonely without you here.",
        "That's my twin sister, Abigail.",
    },
    LEVEL2 = 
    {
        "We'll never be apart again.",
        "That's my twin sister, Abigail.",
    },
    LEVEL3 = 
    {
        "Let's play, Abigail!",
        "That's my twin sister, Abigail.",
    },
}


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