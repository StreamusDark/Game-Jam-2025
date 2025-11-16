extends Control

var tutorial_mode = false
@onready var game_scene: CafeGame = get_tree().current_scene
@export var content_node: Node2D

@export var current_cup: Sprite2D
@export var current_cup_options: VBoxContainer
@export var liquid_button: TextureButton
@export var liquid_effect: GPUParticles2D
@export var steam_button: TextureButton
@export var steam_effect: GPUParticles2D
@export var cups_button: Button
@export var cup_type_display: Label
@export var beans_that_move: Sprite2D

var current_cup_in_deco = false
var current_cup_type: GameManager.CoffeeType = GameManager.CoffeeType.NONE
var current_cup_selected = false
var current_espresso_count = 0

var using_last_drink = false

var coffee_pouring_active = false
var steam_active = false

const milk_jug_positons = {"up": Vector2(606.0, 640.0), "down":Vector2(818.0, 1333.0)}
@export var milk_jug: Sprite2D
@export var milk_jug_options: VBoxContainer
@export var milk_display: Label
var milk_in_deco = true
var milk_in_jug = false
var milk_selected = false
var milk_steam_percent: float = 0.0
var milk_pouring = false

@export var milk_bottle: AnimatedSprite2D
var milk_bottle_selected = false
var milk_bottle_pouring = false

var milk_bottle_volume = 25

func _ready() -> void:
	tutorial_mode = (GameManager.RunData["day"] == 0)
	initialise_signals()
	
	current_cup.position = Vector2(341.0, 532.4)
	milk_jug.position = milk_jug_positons["down"]
	milk_jug.rotation_degrees = 0
	milk_bottle.position = Vector2(122.0, 36.0)
	milk_bottle.rotation_degrees = 0
	milkbottle_update_sprites(true)
	$RecipeBg.visible = false
	
	content_node.position = Vector2(0,0)
	$PanUp.visible = false
	restart_cup()
	restart_jug()

func initialise_signals():
	for btn in [cups_button, liquid_button, steam_button, $RecipeBook/Button, $Content/Jug/MilkJug, $Content/Decorations/MilkBottle/Button, $Exit/Button, $UseLast/Button, $RecipeBg/CloseRecipes/Button]:
		btn.connect("mouse_entered", Callable(self, "selectable_hover_enter").bind(btn))
		btn.connect("mouse_exited", Callable(self, "selectable_hover_exited").bind(btn))
		btn.get_node("Hover").visible = false
		
		var name_node = btn.get_node_or_null("Name")
		if name_node: name_node.visible = false

func selectable_hover_enter(selectable: Node): 
	selectable.get_node("Hover").visible = true
	var name_node = selectable.get_node_or_null("Name")
	if name_node: name_node.visible = true

func selectable_hover_exited(selectable: Node): 
	selectable.get_node("Hover").visible = false
	var name_node = selectable.get_node_or_null("Name")
	if name_node: name_node.visible = false

func _process(delta: float) -> void:
	if coffee_pouring_active:
		beans_that_move.position = Vector2(randf_range(-46.2, -46.6), randf_range(-84.2, -84.8))

func restart_cup():
	current_cup_options.visible = false
	current_cup.get_node("CoffeeTypeContainer").visible = false
	
	liquid_button.disabled = false
	liquid_effect.emitting = false
	coffee_pouring_active = false
	current_cup_options.visible = false
	current_cup_selected = false
	using_last_drink = false
	
	update_coffee_state(GameManager.CoffeeType.NONE)

func restart_jug():
	milk_in_jug = false
	milk_jug.get_node("Colouring").self_modulate = Color("#464559")
	milk_steam_percent = 0.0
	milk_display.text = GameManager.game_lang["milk_none"]

