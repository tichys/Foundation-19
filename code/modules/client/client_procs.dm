	////////////
	//SECURITY//
	////////////
#define UPLOAD_LIMIT		10485760	//Restricts client uploads to the server to 10MB //Boosted this thing. What's the worst that can happen?

//#define TOPIC_DEBUGGING 1

	/*
	When somebody clicks a link in game, this Topic is called first.
	It does the stuff in this proc and  then is redirected to the Topic() proc for the src=[0xWhatever]
	(if specified in the link). ie locate(hsrc).Topic()

	Such links can be spoofed.

	Because of this certain things MUST be considered whenever adding a Topic() for something:
		- Can it be fed harmful values which could cause runtimes?
		- Is the Topic call an admin-only thing?
		- If so, does it have checks to see if the person who called it (usr.client) is an admin?
		- Are the processes being called by Topic() particularly laggy?
		- If so, is there any protection against somebody spam-clicking a link?
	If you have any  questions about this stuff feel free to ask. ~Carn
	*/
/client/Topic(href, href_list, hsrc)
	if(!usr || usr != mob)	//stops us calling Topic for somebody else's client. Also helps prevent usr=null
		return
	if(!user_acted(src))
		return

	#if defined(TOPIC_DEBUGGING)
	log_debug("[src]'s Topic: [href] destined for [hsrc].")

	if(href_list["nano_err"]) //nano throwing errors
		log_debug("## NanoUI, Subject [src]: " + html_decode(href_list["nano_err"]))//NANO DEBUG HOOK


	#endif

	// Tgui Topic middleware
	if(tgui_Topic(href_list))
		return

	if(href_list["reload_tguipanel"])
		nuke_chat()

	if(href_list["reload_statbrowser"])
		stat_panel.reinitialize()

	// asset_cache
	if(href_list["asset_cache_confirm_arrival"])
//		to_chat(src, "ASSET JOB [href_list["asset_cache_confirm_arrival"]] ARRIVED.")
		var/job = text2num(href_list["asset_cache_confirm_arrival"])
		completed_asset_jobs += job
		return

	//search the href for script injection
	if( findtext(href,"<script",1,0) )
		to_world_log("Attempted use of scripts within a topic call, by [src]")
		message_staff("Attempted use of scripts within a topic call, by [src]")
		//qdel(usr)
		return

	//Admin PM
	if(href_list["priv_msg"])
		var/client/C = locate(href_list["priv_msg"])
		var/datum/ticket/ticket = locate(href_list["ticket"])

		if(ismob(C)) 		//Old stuff can feed-in mobs instead of clients
			var/mob/M = C
			C = M.client
		cmd_admin_pm(C, null, ticket)
		return

	//Mentor PM
	if(href_list["mentorreply"])
		mentorpm(href_list["mentorreply"])

	if(href_list["irc_msg"])
		if(!holder && received_irc_pm < world.time - 6000) //Worse they can do is spam IRC for 10 minutes
			to_chat(usr, SPAN_WARNING("You are no longer able to use this, it's been more then 10 minutes since an admin on IRC has responded to you"))
			return
		if(mute_irc)
			to_chat(usr, "<span class='warning'You cannot use this as your client has been muted from sending messages to the admins on IRC</span>")
			return
		cmd_admin_irc_pm(href_list["irc_msg"])
		return

	if(href_list["close_ticket"])
		var/datum/ticket/ticket = locate(href_list["close_ticket"])

		if(isnull(ticket))
			return

		ticket.close(client_repository.get_lite_client(usr.client))

	if (GLOB.href_logfile)
		to_file(GLOB.href_logfile, "<small>[time2text(world.timeofday,"hh:mm")] [src] (usr:[usr])</small> || [hsrc ? "[hsrc] " : ""][href]<br>")

	switch(href_list["_src_"])
		if("holder")
			hsrc = holder
		if("usr")
			hsrc = mob
		if("prefs")
			return prefs.process_link(usr,href_list)
		if("vars")
			return view_var_Topic(href,href_list,hsrc)

	switch(href_list["action"])
		if("openLink")
			send_link(src, href_list["link"])

	if(codex_topic(href, href_list))
		return

	if(href_list["SDQL_select"])
		debug_variables(locate(href_list["SDQL_select"]))
		return

	//byond bug ID:2694120
	if(href_list["reset_macros"])
		reset_macros(skip_alert = TRUE)
		return

	..()	//redirect to hsrc.Topic()

