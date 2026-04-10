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

#func reorder(arr:Array, sort_values:Array) -> Array:
	#return indices.map(func(e:int): return arr[e])

func sort_from(arr:Array, key:Array) -> Array:
	key = key.duplicate()

	# Append the index for later.
	for i:int in range(0, arr.size()):
		key[i] = [key[i], i]
	
	# Sort the key array.
	key.sort_custom(func(a,b): return a[0] < a[1])
	
	# Use the index to reorder the array.
	return arr.map(func(e): return arr[key[1]])

# Does points need sorting?
func split_polyline(polyline:Polyline, ts:Array[float], points:Array[Vector2]=[]) -> Array[Polyline]:
	points = points.duplicate()
	ts = ts.duplicate()
	
	if points:
		points = sort_from(points, ts)
	
	ts.sort()
	
	var result : Array[Polyline]
	var back : Polyline = polyline
	
	for i:int in range(0, ts.size()):
		var t : float = ts[i]
		var split : Array[Polyline] = back.split(t)
		
		# Force the end points to be equal.
		if points:
			var exact_split_point : Vector2 = points[i]
			
			split[0].segments.back().end = exact_split_point
			split[1].segments.front().start = exact_split_point
		
		result.append(split)
		back = split[1]
	
	return result

class PolylineIntersectionResult:
	var points : Array[Vector2]
	
	# The position can be the ID
	#var point_ids : Array[int]
	
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

func graph_from_intersection(polyline_a:Polyline, polyline_b:Polyline) -> Dictionary[Vector2, Array]:
	var intersection : PolylineIntersectionResult = _internal_intersect_polyline_with_polyline(polyline_a, polyline_b)
	
	var graph : Dictionary[Vector2, Array]
	
	var split : Array[Polyline] = split_polyline(polyline_a, intersection.t_a, intersection.points)
	
	for polyline in split:
		if not graph.has(polyline.segments.front().start):
			graph[polyline.segments.front().start] = []
		
		if not graph.has(polyline.segments.back().end):
			graph[polyline.segments.back().end] = []
		
		graph[polyline.segments.front().start].append(polyline)
		graph[polyline.segments.back().end].append(polyline)
	
	split = split_polyline(polyline_b, intersection.t_b, intersection.points)
	
	for polyline in split:
		if not graph.has(polyline.segments.front().start):
			graph[polyline.segments.front().start] = []
		
		if not graph.has(polyline.segments.back().end):
			graph[polyline.segments.back().end] = []
		
		graph[polyline.segments.front().start].append(polyline)
		graph[polyline.segments.back().end].append(polyline)
	
	return graph
