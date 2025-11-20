extends Control

@onready var sky = $Sky
@onready var cloud_control = $CloudControl
@onready var clouds = $CloudControl/Clouds
@onready var clouds2 = $CloudControl/Clouds2
@onready var foreground_day = $ForegroundDay
@onready var foreground_night = $ForegroundNight
@onready var black_overlay = $BlackOverlay

var day_night_progression: float = 0:
	set(value):
		day_night_progression = value
		sky.color = lerp(Color("52c0de"), Color("150e2b"), day_night_progression / 100)
		foreground_day.self_modulate = lerp(Color("ffffff"), Color("ffffff00"), day_night_progression / 100)
		foreground_night.self_modulate = lerp(Color("ffffff00"), Color("ffffff"), day_night_progression / 100)
		clouds.self_modulate = lerp(Color("fff"), Color("372b3d"), day_night_progression / 100)
		clouds2.self_modulate = lerp(Color("fff"), Color("372b3d"), day_night_progression / 100)

func _ready() -> void:
	get_tree().paused = false
	black_overlay.visible = true
	black_overlay.self_modulate = Color("ffffff")
	
	day_night_progression = 0
	$AnimationPlayer.play("introduction")
	$AnimationPlayer.stop()
	repeat_clouds()
	
	for btn in [$Buttons/Play, $Buttons/Quit]:
		btn.get_node("Button").connect("mouse_entered", Callable(self, "hover_enter").bind(btn))
		btn.get_node("Button").connect("mouse_exited", Callable(self, "hover_exit").bind(btn))
		btn.get_node("Hover").visible = false
	
	await get_tree().create_tween().tween_property(black_overlay, "self_modulate", Color("ffffff00"), 1).finished
	black_overlay.visible = false
	await GameManager.wait_seconds(1)
	$AnimationPlayer.play("introduction")
	
	await GameManager.wait_seconds(1)
	repeat_loop_bg()

func hover_enter(btn): btn.get_node("Hover").visible = true
func hover_exit(btn): btn.get_node("Hover").visible = false

func repeat_loop_bg():
	await get_tree().create_tween().tween_property(self, "day_night_progression", 100, 8).finished
	await GameManager.wait_seconds(1)
	await get_tree().create_tween().tween_property(self, "day_night_progression", 0, 8).finished
	await GameManager.wait_seconds(1)
	repeat_loop_bg()

func repeat_clouds():
	await get_tree().create_tween().tween_property(cloud_control, "position", Vector2(0, 0), 10).finished
	cloud_control.position = Vector2(-1280, 0)
	repeat_clouds()

func dip_to_black():
	black_overlay.visible = true
	await get_tree().create_tween().tween_property(black_overlay, "self_modulate", Color("ffffff"), 0.25).finished

func quit_game() -> void:
	await dip_to_black()
	get_tree().quit()

func start_game() -> void:
	await dip_to_black()
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://Scenes/NewGameInterlude/Interlude.tscn")
