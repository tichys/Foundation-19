/client/proc/list_players()//The new one
	set name = "Show Player Panel"
	set desc = "List Players"
	set category = "Admin"

	if(!usr.client.holder || !(check_rights(R_ADMIN|R_MOD, FALSE)))
		return
	holder?.player_panel_new()

/datum/admins/proc/player_panel_new()//The new one
	if(!usr.client.holder || !(check_rights(R_ADMIN|R_MOD, FALSE)))
		return
	var/dat = "<html>"

	//javascript, the part that does most of the work~
	dat += {"
		<head>
			<script type='text/javascript'>

				var locked_tabs = new Array();

				function updateSearch() {
					var filter_text = document.getElementById('filter');
					var filter = filter_text.value.toLowerCase();

					if (complete_list != null && complete_list != "") {
						var mtbl = document.getElementById("maintable_data_archive");
						mtbl.innerHTML = complete_list;
					}

					if (filter.value == "") {
						return;
					} else {
						var maintable_data = document.getElementById('maintable_data');
						var ltr = maintable_data.getElementsByTagName("tr");
						for (var i = 0; i < ltr.length; ++i) {
							try {
								var tr = ltr\[i\];
								if (tr.getAttribute("id").indexOf("data") != 0) {
									continue;
								}
								tr.style.display = '';
								var ltd = tr.getElementsByTagName("td");
								var td = ltd\[0\];
								var lsearch = td.getElementsByTagName("b");
								var search = lsearch\[0\];
								if (search.innerText.toLowerCase().indexOf(filter) == -1) {
									tr.style.display = 'none';
								}
							} catch(err) {}
						}
					}

					var count = 0;
					var index = -1;
					var debug = document.getElementById("debug");

					locked_tabs = new Array();
				}

				function expand(id,job,name,real_name,image,key,ip,antagonist,ref) {
					clearAll();

					var span = document.getElementById(id);

					body = "<table><tr><td>";
					body += "</td><td align='center'>";
					body += "<font size='2'><b>"+job+" "+name+"</b><br><b>Real name "+real_name+"</b><br><b>Played by "+key+" ("+ip+")</b></font>"
					body += "</td><td align='center'>";

					body += "<a href='byond://?src=\ref[src];adminplayeropts="+ref+"'>PP</a> - "
					body += "<a href='byond://?src=\ref[src];playerpanelextended="+ref+"'>PPE</a> - "
					body += "<a href='byond://?src=\ref[src];notes=show;mob="+ref+"'>N</a> - "
					body += "<a href='byond://?_src_=vars;Vars="+ref+"'>VV</a> - "
					body += "<a href='byond://?src=\ref[src];traitor="+ref+"'>TP</a> - "
					body += "<a href='byond://?src=\ref[usr];priv_msg="+ref+"'>PM</a> - "
					body += "<a href='byond://?src=\ref[src];subtlemessage="+ref+"'>SM</a> - "
					body += "<a href='byond://?src=\ref[src];adminplayerobservejump="+ref+"'>JMP</a><br>"
					if(antagonist > 0)
						body += "<font size='2'><a href='byond://?src=\ref[src];check_antagonist=1'><font color='red'><b>Antagonist</b></font></a></font>";
					body += "</td></tr></table>";

					span.innerHTML = body
				}

				function clearAll() {
					var spans = document.getElementsByTagName('span');
					for (var i = 0; i < spans.length; i++) {
						var span = spans\[i\];

						var id = span.getAttribute("id");

						if(id.indexOf("item") != 0)
							continue;

						var pass = 1;

						for (var j = 0; j < locked_tabs.length; j++) {
							if (locked_tabs\[j\]==id) {
								pass = 0;
								break;
							}
						}

						if (pass != 1)
							continue;

						span.innerHTML = "";
					}
				}

				function addToLocked(id,link_id,notice_span_id) {
					var link = document.getElementById(link_id);
					var decision = link.getAttribute("name");
					if (decision == "1") {
						link.setAttribute("name","2");
					} else {
						link.setAttribute("name","1");
						removeFromLocked(id,link_id,notice_span_id);
						return;
					}

					var pass = 1;
					for (var j = 0; j < locked_tabs.length; j++) {
						if (locked_tabs\[j\]==id) {
							pass = 0;
							break;
						}
					}
					if (!pass)
						return;
					locked_tabs.push(id);
					var notice_span = document.getElementById(notice_span_id);
					notice_span.innerHTML = "<font color='red'>Locked</font> ";
				}

				function attempt(ab) {
					return ab;
				}

				function removeFromLocked(id,link_id,notice_span_id) {
					var index = 0;
					var pass = 0;
					for (var j = 0; j < locked_tabs.length; j++) {
						if (locked_tabs\[j\]==id) {
							pass = 1;
							index = j;
							break;
						}
					}
					if (!pass)
						return;
					locked_tabs\[index\] = "";
					var notice_span = document.getElementById(notice_span_id);
					notice_span.innerHTML = "";
				}

				function selectTextField() {
					var filter_text = document.getElementById('filter');
					filter_text.focus();
					filter_text.select();
				}
			</script>
		</head>


	"}

	//body tag start + onload and onkeypress (onkeyup) javascript event calls
	dat += "<body onload='selectTextField(); updateSearch();'>"

	//title + search bar
	dat += {"
		<table width='560' align='center' cellspacing='0' cellpadding='5' id='maintable'>
			<tr id='title_tr'>
				<td align='center'>
					<font size='5'><b>Player panel</b></font><br>
					Hover over a line to see more information - <a href='byond://?src=\ref[src];check_antagonist=1'>Check antagonists</a>
					<p>
				</td>
			</tr>
			<tr id='search_tr'>
				<td align='center'>
					<b>Search:</b> <input type='text' id='filter' value='' onkeyup='updateSearch();' style='width:300px;'>
				</td>
			</tr>
		</table>
	"}

	//player table header
	dat += {"
		<span id='maintable_data_archive'>
		<table width='600' align='center' cellspacing='0' cellpadding='5' id='maintable_data'>"}

	var/list/mobs = sortmobs()
	var/i = 1
	for(var/mob/living/carbon/human/M as anything in mobs)
		if(!M.ckey)
			continue

		var/color = i % 2 == 0 ? "#e6e6e6" : "#f2f2f2"

		var/is_antagonist = is_special_character(M)

		var/M_job = ""

		if(isliving(M))
			if(iscarbon(M)) //Carbon stuff
				if(ishuman(M))
					M_job = M.job
				else
					M_job = "Carbon-based"
			else if(issilicon(M)) //silicon
				if(isAI(M))
					M_job = "AI"
				else if(isrobot(M))
					M_job = "Cyborg"
				else
					M_job = "Silicon-based"
			else if(isanimal(M)) //simple animals
				if(iscorgi(M))
					M_job = "Corgi"
				else
					M_job = "Animal"
			else
				M_job = "Living"
		else if(istype(M,/mob/new_player))
			M_job = "New player"
		else if(isobserver(M))
			M_job = "Ghost"

		M_job = replacetext(M_job, "'", "")
		M_job = replacetext(M_job, "\"", "")
		M_job = replacetext(M_job, "\\", "")

		var/M_name = M.name
		M_name = replacetext(M_name, "'", "")
		M_name = replacetext(M_name, "\"", "")
		M_name = replacetext(M_name, "\\", "")
		var/M_rname = M.real_name
		M_rname = replacetext(M_rname, "'", "")
		M_rname = replacetext(M_rname, "\"", "")
		M_rname = replacetext(M_rname, "\\", "")

		var/M_key = M.key
		M_key = replacetext(M_key, "'", "")
		M_key = replacetext(M_key, "\"", "")
		M_key = replacetext(M_key, "\\", "")

		//output for each mob
		dat += {"
			<tr id='data[i]' name='[i]' onClick="addToLocked('item[i]','data[i]','notice_span[i]')">
				<td align='center' bgcolor='[color]'>
					<span id='notice_span[i]'></span>
					<a id='link[i]'
					onmouseover='expand("item[i]","[M_job]","[M_name]","[M_rname]","--unused--","[M_key]","[M.lastKnownIP]","[is_antagonist]","\ref[M]")'
					>
					<b><span  id='search[i]'>[M_name] - [M_rname] - [M_key] ([M_job])</span></b>
					</a>
					<br><span id='item[i]'></span>
				</td>
			</tr>
		"}

		i++


	//player table ending
	dat += {"
		</table>
		</span>

		<script type='text/javascript'>
			var maintable = document.getElementById("maintable_data_archive");
			var complete_list = maintable.innerHTML;
		</script>
	</body></html>
	"}

	show_browser(usr, dat, "window=players;size=600x480")

//Extended panel with ban related things
/datum/admins/proc/player_panel_extended()
	if (!usr.client.holder || !(usr.client.holder.rights & R_ADMIN|R_MOD))
		return

	var/dat = "<html>"
	dat += "<body><table border=1 cellspacing=5><B><tr><th>Key</th><th>Name</th><th>Real Name</th><th>PP</th><th>CID</th><th>IP</th><th>JMP</th><th>Notes</th></tr></B>"
	//add <th>IP:</th> to this if wanting to add back in IP checking
	//add <td>(IP: [M.lastKnownIP])</td> if you want to know their ip to the lists below
	var/list/mobs = sortmobs()

	for(var/mob/M in mobs)
		if(!M.ckey) continue

		dat += "<tr><td>[M.client ? "[M.client]" : "No client"]</td>"
		dat += "<td>[M.name] [ADMIN_PM(M)]]</td>"
		if(isAI(M))
			dat += "<td>AI</td>"
		else if(isrobot(M))
			dat += "<td>Cyborg</td>"
		else if(ishuman(M))
			dat += "<td>[M.real_name]</td>"
		else if(istype(M, /mob/new_player))
			dat += "<td>New Player</td>"
		else if(isobserver(M))
			dat += "<td>Ghost</td>"
		else
			dat += "<td>Unknown</td>"


		dat += {"<td align=center>[ADMIN_PP(M)]</td>
		<td>[M.computer_id]</td>
		<td>[M.lastKnownIP]</td>
		<td><a href='byond://?src=\ref[src];adminplayerobservejump=\ref[M]'>JMP</a></td>
		<td><a href='byond://?src=\ref[src];notes=show;mob=\ref[M]'>Notes</a></td>
		"}


	dat += "</table></body></html>"

	show_browser(usr, dat, "window=players;size=600x480")

/datum/admins/proc/check_antagonists()
	if(GAME_STATE < RUNLEVEL_GAME)
		tgui_alert("The game hasn't started yet!")
		return

	var/dat = list()
	dat += "<html><head><title>Round Status</title></head><body><h1><B>Round Status</B></h1>"
	dat += "Current Game Mode: <B>[SSticker.mode.name]</B><BR>"
	dat += "Round Duration: <B>[DisplayTimeText(world.time - SSticker.round_start_time)]</B><BR>"
	dat += "<B>Evacuation</B><BR>"
	if (evacuation_controller.is_idle())
		dat += "<a href='byond://?src=\ref[src];call_shuttle=1'>Call Evacuation</a><br>"
	else
		var/timeleft = evacuation_controller.get_eta()
		if (evacuation_controller.waiting_to_leave())
			dat += "ETA: [(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]<BR>"
			dat += "<a href='byond://?src=\ref[src];call_shuttle=2'>Send Back</a><br>"

	dat += "<a href='byond://?src=\ref[src];delay_round_end=1'>[SSticker.delay_end ? "End Round Normally" : "Delay Round End"]</a><br>"
	dat += "<hr>"
	var/list/all_antag_types = GLOB.all_antag_types_
	for(var/antag_type in all_antag_types)
		var/datum/antagonist/A = all_antag_types[antag_type]
		dat += A.get_check_antag_output(src)
	dat += "</body></html>"
	show_browser(usr, jointext(dat,null), "window=roundstatus;size=400x500")

/datum/admins/proc/check_round_status()
	if(GAME_STATE >= RUNLEVEL_GAME)
		var/dat = "<html><body><h1><B>Round Status</B></h1>"
		dat += "Current Game Mode: <B>[SSticker.mode.name]</B><BR>"
		dat += "Round Duration: <B>[round(world.time / 36000)]:[add_zero(world.time / 600 % 60, 2)]:[world.time / 100 % 6][world.time / 100 % 10]</B><BR>"

		if(check_rights(R_DEBUG, 0))
			dat += "<br>[ADMIN_VV(evacuation_controller)]<br>"

		if(check_rights(R_ADMIN|R_MOD, 0))
			dat += "<b>Evacuation:</b> "
			switch(evacuation_controller.state)
				if(EVAC_IDLE)
					dat += "STANDING BY"
				if(EVAC_PREPPING)
					dat += "PREPARING"
				if(EVAC_LAUNCHING)
					dat += "LAUNCHING"
				if(EVAC_IN_TRANSIT)
					dat += "IN TRANSITION"
				if(EVAC_COOLDOWN)
					dat += "ON COOLDOWN"
				if(EVAC_COMPLETE)
					dat += "COMPLETE"
			dat += "<br>"

			dat += "<a href='byond://?src=\ref[src];evac_authority=init_evac'>Initiate Evacuation</a><br>"
			dat += "<a href='byond://?src=\ref[src];evac_authority=cancel_evac'>Cancel Evacuation</a><br>"
			dat += "<a href='byond://?src=\ref[src];evac_authority=toggle_evac'>Toggle Evacuation Permission (does not affect evac in progress)</a><br>"
			if(check_rights(R_ADMIN, 0)) dat += "<a href='byond://?src=\ref[src];evac_authority=force_evac'>Force Evacuation Now</a><br>"

		dat += "<br><a href='byond://?src=\ref[src];delay_round_end=1'>[SSticker.delay_end ? "End Round Normally" : "Delay Round End"]</a><br>"
		dat += "</body></html>"
		show_browser(usr, dat, "window=roundstatus;size=600x500")
	else
		alert("The game hasn't started yet!")

/proc/check_role_table(name, list/members, admins, show_objectives=1)
	var/txt = "<br><table cellspacing=5><tr><td><b>[name]</b></td><td></td></tr>"
	for(var/datum/mind/M in members)
		txt += check_role_table_row(M.current, admins, show_objectives)
	txt += "</table>"
	return txt

/proc/check_role_table_row(mob/M, admins=src, show_objectives)
	if (!istype(M))
		return "<tr><td><i>Not found!</i></td></tr>"

	var/txt = {"
		<tr>
			<td>
				[ADMIN_PP(M)]
				[M.real_name]
				[M.client ? "" : " <i>(logged out)</i>"]
				[M.is_dead() ? " <b><font color='red'>(DEAD)</font></b>" : ""]
			</td>
			<td>
				[ADMIN_PM(M)]
			</td>
	"}

	if (show_objectives)
		txt += {"
			<td>
				[ADMIN_TP(M)]
			</td>
		"}

	txt += "</tr>"
	return txt

/datum/player_panel
	var/mob/targetMob

/datum/player_panel/New(mob/target)
	. = ..()
	targetMob = target


/datum/player_panel/Destroy(force, ...)
	targetMob = null

	SStgui.close_uis(src)
	return ..()


/datum/player_panel/tgui_interact(mob/user, datum/tgui/ui)
	if(!targetMob)
		return

	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "PlayerPanel", "[targetMob.name] Player Panel")
		ui.open()

// Player panel
/datum/player_panel/tgui_data(mob/user)
	. = list()
	.["mob_name"] = targetMob.name

	.["mob_languages"] = list()
	for(var/datum/language/L as anything in targetMob.languages)
		.["mob_languages"] += L.name

	.["mob_sleeping"] = targetMob.sleeping

	.["mob_speed"] = targetMob.move_speed
	.["mob_status_flags"] = targetMob.status_flags

	.["current_permissions"] = user.client?.holder?.rights

	if(isliving(targetMob))
		var/mob/living/psyker = targetMob
		.["can_have_psionics"] = TRUE
		.["has_psy"] = !!psyker.psi
		.["psy"] = list()
		for(var/faculty in GLOB.all_psionics_faculty)
			.["psy"] += list("[faculty]" = psyker.psi ? psyker.psi.get_rank(faculty) : 0)

		if(iscarbon(targetMob))
			if(targetMob.dna)
				//We need to set list len here
				var/list/dna_blocks[DNA_SE_LENGTH]
				.["dna_blocks"] = dna_blocks
				for(var/block = 1 to DNA_SE_LENGTH)
					dna_blocks[block] = targetMob.dna.GetSEState(block)

	.["mob_key"] = targetMob.key
	.["mob_ckey"] = targetMob.ckey

	if(targetMob.client)
		.["has_client"] = TRUE
		.["staff_warn"] = targetMob.client.staffwarn
		.["inactivity_time"] = targetMob.client.inactivity
		.["client_rank"] = targetMob.client.holder ? targetMob.client.holder.rank : "Player"
		.["client_muted"] = targetMob.client.prefs.muted

		targetMob.client.jobtime?.update_jobtime()
		var/list/jt_list = targetMob.client.jobtime.jobtime_list ? targetMob.client.jobtime.jobtime_list : list()
		var/list/jobtime_by_time = list()
		var/list/jobtime_by_name = list()
		for(var/job in jt_list)
			jobtime_by_time += jt_list[job]
			jobtime_by_name += job

		.["playtime_names"] = jobtime_by_name
		.["playtime_times"] = jobtime_by_time

		.["current_job"] = targetMob.mind.assigned_job ? targetMob.mind.assigned_job.title : "N/A"
		.["current_jobtime"] = targetMob.client.jobtime.get_jobtime_by_job(targetMob.mind.assigned_job)

/datum/player_panel/tgui_state(mob/user)
	return GLOB.admin_tgui_state

GLOBAL_LIST_INIT(mute_bits, list(
	list(name = "IC", bitflag = MUTE_IC),
	list(name = "OOC", bitflag = MUTE_OOC),
	list(name = "Pray", bitflag = MUTE_PRAY),
	list(name = "Ahelp", bitflag = MUTE_ADMINHELP),
	list(name = "Dsay", bitflag = MUTE_DEADCHAT),
	list(name = "AOOC", bitflag = MUTE_AOOC),
	list(name = "Mhelp", bitflag = MUTE_MENTOR)
))


GLOBAL_LIST_INIT(narrate_span, list(
	list(name = "Notice", span = "notice"),
	list(name = "Warning", span = "warning"),
	list(name = "Alert", span = "alert"),
	list(name = "Info", span = "info"),
	list(name = "Danger", span = "danger"),
	list(name = "Helpful", span = "helpful")
))

GLOBAL_LIST_INIT(pp_limbs, list(
	"Head" = "head",
	"Left leg" = "l_leg",
	"Right leg" = "r_leg",
	"Left arm" = "l_arm",
	"Right arm" = "r_arm"
))

GLOBAL_LIST_INIT(pp_status_flags, list(
	"Stun" = CANSTUN,
	"Weaken" = CANWEAKEN,
	"Paralyse" = CANPARALYSE,
	"Push" = CANPUSH,
	"Godmode" = GODMODE,
	"Fake Death" = FAKEDEATH,
	"No Antag" = NO_ANTAG,
	"No Target" = NOTARGET,
))

/datum/player_panel/tgui_static_data(mob/user)
	. = list()
	.["mob_type"] = targetMob.type

	.["languages"] = list()
	for(var/datum/language/L as anything in all_languages)
		L = all_languages[L]
		if(!(L.flags & INNATE))
			.["languages"] += L.name

	.["is_human"] = ishuman(targetMob)

	.["glob_dna_blocks"] = assigned_blocks
	.["glob_status_flags"] = GLOB.pp_status_flags
	.["glob_limbs"] = GLOB.pp_limbs
	.["glob_mute_bits"] = GLOB.mute_bits
	.["glob_pp_actions"] = GLOB.pp_actions_data
	.["glob_span"] = GLOB.narrate_span
	.["glob_pp_transformables"] = GLOB.pp_transformables

	.["glob_psionics_faculty"] = GLOB.all_psionics_faculty
	.["glob_psionics_ranks"] = GLOB.psychic_ranks_to_strings

/datum/player_panel/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	. = ..()

	if(.)
		return

	var/datum/player_action/P = GLOB.pp_actions[action]
	if(!P)
		return

	if(!check_rights(P.permissions_required, ui.user.client))
		return

	return P.act(ui.user.client, targetMob, params)

/datum/admins/proc/show_player_panel(mob/M in SSmobs.mob_list)
	set name = "Open Player Panel"
	set desc = "Edit player (respawn, ban, heal, etc)"
	set category = null

	if(!M)
		to_chat(owner, "You seem to be selecting a mob that doesn't exist anymore.")
		return

	// this is stupid, thanks byond
	if(istype(src, /client))
		var/client/C = src
		src = C.holder

	if (!usr.client.holder || !(check_rights(R_ADMIN|R_MOD, FALSE)))
		to_chat(owner, "Error: you are not an admin!")
		return

	if(!M.mob_panel)
		M.mob_panel = new(src)

	M.mob_panel.tgui_interact(owner.mob)
