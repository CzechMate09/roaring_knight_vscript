CollectEventsInScope
({
	OnScriptHook_OnTakeDamage = function(params)
	{
		local damage_recieved = params.damage
		local entity = params.const_entity
		local inflictor = params.inflictor // entity that dealt the damage (example: Sentry Gun)
		local attacker = params.attacker // owner of the damage (example: Engineer of the Sentry Gun)

		if (entity.GetClassname() == "obj_dispenser" || entity.GetClassname() == "obj_sentrygun" || entity.GetClassname() == "obj_teleporter")
		{
			local reduced_damage = damage_recieved * 0.6 // 40% damage resistance
			params.damage = reduced_damage
		}

		if (entity.IsPlayer()) {
			local factor = 1.0 // Make resistances stackable

			local player = entity
			if (player.HasItem())
			{
				if (damage_recieved > 0)
				{
					factor *= 0.34 //reduce by 66%
				}
			}
			
			///////////////////////////////////////////////////////////////////////////////////////////////////////////
			// Resistances granted by Fist of Steel, Battalions Backup, Invis Watch are already handled by the game. //
			///////////////////////////////////////////////////////////////////////////////////////////////////////////

			// if (player.InCond(Constants.ETFCond.TF_COND_DEFENSEBUFF))
			// {
			//     // local reduced_damage = damage_recieved * 0.65 // 35% resistance to all damage
			//     // params.damage = reduced_damage
			//     factor *= 0.65
			// }

			// if (player.IsStealthed())
			// {
			//     params.damage = 0
			// }

			// if (player.IsFullyInvisible())
			// {
			//     // local reduced_damage = damage_recieved * 0.5 // 50% damage resistance when fully invisible
			//     // params.damage = reduced_damage
			//     factor *= 0.5
			// }

			// if (player.InCond(Constants.ETFCond.TF_COND_INVULNERABLE) || 
			//     player.InCond(Constants.ETFCond.TF_COND_INVULNERABLE_WEARINGOFF) || 
			//     player.InCond(Constants.ETFCond.TF_COND_INVULNERABLE_HIDE_UNLESS_DAMAGED) || 
			//     player.InCond(Constants.ETFCond.TF_COND_INVULNERABLE_USER_BUFF) ||
			//     player.InCond(Constants.ETFCond.TF_COND_INVULNERABLE_CARD_EFFECT) ||
			//     player.InCond(Constants.ETFCond.TF_COND_PHASE))
			// {
			//     params.damage = 0 // make player invulnerable from trigger_hurt and other sources that bypass uber.
			// }

			if (player.IsInvulnerable())
			{
				factor *= 0.0 // make player invulnerable from trigger_hurt and other sources that bypass uber.
			}

			if (player.InCond(Constants.ETFCond.TF_COND_PHASE)) // Bonk
			{
				factor *= 0.0
			}

			if (player.InCond(Constants.ETFCond.TF_COND_MEDIGUN_UBER_BULLET_RESIST) ||
				player.InCond(Constants.ETFCond.TF_COND_MEDIGUN_UBER_BLAST_RESIST) ||
				player.InCond(Constants.ETFCond.TF_COND_MEDIGUN_UBER_FIRE_RESIST))
			{
				// Make Vaccinator uber useful
				factor *= 0.25 // 75% resistance to all damage
			}

			if (player.InCond(TF_COND_MEDIGUN_SMALL_BULLET_RESIST) ||
				player.InCond(TF_COND_MEDIGUN_SMALL_BLAST_RESIST) ||
				player.InCond(TF_COND_MEDIGUN_SMALL_FIRE_RESIST)) 
			{
				// Make Vaccinator passive useful
				factor *= 0.90 // 10% damage resistance
			}

			if (damage_recieved * factor > entity.GetHealth() && (entity.GetPlayerClass() == TF_CLASS_DEMOMAN || entity.GetPlayerClass() == TF_CLASS_SNIPER))
			{
				for (local wearable = player.FirstMoveChild(); wearable != null; wearable = wearable.NextMovePeer())
				{
					if (wearable.GetClassname() == null)
						continue
					if (wearable.GetClassname() == "tf_wearable_demoshield" || wearable.GetClassname() == "tf_wearable_razorback")
					{
						PlaySoundOnClient(player, "Player.Spy_Shield_Break")
						wearable.Destroy()
						NetProps.SetPropBool(player, "m_Shared.m_bShieldEquipped", false)
						// player.SetHealth(player.GetMaxHealth())
						factor *= 0.0
						break
					}
				}
			}

			params.damage = damage_recieved * factor
		}

		if (entity.GetClassname() == "base_boss" && attacker.IsPlayer()) // I cant't tell if the damage came from a sentry in npc_hurt event
		{
			local scope = attacker.GetScriptScope()
			scope.dmg_acc += damage_recieved

			if (!("dmg_dealt" in scope))
				scope.dmg_dealt <- 0
			scope.dmg_dealt += damage_recieved

			if (inflictor.GetClassname() == "obj_sentrygun")
			{
				local dmg_cap = 2500
				if (scope.dmg_acc < dmg_cap) return
				while (scope.dmg_acc >= dmg_cap)
				{
					local current = NetProps.GetPropInt(inflictor, "SentrygunLocalData.m_iAssists")
					NetProps.SetPropInt(inflictor, "SentrygunLocalData.m_iAssists", current + 1)
					scope.dmg_acc -= dmg_cap
				}
			} 
		}
	}
})