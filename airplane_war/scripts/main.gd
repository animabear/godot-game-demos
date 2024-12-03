extends Node2D

@export var enemy_scenes: Array[PackedScene] = []
@export var bg_scroll_speed = 100

@onready var player = $Player
@onready var player_spawn_pos = $PlayerSpawnPos
@onready var laser_container = $LaserContainer
@onready var timer = $EnemySpawnTimer
@onready var enemy_container = $EnemyContainer
@onready var gos = $UILayer/GameOverScreen
@onready var bg = $ParallaxBackground

@onready var laser_sound = $SFX/LaserSound
@onready var hit_sound = $SFX/HitSound
@onready var explode_sound = $SFX/ExplodeSound

var score = 0

const MIN_ENEMY_SPAWN_WAIT_TIME = 0.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# position is relative to parent node
	# global_position is relative to global canvas
	player.global_position = player_spawn_pos.global_position
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	elif Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
	
	if timer.wait_time > MIN_ENEMY_SPAWN_WAIT_TIME:
		timer.wait_time -= delta * 0.005
	else:
		timer.wait_time = MIN_ENEMY_SPAWN_WAIT_TIME

	bg.scroll_offset.y += delta * bg_scroll_speed
	if bg.scroll_offset.y >= 960:
		bg.scroll_offset.y = 0


func _on_player_laser_shoot(laser_scene: PackedScene, location: Vector2) -> void:
	var laser = laser_scene.instantiate()
	laser.global_position = location
	laser_container.add_child(laser)
	laser_sound.play()


func _on_enemy_spawn_timer_timeout() -> void:
	var enemy = enemy_scenes.pick_random().instantiate()
	enemy.global_position = Vector2(randf_range(50, 500), -50) # set y=-50, enemy will spawn off screen
	enemy.killed.connect(_on_enemy_killed)
	enemy.hit.connect(_on_enemy_hit)
	enemy_container.add_child(enemy)


func _on_enemy_killed(points):
	score += points
	#print(score)
	
	if PlayerVariables.high_score < score:
		PlayerVariables.high_score = score

	$UILayer/HUD.update_score(score)
	

func _on_enemy_hit():
	hit_sound.play()


func _on_player_killed() -> void:
	explode_sound.play()
	gos.set_score(score)
	gos.set_high_score(PlayerVariables.high_score)
	await get_tree().create_timer(1).timeout
	gos.show()
