/datum/admins/proc/end_round_ru()
	set name = "Choose Win Side"
	set desc = "Immediately ends the round and sets the winner, be very careful"
	set category = "Server.Round"

	if(!check_rights(R_SERVER) || !SSticker.mode)
		return

	if(alert("Are you sure you want to end the round?",,"Yes","No") != "Yes")
		return
	// trying to end the round before it even starts. bruh
	if(!SSticker.mode)
		return

	if(SSticker.mode.type == /datum/game_mode/colonialmarines)
		var/list/options =  list(
	MODE_INFESTATION_X_MAJOR="Xenomorph Major Victory",
	MODE_INFESTATION_M_MAJOR="Marine Major Victory",
	MODE_INFESTATION_X_MINOR="Xenomorph Minor Victory",
	MODE_INFESTATION_M_MINOR="Marine Minor Victory",
	MODE_INFESTATION_DRAW_DEATH="DRAW: Mutual Annihilation",
		)
		SSticker.mode.round_finished = tgui_input_list(usr, "Select what you want the game-mode end like.", "End Options", options)
		return
	if(SSticker.mode.type == /datum/game_mode/whiskey_outpost)
		var/list/options =  list(
	"Xenomorph Major",
	"Marine Major",
	"Neutral Ending",
		)
		var/final_choose
		var/datum/game_mode/whiskey_outpost/mod = SSticker.mode
		var/selection = tgui_input_list(usr, "Select what you want the game-mode end like.", "End Options", options)
		switch(selection)
			if("Xenomorph Major")
				final_choose = 1
			if("Marine Major")
				final_choose = 2
			if("Neutral Ending")
				final_choose = 3
		mod.finished = final_choose
		return
	else
		to_chat(usr, SPAN_BOLDNOTICE("No special endings available for that gamemode"))
		return

