/atom/proc/get_codex_value()
	return src

/atom/proc/get_specific_codex_entry()
	if(SScodex.entries_by_path[type])
		return SScodex.entries_by_path[type]

/// Return FALSE if the mob viewing should not get a direct codex link (e.g. chameleon gear)
/atom/proc/can_see_codex(mob/viewer)
	return TRUE

/atom/examine(mob/user, distance, infix = "", suffix = "")
	. = ..()
	var/datum/codex_entry/entry = SScodex.get_codex_entry(get_codex_value())
	if(entry && can_see_codex(user))
		to_chat(user, SPAN_NOTICE("The codex has <b><a href='byond://?src=\ref[SScodex];show_examined_info=\ref[src];show_to=\ref[user]'>relevant information</a></b> available."))
