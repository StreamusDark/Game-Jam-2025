@tool
extends Area2D

@export_category("Shared Variables")
@export var item_textures: Array[Texture2D]

@export_category("Instance Variables")
@export var item_type: NightManager.ITEMS:
	set(value):
		item_type = value
		sprite.texture = item_textures[item_type]

@export var collected = false:
	set(value):
		collected = value
		
		if collected == true:
			modulate = Color(0.42, 0.42, 0.42, 1.0)
		else:
			modulate = Color(1.0, 1.0, 1.0, 1.0)

@export_category("Node References")
@export var sprite: Sprite2D

var player_inzone = false
@onready var night_manager: NightManager = get_tree().current_scene

func _process(_delta: float) -> void:
	if not collected:
		if player_inzone:
			if Input.is_action_just_pressed("ui_confirm"):
				collected = true
				night_manager.add_item(item_type)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_inzone = true

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_inzone = false
