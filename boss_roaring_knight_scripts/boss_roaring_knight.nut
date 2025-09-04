::ROOT <- getroottable();
if (!("ConstantNamingConvention" in ROOT)) // make sure folding is only done once
{
	foreach (a,b in Constants)
		foreach (k,v in b)
			ROOT[k] <- v != null ? v : 0;
}

IncludeScript("boss_roaring_knight_scripts/boss_roaring_knight_util.nut")
IncludeScript("boss_roaring_knight_scripts/boss_roaring_knight_anims.nut")
IncludeScript("boss_roaring_knight_scripts/events.nut")
IncludeScript("boss_roaring_knight_scripts/base_boss.nut")
IncludeScript("boss_roaring_knight_scripts/boss_roaring_knight_sequences.nut")

// Attacks
IncludeScript("boss_roaring_knight_scripts/attacks/attack_crystal_barrage.nut")
IncludeScript("boss_roaring_knight_scripts/attacks/attack_knife_dance.nut")
IncludeScript("boss_roaring_knight_scripts/attacks/attack_attack_board_rend.nut")
IncludeScript("boss_roaring_knight_scripts/attacks/attack_blade_hallway.nut")
IncludeScript("boss_roaring_knight_scripts/attacks/attack_crystal_nova.nut")
IncludeScript("boss_roaring_knight_scripts/attacks/attack_sanguine_slash.nut")
IncludeScript("boss_roaring_knight_scripts/attacks/attack_sword_slash.nut")
IncludeScript("boss_roaring_knight_scripts/attacks/attack_under_box_attack.nut")
IncludeScript("boss_roaring_knight_scripts/attacks/attack_asgore.nut")

if (!("Boss_difficulty" in ROOT))
{
	::Boss_difficulty <- "normal" // Starting difficulty
}

::tf_gamerules <- null
::active_knight_brush <- null // currently active knight brush
::Round_started <- false

function OnPostSpawn()
{
	tf_gamerules = Entities.FindByName(null, "tf_gamerules")
	tf_gamerules.AcceptInput("SetBlueTeamGoalString", "Roar", null, null)
	tf_gamerules.AcceptInput("SetRedTeamGoalString ", "Roar", null, null)

	Convars.SetValue("mp_autoteambalance", 0)
	Convars.SetValue("mp_respawnwavetime", 10.0)
	Convars.SetValue("mp_tournament_blueteamname", "Roaring Knight")

	local round_timer = Entities.FindByName(null, "round_timer")
	EntityOutputs.AddOutput(round_timer, "OnFinished", "logic_script", "RunScriptCode", "Blue_win()", 0.0, -1)

	inicialize_building_parenter()
	inicialize_knight_brush_parents()
	inicialize_knight_door()
	inicialize_crystal_barrage_path()
	inicialize_board_rend()
	inicialize_base_boss()
	inicialize_asgore_button()
	inicialize_knight_afterimage()

	if (IsInWaitingForPlayers())
	{
		r_knight_intro_waiting_for_players()
		return
	}

	Enable_Brush("brush_r_knight_ball_fly")
	local brush_difficulty = Entities.FindByName(null, "brush_difficulty")
	brush_difficulty.AcceptInput("Enable", "", null, null)
	if (Boss_difficulty == "normal")
		SetTextureFrameIndex(brush_difficulty, 0)
	if (Boss_difficulty == "hard")
		SetTextureFrameIndex(brush_difficulty, 1)
	if (Boss_difficulty == "extreme")
		SetTextureFrameIndex(brush_difficulty, 2)

	// ClientPrint(null, HUD_PRINTTALK, "[DEBUG] Boss difficulty set to " + Boss_difficulty)
	printl("-----------------------------------------")
	printl("[DEBUG] Boss difficulty set to " + Boss_difficulty)
	printl("-----------------------------------------")
}

function inicialize_knight_afterimage()
{
	local r_knight_door_parent = Entities.FindByName(null, "r_knight_door_parent")
	r_knight_door_parent.ValidateScriptScope()
	r_knight_door_parent.GetScriptScope().afterimage_think <- afterimage_think
	AddThinkToEnt(r_knight_door_parent, "afterimage_think")
}

::afterImage_active <- true
::y_offset <- 1

