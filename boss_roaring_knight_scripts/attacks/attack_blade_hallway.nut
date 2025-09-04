//////////////////////////////
//  attack_blade_hallway    //
//////////////////////////////

function attack_blade_hallway()
{
	Stop_r_knight_door_parent()
	PlaySoundOnAllClients("chapter_3/audio_sfx/snd_smallswing.wav", 1.0, 100)
	local brush_r_knight_point = Entities.FindByName(null, "brush_r_knight_point")
	PlaySpriteAnimation(brush_r_knight_point, 0.2, 4, function() {
		SetBossSolid(SOLID_NONE)
		stop_afterimage()
		Disable_All_Brushes()
		Schedule(3.0, Start_blade_hallway)
	})
}

function Start_blade_hallway()
{
	local rand_hallway = RandomInt(0, 1)
	if (rand_hallway == 0)
	{
		local loop_count = 2
		local interval = 0.4

		if (Boss_difficulty == "hard")
		{
			loop_count = 3
			interval = 0.3
		}
		
		if (Boss_difficulty == "extreme")
		{
			loop_count = 4
			interval = 0.2
		}

		Blade_hallway_spawn(loop_count, interval, Blade_hallway_spawn_end)
	} else {
		local total_time = 15.0
		local rot_speed = 0.6
		local train_speed = 0.6

		if (Boss_difficulty == "hard")
		{
			rot_speed = 0.7
			train_speed = 0.8
		}
		
		if (Boss_difficulty == "extreme")
		{
			rot_speed = 0.8
			train_speed = 0.9
		}
		
		Blade_hallway_spawn_rotating(rot_speed, train_speed, total_time, Blade_hallway_spawn_end)
	}
}

function Blade_hallway_spawn_end()
{
	setup_blade_think()

	Stop_r_knight_door_parent()
	Schedule(5.0, PlaySpriteAnimation, ["brush_r_knight_transition_sword", 0.2, 3])

	Schedule(5.5, function() {
		start_afterimage()
		SetBossSolid(SOLID_VPHYSICS)
	})
	Schedule(7.0, R_knight_rand_attack)
}

function Blade_hallway_spawn(loop_count, delay, on_complete = null)
{
	local template = Entities.FindByName(null, "template_blade_hallway_middle_1")

	local paths = [
		"path_knife_corridor_middle_1",
		"path_knife_corridor_left_a_1",
		"path_knife_corridor_left_b_1",
		"path_knife_corridor_left_c_1",
		"path_knife_corridor_left_d_1",
		"path_knife_corridor_right_a_1",
		"path_knife_corridor_right_b_1",
		"path_knife_corridor_right_c_1",
		"path_knife_corridor_right_d_1"
	]

	local spawn_sequence = []
	spawn_sequence.append(0) // middle
	foreach (idx in [1,2,3,4]) spawn_sequence.append(idx) // left
	for (local i = 4; i >= 1; i--) spawn_sequence.append(i) // left reverse
	spawn_sequence.append(0) // middle
	foreach (idx in [5,6,7,8]) spawn_sequence.append(idx) // right
	for (local i = 8; i >= 5; i--) spawn_sequence.append(i) // right reverse

	function do_sequence(current_loop)
	{
		for (local i = 0; i < spawn_sequence.len(); i++) {
			local path_index = spawn_sequence[i]
			local path_name = paths[path_index]
			local path_ent = Entities.FindByName(null, path_name)
			if (template == null || path_ent == null) continue

			Schedule(i * delay + current_loop * spawn_sequence.len() * delay, function(tmpl, target_path) {
				tmpl.ValidateScriptScope()
				tmpl.GetScriptScope().PreSpawnInstance <- function(entity_class, entity_name) {
					if (entity_class == "func_tracktrain") {
						local speed = 2500
						if (Boss_difficulty == "hard") speed = speed * 1.3
						if (Boss_difficulty == "extreme") speed = speed * 1.6
						return { 
							target = target_path, 
							speed = speed,
							startspeed = speed
						}
					}
				}
				tmpl.GetScriptScope().PostSpawn <- function(entities) {
					foreach( handle in entities )
						NetProps.SetPropBool(handle, "m_bForcePurgeFixedupStrings", true)
				}
				tmpl.AcceptInput("ForceSpawn", "", null, null)
				PlaySoundOnAllClients("chapter_3/audiogroup_default/snd_object_passing.wav", 1.0, 100)
			}, [template, path_name])
		}
	}

	for (local loop = 0; loop < loop_count; loop++) {
		do_sequence(loop)
	}

	if (on_complete != null) {
		Schedule(spawn_sequence.len() * delay * loop_count, on_complete)
	}
}

