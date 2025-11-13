class_name Player
extends CharacterBody2D
var max_speed = 225.0
const accel = 1000.0

@onready var character_sprite = $Sprite

const coffee_scene = preload("res://Entities/PrototypePlayer/Coffee.tscn")
var stacked_beverages: Array[Node] = []

func _process(delta):
	movement_process(delta)

func inventory_add_item():
	var new_child: AnimatedSprite2D = coffee_scene.instantiate()
	new_child.play("default")
	stacked_beverages.append(new_child)
	new_child.offset.y = -47.0 - (20 * len(stacked_beverages))
	add_child(new_child)
	max_speed = 225 - (35 * (len(stacked_beverages) - 1))

func inventory_remove_item():
	var latest_idx = len(stacked_beverages) - 1
	var latest_item = stacked_beverages[latest_idx]
	latest_item.queue_free()
	stacked_beverages.remove_at(latest_idx)

func movement_process(delta: float):
	var direction = Vector2.ZERO
	if GameManager.player_can_move:
		direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Movement Animation
	if direction.x != 0:
		var face_dir = "left" if (direction.x < 0) else "right"
		character_sprite.play(face_dir)
		
	elif direction.y != 0:
		var face_dir = "back" if (direction.y < 0) else "front"
		character_sprite.play(face_dir)
		
	else:
		character_sprite.stop()
		character_sprite.frame = 0
	
	velocity = velocity.move_toward(direction * max_speed, accel * delta)
	move_and_slide()
	
	var bev_idx = 0
	for bev in stacked_beverages:
		bev.rotation_degrees = (velocity.x / max_speed) * -(2.2 + bev_idx)
		bev_idx += 1
	
	$"../../Interface/Container/Debug/Pos".text = "pos: " + str(position)
	$"../../Interface/Container/Debug/Vel".text = "vel: " + str(velocity)
