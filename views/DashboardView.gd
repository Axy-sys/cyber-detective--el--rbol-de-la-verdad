class_name DashboardView
extends Control

@onready var tree_canvas = $Background/TreeScroll/TreeCanvas
@onready var ev_container = $HUD/LeftPanel/Scroll/VBox/EvidenceList
@onready var lbl_selected_ev = $HUD/BottomPanel/HBox/Col1/LblSelected
@onready var crime_container = $HUD/BottomPanel/HBox/Col2/GridCrime
@onready var law_container = $HUD/BottomPanel/HBox/Col3/GridLaw
@onready var slider_sev = $HUD/BottomPanel/HBox/Col4/SliderSev
@onready var lbl_sev_val = $HUD/BottomPanel/HBox/Col4/LblSevVal
@onready var btn_link = $HUD/BottomPanel/HBox/Col5/BtnLink
@onready var lbl_feedback = $HUD/TopBar/LblFeedback

var dashboard_controller: DashboardController
var inv_model: InventoryModel
var tree_model: InvestigationTree

var selected_evidence_id: String = ""
var crime_group: ButtonGroup = ButtonGroup.new()
var law_group: ButtonGroup = ButtonGroup.new()

var dragging_tree: bool = false
var last_mouse_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	dashboard_controller = DashboardController.new()
	add_child(dashboard_controller)

	var gm = get_node_or_null("/root/GameManager")
	if gm and gm.investigation_tree:
		tree_model = gm.investigation_tree
	else:
		tree_model = InvestigationTree.new()
		
	if gm and gm.inventory:
		inv_model = gm.inventory
	else:
		inv_model = InventoryModel.new()

	dashboard_controller.setup_dashboard(tree_model, inv_model)
	
	dashboard_controller.connect("evidence_classified_correctly", Callable(self, "_on_correct"))
	dashboard_controller.connect("evidence_classified_incorrectly", Callable(self, "_on_error"))
	dashboard_controller.connect("tree_visually_updated", Callable(self, "_draw_tree"))

	btn_link.connect("pressed", Callable(self, "_on_link_pressed"))
	slider_sev.connect("value_changed", Callable(self, "_on_slider_changed"))

	_setup_ui()
	_draw_tree()

func _setup_ui() -> void:
	# Setup Evidence
	for child in ev_container.get_children():
		child.queue_free()
		
	if inv_model.collected_evidences.size() == 0:
		var empty_lbl = Label.new()
		empty_lbl.text = "SISTEMA EN ESPERA...\n\nNo hay evidencia transferida."
		empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_lbl.add_theme_color_override("font_color", Color(0.4, 0.8, 0.4, 0.7))
		empty_lbl.custom_minimum_size = Vector2(0, 100)
		empty_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		ev_container.add_child(empty_lbl)
		
	for ev in inv_model.collected_evidences:
		var btn = Button.new()
		btn.text = "📄 " + ev.name
		btn.custom_minimum_size = Vector2(0, 50)
		btn.connect("pressed", Callable(self, "_on_evidence_selected").bind(ev, btn))
		ev_container.add_child(btn)

	# Setup Crime Buttons
	_create_toggle_buttons(crime_container, ["Injuria", "Calumnia", "Suplantación", "Acoso Coordinado"], crime_group)
	
	# Setup Law Buttons
	_create_toggle_buttons(law_container, ["Articulo_220_Codigo_Penal", "Ley_1273_Delitos_Informaticos", "Articulo_221_Codigo_Penal"], law_group)

func _create_toggle_buttons(parent: Control, items: Array, group: ButtonGroup) -> void:
	for item in items:
		var btn = Button.new()
		btn.text = item
		btn.toggle_mode = true
		btn.button_group = group
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		parent.add_child(btn)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE or event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				dragging_tree = true
				last_mouse_pos = event.position
			else:
				dragging_tree = false
	
	if event is InputEventMouseMotion and dragging_tree:
		var scroll = $Background/TreeScroll
		var delta = last_mouse_pos - event.position
		scroll.scroll_horizontal += int(delta.x)
		scroll.scroll_vertical += int(delta.y)
		last_mouse_pos = event.position

