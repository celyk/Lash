@tool
class_name VectorGeometryBoilerplate extends RefCounted

static func _polyline_to_curve(polyline:Polyline) -> Curve2D:
	var result := Curve2D.new()
	
	result.add_point(polyline.segments.front().start)
	for segment:Segment in polyline.segments:
		result.add_point(segment.end)
	
	return result

static func _curve_to_polyline(curve:Curve2D) -> Polyline:
	var result := Polyline.new()
	
	for i in range(1, curve.point_count):
		var segment := Segment.new()
		segment.start = curve.get_point_position(i-1)
		segment.end = curve.get_point_position(i)
		result.segments.append(segment)
	
	return null

class Segment:
	var start : Vector2
	var end : Vector2
	var id:int

class Polyline:
	var segments : Array[Segment]
	
	func split(t:float) -> Array[Polyline]:
		var polyline_a := Polyline.new()
		var polyline_b := Polyline.new()
		
		polyline_a.segments += polyline_a.segments.slice(0, int(t))
		polyline_a.segments += []
		polyline_b.segments += []
		polyline_b.segments += polyline_b.segments.slice(int(t)+1)
		
		
		 # segments[]
		
		return [polyline_a, polyline_b]

#class PlanarGraph:
	#pass

# Does points need sorting?
func split_polyline(polyline:Polyline, points:Array[float]) -> Array[Polyline]:
	points = points.duplicate()
	points.sort()
	
	var result : Array[Polyline]
	var back : Polyline = polyline
	
	for t:float in points:
		var split := back.split(t)
		result.append(split)
		back = split[1]
	
	return result

class PolylineIntersectionResult:
	var points : Array[Vector2]
	
	## The t values for the first polyline
	var t_a : Array[float]
	
	## The t values for the second polyline
	var t_b : Array[float]

## Positions and t values required
func _internal_intersect_polyline_with_polyline(polyline_a:Polyline, polyline_b:Polyline) -> PolylineIntersectionResult:
	for i:int in range(0, polyline_a.segments.size()):
		for j:int in range(0, polyline_b.segments.size()):
			pass
	
	return null
