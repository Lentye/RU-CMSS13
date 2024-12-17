/datum/caste_datum/reanimator
	caste_type = XENO_CASTE_REANIMATOR
	tier = 0
	melee_damage_lower = XENO_DAMAGE_TIER_1
	melee_damage_upper = XENO_DAMAGE_TIER_2
	melee_vehicle_damage = XENO_DAMAGE_TIER_2
	max_health = XENO_HEALTH_TIER_4
	plasma_gain = 0 //Вообще не регенит плазму сам, палагается на других
	plasma_max = XENO_PLASMA_TIER_10*2
	xeno_explosion_resistance = XENO_NO_EXPLOSIVE_ARMOR
	armor_deflection = XENO_NO_ARMOR
	evasion = XENO_EVASION_NONE
	speed = XENO_SPEED_TIER_8 //быстрый, но не бронированный

	build_time_mult = 2

	caste_desc = "A support specie created by unstable chemical mutations. Dont regain plasma itself, weaker then drone at combat but faster."
	evolution_allowed = FALSE
	deevolves_to = FALSE
	can_hold_facehuggers = 1
	can_hold_eggs = CAN_HOLD_TWO_HANDS
	acid_level = 3
	caste_luminosity = 2
	weed_level = WEED_LEVEL_STANDARD
	max_build_dist = 1
	can_be_revived = FALSE

	tackle_min = 3
	tackle_max = 4
	tacklestrength_min = 3
	tacklestrength_max = 4

	aura_strength = 4

	minimap_icon = "Reanimator"

/datum/caste_datum/reanimator/New()
	. = ..()

	resin_build_order = GLOB.resin_build_order_drone

/mob/living/carbon/xenomorph/reanimator
	caste_type = XENO_CASTE_REANIMATOR
	name = XENO_CASTE_REANIMATOR
	desc = "An alien reanimator"
	icon = 'icons/mob/xenos/reanimator.dmi'
	icon_size = 48
	icon_state = "Reanimator Walking"
	plasma_types = list(PLASMA_PURPLE, PLASMA_PHEROMONE, PLASMA_CATECHOLAMINE)
	tier = 0
	organ_value = 4000
	pixel_x = -12
	old_x = -12
	base_actions = list(
		/datum/action/xeno_action/onclick/xeno_resting,
		/datum/action/xeno_action/onclick/regurgitate,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/tail_stab,
		/datum/action/xeno_action/activable/corrosive_acid/strong,
		/datum/action/xeno_action/onclick/emit_pheromones,
		/datum/action/xeno_action/activable/place_construction,
		//first macro
		//second macro
		//third macro
		/datum/action/xeno_action/onclick/choose_resin, //fourth macro
		/datum/action/xeno_action/activable/secrete_resin, //fifth macro
		/datum/action/xeno_action/onclick/tacmap,
		)
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,
		/mob/living/carbon/xenomorph/proc/rename_tunnel,
		/mob/living/carbon/xenomorph/proc/set_hugger_reserve_for_morpher,
	)

	icon_xeno = 'icons/mob/xenos/reanimator.dmi'
	icon_xenonid = 'icons/mob/xenonids/reanimator.dmi'
	weed_food_icon = 'icons/mob/xenos/weeds_48x48.dmi'
	weed_food_states = list("Reanimator_1","Reanimator_2","Reanimator_3")
	weed_food_states_flipped = list("Reanimator_1","Reanimator_2","Reanimator_3")