//This stops files larger than UPLOAD_LIMIT being sent from client to server via input(), client.Import() etc.
/client/AllowUpload(filename, filelength)
	if(!user_acted(src))
		return 0
	if(filelength > UPLOAD_LIMIT)
		to_chat(src, FONT_COLORED("red","Error: AllowUpload(): File Upload too large. Upload Limit: [UPLOAD_LIMIT/1024]KiB."))
		return 0
	return 1


	///////////
	//CONNECT//
	///////////
/client/New(TopicData)
	TopicData = null							//Prevent calls to client.Topic from connect

	// Instantiate stat panel
	stat_panel = new(src, "statbrowser")
	stat_panel.subscribe(src, PROC_REF(on_stat_panel_message))

	// Instantiate tgui panel
	tgui_panel = new(src, "browseroutput")

	switch (connection)
		if ("seeker", "web") // check for invalid connection type. do nothing if valid
		else return null
	var/bad_version = config.minimum_byond_version && byond_version < config.minimum_byond_version
	var/bad_build = config.minimum_byond_build && byond_build < config.minimum_byond_build
	if (bad_build || bad_version)
		to_chat(src, "You are attempting to connect with a out of date version of BYOND. Please update to the latest version at http://www.byond.com/ before trying again.")
		qdel(src)
		return

	if("[byond_version].[byond_build]" in config.forbidden_versions)
		_DB_staffwarn_record(ckey, "Tried to connect with broken and possibly exploitable BYOND build.")
		to_chat(src, "You are attempting to connect with a broken and possibly exploitable BYOND build. Please update to the latest version at http://www.byond.com/ before trying again.")
		qdel(src)
		return

	if(!config.guests_allowed && IsGuestKey(key))
		alert(src,"This server doesn't allow guest accounts to play. Please go to http://www.byond.com/ and register for a key.","Guest","OK")
		qdel(src)
		return

	if(config.player_limit != 0)
		if((GLOB.clients.len >= config.player_limit) && !(ckey in GLOB.admin_datums))
			alert(src,"This server is currently full and not accepting new connections.","Server Full","OK")
			log_admin("[ckey] tried to join and was turned away due to the server being full (player_limit=[config.player_limit])")
			qdel(src)
			return

	SSbccm.CollectClientData(src)
	SSbccm.HandleClientAccessCheck(src)
	SSbccm.HandleASNbanCheck(src)

	if(config.panic_bunker && (get_player_age(ckey) < config.panic_bunker_age && !(ckey in GLOB.admin_datums)))
		if(GLOB.panicbunker_bypass.Find(ckey))
			message_staff("[ckey], a new player, was allowed to bypass the Panic Bunker.")
			log_admin("[ckey], a new player, was allowed to bypass the Panic Bunker.")
		else
			message_staff("[ckey] cid:[computer_id] ip:[address] tried to join with [get_player_age(ckey)] days, but there is a configured minimum player age of [config.panic_bunker_age] days.")
			log_admin("[ckey] cid:[computer_id] ip:[address] tried to join with [get_player_age(ckey)] days, but there is a configured minimum player age of [config.panic_bunker_age] days.")
			to_chat("[config.panic_bunker_message]")
			qdel(src)
			return

	// Change the way they should download resources.
	if(config.resource_urls && config.resource_urls.len)
		src.preload_rsc = pick(config.resource_urls)
	else src.preload_rsc = 1 // If config.resource_urls is not set, preload like normal.

	if(byond_version < DM_VERSION)
		to_chat(src, SPAN_WARNING("You are running an older version of BYOND than the server and may experience issues."))
		to_chat(src, SPAN_WARNING("It is recommended that you update to at least [DM_VERSION] at http://www.byond.com/download/."))
	to_chat(src, SPAN_WARNING("If the title screen is black, resources are still downloading. Please be patient until the title screen appears."))
	GLOB.clients += src
	GLOB.ckey_directory[ckey] = src

	//Admin Authorisation
	holder = GLOB.admin_datums[ckey]
	if(holder)
		GLOB.admins += src
		holder.owner = src

	//preferences datum - also holds some persistant data for the client (because we may as well keep these datums to a minimum)
	prefs = SScharacter_setup.preferences_datums[ckey]
	if(!prefs)
		RegisterSignal(src, COMSIG_CLIENT_PREFS_LOADED, PROC_REF(on_prefs_loaded))
		prefs = new /datum/preferences(src)
	else
		on_prefs_loaded(src, prefs)
	prefs.macros.owner = src
	prefs.last_ip = address				//these are gonna be used for banning
	prefs.last_id = computer_id			//these are gonna be used for banning

	. = ..()	//calls mob.Login()

	GLOB.using_map.map_info(src)

	if (config.event)
		to_chat(src, "<h1 class='alert'>Event</h1>")
		to_chat(src, "<h2 class='alert'>An event is taking place. OOC Info:</h2>")
		to_chat(src, SPAN_ALERT("[config.event]"))
		to_chat(src, "<br>")

	if(holder)
		add_admin_verbs()
		admin_memo_show()

	// Forcibly enable hardware-accelerated graphics, as we need them for the lighting overlays.
	// (but turn them off first, since sometimes BYOND doesn't turn them on properly otherwise)
	spawn(5) // And wait a half-second, since it sounds like you can do this too fast.
		if(src)
			winset(src, null, "command=\".configure graphics-hwmode off\"")
			sleep(2) // wait a bit more, possibly fixes hardware mode not re-activating right
			winset(src, null, "command=\".configure graphics-hwmode on\"")

	log_client_to_db()

	var/datum/asset/simple/asset = get_asset_datum(/datum/asset/simple/on_join)
	asset.send(src)

	connection_time = world.time
	connection_realtime = world.realtime
	connection_timeofday = world.timeofday

	apply_clickcatcher()

	if (SSmisc.changelog_hash && prefs.lastchangelog != SSmisc.changelog_hash) //bolds the changelog button on the interface so we know there are updates.
		to_chat(src, SPAN_INFO("You have unread updates in the changelog."))
		winset(src, "infowindow.changelog", "background-color=#eaeaea;font-style=bold")
		if(config.aggressive_changelog)
			src.changelog()

	if(!winexists(src, "asset_cache_browser")) // The client is using a custom skin, tell them.
		to_chat(src, SPAN_WARNING("Unable to access asset cache browser, if you are using a custom skin file, please allow DS to download the updated version, if you are not, then make a bug report. This is not a critical issue but can cause issues with resource downloading, as it is impossible to know when extra resources arrived to you."))

	if(holder)
		src.control_freak = 0 //Devs need 0 for profiler access

	// Initialize stat panel
	stat_panel.initialize(
		inline_html = file("html/statbrowser.html"),
		inline_js = file("html/statbrowser.js"),
		inline_css = file("html/statbrowser.css"),
	)
	addtimer(CALLBACK(src, PROC_REF(check_panel_loaded)), 30 SECONDS)

	// Initialize tgui panel
	tgui_panel.initialize()

	if(SSinput.initialized)
		set_macros()

	/// Initializes jobtime datum
	jobtime = new /datum/jobtime(src)

