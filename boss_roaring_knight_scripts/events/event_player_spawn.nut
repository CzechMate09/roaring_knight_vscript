CollectEventsInScope
({
	OnGameEvent_player_spawn = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		player.SetScriptOverlayMaterial("") // Remove overlay if it preserved

		player.ValidateScriptScope()
		player.GetScriptScope().dmg_acc <- 0

		if (params.team == TF_TEAM_BLUE)
		{
			player.ForceChangeTeam(2, true)
			player.ForceRespawn()
		}

		// Prevent players from blocking the func_movelinear
		// This took me too fucking long to figure out.
		player.SetCollisionGroup(4)
		// player.SetSolid(4)

		// Spawn protection
		local uber_duration = 5.0
		if (Boss_difficulty == "hard")
			uber_duration = 3.4
		if (Boss_difficulty == "extreme")
			uber_duration = 1.8

		if (player != null)
		{
			player.AddCondEx(52, uber_duration, null) // Add uber to player to prevent them from dying imimediately after spawning
		}

		// Give random player the shadow mantle
		if (Shadow_mantle_holder == null &&
			InSetup() == false &&
			Round_started == true &&
			IsInWaitingForPlayers() == false)
		{
			Schedule(uber_duration + 0.5, function(){
				GiveMantleRandom()
			})
		}

		if (Intro_started == true)
		{
			teleport_players_to_arena(player)
		}

		if (InSetup() == false && 
			IsInWaitingForPlayers() == false &&
			Base_boss_setup_finished == true &&
			params.team == TF_TEAM_RED)
		{
			local player_entindex = player.entindex()

			if (accounted_players.find(player_entindex) == null)
			{
				accounted_players.append(player_entindex)

				local base_boss = Entities.FindByName(null, "base_boss_r_knight")
				local new_health = GetRKnightHealth() + base_health
				local new_max_health = GetRKnightMaxHealth() + base_health

				SetRKnightHealth(new_health)
				SetRKnightMaxHealth(new_max_health)

				// ClientPrint(null, HUD_PRINTTALK, "[DEBUG] New player joined, adding HP: +" + base_health)
				printl("-----------------------------------------")
				printl("[DEBUG] New player joined, adding HP: +" + base_health)
				printl("-----------------------------------------")
			}
		}
	}
})