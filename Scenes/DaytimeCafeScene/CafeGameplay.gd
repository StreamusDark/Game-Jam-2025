extends Node2D
class_name CafeGame

@export var table_nodes: Node2D
@export var entities_node: Node2D

@export var timer_display: Label
@onready var time_of_day_lighting = $TimeOfDayLighting

const customer_scene = preload("res://Entities/Customer/Customer.tscn")
var customer_queue: Array[Customer] = []
var customer_count = 0
var occupied_seats: Dictionary[int, Customer]

func _ready() -> void:
	for n in table_nodes.get_child_count():
		occupied_seats[n] = null
	
	$TimeOfDayLighting.color = Color("8fb6ff81")
	start_day()

func _process(delta: float) -> void:
	var time_passed = int(480 - $DaylightTime.time_left)
	var mins = str(int(time_passed / 60) + 9).lpad(2, "0")
	var sec = str(int(time_passed % 60)).lpad(2, "0")
	timer_display.text = str(mins, ":", sec)

func new_customer():
	if customer_count > table_nodes.get_child_count():
		print("Too many customers")
		return
	
	var inst = customer_scene.instantiate()
	entities_node.add_child(inst)
	inst.init(Customer.CUSTOMER_TYPE.FOX)
	customer_count += 1

func do_light_cycle():
	time_of_day_lighting.color = Color("8fb6ff81")
	# 9am -> 1pm
	await get_tree().create_tween().tween_property(time_of_day_lighting, "color", Color("000000"), (60 * 4)).finished
	
	# 1pm -> 5pm
	await get_tree().create_tween().tween_property(time_of_day_lighting, "color", Color("c4be7e"), (60 * 4)).finished

func start_day():
	$DaylightTime.start()
	do_light_cycle()
	
	# Template code
	await get_tree().create_timer(6).timeout
	new_customer()
