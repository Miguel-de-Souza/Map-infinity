extends GraphNode

@export var note: TextEdit
@export var title_line: LineEdit
@export var size_fonts: SpinBox

func _ready() -> void:
	size_fonts.value = Global.font_size_default

	# Atualiza título quando o texto muda (em vez de usar _process)
	size_fonts.value_changed.connect(_on_font_size_value_changed)

	_on_font_size_value_changed(size_fonts.value)

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
		"slots_add": slots_add,
		"slots": slots
	}


func load_save_data(data: Dictionary) -> void:

	title_line.text = data.get("title", "Node")
	note.text = data.get("note_text", "")
	size_fonts.value = data.get("font_size", 14)

	_on_font_size_value_changed(size_fonts.value)

	# 🔥 Limpa ColorRects antigos
	for child in get_children():
		if child is ColorRect:
			child.queue_free()


	# 🔥 Limpa ColorRects antigos
	for child in get_children():
		if child is ColorRect:
			child.queue_free()

	slots_add = 2
	var saved_slots = data.get("slots", [])

	for slot_data in saved_slots:

		var item = ColorRect.new()
		add_child(item)
		item.clip_contents = true

		# Reconstrói Vector2
		var min_size = slot_data["min_size"]
		item.custom_minimum_size = Vector2(min_size[0], min_size[1])

		# Reconstrói Color
		var c = slot_data["color"]
		item.color = Color(c[0], c[1], c[2], c[3])

		# 🔥 Recria o SLOT REAL do GraphNode
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
