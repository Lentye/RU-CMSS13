#define PYLON_REPAIR_TIME (4 SECONDS)
#define PYLON_WEEDS_REGROWTH_TIME (15 SECONDS)

/obj/effect/alien/resin/special/pylon/core/heart
	name = XENO_STRUCTURE_HEART
	desc = "A giant pulsating mound of mass and bodies. It looks very much alive."
	icon_state = "heart"
	health = 2400
	light_range = 6
	cover_range = WEED_RANGE_HEART
	node_type = /obj/effect/alien/weeds/node/pylon
	hardcore = FALSE
	next_attacked_message = 5 SECONDS
	last_attacked_message = 0
	warn = TRUE // should we warn of hivecore destruction?
	heal_amount = 100
	heal_interval = 10 SECONDS
	last_healed = 0
	last_attempt = 0 // logs time of last attempt to prevent spam. if you want to destroy it, you must commit.
	last_larva_time = 0
	last_larva_pool_time = 0
	last_surge_time = 0
	spawn_cooldown = 30 SECONDS
	surge_cooldown = 90 SECONDS
	surge_incremental_reduction = 3 SECONDS
	var/heart_north_west_corner
	var/heart_north_east_corner
	var/heart_south_west_corner
	var/heart_south_east_corner

	plane = FLOOR_PLANE

	protection_level = TURF_PROTECTION_OB

	lesser_drone_spawn_limit = 10

/obj/effect/alien/resin/special/pylon/core/heart/Initialize(mapload, datum/hive_status/hive_ref)
	. = ..()

	// Pick the closest xeno resource activator

	update_minimap_icon()

	if(hive_ref)
		hive_ref.set_hive_location(src, linked_hive.hivenumber)

/obj/effect/alien/resin/special/pylon/core/heart/update_minimap_icon()
	SSminimaps.remove_marker(src)
	SSminimaps.add_marker(src, get_minimap_flag_for_faction(linked_hive?.hivenumber), image('code_ru/icons/ui_icons/map_blips.dmi', null, "xeno_heart"))

/obj/effect/alien/resin/special/pylon/core/heart/attackby(obj/item/attack_item, mob/user)
	if(!istype(attack_item, /obj/item/grab) || !isxeno(user))
		return ..(attack_item, user)

	var/larva_amount = 0 // The amount of larva they get

	var/obj/item/grab/grab = attack_item
	if(!isxeno(grab.grabbed_thing))
		return
	var/mob/living/carbon/carbon_mob = grab.grabbed_thing
	if(carbon_mob.buckled)
		to_chat(user, SPAN_XENOWARNING("Unbuckle first!"))
		return
	if(!linked_hive || carbon_mob.stat != DEAD)
		return

	if(SSticker.mode && !(SSticker.mode.flags_round_type & MODE_XVX))
		return // For now, disabled on gamemodes that don't support it (primarily distress signal)

	// Will probably allow for hives to slowly gain larva by killing hostile xenos and taking them to the hive core
	// A self sustaining cycle until one hive kills more of the other hive to tip the balance

	// Makes attacking hives very profitable if they can successfully wipe them out without suffering any significant losses
	var/mob/living/carbon/xenomorph/xeno = carbon_mob
	if(xeno.hivenumber != linked_hive.hivenumber)
		if(isqueen(xeno))
			larva_amount = 5
		else
			larva_amount += max(xeno.tier, 1) // Now you always gain larva.
	else
		return

	if(!do_after(user, 10, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_GENERIC))
		return

	visible_message(SPAN_DANGER("[src] engulfs [xeno] in resin!"))
	playsound(src, "alien_resin_build", 25, 1)
	qdel(xeno)

	linked_hive.stored_larva += larva_amount
	linked_hive.hive_ui.update_burrowed_larva()

/obj/effect/alien/resin/special/pylon/core/heart/attack_alien(mob/living/carbon/xenomorph/M)
	if(M.a_intent != INTENT_HELP && M.can_destroy_special() && M.hivenumber == linked_hive.hivenumber)
		if(!hardcore && last_attempt + 6 SECONDS > world.time)
			to_chat(M,SPAN_WARNING("We have attempted to destroy \the [src] too recently! Wait a bit!")) // no spammy
			return XENO_NO_DELAY_ACTION

		else if(warn && world.time > XENOMORPH_PRE_SETUP_CUTOFF)
			if((alert(M, "Are we sure that you want to destroy the hive core? (There will be a 5 minute cooldown before you can build another one.)", , "Yes", "No") != "Yes"))
				return XENO_NO_DELAY_ACTION

			INVOKE_ASYNC(src, PROC_REF(startDestroying),M)
			return XENO_NO_DELAY_ACTION

		else if(world.time < XENOMORPH_PRE_SETUP_CUTOFF)
			if((alert(M, "Are we sure that we want to remove the hive core? No cooldown will be applied.", , "Yes", "No") != "Yes"))
				return XENO_NO_DELAY_ACTION

			INVOKE_ASYNC(src, PROC_REF(startDestroying),M)
			return XENO_NO_DELAY_ACTION

	if(linked_hive)
		var/current_health = health
		if(hardcore && HIVE_ALLIED_TO_HIVE(M.hivenumber, linked_hive.hivenumber))
			return XENO_NO_DELAY_ACTION
		. = ..()

		if(hardcore && last_attacked_message < world.time && current_health > health)
			xeno_message(SPAN_XENOANNOUNCE("The hive core is under attack!"), 2, linked_hive.hivenumber)
			last_attacked_message = world.time + next_attacked_message
	else
		. = ..()

