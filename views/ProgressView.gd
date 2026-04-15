class_name ProgressView
extends Control

@onready var lines_layer = $LinesLayer
@onready var nodes_layer = $NodesLayer
@onready var lbl_subtitle = $LblSubtitle

# Definición de los objetivos en la red (Niveles del juego)
var investigation_nodes = [
	{ "id": 1, "name": "Objetivo 1 \n(Acosador de Valeria)", "desc": "Caso: Injuria", "pos": Vector2(150, 450) },
	{ "id": 2, "name": "Objetivo 2 \n(Difamador Grupo)", "desc": "Caso: Calumnia", "pos": Vector2(400, 250) },
	{ "id": 3, "name": "Objetivo 3 \n(Ladrón de Identidad)", "desc": "Caso: Suplantación", "pos": Vector2(700, 250) },
	{ "id": 4, "name": "Objetivo 4 \n(Cabecilla de la Red)", "desc": "Caso: Acoso Coordinado", "pos": Vector2(950, 450) }
]

func _ready() -> void:
	_build_visual_map()

func _build_visual_map() -> void:
	var gm = get_node_or_null("/root/GameManager")
	var current_lvl = 1
	var total_cases_solved = 0
	
	if gm:
		current_lvl = int(gm.current_level)
		if gm.investigation_tree:
			total_cases_solved = gm.investigation_tree.get_all_cases().size()
	
	lbl_subtitle.text = "PROGRESO DEL DETECTIVE | NODOS DESBLOQUEADOS: " + str(total_cases_solved)
	
	# Dibujar Líneas conectoras
	for i in range(investigation_nodes.size() - 1):
		var n1 = investigation_nodes[i]
		var n2 = investigation_nodes[i + 1]
		
		# Solo mostramos la línea si el nivel actual es mayor o igual al nodo de origen
		if current_lvl >= n1.id:
			var line = Line2D.new()
			line.add_point(n1.pos)
			line.add_point(n2.pos)
			line.width = 4
			
			# Color depending on status
			if current_lvl > n2.id:
				line.default_color = Color(0.1, 0.8, 0.4) # Resuelto -> Verde brillante
			elif current_lvl == n2.id:
				line.default_color = Color(0.8, 0.8, 0.2) # Investigando -> Amarillo
			else:
				line.default_color = Color(0.2, 0.3, 0.4) # Bloqueado -> Azul oscuro
				
			lines_layer.add_child(line)
			
	# Dibujar Nodos visuales
	for node_data in investigation_nodes:
		var status = "LOCKED"
		if current_lvl > node_data.id:
			status = "SOLVED"
		elif current_lvl == node_data.id:
			status = "ACTIVE"
			
		var visual_node = _create_visual_node(node_data, status)
		nodes_layer.add_child(visual_node)
		
		# Animación de entrada al cargar el mapa
		visual_node.scale = Vector2.ZERO
		var tween = create_tween()
		tween.tween_property(visual_node, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT).set_delay(node_data.id * 0.15)

func _create_visual_node(data: Dictionary, status: String) -> Control:
	var container = Control.new()
	container.position = data.pos
	
	var circle = Panel.new()
	circle.custom_minimum_size = Vector2(80, 80)
	circle.position = Vector2(-40, -40)
	
	var style = StyleBoxFlat.new()
	style.corner_radius_top_left = 100
	style.corner_radius_top_right = 100
	style.corner_radius_bottom_left = 100
	style.corner_radius_bottom_right = 100
	style.bg_color = Color(0.05, 0.1, 0.15)
	style.border_width_left = 6
	style.border_width_top = 6
	style.border_width_right = 6
	style.border_width_bottom = 6
	
	var pulse_effect = false
	
	# Establecer configuración visual según su estado investigador
	if status == "SOLVED":
		style.border_color = Color(0.1, 0.9, 0.4) # Verde cyber
		style.shadow_color = Color(0.1, 0.9, 0.4, 0.4)
		style.shadow_size = 15
	elif status == "ACTIVE":
		style.border_color = Color(1.0, 0.8, 0.2) # Amarillo alerta
		style.shadow_color = Color(1.0, 0.8, 0.2, 0.6)
		style.shadow_size = 20
		pulse_effect = true
	else:
		style.border_color = Color(0.3, 0.3, 0.3) # Gris bloqueado
	
	circle.add_theme_stylebox_override("panel", style)
	
	# Etiqueta de la información principal
	var lbl_name = Label.new()
	lbl_name.text = data.name
	lbl_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_name.position = Vector2(-100, 50)
	lbl_name.custom_minimum_size = Vector2(200, 0)
	
	var lbl_desc = Label.new()
	lbl_desc.text = data.desc if status != "LOCKED" else "[ENCRIPTADO]"
	lbl_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_desc.add_theme_color_override("font_color", Color(0.5, 0.6, 0.7))
	lbl_desc.position = Vector2(-100, 90)
	lbl_desc.custom_minimum_size = Vector2(200, 0)
	
	# Icono del circulo
	var lbl_icon = Label.new()
	lbl_icon.text = "✓" if status == "SOLVED" else ("!" if status == "ACTIVE" else "?")
	lbl_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl_icon.position = Vector2(-40, -40)
	lbl_icon.custom_minimum_size = Vector2(80, 80)
	lbl_icon.add_theme_font_size_override("font_size", 32)
	if status != "LOCKED":
		lbl_icon.add_theme_color_override("font_color", style.border_color)

	container.add_child(circle)
	container.add_child(lbl_icon)
	container.add_child(lbl_name)
	container.add_child(lbl_desc)
	
	# Efecto de pulsación rítmica si el nodo está activo
	if pulse_effect:
		var p_tween = create_tween().set_loops()
		p_tween.tween_property(circle, "scale", Vector2(1.1, 1.1), 0.8).set_trans(Tween.TRANS_SINE)
		p_tween.tween_property(circle, "scale", Vector2(1.0, 1.0), 0.8).set_trans(Tween.TRANS_SINE)

	return container