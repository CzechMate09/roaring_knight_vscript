///////////////////////////////
//  attack_under_box_attack  //
///////////////////////////////

function attack_under_box_attack()
{
	Disable_All_Brushes()
	Stop_r_knight_door_parent()
	stop_afterimage()
	local brush_r_knight_transition_sword = Entities.FindByName(null, "brush_r_knight_transition_sword")
	PlaySoundOnAllClients("chapter_3/audiogroup_default/snd_knight_teleport.wav", 1.0, 100)

	PlaySpriteAnimationReversed(brush_r_knight_transition_sword, 0.15, 3, function(){
		SetBossSolid(SOLID_NONE)
		Disable_All_Brushes()
		local spawn_count = 7
		local interval = 1.5

		if (Boss_difficulty == "hard")
		{
			spawn_count = 10
			interval = 1.3
		}

		if (Boss_difficulty == "extreme")
		{
			spawn_count = 20
			interval = 1.0
		}
		Schedule(2.0, start_attack_under_box_attack, [spawn_count, interval, end_attack_under_box_attack])
	})
}

function start_attack_under_box_attack(spawn_count, interval, on_finish = null)
{
	function spawnt_template()
	{
		local p1 = Entities.FindByName(null, "target_circle_upper_left")
		local p2 = Entities.FindByName(null, "target_circle_upper_right")
		local p3 = Entities.FindByName(null, "target_circle_bottom_right")
		local p4 = Entities.FindByName(null, "target_circle_bottom_left")

		local min_x = Min(Min(p1.GetOrigin().x, p2.GetOrigin().x), Min(p3.GetOrigin().x, p4.GetOrigin().x))
		local max_x = Max(Max(p1.GetOrigin().x, p2.GetOrigin().x), Max(p3.GetOrigin().x, p4.GetOrigin().x))
		local min_y = Min(Min(p1.GetOrigin().y, p2.GetOrigin().y), Min(p3.GetOrigin().y, p4.GetOrigin().y))
		local max_y = Max(Max(p1.GetOrigin().y, p2.GetOrigin().y), Max(p3.GetOrigin().y, p4.GetOrigin().y))
		local z = p1.GetOrigin().z - 155

		// Pick a random point in the rectangle, or should I make it pick a random player instead?
		local rand_x = Lerp(RandomFloat(0, 1), min_x, max_x)
		local rand_y = Lerp(RandomFloat(0, 1), min_y, max_y)

		local rand_point = Vector(rand_x, rand_y, z)

		local template = Entities.FindByName(null, "template_attack_underboxattack")
		template.ValidateScriptScope()
		template.GetScriptScope().PreSpawnInstance <- function(entity_class, entity_name) {} //needed for PostSpawn
		template.GetScriptScope().PostSpawn <- function(entities) {
			foreach( targetname, handle in entities )
			{
				local delay = interval
				local life_time = delay + 1.0
				if (startswith(targetname, "brush_attack_underboxattack"))
				{
					handle.SetOrigin(rand_point)
					Entity_fade_in(handle, delay)
					EntFireByHandle(handle, "Kill", "", life_time, null, null)
				}

				if (startswith(targetname, "weapon_mimic_underbox_attack"))
				{
					EntFireByHandle(handle, "FireOnce", "", delay, null, null)
					EntFireByHandle(handle, "ClearParent", "", delay, null, null)
					EntFireByHandle(handle, "Kill", "", 20.0, null, null)
				}

				if (startswith(targetname, "hurt_attack_underboxattack"))
					EntFireByHandle(handle, "Enable", "", delay, null, null)

				if (startswith(targetname, "sprite_attack_underboxattack"))
				{
					EntFireByHandle(handle, "ShowSprite", "", delay, null, null)
					EntFireByHandle(handle, "ClearParent", "", delay, null, null)
					handle.ValidateScriptScope()
					handle.GetScriptScope().Weird_shape_think <- Weird_shape_think

					Schedule(delay, AddThinkToEnt, [handle, "Weird_shape_think"])
					Schedule(delay, PlaySoundOnAllClients, ["chapter_3/audiogroup_default/snd_drake_dodge.wav"])
					EntFireByHandle(handle, "Kill", "", life_time, null, null)
				}

				NetProps.SetPropBool(handle, "m_bForcePurgeFixedupStrings", true)

			}
		}
		template.AcceptInput("ForceSpawn", "", null, null)
	}

	for (local i = 0; i < spawn_count; i++)
		Schedule(i * interval, spawnt_template)

	if (on_finish != null)
		Schedule(spawn_count * interval, on_finish)
}

::Weird_shape_think <- function() 
{
	if (self == null) return
	if (!self.IsValid()) return
	local origin = self.GetOrigin()
	local speed = 40
	self.SetOrigin(Vector(origin.x, origin.y, origin.z + speed))
	return -1
}

function end_attack_under_box_attack()
{
	Schedule(2.0, function(){
		local brush_r_knight_transition_sword = Entities.FindByName(null, "brush_r_knight_transition_sword")
		PlaySpriteAnimation(brush_r_knight_transition_sword, 0.2, 3)
		Schedule(0.7, start_afterimage)
		SetBossSolid(SOLID_VPHYSICS)
		Schedule(2.0, R_knight_rand_attack)
	})
}