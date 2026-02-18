extends Label

@export var Graph: GraphEdit

func _process(_delta: float) -> void:
	text = str(Graph.scroll_offset)