//////////////
//DISCONNECT//
//////////////
/client/Del()
	ticket_panels -= src
	if(src && watched_variables_window)
		STOP_PROCESSING(SSprocessing, watched_variables_window)
	if(holder)
		holder.owner = null
		GLOB.admins -= src
	GLOB.ckey_directory -= ckey
	GLOB.clients -= src
	return ..()

/client/Destroy()
	..()
	return QDEL_HINT_HARDDEL_NOW

/**
 * Handles incoming messages from the stat-panel TGUI.
 */
/client/proc/on_stat_panel_message(type, payload)
	switch(type)
		if("Update-Verbs")
			init_verbs()
		if("Remove-Tabs")
			panel_tabs -= payload["tab"]
		if("Send-Tabs")
			panel_tabs |= payload["tab"]
		if("Reset-Tabs")
			panel_tabs = list()
		if("Set-Tab")
			stat_tab = payload["tab"]
			SSstatpanels.immediate_send_stat_data(src)

/// compiles a full list of verbs and sends it to the browser
/client/proc/init_verbs()
	var/list/verblist = list()
	var/list/verbstoprocess = verbs.Copy()
	if(mob)
		verbstoprocess += mob.verbs
		for(var/atom/movable/thing as anything in mob.contents)
			verbstoprocess += thing.verbs
	panel_tabs.Cut() // panel_tabs get reset in init_verbs on JS side anyway
	for(var/procpath/verb_to_init as anything in verbstoprocess)
		if(!verb_to_init)
			continue
		if(verb_to_init.hidden)
			continue
		if(!istext(verb_to_init.category))
			continue
		panel_tabs |= verb_to_init.category
		verblist[++verblist.len] = list(verb_to_init.category, verb_to_init.name)
	src.stat_panel.send_message("init_verbs", list(panel_tabs = panel_tabs, verblist = verblist))

