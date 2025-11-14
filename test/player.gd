extends Node2D

var rng = RandomNumberGenerator.new()
var pos = 0
var direction = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rng.randomize()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	position.y = position.y + direction
	pos = position.y
	if pos < 1:
		direction = direction * -1
	elif pos > 600:
		direction = direction * -1
