@tool
extends Node2D

var points : Array[Vector3]

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	_draw_stroke()

func _draw_stroke() -> void:
	for i:int in range(1, points.size()):
		var p0 : Vector3 = points[i-1]
		var p1 : Vector3 = points[i]
		
		#draw_polyline(,)
		var width := 10.0
		var color := Color.BLACK
		draw_line(_Vector2(p0), _Vector2(p1), color, width)
		draw_circle(_Vector2(p0), width / 2, color)
		draw_circle(_Vector2(p1), width / 2, color)

func _Vector2(p) -> Vector2:
	return Vector2(p.x, p.y)
