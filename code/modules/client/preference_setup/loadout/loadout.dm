var/list/loadout_categories = list()
var/list/gear_datums = list()

/datum/preferences
	var/list/gear_list //Custom/fluff item loadouts.
	var/gear_slot = 1  //The current gear save slot

/datum/preferences/proc/Gear()
	return gear_list[gear_slot]

/datum/loadout_category
	var/category = ""
	var/list/gear = list()

/datum/loadout_category/New(cat)
	category = cat
	..()

/hook/startup/proc/populate_gear_list()

	//create a list of gear datums to sort
	for(var/geartype in typesof(/datum/gear)-/datum/gear)
		var/datum/gear/G = geartype
		if(initial(G.category) == geartype)
			continue
		if(GLOB.using_map.loadout_blacklist && (geartype in GLOB.using_map.loadout_blacklist))
			continue

		var/use_name = initial(G.display_name)
		var/use_category = initial(G.sort_category)

		if(!loadout_categories[use_category])
			loadout_categories[use_category] = new /datum/loadout_category(use_category)
		var/datum/loadout_category/LC = loadout_categories[use_category]
		gear_datums[use_name] = new geartype
		LC.gear[use_name] = gear_datums[use_name]

	loadout_categories = sortAssoc(loadout_categories)
	for(var/loadout_category in loadout_categories)
		var/datum/loadout_category/LC = loadout_categories[loadout_category]
		LC.gear = sortAssoc(LC.gear)
	return 1

/datum/category_item/player_setup_item/loadout
	name = "Loadout"
	sort_order = 1
	var/current_tab = "General"
	var/hide_unavailable_gear = 0

/datum/category_item/player_setup_item/loadout/load_character(datum/pref_record_reader/R)
	pref.gear_list = R.read("gear_list")
	pref.gear_slot = R.read("gear_slot")

/datum/category_item/player_setup_item/loadout/save_character(datum/pref_record_writer/W)
	W.write("gear_list", pref.gear_list)
	W.write("gear_slot", pref.gear_slot)

/datum/category_item/player_setup_item/loadout/proc/valid_gear_choices(max_cost)
	. = list()
	var/mob/preference_mob = preference_mob()
	for(var/gear_name in gear_datums)
		var/datum/gear/G = gear_datums[gear_name]
		var/okay = 1
		if(G.whitelisted && preference_mob)
			okay = 0
			for(var/species in G.whitelisted)
				if(is_species_whitelisted(preference_mob, species))
					okay = 1
					break
		if(!okay)
			continue
		if(max_cost && G.cost > max_cost)
			continue
		. += gear_name

/datum/category_item/player_setup_item/loadout/proc/skill_check(list/jobs, list/skills_required)
	for(var/datum/job/J in jobs)
		. = TRUE
		for(var/R in skills_required)
			if(pref.get_total_skill_value(J, R) < skills_required[R])
				. = FALSE
				break
		if(.)
			return

/datum/category_item/player_setup_item/loadout/sanitize_character()
	pref.gear_slot = sanitize_integer(pref.gear_slot, 1, config.loadout_slots, initial(pref.gear_slot))
	if(!islist(pref.gear_list)) pref.gear_list = list()

	if(pref.gear_list.len < config.loadout_slots)
		pref.gear_list.len = config.loadout_slots

	for(var/index = 1 to config.loadout_slots)
		var/list/gears = pref.gear_list[index]

		if(istype(gears))
			for(var/gear_name in gears)
				if(!(gear_name in gear_datums))
					gears -= gear_name

			var/total_cost = 0
			for(var/gear_name in gears)
				if(!gear_datums[gear_name])
					gears -= gear_name
				else if(!(gear_name in valid_gear_choices()))
					gears -= gear_name
				else
					var/datum/gear/G = gear_datums[gear_name]
					if(total_cost + G.cost > config.max_gear_cost)
						gears -= gear_name
					else
						total_cost += G.cost
		else
			pref.gear_list[index] = list()

