@tool
class_name TimelineState extends Resource

var time : float = 0.0
var fps : float = 24.0
var layer : int = 0

var play_range : Vector2 = Vector2(0, 2.0)

var loop : bool = false

var is_playing := false

var zoom : Vector2 = Vector2(60, 4)

func get_frame_id() -> Vector2i:
	return Vector2i(int(time * fps), layer)
