#define TICKET_AUTORESPONSE_IC_ISSUE "<b>This issue has been deemed an IC (In-Character) issue, and will not be handled by staff. In case it's relevant, you may wish to ask your <a href='https://scp13.miraheze.org/wiki/Rank'>Chain Of Command</a> about your issue if you believe <a href='https://scp13.miraheze.org/wiki/Foundation_Rules'>Foundation Law</a> has been broken.</b>"
#define TICKET_AUTORESPONSE_BEING_HANDLED "<b>The issue is already being dealt with.</b>"
#define TICKET_AUTORESPONSE_FIXED "<b>The issue is already fixed.</b>"
#define TICKET_AUTORESPONSE_THANKS "<b>Have a SCP day!</b>"
#define TICKET_AUTORESPONSE_REQUESTING_TO_BE_SCP "<b>Only under certain circumstances will an admin put you into special SCPs. Examples of these circumstances are: Imminent Test, gross negligence in containment, or an ongoing event. Do not repeatedly ask to become an SCP, as this might get you a mute.</b>"
#define TICKET_AUTORESPONSE_BECOMING_AN_SCP "<b>In order to become a standard SCP, go to the Ghost verbs tab and click on 'Become Euclid/Keter SCP' or 'Become Safe SCP'. If an SCP is not occupied nor listed, it is most likely a special SCP that cannot be automatically joined as.</b>"
#define TICKET_AUTORESPONSE_GITHUB_ISSUE "<b>Thanks for reporting this issue! Though, for maximum effectivity, please create an issue report on our <a href='https://github.com/Foundation-19/Foundation-19/issues'>GitHub</a>.</b>"
#define TICKET_AUTORESPONSE_RUST_ENGINE "<b>The RUST Engine can be set up by finding the placed manual in the chamber area's, or alternatively you can visit <a href='https://bay.ss13.me/Guides/RUST'>the wiki guide on this engine</a>.</b>"
#define TICKET_AUTORESPONSE_D_CLASS_RIOT "<b>D-Class may only riot with permission from a member of staff, and needs a good reason. If you wish to start a riot, you are to adminhelp again, outlining your reason. A member of staff will take your request under advisement.</b>"
#define TICKET_AUTORESPONSE_D_CLASS_CELLS "<b>You can only get out if the on-duty guards feel like releasing you. It's best to wait and watch a YouTube video until such time.</b>"
#define TICKET_AUTORESPONSE_DIRECTIONS_OR_LOST "<b>If you are lost, it is best to keep an eye on directional signs, ask a fellow player or find Holomaps, if they have been added to the current map.</b>"
#define TICKET_AUTORESPONSE_CHARACTER_SETUP "<b>In order to join the game, you are required to select a branch and rank, found in the top area of the character set up. Once you have done this, you can join the jobs that are allowed for that rank. It is best to experiment for a moment to see which rank suits you best, since some jobs allow multiple.</b>"
#define TICKET_AUTORESPONSE_WEBSITE_AND_DISCORD "<b>Hello, and welcome! Our website is located at: <a href='https://foundation-19.github.io/live/#'>https://foundation-19.github.io/live/</a> , our wiki is located at: <a href='https://scp13.miraheze.org/wiki'>https://scp13.miraheze.org/wiki</a>, our Discord is located at: <a href='https://discord.gg/xPxjQpp3Ud'>https://discord.gg/xPxjQpp3Ud</a> and our Patreon is located at: <a href='https://www.patreon.com/GSDR'>https://www.patreon.com/GSDR</a>. Hope to see you soon!</b>"

#define TICKET_AUTORESPONSE_DEFAULT_NOTICE_MESSAGE "<b>NOTICE: [FONT_COLORED(COLOR_RED, usr.key)] is autoresponding with [FONT_COLORED(COLOR_ISLAMIC_GREEN, choice)].</b>"


