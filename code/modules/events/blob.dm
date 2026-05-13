/datum/event/blob
	announceWhen	= 12

	var/obj/effect/blob/core/Blob

/datum/event/blob/announce()
	GLOB.using_map.level_x_biohazard_announcement(7)

/datum/event/blob/start()
	var/turf/T = pick_subarea_turf(pick(
		/area/site53/ulcz/maintenance,
		/area/site53/lhcz/maintenance,
		/area/site53/uez/maintenance,
		/area/site53/lhcz/maintenance),
		list(GLOBAL_PROC_REF(is_station_turf), GLOBAL_PROC_REF(not_turf_contains_dense_objects))
	)
	if(!T)
		log_and_message_staff("Blob failed to find a viable turf.")
		kill()
		return

	log_and_message_staff("Blob spawned in \the [get_area(T)]", location = T)
	Blob = new /obj/effect/blob/core(T)
	for(var/i = 1, i < rand(3, 4), i++)
		Blob.Process()

/datum/event/blob/tick()
	if(!Blob || !Blob.loc)
		Blob = null
		kill()
		return
	if(IsMultiple(activeFor, 3))
		Blob.Process()
