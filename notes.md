# 8/20/20
* wendy summon animation cuts off before end of flower animation but otherwise seems to work
	* it looks like "wendy_channel_pst" is getting cut off - it doesn't include the flower, so I'm going to have to figure that out again. I'm guessing that's why the anim is missing frames.
* I think Wendy's commune animation is supposed to have the flower, and it's possible she's supposed to actually face Abigail when that happens - check DST behavior
* recall also seems to be missing the end and some abby_flower stuff
* I haven't even touched the `wendy_flower_over` and `player_idles_wendy` bits - I don't know how to do either, especially as some of the shit for `wendy_flower_over` seems to be unique to DST
* Wendy's DS prefabs include `abby_flower` but DST's does not - I think I do still need it, because I think DST handles that prefab through starting inventory, which isn't what happens in DS
* I'm having trouble with the `_bondlevel` thing - it seems to store data in a web-specific format and I'm having to deal with that, generally by not using getters and setters. Not sure if this'll cause problems down the line.
* `OnPlayerActivated` and `OnPlayreDeactivated` do not exist in DS - that could potentially cause issues with the flowerover effect, as well as the pethealthbar when I finally get around to adding that in
* It looks like I can remove `local function onresurrection(inst)` - it seems to refer to DST-specific resurrections, not solo touchstones/etc
* addd `not isloading and` to the if statement in `local function ghostlybond_onlevelchange(inst, ghost, level, prev_level, isloading)`
* the issue does seem to fall to the flower, once again
* removed a skin build thing from recall to see if that helps
* I can now commune again because oops I broke that. It looks like she automatically changes direction based on what Wendy was facing previously, so that doesn't need to be fixed
* added prefabs from abby_flower over to modmain
	* that broke everything and I'm removing it
* removing helped - it looked like the entire summon animation plays out, but possibly too fast at the end??
* flower in commune doesn't appeark
* recall looks even worse
* made changes to abby flower `local function MakeSummonFX(anim, use_anim_for_build, is_mounted)`




---


# to do
* see if I can undo the changes made to `ghostlybond_onlevelchange` as I don't think that was the issue
* determine if `ghostlybond_onsummon` is missing things that I deleted, or needs to have some sort of redo
* gonna redo `StartForceField`

# modmain.lua
* I'm giving stategraphs another shot - for now, the action handler is doing nothing, which makes sense given that I didn't give it a state
	* by giving up on action handlers and instead just starting animations within Wendy's `ghostlybond_onsummon` functions and the like

# abby.lua
* not sure if `require "stategraphs/SGabby"` is necessary and it could prove helpful to check
* I don't actually know how sound works in this and having repeated file names might cause issues
* I made `local COMBAT_MUSTHAVE_TAGS` an empty `{}` and that fixed her not attacking things in either form, and this may eventually cause some issues with targeting things that should not - I don't know how to test that
* added back in the stuff from `local function HasFriendlyLeader(inst, target)`
* getting `OnAttacked` better in line with the dst version
* replaced the event listener for phase changes with one single "phasechange" event - I did see it listed in DS files, so here's hoping it works!
* I'm throwing in a bunch of print statements bc why not
* commented out `local function OnExitLimbo(inst)` because it's exclusively DST
* added `"abigail"` tag to abby because there may be other places in the game that reference that tag


# wendst.lua
* Can `local assets` use the DST wendy anim files instead? I don't have them imported into the file
* `local function OnBondLevelDirty(inst)`
	* this seems to be the function that handles `wendyflowerover`, and it gets called by other functions that change bond level. 
* I've left out:
	* `local function OnPlayerDeactivated(inst)` (seems to like a DST thing)
	* `local function OnClientPetSkinChanged(inst)` (skins are never gonna exist here)
* `local function OnPlayerActivated(inst)` is kind of a mess - I'm not sure if it actually gets run at all, so I'm putting in a print statement to see. It puts listeners on for `_bondleveldirty` eventa and seems to trigger wendyflowerover widget
* put in a print statement to OnDespawn as I'm unsure whether that runs in DS
	* given that it does not exist in DS game files, it's a good idea to remove it.
* `ghostlybond_onlevelchange` gives me issues. I removed the parts where `inst._bondlevel` gets directly assigned, as well as the speaking component as it broke in a big way last time - though that could be the result of the `Recall` function in `ghostlybond` that was actually causing the problem 0 those things work fine in the onsummon fn
* `ghostlybond_onsummon` is for some reason very different from the original DST file - I think I may have moved some things around that sound return to the way they were
* I've commented out `update_sisturn_state` as I haven't implemented that yet
* I don't really know what to do with `OnSave` and `OnLoad` - a lot of it has to do with the ghost flowers and online shit however I may still need to set those for this and other scripts
	* wtf is `migrationpets`??? I know tht's what's driving the ghostflower people and aside from that, no idea
* I have yet to include Wendy's custom idle anims - sister's works, so perhaps it's already a thing
* I need to add listeners to `fn` incluing `"onsisturnstatechanged"`, though I think I can leave out things like `"ms_respawnedfromghost"`
---
* ghostlybond_onlevelchange turned out to work, it was `ghostlybond_onsummon` that was mangled
* removed the talking component - if I'm right, that gets handled in SG