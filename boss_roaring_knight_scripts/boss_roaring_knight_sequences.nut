::Intro_started <- false

function r_knight_intro()
{
	if (IsInWaitingForPlayers()) return
	Intro_started = true
	EntFire("board_playerclip", "Enable", null, 0.0, null)
	EntFire("brush_bridge", "Disable", "", 0.0, null)
	EntFire("nobuild_bridge", "Disable", "", 0.0, null)
	EntFire("brush_boss_entrance", "Enable", "", 0.0, null)

	teleport_players_to_arena()
	GiveMantleRandom()

	EntFire("round_timer", "Enable", "", 0.0, null)
	EntFire("knight_appears_loop", "PlaySound", "", 0.0, null)
	Schedule(1.0, Anim_r_knight_ball_transition)
	Schedule(5.0, Anim_r_knight_idle_overworld)
	Schedule(7.5, function() {
		stop_afterimage()
		Anim_r_knight_hurt_idle(null, 2.5)
		EntFire("knight_appears_loop", "StopSound", "", 0.0, null)
		PlaySoundOnAllClients("chapter_3/audiogroup_default/snd_knight_stretch.wav", 1.0, 75)
		EntFire("particle_knight_charge_in", "Start", "", 0.0, null)
		EntFire("particle_knight_charge_in", "Stop", "", 4.0, null)

		local roaring_knight_stretch_background = Entities.FindByName(null, "roaring_knight_stretch_background")
		roaring_knight_stretch_background.AcceptInput("Enable", "", null, null)
		roaring_knight_stretch_background.SetModelScale(0.01, 2.5)
		Entity_fade_out(roaring_knight_stretch_background, 3.5)

		local roaring_knight_stretch_background_white = Entities.FindByName(null, "roaring_knight_stretch_background_white")
		roaring_knight_stretch_background_white.AcceptInput("Enable", "", null, null)
		roaring_knight_stretch_background_white.SetModelScale(0.01, 2.5)

		local roaring_knight_stretch_line = Entities.FindByName(null, "roaring_knight_stretch_line")
		EntFireByHandle(roaring_knight_stretch_line, "Enable", "", 2.5, null, null)
		Schedule(2.5, function() {
			roaring_knight_stretch_line.SetModelScale(0.01, 1.0)
		})
	})
	Schedule(11.0, function() {
		EntFire("roaring_knight_stretch_background", "Disable", "", 0.0, null)
		EntFire("roaring_knight_stretch_background_white", "Disable", "", 0.0, null)
		EntFire("roaring_knight_stretch_line", "Disable", "", 0.0, null)

		EntFire("particle_shockwave", "Start", "", 0.0, null)
		EntFire("particle_shockwave", "Stop", "", 5.0, null)

		Anim_r_knight_pose(6)
		start_afterimage()
		local center = Entities.FindByName(null, "board_center")
		ScreenShake(center.GetOrigin(), 16.0, 40.0, 8.0, 10000.0, 0, true)

		local color_correction = Entities.FindByName(null, "color_correction")
		color_correction.AcceptInput("SetFadeInDuration", "0.0", null, null)
		color_correction.AcceptInput("SetFadeOutDuration", "0.0", null, null)
		color_correction.AcceptInput("Enable", "", null, null)
		EntFireByHandle(color_correction, "Disable", "", 6.0, null, null)

		PlaySoundOnAllClients("chapter_3/audiogroup_default/snd_knight_roar.wav", 1.0, 100)
	})
	Schedule(17.5, function() {
		Anim_r_knight_sword_appear(Boss_start)
	})
}

