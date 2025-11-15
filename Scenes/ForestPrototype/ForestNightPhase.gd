class_name NightManager extends Node2D

@export_category("Node References")
@export var collector_ui_labels: Array[Label]

@export var hearts: Array[Sprite2D]
@export var game_over: Control

var near_cafe_hole = false

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
		
		# health has changed, so we need to update the health ui here
		var idx = 0
		for heart in hearts:
			if idx+1 <= health:
				heart.visible = true
			else:
				heart.visible = false
			
			idx += 1
		
		if health <= 0:
			GameManager.player_can_move = false
			game_over.visible = true


func damage_player(knockback_dir: Vector2):
	health -= 1
	
	# knockback
	GameManager.PlayerInstance.velocity = knockback_dir * 500
	

func add_item(item: ITEMS):
	collected_items[item] += 1
	collector_ui_labels[item].text = str(collected_items[item])


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_confirm") and near_cafe_hole:
		print("save the items that have been collected and return to day phase")


func _on_cafe_hole_body_entered(body: Node2D) -> void:
	if body is Player:
		near_cafe_hole = true

func _on_cafe_hole_body_exited(body: Node2D) -> void:
	if body is Player:
		near_cafe_hole = false


func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/ForestPrototype/PrototypeForest.tscn")

func _on_quit_pressed() -> void:
	pass # shrug
