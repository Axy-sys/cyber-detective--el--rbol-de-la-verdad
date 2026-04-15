class_name InventoryModel
extends Object

# --- MODELO: Inventario de Evidencias ---
# Almacena las pistas que el jugador recolecta durante el chat y la exploración.

var collected_evidences: Array = []

# --- SEÑALES (Observer) ---
signal evidence_added(evidence_data)

func add_evidence(data: Dictionary) -> void:
	collected_evidences.append(data)
	print("Evidencia añadida al inventario: ", data.name)
	emit_signal("evidence_added", data)

func get_all_evidences() -> Array:
	return collected_evidences

func has_evidence(id: String) -> bool:
	for ev in collected_evidences:
		if ev.id == id:
			return true
	return false

func to_dict() -> Dictionary:
	return {
		"collected_evidences": collected_evidences.duplicate(true)
	}

func from_dict(dict: Dictionary) -> void:
	if dict.has("collected_evidences"):
		collected_evidences = dict["collected_evidences"].duplicate(true)
		for ev in collected_evidences:
			emit_signal("evidence_added", ev)
