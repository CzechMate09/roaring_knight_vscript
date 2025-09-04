////////////////////////////
//  attack_sanguine_slash //
////////////////////////////

::sanguine_slash_used <- false

function attack_sanguine_slash()
{
	local delay_between = 2.0

	if (Boss_difficulty == "hard")
		delay_between = 1.4

	if (Boss_difficulty == "extreme")
		delay_between = 1.0

	if (!sanguine_slash_used)
	{
		start_sanguine_slash(delay_between, function() {
			knight_attack_go_to_start_origin = true
			move_brush_random(Entities.FindByName(null, "brush_r_knight_attack"), 1.0)
			Schedule(1.0, sanguine_slash_end)
		})
		sanguine_slash_used = true
	} else {
		start_sanguine_slash(delay_between, function(){
			knight_attack_go_to_start_origin = true
			move_brush_random(Entities.FindByName(null, "brush_r_knight_attack"), 1.0)
			Schedule(1.0, function(){
				Disable_All_Brushes()
				Enable_Brush("brush_r_knight_flurry_prepare")
				do_slasher(50, sanguine_slash_end)
			})
		})
	}
}

::knight_attack_start_origin <- null
::knight_attack_go_to_start_origin <- false

function move_brush_random(brush, max_time)
{
	brush.ValidateScriptScope()
	brush.GetScriptScope().start_time <- Time()

	if (knight_attack_go_to_start_origin == true)
	{
		brush.GetScriptScope().target_origin <- knight_attack_start_origin
	} else {
		brush.GetScriptScope().target_origin <- null
	}

	brush.GetScriptScope().max_time <- max_time
	brush.GetScriptScope().start_origin <- knight_attack_start_origin
	brush.GetScriptScope().move_brush_random_think <- move_brush_random_think
	AddThinkToEnt(brush, "move_brush_random_think")
}

function move_brush_random_think()
{
	local brush = self
	local scope = brush.GetScriptScope()
	local max_time = scope.max_time
	local origin = brush.GetOrigin()

	if (Time() - scope.start_time >= max_time) 
	{
		StopThink(brush)
		NetProps.SetPropString(brush, "m_iszScriptThinkFunction", "")
		return
	}

	local Mins = Vector(800, 0, -800)
	local Maxs = Vector(800, 0, 800)
 
	if (scope.target_origin == null) 
		scope.target_origin = Vector(RandomInt(-1200, 1200), 0, RandomInt(50, 1000)) - Vector(0, 150, 0)

	local pos = origin - Vector(0, 150, 0)
	local dir = scope.target_origin - pos
	local dist = dir.Length()
	dir.Norm()
	local speed = 10000
	dir *= speed * FrameTime()
	local new_origin = pos + dir
	new_origin.y = -2480
	brush.SetAbsOrigin(new_origin)
	return -1
}

function start_sanguine_slash(delay_between = 2.2, on_finish = null)
{
	local templates = [
		Entities.FindByName(null, "template_sanguine_slash_1"),
		Entities.FindByName(null, "template_sanguine_slash_2"),
		Entities.FindByName(null, "template_sanguine_slash_3"),
		Entities.FindByName(null, "template_sanguine_slash_4")
	]

	local p1 = Entities.FindByName(null, "target_circle_upper_left")
	local p2 = Entities.FindByName(null, "target_circle_upper_right")
	local p3 = Entities.FindByName(null, "target_circle_bottom_right")
	local p4 = Entities.FindByName(null, "target_circle_bottom_left")

	local min_x = Min(Min(p1.GetOrigin().x, p2.GetOrigin().x), Min(p3.GetOrigin().x, p4.GetOrigin().x))
	local max_x = Max(Max(p1.GetOrigin().x, p2.GetOrigin().x), Max(p3.GetOrigin().x, p4.GetOrigin().x))
	local min_y = Min(Min(p1.GetOrigin().y, p2.GetOrigin().y), Min(p3.GetOrigin().y, p4.GetOrigin().y))
	local max_y = Max(Max(p1.GetOrigin().y, p2.GetOrigin().y), Max(p3.GetOrigin().y, p4.GetOrigin().y))
	local z = p1.GetOrigin().z

	local brush_r_knight_attack = Entities.FindByName(null, "brush_r_knight_attack")
	if (knight_attack_start_origin == null)
		knight_attack_start_origin <- brush_r_knight_attack.GetOrigin()

	function spawn_template_at_index(idx) {
		local new_delay_between = delay_between - 0.2

		local rand_x = Lerp(RandomFloat(0, 1), min_x, max_x)
		local rand_y = Lerp(RandomFloat(0, 1), min_y, max_y)
		local rand_point = Vector(rand_x, rand_y, z)

		local template = templates[idx]
		template.AcceptInput("ForceSpawn", "", null, null)

		local rot_entities = [
			Entities.FindByName(null, "sanguine_slash_rot_1*"),
			Entities.FindByName(null, "sanguine_slash_rot_2*"),
			Entities.FindByName(null, "sanguine_slash_rot_3*"),
			Entities.FindByName(null, "sanguine_slash_rot_4*")
		]
		local rot = rot_entities[idx]

		if (rot != null)
			rot.SetOrigin(rand_point)

		local brushes = [
			Entities.FindByName(null, "brush_sanguine_slash_1*"),
			Entities.FindByName(null, "brush_sanguine_slash_2*"),
			Entities.FindByName(null, "brush_sanguine_slash_3*"),
			Entities.FindByName(null, "brush_sanguine_slash_4*")
		]

		local hurt = [
			Entities.FindByName(null, "hurt_sanguine_slash_1*"),
			Entities.FindByName(null, "hurt_sanguine_slash_2*"),
			Entities.FindByName(null, "hurt_sanguine_slash_3*"),
			Entities.FindByName(null, "hurt_sanguine_slash_4*")
		]

		Disable_All_Brushes()
		Enable_Brush("brush_r_knight_attack")
		Stop_r_knight_door_parent()

		move_brush_random(brush_r_knight_attack, new_delay_between)

		SetTextureFrameIndex(brush_r_knight_attack, 1)
		Schedule(0.2, SetTextureFrameIndex, [brush_r_knight_attack, 2])

		rot.AcceptInput("Start", "", null, null)
		PlaySoundOnAllClients("chapter_3/audiogroup_default/snd_knight_rotatingslash_line.wav")

		local delay = new_delay_between / 2

		Schedule(delay, function() {
			Do_slash(new_delay_between / 2)
		})

		function Do_slash(duration){
			EntFireByHandle(rot, "Stop", "", 0.0, null, null)
			EntFireByHandle(brushes[idx], "Color", "255 255 255", duration / 2, null, null)
			EntFire("brush_sanguine_slash_top_*", "Disable", "", duration / 2, null)
			EntFireByHandle(hurt[idx], "Enable", "", duration / 2, null, null)
			Schedule(duration / 2, SetTextureFrameIndex, [brush_r_knight_attack, 3])
			Schedule(duration / 2, PlaySoundOnAllClients, ["chapter_3/audiogroup_default/snd_knight_cut.wav"])
			Schedule(duration / 2, PlaySoundOnAllClients, ["chapter_3/audiogroup_default/snd_explosion_firework.wav"])
			Schedule((duration / 2) + 0.1, SetTextureFrameIndex, [brush_r_knight_attack, 4])
			Schedule((duration / 2) + 0.2, SetTextureFrameIndex, [brush_r_knight_attack, 5])
			EntFireByHandle(rot, "Kill", "", duration, null, null)
		}
	}
	
	delay_between = delay_between + 0.2
	local multiplier = 2
	if (Boss_difficulty == "hard" || Boss_difficulty == "extreme")
		multiplier = 3

	local spawn_count = templates.len() * multiplier
	for (local i = 0; i < spawn_count; i++) {
		local idx = i / multiplier
		Schedule(i * delay_between, spawn_template_at_index, [idx])
	}

	if (on_finish != null)
		Schedule(spawn_count * delay_between, on_finish)
}

