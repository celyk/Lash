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
		var rect := Rect2(Vector2(), render_target_instance.size)
		draw_texture_rect(render_target_instance.get_texture(), rect, false)

func commit() -> void:
	var mask : Image = render_target_instance.get_texture().get_image()
	var paths := convert_mask_to_paths(mask)
	stroke_commited.emit(paths)
	
	## Clear the canvas
	set_stroke_points([])

static func convert_mask_to_paths(mask:Image) -> Array[PackedVector2Array]:
	var bitmap : BitMap = convert_image_to_bitmap(mask, 0.02)
	var holes : BitMap = convert_image_to_bitmap(mask, 0.02, true)
	
	var epsilon := 6.0
	var paths := holes.opaque_to_polygons(Rect2i(Vector2(), holes.get_size()), epsilon)
	
	for i in range(1,paths.size()):
		#paths[i].reverse()
		pass
	
	paths.sort_custom(func(a,b): return abs(_get_area_for_polygon(a)) > abs(_get_area_for_polygon(b)))
	
	var main_shape_paths = bitmap.opaque_to_polygons(Rect2i(Vector2(), bitmap.get_size()), epsilon)
	
	if main_shape_paths:
		paths[0] = bitmap.opaque_to_polygons(Rect2i(Vector2(), bitmap.get_size()), epsilon)[0]
	else:
		#assert(false)
		pass
	
	#paths.remove_at(0)
	
	paths[0].reverse()
	#paths.resize(1)
	
	#var main_shape_index := 0
	#var max_area := 0.0
	#for i in range(0, paths.size()):
		#var path := paths[i]
		#
		#var area := abs(_get_area_for_polygon(path))
		#if area > max_area:
			#max_area = area
			#main_shape_index = i
	#
	#paths[main_shape_index].reverse()
	
	return paths

static func convert_image_to_bitmap(mask:Image, threshold:=0.5, invert:bool=false) -> BitMap:
	var result := BitMap.new()
	result.create(mask.get_size())
	
	for j in range(0, mask.get_size().y):
		for i in range(0, mask.get_size().x):
			var is_inside := mask.get_pixel(i, j).a > threshold
			result.set_bit(i, j, is_inside != invert)
	
	return result


static func _get_area_for_polygon(polygon:PackedVector2Array) -> float:
	var triangles := Geometry2D.triangulate_polygon(polygon)
	
	var vertex_buffer : PackedVector2Array
	for i:int in range(0, triangles.size()):
		vertex_buffer.append(polygon[triangles[i]])
	
	var result : float = 0.0
	for i:int in range(0, vertex_buffer.size(), 3):
		var a : Vector2 = vertex_buffer[i]
		var b : Vector2 = vertex_buffer[i+1]
		var c : Vector2 = vertex_buffer[i+2]
		
		result += _get_signed_area_for_triangle(a, b, c)
	
	return result

static func _get_signed_area_for_triangle(a:Vector2, b:Vector2, c:Vector2) -> float:
	b -= a
	c -= a
	return b.cross(c)
