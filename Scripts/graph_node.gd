extends GraphNode

@export var note: TextEdit
@export var title_line: LineEdit
@export var size_fonts: SpinBox
@export var font_size: SpinBox
@export var size_content: CheckBox
@export var Minimum_R := false
@export var mini_spix: CheckBox

#Pega stylebox do GraphNode
var new_stylebox = get_theme_stylebox("panel").duplicate()
var new_stylebox_focus = get_theme_stylebox("panel_selected").duplicate()

func _ready() -> void:

	#Para disconectar o GraphEdit
	get_parent().disconnection_request.connect(_on_disconnection_request)

	add_theme_stylebox_override("panel", new_stylebox)
	add_theme_stylebox_override("panel_selected", new_stylebox_focus)
	
	#Valores padrão das Configurações (Ex: Config Title Size = 10, então )
	size_fonts.value = Global.font_size_default
	font_size.value = Global.font_size_title_default
	
	size_content.button_pressed = Global.var_check_ajust
	mini_spix.button_pressed = Global.var_mini_check_ajust
	
	#atualiza os valores para o padrões das Configuações
	size_fonts._on_value_changed(size_fonts.value)
	font_size._on_value_changed(font_size.value)
	
	mini_spix.on_button_press()
	mini_spix.verification_pls()
	
	_on_check_ajust_pressed()

#Método para salvar as propriedades do Node (o método é chamado em GraphEdit)
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
	"mini_ajust_size": mini_spix.button_pressed,
	"new_stylebox_color": [
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
	"sized_x": size.x,
	"sized_y": size.y,
	"slots": slots
}

#Método para Carregar as propriedades do Node (o método é chamado em GraphEdit)
func load_save_data(data: Dictionary) -> void:

	#Atualiza os valores de Title e Campo
	title_line.text = data.get("title", "Node")
	note.text = data.get("note_text", "")
	size = Vector2(data.get("sized_x", 0), data.get("sized_y", 0))
	
	#Atualiza o fundo normal
	var c = data.get("new_stylebox_color", [0,0,0,1])
	new_stylebox.bg_color = Color(c[0], c[1], c[2], c[3])
	
	#Atualiza o fundo quando focado
	var c_focus = data.get("new_stylebox_focus", [0,0,0,1])
	new_stylebox_focus.bg_color = Color(c_focus[0], c_focus[1], c_focus[2], c_focus[3])

	#Atualiza os valores do SpinBoxs
	size_fonts.value = data.get("font_size", 14)
	font_size.value = data.get("title_font_size", 14)
	
	#Atualiza o CheckBox "Ajustar Tamanho do Campo"
	size_content.button_pressed = data.get("pressed_ajust", false)
	mini_spix.button_pressed = data.get("mini_ajust_size", false)
	
	_on_check_ajust_pressed()
	mini_spix.on_button_press()

	#Coisa para slots
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

#Sistema para adicionar slots
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

#Disconecta Slots
func _disconnect_slot(slot_index: int) -> void:
	var graph = get_parent()
	for connection in graph.get_connection_list():
		if connection.from_node == name and connection.from_port == slot_index:
			graph.disconnect_node(connection.from_node, connection.from_port, connection.to_node, connection.to_port)
			
		if connection.to_node == name and connection.to_port == slot_index:
			graph.disconnect_node(connection.from_node, connection.from_port, connection.to_node, connection.to_port)
			
	Global.alteraction()

#Sistema para retirar slots (e também desconectar)
func _on_button_sub_pressed() -> void:
	var graph := get_parent()

	for connection in graph.get_connection_list():
		if connection.from_node == name and connection.from_port == slots_add - 1:
			graph.disconnect_node(connection.from_node, connection.from_port, connection.to_node, connection.to_port)

		if connection.to_node == name and connection.to_port == slots_add - 1:
			graph.disconnect_node(connection.from_node, connection.from_port, connection.to_node, connection.to_port)
	
	var rects := []
	for child in get_children():
		if child is ColorRect:
			rects.append(child)

	if rects.is_empty():
		return

	rects[-1].queue_free()
	slots_add -= 1
	size = Vector2(1,1)
	
	_disconnect_slot(slots_add - 1)
	set_slot(slots_add, false, 0, Color.WHITE, false, 0, Color.WHITE)

	Global.alteraction()

var type_list:= "poto"
var num_count := 1

#O que realmente faz a desconexão (GraphEdit)
func _on_disconnection_request(from_node, from_port, to_node, to_port):
	get_parent().disconnect_node(from_node, from_port, to_node, to_port)
	Global.alteraction()

# Usar Enum é mais seguro e organizado que Strings
enum ListType { NONE, BULLET, NUMBERED }
var current_list_type = ListType.NONE

func _input(event: InputEvent):
	if note.has_focus() and event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER:
			_handle_list_continuation()

func _handle_list_continuation():
	# Pegamos a linha onde o cursor ESTAVA antes do Enter processar
	var current_line_index = note.get_caret_line()
	var line_text = note.get_line(current_line_index)
	
	# Aguarda o frame para o TextEdit processar a nova linha
	await get_tree().process_frame
	
	match current_list_type:
		ListType.BULLET:
			if line_text.strip_edges().begins_with("•"):
				note.insert_text_at_caret("• ")
		
		ListType.NUMBERED:
			# Verifica se a linha anterior tinha um padrão de número "1. "
			if "." in line_text:
				var parts = line_text.split(".")
				if parts[0].is_valid_int():
					num_count = parts[0].to_int() + 1
					note.insert_text_at_caret(str(num_count) + ". ")

# --- Sinais dos Botões ---

func _on_button_list_pressed() -> void:
	current_list_type = ListType.BULLET
	note.insert_text_at_caret("• ")
	note.grab_focus()

func _on_button_list_num_pressed() -> void:
	current_list_type = ListType.NUMBERED
	num_count = 1
	note.insert_text_at_caret("1. ")
	note.grab_focus()

#CheckBox de Ajustar Campo, quando verdadeiro mantém o tamanho do Campo
func _on_check_ajust_pressed() -> void:
	if size_content.button_pressed:
		note.scroll_fit_content_height = false
		note.scroll_fit_content_width = false
		size = Vector2(1,1)
		
	else:
		note.scroll_fit_content_height = true
		note.scroll_fit_content_width = true
		
	Global.alteraction()

#Sistemas de Cores
func _on_color_button_back_color_changed(color: Color) -> void:
	var sb = get_theme_stylebox("panel")
	var sb_focus = get_theme_stylebox("panel_selected")

	sb.bg_color = color
	sb_focus.bg_color = color.darkened(0.5)
	
	Global.alteraction()


func _on_reset_pressed() -> void:
	remove_theme_stylebox_override("panel")
	remove_theme_stylebox_override("panel_selected")
	
	new_stylebox = get_theme_stylebox("panel").duplicate()
	new_stylebox_focus = get_theme_stylebox("panel_selected").duplicate()
	
	add_theme_stylebox_override("panel", new_stylebox)
	add_theme_stylebox_override("panel_selected", new_stylebox_focus)

	Global.alteraction()
