/*
* This subsystem populates and manages offsite singletons.
*/

SUBSYSTEM_DEF(offsites)
	name = "Offsites"
	init_order = SS_INIT_OFFSITES
	flags = SS_NO_FIRE

	/// Associative list. Key is the offsite type, value is the offsite ref
	var/list/offsites = list()
	/// Associative list. Key is the offsite name, value is the offsite ref
	var/list/offsites_by_name = list()

	/// Associative list. Key is template decl type, value is template decl ref.
	var/list/templates = list()
	/// Associative list. Key is template decl name, value is template decl ref.
	var/list/templates_by_name = list()

	/// Default offsite for regular communications.
	var/default_offsite = /datum/offsite/foundation
	/// Default offsite for antagonist communications.
	var/default_antag_offsite = /datum/offsite/chaos_insurgency
	/// Default fax template for admins.
	var/default_template = /decl/offsite_template/default

/datum/controller/subsystem/offsites/Initialize(timeofday)
	initialize_offsites()
	return ..()

/// Ran on initialize, populates the offsite lists
/datum/controller/subsystem/offsites/proc/initialize_offsites()
	for(var/type in subtypesof(/datum/offsite))
		if(is_abstract(type))
			continue

		var/datum/offsite/ref = new type
		offsites[type] = ref
		offsites_by_name[ref.name] = ref

	// There is a function in decls_repository to do this, but it doesn't check abstractness.
	for(var/type in subtypesof(/decl/offsite_template))
		if(is_abstract(type))
			continue

		var/decl/offsite_template/ref = decls_repository.get_decl(type)
		templates[type] = ref
		templates_by_name[ref.name] = ref

/datum/controller/subsystem/offsites/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "OffsitePanel", "Offsites")
		ui.open()

/datum/controller/subsystem/offsites/tgui_data(mob/user)
	var/list/data = list()

	data["offsites"] = list()
	for(var/key in offsites)
		var/datum/offsite/OS = offsites[key]

		var/list/offsite_history = list()
		for(var/thing in OS.received_faxes)
			var/list/rec_fax = list()
			rec_fax += thing
			rec_fax["type"] = "Received fax from"
			offsite_history += list(rec_fax)

		for(var/thing in OS.sent_faxes)
			var/list/sent_fax = list()
			sent_fax += thing
			sent_fax["type"] = "Sent fax by"
			offsite_history += list(sent_fax)

		for(var/thing in OS.received_messages)
			var/list/received_message = list()
			received_message += thing
			received_message["type"] = "Received message from"
			received_message["ref"] = html_decode(received_message["ref"])
			offsite_history += list(received_message)

		for(var/thing in OS.sent_messages)
			var/list/sent_message = list()
			sent_message += thing
			sent_message["type"] = "Sent message to"
			sent_message["ref"] = html_decode(sent_message["ref"])
			offsite_history += list(sent_message)

		data["offsites"] += list(list("name" = OS.name, "type" = OS.type, "data" = offsite_history))

	return data

/// Returns true if affirmative response with alert to the item already being taken. usr by default.
/datum/controller/subsystem/offsites/proc/verify_ui_taker(mob/user = usr)
	return (tgui_alert(user, "This is already taken! Are you sure?", "Already Taken", list("Yes", "No")) == "Yes")

/datum/controller/subsystem/offsites/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	if(..())
		return

	var/client/admin = usr.client
	if(!check_rights(R_ADMIN|R_MOD, TRUE, admin))
		return

	var/datum/offsite/cur_os = offsites[text2path(params["os"])]
	if(!cur_os)
		return

	switch(action)
		if("send_fax")
			var/fax_target = params["target"]
			var/id = params["id"]
			if(!isnull(id))
				var/output = cur_os.find_and_verify_taker(id, admin)
				if(output && (output["override"] == FALSE))
					return TRUE

			if(fax_target in GLOB.alldepartments)
				cur_os.send_fax(admin, fax_target)
			else
				cur_os.send_fax(admin)
			return TRUE
		if("send_msg")
			var/msg_target = params["target"]
			var/id = params["id"]
			if(!isnull(id))
				var/output = cur_os.find_and_verify_taker(id, admin)
				if(output && (output["override"] == FALSE))
					return TRUE

			var/mob/living/target
			if(msg_target)
				var/client/C = client_by_ckey(msg_target)
				if(istype(C))
					target = C.mob

			if(istype(target))
				cur_os.send_message(admin, target)
			else
				cur_os.send_message(admin)
			return TRUE
		if("take")
			var/id = params["fax"]
			cur_os.take_by_id(id)
			return TRUE
		if("read_fax")
			var/fax_id = params["fax"]

			var/obj/item/fax
			for(var/F in cur_os.history)
				if(F["id"] == fax_id)
					fax = F["ref"]
					break

			if(!istype(fax))
				to_chat(admin, SPAN_WARNING("The fax you're trying to view doesn't exist."))
				return TRUE
			show_fax_admin(fax)

			return TRUE

/datum/controller/subsystem/offsites/tgui_state(mob/user)
	return GLOB.admin_tgui_state