/client/proc/check_panel_loaded()
	if(stat_panel.is_ready())
		return
	to_chat(src, SPAN_USERDANGER("Statpanel failed to load, click <a href='byond://?src=[REF(src)];reload_statbrowser=1'>here</a> to reload the panel "))

/**
 * Initializes dropdown menus on client
 */
/client/proc/initialize_menus()
	var/list/topmenus = GLOB.menulist[/datum/verbs/menu]
	for (var/thing in topmenus)
		var/datum/verbs/menu/topmenu = thing
		var/topmenuname = "[topmenu]"
		if (topmenuname == "[topmenu.type]")
			var/list/tree = splittext(topmenuname, "/")
			topmenuname = tree[tree.len]
		winset(src, "[topmenu.type]", "parent=menu;name=[url_encode(topmenuname)]")
		var/list/entries = topmenu.Generate_list(src)
		for (var/child in entries)
			winset(src, "[child]", "[entries[child]]")
			if (!ispath(child, /datum/verbs/menu))
				var/procpath/verbpath = child
				if (verbpath.name[1] != "@")
					new child(src)

// Returns null if no DB connection can be established, or -1 if the requested key was not found in the database
/proc/get_player_age(key)
	if(!SSdbcore.Connect())
		return null

	var/sql_ckey = sql_sanitize_text(ckey(key))

	var/datum/db_query/query = SSdbcore.NewQuery("SELECT datediff(Now(),firstseen) as age FROM erro_player WHERE ckey = '[sql_ckey]'")
	query.Execute()

	if(query.NextRow())
		var/result = text2num(query.item[1])
		qdel(query)
		return result
	else
		qdel(query)
		return -1


