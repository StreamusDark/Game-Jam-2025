extends Node

var PlayerInstance: Player = null
var player_can_move: bool = true
var dialogue_menu_open: bool = false
var machine_menu_open: bool = false
var game_lang: Dictionary = {}
var true_new_game = true

var Satisfaction: float = 50.0
var RunData: Dictionary = Interlude.Defaults.duplicate(true)

enum CoffeeType {
	NONE,
	EMPTY,
	ESPRESSO,
	DOUBLE_ESPRESSO,
	MACCHIATO,
	MINILATTE,
	CORTADO,
	FLATWHITE,
	DOUBLE_MACCHIATO,
	LATTE,
	CAPPUCHINO,
	DRY,
}

enum Difficulies {
	EASY,
	MEDIUM,
	HARD,
	EXTREME
}

var CurrentDifficulty = Difficulies.EASY

const CoffeeDifficultyOptions = {
	Difficulies.EASY: [ 
		GameManager.CoffeeType.ESPRESSO,
		GameManager.CoffeeType.DOUBLE_ESPRESSO,
		GameManager.CoffeeType.MACCHIATO,
		GameManager.CoffeeType.MINILATTE,
		GameManager.CoffeeType.DOUBLE_MACCHIATO,
		GameManager.CoffeeType.LATTE
	],
	Difficulies.MEDIUM: [ 
		GameManager.CoffeeType.ESPRESSO,
		GameManager.CoffeeType.DOUBLE_ESPRESSO,
		GameManager.CoffeeType.MACCHIATO,
		GameManager.CoffeeType.MINILATTE,
		GameManager.CoffeeType.CORTADO,
		GameManager.CoffeeType.FLATWHITE,
		GameManager.CoffeeType.DOUBLE_MACCHIATO,
		GameManager.CoffeeType.LATTE,
		GameManager.CoffeeType.CAPPUCHINO
	],
	Difficulies.HARD: [ 
		GameManager.CoffeeType.MACCHIATO,
		GameManager.CoffeeType.MINILATTE,
		GameManager.CoffeeType.CORTADO,
		GameManager.CoffeeType.FLATWHITE,
		GameManager.CoffeeType.DOUBLE_MACCHIATO,
		GameManager.CoffeeType.LATTE,
		GameManager.CoffeeType.CAPPUCHINO,
		GameManager.CoffeeType.DRY
	],
	Difficulies.EXTREME: [ 
		GameManager.CoffeeType.MACCHIATO,
		GameManager.CoffeeType.MINILATTE,
		GameManager.CoffeeType.CORTADO,
		GameManager.CoffeeType.FLATWHITE,
		GameManager.CoffeeType.DOUBLE_MACCHIATO,
		GameManager.CoffeeType.LATTE,
		GameManager.CoffeeType.CAPPUCHINO,
		GameManager.CoffeeType.DRY
	]
}

const CoffeeCodenames = ["none", "empty", "espresso", "double_espresso", "macchiato", "minilatte", "cortado", "flatwhite", "double_macchiato", "latte", "cappuchino", "dry" ]

func _ready() -> void:
	initalise_locale()

func wait_seconds(s: float):
	var st := Engine.get_main_loop() as SceneTree
	if not st: 
		return
	var timer := st.create_timer(s)
	await timer.timeout

func initalise_locale():
	var csv_raw: String = FileAccess.open("res://Locale/localisation.csv", FileAccess.READ).get_as_text()
	for kv in csv_raw.split("\n"):
		var kv_spl = kv.split(":", true, 1)
		game_lang[kv_spl[0]] = kv_spl[1].replace("\\n", "\n")

func append_to_interface(node):
	var curr_scene = get_tree().current_scene
	for n in curr_scene.get_children():
		if n is CanvasLayer:
			for m in n.get_children():
				if m is Control:
					m.add_child(node)

const dia_scene = preload("res://Entities/DialogueMenu/DialogueMenu.tscn")

func create_dialogue(dr_data: Array[Dictionary], disable_walk = true):
	dialogue_menu_open = true
	var dia_inst = dia_scene.instantiate()
	append_to_interface(dia_inst)
	dia_inst.init(dr_data, disable_walk)

func destroy_dialogue(obj: NinePatchRect):
	obj.queue_free()
	await GameManager.wait_seconds(1)
	dialogue_menu_open = false

var machine_inst = null

func open_coffee_machine():
	player_can_move = false
	machine_menu_open = true
	if machine_inst == null:
		machine_inst = get_tree().current_scene.get_node("Interface/Container/CoffeeMachineSim")
	
	machine_inst.visible = true

func close_coffee_machine():
	player_can_move = true
	machine_menu_open = false

func update_satisfaction(value: float):
	var scene: CafeGame = get_tree().current_scene
	if (not scene.day_active): return # In case we reach zero after day has ended
	
	GameManager.RunData["satisfaction"] += value
	GameManager.RunData["satisfaction"] = clamp(GameManager.RunData["satisfaction"], 0, 100)
	scene.update_satisfaction()
