@tool
extends Node2D

signal stroke_commited(paths:Array[PackedVector2Array])

var raster_mask : Image

var show_preview := false

const RENDER_TARGET = preload("renderer/RenderTarget.tscn")
var render_target_instance : SubViewport


func set_stroke_points(points:Array[Vector3]) -> void:
	var render_stroke : Node2D = render_target_instance.find_child("stroke")
	render_stroke.points = points


func _ready() -> void:
	render_target_instance = RENDER_TARGET.instantiate()
	add_child(render_target_instance)

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if show_preview:
		var rect := Rect2(Vector2(), Vector2(512,512))
		draw_texture_rect(render_target_instance.get_texture(), rect, false)

func commit() -> void:
	var mask : Image = render_target_instance.get_texture().get_image()
	var paths := convert_mask_to_paths(mask)
	stroke_commited.emit(paths)
	
	## Clear the canvas
	set_stroke_points([])

static func convert_mask_to_paths(mask:Image) -> Array[PackedVector2Array]:
	var bitmap : BitMap = convert_image_to_bitmap(mask)
	var polygons := bitmap.opaque_to_polygons(Rect2i(Vector2(), bitmap.get_size()), 5.0)
	
	return polygons

static func convert_image_to_bitmap(mask:Image) -> BitMap:
	var result := BitMap.new()
	result.create(mask.get_size())
	
	for j in range(0, mask.get_size().y):
		for i in range(0, mask.get_size().x):
			var is_inside := mask.get_pixel(i, j).r < 0.1
			result.set_bit(i, j, is_inside)
	
	return result
