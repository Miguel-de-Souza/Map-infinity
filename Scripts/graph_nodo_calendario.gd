extends GraphNode

@export var grid: GridContainer
@export var label_mes: Label
@export var text_edit: TextEdit
@export var campo_spin: SpinBox
@export var checked_b: CheckBox
@export var Minimum_R := false
@export var title_line: LineEdit
@export var font_size: SpinBox

var mes : int
var ano : int
var eventos := {}
var dia_selecionado := 0
const SAVE_PATH = "user://eventos.json"

func _ready():
	
	font_size.value = Global.font_size_title_default
	campo_spin.value = Global.font_size_default
	
	_on_font_size_campo_value_changed(campo_spin.value)
	var agora = Time.get_datetime_dict_from_system()
	
	ano = agora.year
	mes = agora.month
	
	_on_font_size_campo_value_changed(campo_spin.value)
	_on_font_size_title_value_changed(font_size.value)
	
	atualizar_calendario()

func _process(_delta: float) -> void:
	if Input.is_action_pressed("ui_text_delete") and selected:
		if not title_line.has_focus() and not text_edit.has_focus():
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

func atualizar_calendario():
	limpar_grid()
	
	label_mes.text = nome_mes(mes) + " " + str(ano)
	
	var data = {
		"year": ano,
		"month": mes,
		"day": 1,
		"hour": 0,
		"minute": 0,
		"second": 0
	}
	
	var unix_time = Time.get_unix_time_from_datetime_dict(data)
	var weekday = Time.get_datetime_dict_from_unix_time(unix_time).weekday
	var dias_no_mes = dias_no_mes_func(mes, ano)
	
	# Espaços vazios antes do dia 1
	for i in range(weekday):
		grid.add_child(Label.new())
	
	# Dias do mês
	for dia in range(1, dias_no_mes + 1):
		var btn = Button.new()
		btn.text = str(dia)
		
		btn.pressed.connect(_on_dia_clicado.bind(dia))
		
		grid.add_child(btn)
		
		var chave = gerar_chave(dia)

		if dia == dia_selecionado:
			btn.modulate = Color(0.6, 0.6, 1) # prioridade
			
		elif chave in eventos and eventos[chave] != "":
			btn.modulate = Color(0.6, 1, 0.6)

func limpar_grid():
	for child in grid.get_children():
		child.queue_free()

func dias_no_mes_func(m, a):
	if m == 2:
		if eh_bissexto(a):
			return 29
		return 28
	
	if m in [4, 6, 9, 11]:
		return 30
	
	return 31

func eh_bissexto(a):
	return (a % 4 == 0 and a % 100 != 0) or (a % 400 == 0)

func nome_mes(m):
	var nomes = [
		"Janeiro", "Fevereiro", "Março", "Abril",
		"Maio", "Junho", "Julho", "Agosto",
		"Setembro", "Outubro", "Novembro", "Dezembro"
	]
	return nomes[m - 1]

# Botões de navegação
func _on_button_prev_pressed():
	salvar_texto_atual()
	dia_selecionado = 0
	mes -= 1
	if mes < 1:
		mes = 12
		ano -= 1
	atualizar_calendario()

func _on_button_next_pressed():
	salvar_texto_atual()
	dia_selecionado = 0
	mes += 1
	if mes > 12:
		mes = 1
		ano += 1
	atualizar_calendario()
	
	
func _on_dia_clicado(dia):
	salvar_texto_atual()
	
	dia_selecionado = dia
	
	var chave = gerar_chave(dia)
	
	if chave in eventos:
		text_edit.text = eventos[chave]
	else:
		text_edit.text = ""
	
	atualizar_calendario()
		
		
func salvar_texto_atual():
	if dia_selecionado == 0:
		return
	
	var chave = gerar_chave(dia_selecionado)
	eventos[chave] = text_edit.text
	
	if text_edit.text.strip_edges() == "":
		eventos.erase(chave)
	
	else:
		eventos[chave] = text_edit.text
	
	
func gerar_chave(dia):
	return "%04d-%02d-%02d" % [ano, mes, dia]
	

func get_save_data() -> Dictionary:
	return {
		"font_size": campo_spin.value,
		"title_font_size": font_size.value,
		"mes": mes,
		"ano": ano,
		"eventos": eventos,
		"dia_selecionado": dia_selecionado,
		"texto_atual": text_edit.text,
		"title": title_line.text,
	}

func load_save_data(data: Dictionary) -> void:
	
	title_line.text = data.get("title", "Node")
	mes = data.get("mes", mes)
	ano = data.get("ano", ano)
	eventos = data.get("eventos", {})
	dia_selecionado = data.get("dia_selecionado", 0)

	text_edit.text = data.get("texto_atual", "")

	campo_spin.value = data.get("font_size", 14)
	font_size.value = data.get("title_font_size", 14)
	
	_on_font_size_campo_value_changed(campo_spin.value)
	_on_font_size_title_value_changed(font_size.value)
	
	atualizar_calendario()
	
	
func _on_node_selected() -> void:
	Global.selected_nodes += 1


func _on_node_deselected() -> void:
	Global.selected_nodes -= 1


func _on_font_size_campo_value_changed(value: float) -> void:
	text_edit.add_theme_font_size_override("font_size", int(value))
	Global.alteraction()


func _on_check_ajust_pressed() -> void:
	if checked_b.button_pressed:
		text_edit.scroll_fit_content_height = false
		text_edit.scroll_fit_content_width = false
		size = Vector2(1,1)
		
	else:
		text_edit.scroll_fit_content_height = true
		text_edit.scroll_fit_content_width = true
		
	Global.alteraction()


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

func _on_position_offset_changed() -> void:
	Global.alteraction()


func _on_font_size_title_value_changed(value: float) -> void:
	title_line.add_theme_font_size_override("font_size", int(value))
	Global.alteraction()