/datum/category_item/player_setup_item/loadout/content()
	. = list()
	var/total_cost = 0
	var/list/gears = pref.gear_list[pref.gear_slot]
	for(var/i = 1; i <= gears.len; i++)
		var/datum/gear/G = gear_datums[gears[i]]
		if(G)
			total_cost += G.cost

	var/fcolor =  "#3366cc"
	if(total_cost < config.max_gear_cost)
		fcolor = "#e67300"
	. += "<table align = 'center' width = 100%>"
	. += "<tr><td colspan=3><center>"
	. += "<a href='byond://?src=\ref[src];prev_slot=1'>\<=</a><b><font color = '[fcolor]'>\[[pref.gear_slot]\]</font> </b><a href='byond://?src=\ref[src];next_slot=1'>=\></a>"

	if(config.max_gear_cost < INFINITY)
		. += "<b><font color = '[fcolor]'>[total_cost]/[config.max_gear_cost]</font> loadout points spent.</b>"

	. += "<a href='byond://?src=\ref[src];clear_loadout=1'>Clear Loadout</a>"
	. += "<a href='byond://?src=\ref[src];toggle_hiding=1'>[hide_unavailable_gear ? "Show all" : "Hide unavailable"]</a></center></td></tr>"

	. += "<tr><td colspan=3><center><b>"
	var/firstcat = 1
	for(var/category in loadout_categories)

		if(firstcat)
			firstcat = 0
		else
			. += " |"

		var/datum/loadout_category/LC = loadout_categories[category]
		var/category_cost = 0
		for(var/gear in LC.gear)
			if(gear in pref.gear_list[pref.gear_slot])
				var/datum/gear/G = LC.gear[gear]
				category_cost += G.cost

		if(category == current_tab)
			. += " <span class='linkOn'>[category] - [category_cost]</span> "
		else
			if(category_cost)
				. += " <a href='byond://?src=\ref[src];select_category=[category]'><font color = '#e67300'>[category] - [category_cost]</font></a> "
			else
				. += " <a href='byond://?src=\ref[src];select_category=[category]'>[category] - 0</a> "

	. += "</b></center></td></tr>"

	var/datum/loadout_category/LC = loadout_categories[current_tab]
	. += "<tr><td colspan=3><hr></td></tr>"
	. += "<tr><td colspan=3><b><center>[LC.category]</center></b></td></tr>"
	. += "<tr><td colspan=3><hr></td></tr>"
	var/jobs = list()
	for(var/job_title in (pref.job_medium|pref.job_low|pref.job_high))
		var/datum/job/J = SSjobs.get_by_title(job_title)
		if(J)
			dd_insertObjectList(jobs, J)
	for(var/gear_name in LC.gear)
		if(!(gear_name in valid_gear_choices()))
			continue
		var/list/entry = list()
		var/datum/gear/G = LC.gear[gear_name]
		var/ticked = (G.display_name in pref.gear_list[pref.gear_slot])
		entry += "<tr style='vertical-align:top;'><td width=25%><a style='white-space:normal;' [ticked ? "class='linkOn' " : ""]href='byond://?src=\ref[src];toggle_gear=\ref[G]'>[G.display_name]</a></td>"
		entry += "<td width = 10% style='vertical-align:top'>[G.cost]</td>"
		entry += "<td><font size=2>[G.get_description(get_gear_metadata(G,1))]</font>"
		entry += "<br><i>"

		var/allowed = 1

		var/list/good_jobs = list()
		var/list/bad_jobs = list()
		var/list/jobchecks = list()

		for(var/datum/job/J in jobs)

			// If a department permission is set, we'll work downwards
			// We'll add all roles with a tag, and any allowed_roles, to our "allowed" list, and then remove the denied_roles
			// Every other role is disallowed

			if (G.whitelist_department_flags)
				if(J.department_flag & G.whitelist_department_flags)
					if(J.type in G.denied_roles)
						bad_jobs |= J
					else
						good_jobs |= J
				else if (J.type in G.allowed_roles)
					good_jobs |= J
				else
					bad_jobs |= J

			else if (G.blacklist_department_flags)
				if(J.department_flag & G.blacklist_department_flags)
					if(J.type in G.allowed_roles)
						good_jobs |= J
					else
						bad_jobs |= J
				else if (J.type in G.denied_roles)
					bad_jobs |= J
				else
					good_jobs |= J

			// Otherwise, if a specific allow role permission is set, we'll check that it isn't in an overriding denied_roles list
			else if (G.allowed_roles)
				if (J.type in G.denied_roles)
					bad_jobs |= J
				else if (J.type in G.allowed_roles)
					good_jobs |= J
				else
					bad_jobs |= J

			// And if we only have deny role permissions, we'll set everyone else to allow
			else if (G.denied_roles)
				if (J.type in G.denied_roles)
					bad_jobs |= J
				else
					good_jobs |= J

			// No permissions set = everyone
			else
				good_jobs |= J

		if (length(bad_jobs))
			for(var/datum/job/J in bad_jobs)
				jobchecks += "<font color=cc5555>[J.title]</font>"
				allowed = 0

			for(var/datum/job/J in good_jobs)
				jobchecks += "<font color=55cc55>[J.title]</font>"
				allowed = 1

			if (length(jobchecks))
				entry += "[english_list(jobchecks)]</i>"

		if(allowed && G.allowed_skills)
			var/list/skills_required = list()//make it into instances? instead of path
			for(var/skill in G.allowed_skills)
				var/decl/hierarchy/skill/instance = decls_repository.get_decl(skill)
				skills_required[instance] = G.allowed_skills[skill]

			allowed = skill_check(jobs, skills_required)//Checks if a single job has all the skills required

			entry += "<br><i>"
			var/list/skill_checks = list()
			for(var/R in skills_required)
				var/decl/hierarchy/skill/S = R
				var/skill_entry
				skill_entry += "[S.levels[skills_required[R]]]"
				if(allowed)
					skill_entry = "<font color=55cc55>[skill_entry] [R]</font>"
				else
					skill_entry = "<font color=cc5555>[skill_entry] [R]</font>"
				skill_checks += skill_entry

			entry += "[english_list(skill_checks)]</i>"

		if (G.whitelisted && pref.species)
			entry += "<br><i>"
			if (islist(G.whitelisted))
				var/list/species_names = list()
				for (var/V in G.whitelisted)
					if (V == pref.species)
						species_names += "<font color=55cc55>[V]</font>"
					else
						species_names += "<font color=cc5555>[V]</font>"
				entry += "[english_list(species_names, and_text = " or ", comma_text = " or ", final_comma_text = "")]"
			else
				if (pref.species == G.whitelisted)
					entry += "<font color=55cc55>[pref.species]</font>"
				else
					entry += "<font color=cc5555>[pref.species]</font>"

			entry += "</i>"

		entry += "</tr>"
		if(ticked)
			entry += "<tr><td colspan=3>"
			for(var/datum/gear_tweak/tweak in G.gear_tweaks)
				var/contents = tweak.get_contents(get_tweak_metadata(G, tweak))
				if(contents)
					entry += " <a href='byond://?src=\ref[src];gear=\ref[G];tweak=\ref[tweak]'>[contents]</a>"
			entry += "</td></tr>"
		if(!hide_unavailable_gear || allowed || ticked)
			. += entry
	. += "</table>"
	. = jointext(.,null)

