extends Window

@export var Geapgh: GraphEdit
@export var check_diretory: CheckBox
@export var check_ajust: CheckBox
@export var label_diretorio: Label

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


func _on_check_ajust_pressed() -> void:
	if check_ajust.button_pressed:
		Global.var_check_ajust = true
		
	else:
		Global.var_check_ajust = false


func _on_check_diretorio_pressed() -> void:
	if check_diretory.button_pressed:
		label_diretorio.hide()
		
	
	else:
		label_diretorio.show()
