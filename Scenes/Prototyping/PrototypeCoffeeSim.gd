extends Control

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
var current_cup_type = "none"
var current_cup_selected = false

var coffee_pouring_active = false
var steam_active = false

@export var milk_jug: Button
@export var milk_jug_options: VBoxContainer
@export var milk_display: Label
var milk_in_deco = true
var milk_in_jug = false
var milk_selected = false
var milk_steam_percent: float = 0.0

func _ready() -> void:
	current_cup.position = Vector2(341.0, 532.4)
	milk_jug.position = Vector2(770.0, 1137.0)
	milk_display.text = GameManager.game_lang["milk_none"]
	
	content_node.position = Vector2(0,0)
	$PanUp.visible = false
	restart()

func _process(delta: float) -> void:
	if coffee_pouring_active:
		beans_that_move.position = Vector2(randf_range(-46.2, -46.6), randf_range(-84.2, -84.8))

func restart():
	current_cup_options.visible = false
	liquid_button.get_node("Hover").visible = false
	steam_button.get_node("Hover").visible = false
	cups_button.get_node("Hover").visible = false
	current_cup.get_node("CoffeeTypeContainer").visible = false
	current_cup.get_node("Hover").visible = false
	
	liquid_button.disabled = false
	liquid_effect.emitting = false
	coffee_pouring_active = false
	current_cup_options.visible = false
	current_cup_selected = false
	
	update_coffee_state("none")

func update_coffee_state(coffee_id):
	current_cup_type = coffee_id
	if coffee_id == "none":
		current_cup.visible = false
		return
	
	current_cup.visible = true
	cup_type_display.text = GameManager.game_lang["coffee_name_" + current_cup_type]
	current_cup.get_node("CoffeeColouring").self_modulate = Beverage.coffee_colouring[current_cup_type]

func liquid_button_pressed() -> void:
	if current_cup_selected or milk_selected or GameManager.dialogue_menu_open:
		return
	if current_cup_type == "none" and (not GameManager.dialogue_menu_open):
		var no_drink_info: Array[Dictionary] = [{"name":"", "message":GameManager.game_lang["coffee_needscup"]}]
		GameManager.create_dialogue(no_drink_info, false)
		return
	elif current_cup_type == "double_espresso" and (not GameManager.dialogue_menu_open):
		var too_much: Array[Dictionary] = [{"name":"", "message":GameManager.game_lang["coffee_toomuch"]}]
		GameManager.create_dialogue(too_much, false)
		return
	
	liquid_button.disabled = true
	liquid_effect.emitting = true
	coffee_pouring_active = true
	await get_tree().create_timer(8).timeout
	coffee_pouring_active = false
	liquid_effect.emitting = false
	liquid_button.disabled = false
	
	if current_cup_type == "empty":
		update_coffee_state("espresso")
	elif current_cup_type == "espresso":
		update_coffee_state("double_espresso")

func steam_button_down() -> void:
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
	steam_active = false
	steam_effect.emitting = false

func cup_button_pressed() -> void:
	if current_cup_type == "none" and GameManager.dialogue_menu_open == false:
		update_coffee_state("empty")

func current_coffee_pressed() -> void:
	if (not current_cup_selected) and (not coffee_pouring_active) and (not milk_selected):
		current_cup.get_node("Hover").visible = true
		current_cup.get_node("CoffeeTypeContainer").visible = true
		current_cup_options.visible = true
		current_cup_selected = true

func current_coffee_hover_enter() -> void: 
	if (not current_cup_selected):
		current_cup.get_node("CoffeeTypeContainer").visible = true
		current_cup.get_node("Hover").visible = true
	
func current_coffee_hover_exited() -> void: 
	if (not current_cup_selected):
		current_cup.get_node("CoffeeTypeContainer").visible = false
		current_cup.get_node("Hover").visible = false

func serve_drink_pressed() -> void:
	var coffee_value = {
		"type": "coffee",
		"detail": current_cup_type
	}
	GameManager.PlayerInstance.inventory_add_item(coffee_value)
	restart()
	close_machine()

func discard_drink_pressed() -> void:
	restart()

func cancel_drink_pressed() -> void:
	current_cup.get_node("CoffeeTypeContainer").visible = false
	current_cup.get_node("Hover").visible = false
	current_cup_options.visible = false
	current_cup_selected = false

func close_machine() -> void:
	GameManager.close_coffee_machine()
	visible = false

