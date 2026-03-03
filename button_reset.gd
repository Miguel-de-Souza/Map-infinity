extends Button

@export var node_pai: Node
@export var valor: float

func _ready() -> void:
	if node_pai is SpinBox:
		disabled = true
		node_pai.value_changed.connect(_on_mac_value_changed)

func _on_pressed() -> void:
	if node_pai == null:
		return
	
	if node_pai is SpinBox:
		
		node_pai.value = valor
		disabled = true
		
func _on_mac_value_changed(_value: float):
	disabled = false