function r_knight_intro_waiting_for_players()
{
	if (!IsInWaitingForPlayers()) return
	// Waiting for players lasts ~30 seconds

	EntFire("brush_block_players_intro", "Enable", "", 0.0, null)
	local r_knight_door_parent = Entities.FindByName(null, "r_knight_door_parent")
	r_knight_door_parent.AcceptInput("Open", "", null, null)
	r_knight_door_parent.KeyValueFromInt("speed", 100)

	Enable_Brush("brush_r_knight_faceaway_idle")
	EntFire("knight_appears_loop", "PlaySound", "", 0.5, null)
	Schedule(10.0, function(){
		PlaySoundOnAllClients("chapter_3/audiogroup_default/snd_stardrop.wav", 0.5, 100)
		PlaySpriteAnimation("brush_r_knight_faceaway_turning", 0.2, 9, function(){
			Disable_All_Brushes()
			Enable_Brush("brush_r_knight_droop")
		})
	})

	Schedule(18.0, function(){
		PlaySpriteAnimation("brush_r_knight_droop_up", 0.2, 4, function(){
			PlaySpriteAnimationReversed("brush_r_knight_ball_transition_2", 0.2, 9, function(){
				Disable_All_Brushes()
				afterImage_active = false
				local brush_r_knight_ball_fly_2 = Entities.FindByName(null, "brush_r_knight_ball_fly_2")
				Enable_Brush(brush_r_knight_ball_fly_2)
				brush_r_knight_ball_fly_2.AcceptInput("ClearParent", "", null, null)

				local train_intro_ball = Entities.FindByName(null, "train_intro_ball")
				EntFireByHandle(brush_r_knight_ball_fly_2, "SetParent", train_intro_ball.GetName(), 0.5, null, null)
				EntFireByHandle(train_intro_ball, "SetSpeed", "0.8", 0.5, null, null)
				EntFireByHandle(train_intro_ball, "StartForward", "", 0.5, null, null)
				EntFire("brush_block_players_intro", "Disable", "", 0.5, null)
			})
		})
	})

	local path_intro_4 = Entities.FindByName(null, "path_intro_4")
	EntityOutputs.AddOutput(path_intro_4, "OnPass", "worldspawn", "RunScriptCode", "afterImage_active = true", 0.0, -1)
}

