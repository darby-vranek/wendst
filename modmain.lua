PrefabFiles = {
	"wendst",
}

Assets = {
    Asset( "IMAGE", "images/saveslot_portraits.tex" ),
    Asset( "ATLAS", "images/saveslot_portraits.xml" ),

    Asset( "IMAGE", "images/selectscreen_portraits/selectscreen_portraits.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/wendst.xml" ),
	
    Asset( "IMAGE", "images/selectscreen_portraits/selectscreen_portraits.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/wendst_silho.xml" ),
    Asset( "IMAGE", "bigportraits/wendst.tex" ),
    Asset( "ATLAS", "bigportraits/wendst.xml" ),
	
	Asset( "IMAGE", "minimap/minimap_atlas.tex" ),
	Asset( "ATLAS", "minimap/minimap_data.xml" ),
}


local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS


STRINGS.CHARACTER_TITLES.wendst = "The Bereaved"
STRINGS.CHARACTER_NAMES.wendst = "Wendy"
STRINGS.CHARACTER_DESCRIPTIONS.wendst = "*Is haunted by her twin sister\n*Dabbles in Ectoherbology\n*Feels comfortable in the dark *Doesn't hit very hard"
STRINGS.CHARACTER_QUOTES.wendst = "\"Abigail? Come back! I'm not done playing with you.\""


STRINGS.CHARACTERS.WENDST = STRINGS.CHARACTERS.WENDY


table.insert(GLOBAL.CHARACTER_GENDERS.FEMALE, "wendst")

AddMinimapAtlas("minimap/minimap_data.xml")
AddModCharacter("wendst")