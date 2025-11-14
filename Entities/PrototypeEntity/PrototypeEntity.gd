extends Area2D

var player_inzone = false
const coffee_scene = preload("res://Entities/PrototypeBeverage/Coffee.tscn")

var drink_gotten = false
var drink_choice =  Beverage.coffee_colouring.keys().pick_random()
var drink_name = ""

func _ready() -> void:
	drink_name = GameManager.game_lang["coffee_name_" + drink_choice]

func _process(delta: float) -> void:
	if player_inzone and not GameManager.dialogue_menu_open:
		if Input.is_action_just_pressed("ui_confirm"):
			var plr = GameManager.PlayerInstance
			var latest_item = plr.beverages_latest
			if latest_item is Beverage:
				if latest_item.beverage_id == "Coffee":
					if latest_item.beverage_detail != drink_choice:
						GameManager.create_dialogue([{"name":GameManager.game_lang["proto_name"], "message":GameManager.game_lang["proto_msg5"].replace("{0}", drink_name)}], true)
					else:
						var coff = coffee_scene.instantiate()
						coff.set_all_offset(Vector2(-35, -15))
						coff.read_detail(latest_item.beverage_detail)
						coff.play("default")
						add_child(coff)
					
						plr.inventory_remove_item()
						GameManager.create_dialogue([{"name":GameManager.game_lang["proto_name"], "message":GameManager.game_lang["proto_msg4"]}], true)
			else:
				var dialogue: Array[Dictionary]
				for n in range(1,3): 
					dialogue.append({"name":GameManager.game_lang["proto_name"], "message":GameManager.game_lang["proto_msg" + str(n)]})
				
				dialogue.append({"name":GameManager.game_lang["proto_name"], "message":GameManager.game_lang["proto_msg3"].replace("{0}", drink_name)})
				GameManager.create_dialogue(dialogue, true)

func body_entered(body: Node2D) -> void:
	if body is Player:
		player_inzone = true

func body_exited(body: Node2D) -> void:
	if body is Player:
		player_inzone = false
