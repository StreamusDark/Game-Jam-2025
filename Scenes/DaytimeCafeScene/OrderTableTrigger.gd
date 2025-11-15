extends WorldInteractable

func wait_until(condition: Callable) -> void:
	while not condition.call():
		await get_tree().process_frame

func on_interact():
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
	
	var updated_queue = (get_tree().current_scene as CafeGame).customer_queue
	for n in len(updated_queue):
		var cust: Customer = updated_queue[n]
		var queue_offset = 114.0 + (27 * n)
		
		cust.customer_sprites.play("left")
		await get_tree().create_tween().tween_property(cust, "position", Vector2(queue_offset, cust.position.y), 0.5).finished
		cust.customer_sprites.play("sit-left")
