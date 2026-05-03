@tool
class_name LashProject extends RefCounted

#signal opened()
signal pre_saved()
signal post_saved()

var _resource : LashProjectResource = LashProjectResource.new()
var _edited_scene_root : Node

static func open(path:String) -> LashProject:
	var result := LashProject.new()
	
	#result._resource = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
	
	result.load_with_file(path)
	
	return result

func set_scene(root:Node) -> void:
	_resource.scene = PackedScene.new()
	
	_edited_scene_root = root
	
	if _resource.scene.pack(_edited_scene_root) != Error.OK:
		printerr("Can't pack scene.")

func save(path:String="") -> void:
	assert(_resource != null)
	
	_resource.scene.pack(_edited_scene_root)
	
	#_edited_scene_root
	
	if path == "":
		path = _resource.resource_path
	
	save_with_file(path)
	
	print(path)
	#ResourceSaver.save(_resource, path, ResourceSaver.FLAG_CHANGE_PATH)
	
	post_saved.emit()

func save_with_file(path:String="") -> void:
	#if FileAccess.file_exists(path):
		#DirAccess.remove_absolute()
	var file := FileAccess.open(path, FileAccess.WRITE)
	print("save_with_file ", file, FileAccess.get_open_error())
	
	#_resource.scene.set_path_cache("")
	_resource.scene = _resource.scene.duplicate(true)
	
	#_resource.take_over_path("")
	#_resource.set_path_cache("")
	#
	
	#file.store_var(_resource.duplicate_deep(Resource.DEEP_DUPLICATE_ALL), true)
	file.store_var(_resource, true)

func load_with_file(path:String="") -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	
	if file == null:
		return
	
	var result := file.get_var(true)
	print(result)
	if result is Resource:
		print("it's a resource")
		_resource = result
		
		#_resource.scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
