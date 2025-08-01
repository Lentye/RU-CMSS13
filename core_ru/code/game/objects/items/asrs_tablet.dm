/obj/item/device/asrs_tablet
	icon = 'icons/obj/items/devices.dmi'
	icon_state = "Cotablet"
	item_state = "Cotablet"
	name = "Tabletop"
	desc = "Tabletop used for ASRS manipulations from distance."
	unacidable = TRUE
	explo_proof = TRUE
	w_class = SIZE_SMALL
	req_access = list(ACCESS_MARINE_SENIOR)
	has_special_table_placement = TRUE

	/// if the laptop has been opened (the model not tgui)
	var/open = FALSE

	/// if the laptop is turned on and powered
	var/on = FALSE

	/// if the laptop should announce events on radio, for live server testing
	var/silent = FALSE

	var/power_consumption = 4

	var/screen_state = 0 // controls the 'loading' animation

	// radio which broadcasts updates
	var/obj/item/device/radio/marine/transceiver = new /obj/item/device/radio/marine
	// the hidden mob which voices updates
	var/mob/living/voice = new /mob/living/silicon

	var/datum/controller/supply/linked_supply_controller
	var/faction = FACTION_MARINE
	var/asrs_name = "Automated Storage and Retrieval System"

	/// What message should be displayed to the user when the UI is accessed
	var/system_message = null

	/// If we should prevent the current_order() contents going over the number of points
	var/calculate_max_order = FALSE

	/// What the user currently has in their cart
	var/current_order = list()

	var/id_tag_suffix

	var/cell_type = /obj/item/cell/high
	var/obj/item/cell/cell

/obj/item/device/asrs_tablet/Initialize()
	. = ..()
	id_tag_suffix = "[rand(1000, 9999)][pick(GLOB.alphabet_uppercase)][pick(GLOB.alphabet_uppercase)]"
	switch(faction)
		if(FACTION_MARINE)
			linked_supply_controller = GLOB.supply_controller
		if(FACTION_UPP)
			linked_supply_controller = GLOB.supply_controller_upp
		else
			linked_supply_controller = GLOB.supply_controller //we default to normal budget on wrong input
	LAZYADD(linked_supply_controller.bound_supply_computer_list, src)

/obj/item/device/asrs_tablet/Destroy()
	. = ..()
	QDEL_NULL(cell)

/obj/item/device/asrs_tablet/Move(NewLoc, direct)
	..()
	if(table_setup || open || on)
		teardown()

/**
 * Called to reset the state of the laptop to closed and inactive.
 */
/obj/item/device/asrs_tablet/teardown()
	. = ..()
	open = FALSE
	on = FALSE
	icon_state = "sentrycomp_cl"
	STOP_PROCESSING(SSobj, src)
	playsound(src,  'sound/machines/terminal_off.ogg', 25, FALSE)

/obj/item/device/asrs_tablet/emp_act(severity)
	. = ..()
	return TRUE

/obj/item/device/asrs_tablet/attack_hand(mob/user)
	if(!table_setup)
		return ..()
	if(!on)
		icon_state = "sentrycomp_on"
		on = TRUE
		START_PROCESSING(SSobj, src)
		playsound(src, 'sound/machines/terminal_on.ogg', 25, FALSE)
	else
		tgui_interact(user)

/obj/item/device/asrs_tablet/get_examine_text()
	. = ..()
	if(cell)
		. += "A [cell.name] is loaded. It has [cell.charge]/[cell.maxcharge] charge remaining."
	else
		. += "It has no battery inserted."

	if(table_setup)
		. += "The laptop can be dragged towards you to pick it up."
	else
		. += "The laptop must be placed on a table to be used."

/obj/item/device/asrs_tablet/process()
	if(!on || !cell)
		return

	var/energy_cost = power_consumption * CELLRATE
	if(cell.charge >= (energy_cost))
		cell.use(energy_cost)
	else
		icon_state = "sentrycomp_op"
		on = FALSE
		playsound(src,  'sound/machines/terminal_off.ogg', 25, FALSE)

/obj/item/device/asrs_tablet/attackby(obj/item/object, mob/user)
	if(istype(object, /obj/item/cell))
		var/obj/item/cell/new_cell = object
		to_chat(user, SPAN_NOTICE("The new cell contains: [new_cell.charge] power."))
		cell.forceMove(get_turf(user))
		cell = new_cell
		user.drop_inv_item_to_loc(new_cell, src)
		playsound(src,'sound/machines/click.ogg', 25, 1)