function Blade_hallway_spawn_rotating(rot_speed, train_speed, total_time = 15.0, on_finish = null)
{
	local radius = 3456 // units between the center of the blades and the center of func_rotating
	local rot = Entities.FindByName(null, "blade_hallway_rot")
	if (!rot) return

	local train_blade_hallway_round = Entities.FindByName(null, "train_blade_hallway_round")
	Schedule(3.0, function(){
		local rand_direction = RandomInt(0, 1)
		if (rand_direction == 0)
		{
			EntFire("path_blade_hallway_round_*", "DisableAlternatePath", "", 0.0, null)
		} else {
			EntFire("path_blade_hallway_round_*", "EnableAlternatePath", "", 0.0, null)
		}

		train_blade_hallway_round.AcceptInput("StartForward", "", null, null)
		train_blade_hallway_round.AcceptInput("SetSpeed", train_speed.tostring(), null, null)
	})

	rot.AcceptInput("Start", "", null, null)
	rot.AcceptInput("SetSpeed", rot_speed.tostring(), null, null)

	local template = Entities.FindByName(null, "template_blade_hallway_middle_1")
	template.ValidateScriptScope()
	template.GetScriptScope().PreSpawnInstance <- function(entity_class, entity_name) {
		if (entity_class == "func_tracktrain")
			return { target = "" }
	}

	local start_time = Time()
	local spawn_count = 0
	local deg_per_sec = 100.0 * rot_speed
	local num_trains = 30 // only possible num_trains: 45, 30, 18
	local degrees_between_trains = 360.0 / num_trains
	local spawn_interval = degrees_between_trains / deg_per_sec

	function spawn_loop()
	{
		if (template == null) return
		
		template.GetScriptScope().PostSpawn <- function(entities) {
			foreach(handle in entities)
			{
				NetProps.SetPropBool(handle, "m_bForcePurgeFixedupStrings", true)

				if (handle.GetClassname() == "func_tracktrain")
				{
					// Always spawn at the top (angle 90°)
					local angle_deg = 90
					local angle_rad = angle_deg * PI / 180.0
					local center = rot.GetOrigin()
					local offset = Vector(cos(angle_rad), sin(angle_rad), 0) * radius
					local spawn_pos = center + offset
					handle.SetOrigin(spawn_pos)
					handle.SetAbsAngles(QAngle(0, angle_deg, 0))
					EntFireByHandle(handle, "SetParent", rot.GetName(), 0.0, null, null)
				}
			}
		}

		template.AcceptInput("ForceSpawn", "", null, null)
		PlaySoundOnAllClients("chapter_3/audiogroup_default/snd_object_passing.wav", 1.0, 100)
		spawn_count++

		if (spawn_count < num_trains)
			Schedule(spawn_interval, spawn_loop)
	}

	Schedule(total_time, function(){
		if (on_finish != null) on_finish()
		template.TerminateScriptScope() // remove the PreSpawnInstance from scope
		rot.AcceptInput("StopAtStartPos", "", null, null)
		setup_blade_think()

		Schedule(1.0, function(){
			train_blade_hallway_round.AcceptInput("Stop", "", null, null)
			train_blade_hallway_round.AcceptInput("TeleportToPathTrack", "path_blade_hallway_round_1", null, null)
			// --- CLEANUP TRAINS ---
			local ent = null
			while ((ent = Entities.FindByName(ent, "train_blade_hallway_1*")) != null) {
				ent.Destroy()
			}
		})

		return
	})

	spawn_loop()
}

