//////////////////////////
//  attack_crystal_nova //
//////////////////////////

function attack_crystal_nova()
{
	EntFire("team_round_timer", "pause", null, 0.0, null)
	SetBossSolid(SOLID_NONE)
	Disable_All_Brushes()
	stop_afterimage()

	local door = null
	while (door = Entities.FindByName(door, "board_door_*"))
	{
		door.AcceptInput("Open", "", null, null)
		door.AcceptInput("SetSpeed", "400.0", null, null)
		Entity_fade_out(door, 2.0)
	}

	Schedule(3.0, nova_phase_1)
	Schedule(26.0, nova_phase_2)
}

function nova_phase_1()
{
	local sprite_knight_front_flourish = Entities.FindByName(null, "sprite_knight_front_flourish")
	sprite_knight_front_flourish.AcceptInput("ShowSprite", "", null, null)
	SetTextureFrameIndex(sprite_knight_front_flourish, 0)

	local brush_nova_background_right = Entities.FindByName(null, "brush_nova_background_right")
	brush_nova_background_right.AcceptInput("Enable", "", null, null)
	brush_nova_background_right.ValidateScriptScope()
	brush_nova_background_right.GetScriptScope().nova_background_think <- nova_background_think
	AddThinkToEnt(brush_nova_background_right, "nova_background_think")

	local brush_nova_background_left = Entities.FindByName(null, "brush_nova_background_left")
	brush_nova_background_left.AcceptInput("Enable", "", null, null)
	brush_nova_background_left.ValidateScriptScope()
	brush_nova_background_left.GetScriptScope().nova_background_think <- nova_background_think
	AddThinkToEnt(brush_nova_background_left, "nova_background_think")

	for (local i = 1; i <= 48; i++)
	{
		local paths = Entities.FindByName(null, format("path_crystal_nova_%d_1", i))
		if (paths == null) continue

		EntityOutputs.AddOutput(paths, "OnPass", "!activator", "Kill", "", 0.0, -1)
	}
	
	Schedule(2.0, function(){
		EntFire("push_nova", "Enable", "", 0.0, null)
		Spawn_nova_trains_phase_1(16.0)
	})
}

function Spawn_nova_trains_phase_1(max_time = null)
{
	PlaySoundOnAllClients("chapter_3/audiogroup_default/snd_knight_stretch.wav", 1.0, 10)
	FadePitch("chapter_3/audiogroup_default/snd_knight_stretch.wav", 1, 15, max_time)

	local index = 1
	local start_time = Time()
	local interval = 0.5
	local path_count = 48
	local direction = 1
	local halfway_switched = false

	local template = Entities.FindByName(null, "template_star_nova_b_1")
	if (template == null) return

	template.ValidateScriptScope()
	function spawn_next()
	{
		// Stop if we've reached the time limit
		if ((max_time != null && (Time() - start_time) >= max_time)) return

		if (index > path_count)
			index = 1

		// Check if we need to switch direction at halfway
		if (!halfway_switched && ((Time() - start_time) >= max_time/2))
		{
			interval = 0.2
			direction = -1 // Reverse direction
			halfway_switched = true
		}

		local numArms = halfway_switched ? 2 : 6
		local spacing = path_count / numArms

		for (local i = 1; i <= numArms; i++)
		{
			local idx = index + i * spacing * direction
			idx = ((idx - 1 + path_count) % path_count) + 1
			if (template == null) continue
			template.GetScriptScope().PreSpawnInstance <- function(entity_class, entity_name) {
				if (entity_class == "func_tracktrain")
				{
					local speed = 500
					if (Boss_difficulty == "hard") speed = 600
					if (Boss_difficulty == "extreme") speed = 700
					return { 
						target = format("path_crystal_nova_%d_2", idx),
						speed = speed,
						startspeed = speed
					}
				}
			}
			template.GetScriptScope().PostSpawn <- function(entities) {
				foreach(handle in entities)
					NetProps.SetPropBool(handle, "m_bForcePurgeFixedupStrings", true)
			}
			template.AcceptInput("ForceSpawn", "", null, null)
		}

		index += direction
		if (index > path_count) index = 1
		if (index < 1) index = path_count
		
		Schedule(interval, spawn_next)
	}

	spawn_next()
}

