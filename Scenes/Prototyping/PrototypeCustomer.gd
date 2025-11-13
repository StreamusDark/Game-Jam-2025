extends Area2D

@export var Plr: Player
var player_inzone = false

const coffee_scene = preload("res://Entities/PrototypePlayer/Coffee.tscn")

func _process(delta: float) -> void:
	if player_inzone and not GameManager.dialogue_menu_open:
		if Input.is_action_just_pressed("ui_confirm"):
			if len(Plr.stacked_beverages) == 0: return
			var latest_item = Plr.stacked_beverages[len(Plr.stacked_beverages) - 1]
			if latest_item is Beverage:
				if latest_item.beverage_id == "Coffee":
					Plr.inventory_remove_item()
					var coff = coffee_scene.instantiate()
					coff.offset = Vector2(-35, -15)
					coff.play("default")
					add_child(coff)

func body_entered(body: Node2D) -> void:
	if body is Player:
		player_inzone = true

func body_exited(body: Node2D) -> void:
	if body is Player:
		player_inzone = false
