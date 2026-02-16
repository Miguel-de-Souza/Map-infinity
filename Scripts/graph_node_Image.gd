extends GraphNode

@export var open_image: FileDialog
@export var texture_node: TextureButton 
@export var check: CheckBox

var current_image_path := ""

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
		"slots_add": slots_add,
		"slots": slots,
		"texture_path": current_image_path,
		"check_pressed": check.button_pressed

	}


func load_save_data(data: Dictionary) -> void:

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


	var texture_path = data.get("texture_path", "")

	if texture_path != "":
		current_image_path = texture_path
	
		var imagem = Image.new()
		if imagem.load(texture_path) == OK:
			var imagem_textura = ImageTexture.create_from_image(imagem)
			texture_node.texture_normal = imagem_textura
			
	var check_state = data.get("check_pressed", false)
	check.button_pressed = check_state

	_on_check_size_pressed()


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


func _on_texture_rect_pressed() -> void:
	open_image.popup()

func _on_open_image_file_selected(path: String) -> void:
	current_image_path = path
	
	var imagem = Image.new()
	imagem.load(path)

	var imagem_textura = ImageTexture.create_from_image(imagem)
	texture_node.texture_normal = imagem_textura



func _on_check_size_pressed() -> void:
	if check.button_pressed:
		texture_node.ignore_texture_size = false
		texture_node.stretch_mode = TextureButton.STRETCH_KEEP
		
	else:
		texture_node.ignore_texture_size = true
		texture_node.stretch_mode = TextureButton.STRETCH_SCALE
		size = Vector2(384, 225) 
		


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