function nova_phase_2()
{
	local path_count = 48
	for (local i = 1; i <= path_count; i++)
	{
		local paths = Entities.FindByName(null, format("path_crystal_nova_%d_1", i))
		if (paths == null) continue
		EntityOutputs.RemoveOutput(paths, "OnPass", "!activator", "Kill", "")
	}

	for (local i = 1; i <= path_count; i++)
	{
		local paths = Entities.FindByName(null, format("path_crystal_nova_%d_2", i))
		if (paths == null) continue
		EntityOutputs.AddOutput(paths, "OnPass", "!activator", "Kill", "", 0.0, -1)
	}

	PrecacheModel("roaring_knight/spr_roaringknight_front_roar/spr_roaringknight_front_roar.vmt")
	local sprite_knight_front_flourish = Entities.FindByName(null, "sprite_knight_front_flourish")
	PlaySpriteAnimation(sprite_knight_front_flourish, 0.2, 6)
	Schedule(1.5, PlaySoundOnAllClients, ["chapter_3/audiogroup_default/snd_knight_roar.wav", 1.0, 100])
	
	Schedule(1.5, function(){
		local sprite_knight_front_flourish = Entities.FindByName(null, "sprite_knight_front_flourish")
		sprite_knight_front_flourish.SetModel("roaring_knight/spr_roaringknight_front_roar/spr_roaringknight_front_roar.vmt")
		PlaySpriteAnimation(sprite_knight_front_flourish, 0.1, 60)
	})

	Schedule(2.0, function(){
		Spawn_nova_trains_phase_2(6.0, function(){
			Schedule(2.0, ReverseStarTrains, ["r_knight_star_train_nova_*", "sprite_star_projectile_nova_*"])
			Schedule(2.0, CreateStarChildren, ["r_knight_star_train_nova_*"])
			local sprite_knight_front_flourish = Entities.FindByName(null, "sprite_knight_front_flourish")
			sprite_knight_front_flourish.SetModel("roaring_knight/spr_roaringknight_front_flourish/spr_roaringknight_front_flourish.vmt")
			PlaySpriteAnimationReversed(sprite_knight_front_flourish, 0.2, 6)
			Schedule(2.0, function() {
				for (local i = 0; i <= 48; i++)
				{
					local paths = Entities.FindByName(null, format("path_crystal_nova_%d_2", i))
					if (paths == null) continue
					EntityOutputs.RemoveOutput(paths, "OnPass", "!activator", "Kill", "")
				}
			})

			Schedule(5.0, nova_phase_end)
		})
	})
}

function Spawn_nova_trains_phase_2(max_time = null, on_complete = null)
{
	local index = 1
	local start_time = Time()
	local batch_size = 3
	local path_count = 48

	local interval = 0.3
	if (Boss_difficulty == "hard")
		interval = 0.25
	if (Boss_difficulty == "extreme")
		interval = 0.2 // do NOT go below 0.2

	local template = Entities.FindByName(null, "template_star_nova_1")
	if (template == null) return

	template.ValidateScriptScope()

	function spawn_next()
	{
		if ((max_time != null && (Time() - start_time) >= max_time))
		{
			if (on_complete != null)
				on_complete()
			return
		}

		for (local i = 0; i < batch_size; i++)
		{
			local idx = index + i
			if (idx >= path_count)
				break

			template.GetScriptScope().PreSpawnInstance <- function(entity_class, entity_name) {
				if (entity_class == "func_tracktrain")
				{
					local speed = 350
					if (Boss_difficulty == "hard") speed = 400
					if (Boss_difficulty == "extreme") speed = 450
					if (i == 1) // 0=left, 1=middle, 2=right
						speed = speed / 1.3

					return { 
						target = format("path_crystal_nova_%d_1", idx)
						speed = speed
						startspeed = speed 
					}
				}
			}
			template.GetScriptScope().PostSpawn <- function(entities) {
				foreach(handle in entities)
					NetProps.SetPropBool(handle, "m_bForcePurgeFixedupStrings", true)
			}
			template.AcceptInput("ForceSpawn", "", null, null)
		}

		PlaySoundOnAllClients("chapter_3/audiogroup_default/snd_stardrop.wav", 0.5, 50)
		index += batch_size
		if (index >= path_count)
			index = index % path_count
		Schedule(interval, spawn_next)
	}
	spawn_next()
}

