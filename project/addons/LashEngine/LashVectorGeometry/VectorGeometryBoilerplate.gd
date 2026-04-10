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
	
	return result

class Segment:
	var start : Vector2
	var end : Vector2
	var id:int
	
	func split(t:float) -> Array[Segment]:
		var segment_a := Segment.new()
		var segment_b := Segment.new()
		
		var split_point : Vector2 = lerp(start, end, t)
		
		segment_a.start = start
		segment_a.end = split_point
		
		segment_b.start = split_point
		segment_b.end = end
		
		return [segment_a, segment_b]

class Polyline:
	var segments : Array[Segment]
	
	func split(t:float) -> Array[Polyline]:
		var polyline_a := Polyline.new()
		var polyline_b := Polyline.new()
		
		var index := clamp(int(t), 0, segments.size()-1)
		#print(polyline_a.segments.size()-1)
		
		var split_segment := segments[index].split(fposmod(t, 1.0))
		
		#print(split_segment[0].start)
		
		polyline_a.segments += segments.slice(0, index)
		polyline_a.segments += [split_segment[0]]
		polyline_b.segments += [split_segment[1]]
		polyline_b.segments += segments.slice(index+1)
		
		return [polyline_a, polyline_b]
	
	func slice(t_a:float, t_b:float) -> Polyline:
		var result := Polyline.new()
		
		var index_a := clamp(int(t_a), 0, segments.size()-1)
		var index_b := clamp(int(t_b), 0, segments.size()-1)
		
		var split_segment_a := segments[index_a].split(fposmod(t_a, 1.0))
		var split_segment_b := segments[index_b].split(fposmod(t_b, 1.0))
		
		result.segments += [split_segment_a[1]]
		
		if index_a+1 < index_b:
			result.segments += segments.slice(index_a+1, index_b)
		
		#assert(index_a+1 < index_b)
		
		result.segments += [split_segment_b[0]]
		
		return result

#class PlanarGraph:
	#pass

#func reorder(arr:Array, sort_values:Array) -> Array:
	#return indices.map(func(e:int): return arr[e])

static func sort_from(arr:Array, reference_arr:Array) -> Array[Vector2]:
	var reference_arr0 : Array
	
	for i:int in range(0, reference_arr.size()):
		reference_arr0.append(reference_arr[i])
	
	# Append the index for later.
	for i:int in range(0, reference_arr0.size()):
		reference_arr0[i] = [reference_arr0[i], i]
	
	# Sort the key array.
	reference_arr0.sort_custom(func(a,b): return a[0] < b[0])
	
	var reordered_arr : Array[Vector2]
	reordered_arr.resize(arr.size())
	
	for i:int in range(0, reference_arr.size()):
		reordered_arr[i] = arr[reference_arr0[i][1]]
	
	# Use the index to reorder the array.
	return reordered_arr #arr.map(func(e): return arr[reference_arr0[1]])

# Does points need sorting?
static func split_polyline(polyline:Polyline, ts:Array[float], points:Array[Vector2]=[]) -> Array[Polyline]:
	points = points.duplicate()
	ts = ts.duplicate()
	
	if points:
		points = sort_from(points, ts)
	
	ts.sort()
	
	var result : Array[Polyline]
	var back : Polyline = polyline
	
	var split_t := 0.0
	
	var prev_t := 0.0
	
	var prev_exact_split_point : Vector2
	
	for i:int in range(0, ts.size()):
		var t : float = ts[i]
		var split : Array[Polyline] = back.split(t - split_t)
		var sub_polyline := polyline.slice(prev_t, t)
		prev_t = t
		
		# Force the end points to be equal.
		if points:
			var exact_split_point : Vector2 = points[i]
			
			if i > 0:
				sub_polyline.segments.front().start = prev_exact_split_point
			
			sub_polyline.segments.back().end = exact_split_point
			#split[0].segments.back().end = exact_split_point
			#split[1].segments.front().start = exact_split_point
			prev_exact_split_point = exact_split_point
		
		result.append(sub_polyline)
		
		#if i == ts.size() - 1:
			#result.append(split[1])
		
		back = split[1]
		split_t += t
	
	var sub_polyline := polyline.split(prev_t)[1]
	sub_polyline.segments.front().start = prev_exact_split_point
	result.append(sub_polyline)
	
	return result

