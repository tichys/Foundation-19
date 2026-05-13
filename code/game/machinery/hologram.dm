/* Holograms!
 * Contains:
 *		Holopad
 *		Hologram
 *		Other stuff
 */

/*
Revised. Original based on space ninja hologram code. Which is also mine. /N
How it works:
AI clicks on holopad in camera view. View centers on holopad.
AI clicks again on the holopad to display a hologram. Hologram stays as long as AI is looking at the pad and it (the hologram) is in range of the pad.
AI can use the directional keys to move the hologram around, provided the above conditions are met and the AI in question is the holopad's master.
Only one AI may project from a holopad at any given time.
AI may cancel the hologram at any time by clicking on the holopad once more.

Possible to do for anyone motivated enough:
	Give an AI variable for different hologram icons.
	Itegrate EMP effect to disable the unit.
*/


/*
 * Holopad
 */

#define HOLOPAD_PASSIVE_POWER_USAGE (1<<0)
#define HOLOGRAM_POWER_USAGE 		(1<<1)
#define RANGE_BASED 				(1<<2)
#define AREA_BASED 					6

GLOBAL_LIST_EMPTY(holopad_list)
var/const/HOLOPAD_MODE = RANGE_BASED

/obj/machinery/hologram/holopad
	name = "\improper holopad"
	desc = "It's a floor-mounted device for projecting holographic images."
	icon_state = "holopad-B0"

	layer = ABOVE_TILE_LAYER

	idle_power_usage = 5

	var/power_per_hologram = 500 //per usage per hologram

	var/list/mob/living/silicon/ai/masters = new() //List of AIs that use the holopad
	var/holo_range = 5 // Change to change how far the AI can move away from the holopad before deactivating.

	/// World.time at which the holopad can attempt to call other pads again
	var/request_cooldown = 0
	/// Cooldown time added to world.time upon successful request
	var/request_cooldown_time = 20 SECONDS

	var/last_message

	var/incoming_connection = FALSE
	var/mob/living/caller_id
	var/obj/machinery/hologram/holopad/sourcepad
	var/obj/machinery/hologram/holopad/targetpad

	var/holopad_id = null
	var/list/recent_calls = list()

	var/holopadType = HOLOPAD_SHORT_RANGE //Whether the holopad is short-range or long-range.
	var/base_icon = "holopad-B"

	var/allow_ai = TRUE

/obj/machinery/hologram/holopad/Initialize()
	. = ..()
	if(isnull(holopad_id))
		var/area/A = get_area(src)
		holopad_id = A.name
	// Handling duplicate IDs
	var/holo_number = 0
	var/new_holo_id = holopad_id
	while(new_holo_id in GLOB.holopad_list)
		holo_number += 1
		new_holo_id = "[holopad_id] #[holo_number]"
	holopad_id = new_holo_id
	GLOB.holopad_list[holopad_id] = src

/obj/machinery/hologram/holopad/Destroy()
	GLOB.holopad_list -= holopad_id
	for(var/mob/living/master in masters)
		clear_holo(master)
	return ..()

/obj/machinery/hologram/holopad/Process()
	for(var/mob/living/silicon/ai/master in masters)
		var/active_ai = (master && !master.incapacitated() && master.client && master.eyeobj)//If there is an AI with an eye attached, it's not incapacitated, and it has a client
		if((stat & NOPOWER) || !active_ai)
			clear_holo(master)
			continue

		if(!(masters[master] in view(src)))
			clear_holo(master)
			continue

		use_power_oneoff(power_per_hologram)

	if(world.time > request_cooldown && incoming_connection)
		if(sourcepad)
			sourcepad.audible_message(SPAN_WARNING("<i>The holopad connection timed out</i>"))
		incoming_connection = 0
		end_call()

	if(caller_id && sourcepad)
		if(caller_id.loc != sourcepad.loc)
			to_chat(sourcepad.caller_id, SPAN_WARNING("Severing connection to distant holopad."))
			end_call()
			audible_message(SPAN_WARNING("The connection has been terminated by the caller."))

	return TRUE

