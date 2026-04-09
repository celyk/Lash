class_name TimelineState extends Resource

var frame := 0
var layer := 0

var zoom : Vector2 = Vector2(60, 4)

func get_frame_id() -> Vector2i:
	return Vector2i(frame, layer)
