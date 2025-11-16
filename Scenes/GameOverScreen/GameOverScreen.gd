extends Control

@onready var stats_tables: HBoxContainer = $Stats/KeyVal
var small_label: LabelSettings = load("res://Scenes/GameOverScreen/SmallText.tres")

@onready var left_tab: VBoxContainer = $Stats/KeyVal/Type
@onready var right_tab: VBoxContainer = $Stats/KeyVal/Values

var is_game_over = false

func _ready() -> void:
	for btn in [$Restart, $Quit]:
		btn.get_node("Button").connect("mouse_entered", Callable(self, "hover_enter").bind(btn))
		btn.get_node("Button").connect("mouse_exited", Callable(self, "hover_exit").bind(btn))
		btn.get_node("Hover").visible = false
	
	visible = false

func hover_enter(btn): btn.get_node("Hover").visible = true
func hover_exit(btn): btn.get_node("Hover").visible = false

func init(is_night: bool):
	visible = false
	var naming = {false: "day", true: "night"}
	var texture_name = "interface_button_" + naming[is_night] + ".png"
	var button_texture: Texture2D = load("res://Scenes/" + texture_name)
	
	$Stats/KeyVal/Values/day.text = str(GameManager.RunData["day"])
	$Stats/KeyVal/Values/customers.text = "\n" + str(GameManager.RunData["customers_served"])
	
	for coffee in GameManager.CoffeeCodenames.slice(2):
		var coffee_lang = "- " + GameManager.game_lang["coffee_name_" + coffee]
		
		var name_label: Label = Label.new()
		name_label.label_settings = small_label
		name_label.text = coffee_lang
		
		var val_label: Label = Label.new()
		var val_index = GameManager.CoffeeCodenames.find(coffee)
		val_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		val_label.label_settings = small_label
		val_label.text = str(GameManager.RunData["coffees_served"][val_index])
		
		left_tab.add_child(name_label)
		right_tab.add_child(val_label)
	
	$GameOver.frame = int(is_night)
	$Stats.texture = button_texture
	$Restart.texture = button_texture
	$Quit.texture = button_texture
	
	$AnimationPlayer.play("GameOver")
	$AnimationPlayer.stop()
	
	start_animation()

func start_animation():
	visible = true
	is_game_over = true
	Engine.time_scale = 1
	$AnimationPlayer.play("FadeBlack")
	await get_tree().create_tween().tween_property(Engine, "time_scale", 0.1, 1.5).finished
	GameManager.player_can_move = false
	get_tree().paused = true
	Engine.time_scale = 1
	$AnimationPlayer.play("GameOver")

func quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/TitleScreen/TitleScreen.tscn")

func newrun_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/NewGameInterlude/Interlude.tscn")
