@tool
class_name VGraph2 extends RefCounted

var nodes : Array[VNode]

class VNode:
	var nodes : Array[VNode]

class VVertex extends VNode:
	var pos : Vector2
	
	static func create(pos:Vector2) -> VVertex:
		var result := VVertex.new()
		result.pos = pos
		return result

class VEdge extends VNode:
	var start : Vector2
	var end : Vector2
	
	static func create(a:Vector2, b:Vector2) -> VEdge:
		var result := VEdge.new()
		result.start = a
		result.end = b
		return result

func insert_node(node:VNode) -> VNode:
	assert(not nodes.has(node))
	
	nodes.append(node)
	
	return node

func insert_vertex(pos : Vector2) -> VVertex:
	for node in nodes:
		if node is VVertex:
			assert(node.pos != pos)
	
	var vertex := VVertex.create(pos)
	insert_node(vertex)
	
	return vertex

func insert_edge(start : Vector2, end : Vector2) -> VEdge:
	for node in nodes:
		if node is VEdge:
			assert(node.start != start and node.end != end)
	
	var edge := VEdge.create(start, end)
	insert_node(edge)
	
	return edge

func erase_node(node : VNode) -> void:
	for other_node in node.nodes:
		other_node.nodes.erase(node)
	
	node.free()

func merge_nodes(nodes : Array[VNode]) -> VNode:
	var one_true_node : VNode = nodes[0]
	
	for i in range(1, nodes.size()):
		var node : VNode = nodes[i]
		
		## Remove the one true node from the deleted nodes connections.
		node.nodes.erase(one_true_node)
		
		## Connect the one true node to them.
		for next_node_along in node.nodes:
			if next_node_along.nodes.has(one_true_node):
				next_node_along.nodes.append(one_true_node)
		
		## Merge the nodes connections into the one true node.
		one_true_node.nodes += node.nodes
		
		## Erase the node.
		erase_node(node)
	
	return one_true_node

#func insert_and_merge_edge(start : Vector2, end : Vector2) -> VEdge:
	#
	#var edge := insert_edge(start, end)
	#return edge

class VNodeIntersection:
	var node_a : VNode
	var node_b : VNode

class VVertexIntersection extends VNodeIntersection:
	var pos : Vector2

class VEdgeIntersection extends VNodeIntersection:
	var pos : Vector2
	var a_t : float
	var b_t : float

static func intersect_vertices(vertex_a:VVertex, vertex_b:VVertex) -> VVertexIntersection:
	if vertex_a.pos != vertex_b.pos:
		return null
	
	var result := VVertexIntersection.new()
	result.node_a = vertex_a
	result.node_b = vertex_b
	result.pos = vertex_a.pos
	
	return result

static func _get_t_along_segment(a:Vector2, b:Vector2, p:Vector2) -> float:
	b -= a
	p -= a
	
	return p.dot(b) / b.dot(b)

static func intersect_edges(edge_a:VEdge, edge_b:VEdge) -> VEdgeIntersection:
	var line_intersection : Variant = Geometry2D.segment_intersects_segment(edge_a.nodes[0].pos, edge_a.nodes[1].pos, edge_b.nodes[0].pos, edge_b.nodes[1].pos)
	
	if line_intersection == null: 
		return null
	
	var result := VEdgeIntersection.new()
	result.node_a = edge_a
	result.node_b = edge_b
	
	result.pos = line_intersection
	result.a_t = _get_t_along_segment(edge_a.start, edge_a.end, line_intersection)
	result.b_t = _get_t_along_segment(edge_b.start, edge_b.end, line_intersection)
	
	return result

func get_intersections() -> Array[VNodeIntersection]:
	var result : Array[VNodeIntersection]
	
	for i in range(0, nodes.size()):
		for j in range(i + 1, nodes.size()):
			var node_a := nodes[i]
			var node_b := nodes[j]
			
			if node_a is VVertex and node_b is VVertex:
				var intersection := intersect_vertices(node_a, node_b)
				if intersection:
					result.append(intersection)
			
			if node_a is VEdge and node_b is VEdge:
				var intersection := intersect_edges(node_a, node_b)
				if intersection:
					result.append(intersection)

	return result

func get_node_to_intersection_map() -> Dictionary:
	var intersections := get_intersections()
	
	var node_to_intersections : Dictionary[VNode, Array]
	for intersection:VNodeIntersection in intersections:
		if not node_to_intersections.has(intersection.node_a):
			node_to_intersections[intersection.node_a] = []
		
		node_to_intersections[intersection.node_a].append(intersection)
	
	return node_to_intersections


func resolve_intersections() -> void:
	var intersections := get_intersections()
	var vertex_intersections : Array[VVertexIntersection] = intersections.filter(func(e): return e is VVertexIntersection)
	
	for intersection in vertex_intersections:
		if is_instance_valid(intersection.node_a) and is_instance_valid(intersection.node_b):
			merge_nodes([intersection.node_a, intersection.node_b])
	
	var node_to_intersections := get_node_to_intersection_map()
	for i in range(0, node_to_intersections.keys().size()):
		var node : VNode = node_to_intersections.keys()[i]
		
		if not (node is VEdge):
			return
		
		var edge : VEdge = node
		
		var intersections_per_node : Array[VEdgeIntersection] = node_to_intersections[i]
		intersections_per_node.sort_custom(func(a:VEdgeIntersection,b:VEdgeIntersection) -> bool:
			var sort_dir : Vector2 = edge.end - edge.start
			return a.pos.dot(sort_dir) < b.pos.dot(sort_dir) )
		#
		#for j in range(0, intersections_per_node.size()):
			#pass
		
		var prev_intersection : VEdgeIntersection
		for intersection in intersections_per_node:
			
			
			prev_intersection = intersection

	#for i in range(0, edge_to_intersections.keys().size()):
		#var edge : VEdge = edge_to_intersections.keys()[i]
		#var intersections : Array[VEdge] = edge_to_intersections[i]
		#
		#for j in range(0, intersections.size()):
			#pass
