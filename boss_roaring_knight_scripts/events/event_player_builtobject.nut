CollectEventsInScope
({
	OnGameEvent_player_builtobject = function(params)
	{
		// This just to parent the dispenser_touch_trigger to the dispenser because Valve wouldn't...
		local object = params.object
		local index = params.index
		local disp = EntIndexToHScript(index)
		if (disp == null || !disp.IsValid()) return
		if (object != 0) return // 0 is the dispenser?
		disp.ValidateScriptScope()
		disp.GetScriptScope().disp_think <- function()
		{
			local ent = self
			if (ent == null || !ent.IsValid()) return

			local owner = ent.GetOwner()

			local disp_trigger = null
			while (disp_trigger = Entities.FindByClassname(disp_trigger, "dispenser_touch_trigger"))
			{
				if (disp_trigger == null || !disp_trigger.IsValid()) continue
				if (disp_trigger.GetOwner() == ent)
				{
					disp_trigger.AcceptInput("SetParent", "!activator", ent, null)
					StopThink(ent)
					NetProps.SetPropString(ent, "m_iszScriptThinkFunction", "")
					break
				}
			}
			return -1
		}

		AddThinkToEnt(disp, "disp_think")
	}
})