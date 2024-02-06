/obj/machinery/stasissleeper
	name = "lifeform stasis unit"
	desc = "A somewhat comfortable looking bed with a cover over it. It will keep someone in stasis."
	icon = 'modular_nova/modules/stasisrework/icons/stasissleeper.dmi'
	icon_state = "sleeper"
	base_icon_state = "sleeper"
	density = FALSE
	state_open = TRUE
	circuit = /obj/item/circuitboard/machine/stasissleeper
	idle_power_usage = 40
	active_power_usage = 340
	var/enter_message = span_notice("<b>You feel cool air surround you. You go numb as your senses turn inward.<b>")
	var/last_stasis_sound = FALSE
	/// If SCANNER_CONDENSED, health scans will be in a condensed format. Caused by lowgrade parts.
	var/condensed_mode = SCANNER_CONDENSED
	/// If TRUE, health scans will act as if from a advanced health analyzer.
	var/advanced_scan = FALSE
	/// If TRUE, scanning the health of the occupant will act as if in a health analyzer's wound mode.
	var/wound_mode = FALSE
	fair_market_price = 10
	payment_department = ACCOUNT_MED

/obj/machinery/stasissleeper/Destroy()
	. = ..()

/obj/machinery/stasissleeper/examine(mob/user)
	. = ..()
	. += span_notice("Alt-click to toggle between wound-scanning and health-scanning modes.")
	. += span_notice("It is currently set to [span_notice("[wound_mode ? "wound mode" : "health mode"]")].")
	. += span_notice("A light blinking on the side indicates that it is [span_notice("[occupant ? "occupied" : "vacant"]")].")
	. += span_notice("It has a screen on the side displaying the vitals of the occupant. Right click to read it.")

/obj/machinery/stasissleeper/open_machine(drop = TRUE, density_to_set = FALSE)
	if(!state_open && !panel_open)
		if(occupant)
			thaw_them(occupant)
			play_power_sound()
		playsound(src, 'sound/machines/click.ogg', 60, TRUE)
		flick("[initial(icon_state)]-anim", src)
		. = ..()

/obj/machinery/stasissleeper/close_machine(atom/movable/target, density_to_set = TRUE)
	if((isnull(target) || istype(target)) && state_open && !panel_open)
		playsound(src, 'sound/machines/click.ogg', 60, TRUE)
		flick("[initial(icon_state)]-anim", src)
		. = ..(target)
		var/mob/living/mob_occupant = occupant
		if(occupant)
			play_power_sound()
		if(mob_occupant && mob_occupant.stat != DEAD)
			to_chat(mob_occupant, "[enter_message]")

		if (stasis_running())
			chill_out(mob_occupant)

/obj/machinery/stasissleeper/proc/play_power_sound()
	var/_running = stasis_running()
	if(last_stasis_sound != _running)
		var/sound_freq = rand(5120, 8800)
		if(!(_running))
			playsound(src, 'sound/machines/synth_yes.ogg', 50, TRUE, frequency = sound_freq)
		else
			playsound(src, 'sound/machines/synth_no.ogg', 50, TRUE, frequency = sound_freq)
		last_stasis_sound = _running

/obj/machinery/stasissleeper/Exited(atom/movable/AM, atom/newloc)
	if(!state_open && AM == occupant)
		container_resist_act(AM)
	. = ..()

/obj/machinery/stasissleeper/container_resist_act(mob/living/user)
	visible_message(span_notice("[occupant] emerges from [src]!"),
		span_notice("You climb out of [src]!"))
	open_machine()
	if(HAS_TRAIT(user, TRAIT_STASIS))
		thaw_them(user)

/obj/machinery/stasissleeper/proc/stasis_running()
	return !(state_open) && is_operational

/obj/machinery/stasissleeper/update_icon_state()
	icon_state = "[occupant ? "o-" : null][base_icon_state][state_open ? "-open" : null]"
	return ..()

/obj/machinery/stasissleeper/power_change()
	. = ..()
	play_power_sound()

/obj/machinery/stasissleeper/proc/chill_out(mob/living/target)
	if(!isnull(target) && target != occupant)
		return
	var/freq = rand(24750, 26550)
	playsound(src, 'sound/effects/spray.ogg', 5, TRUE, 2, frequency = freq)
	target.apply_status_effect(/datum/status_effect/grouped/stasis, STASIS_MACHINE_EFFECT)
	ADD_TRAIT(target, TRAIT_TUMOR_SUPPRESSED, TRAIT_GENERIC)
	target.extinguish_mob()
	use_power = ACTIVE_POWER_USE

/obj/machinery/stasissleeper/proc/thaw_them(mob/living/target)
	target.remove_status_effect(/datum/status_effect/grouped/stasis, STASIS_MACHINE_EFFECT)
	REMOVE_TRAIT(target, TRAIT_TUMOR_SUPPRESSED, TRAIT_GENERIC)
	if(target == occupant)
		use_power = IDLE_POWER_USE

/obj/machinery/stasissleeper/process()
	if(!(occupant && isliving(occupant) && check_nap_violations()))
		use_power = IDLE_POWER_USE
		return
	var/mob/living/L_occupant = occupant
	if(stasis_running())
		if(!HAS_TRAIT(L_occupant, TRAIT_STASIS))
			chill_out(L_occupant)
	else if(HAS_TRAIT(L_occupant, TRAIT_STASIS))
		thaw_them(L_occupant)