/obj/machinery/hologram/holopad/examine(mob/user)
	. = ..()
	if(holopad_id)
		to_chat(user, SPAN_NOTICE("Its ID is '<b>[holopad_id]</b>'"))

	if(incoming_connection && sourcepad)
		to_chat(user, SPAN_NOTICE("There is currently an incoming call from [get_area(sourcepad)]!"))

	var/callstring = "Recent incoming calls:"
	for(var/id in recent_calls)
		callstring += "\n[id]"
	callstring = SPAN_NOTICE(callstring)
	to_chat(user, callstring)

/obj/machinery/hologram/holopad/interface_interact(mob/living/carbon/human/user)
	if(!CanInteract(user, DefaultTopicState()))
		return FALSE

	if(incoming_connection && caller_id)
		if(QDELETED(sourcepad)) // If the sourcepad was deleted, most likely.
			incoming_connection = 0
			clear_holo()
			return TRUE
		visible_message("The pad hums quietly as it establishes a connection.")
		if(caller_id.loc != sourcepad.loc)
			visible_message("The pad flashes an error message. The caller has left their holopad.")
			return TRUE
		take_call(user)
		return TRUE
	else if(caller_id && !incoming_connection)
		audible_message("Severing connection to distant holopad.")
		end_call(user)
		return TRUE

	. = TRUE

	var/handle_type = "Holocomms"
	var/ai_exists = FALSE

	for(var/mob/living/silicon/ai/AI in GLOB.living_mob_list_)
		if(!AI.client)
			continue
		ai_exists = TRUE
		break

	if(allow_ai && ai_exists)
		handle_type = alert(user,"Would you like to request an AI's presence or establish communications with another pad?", "Holopad","AIC","Holocomms","Cancel")

	switch(handle_type)
		if("AIC")
			if(request_cooldown > world.time) // Don't spam the AI with requests you jerk!
				to_chat(user, SPAN_NOTICE("A request for AIC presence was already sent recently."))
				return

			request_cooldown = world.time + request_cooldown_time
			to_chat(user, SPAN_NOTICE("You request an AIC's presence."))
			for(var/mob/living/silicon/ai/AI in GLOB.living_mob_list_)
				if(!AI.client)
					continue
				if(holopadType != HOLOPAD_LONG_RANGE && !AreConnectedZLevels(AI.z, src.z))
					continue
				to_chat(AI, SPAN_INFO("Your presence is requested at <a href='byond://?src=\ref[AI];jumptoholopad=\ref[src]'>\the [holopad_id]</a>."))

		if("Holocomms")
			if(user.loc != loc)
				to_chat(user, SPAN_INFO("Please step onto the holopad."))
				return

			if(request_cooldown > world.time) // Don't spam other people with requests either, you jerk!
				to_chat(user, SPAN_NOTICE("A request for holographic communication was already sent recently."))
				return

			request_cooldown = world.time + request_cooldown_time
			var/zlevels = GetConnectedZlevels(z)
			var/zlevels_long = list()
			if(GLOB.using_map.use_overmap && holopadType == HOLOPAD_LONG_RANGE)
				for(var/zlevel in map_sectors)
					var/obj/effect/overmap/visitable/O = map_sectors["[zlevel]"]
					if(!isnull(O))
						zlevels_long |= O.map_z
			var/list/holopad_list = list()
			for(var/HID in GLOB.holopad_list)
				var/obj/machinery/hologram/holopad/H = GLOB.holopad_list[HID]
				if(!istype(H))
					continue
				if(!H.operable())
					continue
				if(H.z in zlevels)
					holopad_list[HID] = H
				else if(H.holopadType == HOLOPAD_LONG_RANGE && (H.z in zlevels_long))
					holopad_list[HID] = H
			holopad_list = sortAssoc(holopad_list)
			var/temp_pad = input(user, "Which holopad would you like to contact?", "holopad list") as null|anything in holopad_list
			targetpad = holopad_list[temp_pad]

			if(QDELETED(targetpad) || !istype(targetpad))
				to_chat(user, SPAN_WARNING("The connection could not be made due to an instance error!"))
				targetpad = null
				return
			if(!targetpad.operable())
				to_chat(user, SPAN_WARNING("The connection could not be made due to target pad being unreachable!"))
				targetpad = null
				return
			if(targetpad == src)
				to_chat(user, SPAN_INFO("Using such sophisticated technology, just to talk to yourself seems a bit silly."))
				targetpad = null //Clean up the mess after an unsuccessful call
				return
			if(targetpad.caller_id)
				to_chat(user, SPAN_INFO("The pad flashes a busy sign. Maybe you should try again later.."))
				targetpad = null //Clean up the mess after an unsuccessful call
				return
			// Successful call attempt
			make_call(targetpad, user)

