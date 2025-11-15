extends WorldInteractable
class_name Customer

enum CUSTOMER_TYPE {
	FOX
}

var customer_type: CUSTOMER_TYPE
var customer_name: String
var customer_seat_number = -1

@export var satisfaction_timeout_time = 5
@export var disatisfaction_rate = 0.1
var customer_current_satisfaction = 10
var customer_served_satisfaction = 0

var drink_request: Dictionary = {}
var drink_request_formatted: String
const type_to_id = {CUSTOMER_TYPE.FOX: "fox"}

var awaiting_order = false
var drinking = false

@onready var customer_sprites: AnimatedSprite2D = $Sprite
@onready var game_scene: CafeGame = get_tree().current_scene
@onready var satisfaction_timer: Timer = $SatisfactionTimer

func _ready() -> void:
	customer_served_satisfaction = customer_current_satisfaction - ((disatisfaction_rate * 60) / satisfaction_timeout_time)
	print("Satisfaction decrease: ", customer_served_satisfaction, " per min")

func init(customer_variant: CUSTOMER_TYPE):
	# Pick Drink
	var type = InventoryItem.ItemType.COFFEE
	var detail = null
	
	match type:
		InventoryItem.ItemType.COFFEE:
			var options = InventoryItem.coffee_colouring.keys().filter(func(n): return n not in [GameManager.CoffeeType.NONE, GameManager.CoffeeType.EMPTY])
			detail = GameManager.CoffeeCodenames[options.pick_random()]
			drink_request_formatted = GameManager.game_lang["coffee_name_" + detail]
	
	drink_request = {
		"type": type,
		"detail": detail,
		"extra": null
	}
	
	# Pick Name
	var lang_key = type_to_id[customer_variant] + "_name_" + str(randi_range(0,20))
	customer_name = GameManager.game_lang[lang_key]
	
	position = Vector2(465.0, 90.0)
	customer_sprites.play("left")
	
	var queue_offset = 114.0 + (27 * len(game_scene.customer_queue))
	await get_tree().create_tween().tween_property(self, "position", Vector2(queue_offset, 90), randi_range(2,6)).finished
	satisfaction_timer.start(satisfaction_timeout_time)
	customer_sprites.play("sit-left")
	game_scene.customer_queue.append(self)

func pick_seat():
	satisfaction_timer.stop()
	game_scene.customer_queue.remove_at(0)
	
	# Absolute garbage code, never write this again kat. -kat
	var seat_options = game_scene.occupied_seats.keys().filter(func(n): return game_scene.occupied_seats[n] == null)
	customer_seat_number = seat_options.pick_random()
	game_scene.occupied_seats[customer_seat_number] = self
	var table_node: StaticBody2D = game_scene.table_nodes.get_node("Table"+str(customer_seat_number))
	var position_goal = table_node.position + table_node.get_node("Mat").position + table_node.get_node("Mat/CollisionShape2D").position
	
	customer_sprites.play("right")
	await get_tree().create_tween().tween_property(self, "position", Vector2(position_goal.x, position.y), 1).finished
	
	if position_goal.y < position.y: customer_sprites.play("back")
	else: customer_sprites.play("front")
	await get_tree().create_tween().tween_property(self, "position", position_goal, 1).finished
	customer_sprites.play("sit-front")
	awaiting_order = true
	satisfaction_timer.start(satisfaction_timeout_time)

func short_dialogue(msg: String):
	GameManager.create_dialogue([{
		"name": customer_name,
		"message": msg.replace("{0}", drink_request_formatted)
	}], true)

const coffee_scene = preload("res://Entities/InventoryItem/CoffeeItem/CoffeeItem.tscn")

func on_interact():
	if drinking:
		short_dialogue(GameManager.game_lang["fox_drinking"])
		return
	elif not awaiting_order: 
		return
	
	var item: InventoryItem = GameManager.PlayerInstance.inventory_latest
	
	if item == null:
		short_dialogue(GameManager.game_lang["fox_recheck"])
		return
	
	if (item.item_id != drink_request["type"]) or (GameManager.CoffeeCodenames[item.item_detail] != drink_request["detail"]):
		GameManager.update_satisfaction(-2.0)
		short_dialogue(GameManager.game_lang["fox_wrongorder"])
		return
	
	satisfaction_timer.stop()
	short_dialogue(GameManager.game_lang["fox_satisfied"])
	GameManager.RunData["customers_served"] += 1
	GameManager.RunData["coffees_served"][item.item_detail] += 1
	GameManager.update_satisfaction(customer_served_satisfaction)
	
	var coffee_clone: AnimatedSprite2D = coffee_scene.instantiate()
	coffee_clone.play("default")
	GameManager.PlayerInstance.inventory_remove_item()
	coffee_clone.read_detail(drink_request["detail"])
	game_scene.add_child(coffee_clone)
	coffee_clone.position = position + Vector2(-20, -20)
	
	awaiting_order = false
	drinking = true
	
	await get_tree().create_timer(randi_range(10, 15)).timeout
	coffee_clone.queue_free()
	drinking = false
	
	if 90 < position.y: customer_sprites.play("back")
	else: customer_sprites.play("front")
	await get_tree().create_tween().tween_property(self, "position", Vector2(position.x, 90), 1).finished
	customer_sprites.play("right")
	await get_tree().create_tween().tween_property(self, "position", Vector2(465.0, 90.0), 1).finished
	
	game_scene.occupied_seats[customer_seat_number] = null
	queue_free()

func satisfaction_timeout() -> void:
	GameManager.update_satisfaction(-disatisfaction_rate)