class PolylineIntersectionResult:
	var points : Array[Vector2]
	
	# The position can be the ID
	#var point_ids : Array[int]
	
	## The t values for the first polyline
	var t_a : Array[float]
	
	## The t values for the second polyline
	var t_b : Array[float]

static func _get_t_along_segment(a:Vector2, b:Vector2, p:Vector2) -> float:
	b -= a
	p -= a
	
	return p.dot(b) / b.dot(b)

## Positions and t values required
static func _internal_intersect_polyline_with_polyline(polyline_a:Polyline, polyline_b:Polyline) -> PolylineIntersectionResult:
	var result := PolylineIntersectionResult.new()
	
	for i:int in range(0, polyline_a.segments.size()):
		for j:int in range(0, polyline_b.segments.size()):
			var segment_a : Segment = polyline_a.segments[i]
			var segment_b : Segment = polyline_b.segments[j]
			
			var line_intersection : Variant = Geometry2D.segment_intersects_segment(segment_a.start, segment_a.end, segment_b.start, segment_b.end)
			
			if line_intersection == null: continue
			
			result.points.append(line_intersection)
			result.t_a.append(float(i) + _get_t_along_segment(segment_a.start, segment_a.end, line_intersection))
			result.t_b.append(float(j) + _get_t_along_segment(segment_b.start, segment_b.end, line_intersection))
	
	return result

static func graph_from_intersection(polyline_a:Polyline, polyline_b:Polyline) -> Dictionary[Vector2, Array]:
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

static func get_polyliines_from_graph(graph:Dictionary[Vector2, Array]) -> Array[Polyline]:
	var result : Dictionary[Polyline, bool]
	
	for polylines in graph.values():
		for polyline in polylines:
			result[polyline] = false
	
	return result.keys()

## Assumes no intersections.
static func polylines_to_graph(polylines:Array[Polyline]) -> Dictionary[Vector2, Array]:
	var result : Dictionary[Vector2, Array]
	
	for polyline in polylines:
		var node_a_id : Vector2 = polyline.segments.front().start
		var node_b_id : Vector2 = polyline.segments.back().end
		
		if not result.has(node_a_id):
			result[node_a_id] = []
		
		if not result.has(node_b_id):
			result[node_b_id] = []
		
		result[node_a_id].append(polyline)
		result[node_b_id].append(polyline)
	
	return result

## Assumes no intersections.
static func merge_graphs(graph_a:Dictionary[Vector2, Array], graph_b:Dictionary[Vector2, Array]) -> Dictionary[Vector2, Array]:
	var result : Dictionary[Vector2, Array] = graph_a.duplicate()
	
	for key in graph_b:
		if not result.has(key):
			result[key] = []
		
		result[key].append_array(graph_b[key])
	
	return result

static func graph_graph_intersection(graph_a:Dictionary[Vector2, Array], graph_b:Dictionary[Vector2, Array]) -> Dictionary[Vector2, Array]:
	var polylines_a : Array[Polyline] = get_polyliines_from_graph(graph_a)
	var polylines_b : Array[Polyline] = get_polyliines_from_graph(graph_b)
	
	var result : Dictionary[Vector2, Array]
	
	for i in range(0, polylines_a.size()):
		for j in range(0, polylines_b.size()):
			var polyline_a : Polyline = polylines_a[i]
			var polyline_b : Polyline = polylines_b[j]
			
			var sub_graph : Dictionary[Vector2, Array] = graph_from_intersection(polyline_a, polyline_b)
			#print(sub_graph)
			
			result = merge_graphs(result, sub_graph)
	
	return result
