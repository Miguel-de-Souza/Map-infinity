extends GraphEdit

@export var file_dia: FileDialog
@export var file_load: FileDialog
@export var more: AcceptDialog
@export var poparquivo: MenuButton
@export var popMake: MenuButton
@export var label_diretorio: Label
@export var check_diretory: CheckBox

var current_project_path: String = ""
var posit:= Vector2(160,160)

func _on_disconnection_request(from_node, from_port, to_node, to_port):
	disconnect_node(from_node, from_port, to_node, to_port)

func _ready():
	
	connection_request.connect(_on_connection_request)
	file_dia.file_selected.connect(_on_save_file_selected)
	file_load.file_selected.connect(_on_load_file_selected)
	disconnection_request.connect(_on_disconnection_request)
	
	var popup_arquivo = poparquivo.get_popup() 
	popup_arquivo.id_pressed.connect(_on_item_selected)
	
	var pop_inserir = popMake.get_popup()
	pop_inserir.id_pressed.connect(_on_item_selected_insert)

func _process(_delta: float) -> void:
	
	label_diretorio.text = current_project_path
	
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

	elif Input.is_action_just_pressed("Add Bloco Color"):
		criar_bloco_notas(2)
		
	elif Input.is_action_just_pressed("Add Bloco URL"):
		criar_bloco_notas(3)
		
	elif Input.is_action_just_pressed("Add Bloco Imagem"):
		criar_bloco_notas(4)

	elif Input.is_action_just_pressed("Add Bloco Notas"):
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
		data["connections"].append({
			"from": conn.from_node,
			"from_port": conn.from_port,
			"to": conn.to_node,
			"to_port": conn.to_port
		})

	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))
	file.close()

	current_project_path = path
	print("Projeto salvo em: ", path)


func criar_bloco_notas(id : int = 1) -> void:
	var nodesGraph = null
	
	match  id:
		1:
			nodesGraph = preload("res://tscn/graph_node.tscn").instantiate()
		
		2:
			nodesGraph = preload("res://tscn/graph_node_color.tscn").instantiate()
			
		3:
			nodesGraph = preload("res://tscn/graph_node_URL.tscn").instantiate()
			
		4:
			nodesGraph = preload("res://tscn/graph_node_Iamge.tscn").instantiate()
	
	nodesGraph.name = "Node_" + str(Time.get_ticks_usec())
	
	add_child(nodesGraph)
	nodesGraph.position_offset += posit
	posit += Vector2(160,160)


func Novo():

	clear_connections()

	for child in get_children():
		if child is GraphNode:
			child.queue_free()

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

	for node_data in data["nodes"]:
		var scene = load(node_data["scene"])
		var node = scene.instantiate()
		add_child(node)

		node.name = node_data["name"]
		node.position_offset = Vector2(node_data["position"][0], node_data["position"][1])
		node.load_save_data(node_data["data"])

	await get_tree().process_frame


	for conn in data["connections"]:
		if has_node(NodePath(conn["from"])) and has_node(NodePath(conn["to"])):
			connect_node(conn["from"], conn["from_port"], conn["to"], conn["to_port"])
		else:
			print("Conexão ignorada:", conn)

	current_project_path = path
	print("Projeto carregado de:", path)


	current_project_path = path
	print("Projeto carregado de: ", path)
	
	
func _on_save_file_selected(path: String) -> void:
	save_project_to_path(path)


func _on_load_file_selected(path: String) -> void:
	load_project_from_path(path)


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
			criar_bloco_notas()
			
		1:
			criar_bloco_notas(2)
			
		2:
			criar_bloco_notas(3)
			
		3:
			criar_bloco_notas(4)


func _on_menu_button_more_pressed() -> void:
	more.popup()
	DisplayServer.beep()

func _on_check_diretorio_pressed() -> void:
	if check_diretory.button_pressed:
		label_diretorio.hide()
		
	
	else:
		label_diretorio.show()


func _on_type_window_item_selected(index: int) -> void:
		
	match index:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
