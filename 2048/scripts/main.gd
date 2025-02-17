extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Engine.time_scale = 0.2 # for debug animation
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
	elif Input.is_action_just_pressed("quit"):
		get_tree().quit()
