extends GraphNode

@export var url: LineEdit
@export var size_fonts: SpinBox

var new_stylebox = get_theme_stylebox("panel").duplicate()
var new_stylebox_focus = get_theme_stylebox("panel_selected").duplicate()

func _ready() -> void:
	
	add_theme_stylebox_override("panel", new_stylebox)
	add_theme_stylebox_override("panel_selected", new_stylebox_focus)

	size_fonts.value = Global.font_size_default
	
func _on_font_size_title_value_changed(value: float) -> void:
	url.add_theme_font_size_override("font_size", int(value))
	
func _on_check_box_pressed() -> void:
	queue_free()


func get_save_data() -> Dictionary:
	var slots := []

	for child in get_children():
		if child is ColorRect:
			slots.append({
				"min_size": [child.custom_minimum_size.x, child.custom_minimum_size.y],
				"color": [child.color.r, child.color.g, child.color.b, child.color.a]
			})

	return {
		"title": url.text,
		"font_size": size_fonts.value,
		"slots_add": slots_add,
		"slots": slots,
		"new_stylebox_color": [ #Como é um Resource (arquivo StyleBox, então tem que passar cada propriedade, e não bg_color)
		new_stylebox.bg_color.r,
		new_stylebox.bg_color.g,
		new_stylebox.bg_color.b,
		new_stylebox.bg_color.a
		],

		"new_stylebox_focus": [
			new_stylebox_focus.bg_color.r,
			new_stylebox_focus.bg_color.g,
			new_stylebox_focus.bg_color.b,
			new_stylebox_focus.bg_color.a,
		],
	}


func load_save_data(data: Dictionary) -> void:

	var c = data.get("new_stylebox_color", [0,0,0,1])
	new_stylebox.bg_color = Color(c[0], c[1], c[2], c[3])
	
	var c_focus = data.get("new_stylebox_focus", [0,0,0,1])
	new_stylebox_focus.bg_color = Color(c_focus[0], c_focus[1], c_focus[2], c_focus[3])


	url.text = data.get("title", "Node")
	size_fonts.value = data.get("font_size", 14)

	for child in get_children():
		if child is ColorRect:
			child.queue_free()

	slots_add = 2
	var saved_slots = data.get("slots", [])

	for slot_data in saved_slots:

		var item = ColorRect.new()
		add_child(item)
		item.clip_contents = true

		var min_size = slot_data["min_size"]
		item.custom_minimum_size = Vector2(min_size[0], min_size[1])

		var color_data = slot_data["color"]
		item.color = Color(
			color_data[0],
			color_data[1],
			color_data[2],
			color_data[3]
		)

		set_slot(
			slots_add,
			true, 0, Color.WHITE,
			true, 0, Color.WHITE
		)

		slots_add += 1


var ative := false
func _process(_delta: float) -> void:
	if Input.is_action_pressed("ui_text_delete") and ative:
		queue_free()

func _on_node_selected() -> void:
	ative = true
	
func _on_node_deselected() -> void:
	ative = false

var slots_add := 2
func _on_button_add_pressed() -> void:
	var item = ColorRect.new()
	add_child(item)
	item.clip_contents = true
	item.custom_minimum_size = Vector2(0, 20)
	item.color = Color(0.078, 0.078, 0.078, 0)
	set_slot(slots_add, true, 0, Color(1.0, 1.0, 1.0, 1.0), true, 0, Color(1.0, 1.0, 1.0, 1.0))
	slots_add += 1


func _on_go_url_pressed() -> void:
	OS.shell_open(url.text)


func _on_button_sub_pressed() -> void:
	var rects := []
	
	for child in get_children():
		if child is ColorRect:
			rects.append(child)
	
	if rects.is_empty():
		return
	
	var last_rect = rects[-1]
	last_rect.queue_free()
	slots_add -= 1
	size = Vector2(1,1)
	
	set_slot(slots_add, false, 0, Color.WHITE, false, 0, Color.WHITE)


func _on_color_button_back_color_changed(color: Color) -> void:

	new_stylebox.bg_color = color
	new_stylebox_focus.bg_color = color.darkened(0.5) #darkened escurece a cor de 0 a 1 (0.5 -> 50%)


func _on_reset_color_pressed() -> void:
	remove_theme_stylebox_override("panel")
	remove_theme_stylebox_override("panel_selected")
	
	new_stylebox = get_theme_stylebox("panel").duplicate()
	new_stylebox_focus = get_theme_stylebox("panel_selected").duplicate()
	
	add_theme_stylebox_override("panel", new_stylebox)
	add_theme_stylebox_override("panel_selected", new_stylebox_focus)
