@tool
class_name LashCanvasCamera extends Node2D

var _camera_2d : Camera2D

func _ready() -> void:
	_camera_2d = Camera2D.new()
	add_child(_camera_2d)

func _process(delta: float) -> void:
	_set_camera_from_transform(_camera_2d, global_transform)

func _set_camera_from_transform(camera_2d:Camera2D, new_transform:Transform2D) -> void:
	camera_2d.zoom = Vector2.ONE / new_transform.get_scale()
	camera_2d.global_transform = new_transform.orthonormalized()
