class_name PipePair extends Node2D

signal bird_entered
signal point_scored

var speed = 0

func set_speed(new_speed):
	speed = new_speed

func _process(delta):
	position.x += speed * delta
	
func _on_body_entered(body):
	if body is Bird:
		bird_entered.emit()

func _on_point_scored(body):
	if body is Bird:
		point_scored.emit()
		
func stop():
	speed = 0

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
