
/datum/action/xeno_action/onclick/toggle_long_range/reanimator
	handles_movement = FALSE
	should_delay = FALSE

/datum/action/xeno_action/activable/chem_empower
	name = "Inject chemicals"
	action_icon_state = "apply_salve"
	ability_name = "Inject_chemicals"
	var/max_range = 1
	macro_path = /datum/action/xeno_action/verb/verb_chem_empower
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_1
	xeno_cooldown = 0.5 SECONDS

/datum/action/xeno_action/activable/chem_empower/use_ability(atom/target_atom)
	if(!action_cooldown_check())
		return
	var/mob/living/carbon/xenomorph/xeno = owner
	xeno.xeno_chem_empower(target_atom, max_range)
	apply_cooldown()
	return ..()

/datum/action/xeno_action/verb/verb_chem_empower()
	set category = "Alien"
	set name = "Inject Chemicals"
	set hidden = TRUE
	var/action_name = "Inject chemicals"
	handle_xeno_macro(src, action_name)

/mob/living/carbon/xenomorph/proc/xeno_chem_empower(mob/living/carbon/xenomorph/target_xeno, max_range = 1)

	if(!check_plasma(100 * 2))
		return

	if(!istype(target_xeno))
		return

	if(target_xeno == src)
		to_chat(src, SPAN_XENOWARNING("We can't inject ourself with our own chemicals,that's meaningless!"))
		return

	if(!check_state())
		return

	if(!can_not_harm(target_xeno)) //We don't wanna heal hostile hives, but we do want to heal our allies!
		to_chat(src, SPAN_XENOWARNING("[target_xeno] is hostile to our hive!"))
		return

	if(!isturf(loc))
		to_chat(src, SPAN_XENOWARNING("We can't inject from here!"))
		return

	if(get_dist(src, target_xeno) > max_range)
		to_chat(src, SPAN_XENOWARNING("We need to be closer to [target_xeno] to inject our chemicals!"))
		return

	if(target_xeno.stat == DEAD)
		to_chat(src, SPAN_XENOWARNING("[target_xeno] is dead!"))
		return

	var/speed_buff_amount = 0.4
	var/speed_duration = 15 SECONDS
	face_atom(target_xeno)
	use_plasma(100 * 2)
	updatehealth()
	target_xeno.xeno_jitter(1 SECONDS)
	to_chat(target_xeno, SPAN_XENONOTICE("The [name] invigorates us to move faster!"))
	new /datum/effects/xeno_speed(target_xeno, ttl = speed_duration, set_speed_modifier = speed_buff_amount, set_modifier_source = XENO_FRUIT_SPEED, set_end_message = SPAN_XENONOTICE("We feel the effects of the injection wane..."))
	to_chat(target_xeno, SPAN_XENOWARNING("[src] injects fluids through our skin with strange feeling. We feel reinvigorated!"))
	to_chat(src, SPAN_XENOWARNING("We share our fluids by spine needles to empower [target_xeno]. We feel exhausted..."))
	playsound(src, "alien_drool", 25)
	update_icons()

/datum/action/xeno_action/onclick/choose_resin/reanimator_macro
	name = "Choose Resin Structure"
	action_icon_state = "retrieve_egg"
	plasma_cost = 0
	macro_path = /datum/action/xeno_action/verb/verb_choose_resin_structure
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_4

// Secrete Resin
/datum/action/xeno_action/activable/secrete_resin/reanimator_macro
	name = "Secrete Resin"
	action_icon_state = "secrete_resin"
	ability_name = "secrete resin"
	thick = TRUE
	make_message = TRUE
	macro_path = /datum/action/xeno_action/verb/verb_secrete_resin
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_5

	build_speed_mod = 1

	plasma_cost = 1
