@tool
class_name LashVectorGeometry2D extends VectorGeometryBoilerplate#"VectorGeometryBoilerplate.gd"

## Positions and t values required
func intersect_polyline_with_polyline() -> Array[Curve2D]:
	return []

func intersect_graph_with_polyline() -> void:
	pass

func merge_graph_with_graph(graph_a:PolylineGraph, graph_b:PolylineGraph) -> PolylineGraph:
	for i:int in range(0, graph_a.edges):
		var edge_a := graph_a.edges[i]
		for j:int in range(0, graph_b.edges):
			var edge_b := graph_b.edges[i]
			_internal_intersect_polyline_with_polyline(edge_a.polyline, edge_b.polyline)
	
	return null

class PolylineNode:
	var pos : Vector2
	var edges : Array[PolylineEdge]

class PolylineEdge:
	var nodes : Array[PolylineNode]
	var polyline : Polyline

class PolylineGraph:
	var nodes : Array[PolylineNode]
	var edges : Array[PolylineEdge]
	
	func add_polyline(polyline:Polyline) -> void:
		pass
	
	func get_region_at_pos(pos:Vector2) -> int:
		return -1
	
	func add_node(pos:Vector2) -> PolylineNode:
		var node := PolylineNode.new()
		
		node.pos = pos
		node.edges = [null, null]
		
		nodes.append(node)
		return node
	
	func add_edge(polyline:Polyline, from:PolylineNode, to:PolylineNode) -> PolylineEdge:
		var edge := PolylineEdge.new()
		edge.polyline = polyline
		
		edge.nodes.append(from)
		edge.nodes.append(to)
		
		edges.append(edge)
		return edge
	
	func get_polylines_as_curves() -> Array[Curve2D]:
		var result : Array[Curve2D]
		
		for edge in edges:
			var curve : Curve2D = VectorGeometryBoilerplate._polyline_to_curve(edge.polyline)
			result.append(curve)
		
		return result
