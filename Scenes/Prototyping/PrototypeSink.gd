extends StaticBody2D

@export var Plr: Player;
var player_inzone = false

func _process(delta: float) -> void:
	if player_inzone and not GameManager.dialogue_menu_open and not GameManager.machine_menu_open:
		if Input.is_action_just_pressed("ui_confirm"):
			GameManager.PlayerInstance.inventory_remove_item()

func body_entered(body: Node2D) -> void:
	if body is Player:
		player_inzone = true

func body_exited(body: Node2D) -> void:
	if body is Player:
		player_inzone = false
