extends ColorRect

@export var is_night: bool = false

func _ready() -> void:
	for btn in [$VBoxContainer/Continue, $VBoxContainer/SkipNight, $VBoxContainer/Quit]:
		btn.get_node("Button").connect("mouse_entered", Callable(self, "hover_enter").bind(btn))
		btn.get_node("Button").connect("mouse_exited", Callable(self, "hover_exit").bind(btn))
		btn.get_node("Hover").visible = false
	
	var naming = {false: "day", true: "night"}
	var texture_name = "interface_button_" + naming[is_night] + ".png"
	var button_texture: Texture2D = load("res://Scenes/" + texture_name)
	
	$VBoxContainer/Continue.texture = button_texture
	$VBoxContainer/SkipNight.texture = button_texture
	$VBoxContainer/Quit.texture = button_texture
	$Title.play(naming[is_night])
	
	visible = false
	$Title.visible = false
	$VBoxContainer.visible = false

func hover_enter(btn): btn.get_node("Hover").visible = true
func hover_exit(btn): btn.get_node("Hover").visible = false

func init():
	get_tree().paused = true
	color = Color("00000000")
	visible = true
	$AnimationPlayer.play("fade")

func anim_finished(anim_name: StringName) -> void:
	$Title.visible = true
	$VBoxContainer.visible = true
	$VBoxContainer/SkipNight.visible = (not is_night)

func continue_pressed() -> void:
	get_tree().paused = false
	
	if is_night:
		GameManager.RunData["day"] += 1
		get_tree().change_scene_to_file("res://Scenes/DaytimeCafeScene/CafeScene.tscn")
	else:
		get_tree().change_scene_to_file("res://Scenes/NighttimeForestScene/NighttimeForestScene.tscn")

func quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/TitleScreen/TitleScreen.tscn")

func skipnight_pressed() -> void:
	get_tree().paused = false
	GameManager.RunData["day"] += 1
	get_tree().change_scene_to_file("res://Scenes/DaytimeCafeScene/CafeScene.tscn")
