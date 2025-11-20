extends Node2D
class_name CafeGame

var day_active = false

var tutorial_progression = {
	"first_text": false,
	"first_fox_dialogue": false,
	"first_machine_open": false,
	"first_cup_on_grid": false,
	"first_espresso": false,
	"first_serve_button": false,
	"first_serving_correct": false,
	"learnt_about_double_espresso": false,
	"second_fox_dialogue": false,
	"second_serving_correct": false,
	"third_fox_dialogue": false,
	"first_pan_down": false,
	"first_bottle_pour": false,
	"first_jug_move": false,
	"first_pan_up": false,
	"third_serving_correct": false,
}
var tutorial_customer_puppets = {
	0: null, 1: null, 2: null
}

@export var table_nodes: Node2D
@export var entities_node: Node2D
@export var section_complete_screen: ColorRect
@export var pause_screen: Control
@export var game_over_screen: Control

@onready var game_timer: Timer = $DaylightTime
@export var timer_display: Label
@onready var time_of_day_lighting = $TimeOfDayLighting
@onready var satisfaction_spinner = $Interface/Container/TopRight/Satisfaction/Spinner

@onready var game_scene = get_tree().current_scene
@export var black_screen: ColorRect
const customer_scene = preload("res://Entities/Customer/Customer.tscn")
var occupied_seats: Dictionary[int, Customer]
var customer_count = 0
var customer_queue: Array[Customer] = []

var tutorial_puppet_customer: Customer

func _ready() -> void:
	for n in table_nodes.get_child_count():
		occupied_seats[n] = null
	
	$TimeOfDayLighting.color = Color("8fb6ff81")
	$Interface/Container/TopLeft/Day/Num.text = str(GameManager.RunData["day"])
	GameManager.player_can_move = true
	game_timer.start()
	game_timer.paused = true
	update_satisfaction()
	
	black_screen.self_modulate = Color("fff")
	black_screen.visible = true
	var day_cnt = black_screen.get_node("DayCnt")
	
	if GameManager.RunData["day"] == 0:
		day_cnt.get_node("Control/Alignment/Old").text = ""
		day_cnt.get_node("Control/Alignment/New").text = "0"
	else:
		day_cnt.get_node("Control/Alignment/Old").text = str(GameManager.RunData["day"] - 1)
		day_cnt.get_node("Control/Alignment/New").text = str(GameManager.RunData["day"])
	
	day_cnt.get_node("Control/Alignment").position = Vector2(0,0)
	day_cnt.modulate = Color("ffffff00")
	await get_tree().create_tween().tween_property(black_screen, "self_modulate", Color("ffffffac"), 0.65).finished
	await get_tree().create_tween().tween_property(day_cnt, "modulate", Color("fff"), 0.35).finished
	await GameManager.wait_seconds(0.7)
	await get_tree().create_tween().tween_property(day_cnt.get_node("Control/Alignment"), "position", Vector2(0,-149), 0.35).finished
	await GameManager.wait_seconds(1)
	await get_tree().create_tween().tween_property(black_screen, "self_modulate", Color("ffffff00"), 0.65).finished
	black_screen.visible = false
	
	if GameManager.RunData["day"] == 7:
		GameManager.create_dialogue([
			{"name":"", "message": GameManager.game_lang["demo_limitation_0"]},
			{"name":"", "message": GameManager.game_lang["demo_limitation_1"]}
		], false)
		await wait_until(func(): return not GameManager.dialogue_menu_open)
	elif GameManager.RunData["day"] == 0:
		start_tutorial()
	else:
		start_day()

func _process(delta: float) -> void:
	var time_passed = int(480 - game_timer.time_left)
	var mins = str(int(time_passed / 60.0) + 9).lpad(2, "0")
	var sec = str(int(time_passed % 60)).lpad(2, "0")
	timer_display.text = str(mins, ":", sec)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		pause_screen.pause_game()

