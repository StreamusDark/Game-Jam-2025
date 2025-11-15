class_name Player
extends CharacterBody2D
var max_speed = 225.0
const accel = 1000.0

@onready var character_sprite = $Sprite

const coffee_scene = preload("res://Entities/PrototypeBeverage/Coffee.tscn")
var beverages_data: Array[Node] = []
var beverages_latest: Node = null
@export var alt_animations = false

func _ready() -> void:
	GameManager.PlayerInstance = self

func _process(delta):
	movement_process(delta)

func inventory_add_item(new_bev_dat: Dictionary):
	if new_bev_dat["type"] == "coffee":
		var new_child: AnimatedSprite2D = coffee_scene.instantiate()
		new_child.play("default")
		beverages_data.append(new_child)
		new_child.set_all_offset(Vector2(0, -47.0 - (20 * len(beverages_data))))
		new_child.read_detail(new_bev_dat["detail"])
		beverages_latest = new_child
		add_child(new_child)
	
	max_speed = 225 - (35 * (len(beverages_data) - 1))

func inventory_remove_item():
	var latest_idx = len(beverages_data) - 1
	if latest_idx == -1: return
	
	var latest_item = beverages_data[latest_idx]
	latest_item.queue_free()
	beverages_data.remove_at(latest_idx)
	
	if latest_idx - 1 != -1:
		beverages_latest = beverages_data[latest_idx-1]
	else:
		beverages_latest = null
	
	max_speed = 225 - (35 * (len(beverages_data) - 1))

func movement_process(delta: float):
	var direction = Vector2.ZERO
	if GameManager.player_can_move:
		direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	var suffix = ""
	if alt_animations:
		suffix = "alt-"
	
	# Movement Animation
	if direction.x != 0:
		var face_dir = "left" if (direction.x < 0) else "right"
		character_sprite.play(suffix + face_dir)
		
	elif direction.y != 0:
		var face_dir = "back" if (direction.y < 0) else "front"
		character_sprite.play(suffix + face_dir)
		
	else:
		character_sprite.stop()
		character_sprite.frame = 0
	
	velocity = velocity.move_toward(direction * max_speed, accel * delta)
	move_and_slide()
	
	var bev_idx = 0
	for bev in beverages_data:
		bev.rotation_degrees = (velocity.x / max_speed) * -(2.2 + bev_idx)
		bev_idx += 1
	