func uselast_pressed() -> void:
	if coffee_pouring_active or steam_active:
		return
	
	var last: Beverage = GameManager.PlayerInstance.beverages_latest
	if last == null: 
		var no_drink_info: Array[Dictionary] = [{"name":"", "message":GameManager.game_lang["coffee_last_none"]}]
		GameManager.create_dialogue(no_drink_info, false)
		return
	elif last.beverage_id != "Coffee":
		var no_drink_info: Array[Dictionary] = [{"name":"", "message":GameManager.game_lang["coffee_last_notcoffee"]}]
		GameManager.create_dialogue(no_drink_info, false)
		return
	
	restart()
	update_coffee_state(last.beverage_detail)
	GameManager.PlayerInstance.inventory_remove_item()

func pan_direction(up: bool):
	if (not GameManager.dialogue_menu_open):
		$PanDown.visible = false
		$PanUp.visible = false
		liquid_effect.visible = false
		steam_effect.visible = false
		var pos = Vector2(0, 0) if up else Vector2(0, -686)
		await get_tree().create_tween().tween_property(content_node, "position", pos, 0.2).finished

func pan_down_hover() -> void:
	await pan_direction(false)
	$PanUp.visible = true

func pan_up_hover() -> void:
	await pan_direction(true)
	$PanDown.visible = true
	liquid_effect.visible = true
	steam_effect.visible = true

func liquid_button_hover_enter() -> void: liquid_button.get_node("Hover").visible = true
func liquid_button_hover_exit() -> void: liquid_button.get_node("Hover").visible = false
func steam_button_hover_enter() -> void: steam_button.get_node("Hover").visible = true
func steam_button_hover_exit() -> void: steam_button.get_node("Hover").visible = false
func cups_button_hover_enter() -> void: cups_button.get_node("Hover").visible = true
func cups_button_hover_exited() -> void: cups_button.get_node("Hover").visible = false
func close_button_hover_enter() -> void: $Exit.get_node("Hover").visible = true
func close_button_hover_exited() -> void: $Exit.get_node("Hover").visible = false

func milk_jug_clicked() -> void:
	if (not current_cup_selected) and (not coffee_pouring_active) and (not milk_selected):
		#milk_jug.get_node("Hover").visible = true
		milk_jug_options.get_node("Use").visible = (current_cup_type in ["espresso","double_espresso"]) and milk_in_jug and (current_cup_in_deco == milk_in_deco)
		milk_jug_options.get_node("MoveUp").visible = milk_in_deco
		milk_jug_options.get_node("MoveDown").visible = not milk_in_deco
		milk_jug_options.visible = true
		milk_selected = true
		milk_jug.get_node("Name").visible = true

func milk_move_up() -> void:
	milk_cancel()
	milk_in_deco = false
	
	get_tree().create_tween().tween_property(milk_jug, "position", Vector2(544.0, 418.0), 0.2)

func milk_move_down() -> void:
	milk_cancel()
	milk_in_deco = true
	
	get_tree().create_tween().tween_property(milk_jug, "position", Vector2(770.0, 1137.0), 0.2)

func milk_cancel() -> void:
	milk_jug.get_node("Name").visible = false
	#milk_jug.get_node("Hover").visible = false
	milk_jug_options.visible = false
	milk_selected = false

func milk_carton_pressed() -> void:
	if (not milk_selected) and (not milk_in_jug) and (milk_in_deco):
		milk_in_jug = true
		milk_display.text = GameManager.game_lang["milk_froath"].replace("{0}", "0")

func milk_pour_pressed() -> void:
	if current_cup_type == "espresso":
		if milk_steam_percent < 25:
			update_coffee_state("macchiato")
		elif milk_steam_percent in range(25,50):
			update_coffee_state("minilatte")
		elif milk_steam_percent in range(50,75):
			update_coffee_state("cortado")
		else:
			update_coffee_state("flatwhite")
	
	elif current_cup_type == "double_espresso":
		if milk_steam_percent < 25:
			update_coffee_state("double_macchiato")
		elif milk_steam_percent in range(25,50):
			update_coffee_state("latte")
		elif milk_steam_percent in range(50,75):
			update_coffee_state("cappuchino")
		else:
			update_coffee_state("dry")
	
	milk_in_jug = false
	milk_steam_percent = 0.0
	milk_display.text = GameManager.game_lang["milk_none"]
