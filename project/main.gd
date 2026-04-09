extends Control

@onready var lash_timeline: LashTimeline = $UI/HSplitContainer/VSplitContainer/Control/LashTimeline

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("timeline_previous_frame"):
		lash_timeline.advance(-1)
	
	if Input.is_action_just_pressed("timeline_next_frame"):
		lash_timeline.advance(1)
	
	if Input.is_action_just_pressed("timeline_play"):
		lash_timeline.toggle_play()
