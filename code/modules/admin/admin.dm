
var/global/BSACooldown = 0
var/global/floorIsLava = 0


////////////////////////////////
/proc/message_admins(msg)
	msg = "<span class=\"log_message\"><span class=\"prefix\">ADMIN LOG:</span> <span class=\"message\">[msg]</span></span>"
	log_adminwarn(msg)
	for(var/client/C in GLOB.admins)
		if(check_rights(R_ADMIN, FALSE, C))
			to_chat(C, msg, MESSAGE_TYPE_ADMINLOG)
/proc/message_staff(msg)
	msg = "<span class=\"log_message\"><span class=\"prefix\">STAFF LOG:</span> <span class=\"message\">[msg]</span></span>"
	log_adminwarn(msg)
	for(var/client/C in GLOB.admins)
		if(check_rights(R_ADMIN|R_MOD, FALSE, C))
			to_chat(C, msg, MESSAGE_TYPE_ADMINLOG)
/proc/msg_admin_attack(text) //Toggleable Attack Messages
	log_attack(text)
	var/rendered = "<span class=\"log_message\"><span class=\"prefix\">ATTACK:</span> <span class=\"message\">[text]</span></span>"
	for(var/client/C in GLOB.admins)
		if(check_rights(R_ADMIN|R_MOD, FALSE, C))
			if(C.get_preference_value(/datum/client_preference/staff/show_attack_logs) == GLOB.PREF_SHOW)
				var/msg = rendered
				to_chat(C, msg, MESSAGE_TYPE_ATTACKLOG)
/proc/admin_notice(message, rights)
	for(var/mob/M in SSmobs.mob_list)
		if(check_rights(rights, 0, M))
			to_chat(M, message)
///////////////////////////////////////////////////////////////////////////////////////////////Panels

/datum/player_info/var/author // admin who authored the information
/datum/player_info/var/rank //rank of admin who made the notes
/datum/player_info/var/content // text content of the information
/datum/player_info/var/timestamp // Because this is bloody annoying

#define PLAYER_NOTES_ENTRIES_PER_PAGE 50
/datum/admins/proc/PlayerNotes()
	set category = "Admin"
	set name = "Player Notes"
	if (!istype(src,/datum/admins))
		src = usr.client.holder
	if (!istype(src,/datum/admins))
		to_chat(usr, "Error: you are not an admin!")
		return
	PlayerNotesPage()

/datum/admins/proc/PlayerNotesPage(filter_term)
	var/list/dat = list()
	dat += "<B>Player notes</B><HR>"
	var/savefile/S=new("data/player_notes.sav")
	var/list/note_keys
	from_save(S, note_keys)

	if(filter_term)
		for(var/t in note_keys)
			if(findtext(lowertext(t), lowertext(filter_term)))
				continue
			note_keys -= t

	dat += "<center><b>Search term:</b> <a href='byond://?src=\ref[src];notes=set_filter'>[filter_term ? filter_term : "-----"]</a></center><hr>"

	if(!note_keys)
		dat += "No notes found."
	else
		dat += "<table>"
		note_keys = sortList(note_keys)
		for(var/t in note_keys)
			dat += "<tr><td><a href='byond://?src=\ref[src];notes=show;ckey=[t]'>[t]</a></td></tr>"
		dat += "</table><br>"

	var/datum/browser/popup = new(usr, "player_notes", "Player Notes", 400, 400)
	popup.set_content(jointext(dat, null))
	popup.open()


/datum/admins/proc/player_has_info(key as text)
	var/savefile/info = new("data/player_saves/[copytext(key, 1, 2)]/[key]/info.sav")
	var/list/infos
	from_save(info, infos)
	if(!infos || !infos.len) return 0
	else return 1


