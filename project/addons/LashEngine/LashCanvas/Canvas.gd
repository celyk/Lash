@tool
class_name LashCanvas extends Node2D

var size := Vector2i(512, 512)

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2(), size), Color.WHITE.darkened(0.5))