/client/proc/log_client_to_db()

	if ( IsGuestKey(src.key) )
		return

	if(!SSdbcore.Connect())
		return

	var/sql_ckey = sql_sanitize_text(src.ckey)

	var/datum/db_query/query = SSdbcore.NewQuery("SELECT id, datediff(Now(),firstseen) as age FROM erro_player WHERE ckey = '[sql_ckey]'")
	query.Execute()
	var/sql_id = 0
	player_age = 0	// New players won't have an entry so knowing we have a connection we set this to zero to be updated if their is a record.
	while(query.NextRow())
		sql_id = query.item[1]
		player_age = text2num(query.item[2])
		break
	qdel(query)

	var/datum/db_query/query_ip = SSdbcore.NewQuery("SELECT ckey FROM erro_player WHERE ip = '[address]'")
	query_ip.Execute()
	related_accounts_ip = ""
	while(query_ip.NextRow())
		related_accounts_ip += "[query_ip.item[1]], "
		break
	qdel(query_ip)

	var/datum/db_query/query_cid = SSdbcore.NewQuery("SELECT ckey FROM erro_player WHERE computerid = '[computer_id]'")
	query_cid.Execute()
	related_accounts_cid = ""
	while(query_cid.NextRow())
		related_accounts_cid += "[query_cid.item[1]], "
		break
	qdel(query_cid)

	var/datum/db_query/query_staffwarn = SSdbcore.NewQuery("SELECT staffwarn FROM erro_player WHERE ckey = '[sql_ckey]' AND !ISNULL(staffwarn)")
	query_staffwarn.Execute()
	if(query_staffwarn.NextRow())
		src.staffwarn = query_staffwarn.item[1]
	qdel(query_staffwarn)

	//Just the standard check to see if it's actually a number
	if(sql_id)
		if(istext(sql_id))
			sql_id = text2num(sql_id)
		if(!isnum(sql_id))
			return

	var/admin_rank = "Player"
	if(src.holder)
		admin_rank = src.holder.rank
		for(var/client/C in GLOB.clients)
			if(C.staffwarn)
				C.mob.send_staffwarn(src, "is connected", 0)

	var/sql_ip = sql_sanitize_text(src.address)
	var/sql_computerid = sql_sanitize_text(src.computer_id)
	var/sql_admin_rank = sql_sanitize_text(admin_rank)


	if(sql_id)
		//Player already identified previously, we need to just update the 'lastseen', 'ip' and 'computer_id' variables
		var/datum/db_query/query_update = SSdbcore.NewQuery("UPDATE erro_player SET lastseen = Now(), ip = '[sql_ip]', computerid = '[sql_computerid]', lastadminrank = '[sql_admin_rank]' WHERE id = [sql_id]")
		query_update.Execute()
		qdel(query_update)
	else
		//New player!! Need to insert all the stuff
		log_and_message_staff("[ckey]([computer_id] [address]) joined for the first time.")
		var/datum/db_query/query_insert = SSdbcore.NewQuery("INSERT INTO erro_player (id, ckey, firstseen, lastseen, ip, computerid, lastadminrank) VALUES (null, '[sql_ckey]', Now(), Now(), '[sql_ip]', '[sql_computerid]', '[sql_admin_rank]')")
		query_insert.Execute()
		qdel(query_insert)

	//Logging player access
	log_client_to_db_connection_log()

#undef UPLOAD_LIMIT

/client/proc/log_client_to_db_connection_log()
	var/sql_ip = sql_sanitize_text(src.address)
	var/sql_computerid = sql_sanitize_text(src.computer_id)
	var/sql_ckey = sql_sanitize_text(src.ckey)
	var/serverip = "[world.internet_address]:[world.port]"

	var/datum/db_query/query_accesslog = SSdbcore.NewQuery("INSERT INTO `erro_connection_log`(`id`,`datetime`,`serverip`,`ckey`,`ip`,`computerid`) VALUES(null,Now(),'[serverip]','[sql_ckey]','[sql_ip]','[sql_computerid]');")
	query_accesslog.Execute()
	qdel(query_accesslog)


//checks if a client is afk
//3000 frames = 5 minutes
/client/proc/is_afk(duration=3000)
	if(inactivity > duration)	return inactivity
	return 0

/client/proc/get_default_view()
	return getScreenSize(get_preference_value(/datum/client_preference/widescreen) == GLOB.PREF_YES)

/client/proc/has_default_view()
	var/default_view = getviewsize(get_default_view())
	var/current_view = getviewsize(view)
	return (current_view[1] == default_view[1]) && (current_view[2] == default_view[2])

/client/proc/change_view(new_size)
	if(isnull(new_size))
		CRASH("change_view called without argument.")

	view = new_size
	apply_clickcatcher()
	update_skybox(TRUE)
	if(mob)
		mob.update_cone_size()
		mob.reload_fullscreen()
		mob.update_lighting_size()

/client/proc/generate_clickcatcher()
	if(!void)
		void = new()
	if(!(void in screen))
		screen += void

/client/proc/apply_clickcatcher()
	generate_clickcatcher()
	var/list/actualview = getviewsize(view)
	void.UpdateGreed(actualview[1], actualview[2])

/client/proc/inactivity2text()
	var/seconds = inactivity/10
	return "[round(seconds / 60)] minute\s, [seconds % 60] second\s"

/mob/proc/MayRespawn()
	return 0

/client/proc/MayRespawn()
	if(mob)
		return mob.MayRespawn()

	// Something went wrong, client is usually kicked or transfered to a new mob at this point
	return 0

/client/verb/character_setup()
	set name = "Character Setup"
	set category = "Preferences"
	prefs?.open_setup_window(usr)

