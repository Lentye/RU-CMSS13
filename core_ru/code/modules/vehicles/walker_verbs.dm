//README: Be aware, what add_verb from vehicle makes src be client,so ensure src is mech and user is mech-operator,if you're making new verbs

/obj/vehicle/walker/proc/exit_walker(mob/pilot)
	set name = "Eject"
	set category = "Vehicle"

	var/mob/user = usr
	if(pilot) //overriding external usr from destroying to internal pilot
		user = pilot
	if(!istype(src, /obj/vehicle/walker))
		src = user.interactee
	if(!mech_link_check(src, user))
		log_debug("Wrong Mech Parameters detected, user[user] or src[src]")
		return FALSE

	if(zoom)
		unzoom()

	if(user.client)
		user.client.mouse_pointer_icon = initial(user.client.mouse_pointer_icon)

	user.unset_interaction()
	user.loc = get_turf(src)
	user.reset_view(null)
	if(user.client)
		remove_verb(user.client, verb_list)
	UnregisterSignal(user, COMSIG_MOB_RESISTED)

	if(module_map[WALKER_HARDPOIN_LEFT])
		module_map[WALKER_HARDPOIN_LEFT].unregister_signals(user)
	if(module_map[WALKER_HARDPOIN_RIGHT])
		module_map[WALKER_HARDPOIN_RIGHT].unregister_signals(user)

	seats[VEHICLE_DRIVER] = null
	update_icon()
	return TRUE


/obj/vehicle/walker/proc/toggle_lights()
	set name = "Lights on/off"
	set category = "Vehicle"

	if(!istype(src, /obj/vehicle/walker))
		src = usr.interactee
	var/mob/user = usr
	if(!mech_link_check(src, user))
		log_debug("Wrong Mech Parameters detected, user[user] or src[src]")
		return FALSE

	if(lights)
		lights = FALSE
		set_light(-lights_power)
	else
		lights = TRUE
		set_light(lights_power)

	playsound(src, 'sound/machines/click.ogg', 50)
	return TRUE


/obj/vehicle/walker/proc/eject_magazine()
	set name = "Eject Magazine"
	set category = "Vehicle"

	if(!istype(src, /obj/vehicle/walker))
		src = usr.interactee
	var/mob/user = usr
	if(!mech_link_check(src, user))
		log_debug("Wrong Mech Parameters detected, user[user] or src[src]")
		return FALSE

	var/list/acceptible_modules = list()
	if(module_map[WALKER_HARDPOIN_LEFT]?.ammo)
		acceptible_modules += module_map[WALKER_HARDPOIN_LEFT]
	if(module_map[WALKER_HARDPOIN_RIGHT]?.ammo)
		acceptible_modules += module_map[WALKER_HARDPOIN_RIGHT]

	if(!length(acceptible_modules))
		to_chat(user, "Not found magazines to eject")
		return FALSE

	var/obj/item/walker_gun/hardpoint = tgui_input_list(usr, "Select a hardpoint to eject magazine.", "Eject Magazine", acceptible_modules)
	if(!hardpoint || !hardpoint.ammo)
		return FALSE

	hardpoint.ammo.forceMove(get_turf(src))
	hardpoint.ammo = null
	to_chat(user, SPAN_WARNING("WARNING! [hardpoint.name] ammo magazine deployed."))
	visible_message("[name]'s systems ejected used magazine.","")
	return TRUE


/obj/vehicle/walker/proc/get_stats()
	set name = "Status Display"
	set category = "Vehicle"

	if(!istype(src, /obj/vehicle/walker))
		src = usr.interactee
	var/mob/user = usr
	if(!mech_link_check(src, user))
		log_debug("Wrong Mech Parameters detected, user[user] or src[src]")
		return FALSE

	tgui_interact(user)
	return TRUE

/obj/vehicle/walker/proc/toggle_zoom()
	set name = "Zoom on/off"
	set category = "Vehicle"

	if(!istype(src, /obj/vehicle/walker))
		src = usr.interactee
	var/mob/user = usr
	if(!mech_link_check(src, user))
		log_debug("Wrong Mech Parameters detected, user[user] or src[src]")
		return FALSE

	if(zoom)
		unzoom()
	else
		do_zoom()
	return TRUE

/obj/vehicle/walker/proc/mech_link_check(obj/vehicle/walker/walker, mob/user)
	if(!istype(user))
		return FALSE
	if(!istype(walker))
		return FALSE
	else
		return TRUE
