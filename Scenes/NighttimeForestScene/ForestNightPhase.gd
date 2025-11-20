class_name NightManager extends Node2D

@export_category("Node References")
@export var collector_ui_labels: Array[Label]

@export var hearts: Array[Sprite2D]
@export var game_over: Control
@export var pause_screen: Control
@export var black_screen: ColorRect

const enemy_scene = preload("res://Scenes/NighttimeForestScene/Enemy.tscn")

var near_cafe_hole = false

enum ITEMS {
	MILK,
	COFFEE_BEANS,
}

var collected_items = {
	ITEMS.MILK : 0,
	ITEMS.COFFEE_BEANS : 0
}


@export_category("Other Stuff")
@export var max_health = 3

@onready var health = max_health:
	set(value):
		health = value
		
		# health has changed, so we need to update the health ui here
		var idx = 0
		for heart in hearts:
			if idx+1 <= health:
				heart.visible = true
			else:
				heart.visible = false
			
			idx += 1
		
		if health <= 0 and not game_over.is_game_over:
			game_over.init(true)

func _ready() -> void:
	var day_num: int = GameManager.RunData["day"]
	$Interface/Container/Night/Num.text = str(day_num)
	
	black_screen.self_modulate = Color("fff")
	black_screen.visible = true
	var day_cnt = black_screen.get_node("Cnt")
	
	if GameManager.RunData["day"] == 0:
		day_cnt.get_node("Control/Alignment/Old").text = ""
		day_cnt.get_node("Control/Alignment/New").text = "0"
	else:
		day_cnt.get_node("Control/Alignment/Old").text = str(GameManager.RunData["day"] - 1)
		day_cnt.get_node("Control/Alignment/New").text = str(GameManager.RunData["day"])
	
	day_cnt.get_node("Control/Alignment").position = Vector2(0,0)
	day_cnt.modulate = Color("ffffff00")
	await get_tree().create_tween().tween_property(black_screen, "self_modulate", Color("ffffffac"), 0.65).finished
	await get_tree().create_tween().tween_property(day_cnt, "modulate", Color("fff"), 0.35).finished
	await GameManager.wait_seconds(0.7)
	await get_tree().create_tween().tween_property(day_cnt.get_node("Control/Alignment"), "position", Vector2(0,-149), 0.35).finished
	await GameManager.wait_seconds(1)
	await get_tree().create_tween().tween_property(black_screen, "self_modulate", Color("ffffff00"), 0.65).finished
	black_screen.visible = false
	
	if GameManager.RunData["day"] == 0:
		GameManager.create_dialogue([
			{"name":"", "message": GameManager.game_lang["tutorial_night_none"]}
		], false)
	
	var enemy_count = ceil(float(day_num) / 2)
	for n in enemy_count:
		$SpawnOrigin/EnemySpawnSpinner.position = Vector2( randi_range(580.0, 920.0), 0 )
		$SpawnOrigin.rotation_degrees = randi_range(-1, 360)
		
		var enm: Enemy = enemy_scene.instantiate()
		add_child(enm)
		enm.position = $SpawnOrigin/EnemySpawnSpinner.global_position

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		pause_screen.pause_game()

func damage_player(knockback_dir: Vector2):
	health -= 1
	GameManager.PlayerInstance.velocity = knockback_dir * 500 # knockback

func add_item(item: ITEMS):
	collected_items[item] += 1
	collector_ui_labels[item].text = str(collected_items[item])

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_confirm") and near_cafe_hole:
		GameManager.RunData["cafe_inventory"]["coffee"] += collected_items[ITEMS.COFFEE_BEANS]
		GameManager.RunData["cafe_inventory"]["milk"] += collected_items[ITEMS.MILK]
		$Interface/Container/SectionComplete.init()

func _on_cafe_hole_body_entered(body: Node2D) -> void:
	if body is Player:
		near_cafe_hole = true

func _on_cafe_hole_body_exited(body: Node2D) -> void:
	if body is Player:
		near_cafe_hole = false
