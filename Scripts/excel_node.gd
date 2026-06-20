extends GraphNode

@export var btn_add_linha: Button
@export var btn_add_coluna: Button

@export var scroll_topo: ScrollContainer
@export var scroll_base: ScrollContainer

@export var header_letras: HBoxContainer
@export var container_planilha: HBoxContainer

@export var total_linhas: int = 8
@export var total_colunas: int = 3

@export var title_line: LineEdit
@export var note: LineEdit
@export var checks: CheckBox

var dados_planilha: Dictionary = {}
var titled = preload("uid://dyxn2spfd3ra7")

var new_stylebox = get_theme_stylebox("panel").duplicate()
var new_stylebox_focus = get_theme_stylebox("panel_selected").duplicate()


func _ready() -> void:
	custom_minimum_size = Vector2(550, 400)
	
	btn_add_linha.text = "+ Linha"
	btn_add_coluna.text = "+ Coluna"
	
	btn_add_linha.pressed.connect(_on_btn_add_linha_pressed)
	btn_add_coluna.pressed.connect(_on_btn_add_coluna_pressed)
	
	var barra_topo = scroll_topo.get_h_scroll_bar()
	var barra_base = scroll_base.get_h_scroll_bar()
	
	barra_base.value_changed.connect(func(valor_scroll: float):
		barra_topo.value = valor_scroll
	)
	
	atualizar_planilha()

func get_save_data() -> Dictionary:
	# Convertemos o dicionário de dados da planilha para usar chaves em String (compatível com JSON)
	var dados_salvamento_planilha: Dictionary = {}
	for chave in dados_planilha:
		if chave is Vector2i:
			var chave_string = "%d,%d" % [chave.x, chave.y]
			dados_salvamento_planilha[chave_string] = dados_planilha[chave]
	
	return {
		"title": title_line.text if title_line else "",
		"note": note.text if note else "",
		"total_linhas": total_linhas,
		"total_colunas": total_colunas,
		"dados_planilha": dados_salvamento_planilha,
		"slots_add": slots_add,
		"sized_x": size.x,
		"sized_y": size.y,
		"active_siz": checks.button_pressed,
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
	]
	}

func load_save_data(data: Dictionary) -> void:
	if title_line:
		title_line.text = data.get("title", "")
	if note:
		note.text = data.get("note", "")
		
	total_linhas = data.get("total_linhas", 5)
	total_colunas = data.get("total_colunas", 3)
	slots_add = data.get("slots_add", 2)
	size = Vector2(data.get("sized_x", 0), data.get("sized_y", 0))
	
	#Atualiza o fundo normal
	var c = data.get("new_stylebox_color", [0,0,0,1])
	new_stylebox.bg_color = Color(c[0], c[1], c[2], c[3])
	
	#Atualiza o fundo quando focado
	var c_focus = data.get("new_stylebox_focus", [0,0,0,1])
	new_stylebox_focus.bg_color = Color(c_focus[0], c_focus[1], c_focus[2], c_focus[3])

	checks.button_pressed = data.set("active_siz", false)
	
	dados_planilha.clear()
	var dados_salvados = data.get("dados_planilha", {})
	for chave_string in dados_salvados:
		var partes = chave_string.split(",")
		if partes.size() == 2:
			var chave_vector = Vector2i(int(partes[0]), int(partes[1]))
			dados_planilha[chave_vector] = dados_salvados[chave_string]
	
	atualizar_planilha()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_text_delete") and selected:
		var foco_atual = get_viewport().gui_get_focus_owner()
		
		if not (foco_atual is LineEdit):
			Global.alteraction()
			Global.selected_nodes -= 1
			queue_free()

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not selected:
			var shift_pressed = Input.is_key_pressed(KEY_SHIFT)
			if not shift_pressed:
				get_parent().clear_selection()
			selected = true

func obter_letra_coluna(col_idx: int) -> String:
	var letra = ""
	while col_idx > 0:
		var resto = (col_idx - 1) % 26
		letra = char(65 + resto) + letra
		col_idx = (col_idx - resto) / 26
	return letra

