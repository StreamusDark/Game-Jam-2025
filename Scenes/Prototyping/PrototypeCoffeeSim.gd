extends Control

var current_pan = ""
const pan_positions = {
	"centre": Vector2(-871.0, 0.0),
	"left": Vector2(326.0, 0.0),
	"right": Vector2(-2079.0, 0.0)
}

func _ready() -> void:
	change_pan("centre")

func change_pan(pan_id: String):
	get_tree().create_tween().tween_property($Interface, "position", pan_positions[pan_id], 0.5)
	current_pan = pan_id

func leftpan_mouse_entered() -> void:
	$Interface/PanHitboxes.visible = false
	change_pan("left" if current_pan == "centre" else "centre")
	await get_tree().create_timer(1).timeout
	$Interface/PanHitboxes.visible = true


func rightpan_mouse_entered() -> void:
	$Interface/PanHitboxes.visible = false
	change_pan("right" if current_pan == "centre" else "centre")
	await get_tree().create_timer(1).timeout
	$Interface/PanHitboxes.visible = true
