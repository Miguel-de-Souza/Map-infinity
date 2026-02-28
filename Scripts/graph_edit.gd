extends GraphEdit

@export var file_dia: FileDialog
@export var file_load: FileDialog
@export var more: AcceptDialog
@export var poparquivo: MenuButton
@export var popMake: MenuButton
@export var label_diretorio: Label
@export var text_more: RichTextLabel
@export var confirmation_version: ConfirmationDialog

var current_project_path: String = ""
var posit:= Vector2(0,0)
var desktop := OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)
var active_mode_node:= false
var selected_mode_make:= false
var numb := 0
var description := str(ProjectSettings.get_setting("application/config/description"))
var version := str(ProjectSettings.get_setting("application/config/version"))
	
func _on_disconnection_request(from_node, from_port, to_node, to_port):
	disconnect_node(from_node, from_port, to_node, to_port)

func _ready():
	text_more.bbcode_enabled = true
	label_diretorio.text = ""
	file_dia.current_dir = desktop
	file_load.current_dir = desktop
	text_more.bbcode_enabled = true

	text_more.text = description + " [b]Versão do Projeto: " + version + "[/b]"

	connection_request.connect(_on_connection_request)
	file_dia.file_selected.connect(_on_save_file_selected)
	file_load.file_selected.connect(_on_load_file_selected)
	disconnection_request.connect(_on_disconnection_request)
	
	var popup_arquivo = poparquivo.get_popup() 
	popup_arquivo.id_pressed.connect(_on_item_selected)
	
	var pop_inserir = popMake.get_popup()
	pop_inserir.id_pressed.connect(_on_item_selected_insert)

func _process(_delta: float) -> void:
	
	if not selected_mode_make:
		mouse_default_cursor_shape = Control.CURSOR_ARROW
	
	if selected_mode_make:
		
		mouse_default_cursor_shape = Control.CURSOR_CROSS
				
		if Input.is_action_just_pressed("Click"):
			criar_bloco_notas(numb)
			selected_mode_make = false
	
	if Input.is_action_just_pressed("Novo"):
		get_tree().reload_current_scene()
		
	elif Input.is_action_just_pressed("Abrir"):
		file_load.popup()
	
	elif Input.is_action_just_pressed("Salvar Como"):
		file_dia.popup()
	
	elif Input.is_action_just_pressed("Salvar"):
		if current_project_path == "":
				file_dia.popup()
				
		else:
			save_project_to_path(current_project_path)
			for conn in get_connection_list():
				print(conn)

	elif Input.is_action_just_pressed("Add Bloco Color"):
		if active_mode_node:
			selected_mode_make = true
			numb = 2
					
		else:
			criar_bloco_notas(2)
		
	elif Input.is_action_just_pressed("Add Bloco URL"):
		if active_mode_node:
			selected_mode_make = true
			numb = 3
					
		else:
			criar_bloco_notas(3)
		
	elif Input.is_action_just_pressed("Add Bloco Imagem"):
		if active_mode_node:
			selected_mode_make = true
			numb = 4
					
		else:
			criar_bloco_notas(4)

	elif Input.is_action_just_pressed("Add Bloco Notas"):
		if active_mode_node:
			selected_mode_make = true
			numb = 1
					
		else:
			criar_bloco_notas()


func _input(_event):
	if Input.is_action_just_pressed("Duplicar"):

		var selecionados: Array = []
		var mapa := {}

		for node in get_children():
			if node is GraphNode and node.selected:
				selecionados.append(node)

		for node in selecionados:
			var copia = node.duplicate()
			add_child(copia)

			var original_style = node.get_theme_stylebox("panel")
			
			if original_style:
				copia.add_theme_stylebox_override("panel", original_style.duplicate())
				
				
			var original_style_select = node.get_theme_stylebox("panel_selected")
			
			if original_style_select:
				copia.add_theme_stylebox_override("panel_selected", original_style_select.duplicate())
				
			copia.position_offset = node.position_offset + Vector2(160,160)
			copia.selected = false

			mapa[node.name] = copia.name

		for conn in get_connection_list():

			if conn.from_node in mapa and conn.to_node in mapa:

				connect_node(
					mapa[conn.from_node],
					conn.from_port,
					mapa[conn.to_node],
					conn.to_port
				)

func _on_connection_request(from_node, from_port, to_node, to_port):
	connect_node(from_node, from_port, to_node, to_port)


