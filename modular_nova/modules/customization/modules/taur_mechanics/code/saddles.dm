/obj/item/riding_saddle
	name = "generic riding saddle"
	desc = "someone spawned a basetype!"
	slot_flags = ITEM_SLOT_BACK // no storage

	icon = 'modular_nova/modules/customization/modules/taur_mechanics/sprites/saddles.dmi'
	worn_icon = 'modular_nova/modules/customization/modules/taur_mechanics/sprites/saddles.dmi'
	worn_icon_taur_snake = 'modular_nova/modules/customization/modules/taur_mechanics/sprites/saddles.dmi'
	supports_variations_flags = STYLE_TAUR_HOOF|STYLE_TAUR_PAW

/obj/item/riding_saddle/Initialize(mapload)
	. = ..()
	if(type == /obj/item/riding_saddle) // don't even let these prototypes exist
		return INITIALIZE_HINT_QDEL

/obj/item/riding_saddle/mob_can_equip(mob/living/target, slot, disable_warning, bypass_equip_delay_self, ignore_equipped, indirect_action)
	if (!iscarbon(target))
		return FALSE
	var/mob/living/carbon/target_carbon = target

	var/obj/item/organ/external/taur_body/taur_body = locate(/obj/item/organ/external/taur_body) in target_carbon.organs // hardcoded for now, we can do a better job later
	if (!taur_body?.can_use_saddle)
		return FALSE

	return ..()

/obj/item/riding_saddle/leather
	name = "riding saddle"
	desc = "A thick leather riding saddle. Typically used for animals, this one has been designed for use by the taurs of the galaxy. \n\
	This saddle has specialized footrests that will allow a rider to <b>use both their hands</b> while riding."

	icon_state = "saddle_leather_item"
	worn_icon_state = "saddle_leather"

	inhand_icon_state = "syringe_kit" // placeholder
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'

/obj/item/riding_saddle/leather/Initialize(mapload)
	. = ..()

	AddComponent(/datum/component/carbon_saddle, RIDING_TAUR) // FREE HANDS

/obj/item/riding_saddle/leather/peacekeeper
	name = "peacekeeper saddle"

	icon_state = "saddle_sec_item"
	worn_icon_state = "saddle_sec"

/obj/item/riding_saddle/leather/peacekeeper/Initialize(mapload)
	. = ..()

	desc += " This one is painted in peacekeeper livery."

/obj/item/storage/backpack/saddlebags
	name = "saddlebags"
	desc = "A collection of small pockets bound together by belt, typically used on caravan animals. This one has been designed for use by the taurs of the galaxy. \n\
	These saddlebags can be accessed by anyone if they <b>alt-click</b> the wearer.\n\
	Additionally, they have been modified with a hand grip that would allow <b>one free hand</b> during riding."
	gender = PLURAL

	slot_flags = ITEM_SLOT_BACK

	icon = 'modular_nova/modules/customization/modules/taur_mechanics/sprites/saddles.dmi'
	worn_icon = 'modular_nova/modules/customization/modules/taur_mechanics/sprites/saddles.dmi'
	worn_icon_taur_snake = 'modular_nova/modules/customization/modules/taur_mechanics/sprites/saddles.dmi'
	supports_variations_flags = STYLE_TAUR_HOOF|STYLE_TAUR_PAW

	storage_type = /datum/storage/saddlebags

	icon_state = "saddle_satchel_item"
	worn_icon_state = "saddle_satchel"

// slightly better than a backpack, but accessable_storage counterbalances this
/datum/storage/saddlebags
	max_total_storage = 26
	max_slots = 21

/obj/item/storage/backpack/saddlebags/Initialize(mapload)
	. = ..()

	AddComponent(/datum/component/carbon_saddle, RIDING_TAUR|RIDER_NEEDS_ARM) // one arm
	AddComponent(/datum/component/accessable_storage)