/obj/effect/alien/resin/special/pylon/core/heart/Destroy()
	if(linked_hive)
		visible_message(SPAN_XENOHIGHDANGER("The resin roof withers away as \the [src] dies!"), max_distance = WEED_RANGE_CORE)
		linked_hive.hive_location = null
		if(world.time < XENOMORPH_PRE_SETUP_CUTOFF && !hardcore)
			. = ..()
			return
		linked_hive.hivecore_cooldown = TRUE
		INVOKE_ASYNC(src, PROC_REF(cooldownFinish),linked_hive) // start cooldown
		if(hardcore)
			xeno_message(SPAN_XENOANNOUNCE("We can no longer gain new sisters or another Queen. Additionally, we are unable to heal if our Queen is dead."), 2, linked_hive.hivenumber)
			linked_hive.hardcore = TRUE
			linked_hive.allow_queen_evolve = FALSE
			linked_hive.hive_structures_limit[XENO_STRUCTURE_HEART] = 0
			xeno_announcement("\The [linked_hive.name] has lost their hive core!", "everything", HIGHER_FORCE_ANNOUNCE)

		if(linked_hive.hijack_burrowed_surge)
			visible_message(SPAN_XENODANGER("We hear something resembling a scream from [src] as it's destroyed!"))
			xeno_message(SPAN_XENOANNOUNCE("Psychic pain storms throughout the hive as [src] is destroyed! We will no longer gain burrowed larva over time."), 3, linked_hive.hivenumber)
			linked_hive.hijack_burrowed_surge = FALSE

	SSminimaps.remove_marker(src)
	. = ..()

/obj/effect/alien/resin/special/pylon/core/heart/startDestroying(mob/living/carbon/xenomorph/M)
	xeno_message(SPAN_XENOANNOUNCE("[M] is destroying \the [src]!"), 3, linked_hive.hivenumber)
	visible_message(SPAN_DANGER("[M] starts destroying \the [src]!"))
	last_attempt = world.time //spamcheck
	if(!do_after(M, 5 SECONDS , INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_HOSTILE))
		to_chat(M,SPAN_WARNING("You stop destroying \the [src]."))
		visible_message(SPAN_WARNING("[M] stops destroying \the [src]."))
		last_attempt = world.time // update the spam check
		return XENO_NO_DELAY_ACTION
	qdel(src)

/obj/effect/alien/resin/special/pylon/core/heart/cooldownFinish(datum/hive_status/linked_hive)
	sleep(HIVECORE_COOLDOWN)
	if(linked_hive.hivecore_cooldown) // check if its true so we don't double set it.
		linked_hive.hivecore_cooldown = FALSE
		xeno_message(SPAN_XENOANNOUNCE("The weeds have recovered! A new hive core can be built!"), 3, linked_hive.hivenumber)
	else
		log_admin("Hivecore cooldown reset proc aborted due to hivecore cooldown var being set to false before the cooldown has finished!")
		// Tell admins that this condition is reached so they know what has happened if it fails somehow
		return

/obj/effect/alien/resin/special/heart_part
	name = XENO_STRUCTURE_HEART
	icon = 'code_ru/icons/mob/xenos/structures96x128.dmi'
	health = 2400
	maxhealth = 2400
	plane = GAME_PLANE
	opacity = TRUE

/obj/effect/alien/resin/special/heart_part/North_west
	bound_width = 128
	bound_height = 96
	icon_state = "heart_north_west"

/obj/effect/alien/resin/special/heart_part/North_east
	bound_width = 96
	bound_height = 128
	icon_state = "heart_north_east"

/obj/effect/alien/resin/special/heart_part/South_west
	bound_width = 96
	bound_height = 128
	icon_state = "heart_south_west"

/obj/effect/alien/resin/special/heart_part/South_east
	bound_width = 128
	bound_height = 96
	icon_state = "heart_south_east"

#undef PYLON_REPAIR_TIME
#undef PYLON_WEEDS_REGROWTH_TIME
