///////////////////////////
//  attack_knife_dance   //
///////////////////////////

::knife_dance_used <- false

function attack_knife_dance()
{
	local interval = 2.9
	if (Boss_difficulty == "hard")
		interval = 2.8

	if (Boss_difficulty == "extreme")
		interval = 2.6

	local duration = 25.0

	if (!knife_dance_used)
	{
		printl("attack_knife_dance")
		knife_dance_spawn_repeat(interval, duration)
		Schedule(duration, R_knight_rand_attack)
		knife_dance_used = true
	} else {
		printl("attack_knife_dance_extra")
		knife_dance_spawn_repeat(interval, duration)
		knife_dance_circle(duration)
		Schedule(duration, R_knight_rand_attack)
	}
}

::angle_index <- 0
::angle_random <- false
function knife_dance_spawn_repeat(start_interval, duration)
{
	local start_time = Time()
	local interval = start_interval
	angle_index = 0
	
	function spawn_and_repeat()
	{
		knife_dance_spawn()
		local elapsed = Time() - start_time
		if (elapsed > duration) return
		interval = start_interval - (0.1 * floor(elapsed))
		if (interval < 0.1) interval = 0.1
		if (elapsed + interval + 2.0 < duration)
			Schedule(interval, spawn_and_repeat)
	}
	spawn_and_repeat()
}

::handled_brushes <- []
function knife_dance_spawn()
{
	local template_sword_dance = Entities.FindByName(null, "template_sword_dance")
	if (template_sword_dance == null) return
	template_sword_dance.ValidateScriptScope()
	template_sword_dance.GetScriptScope().PreSpawnInstance <- function(entity_class, entity_name) {
		if (entity_class == "func_tracktrain")
		{
			local speed = 3000
			if (Boss_difficulty == "hard")
				speed = 4000
			if (Boss_difficulty == "extreme")
				speed = 6000

			return {
				startspeed = speed,
			}
		}

	}
	template_sword_dance.GetScriptScope().PostSpawn <- function(entities) {
		foreach( targetname, handle in entities )
		{
			if (startswith(targetname, "brush_sword_dance_measure"))
			{
				local alive_players = GetAlivePlayers()
				if (alive_players.len() == 0) return
				local target = alive_players[RandomInt(0, alive_players.len() - 1)]
				local target_pos = target.GetOrigin()
				target_pos.z = 0

				// Compass angles: N, NE, E, SE, S, SW, W, NW
				local compass_angles = [0, 45, 90, 135, 180, 225, 270, 315]

				PlaySoundOnAllClients("chapter_3/audiogroup_default/snd_knight_jump_quick.wav", 1.0, 130)
				handle.SetOrigin(target_pos + Vector(0, 0, 20))
				local angle
				if (angle_random == true)
				{
					angle = compass_angles[RandomInt(0, compass_angles.len() - 1)]
				} else {
					angle = compass_angles[angle_index % compass_angles.len()]
				}
				angle_index++

				handle.SetAbsAngles(QAngle(0, angle, 0))

				handle.ValidateScriptScope()
				handle.GetScriptScope().Knife_dance_think <- Knife_dance_think
				handle.GetScriptScope().Target <- target

				AddThinkToEnt(handle, "Knife_dance_think")
				Schedule(1.6, PlaySoundOnAllClients, ["chapter_3/audiogroup_default/snd_knight_cut2.wav", 1.0, 130])
				Schedule(1.6, StopThink, [handle])
			}
			NetProps.SetPropBool(handle, "m_bForcePurgeFixedupStrings", true)
		}
	}

	template_sword_dance.AcceptInput("ForceSpawn", "", null, null)
}

::Knife_dance_think <- function()
{
	local scope = self.GetScriptScope()
	local target = scope.Target
	if (target == null || !target.IsValid() || !(target.IsAlive()))
	{
		StopThink(self)
		return
	}
	local target_pos = target.GetOrigin()
	target_pos.z = 0
	local target_angles = target.GetAbsAngles()
	self.KeyValueFromVector("origin", target_pos + Vector(0, 0, 20)) // using KeyValueFromVector seems to be the smoothest
	return -1
}

function attack_knife_dance_extra(duration, interval)
{
	knife_dance_spawn_repeat(interval, duration)
	knife_dance_circle(duration)
	Schedule(duration, R_knight_rand_attack)
}

