@tool
class_name LashToolbar extends BoxContainer

## A BoxContainer that allows only one button to be toggled at a time.

#enum Orientation {ORIENTATION_HORIZONTAL, ORIENTATION_VERTICAL}
#@export var mode := Orientation.ORIENTATION_HORIZONTAL

@export var tool_index := 0 : set = _set_tool_index

signal tool_index_changed(index:int)

var buttons : Array[LashToolbarButton] = []

func _ready() -> void:
	for index in range(0, get_children().size()):
		var node : Node = get_children()[index]
		
		assert(node is LashToolbarButton)
		
		buttons.append(node)
		
		node.toggle_mode = true
		node.toggled.connect(_on_button_toggled.bind(index))
	
	# Toggle the current tool.
	buttons[posmod(tool_index, get_children().size())].set_deferred("button_pressed", true)
	tool_index = tool_index

func _on_button_toggled(toggled_on: bool, index:int) -> void:
	# Ignore buttons being toggled off. This should prevent an infinite loop.
	if not toggled_on:
		return
	
	_set_tool_index(index)

func _set_tool_index(index:int) -> void:
	# Release the one that was last pressed.
	if is_inside_tree() and tool_index != index:
		get_children()[tool_index].button_pressed = false
	
	# Finally update the tool index.
	tool_index = index
	tool_index_changed.emit(index)
