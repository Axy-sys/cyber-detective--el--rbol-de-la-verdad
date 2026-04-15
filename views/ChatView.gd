class_name ChatView
extends Control

# --- VISTA: EL TELÉFONO DE ALEX CON RESPUESTAS INTERACTIVAS ---

@onready var chat_history: VBoxContainer = $ScrollContainer/VBoxContainer
@onready var bottom_bar: ColorRect = $BottomBar
@onready var btn_next: Button = $BottomBar/BtnSiguiente
@onready var fake_input: Label = $BottomBar/FakeInput
@onready var notification_label: Label = $NotificationLabel
@onready var contact_name_label: Label = $HeaderBar/ContactName

var chat_controller: Level1ChatController
var current_in_chat_options_node: Control = null

func _ready() -> void:
	chat_controller = Level1ChatController.new()
	add_child(chat_controller)
	
	# Ocultamos el botón viejo genérico
	btn_next.hide()
	
	# Conexiones
	chat_controller.connect("chat_updated", Callable(self, "_on_chat_updated"))
	chat_controller.connect("options_requested", Callable(self, "_show_player_options"))
	chat_controller.connect("evidence_received", Callable(self, "_on_evidence_received"))
	chat_controller.connect("level1_chat_finished", Callable(self, "_on_chat_finished"))
	
	notification_label.visible = false
	
	print("Iniciando chat automatizado...")
	chat_controller.start_chat()

# --- FUNCIONES DE LA VISTA (Dibujar Burbujas y Opciones) ---

func _show_player_options(options: Array) -> void:
	fake_input.hide()
	
	if is_instance_valid(current_in_chat_options_node):
		current_in_chat_options_node.queue_free()
		
	# Creamos un contenedor que se alinea a la derecha (estilo Alex) dentro del propio chat
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 60)
	margin.add_theme_constant_override("margin_right", 15)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	
	var title = Label.new()
	title.text = "Selecciona cómo responder:"
	title.add_theme_font_size_override("font_size", 12)
	title.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	vbox.add_child(title)
	
	for i in range(options.size()):
		var opt_btn = Button.new()
		# Mostramos el texto final directamente en el botón
		opt_btn.text = options[i].text
		opt_btn.custom_minimum_size = Vector2(250, 40)
		opt_btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		
		# Le damos un color azul oscuro interactivo para que se diferencie
		var style = StyleBoxFlat.new()
		style.bg_color = Color("#2b5278") 
		style.corner_radius_top_left = 12
		style.corner_radius_top_right = 12
		style.corner_radius_bottom_left = 12
		style.corner_radius_bottom_right = 12
		style.content_margin_left = 10
		style.content_margin_right = 10
		style.content_margin_top = 8
		style.content_margin_bottom = 8
		opt_btn.add_theme_stylebox_override("normal", style)
		
		var hover_style = style.duplicate()
		hover_style.bg_color = Color("#417dae") # Más claro al hacer hover
		opt_btn.add_theme_stylebox_override("hover", hover_style)
		opt_btn.add_theme_stylebox_override("pressed", hover_style)
		
		opt_btn.pressed.connect(Callable(self, "_on_option_selected").bind(i))
		vbox.add_child(opt_btn)
		
	margin.add_child(vbox)
	chat_history.add_child(margin)
	current_in_chat_options_node = margin
	
	await get_tree().process_frame
	var scroll = chat_history.get_parent() as ScrollContainer
	scroll.scroll_vertical = int(scroll.get_v_scroll_bar().max_value)

func _on_option_selected(index: int) -> void:
	if is_instance_valid(current_in_chat_options_node):
		current_in_chat_options_node.queue_free() # Borra de la pantalla los botones temporales de opciones
		
	fake_input.show()
	chat_controller.choose_option(index)

func _on_chat_updated(sender: String, text: String) -> void:
	var bubble_container = MarginContainer.new()
	bubble_container.add_theme_constant_override("margin_top", 5)
	bubble_container.add_theme_constant_override("margin_bottom", 5)
	bubble_container.add_theme_constant_override("margin_left", 15)
	bubble_container.add_theme_constant_override("margin_right", 15)
	
	var panel = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	
	var label = RichTextLabel.new()
	label.bbcode_enabled = true
	label.fit_content = true
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(250, 0)
	
	if sender == "Alex":
		style.bg_color = Color("#effedb") # Verde Telegram (Alex)
		panel.size_flags_horizontal = Control.SIZE_SHRINK_END
		label.text = "[color=black]" + text + "[/color]"
	elif sender == "Valeria":
		style.bg_color = Color("#ffffff") # Blanco (Valeria)
		panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		label.text = "[color=black]" + text + "[/color]"
	else:
		style.bg_color = Color("#4a000000") # Mensaje sistema
		panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		label.text = "[center][color=white][font_size=12]" + text + "[/font_size][/color][/center]"

	panel.add_theme_stylebox_override("panel", style)
	
	var margin_inner = MarginContainer.new()
	margin_inner.add_theme_constant_override("margin_top", 10)
	margin_inner.add_theme_constant_override("margin_bottom", 10)
	margin_inner.add_theme_constant_override("margin_left", 12)
	margin_inner.add_theme_constant_override("margin_right", 12)
	
	margin_inner.add_child(label)
	panel.add_child(margin_inner)
	bubble_container.add_child(panel)
	
	chat_history.add_child(bubble_container)
	
	await get_tree().process_frame
	var scroll = chat_history.get_parent() as ScrollContainer
	scroll.scroll_vertical = int(scroll.get_v_scroll_bar().max_value)

func _on_evidence_received(attachment_data: Dictionary) -> void:
	notification_label.text = "¡NUEVA PISTA!\n" + attachment_data.name + " AÑADIDA"
	notification_label.visible = true
	var tween = create_tween()
	tween.tween_property(notification_label, "modulate:a", 1.0, 0.2)
	tween.tween_property(notification_label, "modulate:a", 0.0, 2.0).set_delay(2.0)

func _on_chat_finished() -> void:
	fake_input.hide()
	$HeaderBar/ContactStatus.text = "últ. vez hace un momento"
