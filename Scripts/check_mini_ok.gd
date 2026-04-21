extends CheckBox

@export var node: GraphNode

func _on_pressed() -> void:
	if button_pressed:
		node.Minimum_R = true
		
	else:
		node.Minimum_R = false

func _process(_delta: float) -> void:
	if node.Minimum_R:
		node.size = Vector2(0,0)
		node.resizable = false
		
	else:
		node.resizable = true
