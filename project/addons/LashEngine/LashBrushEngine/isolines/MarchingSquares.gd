@tool
extends RefCounted

var polygons : Array[PackedVector2Array]



var _current_img : Image
func create_from_image(img:Image) -> void:
	_current_img = img
	
	polygons.clear()
	_prepare_edges(img)
	_extract_polygons_from_edges()

func get_value(i:int, j:int) -> float:
	i = posmod(i, _current_img.get_size().x)
	j = posmod(j, _current_img.get_size().y)
	return _current_img.get_pixel(i, j).r

class Edge:
	#var from : Vector2
	#var to : Vector2
	
	var next_edge : Edge
	var polygon_id : int = -2
	#var t : float = -1.0
	var p : Vector2

var edges : Dictionary[Vector2i, Array]

func _prepare_edges(img:Image) -> void:
	edges.clear()
	
	for j in range(0, img.get_size().y):
		for i in range(0, img.get_size().x):
			var coord := Vector2(i, j)
			
			var center : float = get_value(i, j)
			var right : float = get_value(i+1, j)
			var down : float = get_value(i, j+1)
			
			edges[Vector2i(i,j)] = []
			
			var horizontal_edge := Edge.new()
			var horizontal_t = _solve_crossing(center, right)
			
			if _intersects_interval(horizontal_t, 0, 1):
				horizontal_edge.p = coord + horizontal_t * Vector2(1.0, 0.0)
				horizontal_edge.polygon_id = -1
			
			edges[Vector2i(i,j)].append(horizontal_edge)
			
			var vertical_edge := Edge.new()
			var vertical_t = _solve_crossing(center, down)
			
			if _intersects_interval(horizontal_t, 0, 1):
				vertical_edge.p = coord + vertical_t * Vector2(0.0, 1.0)
				vertical_edge.polygon_id = -1
			
			edges[Vector2i(i,j)].append(vertical_edge)
	
	for j in range(0, img.get_size().y-1):
		for i in range(0, img.get_size().x-1):
			var horizontal_edge : Edge = edges[Vector2i(i,j)][0]
			var vertical_edge : Edge = edges[Vector2i(i,j)][1]
			
			var center : float = get_value(i, j)
			
			if horizontal_edge.polygon_id == -1:
				var cell_edges := _get_cell_edges(i, j)
				if center < 0.0:
					cell_edges.reverse()
				
				for k in range(0, cell_edges.size()):
					var cell_edge = cell_edges[i]
					var next_cell_edge = cell_edges[posmod(i+1, cell_edges.size())]
					
					
				
				horizontal_edge.next_edge = _find_next_edge(i, j, 0)
			
			if vertical_edge.polygon_id == -1:
				vertical_edge.next_edge = _find_next_edge(i, j, 1)

func _find_next_edge(i:int, j:int, edge_number:int) -> Edge:
	var current_edge : Edge = edges[Vector2i(i,j)][edge_number]
	
	var center : float = get_value(i, j)
	
	var step := float(center < 0.0)
	
	var cell_edges : Array[Edge]
	#match edge_number:
		#0:
			#cell_edges = _get_cell_edges(i, j + step)
		#1:
			#cell_edges = _get_cell_edges(i + step, j)
	#
	#for cell_edge in cell_edges:
		#if cell_edge == current_edge:
			#continue
		#
		#if cell_edge
			#pass
	
	return null

func _get_next_cell_edge() -> Edge:
	return null

func _get_cell_edges(i:int, j:int) -> Array[Edge]:
	var result : Array[Edge]
	
	result += edges[Vector2i(i,j)][0]
	result += [edges[Vector2i(i+1,j)][1]]
	result += [edges[Vector2i(i,j+1)][0]]
	result += edges[Vector2i(i,j)][1]
	
	return result

func _extract_polygons_from_edges() -> void:
	for edge in edges.values():
		var polygon : PackedVector2Array = _extract_polygon_from_edge(edge)
		
		if polygon:
			polygons.append(polygon)

func _extract_polygon_from_edge(edge:Edge) -> PackedVector2Array:
	var result := PackedVector2Array()
	
	while edge.polygon_id == -1:
		edge.polygon_id = polygons.size()
		
		result.append(edge.p)
		
		assert(edge.next_edge != null)
		
		edge = edge.next_edge
	
	return result

## a + t(b-a) = 0 -> t = -a / (b-a)
static func _solve_crossing(a:float, b:float) -> float:
	return -a / (b-a)

static func _intersects_interval(x:float, a:float, b:float) -> bool:
	return a <= x and x < b

static var patterns := ["0000", "1110", "1010", "0110"]
static func _get_cell_class(values:Array[float]) -> int:
	var key := ""
	
	for value in values:
		if value < 0.0:
			key += "0"
		else:
			key += "1"
	
	for i in range(0, patterns.size()):
		var pattern : String = patterns[i]
		if (pattern + pattern).contains(key):
			return i
	
	return 1

static func _get_cell_transform(values:Array[float], cell_class:int) -> int:
	return 0

static func _get_connectivity_map(values:Array[float]) -> Dictionary:
	var average : float = (values[0] + values[1] + values[2] + values[3]) / 4
	
	var pos_count := 0
	for value in values:
		if value >= 0.0:
			pos_count += 1
	
	var neg_count := 4 - pos_count
	var min_count : int = min(pos_count, neg_count)
	
	var result := {}
	
	match min_count:
		1:
			pass
		2:
			pass
	
	if neg_count < pos_count:
		pass
	
	return result


static func _get_cell_edge_connection(id:int, values:Array[float]) -> int:
	var result : int = 0
	
	var average : float = (values[0] + values[1] + values[2] + values[3]) / 4
	
	var prev_value : float = 1.0
	var next_id := id
	for i in range(0, 4):
		var value := values[posmod(next_id, 4)]
		if (value < 0.0):
			next_id += 1
		else:
			next_id -= 1
		
		if sign(value) != sign(values[posmod(id, 4)]):
			break
	
	return id
