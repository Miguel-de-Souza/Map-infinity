extends Window

@export var Geapgh: GraphEdit
@export var check_diretory: CheckBox
@export var check_ajust: CheckBox
@export var label_diretorio: Label
@export var show_debug: CheckBox
@export var debug_label: Label
@export var option_grid: OptionButton
@export var option_scroll: OptionButton
@export var option_camp: SpinBox
@export var option_title: SpinBox
@export var type_window: OptionButton
@export var mode_option: OptionButton
@export var min_op: SpinBox
@export var max_op: SpinBox
@export var option_BG: HSlider
@export var option_Grides: HSlider

var cor_tema : Color = Color.BLACK

func _ready():
	load_settings()

func save_settings():
	var config = ConfigFile.new()
	
	config.set_value("graph", "grid_pattern", Geapgh.grid_pattern)
	config.set_value("graph", "panning_scheme", Geapgh.panning_scheme)
	config.set_value("graph", "zoom_min", Geapgh.zoom_min)
	config.set_value("graph", "zoom_max", Geapgh.zoom_max)
	config.set_value("theme", "grid_major_alpha", get_values_ma)
	config.set_value("theme", "grid_minor_alpha", get_values_mi)
	config.set_value("theme", "option_bg", option_BG.value)
	config.set_value("theme", "option_grids", option_Grides.value)
	

	config.set_value("ui", "check_ajust", check_ajust.button_pressed)
	config.set_value("ui", "check_diretory", check_diretory.button_pressed)
	config.set_value("ui", "show_debug", show_debug.button_pressed)
	config.set_value("ui", "font_size_default", Global.font_size_default)
	
	config.set_value("ui", "option_grid", option_grid.selected)
	config.set_value("ui", "option_scroll", option_scroll.selected)
	config.set_value("ui", "type_window", type_window.selected)
	config.set_value("ui", "mode_option", mode_option.selected)
	
	config.set_value("ui", "option_camp", option_camp.value)
	config.set_value("ui", "option_title", option_title.value)
	config.set_value("ui", "min_op", min_op.value)
	config.set_value("ui", "max_op", max_op.value)
	

	config.save("user://settings.cfg")

func load_settings():
	var config = ConfigFile.new()
	
	if config.load("user://settings.cfg") != OK:
		return
	
	Geapgh.grid_pattern = config.get_value("graph", "grid_pattern", GraphEdit.GRID_PATTERN_LINES)
	Geapgh.panning_scheme = config.get_value("graph", "panning_scheme", GraphEdit.SCROLL_ZOOMS)
	Geapgh.zoom_min = config.get_value("graph", "zoom_min", 0.1)
	Geapgh.zoom_max = config.get_value("graph", "zoom_max", 2.0)
	

	check_ajust.button_pressed = config.get_value("ui", "check_ajust", false)
	check_diretory.button_pressed = config.get_value("ui", "check_diretory", false)
	show_debug.button_pressed = config.get_value("ui", "show_debug", false)
	Global.font_size_default = config.get_value("ui", "font_size_default", 16)
	
	option_grid.selected = config.get_value("ui", "option_grid", 0)
	option_scroll.selected = config.get_value("ui", "option_scroll", 0)
	type_window.selected = config.get_value("ui", "type_window", 0)
	mode_option.selected = config.get_value("ui", "mode_option", 0)
	
	option_camp.value = config.get_value("ui", "option_camp", 12)
	option_title.value = config.get_value("ui", "option_title", 16)
	min_op.value = config.get_value("ui", "min_op", 0.1)
	max_op.value = config.get_value("ui", "max_op", 2.0)
	
	get_values_ma = config.get_value("theme", "grid_major_alpha", 51)
	get_values_mi = config.get_value("theme", "grid_minor_alpha", 13)

	option_BG.value = config.get_value("theme", "option_bg", 0)
	option_Grides.value = config.get_value("theme", "option_grids", 0)

	tema(option_BG.value)
	verification_theme()

	if show_debug.button_pressed:
		debug_label.visible = true
		
	else:
		debug_label.visible = false
	
	_on_type_window_item_selected(type_window.selected)