function setup_blade_think()
{
	local delay = 3.0
	if (Boss_difficulty == "hard")  delay = 2.5
	if (Boss_difficulty == "extreme")  delay = 2.0

	local projectile_blade_hallway = null
	while (projectile_blade_hallway = Entities.FindByName(projectile_blade_hallway, "projectile_blade_hallway*"))
	{
		if (!projectile_blade_hallway) continue
		if (projectile_blade_hallway.IsEFlagSet(1048576)) continue
		projectile_blade_hallway.AddEFlags(1048576)

		projectile_blade_hallway.ValidateScriptScope()
		local scope = projectile_blade_hallway.GetScriptScope()
		projectile_blade_hallway.GetScriptScope().blade_think <- blade_think
		projectile_blade_hallway.AcceptInput("ClearParent", "", null, null)

		local players = GetAlivePlayers()
		local my_pos = projectile_blade_hallway.GetOrigin()
		local dir

		if (players.len() == 0) {
			// No players: go forward (use current angles)
			local angles = projectile_blade_hallway.GetAbsAngles()
			local yaw_rad = angles.y * PI / 180.0
			dir = Vector(cos(yaw_rad), sin(yaw_rad), 0)
			projectile_blade_hallway.GetScriptScope().target_selected <- true
		} else {
			local max_dist = 2800
			local target = players[RandomInt(0, players.len() - 1)]

			local target_pos = target.GetOrigin()
			dir = target_pos - my_pos
			dir.z = 0
			if (dir.Length() > max_dist) {
				projectile_blade_hallway.Destroy()
				continue
			}

			local yaw = atan2(dir.y, dir.x) * 180.0 / PI
			dir.Norm()
			projectile_blade_hallway.SetAbsAngles(QAngle(0, yaw, 0))

			projectile_blade_hallway.GetScriptScope().target_selected <- true
			projectile_blade_hallway.GetScriptScope().target_ent <- target
		}

		projectile_blade_hallway.GetScriptScope().launch_dir <- dir

		Schedule(delay, function(ent) {
			EntFire("brush_blade_hallway_*", "Disable", "", 0.0, null)
			if (ent == null) return
			if (!ent.IsValid()) return
			ent.GetScriptScope().launch_start_time <- Time()
			AddThinkToEnt(ent, "blade_think")
		}, [projectile_blade_hallway])


		EntFire("brush_blade_hallway_*", "Enable", "", 0.0, null)
		// DebugDrawLine_vCol(my_pos + dir * 500, my_pos + dir * 200000, Vector(255, 0, 0), false, 3.0)

		NetProps.SetPropBool(projectile_blade_hallway, "m_bForcePurgeFixedupStrings", true)
	}

	PlaySoundOnAllClients("chapter_3/audiogroup_default/snd_knight_jump.wav", 1.0, 80)
	// PlaySoundOnAllClients("chapter_3/audio_sfx/snd_jump.wav", 1.0, 100)
	// PlaySoundOnAllClients("chapter_3/audiogroup_default/snd_shinka_ambience.wav", 1.0, 100)
	Schedule(delay, PlaySoundOnAllClients, ["chapter_3/audiogroup_default/snd_knight_cut.wav", 1.0, 80])
}

function blade_think()
{
	local scope = self.GetScriptScope()

	local speed = 3000
	local now = Time()
	local pos = self.GetOrigin()
	local dir = scope.launch_dir * speed * FrameTime()
	self.SetOrigin(pos + dir)

	if (now - scope.launch_start_time > 4.0)
	{
		StopThink(self)
		self.Destroy()
	}

	return -1
}