function afterimage_think()
{
	if (active_knight_brush == null) return
	if (afterImage_active == false) return
	if (y_offset > 12)
		y_offset = 1

	local move_time = 0.7
	local move_distance = 8*50
	local model = NetProps.GetPropString(active_knight_brush, "m_ModelName")
	local frameIndex = GetTextureFrameIndex(active_knight_brush)
	local origin = active_knight_brush.GetOrigin()
	local new_origin = origin + Vector(0, 4 * y_offset, 0)
	local angles = active_knight_brush.GetAbsAngles()

	local afterImage = SpawnEntityFromTable("func_brush",
	{
		origin = new_origin,
		angles = angles,
		targetname = "afterImage",
		model = model,
		spawnflags = "2",
		rendermode = "1",
		solidity = "1"
		disableshadows = "1",
	})

	NetProps.SetPropBool(afterImage, "m_bForcePurgeFixedupStrings", true)
	afterImage.AcceptInput("Alpha", "180", null, null)
	SetTextureFrameIndex(afterImage, frameIndex)

	// Move right over time
	afterImage.ValidateScriptScope()
	afterImage.GetScriptScope().move_time_left <- move_time
	afterImage.GetScriptScope().move_distance <- move_distance
	afterImage.GetScriptScope().start_origin <- new_origin
	afterImage.GetScriptScope().afterimage_move_think <- function() {
		local scope = self.GetScriptScope()
		if (!("move_time_left" in scope)) return
		local dt = FrameTime()
		scope.move_time_left -= dt
		local frac = 1.0 - (scope.move_time_left / move_time)
		local new_origin = scope.start_origin + Vector(scope.move_distance * frac, 0, 0)
		self.SetOrigin(new_origin)
		if (scope.move_time_left <= 0)
		{
			StopThink(self)
			self.Destroy()
		}
		return -1
	}

	AddThinkToEnt(afterImage, "afterimage_move_think")

	y_offset += 1
	return 0.15
}

function inicialize_building_parenter()
{
	local triggers = [
		"trigger_board_top_right_a",
		"trigger_board_top_right_b",
		"trigger_board_top_left_a",
		"trigger_board_top_left_b",
		"trigger_board_bottom_right_a",
		"trigger_board_bottom_right_b",
		"trigger_board_bottom_left_a",
		"trigger_board_bottom_left_b"
	]

	for (local i = 0; i < triggers.len(); i++)
	{
		local ent = Entities.FindByName(null, triggers[i])
		EntityOutputs.AddOutput(ent, "OnStartTouch", "logic_script", "RunScriptCode", "parent_activator_to_caller()", 0.0, -1)
	}
}

function inicialize_knight_brush_parents()
{
	local r_knight_door_parent = Entities.FindByName(null, "r_knight_door_parent")
	local brushes = GetAllKnightBrushes()
	for (local i = 0; i < brushes.len(); i++)
	{
		local brush = Entities.FindByName(null, brushes[i])
		if (brush == null) continue
		brush.AcceptInput("SetParent", r_knight_door_parent.GetName(), null, null)
	}
}

function inicialize_knight_door()
{
	local r_knight_door_parent = Entities.FindByName(null, "r_knight_door_parent") // starts closed
	EntityOutputs.AddOutput(r_knight_door_parent, "OnFullyOpen", "!self", "Close", "", 0.0, -1)
	EntityOutputs.AddOutput(r_knight_door_parent, "OnFullyClosed", "!self", "Open", "", 0.0, -1)
}

function Start_intro()
{
	EntFire("arena_teleporter", "Enable", "", 1.0, null)
	r_knight_intro()
}

function Boss_start()
{
	Round_started = true
	SetUpBossHealth()
	SetBossSolid(SOLID_VPHYSICS)

	local r_knight_door_parent = Entities.FindByName(null, "r_knight_door_parent")
	r_knight_door_parent.AcceptInput("Open", "", null, null)
	r_knight_door_parent.KeyValueFromInt("speed", 100)
	start_afterimage()
	PlaySoundOnAllClients("chapter_3/audiogroup_default/snd_weaponpull.wav", 1.0, 100)

	if (Boss_difficulty == "extreme")
	{
		// Black Knife cover by FalKKonE https://youtu.be/EJ4jWRHjtEY
		EntFire("snd_black_knife_cover", "PlaySound", "", 0.5, null)
		ClientPrint(null, HUD_PRINTTALK, "\x07ffff00" + "[BOSS] Now Playing: Black Knife 【Intense Symphonic Metal Cover】 By FalKKonE")
	} else {
		EntFire("snd_black_knife", "PlaySound", "", 0.5, null)
	}

	R_knight_rand_attack()
}

::Red_win <- function()
{
	EntFire("snd_black_knife_cover", "StopSound", "", 0.0, null)
	EntFire("snd_black_knife", "StopSound", "", 0.0, null)

	Disable_All_Brushes()
	EntFire("red_win", "RoundWin", "", 0.0, null)
	local current_difficulty = Boss_difficulty
	if (current_difficulty == "normal")
		Boss_difficulty = "hard"
	if (current_difficulty == "hard")
		Boss_difficulty = "extreme"
	// if (current_difficulty == "extreme")
	//     Boss_difficulty = "normal"

	ShowDamageDealt()
}

