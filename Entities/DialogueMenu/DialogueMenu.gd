extends NinePatchRect

var dialogue_progress = 0
var is_complete = false

@onready var content_menu: RichTextLabel = $DialogueText
var current_sentence: String = ""
var current_sentence_filtered: String = ""

@onready var charname_label: Label = $NamePlate/CharacterName

@onready var voice_sound: AudioStreamPlayer = $AudioStreamPlayer
var voice_playing = false
var random_gen = RandomNumberGenerator.new()

@onready var letter_timer: Timer = $LetterTimer
@onready var pause_timer: Timer = $PauseTimer

var dialogue_data = []
var disable_walk = true

func _ready() -> void:
	GameManager.dialogue_menu_open = true
	position = Vector2(20, 519)
	random_gen.randomize()

func init(dr_dat: Array[Dictionary], no_walk = true):
	disable_walk = no_walk
	dialogue_data = dr_dat
	
	if disable_walk: GameManager.player_can_move = false
	dialogue_progress = 0
	update_dialogue(dialogue_data[0])

func _input(event: InputEvent) -> void:
	if is_complete:
		if event is InputEventKey:
			if event.is_action("ui_confirm"):
				dialogue_progress += 1
				if dialogue_progress >= len(dialogue_data):
					if disable_walk: GameManager.player_can_move = true
					GameManager.destroy_dialogue(self)
				else:
					update_dialogue(dialogue_data[dialogue_progress])

func update_dialogue(message_data: Dictionary) -> void:
	is_complete = false
	
	charname_label.text = message_data["name"]
	var message = message_data["message"]
	
	var reg = RegEx.new()
	reg.compile(r"\[.*?\]")
	current_sentence = message.strip_edges()
	current_sentence_filtered = reg.sub(message, "", true)
	
	content_menu.text = current_sentence
	content_menu.visible_characters = 0
	
	voice_playing = true
	voice_sound.play(0)
	letter_timer.start()

func letter_timer_timeout() -> void:
	var chr = current_sentence_filtered[content_menu.visible_characters]
	if chr in ['!', '.', '?']:
		voice_playing = false
		await get_tree().create_timer(0.5).timeout
		voice_playing = true
		voice_sound.play(0)
	
	content_menu.visible_characters += 1
	
	if content_menu.visible_ratio >= 1.0:
		voice_playing = false
		is_complete = true
		letter_timer.stop()

func voicesound_finished() -> void:
	if voice_playing:
		voice_sound.pitch_scale = random_gen.randf_range(0.96, 1.05)
		voice_sound.play(0)
