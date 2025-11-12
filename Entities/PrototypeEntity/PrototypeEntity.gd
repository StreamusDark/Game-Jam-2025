extends Area2D

var player_inzone = false

const Dialogue: Array[Dictionary] = [
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

func _process(delta: float) -> void:
	if player_inzone and not GameManager.dialogue_menu_open:
		if Input.is_action_just_pressed("ui_confirm"):
			GameManager.create_dialogue(Dialogue, true)

func body_entered(body: Node2D) -> void:
	if body is Player:
		player_inzone = true

func body_exited(body: Node2D) -> void:
	if body is Player:
		player_inzone = false