func change_selectable(selectable_id: String):
	var cup_nodes = [current_cup.get_node("Hover"), current_cup.get_node("CoffeeTypeContainer"), current_cup_options]
	var milkjug_nodes = [milk_jug.get_node("MilkJug/Name"), milk_jug.get_node("MilkJug/Hover"), milk_jug_options]
	var milkbottle_nodes = [milk_bottle.get_node("Button/Name"), milk_bottle.get_node("Button/Hover"), milk_bottle.get_node("BottleOptions")]
	
	var true_nodes = []
	var false_nodes = []
	
	match selectable_id:
		"cup":
			current_cup_selected = true
			milk_selected = false
			
			true_nodes = cup_nodes
			false_nodes.append_array(milkjug_nodes)
			false_nodes.append_array(milkbottle_nodes)
		"milkjug":
			current_cup_selected = false
			milk_selected = true
			
			true_nodes = milkjug_nodes
			false_nodes.append_array(cup_nodes)
			false_nodes.append_array(milkbottle_nodes)
		"milkbottle":
			current_cup_selected = false
			milk_selected = false
			milk_bottle_selected = true
			
			true_nodes = milkbottle_nodes
			false_nodes.append_array(cup_nodes)
			false_nodes.append_array(milkjug_nodes)
		"close":
			current_cup_selected = false
			milk_selected = false
			milk_bottle_selected = true
			
			false_nodes.append_array(cup_nodes)
			false_nodes.append_array(milkjug_nodes)
			false_nodes.append_array(milkbottle_nodes)
	
	for n in true_nodes: 
		n.visible = true
	for m in false_nodes: 
		m.visible = false

func update_coffee_state(coffee_id: GameManager.CoffeeType):
	current_cup_type = coffee_id
	if current_cup_type == GameManager.CoffeeType.NONE:
		current_espresso_count = 0
		current_cup.visible = false
		return
	
	current_cup.visible = true
	cup_type_display.text = GameManager.game_lang["coffee_name_" + GameManager.CoffeeCodenames[current_cup_type]]
	current_cup.get_node("CoffeeColouring").self_modulate = InventoryItem.coffee_colouring[current_cup_type]

func liquid_button_pressed() -> void:
	liquid_button.get_node("Beep").play()
	if current_cup_selected or milk_selected or GameManager.dialogue_menu_open or milk_pouring:
		return
		
	if current_cup_type == GameManager.CoffeeType.NONE and (not GameManager.dialogue_menu_open):
		var no_drink_info: Array[Dictionary] = [{"name":"", "message":GameManager.game_lang["coffee_needscup"]}]
		GameManager.create_dialogue(no_drink_info, false)
		return
	elif current_espresso_count == 2 and (not GameManager.dialogue_menu_open):
		var too_much: Array[Dictionary] = [{"name":"", "message":GameManager.game_lang["coffee_toomuch"]}]
		GameManager.create_dialogue(too_much, false)
		return
	
	liquid_button.disabled = true
	liquid_effect.emitting = true
	coffee_pouring_active = true
	liquid_button.get_node("Pouring").play()
	await get_tree().create_timer(8).timeout
	
	coffee_pouring_active = false
	liquid_effect.emitting = false
	liquid_button.disabled = false
	liquid_button.get_node("Pouring").stop()
	
	var change_state_link = {
		GameManager.CoffeeType.EMPTY: GameManager.CoffeeType.ESPRESSO,
		GameManager.CoffeeType.ESPRESSO: GameManager.CoffeeType.DOUBLE_ESPRESSO,
		GameManager.CoffeeType.MACCHIATO: GameManager.CoffeeType.DOUBLE_MACCHIATO,
		GameManager.CoffeeType.MINILATTE: GameManager.CoffeeType.LATTE,
		GameManager.CoffeeType.CORTADO: GameManager.CoffeeType.CAPPUCHINO,
		GameManager.CoffeeType.FLATWHITE: GameManager.CoffeeType.DRY
	}
	
	current_espresso_count += 1
	update_coffee_state(change_state_link[current_cup_type])
	
	if tutorial_mode and (not game_scene.tutorial_progression["first_espresso"]):
		game_scene.tutorial_progress(4)

