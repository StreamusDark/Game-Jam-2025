extends Node

var player_can_move: bool = true
var dialogue_menu_open: bool = false
var game_lang: Dictionary = {}

func _ready() -> void:
	initalise_locale()

func initalise_locale():
	var csv_raw: String = FileAccess.open("res://Locale/localisation.csv", FileAccess.READ).get_as_text()
	for kv in csv_raw.split("\n"):
		var kv_spl = kv.split(":")
		game_lang[kv_spl[0]] = kv_spl[1]

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

const machine_scene = preload("res://Scenes/Prototyping/PrototypeCoffeeSim.tscn")

func open_coffee_machine():
	dialogue_menu_open = true
	player_can_move = false
	var cof_inst = machine_scene.instantiate()
	append_to_interface(cof_inst)