/obj/machinery/hologram/holopad/attackby(obj/item/W, mob/user)
	if(isMultitool(W))
		var/new_hid = sanitize(input(user, "Select new holopad ID.",,holopad_id) as text|null, 30)
		if(new_hid)
			ChangeID(new_hid)
			playsound(get_turf(src), 'sounds/effects/pop.ogg', 25)
			to_chat(user, SPAN_NOTICE("\The [src] ID has been changed to [holopad_id]!"))
		return
	return ..()

/obj/machinery/hologram/holopad/proc/make_call(obj/machinery/hologram/holopad/targetpad, mob/living/carbon/user)
	targetpad.request_cooldown = world.time + request_cooldown_time
	targetpad.sourcepad = src //This marks the holopad you are making the call from
	targetpad.caller_id = user //This marks you as the caller
	targetpad.incoming_connection = TRUE
	playsound(targetpad.loc, 'sounds/machines/chime.ogg', 25, 5)
	targetpad.icon_state = "[targetpad.base_icon]1"
	targetpad.audible_message("<b>\The [src]</b> announces, \"Incoming communications request from [targetpad.sourcepad.loc.loc].\"")
	to_chat(user, SPAN_NOTICE("Trying to establish a connection to the holopad in [targetpad.loc.loc]... Please await confirmation from recipient."))
	targetpad.addrecentcall(get_area(src))


/obj/machinery/hologram/holopad/proc/take_call(mob/living/carbon/user)
	incoming_connection = FALSE
	caller_id.machine = sourcepad
	caller_id.reset_view(src)
	if(!masters[caller_id])//If there is no hologram, possibly make one.
		activate_holocall(caller_id)
	log_admin("[key_name(caller_id)] just established a holopad connection from [sourcepad.loc.loc] to [src.loc.loc]")

/obj/machinery/hologram/holopad/proc/end_call(mob/user)
	if(!caller_id)
		return
	caller_id.unset_machine()
	caller_id.reset_view() //Send the caller back to his body
	clear_holo(0, caller_id) // destroy the hologram
	caller_id = null

/obj/machinery/hologram/holopad/proc/addrecentcall(id)
	recent_calls += id
	if(length(recent_calls) > 5)
		recent_calls -= recent_calls[1]

/obj/machinery/hologram/holopad/check_eye(mob/user)
	return 0

/obj/machinery/hologram/holopad/attack_ai(mob/living/silicon/ai/user)
	if (!istype(user))
		return
	/*There are pretty much only three ways to interact here.
	I don't need to check for client since they're clicking on an object.
	This may change in the future but for now will suffice.*/
	if(user.eyeobj && (user.eyeobj.loc != src.loc))//Set client eye on the object if it's not already.
		user.eyeobj.setLoc(get_turf(src))
	else if(!allow_ai)
		to_chat(user, SPAN_WARNING("Access denied."))
	else if(holopadType != HOLOPAD_LONG_RANGE && !AreConnectedZLevels(user.z, src.z))
		to_chat(user, SPAN_WARNING("Out of range."))
	else if(!masters[user])//If there is no hologram, possibly make one.
		activate_holo(user)
	else//If there is a hologram, remove it.
		clear_holo(user)
	return

