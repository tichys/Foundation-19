/*
	Badges are worn on the belt or neck, and can be used to show the user's credentials.
	The user' details can be imprinted on holobadges with the relevant ID card,
	or they can be emagged to accept any ID for use in disguises.
*/

/obj/item/clothing/accessory/badge
	name = "badge"
	desc = "A leather-backed badge, with gold trimmings."
	icon_state = "detectivebadge"
	slot_flags = SLOT_BELT | SLOT_TIE
	slot = ACCESSORY_SLOT_INSIGNIA
	high_visibility = 1
	var/badge_string = "Detective"
	var/stored_name

/obj/item/clothing/accessory/badge/proc/set_stored_name(new_name)
	stored_name = new_name

/obj/item/clothing/accessory/badge/proc/set_desc(mob/living/carbon/human/H)

/obj/item/clothing/accessory/badge/CanUseTopic(user)
	if(user in view(get_turf(src)))
		return STATUS_INTERACTIVE

/obj/item/clothing/accessory/badge/OnTopic(mob/user, list/href_list)
	if(href_list["look_at_me"])
		if(istype(user))
			user.examinate(src)
			return TOPIC_HANDLED

/obj/item/clothing/accessory/badge/get_examine_line(mob/user)
	. = ..()
	. += "  <a href='byond://?src=\ref[src];look_at_me=1'>\[View\]</a>"

/obj/item/clothing/accessory/badge/examine(user)
	. = ..()
	if(stored_name)
		to_chat(user,"It reads: [stored_name], [badge_string].")

/obj/item/clothing/accessory/badge/attack_self(mob/user as mob)

	if(!stored_name)
		to_chat(user, "You inspect your [src.name]. Everything seems to be in order and you give it a quick cleaning with your hand.")
		set_stored_name(user.real_name)
		set_desc(user)
		return

	if(isliving(user))
		if(stored_name)
			user.visible_message(SPAN_NOTICE("[user] displays their [src.name].\nIt reads: [stored_name], [badge_string]."),SPAN_NOTICE("You display your [src.name].\nIt reads: [stored_name], [badge_string]."))
		else
			user.visible_message(SPAN_NOTICE("[user] displays their [src.name].\nIt reads: [badge_string]."),SPAN_NOTICE("You display your [src.name]. It reads: [badge_string]."))

/obj/item/clothing/accessory/badge/attack(mob/living/carbon/human/M, mob/living/user)
	if(isliving(user))
		user.visible_message(SPAN_DANGER("[user] invades [M]'s personal space, thrusting \the [src] into their face insistently."),SPAN_DANGER("You invade [M]'s personal space, thrusting \the [src] into their face insistently."))
		if(stored_name)
			to_chat(M, SPAN_WARNING("It reads: [stored_name], [badge_string]."))

/obj/item/clothing/accessory/badge/PI
	name = "private investigator's badge"
	badge_string = "Private Investigator"

/*
 *Holobadges
 */
/obj/item/clothing/accessory/badge/holo
	name = "holobadge"
	desc = "This glowing blue badge marks the holder as a member of security."
	color = COLOR_PALE_BLUE_GRAY
	icon_state = "holobadge"
	item_state = "holobadge"
	badge_string = "Security"
	var/badge_access = ACCESS_SECURITY
	var/badge_number
	var/emagged //emag_act removes access requirements

/obj/item/clothing/accessory/badge/holo/NT
	name = "corporate holobadge"
	desc = "This glowing green badge marks the holder as a member of corporate security."
	icon_state = "ntholobadge"
	color = null
	badge_string = "Corporate Security"
	badge_access = ACCESS_RESEARCH

/obj/item/clothing/accessory/badge/holo/cord
	icon_state = "holobadge-cord"
	slot_flags = SLOT_MASK | SLOT_TIE

/obj/item/clothing/accessory/badge/holo/NT/cord
	icon_state = "holobadge-cord"
	slot_flags = SLOT_MASK | SLOT_TIE

/obj/item/clothing/accessory/badge/holo/set_stored_name(new_name)
	..()
	badge_number = random_id(type,1000,9999)
	name = "[name] ([badge_number])"

/obj/item/clothing/accessory/badge/holo/examine(user)
	. = ..()
	if(badge_number)
		to_chat(user,"The badge number is [badge_number].")

