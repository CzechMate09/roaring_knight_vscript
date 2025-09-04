CollectEventsInScope
({
	OnGameEvent_teamplay_flag_event = function(params)
	{
		local eventtype = params.eventtype
		if (eventtype == 1) // pick up
		{
			local player = EntIndexToHScript(params.player)
			PlaySoundOnAllClients("chapter_3/audiogroup_default/snd_board_mantle_laugh_fast.wav")
			ClientPrint(player, HUD_PRINTCENTER, "You have recieved the Shadow Mantle!\nAll incoming damage reduced by 66%")
			Shadow_mantle_holder = player

			if (First_SM_holder == true) 
			{
				local player_name = GetPlayerName(player)
				ClientPrint(null, HUD_PRINTTALK, "\x07ffff00" + "[BOSS] Player" + " '" + player_name + "' "+ "has recieved the Shadow Mantle! All incoming damage reduced by 66%.")
				First_SM_holder = false
			}
		}

		if (eventtype == 4) // flag dropped
		{
			Shadow_mantle_holder = null
		}

		if (eventtype == 5) // flag returned
		{
			Shadow_mantle_holder = null
			GiveMantleRandom()
		}
	}	
})