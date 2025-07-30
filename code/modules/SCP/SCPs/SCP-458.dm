/obj/item/pizzabox/scp458
	name = "The Never-Ending Pizza Box"
	desc = "A seemingly ordinary pizza box that is anomalously capable of producing an infinite amount of pizza."
	w_class = ITEM_SIZE_NORMAL

	// Pizza types are weighted by their chance to be someone's favorite
	var/list/pizza_types = list(
		/obj/item/reagent_containers/food/snacks/sliceable/pizza/meatpizza = 1,
		/obj/item/reagent_containers/food/snacks/sliceable/pizza/mushroompizza = 1,
		/obj/item/reagent_containers/food/snacks/sliceable/pizza/margherita = 1,
		/obj/item/reagent_containers/food/snacks/sliceable/pizza/vegetablepizza = 0.8
	)
	var/static/list/pizza_preferences

/obj/item/pizzabox/scp458/Initialize()
	. = ..()
	if(!pizza_preferences)
		pizza_preferences = list()

// Description when examined
/obj/item/pizzabox/scp458/examine(mob/user)
	. = ..()
	. += "<span class='info'>It seems to be an ordinary pizza box, but you can feel a faint warmth coming from inside.</span>"

/obj/item/pizzabox/scp458/attack_self(mob/living/user)
	QDEL_NULL(pizza)
	if(ishuman(user))
		attune_pizza(user)
	. = ..()

/obj/item/pizzabox/scp458/proc/attune_pizza(mob/living/carbon/human/noms)
	if(!pizza_preferences[noms.ckey])
		pizza_preferences[noms.ckey] = pickweight(pizza_types)
	var/obj/item/pizza_type = pizza_preferences[noms.ckey]
	pizza = new pizza_type (src)