::Blue_win <- function()
{
	EntFire("blue_win", "RoundWin", "", 0.0, null)

	printl("-----------------------------------------")
	printl("[DEBUG] Remaining Boss HP: " + GetRKnightHealth())
	printl("-----------------------------------------")

	ShowDamageDealt()
}

function ShowDamageDealt()
{
	local players = GetAllPlayers()
	local valid_players = []

	foreach (player in players)
	{
		local scope = player.GetScriptScope()
		if (!("dmg_dealt" in scope)) continue
		valid_players.append(player)
	}

	valid_players.sort(function(a, b) {
		local sa = a.GetScriptScope()
		local sb = b.GetScriptScope()
		return sb.dmg_dealt <=> sa.dmg_dealt
	})

	local baseTop = "TOP DAMAGE\n"
	local topPlayers = []
	local topCount = Min(3, valid_players.len())
	for (local i = 0; i < topCount; i++)
	{
		local p = valid_players[i]
		local scope = p.GetScriptScope()
		baseTop += (i+1) + ". " + GetPlayerName(p) + " - " + scope.dmg_dealt + " damage\n"
		topPlayers.append(p)
	}

	foreach (player in players)
	{
		local msg = baseTop

		// If player is NOT in the top 3, add their own damage line
		if (topPlayers.find(player) == null)
		{
			local scope = player.GetScriptScope()
			local dmg = ("dmg_dealt" in scope) ? scope.dmg_dealt : 0
			msg += "\nYour damage: " + dmg
		}

		ClientPrint(player, HUD_PRINTCENTER, msg)
	}
}

::last_r_knight_attack_indices <- []
::attack_crystal_nova_used <- false
::first_attack <- true

function R_knight_rand_attack()
{
	printl("choosing random attack...")

	local delay = 3.5
	if (Boss_difficulty == "hard")
		delay = 2.5

	if (Boss_difficulty == "extreme")
		delay = 1.5

	Anim_r_knight_idle_sword()
	SetBossSolid(SOLID_VPHYSICS)
	start_afterimage()

	local boss_hp = GetRKnightHealth()
	if (boss_hp <= 0)
	{
		EndSequence()
		return
	}

	//if under 20% health, use crystal nova
	if (boss_hp <= 0.20 * GetRKnightMaxHealth() && attack_crystal_nova_used == false)
	{
		//PlaySoundOnAllClients("chapter_3/audiogroup_default/snd_knight_powerup_white.wav", 1.0, 100) // played when knight is about to use final attack
		Schedule(delay, function() {
			attack_crystal_nova()
			attack_crystal_nova_used = true
			// last_r_knight_attack_indices.append(3) // Getting the hallway attack after the nova is actual bullshit, but also kinda funny..
		})
		return
	}

	Schedule(delay, function() { 
		// Pick a random attack index, but not the same as last time
		local possible_indices = [0, 1, 2, 3, 4]
		if (Boss_difficulty == "hard" || Boss_difficulty == "extreme")
		{
			possible_indices = [0, 1, 2, 3, 4, 5, 6]
		}

		foreach (idx in last_r_knight_attack_indices)
		{
			local remove_idx = possible_indices.find(idx)
			if (remove_idx != null && possible_indices.len() > 1)
				possible_indices.remove(remove_idx)
		}
		local rand_index = possible_indices[RandomInt(0, possible_indices.len() - 1)]
		
		local last_attack_treshhold = 3
		if (Boss_difficulty == "hard" || Boss_difficulty == "extreme")
		{
			last_attack_treshhold = 4
		}

		if (first_attack == true) 
		{
			rand_index = 0
			first_attack = false
		}

		last_r_knight_attack_indices.append(rand_index)
		if (last_r_knight_attack_indices.len() > last_attack_treshhold)
			last_r_knight_attack_indices.remove(0)

		clearParentBoard()
		board_rend_reset_velocity()

		switch(rand_index)
		{
			case 0:
				printl("attack_crystal_barrage")
				attack_crystal_barrage(10.0)
				break
			case 1:
				attack_knife_dance()
				break
			case 2:
				printl("attack_board_rend")
				attack_board_rend(6)
				break
			case 3:
				printl("attack_blade_hallway")
				attack_blade_hallway()
				break
			case 4:
				attack_sanguine_slash()
				break
			case 5:
				printl("attack_sword_slash")
				attack_sword_slash()
				break
			case 6:
				printl("attack_under_box_attack")
				attack_under_box_attack()
				break
			default:
				ClientPrint(null, HUD_PRINTTALK, "[DEBUG] ERROR: No attack selected, trying again.")
				R_knight_rand_attack()
		}
	})
}