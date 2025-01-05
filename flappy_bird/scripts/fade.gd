class_name Fade extends Node

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func play():
	animation_player.play("fade")