function knife_dance_circle(duration)
{
	local knife_dance_rot_1 = Entities.FindByName(null, "knife_dance_rot_1")

	local template = Entities.FindByName(null, "template_sword_circle")
	local num_swords = 15
	local center = knife_dance_rot_1.GetOrigin()
	local radius = 1024
	
	template.ValidateScriptScope()
	for (local i = 0; i < num_swords; i++)
	{
		local delay = 0.15 * i
		Schedule(delay, function(idx) {
			local angle_deg = 360.0 - ((360.0 / num_swords) * idx)
			local angle_rad = angle_deg * PI / 180.0
			local offset = Vector(cos(angle_rad), sin(angle_rad), 0) * radius
			local spawn_pos = center + offset
			spawn_pos.z -= 64

			template.GetScriptScope().PreSpawnInstance <- function(entity_class, entity_name) {
					return {
						origin = spawn_pos,
						angles = format("0, %i, 90", angle_deg - 90)
					}
			}

			template.GetScriptScope().PostSpawn <- function(entities) {
				foreach(handle in entities)
					NetProps.SetPropBool(handle, "m_bForcePurgeFixedupStrings", true)
			}
			
			template.AcceptInput("ForceSpawn", "", null, null)
		}, [i])
	}

	local delay = 0.15 * num_swords
	Schedule(delay, function() {
		if (knife_dance_rot_1 == null) return
	
		knife_dance_rot_1.AcceptInput("Start", "", null, null)

		if (Boss_difficulty == "normal")
			knife_dance_rot_1.AcceptInput("SetSpeed", "0.2", null, null)

		if (Boss_difficulty == "hard")
			knife_dance_rot_1.AcceptInput("SetSpeed", "0.3", null, null)

		if (Boss_difficulty == "extreme")
			knife_dance_rot_1.AcceptInput("SetSpeed", "0.4", null, null)
		
		local targets = [
			"target_circle_center", 
			"target_circle_upper_right", 
			"target_circle_upper_left",
			"target_circle_bottom_right",
			"target_circle_bottom_left"
		]

		knife_dance_rot_1.ValidateScriptScope()
		knife_dance_rot_1.GetScriptScope().knife_dance_rot_think <- knife_dance_rot_think
		knife_dance_rot_1.GetScriptScope().targets <- targets

		AddThinkToEnt(knife_dance_rot_1, "knife_dance_rot_think")
		Schedule(duration/2, CloseSwords, [5.0, 448])

		Schedule(duration, StopThink, [knife_dance_rot_1])
		Schedule(duration, function(knife_dance_rot_1) {
			knife_dance_rot_1.AcceptInput("Stop", "", null, null)
			knife_dance_rot_1.AcceptInput("SetSpeed", "0.0", null, null)
			knife_dance_rot_1.AcceptInput("Disable", "", null, null)
		}, [knife_dance_rot_1])
	})

	EntFire("hurt_projectile_sword_circle*", "Enable", null, delay, null)
	EntFire("hurt_projectile_sword_circle*", "Disable", null, duration, null)

	EntFire("projectile_sword_circle*", "Kill", null, duration, null)
}

function knife_dance_rot_think()
{
	local scope = self.GetScriptScope()
	local targets = scope.targets

	if (!("current_target" in scope) || Time() >= scope.next_target_change)
	{
		local target_name = targets[RandomInt(0, targets.len() - 1)]
		local target_ent = Entities.FindByName(null, target_name)
		scope.current_target <- target_ent
		scope.next_target_change <- Time() + RandomFloat(2.0, 5.0)
	}

	if ("current_target" in scope && scope.current_target != null)
	{
		local pos = self.GetOrigin()
		local target_pos = scope.current_target.GetOrigin()
		local dir = (target_pos - pos)
		dir.z = 0
		local dist = dir.Length()
		if (dist > 1) 
		{
			dir.Norm()
			local speed = 100
			local dt = FrameTime()
			dir *= speed * dt
			self.SetOrigin(pos + dir)
		}
	}

	return -1
}

function CloseSwords(duration = 2.0, closed_distance = 512)
{
	local swords = []
	local start_offsets = {}

	local sword = null
	while (sword = Entities.FindByName(sword, "projectile_sword_circle*"))
	{
		if (sword == null) continue
		if (sword.IsEFlagSet(1048576)) continue
		sword.AddEFlags(1048576)

		sword.ValidateScriptScope()
		local scope = sword.GetScriptScope()
		scope.start_offset <- sword.GetLocalOrigin()
		scope.duration <- duration
		scope.start_time <- Time()
		scope.closed_distance <- closed_distance

		scope.close_think <- function()
		{
			local scope = self.GetScriptScope()
			local t = (Time() - scope.start_time) / scope.duration
			if (t > 1.0) t = 1.0

			local start_offset = scope.start_offset
			local dir = Vector(start_offset.x, start_offset.y, 0)
			local original_z = start_offset.z
			if (dir.Length() > 0)
			{
				dir.Norm()
				local closed_offset = dir * scope.closed_distance
				local new_offset = Vector(
					Lerp(t, start_offset.x, closed_offset.x),
					Lerp(t, start_offset.y, closed_offset.y),
					original_z // keep z unchanged
				)
				self.SetLocalOrigin(new_offset)
			} else {
				self.SetLocalOrigin(Vector(0, 0, original_z))
			}

			return -1
		}

		AddThinkToEnt(sword, "close_think")
	}
}