func steam_button_down() -> void:
	steam_button.get_node("Beep").play()
	if (milk_in_deco) and (not GameManager.dialogue_menu_open):
		var need_milk: Array[Dictionary] = [{"name":"", "message":GameManager.game_lang["coffee_needmilkjug"]}]
		GameManager.create_dialogue(need_milk, false)
		steam_active = false
		return
	elif (milk_selected):
		return
	
	steam_active = true
	steam_effect.emitting = true
	for n in range(1000):
		await get_tree().create_timer(0.1).timeout
		if steam_active and milk_steam_percent < 100 and milk_in_jug:
			milk_steam_percent += 1
			milk_display.text = GameManager.game_lang["milk_froath"].replace("{0}", str(int(milk_steam_percent)))
		else:
			if milk_steam_percent > 100: milk_steam_percent = 100
			break

func steam_button_up() -> void:
	if not milk_in_deco:
		steam_active = false
		steam_effect.emitting = false

func cup_button_pressed() -> void:
	if tutorial_mode and (not game_scene.tutorial_progression["first_cup_on_grid"]): 
		if (current_cup_type == GameManager.CoffeeType.NONE) and GameManager.dialogue_menu_open == false:
			game_scene.tutorial_progress(3)
			update_coffee_state(GameManager.CoffeeType.EMPTY)
			cups_button.get_node("MoveSound").play()
			return
	
	if (current_cup_type == GameManager.CoffeeType.NONE) and GameManager.dialogue_menu_open == false:
		cups_button.get_node("MoveSound").play()
		update_coffee_state(GameManager.CoffeeType.EMPTY)

func current_coffee_pressed() -> void:
	if tutorial_mode and (not game_scene.tutorial_progression["first_espresso"]):
		return
	
	if (not coffee_pouring_active):
		change_selectable("cup")

func current_coffee_hover_enter() -> void: 
	current_cup.get_node("CoffeeTypeContainer").visible = true
	current_cup.get_node("Hover").visible = true
	
func current_coffee_hover_exited() -> void: 
	if (not current_cup_selected):
		current_cup.get_node("CoffeeTypeContainer").visible = false
		current_cup.get_node("Hover").visible = false

func serve_drink_pressed() -> void:
	get_node("MoveSound").play()
	if tutorial_mode and (not game_scene.tutorial_progression["first_serve_button"]):
		game_scene.tutorial_progress(5)
	
	if len(GameManager.PlayerInstance.inventory_data) >= 6:
		change_selectable("close")
		var toomany: Array[Dictionary] = [{"name":"", "message":GameManager.game_lang["coffee_toomany"]}]
		GameManager.create_dialogue(toomany, false)
		return
		
	
	var coffee_value = {
		"type": "coffee",
		"detail": current_cup_type
	}
	GameManager.PlayerInstance.inventory_add_item(coffee_value)
	restart_cup()
	close_machine()

func discard_drink_pressed() -> void:
	restart_cup()

func cancel_drink_pressed() -> void:
	change_selectable("close")

func close_machine() -> void:
	if (tutorial_mode and not game_scene.tutorial_progression["first_serve_button"]):
		return
	GameManager.close_coffee_machine()
	visible = false

func uselast_pressed() -> void:
	if coffee_pouring_active or steam_active or GameManager.dialogue_menu_open or using_last_drink:
		return
	
	var last: InventoryItem = GameManager.PlayerInstance.inventory_latest
	if last == null: 
		var no_drink_info: Array[Dictionary] = [{"name":"", "message":GameManager.game_lang["coffee_last_none"]}]
		GameManager.create_dialogue(no_drink_info, false)
		return
	elif last.item_id != InventoryItem.ItemType.COFFEE:
		var no_drink_info: Array[Dictionary] = [{"name":"", "message":GameManager.game_lang["coffee_last_notcoffee"]}]
		GameManager.create_dialogue(no_drink_info, false)
		return
	
	restart_cup()
	using_last_drink = true
	update_coffee_state(last.item_detail)
	GameManager.PlayerInstance.inventory_remove_item()

