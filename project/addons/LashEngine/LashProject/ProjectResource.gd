@tool
class_name LashProjectResource extends Resource

@export var version : String = "0.0"

# Data container
@export var scene : PackedScene

func _init() -> void:
	scene = PackedScene.new()
	scene.pack(Node2D.new())
