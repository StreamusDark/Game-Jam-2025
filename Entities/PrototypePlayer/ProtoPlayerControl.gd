class_name Player
extends CharacterBody2D
const max_speed = 225.0
const accel = 1000.0

@onready var character_sprite = $Sprite
@onready var coffee_sprite = $Coffee

func _ready() -> void:
	coffee_sprite.play("default")

func _process(delta):
	movement_process(delta)

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
	coffee_sprite.rotation_degrees = (velocity.x / max_speed) * -2
	move_and_slide()
	
	$"../../Interface/Container/Debug/Pos".text = "pos: " + str(position)
	$"../../Interface/Container/Debug/Vel".text = "vel: " + str(velocity)