function EndSequence()
{
	stop_afterimage()
	EntFire("snd_black_knife_cover", "StopSound", "", 0.0, null)
	EntFire("snd_black_knife", "StopSound", "", 0.0, null)

	EntFire("team_round_timer", "pause", null, 0.0, null)
	
	local brush_r_knight_ball_transition = Entities.FindByName(null, "brush_r_knight_ball_transition")

	Stop_r_knight_door_parent()

	Disable_All_Brushes()
	PlaySoundOnAllClients("chapter_3/audiogroup_default/snd_chargeshot_fire.wav")

	local brush_sequence_phase_1 = [
		["brush_r_knight_ball_transition", [7]],
		["brush_r_knight_idle_sword", []],
		["brush_r_knight_ball_transition", [7]],
		["brush_r_knight_idle_sword", []],
		["brush_r_knight_ball_transition", [7]],
		["brush_r_knight_idle_sword", []],
		["brush_r_knight_ball_transition", [7]],
		["brush_r_knight_idle_sword", []],
		["brush_r_knight_ball_transition", [7]],
		["brush_r_knight_idle_sword", []],
		["brush_r_knight_ball_transition", [7]],
		["brush_r_knight_idle_sword", []],
		["brush_r_knight_ball_transition", [7]],
		["brush_r_knight_idle_sword", []],
	]

	SwitchBrushSequence(brush_sequence_phase_1, 0.2, function() {
		Anim_r_knight_idle_sword()
		Stop_r_knight_door_parent()
		Schedule(1.0, function(){
			local brush_r_knight_static = Entities.FindByName(null, "brush_r_knight_static")
			local brush_r_knight_transition_sword = Entities.FindByName(null, "brush_r_knight_transition_sword")
			local brush_r_knight_ball_transition = Entities.FindByName(null, "brush_r_knight_ball_transition")

			Disable_All_Brushes()
			PlaySpriteAnimation(brush_r_knight_transition_sword, 0.2, 2, function() {
				Disable_All_Brushes()
				local brush_sequence_part_2 = [
					["brush_r_knight_transition_sword", [1]],
					["brush_r_knight_static", [1]],
					["brush_r_knight_transition_sword", [1]],
					["brush_r_knight_transition_sword", [0]],
					["brush_r_knight_ball_transition", [0]]
				]

				local brush_sequence_part_3 = [
					["brush_r_knight_ball_transition", [5]],
					["brush_r_knight_ball_transition", [6]],
					["brush_r_knight_static", [0]],
					["brush_r_knight_static", [1]],
					["brush_r_knight_static", [0]],
					["brush_r_knight_ball_transition", [6]],
					["brush_r_knight_static", [0]],
					["brush_r_knight_ball_transition", [6]],
					["brush_r_knight_ball_transition", [5]],
					["brush_r_knight_ball_transition", [0]],
				]

				local brush_sequence_part_4 = [
					["brush_r_knight_transition_sword", [0]],
					["brush_r_knight_transition_sword", [1]],
					["brush_r_knight_static", [1]],
					["brush_r_knight_static", [0]],
					["brush_r_knight_static", [1]],
					["brush_r_knight_ball_transition", [6]],
					["brush_r_knight_ball_transition", [5]],
					["brush_r_knight_ball_transition", [0]],
				]

				local brush_sequence_part_5 = [
					["brush_r_knight_transition_sword", [0]],
					["brush_r_knight_transition_sword", [1]],
					["brush_r_knight_transition_sword", [2]],
					["brush_r_knight_static", [1]],
					["brush_r_knight_transition_sword", [1]],
					["brush_r_knight_transition_sword", [2]],
					["brush_r_knight_transition_sword", [1]],
					["brush_r_knight_transition_sword", [0]],
					["brush_r_knight_transition_sword", [0]],
					["brush_r_knight_transition_sword", [0]],
					["brush_r_knight_transition_sword", [1]],
					["brush_r_knight_static", [0]],
					["brush_r_knight_static", [1]],
					["brush_r_knight_transition_sword", [1]],
					["brush_r_knight_static", [1]],
					["brush_r_knight_ball_transition", [6]],
					["brush_r_knight_ball_transition", [5]],
					["brush_r_knight_ball_transition", [0]],
				]

				local brush_phases = [
					{ type = "sequence", sequence = brush_sequence_part_2, interval = 0.15 },
					{ type = "schedule", delay = 0.6 },
					{ type = "sequence", sequence = brush_sequence_part_3, interval = 0.15 },
					{ type = "schedule", delay = 0.6 },
					{ type = "sequence", sequence = brush_sequence_part_4, interval = 0.15 },
					{ type = "schedule", delay = 0.6 },
					{ type = "sequence", sequence = brush_sequence_part_5, interval = 0.15 },
					{ type = "schedule", delay = 0.3 },
					{ type = "custom", func = function(next) {
						Disable_All_Brushes()
						local snd_knight_static = Entities.FindByName(null, "snd_knight_static_loop")
						snd_knight_static.AcceptInput("PlaySound", "", null, null)
						PlaySpriteAnimation(brush_r_knight_static, 0.15, 30,
							function() {
								snd_knight_static.AcceptInput("StopSound", "", null, null)

								if (Boss_difficulty == "extreme")
								{
									EntFire("weapon_mimic_shadow_crystal", "FireOnce", "", 0.0, null)
									PlaySoundOnAllClients("chapter_3/audiogroup_default/snd_sparkle_glock.wav")
									PlaySoundOnAllClients("chapter_3/audiogroup_default/snd_glassbreak.wav", 1.0, 100)
								}

								Disable_All_Brushes()
								PlaySpriteAnimationReversed(brush_r_knight_transition_sword, 0.3, 2)
								Schedule(1.2, Disable_All_Brushes)
								Schedule(3.0, Red_win)
								if (next) next()
							}
						)
					}}
				]

				RunBrushPhases(brush_phases)
				
			})
		})
	})
}