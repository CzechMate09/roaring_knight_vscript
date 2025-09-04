CollectEventsInScope
({
	OnGameEvent_post_inventory_application = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)

		//
		// Weapon rebalances
		//

		local CUSTOM_HEX = "\x07"
		local NERF = CUSTOM_HEX + "ff0000" + "[BOSS] "
		local BUFF = CUSTOM_HEX + "2bff00" + "[BOSS] "
		for (local i = 0; i < MAX_WEAPONS; i++)
		{
			local held_weapon = NetProps.GetPropEntityArray(player, "m_hMyWeapons", i)
			if (held_weapon == null)
				continue

			local weapon_slot = held_weapon.GetSlot()
			if (weapon_slot != 0 && // Primary
				weapon_slot != 1 && // Secondary
				weapon_slot != 2) // Melee
			{
				continue
			}
			// Scout
			// ---

			// Soldier
			if (held_weapon.GetClassname() == "tf_weapon_rocketlauncher" ||
				held_weapon.GetClassname() == "tf_weapon_particle_cannon" ||
				held_weapon.GetClassname() == "tf_weapon_rocketlauncher_airstrike")
			{
				held_weapon.AddAttribute("damage bonus", 1.6, 0.0)
				ClientPrint(player, HUD_PRINTTALK, BUFF + "Rocket Launcher damage increased by 60%.")
				continue
			}

			if (held_weapon.GetClassname() == "tf_weapon_rocketlauncher_directhit")
			{
				ClientPrint(player, HUD_PRINTTALK, BUFF + "Rocket Launcher damage increased by 60%.")
				held_weapon.AddAttribute("damage bonus", 1.85, 0.0) // +25% damage bonus from direct hit
				continue
			}

			// Pyro
			if (held_weapon.GetClassname() == "tf_weapon_flamethrower")
			{
				held_weapon.AddAttribute("flame_lifetime", 1.0, 0.0)
				held_weapon.AddAttribute("flame_drag", 0.0, 0.0)

				if (NetProps.GetPropInt(held_weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex") == 594) // phlog
				{
					held_weapon.AddAttribute("damage penalty", 0.2, 0.0)
					ClientPrint(player, HUD_PRINTTALK, NERF + "Phlogistinator damage reduced by 20%.")
				} else {
					// held_weapon.AddAttribute("airblast cost increased", 100.0, 0.0)
					held_weapon.AddAttribute("airblast disabled", 1.0, 0.0)
					ClientPrint(player, HUD_PRINTTALK, NERF + "Flamethrower airblast disabled.")
				}

				continue
			}

			// Demoman
			if (held_weapon.GetClassname() == "tf_weapon_pipebomblauncher")
			{
				held_weapon.AddAttribute("Projectile speed increased", 7.0, 0.0)
				held_weapon.AddAttribute("stickybomb charge rate", 0.1, 0.0)
				held_weapon.AddAttribute("sticky arm time bonus", 0.01, 0.0)
			}

			if (held_weapon.GetClassname() == "tf_weapon_grenadelauncher" ||
				held_weapon.GetClassname() == "tf_weapon_cannon")
			{
				held_weapon.AddAttribute("Projectile speed increased", 2.5, 0.0) // value above 2.5 causes error spam in console
				continue
			}

			// Heavy
			if (held_weapon.GetClassname() == "tf_weapon_minigun")
			{
				held_weapon.AddAttribute("damage penalty", 0.5, 0.0) // Nerf minigun damage to encourage players to play other classes :)
				ClientPrint(player, HUD_PRINTTALK, NERF + "Minigun damage reduced by 50%.")
				continue
			}

			// Engineer
			if (held_weapon.GetClassname() == "tf_weapon_wrench" || 
				held_weapon.GetClassname() == "tf_weapon_robot_arm" || 
				held_weapon.GetClassname() == "saxxy")
			{
				held_weapon.AddAttribute("engy sentry radius increased", 4.0, 0.0)
				held_weapon.AddAttribute("engy dispenser radius increased", 4.0, 0.0)
				held_weapon.AddAttribute("engy sentry damage bonus", 0.4, 0.0)
				ClientPrint(player, HUD_PRINTTALK, NERF + "Sentry damage reduced by 50%.")
			}

			if (held_weapon.GetClassname() == "tf_weapon_mechanical_arm") // The Short Circuit would break most boss attacks
			{
				held_weapon.Destroy()
				local viewmodel = NetProps.GetPropEntity(player, "m_hViewModel")
				if (viewmodel != null)
					viewmodel.SetBodygroup(1, 0)
				ClientPrint(player, HUD_PRINTTALK, NERF + "The Short Circuit is banned.")
				continue
			}

			if (NetProps.GetPropInt(held_weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex") == 527) // Widowmaker
			{
				// held_weapon.AddAttribute("mod ammo per shot", 100.0, 0.0)
				continue
			}

			// Medic
			if (held_weapon.GetClassname() == "tf_weapon_crossbow")
			{
				continue
			}

			if (held_weapon.GetClassname() == "tf_weapon_syringegun_medic")
			{
				held_weapon.AddAttribute("damage bonus", 1.8, 0.0)
				ClientPrint(player, HUD_PRINTTALK, BUFF + "Syringe Gun damage increased by 80%.")
				continue
			}

			if (held_weapon.GetClassname() == "tf_weapon_medigun")
			{
				held_weapon.AddAttribute("ubercharge rate bonus", 2.0, 0.0)
				ClientPrint(player, HUD_PRINTTALK, BUFF + "Medigun ÜberCharge rate increased by 100%.")
				continue
			}

			// Sniper
			if (held_weapon.GetClassname() == "tf_weapon_sniperrifle" ||
				held_weapon.GetClassname() == "tf_weapon_sniperrifle_decap" ||
				held_weapon.GetClassname() == "tf_weapon_sniperrifle_classic")
			{
				if (NetProps.GetPropInt(held_weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex") == 526 || // The Machina
					NetProps.GetPropInt(held_weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex") == 30665) // The Shooting Star
				{
					held_weapon.AddAttribute("sniper full charge damage bonus", 3.65, 0.0) // +15% full charge damage bonus of The Machina
				} else {
					held_weapon.AddAttribute("sniper full charge damage bonus", 3.5, 0.0)
				}
				ClientPrint(player, HUD_PRINTTALK, BUFF + "Full charge damage increased by 250%")
				continue
			}

			if (held_weapon.GetClassname() == "tf_weapon_compound_bow")
			{
				continue
			}

			if (held_weapon.GetClassname() == "tf_weapon_smg")
			{
				held_weapon.AddAttribute("damage bonus", 1.8, 0.0)
				ClientPrint(player, HUD_PRINTTALK, BUFF + "SMG damage increased by 80%.")
				continue
			}

			if (held_weapon.GetClassname() == "tf_weapon_charged_smg")
			{
				continue
			}

			// Spy
			// ---

			// All wepons except for a few selected ones
			held_weapon.AddAttribute("damage bonus", 2.6, 0.0) // Buff most weapons

			if (held_weapon.GetClassname() == "tf_weapon_lunchbox" ||
				held_weapon.GetClassname() == "tf_weapon_lunchbox_drink" ||
				held_weapon.GetClassname() == "tf_weapon_buff_item" ||
				held_weapon.GetClassname() == "tf_weapon_parachute" ||
				held_weapon.GetClassname() == "tf_wearable" ||
				held_weapon.GetClassname() == "tf_weapon_rocketpack" ||
				held_weapon.GetClassname() == "tf_weapon_laser_pointer" ||
				held_weapon.GetClassname() == "tf_wearable_razorback" ||
				held_weapon.GetClassname() == "tf_weapon_jar" ||
				held_weapon.GetClassname() == "tf_weapon_jar_milk" ||
				held_weapon.GetClassname() == "tf_weapon_builder" ||
				held_weapon.GetClassname() == "tf_weapon_sapper")
			{
				continue
			}

			if (weapon_slot == 0) // Primary
			{
				ClientPrint(player, HUD_PRINTTALK, BUFF + "Primary weapon damage increased by 160%.")
			}

			if (weapon_slot == 1) // Secondary
			{
				ClientPrint(player, HUD_PRINTTALK, BUFF + "Secondary weapon damage increased by 160%.")
			}
		}
	}
})