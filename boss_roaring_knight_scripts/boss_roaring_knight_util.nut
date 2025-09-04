/////////////////////
//  util functions //
/////////////////////

// brushes
::GetAllKnightBrushes <- function()
{
	return [
		"brush_r_knight_ball_fly",
		"brush_r_knight_ball_transition",
		"brush_r_knight_idle_overworld",
		"brush_r_knight_hurt_idle",
		"brush_r_knight_pose",
		"brush_r_knight_sword_appear",
		"brush_r_knight_idle_sword",
		"brush_r_knight_point",
		"brush_r_knight_attack",
		"r_knight_sword_brush",
		"brush_r_knight_transition_sword",
		"brush_r_knight_flurry",
		"brush_r_knight_flurry_prepare",
		"brush_r_knight_static",
		"brush_r_knight_crescentslash",
		"brush_r_knight_droop_up", // alt intro
		"brush_r_knight_faceaway_turning",
		"brush_r_knight_faceaway_idle",
		"brush_r_knight_ball_transition_2",
		"brush_r_knight_ball_fly_2",
		"brush_r_knight_droop"
	]
}

::Disable_All_Brushes <- function()
{
	local brushes = GetAllKnightBrushes()
	for (local i = 0; i < brushes.len(); i++)
	{
		Disable_Brush(brushes[i])
	}
}

::Enable_Brush <- function(brush_name)
{
	local brush
	if (typeof(brush_name) == "string")
	{
		brush = Entities.FindByName(null, brush_name)
	} else {
		brush = brush_name
	}

	if (brush == null) return
	active_knight_brush = brush
	brush.AcceptInput("Enable", "", null, null)
}

::Disable_Brush  <- function(brush_name)
{
	local brush
	if (typeof(brush_name) == "string")
	{
		brush = Entities.FindByName(null, brush_name)
	} else {
		brush = brush_name
	}

	if (brush == null) return
	active_knight_brush = null
	brush.AcceptInput("Disable", "", null, null)
}

// parenting
function parent_activator_to_caller()
{
	activator.AcceptInput("SetParent", caller.GetName(), null, null)
}

function clearParentBoard()
{
	EntFire("brush_board_top_left", "ClearParent", "", 0.0, null)
	EntFire("brush_board_top_right", "ClearParent", "", 0.0, null)
	EntFire("brush_board_bottom_left", "ClearParent", "", 0.0, null)
	EntFire("brush_board_bottom_right", "ClearParent", "", 0.0, null)
}

// Base_boss
function SetBossSolid(solid)
{
	local base_boss = Entities.FindByName(null, "base_boss_r_knight")
	if (base_boss == null) return
	if (solid == SOLID_NONE) {
		EntFire("sticky_trigger", "Disable", "", 0.0, null)
		EntFire("sprite_boss_healthbar", "HideSprite", "", 0.0, null)
	} else {
		EntFire("sticky_trigger", "Enable", "", 0.0, null)
		EntFire("sprite_boss_healthbar", "ShowSprite", "", 0.0, null)
	}

	base_boss.SetSolid(solid)
}

function SetBossOrigin(origin)
{
	local base_boss = Entities.FindByName(null, "base_boss_r_knight")
	if (base_boss == null) return
	// base_boss.SetOrigin(origin)
	base_boss.SetAbsOrigin(origin)
}

function GetBossOrigin()
{
	local base_boss = Entities.FindByName(null, "base_boss_r_knight")
	if (base_boss == null) return
	return base_boss.GetOrigin()
}

function GetRKnightHealth()
{
	local base_boss = Entities.FindByName(null, "base_boss_r_knight")
	return base_boss == null ? 0 : base_boss.GetHealth()
}

function GetRKnightMaxHealth()
{
	local base_boss = Entities.FindByName(null, "base_boss_r_knight")
	return base_boss == null ? 0 : base_boss.GetMaxHealth()
}

function SetRKnightHealth(health)
{
	local base_boss = Entities.FindByName(null, "base_boss_r_knight")
	if (base_boss == null) return
	if (!base_boss.IsValid()) return
	base_boss.SetHealth(health)
}

