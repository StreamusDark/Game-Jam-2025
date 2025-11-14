extends AnimatedSprite2D
class_name Beverage
@export var beverage_id = "Coffee"
var beverage_detail

const coffee_colouring = {
	"empty": Color("#c6c7e3"),
	"espresso": Color("#826248"),
	"double_espresso": Color("#301702"),
	"macchiato": Color("8d6a4eff"),
	"minilatte": Color("a98263ff"),
	"cortado": Color("c09979ff"),
	"flatwhite": Color("dbbca3ff"),
	"double_macchiato": Color("522b06ff"),
	"latte": Color("844910ff"),
	"cappuchino": Color("b3661bff"),
	"dry": Color("e58936ff"),
}

func read_detail(detail: String):
	beverage_detail = detail
	if beverage_id == "Coffee": coffee_detail(detail)

func set_all_offset(off:Vector2):
	for n in get_children():
		n.offset = off
	offset = off

func coffee_detail(detail: String):
	get_node("Colouring").self_modulate = coffee_colouring[detail]
