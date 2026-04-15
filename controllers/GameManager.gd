extends Node

# --- PATRÓN SINGLETON (Autoload en Godot) ---
# Este script controlará el estado global del juego y los niveles ("Capas del Acoso")

enum GameLevel {
	PROLOGUE = 0,
	LEVEL_1_INJURIA = 1,
	LEVEL_2_CALUMNIA = 2,
	LEVEL_3_SUPLANTACION = 3,
	LEVEL_4_ACOSO = 4,
	FINAL_REPORT = 5
}

var current_level: GameLevel = GameLevel.PROLOGUE
var investigation_tree: InvestigationTree = null
var inventory: InventoryModel = null

# Señales para notificar a la interfaz
signal level_changed(new_level)
signal game_completed()

func _ready() -> void:
	print("GameManager Inicializado. Iniciando Cyber Detective: El Árbol de la Verdad.")
	investigation_tree = InvestigationTree.new()
	inventory = InventoryModel.new()
	
	# Connect to save the game automatically when items change
	investigation_tree.connect("tree_updated", Callable(self, "save_game"))
	inventory.connect("evidence_added", Callable(self, "_on_evidence_added"))
	
	load_game() # Automatically load progress if it exists
	
func _on_evidence_added(_data: Dictionary) -> void:
	save_game()
	
func start_game() -> void:
	current_level = GameLevel.LEVEL_1_INJURIA
	emit_signal("level_changed", current_level)
	save_game()

func save_game() -> void:
	var save_dict = {
		"current_level": current_level,
		"investigation_tree": investigation_tree.to_dict(),
		"inventory": inventory.to_dict()
	}
	var save_file = FileAccess.open("user://savegame.json", FileAccess.WRITE)
	if save_file:
		save_file.store_string(JSON.stringify(save_dict, "\t"))
		print("Juego guardado correctamente.")

func load_game() -> void:
	if not FileAccess.file_exists("user://savegame.json"):
		print("No hay partida guardada previa.")
		return
	
	var save_file = FileAccess.open("user://savegame.json", FileAccess.READ)
	if save_file:
		var json_string = save_file.get_as_text()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			var data = json.get_data()
			if typeof(data) == TYPE_DICTIONARY:
				current_level = data.get("current_level", GameLevel.PROLOGUE)
				if data.has("investigation_tree"):
					investigation_tree.from_dict(data["investigation_tree"])
				if data.has("inventory"):
					inventory.from_dict(data["inventory"])
				print("Partida cargada exitosamente.")
	print("Nivel 1 Inciado: Las primeras señales.")

func advance_level() -> void:
	if current_level < GameLevel.FINAL_REPORT:
		current_level += 1
		emit_signal("level_changed", current_level)
		print("Avanzando a Nivel: ", current_level)
		save_game()
		
		if current_level == GameLevel.FINAL_REPORT:
			generate_final_report()
	else:
		print("El juego ya ha terminado.")

func add_case_to_tree(case_data: Dictionary) -> void:
	if investigation_tree != null:
		investigation_tree.insert_case(case_data)
		# Nota: Árbol B maneja división de nodos internamente

func generate_final_report() -> void:
	print("--- REPORTE FINAL DEL CASO ---")
	var all_cases = investigation_tree.get_all_cases()
	
	if all_cases.size() == 0:
		print("No se encontraron evidencias. El agresor escapó.")
		return
		
	for crime in all_cases:
		print("Caso: ", crime["harassment_type"])
		print("Ley Aplicada: ", crime["colombian_law"])
		print("Pena: ", crime["penalty"])
		print("Gravedad: ", crime["severity"])
		print("-")
	
	emit_signal("game_completed")
