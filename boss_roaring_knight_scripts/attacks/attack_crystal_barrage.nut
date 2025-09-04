//////////////////////////////
//  attack_crystal_barrage  //
//////////////////////////////

function inicialize_crystal_barrage_path()
{
	local letters = "abcdefghijklmnopqrstuvwxyz"

	local pathsArray = []
	for (local i = 0; i < 17; i++)
	{
		local path_track = Entities.FindByName(null, format("path_crystal_barrage_%s_2", letters.slice(i, i+1)))
		EntityOutputs.AddOutput(path_track, "OnPass", "!activator", "Kill", "", 0.0, -1)
	}
}

function attack_crystal_barrage(duration)
{
	Stop_r_knight_door_parent()

	local interval = 0.14

	if (Boss_difficulty == "hard")
		interval = 0.12

	if (Boss_difficulty == "extreme")
		interval = 0.1
	
	Schedule(1.2, Start_crystal_barrage, [duration, interval])
}

function Start_crystal_barrage(duration, interval)
{
	local brush_r_knight_point = Entities.FindByName(null, "brush_r_knight_point")
	local door_r_knight_point_ver = Entities.FindByName(null, "door_r_knight_point_ver")
	local door_r_knight_point_hor = Entities.FindByName(null, "door_r_knight_point_hor")

	brush_r_knight_point.AcceptInput("SetParent", door_r_knight_point_hor.GetName(), null, null)
	door_r_knight_point_ver.AcceptInput("Open", "", null, null)
	door_r_knight_point_hor.AcceptInput("Open", "", null, null)

	PlaySpriteAnimation(brush_r_knight_point, 0.15, 4, function() {
		local brush_bullet_flow_white_line = Entities.FindByName(null, "brush_bullet_flow_white_line")
		if (brush_bullet_flow_white_line != null)
		{
			brush_bullet_flow_white_line.AcceptInput("Enable", "", null, null)
			brush_bullet_flow_white_line.AcceptInput("Alpha", "0", null, null)
			Entity_fade_in(brush_bullet_flow_white_line, 1.8)
			EntFireByHandle(brush_bullet_flow_white_line, "Disable", "", 1.8, null, null)
		}

		Schedule(0.2, MoveBoard)

		Schedule(1.8, function() {
			local brush_bullet_flow = Entities.FindByName(null, "brush_bullet_flow")
			if (brush_bullet_flow == null) return
			brush_bullet_flow.AcceptInput("Enable", "", null, null)
			brush_bullet_flow.AcceptInput("Alpha", "128", null, null)
			PlaySoundOnAllClients("chapter_3/audiogroup_default/snd_rocket_long.wav", 1.0, 60)
		})

		Schedule(2.2, Spawn_star_trains, [6.0, interval])
		PlaySoundOnAllClients("chapter_3/audiogroup_default/snd_knight_drawpower.wav", 1.0, 130)
	})

	Schedule(duration, function() {
		PlaySpriteAnimationReversed(brush_r_knight_point, 0.15, 4)
		door_r_knight_point_ver.AcceptInput("Close", "", null, null)
		door_r_knight_point_hor.AcceptInput("Close", "", null, null)

		EntFireByHandle(brush_r_knight_point, "SetParent", "r_knight_door_parent", 3.0, null, null)
		EntFire("base_boss_r_knight", "ClearParent", "", 3.0, null)
		
		local brush_bullet_flow = Entities.FindByName(null, "brush_bullet_flow")
		if (brush_bullet_flow != null)
			brush_bullet_flow.AcceptInput("Disable", "", null, null)

		Schedule(0.5, function(){
			ReverseStarTrains("r_knight_star_train*", "sprite_star_projectile*")
			CreateStarChildren("r_knight_star_train_a*", true)
		})

		Schedule(duration, function(){
			R_knight_rand_attack()
			board_rend_reset_velocity()
		})
	})
}

