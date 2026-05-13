/mob/living/carbon/human/examine(mob/user, distance)
	. = TRUE
	var/skipgloves = 0
	var/skipsuitstorage = 0
	var/skipjumpsuit = 0
	var/skipshoes = 0
	var/skipmask = 0
	var/skipears = 0
	var/skipeyes = 0
	var/skipface = 0

	//Skips this for humanoid SCPS
	if(SCP && !SCP.regular_examine)
		to_chat(user, "[icon2html(src, user)] That's \a [src] [suffix]")
		to_chat(user, desc)
		return

	//exosuits and helmets obscure our view and stuff.
	if(wear_suit)
		skipgloves = wear_suit.flags_inv & HIDEGLOVES
		skipsuitstorage = wear_suit.flags_inv & HIDESUITSTORAGE
		skipjumpsuit = wear_suit.flags_inv & HIDEJUMPSUIT
		skipshoes = wear_suit.flags_inv & HIDESHOES

	if(head)
		skipmask = head.flags_inv & HIDEMASK
		skipeyes = head.flags_inv & HIDEEYES
		skipears = head.flags_inv & HIDEEARS
		skipface = head.flags_inv & HIDEFACE

	if(wear_mask)
		skipeyes |= wear_mask.flags_inv & HIDEEYES
		skipears |= wear_mask.flags_inv & HIDEEARS
		skipface |= wear_mask.flags_inv & HIDEFACE

	//no accuately spotting headsets from across the room.
	if(distance > 3)
		skipears = 1

	var/list/msg = list("<span class='info'>*---------*\nThis is ")

	if(!(skipjumpsuit && skipface))
		if(icon)
			msg += "[icon2html(icon, user)] " //fucking BYOND: this should stop dreamseeker crashing if we -somehow- examine somebody before their icon is generated

	msg += "<EM>[src.name]</EM>"

	var/is_synth = isSynthetic()
	if(!(skipjumpsuit && skipface))
		var/species_name = "\improper "
		if(is_synth && species.cyborg_noun)
			species_name += "[species.cyborg_noun] [species.get_bodytype(src)]"
		else
			species_name += "[species.name]"
		msg += ", <b><font color='[species.get_flesh_colour(src)]'>\a [species_name]!</font></b>[SScodex.get_codex_entry(get_codex_value()) ?  SPAN_NOTICE(" \[<a href='byond://?src=\ref[SScodex];show_examined_info=\ref[src];show_to=\ref[user]'>?</a>\]") : ""]"

	msg += "<br>"

	//uniform
	if(w_uniform && !skipjumpsuit)
		msg += "[p_they(TRUE)] [p_are()] wearing [w_uniform.get_examine_line(user)].\n"

	//head
	if(head)
		msg += "[p_they(TRUE)] [p_are()] wearing [head.get_examine_line(user)] on [p_their()] head.\n"

	//suit/armour
	if(wear_suit)
		msg += "[p_they(TRUE)] [p_are()] wearing [wear_suit.get_examine_line(user)].\n"
		//suit/armour storage
		if(s_store && !skipsuitstorage)
			msg += "[p_they(TRUE)] [p_are()] carrying [s_store.get_examine_line(user)] on [p_their()] [wear_suit.name].\n"

	//back
	if(back)
		msg += "[p_they(TRUE)] [p_have()] [back.get_examine_line(user)] on [p_their()] back.\n"

	//left hand
	if(l_hand)
		msg += "[p_they(TRUE)] [p_are()] holding [l_hand.get_examine_line(user)] in [p_their()] left hand.\n"

	//right hand
	if(r_hand)
		msg += "[p_they(TRUE)] [p_are()] holding [r_hand.get_examine_line(user)] in [p_their()] right hand.\n"

	//gloves
	if(gloves && !skipgloves)
		msg += "[p_they(TRUE)] [p_have()] [gloves.get_examine_line(user)] on [p_their()] hands.\n"
	else if(blood_DNA)
		msg += "<span class='warning'>[p_they()] [p_have()] [(hand_blood_color != SYNTH_BLOOD_COLOUR) ? "blood" : "oil"]-stained hands!</span>\n"

	//belt
	if(belt)
		msg += "[p_they(TRUE)] [p_have()] [belt.get_examine_line(user)] about [p_their()] waist.\n"

	//shoes
	if(shoes && !skipshoes)
		msg += "[p_they(TRUE)] [p_are()] wearing [shoes.get_examine_line(user)] on [p_their()] feet.\n"
	else if(feet_blood_DNA)
		msg += "<span class='warning'>[p_they()] [p_have()] [(feet_blood_color != SYNTH_BLOOD_COLOUR) ? "blood" : "oil"]-stained feet!</span>\n"

	//mask
	if(wear_mask && !skipmask)
		msg += "[p_they(TRUE)] [p_have()] [wear_mask.get_examine_line(user)] on [p_their()] face.\n"

	//eyes
	if(glasses && !skipeyes)
		msg += "[p_they(TRUE)] [p_have()] [glasses.get_examine_line(user)] covering [p_their()] eyes.\n"

	//left ear
	if(l_ear && !skipears)
		msg += "[p_they(TRUE)] [p_have()] [l_ear.get_examine_line(user)] on [p_their()] left ear.\n"

	//right ear
	if(r_ear && !skipears)
		msg += "[p_they(TRUE)] [p_have()] [r_ear.get_examine_line(user)] on [p_their()] right ear.\n"

	//ID
	if(wear_id)
		var/obj/item/card/id/id = GetIdCard()
		msg += "[p_they(TRUE)] [p_are()] wearing [wear_id.get_examine_line(user)]. Job: [id.assignment]. CLASS: [id.class].\n "

	//handcuffed?
	if(handcuffed)
		if(istype(handcuffed, /obj/item/handcuffs/cable))
			msg += "<span class='warning'>[p_they(TRUE)] [p_are()] [icon2html(handcuffed, user)] restrained with cable!</span>\n"
		else
			msg += "<span class='warning'>[p_they(TRUE)] [p_are()] [icon2html(handcuffed, user)] handcuffed!</span>\n"

	//buckled
	if(buckled)
		msg += "<span class='warning'>[p_they(TRUE)] [p_are()] [icon2html(buckled, user)] buckled to [buckled]!</span>\n"

	//Disfigured face
	if(!skipface) //Disfigurement only matters for the head currently.
		var/obj/item/organ/external/head/E = get_organ(BP_HEAD)
		if(E && (E.status & ORGAN_DISFIGURED)) //Check to see if we even have a head and if the head's disfigured.
			if(E.species) //Check to make sure we have a species
				msg += E.species.disfigure_msg(src)
			else //Just in case they lack a species for whatever reason.
				msg += "<span class='warning'>[p_their()] face is horribly mangled!</span>\n"

		var/obj/item/organ/internal/eyes/eyeballs = get_organ(BP_EYES)
		// Handle the sanity if we see the face & eyes. And if we have eyes.
		// Sanity level of the examined mob, not the user
		var/sanityLvl = getSanityLevel()
		if(!skipeyes && sanityLvl && eyeballs && equipment_tint_total < TINT_MODERATE)
			switch(sanityLvl)
				if(SL_STRESSED)
					msg += SPAN_WARNING("[p_they(TRUE)] seem[p_s()] to drift away, lost in thought, ever so slightly.\n")
				if(SL_DISTRESSED)
					msg += SPAN_WARNING("[p_their(TRUE)] eyes are darting around.\n")
				if(SL_INSANE)
					msg += SPAN_WARNING("[p_they(TRUE)] [p_are()] staring with bloodshot eyes.\n")

	//splints
	for(var/organ in list(BP_L_LEG, BP_R_LEG, BP_L_ARM, BP_R_ARM))
		var/obj/item/organ/external/o = get_organ(organ)
		if(o && o.splinted && o.splinted.loc == o)
			msg += "<span class='warning'>[p_they()] [p_have()] \a [o.splinted] on [p_their()] [o.name]!</span>\n"

	if(mSmallsize in mutations)
		msg += "[p_they(TRUE)] [p_are()] small halfling!\n"

	if(stat || status_flags & FAKEDEATH)
		msg += "<span class='warning'>[p_they(TRUE)] [p_are()]n't responding to anything around [p_them()] and seems to be unconscious.</span>\n"
		if((stat == DEAD || is_asystole() || losebreath || status_flags & FAKEDEATH) && distance <= 3)
			msg += "<span class='warning'>[p_they(TRUE)] [p_do()] not appear to be breathing.</span>\n"

	if(fire_stacks > 0)
		msg += "[p_they(TRUE)] looks flammable.\n"
	else if(fire_stacks < 0)
		msg += "[p_they(TRUE)] looks wet.\n"
	if(on_fire)
		msg += "<span class='warning'>[p_they()] [p_are()] on fire!.</span>\n"

	var/ssd_msg = species.get_ssd(src)
	if(ssd_msg && (!should_have_organ(BP_BRAIN) || has_brain()) && stat != DEAD)
		if(!key)
			msg += SPAN_DEADSAY("[p_they(TRUE)] [p_are()] [ssd_msg]. [p_they()] won't be recovering any time soon. (Ghosted)") + "\n"
		else if(!client)
			msg += SPAN_DEADSAY("[p_they(TRUE)] [p_are()] [ssd_msg]. (Disconnected)") + "\n"

	if(admin_paralyzed)
		msg += SPAN_DEBUG("OOC: [p_they()] [p_have()] been paralyzed by staff. Please avoid interacting with [p_them()] unless cleared to do so by staff.") + "\n"

	var/obj/item/organ/external/head/H = organs_by_name[BP_HEAD]
	if(istype(H) && H.forehead_graffiti && H.graffiti_style)
		msg += "<span class='notice'>[p_they()] [p_have()] \"[H.forehead_graffiti]\" written on [p_their()] [H.name] in [H.graffiti_style]!</span>\n"

	if(became_younger)
		msg += "[p_they(TRUE)] looks a lot younger than you remember.\n"
	if(became_older)
		msg += "[p_they(TRUE)] looks a lot older than you remember.\n"

	var/extra_species_text = species.get_additional_examine_text(src)
	if(extra_species_text)
		msg += "[extra_species_text]\n"

	var/list/wound_flavor_text = list()
	var/applying_pressure = ""
	var/list/shown_objects = list()
	var/list/hidden_bleeders = list()

	for(var/organ_tag in species.has_limbs)

		var/list/organ_data = species.has_limbs[organ_tag]
		var/organ_descriptor = organ_data["descriptor"]
		var/obj/item/organ/external/E = organs_by_name[organ_tag]

		if(!E)
			wound_flavor_text[organ_descriptor] = "<b>[p_they(TRUE)] [p_are()] missing [p_their()] [organ_descriptor].</b>\n"
			continue

		wound_flavor_text[E.name] = ""

		if(E.applied_pressure == src)
			applying_pressure = "<span class='info'>[p_they(TRUE)] [p_are()] applying pressure to [p_their()] [E.name].</span><br>"

		var/obj/item/clothing/hidden
		var/list/clothing_items = list(head, wear_mask, wear_suit, w_uniform, gloves, shoes)
		for(var/obj/item/clothing/C in clothing_items)
			if(istype(C) && (C.body_parts_covered & E.body_part))
				hidden = C
				break

		if(hidden && user != src)
			if(E.status & ORGAN_BLEEDING && !(hidden.item_flags & ITEM_FLAG_THICKMATERIAL)) //not through a spacesuit
				if(!hidden_bleeders[hidden])
					hidden_bleeders[hidden] = list()
				hidden_bleeders[hidden] += E.name
		else
			if(E.is_stump())
				wound_flavor_text[E.name] += "<b>[p_they(TRUE)] [p_have()] a stump where [p_their()] [organ_descriptor] should be.</b>\n"
				if(LAZYLEN(E.wounds) && E.parent)
					wound_flavor_text[E.name] += "[p_they(TRUE)] [p_have()] [E.get_wounds_desc()] on [p_their()] [E.parent.name].<br>"
			else
				if(!is_synth && BP_IS_ROBOTIC(E) && (E.parent && !BP_IS_ROBOTIC(E.parent) && !BP_IS_ASSISTED(E.parent)))
					wound_flavor_text[E.name] = "[p_they(TRUE)] [p_have()] a [E.name].\n"
				var/wounddesc = E.get_wounds_desc()
				if(wounddesc != "nothing")
					wound_flavor_text[E.name] += "[p_they(TRUE)] [p_have()] [wounddesc] on [p_their()] [E.name].<br>"
		if(!hidden || distance <=1)
			if(E.dislocated > 0)
				wound_flavor_text[E.name] += "[p_their(TRUE)] [E.joint] is dislocated!<br>"
			if(((E.status & ORGAN_BROKEN) && E.brute_dam > E.min_broken_damage) || (E.status & ORGAN_MUTATED))
				wound_flavor_text[E.name] += "[p_their(TRUE)] [E.name] is dented and swollen!<br>"

		for(var/datum/wound/wound in E.wounds)
			var/list/embedlist = wound.embedded_objects
			if(LAZYLEN(embedlist))
				shown_objects += embedlist
				var/parsedembed[0]
				for(var/obj/embedded in embedlist)
					if(!parsedembed.len || (!list_find(parsedembed, embedded.name) && !list_find(parsedembed, "multiple [embedded.name]")))
						parsedembed.Add(embedded.name)
					else if(!list_find(parsedembed, "multiple [embedded.name]"))
						parsedembed.Remove(embedded.name)
						parsedembed.Add("multiple "+embedded.name)
				wound_flavor_text["[E.name]"] += "The [wound.desc] on [p_their()] [E.name] has \a [english_list(parsedembed, and_text = " and \a ", comma_text = ", \a ")] sticking out of it!<br>"
	for(var/hidden in hidden_bleeders)
		wound_flavor_text[hidden] = "[p_they(TRUE)] [p_have()] blood soaking through [hidden] around [p_their()] [english_list(hidden_bleeders[hidden])]!<br>"

	msg += "<span class='warning'>"
	for(var/limb in wound_flavor_text)
		msg += wound_flavor_text[limb]
	msg += "</span>"

	for(var/obj/implant in get_visible_implants(0))
		if(implant in shown_objects)
			continue
		msg += "<span class='danger'>[src] [p_have()] \a [implant.name] sticking out of [p_their()] flesh!</span>\n"
	if(digitalcamo)
		msg += "[p_they(TRUE)] [p_are()] repulsively uncanny!\n"

	if(hasHUD(user, HUD_SECURITY))
		var/perpname = "wot"
		var/criminal = "None"

		var/obj/item/card/id/id = GetIdCard()
		if(istype(id))
			perpname = id.registered_name
		else
			perpname = src.name

		if(perpname)
			var/datum/computer_file/report/crew_record/R = get_crewmember_record(perpname)
			if(R)
				criminal = R.get_criminalStatus()

			msg += "<span class = 'deptradio'>Criminal status:</span> <a href='byond://?src=\ref[src];criminal=1'>\[[criminal]\]</a>\n"
			msg += "<span class = 'deptradio'>Security records:</span> <a href='byond://?src=\ref[src];secrecord=`'>\[View\]</a>\n"

			if(GLOB.informants.is_antagonist(mind))	// hacky, but functional
				msg += "<span class = 'deptradio'>Special information:</span> This D-class is listed as an INFORMANT. Protect him, but do not blow his cover."

	if(hasHUD(user, HUD_MEDICAL))
		var/perpname = "wot"
		var/medical = "None"

		var/obj/item/card/id/id = GetIdCard()
		if(istype(id))
			perpname = id.registered_name
		else
			perpname = src.name

		var/datum/computer_file/report/crew_record/R = get_crewmember_record(perpname)
		if(R)
			medical = R.get_status()

		msg += "<span class = 'deptradio'>Physical status:</span> <a href='byond://?src=\ref[src];medical=1'>\[[medical]\]</a>\n"
		msg += "<span class = 'deptradio'>Medical records:</span> <a href='byond://?src=\ref[src];medrecord=`'>\[View\]</a>\n"


	if(print_flavor_text()) msg += "[print_flavor_text()]\n"

	msg += "*---------*</span><br>"
	msg += applying_pressure

	if(pose)
		if( findtext(pose,".",length(pose)) == 0 && findtext(pose,"!",length(pose)) == 0 && findtext(pose,"?",length(pose)) == 0 )
			pose = addtext(pose,".") //Makes sure all emotes end with a period.
		msg += "[p_they()] [pose]\n"

	var/show_descs = show_descriptors_to(user)
	if(show_descs)
		msg += SPAN_NOTICE("[jointext(show_descs, "<br>")]")

	for(var/datum/status_effect/effect as anything in status_effects)
		var/effect_text = effect.get_examine_text()
		if(!effect_text)
			continue

		msg += effect_text

	to_chat(user, jointext(msg, null))

