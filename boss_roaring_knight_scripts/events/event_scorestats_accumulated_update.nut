CollectEventsInScope
({
	OnGameEvent_scorestats_accumulated_update = function(params)
	{
		EntFire("knight_appears_loop", "StopSound", "", 0.0, null)
		EntFire("snd_black_knife_cover", "StopSound", "", 0.0, null)
		EntFire("snd_black_knife", "StopSound", "", 0.0, null)

		local players = GetAllPlayers()
		foreach (player in players)
		{
			player.TerminateScriptScope()
		}
	}
})