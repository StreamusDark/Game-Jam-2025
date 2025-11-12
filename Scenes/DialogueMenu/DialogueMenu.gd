extends NinePatchRect

@onready var dialogue_text_node = $DialogueText
@onready var charname_label = $NamePlate/CharacterName
@onready var pop_sound = $AudioStreamPlayer

var dialogue_data = [
	{
		"type": "message",
		"name": "Character Name",
		"message": "[wave]Woah![/wave] Who the [rainbow]heck[/rainbow] are [shake rate=20 level=10]you?![/shake]\nMy... [i][b]clone[/b][/i]?"
	},
	{
		"type": "message",
		"name": "Character Name",
		"message": "...[wave]Who knows?[/wave]\nMaybe I'm you from the future!"
	},
]

func _ready() -> void:
	initalise_dialogue()

func initalise_dialogue():
	for text_dict in dialogue_data:
		match text_dict.get("type"):
			"message": await run_message(text_dict)
	
	GameManager.dialogue_menu_open = false
	queue_free()

func run_message(message_dict: Dictionary):
	dialogue_text_node.visible_characters = 0
	charname_label.text = message_dict.get("name")
	
	var msg = message_dict.get("message")
	dialogue_text_node.text = msg
	
	for i in msg:
		await get_tree().create_timer(0.02).timeout
		dialogue_text_node.visible_characters += 1
	
	
	return
