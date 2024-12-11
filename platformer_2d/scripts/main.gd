extends Node2D

const MAX_LEVEL = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _enter_tree():
	# print("enter tree")
	switch_level(1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
	elif Input.is_action_just_pressed("quit"):
		get_tree().quit()

func switch_level(level):
	if level > MAX_LEVEL:
		level = 1

	var level_scene_file = "res://scenes/levels/level_%s.tscn" % level
	get_tree().call_deferred("change_scene_to_file", level_scene_file)
