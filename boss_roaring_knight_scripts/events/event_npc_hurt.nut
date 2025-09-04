CollectEventsInScope
({
	OnGameEvent_npc_hurt = function(params)
	{
		local damage_recieved = params.damageamount
		local entity = EntIndexToHScript(params.entindex)
		local attacker = GetPlayerFromUserID(params.attacker_player)

		if (entity.GetClassname() == "base_boss" && attacker.IsPlayer())
		{
			// Fixing weapon rages not working with base_boss
			local weapon = attacker.GetActiveWeapon()
			if (weapon != null)
			{
				if (!(weapon.IsValid())) return

				if (weapon.GetClassname() == "tf_weapon_soda_popper")
				{
					if (!(attacker.IsHypeBuffed()))
					{
						local damage_bonus = 2.6
						local hype = attacker.GetScoutHypeMeter()
						local ratio = 100.0 / 350.0 // 350 damage needed for full charge
						hype += (damage_recieved * ratio) / damage_bonus
						if (hype > 100)
							hype = 100
						attacker.SetScoutHypeMeter(hype)
					}
				}

				if (weapon.GetClassname() == "tf_weapon_pep_brawler_blaster")
				{
					local damage_bonus = 2.6
					local hype = attacker.GetScoutHypeMeter()
					local current_ammo = weapon.Clip1()
					hype += (damage_recieved/6)/10
					local ratio = 100.0 / 100.0 // 100 damage needed for full charge
					hype += (damage_recieved * ratio) / damage_bonus
					if (hype > 100)
						hype = 100
					weapon.DispatchSpawn()
					attacker.Weapon_Equip(weapon)
					weapon.SetClip1(current_ammo)
					attacker.SetScoutHypeMeter(hype)
				}

				if (NetProps.GetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex") == 752) // The Hitman's Heatmaker
				{
					if (attacker.IsRageDraining()) return
					local rage = attacker.GetRageMeter()
					local ratio = 100.0 / 1800.0 // 3 kills or 9 assists for full charge
					rage += damage_recieved * ratio
					if (rage > 100)
						rage = 100

					Schedule(FrameTime(), function(){
						attacker.SetRageMeter(rage)
					})
				}

				if (NetProps.GetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex") == 773 || // The Pretty Boy's Pocket Pistol
					NetProps.GetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex") == 36) // The Blutsauger
				{
					if (attacker.GetHealth() < attacker.GetMaxHealth())
					{
						local healAmount = 3.0 // 3 health per hit
						attacker.SetHealth(attacker.GetHealth() + healAmount)

						SendGlobalGameEvent("player_healonhit", {
							entindex = attacker.entindex(),
							amount = healAmount
						})
					}
				}

				if (NetProps.GetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex") == 228 || // The Black Box
					NetProps.GetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex") == 1085) // The Festive Black Box
				{
					if (attacker.GetHealth() < attacker.GetMaxHealth())
					{
						local healAmount = damage_recieved / 4.5 // 1 HP per 4.5 damage dealt
						if (healAmount > 20) // cap heal amount to 20 according to the Black Box stat
							healAmount = 20
						attacker.SetHealth(attacker.GetHealth() + healAmount)

						SendGlobalGameEvent("player_healonhit", {
							entindex = attacker.entindex(),
							amount = healAmount
						})
					}
				}
			}

			if (attacker.InCond(TF_COND_REGENONDAMAGEBUFF))
			{
				local healAmount = damage_recieved * 0.35 // Heal 35% of damage dealt
				if (attacker.GetHealth() + healAmount > attacker.GetMaxHealth())
				{
					attacker.SetHealth(attacker.GetMaxHealth())
				} else {
					attacker.SetHealth(attacker.GetHealth() + healAmount)
				}

				SendGlobalGameEvent("player_healonhit", {
					entindex = attacker.entindex(),
					amount = healAmount
				})
			}

			if (attacker.GetPlayerClass() != TF_CLASS_ENGINEER && weapon != null) // Engineer is handled in OnTakeDamage event
			{
				local scope = attacker.GetScriptScope()

				scope.dmg_acc += damage_recieved

				if (!("dmg_dealt" in scope))
					scope.dmg_dealt <- 0
				scope.dmg_dealt += damage_recieved

				local dmg_cap = 2500
				if (scope.dmg_acc < dmg_cap) return
				while (scope.dmg_acc >= dmg_cap)
				{
					local current = NetProps.GetPropInt(attacker, "m_Shared.m_iDecapitations")
					local current_revenge = NetProps.GetPropInt(attacker, "m_Shared.m_iRevengeCrits")

					local active_weapon = attacker.GetActiveWeapon()
					if (active_weapon == null) break
					if (!(active_weapon.IsValid())) break
					if (NetProps.GetPropInt(active_weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex") == 525 || // The Diamondback
						active_weapon.GetClassname() == "tf_weapon_flaregun_revenge") // The Manmelter
					{
						for (local i = 0; i < MAX_WEAPONS; i++)
						{
							local wep = NetProps.GetPropEntityArray(attacker, "m_hMyWeapons", i)
							if (wep == null) continue
							if (active_weapon == wep) continue
							attacker.Weapon_Switch(wep) // force switch weapons to apply the revenge crit
							Schedule(FrameTime(), function(){
								NetProps.SetPropInt(attacker, "m_Shared.m_iRevengeCrits", current_revenge + 1)
								attacker.Weapon_Switch(active_weapon)
							})
							break
						}
					} else {
						NetProps.SetPropInt(attacker, "m_Shared.m_iRevengeCrits", current_revenge + 1)
					}
					NetProps.SetPropInt(attacker, "m_Shared.m_iDecapitations", current + 1)
					scope.dmg_acc -= dmg_cap
				}
			}
		}
	}
})