extends Node2D
class_name WorldInteractable

var player_inzone = false
@export var outline_sprite: TextureRect

func _ready() -> void:
	if outline_sprite: outline_sprite.visible = false

func _process(delta: float) -> void:
	if player_inzone and not GameManager.dialogue_menu_open and not GameManager.machine_menu_open:
		if Input.is_action_just_pressed("ui_confirm"):
			on_interact()

func on_interact():
	# Replace this in override class
	pass

func body_entered(body: Node2D) -> void:
	if body is Player:
		player_inzone = true
		if outline_sprite: outline_sprite.visible = true

func body_exited(body: Node2D) -> void:
	if body is Player:
		player_inzone = false
		if outline_sprite: outline_sprite.visible = false