function do_slasher(slashes, on_finish = null)
{
	local template = Entities.FindByName(null, "template_sanguine_slash_1")
	if (template == null) return
	template.AcceptInput("ForceSpawn", "", null, null)

	local target_circle_center = Entities.FindByName(null, "target_circle_center")
	local position = target_circle_center.GetOrigin()
	local sanguine_slash_rot_1 = Entities.FindByName(null, "sanguine_slash_rot_1*")
	local brush = Entities.FindByName(null, "brush_sanguine_slash_1*")

	sanguine_slash_rot_1.SetOrigin(position)
	brush.AcceptInput("Enable", "", null, null)
	sanguine_slash_rot_1.AcceptInput("Start", "", null, null)
	local start_time = RandomFloat(1.5, 2.5)

	EntFire("hurt_sanguine_slash_1*", "Enable", "", start_time, null)
	
	if (Boss_difficulty == "normal")
		EntFireByHandle(sanguine_slash_rot_1, "SetSpeed", "0.2", start_time, null, null)

	if (Boss_difficulty == "hard")
		EntFireByHandle(sanguine_slash_rot_1, "SetSpeed", "0.25", start_time, null, null)

	if (Boss_difficulty == "extreme")
		EntFireByHandle(sanguine_slash_rot_1, "SetSpeed", "0.3", start_time, null, null)

	function ColorFlashAndSound(brush, times, start_time, color_time) {
		for (local i = 0; i < times; i++) {
			local t = start_time + i * color_time
			local brush_r_knight_flurry = Entities.FindByName(null, "brush_r_knight_flurry")
			EntFireByHandle(brush, "Color", "255 255 255", t, null, null)
			Schedule(t, SetTextureFrameIndex, [brush_r_knight_flurry, i])
			Schedule(t, PlaySoundOnAllClients, ["chapter_3/audiogroup_default/snd_knight_cut.wav"])
			// EntFireByHandle(brush, "Color", "255 0 0", t + color_time/2, null, null) // Disabled due to epilepsy concerns
		}

		EntFireByHandle(sanguine_slash_rot_1, "Kill", "", start_time + times * color_time + color_time/2, null, null)
		Schedule(start_time + times * color_time + color_time/2, PlaySoundOnAllClients, ["chapter_3/audiogroup_default/snd_knight_puff.wav"])

		if (on_finish != null)
			Schedule(start_time + times * color_time + color_time/2, on_finish)
	}
	
	Schedule(start_time, function(){
		Disable_All_Brushes()
		Enable_Brush("brush_r_knight_flurry")
	})

	ColorFlashAndSound(brush, slashes, start_time, 0.1)
}

function sanguine_slash_end()
{
	local brush_r_knight_attack = Entities.FindByName(null, "brush_r_knight_attack")
	knight_attack_go_to_start_origin = false
	brush_r_knight_attack.SetAbsOrigin(knight_attack_start_origin)
	R_knight_rand_attack()
}