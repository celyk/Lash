@tool
class_name LashCanvasContainer extends Control

func _process(delta: float) -> void:
	_update()

func _update() -> void:
	if get_child_count() == 0:
		return
	
	var canvas : Variant = get_child(0)
	
	if not (canvas is LashCanvas):
		return
	
	canvas.position = Vector2()
	canvas.size = size
