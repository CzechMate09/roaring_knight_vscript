///////////////////////////
//  attack_sword_slash   //
///////////////////////////

function attack_sword_slash()
{
	Disable_All_Brushes()
	Stop_r_knight_door_parent()
	stop_afterimage()
	local brush_r_knight_transition_sword = Entities.FindByName(null, "brush_r_knight_transition_sword")
	PlaySpriteAnimationReversed(brush_r_knight_transition_sword, 0.2, 3, function() {
		SetBossSolid(SOLID_NONE)
		Disable_All_Brushes()
		local slash_count = 6
		local interval = 1.5

		if (Boss_difficulty == "hard")
		{
			slash_count = 7
			interval = 1.2
		}
		
		if (Boss_difficulty == "extreme")
		{
			slash_count = 8
			interval = 1.0
		}

		Schedule(1.0, Sword_slash_spawn, [slash_count, interval, Sword_slash_spawn_end])
	})
}

::Boss_origin <- null
function Sword_slash_spawn(slash_count, delay, on_complete = null)
{
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

	local last_path_index = null
	Boss_origin = GetBossOrigin()

	function spawn_at_random_path()
	{
		local possible_indices = []
		for (local i = 0; i < paths.len(); i++) {
			if (i != last_path_index) possible_indices.append(i)
		}
		local path_index = possible_indices[RandomInt(0, possible_indices.len() - 1)]
		last_path_index = path_index

		local path_name = paths[path_index]
		local path_ent = Entities.FindByName(null, path_name)
		local template = Entities.FindByName(null, "template_sword_slash_1")
		if (template == null || path_ent == null) return
		
		local brush_r_knight_crescentslash = Entities.FindByName(null, "brush_r_knight_crescentslash")
		local path_origin = path_ent.GetOrigin()
		brush_r_knight_crescentslash.SetAbsOrigin(path_origin + Vector(1024, 0, 600))
		SetBossOrigin(path_origin + Vector(640, 0, 400))
		SetBossSolid(SOLID_VPHYSICS)
		Schedule(0.8, SetBossSolid, [SOLID_NONE])

		Disable_All_Brushes()
		Enable_Brush(brush_r_knight_crescentslash)
		PlaySpriteAnimation(brush_r_knight_crescentslash, 0.1, 7, Disable_All_Brushes)
	
		PlaySoundOnAllClients("chapter_3/audiogroup_default/snd_knight_cut2.wav", 1.0, 130)
		template.ValidateScriptScope()
		template.GetScriptScope().PreSpawnInstance <- function(entity_class, entity_name) {
			if (entity_class == "func_tracktrain")
			{
				local speed = 1000
				if (Boss_difficulty == "hard")
					speed = 1100
				if (Boss_difficulty == "extreme")
					speed = 1200

				return { 
					target = path_name,
					speed = speed,
					startspeed = speed,
				}
			}

			if (entity_class == "func_door")
			{
				return { 
					speed = 400
				}
			}
			
		}
		template.GetScriptScope().PostSpawn <- function(entities) {
			foreach(handle in entities)
				NetProps.SetPropBool(handle, "m_bForcePurgeFixedupStrings", true)
		}
		template.AcceptInput("ForceSpawn", "", null, null)
		EntFire("door_sword_slash_*", "Open", null, 0.2, null)
	}

	for (local i = 0; i < slash_count; i++)
		Schedule(i * delay, spawn_at_random_path)

	if (on_complete != null)
		Schedule(slash_count * delay, on_complete)
}

function Sword_slash_spawn_end()
{
	Schedule(1.5, function(){
		local brush_r_knight_transition_sword = Entities.FindByName(null, "brush_r_knight_transition_sword")
		PlaySpriteAnimation(brush_r_knight_transition_sword, 0.2, 3)
		start_afterimage()
		SetBossOrigin(Boss_origin)
		SetBossSolid(SOLID_VPHYSICS)
		Schedule(2.0, R_knight_rand_attack)
	})
}