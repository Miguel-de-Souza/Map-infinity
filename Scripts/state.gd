extends Control

@export var node_bloc: GraphNode

func _ready() -> void:
	node_bloc.node_selected.connect(_on_node_selected)
	node_bloc.node_deselected.connect(_on_node_deselected)
	node_bloc.position_offset_changed.connect(_on_position_offset_changed)
	node_bloc.slot_sizes_changed.connect(_on_slot_sizes_changed)

func _on_node_selected():
	Global.selected_nodes += 1
	
func _on_node_deselected():
	Global.selected_nodes -= 1
	
func _on_position_offset_changed():
	Global.alteraction()
	
func _on_slot_sizes_changed():
	Global.alteraction()

#Sistema de Multi Seleção
func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not node_bloc.selected:
			var shift_pressed = Input.is_key_pressed(KEY_SHIFT)
			
			if not shift_pressed:
				node_bloc.get_parent().clear_selection()
			
			node_bloc.selected = true
			
#Sistema para apagar Node
func _process(_delta: float) -> void:
		
	if Input.is_action_pressed("ui_text_delete") and node_bloc.selected:
		if not Global.not_atalho:
			delete_node()

func delete_node():
	Global.alteraction()
	Global.selected_nodes -= 1
	node_bloc.queue_free()