// TODO: track interception separately for each offsite + methods that bypass interception?
/proc/message_offsite(msg, mob/sender, offsite_type)
	var/datum/offsite/os
	if(isdatum(offsite_type))
		os = offsite_type
	else
		os = SSoffsites.offsites[offsite_type]
	if(!os)
		return

	var/list/mob/living/silicon/ai/intercepters = check_for_interception()
	if(intercepters.len)
		for(var/thing in intercepters)
			var/mob/living/silicon/ai/ai = thing

			var/action = tgui_alert(ai, "Outgoing message from [sender]:\n", "Message Intercepted", list("Modify", "Block", "Allow"), timeout = 30 SECONDS)

			switch(action)
				if("Modify")
					msg = tgui_input_text(ai, "Set new message (from [sender]):", "Modify Message", default = msg)
				if("Block")
					return

	os.receive_message(msg, sender)

/proc/fax_offsite(obj/item/rcvdcopy, mob/sender, offsite_type, department)
	var/datum/offsite/os
	if(isdatum(offsite_type))
		os = offsite_type
	else
		os = SSoffsites.offsites[offsite_type]
	if(!os)
		// we can still forward to other fax machines with the dept tag
		return TRUE

	var/list/mob/living/silicon/ai/intercepters = check_for_interception()
	if(intercepters.len)
		for(var/thing in intercepters)
			var/mob/living/silicon/ai/ai = thing

			if(tgui_alert(ai, "Outgoing fax from [department] to [os.name]!", "Fax intercepted", list("Intercept", "Allow"), timeout = 30 SECONDS) == "Intercept")

				if(istype(rcvdcopy, /obj/item/paper))
					var/obj/item/paper/paper_copy = rcvdcopy
					paper_copy.show_content(ai, TRUE)
					var/action = tgui_alert(ai, "Modify, block, or allow fax?", "Choose action", list("Modify", "Block", "Allow"))

					switch(action)
						if("Modify")
							var/t = tgui_input_text(ai, "Enter what you want to write:", "Write", html2pencode(paper_copy.info), MAX_PAPER_MESSAGE_LEN, TRUE)
							if(!t)
								continue

							var/old_fields_value = paper_copy.fields
							paper_copy.fields = 0
							t = replacetext(t, "\n", "\[br\]")
							t = paper_copy.parsepencode(t) // Encode everything from pencode to html

							if(paper_copy.fields > 50)//large amount of fields creates a heavy load on the server, see updateinfolinks() and addtofield()
								to_chat(sender, SPAN_WARNING("Too many fields. Sorry, you can't do this."))
								paper_copy.fields = old_fields_value
								continue

							paper_copy.info = t // set the file to the new text
							paper_copy.updateinfolinks()

							//manualy set freespace
							paper_copy.free_space = MAX_PAPER_MESSAGE_LEN - length(strip_html_properly(t))
							paper_copy.update_icon()

						if("Block")
							paper_copy = null
							QDEL_NULL(rcvdcopy)
							return FALSE
				else if(istype(rcvdcopy, /obj/item/photo))
					var/obj/item/photo/photo_copy = rcvdcopy
					photo_copy.show(ai)

					if(tgui_alert(ai, "Block or allow fax?", "Choose action", list("Block", "Allow")) == "Block")
						photo_copy = null
						QDEL_NULL(rcvdcopy)
						return FALSE
				else // paper bundle
					var/obj/item/paper_bundle/bundle_copy = rcvdcopy
					bundle_copy.show_content(ai)

					if(tgui_alert(ai, "Block or allow fax?", "Choose action", list("Block", "Allow")) == "Block")
						bundle_copy = null
						QDEL_NULL(rcvdcopy)
						return FALSE

	// For legacy menu support.
	GLOB.adminfaxes += rcvdcopy
	os.receive_fax(rcvdcopy, department, sender)
	return TRUE

/// Intended for staff. Uses admin holder to view paper bundles, normal calls for everything else. usr by default.
/proc/show_fax_admin(obj/item/fax, mob/user = usr)
	if (istype(fax, /obj/item/paper))
		var/obj/item/paper/P = fax
		P.show_content(user, TRUE)
	else if (istype(fax, /obj/item/photo))
		var/obj/item/photo/H = fax
		H.show(user)
	else if (istype(fax, /obj/item/paper_bundle))
		//having multiple people turning pages on a paper_bundle can cause issues
		//open a browse window listing the contents instead
		var/data = ""
		var/obj/item/paper_bundle/B = fax

		for (var/page = 1, page <= B.pages.len, page++)
			var/obj/pageobj = B.pages[page]
			data += "<A href='byond://?_src_=holder;AdminFaxViewPage=[page];paper_bundle=\ref[B]'>Page [page] - [pageobj.name]</A><BR>"

		show_browser(user, data, "window=[B.name]")
	else
		to_chat(user, SPAN_WARNING("The faxed item is not viewable. This is probably a bug, and should be reported on the tracker. Fax type: [fax ? fax.type : "null"]"))
