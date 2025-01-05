class_name PipeSpawner extends Node

signal bird_crashed
signal point_scored

var pipe_pair_scene = preload("res://scenes/pipe_pair.tscn")

@export var pipe_speed = -150

@onready var spawn_timer = $SpawnTimer


func start_spawning_pipes():
	spawn_timer.start()

func spawn_pipe():
	var pipe: PipePair = pipe_pair_scene.instantiate()
	add_child(pipe)
	
	var viewport_rect = get_viewport().get_camera_2d().get_viewport_rect()
	var viewport_height = viewport_rect.size.y
	
	pipe.position.x = viewport_rect.end.x / 2 - 100
	pipe.position.y = randf_range(-viewport_height * 0.18, viewport_height * 0.08)
	
	pipe.bird_entered.connect(on_bird_entered)
	pipe.point_scored.connect(on_point_scored)
	pipe.set_speed(pipe_speed)

func on_bird_entered():
	bird_crashed.emit()
	
func on_point_scored():
	point_scored.emit()

func stop():
	spawn_timer.stop()

	var pipes = get_tree().get_nodes_in_group("pipe")
	for pipe: PipePair in pipes:
		pipe.stop()

func accelerate(value):
	pipe_speed -= value
	
	var pipes = get_tree().get_nodes_in_group("pipe")
	for pipe: PipePair in pipes:
		pipe.set_speed(pipe_speed)
