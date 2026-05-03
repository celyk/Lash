@tool
class_name LashCanvasCamera extends Node2D

var _camera_2d : Camera2D
var _canvas : LashCanvas

func _ready() -> void:
	_camera_2d = Camera2D.new()
	add_child(_camera_2d)

func _process(delta: float) -> void:
	_set_camera_from_transform(_camera_2d, global_transform)

func _set_camera_from_transform(camera_2d:Camera2D, new_transform:Transform2D) -> void:
	camera_2d.zoom = Vector2.ONE / new_transform.get_scale()
	camera_2d.global_transform = new_transform.orthonormalized()

func get_view_matrix() -> Transform2D:
	return global_transform.affine_inverse()

func get_screen_matrix() -> Transform2D:
	if _canvas == null:
		return Transform3D()
	
	return Transform3D().translated(Vector3(_canvas.size.x / 2.0, _canvas.size.y / 2.0, 0.0))
