extends CheckBox

@export var node: GraphNode

func _on_pressed() -> void:
	on_button_press()

func _process(_delta: float) -> void:
	verification_pls()

func on_button_press():
	if button_pressed:
		node.Minimum_R = true
		Global.var_mini_check_ajust = true
		
	else:
		node.Minimum_R = false
		Global.var_mini_check_ajust = false

func verification_pls():
	if node.Minimum_R:
		node.size = Vector2(0,0)
		node.resizable = false
		
	else:
		node.resizable = true
	