/datum/category_item/player_setup_item/loadout/proc/get_gear_metadata(datum/gear/G, readonly)
	var/list/gear = pref.gear_list[pref.gear_slot]
	. = gear[G.display_name]
	if(!.)
		. = list()
		if(!readonly)
			gear[G.display_name] = .

/datum/category_item/player_setup_item/loadout/proc/get_tweak_metadata(datum/gear/G, datum/gear_tweak/tweak)
	var/list/metadata = get_gear_metadata(G)
	. = metadata["[tweak]"]
	if(!.)
		. = tweak.get_default()
		metadata["[tweak]"] = .

/datum/category_item/player_setup_item/loadout/proc/set_tweak_metadata(datum/gear/G, datum/gear_tweak/tweak, new_metadata)
	var/list/metadata = get_gear_metadata(G)
	metadata["[tweak]"] = new_metadata

/datum/category_item/player_setup_item/loadout/OnTopic(href, href_list, user)
	if(href_list["toggle_gear"])
		var/datum/gear/TG = locate(href_list["toggle_gear"])
		if(!istype(TG) || gear_datums[TG.display_name] != TG)
			return TOPIC_REFRESH
		if(TG.display_name in pref.gear_list[pref.gear_slot])
			pref.gear_list[pref.gear_slot] -= TG.display_name
		else
			var/total_cost = 0
			for(var/gear_name in pref.gear_list[pref.gear_slot])
				var/datum/gear/G = gear_datums[gear_name]
				if(istype(G)) total_cost += G.cost
			if((total_cost+TG.cost) <= config.max_gear_cost)
				pref.gear_list[pref.gear_slot] += TG.display_name
		return TOPIC_REFRESH_UPDATE_PREVIEW
	if(href_list["gear"] && href_list["tweak"])
		var/datum/gear/gear = locate(href_list["gear"])
		var/datum/gear_tweak/tweak = locate(href_list["tweak"])
		if(!tweak || !istype(gear) || !(tweak in gear.gear_tweaks) || gear_datums[gear.display_name] != gear)
			return TOPIC_NOACTION
		var/metadata = tweak.get_metadata(user, get_tweak_metadata(gear, tweak))
		if(!metadata || !CanUseTopic(user))
			return TOPIC_NOACTION
		set_tweak_metadata(gear, tweak, metadata)
		return TOPIC_REFRESH_UPDATE_PREVIEW
	if(href_list["next_slot"])
		pref.gear_slot = pref.gear_slot+1
		if(pref.gear_slot > config.loadout_slots)
			pref.gear_slot = 1
		return TOPIC_REFRESH_UPDATE_PREVIEW
	if(href_list["prev_slot"])
		pref.gear_slot = pref.gear_slot-1
		if(pref.gear_slot < 1)
			pref.gear_slot = config.loadout_slots
		return TOPIC_REFRESH_UPDATE_PREVIEW
	if(href_list["select_category"])
		current_tab = href_list["select_category"]
		return TOPIC_REFRESH
	if(href_list["clear_loadout"])
		var/list/gear = pref.gear_list[pref.gear_slot]
		gear.Cut()
		return TOPIC_REFRESH_UPDATE_PREVIEW
	if(href_list["toggle_hiding"])
		hide_unavailable_gear = !hide_unavailable_gear
		return TOPIC_REFRESH
	return ..()

