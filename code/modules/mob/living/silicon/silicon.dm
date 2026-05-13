/mob/living/silicon
	gender = NEUTER
	voice_name = "synthesized voice"
	skillset = /datum/skillset/silicon

	meat_type = null
	meat_amount = 0
	skin_material = null
	skin_amount = 0
	bone_material = null
	bone_amount = 0

	var/syndicate = 0
	var/const/MAIN_CHANNEL = "Main Frequency"
	var/lawchannel = MAIN_CHANNEL // Default channel on which to state laws
	var/list/stating_laws = list()// Channels laws are currently being stated on
	var/obj/item/device/radio/silicon_radio

	var/list/hud_list[10]
	var/list/speech_synthesizer_langs = list()	//which languages can be vocalized by the speech synthesizer

	//Used in say.dm.
	var/speak_statement = "states"
	var/speak_exclamation = "declares"
	var/speak_query = "queries"
	var/pose //Yes, now AIs can pose too.
	var/obj/item/device/camera/siliconcam/silicon_camera = null //photography
	var/local_transmit //If set, can only speak to others of the same type within a short range.

	var/sensor_mode = 0 //Determines the current HUD.

	var/next_alarm_notice
	var/list/datum/alarm/queued_alarms = new()

	var/list/access_rights
	var/obj/item/card/id/idcard = /obj/item/card/id/synthetic

	var/machine_restriction = TRUE // Whether or not the silicon mob is affected by the `silicon_restriction` var on machines

	#define SEC_HUD 1 //Security HUD mode
	#define MED_HUD 2 //Medical HUD mode

	roundstart_traits = list(TRAIT_ADVANCED_TOOL_USER)

/mob/living/silicon/Initialize()
	GLOB.silicon_mob_list += src
	. = ..()

	if(silicon_radio)
		silicon_radio = new silicon_radio(src)
	if(silicon_camera)
		silicon_camera = new silicon_camera(src)

	add_language(LANGUAGE_ENGLISH)
	default_language = all_languages[LANGUAGE_ENGLISH]
	init_id()
	init_subsystems()

/mob/living/silicon/Destroy()
	GLOB.silicon_mob_list -= src
	QDEL_NULL(silicon_radio)
	QDEL_NULL(silicon_camera)
	QDEL_NULL(idcard)
	for(var/datum/alarm_handler/AH as anything in SSalarm.handlers)
		AH.unregister_alarm(src)
	return ..()

/mob/living/silicon/fully_replace_character_name(new_name)
	..()
	create_or_rename_email(new_name, "root.rt")
	if(istype(idcard))
		idcard.registered_name = new_name

/mob/living/silicon/proc/init_id()
	if(ispath(idcard))
		idcard = new idcard(src)
		set_id_info(idcard)

/mob/living/silicon/proc/show_laws()
	return

/mob/living/silicon/drop_active_hand()
	return

/mob/living/silicon/emp_act(severity)
	if(status_flags & GODMODE)
		return

	switch(severity)
		if(1)
			take_organ_damage(0, 16, ORGAN_DAMAGE_SILICON_EMP)
			if(prob(50))
				Stun(rand(5,10))
			else
				adjust_confusion_up_to(2 SECONDS, 40 SECONDS)
		if(2)
			take_organ_damage(0, 7, ORGAN_DAMAGE_SILICON_EMP)
			adjust_confusion_up_to(2 SECONDS, 30 SECONDS)
	flash_eyes(affect_silicon = 1)
	to_chat(src, SPAN_DANGER("<B>*BZZZT*</B>"))
	to_chat(src, SPAN_DANGER("Warning: Electromagnetic pulse detected."))
	..()

/mob/living/silicon/stun_effect_act(stun_amount, agony_amount)
	return	//immune

/mob/living/silicon/electrocute_act(shock_damage, obj/source, siemens_coeff = 1.0, def_zone = null)

	if (istype(source, /obj/machinery/containment_field))
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(5, 1, loc)
		s.start()

		shock_damage *= 0.75	//take reduced damage
		take_overall_damage(0, shock_damage)
		visible_message(SPAN_WARNING("\The [src] was shocked by \the [source]!"), \
			SPAN_DANGER("Energy pulse detected, system damaged!"), \
			SPAN_WARNING("You hear an electrical crack"))
		if(prob(20))
			Stun(2)
		return

/mob/living/silicon/proc/damage_mob(brute = 0, fire = 0, tox = 0)
	return

