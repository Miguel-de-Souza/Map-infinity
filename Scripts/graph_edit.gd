extends GraphEdit

@export var file_dia: FileDialog
@export var file_load: FileDialog
@export var more: AcceptDialog
var current_project_path: String = ""
var posit:= Vector2(160,160)

func _ready():
	connection_request.connect(_on_connection_request)
	file_dia.file_selected.connect(_on_save_file_selected)
	file_load.file_selected.connect(_on_load_file_selected)
	
func _on_button_pressed() -> void:
	var nodesGraph = preload("res://graph_node.tscn").instantiate()
	nodesGraph.name = "Node_" + str(Time.get_ticks_usec())
	add_child(nodesGraph)
	nodesGraph.position_offset += posit
	posit += Vector2(160,160)

func _input(_event):
	if Input.is_action_just_pressed("Duplicar"):
		for node in get_children():
			if node is GraphNode and node.selected:
				var copia = node.duplicate()
				add_child(copia)
				copia.position_offset += node.position_offset + Vector2(160,160)
				copia.selected = false
				posit += Vector2(160,160)

func _on_connection_request(from_node, from_port, to_node, to_port):
	connect_node(from_node, from_port, to_node, to_port)


func _on_more_pressed() -> void:
	var text_infor := "Versão do Projeto: " + str(ProjectSettings.get_setting("application/config/version")) + "\nEste é um programa para Anotações totalmente gratuito e ilimitado"
	more.dialog_text = text_infor
	more.popup()

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

func load_project_from_path(path: String):
	if not FileAccess.file_exists(path):
		print("Arquivo não encontrado.")
		return

	# 1️⃣ Remove conexões visuais
	clear_connections()

	# 2️⃣ Apaga todos os GraphNodes
	for child in get_children():
		if child is GraphNode:
			child.queue_free()

	# 3️⃣ Espera eles realmente sumirem da cena
	await get_tree().process_frame

	# 4️⃣ Agora sim ler o arquivo
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()

	var result = JSON.parse_string(content)
	if typeof(result) != TYPE_DICTIONARY:
		push_error("Erro ao ler JSON")
		return

	var data: Dictionary = result

	# 5️⃣ Recriar nodes
	for node_data in data["nodes"]:
		var scene = load(node_data["scene"])
		var node = scene.instantiate()
		add_child(node)

		node.name = node_data["name"]
		node.position_offset = Vector2(node_data["position"][0], node_data["position"][1])
		node.load_save_data(node_data["data"])

	# 6️⃣ Espera os ports existirem
	await get_tree().process_frame

	# 7️⃣ Recriar conexões
	for conn in data["connections"]:
		if has_node(NodePath(conn["from"])) and has_node(NodePath(conn["to"])):
			connect_node(conn["from"], conn["from_port"], conn["to"], conn["to_port"])
		else:
			print("Conexão ignorada:", conn)

	current_project_path = path
	print("Projeto carregado de:", path)


	current_project_path = path
	print("Projeto carregado de: ", path)


func _on_save_pressed() -> void:
	if current_project_path == "":
		file_dia.popup()
	else:
		save_project_to_path(current_project_path)


func _on_load_pressed() -> void:
	file_load.popup()
	
	
func _on_save_file_selected(path: String) -> void:
	save_project_to_path(path)


func _on_load_file_selected(path: String) -> void:
	load_project_from_path(path)


func _on_save_more_pressed() -> void:
	file_dia.popup()
