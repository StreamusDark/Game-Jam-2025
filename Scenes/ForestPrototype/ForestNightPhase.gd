class_name NightManager extends Node2D

@export_category("Node References")
@export var health_counter: Label
@export var collector_ui_labels: Array[Label]

enum ITEMS {
	MILK,
	CARROTS,
	COFFEE_BEANS,
	STRAWBERRIES,
}

var collected_items = {
	ITEMS.MILK : 0,
	ITEMS.CARROTS : 0,
	ITEMS.COFFEE_BEANS : 0,
	ITEMS.STRAWBERRIES : 0,
}


@export_category("Other Stuff")
@export var max_health = 3

@onready var health = max_health:
	set(value):
		health = value
		
		health_counter.text = str(health)
		# health has changed, so we need to update the health ui here
		
		if health < 0:
			pass # DIE

func damage_player(knockback_dir: Vector2):
	health -= 1
	GameManager.PlayerInstance.velocity = knockback_dir * 500
	# knockback
	

func add_item(item: ITEMS):
	collected_items[item] += 1
	collector_ui_labels[item].text = str(collected_items[item])