func pan_direction(up: bool):
	$PanDown.visible = false
	$PanUp.visible = false
	liquid_effect.visible = false
	steam_effect.visible = false
	milk_jug.get_node("Liquid").visible = false
	var pos = Vector2(0, 0) if up else Vector2(0, -686)
	await get_tree().create_tween().tween_property(content_node, "position", pos, 0.2).finished

func pan_down_hover() -> void:
	if (tutorial_mode) and (not game_scene.tutorial_progression["third_fox_dialogue"]):
		return
	
	if (not GameManager.dialogue_menu_open):
		await pan_direction(false)
		$PanUp.visible = true
		milk_jug.get_node("Liquid").visible = true
	
	if (tutorial_mode):
		if (game_scene.tutorial_progression["third_fox_dialogue"]) and not (game_scene.tutorial_progression["first_pan_down"]):
			GameManager.create_dialogue([{"name":"", "message": GameManager.game_lang["tutorial_23"]}], false)
			game_scene.tutorial_progression["first_pan_down"] = true

func pan_up_hover() -> void:
	if (tutorial_mode) and (not game_scene.tutorial_progression["first_jug_move"]):
		return
	
	if (not GameManager.dialogue_menu_open):
		await pan_direction(true)
		$PanDown.visible = true
		liquid_effect.visible = true
		steam_effect.visible = true
	
		if (tutorial_mode) and (not game_scene.tutorial_progression["first_pan_up"]):
				var dr_dat: Array[Dictionary] = []
				for n in range(26, 30): dr_dat.append({"name":"", "message": GameManager.game_lang["tutorial_"+str(n)]})
				GameManager.create_dialogue(dr_dat, false)
				game_scene.tutorial_progression["first_pan_up"] = true

func milk_jug_clicked() -> void:
	if tutorial_mode and not (game_scene.tutorial_progression["first_bottle_pour"]):
		return
	
	if (not milk_bottle_pouring) and (not steam_active):
		change_selectable("milkjug")
		milk_jug_options.get_node("Use").visible = (not coffee_pouring_active) and (current_cup_type in [GameManager.CoffeeType.ESPRESSO,GameManager.CoffeeType.DOUBLE_ESPRESSO]) and milk_in_jug and (current_cup_in_deco == milk_in_deco)
		milk_jug_options.get_node("Discard").visible = milk_in_jug
		milk_jug_options.get_node("MoveUp").visible = milk_in_deco
		milk_jug_options.get_node("MoveDown").visible = not milk_in_deco

func milk_move_up() -> void:
	change_selectable("close")
	milk_in_deco = false
	
	if (tutorial_mode and not (game_scene.tutorial_progression["first_jug_move"])):
		GameManager.create_dialogue([{"name":"", "message": GameManager.game_lang["tutorial_25"]}], false)
		game_scene.tutorial_progression["first_jug_move"] = true
	
	await get_tree().create_tween().tween_property(milk_jug, "position", milk_jug_positons["up"], 0.2).finished
	milk_jug.get_node("MoveSound").play()

func milk_move_down() -> void:
	change_selectable("close")
	milk_in_deco = true
	
	await get_tree().create_tween().tween_property(milk_jug, "position", milk_jug_positons["down"], 0.2).finished
	milk_jug.get_node("MoveSound").play()

func milk_cancel():
	change_selectable("close")

func milk_carton_pressed() -> void:
	if tutorial_mode and not (game_scene.tutorial_progression["first_pan_down"]):
		return
	
	if (milk_in_deco) and (not milk_bottle_pouring):
		change_selectable("milkbottle")

func milkbottle_update_sprites(face_up:bool):
	if face_up:
		milk_bottle.get_node("MilkPourHigher").visible = false
		milk_bottle.get_node("MilkPourLower").visible = false
		milk_bottle.get_node("MilkHigher").visible = (milk_bottle_volume > 12)
		milk_bottle.get_node("MilkLower").visible = (milk_bottle_volume > 0)
	else:
		milk_bottle.get_node("MilkPourHigher").visible = (milk_bottle_volume > 12)
		milk_bottle.get_node("MilkPourLower").visible = (milk_bottle_volume > 0)
		milk_bottle.get_node("MilkHigher").visible = false
		milk_bottle.get_node("MilkLower").visible = false

