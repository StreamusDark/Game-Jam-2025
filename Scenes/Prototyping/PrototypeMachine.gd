extends StaticBody2D

@export var Plr: Player;
var player_inzone = false

func _process(delta: float) -> void:
	if player_inzone and not GameManager.dialogue_menu_open:
		if Input.is_action_just_pressed("ui_confirm"):
			GameManager.open_coffee_machine()
			#GameManager.dialogue_menu_open = true
			#GameManager.player_can_move = false
			#await get_tree().create_timer(2).timeout
			#Plr.inventory_add_item()
			#GameManager.dialogue_menu_open = false
			#GameManager.player_can_move = true

func body_entered(body: Node2D) -> void:
	if body is Player:
		player_inzone = true

func body_exited(body: Node2D) -> void:
	if body is Player:
		player_inzone = false
