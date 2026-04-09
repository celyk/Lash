@tool
class_name LashToolbar extends Control

enum Orientation {ORIENTATION_HORIZONTAL, ORIENTATION_VERTICAL}
@export var mode := Orientation.ORIENTATION_HORIZONTAL

var buttons : Array[Button] = []

func _ready() -> void:
	pass
