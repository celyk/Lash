@tool
class_name VGraph extends RefCounted

var nodes : Array[VNode]
var edges : Array[VEdge]
#var faces : Array[VFace]

var pos_to_node_cache : Dictionary[Vector2, VNode]

class VNode:
	var pos : Vector2
	var edges : Array[VEdge]
	var id : int
	func get_hash() -> int:
		return hash(pos)
	
	static func create(pos:Vector2) -> VNode:
		var result := VNode.new()
		result.pos = pos
		return result

class VEdge:
	var nodes : Array[VNode]
	var faces : Array[VNode]
	#var faces : Dictionary[VFace, bool]
	var id : int
	
	func is_valid() -> bool:
		return nodes and nodes[0] != null and nodes[1] != null
	
	static func create(node_a:VNode, node_b:VNode) -> VEdge:
		var result := VEdge.new()
		
		result.nodes = [node_a, node_b]
		
		return result
	
	static func create_from_segment(a:Vector2, b:Vector2) -> VEdge:
		var node_a := VNode.create(a)
		var node_b := VNode.create(b)
		
		var result := create(node_a, node_b)
		
		node_a.edges.append(result)
		node_b.edges.append(result)
		
		return result

class VFace:
	var nodes : Array[VNode]
	var edges : Array[VEdge]

class IntersectionPoint:
	var pos : Vector2
	var edges : Array[VEdge]
	var ts : Array[float]

class IntersectionResult:
	# Every edge that intersects needs to be replaced by subedges.
	var edges : Array[VEdge]
	var points : Array[Vector2]

static func _get_t_along_segment(a:Vector2, b:Vector2, p:Vector2) -> float:
	b -= a
	p -= a
	
	return p.dot(b) / b.dot(b)

static func intersect_edges(edge_a:VEdge, edge_b:VEdge) -> IntersectionPoint:
	var result := IntersectionPoint.new()
	result.edges.append(edge_a)
	result.edges.append(edge_b)
	
	# Ignore any end points intersection.
	for i in range(0, 2):
		for j in range(0, 2):
			if edge_a.nodes[i].pos == edge_b.nodes[j].pos:
				return null
	
	
	var line_intersection : Variant = Geometry2D.segment_intersects_segment(edge_a.nodes[0].pos, edge_a.nodes[1].pos, edge_b.nodes[0].pos, edge_b.nodes[1].pos)
	
	if line_intersection == null: 
		return null
	
	result.pos = line_intersection
	result.ts.append(_get_t_along_segment(edge_a.nodes[0].pos, edge_a.nodes[1].pos, line_intersection))
	result.ts.append(_get_t_along_segment(edge_b.nodes[0].pos, edge_b.nodes[1].pos, line_intersection))
	
	return result

func intersect_with_edge(edge:VEdge) -> Array[IntersectionPoint]:
	var result : Array[IntersectionPoint]
	
	for graph_edge in edges:
		var intersection := intersect_edges(edge, graph_edge)
		if intersection:
			result.append(intersection)
	
	# Sort the result
	result.sort_custom(
		func(a:IntersectionPoint,b:IntersectionPoint) -> bool:
			var sort_dir : Vector2 = edge.nodes[1].pos - edge.nodes[0].pos
			return a.pos.dot(sort_dir) < b.pos.dot(sort_dir))
	
	return result

func merge_nonintersecting_edge(edge:VEdge) -> void:
	## Merge overlapping nodes.
	for i in range(0, 2):
		var pos : Vector2 = edge.nodes[i].pos
		if pos_to_node_cache.has(pos):
			edge.nodes[i] = pos_to_node_cache[pos]
			edge.nodes[i].edges.append(edge)
		else:
			pos_to_node_cache[pos] = edge.nodes[i]
			nodes.append(edge.nodes[i])
	
	edges.append(edge)

func merge_node_between_edge(node:VNode, graph_edge:VEdge) -> void:
	var edge_a := VEdge.create(graph_edge.nodes[0], node)
	var edge_b := VEdge.create(node, graph_edge.nodes[1])
	
	node.edges = [null, null]
	node.edges[0] = edge_a
	node.edges[1] = edge_b
	
	edges.append(edge_a)
	edges.append(edge_b)
	nodes.append(node)
	
	remove_edge(graph_edge)

# This edge is non-intersecting except at the end points where it is touching one edge of the graph.
# Specifically edge.nodes[0] is the one touching the graph.
func merge_kissing_edge(edge:VEdge, touched_edge:VEdge):
	merge_node_between_edge(edge.nodes[0], touched_edge)
	#merge_nonintersecting_edge(edge)

