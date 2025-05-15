/datum/tech/droppod/item/medic_czsp
	name = "Squad Medic Combat Zone Support Package"
	desc = "Gives medics to use powerful tools to heal marines."
	icon_state = "medic_qol"
	droppod_name = "Medic CZSP"

	flags = TREE_FLAG_MARINE

	required_points = 6
	tier = /datum/tier/one/additional

/datum/tech/droppod/item/medic_czsp/get_options(mob/living/carbon/human/H, obj/structure/droppod/D)
	. = ..()
	if(!H || skillcheck(H, SKILL_MEDICAL, SKILL_MEDICAL_MEDIC))
		.["Medical CZSP"] = /obj/item/storage/box/combat_zone_support_package
	else
		var/type_to_add = /obj/item/stack/medical/bruise_pack
		if(prob(50))
			type_to_add = /obj/item/stack/medical/ointment

		if(prob(5))
			type_to_add = /obj/item/device/healthanalyzer

		.["Random Medical Item"] = type_to_add

/obj/item/storage/box/combat_zone_support_package
	name = "Medical czsp"
	icon_state = "medicbox"
	storage_slots = 8

/obj/item/storage/box/combat_zone_support_package/Initialize()
	. = ..()
	new /obj/item/stack/medical/advanced/bruise_pack/upgraded(src)
	new /obj/item/stack/medical/advanced/bruise_pack/upgraded(src)
	new /obj/item/stack/medical/advanced/ointment/upgraded(src)
	new /obj/item/stack/medical/advanced/ointment/upgraded(src)
	new /obj/item/device/defibrillator/upgraded(src)
	new /obj/item/stack/medical/splint/nano(src)
	new /obj/item/weapon/gun/pill(src)
	new /obj/item/tool/crew_monitor(src)
