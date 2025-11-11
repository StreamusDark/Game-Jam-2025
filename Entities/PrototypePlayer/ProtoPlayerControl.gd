extends CharacterBody2D
const max_speed = 500.0
const accel = 2200

func _process(delta):
	movement_process(delta)

func movement_process(delta: float):
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = velocity.move_toward(direction * max_speed, accel * delta)
	move_and_slide()
