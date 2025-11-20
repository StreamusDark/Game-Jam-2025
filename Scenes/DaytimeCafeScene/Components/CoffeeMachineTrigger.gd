extends WorldInteractable

@onready var game_scene: CafeGame = get_tree().current_scene

func on_interact():
	if (GameManager.RunData["day"] == 0) :
		if (not game_scene.tutorial_progression["first_fox_dialogue"]):
			return
		elif (not game_scene.tutorial_progression["first_machine_open"]):
			GameManager.open_coffee_machine()
			game_scene.tutorial_progress(2)
			return
		elif ((game_scene.tutorial_progression["first_serving_correct"]) and not (game_scene.tutorial_progression["second_serving_correct"])):
			GameManager.open_coffee_machine()
			game_scene.tutorial_progress(8)
			return
		elif ((game_scene.tutorial_progression["third_fox_dialogue"]) and not (game_scene.tutorial_progression["third_serving_correct"])):
			GameManager.open_coffee_machine()
			game_scene.tutorial_progress(11)
			return
	
	GameManager.open_coffee_machine()
