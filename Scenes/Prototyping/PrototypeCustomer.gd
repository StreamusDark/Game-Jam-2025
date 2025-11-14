extends Area2D

var player_inzone = false

const coffee_scene = preload("res://Entities/PrototypeBeverage/Coffee.tscn")

func _process(delta: float) -> void:
	if player_inzone and not GameManager.dialogue_menu_open:
		if Input.is_action_just_pressed("ui_confirm"):
			var plr = GameManager.PlayerInstance
			var latest_item = plr.beverages_latest
			if latest_item is Beverage:
				if latest_item.beverage_id == "Coffee":
					if latest_item.beverage_detail == "empty":
						GameManager.create_dialogue([{"name":GameManager.game_lang["fox_name"], "message":GameManager.game_lang["fox_emptymug"]}], true)
					else:
						var coff = coffee_scene.instantiate()
						coff.set_all_offset(Vector2(-35, -15))
						coff.read_detail(latest_item.beverage_detail)
						coff.play("default")
						add_child(coff)
					
						plr.inventory_remove_item()
						GameManager.create_dialogue([{"name":GameManager.game_lang["fox_name"], "message":GameManager.game_lang["fox_satisfied"]}], true)

func body_entered(body: Node2D) -> void:
	if body is Player:
		player_inzone = true

func body_exited(body: Node2D) -> void:
	if body is Player:
		player_inzone = false
