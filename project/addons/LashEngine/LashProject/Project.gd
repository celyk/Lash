@tool
class_name LashProject extends RefCounted

#signal opened()
signal pre_saved()
signal post_saved()

var _resource : LashProjectResource = LashProjectResource.new()
var _edited_scene_root : Node

static func open(path:String) -> LashProject:
	var result := LashProject.new()
	result._resource = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)

	return result

func set_scene(root:Node) -> void:
	_resource.scene = PackedScene.new()
	
	_edited_scene_root = root
	
	if _resource.scene.pack(_edited_scene_root) != Error.OK:
		printerr("Can't pack scene.")

func save(path:String="") -> void:
	assert(_resource != null)
	
	_resource.scene.pack(_edited_scene_root)
	
	_edited_scene_root
	
	if path == "":
		path = _resource.resource_path
	
	print(path)
	ResourceSaver.save(_resource, path)
	
	post_saved.emit()