/obj/item/device/asrs_tablet/attack_remote(mob/user)
	return attack_hand(user)

/obj/item/device/asrs_tablet/tgui_interact(mob/user, datum/tgui/ui)
	. = ..()

	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "SupplyComputerTabletop", "ASRS Link")
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/item/device/asrs_tablet/ui_data(mob/user)
	. = ..()

	.["system_message"] = system_message

	.["points"] = linked_supply_controller.points

	.["requests"] = list()
	for(var/datum/supply_order/order as anything in linked_supply_controller.requestlist)
		.["requests"] += list(
			order.get_list_representation()
		)

	.["pending"] = list()
	for(var/datum/supply_order/order as anything in linked_supply_controller.shoppinglist)
		.["pending"] += list(
			order.get_list_representation()
		)

	.["current_order"] = list()
	for(var/pack_type in current_order)
		var/datum/supply_packs/pack = GLOB.supply_packs_datums[pack_type]

		var/list_pack = pack.get_list_representation()
		list_pack["quantity"] = current_order[pack_type]

		.["current_order"] += list(list_pack)

	var/datum/shuttle/ferry/supply/shuttle = linked_supply_controller.shuttle
	.["shuttle_status"] = "lowered"
	if (shuttle.has_arrive_time())
		.["shuttle_status"] = "moving"
		return

	if (shuttle.at_station() )
		.["shuttle_status"] = "raised"

		switch(shuttle.docking_controller?.get_docking_status())
			if ("docked")
				.["shuttle_status"] = "raised"
			if ("undocked")
				.["shuttle_status"] = "lowered"
			if ("docking")
				.["shuttle_status"] = "raising"
			if ("undocking")
				.["shuttle_status"] = "lowering"

/obj/item/device/asrs_tablet/ui_static_data(mob/user)
	. = ..()

	.["categories"] = linked_supply_controller.all_supply_groups

	.["all_items"] = list()
	.["valid_categories"] = list()

	.["categories_to_objects"] = list()
	for(var/pack_type in GLOB.supply_packs_datums)
		var/datum/supply_packs/pack = GLOB.supply_packs_datums[pack_type]

		if(!pack.buyable)
			continue

		if(isnull(pack.contains) && isnull(pack.containertype))
			continue

		if(!(pack.group in (list() + linked_supply_controller.all_supply_groups + linked_supply_controller.contraband_supply_groups)))
			continue

		if(!pack.contraband && length(pack.group))
			.["valid_categories"] |= pack.group

		var/list_pack = pack.get_list_representation()

		if(length(pack.group))
			if(!.["categories_to_objects"][pack.group])
				.["categories_to_objects"][pack.group] = list()

			.["categories_to_objects"][pack.group] += list(
				list_pack
			)

		.["all_items"] += list(
			list_pack
		)