//Helper procedure. Called by /mob/living/carbon/human/examine() and /mob/living/carbon/human/Topic() to determine HUD access to security and medical records.
/proc/hasHUD(mob/M as mob, hudtype)
	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/clothing/glasses/G = H.glasses
		var/obj/item/card/id/ID = M.GetIdCard()
		var/obj/item/organ/internal/augment/active/hud/AUG
		for (var/obj/item/organ/internal/augment/active/hud/A in H.internal_organs) // Check for installed and active HUD implants
			if(A.hud_type & hudtype)
				AUG = A
				break

		return ((istype(G) && ((G.hud_type & hudtype) || (G.hud && (G.hud.hud_type & hudtype)))) && G.check_access(ID)) || AUG?.active && AUG.check_access(ID)
	else if(istype(M, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = M
		for(var/obj/item/borg/sight/sight in list(R.module_state_1, R.module_state_2, R.module_state_3))
			if(istype(sight) && (sight.hud_type & hudtype))
				return TRUE
	return FALSE

/mob/living/carbon/human/verb/pose()
	set name = "Set Pose"
	set desc = "Sets a description which will be shown when someone examines you."
	set category = "IC"

	pose =  sanitize(input(usr, "This is [src]. [get_visible_gender() == MALE ? "He" : get_visible_gender() == FEMALE ? "She" : "They"]...", "Pose", null)  as text)

/mob/living/carbon/human/verb/set_flavor()
	set name = "Set Flavour Text"
	set desc = "Sets an extended description of your character's features."
	set category = "IC"

	var/list/HTML = list()
	HTML += "<body>"
	HTML += "<tt><center>"
	HTML += "<b>Update Flavour Text</b> <hr />"
	HTML += "<br></center>"
	HTML += "<a href='byond://?src=\ref[src];flavor_change=general'>General:</a> "
	HTML += TextPreview(flavor_texts["general"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[src];flavor_change=head'>Head:</a> "
	HTML += TextPreview(flavor_texts["head"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[src];flavor_change=face'>Face:</a> "
	HTML += TextPreview(flavor_texts["face"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[src];flavor_change=eyes'>Eyes:</a> "
	HTML += TextPreview(flavor_texts["eyes"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[src];flavor_change=torso'>Body:</a> "
	HTML += TextPreview(flavor_texts["torso"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[src];flavor_change=arms'>Arms:</a> "
	HTML += TextPreview(flavor_texts["arms"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[src];flavor_change=hands'>Hands:</a> "
	HTML += TextPreview(flavor_texts["hands"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[src];flavor_change=legs'>Legs:</a> "
	HTML += TextPreview(flavor_texts["legs"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[src];flavor_change=feet'>Feet:</a> "
	HTML += TextPreview(flavor_texts["feet"])
	HTML += "<br>"
	HTML += "<hr />"
	HTML +="<a href='byond://?src=\ref[src];flavor_change=done'>\[Done\]</a>"
	HTML += "<tt>"
	show_browser(src, jointext(HTML,null), "window=flavor_changes;size=430x300")
