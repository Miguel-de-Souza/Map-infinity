extends Window

@export var Geapgh: GraphEdit

func _on_close_requested() -> void:
	hide()

func _on_option_grids_item_selected(index: int) -> void:
	if index == 0:
		Geapgh.grid_pattern = GraphEdit.GRID_PATTERN_LINES
		
	elif index == 1:
		Geapgh.grid_pattern = GraphEdit.GRID_PATTERN_DOTS


func _on_option_scroll_item_selected(index: int) -> void:
	if index == 0:
		Geapgh.panning_scheme = GraphEdit.SCROLL_ZOOMS
		
	elif index == 1:
		Geapgh.panning_scheme = GraphEdit.SCROLL_PANS


func _on_option_scroll_value_changed(value: float) -> void:
	Global.font_size_default = int(value)


func _on_menu_button_config_pressed() -> void:
	popup()
