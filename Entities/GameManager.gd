extends Node

var PlayerInstance: Player = null
var player_can_move: bool = true
var dialogue_menu_open: bool = false
var machine_menu_open: bool = false
var game_lang: Dictionary = {}

var Satisfaction: float = 50.0
var RunData: Dictionary = {
	"day": 1,
	"satisfaction": 50.0,
	"customers_served": 0,
	"cafe_inventory": {
		"coffee": 1000,
		"milk": 50,
	},
	"coffees_served": {
		CoffeeType.ESPRESSO: 0,
		CoffeeType.DOUBLE_ESPRESSO: 0,
		CoffeeType.MACCHIATO: 0,
		CoffeeType.MINILATTE: 0,
		CoffeeType.CORTADO: 0,
		CoffeeType.FLATWHITE: 0,
		CoffeeType.DOUBLE_MACCHIATO: 0,
		CoffeeType.LATTE: 0,
		CoffeeType.CAPPUCHINO: 0,
		CoffeeType.DRY: 0
	}
}

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

const CoffeeCodenames = ["none", "empty", "espresso", "double_espresso", "macchiato", "minilatte", "cortado", "flatwhite", "double_macchiato", "latte", "cappuchino", "dry" ]

func _ready() -> void:
	initalise_locale()

func initalise_locale():
	var csv_raw: String = FileAccess.open("res://Locale/localisation.csv", FileAccess.READ).get_as_text()
	for kv in csv_raw.split("\n"):
		var kv_spl = kv.split(":")
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
	await get_tree().create_timer(1).timeout
	dialogue_menu_open = false

var machine_inst = null
const machine_scene = preload("res://Scenes/CoffeeMachine/CoffeeMachine.tscn")

func open_coffee_machine():
	player_can_move = false
	machine_menu_open = true
	if machine_inst == null:
		machine_inst = machine_scene.instantiate()
		append_to_interface(machine_inst)
	else:
		machine_inst.visible = true

func close_coffee_machine():
	player_can_move = true
	machine_menu_open = false

func update_satisfaction(value: float):
	GameManager.RunData["satisfaction"] += value
	var scene: CafeGame = get_tree().current_scene
	scene.update_satisfaction()
