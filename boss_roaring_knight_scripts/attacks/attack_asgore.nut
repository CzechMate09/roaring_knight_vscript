// ⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠗⣪⣵⣶⠞⣃⣄⡻⠇⣿⣿⣿⣿⣿⣶⣿⡇⣿⣿ 
// ⢸⣿⣿⣿⣿⣿⣿⣿⣿⡿⢡⣾⣿⣿⠁⠚⠧⠿⠛⠜⢸⣿⣿⣿⣿⡏⣿⡇⣿⣿
// ⢸⣿⣿⣿⣿⣿⣿⣿⣿⡇⣿⡿⣛⣋⢅⣤⣷⡯⣥⣒⠎⣙⡛⠿⠿⠿⢋⡇⣿⣿
// ⢨⣭⣭⣭⣭⣭⣭⣭⣭⢡⣴⣾⠏⣴⣯⣍⠻⣿⣮⠻⢷⣌⢻⣧⢰⣶⡟⡅⣿⣿ 
// ⢸⣿⣿⣿⣿⣿⣿⡿⣥⣾⣿⠇⣾⢿⣧⣤⣤⣌⡟⢳⠿⠛⠀⣿⠸⢋⣼⣧⣛⣻ 
// ⢈⣉⣉⣉⣉⣉⢉⠁⣿⣿⠏⣾⢟⣨⣛⠻⣛⣻⡻⣿⣶⣮⢐⢡⣾⡈⣿⣿⣿⣿ 
// ⢀⣠⣤⣶⣶⡶⢒⠀⠿⡿⢸⡏⠼⢢⡩⣅⠈⢹⣿⢿⡛⢗⢸⢘⣟⣣⣛⣛⣛⣛ 
// ⢸⣿⣿⣿⡿⣣⣿⢿⡷⣭⠘⡀⠐⣻⣷⠪⣛⠦⣤⣤⣬⡤⢠⡈⢼⣇⣿⣿⣿⣿ 
// ⢸⣿⣿⡟⣰⣿⣿⣦⡛⢷⣾⣿⠡⣿⣿⣿⣶⣿⣷⣶⠶⣶⣆⢩⢸⣿⣿⣿⣿⣿ 
// ⢸⣿⣿⢱⣿⣿⣿⣿⣿⡦⠙⣿⣟⠹⣿⣿⣿⣿⣯⣷⣿⣿⢣⣿⡇⢿⣿⣿⣿⣿ 
// ⢸⣿⡏⣿⣿⣿⣿⣿⠟⣵⣷⠹⣿⣷⣤⣉⣥⣛⠘⣋⠛⢣⣿⣿⡇⣠⡹⣿⣿⣿ 
// ⢸⣿⣧⠻⣿⣿⡿⢋⣾⣿⣿⣧⠹⠿⡿⠿⢿⣿⠿⢋⣔⣻⠿⣫⣾⣿⣿⡌⢿⣿

function inicialize_asgore_button()
{
	local button_attack_asgore_truck = Entities.FindByName(null, "button_attack_asgore_truck") 
	EntityOutputs.AddOutput(button_attack_asgore_truck, "OnPressed", "logic_script", "RunScriptCode", "attack_asgore()", 0.0, 1)

	local path_asgore_truck_2 = Entities.FindByName(null, "path_asgore_truck_2")
	EntityOutputs.AddOutput(path_asgore_truck_2, "OnPass", "logic_script", "RunScriptCode", "attack_asgore_finish()", 0.0, 1)

	local train_truck = Entities.FindByName(null, "train_truck*")
	hideModel(train_truck)
	PrecacheModel("roaring_knight/Asgore/asgore_smile.vmt")
	PrecacheModel("roaring_knight/Asgore/asgore_car.vmt")
}

function attack_asgore()
{
	local all_players = GetAllPlayers()
	foreach (player in all_players)
		player.SetScriptOverlayMaterial("roaring_knight/Asgore/asgore_smile")

	EntFire("snd_black_knife_cover", "StopSound", "", 0.0, null)
	EntFire("snd_black_knife", "StopSound", "", 0.0, null)
	
	EntFire("material_modify_control", "StartAnimSequence", "0 10 7 0", 0.0, null)

	Schedule(2.0, function(){
		spawn_truck()
	})
}

function spawn_truck()
{
	PlaySoundOnAllClients("roaring_knight/Asgore_runs_over_dess_short.wav")

	local truck_pov = Entities.FindByName(null, "camera_truck_pov*")
	local train_truck = Entities.FindByName(null, "train_truck*")
	local origin = train_truck.GetOrigin() + Vector(0, 256, 0)

	if (truck_pov == null) // Create point_viewcontrol if it somehow gets deleted
	{
		truck_pov = SpawnEntityFromTable("point_viewcontrol", 
		{
			origin = origin,
			angles = "0 90 0",
			targetname = "camera_truck_pov",
			vscripts = "boss_roaring_knight_scripts/viewcontrol_fixer.nut"
			spawnflags = 12
		})
	}

	local timer = 15.0 // song is ~7.0s long
	local all_players = GetAlivePlayers()
	foreach (player in all_players)
	{
		player.SetScriptOverlayMaterial("roaring_knight/Asgore/asgore_car")
		EntFireByHandle(truck_pov, "Enable", "", -1, player, player)
	}
	
	// point_viewcontrol doesn't reset when a new round starts
	// because it's a preserved entity, so just teleport it
	// where it's supposed to be.
	truck_pov.SetOrigin(origin) 
	showModel(train_truck)
	truck_pov.AcceptInput("SetParent", "train_truck", null, null)

	train_truck.AcceptInput("StartForward", "", null, null)
	train_truck.AcceptInput("SetSpeed", "0.53", null, null)
}

function attack_asgore_finish()
{
	EmitSoundEx({
		sound_name = "roaring_knight/Asgore_runs_over_dess_short.wav",
		filter = Constants.EScriptRecipientFilter.RECIPIENT_FILTER_GLOBAL
		soundlevel = 0
		flags = 1 //SND_CHANGE_VOL
		volume = 0
	})
	local truck_pov = Entities.FindByName(null, "camera_truck_pov*")
	truck_pov.AcceptInput("ClearParent", "", null, null)

	local all_players = GetAllPlayers()
	foreach (player in all_players)
	{
		player.SetScriptOverlayMaterial("")
		EntFireByHandle(truck_pov, "Disable", "", -1, player, player)
	}

	PlaySoundOnAllClients("chapter_3/audio_sfx/snd_badexplosion.wav")
	EntFire("truck_explosion", "Explode", "", 0.0, null)
	EntFire("particle_explosion", "Start", "", 0.0, null)

	// SetRKnightHealth(0)
	EntFire("base_boss_r_knight", "Kill", "", 0.0, null)
}