/datum/gear
	/// Name/index. Must be unique.
	var/display_name
	/// Description of this gear. If left blank, it will default to the description of the pathed item.
	var/description
	/// A path to the item to spawn.
	var/path
	/// Number of points used. Default point amount is 10; balance accordingly.
	var/cost = 1
	/// The slot define to equip this item to - slot_tie, slot_gloves, etc.
	var/slot
	/// Categories are automatically generated by strings in gear types. This value indicates which category the gear datum belongs to.
	var/sort_category = "General"
	/// Flags that affect this gear item. Check "loadout/_defines.dm" for more information on these.
	var/flags
	/// The path to an atom proc that will be called on the spawned item when it is created. Use to set information on passports, and so on.
	var/custom_setup_proc
	/// Unused?
	var/category
	/// A blacklist of roles that can spawn with this item. If blank, it's valid for all roles.
	var/list/denied_roles
	/// A whitelist of roles that can spawn with this item. If blank, it's valid for all roles.
	var/list/allowed_roles
	/// A whitelist of department bitflags that can spawn with this item. If null, all departments are allowed.
	var/whitelist_department_flags
	/// A blacklist of department bitflags that can spawn with this item. If null, all departments are allowed.
	var/blacklist_department_flags
	/// Skills required to spawn with this item. If blank, no skills are required.
	var/list/allowed_skills
	/// The species whitelist required to spawn with this item. Can be a single value or a list of valid options.
	var/whitelisted
	/// List of datums which will alter the item after it has been spawned. Typically added by flags.
	var/list/gear_tweaks = list()

