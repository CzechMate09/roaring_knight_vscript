////////////////
//  base_boss //
////////////////

::use_custom_bar <- true

function inicialize_base_boss()
{
	local base_boss = Entities.FindByName(null, "base_boss_r_knight")
	hideModel(base_boss)
	SetBossSolid(SOLID_NONE)
	EntityOutputs.AddOutput(base_boss, "OnKilled", "team_round_timer", "pause", "", 0.0, -1)
	EntityOutputs.AddOutput(base_boss, "OnKilled", "item_currencypack_custom", "Kill", "", 0.0, -1)

	SetDestroyCallback(base_boss, function()
	{
		// local bossBar = Entities.FindByClassname(null, "monster_resource")
		// NetProps.SetPropInt(bossBar,"m_iBossHealthPercentageByte", 0)
		EntFire("sprite_boss_healthbar", "HideSprite", "", 0.0, null)
		StopThink(self)
	})
}

::Base_boss_setup_finished <- false
::base_health <- 999999
::accounted_players <- []
function SetUpBossHealth()
{
	base_health = 15000

	if (Boss_difficulty == "hard")
		base_health = 15500

	if (Boss_difficulty == "extreme")
		base_health = 16000

	local red_players = GetAllRedPlayers()
	foreach (player in red_players)
	{
		local entindex = player.entindex()
		accounted_players.append(entindex)
	}

	local player_count = accounted_players.len()
	local boss_health = base_health * player_count
	local base_boss = Entities.FindByName(null, "base_boss_r_knight")
	base_boss.RemoveSolidFlags(FSOLID_TRIGGER)

	SetRKnightHealth(boss_health)
	SetRKnightMaxHealth(boss_health)

	// ClientPrint(null, HUD_PRINTTALK, "[DEBUG] Boss Health set to: " + boss_health)
	printl("-----------------------------------------")
	printl("[DEBUG] Boss Health set to: " + boss_health)
	printl("-----------------------------------------")

	if (boss_health > 0)
	{
		// local bossBar = Entities.FindByClassname(null, "monster_resource")
		// NetProps.SetPropInt(bossBar,"m_iBossHealthPercentageByte", 0)
		base_boss.ValidateScriptScope()
		base_boss.GetScriptScope().Boss_think <- Boss_think
		AddThinkToEnt(base_boss, "Boss_think")

		Base_boss_setup_finished = true
	}
}

function Boss_think()
{
	local boss = self
	local health = boss.GetHealth()
	// local bossBar = Entities.FindByClassname(null, "monster_resource")
	local hpByte = (boss.GetHealth() * 255) / boss.GetMaxHealth()
	if (hpByte == 0 && boss.GetHealth() > 0)
		hpByte = 1
	if (hpByte > 255)
		hpByte = 255

	// NetProps.SetPropInt(bossBar,"m_iBossHealthPercentageByte", hpByte)
	local invertedHpByte = 255 - hpByte
	local sprite_boss_healthbar = Entities.FindByName(null, "sprite_boss_healthbar")
	SetTextureFrameIndex(sprite_boss_healthbar, invertedHpByte)


	if (health <= 0)
	{
		StopThink(boss)
		SetTextureFrameIndex(sprite_boss_healthbar, 255)
		sprite_boss_healthbar.AcceptInput("HideSprite", "", null, null)
	}

	if (active_knight_brush == null) return
	local origin = active_knight_brush.GetOrigin()
	local angles = active_knight_brush.GetAbsAngles()

	local base_boss = Entities.FindByName(null, "base_boss_r_knight")
	local boss_offset = Vector(0, 0, 0)
	if (base_boss != null)
		base_boss.Teleport(true, origin, true, angles, false, Vector(0, 0, 0))
	
	local sprite_boss_healthbar = Entities.FindByName(null, "sprite_boss_healthbar")
	if (sprite_boss_healthbar != null)
		sprite_boss_healthbar.Teleport(true, origin + Vector(0,0, 720), true, angles, false, Vector(0, 0, 0))

	local sticky_trigger = Entities.FindByName(null, "sticky_trigger")
	origin.x -= -184
	origin.y -= -2480
	origin.z -= 736
	if (sticky_trigger != null)
		sticky_trigger.Teleport(true, origin, true, angles, false, Vector(0, 0, 0))
		// sticky_trigger.SetLocalOrigin(origin)

	return -1
}