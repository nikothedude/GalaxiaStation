#define MINIMUM_NAGA_TAIL_LENGTH 2

/obj/item/organ/external/taur_body/naga
	name = "naga body"
	/// How many segments?
	var/tail_length = 5

	var/list/mob/living/basic/taur_tail_segment/segments = list()

/obj/item/organ/external/taur_body/naga/Initialize(mapload, accessory_type)
	. = ..()

	build_tail(tail_length)

/obj/item/organ/external/taur_body/naga/Insert(mob/living/carbon/reciever, special, movement_flags)
	. = ..()

	deploy_tail()

/mob/living/basic/taur_tail_segment
	name = "tail segment"
	desc = "Part of a naga's tail."

	///Previous segment in the chain, we hold onto this purely to keep track of how long we currently are and to attach new growth to the back
	var/mob/living/basic/taur_tail_segment/back
	var/obj/item/organ/external/taur_body/naga/parent

/obj/item/organ/external/taur_body/naga/proc/build_tail(worm_length)
	tail_length = max(tail_length, MINIMUM_NAGA_TAIL_LENGTH)
	// Sets the hp of the head to be exactly the (length * hp), so the head is de facto the hardest to destroy.
	maxHealth = tail_length * maxHealth
	health = maxHealth

	AddComponent(/datum/component/mob_chain, vary_icon_state = TRUE) // We're the front

	var/mob/living/basic/taur_tail_segment/prev = src
	for(var/i in 1 to tail_length)
		prev = new_segment(behind = prev)
	update_appearance(UPDATE_ICON_STATE)

/// Grows a new segment behind the passed mob
/obj/item/organ/external/taur_body/naga/proc/new_segment(mob/living/basic/taur_tail_segment/behind)
	var/mob/living/segment = new type(drop_location(), FALSE)
	ADD_TRAIT(segment, TRAIT_PERMANENTLY_MORTAL, INNATE_TRAIT)
	segment.AddComponent(/datum/component/mob_chain, front = behind, vary_icon_state = TRUE)
	behind.register_behind(segment)
	return segment

/// Record that we got another guy on our ass
/obj/item/organ/external/taur_body/naga/proc/register_behind(mob/living/tail)
	if(!isnull(back)) // Shouldn't happen but just in case
		UnregisterSignal(back, COMSIG_QDELETING)
	back = tail
	update_appearance(UPDATE_ICON_STATE)
	if(!isnull(back))
		RegisterSignal(back, COMSIG_QDELETING, PROC_REF(tail_deleted))

/// When our tail is gone stop holding a reference to it
/mob/living/basic/taur_tail_segment/proc/tail_deleted()
	SIGNAL_HANDLER
	register_behind(null)

#undef MINIMUM_NAGA_TAIL_LENGTH
