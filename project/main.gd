extends Control

#@onready var lash_timeline: LashTimeline = $UI/HSplitContainer/VSplitContainer/Control/LashTimeline
@onready var lash_timeline: LashTimeline = $CanvasLayer/UI/%LashTimeline
@onready var lash_canvas: LashCanvas = $CanvasLayer/UI/%LashCanvas

var project := LashProject.new()

var save_name := "user://test_save.res" #.lash

func _ready() -> void:
	project = LashProject.open(save_name)
	lash_canvas.project = project
	
	var line_2d := Line2D.new()
	line_2d.width = 40
	line_2d.antialiased = true
	line_2d.default_color = Color.BLUE
	line_2d.add_point(Vector2(500,10))
	line_2d.add_point(Vector2(0, 400))
	line_2d.add_point(Vector2(500, 500))
	line_2d.add_point(Vector2(200, 500))
	#lash_canvas.viewport.get_child(2).add_child(line_2d)
	#line_2d.owner = lash_canvas.viewport.get_child(2)
	
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
		project.set_scene(lash_canvas.viewport.get_child(2))
		project.save(save_name)
		project = LashProject.open(save_name)
		lash_canvas.project = project