func _on_evidence_selected(ev: Dictionary, sender: Button) -> void:
	selected_evidence_id = ev.id
	lbl_selected_ev.text = ev.name
	_flash_control(lbl_selected_ev)
	
	# Resaltar la evidencia activa
	for btn in ev_container.get_children():
		if btn == sender:
			btn.modulate = Color(0.2, 1.0, 1.0, 1.0)
		else:
			btn.modulate = Color(0.6, 0.6, 0.6, 1.0)

func _on_slider_changed(val: float) -> void:
	lbl_sev_val.text = "Nivel: " + str(val)
	var color = Color(1, 1-val/10.0, 0)
	lbl_sev_val.add_theme_color_override("font_color", color)

func _on_link_pressed() -> void:
	if selected_evidence_id == "":
		_on_error("Selecciona una evidencia primero.")
		return
		
	var crime_btn = crime_group.get_pressed_button()
	var law_btn = law_group.get_pressed_button()
	
	if not crime_btn or not law_btn:
		_on_error("Faltan parámetros (Delito o Ley).")
		return
		
	dashboard_controller.classify_evidence(
		selected_evidence_id,
		crime_btn.text,
		law_btn.text,
		int(slider_sev.value)
	)

func _on_correct(node: Dictionary) -> void:
	lbl_feedback.text = "[ SISTEMA ] CONEXIÓN ESTABLECIDA: " + node["harassment_type"]
	lbl_feedback.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4))
	selected_evidence_id = ""
	lbl_selected_ev.text = "Ninguna"
	_flash_control(lbl_feedback)
	
	# Efecto de destello verde en el HUD superior
	var tw = create_tween()
	var top_bar = $HUD/TopBar
	top_bar.modulate = Color(1.5, 2.0, 1.5, 1)
	tw.tween_property(top_bar, "modulate", Color.WHITE, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# Deseleccionar botones de evidencia
	for btn in ev_container.get_children():
		btn.modulate = Color.WHITE
		if btn.text.contains(node["evidences"][0]):
			btn.queue_free()

func _on_error(msg: String) -> void:
	lbl_feedback.text = "[ ERROR ] " + msg
	lbl_feedback.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
	_flash_control(lbl_feedback)
	_shake_control($HUD/BottomPanel)

func _shake_control(ctrl: Control) -> void:
	var tw = create_tween()
	var original_pos = ctrl.position
	var offset = 10.0
	for i in range(4):
		tw.tween_property(ctrl, "position:x", original_pos.x + offset, 0.05)
		tw.tween_property(ctrl, "position:x", original_pos.x - offset, 0.05)
	tw.tween_property(ctrl, "position:x", original_pos.x, 0.05)

func _flash_control(ctrl: Control) -> void:
	var tw = create_tween()
	ctrl.modulate = Color(2, 2, 2, 1)
	tw.tween_property(ctrl, "modulate", Color(1, 1, 1, 1), 0.4)

func _draw_tree() -> void:
	for child in tree_canvas.get_children():
		child.queue_free()
		
	var root = tree_model.root
	if root != null:
		_draw_node_recursive(root, Vector2(1200, 150), 500)

func _draw_node_recursive(node: CrimeNode, pos: Vector2, x_offset: float) -> void:
	if not node.is_leaf:
		var children_count = node.children.size()
		# Ajustar distribución de las líneas de los hijos
		var start_x = -((children_count - 1) * x_offset) / 2.0
		for i in range(children_count):
			var child_pos = pos + Vector2(start_x + (i * x_offset), 200)
			_create_line(pos, child_pos)
			_draw_node_recursive(node.children[i], child_pos, x_offset / 1.5)

	var panel = PanelContainer.new()
	var keys_count = node.keys.size()
	if keys_count == 0:
		return

	panel.position = pos - Vector2(100 * keys_count, 60)
	panel.custom_minimum_size = Vector2(200 * keys_count, 120)
	panel.pivot_offset = Vector2(100 * keys_count, 60)

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.1, 0.15, 0.95)
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.border_color = Color(0.0, 0.8, 1.0, 0.9)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_right = 12
	style.corner_radius_bottom_left = 12
	style.shadow_color = Color(0.0, 0.5, 0.8, 0.4)
	style.shadow_size = 15
	panel.add_theme_stylebox_override("panel", style)
	
	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 20)

	for k in node.keys:
		var vbox = VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	
		var lbl_title = Label.new()
		lbl_title.text = "[ " + str(k["harassment_type"]).to_upper() + " ]"
		lbl_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl_title.add_theme_font_size_override("font_size", 18)
		lbl_title.add_theme_color_override("font_color", Color(0.8, 0.95, 1.0))
	
		var lbl_sev = Label.new()
		lbl_sev.text = "GRAVEDAD: " + str(k["severity"])
		lbl_sev.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl_sev.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
		lbl_sev.add_theme_font_size_override("font_size", 14)
	
		var hz = HSeparator.new()
		var style_sep = StyleBoxLine.new()
		style_sep.color = Color(0.0, 0.8, 1.0, 0.3)
		hz.add_theme_stylebox_override("separator", style_sep)
	
		vbox.add_child(lbl_title)
		vbox.add_child(hz)
		vbox.add_child(lbl_sev)
		hbox.add_child(vbox)
		
		# Agrega un separador vertical si no es el último (para simular ranuras)
		if node.keys.find(k) < keys_count - 1:
			var vs = VSeparator.new()
			var style_vsep = StyleBoxLine.new()
			style_vsep.color = Color(0.0, 0.6, 0.8, 0.5)
			style_vsep.vertical = true
			vs.add_theme_stylebox_override("separator", style_vsep)
			hbox.add_child(vs)

	panel.add_child(hbox)
	tree_canvas.add_child(panel)

	# Animación Dinámica (Popping)
	panel.scale = Vector2.ZERO
	panel.modulate = Color(1.5, 1.5, 2.0, 1.0)
	var tw = create_tween()
	tw.tween_property(panel, "scale", Vector2(1.1, 1.1), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(panel, "modulate", Color.WHITE, 0.6)
	tw.chain().tween_property(panel, "scale", Vector2.ONE, 0.15)

func _create_line(from: Vector2, to: Vector2) -> void:
	var path = Path2D.new()
	var curve = Curve2D.new()
	
	# Añadimos puntos para una curva Bezier suave
	curve.add_point(from, Vector2.ZERO, Vector2(0, 80))
	curve.add_point(to, Vector2(0, -80), Vector2.ZERO)
	path.curve = curve
	
	var line = Line2D.new()
	line.width = 4.0
	line.default_color = Color(0.0, 0.8, 1.0, 0.6)
	line.texture_mode = Line2D.LINE_TEXTURE_NONE
	line.points = curve.get_baked_points()
	
	tree_canvas.add_child(line)

	# Animación dinámica (dibujando la línea de arriba a abajo)
	var tw = create_tween()
	var final_points = line.points.duplicate()
	line.points = PackedVector2Array([from, from]) # Inicia con solo el primer punto
	
	# Usando tween_method para ir agregando puntos a la Line2D gradualmente
	tw.tween_method(Callable(self, "_animate_line_drawing").bind(line, final_points), 0.0, 1.0, 0.5).set_trans(Tween.TRANS_SINE)

func _animate_line_drawing(progress: float, line: Line2D, final_points: PackedVector2Array) -> void:
	var idx = int(progress * float(final_points.size() - 1))
	idx = max(1, idx) # Al menos 2 puntos para dibujar
	if idx < final_points.size():
		var current_pts = final_points.slice(0, idx + 1)
		line.points = current_pts
