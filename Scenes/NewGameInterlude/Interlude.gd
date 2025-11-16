extends ColorRect
class_name Interlude

const Defaults: Dictionary = {
		"day": 1,
		"satisfaction": 50.0,
		"customers_served": 0,
		"cafe_inventory": {
			"coffee": 100,
			"milk": 50,
		},
		"coffees_served": {
			GameManager.CoffeeType.ESPRESSO: 0,
			GameManager.CoffeeType.DOUBLE_ESPRESSO: 0,
			GameManager.CoffeeType.MACCHIATO: 0,
			GameManager.CoffeeType.MINILATTE: 0,
			GameManager.CoffeeType.CORTADO: 0,
			GameManager.CoffeeType.FLATWHITE: 0,
			GameManager.CoffeeType.DOUBLE_MACCHIATO: 0,
			GameManager.CoffeeType.LATTE: 0,
			GameManager.CoffeeType.CAPPUCHINO: 0,
			GameManager.CoffeeType.DRY: 0
		}
	}

func _ready() -> void:
	$Tut.visible = GameManager.true_new_game
	
	# Reset Run Data
	GameManager.RunData = Defaults.duplicate(true)
	
	if GameManager.true_new_game:
		for btn in [$Tut/VBoxContainer/Yes, $Tut/VBoxContainer/No]:
			btn.get_node("Button").connect("mouse_entered", Callable(self, "hover_enter").bind(btn))
			btn.get_node("Button").connect("mouse_exited", Callable(self, "hover_exit").bind(btn))
			btn.get_node("Hover").visible = false
	else:
		start_game()

func start_game():
	GameManager.true_new_game = false
	get_tree().change_scene_to_file("res://Scenes/DaytimeCafeScene/CafeScene.tscn")

func hover_enter(btn): btn.get_node("Hover").visible = true
func hover_exit(btn): btn.get_node("Hover").visible = false

func start_with_tutorial() -> void:
	GameManager.RunData["day"] = 0
	start_game()
