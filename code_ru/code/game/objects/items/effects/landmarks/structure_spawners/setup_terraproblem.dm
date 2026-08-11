/obj/effect/landmark/structure_spawner/setup/terraproblem
	name = "abstract terraproblem spawner"
	icon = 'code_ru/icons/landmarks.dmi'
	mode_flags = MODE_TERRAPROBLEM

/obj/effect/landmark/structure_spawner/setup/terraproblem/xeno_core
	name = "TerraProblem Hive Core spawner"
	icon_state = "core"
	path_to_spawn = /obj/effect/alien/resin/special/pylon/core

/obj/effect/landmark/structure_spawner/setup/terraproblem/xeno_heart
	name = "TerraProblem Hive Heart spawner"
	icon_state = "heart"
	path_to_spawn = /obj/effect/alien/resin/special/pylon/core/heart

/obj/effect/landmark/structure_spawner/setup/terraproblem/xeno_wall
	name = "TerraProblem Xeno wall spawner"
	icon_state = "wall"
	path_to_spawn = /turf/closed/wall/resin
	is_turf = TRUE

/obj/effect/landmark/structure_spawner/setup/terraproblem/xeno_membrane
	name = "TerraProblem Xeno membrane spawner"
	icon_state = "membrane"
	path_to_spawn = /turf/closed/wall/resin/membrane
	is_turf = TRUE

/obj/effect/landmark/structure_spawner/setup/terraproblem/xeno_door
	name = "TerraProblem Xeno door spawner"
	icon_state = "door"
	path_to_spawn = /obj/structure/mineral_door/resin

/obj/effect/landmark/structure_spawner/setup/terraproblem/xeno_nest
	name = "TerraProblem Xeno nest spawner"
	icon_state = "nest"
	path_to_spawn = /obj/structure/bed/nest

/obj/effect/landmark/structure_spawner/setup/terraproblem/xeno_weed_node
	name = "TerraProblem Xeno weed node spawner"
	icon_state = "weednode"
	path_to_spawn = /obj/effect/alien/weeds/node

/obj/effect/landmark/structure_spawner/setup/terraproblem/xeno_sticky
	name = "TerraProblem Xeno sticky spawner"
	icon = 'code_ru/icons/mob/xenos/effects.dmi'
	icon_state = "sticky"
	path_to_spawn = /obj/effect/alien/resin/sticky

/obj/effect/landmark/structure_spawner/setup/terraproblem/xeno_wall_reinforced
	name = "TerraProblem Xeno reinforced wall spawner"
	icon_state = "wall_r"
	path_to_spawn = /turf/closed/wall/resin/thick
	is_turf = TRUE

/obj/effect/landmark/structure_spawner/setup/terraproblem/xeno_door_reinforced
	name = "TerraProblem Xeno reinforced door spawner"
	icon_state = "door_r"
	path_to_spawn = /obj/structure/mineral_door/resin/thick