func new_customer():
	if game_over_screen.is_game_over:
		return
	
	if (customer_count > 13) or (not occupied_seats.values().has(null)):
		GameManager.update_satisfaction(-2)
		print("Too many customers")
		return
	
	var inst = customer_scene.instantiate()
	entities_node.add_child(inst)
	inst.init(Customer.CUSTOMER_TYPE.FOX)
	customer_count += 1

func update_satisfaction():
	if game_over_screen.is_game_over:
		return
	
	var low_rot = -120
	var high_rot = 120
	var rate = lerp(low_rot, high_rot, GameManager.RunData["satisfaction"] / 100)
	satisfaction_spinner.rotation_degrees = rate
	
	if GameManager.RunData["satisfaction"] == 0:
		game_over_screen.init(false)

func do_light_cycle():
	time_of_day_lighting.color = Color("8fb6ff81")
	# 9am -> 1pm
	await get_tree().create_tween().tween_property(time_of_day_lighting, "color", Color("000000"), (60 * 4)).finished
	
	# 1pm -> 5pm
	await get_tree().create_tween().tween_property(time_of_day_lighting, "color", Color("9c7d56"), (60 * 4)).finished

func start_day():
	var current_day: int = GameManager.RunData["day"]
	
	day_active = true
	game_timer.paused = false
	game_timer.start()
	do_light_cycle()
	
	# These are for the coffee and dessert choice pool, easier coffees to be made are put on EASY for example
	# Extreme allows for any coffee or dessert
	# The game is only really supposed to be played up to level 10 or so.
	if current_day < 5:
		GameManager.CurrentDifficulty = GameManager.Difficulies.EASY
	elif current_day < 10:
		GameManager.CurrentDifficulty = GameManager.Difficulies.MEDIUM
	elif current_day < 15:
		GameManager.CurrentDifficulty = GameManager.Difficulies.HARD
	else:
		GameManager.CurrentDifficulty = GameManager.Difficulies.EXTREME
	
	await GameManager.wait_seconds(10)
	
	## Interval Calculation
	var min_start = 40.0
	var max_start = 50.0
	var min_limit = 5.0
	var decay_rate = 0.45
	
	var high = min_limit + (max_start - min_limit) * exp(-decay_rate * float(current_day - 1))
	var low = min_limit + (min_start - min_limit) * exp(-decay_rate * float(current_day - 1))
	
	while day_active:
		if (game_timer.time_left <= 0) or (game_over_screen.is_game_over):
			break
		new_customer()
		await GameManager.wait_seconds(randf_range(low, high))

func wait_until(condition: Callable) -> void:
	while not condition.call():
		if "process_frame" not in get_tree(): break
		await get_tree().process_frame

# Absolute mess. Apologies for anyone reading this. The jam is literally due 8 hours as of writing this -Kat
# This is literally just PirateSoftware code 101 -Kat
func start_tutorial():
	tutorial_progress(0)