function SetRKnightMaxHealth(max_health)
{
	local base_boss = Entities.FindByName(null, "base_boss_r_knight")
	if (base_boss == null) return
	if (!base_boss.IsValid()) return
	base_boss.SetMaxHealth(max_health)
}

// players

function GetPlayerName(player)
{
	return NetProps.GetPropString(player, "m_szNetname")
}

function teleport_players_to_arena(client = null)
{
	local teleport_targets = [
		"target_teleport_left_1",
		"target_teleport_left_2",
		"target_teleport_right_1",
		"target_teleport_right_2"
	]

	local player = client
	if (player != null)
	{
		local random_target =  Entities.FindByName(null, teleport_targets[RandomInt(0, teleport_targets.len() - 1)]) 
		player.Teleport(true, random_target.GetOrigin(), true, random_target.GetAbsAngles(), false, Vector(0,0,0))
	} else {
		local players = GetAlivePlayers()
		for (local i = 0; i < players.len(); i++ )
		{
			local player = players[i]
			local random_target =  Entities.FindByName(null, teleport_targets[RandomInt(0, teleport_targets.len() - 1)]) 
			player.Teleport(true, random_target.GetOrigin(), true, random_target.GetAbsAngles(), false, Vector(0,0,0))
		}
	}
}

function GetAllRedPlayers()
{
	local red_players = []
	for (local i = 0; i <= MaxClients(); i++)
	{
		local player = PlayerInstanceFromIndex(i)
		if (player == null) continue
		if (!player.IsValid()) continue
		if (player.GetTeam() != TF_TEAM_RED) continue

		red_players.append(player)
	}

	return red_players
}

::GetAlivePlayers <- function()
{
	local alive_players = []
	for (local i = 0; i <= MaxClients(); i++)
	{
		local player = PlayerInstanceFromIndex(i)
		if (player == null) continue
		if (!(player.IsAlive())) continue
		alive_players.append(player)
	}

	return alive_players
}

function GetAllPlayers()
{
	local all_players = []
	for (local i = 0; i <= MaxClients(); i++)
	{
		local player = PlayerInstanceFromIndex(i)
		if (player == null) continue
		all_players.append(player)
	}

	return all_players
}

function GiveMantleRandom()
{
	// select random player to recieve the shadow mantle
	local players = GetAlivePlayers()
	if (players.len() > 0)
	{
		local random_player = players[RandomInt(0, players.len() - 1)]
		local shadow_mantle_flag = Entities.FindByName(null, "shadow_mantle_flag")
		shadow_mantle_flag.SetOrigin(random_player.GetOrigin())
	} else {
		Shadow_mantle_holder = null
	}
}

// Animations and effects

::SetTextureFrameIndex <- function(entity, index)
{
	NetProps.SetPropInt(entity, "m_iTextureFrameIndex", index)
}

::GetTextureFrameIndex <- function(entity)
{
	if (typeof(entity) == "string")
		entity = Entities.FindByName(null, entity.tostring())

	if (entity == null) return
	return NetProps.GetPropInt(entity, "m_iTextureFrameIndex")
}

::PlaySpriteAnimation <- function(entity, delay, frames, on_finish = null)
{
	if (typeof(entity) == "string")
		entity = Entities.FindByName(null, entity.tostring())

	Disable_All_Brushes()
	Enable_Brush(entity)

	for (local i = 0; i <= frames; i++)
	{
		Schedule(delay * i, SetTextureFrameIndex, [entity, i])
	}

	if (on_finish != null) 
		Schedule(delay * (frames + 1), on_finish)
}

::PlaySpriteAnimationReversed <- function(entity, delay, frames, on_finish = null)
{
	if (typeof(entity) == "string")
		entity = Entities.FindByName(null, entity.tostring())

	Disable_All_Brushes()
	Enable_Brush(entity)

	for (local i = frames; i >= 0; i--)
	{
		Schedule(delay * (frames - i), SetTextureFrameIndex, [entity, i])
	}

	if (on_finish != null)
		Schedule(delay * (frames + 1), on_finish)
}

