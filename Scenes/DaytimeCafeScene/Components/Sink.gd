extends WorldInteractable

func on_interact():
	GameManager.PlayerInstance.inventory_remove_item()