func tutorial_progress(prog: int):
	if prog == 0:
		var dr_dat: Array[Dictionary] = []
		for n in range(0, 4):
			dr_dat.append({"name":"", "message": GameManager.game_lang["tutorial_"+str(n)]})
		
		GameManager.create_dialogue(dr_dat, false)
		await wait_until(func(): return not GameManager.dialogue_menu_open)
		await GameManager.wait_seconds(2)
		
		tutorial_customer_puppets[0] = customer_scene.instantiate()
		entities_node.add_child(tutorial_customer_puppets[0])
		tutorial_customer_puppets[0].position = Vector2(465.0, 90.0)
		tutorial_customer_puppets[0].customer_sprites.play("left")
		tutorial_customer_puppets[0].customer_name = GameManager.game_lang["fox_name_0"]
		tutorial_customer_puppets[0].pick_drink_request({
			"type": InventoryItem.ItemType.COFFEE,
			"detail": "espresso",
			"extra": null
		})
		await get_tree().create_tween().tween_property(tutorial_customer_puppets[0], "position", Vector2(114, 90), 4).finished
		tutorial_customer_puppets[0].customer_sprites.play("sit-left")
		
		GameManager.create_dialogue([{"name":"", "message": GameManager.game_lang["tutorial_4"]}], false)
		await wait_until(func(): return not GameManager.dialogue_menu_open)
		tutorial_progression["first_text"] = true
	
	elif prog == 1:
		GameManager.create_dialogue([
			{"name":"Brush", "message": GameManager.game_lang["fox_tutorial_speak"]},
			{"name":"", "message": GameManager.game_lang["tutorial_5"]}
		], false)
		await wait_until(func(): return not GameManager.dialogue_menu_open)
		
		var fox_pos: Vector2 = entities_node.get_node("TablesNodes/Table1/Mat/CollisionShape2D").global_position
		tutorial_customer_puppets[0].customer_sprites.play("right")
		await get_tree().create_tween().tween_property(tutorial_customer_puppets[0], "position", Vector2(fox_pos.x, 90), 1).finished
		tutorial_customer_puppets[0].customer_sprites.play("back")
		await get_tree().create_tween().tween_property(tutorial_customer_puppets[0], "position", fox_pos, 1).finished
		tutorial_customer_puppets[0].customer_sprites.play("sit-front")
		
		GameManager.create_dialogue([
			{"name":"", "message": GameManager.game_lang["tutorial_6"]}
		], false)
		await wait_until(func(): return not GameManager.dialogue_menu_open)
		tutorial_progression["first_fox_dialogue"] = true
	
	elif prog == 2:
		var dr_dat: Array[Dictionary] = []
		for n in range(7, 10): dr_dat.append({"name":"", "message": GameManager.game_lang["tutorial_"+str(n)]})
		GameManager.create_dialogue(dr_dat, false)
		tutorial_progression["first_machine_open"] = true
	
	elif prog == 3:
		var dr_dat: Array[Dictionary] = []
		for n in range(10, 12): dr_dat.append({"name":"", "message": GameManager.game_lang["tutorial_"+str(n)]})
		GameManager.create_dialogue(dr_dat, false)
		tutorial_progression["first_cup_on_grid"] = true
	
	elif prog == 4:
		var dr_dat: Array[Dictionary] = []
		for n in range(12, 16): dr_dat.append({"name":"", "message": GameManager.game_lang["tutorial_"+str(n)]})
		GameManager.create_dialogue(dr_dat, false)
		tutorial_progression["first_espresso"] = true
	
	elif prog == 5:
		GameManager.create_dialogue([
			{"name":"", "message": GameManager.game_lang["tutorial_16"]}
		], false)
		tutorial_customer_puppets[0].awaiting_order = true
		tutorial_progression["first_serve_button"] = true
	
	elif prog == 6:
		var dr_dat: Array[Dictionary] = []
		for n in range(17, 20): dr_dat.append({"name":"", "message": GameManager.game_lang["tutorial_"+str(n)]})
		await wait_until(func(): return not GameManager.dialogue_menu_open)
		GameManager.create_dialogue(dr_dat, false)
		tutorial_progression["first_serving_correct"] = true
		
		await GameManager.wait_seconds(10)
		tutorial_customer_puppets[1] = customer_scene.instantiate()
		entities_node.add_child(tutorial_customer_puppets[1])
		tutorial_customer_puppets[1].position = Vector2(465.0, 90.0)
		tutorial_customer_puppets[1].customer_sprites.play("left")
		tutorial_customer_puppets[1].customer_name = GameManager.game_lang["fox_name_1"]
		tutorial_customer_puppets[1].pick_drink_request({
			"type": InventoryItem.ItemType.COFFEE,
			"detail": "double_espresso",
			"extra": null
		})
		await get_tree().create_tween().tween_property(tutorial_customer_puppets[1], "position", Vector2(114, 90), 4).finished
		tutorial_customer_puppets[1].customer_sprites.play("sit-left")
	
	elif prog == 7:
		GameManager.create_dialogue([
			{"name":"Basil", "message": GameManager.game_lang["fox_speak_0"].replace("{0}", "Double Espresso")}
		], false)
		await wait_until(func(): return not GameManager.dialogue_menu_open)
		
		tutorial_progression["second_fox_dialogue"] = true
		var fox_pos: Vector2 = entities_node.get_node("TablesNodes/Table6/Mat/CollisionShape2D").global_position
		tutorial_customer_puppets[1].customer_sprites.play("right")
		await get_tree().create_tween().tween_property(tutorial_customer_puppets[1], "position", Vector2(fox_pos.x, 90), 1).finished
		tutorial_customer_puppets[1].customer_sprites.play("front")
		await get_tree().create_tween().tween_property(tutorial_customer_puppets[1], "position", fox_pos, 1).finished
		tutorial_customer_puppets[1].customer_sprites.play("sit-front")
		tutorial_customer_puppets[1].awaiting_order = true
	
	elif prog == 8:
		if (not tutorial_progression["learnt_about_double_espresso"]):
			GameManager.create_dialogue([
				{"name":"", "message": GameManager.game_lang["tutorial_20"]}
			], false)
			tutorial_progression["learnt_about_double_espresso"] = true
	
	elif prog == 9:
		tutorial_progression["second_serving_correct"] = true
		
		await GameManager.wait_seconds(10)
		tutorial_customer_puppets[2] = customer_scene.instantiate()
		entities_node.add_child(tutorial_customer_puppets[2])
		tutorial_customer_puppets[2].position = Vector2(465.0, 90.0)
		tutorial_customer_puppets[2].customer_sprites.play("left")
		tutorial_customer_puppets[2].customer_name = GameManager.game_lang["fox_name_2"]
		tutorial_customer_puppets[2].pick_drink_request({
			"type": InventoryItem.ItemType.COFFEE,
			"detail": "cappuchino",
			"extra": null
		})
		await get_tree().create_tween().tween_property(tutorial_customer_puppets[2], "position", Vector2(114, 90), 4).finished
		tutorial_customer_puppets[2].customer_sprites.play("sit-left")
		
	elif prog == 10:
		GameManager.create_dialogue([
			{"name":"Breeze", "message": GameManager.game_lang["fox_speak_0"].replace("{0}", "Cappuchino")},
			{"name":"", "message": GameManager.game_lang["tutorial_21"]}
		], false)
		await wait_until(func(): return not GameManager.dialogue_menu_open)
		tutorial_progression["third_fox_dialogue"] = true
	
		var fox_pos: Vector2 = entities_node.get_node("TablesNodes/Table9/Mat/CollisionShape2D").global_position
		tutorial_customer_puppets[2].customer_sprites.play("right")
		await get_tree().create_tween().tween_property(tutorial_customer_puppets[2], "position", Vector2(fox_pos.x, 90), 1).finished
		tutorial_customer_puppets[2].customer_sprites.play("front")
		await get_tree().create_tween().tween_property(tutorial_customer_puppets[2], "position", fox_pos, 1).finished
		tutorial_customer_puppets[2].customer_sprites.play("sit-front")
		tutorial_customer_puppets[2].awaiting_order = true
	
	elif prog == 11:
		GameManager.create_dialogue([{"name":"", "message": GameManager.game_lang["tutorial_22"]}], false)
		
	elif prog == 12:
		await GameManager.wait_seconds(2)
		GameManager.create_dialogue([{"name":"", "message": GameManager.game_lang["tutorial_30"]}], false)
		await wait_until(func(): return not GameManager.dialogue_menu_open)
		await GameManager.wait_seconds(8)
		await wait_until(func(): return not GameManager.dialogue_menu_open)
		$Interface/Container/SectionComplete.init()

func gametimer_timeout() -> void:
	game_timer.stop()
	game_timer.autostart = false
	$Interface/Container/TopRight/Timer/CurrentTime.text = "17:00"
	$Interface/Container/SectionComplete.init()
