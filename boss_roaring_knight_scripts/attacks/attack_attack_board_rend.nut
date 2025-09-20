//////////////////////////////////
//  attack_attack_board_rend    //
//////////////////////////////////

::attack_board_rend_toggle <- false

function attack_board_rend(slash_amount)
{
	clearParentBoard()
	Disable_All_Brushes()
	Enable_Brush("brush_r_knight_attack")
	local brush_r_knight_attack = Entities.FindByName(null, "brush_r_knight_attack")
	SetTextureFrameIndex(brush_r_knight_attack, 0)
	Stop_r_knight_door_parent()

	if (attack_board_rend_toggle)
		SetTextureFrameIndex(brush_r_knight_attack, 2)
	else
		SetTextureFrameIndex(brush_r_knight_attack, 5)

	function do_slash(i)
	{
		local delay = 1.0
		if (Boss_difficulty == "hard")
			delay = 0.6

		if (Boss_difficulty == "extreme")
			delay = 0.2
		

		if (attack_board_rend_toggle) 
		{
			Schedule(delay + 0.3, SetTextureFrameIndex, [brush_r_knight_attack, 4])
			Schedule(delay + 0.7, SetTextureFrameIndex, [brush_r_knight_attack, 5])
		}
		else
		{
			Schedule(delay + 0.3, SetTextureFrameIndex, [brush_r_knight_attack, 1])
			Schedule(delay + 0.7, SetTextureFrameIndex, [brush_r_knight_attack, 2])
		}

		attack_board_rend_toggle = !attack_board_rend_toggle

		clearParentBoard()

		local rand = RandomInt(0, 3)
		switch(rand)
		{
			//  function handle_slash( string brush_name, array weapon_mimics, array weapon_delays, function slash_func, float delay)
			case 0:
				handle_slash("brush_slash_hor", "brush_slash_bottom_hor", ["weapon_mimic_tooth_hor", "weapon_mimic_tooth_hor_2"], [0.3, 0.5], slash_horizontal, delay)
				break
			case 1:
				handle_slash("brush_slash_ver", "brush_slash_bottom_ver", ["weapon_mimic_tooth_ver", "weapon_mimic_tooth_ver_2"], [0.3, 0.5], slash_vertical, delay)
				break
			case 2:
				handle_slash("brush_slash_side_1", "brush_slash_bottom_side_1", ["weapon_mimic_tooth_side"], [0.3], slash_side_1, delay)
				break
			case 3:
				handle_slash( "brush_slash_side_2", "brush_slash_bottom_side_2", ["weapon_mimic_tooth_side"], [0.3], slash_side_2, delay)
				break
			default:
				ClientPrint(null, HUD_PRINTTALK, "[DEBUG] ERROR: RandomInt() function broke?")
		}

		if (i + 1 < slash_amount)
			Schedule(delay + 3.0, do_slash, [i + 1])
		else
			Schedule(3.0, R_knight_rand_attack)
	}

	do_slash(0)
}

function handle_slash(brush_name, brush_name_bottom, weapon_mimics, weapon_delays, slash_func, delay) 
{
	local brush = Entities.FindByName(null, brush_name)
	local brush_bottom = Entities.FindByName(null, brush_name_bottom)
	brush_bottom.AcceptInput("Enable", "", null, null)
	EntFireByHandle(brush_bottom, "Disable", "", delay, null, null)
	EntFireByHandle(brush, "Enable", "", delay, null, null)
	EntFireByHandle(brush, "Disable", "", delay + 0.3, null, null)

	Schedule(delay + 0.3, slash_func)
	Schedule(delay + 0.3, function(){
		PlaySoundOnAllClients("chapter_3/audiogroup_default/snd_knight_boxbreak.wav", 1.0, 110)
		PlaySoundOnAllClients("chapter_3/audiogroup_default/snd_chargeshot_fire.wav")
	})

	for (local i = 0; i < weapon_mimics.len(); i++)
		EntFire(weapon_mimics[i], "FireOnce", "", delay + weapon_delays[i], null)
}

function inicialize_board_rend()
{
	local doors = [
		"brush_board_side_door_1",
		"brush_board_side_door_2",
		"brush_board_side_door_3",
		"brush_board_side_door_4",
		"brush_board_right_door_1",
		"brush_board_left_door_1",
		"brush_board_top_door_1",
		"brush_board_bottom_door_1"
	]

	for (local i = 0; i < doors.len(); i++)
	{
		local ent = Entities.FindByName(null, doors[i])
		EntityOutputs.AddOutput(ent, "OnFullyOpen", "!self", "Close", "", 0.4, -1)
		EntityOutputs.AddOutput(ent, "OnFullyClosed", "logic_script", "RunScriptCode", "disableBoardFlames()", 0.0, -1)
		EntityOutputs.AddOutput(ent, "OnFullyClosed", "logic_script", "RunScriptCode", "board_rend_reset_velocity()", 0.1, -1)
		ent.AddEFlags(EFL_FORCE_CHECK_TRANSMIT)
	}
}