/datum/gear/New()
	if(HAS_FLAGS(flags, GEAR_HAS_TYPE_SELECTION|GEAR_HAS_SUBTYPE_SELECTION))
		CRASH("May not have both type and subtype selection tweaks")
	if(!description)
		var/obj/O = path
		description = initial(O.desc)
	if(flags & GEAR_HAS_COLOR_SELECTION)
		gear_tweaks += gear_tweak_free_color_choice()
	if(flags & GEAR_HAS_TYPE_SELECTION)
		gear_tweaks += new/datum/gear_tweak/path/type(path)
	if(flags & GEAR_HAS_SUBTYPE_SELECTION)
		gear_tweaks += new/datum/gear_tweak/path/subtype(path)
	if(custom_setup_proc)
		gear_tweaks += new/datum/gear_tweak/custom_setup(custom_setup_proc)

/datum/gear/proc/get_description(metadata)
	. = description
	for(var/datum/gear_tweak/gt in gear_tweaks)
		. = gt.tweak_description(., metadata["[gt]"])

/datum/gear_data
	var/path
	var/location

/datum/gear_data/New(path, location)
	src.path = path
	src.location = location

/datum/gear/proc/spawn_item(user, location, metadata)
	var/datum/gear_data/gd = new(path, location)
	for(var/datum/gear_tweak/gt in gear_tweaks)
		gt.tweak_gear_data(metadata && metadata["[gt]"], gd)
	var/item = new gd.path(gd.location)
	for(var/datum/gear_tweak/gt in gear_tweaks)
		gt.tweak_item(user, item, metadata && metadata["[gt]"])
	return item

/datum/gear/proc/spawn_in_storage_or_drop(mob/living/carbon/human/H, metadata)
	var/obj/item/item = spawn_item(H, H, metadata)
	item.add_fingerprint(H)

	// Roundstart augments require special handling in order to properly install
	if (istype(item, /obj/item/organ/internal/augment))
		var/obj/item/organ/internal/augment/A = item
		var/obj/item/organ/external/affected = H.get_organ(A.parent_organ)
		if (!affected)
			to_chat(H, SPAN_WARNING("Failed to install \the [A]!"))
			QDEL_NULL(A)
		else
			var/beep_boop = BP_IS_ROBOTIC(affected)
			var/obj/item/organ/internal/I = H.internal_organs_by_name[A.organ_tag]
			if (!(A.augment_flags & AUGMENTATION_MECHANIC) && beep_boop)
				to_chat(H, SPAN_WARNING("\The [A] cannot be installed in a robotic part!"))
				QDEL_NULL(A)
			else if (!(A.augment_flags & AUGMENTATION_ORGANIC) && !beep_boop)
				to_chat(H, SPAN_WARNING("\The [A] cannot be installed in an organic part!"))
				QDEL_NULL(A)
			else if(I && (I.parent_organ == A.parent_organ))
				to_chat(H, SPAN_WARNING("\The [A] could not be installed because you can only have one [A.organ_tag] at a time."))
				QDEL_NULL(A)
			else
				to_chat(H, SPAN_NOTICE("Installing \the [A] in your [affected.name]!"))
				A.forceMove(H)
				A.replaced(H, affected)
				A.onRoundstart()
				. = A
	else
		if(H.equip_to_slot_if_possible(item, slot, del_on_fail = 0, force = 0))
			to_chat(H, SPAN_NOTICE("Placing \the [item] in its default inventory slot!"))
		else if(H.equip_to_appropriate_slot(item))
			to_chat(H, SPAN_NOTICE("Placing \the [item] in an inventory slot!"))
		else
			var/atom/placed_in = H.equip_to_storage(item)
			if(placed_in)
				to_chat(H, SPAN_NOTICE("Placing \the [item] in your [placed_in.name]!"))
			else if(H.put_in_hands(item))
				to_chat(H, SPAN_NOTICE("Placing \the [item] in your hands!"))
			else
				to_chat(H, SPAN_DANGER("Dropping \the [item] on the ground!"))