/obj/item/device/asrs_tablet/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()

	if(!ishuman(ui.user))
		return
	var/mob/living/carbon/human/human_user = ui.user
	var/id_name = human_user.get_authentification_name()
	var/assignment = human_user.get_assignment()

	switch(action)
		if("place_order")
			var/to_order = list()
			for(var/item in current_order)
				var/datum/supply_packs/pack = GLOB.supply_packs_datums[item]

				if(!pack || !is_buyable(pack))
					continue

				for(var/iterator in 1 to current_order[item])
					to_order += pack

			var/datum/supply_order/supply_order = new
			supply_order.ordernum = linked_supply_controller.ordernum++
			supply_order.objects = to_order
			supply_order.orderedby = id_name
			supply_order.orderedby_rank = assignment
			supply_order.approvedby = id_name

			print_form(supply_order)

			current_order = list()

			if(supply_order.buy(src))
				return TRUE

			linked_supply_controller.requestlist += supply_order
			system_message = "Unable to purchase order, order has been placed in Requests."
			return TRUE

		if("change_order")
			var/datum/supply_order/order

			var/ordernum = params["ordernum"]
			if(!isnum(ordernum))
				return

			for(var/datum/supply_order/iter_order as anything in linked_supply_controller.requestlist)
				if(ordernum != iter_order.ordernum)
					continue

				order = iter_order
				break

			if(!istype(order))
				return

			switch(params["order_status"])
				if("approve")
					order.approvedby = id_name
					if(order.buy(src))
						return TRUE

					system_message = "Unable to approve order, order remains in Requests."
					return TRUE
				if("deny")
					linked_supply_controller.requestlist -= order
					qdel(order)

					return TRUE

		if("send")
			var/datum/shuttle/ferry/supply/shuttle = linked_supply_controller.shuttle

			if(shuttle.at_station())
				if (shuttle.forbidden_atoms_check())
					system_message = "For safety reasons, the Automated Storage and Retrieval System cannot store live organisms, classified nuclear weaponry or homing beacons."
					return TRUE
				shuttle.launch(src)
				return TRUE

			shuttle.launch(src)
			return TRUE

		if("call_down_order")
			var/datum/supply_order/order

			var/ordernum = params["ordernum"]
			if(!isnum(ordernum))
				return

			for(var/datum/supply_order/iter_order as anything in linked_supply_controller.shoppinglist)
				if(ordernum != iter_order.ordernum)
					continue

				order = iter_order
				break

			if(!istype(order))
				return

			switch(params["order_status"])
				if("calldown")
					var/x_coord
					var/y_coord
					var/z_coord
					if(linked_supply_controller.points >= 2)
						x_coord = src.x
						y_coord = src.y
						z_coord = src.z
						if(!istype(src.loc, /turf))
							x_coord = src.loc.x
							y_coord = src.loc.y
							z_coord = src.loc.z
					else
						system_message = "Unable to approve call down, not enough supply."
						return TRUE
					if(!is_ground_level(z_coord))
						to_chat(usr, "[icon2html(src, usr)] [SPAN_WARNING("The local zone appears to be out of bounds. Please check GPS device.")]")
						return TRUE

					var/turf/T = locate(x_coord, y_coord, z_coord)
					if(!T)
						to_chat(usr, "[icon2html(src, usr)] [SPAN_WARNING("Error, invalid local coordinates. Please check GPS device")]")
						return TRUE

					var/area/A = get_area(T)
					if(A && CEILING_IS_PROTECTED(A.ceiling, CEILING_PROTECTION_TIER_2))
						to_chat(usr, "[icon2html(src, usr)] [SPAN_WARNING("The local zone is underground. The supply drop cannot reach here.")]")
						return TRUE

					if(istype(T, /turf/open/space) || T.density)
						to_chat(usr, "[icon2html(src, usr)] [SPAN_WARNING("The local zone appears to be obstructed or out of bounds. Package would be lost on drop.")]")
						return TRUE
					var/obj/container
					for(var/datum/supply_packs/package as anything in order.objects)
						if(package.containertype)
							container = new package.containertype(T)
							if(package.containername)
								container.name = package.containername

						// Lock it up if it's something that can be
						if(isobj(container) && package.access)
							var/obj/lockable = container
							lockable.req_access = list(package.access)

						// Contents generation
						var/list/content_names = list()
						var/list/content_types = package.contains
						if(package.randomised_num_contained)
							content_types = list()
							for(var/i in 1 to package.randomised_num_contained)
								content_types += pick(package.contains)
						for(var/typepath in content_types)
							var/atom/item = new typepath(container)
							content_names += item.name

						// Manifest generation
						var/obj/item/paper/manifest/slip
						if(!package.contraband) // I'm sorry boss i misplaced it...
							slip = new /obj/item/paper/manifest(container)
							slip.ordername = package.name
							slip.ordernum = order.ordernum
							slip.orderedby = order.orderedby
							slip.approvedby = order.approvedby
							slip.packages = content_names
							slip.generate_contents()
							slip.update_icon()

					var/obj/structure/droppod/supply/pod = new(null, container)
					container.forceMove(pod)
					pod.launch(T)
					linked_supply_controller.points -= 2
					log_ares_requisition("Supply Drop", "Launch [container.name] to X[x_coord], Y[y_coord].", usr.real_name)
					log_game("[key_name(usr)] launched supply drop '[container.name]' to X[x_coord], Y[y_coord].")
					visible_message("[icon2html(src, viewers(src))] [SPAN_BOLDNOTICE("'[container.name]' supply drop launched! Another launch will be available in five minutes.200 credits suspended")]")
					var/list/shopping_list = linked_supply_controller.shoppinglist
					shopping_list.Remove(order)
					return TRUE

		if("force_launch")
			linked_supply_controller.shuttle.force_launch()
			return TRUE

		if("cancel_launch")
			linked_supply_controller.shuttle.cancel_launch()
			return TRUE

		if("adjust_cart")
			var/picked_pack = text2path(params["pack"])
			var/datum/supply_packs/pack = GLOB.supply_packs_datums[picked_pack]
			if(!pack || !is_buyable(pack))
				return

			var/adjust_to = params["to"]
			if(adjust_to == "min")
				current_order -= picked_pack
				return TRUE

			var/used_points = 0
			var/used_dollars = 0

			for(var/pack_type in current_order)
				var/datum/supply_packs/iter_pack = GLOB.supply_packs_datums[pack_type]
				if(isnum(adjust_to) && pack_type == picked_pack)
					continue // if manually specifying number, we calculate later how many it can be set to

				used_points += (iter_pack.cost * current_order[pack_type])
				used_dollars += (iter_pack.dollar_cost * current_order[pack_type])

			if(!isnum(adjust_to))
				return

			var/number_to_get = floor(adjust_to)
			if(!calculate_max_order)
				current_order[picked_pack] = number_to_get

				if(number_to_get <= 0)
					current_order -= picked_pack

				return TRUE

			var/cost_to_use = pack.dollar_cost ? pack.dollar_cost : pack.cost
			var/points_to_use = pack.dollar_cost ? linked_supply_controller.black_market_points : linked_supply_controller.points
			var/used_to_use = pack.dollar_cost ? used_dollars : used_points

			var/available_points = points_to_use - used_to_use

			var/number_to_hold
			if(cost_to_use * number_to_get > available_points)
				number_to_hold = floor(available_points / cost_to_use)
			else
				number_to_hold = number_to_get

			if(number_to_hold <= 0)
				current_order -= picked_pack
				return TRUE

			current_order[picked_pack] = number_to_hold
			return TRUE

		if("discard_cart")
			current_order = list()

			return TRUE

		if("request_cart")
			var/reason = params["reason"]
			if(!length(reason))
				return

			var/to_order = list()
			for(var/item in current_order)
				var/datum/supply_packs/pack = GLOB.supply_packs_datums[item]

				if(!pack || !is_buyable(pack))
					continue

				for(var/iterator in 1 to current_order[item])
					to_order += pack

			var/datum/supply_order/supply_order = new
			supply_order.ordernum = linked_supply_controller.ordernum++
			supply_order.objects = to_order
			supply_order.reason = reason
			supply_order.orderedby = id_name
			supply_order.orderedby_rank = assignment
			current_order = list()

			print_form(supply_order)

			linked_supply_controller.requestlist += supply_order
			system_message = "Thanks for your request. The cargo team will process it as soon as possible."
			return TRUE

		if("acknowledged")
			system_message = null
			return TRUE

		if("keyboard")
			playsound(src, "keyboard", 15, 1)

