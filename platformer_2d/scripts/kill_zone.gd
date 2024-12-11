extends Area2D

@onready var timer = $Timer

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		print("You died!")
		Engine.time_scale = 0.5
		body.die() # You can also send a signal
		timer.start()


func _on_timer_timeout() -> void:
	Engine.time_scale = 1
	get_tree().reload_current_scene()
