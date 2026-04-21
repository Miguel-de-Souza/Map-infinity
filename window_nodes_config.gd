extends Window

@export var graphnod: GraphNode

func _process(_delta: float) -> void:
	if Global.selected_nodes > 1:
		hide()


func _ready() -> void:
	if graphnod == null:
		return
		
	else:
		hide()
		graphnod.node_selected.connect(_node_selected)
		graphnod.node_deselected.connect(_node_deselected)
	
func _node_selected():
	if Global.selected_nodes <= 1:
		position = Vector2(200,70)
		show()
	
func _node_deselected():
	hide()

func _on_close_requested() -> void:
	hide()
