class_name Enemy extends CharacterBody2D

@export var max_speed = 200.0
const accel = 1000.0

@export_category("Scene Stuff")
@export var night_manager: NightManager

@export_category("Node References")
@export var damage_box: Area2D
@export var attack_cooldown: Timer
@export var kicked_cooldown: Timer
@export var character_sprite: AnimatedSprite2D

var on_screen = false

func _process(delta):
	movement_process(delta)
	attempt_attack() # kinda inefficent to do every frame but whatever
	


func movement_process(delta: float):
	var direction = Vector2.ZERO
	
	var prefix = ""
	
	if attack_on_cooldown or is_kicked:
		prefix = "sit-alt-"
	else:
		direction = (GameManager.PlayerInstance.global_position - global_position).normalized() # moves towards player
		prefix = "alt-"
	
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
	
	var speed = max_speed
	# half the speed of the enemy if it's not on screen
	if not on_screen:
		speed = speed/2
	
	velocity = velocity.move_toward(direction * speed, accel * delta)
	velocity = velocity.clamp(Vector2(-200, -200), Vector2(200, 200))
	
	move_and_slide()

var last_face_dir = ""

var attack_on_cooldown = false
var is_kicked = false

func attempt_attack():
	if not damage_box.overlaps_body(GameManager.PlayerInstance): # damage box not overlapping player
		return
	if attack_on_cooldown:
		return
	
	# can attack
	var knockback_dir = (GameManager.PlayerInstance.global_position - global_position).normalized() 
	get_tree().current_scene.damage_player(knockback_dir)
	
	attack_cooldown.start()
	attack_on_cooldown = true


func get_kicked():
	var knockback_dir = (global_position - GameManager.PlayerInstance.global_position).normalized() 
	velocity = knockback_dir * 500
	kicked_cooldown.start()
	is_kicked = true


func _on_attack_cooldown_timeout() -> void:
	attack_on_cooldown = false


func _on_screen_notifier_screen_entered() -> void:
	on_screen = true

func _on_screen_notifier_screen_exited() -> void:
	on_screen = false


func _on_kicked_cooldown_timeout() -> void:
	is_kicked = false