/mob/living/silicon/bullet_act(obj/item/projectile/Proj)
	if(status_flags & GODMODE)
		return PROJECTILE_FORCE_MISS

	if(!Proj.nodamage)
		switch(Proj.damage_type)
			if(BRUTE)
				adjustBruteLoss(Proj.damage)
			if(BURN)
				adjustFireLoss(Proj.damage)

	Proj.on_hit(src,100) //wow this is a terrible hack
	updatehealth()
	return 100

/mob/living/silicon/apply_effect(effect = 0,effecttype = STUN, blocked = 0)
	return 0//The only effect that can hit them atm is flashes and they still directly edit so this works for now

/proc/islinked(mob/living/silicon/robot/bot, mob/living/silicon/ai/ai)
	if(!istype(bot) || !istype(ai))
		return 0
	if (bot.connected_ai == ai)
		return 1
	return 0

// This adds the basic clock, shuttle recall timer, and malf_ai info to all silicon lifeforms
/mob/living/silicon/get_status_tab_items()
	.=..()
	if(!stat)
		. += "System integrity: [round((health/maxHealth)*100)]%"
	else
		. += "Systems nonfunctional"

//can't inject synths
/mob/living/silicon/can_inject(mob/user, target_zone)
	to_chat(user, SPAN_WARNING("The armoured plating is too tough."))
	return 0


//Silicon mob language procs

/mob/living/silicon/can_speak(datum/language/speaking)
	return universal_speak || (speaking in src.speech_synthesizer_langs)	//need speech synthesizer support to vocalize a language

/mob/living/silicon/add_language(language, can_speak=1)
	var/datum/language/added_language = all_languages[language]
	if(!added_language)
		return

	. = ..(language)
	if (can_speak && (added_language in languages) && !(added_language in speech_synthesizer_langs))
		speech_synthesizer_langs += added_language
		return 1

/mob/living/silicon/remove_language(rem_language)
	var/datum/language/removed_language = all_languages[rem_language]
	if(!removed_language)
		return

	..(rem_language)
	speech_synthesizer_langs -= removed_language

/mob/living/silicon/check_languages()
	set name = "Check Known Languages"
	set category = "IC"
	set src = usr

	var/dat = "<b><font size = 5>Known Languages</font></b><br/><br/>"

	if(default_language)
		dat += "Current default language: [default_language] - <a href='byond://?src=\ref[src];default_lang=reset'>reset</a><br/><br/>"

	for(var/datum/language/L in languages)
		if(!(L.flags & NONGLOBAL))
			var/default_str
			if(L == default_language)
				default_str = " - default - <a href='byond://?src=\ref[src];default_lang=reset'>reset</a>"
			else
				default_str = " - <a href='byond://?src=\ref[src];default_lang=\ref[L]'>set default</a>"

			var/synth = (L in speech_synthesizer_langs)
			dat += "<b>[L.name] ([get_language_prefix()][L.key])</b>[synth ? default_str : null]<br/>Speech Synthesizer: <i>[synth ? "YES" : "NOT SUPPORTED"]</i><br/>[L.desc]<br/><br/>"

	show_browser(src, dat, "window=checklanguage")
	return

/mob/living/silicon/proc/toggle_sensor_mode()
	var/sensor_type = input("Please select sensor type.", "Sensor Integration", null) in list("Security", "Medical","Disable")
	switch(sensor_type)
		if ("Security")
			sensor_mode = SEC_HUD
			to_chat(src, SPAN_NOTICE("Security records overlay enabled."))
		if ("Medical")
			sensor_mode = MED_HUD
			to_chat(src, SPAN_NOTICE("Life signs monitor overlay enabled."))
		if ("Disable")
			sensor_mode = 0
			to_chat(src, "Sensor augmentations disabled.")

/mob/living/silicon/verb/pose()
	set name = "Set Pose"
	set desc = "Sets a description which will be shown when someone examines you."
	set category = "IC"

	pose =  sanitize(input(usr, "This is [src]. It...", "Pose", null)  as text)

/mob/living/silicon/verb/set_flavor()
	set name = "Set Flavour Text"
	set desc = "Sets an extended description of your character's features."
	set category = "IC"

	flavor_text =  sanitize(input(usr, "Please enter your new flavour text.", "Flavour text", null)  as text)

/mob/living/silicon/binarycheck()
	return 1