function nova_phase_end()
{
	EntFire("push_nova", "Disable", "", 0.0, null)
	PrecacheModel("roaring_knight/spr_roaringknight_front_slash/spr_roaringknight_front_slash.vmt")

	EntFire("sprite_knight_front_flourish", "HideSprite", "", 0.0, null)

	local sprite_knight_front_slash = Entities.FindByName(null, "sprite_knight_front_slash")
	sprite_knight_front_slash.AcceptInput("ShowSprite", "", null, null)
	SetTextureFrameIndex(sprite_knight_front_slash, 0)
	PlaySpriteAnimation(sprite_knight_front_slash, 0.2, 5)

	Schedule(0.5, PlaySoundOnAllClients, ["chapter_3/audiogroup_default/snd_knight_cut2.wav", 1.0, 100])
	EntFire("brush_nova_background_cut_right", "Enable", "", 0.5, null)
	EntFire("brush_nova_background_cut_left", "Enable", "", 0.5, null)

	EntFire("door_nova_background_left", "Open", "", 1.0, null)
	EntFire("door_nova_background_right", "Open", "", 1.0, null)

	EntFireByHandle(sprite_knight_front_slash, "HideSprite", "", 2.0, null, null)

	Schedule(3.0, function() {
		local door = null
		while (door = Entities.FindByName(door, "board_door_*"))
		{
			door.AcceptInput("Close", "", null, null)
			door.AcceptInput("SetSpeed", "500.0", null, null)
			Entity_fade_in(door, 1.5)
		}

		Stop_r_knight_door_parent()
		local brush_r_knight_transition_sword = Entities.FindByName(null, "brush_r_knight_transition_sword")
		PlaySpriteAnimation(brush_r_knight_transition_sword, 0.2, 3)
		Schedule(0.7, start_afterimage)

		SetBossSolid(SOLID_VPHYSICS)
		local delay = 10.0
		// local delay = 15.0
		// if (Boss_difficulty == "hard")
		// 	delay = 12.5

		// if (Boss_difficulty == "extreme")
		// 	delay = 10.0

		EntFire("team_round_timer", "resume", null, delay, null)

		local brush_nova_background_left = Entities.FindByName(null, "brush_nova_background_left")
		StopThink(brush_nova_background_left)
		local brush_nova_background_right = Entities.FindByName(null, "brush_nova_background_right")
		StopThink(brush_nova_background_right)
		
		Schedule(delay, R_knight_rand_attack)
	})
}

function nova_background_think()
{
	local scope = self.GetScriptScope()
	if (!("r" in scope)) scope.r <- 0
	if (!("g" in scope)) scope.g <- 0
	if (!("b" in scope)) scope.b <- 0

	local r = scope.r, g = scope.g, b = scope.b

	if (r < 255 && g == 0 && b == 0) {
		r++
	} else if (r == 255 && b == 0 && g < 255) {
		g++
	} else if (r == 255 && g == 255 && b < 255) {
		b++
	} else if (b == 255 && g == 255 && r > 0) {
		r--
	} else if (r == 0 && b == 255 && g > 0) {
		g--
	} else if (r == 0 && g == 0 && b > 0) {
		b--
	}

	scope.r = r
	scope.g = g
	scope.b = b

	self.AcceptInput("Color", format("%d %d %d", r, g, b), null, null)

	return -1
}