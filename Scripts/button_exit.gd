extends Button

@export var node_Graph: GraphNode

func _on_pressed() -> void:
	if node_Graph == null:
		return
	
	Global.alteraction()
	node_Graph.queue_free()
