/datum/antagonist/proc/get_panel_entry(datum/mind/player)

	var/dat = "<tr><td><b>[role_text]:</b>"
	var/extra = get_extra_panel_options(player)
	if(is_antagonist(player))
		dat += "<a href='byond://?src=\ref[player];remove_antagonist=[id]'>\[-\]</a>"
		dat += "<a href='byond://?src=\ref[player];equip_antagonist=[id]'>\[equip\]</a>"
		if(starting_locations && starting_locations.len)
			dat += "<a href='byond://?src=\ref[player];move_antag_to_spawn=[id]'>\[move to spawn\]</a>"
		if(extra) dat += "[extra]"
	else
		dat += "<a href='byond://?src=\ref[player];add_antagonist=[id]'>\[+\]</a>"
	dat += "</td></tr>"

	return dat

/datum/antagonist/proc/get_extra_panel_options()
	return

/datum/antagonist/proc/get_check_antag_output(datum/admins/caller)

	if(!current_antagonists || !current_antagonists.len)
		return ""

	var/dat = "<br><table cellspacing=5><tr><td><B>[role_text_plural]</B></td><td></td></tr>"
	for(var/datum/mind/player in current_antagonists)
		var/mob/M = player.current
		dat += "<tr>"
		if(M)
			dat += "<td>[ADMIN_PP(M)] [M.real_name]/([player.key])"
			if(!M.client)      dat += " <i>(logged out)</i>"
			if(M.stat == DEAD) dat += " <b><font color=red>(DEAD)</font></b>"
			dat += "</td>"
			dat += "<td>[ADMIN_PM(M)][ADMIN_TP(M)]</td>"
		else
			dat += "<td><i>Mob not found/([player.key])!</i></td>"
		dat += "</tr>"
	dat += "</table>"

	dat += get_additional_check_antag_output(caller)
	dat += "<hr>"
	return dat

//Overridden elsewhere.
/datum/antagonist/proc/get_additional_check_antag_output(datum/admins/caller)
	return ""
