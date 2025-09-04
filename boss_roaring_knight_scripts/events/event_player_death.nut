CollectEventsInScope
({
	OnGameEvent_player_death = function(params)
	{
		local alive_players = GetAlivePlayers()

		if (alive_players.len() - 1 <= 0 && 
			InSetup() == false &&
			IsInWaitingForPlayers() == false &&
			GetRKnightHealth() > 0 &&
			Round_started == true) // Death screen if all players are dead and the boss is still alive
		{
			Round_started = false
			local all_players = GetAllPlayers()
			foreach (player in all_players)
			{
				player.SetScriptOverlayMaterial("roaring_knight/spr_roaringknight_slash_white_horizontal") // Evil and intimidating Nike logo
				Schedule(4.0, function(player){
					player.SetScriptOverlayMaterial("")
				}, [player])
			}

			PlaySoundOnAllClients("chapter_3/audio_sfx/snd_damage.wav", 1.0, 20)
			PlaySoundOnAllClients("chapter_3/audio_sfx/snd_damage.wav", 1.0, 20)
			PlaySoundOnAllClients("chapter_3/audio_sfx/snd_damage.wav", 1.0, 20)

			Schedule(4.0, function(){
				PlaySoundOnAllClients("chapter_3/audiogroup_default/snd_glassbreak.wav", 1.0, 30)
				PlaySoundOnAllClients("chapter_3/audiogroup_default/snd_glassbreak.wav", 1.0, 30)
				Schedule(2.0, function(){
					Blue_win()
				})
			})
		}
	}
})