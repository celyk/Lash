@tool
extends EditorPlugin

const Autoload = preload("autoload.gd")
var autoload_instance

func _enter_tree() -> void:
	autoload_instance = Autoload.new()
	add_child(autoload_instance)

func _exit_tree() -> void:
	autoload_instance.queue_free()