/client/proc/apply_fps(client_fps)
	if(client_fps >= CLIENT_MIN_FPS && client_fps <= CLIENT_MAX_FPS)
		vars["fps"] = client_fps

/client/proc/on_prefs_loaded(client/target, datum/preferences/prefs)
	SIGNAL_HANDLER
	apply_fps(prefs.clientfps)
	change_view(get_default_view())

/client/MouseDrag(src_object, over_object, src_location, over_location, src_control, over_control, params)
	. = ..()
	var/mob/living/M = mob
	if(istype(M))
		M.OnMouseDrag(src_object, over_object, src_location, over_location, src_control, over_control, params)

	var/datum/click_handler/build_mode/B = M.GetClickHandler()
	if (istype(B))
		if(B.current_build_mode && src_control == "mapwindow.map" && src_control == over_control)
			build_drag(src,B.current_build_mode,src_object,over_object,src_location,over_location,src_control,over_control,params)

/client/MouseUp(object, location, control, params)
	. = ..()
	var/mob/living/M = mob
	if(istype(M))
		M.OnMouseUp(object, location, control, params)

/client/MouseDown(object, location, control, params)
	. = ..()
	var/mob/living/M = mob
	if(istype(M) && !M.in_throw_mode)
		M.OnMouseDown(object, location, control, params)

/client/verb/fit_viewport()
	set name = "Fit Viewport"
	set category = "OOC"
	set desc = "Fit the width of the map window to match the viewport"

	// Fetch aspect ratio
	var/view_size = getviewsize(view)
	var/aspect_ratio = view_size[1] / view_size[2]

	// Calculate desired pixel width using window size and aspect ratio
	var/list/sizes = params2list(winget(src, "mainwindow.split;mapwindow", "size"))

	// Client closed the window? Some other error? This is unexpected behaviour, let's
	// CRASH with some info.
	if(!sizes["mapwindow.size"])
		CRASH("sizes does not contain mapwindow.size key. This means a winget failed to return what we wanted. --- sizes var: [sizes] --- sizes length: [length(sizes)]")

	var/list/map_size = splittext(sizes["mapwindow.size"], "x")

	var/desired_width = 0

	// Looks like we expect mapwindow.size to be "ixj" where i and j are numbers.
	// If we don't get our expected 2 outputs, let's give some useful error info.
	if(length(map_size) != 2)
		CRASH("map_size of incorrect length --- map_size var: [map_size] --- map_size length: [length(map_size)]")
	var/height = text2num(map_size[2])
	desired_width = round(height * aspect_ratio)

	if (text2num(map_size[1]) == desired_width)
		// Nothing to do
		return

	var/split_size = splittext(sizes["mainwindow.split.size"], "x")
	var/split_width = text2num(split_size[1])

	// Avoid auto-resizing the statpanel and chat into nothing.
	desired_width = min(desired_width, split_width - 300)

	// Calculate and apply a best estimate
	// +4 pixels are for the width of the splitter's handle
	var/pct = 100 * (desired_width + 4) / split_width
	winset(src, "mainwindow.split", "splitter=[pct]")

	// Apply an ever-lowering offset until we finish or fail
	var/delta
	for(var/safety in 1 to 10)
		var/after_size = winget(src, "mapwindow", "size")
		map_size = splittext(after_size, "x")
		var/got_width = text2num(map_size[1])

		if (got_width == desired_width)
			// success
			return
		else if (isnull(delta))
			// calculate a probable delta value based on the difference
			delta = 100 * (desired_width - got_width) / split_width
		else if ((delta > 0 && got_width > desired_width) || (delta < 0 && got_width < desired_width))
			// if we overshot, halve the delta and reverse direction
			delta = -delta/2

		pct += delta
		winset(src, "mainwindow.split", "splitter=[pct]")

/client/verb/show_lore()
	set name = "Show Lore"
	set category = "OOC"
	set desc = "Show the lore page of server"
	src.lore()