/obj/machinery/hologram/holopad/proc/activate_holo(mob/living/silicon/ai/user)
	if(!(stat & NOPOWER) && user.eyeobj && user.eyeobj.loc == src.loc)//If the projector has power and client eye is on it
		if (user.holo)
			to_chat(user, SPAN_DANGER("ERROR: Image feed in progress."))
			return
		src.visible_message("A holographic image of [user] flicks to life right before your eyes!")
		create_holo(user)//Create one.
	else
		to_chat(user, SPAN_DANGER("ERROR: Unable to project hologram."))
	return

/obj/machinery/hologram/holopad/proc/activate_holocall(mob/living/carbon/caller_id)
	if(caller_id)
		src.visible_message("A holographic image of [caller_id] flicks to life right before your eyes!")
		create_holo(0,caller_id)//Create one.
	else
		to_chat(caller_id, SPAN_DANGER("ERROR: Unable to project hologram."))
	return

// VV handler for updating the global list
/obj/machinery/hologram/holopad/proc/ChangeID(new_id)
	GLOB.holopad_list -= holopad_id
	// Handling duplicate IDs
	var/holo_number = 0
	var/new_holo_id = new_id
	while(new_holo_id in GLOB.holopad_list)
		holo_number += 1
		new_holo_id = "[holopad_id] #[holo_number]"
	holopad_id = new_holo_id
	GLOB.holopad_list[holopad_id] = src

/*This is the proc for special two-way communication between AI and holopad/people talking near holopad.
For the other part of the code, check silicon say.dm. Particularly robot talk.*/
// Note that speaking may be null here, presumably due to echo effects/non-mob transmission.
/obj/machinery/hologram/holopad/hear_talk(mob/living/M, text, verb, datum/language/speaking)
	if(M)
		for(var/mob/living/silicon/ai/master in masters)
			var/ai_text = text
			if(!master.say_understands(M, speaking))//The AI will be able to understand most mobs talking through the holopad.
				if(speaking)
					ai_text = speaking.scramble(text)
				else
					ai_text = stars(text)
			if(isanimal(M) && !M.universal_speak)
				var/datum/say_list/SA = M.say_list
				if (SA)
					ai_text = pick(SA.speak)
			var/name_used = M.GetVoice()
			//This communication is imperfect because the holopad "filters" voices and is only designed to connect to the master only.
			var/short_links = master.get_preference_value(/datum/client_preference/ghost_follow_link_length) == GLOB.PREF_SHORT
			var/follow = short_links ? "\[F]" : "\[Follow]"
			var/prefix = "<a href='byond://?src=\ref[master];trackname=[html_encode(name_used)];track=\ref[M]'>[follow]</a>"
			master.show_message(get_hear_message(name_used, ai_text, verb, speaking, prefix), 2)
	var/name_used = M.GetVoice()
	var/message
	if(isanimal(M) && !M.universal_speak)
		var/datum/say_list/SA = M.say_list
		if(LAZYLEN(SA.speak))
			message = get_hear_message(name_used, pick(SA.speak), verb, speaking)
	else
		message = get_hear_message(name_used, text, verb, speaking)
	if(targetpad && !targetpad.incoming_connection) //If this is the pad you're making the call from and the call is accepted
		targetpad.audible_message(message)
		targetpad.last_message = message
	if(sourcepad && sourcepad.targetpad && !sourcepad.targetpad.incoming_connection) //If this is a pad receiving a call and the call is accepted
		if(name_used==caller_id||text==last_message||findtext(text, "Holopad received")) //prevent echoes
			return
		sourcepad.audible_message(message)

