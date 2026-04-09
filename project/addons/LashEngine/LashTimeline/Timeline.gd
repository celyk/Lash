@tool
class_name LashTimeline extends Control

var state := TimelineState.new()

func play() -> void:
	pass

## Scrubs to the frame in the timeline.
func seek_frame(frame:int) -> void:
	state.frame = frame

## Scrubs to the keyframe in the current layer.
func seek_keyframe(keyframe:int) -> void:
	pass

func select_frame(frame_id:Vector2i) -> void:
	state.layer = frame_id.y
	seek_frame(frame_id.x)

func _gui_input(event: InputEvent) -> void:
	#print(event)
	if event is InputEventMouseButton:
		var frame_id := _get_frame_id_at(event.position)
		select_frame(frame_id)
	if event is InputEventMouseMotion:
		if event.button_mask == MouseButtonMask.MOUSE_BUTTON_MASK_LEFT:
			var frame_id := _get_frame_id_at(event.position)
			select_frame(frame_id)

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	#draw_set_transform(Vector2(), 0.0, Vector2.ONE)
	
	draw_rect(Rect2(Vector2(), size), Color.WHITE.darkened(0.7))
	
	var frame_scale : Vector2 = _get_frame_size()
	var frame_size : Vector2 = _get_frame_size()
	
	var padding := Vector2(2, 2)
	frame_size -= padding
	
	#draw_set_transform(Vector2(), 0.0, frame_scale)
	
	for j in range(0, state.zoom.y):
		for i in range(0, state.zoom.x):
			var frame_pos := Vector2(i, j) * frame_scale
			var color := Color.WHITE.darkened(0.5)
			
			if state.get_frame_id() == Vector2i(i,j):
				color = color.darkened(0.2)
			
			draw_rect(Rect2(frame_pos, frame_size), color, true, -1.0, true)
			draw_circle(frame_pos + frame_size / 2, frame_size.x / 2 / 4, Color.BLACK, true, -1.0, true)

	var needle_x : float = state.frame * frame_scale.x + 0.5 * frame_size.x
	
	if 0.0 <= needle_x and needle_x <= size.x:
		draw_line(Vector2(needle_x, 0), Vector2(needle_x, size.y), Color.RED.darkened(0.3), 1.0, true)

func _get_frame_size() -> Vector2:
	return size / state.zoom

func _get_frame_id_at(pos:Vector2) -> Vector2i:
	return Vector2i(pos / _get_frame_size())