::Entity_fade_in <- function(entity, fadeDuration)
{
	if (!entity || fadeDuration <= 0) return
	NetProps.SetPropInt(entity, "m_nRenderMode", 1)

	local minStepTime = 0.1
	local steps = Max(1, fadeDuration / minStepTime)
	local stepTime = fadeDuration / steps
	local alphaStep = 255.0 / steps

	for (local i = 0; i <= steps; i++)
	{
		local alpha = Clamp(floor(i * alphaStep), 0, 255)
		Schedule(i * stepTime, function(ent, a) {
			if (ent == null) return
			if(!ent.IsValid()) return
			ent.AcceptInput("Alpha", a.tostring(), null, null)
			// ent.KeyValueFromString("renderamt", a.tostring())
		}, [entity, alpha])
	}
}

function Entity_fade_out(entity, fadeDuration)
{
	if (!entity || fadeDuration <= 0) return
	NetProps.SetPropInt(entity, "m_nRenderMode", 1)
	
	local minStepTime = 0.1
	local steps = Max(1, fadeDuration / minStepTime)
	local stepTime = fadeDuration / steps
	local alphaStep = 255.0 / steps
	// doesn't work if "$alphatest" is set to 1...
	for (local i = 0; i <= steps; i++)
	{
		local alpha = Clamp(255 - floor(i * alphaStep), 0, 255)
		Schedule(i * stepTime, function(ent, a) {
			if (ent == null) return
			if(!ent.IsValid()) return
			ent.AcceptInput("Alpha", a.tostring(), null, null)
			// ent.KeyValueFromString("renderamt", a.tostring())
		}, [entity, alpha])
	}
}

::SetEntityColor <- function(entity, r, g, b, a)
{
	local color = (r) | (g << 8) | (b << 16) | (a << 24)
	NetProps.SetPropInt(entity, "m_clrRender", color)
}

function RunBrushPhases(phases, idx = 0) 
{
	if (idx >= phases.len()) return

	local phase = phases[idx]

	if (phase.type == "sequence") {
		SwitchBrushSequence(phase.sequence, phase.interval, function() {
			RunBrushPhases(phases, idx + 1)
		})
	} else if (phase.type == "schedule") {
		Schedule(phase.delay, function() {
			if ("func" in phase) phase.func()
			RunBrushPhases(phases, idx + 1)
		})
	} else if (phase.type == "custom") {
		phase.func(function() {
			RunBrushPhases(phases, idx + 1)
		})
	}
}

function SwitchBrushSequence(sequence, interval, on_complete = null) 
{
	local snd_knight_static = Entities.FindByName(null, "snd_knight_static_loop")
	snd_knight_static.AcceptInput("PlaySound", "", null, null)

	local idx = 0
	function next_step() {
		if (idx >= sequence.len()) {
			if (on_complete != null) on_complete()
			snd_knight_static.AcceptInput("StopSound", "", null, null)
			return
		}
		local brush_name = sequence[idx][0]
		local frames = sequence[idx][1]
		Disable_All_Brushes()
		Enable_Brush(brush_name)
		foreach (frame in frames) {
			SetTextureFrameIndex(Entities.FindByName(null, brush_name), frame)
		}
		idx++
		Schedule(interval, next_step)
	}
	next_step()
}

// Sounds

::PlaySoundOnAllClients <- function(name, volume = 1.0, pitch = 100, flags = 0)
{
	// PrecacheSound(name)
	EmitSoundEx({
		sound_name = name,
		volume = volume
		pitch = pitch,
		flags = flags,
		filter_type = RECIPIENT_FILTER_GLOBAL
	})
}

function PlaySoundOnClient(player, name, volume = 1.0, pitch = 100, flags = 0)
{
	EmitSoundEx({
		sound_name = name,
		volume = volume
		pitch = pitch,
		entity = player,
		flags = flags,
		filter_type = RECIPIENT_FILTER_SINGLE_PLAYER
	})
}

