/client/verb/mentorhelp(msg as text)
	set name = "Mhelp"
	set desc = "Request an in-game mentor to help you with one of the game's mechanics."
	set category = "Staff Help"

	if(!msg || !usr)
		return
	msg = sanitize(copytext(msg, 1, MAX_MESSAGE_LEN))
	if(!msg || !usr)
		return
	if(prefs.muted & MUTE_MENTOR)
		to_chat(src, SPAN_WARNING("You are unable to mentorhelp (muted)."))
		return

	var/mentormsg = SPAN_MENTOR(SPAN_BOLD("MENTORHELP: [key_name_mentor(src)]: ") + msg)

	log_mentor("MENTORHELP: [key_name_mentor(src)]: [msg]")

	for(var/client/C in GLOB.admins)
		if(is_mentor(C))
			sound_to(C, 'sounds/items/bikehorn.ogg')
			to_chat(C, mentormsg)

	to_chat(src, SPAN_MENTOR(SPAN_BOLD("PM to mentors: ") + msg))

/proc/key_name_mentor(asker)
	var/mob/M
	var/client/C
	var/ckey

	if(!asker)
		return "ERROR"

	if(istype(asker, /client))
		C = asker
		ckey = C.ckey
	else if(ismob(asker))
		M = asker
		C = M.client
		ckey = C.ckey
	else if(istext(asker))
		C = GLOB.ckey_directory[asker]
		ckey = asker
	else
		return "ERROR"

	return "<a href='byond://?mentorreply=[ckey]'>[ckey][!C ? "(DC)" : ""]</a>"

/proc/is_mentor(client/C)
	return check_rights(R_MENTOR, 1, C)

/client/proc/mentorpm_mob(mob/M as mob in SSmobs.mob_list)
	set name = "Mentor PM Mob"
	set category = null

	if(!is_mentor(usr))
		return
	if(!M.client)
		to_chat(usr, SPAN_WARNING("That mob has no associated player, or their player has disconnected."))
		return
	mentorpm(M)

/client/proc/mentorpm_panel()
	set name = "Mentor PM"
	set category = "Staff Help"

	if(!is_mentor(usr))
		return
	var/list/client/targets[0]

	for(var/client/C in GLOB.clients)
		targets |= C

	targets = sortList(targets)
	var/bullseye = input(src, "To whom shall we send a message?", "Mentor PM") in targets|null
	if(!bullseye)
		return
	mentorpm(bullseye)

/client/proc/mentorpm(target, msg)
	if(prefs.muted & MUTE_MENTOR)
		to_chat(src, SPAN_WARNING("You are unable to mentor PM (muted)."))
		return

	var/client/C
	var/mob/M
	if(isclient(target))
		C = target
	else if(istext(target))
		C = GLOB.ckey_directory[target]
	else if(ismob(target))
		M = target
		C = M.client
	if(!C) //If our target has disconnected or does not exist
		if(is_mentor(src))
			to_chat(src, SPAN_WARNING("Cannot reply: Client not found."))
		else
			mentorhelp(msg) //Our mentor has disconnected, send the line back out into the water
		return

	if(!msg)
		for(var/client/L in GLOB.admins)
			if(is_mentor(L))
				to_chat(L, SPAN_NOTICE("[src] has started replying to [target]'s mentorhelp."))

		msg = input(src, "Message:", "Mentor message") as text|null

		if(!msg)
			for(var/client/L in GLOB.admins)
				if(is_mentor(L))
					to_chat(L, SPAN_NOTICE("[src] has stopped replying to [target]'s mentorhelp."))
					return

		if(!C)
			if(is_mentor(src))
				to_chat(src, SPAN_WARNING("Cannot reply: Client not found."))
			else
				mentorhelp(msg)
			return

		msg = sanitize(copytext(msg, 1, MAX_MESSAGE_LEN))
		if(!msg)
			return

		log_mentor("Mentor PM: [SPAN_BOLD(key_name_mentor(src))] -> [SPAN_BOLD(key_name_mentor(C))]: [msg]")

		sound_to(C, 'sounds/items/bikehorn.ogg')
		to_chat(C, SPAN_NOTICE("Mentor PM from " + SPAN_BOLD(key_name_mentor(src)) + ": [msg]"))
		to_chat(src, SPAN_NOTICE("Mentor PM to " + SPAN_BOLD(key_name_mentor(C)) + ": [msg]"))

		for(var/client/L in GLOB.admins)
			if(is_mentor(L) && L.ckey != ckey && L.ckey != C.ckey) //no duplicate notifs
				to_chat(L, SPAN_MENTOR("Mentor PM: [SPAN_BOLD(key_name_mentor(src))] -> [SPAN_BOLD(key_name_mentor(C))]: [msg]"))