/obj/item/clothing/accessory/badge/holo/attack_self(mob/user as mob)
	if(!stored_name)
		to_chat(user, "Waving around a holobadge before swiping an ID would be pretty pointless.")
		return
	return ..()

/obj/item/clothing/accessory/badge/holo/emag_act(remaining_charges, mob/user)
	if (emagged)
		to_chat(user, SPAN_DANGER("\The [src] is already cracked."))
		return
	else
		emagged = TRUE
		to_chat(user, SPAN_DANGER("You crack the holobadge security checks."))
		return 1

/obj/item/clothing/accessory/badge/holo/attackby(obj/item/O as obj, mob/user as mob)
	if(istype(O, /obj/item/card/id) || istype(O, /obj/item/modular_computer))

		var/obj/item/card/id/id_card = O.GetIdCard()

		if(!id_card)
			return

		if((badge_access in id_card.access) || emagged)
			to_chat(user, "You imprint your ID details onto the badge.")
			set_stored_name(id_card.registered_name)
			set_desc(user)
		else
			to_chat(user, "[src] rejects your ID, and flashes 'Insufficient access!'")
		return
	..()

/obj/item/storage/box/holobadge
	name = "holobadge box"
	desc = "A box containing security holobadges."
	startswith = list(/obj/item/clothing/accessory/badge/holo = 4,
					  /obj/item/clothing/accessory/badge/holo/cord = 2)

/obj/item/storage/box/holobadgeNT
	name = "corporate holobadge box"
	desc = "A box containing corporate security holobadges."
	startswith = list(/obj/item/clothing/accessory/badge/holo/NT = 4,
					  /obj/item/clothing/accessory/badge/holo/NT/cord = 2)

/obj/item/clothing/accessory/badge/old
	name = "faded badge"
	desc = "A faded badge, backed with leather. Looks crummy."
	icon_state = "badge_round"
	badge_string = "Unknown"

/obj/item/clothing/accessory/badge/defenseintel
	name = "\improper DIA investigator's badge"
	desc = "A leather-backed silver badge bearing the crest of the Defense Intelligence Agency."
	icon_state = "diabadge"
	badge_string = "Defense Intelligence Agency"

/obj/item/clothing/accessory/badge/interstellarintel
	name = "\improper OII agent's badge"
	desc = "A synthleather holographic badge bearing the crest of the Office of Interstellar Intelligence."
	icon_state = "intelbadge"
	badge_string = "Office of Interstellar Intelligence"

/obj/item/clothing/accessory/badge/nanotrasen
	name = "corporate badge"
	desc = "A leather-backed plastic badge with a variety of information printed on it. Belongs to a corporate executive."
	icon_state = "ntbadge"
	badge_string = "Corporate Executive Body"

/obj/item/clothing/accessory/badge/press
	name = "press badge"
	desc = "A leather-backed plastic badge displaying that the owner is certified press personnel."
	icon_state = "pressbadge"
	badge_string = "Journalist"

/obj/item/clothing/accessory/badge/tags/skrell
	name = "\improper Skrellian holobadge"
	desc = "A high tech Skrellian holobadge, designed to project information about the owner."
	icon_state = "skrell_badge"
	badge_string = null	//Will be the name of the SDTF.

/obj/item/clothing/accessory/badge/tags/skrell/set_desc(mob/living/carbon/human/H)
	if(!istype(H))
		return
	desc = "Blood type: [H.b_type]"

/obj/item/clothing/accessory/badge/tags/skrell/verb/set_sdtf()
	set name = "Set SDTF Name"
	set category = "Object"
	set src in usr

	if(usr.incapacitated())
		to_chat(usr, SPAN_WARNING("You're unable to do that."))
		return

	var/obj/item/in_hand = usr.get_active_hand()
	if(in_hand != src)
		to_chat(usr, SPAN_WARNING("You have to be holding [src] to modify it."))
		return

	badge_string = sanitize(input(usr, "Input your SDTF.", "SDTF Holobadge") as null|text, MAX_NAME_LEN)

	if(usr.incapacitated())	//Because things can happen while you're typing
		to_chat(usr, SPAN_WARNING("You're unable to do that."))
		return
	in_hand = usr.get_active_hand()
	if(in_hand != src)
		to_chat(usr, SPAN_WARNING("You have to be holding [src] to modify it."))
		return

	if(badge_string)
		set_stored_name(usr.real_name)
		set_desc(usr)
		verbs -= /obj/item/clothing/accessory/badge/tags/skrell/verb/set_sdtf