func split_edge(edge:VEdge, t:float) -> VNode:
	var node := VNode.new()
	node.pos = lerp(edge.nodes[0].pos, edge.nodes[1].pos, t)
	
	merge_node_between_edge(node, edge)
	
	return node

func merge_edge(edge:VEdge) -> void:
	if not edge.is_valid():
		return
	
	for my_edge in edges:
		pass
	
	var intersections := intersect_with_edge(edge)
	
	if intersections.is_empty():
		merge_nonintersecting_edge(edge)
		return
	
	## For every intersection point, one new node and non-intersecting edge must be added.
	
	var prev_intersection : IntersectionPoint
	var prev_edge_node : VNode = edge.nodes[0]
	for i:int in range(0, intersections.size()):
		var intersection := intersections[i]
		
		var split_node : VNode = split_edge(intersection.edges[1], intersection.ts[1])
		
		var new_edge := VEdge.create(prev_edge_node, split_node)
		
		merge_nonintersecting_edge(new_edge)
		
		prev_intersection = intersection
		prev_edge_node = new_edge.nodes[0] 
		
		#remove_edge(intersection.edges[1])
		
		#for intersecting_edge in intersection.edges:
			#var node := split_edge(intersecting_edge, intersection.ts[1])
			#
			#var edge_a := VEdge.new()
			#edge_a.nodes = [null, null]
			#edge_a.nodes[0] = edge.nodes[0]
			#edge_a.nodes[1] = node
			#
			#var edge_b := VEdge.new()
			#edge_b.nodes = [null, null]
			#edge_b.nodes[0] = node
			#edge_b.nodes[1] = edge.nodes[1]
			#
			#merge_nonintersecting_edge(edge_a)
			#merge_nonintersecting_edge(edge_b)
			#
			## Just erase all these edges?
			##remove_edge(intersecting_edge)
	
	var new_edge := VEdge.new()
	new_edge.nodes = [null, null]
	new_edge.nodes[0] = prev_edge_node
	
	#var split_node : VNode = split_edge(prev_intersection.edges[1], prev_intersection.ts[1])
	
	new_edge.nodes[1] = edge.nodes[1]
	
	merge_nonintersecting_edge(new_edge)
	
	
	#for edge in overlapping_edges:
		#pass
	
	rebuild_position_cache()

func merge(other:VGraph) -> void:
	for edge in other.edges:
		merge_edge(edge)

func remove_edge(edge:VEdge) -> void:
	for node in edge.nodes:
		node.edges.erase(edge)
	
	edges.erase(edge)

func rebuild_position_cache() -> void:
	pos_to_node_cache.clear()
	
	for node in nodes:
		pos_to_node_cache[node.pos] = node

func get_next_CCW_edge(edge:VEdge) -> VEdge:
	var result : VEdge
	
	var central_node := edge.nodes[1]
	
	var sort_dir : Vector2 = central_node.pos - edge.nodes[0].pos
	
	print(edge.nodes[1].edges)
	var candidates := edge.nodes[1].edges.duplicate()
	print("before erase: ", candidates)
	candidates.erase(edge)
	print("after erase: ", candidates)
	
	if candidates.is_empty():
		return null
	
	candidates.sort_custom(func(a:VEdge, b:VEdge): 
		var a_dir : Vector2
		var b_dir : Vector2
		
		if a.nodes[0] == central_node:
			a_dir = a.nodes[1].pos - central_node.pos
		else:
			a_dir = a.nodes[0].pos - central_node.pos
		
		if b.nodes[0] == central_node:
			b_dir = b.nodes[1].pos - central_node.pos
		else:
			b_dir = b.nodes[0].pos - central_node.pos
		
		return sort_dir.angle_to(a_dir) < sort_dir.angle_to(b_dir))
	
	return candidates[0]

func build_faces_from_edge(edge:VEdge) -> Array[VFace]:
	var face_a := VFace.new()
	var face_b := VFace.new()
	
	var current_edge : VEdge = edge
	face_a.edges.append(edge)
	
	while true:
		face_a.edges.append(current_edge)
		
		current_edge = get_next_CCW_edge(current_edge)
		print("build_faces_from_edge", current_edge)
		
		if current_edge == null:
			break
		
		## Advance
		if current_edge == edge:
			break
	
	return [face_a, face_b]

func get_face_from_pos(pos:Vector2) -> VFace:
	var segment := VEdge.create_from_segment(pos + Vector2(10,0), pos + Vector2(1000,0))
	
	var intersections := intersect_with_edge(segment)
	
	if intersections.is_empty():
		return null
	
	var faces := build_faces_from_edge(intersections[0].edges[1])
	
	return faces[0]

var faces_cache : Dictionary[VFace, bool]
func rebuild_faces() -> void:
	for edge in edges:
		#var faces := build_faces_from_edge()
		pass