func atualizar_planilha() -> void:
	for child in container_planilha.get_children(): child.queue_free()
	for child in header_letras.get_children(): child.queue_free()
	
	var canto_vazio := titled.instantiate() as LineEdit
	canto_vazio.custom_minimum_size = Vector2(35, 30)
	header_letras.add_child(canto_vazio)
	
	var coluna_numeros := VBoxContainer.new()
	coluna_numeros.custom_minimum_size = Vector2(35, 0)
	coluna_numeros.add_theme_constant_override("separation", 5)
	
	for i in range(total_linhas):
		var lbl_linha := Label.new()
		lbl_linha.text = str(i + 1)
		lbl_linha.custom_minimum_size = Vector2(0, 30)
		lbl_linha.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl_linha.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		coluna_numeros.add_child(lbl_linha)
		
	container_planilha.add_child(coluna_numeros)
	
	var split_topo_atual: Node = header_letras
	var split_base_atual: Node = container_planilha
	
	for j in range(total_colunas):
		var label_container := MarginContainer.new()
		label_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var lbl_coluna := Label.new()
		lbl_coluna.text = obter_letra_coluna(j + 1)
		lbl_coluna.custom_minimum_size = Vector2(40, 30)
		lbl_coluna.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl_coluna.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label_container.add_child(lbl_coluna)
		
		var coluna_vbox := VBoxContainer.new()
		coluna_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		for i in range(total_linhas):
			title_line = titled.instantiate() as LineEdit
			title_line.alignment = HORIZONTAL_ALIGNMENT_CENTER
			var chave = Vector2i(i, j)
			title_line.custom_minimum_size = Vector2(80, 30)
			title_line.placeholder_text = "%s%d" % [obter_letra_coluna(j + 1), i + 1]
			
			if i == 0:
				var estilo_titulo := StyleBoxFlat.new()
				estilo_titulo.bg_color = Color("121212ff")
				estilo_titulo.border_width_bottom = 2
				estilo_titulo.border_color = Color("272727ff")
				title_line.add_theme_stylebox_override("normal", estilo_titulo)
				title_line.add_theme_stylebox_override("focus", estilo_titulo)
				title_line.add_theme_color_override("font_color", Color.WHITE)
			
			if dados_planilha.has(chave):
				title_line.text = dados_planilha[chave]
				
			title_line.text_changed.connect(func(novo_texto: String):
				dados_planilha[chave] = novo_texto
			)
			coluna_vbox.add_child(title_line)
		
		if j < total_colunas - 1:
			var splitter_topo := HSplitContainer.new()
			var splitter_base := HSplitContainer.new()
			
			splitter_topo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			splitter_base.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			splitter_base.dragged.connect(func(offset: int):
				splitter_topo.split_offset = offset
			)
			
			split_topo_atual.add_child(splitter_topo)
			splitter_topo.add_child(label_container)
			split_topo_atual = splitter_topo
			
			split_base_atual.add_child(splitter_base)
			splitter_base.add_child(coluna_vbox)
			split_base_atual = splitter_base
		else:
			split_topo_atual.add_child(label_container)
			split_base_atual.add_child(coluna_vbox)


func _on_btn_add_linha_pressed() -> void:
	total_linhas += 1
	atualizar_planilha()

func _on_btn_add_coluna_pressed() -> void:
	total_colunas += 1
	atualizar_planilha()

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
	
func _disconnect_slot(slot_index: int) -> void:
	var graph = get_parent()
	for connection in graph.get_connection_list():
		if connection.from_node == name and connection.from_port == slot_index:
			graph.disconnect_node(connection.from_node, connection.from_port, connection.to_node, connection.to_port)
			
		if connection.to_node == name and connection.to_port == slot_index:
			graph.disconnect_node(connection.from_node, connection.from_port, connection.to_node, connection.to_port)
			
	Global.alteraction()


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


func _on_check_box_pressed() -> void:
	if checks.button_pressed:
		scroll_base.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		scroll_base.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		
	else:
		scroll_base.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
		scroll_base.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
