@tool
class_name LashCanvas extends Node2D

var size := Vector2i(512, 512)

var viewport : SubViewport
var camera : LashCanvasCamera

const CANVAS = preload("ui/Canvas.tscn")

func _ready() -> void:
	viewport = SubViewport.new()
	add_child(viewport)
	
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
