function CollectEventsInScope(events)
{
	local events_id = UniqueString()
	getroottable()[events_id] <- events
	local events_table = getroottable()[events_id]
	foreach (name, callback in events) events_table[name] = callback.bindenv(this)
	local cleanup_user_func, cleanup_event = "OnGameEvent_scorestats_accumulated_update"
	if (cleanup_event in events) cleanup_user_func = events[cleanup_event].bindenv(this)
	events_table[cleanup_event] <- function(params)
	{
		if (cleanup_user_func) cleanup_user_func(params)
		delete getroottable()[events_id]
	} __CollectGameEventCallbacks(events_table)
}

::MAX_WEAPONS <- 8
::Shadow_mantle_holder <- null
::First_SM_holder <- true

IncludeScript("boss_roaring_knight_scripts/events/event_scorestats_accumulated_update.nut")
IncludeScript("boss_roaring_knight_scripts/events/event_player_builtobject.nut")
IncludeScript("boss_roaring_knight_scripts/events/event_teamplay_flag_event.nut")
IncludeScript("boss_roaring_knight_scripts/events/event_player_death.nut")
IncludeScript("boss_roaring_knight_scripts/events/event_post_inventory_application.nut")
IncludeScript("boss_roaring_knight_scripts/events/event_player_spawn.nut")
IncludeScript("boss_roaring_knight_scripts/events/event_ontakedamage.nut")
IncludeScript("boss_roaring_knight_scripts/events/event_npc_hurt.nut")