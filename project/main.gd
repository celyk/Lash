extends Control

#@onready var lash_timeline: LashTimeline = $UI/HSplitContainer/VSplitContainer/Control/LashTimeline
@onready var lash_timeline: LashTimeline = $CanvasLayer/UI/%LashTimeline
@onready var lash_canvas: LashCanvas = $CanvasLayer/UI/%LashCanvas

var project := LashProject.new()

var save_name := "user://test_save.lash"

var save_count := 0

func _ready() -> void:
	#project = LashProject.open(save_name)
	lash_canvas.project = project
	
	var line_2d := Line2D.new()
	line_2d.width = 40
	line_2d.antialiased = true
	line_2d.default_color = Color.PURPLE.from_hsv(save_count / PI + .6, 1.0, 1.0)
	line_2d.add_point(Vector2(400 + save_count * 50,100))
	line_2d.add_point(Vector2(100, 400))
	line_2d.add_point(Vector2(500, 500))
	line_2d.add_point(Vector2(200, 500))
	
	print(lash_canvas.viewport.get_child(2))
	#lash_canvas.viewport.get_child(2).add_child(line_2d, true); line_2d.owner = lash_canvas.viewport.get_child(2)
	print(line_2d.get_path())
	
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
		save_count += 1
	

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_D:
			AppState.show_debug = event.pressed
