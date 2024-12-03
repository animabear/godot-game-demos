class_name Player extends CharacterBody2D

# generate the laser through signal
# avoid the laser's position being affected by the player position(if appended as a child node)
signal laser_shoot(laser_scene, location)
signal killed

@export var speed = 300
@export var rate_of_fire = 0.25

@onready var muzzle = $Muzzle
@onready var sprite2d = $Sprite2D

#var laser_scene = preload("res://scenes/laser.tscn")
@export var laser_scene: PackedScene # better performance

var shoot_cd = false

func _process(delta: float) -> void:
	if Input.is_action_pressed("shoot"):
		if !shoot_cd:
			shoot_cd = true
			shoot()
			await get_tree().create_timer(rate_of_fire).timeout
			shoot_cd = false

func _physics_process(delta: float) -> void:
	var direction = Vector2(
		Input.get_axis("move_left", "move_right"), 
		Input.get_axis("move_up", "move_down"),
	)
	velocity = direction * speed
	move_and_slide()
	
	var airplaneSize = sprite2d.get_rect().size
	global_position = global_position.clamp(
		Vector2.ZERO + airplaneSize / 2, 
		get_viewport_rect().size - airplaneSize / 2,
	)
	
func shoot():
	# pass laser_scene params to support different laser
	laser_shoot.emit(laser_scene, muzzle.global_position)
	
func die():
	killed.emit()
	queue_free()