/mob/living/silicon/ex_act(severity)
	if(status_flags & GODMODE)
		return

	if(can_see())
		flash_eyes()

	var/brute
	var/burn
	switch(severity)
		if(1.0)
			brute = 400
			burn = 100
		if(2.0)
			brute = 60
			burn = 60
		if(3.0)
			brute = 30

	apply_damage(brute, BRUTE, damage_flags = DAM_EXPLODE)
	apply_damage(burn, BURN, damage_flags = DAM_EXPLODE)

/mob/living/silicon/proc/receive_alarm(datum/alarm_handler/alarm_handler, datum/alarm/alarm, was_raised)
	if(!(alarm.alarm_z() in GetConnectedZlevels(get_z(src))))
		return // Didn't actually hear it as far as we're concerned.
	if(!next_alarm_notice)
		next_alarm_notice = world.time + SecondsToTicks(10)

	var/list/alarms = queued_alarms[alarm_handler]
	if(was_raised)
		// Raised alarms are always set
		alarms[alarm] = 1
	else
		// Alarms that were raised but then cleared before the next notice are instead removed
		if(alarm in alarms)
			alarms -= alarm
		// And alarms that have only been cleared thus far are set as such
		else
			alarms[alarm] = -1

/mob/living/silicon/proc/process_queued_alarms()
	if(next_alarm_notice && (world.time > next_alarm_notice))
		next_alarm_notice = 0

		var/alarm_raised = 0
		for(var/datum/alarm_handler/AH in queued_alarms)
			var/list/alarms = queued_alarms[AH]
			var/reported = 0
			for(var/datum/alarm/A in alarms)
				if(alarms[A] == 1)
					alarm_raised = 1
					if(!reported)
						reported = 1
						to_chat(src, SPAN_WARNING("--- [AH.category] Detected ---"))
					raised_alarm(A)

		for(var/datum/alarm_handler/AH in queued_alarms)
			var/list/alarms = queued_alarms[AH]
			var/reported = 0
			for(var/datum/alarm/A in alarms)
				if(alarms[A] == -1)
					if(!reported)
						reported = 1
						to_chat(src, SPAN_NOTICE("--- [AH.category] Cleared ---"))
					to_chat(src, "\The [A.alarm_name()].")

		if(alarm_raised)
			to_chat(src, "<A href=byond://?src=\ref[src];showalerts=1>\[Show Alerts\]</A>")

		for(var/datum/alarm_handler/AH in queued_alarms)
			var/list/alarms = queued_alarms[AH]
			alarms.Cut()

/mob/living/silicon/proc/raised_alarm(datum/alarm/A)
	to_chat(src, "[A.alarm_name()]!")

/mob/living/silicon/ai/raised_alarm(datum/alarm/A)
	var/cameratext = ""
	for(var/obj/machinery/camera/C in A.cameras())
		cameratext += "[(cameratext == "")? "" : "|"]<A href=byond://?src=\ref[src];switchcamera=\ref[C]>[C.c_tag]</A>"
	to_chat(src, "[A.alarm_name()]! ([(cameratext)? cameratext : "No Camera"])")


/mob/living/silicon/proc/is_traitor()
	return mind && (mind in GLOB.traitors.current_antagonists)

/mob/living/silicon/proc/is_malf()
	return mind && (mind in GLOB.malf.current_antagonists)

/mob/living/silicon/proc/is_malf_or_traitor()
	return is_traitor() || is_malf()

/mob/living/silicon/adjustEarDamage()
	return

/mob/living/silicon/setEarDamage()
	return

/mob/living/silicon/reset_view()
	..()
	if(cameraFollow)
		cameraFollow = null

/mob/living/silicon/proc/clear_client()
	//Handle job slot/tater cleanup.
	if(mind)
		if(mind.assigned_job)
			mind.assigned_job.clear_slot()
		if(mind.objectives.len)
			qdel(mind.objectives)
			mind.special_role = null
		clear_antag_roles(mind)
	ghostize(0)
	qdel(src)

/mob/living/silicon/flash_eyes(intensity = FLASH_PROTECTION_MODERATE, override_blindness_check = FALSE, affect_silicon = FALSE, visual = FALSE, type = /atom/movable/screen/fullscreen/flash)
	if(affect_silicon)
		return ..()

/mob/living/silicon/seizure()
	flash_eyes(affect_silicon = TRUE)

/mob/living/silicon/get_bullet_impact_effect_type(def_zone)
	return BULLET_IMPACT_METAL
