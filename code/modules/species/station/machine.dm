/datum/species/machine
	name = SPECIES_IPC
	name_plural = "machines"

	description = "Positronic intelligence really took off in the 21st century, and it is not uncommon to see independant, free-willed \
	robots in the anolmalous world, particularly where Anderson Robotics is involved. IPCs (Integrated Positronic Chassis) are a \
	loose category of self-willed robots with a humanoid form, generally owned and produced by Anderson Robotics. They are occasionally \
	quietly purchased or seized from them by the SCP Foundation, or produced in-house by the SCP Foundation using assets aquired from \
	Prometheus Labs. They are reliable and dedicated workers, albeit more than slightly inhuman in outlook and perspective."
	cyborg_noun = null

	preview_icon = 'icons/mob/human_races/species/ipc/preview.dmi'

	unarmed_types = list(/datum/unarmed_attack/punch, /datum/unarmed_attack/kick, /datum/unarmed_attack/stomp)
	rarity_value = 2
	strength = STR_HIGH

	min_age = 1
	max_age = 90

	warning_low_pressure = 50
	hazard_low_pressure = -1

	cold_level_1 = SYNTH_COLD_LEVEL_1
	cold_level_2 = SYNTH_COLD_LEVEL_2
	cold_level_3 = SYNTH_COLD_LEVEL_3

	heat_level_1 = SYNTH_HEAT_LEVEL_1		// Gives them about 25 seconds in space before taking damage
	heat_level_2 = SYNTH_HEAT_LEVEL_2
	heat_level_3 = SYNTH_HEAT_LEVEL_3

	body_temperature = null
	passive_temp_gain = 5  // This should cause IPCs to stabilize at ~80 C in a 20 C environment.

	species_flags = SPECIES_FLAG_NO_SCAN | SPECIES_FLAG_NO_PAIN | SPECIES_FLAG_NO_POISON | SPECIES_FLAG_NO_DISEASE
	spawn_flags = SPECIES_CAN_JOIN | SPECIES_IS_WHITELISTED | SPECIES_NO_FBP_CONSTRUCTION
	appearance_flags = HAS_UNDERWEAR | HAS_EYE_COLOR //IPCs can wear undies too :(

	blood_color = "#1f181f"
	flesh_color = "#575757"

	has_organ = list(
		BP_POSIBRAIN = /obj/item/organ/internal/posibrain,
		BP_EYES = /obj/item/organ/internal/eyes/robot
		)

	heat_discomfort_level = 373.15
	heat_discomfort_strings = list(
		"Your CPU temperature probes warn you that you are approaching critical heat levels!"
		)
	genders = list(NEUTER)

	available_cultural_info = list(
		TAG_CULTURE = list(
			CULTURE_OTHER
		),
		TAG_HOMEWORLD = list(
			HOME_SYSTEM_OTHER
		),
		TAG_FACTION = list(
			FACTION_OTHER
		)
	)

	default_cultural_info = list(
		TAG_CULTURE = CULTURE_OTHER,
		TAG_HOMEWORLD = HOME_SYSTEM_OTHER,
		TAG_FACTION = FACTION_OTHER
	)

	exertion_effect_chance = 10
	exertion_charge_scale = 1
	exertion_emotes_synthetic = list(
		/decl/emote/exertion/synthetic,
		/decl/emote/exertion/synthetic/creak
	)
	special_footstep_sounds = list('sounds/effects/footstep/special/servostep.ogg')

/datum/species/machine/handle_death(mob/living/carbon/human/H)
	..()
	if(istype(H.wear_mask,/obj/item/clothing/mask/monitor))
		var/obj/item/clothing/mask/monitor/M = H.wear_mask
		M.monitor_state_index = "blank"
		M.update_icon()

/datum/species/machine/post_organ_rejuvenate(obj/item/organ/org, mob/living/carbon/human/H)
	var/obj/item/organ/external/E = org
	if(istype(E) && !BP_IS_ROBOTIC(E))
		E.robotize("Morpheus")

/datum/species/machine/get_blood_name()
	return "oil"

/datum/species/machine/disfigure_msg(mob/living/carbon/human/H)
	return "<span class='danger'>[H.p_their(TRUE)] monitor is completely busted!</span>\n"

/datum/species/machine/can_float(mob/living/carbon/human/H)
	return FALSE
