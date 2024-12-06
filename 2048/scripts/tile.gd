class_name Tile extends Node2D

const DEFAULT_SACLE = 1.5 # set in the godot editor (Sprite2D > Node2D > Transform)

const TILE_BG_COLOR_CONF_DEFAULT = Color8(237, 194, 45)
const TILE_BG_COLOR_CONF = {
	2:    Color8(239, 228, 218),
	4:    Color8(237, 224, 200),
	8:    Color8(242, 177, 121),
	16:   Color8(245, 149, 99),
	32:   Color8(246, 124, 96),
	64:   Color8(246, 94, 59),
	128:  Color8(237, 207, 115),
	256:  Color8(237, 204, 98),
	512:  Color8(237, 200, 80),
	1024: Color8(237, 197, 63),
	2048: Color8(237, 194, 45),
}

const TILE_FONT_COLOR_DEFAULT = Color8(249, 246, 242)
const TILE_FONT_COLOR_CONF = {
	2: Color8(119, 110, 101),
	4: Color8(119, 110, 101),
}

const DEFAULT_VALUE = 2

const DEFAULT_FONT_SIZE = 36 # 36 px, set in godot editor

var value = DEFAULT_VALUE
var has_merged = false

func animate_spawn():
	$Sprite2D.scale = Vector2(DEFAULT_SACLE * 0.2, DEFAULT_SACLE * 0.2)
	$Sprite2D.modulate.a = 0 # alpha channel
	
	var tween = get_tree().create_tween()
	
	tween.parallel().tween_property($Sprite2D, "scale", 
		Vector2(DEFAULT_SACLE * 1.2, DEFAULT_SACLE * 1.2), 0.1).set_trans(Tween.TRANS_QUAD).set_delay(0.2)

	tween.parallel().tween_property($Sprite2D, "modulate", TILE_BG_COLOR_CONF[DEFAULT_VALUE], 0.1).set_delay(0.2)

	tween.tween_property($Sprite2D, "scale", 
		Vector2(DEFAULT_SACLE, DEFAULT_SACLE), 0.1).set_trans(Tween.TRANS_QUAD)


func animate_position(newPos: Vector2, should_free: bool):
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", newPos, 0.2).set_trans(Tween.TRANS_QUAD)
	if should_free:
		$Sprite2D.z_index = 0
		tween.tween_callback(queue_free) # wait animation to finish

func merge():
	value *= 2
	animate_merge(get_bg_color(value), get_font_color(value), 0.1, 0.1)

func animate_merge(bg_color, font_color, time, delay):
	var tween = get_tree().create_tween()
	
	# color and sacle will change at the same time
	tween.parallel().tween_property($Sprite2D, "self_modulate",
		bg_color, time).set_delay(delay)
	
	tween.parallel().tween_property($Sprite2D, "scale", 
		Vector2(DEFAULT_SACLE * 1.2, DEFAULT_SACLE * 1.2), 
		time).set_trans(Tween.TRANS_QUAD).set_delay(delay)
	
	tween.parallel().tween_property($Sprite2D/Control/Label, 
		"theme_override_colors/font_color", font_color, time).set_delay(delay)

	tween.tween_callback(update_label) # update immediately after sacle the tile
		
	tween.tween_property($Sprite2D, "scale",
		Vector2(DEFAULT_SACLE, DEFAULT_SACLE), time).set_trans(Tween.TRANS_QUAD)
   
func get_font_color(v):
	if TILE_FONT_COLOR_CONF.has(v):
		return TILE_FONT_COLOR_CONF[v]
 
	return TILE_FONT_COLOR_DEFAULT

func get_bg_color(v):
	if TILE_BG_COLOR_CONF.has(v):
		return TILE_BG_COLOR_CONF[v]

	return TILE_BG_COLOR_CONF_DEFAULT
	
func update_label():
	$Sprite2D/Control/Label.text = str(value)
	
	var tween = get_tree().create_tween()
	tween.tween_property($Sprite2D/Control/Label,
		"theme_override_font_sizes/font_size", get_font_size(value), 0.1)

func get_font_size(value) -> int:
	if value >= 128:
		return 28
	if value >= 1024:
		return 20
	return DEFAULT_FONT_SIZE