/obj/item/device/asrs_tablet/proc/print_form(datum/supply_order/order)
	var/list/accesses = list()

	for(var/datum/supply_packs/pack as anything in order.objects)
		var/access = get_access_desc(pack.access)
		if(length(access))
			accesses += access

	var/obj/item/paper/reqform = new(loc)
	reqform.name = "Requisition Form - #[order.ordernum]"

	reqform.info += "<h3>[MAIN_SHIP_NAME] Supply Requisition Form</h3><hr>"
	reqform.info += "INDEX: #[order.ordernum]<br>"
	reqform.info += "REQUESTED BY: [order.orderedby]<br>"
	reqform.info += "RANK: [order.orderedby_rank]<br>"
	reqform.info += "REASON: [order.reason]<br>"
	reqform.info += "ACCESS RESTRICTION: [english_list(accesses, nothing_text = "None")]<br>"
	reqform.info += "CONTENTS:<br>"
	for(var/datum/supply_packs/supply_pack as anything in order.objects)
		reqform.info += supply_pack.manifest
	reqform.info += "<hr>"
	reqform.info += "STAMP BELOW TO APPROVE THIS REQUISITION:<br>"

	reqform.update_icon()

/obj/item/device/asrs_tablet/proc/is_buyable(datum/supply_packs/supply_pack)
	if(!supply_pack.buyable)
		return FALSE

	if(supply_pack.contraband)
		return FALSE

	if(isnull(supply_pack.contains) && isnull(supply_pack.containertype))
		return FALSE

	return TRUE
