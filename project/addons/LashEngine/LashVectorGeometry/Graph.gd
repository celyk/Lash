@tool
class_name VGraph extends RefCounted

var nodes : Array[VNode]
var edges : Array[VEdge]

var pos_to_node_cache : Dictionary[Vector2, VNode]

class VNode:
	var pos : Vector2
	var edges : Array[VEdge]
	var id : int
	func get_hash() -> int:
		return hash(pos)

class VEdge:
	var nodes : Array[VNode]
	var id : int
	
	func is_valid() -> bool:
		return nodes[0] != null and nodes[1] != null

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
		else:
			pos_to_node_cache[pos] = edge.nodes[i]
			nodes.append(edge.nodes[i])
	
	edges.append(edge)

func merge_node_between_edge(node:VNode, graph_edge:VEdge) -> void:
	var edge_a := VEdge.new()
	var edge_b := VEdge.new()
	
	edge_a.nodes = [null, null]
	edge_b.nodes = [null, null]
	node.edges = [null, null]
	
	edge_a.nodes[0] = graph_edge.nodes[0]
	edge_a.nodes[1] = node
	edge_b.nodes[0] = node
	edge_b.nodes[1] = graph_edge.nodes[1]
	
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
		
		var new_edge := VEdge.new()
		new_edge.nodes = [null, null]
		new_edge.nodes[0] = prev_edge_node
		
		var split_node : VNode = split_edge(intersection.edges[1], intersection.ts[1])
		
		new_edge.nodes[1] = split_node
		
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
