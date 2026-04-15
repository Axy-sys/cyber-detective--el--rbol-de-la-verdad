class_name Level1ChatController
extends Node

# --- ESTRUCTURA: Máquina de estados para un chat automatizado y con opciones ---
var chat_sequence: Array = [
	{"sender": "Valeria", "text": "Hola, ¿eres Alex? Me dijeron del departamento que me ayudarías...", "delay": 1.0},
	{"sender": "CHOICE", "options": [
		{"label": "Hola Valeria. Soy Alex. Cuéntame.", "text": "Hola Valeria. Soy Alex. Estoy aquí para investigar tu caso y detener esto. Cuéntame desde el principio."},
		{"label": "Sí, soy el detective. ¿Qué pasó?", "text": "Alex al habla. Eres la víctima del caso de acoso, ¿correcto? Relátame los hechos."}
	]},
	{"sender": "Valeria", "text": "Todo empezó hace unas semanas. Alguien publicaba bromas sobre mí en el muro escolar...", "delay": 1.5},
	{"sender": "Valeria", "text": "Se burlan de mí, de cómo visto y hacen chistes feos. Ya no quiero ir a clase.", "delay": 2.5},
	{"sender": "CHOICE", "options": [
		{"label": "¿Alcanzaste a tomar captura?", "text": "¿Alcanzaste a tomar captura de pantalla de alguno de esos mensajes antes de que los borraran?"},
		{"label": "¿Lograste ver quién fue?", "text": "¿Tienes los nombres de los perfiles que publicaron esos insultos?"}
	]},
	{
		"sender": "Valeria", 
		"text": "Sí, alcancé a guardar varias cosas antes de bloquear los perfiles. Aquí te paso la primera publicación.",
		"delay": 1.5,
		"attachment": {
			"id": "ev_01_injuria",
			"name": "Captura_Insultos.jpg",
			"desc": "Mensajes amenazantes que dañan el buen nombre.",
			"clue": "Usuario 'NinjaHater' dice cosas falsas y despectivas sobre Valeria."
		}
	},
	{"sender": "CHOICE", "options": [
		{"label": "Entendido. Iniciaré el trazado.", "text": "Recibido. Esto es material suficiente para el Nodo Inicial. Afectar públicamente el buen nombre es un delito en Colombia."}
	]},
	{"sender": "SYSTEM", "text": "[EVIDENCIA EN LA BANDEJA. PRESIONA 'IR AL TABLERO' PARA CLASIFICAR]", "delay": 2.0}
]

var current_step_index: int = 0
var inventory: InventoryModel = null

# --- SEÑALES (Patrón Observer) ---
signal chat_updated(sender, text)
signal options_requested(options_array)
signal evidence_received(attachment_data)
signal level1_chat_finished()

func _ready() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm and gm.inventory:
		inventory = gm.inventory
	else:
		inventory = InventoryModel.new()

func start_chat() -> void:
	current_step_index = 0
	_process_current_step()

func _process_current_step() -> void:
	if current_step_index >= chat_sequence.size():
		emit_signal("level1_chat_finished")
		return
		
	var step = chat_sequence[current_step_index]
	
	if step.sender == "CHOICE":
		# Es turno de que el jugador elija
		emit_signal("options_requested", step.options)
	else:
		# Es un mensaje automático de Valeria o del Sistema
		var delay_time = step.get("delay", 1.5)
		# Esperamos el tiempo definido antes de mostrar el mensaje
		await get_tree().create_timer(delay_time).timeout
		
		# Enviamos el mensaje a la vista
		emit_signal("chat_updated", step.sender, step.text)
		
		# Si hay evidencia adjunta, la inyectamos en el modelo MVC
		if step.has("attachment"):
			var clue_data = step.attachment
			inventory.add_evidence(clue_data)
			emit_signal("evidence_received", clue_data)
			
		# Pasamos automáticamente al siguiente paso
		current_step_index += 1
		_process_current_step()

# --- INPUT DEL JUGADOR ---
func choose_option(option_index: int) -> void:
	var step = chat_sequence[current_step_index]
	var chosen = step.options[option_index]
	
	# Mostramos en pantalla el mensaje completo que eligió Alex
	emit_signal("chat_updated", "Alex", chosen.text)
	
	# Avanzamos
	current_step_index += 1
	_process_current_step()