/obj/machinery/hologram/holopad/proc/get_hear_message(name_used, text, verb, datum/language/speaking, prefix = "")
	if(speaking)
		return "<i><span class='game say'>Holopad received, <span class='name'>[name_used]</span>[prefix] [speaking.format_message(text, verb)]</span></i>"
	return "<i><span class='game say'>Holopad received, <span class='name'>[name_used]</span>[prefix] [verb], <span class='message'>\"[text]\"</span></span></i>"

/obj/machinery/hologram/holopad/see_emote(mob/living/M, text)
	if(M)
		for(var/mob/living/silicon/ai/master in masters)
			//var/name_used = M.GetVoice()
			var/rendered = "<i><span class='game say'>Holopad received, <span class='message'>[text]</span></span></i>"
			//The lack of name_used is needed, because message already contains a name.  This is needed for simple mobs to emote properly.
			master.show_message(rendered, 2)
		for(var/mob/living/carbon/master in masters)
			//var/name_used = M.GetVoice()
			var/rendered = "<i><span class='game say'>Holopad received, <span class='message'>[text]</span></span></i>"
			//The lack of name_used is needed, because message already contains a name.  This is needed for simple mobs to emote properly.
			master.show_message(rendered, 2)
		if(targetpad)
			targetpad.visible_message("<i><span class='message'>[text]</span></i>")

/obj/machinery/hologram/holopad/show_message(msg, type, alt, alt_type)
	for(var/mob/living/silicon/ai/master in masters)
		var/rendered = "<i><span class='game say'>The holographic image of <span class='message'>[msg]</span></span></i>"
		master.show_message(rendered, type)
	if(findtext(msg, "Holopad received,"))
		return
	for(var/mob/living/carbon/master in masters)
		var/rendered = "<i><span class='game say'>The holographic image of <span class='message'>[msg]</span></span></i>"
		master.show_message(rendered, type)
	if(targetpad)
		for(var/mob/living/carbon/master in view(targetpad))
			var/rendered = "<i><span class='game say'>The holographic image of <span class='message'>[msg]</span></span></i>"
			master.show_message(rendered, type)

/obj/machinery/hologram/holopad/proc/create_holo(mob/living/silicon/ai/A, mob/living/carbon/caller_id, turf/T = loc)
	var/obj/effect/overlay/hologram = new(T)//Spawn a blank effect at the location.
	if(caller_id)
		hologram.add_overlay(getHologramIcon(getFlatIcon(caller_id), hologram_color = holopadType)) // Add the callers image as an overlay to keep coloration!
	else if(A)
		if(holopadType == HOLOPAD_LONG_RANGE)
			hologram.add_overlay(A.holo_icon_longrange)
		else
			hologram.add_overlay(A.holo_icon) // Add the AI's configured holo Icon
	if(A)
		if(A.holo_icon_malf == TRUE)
			hologram.add_overlay(icon("icons/effects/effects.dmi", "malf-scanline"))
	hologram.mouse_opacity = MOUSE_OPACITY_TRANSPARENT//So you can't click on it.
	hologram.layer = ABOVE_HUMAN_LAYER //Above all the other objects/mobs. Or the vast majority of them.
	hologram.anchored = TRUE//So space wind cannot drag it.
	if(caller_id)
		hologram.SetName("[caller_id.name] (Hologram)")
		hologram.forceMove(get_step(src,1))
		masters[caller_id] = hologram
	else
		hologram.SetName("[A.name] (Hologram)") //If someone decides to right click.
		A.holo = src
		masters[A] = hologram
	hologram.set_light(1, 0.1, 2)	//hologram lighting
	hologram.color = color //painted holopad gives coloured holograms
	set_light(1, 0.1, 2)			//pad lighting
	icon_state = "[base_icon]1"
	return TRUE

