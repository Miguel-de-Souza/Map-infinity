extends Label

@export var Graph: GraphEdit

func _process(_delta: float) -> void:
	text = str("Scroll Offset: ",Graph.scroll_offset,
	"\nContagem de Nodes: ", Graph.get_child_count() - 1
	)
	
