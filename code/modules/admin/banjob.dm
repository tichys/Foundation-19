var/jobban_runonce			// Updates legacy bans with new info
var/jobban_keylist[0]		//to store the keys & ranks

/proc/jobban_fullban(mob/M, rank, reason)
	if(!M)
		return
	var/last_ckey = LAST_CKEY(M)
	if(!last_ckey)
		return
	jobban_keylist.Add(text("[last_ckey] - [rank] ## [reason]"))
	jobban_savebanfile()

/proc/jobban_client_fullban(ckey, rank)
	if (!ckey || !rank) return
	jobban_keylist.Add(text("[ckey] - [rank]"))
	jobban_savebanfile()

//returns a reason if M is banned from rank, returns 0 otherwise
/proc/jobban_isbanned(mob/M, rank)
	if(M && rank)
		if (SSjobs.guest_jobbans(rank))
			if(config.guest_jobban && IsGuestKey(M.key))
				return "Guest Job-ban"
			if(config.usewhitelist && !check_whitelist(M))
				return "Whitelisted Job"
		return ckey_is_jobbanned(M.ckey, rank)
	return 0

/proc/ckey_is_jobbanned(check_key, rank)
	for(var/s in jobban_keylist)
		if(findtext(s,"[check_key] - [rank]") == 1 )
			var/startpos = findtext(s, "## ")+3
			if(startpos && startpos<length(s))
				var/text = copytext(s, startpos, 0)
				if(text)
					return text
			return "Reason Unspecified"
	return 0

/hook/startup/proc/loadJobBans()
	jobban_loadbanfile()
	return 1

/proc/jobban_loadbanfile()
	if(config.ban_legacy_system)
		var/savefile/S=new("data/job_full.ban")
		from_save(S["keys[0]"],  jobban_keylist)
		log_admin("Loading jobban_rank")
		from_save(S["runonce"], jobban_runonce)

		if (!length(jobban_keylist))
			jobban_keylist=list()
			log_admin("jobban_keylist was empty")
	else
		if(!SSdbcore.Connect())
			error("Database connection failed. Reverting to the legacy ban system.")
			log_misc("Database connection failed. Reverting to the legacy ban system.")
			config.ban_legacy_system = 1
			jobban_loadbanfile()
			return

		//Job permabans
		var/datum/db_query/query = SSdbcore.NewQuery("SELECT ckey, job FROM erro_ban WHERE bantype = 'JOB_PERMABAN' AND isnull(unbanned)")
		query.Execute()

		while(query.NextRow())
			var/ckey = query.item[1]
			var/job = query.item[2]

			jobban_keylist.Add("[ckey] - [job]")

		//Job tempbans
		var/datum/db_query/query1 = SSdbcore.NewQuery("SELECT ckey, job FROM erro_ban WHERE bantype = 'JOB_TEMPBAN' AND isnull(unbanned) AND expiration_time > Now()")
		query1.Execute()

		while(query1.NextRow())
			var/ckey = query1.item[1]
			var/job = query1.item[2]

			jobban_keylist.Add("[ckey] - [job]")

		qdel(query)
		qdel(query1)

/proc/jobban_savebanfile()
	var/savefile/S=new("data/job_full.ban")
	to_save(S["keys[0]"], jobban_keylist)

/proc/jobban_unban(mob/M, rank)
	jobban_remove("[M.ckey] - [rank]")
	jobban_savebanfile()


/proc/ban_unban_log_save(formatted_log)
	text2file(formatted_log,"data/ban_unban_log.txt")


/proc/jobban_remove(X)
	for (var/i = 1; i <= length(jobban_keylist); i++)
		if( findtext(jobban_keylist[i], "[X]") )
			jobban_keylist.Remove(jobban_keylist[i])
			jobban_savebanfile()
			return 1
	return 0

/client/proc/cmd_admin_job_ban(mob/M)
	if(!check_rights(R_BAN|R_MOD))
		return

	if(holder)
		holder.job_ban(M)