func milkbottle_pour_pressed() -> void:
	milk_bottle_pouring = true
	milk_jug.get_node("MilkJug").disabled = true
	change_selectable("close")
	
	get_tree().create_tween().tween_property(milk_bottle, "position", Vector2(159, 3.8), 0.3)
	await get_tree().create_tween().tween_property(milk_bottle, "rotation_degrees", -92, 0.3).finished
	milk_jug.get_node("Liquid").emitting = true
	milkbottle_update_sprites(false)
	
	await get_tree().create_timer(3).timeout
	
	get_tree().create_tween().tween_property(milk_bottle, "position", Vector2(122.0, 36.0), 0.3)
	
	milk_jug.get_node("Liquid").emitting = false
	milk_bottle_pouring = false
	milk_in_jug = true
	milk_jug.get_node("Colouring").self_modulate = Color("#f5f5ff")
	milk_display.text = GameManager.game_lang["milk_froath"].replace("{0}", "0")
	milkbottle_update_sprites(false)
	
	await get_tree().create_tween().tween_property(milk_bottle, "rotation_degrees", 0, 0.3).finished
	milk_jug.get_node("MilkJug").disabled = false
	milkbottle_update_sprites(true)
	
	if (tutorial_mode and not game_scene.tutorial_progression["first_bottle_pour"]):
		GameManager.create_dialogue([{"name":"", "message": GameManager.game_lang["tutorial_24"]}], false)
		game_scene.tutorial_progression["first_bottle_pour"] = true

func milkbottle_cancel_pressed() -> void:
	change_selectable("close")

func milkjug_discard_pressed() -> void:
	restart_jug()
	change_selectable("close")

func milk_pour_pressed() -> void:
	milk_pouring = true
	milk_jug.get_node("MilkJug").disabled = true
	change_selectable("close")
	
	get_tree().create_tween().tween_property(milk_jug, "position", Vector2(516.0, 422.0), 0.3)
	await get_tree().create_tween().tween_property(milk_jug, "rotation_degrees", -60.0, 0.3).finished
	milk_jug.get_node("LiquidToCup").emitting = true

	await get_tree().create_timer(3).timeout
	milk_pouring = false
	milk_jug.get_node("LiquidToCup").emitting = false
	milk_jug.get_node("MilkJug").disabled = false
	
	if current_cup_type == GameManager.CoffeeType.ESPRESSO:
		if milk_steam_percent < 25:
			update_coffee_state(GameManager.CoffeeType.MACCHIATO)
		elif milk_steam_percent < 50:
			update_coffee_state(GameManager.CoffeeType.MINILATTE)
		elif milk_steam_percent < 75:
			update_coffee_state(GameManager.CoffeeType.CORTADO)
		else:
			update_coffee_state(GameManager.CoffeeType.FLATWHITE)
	
	elif current_cup_type == GameManager.CoffeeType.DOUBLE_ESPRESSO:
		if milk_steam_percent < 25:
			update_coffee_state(GameManager.CoffeeType.DOUBLE_MACCHIATO)
		elif milk_steam_percent < 50:
			update_coffee_state(GameManager.CoffeeType.LATTE)
		elif milk_steam_percent < 75:
			update_coffee_state(GameManager.CoffeeType.CAPPUCHINO)
		else:
			update_coffee_state(GameManager.CoffeeType.DRY)
	
	restart_jug()
	
	get_tree().create_tween().tween_property(milk_jug, "position", milk_jug_positons["up"], 0.3)
	await get_tree().create_tween().tween_property(milk_jug, "rotation_degrees", 0, 0.3).finished
	
	change_selectable("close")

func close_recipes() -> void:
	$RecipeBg.visible = false

func open_recipes() -> void:
	if (not GameManager.dialogue_menu_open):
		$RecipeBg.visible = true