func save_project_to_path(path: String):
	var data := {
		"version": version,
		"nodes": [],
		"connections": []
	}

	for child in get_children():
		if child is GraphNode:
			data["nodes"].append({
				"name": child.name,
				"scene": child.scene_file_path,
				"position": [child.position_offset.x, child.position_offset.y],
				"data": child.get_save_data()
			})

	for conn in get_connection_list():
		
		var from_node = get_graph_node_by_name(conn.from_node)
		var to_node = get_graph_node_by_name(conn.to_node)

		if from_node and to_node:
			data["connections"].append({
				"from": from_node.name,
				"from_port": int(conn.from_port),
				"to": to_node.name,
				"to_port": int(conn.to_port)
			})

	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))
	file.close()

	current_project_path = path
	print("Projeto salvo em: ", path)
	
	label_diretorio.text = current_project_path + " (Salvo) "
	await get_tree().create_timer(1.5).timeout
	label_diretorio.text = current_project_path


func criar_bloco_notas(id : int = 1) -> void:
	var nodesGraph = null
	
	match  id:
		1:
			nodesGraph = preload("uid://excut3nknqvk").instantiate() #Node

		2:
			nodesGraph = preload("uid://dbdw60boboltf").instantiate() #Color


		3:
			nodesGraph = preload("uid://ci4galkmc7v4a").instantiate() #URL
			
		4:
			nodesGraph = preload("uid://di7oqrwfyddru").instantiate() #Image
	
	nodesGraph.name = "Node_" + str(Time.get_ticks_usec())
	
	add_child(nodesGraph)
	
	var graph_size = size            
	var node_size = nodesGraph.size    
	
	if active_mode_node:
		nodesGraph.position_offset = (get_local_mouse_position() + scroll_offset) / zoom
		selected_mode_make = false
		
	else:      
		nodesGraph.position_offset = scroll_offset + (graph_size - node_size) / 2


func Novo():

	clear_connections()

	for child in get_children():
		if child is GraphNode:
			child.queue_free()

func get_graph_node_by_name(namef: String) -> GraphNode:
	for child in get_children():
		if child is GraphNode and child.name == namef:
			return child
	return null

var unlock_load:= false
func load_project_from_path(path: String):
	if not FileAccess.file_exists(path):
		print("Arquivo não encontrado.")
		return

	Novo()

	await get_tree().process_frame
	
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()

	var result = JSON.parse_string(content)
	if typeof(result) != TYPE_DICTIONARY:
		push_error("Erro ao ler JSON")
		return
		
	var data: Dictionary = result
	
	if (data["version"] == version) or unlock_load:
		for node_data in data["nodes"]:
			var scene = load(node_data["scene"])
			var node = scene.instantiate()
			add_child(node)

			node.name = node_data["name"]
			node.position_offset = Vector2(node_data["position"][0], node_data["position"][1])
			node.load_save_data(node_data["data"])

		await get_tree().process_frame
		await get_tree().process_frame

		for conn in data["connections"]:

			var from_node = get_graph_node_by_name(conn["from"])
			var to_node = get_graph_node_by_name(conn["to"])

			if from_node and to_node:
				connect_node(
					from_node.name,
					conn["from_port"],
					to_node.name,
					conn["to_port"]
				)
			else:
				print("Conexão ignorada:", conn)

		current_project_path = path
		print("Projeto carregado de: ", path)
		label_diretorio.text = current_project_path
	
	if data["version"] != version and not unlock_load:
		confirmation_version.popup()
		DisplayServer.beep()
	
	
func _on_save_file_selected(path: String) -> void:
	save_project_to_path(path)

var caminho : String 
func _on_load_file_selected(path: String) -> void:
	load_project_from_path(path)
	caminho = path


func _on_item_selected(id: int) -> void:
	match id:
		0:
			get_tree().reload_current_scene()
		1:
			file_load.popup()
		2:
			if current_project_path == "":
				file_dia.popup()
				
			else:
				save_project_to_path(current_project_path)
				
		3:
			file_dia.popup()

func _on_item_selected_insert(id: int) -> void:
	match id:
		0:
			if active_mode_node:
				selected_mode_make = true
				numb = 1
					
			else:
				criar_bloco_notas()
			
		1:
			if active_mode_node:
				selected_mode_make = true
				numb = 2
					
			else:
				criar_bloco_notas(2)
			
		2:
			if active_mode_node:
				selected_mode_make = true
				numb = 3
					
			else:
				criar_bloco_notas(3)
			
		3:
			if active_mode_node:
				selected_mode_make = true
				numb = 4
					
			else:
				criar_bloco_notas(4)


func _on_menu_button_more_pressed() -> void:
	more.popup()
	DisplayServer.beep()


func _on_type_window_item_selected(index: int) -> void:
		
	match index:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _on_option_size_title_value_changed(value: float) -> void:
	Global.font_size_title_default = int(value)


func _on_modo_option_item_selected(index: int) -> void:
	if index == 0:
		active_mode_node = false
		selected_mode_make = false
		
	elif index == 1:
		active_mode_node = true

func clear_selection():
	for child in get_children():
		if child is GraphNode:
			child.selected = false


func _on_confirmation_version_confirmed() -> void:
	unlock_load = true
	load_project_from_path(caminho)
