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

const dia_scene = preload("res://Entities/DialogueMenu/DialogueMenu.tscn")

func create_dialogue(dr_data: Array[Dictionary], disable_walk = true):
	GameManager.dialogue_menu_open = true
	var dia_inst = dia_scene.instantiate()
	var curr_scene = get_tree().current_scene
	
	for n in curr_scene.get_children():
		if n is CanvasLayer:
			for m in n.get_children():
				if m is Control:
					m.add_child(dia_inst)
	
	dia_inst.init(dr_data, disable_walk)

func destroy_dialogue(obj: NinePatchRect):
	obj.queue_free()
	await get_tree().create_timer(1).timeout
	dialogue_menu_open = false