function MoveBoard()
{
	local crystal_barrage_train = Entities.FindByName(null, "crystal_barrage_train")
	
	if (crystal_barrage_train == null) return
	crystal_barrage_train.AddEFlags(EFL_FORCE_CHECK_TRANSMIT) // idk if this does anything, it's to prevent the platform from being jittery

	EntFire("brush_board_top_left_a", "SetParent", crystal_barrage_train.GetName(), 0.0, null)
	EntFire("brush_board_top_left_b", "SetParent", crystal_barrage_train.GetName(), 0.0, null)
	EntFire("brush_board_bottom_left_a", "SetParent", crystal_barrage_train.GetName(), 0.0, null)
	EntFire("brush_board_bottom_left_b", "SetParent", crystal_barrage_train.GetName(), 0.0, null)
	EntFire("brush_board_top_right_a", "SetParent", crystal_barrage_train.GetName(), 0.0, null)
	EntFire("brush_board_top_right_b", "SetParent", crystal_barrage_train.GetName(), 0.0, null)
	EntFire("brush_board_bottom_right_a", "SetParent", crystal_barrage_train.GetName(), 0.0, null)
	EntFire("brush_board_bottom_right_b", "SetParent", crystal_barrage_train.GetName(), 0.0, null)

	crystal_barrage_train.AcceptInput("SetSpeed", "350", null, null)
	crystal_barrage_train.AcceptInput("Open", "", null, null)
}

function Spawn_star_trains(max_time = null, interval = 0.18)
{
	local template = Entities.FindByName(null, "template_star_a")
	if (template == null) return

	local letters = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q"]
	local start_time = Time()

	local recent_indices = []

	function spawn_next()
	{
		if ((max_time != null && (Time() - start_time) >= max_time)) return

		local possible_indices = []
		for (local i = 0; i < letters.len(); i++) {
			if (recent_indices.find(i) == null) {
				possible_indices.append(i)
			}
		}

		local rand_index = possible_indices[RandomInt(0, possible_indices.len() - 1)]

		recent_indices.append(rand_index)
		if (recent_indices.len() > 10) {
			recent_indices.remove(0)
		}

		template.ValidateScriptScope()
		template.GetScriptScope().PreSpawnInstance <- function(entity_class, entity_name) {
			if (entity_class == "func_tracktrain")
			{
				local speed = 800
				return {
					target = "path_crystal_barrage_" + letters[rand_index] + "_1",
					speed = speed,
					startspeed = speed
				}
			}
		}
		template.GetScriptScope().PostSpawn <- function(entities) {
			foreach(handle in entities )
			{ 
				NetProps.SetPropBool(handle, "m_bForcePurgeFixedupStrings", true)
			}
		}
		template.AcceptInput("ForceSpawn", "", null, null)
		PlaySoundOnAllClients("chapter_3/audiogroup_default/snd_stardrop.wav", 0.5, 50)

		Schedule(interval, spawn_next)
	}
	spawn_next()
}

function ReverseStarTrains(name = null, sprite = null)
{
	local target_name = name
	if(target_name == null) return
	EntFire(target_name, "StartBackward", "", 0.0 null)
	EntFire(target_name, "SetSpeed", "0.5", 0.0 null)

	// EntFire("spotlight_*", "LightOn", "", 0.0 null)

	local sprite_star_projectile = null
	local sprite_name = sprite
	while (sprite_star_projectile = Entities.FindByName(sprite_star_projectile, sprite_name))
	{
		if (sprite_star_projectile == null) continue
		if (sprite_star_projectile.IsEFlagSet(1048576)) continue
		sprite_star_projectile.AddEFlags(1048576)
		
		SetTextureFrameIndex(sprite_star_projectile, 3)
		Schedule(0.2, SetTextureFrameIndex, [sprite_star_projectile, 1])
		Schedule(0.3, SetTextureFrameIndex, [sprite_star_projectile, 3])
		Schedule(0.4, SetTextureFrameIndex, [sprite_star_projectile, 1])
		Schedule(0.5, SetTextureFrameIndex, [sprite_star_projectile, 3])
		Schedule(0.6, SetTextureFrameIndex, [sprite_star_projectile, 1])
		Schedule(0.7, SetTextureFrameIndex, [sprite_star_projectile, 3])
		Schedule(0.8, SetTextureFrameIndex, [sprite_star_projectile, 1])
		Schedule(0.9, SetTextureFrameIndex, [sprite_star_projectile, 3])
		Schedule(1.0, SetTextureFrameIndex, [sprite_star_projectile, 1])
		Schedule(1.1, SetTextureFrameIndex, [sprite_star_projectile, 3])
		Schedule(1.2, SetTextureFrameIndex, [sprite_star_projectile, 1])
		Schedule(1.3, SetTextureFrameIndex, [sprite_star_projectile, 3])
		Schedule(1.4, SetTextureFrameIndex, [sprite_star_projectile, 1])
		Schedule(1.5, SetTextureFrameIndex, [sprite_star_projectile, 2])
		Schedule(1.7, SetTextureFrameIndex, [sprite_star_projectile, 1])
	}

	PlaySoundOnAllClients("chapter_3/audiogroup_default/snd_knight_star_explosion_close.wav", 1.0, 70)

	local crystal_barrage_train = Entities.FindByName(null, "crystal_barrage_train")
	crystal_barrage_train.AcceptInput("SetSpeed", "200", null, null)
	crystal_barrage_train.AcceptInput("Close", "", null, null)
}


