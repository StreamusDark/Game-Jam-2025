class_name Player
extends CharacterBody2D

@export var player_sprite: AnimatedSprite2D
@export var max_speed = 130.0
const Acceleration = 1000.0

var inventory_data: Array[Node] = []
var inventory_latest: Node = null

@export var alt_mode = false
var animation_prefix = ""

const coffee_scene = preload("res://Entities/InventoryItem/CoffeeItem/CoffeeItem.tscn")

func _ready() -> void:
	GameManager.PlayerInstance = self
	
	if alt_mode:
		animation_prefix = "alt-"

func _process(delta: float):
	var direction = Vector2.ZERO
	if GameManager.player_can_move:
		direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Movement Animation
	if direction.x != 0:
		var face_dir = "left" if (direction.x < 0) else "right"
		player_sprite.play(animation_prefix + face_dir)
		
	elif direction.y != 0:
		var face_dir = "back" if (direction.y < 0) else "front"
		player_sprite.play(animation_prefix + face_dir)
		
	else:
		player_sprite.stop()
		player_sprite.frame = 0
	
	velocity = velocity.move_toward(direction * max_speed, Acceleration * delta)
	move_and_slide()
	
	var item_index = 0
	for item in inventory_data:
		item.rotation_degrees = (velocity.x / max_speed) * -(2.2 + item_index)
		item_index += 1

func inventory_add_item(new_item_data: Dictionary):
	if new_item_data["type"] == "coffee":
		var new_child: AnimatedSprite2D = coffee_scene.instantiate()
		new_child.play("default")
		inventory_data.append(new_child)
		new_child.set_all_offset(Vector2(0, -47.0 - (20 * len(inventory_data))))
		new_child.read_detail(new_item_data["detail"])
		inventory_latest = new_child
		add_child(new_child)
	
	max_speed = 130 - (25 * (len(inventory_data) - 1))

func inventory_remove_item():
	var latest_idx = len(inventory_data) - 1
	if latest_idx == -1: return
	
	var latest_item = inventory_data[latest_idx]
	latest_item.queue_free()
	inventory_data.remove_at(latest_idx)
	
	if latest_idx - 1 != -1:
		inventory_latest = inventory_data[latest_idx-1]
	else:
		inventory_latest = null
	
	max_speed = 130 - (25 * (len(inventory_data) - 1))