::ChangePitch <- function(soundName, NewPitch)
{
	EmitSoundEx({
		sound_name = soundName,
		pitch = NewPitch,
		volume = 0,
		flags = 2 // SND_CHANGE_PITCH
	})
}

// Gradually changes the pitch of a sound over a given duration
::FadePitch <- function(soundName, startPitch, endPitch, duration)
{
	if (soundName == "" || duration <= 0) return

	local minStepTime = 0.1
	local steps = Max(1, duration / minStepTime)
	local stepTime = duration / steps
	local pitchStep = (endPitch - startPitch) / steps

	for (local i = 0; i <= steps; i++)
	{
		local pitch = startPitch + pitchStep * i
		EntFireByHandle(Entities.FindByClassname(null, "worldspawn"), "RunScriptCode", format("ChangePitch(\"%s\", %d)", soundName, pitch), i * stepTime, null, null)
	}
}

// Math

::Clamp <- function(val, min, max)
{
	return (val < min) ? min : (max < val) ? max : val
}

::Min <- function(a, b)
{
	return (a <= b) ? a : b
}

::Max <- function(a, b)
{
	return (a >= b) ? a : b
}

::Lerp <- function(val, min, max)
{
	return min + (max - min) * val
}

// Other

function hideModel(entity) 
{
	NetProps.SetPropInt(entity, "m_nRenderMode", 1)
	NetProps.SetPropInt(entity, "m_clrRender", 1)
}

function showModel(entity) 
{
	NetProps.SetPropInt(entity, "m_nRenderMode", 0)
	NetProps.SetPropInt(entity, "m_clrRender", 0xFFFFFFFF)
}

function Stop_r_knight_door_parent()
{
	local r_knight_door_parent = Entities.FindByName(null, "r_knight_door_parent")
	if (r_knight_door_parent == null) return

	r_knight_door_parent.AcceptInput("Lock", "", null, null)
	r_knight_door_parent.AcceptInput("Close", "", null, null)
}

function Start_r_knight_door_parent()
{
	local r_knight_door_parent = Entities.FindByName(null, "r_knight_door_parent")
	if (r_knight_door_parent == null) return

	r_knight_door_parent.AcceptInput("Unlock", "", null, null)
	r_knight_door_parent.AcceptInput("Open", "", null, null)
}

::StopThink <- function(entity)
{
	// NetProps.SetPropString(entity, "m_iszScriptThinkFunction", "")
	AddThinkToEnt(entity, null)
}

function InSetup()
{
	return NetProps.GetPropBool(tf_gamerules, "m_bInSetup")
}

function stop_afterimage()
{
	afterImage_active = false
}

function start_afterimage()
{
	afterImage_active = true
}

// Implementation
function SetDestroyCallback(entity, callback)
{
	entity.ValidateScriptScope()
	local scope = entity.GetScriptScope()
	scope.setdelegate({}.setdelegate({
			parent   = scope.getdelegate()
			id       = entity.GetScriptId()
			index    = entity.entindex()
			callback = callback
			_get = function(k)
			{
				return parent[k]
			}
			_delslot = function(k)
			{
				if (k == id)
				{
					entity = EntIndexToHScript(index)
					local scope = entity.GetScriptScope()
					scope.self <- entity
					callback.pcall(scope)
				}
				delete parent[k]
			}
		})
	)
}

::ClearStringFromPool <- function(string)
{
	local dummy = Entities.CreateByClassname("logic_relay")
	dummy.KeyValueFromString("targetname", string)
	NetProps.SetPropBool(dummy, "m_bForcePurgeFixedupStrings", true)
	dummy.Destroy()
}

::Schedule <- function(delay, fn, params = [], scope = this) {
	// Credits to Mr. Burguers from TF2Maps Discord.
	local name = UniqueString()
	getroottable()[name] <- function () {
		local err = null
		local args = [scope]
		args.extend(params)
		try {
			fn.acall(args)
		} catch (e) {
			err = e
		}
		delete getroottable()[name]
		if (err) throw err
	}
	local code = "::" + name + "()"
	EntFire("worldspawn", "RunScriptCode", code, delay)
	ClearStringFromPool(code)
}