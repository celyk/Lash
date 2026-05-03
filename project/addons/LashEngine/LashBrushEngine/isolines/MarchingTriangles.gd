@tool
extends RefCounted

var polygons : Array[PackedVector2Array]

var values : Array[Array]
var points : Array[Array]

func create_from_image(img:Image) -> void:
	polygons.clear()
	
	var jagged_polygons := _get_jagged_polygons(img)
	
	for jagged_polygon:PackedInt64Array in jagged_polygons:
		var polygon := PackedVector2Array()
		
		for i in range(0, jagged_polygon.size()):
			var edge_hash : int = jagged_polygon[i]
			var edge_coord : Vector3i = _edge_hash_to_coord(edge_hash)
			var edge_number : int = edge_coord.z
			
			var t : float = values[edge_coord.x][edge_coord.y][edge_number]
			
			var a : Vector2 = Vector2(edge_coord.x, edge_coord.y)
			var b : Vector2 = a + [Vector2(1,0), Vector2(1,1), Vector2(0,1)][edge_number]

			var p : Vector2 = lerp(a, b, t)
			
			polygon.append(p)
		
		polygons.append(polygon)

# Returns integer IDs
func _get_jagged_polygons(img:Image) -> Array[PackedInt64Array]:
	values.resize(img.get_size().y)
	
	for j:int in range(0, img.get_size().y):
		for i:int in range(0, img.get_size().x):
			_get_isoline_for_tri(img, i, j, 0)
			
			var next_i : int = posmod(i + 1, img.get_size().x)
			var next_j : int = posmod(j + 1, img.get_size().y)
			
			var a : float
			var b : float
			
			var edges : Array[float] = []
			
			a = img.get_pixel(i, j).r
			
			b = img.get_pixel(next_i, j).r
			edges.append(_solve_crossing(a, b))
			
			b = img.get_pixel(next_i, next_j).r
			edges.append(_solve_crossing(a, b))
			
			b = img.get_pixel(i, next_j).r
			edges.append(_solve_crossing(a, b))
			
			values[i].append(edges)
	
	for j:int in range(0, img.get_size().y):
		for i:int in range(0, img.get_size().x):
			_intersects_interval(values[i][j], 0.0, 1.0)
	
	return []

## Returns the isoline in right triangle coordinates.
## Oriented
## dot(p,n) = 0
func _get_isoline_for_tri(img:Image, i:int, j:int, tri_id:int) -> Dictionary:
	var result := Dictionary()
	
	var a : float = img.get_pixel(i, j).r
	var b : float = img.get_pixel(i+1, j+1).r
	var c : float = img.get_pixel(i+1, j).r
	
	var ab_t : float = _solve_crossing(a, b)
	var ac_t : float = _solve_crossing(a, c)
	var bc_t : float = _solve_crossing(b, c)
	
	if not _intersects_interval(ab_t, 0, 1):
		pass
	
	match tri_id:
		0:
			result["from"] = Vector3()
			result["to"] = Vector3()
		1:
			result["from"] = Vector3()
			result["to"] = Vector3()
	
	return result

func _edge_hash_to_coord(hash:int) -> Vector3i:
	var result := Vector3i()
	result.z = hash % 3
	
	hash /= 3
	result.y = hash / values[0].size() 
	result.x = hash % values[0].size() 
	
	return result

func _coord_to_edge_hash(i:int, j:int, edge_number:int) -> int:
	return (j * values[0].size() + i) * 3 + edge_number

## a + t(b-a) = 0 -> t = -a / (b-a)
static func _solve_crossing(a:float, b:float) -> float:
	return -a / (b-a)

static func _intersects_interval(x:float, a:float, b:float) -> bool:
	return a <= x and x < b