func _on_close_requested() -> void:
	hide()

func _on_option_grids_item_selected(index: int) -> void:
	if index == 0:
		Geapgh.grid_pattern = GraphEdit.GRID_PATTERN_LINES
		
	elif index == 1:
		Geapgh.grid_pattern = GraphEdit.GRID_PATTERN_DOTS
		
	save_settings()


func _on_option_scroll_item_selected(index: int) -> void:
	if index == 0:
		Geapgh.panning_scheme = GraphEdit.SCROLL_ZOOMS
		
	elif index == 1:
		Geapgh.panning_scheme = GraphEdit.SCROLL_PANS
		
	save_settings()


func _on_option_scroll_value_changed(value: float) -> void:
	Global.font_size_default = int(value)
	save_settings()


func _on_menu_button_config_pressed() -> void:
	popup()


func _on_check_ajust_pressed() -> void:
	Global.var_check_ajust = check_ajust.button_pressed
	save_settings()

func _on_check_diretorio_pressed() -> void:
	if check_diretory.button_pressed:
		label_diretorio.hide()
		
	
	else:
		label_diretorio.show()
		
	save_settings()


func _on_check_debug_pressed() -> void:
	if show_debug.button_pressed:
		debug_label.show()
		
	
	else:
		debug_label.hide()

	save_settings()

func _on_spin_min_value_changed(value: float) -> void:
	Geapgh.zoom_min = (value / 100)
	save_settings()

func _on_spin_max_value_changed(value: float) -> void:
	Geapgh.zoom_max = (value / 100)
	save_settings()


func _on_option_size_title_value_changed(value: float) -> void:
	Global.font_size_title_default = int(value)
	save_settings()


func _on_type_window_item_selected(index: int) -> void:
		
	if index == 0:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		
	save_settings()

var cor_for_theme: int
func tema(intensy: float):
	var style = Geapgh.get_theme_stylebox("panel")
	if style == null:
		return

	var new_stylebox_normal = style.duplicate()
	
	cor_tema.v = intensy
	new_stylebox_normal.bg_color = cor_tema

	Geapgh.remove_theme_stylebox_override("panel")
	Geapgh.add_theme_stylebox_override("panel", new_stylebox_normal)
	
	verification_theme()
	save_settings()


func verification_theme():
	if cor_tema.v > 0.5:
		cor_for_theme = 33
		Geapgh.add_theme_color_override("grid_major", Color.from_rgba8(cor_for_theme, cor_for_theme, cor_for_theme, get_values_ma))
		Geapgh.add_theme_color_override("grid_minor", Color.from_rgba8(cor_for_theme, cor_for_theme, cor_for_theme, get_values_mi))
		
	else:
		cor_for_theme = 255
		Geapgh.add_theme_color_override("grid_major", Color.from_rgba8(cor_for_theme, cor_for_theme, cor_for_theme, get_values_ma))
		Geapgh.add_theme_color_override("grid_minor", Color.from_rgba8(cor_for_theme, cor_for_theme, cor_for_theme, get_values_mi))


var get_values_ma : int = 51
var get_values_mi : int = 13

func _on_option_grid_value_changed(value: float) -> void:
	var cor_ma = Color.from_rgba8(cor_for_theme, cor_for_theme, cor_for_theme, 51)
	cor_ma.a8 = int(value + 51)
	
	var cor_mi = Color.from_rgba8(cor_for_theme, cor_for_theme, cor_for_theme, 13)
	cor_mi.a8 = int(value + 13)
	
	verification_theme()

	get_values_ma = int(value + 51)
	get_values_mi = int(value + 13)
	save_settings()


func _on_reset_themes_pressed() -> void:
	option_BG.value = 0.17682926829268
	option_Grides.value = 0
	
	Geapgh.remove_theme_stylebox_override("panel")
	Geapgh.remove_theme_color_override("grid_major")
	Geapgh.remove_theme_color_override("grid_minor")
	
	save_settings()

func _on_option_bg_value_changed(value: float) -> void:
	tema(value)
	print("value do slide ",value)
	save_settings()