function disableBoardFlames()
{
	PlaySoundOnAllClients("chapter_3/audio_sfx/snd_locker.wav")
	
	// horizontal flames
	EntFire("board_flame_top_left_hor", "Disable", null, 0.0, null)
	EntFire("board_flame_top_right_hor", "Disable", null, 0.0, null)
	EntFire("board_flame_bottom_left_hor", "Disable", null, 0.0, null)
	EntFire("board_flame_bottom_right_hor", "Disable", null, 0.0, null)

	// vertical flames
	EntFire("board_flame_top_left_ver", "Disable", null, 0.0, null)
	EntFire("board_flame_top_right_ver", "Disable", null, 0.0, null)
	EntFire("board_flame_bottom_left_ver", "Disable", null, 0.0, null)
	EntFire("board_flame_bottom_right_ver", "Disable", null, 0.0, null)

	// side flames
	EntFire("board_flame_side_1", "Disable", null, 0.0, null)
	EntFire("board_flame_side_2", "Disable", null, 0.0, null)
	EntFire("board_flame_side_3", "Disable", null, 0.0, null)
	EntFire("board_flame_side_4", "Disable", null, 0.0, null)
}

function slash_horizontal()
{
	local brush_board_top_door_1 = Entities.FindByName(null, "brush_board_top_door_1")
	EntFire("brush_board_top_left_a", "SetParent", brush_board_top_door_1.GetName(), 0.0, null)
	EntFire("brush_board_top_left_b", "SetParent", brush_board_top_door_1.GetName(), 0.0, null)
	EntFire("brush_board_top_right_a", "SetParent", brush_board_top_door_1.GetName(), 0.0, null)
	EntFire("brush_board_top_right_b", "SetParent", brush_board_top_door_1.GetName(), 0.0, null)
	brush_board_top_door_1.AcceptInput("SetSpeed", "600.0", null, null)
	brush_board_top_door_1.AcceptInput("Open", "", null, null)

	local brush_board_bottom_door_1 = Entities.FindByName(null, "brush_board_bottom_door_1")
	EntFire("brush_board_bottom_left_a", "SetParent", brush_board_bottom_door_1.GetName(), 0.0, null)
	EntFire("brush_board_bottom_left_b", "SetParent", brush_board_bottom_door_1.GetName(), 0.0, null)
	EntFire("brush_board_bottom_right_a", "SetParent", brush_board_bottom_door_1.GetName(), 0.0, null)
	EntFire("brush_board_bottom_right_b", "SetParent", brush_board_bottom_door_1.GetName(), 0.0, null)
	brush_board_bottom_door_1.AcceptInput("SetSpeed", "600.0", null, null)
	brush_board_bottom_door_1.AcceptInput("Open", "", null, null)

	// enable flames
	EntFire("board_flame_top_left_hor", "Enable", null, 0.0, null)
	EntFire("board_flame_top_right_hor", "Enable", null, 0.0, null)
	EntFire("board_flame_bottom_left_hor", "Enable", null, 0.0, null)
	EntFire("board_flame_bottom_right_hor", "Enable", null, 0.0, null)
}

function slash_vertical()
{
	local brush_board_left_door_1 = Entities.FindByName(null, "brush_board_left_door_1")
	EntFire("brush_board_top_left_a", "SetParent", brush_board_left_door_1.GetName(), 0.0, null)
	EntFire("brush_board_top_left_b", "SetParent", brush_board_left_door_1.GetName(), 0.0, null)
	EntFire("brush_board_bottom_left_a", "SetParent", brush_board_left_door_1.GetName(), 0.0, null)
	EntFire("brush_board_bottom_left_b", "SetParent", brush_board_left_door_1.GetName(), 0.0, null)
	brush_board_left_door_1.AcceptInput("SetSpeed", "600.0", null, null)
	brush_board_left_door_1.AcceptInput("Open", "", null, null)

	local brush_board_right_door_1 = Entities.FindByName(null, "brush_board_right_door_1")
	EntFire("brush_board_top_right_a", "SetParent", brush_board_right_door_1.GetName(), 0.0, null)
	EntFire("brush_board_top_right_b", "SetParent", brush_board_right_door_1.GetName(), 0.0, null)
	EntFire("brush_board_bottom_right_a", "SetParent", brush_board_right_door_1.GetName(), 0.0, null)
	EntFire("brush_board_bottom_right_b", "SetParent", brush_board_right_door_1.GetName(), 0.0, null)
	brush_board_right_door_1.AcceptInput("SetSpeed", "600.0", null, null)
	brush_board_right_door_1.AcceptInput("Open", "", null, null)

	// enable flames
	EntFire("board_flame_top_left_ver", "Enable", null, 0.0, null)
	EntFire("board_flame_top_right_ver", "Enable", null, 0.0, null)
	EntFire("board_flame_bottom_left_ver", "Enable", null, 0.0, null)
	EntFire("board_flame_bottom_right_ver", "Enable", null, 0.0, null)
}

