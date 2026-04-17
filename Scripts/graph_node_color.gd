extends GraphNode

@export var title_line: LineEdit
@export var size_fonts: SpinBox
@export var button_color: ColorPickerButton

@export var line_hex: LineEdit
@export var line_r: LineEdit
@export var line_g: LineEdit
@export var line_b: LineEdit

func _ready() -> void:
	size_fonts.value = Global.font_size_default
	line_r.text = str(int(button_color.color.r))
	line_g.text = str(int(button_color.color.g))
	line_b.text = str(int(button_color.color.b))
	line_hex.text = str(button_color.color.to_html(false))

	
func _on_font_size_title_value_changed(value: float) -> void:
	title_line.add_theme_font_size_override("font_size", int(value))
	
	Global.alteraction()

func get_save_data() -> Dictionary:
	var slots := []

	for child in get_children():
		if child is ColorRect:
			slots.append({
				"min_size": [child.custom_minimum_size.x, child.custom_minimum_size.y],
				"color": [child.color.r, child.color.g, child.color.b, child.color.a]
			})

	return {
		"title": title_line.text,
		"font_size": size_fonts.value,
		"node_color": [button_color.color.r, button_color.color.g, button_color.color.b, button_color.color.a],
		"slots_add": slots_add,
		"slots": slots,
		"sized_x": size.x,
		"sized_y": size.y,
		"info_color_r": line_r.text,
		"info_color_g": line_g.text,
		"info_color_b": line_b.text,
		"info_color_hex": line_hex.text
	}


func load_save_data(data: Dictionary) -> void:

	title_line.text = data.get("title", "Node")
	size_fonts.value = data.get("font_size", 14)
	size = Vector2(data.get("sized_x", 0), data.get("sized_y", 0))
	
	var saved_color = data.get("node_color", [1,1,1,1])
	button_color.color = Color(saved_color[0], saved_color[1], saved_color[2], saved_color[3])

	line_r.text = data.get("info_color_r",0)
	line_g.text = data.get("info_color_g",0)
	line_b.text = data.get("info_color_b",0)
	line_hex.text = data.get("info_color_hex",0)

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

		var c = slot_data["color"]
		item.color = Color(c[0], c[1], c[2], c[3])

		set_slot(
			slots_add,
			true, 0, Color.WHITE,
			true, 0, Color.WHITE
		)

		slots_add += 1

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not selected:
			var shift_pressed = Input.is_key_pressed(KEY_SHIFT)
			if not shift_pressed:
				get_parent().clear_selection()
			selected = true

func _process(_delta: float) -> void:
	if Input.is_action_pressed("ui_text_delete") and selected:
		Global.alteraction()
		Global.selected_nodes -= 1
		queue_free()

var slots_add := 2
func _on_button_add_pressed() -> void:
	var item = ColorRect.new()
	add_child(item)
	item.clip_contents = true
	item.custom_minimum_size = Vector2(0, 20)
	item.color = Color(0.078, 0.078, 0.078, 0)
	set_slot(slots_add, true, 0, Color(1.0, 1.0, 1.0, 1.0), true, 0, Color(1.0, 1.0, 1.0, 1.0))
	slots_add += 1
	
	Global.alteraction()


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
	
	Global.alteraction()


func _on_color_picker_button_color_changed(color: Color) -> void:
	line_r.text = str(int(button_color.color.r * 255))
	line_g.text = str(int(button_color.color.g * 255))
	line_b.text = str(int(button_color.color.b * 255))
	line_hex.text = str(button_color.color.to_html(false))
	
	Global.alteraction()

func _on_node_selected() -> void:
	Global.selected_nodes += 1


func _on_node_deselected() -> void:
	Global.selected_nodes -= 1
	
func _on_position_offset_changed() -> void:
	Global.alteraction()