/datum/admins/proc/job_ban(mob/M)
	if(!ismob(M))
		to_chat(usr, "This can only be used on instances of type /mob")
		return

	if(!M.ckey)	//sanity
		to_chat(usr, "This mob has no ckey")
		return

	var/dat = ""
	var/header = "<head><title>Job-Ban Panel: [M.name]</title></head>"
	var/body
	var/jobs = ""

/* WARNING!
					The jobban stuff looks mangled and disgusting
							But it looks beautiful in-game
									-Nodrak
WARNING!*/
	var/counter = 0
	//Regular jobs
	//Command (Blue)
	jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
	jobs += "<tr align='center' bgcolor='ccccff'><th colspan='[length(SSjobs.distinct_titles_by_department(COM))]'><a href='byond://?src=\ref[src];jobban1=commanddept;jobban2=\ref[M]'>Command Positions</a></th></tr><tr align='center'>"
	for(var/jobPos in SSjobs.distinct_titles_by_department(COM))
		if(!jobPos)	continue
		var/datum/job/job = SSjobs.get_by_title(jobPos)
		if(!job) continue

		if(jobban_isbanned(M, job.title))
			jobs += "<td width='20%'><a href='byond://?src=\ref[src];jobban1=[job.title];jobban2=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
			counter++
		else
			jobs += "<td width='20%'><a href='byond://?src=\ref[src];jobban1=[job.title];jobban2=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
			counter++

		if(counter >= 6) //So things dont get squiiiiished!
			jobs += "</tr><tr>"
			counter = 0
	jobs += "</tr></table>"

	//Command Support (Sky Blue)
	jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
	jobs += "<tr bgcolor='87ceeb'><th colspan='[length(SSjobs.distinct_titles_by_department(SPT))]'><a href='byond://?src=\ref[src];jobban1=supportdept;jobban2=\ref[M]'>Command Support Positions</a></th></tr><tr align='center'>"
	for(var/jobPos in SSjobs.distinct_titles_by_department(SPT))
		if(!jobPos)	continue
		var/datum/job/job = SSjobs.get_by_title(jobPos)
		if(!job) continue

		if(jobban_isbanned(M, job.title))
			jobs += "<td width='20%'><a href='byond://?src=\ref[src];jobban1=[job.title];jobban2=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
			counter++
		else
			jobs += "<td width='20%'><a href='byond://?src=\ref[src];jobban1=[job.title];jobban2=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
			counter++

		if(counter >= 6) //So things dont get squiiiiished!
			jobs += "</tr><tr>"
			counter = 0
	jobs += "</tr></table>"

	//Security (Red)
	counter = 0
	jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
	jobs += "<tr bgcolor='ffddf0'><th colspan='[length(SSjobs.distinct_titles_by_department(SEC))]'><a href='byond://?src=\ref[src];jobban1=securitydept;jobban2=\ref[M]'>Security Positions</a></th></tr><tr align='center'>"
	for(var/jobPos in SSjobs.distinct_titles_by_department(SEC))
		if(!jobPos)	continue
		var/datum/job/job = SSjobs.get_by_title(jobPos)
		if(!job) continue

		if(jobban_isbanned(M, job.title))
			jobs += "<td width='20%'><a href='byond://?src=\ref[src];jobban1=[job.title];jobban2=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
			counter++
		else
			jobs += "<td width='20%'><a href='byond://?src=\ref[src];jobban1=[job.title];jobban2=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
			counter++

		if(counter >= 5) //So things dont get squiiiiished!
			jobs += "</tr><tr align='center'>"
			counter = 0
	jobs += "</tr></table>"

	//Engineering (Yellow)
	counter = 0
	jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
	jobs += "<tr bgcolor='fff5cc'><th colspan='[length(SSjobs.distinct_titles_by_department(ENG))]'><a href='byond://?src=\ref[src];jobban1=engineeringdept;jobban2=\ref[M]'>Engineering Positions</a></th></tr><tr align='center'>"
	for(var/jobPos in SSjobs.distinct_titles_by_department(ENG))
		if(!jobPos)	continue
		var/datum/job/job = SSjobs.get_by_title(jobPos)
		if(!job) continue

		if(jobban_isbanned(M, job.title))
			jobs += "<td width='20%'><a href='byond://?src=\ref[src];jobban1=[job.title];jobban2=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
			counter++
		else
			jobs += "<td width='20%'><a href='byond://?src=\ref[src];jobban1=[job.title];jobban2=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
			counter++

		if(counter >= 5) //So things dont get squiiiiished!
			jobs += "</tr><tr align='center'>"
			counter = 0
	jobs += "</tr></table>"

	//Medical (White)
	counter = 0
	jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
	jobs += "<tr bgcolor='ffeef0'><th colspan='[length(SSjobs.distinct_titles_by_department(MED))]'><a href='byond://?src=\ref[src];jobban1=medicaldept;jobban2=\ref[M]'>Medical Positions</a></th></tr><tr align='center'>"
	for(var/jobPos in SSjobs.distinct_titles_by_department(MED))
		if(!jobPos)	continue
		var/datum/job/job = SSjobs.get_by_title(jobPos)
		if(!job) continue

		if(jobban_isbanned(M, job.title))
			jobs += "<td width='20%'><a href='byond://?src=\ref[src];jobban1=[job.title];jobban2=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
			counter++
		else
			jobs += "<td width='20%'><a href='byond://?src=\ref[src];jobban1=[job.title];jobban2=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
			counter++

		if(counter >= 5) //So things dont get squiiiiished!
			jobs += "</tr><tr align='center'>"
			counter = 0
	jobs += "</tr></table>"

	//Science (Purple)
	counter = 0
	jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
	jobs += "<tr bgcolor='e79fff'><th colspan='[length(SSjobs.distinct_titles_by_department(SCI))]'><a href='byond://?src=\ref[src];jobban1=sciencedept;jobban2=\ref[M]'>Science Positions</a></th></tr><tr align='center'>"
	for(var/jobPos in SSjobs.distinct_titles_by_department(SCI))
		if(!jobPos)	continue
		var/datum/job/job = SSjobs.get_by_title(jobPos)
		if(!job) continue

		if(jobban_isbanned(M, job.title))
			jobs += "<td width='20%'><a href='byond://?src=\ref[src];jobban1=[job.title];jobban2=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
			counter++
		else
			jobs += "<td width='20%'><a href='byond://?src=\ref[src];jobban1=[job.title];jobban2=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
			counter++

		if(counter >= 5) //So things dont get squiiiiished!
			jobs += "</tr><tr align='center'>"
			counter = 0
	jobs += "</tr></table>"

	//Exploration (Pale Purple)
	jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
	jobs += "<tr bgcolor='b784a7'><th colspan='[length(SSjobs.distinct_titles_by_department(EXP))]'><a href='byond://?src=\ref[src];jobban1=explorationdept;jobban2=\ref[M]'>Exploration Positions</a></th></tr><tr align='center'>"
	for(var/jobPos in SSjobs.distinct_titles_by_department(EXP))
		if(!jobPos)	continue
		var/datum/job/job = SSjobs.get_by_title(jobPos)
		if(!job) continue

		if(jobban_isbanned(M, job.title))
			jobs += "<td width='20%'><a href='byond://?src=\ref[src];jobban1=[job.title];jobban2=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
			counter++
		else
			jobs += "<td width='20%'><a href='byond://?src=\ref[src];jobban1=[job.title];jobban2=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
			counter++

		if(counter >= 6) //So things dont get squiiiiished!
			jobs += "</tr><tr>"
			counter = 0
	jobs += "</tr></table>"

	//Service (Tea Green)
	jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
	jobs += "<tr bgcolor='d0f0c0'><th colspan='[length(SSjobs.distinct_titles_by_department(SRV))]'><a href='byond://?src=\ref[src];jobban1=servicedept;jobban2=\ref[M]'>Service Positions</a></th></tr><tr align='center'>"
	for(var/jobPos in SSjobs.distinct_titles_by_department(SRV))
		if(!jobPos)	continue
		var/datum/job/job = SSjobs.get_by_title(jobPos)
		if(!job) continue

		if(jobban_isbanned(M, job.title))
			jobs += "<td width='20%'><a href='byond://?src=\ref[src];jobban1=[job.title];jobban2=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
			counter++
		else
			jobs += "<td width='20%'><a href='byond://?src=\ref[src];jobban1=[job.title];jobban2=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
			counter++

		if(counter >= 6) //So things dont get squiiiiished!
			jobs += "</tr><tr>"
			counter = 0
	jobs += "</tr></table>"


	//Supply (Khaki)
	jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
	jobs += "<tr bgcolor='f0e68c'><th colspan='[length(SSjobs.distinct_titles_by_department(SUP))]'><a href='byond://?src=\ref[src];jobban1=supplydept;jobban2=\ref[M]'>Supply Positions</a></th></tr><tr align='center'>"
	for(var/jobPos in SSjobs.distinct_titles_by_department(SUP))
		if(!jobPos)	continue
		var/datum/job/job = SSjobs.get_by_title(jobPos)
		if(!job) continue

		if(jobban_isbanned(M, job.title))
			jobs += "<td width='20%'><a href='byond://?src=\ref[src];jobban1=[job.title];jobban2=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
			counter++
		else
			jobs += "<td width='20%'><a href='byond://?src=\ref[src];jobban1=[job.title];jobban2=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
			counter++

		if(counter >= 6) //So things dont get squiiiiished!
			jobs += "</tr><tr>"
			counter = 0
	jobs += "</tr></table>"

	//Civilian (Grey)
	counter = 0
	jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
	jobs += "<tr bgcolor='dddddd'><th colspan='[length(SSjobs.distinct_titles_by_department(CIV))]'><a href='byond://?src=\ref[src];jobban1=civiliandept;jobban2=\ref[M]'>Civilian Positions</a></th></tr><tr align='center'>"
	for(var/jobPos in SSjobs.distinct_titles_by_department(CIV))
		if(!jobPos)	continue
		var/datum/job/job = SSjobs.get_by_title(jobPos)
		if(!job) continue

		if(jobban_isbanned(M, job.title))
			jobs += "<td width='20%'><a href='byond://?src=\ref[src];jobban1=[job.title];jobban2=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
			counter++
		else
			jobs += "<td width='20%'><a href='byond://?src=\ref[src];jobban1=[job.title];jobban2=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
			counter++

		if(counter >= 5) //So things dont get squiiiiished!
			jobs += "</tr><tr align='center'>"
			counter = 0

	if(jobban_isbanned(M, "Internal Affairs Agent"))
		jobs += "<td width='20%'><a href='byond://?src=\ref[src];jobban1=Internal Affairs Agent;jobban2=\ref[M]'><font color=red>Internal Affairs Agent</font></a></td>"
	else
		jobs += "<td width='20%'><a href='byond://?src=\ref[src];jobban1=Internal Affairs Agent;jobban2=\ref[M]'>Internal Affairs Agent</a></td>"

	jobs += "</tr></table>"

	//Non-Human (Green)
	counter = 0
	jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
	jobs += "<tr bgcolor='ccffcc'><th colspan='[length(SSjobs.distinct_titles_by_department(MSC))+2]'><a href='byond://?src=\ref[src];jobban1=nonhumandept;jobban2=\ref[M]'>Non-human Positions</a></th></tr><tr align='center'>"
	for(var/jobPos in SSjobs.distinct_titles_by_department(MSC))
		if(!jobPos)	continue
		var/datum/job/job = SSjobs.get_by_title(jobPos)
		if(!job) continue

		if(jobban_isbanned(M, job.title))
			jobs += "<td width='20%'><a href='byond://?src=\ref[src];jobban1=[job.title];jobban2=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
			counter++
		else
			jobs += "<td width='20%'><a href='byond://?src=\ref[src];jobban1=[job.title];jobban2=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
			counter++

		if(counter >= 5) //So things dont get squiiiiished!
			jobs += "</tr><tr align='center'>"
			counter = 0

	//pAI isn't technically a job, but it goes in here.

	if(jobban_isbanned(M, "pAI"))
		jobs += "<td width='20%'><a href='byond://?src=\ref[src];jobban1=pAI;jobban2=\ref[M]'><font color=red>pAI</font></a></td>"
	else
		jobs += "<td width='20%'><a href='byond://?src=\ref[src];jobban1=pAI;jobban2=\ref[M]'>pAI</a></td>"
	if(jobban_isbanned(M, "AntagHUD"))
		jobs += "<td width='20%'><a href='byond://?src=\ref[src];jobban1=AntagHUD;jobban2=\ref[M]'><font color=red>AntagHUD</font></a></td>"
	else
		jobs += "<td width='20%'><a href='byond://?src=\ref[src];jobban1=AntagHUD;jobban2=\ref[M]'>AntagHUD</a></td>"
	jobs += "</tr></table>"

	//Antagonist (Orange)
	jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
	jobs += "<tr bgcolor='ffeeaa'><th colspan='10'><a href='byond://?src=\ref[src];jobban1=Syndicate;jobban2=\ref[M]'>Antagonist Positions</a></th></tr><tr align='center'>"

	// Antagonists.
	#define ANTAG_COLUMNS 5
	var/list/all_antag_types = GLOB.all_antag_types_
	var/i = 1
	for(var/antag_type in all_antag_types)
		var/datum/antagonist/antag = all_antag_types[antag_type]
		if(!antag || !antag.id)
			continue
		if(jobban_isbanned(M, "[antag.id]"))
			jobs += "<td width='20%'><a href='byond://?src=\ref[src];jobban1=[antag.id];jobban2=\ref[M]'><font color=red>[replacetext("[antag.role_text]", " ", "&nbsp")]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='byond://?src=\ref[src];jobban1=[antag.id];jobban2=\ref[M]'>[replacetext("[antag.role_text]", " ", "&nbsp")]</a></td>"
		if(i % ANTAG_COLUMNS == 0 && i < length(all_antag_types))
			jobs += "</tr><tr align='center'>"
		i++
	jobs += "</tr></table>"
	#undef ANTAG_COLUMNS

	var/list/misc_roles = list("Dionaea", "Graffiti", "Safe SCP", "Non-Safe SCP")
	counter = 0
	//Other roles  (BLUE, because I have no idea what other color to make this)
	jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
	jobs += "<tr bgcolor='ccccff'><th colspan='[LAZYLEN(misc_roles)]'>Other Roles</th></tr><tr align='center'>"
	for(var/entry in misc_roles)
		if(jobban_isbanned(M, entry))
			jobs += "<td width='20%'><a href='byond://?src=\ref[src];jobban1=[entry];jobban2=\ref[M]'><font color=red>[entry]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='byond://?src=\ref[src];jobban1=[entry];jobban2=\ref[M]'>[entry]</a></td>"

		if(counter >= 5) //So things dont get squiiiiished!
			jobs += "</tr><tr align='center'>"
			counter = 0

	jobs += "</tr></table>"

	// Channels
	jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
	var/list/channels = decls_repository.get_decls_of_subtype(/decl/communication_channel)
	jobs += "<tr bgcolor='ccccff'><th colspan='[LAZYLEN(channels)]'>Channel Bans</th></tr><tr align='center'>"
	for(var/channel_type in channels)
		var/decl/communication_channel/channel = channels[channel_type]
		if(jobban_isbanned(M, channel.name))
			jobs += "<td width='20%'><a href='byond://?src=\ref[src];jobban1=[channel.name];jobban2=\ref[M]'><font color=red>[channel.name]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='byond://?src=\ref[src];jobban1=[channel.name];jobban2=\ref[M]'>[channel.name]</a></td>"
	jobs += "</tr></table>"

	// Finalize and display.
	body = "<body>[jobs]</body>"
	dat = "<tt>[header][body]</tt>"
	show_browser(usr, dat, "window=jobban2;size=800x490")
	return
