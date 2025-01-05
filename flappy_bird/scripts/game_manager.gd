extends Node

@onready var bird: Bird = $"../Bird"
@onready var pipe_spawner: PipeSpawner = $"../PipeSpawner"
@onready var ground: Ground = $"../Ground"
@onready var bird_spawn_pos: Marker2D = $"../BirdSpawnPos"
@onready var fade: Fade = $"../Fade"
@onready var ui: UI = $"../UI"

@export var acceleration = 5

var points = 0
var is_game_ended = false

func _ready():
	bird.global_position = bird_spawn_pos.global_position

func on_game_started():
	pipe_spawner.start_spawning_pipes()

func on_game_ended():
	if is_game_ended:
		return
	
	is_game_ended = true
	fade.play()
	ground.stop()
	bird.killed()
	pipe_spawner.stop()
	ui.on_game_over()

func on_point_scored():
	points += 1
	ui.update_points(points)
	
	ground.accelerate(acceleration)
	pipe_spawner.accelerate(acceleration)