/obj/machinery/stasissleeper/screwdriver_act(mob/living/user, obj/item/used_item)
	. = ..()
	if(.)
		return
	if(occupant)
		balloon_alert(user, "occupied!")
		return
	if(state_open)
		balloon_alert(user, "close it first!")
		return
	default_deconstruction_screwdriver(user, "[initial(icon_state)]-o", initial(icon_state), used_item)

/obj/machinery/stasissleeper/wrench_act(mob/living/user, obj/item/used_item)
	. = ..()
	default_change_direction_wrench(user, used_item)

/obj/machinery/stasissleeper/crowbar_act(mob/living/user, obj/item/used_item)
	. = ..()
	if(default_pry_open(used_item))
		return TRUE
	default_deconstruction_crowbar(used_item)

/obj/machinery/stasissleeper/default_pry_open(obj/item/used_item)
	if(occupant)
		thaw_them(occupant)
	. = !(state_open || panel_open || (obj_flags & NO_DECONSTRUCTION)) && used_item.tool_behaviour == TOOL_CROWBAR
	if(.)
		used_item.play_tool_sound(src, 50)
		visible_message(span_notice("[usr] pries open [src]."), span_notice("You pry open [src]."))
		open_machine()

/obj/machinery/stasissleeper/AltClick(mob/user)
	if(!is_operational || !user.can_perform_action(src, ALLOW_SILICON_REACH))
		return FALSE

	wound_mode = !wound_mode
	var/mode_string = (wound_mode ? "wounds" : "health")
	balloon_alert(user, "now scanning [mode_string]")
	return TRUE

/obj/machinery/stasissleeper/attack_hand(mob/user)
	if(!is_operational || !user.can_perform_action(src, ALLOW_SILICON_REACH))
		return FALSE
	if (state_open)
		close_machine()
	else
		open_machine()
	return TRUE

/obj/machinery/stasissleeper/attack_hand_secondary(mob/user)
	if(!is_operational || !user.can_perform_action(src, ALLOW_SILICON_REACH))
		return FALSE
	if (occupant)
		if (wound_mode)
			balloon_alert(user, "scanning wounds")
			woundscan(user, occupant)
		else
			balloon_alert(user, "scanning health")
			healthscan(user, occupant, mode = condensed_mode, advanced = advanced_scan)
		chemscan(user, occupant)
	else
		balloon_alert(user, "no occupant!")
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/stasissleeper/attack_ai(mob/user)
	attack_hand(user)

/obj/machinery/stasissleeper/attack_robot(mob/user)
	attack_hand(user)

/obj/machinery/stasissleeper/attack_ai_secondary(mob/user) // this works for borgs and ais shrug
	attack_hand_secondary(user)

/obj/machinery/stasissleeper/MouseDrop_T(mob/living/target, mob/living/user) // pasted from disposal bin code
	if(istype(target))
		stuff_mob_in(target, user)

/obj/machinery/stasissleeper/proc/stuff_mob_in(mob/living/target, mob/living/user)
	if(!user.can_perform_action(src))
		return FALSE
	if(!isturf(user.loc)) //No magically doing it from inside closets
		return FALSE
	if(target.buckled || target.has_buckled_mobs())
		return FALSE
	if(target.mob_size > MOB_SIZE_HUMAN)
		to_chat(user, span_warning("[target] doesn't fit inside [src]!"))
		return FALSE
	if (occupant)
		balloon_alert(user, "occupied!")
		return FALSE
	add_fingerprint(user)
	if (Adjacent(target))
		close_machine(target)
		return TRUE

	if(user == target)
		user.visible_message(span_warning("[user] starts climbing into [src]."), span_notice("You start climbing into [src]..."))
	else
		target.visible_message(span_danger("[user] starts putting [target] into [src]."), span_userdanger("[user] starts putting you into [src]!"))

	if(do_after(user, 2 SECONDS, target))
		if (!loc)
			return FALSE
		if(user == target)
			user.visible_message(span_warning("[user] climbs into [src]."), span_notice("You climb into [src]."))
			. = TRUE
		else
			target.visible_message(span_danger("[user] places [target] in [src]."), span_userdanger("[user] places you in [src]."))
			log_combat(user, target, "stuffed", addition="into [src]")
			target.LAssailant = WEAKREF(user)
			. = TRUE
		close_machine(target)
		update_appearance()

/obj/machinery/stasissleeper/relaymove(mob/living/user, direction)
	if (user == occupant)
		container_resist_act()

/obj/machinery/stasissleeper/RefreshParts()
	. = ..()

	if(!length(component_parts))
		return
	for (var/obj/item/stock_parts/scanning_module/scanner in component_parts)
		if (scanner.rating <= 1)
			condensed_mode = SCANNER_CONDENSED
			advanced_scan = FALSE
		else if (scanner.rating == 2)
			condensed_mode = SCANNER_VERBOSE
			advanced_scan = FALSE
		else if (scanner.rating >= 3)
			condensed_mode = SCANNER_VERBOSE
			advanced_scan = TRUE

		break

