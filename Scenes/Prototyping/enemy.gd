extends CharacterBody2D
@onready var character_sprite = $Sprite

var max_speed = 200.0
const accel = 1000.0

@export var player: CharacterBody2D

func _process(delta):
	movement_process(delta)

func movement_process(delta: float):
	var direction = Vector2.ZERO
	direction = (player.global_position - global_position).normalized()
	
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
	
