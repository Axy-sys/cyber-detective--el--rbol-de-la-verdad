class_name PrologueController
extends Node

# --- ESTRUCTURAS DE DATOS: Array/Lista de Correos Electrónicos ---
# Simulamos la bandeja de entrada del detective (Prólogo y Mini-tutorial)
var email_inbox: Array = [
	{
		"from": "director.operaciones@netcity.gov",
		"to": "alex.investigador@netcity.gov",
		"subject": "ASIGNACIÓN URGENTE: Caso de Ciberacoso - Valeria",
		"body": "Alex,\n\nTe asigno un caso crítico. La víctima es Valeria, una estudiante de la ciudad. Empezó recibiendo mensajes que parecían bromas, pero el acoso ha escalado rápidamente. Su vida personal y académica se está desmoronando.\n\nEsta vez no usaremos el archivo lineal. Te he habilitado el nuevo sistema 'Cyber-Tree'. Es nuestra herramienta experimental que organiza los crímenes de forma jerárquica para encontrar al principal agresor."
	},
	{
		"from": "director.operaciones@netcity.gov",
		"to": "alex.investigador@netcity.gov",
		"subject": "RE: Instrucciones del sistema Cyber-Tree",
		"body": "A modo de recordatorio, aquí tienes cómo proceder:\n\n1. RECOLECCIÓN: Accederé tu terminal al chat seguro de la víctima. Ella te enviará imágenes y perfiles. Extrae y adjunta esas pistas a tu inventario.\n\n2. CLASIFICACIÓN: Revisa el Código Penal Colombiano y la Ley 1273. Cada pista representa un delito (Injuria, Calumnia, Suplantación...). Debes vincular la evidencia al delito correcto.\n\n3. EL ÁRBOL: Una vez clasificado, asígnale un 'Nivel de Gravedad'. El sistema insertará un Nuevo Nodo en tu panel. Si lo haces bien, nuestro algoritmo (el árbol) organizará los casos para revelar el patrón criminal.\n\nEmpieza por lo básico, busca el origen de los mensajes ofensivos."
	},
	{
		"from": "sistema.seguridad@netcity.gov",
		"to": "alex.investigador@netcity.gov",
		"subject": "[SISTEMA] Enlace de comunicación establecido",
		"body": "Túnel encriptado P2P activado con éxito.\n\nHaz clic en CONTINUAR para iniciar la interfaz de CHAT DIRECTO con el dispositivo de la víctima [Valeria].\n\nEl Tablero de Investigación en segundo plano ha sido inicializado."
	}
]

var current_email_index: int = 0

# --- SEÑALES (Patrón Observer) ---
signal email_opened(email_data)
signal prologue_finished()

func _ready() -> void:
	pass

func start_prologue() -> void:
	current_email_index = 0
	_show_current_email()

func next_email() -> void:
	current_email_index += 1
	if current_email_index < email_inbox.size():
		_show_current_email()
	else:
		_end_prologue()

func _show_current_email() -> void:
	var current_email = email_inbox[current_email_index]
	emit_signal("email_opened", current_email)
	
func _end_prologue() -> void:
	emit_signal("prologue_finished")
	print("Prólogo finalizado. Transición al Chat con Valeria (Nivel 1).")
