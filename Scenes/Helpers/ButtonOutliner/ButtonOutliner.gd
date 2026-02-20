extends Node

@export var elements_to_outline: Array[Node]

func _ready() -> void:
	for btn in elements_to_outline:
		if btn == null: continue               # Empty/non-existent element
		
		var button_base: Node = null           # Reference to the Button node of interest
		var hover_base: Node  = null           # Reference to the "Hover" node
		
		# Check if the node itself is a button or if it has a "Button" child
		if (btn is Button) or (btn is TextureButton):
			button_base = btn
		else:
			button_base = btn.get_node_or_null("Button")
		
		if button_base != null:
			button_base.connect("mouse_entered", Callable(self, "hover_enter").bind(btn))
			button_base.connect("mouse_exited", Callable(self, "hover_exit").bind(btn))
		
		hover_base = btn.get_node("Hover")
		hover_base.visible = false
		
		var name_node: Node = btn.get_node_or_null("Name")
		if name_node:
			name_node.visible = false

func hover_enter(btn): btn.get_node("Hover").visible = true
func hover_exit(btn): btn.get_node("Hover").visible = false
