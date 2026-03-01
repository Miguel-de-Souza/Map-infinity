extends Button

@export var node_pai: Node
@export var valor: float

func _on_pressed() -> void:
	if node_pai is SpinBox:
		node_pai.value = valor