/datum/admins/proc/show_player_info(key as text)
	set category = "Admin"
	set name = "Show Player Info"
	if (!istype(src,/datum/admins))
		src = usr.client.holder
	if (!istype(src,/datum/admins))
		to_chat(usr, "Error: you are not an admin!")
		return

	var/list/dat = list()

	var/p_age
	var/key_c = ckey(key)
	for(var/client/C in GLOB.clients)
		if(C.ckey == key_c)
			p_age = C.player_age
			break

	if(p_age == null)
		p_age = get_player_age(key)

	dat += "<b>Player age: [p_age ? p_age : "unknown"]</b><br><ul id='notes'>"

	var/savefile/info = new("data/player_saves/[copytext(key, 1, 2)]/[key]/info.sav")
	var/list/infos
	from_save(info, infos)
	if(!infos)
		dat += "No information found on the given key.<br>"
	else
		var/update_file = 0
		var/i = 0
		for(var/datum/player_info/I in infos)
			i += 1
			if(!I.timestamp)
				I.timestamp = "Pre-4/3/2012"
				update_file = 1
			if(!I.rank)
				I.rank = "N/A"
				update_file = 1
			dat += "<li><font color=#7d9177>[I.content]</font> <i>by [I.author] ([I.rank])</i> on <i><font color='#8a94a3'>[I.timestamp]</i></font> "
			if(I.author == usr.key || I.author == "Adminbot" || ishost(usr))
				dat += "<A href='byond://?src=\ref[src];remove_player_info=[key];remove_index=[i]'>Remove</A>"
			dat += "<hr></li>"
		if(update_file) to_save(info, infos)

	dat += "</ul><br><A href='byond://?src=\ref[src];add_player_info=[key]'>Add Comment</A><br>"

	var/html = {"
		<html>
		<head>
			<title>Info on [key]</title>
			<script src='player_info.js'></script>
		</head>
		<body onload='selectTextField(); updateSearch()'; onkeyup='updateSearch()'>
			<div align='center'>
			<table width='100%'><tr>
				<td width='20%'>
					<div align='center'>
						<b>Search:</b>
					</div>
				</td>
				<td width='80%'>
					<input type='text'
					       id='filter'
					       name='filter_text'
					       value=''
					       style='width:100%;' />
				</td>
			</tr></table>
			<hr/>
			[jointext(dat, null)]
		</body>
		</html>
		"}

	send_rsc(usr,'code/js/player_info.js', "player_info.js")
	var/datum/browser/popup = new(usr, "adminplayerinfo", "Player Info", 480, 480)
	popup.set_content(html)
	popup.open()

/datum/admins/proc/access_news_network() //MARKER
	set category = "Fun"
	set name = "Access Newscaster Network"
	set desc = "Allows you to view, add and edit news feeds."

	if (!istype(src,/datum/admins))
		src = usr.client.holder
	if (!istype(src,/datum/admins))
		to_chat(usr, "Error: you are not an admin!")
		return

	var/datum/feed_network/torch_network = news_network[1] //temp change until the UI can be updated to support switching networks.

	var/dat
	dat = text("<HEAD><TITLE>Admin Newscaster</TITLE></HEAD><H3>Admin Newscaster Unit</H3>")

	switch(admincaster_screen)
		if(0)
			dat += {"Welcome to the admin newscaster.<BR> Here you can add, edit and censor every newspiece on the network.
				<BR>Feed channels and stories entered through here will be uneditable and handled as official news by the rest of the units.
				<BR>Note that this panel allows full freedom over the news network, there are no constrictions except the few basic ones. Don't break things!
			"}
			if(torch_network.wanted_issue)
				dat+= "<HR><A href='byond://?src=\ref[src];ac_view_wanted=1'>Read Wanted Issue</A>"

			dat+= {"<HR><BR><A href='byond://?src=\ref[src];ac_create_channel=1'>Create Feed Channel</A>
				<BR><A href='byond://?src=\ref[src];ac_view=1'>View Feed Channels</A>
				<BR><A href='byond://?src=\ref[src];ac_create_feed_story=1'>Submit new Feed story</A>
				<BR><BR><A href='byond://?src=\ref[usr];mach_close=newscaster_main'>Exit</A>
			"}

			var/wanted_already = 0
			if(torch_network.wanted_issue)
				wanted_already = 1

			dat+={"<HR><B>Feed Security functions:</B><BR>
				<BR><A href='byond://?src=\ref[src];ac_menu_wanted=1'>[(wanted_already) ? ("Manage") : ("Publish")] \"Wanted\" Issue</A>
				<BR><A href='byond://?src=\ref[src];ac_menu_censor_story=1'>Censor Feed Stories</A>
				<BR><A href='byond://?src=\ref[src];ac_menu_censor_channel=1'>Mark Feed Channel with [GLOB.using_map.company_name] D-Notice (disables and locks the channel.</A>
				<BR><HR><A href='byond://?src=\ref[src];ac_set_signature=1'>The newscaster recognises you as:<BR> <FONT COLOR='green'>[src.admincaster_signature]</FONT></A>
			"}
		if(1)
			dat+= "Feed Channels<HR>"
			if( !length(torch_network.network_channels) )
				dat+="<I>No active channels found...</I>"
			else
				for(var/datum/feed_channel/CHANNEL in torch_network.network_channels)
					if(CHANNEL.is_admin_channel)
						dat+="<B><FONT style='BACKGROUND-COLOR: LightGreen'><A href='byond://?src=\ref[src];ac_show_channel=\ref[CHANNEL]'>[CHANNEL.channel_name]</A></FONT></B><BR>"
					else
						dat+="<B><A href='byond://?src=\ref[src];ac_show_channel=\ref[CHANNEL]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? (FONT_COLORED("red","***")) : null ]<BR></B>"
			dat+={"<BR><HR><A href='byond://?src=\ref[src];ac_refresh=1'>Refresh</A>
				<BR><A href='byond://?src=\ref[src];ac_setScreen=[0]'>Back</A>
			"}

		if(2)
			dat+={"
				Creating new Feed Channel...
				<HR><B><A href='byond://?src=\ref[src];ac_set_channel_name=1'>Channel Name</A>:</B> [src.admincaster_feed_channel.channel_name]<BR>
				<B><A href='byond://?src=\ref[src];ac_set_signature=1'>Channel Author</A>:</B> <FONT COLOR='green'>[src.admincaster_signature]</FONT><BR>
				<B><A href='byond://?src=\ref[src];ac_set_channel_lock=1'>Will Accept Public Feeds</A>:</B> [(src.admincaster_feed_channel.locked) ? ("NO") : ("YES")]<BR><BR>
				<BR><A href='byond://?src=\ref[src];ac_submit_new_channel=1'>Submit</A><BR><BR><A href='byond://?src=\ref[src];ac_setScreen=[0]'>Cancel</A><BR>
			"}
		if(3)
			dat+={"
				Creating new Feed Message...
				<HR><B><A href='byond://?src=\ref[src];ac_set_channel_receiving=1'>Receiving Channel</A>:</B> [src.admincaster_feed_channel.channel_name]<BR>" //MARK
				<B>Message Author:</B> <FONT COLOR='green'>[src.admincaster_signature]</FONT><BR>
				<B><A href='byond://?src=\ref[src];ac_set_new_message=1'>Message Body</A>:</B> [src.admincaster_feed_message.body] <BR>
				<BR><A href='byond://?src=\ref[src];ac_submit_new_message=1'>Submit</A><BR><BR><A href='byond://?src=\ref[src];ac_setScreen=[0]'>Cancel</A><BR>
			"}
		if(4)
			dat+={"
					Feed story successfully submitted to [src.admincaster_feed_channel.channel_name].<BR><BR>
					<BR><A href='byond://?src=\ref[src];ac_setScreen=[0]'>Return</A><BR>
				"}
		if(5)
			dat+={"
				Feed Channel [src.admincaster_feed_channel.channel_name] created successfully.<BR><BR>
				<BR><A href='byond://?src=\ref[src];ac_setScreen=[0]'>Return</A><BR>
			"}
		if(6)
			dat+="<B><FONT COLOR='maroon'>ERROR: Could not submit Feed story to Network.</B></FONT><HR><BR>"
			if(src.admincaster_feed_channel.channel_name=="")
				dat+="<FONT COLOR='maroon'>Invalid receiving channel name.</FONT><BR>"
			if(src.admincaster_feed_message.body == "" || src.admincaster_feed_message.body == "\[REDACTED\]")
				dat+="<FONT COLOR='maroon'>Invalid message body.</FONT><BR>"
			dat+="<BR><A href='byond://?src=\ref[src];ac_setScreen=[3]'>Return</A><BR>"
		if(7)
			dat+="<B><FONT COLOR='maroon'>ERROR: Could not submit Feed Channel to Network.</B></FONT><HR><BR>"
			if(src.admincaster_feed_channel.channel_name =="" || src.admincaster_feed_channel.channel_name == "\[REDACTED\]")
				dat+="<FONT COLOR='maroon'>Invalid channel name.</FONT><BR>"
			var/check = 0
			for(var/datum/feed_channel/FC in torch_network.network_channels)
				if(FC.channel_name == src.admincaster_feed_channel.channel_name)
					check = 1
					break
			if(check)
				dat+="<FONT COLOR='maroon'>Channel name already in use.</FONT><BR>"
			dat+="<BR><A href='byond://?src=\ref[src];ac_setScreen=[2]'>Return</A><BR>"
		if(9)
			dat+="<B>[src.admincaster_feed_channel.channel_name]: </B><FONT SIZE=1>\[created by: <FONT COLOR='maroon'>[src.admincaster_feed_channel.author]</FONT>\]</FONT><HR>"
			if(src.admincaster_feed_channel.censored)
				dat+={"
					<FONT COLOR='red'><B>ATTENTION: </B></FONT>This channel has been deemed as threatening to the welfare of the [station_name()], and marked with a [GLOB.using_map.company_name] D-Notice.<BR>
					No further feed story additions are allowed while the D-Notice is in effect.<BR><BR>
				"}
			else
				if( !length(admincaster_feed_channel.messages) )
					dat+="<I>No feed messages found in channel...</I><BR>"
				else
					var/i = 0
					for(var/datum/feed_message/MESSAGE in src.admincaster_feed_channel.messages)
						i++
						dat+="-[MESSAGE.body] <BR>"
						if(MESSAGE.img)
							send_rsc(usr, MESSAGE.img, "tmp_photo[i].png")
							dat+="<img src='tmp_photo[i].png' width = '180'><BR><BR>"
						dat+="<FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[MESSAGE.author]</FONT>\]</FONT><BR>"
			dat+={"
				<BR><HR><A href='byond://?src=\ref[src];ac_refresh=1'>Refresh</A>
				<BR><A href='byond://?src=\ref[src];ac_setScreen=[1]'>Back</A>
			"}
		if(10)
			dat+={"
				<B>[GLOB.using_map.company_name] Feed Censorship Tool</B><BR>
				<FONT SIZE=1>NOTE: Due to the nature of news Feeds, total deletion of a Feed Story is not possible.<BR>
				Keep in mind that users attempting to view a censored feed will instead see the \[REDACTED\] tag above it.</FONT>
				<HR>Select Feed channel to get Stories from:<BR>
			"}
			if(!length(torch_network.network_channels))
				dat+="<I>No feed channels found active...</I><BR>"
			else
				for(var/datum/feed_channel/CHANNEL in torch_network.network_channels)
					dat+="<A href='byond://?src=\ref[src];ac_pick_censor_channel=\ref[CHANNEL]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? (FONT_COLORED("red","***")) : null ]<BR>"
			dat+="<BR><A href='byond://?src=\ref[src];ac_setScreen=[0]'>Cancel</A>"
		if(11)
			dat+={"
				<B>[GLOB.using_map.company_name] D-Notice Handler</B><HR>
				<FONT SIZE=1>A D-Notice is to be bestowed upon the channel if the handling Authority deems it as harmful for the [station_name()]'s
				morale, integrity or disciplinary behaviour. A D-Notice will render a channel unable to be updated by anyone, without deleting any feed
				stories it might contain at the time. You can lift a D-Notice if you have the required access at any time.</FONT><HR>
			"}
			if(!length(torch_network.network_channels))
				dat+="<I>No feed channels found active...</I><BR>"
			else
				for(var/datum/feed_channel/CHANNEL in torch_network.network_channels)
					dat+="<A href='byond://?src=\ref[src];ac_pick_d_notice=\ref[CHANNEL]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? (FONT_COLORED("red","***")) : null ]<BR>"

			dat+="<BR><A href='byond://?src=\ref[src];ac_setScreen=[0]'>Back</A>"
		if(12)
			dat+={"
				<B>[src.admincaster_feed_channel.channel_name]: </B><FONT SIZE=1>\[ created by: <FONT COLOR='maroon'>[src.admincaster_feed_channel.author]</FONT> \]</FONT><BR>
				<FONT SIZE=2><A href='byond://?src=\ref[src];ac_censor_channel_author=\ref[src.admincaster_feed_channel]'>[(src.admincaster_feed_channel.author=="\[REDACTED\]") ? ("Undo Author censorship") : ("Censor channel Author")]</A></FONT><HR>
			"}
			if( !length(admincaster_feed_channel.messages) )
				dat+="<I>No feed messages found in channel...</I><BR>"
			else
				for(var/datum/feed_message/MESSAGE in src.admincaster_feed_channel.messages)
					dat+={"
						-[MESSAGE.body] <BR><FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[MESSAGE.author]</FONT>\]</FONT><BR>
						<FONT SIZE=2><A href='byond://?src=\ref[src];ac_censor_channel_story_body=\ref[MESSAGE]'>[(MESSAGE.body == "\[REDACTED\]") ? ("Undo story censorship") : ("Censor story")]</A>  -  <A href='byond://?src=\ref[src];ac_censor_channel_story_author=\ref[MESSAGE]'>[(MESSAGE.author == "\[REDACTED\]") ? ("Undo Author Censorship") : ("Censor message Author")]</A></FONT><BR>
					"}
			dat+="<BR><A href='byond://?src=\ref[src];ac_setScreen=[10]'>Back</A>"
		if(13)
			dat+={"
				<B>[src.admincaster_feed_channel.channel_name]: </B><FONT SIZE=1>\[ created by: <FONT COLOR='maroon'>[src.admincaster_feed_channel.author]</FONT> \]</FONT><BR>
				Channel messages listed below. If you deem them dangerous to the [station_name()], you can <A href='byond://?src=\ref[src];ac_toggle_d_notice=\ref[src.admincaster_feed_channel]'>Bestow a D-Notice upon the channel</A>.<HR>
			"}
			if(src.admincaster_feed_channel.censored)
				dat+={"
					<FONT COLOR='red'><B>ATTENTION: </B></FONT>This channel has been deemed as threatening to the welfare of the [station_name()], and marked with a [GLOB.using_map.company_name] D-Notice.<BR>
					No further feed story additions are allowed while the D-Notice is in effect.<BR><BR>
				"}
			else
				if( !length(admincaster_feed_channel.messages) )
					dat+="<I>No feed messages found in channel...</I><BR>"
				else
					for(var/datum/feed_message/MESSAGE in src.admincaster_feed_channel.messages)
						dat+="-[MESSAGE.body] <BR><FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[MESSAGE.author]</FONT>\]</FONT><BR>"

			dat+="<BR><A href='byond://?src=\ref[src];ac_setScreen=[11]'>Back</A>"
		if(14)
			dat+="<B>Wanted Issue Handler:</B>"
			var/wanted_already = 0
			var/end_param = 1
			if(torch_network.wanted_issue)
				wanted_already = 1
				end_param = 2
			if(wanted_already)
				dat+="<FONT SIZE=2><BR><I>A wanted issue is already in Feed Circulation. You can edit or cancel it below.</FONT></I>"
			dat+={"
				<HR>
				<A href='byond://?src=\ref[src];ac_set_wanted_name=1'>Criminal Name</A>: [src.admincaster_feed_message.author] <BR>
				<A href='byond://?src=\ref[src];ac_set_wanted_desc=1'>Description</A>: [src.admincaster_feed_message.body] <BR>
			"}
			if(wanted_already)
				dat+="<B>Wanted Issue created by:</B><FONT COLOR='green'> [torch_network.wanted_issue.backup_author]</FONT><BR>"
			else
				dat+="<B>Wanted Issue will be created under prosecutor:</B><FONT COLOR='green'> [src.admincaster_signature]</FONT><BR>"
			dat+="<BR><A href='byond://?src=\ref[src];ac_submit_wanted=[end_param]'>[(wanted_already) ? ("Edit Issue") : ("Submit")]</A>"
			if(wanted_already)
				dat+="<BR><A href='byond://?src=\ref[src];ac_cancel_wanted=1'>Take down Issue</A>"
			dat+="<BR><A href='byond://?src=\ref[src];ac_setScreen=[0]'>Cancel</A>"
		if(15)
			dat+={"
				<FONT COLOR='green'>Wanted issue for [src.admincaster_feed_message.author] is now in Network Circulation.</FONT><BR><BR>
				<BR><A href='byond://?src=\ref[src];ac_setScreen=[0]'>Return</A><BR>
			"}
		if(16)
			dat+="<B><FONT COLOR='maroon'>ERROR: Wanted Issue rejected by Network.</B></FONT><HR><BR>"
			if(src.admincaster_feed_message.author =="" || src.admincaster_feed_message.author == "\[REDACTED\]")
				dat+="<FONT COLOR='maroon'>Invalid name for person wanted.</FONT><BR>"
			if(src.admincaster_feed_message.body == "" || src.admincaster_feed_message.body == "\[REDACTED\]")
				dat+="<FONT COLOR='maroon'>Invalid description.</FONT><BR>"
			dat+="<BR><A href='byond://?src=\ref[src];ac_setScreen=[0]'>Return</A><BR>"
		if(17)
			dat+={"
				<B>Wanted Issue successfully deleted from Circulation</B><BR>
				<BR><A href='byond://?src=\ref[src];ac_setScreen=[0]'>Return</A><BR>
			"}
		if(18)
			dat+={"
				<B><FONT COLOR ='maroon'>-- STATIONWIDE WANTED ISSUE --</B></FONT><BR><FONT SIZE=2>\[Submitted by: <FONT COLOR='green'>[torch_network.wanted_issue.backup_author]</FONT>\]</FONT><HR>
				<B>Criminal</B>: [torch_network.wanted_issue.author]<BR>
				<B>Description</B>: [torch_network.wanted_issue.body]<BR>
				<B>Photo:</B>:
			"}
			if(torch_network.wanted_issue.img)
				send_rsc(usr, torch_network.wanted_issue.img, "tmp_photow.png")
				dat+="<BR><img src='tmp_photow.png' width = '180'>"
			else
				dat+="None"
			dat+="<BR><A href='byond://?src=\ref[src];ac_setScreen=[0]'>Back</A><BR>"
		if(19)
			dat+={"
				<FONT COLOR='green'>Wanted issue for [src.admincaster_feed_message.author] successfully edited.</FONT><BR><BR>
				<BR><A href='byond://?src=\ref[src];ac_setScreen=[0]'>Return</A><BR>
			"}
		else
			dat+="I'm sorry to break your immersion. This shit's bugged. Report this bug to Agouri, polyxenitopalidou@gmail.com"

//	log_debug("Channelname: [src.admincaster_feed_channel.channel_name] [src.admincaster_feed_channel.author]")
//	log_debug("Msg: [src.admincaster_feed_message.author] [src.admincaster_feed_message.body]")

	show_browser(usr, dat, "window=admincaster_main;size=400x600")
	onclose(usr, "admincaster_main")



/datum/admins/proc/Jobbans()
	if(!check_rights(R_BAN))	return

	var/dat = "<B>Job Bans!</B><HR><table>"
	for(var/t in jobban_keylist)
		var/r = t
		if( findtext(r,"##") )
			r = copytext( r, 1, findtext(r,"##") )//removes the description
		dat += text("<tr><td>[t] (<A href='byond://?src=\ref[src];removejobban=[r]'>unban</A>)</td></tr>")
	dat += "</table>"
	show_browser(usr, dat, "window=ban;size=400x400")

/datum/admins/proc/Game()
	if(!check_rights(0))	return

	var/dat = {"
		<center><B>Game Panel</B></center><hr>\n
		<A href='byond://?src=\ref[src];c_mode=1'>Change Game Mode</A><br>
		"}
	if(SSticker.master_mode == "secret")
		dat += "<A href='byond://?src=\ref[src];f_secret=1'>(Force Secret Mode)</A><br>"

	dat += {"
		<BR>
		<A href='byond://?src=\ref[src];create_object=1'>Create Object</A><br>
		<A href='byond://?src=\ref[src];create_turf=1'>Create Turf</A><br>
		<A href='byond://?src=\ref[src];create_mob=1'>Create Mob</A><br>
		<br><A href='byond://?src=\ref[src];vsc=airflow'>Edit Airflow Settings</A><br>
		<A href='byond://?src=\ref[src];vsc=phoron'>Edit Phoron Settings</A><br>
		<A href='byond://?src=\ref[src];vsc=default'>Choose a default ZAS setting</A><br>
		"}

	show_browser(usr, HTML_SKELETON(dat), "window=admin2;size=210x280")
	return

/datum/admins/proc/Secrets(datum/admin_secret_category/active_category = null)
	if(!check_rights(0))	return

	// Print the header with category selection buttons.
	var/dat = "<B>The first rule of adminbuse is: you don't talk about the adminbuse.</B><HR>"
	for(var/datum/admin_secret_category/category in admin_secrets.categories)
		if(!category.can_view(usr))
			continue
		if(active_category == category)
			dat += SPAN_CLASS("linkOn","[category.name]")
		else
			dat += "<A href='byond://?src=\ref[src];admin_secrets_panel=\ref[category]'>[category.name]</A> "
	dat += "<HR>"

	// If a category is selected, print its description and then options
	if(istype(active_category) && active_category.can_view(usr))
		if(active_category.desc)
			dat += "<I>[active_category.desc]</I><BR>"
		for(var/datum/admin_secret_item/item in active_category.items)
			if(!item.can_view(usr))
				continue
			dat += "<A href='byond://?src=\ref[src];admin_secrets=\ref[item]'>[item.name()]</A><BR>"
		dat += "<BR>"

	var/datum/browser/popup = new(usr, "secrets", "Secrets", 550, 500)
	popup.set_content(dat)
	popup.open()
	return

/////////////////////////////////////////////////////////////////////////////////////////////////admins2.dm merge
//i.e. buttons/verbs


/datum/admins/proc/restart()
	set category = "Server"
	set name = "Restart"
	set desc="Restarts the world"
	if (!usr.client.holder)
		return
	var/confirm = alert("Restart the game world?", "Restart", "Yes", "Cancel")
	if(confirm == "Cancel")
		return
	if(confirm == "Yes")
		to_world(SPAN_DANGER("Restarting world!</span> <span class='notice'>Initiated by [usr.key]!"))
		log_admin("[key_name(usr)] initiated a reboot.")

		SSstatistics.set_field_details("end_error","admin reboot - by [usr.key]")
		SSstatistics.add_field_details("admin_verb","R") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

		sleep(50)
		world.Reboot()


/datum/admins/proc/announce()
	set category = "Admin"
	set name = "Announce"
	set desc="Announce your desires to the world"
	if(!check_rights(0))	return

	var/message = input("Global message to send:", "Admin Announce", null, null) as message
	var/max_length = 1000
	if(message)
		if(length(message) >= max_length)
			var/overflow = ((length(message)+1) - max_length)
			to_chat(usr, SPAN_WARNING("Your message is too long by [overflow] character\s."))
			return
		message = copytext_char(message,1,max_length)
		message = replacetext(message, "\n", "<br>") // required since we're putting it in a <p> tag
		to_world("<span class=notice><b>[usr.key] Announces:</b><p style='text-indent: 50px'>[message]</p></span>")
		log_admin("Announce: [key_name(usr)] : [message]")
	SSstatistics.add_field_details("admin_verb","A") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
/datum/admins/proc/toggleooc()
	set category = "Server"
	set desc="Globally Toggles OOC"
	set name="Toggle OOC"

	if(!check_rights(R_ADMIN))
		return

	config.ooc_allowed = !(config.ooc_allowed)
	if (config.ooc_allowed)
		to_world("<B>The OOC channel has been globally enabled!</B>")
	else
		to_world("<B>The OOC channel has been globally disabled!</B>")
	log_and_message_staff("toggled OOC.")
	SSstatistics.add_field_details("admin_verb","TOOC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggleaooc()
	set category = "Server"
	set desc="Globally Toggles AOOC"
	set name="Toggle AOOC"

	if(!check_rights(R_ADMIN))
		return

	config.aooc_allowed = !(config.aooc_allowed)
	if (config.aooc_allowed)
		communicate_broadcast(/decl/communication_channel/aooc, "The AOOC channel has been globally enabled!", TRUE)
	else
		communicate_broadcast(/decl/communication_channel/aooc, "The AOOC channel has been globally disabled!", TRUE)
	log_and_message_staff("toggled AOOC.")
	SSstatistics.add_field_details("admin_verb","TAOOC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/togglelooc()
	set category = "Server"
	set desc="Globally Toggles LOOC"
	set name="Toggle LOOC"

	if(!check_rights(R_ADMIN))
		return

	config.looc_allowed = !(config.looc_allowed)
	if (config.looc_allowed)
		to_world("<B>The LOOC channel has been globally enabled!</B>")
	else
		to_world("<B>The LOOC channel has been globally disabled!</B>")
	log_and_message_staff("toggled LOOC.")
	SSstatistics.add_field_details("admin_verb","TLOOC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/togglecrosscomms()
	set category = "Server"
	set desc="Toggle dis bitch"
	set name="Toggle Cross-Server Communications"

	if(!check_rights(R_ADMIN))
		return

	GLOB.cross_comms_allowed = !GLOB.cross_comms_allowed
	log_and_message_admins("toggled cross-comms [GLOB.cross_comms_allowed ? "on" : "off"].")
	SSstatistics.add_field_details("admin_verb", "TCCC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/endnow()
	set category = "Server"
	set desc = "round goes bye bye"
	set name = "End Round"

	var/check = alert("This will immediately end the round. Are you sure about this?", "End Game", "Yes", "No") == "Yes"

	if (!check)
		return

	if (GAME_STATE > RUNLEVEL_LOBBY)
		SSticker.forced_end = TRUE
		log_and_message_staff("has ended the round.")
	else
		to_chat(usr,FONT_LARGE(SPAN_WARNING("You cannot end the round before it's begun!")))

/datum/admins/proc/toggledsay()
	set category = "Server"
	set desc="Globally Toggles DSAY"
	set name="Toggle DSAY"

	if(!check_rights(R_ADMIN))
		return

	config.dsay_allowed = !(config.dsay_allowed)
	if (config.dsay_allowed)
		to_world("<B>Deadchat has been globally enabled!</B>")
	else
		to_world("<B>Deadchat has been globally disabled!</B>")
	log_and_message_staff("toggled deadchat.")
	SSstatistics.add_field_details("admin_verb","TDSAY") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc

/datum/admins/proc/toggletimelocks()
	set category = "Server"
	set desc="Globally Toggles Timelocks for Jobs"
	set name="Toggle Timelocks"
	if(!check_rights(R_ADMIN))
		return
	if(!SSdbcore.IsConnected())
		to_chat(usr,SPAN_WARNING("Timelocks cannot be enabled as there is no connection to the DB!"))
		config.use_timelocks = 0
		return

	config.use_timelocks = !(config.use_timelocks)
	to_world("<B>Timelocks have been globally [config.use_timelocks ? "enabled" : "disabled"]!</B>")
	log_and_message_staff("toggled timelocks.")

/datum/admins/proc/toggleoocdead()
	set category = "Server"
	set desc="Toggle Dead OOC."
	set name="Toggle Dead OOC"

	if(!check_rights(R_ADMIN))
		return

	config.dooc_allowed = !( config.dooc_allowed )
	log_admin("[key_name(usr)] toggled Dead OOC.")
	message_staff("[key_name_admin(usr)] toggled Dead OOC.", 1)
	SSstatistics.add_field_details("admin_verb","TDOOC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/togglehubvisibility()
	set category = "Server"
	set desc="Globally Toggles Hub Visibility"
	set name="Toggle Hub Visibility"

	if(!check_rights(R_ADMIN))
		return

	world.update_hub_visibility(TRUE)
	var/long_message = "Updated hub visibility. The server is now [config.hub_visible ? "visible" : "invisible"]."
	if (config.hub_visible && !world.reachable)
		message_staff("WARNING: The server will not show up on the hub because byond is detecting that a firewall is blocking incoming connections.")

	send2adminirc("[key_name(src)]" + long_message)
	log_and_message_staff(long_message)
	SSstatistics.add_field_details("admin_verb","THUB") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc

/datum/admins/proc/toggletraitorscaling()
	set category = "Server"
	set desc="Toggle traitor scaling"
	set name="Toggle Traitor Scaling"
	config.traitor_scaling = !config.traitor_scaling
	log_admin("[key_name(usr)] toggled Traitor Scaling to [config.traitor_scaling].")
	message_staff("[key_name_admin(usr)] toggled Traitor Scaling [config.traitor_scaling ? "on" : "off"].", 1)
	SSstatistics.add_field_details("admin_verb","TTS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/startnow()
	set category = "Server"
	set desc="Start the round RIGHT NOW"
	set name="Start Now"
	if(GAME_STATE < RUNLEVEL_LOBBY)
		to_chat(usr, FONT_LARGE(SPAN_DANGER("Unable to start the game as it is not yet set up.")))
		SSticker.start_ASAP = !SSticker.start_ASAP
		if(SSticker.start_ASAP)
			to_chat(usr, FONT_LARGE(SPAN_WARNING("The game will begin as soon as possible.")))
			log_and_message_staff("will begin the game as soon as possible.")
		else
			to_chat(usr, FONT_LARGE(SPAN_WARNING("The game will begin as normal.")))
			log_and_message_staff("will begin the game as normal.")
		return 0
	if(SSticker.start_now())
		log_and_message_staff("has started the game.")
		SSstatistics.add_field_details("admin_verb","SN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		return 1
	else
		to_chat(usr, SPAN_CLASS("bigwarning","Error: Start Now: Game has already started."))
		return 0

/datum/admins/proc/toggleenter()
	set category = "Server"
	set desc="People can't enter"
	set name="Toggle Entering"
	config.enter_allowed = !(config.enter_allowed)
	if (!(config.enter_allowed))
		to_world("<B>New players may no longer enter the game.</B>")
	else
		to_world("<B>New players may now enter the game.</B>")
	log_and_message_staff("[key_name_admin(usr)] toggled new player game entering.")
	world.update_status()
	SSstatistics.add_field_details("admin_verb","TE") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggleaban()
	set category = "Server"
	set desc="Respawn basically"
	set name="Toggle Respawn"
	config.abandon_allowed = !(config.abandon_allowed)
	if(config.abandon_allowed)
		to_world("<B>You may now respawn.</B>")
	else
		to_world("<B>You may no longer respawn :(</B>")
	log_and_message_staff("toggled respawn to [config.abandon_allowed ? "On" : "Off"].")
	world.update_status()
	SSstatistics.add_field_details("admin_verb","TR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/delay()
	set category = "Server"
	set desc="Delay the game start/end"
	set name="Delay"

	if(!check_rights(R_SERVER))	return
	if (GAME_STATE > RUNLEVEL_LOBBY)
		SSticker.delay_end = !SSticker.delay_end
		log_and_message_staff("[SSticker.delay_end ? "delayed the round end" : "has made the round end normally"].")
		return //alert("Round end delayed", null, null, null, null, null)
	SSticker.round_progressing = !SSticker.round_progressing
	if (!SSticker.round_progressing)
		to_world("<b>The game start has been delayed.</b>")
		log_admin("[key_name(usr)] delayed the game.")
	else
		to_world("<b>The game will start soon.</b>")
		log_admin("[key_name(usr)] removed the delay.")
	SSstatistics.add_field_details("admin_verb","DELAY") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/adjump()
	set category = "Server"
	set desc="Toggle admin jumping"
	set name="Toggle Jump"
	config.allow_admin_jump = !(config.allow_admin_jump)
	log_and_message_staff("Toggled admin jumping to [config.allow_admin_jump].")
	SSstatistics.add_field_details("admin_verb","TJ") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/adspawn()
	set category = "Server"
	set desc="Toggle admin spawning"
	set name="Toggle Spawn"
	config.allow_admin_spawning = !(config.allow_admin_spawning)
	log_and_message_staff("toggled admin item spawning to [config.allow_admin_spawning].")
	SSstatistics.add_field_details("admin_verb","TAS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/adrev()
	set category = "Server"
	set desc="Toggle admin revives"
	set name="Toggle Revive"
	config.allow_admin_rev = !(config.allow_admin_rev)
	log_and_message_staff("toggled reviving to [config.allow_admin_rev].")
	SSstatistics.add_field_details("admin_verb","TAR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/immreboot()
	set category = "Server"
	set desc="Reboots the server post haste"
	set name="Immediate Reboot"
	if(!check_rights(R_SERVER, FALSE, usr))
		return
	if( alert("Reboot server?",,"Yes","No") == "No")
		return
	to_world(SPAN_DANGER("Rebooting world!</span> <span class='notice'>Initiated by [usr.key]!"))
	log_admin("[key_name(usr)] initiated an immediate reboot.")

	SSstatistics.set_field_details("end_error","immediate admin reboot - by [usr.key]")
	SSstatistics.add_field_details("admin_verb","IR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	world.Reboot()

/datum/admins/proc/unprison(mob/M in SSmobs.mob_list)
	set category = "Admin"
	set name = "Unprison"
	if (isAdminLevel(M.z))
		if (config.allow_admin_jump)
			M.forceMove(pick(GLOB.latejoin))
			message_staff("[key_name_admin(usr)] has unprisoned [key_name_admin(M)]", 1)
			log_admin("[key_name(usr)] has unprisoned [key_name(M)]")
		else
			alert("Admin jumping disabled")
	else
		alert("[M.name] is not prisoned.")
	SSstatistics.add_field_details("admin_verb","UP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

////////////////////////////////////////////////////////////////////////////////////////////////ADMIN HELPER PROCS

/proc/is_special_character(character) // returns 1 for special characters and 2 for heroes of gamemode
	if(!SSticker.mode)
		return 0
	var/datum/mind/M
	if (ismob(character))
		var/mob/C = character
		M = C.mind
	else if(istype(character, /datum/mind))
		M = character

	if(M)
		if(SSticker.mode.antag_templates && SSticker.mode.antag_templates.len)
			for(var/datum/antagonist/antag in SSticker.mode.antag_templates)
				if(antag.is_antagonist(M))
					return 2
		if(M.special_role)
			return 1

	if(isrobot(character))
		var/mob/living/silicon/robot/R = character
		if(R.emagged)
			return 1

	return 0

/datum/admins/proc/mass_debug_closet_icons()

	set name = "Mass Debug Closet Icons"
	set desc = "Spawn every possible custom closet. Do not do this on live."
	set category = "Debug"

	if(!check_rights(R_SPAWN))
		return

	if((input(usr, "Are you sure you want to spawn all these closets?", "So Many Closets") as null|anything in list("No", "Yes")) == "Yes")
		log_admin("[key_name(usr)] mass-spawned closets (icon debug), if this is a live server you should yell at them.")
		var/x = 0
		var/y = 0
		for(var/check_appearance in typesof(/decl/closet_appearance))
			x++
			if(x > 10)
				x = 0
				y++
			var/turf/T = locate(usr.x+x, usr.y+y, usr.z)
			if(T)
				new /obj/structure/closet/debug(T, check_appearance)

/datum/admins/proc/spawn_fruit(seedtype in SSplants.seeds)
	set category = "Debug"
	set desc = "Spawn the product of a seed."
	set name = "Spawn Fruit"

	if(!check_rights(R_SPAWN))	return

	if(!seedtype || !SSplants.seeds[seedtype])
		return
	var/datum/seed/S = SSplants.seeds[seedtype]
	S.harvest(usr,0,0,1)
	log_admin("[key_name(usr)] spawned [seedtype] fruit at ([usr.x],[usr.y],[usr.z])")

/datum/admins/proc/spawn_plant(seedtype in SSplants.seeds)
	set category = "Debug"
	set desc = "Spawn a spreading plant effect."
	set name = "Spawn Plant"

	if(!check_rights(R_SPAWN))	return

	if(!seedtype || !SSplants.seeds[seedtype])
		return
	new /obj/effect/vine(get_turf(usr), SSplants.seeds[seedtype])
	log_admin("[key_name(usr)] spawned [seedtype] vines at ([usr.x],[usr.y],[usr.z])")

/datum/admins/proc/spawn_atom(object as text)
	set category = "Debug"
	set desc = "(atom path) Spawn an atom"
	set name = "Spawn"

	if(!check_rights(R_SPAWN))	return

	var/list/types = typesof(/atom)
	var/list/matches = new()

	for(var/path in types)
		if(findtext("[path]", object))
			matches += path

	if(matches.len==0)
		return

	var/chosen
	if(matches.len==1)
		chosen = matches[1]
	else
		chosen = tgui_input_list(usr, "Select an atom type", "Spawn Atom", matches, matches[1])
		if(!chosen)
			return

	if(ispath(chosen,/turf))
		var/turf/T = get_turf(usr.loc)
		T.ChangeTurf(chosen)
	else
		new chosen(usr.loc)

	log_and_message_staff("spawned [chosen] at ([usr.x],[usr.y],[usr.z])")
	SSstatistics.add_field_details("admin_verb","SA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/spawn_artifact(effect in subtypesof(/datum/artifact_effect))
	set category = "Debug"
	set desc = "(atom path) Spawn an artifact with a specified effect."
	set name = "Spawn Artifact"

	if (!check_rights(R_SPAWN))
		return

	var/obj/machinery/artifact/A
	var/datum/artifact_trigger/primary_trigger

	var/datum/artifact_effect/secondary_effect
	var/datum/artifact_trigger/secondary_trigger

	if (ispath(effect))
		primary_trigger = input(usr, "Choose a trigger", "Choose a trigger") as null | anything in subtypesof(/datum/artifact_trigger)

		if (!ispath(primary_trigger))
			return

		var/choice = alert(usr, "Secondary effect?", "Secondary effect", "Yes", "No") == "Yes"

		if (choice)
			secondary_effect = input(usr, "Choose an effect", "Choose effect") as null | anything in subtypesof(/datum/artifact_effect)

			if (!ispath(secondary_effect))
				return

			secondary_trigger = input(usr, "Choose a trigger", "Choose a trigger") as null | anything in subtypesof(/datum/artifact_trigger)

			if (!ispath(secondary_trigger))
				return


		A = new(usr.loc)
		A.my_effect = new effect(A)
		A.my_effect.trigger = new primary_trigger(A.my_effect)

		if (secondary_effect)
			A.secondary_effect = new secondary_effect
			A.secondary_effect.trigger = new secondary_trigger
		else
			QDEL_NULL(A.secondary_effect)

/datum/admins/proc/show_traitor_panel(mob/M in SSmobs.mob_list)
	set category = "Admin"
	set desc = "Edit mobs's memory and role"
	set name = "Show Traitor Panel"

	if(!istype(M))
		to_chat(usr, "This can only be used on instances of type /mob")
		return
	if(!M.mind)
		to_chat(usr, "This mob has no mind!")
		return

	M.mind.edit_memory()
	SSstatistics.add_field_details("admin_verb","STP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/show_game_mode()
	set category = "Admin"
	set desc = "Show the current round configuration."
	set name = "Show Game Mode"

	if(!SSticker.mode)
		alert("Not before roundstart!", "Alert")
		return

	var/out = "<font size=3><b>Current mode: [SSticker.mode.name] (<a href='byond://?src=\ref[SSticker.mode];debug_antag=self'>[SSticker.mode.config_tag]</a>)</b></font><br/>"
	out += "<hr>"

	if(SSticker.mode.ert_disabled)
		out += "<b>Mobile Task Forces:</b> <a href='byond://?src=\ref[SSticker.mode];toggle=ert'>disabled</a>"
	else
		out += "<b>Mobile Task Forces:</b> <a href='byond://?src=\ref[SSticker.mode];toggle=ert'>enabled</a>"
	out += "<br/>"

	if(SSticker.mode.deny_respawn)
		out += "<b>Respawning:</b> <a href='byond://?src=\ref[SSticker.mode];toggle=respawn'>disallowed</a>"
	else
		out += "<b>Respawning:</b> <a href='byond://?src=\ref[SSticker.mode];toggle=respawn'>allowed</a>"
	out += "<br/>"

	out += "<b>Shuttle delay multiplier:</b> <a href='byond://?src=\ref[SSticker.mode];set=shuttle_delay'>[SSticker.mode.shuttle_delay]</a><br/>"

	if(SSticker.mode.auto_recall_shuttle)
		out += "<b>Shuttle auto-recall:</b> <a href='byond://?src=\ref[SSticker.mode];toggle=shuttle_recall'>enabled</a>"
	else
		out += "<b>Shuttle auto-recall:</b> <a href='byond://?src=\ref[SSticker.mode];toggle=shuttle_recall'>disabled</a>"
	out += "<br/><br/>"

	if(SSticker.mode.event_delay_mod_moderate)
		out += "<b>Moderate event time modifier:</b> <a href='byond://?src=\ref[SSticker.mode];set=event_modifier_moderate'>[SSticker.mode.event_delay_mod_moderate]</a><br/>"
	else
		out += "<b>Moderate event time modifier:</b> <a href='byond://?src=\ref[SSticker.mode];set=event_modifier_moderate'>unset</a><br/>"

	if(SSticker.mode.event_delay_mod_major)
		out += "<b>Major event time modifier:</b> <a href='byond://?src=\ref[SSticker.mode];set=event_modifier_severe'>[SSticker.mode.event_delay_mod_major]</a><br/>"
	else
		out += "<b>Major event time modifier:</b> <a href='byond://?src=\ref[SSticker.mode];set=event_modifier_severe'>unset</a><br/>"

	out += "<hr>"

	if(SSticker.mode.antag_tags && SSticker.mode.antag_tags.len)
		out += "<b>Core antag templates:</b></br>"
		for(var/antag_tag in SSticker.mode.antag_tags)
			out += "<a href='byond://?src=\ref[SSticker.mode];debug_antag=[antag_tag]'>[antag_tag]</a>.</br>"

	if(SSticker.mode.round_autoantag)
		out += "<b>Autotraitor <a href='byond://?src=\ref[SSticker.mode];toggle=autotraitor'>enabled</a></b>."
		if(SSticker.mode.antag_scaling_coeff > 0)
			out += " (scaling with <a href='byond://?src=\ref[SSticker.mode];set=antag_scaling'>[SSticker.mode.antag_scaling_coeff]</a>)"
		else
			out += " (not currently scaling, <a href='byond://?src=\ref[SSticker.mode];set=antag_scaling'>set a coefficient</a>)"
		out += "<br/>"
	else
		out += "<b>Autotraitor <a href='byond://?src=\ref[SSticker.mode];toggle=autotraitor'>disabled</a></b>.<br/>"

	out += "<b>All antag ids:</b>"
	if(SSticker.mode.antag_templates && SSticker.mode.antag_templates.len)
		for(var/datum/antagonist/antag in SSticker.mode.antag_templates)
			antag.update_current_antag_max(SSticker.mode)
			out += " <a href='byond://?src=\ref[SSticker.mode];debug_antag=[antag.id]'>[antag.id]</a>"
			out += " ([antag.get_antag_count()]/[antag.cur_max]) "
			out += " <a href='byond://?src=\ref[SSticker.mode];remove_antag_type=[antag.id]'>\[-\]</a><br/>"
	else
		out += " None."
	out += " <a href='byond://?src=\ref[SSticker.mode];add_antag_type=1'>\[+\]</a><br/>"

	show_browser(usr, out, "window=edit_mode[src]")
	SSstatistics.add_field_details("admin_verb","SGM")


/datum/admins/proc/toggletintedweldhelmets()
	set category = "Debug"
	set desc="Reduces view range when wearing welding helmets"
	set name="Toggle tinted welding helmets."
	config.welder_vision = !( config.welder_vision )
	if (config.welder_vision)
		to_world("<B>Reduced welder vision has been enabled!</B>")
	else
		to_world("<B>Reduced welder vision has been disabled!</B>")
	log_and_message_staff("toggled welder vision.")
	SSstatistics.add_field_details("admin_verb","TTWH") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggleguests()
	set category = "Server"
	set desc="Guests can't enter"
	set name="Toggle guests"
	config.guests_allowed = !(config.guests_allowed)
	if (!(config.guests_allowed))
		to_world("<B>Guests may no longer enter the game.</B>")
	else
		to_world("<B>Guests may now enter the game.</B>")
	log_admin("[key_name(usr)] toggled guests game entering [config.guests_allowed?"":"dis"]allowed.")
	log_and_message_staff("toggled guests game entering [config.guests_allowed?"":"dis"]allowed.")
	SSstatistics.add_field_details("admin_verb","TGU") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/output_ai_laws()
	var/ai_number = 0
	for(var/mob/living/silicon/S in SSmobs.mob_list)
		ai_number++
		if(isAI(S))
			to_chat(usr, "<b>AI [key_name(S, usr)]'s laws:</b>")
		else if(isrobot(S))
			var/mob/living/silicon/robot/R = S
			to_chat(usr, "<b>CYBORG [key_name(S, usr)] [R.connected_ai?"(Slaved to: [R.connected_ai])":"(Independant)"]: laws:</b>")
		else if (ispAI(S))
			to_chat(usr, "<b>pAI [key_name(S, usr)]'s laws:</b>")
		else
			to_chat(usr, "<b>SOMETHING SILICON [key_name(S, usr)]'s laws:</b>")

		if (S.laws == null)
			to_chat(usr, "[key_name(S, usr)]'s laws are null?? Contact a coder.")
		else
			S.laws.show_laws(usr)
	if(!ai_number)
		to_chat(usr, "<b>No AIs located</b>")//Just so you know the thing is actually working and not just ignoring you.

/datum/admins/proc/show_skills(mob/M)
	set category = null
	set name = "Skill Panel"

	if (!istype(src,/datum/admins))
		src = usr.client.holder
	if (!istype(src,/datum/admins))
		to_chat(usr, "Error: you are not an admin!")
		return

	if(!M)
		M = input("Select mob.", "Select mob.") as null|anything in GLOB.player_list
	if(!istype(M))
		return
	var/datum/nano_module/skill_ui/NM = /datum/nano_module/skill_ui
	if(check_rights(R_MOD|R_ADMIN, 0, usr))
		NM = /datum/nano_module/skill_ui/admin //They get the fancy version that lets you change skills and debug stuff.
	NM = new NM(usr, override = M.skillset)
	NM.ui_interact(usr)

/client/proc/update_mob_sprite(mob/living/carbon/human/H as mob)
	set category = "Admin"
	set name = "Update Mob Sprite"
	set desc = "Should fix any mob sprite update errors."

	if (!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	if(istype(H))
		H.regenerate_icons()

/proc/get_options_bar(whom, detail = 2, name = 0, link = 1, highlight_special = 1, datum/ticket/ticket = null)
	if(!whom)
		return "<b>(*null*)</b>"
	var/mob/M
	var/client/C
	if(istype(whom, /client))
		C = whom
		M = C.mob
	else if(istype(whom, /mob))
		M = whom
		C = M.client
	else
		return "<b>(*not a mob*)</b>"
	switch(detail)
		if(0)
			return key_name_admin(M)

		if(1)	//Private Messages
			return "[ADMIN_LOOKUP(M)]"

		if(2)	//Admins
			return ADMIN_FULLMONTY(M)

		if(3)	//Devs
			return "[key_name_admin(M)][ADMIN_VV(M)][ADMIN_JMP(M)]"

/proc/ishost(client/C)
	return check_rights(R_HOST, 0, C)

//Prevents SDQL2 commands from changing admin permissions
/datum/admins/SDQL_update(const/var_name, new_value)
	return 0

//
//
//ALL DONE
//*********************************************************************************************************
//

//Returns 1 to let the dragdrop code know we are trapping this event
//Returns 0 if we don't plan to trap the event
/datum/admins/proc/cmd_ghost_drag(mob/observer/ghost/frommob, mob/living/tomob)
	if(!istype(frommob))
		return //Extra sanity check to make sure only observers are shoved into things

	//Same as assume-direct-control perm requirements.
	if (!check_rights(R_VAREDIT,0) || !check_rights(R_ADMIN|R_DEBUG,0))
		return 0
	if (!frommob.ckey)
		return 0
	var/question = ""
	if (tomob.ckey)
		question = "This mob already has a user ([tomob.key]) in control of it! "
	question += "Are you sure you want to place [frommob.name]([frommob.key]) in control of [tomob.name]?"
	var/ask = alert(question, "Place ghost in control of mob?", "Yes", "No")
	if (ask != "Yes")
		return 1
	if (!frommob || !tomob) //make sure the mobs don't go away while we waited for a response
		return 1
	if(tomob.client) //No need to ghostize if there is no client
		tomob.ghostize(0)
	message_staff(SPAN_CLASS("adminnotice","[key_name_admin(usr)] has put [frommob.ckey] in control of [tomob.name]."))
	log_admin("[key_name(usr)] stuffed [frommob.ckey] into [tomob.name].")
	SSstatistics.add_field_details("admin_verb","CGD")
	tomob.ckey = frommob.ckey
	qdel(frommob)
	return 1

/datum/admins/proc/force_antag_latespawn()
	set category = "Admin"
	set name = "Force Template Spawn"
	set desc = "Force an antagonist template to spawn."

	if (!istype(src,/datum/admins))
		src = usr.client.holder
	if (!istype(src,/datum/admins))
		to_chat(usr, "Error: you are not an admin!")
		return

	if(GAME_STATE < RUNLEVEL_GAME)
		to_chat(usr, "Mode has not started.")
		return

	var/list/all_antag_types = GLOB.all_antag_types_
	var/antag_type = input("Choose a template.","Force Latespawn") as null|anything in all_antag_types
	if(!antag_type || !all_antag_types[antag_type])
		to_chat(usr, "Aborting.")
		return

	var/datum/antagonist/antag = all_antag_types[antag_type]
	message_staff("[key_name(usr)] attempting to force latespawn with template [antag.id].")
	antag.attempt_auto_spawn()

/datum/admins/proc/force_mode_latespawn()
	set category = "Admin"
	set name = "Force Mode Spawn"
	set desc = "Force autotraitor to proc."

	if (!istype(src,/datum/admins))
		src = usr.client.holder
	if (!istype(src,/datum/admins) || !check_rights(R_ADMIN))
		to_chat(usr, "Error: you are not an admin!")
		return

	if(GAME_STATE < RUNLEVEL_GAME)
		to_chat(usr, "Mode has not started.")
		return

	log_and_message_staff("attempting to force mode autospawn.")
	SSticker.mode.process_autoantag()

/datum/admins/proc/paralyze_mob(mob/living/H as mob in GLOB.player_list)
	set category = null
	set name = "Toggle Paralyze"
	set desc = "Toggles paralyze state, which stuns, blinds and mutes the victim."

	var/msg

	if(!isliving(H))
		return

	if(check_rights(R_ADMIN|R_MOD))
		if (!H.admin_paralyzed)
			H.paralysis = 8000
			H.admin_paralyzed = TRUE
			msg = "has paralyzed [key_name(H)]."
			H.visible_message(SPAN_DEBUG("OOC: \The [H] has been paralyzed by a staff member. Please hold all interactions with them until staff have finished with them."))
			to_chat(H, SPAN_DEBUG("OOC: You have been paralyzed by a staff member. Please refer to your currently open admin help ticket or, if you don't have one, admin help for assistance."))
		else
			H.paralysis = 0
			H.admin_paralyzed = FALSE
			msg = "has unparalyzed [key_name(H)]."
			H.visible_message(SPAN_DEBUG("OOC: \The [H] has been released from paralysis by staff. You may resume interactions with them."))
			to_chat(H, SPAN_DEBUG("OOC: You have been released from paralysis by staff and can return to your game."))
		log_and_message_staff(msg)


/datum/admins/proc/sendFax()
	set category = "Special Verbs"
	set name = "Send Fax"
	set desc = "Sends a fax to this machine"

	// Admin status checks
	if (!istype(src,/datum/admins))
		src = usr.client.holder
	if (!istype(src,/datum/admins))
		to_chat(usr, "Error: you are not an admin!")
		return

	// Origin
	var/list/option_list = GLOB.alldepartments.Copy() + "(Custom)"
	var/replyorigin = tgui_input_list(owner, "Please specify who the fax is coming from. Choose '(Custom)' to enter a custom department or '(Cancel) to cancel.", "Fax Origin", option_list)
	if (!replyorigin || replyorigin == "(Cancel)")
		return
	if (replyorigin == "(Custom)")
		replyorigin = tgui_input_text(owner, "Please specify who the fax is coming from.", "Fax Machine Department Tag")
		if (!replyorigin)
			return
	if (replyorigin == "Unknown" || replyorigin == "(Custom)")
		to_chat(owner, SPAN_WARNING("Invalid origin selected."))
		return

	// Destination
	var/department = tgui_input_list(owner, "Choose a destination fax", "Fax Target", GLOB.alldepartments)
	if(!department)
		return

	// Generate the fax
	var/obj/item/paper/admin/P = new /obj/item/paper/admin( null ) //hopefully the null loc won't cause trouble for us
	faxreply = P
	P.admindatum = src
	P.origin = replyorigin
	P.department = department
	P.destinations = get_fax_machines_by_department(department)
	P.adminbrowse()


/client/proc/check_fax_history()
	set category = "Special Verbs"
	set name = "Check Fax History"
	set desc = "Look up the faxes sent this round."

	var/data = "<center><b>Fax History:</b></center><br>"

	if(length(GLOB.adminfaxes))
		for(var/obj/item/item in GLOB.adminfaxes)
			data += "[item.name] - <a href='byond://?_src_=holder;AdminFaxView=\ref[item]'>view message</a><br>"
	else
		data += "<center>No faxes yet.</center>"
	show_browser(usr, "<HTML><HEAD><TITLE>Fax History</TITLE><meta http-equiv='X-UA-Compatible' content='IE=edge' charset='UTF-8'/></HEAD><BODY>[data]</BODY></HTML>", "window=FaxHistory;size=450x400")


/datum/admins/var/obj/item/paper/admin/faxreply // var to hold fax replies in

/datum/admins/proc/faxCallback(obj/item/paper/admin/P)
	var/customname = tgui_input_text(src.owner, "Pick a title for the report", "Title")

	P.SetName("[customname]")

	var/shouldStamp = TRUE
	var/need_stamp = tgui_alert(src.owner, "Would you like the fax stamped?", "Stamp", list("Yes", "No"))
	if(need_stamp != "Yes")
		shouldStamp = FALSE

	if(shouldStamp)
		P.stamps += "<hr><i>This paper has been stamped by the [P.origin] Quantum Relay.</i>"

		var/image/stampoverlay = image('icons/obj/bureaucracy.dmi')
		var/x
		var/y
		x = rand(-2, 0)
		y = rand(-1, 2)
		P.offset_x += x
		P.offset_y += y
		stampoverlay.pixel_x = x
		stampoverlay.pixel_y = y

		if(!P.ico)
			P.ico = new
		P.ico += "paper_stamp-boss"
		stampoverlay.icon_state = "paper_stamp-boss"

		if(!P.stamped)
			P.stamped = new
		P.stamped += /obj/item/stamp/boss
		P.overlays += stampoverlay

	var/obj/item/rcvdcopy
	var/obj/machinery/photocopier/faxmachine/destination = P.destinations[1]
	rcvdcopy = destination.copy(P, FALSE)
	rcvdcopy.forceMove(null) //hopefully this shouldn't cause trouble

	if(P.origin_offsite)
		SEND_SIGNAL(P.origin_offsite, COMSIG_OFFSITE_FAX_SENT, rcvdcopy, P)
	GLOB.adminfaxes += rcvdcopy
	var/success = send_fax_loop(P, P.department, P.origin)

	if(success)
		log_admin("[key_name(src.owner)] has sent a fax message to [P.department]")
		message_staff("[key_name_admin(src.owner)] has sent a fax message to [P.department] (<a href='byond://?_src_=holder;AdminFaxView=\ref[rcvdcopy]'>VIEW</a>)")
	else
		to_chat(src.owner, SPAN_WARNING("Fax transmission failed! Saved to offsite log for recovery of contents."))

	qdel(P)
	faxreply = null
	return

/datum/admins/proc/shutdown_server()
	set category = "Server"
	set name = "Shutdown Server"
	set desc = "Shuts the server down."

	var/static/client/shuttingdown

	if(!(check_rights(R_ADMIN) && check_rights(R_DEBUG) && check_rights(R_SERVER)))
		return

	if(shuttingdown)
		if(alert("Are you use you want to cancel the shutdown initiated by [shuttingdown.key]?", "Cancel the shutdown?", "No", "Yes") != "Yes")
			return
		message_staff("[key_name_admin(usr)] cancelled the server shutdown, started by [key_name_admin(shuttingdown)] .")
		shuttingdown = FALSE
		return

	if(alert("Are you sure you want to shutdown the server? Only somebody with remote access to the server can turn it back on.", "Shutdown Server?", "Cancel", "Shutdown Server") != "Shutdown Server")
		return

	if(GAME_STATE == RUNLEVEL_GAME)
		to_chat(usr, SPAN_DANGER("The server must be in either pre-game and the start must be delayed or already started with the end delayed to shutdown the server."))
		return

	if((GAME_STATE == RUNLEVEL_LOBBY && SSticker.round_start_time > 0) || (GAME_STATE == RUNLEVEL_POSTGAME && !SSticker.delay_end))
		to_chat(usr, SPAN_DANGER("The round start/end is not delayed."))
		return

	to_chat(usr, SPAN_DANGER("Alert: Delayed confirmation required. You will be asked to confirm again in 30 seconds."))
	log_and_message_staff("[key_name_admin(usr.client)] initiated the shutdown process.")
	message_staff("You may abort this by pressing the shutdown server button again.")
	shuttingdown = usr.client

	sleep(30 SECONDS)

	if(!shuttingdown || shuttingdown != usr?.client)
		return

	if(alert("ARE YOU REALLY SURE YOU WANT TO SHUTDOWN THE SERVER? ONLY SOMEBODY WITH REMOTE ACCESS TO THE SERVER CAN TURN IT BACK ON.", "Shutdown Server?", "Cancel", "Shutdown Server") != "Shutdown Server")
		log_and_message_staff("[key_name_admin(shuttingdown)] decided against shutting down the server.")
		shuttingdown = null
		return

	to_world("[SPAN_DANGER("Server shutting down in 30 seconds!")] [SPAN_NOTICE("Initiated by [shuttingdown.key]!")]")
	message_staff("[key_name_admin(shuttingdown)] is shutting down the server. You may abort this by pressing the shutdown server button again within 30 seconds.")

	sleep(30 SECONDS)

	if(!shuttingdown)
		to_world(SPAN_NOTICE("Server shutdown was aborted"))
		return

	if(shuttingdown != usr?.client)
		return

	to_world("[SPAN_DANGER("Shutting down server!")] [SPAN_NOTICE("Initiated by [shuttingdown.key]!")]")
	log_admin("Server shutting down. Initiated by: [shuttingdown]")

	sleep(world.tick_lag)
	shutdown()
