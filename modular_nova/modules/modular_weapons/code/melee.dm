// Sabres, including the cargo variety

/obj/item/storage/belt/sabre/cargo
	name = "authentic shamshir leather sheath"
	desc = "A good-looking sheath that is advertised as being made of real Venusian black leather. It feels rather plastic-like to the touch, and it looks like it's made to fit a British cavalry sabre."
	icon = 'modular_nova/master_files/icons/obj/clothing/belts.dmi'
	worn_icon = 'modular_nova/master_files/icons/mob/clothing/belt.dmi'

/obj/item/storage/belt/sabre/cargo/PopulateContents()
	new /obj/item/melee/sabre/cargo(src)
	update_appearance()

/obj/item/melee/sabre
	force = 20 // Original: 15
	wound_bonus = 5 // Original: 10
	bare_wound_bonus = 20 // Original: 25 Both down slightly, to make up for the damage buff, since it'd get a bit wacky ontop of the armor pen.

/obj/item/melee/sabre/cargo
	name = "authentic shamshir sabre"
	desc = "An expertly crafted historical human sword once used by the Persians which has recently gained traction due to Venusian historal recreation sports. One small flaw, the Taj-based company who produces these has mistaken them for British cavalry sabres akin to those used by high ranking Nanotrasen officials. Atleast it cuts the same way!"
	icon = 'modular_nova/modules/modular_weapons/icons/obj/melee.dmi'
	lefthand_file = 'modular_nova/modules/modular_weapons/icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'modular_nova/modules/modular_weapons/icons/mob/inhands/weapons/swords_righthand.dmi'
	block_chance = 20
	armour_penetration = 25

// This is here so that people can't buy the Sabres and craft them into powercrepes
/datum/crafting_recipe/food/powercrepe
	blacklist = list(/obj/item/melee/sabre/cargo)

/obj/item/melee/baton
	/// For use with jousting. For each usable jousting tile, increase the stamina damage of the jousting hit by this much.
	var/stamina_damage_per_jousting_tile = 2

/obj/item/melee/baton/Initialize(mapload)
	. = ..()

	add_jousting_component()

/// Component adder proc for custom behavior, without needing to add more vars.
/obj/item/melee/baton/proc/add_jousting_component()
	AddComponent(/datum/component/jousting, damage_boost_per_tile = 0, knockdown_chance_per_tile = 6, successful_joust_callback = CALLBACK(src, PROC_REF(on_successful_joust)))

/// Callback proc for jousting. Called when a joust is successfully done.
/obj/item/melee/baton/proc/on_successful_joust(mob/living/target, mob/user, usable_charge)
	target.apply_damage(stamina_damage_per_jousting_tile * usable_charge, STAMINA)

/obj/item/melee/baton/security/two_handed
	name = "base type"
	desc = "if you see this, someone messed up"

/// Component adder proc for custom behavior, without needing to add more vars.
/obj/item/melee/baton/security/two_handed/proc/add_two_handed_component()
	AddComponent(
		/datum/component/two_handed,
		force_unwielded = 4,
		force_wielded = 12,
//		icon_wielded = '',
		wield_callback = CALLBACK(src, PROC_REF(on_wielded)),
		unwield_callback = CALLBACK(src, PROC_REF(on_unwielded))
	)

/obj/item/melee/baton/security/two_handed/baton_attack(mob/living/target, mob/living/user, modifiers)
	if (LAZYACCESS(modifiers, LEFT_CLICK))
		var/obj/item/bodypart/other_hand = user.has_hand_for_held_index(user.get_inactive_hand_index())
		if (user.get_inactive_held_item() || other_hand)
			balloon_alert(user, "use both hands!")
			return BATON_ATTACK_DONE

	return ..()

#define STUN_STAFF_BLOCK_CHANCE 20
/obj/item/melee/baton/security/two_handed/staff
	name = "stun staff"
	desc = "A double sided stun baton for more subduing the more troublesome criminals."

	force = 12 // only slightly stronger
	cooldown = 1.8 SECONDS // versus 2.5 seconds, somewhat better

	w_class = WEIGHT_CLASS_BULKY

	light_range = 3 // its 2 batons

/obj/item/melee/baton/security/two_handed/staff/proc/on_wielded()
	block_chance += STUN_STAFF_BLOCK_CHANCE

/obj/item/melee/baton/security/two_handed/staff/proc/on_unwielded()
	block_chance -= STUN_STAFF_BLOCK_CHANCE

#undef STUN_STAFF_BLOCK_CHANCE

/obj/item/melee/baton/security/two_handed/pike
	name = "stun pike"
	desc = "An oversized stun baton, made long enough to attack at a distance. Perfect for riot control."

	cooldown = 3.5 SECONDS // versus 2.5
	// range is extended below via wielding procs

/obj/item/melee/baton/security/two_handed/pike/Initialize(mapload)
	. = ..()

	AddComponent(
		/datum/component/two_handed,
		force_unwielded = 3,
		force_wielded = 10,
//		icon_wielded = '',
		wield_callback = CALLBACK(src, PROC_REF(on_wielded)),
		unwield_callback = CALLBACK(src, PROC_REF(on_unwielded))
	)

/obj/item/melee/baton/security/two_handed/pike/proc/on_wielded()
	range += 1 // this doesnt seem like much, but it creates the potential for lots of schenanigans

/obj/item/melee/baton/security/two_handed/pike/proc/on_unwielded()
	range -= 1
