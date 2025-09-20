function Anim_r_knight_sword_appear(on_finish = null, frame_rate = 8, frame_count = 19)
{
	Disable_All_Brushes()
	Enable_Brush("r_knight_sword_brush")
	Enable_Brush("brush_r_knight_sword_appear")
	Start_r_knight_door_parent()
	local r_knight_sword_brush = Entities.FindByName(null, "r_knight_sword_brush")
	local brush_r_knight_sword_appear = Entities.FindByName(null, "brush_r_knight_sword_appear")
	local frame_delay = 1.0 / frame_rate

	for (local i = 0; i < frame_count; i++)
	{
		(function(index) {
			Schedule(frame_delay * index, function() {
				SetTextureFrameIndex(brush_r_knight_sword_appear, index)
				if (index == 0)
					r_knight_sword_brush.AcceptInput("Enable", "", null, null)


				if (index == 8)
				{
					r_knight_sword_brush.AcceptInput("Disable", "", null, null)
					stop_afterimage()
				}

				if (index == frame_count - 1)
					if (on_finish != null) on_finish()
			})
		})(i)
	}
}

function Anim_r_knight_idle_sword()
{
	Disable_All_Brushes()
	Enable_Brush("brush_r_knight_idle_sword")
	Start_r_knight_door_parent()
}

function Anim_r_knight_idle_overworld(on_finish = null, duration = 3.0)
{
	Disable_All_Brushes()
	Enable_Brush("brush_r_knight_idle_overworld")
	Start_r_knight_door_parent()
	if (on_finish != null)
	{
		Schedule(duration, function() {
			on_finish()
		})
	}
}

function Anim_r_knight_hurt_idle(on_finish = null, duration = 3.0)
{
	Disable_All_Brushes()
	Enable_Brush("brush_r_knight_hurt_idle")
	Stop_r_knight_door_parent()
	if (on_finish != null)
	{
		Schedule(duration, function() {
			on_finish()
		})
	}
}

function Anim_r_knight_ball_transition(loop_duration = null, on_finish = null, frame_rate = 5, frame_count = 10)
{
	Disable_All_Brushes()
	Enable_Brush("brush_r_knight_ball_transition")
	Stop_r_knight_door_parent()
	local brush_r_knight_ball_transition = Entities.FindByName(null, "brush_r_knight_ball_transition")
	local frame_delay = 1.0 / frame_rate

	if (loop_duration != null)
	{
		local start_time = Time()
		function play_frame(index)
		{
			local elapsed = Time() - start_time
			if (elapsed >= loop_duration)
			{
				if (on_finish != null) on_finish()
				return
			}
			SetTextureFrameIndex(brush_r_knight_ball_transition, index)
			local next_index = (index + 1) % frame_count
			Schedule(frame_delay, function() {
				play_frame(next_index)
			})
		}
		play_frame(0)
	}
	else
	{
		for (local i = 0; i < frame_count; i++)
		{
			(function(index) {
				Schedule(frame_delay * index, function() {
					SetTextureFrameIndex(brush_r_knight_ball_transition, index)
					if (index == frame_count - 1)
						if (on_finish != null) on_finish()
				})
			})(i)
		}
	}
}

function Anim_r_knight_pose(loop_duration = null, on_finish = null, frame_rate = 10, frame_count = 2)
{
	Disable_All_Brushes()
	Enable_Brush("brush_r_knight_pose")
	Start_r_knight_door_parent()
	local brush_r_knight_pose = Entities.FindByName(null, "brush_r_knight_pose")
	local frame_delay = 1.0 / frame_rate

	if (loop_duration != null)
	{
		local start_time = Time()
		function play_frame(index)
		{
			local elapsed = Time() - start_time
			if (elapsed >= loop_duration)
			{
				if (on_finish != null) on_finish()
				return
			}
			SetTextureFrameIndex(brush_r_knight_pose, index)
			local next_index = (index + 1) % frame_count
			Schedule(frame_delay, function() {
				play_frame(next_index)
			})
		}
		play_frame(0)
	}
	else
	{
		for (local i = 0; i < frame_count; i++)
		{
			(function(index) {
				Schedule(frame_delay * index, function() {
					SetTextureFrameIndex(brush_r_knight_pose, index)
					if (index == frame_count - 1)
						if (on_finish != null) on_finish()
				})
			})(i)
		}
	}
}

function Anim_r_knight_flurry(loop_duration = null, on_finish = null, frame_rate = 10, frame_count = 3)
{
	Disable_All_Brushes()
	Enable_Brush("brush_r_knight_flurry")
	Start_r_knight_door_parent()
	local brush_r_knight_flurry = Entities.FindByName(null, "brush_r_knight_flurry")
	local frame_delay = 1.0 / frame_rate

	if (loop_duration != null)
	{
		local start_time = Time()
		function play_frame(index)
		{
			local elapsed = Time() - start_time
			if (elapsed >= loop_duration)
			{
				if (on_finish != null) on_finish()
				return
			}
			SetTextureFrameIndex(brush_r_knight_flurry, index)
			local next_index = (index + 1) % frame_count
			Schedule(frame_delay, function() {
				play_frame(next_index)
			})
		}
		play_frame(0)
	}
	else
	{
		for (local i = 0; i < frame_count; i++)
		{
			(function(index) {
				Schedule(frame_delay * index, function() {
					SetTextureFrameIndex(brush_r_knight_flurry, index)
					if (index == frame_count - 1)
						if (on_finish != null) on_finish()
				})
			})(i)
		}
	}
}