extends CharacterBody2D

var max_speed = 140.0
const accel = 1000.0

@export_category("Scene Stuff")
@export var night_manager: NightManager
@export var player: CharacterBody2D

@export_category("Node References")
@export var damage_box: Area2D
@export var attack_cooldown: Timer
@export var character_sprite: AnimatedSprite2D

func _process(delta):
	movement_process(delta)
	attempt_attack() # kinda inefficent to do every frame but whatever
	


func movement_process(delta: float):
	var direction = Vector2.ZERO
	
	var prefix = ""
	
	if attack_on_cooldown:
		prefix = "sit-"
	else:
		direction = (player.global_position - global_position).normalized() # moves towards player
		prefix = "run-"
	
	# Movement Animation
	if (direction.x < -0.6) or (direction.x > 0.6):
		var face_dir = "left" if (direction.x < 0) else "right"
		character_sprite.play(prefix + face_dir)
		last_face_dir = face_dir
		
	elif direction.y != 0:
		var face_dir = "back" if (direction.y < 0) else "front"
		character_sprite.play(prefix + face_dir)
		last_face_dir = face_dir
		
	else:
		character_sprite.play(prefix + last_face_dir)
	
	
	velocity = velocity.move_toward(direction * max_speed, accel * delta)
	velocity = velocity.clamp(Vector2(-200, -200), Vector2(200, 200))
	
	move_and_slide()

var last_face_dir = ""

var attack_on_cooldown = false

func attempt_attack():
	
	if not damage_box.overlaps_body(player): # damage box not overlapping player
		return
	if attack_on_cooldown:
		return
	
	# can attack
	var knockback_dir = (player.global_position - global_position).normalized() 
	night_manager.damage_player(knockback_dir)
	
	attack_cooldown.start()
	attack_on_cooldown = true


func _on_attack_cooldown_timeout() -> void:
	attack_on_cooldown = false
