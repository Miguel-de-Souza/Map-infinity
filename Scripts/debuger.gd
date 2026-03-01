extends Label

@export var Graph: GraphEdit
var mem = OS.get_memory_info()

func _process(_delta: float) -> void:
	text = str("Scroll Offset: ",Graph.scroll_offset,
	"\nContagem de Nodes: ", Graph.get_child_count() - 1,
	"\nFPS: ", Engine.get_frames_per_second(),
	)
