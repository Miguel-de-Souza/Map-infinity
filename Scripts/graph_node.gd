extends GraphNode

@export var note: TextEdit
@export var title_line: LineEdit
@export var size_fonts: SpinBox
@export var font_size: SpinBox
@export var size_content: CheckBox

var new_stylebox = get_theme_stylebox("panel").duplicate()
var new_stylebox_focus = get_theme_stylebox("panel_selected").duplicate()

func _ready() -> void:

	add_theme_stylebox_override("panel", new_stylebox)
	add_theme_stylebox_override("panel_selected", new_stylebox_focus)
	
	size_fonts.value = Global.font_size_default
	font_size.value = Global.font_size_title_default
	size_content.button_pressed = Global.var_check_ajust

	_on_font_size_value_changed(size_fonts.value)
	_on_font_size_title_value_changed(font_size.value)
	_on_check_ajust_pressed()


func _on_font_size_value_changed(value: float) -> void:
	note.add_theme_font_size_override("font_size", int(value))

	
func _on_font_size_title_value_changed(value: float) -> void:
	title_line.add_theme_font_size_override("font_size", int(value))
	
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
	"title": title_line.text,
	"note_text": note.text,
	"font_size": size_fonts.value,
	"title_font_size": font_size.value,
	"pressed_ajust": size_content.button_pressed,
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
	
	"slots_add": slots_add,
	"slots": slots
}

func load_save_data(data: Dictionary) -> void:

	title_line.text = data.get("title", "Node")
	note.text = data.get("note_text", "")
	
	var c = data.get("new_stylebox_color", [0,0,0,1])
	new_stylebox.bg_color = Color(c[0], c[1], c[2], c[3])
	
	var c_focus = data.get("new_stylebox_focus", [0,0,0,1])
	new_stylebox_focus.bg_color = Color(c_focus[0], c_focus[1], c_focus[2], c_focus[3])

	size_fonts.value = data.get("font_size", 14)
	font_size.value = data.get("title_font_size", 14)
	
	size_content.button_pressed = data.get("pressed_ajust", false)
	_on_check_ajust_pressed()

	_on_font_size_value_changed(size_fonts.value)
	_on_font_size_title_value_changed(font_size.value)

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
		if not title_line.has_focus() and not note.has_focus():
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


var type_list:= "ponto"
var num_count := 1

func _input(event):
	if type_list == "ponto":
		if event is InputEventKey and event.pressed:
			if event.keycode == KEY_ENTER:
				var line = note.get_line(note.get_caret_line())

				if line.begins_with("• "):
					await get_tree().process_frame
					note.insert_text_at_caret("• ")
					
	elif type_list == "num":
		if event is InputEventKey and event.pressed:
			if event.keycode == KEY_ENTER:
				var line = note.get_line(note.get_caret_line())

				if line.begins_with(str(num_count)):
					await get_tree().process_frame
					num_count += 1
					note.insert_text_at_caret(str(num_count) + ". ")


func _on_button_lista_pressed() -> void:
	note.insert_text_at_caret("• ")
	type_list = "ponto"


func _on_button_list_num_pressed() -> void:
	num_count = 1
	note.insert_text_at_caret(str(num_count) + ". ")
	type_list = "num"


func _on_check_ajust_pressed() -> void:
	if size_content.button_pressed:
		note.scroll_fit_content_height = false
		note.scroll_fit_content_width = false
		size = Vector2(1,1)
		
	else:
		note.scroll_fit_content_height = true
		note.scroll_fit_content_width = true


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
