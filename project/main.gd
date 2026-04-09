extends Control

#@onready var lash_timeline: LashTimeline = $UI/HSplitContainer/VSplitContainer/Control/LashTimeline
@onready var lash_timeline: LashTimeline = $CanvasLayer/UI/%LashTimeline
@onready var lash_canvas: LashCanvas = $CanvasLayer/UI/%LashCanvas

var project := LashProject.new()

func _ready() -> void:
	lash_canvas.project = project
	
	if OS.get_name() == "macOS" || OS.get_name() == "iOS":
		get_window().content_scale_factor = 2.0

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("timeline_previous_frame"):
		lash_timeline.advance(-1)
	
	if Input.is_action_just_pressed("timeline_next_frame"):
		lash_timeline.advance(1)
	
	if Input.is_action_just_pressed("timeline_play"):
		lash_timeline.toggle_play()
	
	if Input.is_action_just_pressed("file_save"):
		var save_name := "user://test_save.lash"
		project.set_scene(lash_canvas.viewport)
		project.save(save_name)
		project = LashProject.open(save_name)
		lash_canvas.project = project