/client/Click(atom/A)
	if(!user_acted(src))
		return

	if(holder && holder.callproc && holder.callproc.waiting_for_click)
		if(alert("Do you want to select \the [A] as the [holder.callproc.arguments.len+1]\th argument?",, "Yes", "No") == "Yes")
			holder.callproc.arguments += A

		holder.callproc.waiting_for_click = 0
		remove_verb(src, /client/proc/cancel_callproc_select)
		holder.callproc.do_args()
		return

	if (prefs.hotkeys)
		// If hotkey mode is enabled, then clicking the map will automatically
		// unfocus the text bar. This removes the red color from the text bar
		// so that the visual focus indicator matches reality.
		winset(src, null, "outputwindow.input.focus=false")
	else
		winset(src, null, "outputwindow.input.focus=true")

	return ..()

/**
 * Updates the keybinds for special keys
 *
 * Handles adding macros for the keys that need it
 * And adding movement keys to the clients movement_keys list
 * At the time of writing this, communication(OOC, Say, IC) require macros
 * Arguments:
 * * direct_prefs - the preference we're going to get keybinds from
 */
/client/proc/update_special_keybinds(datum/preferences/direct_prefs)
	var/datum/preferences/D = prefs || direct_prefs
	if(!D?.key_bindings)
		return
	movement_keys = list()
	var/list/communication_hotkeys = list()
	for(var/key in D.key_bindings)
		for(var/kb_name in D.key_bindings[key])
			switch(kb_name)
				if("North")
					movement_keys[key] = NORTH
				if("East")
					movement_keys[key] = EAST
				if("West")
					movement_keys[key] = WEST
				if("South")
					movement_keys[key] = SOUTH
				if("Say")
					winset(src, "default-\ref[key]", "parent=default;name=[key];command=.say")
					communication_hotkeys += key
				if("OOC")
					winset(src, "default-\ref[key]", "parent=default;name=[key];command=ooc")
					communication_hotkeys += key
				if("LOOC")
					winset(src, "default-\ref[key]", "parent=default;name=[key];command=looc")
					communication_hotkeys += key
				if("Me")
					winset(src, "default-\ref[key]", "parent=default;name=[key];command=.me")
					communication_hotkeys += key
		calculate_move_dir()
	// winget() does not work for F1 and F2
	for(var/key in communication_hotkeys)
		if(!(key in list("F1","F2")) && !winget(src, "default-\ref[key]", "command"))
			to_chat(src, "You probably entered the game with a different keyboard layout.\n<a href='byond://?src=\ref[src];reset_macros=1'>Please switch to the English layout and click here to fix the communication hotkeys.</a>")
			break

/client/verb/toggle_fullscreen()
	set name = "Toggle Fullscreen"
	set category = "OOC"

	fullscreen = !fullscreen

	if (fullscreen)
		winset(usr, "mainwindow", "titlebar=false")
		winset(usr, "mainwindow", "can-resize=false")
		winset(usr, "mainwindow", "is-maximized=false")
		winset(usr, "mainwindow", "is-maximized=true")
		winset(usr, "mainwindow", "statusbar=false")
		winset(usr, "mainwindow", "menu=")
	else
		winset(usr, "mainwindow", "is-maximized=false")
		winset(usr, "mainwindow", "titlebar=true")
		winset(usr, "mainwindow", "can-resize=true")
		winset(usr, "mainwindow", "statusbar=true")
		winset(usr, "mainwindow", "menu=menu")

	fit_viewport()

/client/verb/toggle_status_bar()
	set name = "Toggle Status Bar"
	set category = "OOC"

	show_status_bar = !show_status_bar

	if (show_status_bar)
		winset(usr, "mapwindow.status_bar", "is-visible=true")
	else
		winset(usr, "mapwindow.status_bar", "is-visible=false")

// Creates the character out of client's preferences
/client/proc/SpawnPrefsCharacter(turf/T)
	var/mob/living/carbon/human/new_character = new(T)
	new_character.lastarea = get_area(T)
	prefs.copy_to(new_character)
	new_character.dna.ready_dna(new_character)
	new_character.dna.b_type = prefs.b_type
	new_character.sync_organ_dna()
	if(prefs.char_nearsighted)
		new_character.become_nearsighted(ROUNDSTART_TRAIT)
	new_character.force_update_limbs()
	new_character.update_eyes()
	new_character.regenerate_icons()
	new_character.ckey = ckey
	return new_character