function slash_side_1()
{
	local brush_board_side_door_1 = Entities.FindByName(null, "brush_board_side_door_1")
	EntFire("brush_board_bottom_left_b", "SetParent", brush_board_side_door_1.GetName(), 0.0, null)
	EntFire("brush_board_bottom_right_b", "SetParent", brush_board_side_door_1.GetName(), 0.0, null)
	EntFire("brush_board_bottom_right_a", "SetParent", brush_board_side_door_1.GetName(), 0.0, null)
	EntFire("brush_board_top_right_a", "SetParent", brush_board_side_door_1.GetName(), 0.0, null)
	brush_board_side_door_1.AcceptInput("SetSpeed", "600.0", null, null)
	brush_board_side_door_1.AcceptInput("Open", "", null, null)

	local brush_board_side_door_2 = Entities.FindByName(null, "brush_board_side_door_2")
	EntFire("brush_board_bottom_left_a", "SetParent", brush_board_side_door_2.GetName(), 0.0, null)
	EntFire("brush_board_top_left_a", "SetParent", brush_board_side_door_2.GetName(), 0.0, null)
	EntFire("brush_board_top_left_b", "SetParent", brush_board_side_door_2.GetName(), 0.0, null)
	EntFire("brush_board_top_right_b", "SetParent", brush_board_side_door_2.GetName(), 0.0, null)
	brush_board_side_door_2.AcceptInput("SetSpeed", "600.0", null, null)
	brush_board_side_door_2.AcceptInput("Open", "", null, null)

	// enable flames
	EntFire("board_flame_side_1", "Enable", null, 0.0, null)
	EntFire("board_flame_side_2", "Enable", null, 0.0, null)
}

function slash_side_2()
{
	local brush_board_side_door_3 = Entities.FindByName(null, "brush_board_side_door_3")
	EntFire("brush_board_bottom_right_b", "SetParent", brush_board_side_door_3.GetName(), 0.0, null)
	EntFire("brush_board_bottom_left_b", "SetParent", brush_board_side_door_3.GetName(), 0.0, null)
	EntFire("brush_board_bottom_left_a", "SetParent", brush_board_side_door_3.GetName(), 0.0, null)
	EntFire("brush_board_top_left_a", "SetParent", brush_board_side_door_3.GetName(), 0.0, null)
	brush_board_side_door_3.AcceptInput("SetSpeed", "600.0", null, null)
	brush_board_side_door_3.AcceptInput("Open", "", null, null)

	local brush_board_side_door_4 = Entities.FindByName(null, "brush_board_side_door_4")
	EntFire("brush_board_bottom_right_a", "SetParent", brush_board_side_door_4.GetName(), 0.0, null)
	EntFire("brush_board_top_right_a", "SetParent", brush_board_side_door_4.GetName(), 0.0, null)
	EntFire("brush_board_top_right_b", "SetParent", brush_board_side_door_4.GetName(), 0.0, null)
	EntFire("brush_board_top_left_b", "SetParent", brush_board_side_door_4.GetName(), 0.0, null)
	brush_board_side_door_4.AcceptInput("SetSpeed", "600.0", null, null)
	brush_board_side_door_4.AcceptInput("Open", "", null, null)

	// enable flames
	EntFire("board_flame_side_3", "Enable", null, 0.0, null)
	EntFire("board_flame_side_4", "Enable", null, 0.0, null)
}

function board_rend_reset_velocity()
{
	local board_brushes = [
		"brush_board_top_left_a",
		"brush_board_top_left_b",
		"brush_board_top_right_a",
		"brush_board_top_right_b",
		"brush_board_bottom_left_a",
		"brush_board_bottom_left_b",
		"brush_board_bottom_right_a",
		"brush_board_bottom_right_b"
	]

	for (local i = 0; i < board_brushes.len(); i++)
	{
		local ent = Entities.FindByName(null, board_brushes[i])
		ent.SetAbsVelocity(Vector(0, 0, 0))
		ent.SetAngularVelocity(0.0, 0.0, 0.0)
	}
}