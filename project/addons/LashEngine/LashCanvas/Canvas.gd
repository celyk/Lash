@tool
class_name LashCanvas extends Node2D

var size := Vector2i(512, 512)

var project : LashProject :
	set(value):
		project = value
		reload_project()

var viewport : SubViewport
var camera : LashCanvasCamera

const CANVAS = preload("ui/Canvas.tscn")


#func create_project() -> void:
	#pass

func reload_project() -> void:
	if not (project and project._resource and project._resource.scene):
		return
	
	_initialize()
	viewport.add_child(project._resource.scene.instantiate())

func _ready() -> void:
	viewport = SubViewport.new()
	add_child(viewport)

func _initialize() -> void:
	for child in viewport.get_children():
		child.queue_free()
	
	camera = LashCanvasCamera.new()
	viewport.add_child(camera)
	viewport.add_child(CANVAS.instantiate())

func _process(delta: float) -> void:
	if viewport.size != size:
		viewport.size = size
	
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2(), size), Color.WHITE.darkened(0.5))
	draw_texture(viewport.get_texture(), Vector2())