/obj/machinery/hologram/holopad/proc/clear_holo(mob/living/silicon/ai/user, mob/living/carbon/caller_id)
	if(user)
		qdel(masters[user])//Get rid of user's hologram
		user.holo = null
		masters -= user //Discard AI from the list of those who use holopad

	if(caller_id)
		qdel(masters[caller_id])//Get rid of user's hologram
		masters -= caller_id //Discard the caller from the list of those who use holopad

	if(!length(masters))//If no users left
		set_light(0)			//pad lighting (hologram lighting will be handled automatically since its owner was deleted)
		icon_state = "[base_icon]0"
		if(sourcepad)
			sourcepad.targetpad = null
			sourcepad = null
			caller_id = null

	return TRUE

/obj/machinery/hologram/holopad/proc/move_hologram(mob/living/silicon/ai/user)
	if(masters[user])
		step_to(masters[user], user.eyeobj) // So it turns.
		var/obj/effect/overlay/H = masters[user]
		H.dropInto(user.eyeobj)
		masters[user] = H

		if(!(H in view(src)))
			clear_holo(user)
			return 0

		if((HOLOPAD_MODE == RANGE_BASED && (get_dist(user.eyeobj, src) > holo_range)))
			clear_holo(user)

		if(HOLOPAD_MODE == AREA_BASED)
			var/area/holo_area = get_area(src)
			var/area/hologram_area = get_area(H)
			if(hologram_area != holo_area)
				clear_holo(user)
	return 1


/obj/machinery/hologram/holopad/proc/setDir_hologram(new_dir, mob/living/silicon/ai/user)
	if(masters[user])
		var/obj/effect/overlay/hologram = masters[user]
		hologram.dir = new_dir



/*
 * Hologram
 */

/obj/machinery/hologram
	anchored = TRUE
	idle_power_usage = 5
	active_power_usage = 100

//Destruction procs.
/obj/machinery/hologram/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			if (prob(50))
				qdel(src)
		if(3.0)
			if (prob(5))
				qdel(src)
	return

/*
Holographic project of everything else.

/mob/verb/hologram_test()
	set name = "Hologram Debug New"
	set category = "CURRENT DEBUG"

	var/obj/effect/overlay/hologram = new(loc)//Spawn a blank effect at the location.
	var/icon/flat_icon = icon(getFlatIcon(src,0))//Need to make sure it's a new icon so the old one is not reused.
	flat_icon.ColorTone(rgb(125,180,225))//Let's make it bluish.
	flat_icon.ChangeOpacity(0.5)//Make it half transparent.
	var/input = input("Select what icon state to use in effect.",,"")
	if(input)
		var/icon/alpha_mask = new('icons/effects/effects.dmi', "[input]")
		flat_icon.AddAlphaMask(alpha_mask)//Finally, let's mix in a distortion effect.
		hologram.icon = flat_icon

		log_debug("Your icon should appear now.")

	return
*/

/*
 * Other Stuff: Is this even used?
 */
/obj/machinery/hologram/projector
	name = "hologram projector"
	desc = "It makes a hologram appear... with magnets or something..."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "hologram0"

/obj/machinery/hologram/holopad/longrange
	name = "long range holopad"
	desc = "It's a floor-mounted device for projecting holographic images. This one utilizes bluespace transmitter to communicate with far away locations."
	icon_state = "holopad-Y0"
	power_per_hologram = 1000 //per usage per hologram
	holopadType = HOLOPAD_LONG_RANGE
	base_icon = "holopad-Y"

// Used for overmap capable ships that should have communications, but not be AI accessible
/obj/machinery/hologram/holopad/longrange/remoteship
	allow_ai = FALSE

#undef RANGE_BASED
#undef AREA_BASED
#undef HOLOPAD_PASSIVE_POWER_USAGE
#undef HOLOGRAM_POWER_USAGE
