/datum/tech/droppod/item/experimentals
	name = "Combat Experimentals"
	desc = "Морпехи получают доступ к передовым эксперементальным технологиям для улучшения производительности на поле боя."
	icon_state = "stimulants"
	droppod_name = "Experimentals"

	flags = TREE_FLAG_MARINE

	required_points = 20
	tier = /datum/tier/three/additional

	droppod_input_message = "Choose an experimental to retrieve from the droppod."
	options_to_give = 2

/datum/tech/droppod/item/experimentals/get_options(mob/living/carbon/human/H, obj/structure/droppod/D)
	. = ..()

	if(!H || skillcheck(H, SKILL_ENGINEER, SKILL_ENGINEER_ENGI))
		.["incision management system"] = /obj/item/tool/surgery/scalpel/manager
	if(!H || skillcheck(H, SKILL_ENGINEER, SKILL_ENGINEER_ENGI))
		.["Breaching Hammer"] = /obj/item/weapon/twohanded/breacher

	.["Experimental Hoverpack"] = /obj/item/hoverpack
	.["Speed Stimulant"] = /obj/item/reagent_container/hypospray/autoinjector/stimulant/speed_stimulant
	.["Brain Stimulant"] = /obj/item/reagent_container/hypospray/autoinjector/stimulant/brain_stimulant