/datum/admins/Topic(href, href_list)
	..()

	if(usr.client != src.owner || !check_rights(0))
		log_admin("[key_name(usr)] tried to use the admin panel without authorization.")
		message_staff("[usr.key] has attempted to override the admin panel!")
		return

	if(SSticker.mode && SSticker.mode.check_antagonists_topic(href, href_list))
		check_antagonists()
		return

	if(href_list["dbsearchckey"] || href_list["dbsearchadmin"])

		var/adminckey = href_list["dbsearchadmin"]
		var/playerckey = href_list["dbsearchckey"]
		var/playerip = href_list["dbsearchip"]
		var/playercid = href_list["dbsearchcid"]
		var/dbbantype = text2num(href_list["dbsearchbantype"])
		var/match = 0

		if("dbmatch" in href_list)
			match = 1

		DB_ban_panel(playerckey, adminckey, playerip, playercid, dbbantype, match)
		return

	else if(href_list["dbbanedit"])
		var/banedit = href_list["dbbanedit"]
		var/banid = text2num(href_list["dbbanid"])
		if(!banedit || !banid)
			return

		DB_ban_edit(banid, banedit)
		return

	else if(href_list["dbbanaddtype"])

		var/bantype = text2num(href_list["dbbanaddtype"])
		var/banckey = href_list["dbbanaddckey"]
		var/banip = href_list["dbbanaddip"]
		var/bancid = href_list["dbbanaddcid"]
		var/banduration = text2num(href_list["dbbaddduration"])
		var/banjob = href_list["dbbanaddjob"]
		var/banreason = href_list["dbbanreason"]

		banckey = ckey(banckey)

		switch(bantype)
			if(BANTYPE_PERMA)
				if(!banckey || !banreason)
					to_chat(usr, "Not enough parameters (Requires ckey and reason)")
					return
				banduration = null
				banjob = null
			if(BANTYPE_TEMP)
				if(!banckey || !banreason || !banduration)
					to_chat(usr, "Not enough parameters (Requires ckey, reason and duration)")
					return
				banjob = null
			if(BANTYPE_JOB_PERMA)
				if(!banckey || !banreason || !banjob)
					to_chat(usr, "Not enough parameters (Requires ckey, reason and job)")
					return
				banduration = null
			if(BANTYPE_JOB_TEMP)
				if(!banckey || !banreason || !banjob || !banduration)
					to_chat(usr, "Not enough parameters (Requires ckey, reason and job)")
					return

		var/mob/playermob

		for(var/mob/M in GLOB.player_list)
			if(M.ckey == banckey)
				playermob = M
				break


		banreason = "(MANUAL BAN) "+banreason

		if(!playermob)
			if(banip)
				banreason = "[banreason] (CUSTOM IP)"
			if(bancid)
				banreason = "[banreason] (CUSTOM CID)"
		else
			message_staff("Ban process: A mob matching [playermob.ckey] was found at location [playermob.x], [playermob.y], [playermob.z]. Custom ip and computer id fields replaced with the ip and computer id from the located mob")
		notes_add(banckey,banreason,usr)

		DB_ban_record(bantype, playermob, banduration, banreason, banjob, null, banckey, banip, bancid )

	else if(href_list["editrights"])
		if(!check_rights(R_PERMISSIONS))
			message_staff("[key_name_admin(usr)] attempted to edit the admin permissions without sufficient rights.")
			log_admin("[key_name(usr)] attempted to edit the admin permissions without sufficient rights.")
			return

		var/adm_ckey

		var/task = href_list["editrights"]
		if(task == "add")
			var/new_ckey = ckey(input(usr,"New admin's ckey","Admin ckey", null) as text|null)
			if(!new_ckey)	return
			if(new_ckey in GLOB.admin_datums)
				to_chat(usr, FONT_COLORED("red","Error: Topic 'editrights': [new_ckey] is already an admin"))
				return
			adm_ckey = new_ckey
			task = "rank"
		else if(task != "show")
			adm_ckey = ckey(href_list["ckey"])
			if(!adm_ckey)
				to_chat(usr, FONT_COLORED("red","Error: Topic 'editrights': No valid ckey"))
				return

		var/datum/admins/D = GLOB.admin_datums[adm_ckey]

		if(task == "remove")
			if(alert("Are you sure you want to remove [adm_ckey]?","Message","Yes","Cancel") == "Yes")
				if(!D)	return
				GLOB.admin_datums -= adm_ckey
				D.disassociate()

				message_staff("[key_name_admin(usr)] removed [adm_ckey] from the admins list")
				log_admin("[key_name(usr)] removed [adm_ckey] from the admins list")
				log_admin_rank_modification(adm_ckey, "Removed")

		else if(task == "rank")
			var/new_rank
			if(admin_ranks.len)
				new_rank = input("Please select a rank", "New rank", null, null) as null|anything in (admin_ranks|"*New Rank*")
			else
				new_rank = input("Please select a rank", "New rank", null, null) as null|anything in list("Game Master","Game Admin", "Trial Admin", "Admin Observer","*New Rank*")

			var/rights = 0
			if(D)
				rights = D.rights
			switch(new_rank)
				if(null,"") return
				if("*New Rank*")
					new_rank = input("Please input a new rank", "New custom rank", null, null) as null|text
					if(config.admin_legacy_system)
						new_rank = ckeyEx(new_rank)
					if(!new_rank)
						to_chat(usr, FONT_COLORED("red","Error: Topic 'editrights': Invalid rank"))
						return
					if(config.admin_legacy_system)
						if(admin_ranks.len)
							if(new_rank in admin_ranks)
								rights = admin_ranks[new_rank]		//we typed a rank which already exists, use its rights
							else
								admin_ranks[new_rank] = 0			//add the new rank to admin_ranks
				else
					if(config.admin_legacy_system)
						new_rank = ckeyEx(new_rank)
						rights = admin_ranks[new_rank]				//we input an existing rank, use its rights

			if(D)
				D.disassociate()								//remove adminverbs and unlink from client
				D.rank = new_rank								//update the rank
				D.rights = rights								//update the rights based on admin_ranks (default: 0)
			else
				D = new /datum/admins(new_rank, rights, adm_ckey)

			var/client/C = GLOB.ckey_directory[adm_ckey]					//find the client with the specified ckey (if they are logged in)
			D.associate(C)											//link up with the client and add verbs

			to_chat(C, "[key_name_admin(usr)] has set your admin rank to: [new_rank].")
			message_staff("[key_name_admin(usr)] edited the admin rank of [adm_ckey] to [new_rank]")
			log_admin("[key_name(usr)] edited the admin rank of [adm_ckey] to [new_rank]")
			log_admin_rank_modification(adm_ckey, new_rank)

		else if(task == "permissions")
			if(!D)	return
			var/list/permissionlist = list()
			for(var/i=1, i<=R_MAXPERMISSION, i<<=1)		//that <<= is shorthand for i = i << 1. Which is a left bitshift
				permissionlist[rights2text(i)] = i
			var/new_permission = input("Select a permission to turn on/off", "Permission toggle", null, null) as null|anything in permissionlist
			if(!new_permission)	return
			D.rights ^= permissionlist[new_permission]

			var/client/C = GLOB.ckey_directory[adm_ckey]
			to_chat(C, "[key_name_admin(usr)] has toggled your permission: [new_permission].")
			message_staff("[key_name_admin(usr)] toggled the [new_permission] permission of [adm_ckey]")
			log_admin("[key_name(usr)] toggled the [new_permission] permission of [adm_ckey]")
			log_admin_permission_modification(adm_ckey, permissionlist[new_permission])

		edit_admin_permissions()

	else if(href_list["call_shuttle"])

		if(!check_rights(R_ADMIN))	return

		if(!SSticker.mode || !evacuation_controller)
			return

		if(SSticker.mode.name == "blob")
			alert("You can't call the shuttle during blob!")
			return

		switch(href_list["call_shuttle"])
			if("1")
				if (evacuation_controller.call_evacuation(usr, TRUE))
					log_and_message_staff("called an evacuation.")
			if("2")
				if (evacuation_controller.cancel_evacuation())
					log_and_message_staff("cancelled an evacuation.")

		href_list["secretsadmin"] = "check_antagonist"

	else if(href_list["delay_round_end"])
		if(!check_rights(R_SERVER))	return

		SSticker.delay_end = !SSticker.delay_end
		log_and_message_staff("[SSticker.delay_end ? "delayed the round end" : "has made the round end normally"].")
		href_list["secretsadmin"] = "check_antagonist"

	else if(href_list["simplemake"])

		if(!check_rights(R_SPAWN))	return

		var/mob/M = locate(href_list["mob"])
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		var/delmob = 0
		switch(alert("Delete old mob?","Message","Yes","No","Cancel"))
			if("Cancel")	return
			if("Yes")		delmob = 1

		log_and_message_staff("has used rudimentary transformation on [key_name_admin(M)]. Transforming to [href_list["simplemake"]]; deletemob=[delmob]")

		switch(href_list["simplemake"])
			if("observer")			M.change_mob_type( /mob/observer/ghost , null, null, delmob )
			if("nymph")				M.change_mob_type( /mob/living/carbon/alien/diona , null, null, delmob )
			if("human")				M.change_mob_type( /mob/living/carbon/human , null, null, delmob, href_list["species"])
			if("slime")				M.change_mob_type( /mob/living/carbon/slime , null, null, delmob )
			if("monkey")			M.change_mob_type( /mob/living/carbon/human/monkey , null, null, delmob )
			if("robot")				M.change_mob_type( /mob/living/silicon/robot , null, null, delmob )
			if("cat")				M.change_mob_type( /mob/living/simple_animal/friendly/cat , null, null, delmob )
			if("runtime")			M.change_mob_type( /mob/living/simple_animal/friendly/cat/fluff/Runtime , null, null, delmob )
			if("corgi")				M.change_mob_type( /mob/living/simple_animal/friendly/corgi , null, null, delmob )
			if("ian")				M.change_mob_type( /mob/living/simple_animal/friendly/corgi/Ian , null, null, delmob )
			if("crab")				M.change_mob_type( /mob/living/simple_animal/crab , null, null, delmob )
			if("coffee")			M.change_mob_type( /mob/living/simple_animal/crab/Coffee , null, null, delmob )
			if("parrot")			M.change_mob_type( /mob/living/simple_animal/hostile/retaliate/parrot , null, null, delmob )
			if("polyparrot")		M.change_mob_type( /mob/living/simple_animal/hostile/retaliate/parrot/Poly , null, null, delmob )
			if("constructarmoured")	M.change_mob_type( /mob/living/simple_animal/construct/armoured , null, null, delmob )
			if("constructbuilder")	M.change_mob_type( /mob/living/simple_animal/construct/builder , null, null, delmob )
			if("constructwraith")	M.change_mob_type( /mob/living/simple_animal/construct/wraith , null, null, delmob )
			if("shade")				M.change_mob_type( /mob/living/simple_animal/shade , null, null, delmob )


	/////////////////////////////////////new ban stuff
	else if(href_list["unbanf"])
		if(!check_rights(R_BAN))	return

		var/banfolder = href_list["unbanf"]
		Banlist.cd = "/base/[banfolder]"
		var/key = Banlist["key"]
		if(alert(usr, "Are you sure you want to unban [key]?", "Confirmation", "Yes", "No") == "Yes")
			if(RemoveBan(banfolder))
				unbanpanel()
			else
				alert(usr, "This ban has already been lifted / does not exist.", "Error", "Ok")
				unbanpanel()

	else if(href_list["warn"])
		usr.client.warn(href_list["warn"])

	else if(href_list["unbane"])
		if(!check_rights(R_BAN))	return

		UpdateTime()
		var/reason

		var/banfolder = href_list["unbane"]
		Banlist.cd = "/base/[banfolder]"
		var/reason2 = Banlist["reason"]
		var/temp = Banlist["temp"]

		var/minutes = Banlist["minutes"]

		var/banned_key = Banlist["key"]
		Banlist.cd = "/base"

		var/duration

		switch(alert("Temporary Ban?",,"Yes","No"))
			if("Yes")
				temp = 1
				var/mins = 0
				if(minutes > CMinutes)
					mins = minutes - CMinutes
				mins = input(usr,"How long (in minutes)? (Default: 1440)","Ban time",mins ? mins : 1440) as num|null
				if(!mins)	return
				mins = min(525599,mins)
				minutes = CMinutes + mins
				duration = GetExp(minutes)
				reason = sanitize(input(usr,"Reason?","reason",reason2) as text|null)
				if(!reason)	return
			if("No")
				temp = 0
				duration = "Perma"
				reason = sanitize(input(usr,"Reason?","reason",reason2) as text|null)
				if(!reason)	return

		ban_unban_log_save("[key_name(usr)] edited [banned_key]'s ban. Reason: [reason] Duration: [duration]")
		log_and_message_staff("edited [banned_key]'s ban. Reason: [reason] Duration: [duration]")
		Banlist.cd = "/base/[banfolder]"
		to_save(Banlist["reason"], reason)
		to_save(Banlist["temp"], temp)
		to_save(Banlist["minutes"], minutes)
		to_save(Banlist["bannedby"], usr.ckey)
		Banlist.cd = "/base"
		SSstatistics.add_field("ban_edit",1)
		unbanpanel()

	//JOBBAN'S INNARDS
	else if(href_list["jobban1"])
		if(!check_rights(R_BAN,0))
			to_chat(usr, SPAN_WARNING("You do not have the appropriate permissions to add job bans!"))
			return

		var/mob/M = locate(href_list["jobban2"])
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		if(M != usr)																//we can jobban ourselves
			if(M.client && M.client.holder && (M.client.holder.rights & R_BAN))		//they can ban too. So we can't ban them
				alert("You cannot perform this action. You must be of a higher administrative rank!")
				return

		//get jobs for department if specified, otherwise just returnt he one job in a list.
		var/list/job_list = list()
		switch(href_list["jobban1"])
			if("commanddept")
				for(var/jobPos in SSjobs.distinct_titles_by_department(COM))
					if(!jobPos)	continue
					var/datum/job/temp = SSjobs.get_by_title(jobPos)
					if(!temp) continue
					job_list += temp.title
			if("supportdept")
				for(var/jobPos in SSjobs.distinct_titles_by_department(SPT))
					if(!jobPos)	continue
					var/datum/job/temp = SSjobs.get_by_title(jobPos)
					if(!temp) continue
					job_list += temp.title
			if("securitydept")
				for(var/jobPos in SSjobs.distinct_titles_by_department(SEC))
					if(!jobPos)	continue
					var/datum/job/temp = SSjobs.get_by_title(jobPos)
					if(!temp) continue
					job_list += temp.title
			if("engineeringdept")
				for(var/jobPos in SSjobs.distinct_titles_by_department(ENG))
					if(!jobPos)	continue
					var/datum/job/temp = SSjobs.get_by_title(jobPos)
					if(!temp) continue
					job_list += temp.title
			if("medicaldept")
				for(var/jobPos in SSjobs.distinct_titles_by_department(MED))
					if(!jobPos)	continue
					var/datum/job/temp = SSjobs.get_by_title(jobPos)
					if(!temp) continue
					job_list += temp.title
			if("sciencedept")
				for(var/jobPos in SSjobs.distinct_titles_by_department(SCI))
					if(!jobPos)	continue
					var/datum/job/temp = SSjobs.get_by_title(jobPos)
					if(!temp) continue
					job_list += temp.title
			if("explorationdept")
				for(var/jobPos in SSjobs.distinct_titles_by_department(EXP))
					if(!jobPos)	continue
					var/datum/job/temp = SSjobs.get_by_title(jobPos)
					if(!temp) continue
					job_list += temp.title
			if("servicedept")
				for(var/jobPos in SSjobs.distinct_titles_by_department(SRV))
					if(!jobPos)	continue
					var/datum/job/temp = SSjobs.get_by_title(jobPos)
					if(!temp) continue
					job_list += temp.title
			if("supplydept")
				for(var/jobPos in SSjobs.distinct_titles_by_department(SUP))
					if(!jobPos)	continue
					var/datum/job/temp = SSjobs.get_by_title(jobPos)
					if(!temp) continue
					job_list += temp.title
			if("civiliandept")
				for(var/jobPos in SSjobs.distinct_titles_by_department(CIV))
					if(!jobPos)	continue
					var/datum/job/temp = SSjobs.get_by_title(jobPos)
					if(!temp) continue
					job_list += temp.title
			if("nonhumandept")
				job_list += "pAI"
				for(var/jobPos in SSjobs.distinct_titles_by_department(MSC))
					if(!jobPos)	continue
					var/datum/job/temp = SSjobs.get_by_title(jobPos)
					if(!temp) continue
					job_list += temp.title
			if("Syndicate")
				var/list/all_antag_types = GLOB.all_antag_types_
				for(var/antagPos in all_antag_types)
					if(!antagPos) continue
					var/datum/antagonist/temp = all_antag_types[antagPos]
					if(!temp) continue
					job_list += temp.id
			else
				job_list += href_list["jobban1"]

		//Create a list of unbanned jobs within job_list
		var/list/notbannedlist = list()
		for(var/job in job_list)
			if(!jobban_isbanned(M, job))
				notbannedlist += job

		//Banning comes first
		if(notbannedlist.len) //at least 1 unbanned job exists in job_list so we have stuff to ban.
			switch(alert("Temporary Ban?",,"Yes","No", "Cancel"))
				if("Yes")
					if(!check_rights(R_BAN, 0))
						to_chat(usr, SPAN_WARNING(" You cannot issue temporary job-bans!"))
						return
					if(config.ban_legacy_system)
						to_chat(usr, SPAN_WARNING("Your server is using the legacy banning system, which does not support temporary job bans. Consider upgrading. Aborting ban."))
						return
					var/mins = input(usr,"How long (in minutes)?","Ban time",1440) as num|null
					if(!mins)
						return
					var/reason = sanitize(input(usr,"Reason?","Please State Reason","") as text|null)
					if(!reason)
						return

					var/msg
					var/mins_readable = minutes_to_readable(mins)
					for(var/job in notbannedlist)
						ban_unban_log_save("[key_name(usr)] temp-jobbanned [key_name(M)] from [job] for [mins_readable]. reason: [reason]")
						log_admin("[key_name(usr)] temp-jobbanned [key_name(M)] from [job] for [mins_readable]")
						SSstatistics.add_field("ban_job_tmp",1)
						DB_ban_record(BANTYPE_JOB_TEMP, M, mins, reason, job)
						SSstatistics.add_field_details("ban_job_tmp","- [job]")
						jobban_fullban(M, job, "[reason]; By [usr.ckey] on [time2text(world.realtime)]") //Legacy banning does not support temporary jobbans.
						if(!msg)
							msg = job
						else
							msg += ", [job]"
					notes_add(LAST_CKEY(M), "Banned  from [msg] - [reason]", usr)
					message_staff("[key_name_admin(usr)] banned [key_name_admin(M)] from [msg] for [mins_readable]", 1)
					to_chat(M, SPAN_DANGER("You have been jobbanned by [usr.client.ckey] from: [msg]."))
					to_chat(M, SPAN_WARNING("The reason is: [reason]"))
					to_chat(M, SPAN_WARNING("This jobban will be lifted in [mins_readable]."))
					job_ban(M) // lets it fall through and refresh
					return 1
				if("No")
					if(!check_rights(R_BAN))  return
					var/reason = sanitize(input(usr,"Reason?","Please State Reason","") as text|null)
					if(reason)
						var/msg
						for(var/job in notbannedlist)
							ban_unban_log_save("[key_name(usr)] perma-jobbanned [key_name(M)] from [job]. reason: [reason]")
							log_admin("[key_name(usr)] perma-banned [key_name(M)] from [job]")
							SSstatistics.add_field("ban_job",1)
							DB_ban_record(BANTYPE_JOB_PERMA, M, -1, reason, job)
							SSstatistics.add_field_details("ban_job","- [job]")
							jobban_fullban(M, job, "[reason]; By [usr.ckey] on [time2text(world.realtime)]")
							if(!msg)	msg = job
							else		msg += ", [job]"
						notes_add(LAST_CKEY(M), "Banned  from [msg] - [reason]", usr)
						message_staff("[key_name_admin(usr)] banned [key_name_admin(M)] from [msg]", 1)
						to_chat(M, SPAN_DANGER("You have been jobbanned by [usr.client.ckey] from: [msg]."))
						to_chat(M, SPAN_WARNING("The reason is: [reason]"))
						to_chat(M, SPAN_WARNING("Jobban can be lifted only upon request."))
						job_ban(M) // lets it fall through and refresh
						return 1
				if("Cancel")
					return

		//Unbanning job list
		//all jobs in job list are banned already OR we didn't give a reason (implying they shouldn't be banned)
		if(LAZYLEN(SSjobs.titles_to_datums)) //at least 1 banned job exists in job list so we have stuff to unban.
			if(!config.ban_legacy_system)
				to_chat(usr, "Unfortunately, database based unbanning cannot be done through this panel")
				DB_ban_panel(M.ckey)
				return
			var/msg
			for(var/job in SSjobs.titles_to_datums)
				var/reason = jobban_isbanned(M, job)
				if(!reason) continue //skip if it isn't jobbanned anyway
				switch(alert("Job: '[job]' Reason: '[reason]' Un-jobban?","Please Confirm","Yes","No"))
					if("Yes")
						ban_unban_log_save("[key_name(usr)] unjobbanned [key_name(M)] from [job]")
						log_admin("[key_name(usr)] unbanned [key_name(M)] from [job]")
						DB_ban_unban(M.ckey, BANTYPE_JOB_PERMA, job)
						SSstatistics.add_field("ban_job_unban",1)
						SSstatistics.add_field_details("ban_job_unban","- [job]")
						jobban_unban(M, job)
						if(!msg)	msg = job
						else		msg += ", [job]"
					else
						continue
			if(msg)
				message_staff("[key_name_admin(usr)] unbanned [key_name_admin(M)] from [msg]", 1)
				to_chat(M, SPAN_DANGER("You have been un-jobbanned by [usr.client.ckey] from [msg]."))
				job_ban(M) // lets it fall through and refresh
			return 1
		return 0 //we didn't do anything!

	else if(href_list["boot2"])
		if(!check_rights(R_ADMIN|R_MOD))
			return
		var/mob/M = locate(href_list["boot2"])
		if (ismob(M))
			if(!check_if_greater_rights_than(M.client))
				return
			var/reason = sanitize(input("Please enter reason"))
			if(!reason)
				to_chat(M, SPAN_WARNING("You have been kicked from the server"))
			else
				to_chat(M, SPAN_WARNING("You have been kicked from the server: [reason]"))
			log_and_message_staff("booted [key_name_admin(M)].")
			//M.client = null
			qdel(M.client)

	else if(href_list["removejobban"])
		if(!check_rights(R_BAN))	return

		var/t = href_list["removejobban"]
		if(t)
			if((alert("Do you want to unjobban [t]?","Unjobban confirmation", "Yes", "No") == "Yes") && t) //No more misclicks! Unless you do it twice.
				log_and_message_staff("[key_name_admin(usr)] removed [t]")
				jobban_remove(t)
				href_list["ban"] = 1 // lets it fall through and refresh
				var/t_split = splittext(t, " - ")
				var/key = t_split[1]
				var/job = t_split[2]
				DB_ban_unban(ckey(key), BANTYPE_JOB_PERMA, job)

	else if(href_list["newban"])
		if(!check_rights(R_BAN, 0))
			to_chat(usr, SPAN_WARNING("You do not have the appropriate permissions to add bans!"))
			return

		var/mob/M = locate(href_list["newban"])
		if(!ismob(M)) return

		if(M.client && M.client.holder)	return	//admins cannot be banned. Even if they could, the ban doesn't affect them anyway

		var/given_key = href_list["last_key"]
		if(!given_key)
			to_chat(usr, SPAN_DANGER("This mob has no known last occupant and cannot be banned."))
			return

		switch(alert("Temporary Ban?",,"Yes","No", "Cancel"))
			if("Yes")
				var/mins = input(usr,"How long (in minutes)?","Ban time",1440) as num|null
				if(!mins)
					return
				if(mins >= 525600) mins = 525599
				var/reason = sanitize(input(usr,"Reason?","reason","Griefer") as text|null)
				if(!reason)
					return
				var/mob_key = LAST_CKEY(M)
				if(mob_key != given_key)
					to_chat(usr, SPAN_DANGER("This mob's occupant has changed from [given_key] to [mob_key]. Please try again."))
					show_player_panel(M)
					return
				AddBan(mob_key, M.computer_id, reason, usr.ckey, 1, mins)
				var/mins_readable = minutes_to_readable(mins)
				ban_unban_log_save("[usr.client.ckey] has banned [mob_key]. - Reason: [reason] - This will be removed in [mins_readable].")
				notes_add(mob_key,"[usr.client.ckey] has banned [mob_key]. - Reason: [reason] - This will be removed in [mins_readable].",usr)
				to_chat(M, SPAN_DANGER("You have been banned by [usr.client.ckey].\nReason: [reason]."))
				to_chat(M, SPAN_WARNING("This is a temporary ban, it will be removed in [mins_readable]."))
				SSstatistics.add_field("ban_tmp",1)
				DB_ban_record(BANTYPE_TEMP, M, mins, reason)
				SSstatistics.add_field("ban_tmp_mins",mins)
				if(config.banappeals)
					to_chat(M, SPAN_WARNING("To try to resolve this matter head to [config.banappeals]"))
				else
					to_chat(M, SPAN_WARNING("No ban appeals URL has been set."))
				log_and_message_staff("has banned [mob_key].\nReason: [reason]\nThis will be removed in [mins_readable].")

				qdel(M.client)
				//qdel(M)	// See no reason why to delete mob. Important stuff can be lost. And ban can be lifted before round ends.
			if("No")
				if(!check_rights(R_BAN))   return
				var/reason = sanitize(input(usr,"Reason?","reason","Griefer") as text|null)
				if(!reason)
					return
				var/mob_key = LAST_CKEY(M)
				if(mob_key != given_key)
					to_chat(usr, SPAN_DANGER("This mob's occupant has changed from [given_key] to [mob_key]. Please try again."))
					show_player_panel(M)
					return
				switch(alert(usr,"IP ban?",,"Yes","No","Cancel"))
					if("Cancel")	return
					if("Yes")
						AddBan(mob_key, M.computer_id, reason, usr.ckey, 0, 0, M.lastKnownIP)
					if("No")
						AddBan(mob_key, M.computer_id, reason, usr.ckey, 0, 0)
				to_chat(M, SPAN_DANGER("You have been banned by [usr.client.ckey].\nReason: [reason]."))
				to_chat(M, SPAN_WARNING("This is a ban until appeal."))
				if(config.banappeals)
					to_chat(M, SPAN_WARNING("To try to resolve this matter head to [config.banappeals]"))
				else
					to_chat(M, SPAN_WARNING("No ban appeals URL has been set."))
				ban_unban_log_save("[usr.client.ckey] has permabanned [mob_key]. - Reason: [reason] - This is a ban until appeal.")
				notes_add(mob_key,"[usr.client.ckey] has permabanned [mob_key]. - Reason: [reason] - This is a ban until appeal.",usr)
				log_and_message_staff("has banned [mob_key].\nReason: [reason]\nThis is a ban until appeal.")
				SSstatistics.add_field("ban_perma",1)
				DB_ban_record(BANTYPE_PERMA, M, -1, reason)

				qdel(M.client)
				//qdel(M)
			if("Cancel")
				return

	else if(href_list["mute"])
		if(!check_rights(R_MOD,0) && !check_rights(R_ADMIN))  return

		var/mob/M = locate(href_list["mute"])
		if(!ismob(M))	return
		if(!M.client)	return

		var/mute_type = href_list["mute_type"]
		if(istext(mute_type))	mute_type = text2num(mute_type)
		if(!isnum(mute_type))	return

		cmd_admin_mute(M, mute_type)

	else if(href_list["c_mode"])
		if(!check_rights(R_ADMIN))	return

		if(SSticker.mode)
			return alert(usr, "The game has already started.", null, null, null, null)
		var/dat = {"<B>What mode do you wish to play?</B><HR>"}
		for(var/mode in config.modes)
			dat += {"<A href='byond://?src=\ref[src];c_mode2=[mode]'>[config.mode_names[mode]]</A><br>"}
		dat += {"<A href='byond://?src=\ref[src];c_mode2=secret'>Secret</A><br>"}
		dat += {"Now: [SSticker.master_mode]"}
		show_browser(usr, dat, "window=c_mode")

	else if(href_list["f_secret"])
		if(!check_rights(R_ADMIN))	return

		if(SSticker.mode)
			return alert(usr, "The game has already started.", null, null, null, null)
		if(SSticker.master_mode != "secret")
			return alert(usr, "The game mode has to be secret!", null, null, null, null)
		var/dat = {"<B>What game mode do you want to force secret to be? Use this if you want to change the game mode, but want the players to believe it's secret. This will only work if the current game mode is secret.</B><HR>"}
		for(var/mode in config.modes)
			dat += {"<A href='byond://?src=\ref[src];f_secret2=[mode]'>[config.mode_names[mode]]</A><br>"}
		dat += {"<A href='byond://?src=\ref[src];f_secret2=secret'>Random (default)</A><br>"}
		dat += {"Now: [SSticker.secret_force_mode]"}
		show_browser(usr, dat, "window=f_secret")

	else if(href_list["c_mode2"])
		if(!check_rights(R_ADMIN|R_SERVER))	return

		if (SSticker.mode)
			return alert(usr, "The game has already started.", null, null, null, null)
		SSticker.master_mode = href_list["c_mode2"]
		SSticker.bypass_gamemode_vote = 1
		log_and_message_staff("set the mode as [SSticker.master_mode].")
		to_world(SPAN_NOTICE("<b>The mode is now: [SSticker.master_mode]</b>"))
		Game() // updates the main game menu
		world.save_mode(SSticker.master_mode)
		.(href, list("c_mode"=1))

	else if(href_list["f_secret2"])
		if(!check_rights(R_ADMIN|R_SERVER))	return

		if(SSticker.mode)
			return alert(usr, "The game has already started.", null, null, null, null)
		if(SSticker.master_mode != "secret")
			return alert(usr, "The game mode has to be secret!", null, null, null, null)
		SSticker.secret_force_mode = href_list["f_secret2"]
		log_and_message_staff("set the forced secret mode as [SSticker.secret_force_mode].")
		Game() // updates the main game menu
		.(href, list("f_secret"=1))

	else if(href_list["monkeyone"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["monkeyone"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		log_and_message_staff("attempting to monkeyize [key_name_admin(H)]")
		H.monkeyize()

	else if(href_list["corgione"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["corgione"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		log_and_message_staff("attempting to corgize [key_name_admin(H)]")
		H.corgize()

	else if(href_list["forcespeech"])
		if(!check_rights(R_FUN))	return

		var/mob/M = locate(href_list["forcespeech"])
		if(!ismob(M))
			to_chat(usr, "this can only be used on instances of type /mob")

		var/speech = input("What will [key_name(M)] say?.", "Force speech", "")// Don't need to sanitize, since it does that in say(), we also trust our admins.
		if(!speech)	return
		M.say(speech)
		speech = sanitize(speech) // Nah, we don't trust them
		log_and_message_staff("forced [key_name_admin(M)] to say: [speech]")

	else if (href_list["reloadsave"])
		if(!check_rights(R_DEBUG))	return
		var/mob/M = locate(href_list["reloadsave"])
		if (!ismob(M))
			return
		if (!M.client)
			return
		var/client/C = M.client
		to_chat(usr, SPAN_NOTICE("Attempting to reload save for [C.key] <A href='byond://?src=\ref[src];reloadsaveshow=\ref[C.prefs]'>View Prefs Datum</A>"))
		C.prefs.setup()

	else if (href_list["reloadsaveshow"])
		if(!check_rights(R_DEBUG))	return
		var/datum/preferences/prefs = locate(href_list["reloadsaveshow"])
		if (prefs)
			usr.client.debug_variables(prefs)

	else if (href_list["reloadchar"])
		if (!check_rights(R_DEBUG))
			return
		var/mob/living/carbon/human/H = locate(href_list["reloadchar"])
		if (!istype(H))
			to_chat(usr, SPAN_WARNING("\The [H] is not a valid type to apply preferences to."))
			return
		var/datum/preferences/P = H.client?.prefs
		if (!istype(P))
			to_chat(usr, SPAN_WARNING("\The [H] has no client to apply preferences from."))
			return
		var/confirm = alert(usr, "This will erase the state of \the [H]!", "Reload Character", "Okay", "Cancel")
		if (confirm != "Okay")
			return
		if (QDELETED(P) || QDELETED(H))
			to_chat(usr, SPAN_WARNING("\The [H] or its preferences are no longer valid."))
			return
		P.copy_to(H)

	else if(href_list["sendtoprison"])
		if(!check_rights(R_ADMIN))	return

		if(alert(usr, "Send to admin prison for the round?", "Message", "Yes", "No") != "Yes")
			return

		var/mob/M = locate(href_list["sendtoprison"])
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return
		if(istype(M, /mob/living/silicon/ai))
			to_chat(usr, "This cannot be used on instances of type /mob/living/silicon/ai")
			return

		var/turf/prison_cell = pick(GLOB.prisonwarp)
		if(!prison_cell)	return

		var/obj/structure/closet/secure_closet/brig/locker = new /obj/structure/closet/secure_closet/brig(prison_cell)
		locker.opened = 0
		locker.locked = 1

		//strip their stuff and stick it in the crate
		for(var/obj/item/I in M)
			M.drop_from_inventory(I, locker)
		M.update_icons()

		//so they black out before warping
		M.Paralyse(5)
		sleep(5)
		if(!M)	return

		M.forceMove(prison_cell)
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/prisoner = M
			prisoner.equip_to_slot_or_del(new /obj/item/clothing/under/color/orange(prisoner), slot_w_uniform)
			prisoner.equip_to_slot_or_del(new /obj/item/clothing/shoes/orange(prisoner), slot_shoes)

		to_chat(M, SPAN_WARNING("You have been sent to the prison station!"))
		log_and_message_staff("sent [key_name_admin(M)] to the prison station.")

	else if(href_list["tdome1"])
		if(!check_rights(R_FUN))	return

		if(alert(usr, "Confirm?", "Message", "Yes", "No") != "Yes")
			return

		var/mob/M = locate(href_list["tdome1"])
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return
		if(istype(M, /mob/living/silicon/ai))
			to_chat(usr, "This cannot be used on instances of type /mob/living/silicon/ai")
			return

		for(var/obj/item/I in M)
			M.drop_from_inventory(I)

		M.Paralyse(5)
		sleep(5)
		M.forceMove(pick(GLOB.tdome1))
		spawn(50)
			to_chat(M, SPAN_NOTICE("You have been sent to the Thunderdome."))
		log_admin("[key_name(usr)] has sent [key_name(M)] to the thunderdome. (Team 1)")
		message_staff("[key_name_admin(usr)] has sent [key_name_admin(M)] to the thunderdome. (Team 1)", 1)

	else if(href_list["tdome2"])
		if(!check_rights(R_FUN))	return

		if(alert(usr, "Confirm?", "Message", "Yes", "No") != "Yes")
			return

		var/mob/M = locate(href_list["tdome2"])
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return
		if(istype(M, /mob/living/silicon/ai))
			to_chat(usr, "This cannot be used on instances of type /mob/living/silicon/ai")
			return

		for(var/obj/item/I in M)
			M.drop_from_inventory(I)

		M.Paralyse(5)
		sleep(5)
		M.forceMove(pick(GLOB.tdome2))
		spawn(50)
			to_chat(M, SPAN_NOTICE("You have been sent to the Thunderdome."))
		log_admin("[key_name(usr)] has sent [key_name(M)] to the thunderdome. (Team 2)")
		message_staff("[key_name_admin(usr)] has sent [key_name_admin(M)] to the thunderdome. (Team 2)", 1)

	else if(href_list["tdomeadmin"])
		if(!check_rights(R_FUN))	return

		if(alert(usr, "Confirm?", "Message", "Yes", "No") != "Yes")
			return

		var/mob/M = locate(href_list["tdomeadmin"])
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return
		if(istype(M, /mob/living/silicon/ai))
			to_chat(usr, "This cannot be used on instances of type /mob/living/silicon/ai")
			return

		M.Paralyse(5)
		sleep(5)
		M.forceMove(pick(GLOB.tdomeadmin))
		spawn(50)
			to_chat(M, SPAN_NOTICE("You have been sent to the Thunderdome."))
		log_admin("[key_name(usr)] has sent [key_name(M)] to the thunderdome. (Admin.)")
		message_staff("[key_name_admin(usr)] has sent [key_name_admin(M)] to the thunderdome. (Admin.)", 1)

	else if(href_list["tdomeobserve"])
		if(!check_rights(R_FUN))	return

		if(alert(usr, "Confirm?", "Message", "Yes", "No") != "Yes")
			return

		var/mob/M = locate(href_list["tdomeobserve"])
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return
		if(istype(M, /mob/living/silicon/ai))
			to_chat(usr, "This cannot be used on instances of type /mob/living/silicon/ai")
			return

		for(var/obj/item/I in M)
			M.drop_from_inventory(I)

		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/observer = M
			observer.equip_to_slot_or_del(new /obj/item/clothing/under/suit_jacket(observer), slot_w_uniform)
			observer.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(observer), slot_shoes)
		M.Paralyse(5)
		sleep(5)
		M.forceMove(pick(GLOB.tdomeobserve))
		spawn(50)
			to_chat(M, SPAN_NOTICE("You have been sent to the Thunderdome."))
		log_admin("[key_name(usr)] has sent [key_name(M)] to the thunderdome. (Observer.)")
		message_staff("[key_name_admin(usr)] has sent [key_name_admin(M)] to the thunderdome. (Observer.)", 1)

	else if(href_list["revive"])
		if(!check_rights(R_REJUVINATE))	return

		var/mob/living/L = locate(href_list["revive"])
		if(!istype(L))
			to_chat(usr, "This can only be used on instances of type /mob/living")
			return

		if(config.allow_admin_rev)
			L.revive()
			log_and_message_staff("healed / Revived [key_name(L)]")
		else
			to_chat(usr, "Admin Rejuvinates have been disabled")

	else if(href_list["makeai"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["makeai"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		log_and_message_staff("AIized [key_name_admin(H)]!")
		H.AIize()

	else if(href_list["makeslime"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["makeslime"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		usr.client.cmd_admin_slimeize(H)

	else if(href_list["makerobot"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["makerobot"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		usr.client.cmd_admin_robotize(H)

	else if(href_list["makeanimal"])
		if(!check_rights(R_SPAWN))	return

		var/mob/M = locate(href_list["makeanimal"])
		if(istype(M, /mob/new_player))
			to_chat(usr, "This cannot be used on instances of type /mob/new_player")
			return

		usr.client.cmd_admin_animalize(M)

	else if(href_list["makezombie"])
		if(!check_rights(R_ADMIN))	return

		var/mob/living/carbon/human/H = locate(href_list["makezombie"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")

		log_and_message_staff("attempting to zombify [key_name_admin(H)]")
		H.zombify()

	else if(href_list["togmutate"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["togmutate"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return
		var/block=text2num(href_list["block"])
		//testing("togmutate([href_list["block"]] -> [block])")
		usr.client.cmd_admin_toggle_block(H,block)
		show_player_panel(H)
		//H.regenerate_icons()

	else if(href_list["adminplayeropts"])
		var/mob/M = locate(href_list["adminplayeropts"])
		show_player_panel(M)

	else if(href_list["adminplayerobservejump"])
		if(!check_rights(R_MOD|R_ADMIN))	return

		var/mob/M = locate(href_list["adminplayerobservejump"])
		var/client/C = usr.client
		if(!M)
			to_chat(C, SPAN_WARNING("Unable to locate mob."))
			return

		if(!isghost(usr))	C.admin_ghost()
		sleep(2)
		C.jumptomob(M)

	else if(href_list["adminplayerobservefollow"])
		if(!check_rights(R_MOD|R_ADMIN))
			return

		var/mob/M = locate(href_list["adminplayerobservefollow"])
		var/client/C = usr.client
		if(!M)
			to_chat(C, SPAN_WARNING("Unable to locate mob."))
			return

		if(!isobserver(usr))	C.admin_ghost()
		var/mob/observer/ghost/G = C.mob
		if(istype(G))
			sleep(2)
			G.start_following(M)

	else if(href_list["check_antagonist"])
		check_antagonists()

	// call dibs on IC messages (prays, emergency comms, faxes)
	else if(href_list["take_ic"])

		var/mob/M = locate(href_list["take_question"])
		if(ismob(M))
			var/take_msg = SPAN_NOTICE("<b>[key_name(usr.client)]</b> is attending to <b>[key_name(M)]'s</b> message.")
			for(var/client/X in GLOB.admins)
				if((R_ADMIN|R_MOD) & X.holder.rights)
					to_chat(X, take_msg)
			to_chat(M, SPAN_NOTICE("<b>Your message is being attended to by [usr.client]. Thanks for your patience!</b>"))
		else
			to_chat(usr, SPAN_WARNING("Unable to locate mob."))

	else if(href_list["take_ticket"])
		var/datum/ticket/ticket = locate(href_list["take_ticket"])

		if(isnull(ticket))
			return

		ticket.take(client_repository.get_lite_client(usr.client))

	else if(href_list["autoresponse"])

		var/mob/ref_person = locate(href_list["autoresponse"])
		if(!ref_person || !istype(ref_person) || !ref_person.client)
			to_chat(usr, "\blue Looks like that person stopped existing!")
			return
		var/client/ref_client = ref_person.client

		var/datum/ticket/ticket = get_open_ticket_by_client(ref_client)
		if(ticket && ticket.assigned_admins.len)
			to_chat(usr, "<b>This adminhelp is already being handled, but continue if you wish.</b>")
			if(alert(usr, "Are you sure you want to autoreply to this marked adminhelp?", "Confirmation", "Yes", "No") == "No")
				return
		else if (!ticket)
			to_chat(usr, "<b>This ticket no longer exists.</b>")
			return
		ticket.take(client_repository.get_lite_client(usr.client))

		var/list/choicelist = list("--CANCEL--",
									"IC Issue",
									"Being Handled",
									"Fixed","Thanks!",
									"L: GitHub Issue",
									"A: Requesting to be an SCP",
									"A: Becoming an SCP",
									"L: RUST Engine",
									"A: D-Class Riot",
									"A: D-Class Cells",
									"A: Directions/Lost",
									"A: Character setup",
									"L: Website and Discord information")

		var/choice = input("Which autoresponse option do you want to send to the player?\n\n L - A webpage link.\n A - An answer to a common question.", "Autoresponse", "--CANCEL--") in choicelist

		var/msgplayer
		switch(choice)
			if("IC Issue")
				msgplayer = TICKET_AUTORESPONSE_IC_ISSUE
			if("Being Handled")
				msgplayer = TICKET_AUTORESPONSE_BEING_HANDLED
			if("Fixed")
				msgplayer = TICKET_AUTORESPONSE_FIXED
			if("Thanks!")
				msgplayer = TICKET_AUTORESPONSE_THANKS
			if("A: Requesting to be an SCP")
				msgplayer = TICKET_AUTORESPONSE_REQUESTING_TO_BE_SCP
			if("A: Becoming an SCP")
				msgplayer = TICKET_AUTORESPONSE_BECOMING_AN_SCP
			if("L: GitHub Issue")
				msgplayer = TICKET_AUTORESPONSE_GITHUB_ISSUE
			if("L: RUST Engine")
				msgplayer = TICKET_AUTORESPONSE_RUST_ENGINE
			if("A: D-Class Riot")
				msgplayer = TICKET_AUTORESPONSE_D_CLASS_RIOT
			if("A: D-Class Cells")
				msgplayer = TICKET_AUTORESPONSE_D_CLASS_CELLS
			if("A: Directions/Lost")
				msgplayer = TICKET_AUTORESPONSE_DIRECTIONS_OR_LOST
			if("A: Character setup")
				msgplayer = TICKET_AUTORESPONSE_CHARACTER_SETUP
			if("L: Website and Discord information")
				msgplayer = TICKET_AUTORESPONSE_WEBSITE_AND_DISCORD
			else return

		var/staff_message = "[usr.key] is autoresponding to [ref_client.key] with [FONT_COLORED(COLOR_ISLAMIC_GREEN, choice)]."
		message_staff(staff_message, 1)
		ticket.msgs += new /datum/ticket_msg(usr.ckey, ref_client.ckey, staff_message)
		to_chat(ref_client, TICKET_AUTORESPONSE_DEFAULT_NOTICE_MESSAGE)
		to_chat(ref_client, msgplayer)
		if(ref_client.get_preference_value(/datum/client_preference/staff/play_adminhelp_ping) == GLOB.PREF_HEAR)
			sound_to(ref_client, 'sounds/effects/adminhelp-reply.ogg')
		ticket.close(client_repository.get_lite_client(usr.client))

	else if(href_list["adminplayerobservecoodjump"])
		if(!check_rights(R_ADMIN|R_MOD))	return

		var/x = text2num(href_list["X"])
		var/y = text2num(href_list["Y"])
		var/z = text2num(href_list["Z"])

		var/client/C = usr.client
		if(!isghost(usr))	C.admin_ghost()
		sleep(2)
		C.jumptocoord(x,y,z)

	else if(href_list["adminchecklaws"])
		output_ai_laws()

	else if(href_list["adminmoreinfo"])
		var/mob/M = locate(href_list["adminmoreinfo"])
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		var/location_description = ""
		var/special_role_description = ""
		var/health_description = ""
		var/gender_description = ""
		var/turf/T = get_turf(M)

		//Location
		if(isturf(T))
			if(isarea(T.loc))
				location_description = "([M.loc == T ? "at coordinates " : "in [M.loc] at coordinates "] [T.x], [T.y], [T.z] in area <b>[T.loc]</b>)"
			else
				location_description = "([M.loc == T ? "at coordinates " : "in [M.loc] at coordinates "] [T.x], [T.y], [T.z])"

		//Job + antagonist
		if(M.mind)
			special_role_description = "Role: <b>[M.mind.assigned_role]</b>; Antagonist: <font color='red'><b>[M.mind.special_role]</b></font>; Has been rev: [(M.mind.has_been_rev)?"Yes":"No"]"
		else
			special_role_description = "Role: <i>Mind datum missing</i> Antagonist: <i>Mind datum missing</i>; Has been rev: <i>Mind datum missing</i>;"

		//Health
		if(isliving(M))
			var/mob/living/L = M
			var/status
			switch (M.stat)
				if (0) status = "Alive"
				if (1) status = FONT_COLORED("orange","<b>Unconscious</b>")
				if (2) status = FONT_COLORED("red","<b>Dead</b>")
			health_description = "Status = [status]"
			health_description += "<BR>Oxy: [L.getOxyLoss()] - Tox: [L.getToxLoss()] - Fire: [L.getFireLoss()] - Brute: [L.getBruteLoss()] - Clone: [L.getCloneLoss()] - Brain: [L.getBrainLoss()]"
		else
			health_description = "This mob type has no health to speak of."

		//Gener
		switch(M.gender)
			if(MALE,FEMALE)	gender_description = "[M.gender]"
			else			gender_description = FONT_COLORED("red","<b>[M.gender]</b>")

		to_chat(src.owner, "<b>Info about [M.name]:</b> ")
		to_chat(src.owner, "Mob type = [M.type]; Gender = [gender_description] Damage = [health_description]")
		to_chat(src.owner, "Name = <b>[M.name]</b>; Real_name = [M.real_name]; Mind_name = [M.mind?"[M.mind.name]":""]; Key = <b>[M.key]</b>;")
		to_chat(src.owner, "Location = [location_description];")
		to_chat(src.owner, "[special_role_description]")
		to_chat(src.owner, "[ADMIN_FULLMONTY(M)]")

	else if(href_list["adminspawncookie"])
		if(!check_rights(R_ADMIN|R_FUN))
			return

		var/mob/living/carbon/human/H = locate(href_list["adminspawncookie"])
		if(!ishuman(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human.", confidential = TRUE)
			return

		H.equip_to_slot_or_del( new /obj/item/reagent_containers/food/snacks/cookie(H), slot_l_hand )
		if(!(istype(H.l_hand,/obj/item/reagent_containers/food/snacks/cookie)))
			H.equip_to_slot_or_del( new /obj/item/reagent_containers/food/snacks/cookie(H), slot_r_hand )
			if(!(istype(H.r_hand,/obj/item/reagent_containers/food/snacks/cookie)))
				log_admin("[key_name(H)] has their hands full, so they did not receive their cookie, spawned by [key_name(src.owner)].")
				message_admins("[key_name(H)] has their hands full, so they did not receive their cookie, spawned by [key_name(src.owner)].")
				return
			else
				H.update_inv_r_hand()//To ensure the icon appears in the HUD
		else
			H.update_inv_l_hand()

		log_admin("[key_name(H)] got their cookie, spawned by [key_name(src.owner)].")
		message_admins("[key_name(H)] got their cookie, spawned by [key_name(src.owner)].")
		SSstatistics.add_field("admin_cookies_spawned",1)
		to_chat(H, SPAN_NOTICE("Your prayers have been answered!! You received the <b>best cookie!</b>"))

	else if(href_list["individuallog"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["individuallog"]) in SSmobs.mob_list
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob.", confidential = TRUE)
			return

		var/datum/player_action/P = GLOB.pp_actions["check_logs"]
		if(!P)
			return

		if(!LAZYLEN(href_list["log_type"]))
			// oh god i hate this
			href_list["log_type"] = input(usr, "Choose which log to read from.") in list("say", "emote", "ooc", "dsay", "interact")

		P.act(usr.client, M, list("log_type" = href_list["log_type"]))

	else if(href_list["tag_datum"])
		if(!check_rights(R_ADMIN))
			return
		var/datum/datum_to_tag = locate(href_list["tag_datum"])
		if(!datum_to_tag || !istype(datum_to_tag))
			return

		usr.client.holder.marked_datum_weakref = weakref(datum_to_tag)

	else if(href_list["adminsmite"])
		if(!check_rights(R_ADMIN|R_FUN))
			return

		var/mob/living/carbon/human/H = locate(href_list["adminsmite"]) in GLOB.human_mob_list
		if(!H || !istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human", confidential = TRUE)
			return

		usr.client.smite(H)

	else if(href_list["CentcommReply"])
		var/mob/living/L = locate(href_list["CentcommReply"])
		if(!istype(L))
			to_chat(usr, "This can only be used on instances of type /mob/living/")
			return

		if(L.can_centcom_reply())
			var/input = sanitize(input(src.owner, "Please enter a message to reply to [key_name(L)] via their headset.","Outgoing message from Centcomm", ""))
			if(!input)		return

			to_chat(src.owner, "You sent [input] to [L] via a secure channel.")
			log_admin("[src.owner] replied to [key_name(L)]'s Centcomm message with the message [input].")
			message_staff("[src.owner] replied to [key_name(L)]'s Centcom message with: \"[input]\"")
			if(!isAI(L))
				to_chat(L, SPAN_INFO("You hear something crackle in your headset for a moment before a voice speaks."))
			to_chat(L, SPAN_INFO("Please stand by for a message from Central Command."))
			to_chat(L, SPAN_INFO("Message as follows."))
			to_chat(L, SPAN_NOTICE("[input]"))
			to_chat(L, SPAN_INFO("Message ends."))
		else
			to_chat(src.owner, "The person you are trying to contact does not have functional radio equipment.")

	else if(href_list["AdminFaxView"])
		var/obj/item/fax = locate(href_list["AdminFaxView"])
		if(!fax)
			to_chat(usr, SPAN_WARNING("The fax you're trying to view doesn't exist."))
			return
		show_fax_admin(fax)
	else if (href_list["AdminFaxViewPage"])
		var/page = text2num(href_list["AdminFaxViewPage"])
		var/obj/item/paper_bundle/bundle = locate(href_list["paper_bundle"])

		if (!bundle) return

		if (istype(bundle.pages[page], /obj/item/paper))
			var/obj/item/paper/P = bundle.pages[page]
			P.show_content(src.owner, TRUE)
		else if (istype(bundle.pages[page], /obj/item/photo))
			var/obj/item/photo/H = bundle.pages[page]
			H.show(src.owner)
		return

	else if(href_list["FaxReply"])
		var/obj/machinery/photocopier/faxmachine/fax = locate(href_list["originfax"])
		var/replyorigin = href_list["replyorigin"]


		var/obj/item/paper/admin/P = new /obj/item/paper/admin( null ) //hopefully the null loc won't cause trouble for us
		faxreply = P

		P.admindatum = src
		P.origin = replyorigin
		P.department = fax.department
		P.destinations = get_fax_machines_by_department(fax.department)
		P.adminbrowse()

	else if(href_list["jumpto"])
		if(!check_rights(R_ADMIN))	return

		var/mob/M = locate(href_list["jumpto"])
		usr.client.jumptomob(M)

	else if(href_list["getmob"])
		if(!check_rights(R_ADMIN))	return

		if(alert(usr, "Confirm?", "Message", "Yes", "No") != "Yes")	return
		var/mob/M = locate(href_list["getmob"])
		usr.client.Getmob(M)

	else if(href_list["sendmob"])
		if(!check_rights(R_ADMIN))	return

		var/mob/M = locate(href_list["sendmob"])
		usr.client.sendmob(M)

	else if(href_list["narrateto"])
		if(!check_rights(R_ADMIN|R_MOD))	return

		var/mob/M = locate(href_list["narrateto"])
		usr.client.cmd_admin_direct_narrate(M)

	else if(href_list["traitor"])
		if(!check_rights(R_ADMIN|R_MOD))	return

		if(GAME_STATE < RUNLEVEL_GAME)
			alert("The game hasn't started yet!")
			return

		var/mob/M = locate(href_list["traitor"])
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob.")
			return
		show_traitor_panel(M)

	else if(href_list["skillpanel"])
		if(!check_rights(R_ADMIN|R_MOD))
			return

		if(GAME_STATE < RUNLEVEL_GAME)
			alert("The game hasn't started yet!")
			return

		var/mob/M = locate(href_list["skillpanel"])
		show_skills(M)

	else if(href_list["create_object"])
		if(!check_rights(R_SPAWN))	return
		return create_object(usr)

	else if(href_list["create_turf"])
		if(!check_rights(R_SPAWN))	return
		return create_turf(usr)

	else if(href_list["create_mob"])
		if(!check_rights(R_SPAWN))	return
		return create_mob(usr)

	else if(href_list["object_list"])			//this is the laggiest thing ever
		if(!check_rights(R_SPAWN))	return

		if(!config.allow_admin_spawning)
			to_chat(usr, "Spawning of items is not allowed.")
			return

		var/atom/loc = usr.loc

		var/dirty_paths
		if (istext(href_list["object_list"]))
			dirty_paths = list(href_list["object_list"])
		else if (istype(href_list["object_list"], /list))
			dirty_paths = href_list["object_list"]

		var/paths = list()
		var/removed_paths = list()

		for(var/dirty_path in dirty_paths)
			var/path = text2path(dirty_path)
			if(!path)
				removed_paths += dirty_path
				continue
			else if(!ispath(path, /obj) && !ispath(path, /turf) && !ispath(path, /mob))
				removed_paths += dirty_path
				continue
			else if(ispath(path, /obj/item/gun/energy/pulse_rifle))
				if(!check_rights(R_FUN,0))
					removed_paths += dirty_path
					continue
			else if(ispath(path, /obj/item/melee/energy/blade))//Not an item one should be able to spawn./N
				if(!check_rights(R_FUN,0))
					removed_paths += dirty_path
					continue
			else if(ispath(path, /obj/effect/bhole))
				if(!check_rights(R_FUN,0))
					removed_paths += dirty_path
					continue
			paths += path

		if(!paths)
			alert("The path list you sent is empty")
			return
		if(length(paths) > 5)
			alert("Select fewer object types, (max 5)")
			return
		else if(length(removed_paths))
			alert("Removed:\n" + jointext(removed_paths, "\n"))

		var/list/offset = splittext(href_list["offset"],",")
		var/number = dd_range(1, 100, text2num(href_list["object_count"]))
		var/X = offset.len > 0 ? text2num(offset[1]) : 0
		var/Y = offset.len > 1 ? text2num(offset[2]) : 0
		var/Z = offset.len > 2 ? text2num(offset[3]) : 0
		var/tmp_dir = href_list["object_dir"]
		var/obj_dir = tmp_dir ? text2num(tmp_dir) : 2
		if(!obj_dir || !(obj_dir in list(1,2,4,8,5,6,9,10)))
			obj_dir = 2
		var/obj_name = sanitize(href_list["object_name"])
		var/where = href_list["object_where"]
		if(!(where in list("onfloor", "inhand", "inmarked")))
			where = "onfloor"

		if(where == "inhand")	//Can only give when human or monkey
			if(!(ishuman(usr) || issmall(usr)))
				to_chat(usr, "Can only spawn in hand when you're a human or a monkey.")
				where = "onfloor"

		if(where == "inmarked")
			var/marked_datum = marked_datum()
			if(!marked_datum)
				to_chat(usr, "You don't have any object marked. Abandoning spawn.")
				return
			else
				if(!istype(marked_datum, /atom))
					to_chat(usr, "The object you have marked cannot be used as a target. Target must be of type /atom. Abandoning spawn.")
					return

		var/atom/target //Where the object will be spawned
		switch(where)
			if("onfloor")
				switch (href_list["offset_type"])
					if("absolute")
						target = locate(0 + X,0 + Y,0 + Z)
					if("relative")
						target = locate(loc.x + X,loc.y + Y,loc.z + Z)
			if("inmarked")
				target = marked_datum()
			if("inhand")
				target = usr.loc

		if(target)
			for(var/path in paths)
				for(var/i = 0; i < number; i++)
					if(path in typesof(/turf))
						var/turf/O = target
						var/turf/N = O.ChangeTurf(path)
						if(N)
							if(obj_name)
								N.SetName(obj_name)
					else
						var/atom/O = new path(target)
						if(O)
							O.setDir(obj_dir)
							if(obj_name)
								O.SetName(obj_name)
								if(istype(O, /mob))
									var/mob/M = O
									M.real_name = obj_name
							if(istype(O, /obj/item) && where == "inhand")
								var/obj/item/W = O
								usr.put_in_any_hand_if_possible(W)

		log_and_message_staff("created [number] [english_list(paths)]")
		return

	else if(href_list["admin_secrets_panel"])
		var/datum/admin_secret_category/AC = locate(href_list["admin_secrets_panel"]) in admin_secrets.categories
		src.Secrets(AC)

	else if(href_list["admin_secrets"])
		var/datum/admin_secret_item/item = locate(href_list["admin_secrets"]) in admin_secrets.items
		item.execute(usr)

	else if(href_list["ac_view_wanted"])            //Admin newscaster Topic() stuff be here
		src.admincaster_screen = 18                 //The ac_ prefix before the hrefs stands for AdminCaster.
		src.access_news_network()

	else if(href_list["ac_set_channel_name"])
		src.admincaster_feed_channel.channel_name = sanitizeSafe(input(usr, "Provide a Feed Channel Name", "Network Channel Handler", ""))
		src.access_news_network()

	else if(href_list["ac_set_channel_lock"])
		src.admincaster_feed_channel.locked = !src.admincaster_feed_channel.locked
		src.access_news_network()

	else if(href_list["ac_submit_new_channel"])
		var/datum/feed_network/torch_network = news_network[1]
		var/check = 0
		for(var/datum/feed_channel/FC in torch_network.network_channels)
			if(FC.channel_name == src.admincaster_feed_channel.channel_name)
				check = 1
				break
		if(src.admincaster_feed_channel.channel_name == "" || src.admincaster_feed_channel.channel_name == "\[REDACTED\]" || check )
			src.admincaster_screen=7
		else
			var/choice = alert("Please confirm Feed channel creation","Network Channel Handler","Confirm","Cancel")
			if(choice=="Confirm")
				torch_network.CreateFeedChannel(admincaster_feed_channel.channel_name, admincaster_signature, admincaster_feed_channel.locked, 1)
				SSstatistics.add_field("newscaster_channels",1)                  //Adding channel to the global network
				log_admin("[key_name_admin(usr)] created command feed channel: [src.admincaster_feed_channel.channel_name]!")
				src.admincaster_screen=5
		src.access_news_network()

	else if(href_list["ac_set_channel_receiving"])
		var/datum/feed_network/torch_network = news_network[1]
		var/list/available_channels = list()
		for(var/datum/feed_channel/F in torch_network.network_channels)
			available_channels += F.channel_name
		src.admincaster_feed_channel.channel_name = sanitizeSafe(input(usr, "Choose receiving Feed Channel", "Network Channel Handler") in available_channels )
		src.access_news_network()

	else if(href_list["ac_set_new_message"])
		src.admincaster_feed_message.body = sanitize(input(usr, "Write your Feed story", "Network Channel Handler", ""))
		src.access_news_network()

	else if(href_list["ac_submit_new_message"])
		var/datum/feed_network/torch_network = news_network[1]
		if(src.admincaster_feed_message.body =="" || src.admincaster_feed_message.body =="\[REDACTED\]" || src.admincaster_feed_channel.channel_name == "" )
			src.admincaster_screen = 6
		else
			SSstatistics.add_field("newscaster_stories",1)
			torch_network.SubmitArticle(src.admincaster_feed_message.body, src.admincaster_signature, src.admincaster_feed_channel.channel_name, null, 1)
			src.admincaster_screen=4

		log_admin("[key_name_admin(usr)] submitted a feed story to channel: [src.admincaster_feed_channel.channel_name]!")
		src.access_news_network()

	else if(href_list["ac_create_channel"])
		src.admincaster_screen=2
		src.access_news_network()

	else if(href_list["ac_create_feed_story"])
		src.admincaster_screen=3
		src.access_news_network()

	else if(href_list["ac_menu_censor_story"])
		src.admincaster_screen=10
		src.access_news_network()

	else if(href_list["ac_menu_censor_channel"])
		src.admincaster_screen=11
		src.access_news_network()

	else if(href_list["ac_menu_wanted"])
		var/datum/feed_network/torch_network = news_network[1]
		var/already_wanted = 0
		if(torch_network.wanted_issue)
			already_wanted = 1

		if(already_wanted)
			src.admincaster_feed_message.author = torch_network.wanted_issue.author
			src.admincaster_feed_message.body = torch_network.wanted_issue.body
		src.admincaster_screen = 14
		src.access_news_network()

	else if(href_list["ac_set_wanted_name"])
		src.admincaster_feed_message.author = sanitize(input(usr, "Provide the name of the Wanted person", "Network Security Handler", ""))
		src.access_news_network()

	else if(href_list["ac_set_wanted_desc"])
		src.admincaster_feed_message.body = sanitize(input(usr, "Provide the a description of the Wanted person and any other details you deem important", "Network Security Handler", ""))
		src.access_news_network()

	else if(href_list["ac_submit_wanted"])
		var/datum/feed_network/torch_network = news_network[1]
		var/input_param = text2num(href_list["ac_submit_wanted"])
		if(src.admincaster_feed_message.author == "" || src.admincaster_feed_message.body == "")
			src.admincaster_screen = 16
		else
			var/choice = alert("Please confirm Wanted Issue [(input_param==1) ? ("creation.") : ("edit.")]","Network Security Handler","Confirm","Cancel")
			if(choice=="Confirm")

				if(input_param==1)          //If input_param == 1 we're submitting a new wanted issue. At 2 we're just editing an existing one. See the else below
					var/datum/feed_message/WANTED = new /datum/feed_message
					WANTED.author = src.admincaster_feed_message.author               //Wanted name
					WANTED.body = src.admincaster_feed_message.body                   //Wanted desc
					WANTED.backup_author = src.admincaster_signature                  //Submitted by
					WANTED.is_admin_message = 1
					torch_network.wanted_issue = WANTED
					for(var/obj/machinery/newscaster/NEWSCASTER in allCasters)
						NEWSCASTER.newsAlert()
						NEWSCASTER.update_icon()
					src.admincaster_screen = 15
				else
					torch_network.wanted_issue.author = src.admincaster_feed_message.author
					torch_network.wanted_issue.body = src.admincaster_feed_message.body
					torch_network.wanted_issue.backup_author = src.admincaster_feed_message.backup_author
					src.admincaster_screen = 19
				log_admin("[key_name_admin(usr)] issued a Wanted Notification for [src.admincaster_feed_message.author]!")
		src.access_news_network()

	else if(href_list["ac_cancel_wanted"])
		var/datum/feed_network/torch_network = news_network[1]
		var/choice = alert("Please confirm Wanted Issue removal","Network Security Handler","Confirm","Cancel")
		if(choice=="Confirm")
			torch_network.wanted_issue = null
			for(var/obj/machinery/newscaster/NEWSCASTER in allCasters)
				NEWSCASTER.update_icon()
			src.admincaster_screen=17
		src.access_news_network()

	else if(href_list["ac_censor_channel_author"])
		var/datum/feed_channel/FC = locate(href_list["ac_censor_channel_author"])
		if(FC.author != "<B>\[REDACTED\]</B>")
			FC.backup_author = FC.author
			FC.author = "<B>\[REDACTED\]</B>"
		else
			FC.author = FC.backup_author
		src.access_news_network()

	else if(href_list["ac_censor_channel_story_author"])
		var/datum/feed_message/MSG = locate(href_list["ac_censor_channel_story_author"])
		if(MSG.author != "<B>\[REDACTED\]</B>")
			MSG.backup_author = MSG.author
			MSG.author = "<B>\[REDACTED\]</B>"
		else
			MSG.author = MSG.backup_author
		src.access_news_network()

	else if(href_list["ac_censor_channel_story_body"])
		var/datum/feed_message/MSG = locate(href_list["ac_censor_channel_story_body"])
		if(MSG.body != "<B>\[REDACTED\]</B>")
			MSG.backup_body = MSG.body
			MSG.body = "<B>\[REDACTED\]</B>"
		else
			MSG.body = MSG.backup_body
		src.access_news_network()

	else if(href_list["ac_pick_d_notice"])
		var/datum/feed_channel/FC = locate(href_list["ac_pick_d_notice"])
		src.admincaster_feed_channel = FC
		src.admincaster_screen=13
		src.access_news_network()

	else if(href_list["ac_toggle_d_notice"])
		var/datum/feed_channel/FC = locate(href_list["ac_toggle_d_notice"])
		FC.censored = !FC.censored
		src.access_news_network()

	else if(href_list["ac_view"])
		src.admincaster_screen=1
		src.access_news_network()

	else if(href_list["ac_setScreen"]) //Brings us to the main menu and resets all fields~
		src.admincaster_screen = text2num(href_list["ac_setScreen"])
		if (src.admincaster_screen == 0)
			if(src.admincaster_feed_channel)
				src.admincaster_feed_channel = new /datum/feed_channel
			if(src.admincaster_feed_message)
				src.admincaster_feed_message = new /datum/feed_message
		src.access_news_network()

	else if(href_list["ac_show_channel"])
		var/datum/feed_channel/FC = locate(href_list["ac_show_channel"])
		src.admincaster_feed_channel = FC
		src.admincaster_screen = 9
		src.access_news_network()

	else if(href_list["ac_pick_censor_channel"])
		var/datum/feed_channel/FC = locate(href_list["ac_pick_censor_channel"])
		src.admincaster_feed_channel = FC
		src.admincaster_screen = 12
		src.access_news_network()

	else if(href_list["ac_refresh"])
		src.access_news_network()

	else if(href_list["ac_set_signature"])
		src.admincaster_signature = sanitize(input(usr, "Provide your desired signature", "Network Identity Handler", ""))
		src.access_news_network()

	else if(href_list["vsc"])
		if(check_rights(R_ADMIN|R_SERVER))
			if(href_list["vsc"] == "airflow")
				vsc.ChangeSettingsDialog(usr,vsc.settings)
			if(href_list["vsc"] == "phoron")
				vsc.ChangeSettingsDialog(usr,vsc.plc.settings)
			if(href_list["vsc"] == "default")
				vsc.SetDefault(usr)

	else if(href_list["paralyze"])
		var/mob/M = locate(href_list["paralyze"])
		paralyze_mob(M)

	else if(href_list["set_selfdestruct_code"])
		if(!check_rights(R_ADMIN))
			return
		var/code = "[rand(10000, 99999.0)]"
		for(var/obj/machinery/nuclearbomb/SD as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/nuclearbomb))
			SD.r_code = code
		message_admins("[key_name_admin(usr)] has set the self-destruct code to \"[code]\".")


	// player info stuff

	if(href_list["add_player_info"])
		var/key = href_list["add_player_info"]
		var/add = sanitize(input("Add Player Info") as null|text)
		if(!add) return

		notes_add(key,add,usr)
		show_player_info(key)

	if(href_list["remove_player_info"])
		var/key = href_list["remove_player_info"]
		var/index = text2num(href_list["remove_index"])

		notes_del(key, index)
		show_player_info(key)

	if(href_list["notes"])
		if(href_list["notes"] == "set_filter")
			var/choice = input(usr,"Please specify a text filter to use or cancel to clear.","Player Notes",null) as text|null
			PlayerNotesPage(choice)
		else
			var/ckey = href_list["ckey"]
			if(!ckey)
				var/mob/M = locate(href_list["mob"])
				if(ismob(M))
					ckey = LAST_CKEY(M)
			show_player_info(ckey)
		return
	if(href_list["setstaffwarn"])
		var/mob/M = locate(href_list["setstaffwarn"])
		if(!ismob(M)) return

		if(M.client && M.client.holder) return // admins don't get staffnotify'd about

		switch(alert("Really set staff warn?",,"Yes","No"))
			if("Yes")
				var/last_ckey = LAST_CKEY(M)
				var/reason = sanitize(input(usr,"Staff warn message","Staff Warn","Problem Player") as text|null)
				if (!reason || reason == "")
					return
				notes_add(last_ckey,"\[AUTO\] Staff warn enabled: [reason]",usr)
				reason += "\n-- Set by [usr.client.ckey]([usr.client.holder.rank])"
				DB_staffwarn_record(last_ckey, reason)
				if(M.client)
					M.client.staffwarn = reason
				SSstatistics.add_field("staff_warn",1)
				log_and_message_staff("has enabled staffwarn on [last_ckey].\nMessage: [reason]\n")
				show_player_panel(M)
			if("No")
				return
	if(href_list["removestaffwarn"])
		var/mob/M = locate(href_list["removestaffwarn"])
		if(!ismob(M)) return

		switch(alert("Really remove staff warn?",,"Yes","No"))
			if("Yes")
				var/last_ckey = LAST_CKEY(M)
				if(!DB_staffwarn_remove(last_ckey))
					return
				notes_add(last_ckey,"\[AUTO\] Staff warn disabled",usr)
				if(M.client)
					M.client.staffwarn = null
				log_and_message_staff("has removed the staffwarn on [last_ckey].\n")
				show_player_panel(M)
			if("No")
				return

	if(href_list["pilot"])
		var/mob/M = locate(href_list["pilot"])
		if(!ismob(M)) return

		show_player_panel(M)



	if(href_list["say"])
		var/list/dat = list()
		var/mob/M = locate(href_list["say"])


		for(var/log in M.say_log)
			dat += log
			dat += "<br>"
		var/datum/browser/popup = new(usr, "admin_log_panel_log", "Logs", 700, 700)
		popup.set_content(JOINTEXT(dat))
		popup.open()
		return

	if(href_list["ooc"])
		var/list/dat = list()
		var/mob/M = locate(href_list["ooc"])


		for(var/log in M.ooc_log)
			dat += log
			dat += "<br>"
		var/datum/browser/popup = new(usr, "admin_log_panel_log", "Logs", 700, 700)
		popup.set_content(JOINTEXT(dat))
		popup.open()
		return

	if(href_list["emote"])
		var/list/dat = list()
		var/mob/M = locate(href_list["emote"])


		for(var/log in M.emote_log)
			dat += log
			dat += "<br>"
		var/datum/browser/popup = new(usr, "admin_log_panel_log", "Logs", 700, 700)
		popup.set_content(JOINTEXT(dat))
		popup.open()
		return

	if(href_list["dsay"])
		var/list/dat = list()
		var/mob/M = locate(href_list["dsay"])


		for(var/log in M.dsay_log)
			dat += log
			dat += "<br>"
		var/datum/browser/popup = new(usr, "admin_log_panel_log", "Logs", 700, 700)
		popup.set_content(JOINTEXT(dat))
		popup.open()
		return

	if(href_list["interact"])
		var/list/dat = list()
		var/mob/M = locate(href_list["interact"])


		for(var/log in M.interact_log)
			dat += log
			dat += "<br>"
		var/datum/browser/popup = new(usr, "admin_log_panel_log", "Logs", 700, 700)
		popup.set_content(JOINTEXT(dat))
		popup.open()
		return

	// Now isn't that much better? IT IS NOW A PROC, i.e. kinda like a big panel like unstable
	else if(href_list["playerpanelextended"])
		player_panel_extended()

/mob/living/proc/can_centcom_reply()
	return 0

/mob/living/carbon/human/can_centcom_reply()
	return istype(l_ear, /obj/item/device/radio/headset) || istype(r_ear, /obj/item/device/radio/headset)

/mob/living/silicon/ai/can_centcom_reply()
	return silicon_radio != null && !check_unable(2)

/datum/proc/extra_admin_link(prefix, sufix, short_links)
	return list()

/atom/movable/extra_admin_link(source, prefix, sufix, short_links)
	return list("<A href='byond://?[source];adminplayerobservefollow=\ref[src]'>[prefix][short_links ? "J" : "JMP"][sufix]</A>")

/client/extra_admin_link(source, prefix, sufix, short_links)
	return mob ? mob.extra_admin_link(source, prefix, sufix, short_links) : list()

/mob/extra_admin_link(source, prefix, sufix, short_links)
	. = ..()
	if(client && eyeobj)
		. += "<A href='byond://?[source];adminplayerobservefollow=\ref[eyeobj]'>[prefix][short_links ? "E" : "EYE"][sufix]</A>"

/mob/observer/ghost/extra_admin_link(source, prefix, sufix, short_links)
	. = ..()
	if(mind && (mind.current && !isghost(mind.current)))
		. += "<A href='byond://?[source];adminplayerobservefollow=\ref[mind.current]'>[prefix][short_links ? "B" : "BDY"][sufix]</A>"

/proc/admin_jump_link(datum/target, source, delimiter = "|", prefix, sufix, short_links)
	if(!istype(target))
		CRASH("Invalid admin jump link target: [log_info_line(target)]")
	// The way admin jump links handle their src is weirdly inconsistent...
	if(istype(source, /datum/admins))
		source = "src=\ref[source]"
	else
		source = "_src_=holder"
	return jointext(target.extra_admin_link(source, prefix, sufix, short_links), delimiter)

/datum/proc/get_admin_jump_link(atom/target)
	return

/mob/get_admin_jump_link(atom/target, delimiter, prefix, sufix)
	return client && client.get_admin_jump_link(target, delimiter, prefix, sufix)

/client/get_admin_jump_link(atom/target, delimiter, prefix, sufix)
	if(holder)
		var/short_links = get_preference_value(/datum/client_preference/ghost_follow_link_length) == GLOB.PREF_SHORT
		return admin_jump_link(target, src, delimiter, prefix, sufix, short_links)


#undef TICKET_AUTORESPONSE_IC_ISSUE
#undef TICKET_AUTORESPONSE_BEING_HANDLED
#undef TICKET_AUTORESPONSE_FIXED
#undef TICKET_AUTORESPONSE_THANKS
#undef TICKET_AUTORESPONSE_REQUESTING_TO_BE_SCP
#undef TICKET_AUTORESPONSE_BECOMING_AN_SCP
#undef TICKET_AUTORESPONSE_GITHUB_ISSUE
#undef TICKET_AUTORESPONSE_RUST_ENGINE
#undef TICKET_AUTORESPONSE_D_CLASS_RIOT
#undef TICKET_AUTORESPONSE_D_CLASS_CELLS
#undef TICKET_AUTORESPONSE_DIRECTIONS_OR_LOST
#undef TICKET_AUTORESPONSE_CHARACTER_SETUP
#undef TICKET_AUTORESPONSE_WEBSITE_AND_DISCORD
#undef TICKET_AUTORESPONSE_DEFAULT_NOTICE_MESSAGE
