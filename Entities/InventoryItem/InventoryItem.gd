extends AnimatedSprite2D
class_name InventoryItem

@export var item_id: ItemType
@export var item_detail: Variant = ""

enum ItemType {
	COFFEE
}

const coffee_colouring = {
	GameManager.CoffeeType.NONE: Color("#fff"),
	GameManager.CoffeeType.EMPTY: Color("#c6c7e3"),
	GameManager.CoffeeType.ESPRESSO: Color("#826248"),
	GameManager.CoffeeType.DOUBLE_ESPRESSO: Color("#301702"),
	GameManager.CoffeeType.MACCHIATO: Color("8d6a4eff"),
	GameManager.CoffeeType.MINILATTE: Color("a98263ff"),
	GameManager.CoffeeType.CORTADO: Color("c09979ff"),
	GameManager.CoffeeType.FLATWHITE: Color("dbbca3ff"),
	GameManager.CoffeeType.DOUBLE_MACCHIATO: Color("522b06ff"),
	GameManager.CoffeeType.LATTE: Color("844910ff"),
	GameManager.CoffeeType.CAPPUCHINO: Color("b3661bff"),
	GameManager.CoffeeType.DRY: Color("e58936ff"),
}

func read_detail(detail: Variant):
	item_detail = detail
	if item_id == ItemType.COFFEE: 
		if type_string(typeof(detail)) == "String":
			detail = GameManager.CoffeeCodenames.find(detail)
		coffee_detail(detail)

func set_all_offset(off:Vector2):
	for n in get_children():
		if n is Node2D:
			n.offset = off
	offset = off

func coffee_detail(detail: GameManager.CoffeeType):
	get_node("Colouring").self_modulate = coffee_colouring[detail]
