class_name HealthComponent extends Node

const health_ui_scene = preload("res://Scenes/ForestPrototype/HealthUI.tscn")

func _ready() -> void:
	var health_ui_instance = health_ui_scene.instantiate()
	GameManager.append_to_interface(health_ui_instance)

@export var health = 3