// point_spotlight casually spawning 2 edicts per entity
// so I have to spawn the weapon mimics AFTER deleting
// the other star entities to prevent edict overflow.

function CreateStarChildren(name = null, transparent = true)
{
	local target_name = name
	if (target_name == null) return
	local template = Entities.FindByName(null, "template_star_mimic")
	template.ValidateScriptScope()
	local scope = template.GetScriptScope()
	local delay = 1.7

	// EntFire("spotlight_*", "LightOff", "", delay - 0.2 null)

	Schedule(delay, function() {
		local train_origins = []
		local train_star = null
		while (train_star = Entities.FindByName(train_star, target_name))
		{
			if (train_star == null) continue
			if (train_star.IsEFlagSet(1048576)) continue
			train_star.AddEFlags(1048576) // useless flag

			local origin = train_star.GetOrigin()
			train_origins.append(origin)
			train_star.Destroy()
		}

		// Schedule(0.1, function() {
			foreach(origin in train_origins)
			{
				scope.PreSpawnInstance <- function(entity_class, entity_name) {
					local modelOverride = "models/czechmate/roaring_knight/projectile/projectile_star_child_trans.mdl"
					if (transparent == false)
					{
						modelOverride = "models/czechmate/roaring_knight/projectile/projectile_star_child.mdl"
					}
					return {
						origin = origin,
						ModelOverride = modelOverride
						}
				}
				scope.PostSpawn <- function(entities) {
					foreach(handle in entities)
						NetProps.SetPropBool(handle, "m_bForcePurgeFixedupStrings", true)
				}
				template.AcceptInput("ForceSpawn", "", null, null)
			}
		EntFire("weapon_mimic_star_child*", "FireOnce", null, 0.0, null)
		// })
	})

	Schedule(delay + 0.3, FadeStarChildren)
	Schedule(delay + 0.3, PlaySoundOnAllClients, ["chapter_3/audiogroup_default/snd_rocket_bc.wav"])
}

function FadeStarChildren()
{
	local weapon_mimic_star_kid = null
	while (weapon_mimic_star_kid = Entities.FindByClassname(weapon_mimic_star_kid, "tf_projectile_rocket"))
	{
		if (weapon_mimic_star_kid == null) continue
		if (!weapon_mimic_star_kid.IsValid()) continue
		if (weapon_mimic_star_kid.IsEFlagSet(1048576)) continue
		local owner = NetProps.GetPropEntity(weapon_mimic_star_kid, "m_hOwnerEntity")
		if (!startswith(owner.GetName(), "weapon_mimic_star")) continue

		weapon_mimic_star_kid.AddEFlags(1048576)
		NetProps.SetPropBool(weapon_mimic_star_kid, "m_bForcePurgeFixedupStrings", true)

		Schedule(1.5, Entity_fade_out, [weapon_mimic_star_kid, 0.5])
		Schedule(2.0, function(weapon_mimic_star_kid) {
			if(weapon_mimic_star_kid == null) return
			if(!weapon_mimic_star_kid.IsValid()) return
			EntFireByHandle(weapon_mimic_star_kid, "Kill", "", 0.0, null, null)
			EntFireByHandle(NetProps.GetPropEntity(weapon_mimic_star_kid, "m_hOwnerEntity"), "Kill", "", 0.0, null, null)
		},[weapon_mimic_star_kid])
	}
}