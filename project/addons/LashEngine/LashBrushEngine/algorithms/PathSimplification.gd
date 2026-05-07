@tool
class_name LashPathSimplification extends Object

## An implementation of Schneider path fitting algorithm.
## Some code taken from:
## https://github.com/erich666/GraphicsGems/blob/master/gems/FitCurves.c
## https://github.com/volkerp/fitCurves/blob/master/fitCurves.py

## No duplicate control points pls
static func fit_curve(polyline:PackedVector2Array, error:float) -> PackedVector2Array:
	var tangent_0 : Vector2 = _compute_tangent(polyline, 0)
	var tangent_1 : Vector2 = -1.0 * _compute_tangent(polyline, polyline.size() - 1)
	
	var first : int = 0
	var last : int = polyline.size() - 1
	
	return _fit_cubic_spline(polyline, first, last, tangent_0, tangent_1, error)

## Fit a cubic bezier to a polyline
static func _fit_cubic_spline(polyline:PackedVector2Array, first:int, last:int, tangent_0:Vector2, tangent_1:Vector2, error:float, iteration_depth:=0) -> PackedVector2Array:
	assert(polyline.size() > 2)
	
	## Handle max recursion depth. This shouldn't happen often.
	if last - first <= 2:
		# Just a straight line.
		return [polyline[first], polyline[first], polyline[last], polyline[last]]
	
	var t_values : Array[float] = _chord_length_parameterize(polyline, first, last)
	
	var bezier_candidate : PackedVector2Array = _fit_cubic_bezier(polyline, first, last, t_values, tangent_0, tangent_1)
	#bezier_candidate = [polyline[first], polyline[first], polyline[last], polyline[last]]
	
	#return bezier_candidate
	
	## Find max deviation of points to fitted curve.
	#print(iteration_depth == 0 || last != polyline.size()-1)
	var error_result : Dictionary =  _compute_max_error(polyline, first, last, bezier_candidate, t_values)
	var max_error : float = error_result.max_error
	var split_index : int = error_result.split_index

	
	if max_error < error:
		return bezier_candidate
	
	#
	#if iteration_depth > 2:
		#return bezier_candidate
	
	#if iteration_depth > (((Engine.get_main_loop() as SceneTree).get_frame() / 30) % 10):
		#return bezier_candidate
	
	var split_tangent := _compute_tangent(polyline, split_index)
	
	var result := PackedVector2Array()
	
	if split_index - first < 3 || last - split_index < 3:
		split_index = (last + first + 1) / 2
	
	if split_index - first < 3 || last - split_index < 3:
		return bezier_candidate
	
	result.append_array(
		_fit_cubic_spline(polyline, first, split_index, tangent_0, -split_tangent, error, iteration_depth + 1)
	)
	result.append_array(
		_fit_cubic_spline(polyline, split_index, last, split_tangent, tangent_1, error, iteration_depth + 1)
	)
	
	return result

static func _fit_cubic_bezier(polyline:PackedVector2Array, first:int, last:int, t_values:Array[float], tangent_0:Vector2, tangent_1:Vector2) -> PackedVector2Array:
	var result : PackedVector2Array = [polyline[first], polyline[first], polyline[last], polyline[last]]
	
	#return result
	
	var num_points : int = last - first + 1

	# compute the A's
	var A : Array[PackedVector2Array]
	A.resize(num_points)
	
	
	for i:int in range(0, num_points):
		var u : float = t_values[i]
		
		A[i].resize(2)
		A[i][0] = tangent_0 * 3 * pow(1.0 - u, 2.0) * u
		A[i][1] = tangent_1 * 3 * (1.0 - u) * pow(u, 2.0)

	# Create the C and X matrices
	var X := Vector2()
	var C : Array[Array] # Transform2D()
	C.append([0.0, 0.0])
	C.append([0.0, 0.0])

	for i:int in range(0, num_points):
		C[0][0] += A[i][0].dot(A[i][0])
		C[0][1] += A[i][0].dot(A[i][1])
		C[1][0] += A[i][0].dot(A[i][1])
		C[1][1] += A[i][1].dot(A[i][1])

		var u : float = t_values[i]
		
		## TODO: Why does this look different to the paper?
		var tmp : Vector2 = polyline[first + i] - _bezier_interpolate(result[0], result[0], result[3], result[3], u)
		
		X[0] += A[i][0].dot(tmp)
		X[1] += A[i][1].dot(tmp)
	
	# Compute the determinants of C and X
	var det_C0_C1 : float = C[0][0] * C[1][1] - C[1][0] * C[0][1]
	var det_C0_X : float = C[0][0] * X[1] - C[1][0] * X[0]
	var det_X_C1 : float = X[0] * C[1][1] - X[1] * C[0][1]

	# Finally, derive alpha values
	var alpha_l : float = 0.0 if det_C0_C1 == 0 else det_X_C1 / det_C0_C1
	var alpha_r : float = 0.0 if det_C0_C1 == 0 else det_C0_X / det_C0_C1
	
	# First and last control points of the Bezier curve are
	# positioned exactly at the first and last data points
	# Control points 1 and 2 are positioned an alpha distance out
	# on the tangent vectors, left and right, respectively
	result[1] = result[0] + tangent_0 * alpha_l
	result[2] = result[3] + tangent_1 * alpha_r
	
	
	#result[1] = result[0] + tangent_0 * 100.0# * alpha_l
	#result[2] = result[3] + tangent_1 * 100.0# * alpha_r
	
	return result

static func _chord_length_parameterize(polyline:PackedVector2Array, first:int, last:int) -> Array[float]:
	var t_values : Array[float]
	t_values.resize(last - first + 1)
	
	var current_t : float = 0.0
	t_values[0] = current_t
	
	for i:int in range(first+1, last+1):
		current_t += (polyline[i] - polyline[i - 1]).length()
		t_values[i - first] = current_t
	
	assert(t_values.size() == last - first + 1)
	
	for i:int in range(0, t_values.size()):
		t_values[i] /= current_t
	
	return t_values

static func _refine_parameterization(t_values:Array[float]) -> Array[float]:
	# TODO: use Newtons method for better t values
	return t_values

static func _compute_max_error(
		polyline:PackedVector2Array, 
		first:int, 
		last:int, 
		bezier:PackedVector2Array, 
		t_values:Array[float]) -> Dictionary:
	
	var max_dist : float = 0.0
	var split_index : int = -1
	
	for i in range(first, last+1):
		var p : Vector2 = _bezier_interpolate(bezier[0], bezier[1], bezier[2], bezier[3], t_values[i - first])
		var dist : float = (p - polyline[i]).length_squared()
		
		if dist >= max_dist:
			max_dist = dist
			split_index = i
	
	assert(split_index != -1)
	
	return {
		"max_error": max_dist,
		"split_index": split_index
	}

static func _compute_tangent(polyline:PackedVector2Array, index:int) -> Vector2:
	var previous_index : int = max(index - 1, 0)
	var next_index : int = min(index + 1, polyline.size() - 1)
	return (polyline[next_index] - polyline[previous_index]).normalized()

static func _bezier_interpolate(p0:Vector2, p1:Vector2, p2:Vector2, p3:Vector2, t:float) -> Vector2:
	return p0.bezier_interpolate(p1, p2, p3, t)
	return p0.bezier_interpolate(p1 - p0, p2 - p3, p3, t)
