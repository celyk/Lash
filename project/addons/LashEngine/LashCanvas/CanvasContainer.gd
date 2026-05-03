@tool
class_name LashCanvasContainer extends Control

func get_lash_canvas() -> LashCanvas:
	if get_child_count() == 0:
		return null
	
	if not (get_child(0) is LashCanvas):
		return null
	
	return get_child(0)

func _process(delta: float) -> void:
	_update()

func _update() -> void:
	if get_child_count() == 0:
		return
	
	var canvas : Variant = get_lash_canvas()
	
	if canvas == null:
		return
	
	canvas.position = Vector2()
	canvas.size = size

func _gui_input(event: InputEvent) -> void:
	get_lash_canvas().viewport.push_input(event)
	
	var canvas : Variant = get_lash_canvas()

	if canvas == null:
		return
	
	if event is InputEventMagnifyGesture:
		canvas.camera.transform = canvas.camera.transform.scaled_local(Vector2.ONE * 1.0 / pow(event.factor, 0.4))
	
	if event is InputEventPanGesture:
		canvas.camera.transform = canvas.camera.transform.translated_local(event.delta * 30)
