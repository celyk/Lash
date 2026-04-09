@tool
class_name LashProject extends RefCounted

#signal opened()
signal pre_saved()
signal post_saved()

var _resource := LashProjectResource.new()

static func open(path:String) -> LashProject:
	var result := LashProject.new()
	result._resource = ResourceLoader.load(path)

	return result

func set_scene(root:Node) -> void:
	_resource.scene = PackedScene.new()
	
	if _resource.scene.pack(root) != Error.ERR_CANT_CREATE:
		printerr("Can't pack scene.")

func save(path:String="") -> void:
	assert(_resource != null)
	
	pre_saved.emit()
	
	if path == "":
		path = _resource.resource_path
	
	ResourceSaver.save(_resource, path)
	
	post_saved.emit()
