extends WorldInteractable

@onready var game_scene = get_tree().current_scene

func wait_until(condition: Callable) -> void:
	while not condition.call():
		await get_tree().process_frame

func on_interact():
	if (GameManager.RunData["day"] == 0):
		if game_scene.tutorial_progression["first_text"] and not game_scene.tutorial_progression["first_fox_dialogue"]:
			game_scene.tutorial_progress(1)
			return
		elif game_scene.tutorial_progression["first_serving_correct"] and not game_scene.tutorial_progression["second_fox_dialogue"]:
			game_scene.tutorial_progress(7)
			return
		elif game_scene.tutorial_progression["second_serving_correct"] and not game_scene.tutorial_progression["third_fox_dialogue"]:
			game_scene.tutorial_progress(10)
			return
	
	var queue = (get_tree().current_scene as CafeGame).customer_queue
	if len(queue) == 0: return
	
	var latest: Customer = queue[0]
	
	var dialogue_data: Array[Dictionary] = [{
		"name": latest.customer_name, 
		"message": GameManager.game_lang["fox_speak_0"].replace("{0}", latest.drink_request_formatted)
	}]
	
	GameManager.create_dialogue(dialogue_data, true)
	await wait_until(func(): return not GameManager.dialogue_menu_open)
	latest.pick_seat()
	await get_tree().create_timer(0.5).timeout
	await wait_until(func(): return not GameManager.dialogue_menu_open)
	
	var updated_queue = (get_tree().current_scene as CafeGame).customer_queue
	for n in len(updated_queue):
		var queue_offset = 114.0 + (27 * n)
		move_customer_position(updated_queue[n], queue_offset)

func move_customer_position(cust: Customer, pos: float):
	cust.customer_sprites.play("left")
	await get_tree().create_tween().tween_property(cust, "position", Vector2(pos, cust.position.y), 0.5).finished
	cust.customer_sprites.play("sit-left")
