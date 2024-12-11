extends Node

var score = 0

@onready var score_label = $ScoreLabel
@onready var pickup_sound = $"../SFX/PickupSound"

func _ready():
	var coins = get_tree().get_nodes_in_group("coin")
	for coin:Coin in coins:
		coin.collected.connect(_on_coin_collected)

func _on_coin_collected():
	pickup_sound.play()
	score += 1
	score_label.text = "You collected %s coins." % score
