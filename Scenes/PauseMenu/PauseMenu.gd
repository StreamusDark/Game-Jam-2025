extends Control

@export var is_night: bool = false

func _ready() -> void:
	for btn in [$Continue, $Quit]:
		btn.get_node("Button").connect("mouse_entered", Callable(self, "hover_enter").bind(btn))
		btn.get_node("Button").connect("mouse_exited", Callable(self, "hover_exit").bind(btn))
		btn.get_node("Hover").visible = false
	
	visible = false
	init()

func hover_enter(btn): btn.get_node("Hover").visible = true
func hover_exit(btn): btn.get_node("Hover").visible = false

func init():
	var naming = {false: "day", true: "night"}
	var texture_name = "interface_button_" + naming[is_night] + ".png"
	var button_texture: Texture2D = load("res://Scenes/" + texture_name)
	
	$Pause.play(naming[is_night], 1)
	$Continue.texture = button_texture
	$Quit.texture = button_texture
	$Objective.texture = button_texture
	
	$Objective/VBoxContainer/Description.text = GameManager.game_lang["pause_" + naming[is_night]]

func pause_game():
	visible = true
	get_tree().paused = true

func continue_pressed() -> void:
	visible = false
	get_tree().paused = false

func quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/TitleScreen/TitleScreen.tscn")

func music_changed(value_changed: bool) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db($MusicSlider.value))

func sfx_changed(value_changed: bool) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SoundEffects"), linear_to_db($SoundsSlider.value))
