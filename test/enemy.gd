extends Node2D
var enemy_pos_x
var enemy_pos_y
var player_pos_x
var player_pos_y
var health = 3
var invunrable = true
var wait = 0
var trap_1 = Node2D.new()
var trap_2 = Node2D.new()
var trap_3 = Node2D.new()
var trap_4 = Node2D.new()
var base_speed = 1
var speed
var stuck = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enemy_pos_x = $Enemy.position.x
	enemy_pos_y = $Enemy.position.y
	player_pos_x = $Player.position.x
	player_pos_y = $Player.position.y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if stuck == true:
		speed = base_speed * 0.5
	else:
		speed = base_speed
	player_pos_x = $Player.position.x
	player_pos_y = $Player.position.y
	if player_pos_x > enemy_pos_x:
		$Enemy.position.x = $Enemy.position.x +speed #enemy movement
		enemy_pos_x = $Enemy.position.x
	elif player_pos_x < enemy_pos_x:
		$Enemy.position.x = $Enemy.position.x -speed
		enemy_pos_x = $Enemy.position.x
	if player_pos_y > enemy_pos_y:
		$Enemy.position.y = $Enemy.position.y +speed
		enemy_pos_y = $Enemy.position.y
	elif player_pos_y < enemy_pos_y:
		$Enemy.position.y = $Enemy.position.y -speed
		enemy_pos_y = $Enemy.position.y
	
	if invunrable == false:
		if $Enemy.position == $Player.position: #losing health
			health = health -1
			if health == 0:
				get_tree().change_scene_to_file("res://EnemyMove.tscn")
			invunrable = true
	elif invunrable == true:
		if wait < 180: #adjust later
			wait = wait +1
		else:
			invunrable = false
			wait = 0
			
	if $Enemy.position == trap_1.position:
		stuck = true
	else:
		stuck = false
	
func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_1:
			add_child(trap_1)
			trap_1.position.x = 50
			trap_1.position.y = 50
			trap_1.add_child(Sprite2D.new())
		elif event.keycode == KEY_2:
			add_child(trap_2)
			trap_1.add_child(Sprite2D.new())
		elif event.keycode == KEY_3:
			add_child(trap_3)
			trap_1.add_child(Sprite2D.new())
		elif event.keycode == KEY_4:
			add_child(trap_4)
			trap_1.add_child(Sprite2D.new())
