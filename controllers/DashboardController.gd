class_name DashboardController
extends Node

# --- CONTROLADOR DEL TABLERO CIBERNÉTICO (MVC) ---
# Maneja la lógica de clasificación de evidencias y la creación de nodos en el Árbol AVL.

var investigation_tree: InvestigationTree = null
var inventory: InventoryModel = null

# --- SEÑALES (Observer para la Vista UI) ---
signal evidence_classified_correctly(case_node)
signal evidence_classified_incorrectly(error_msg)
signal tree_visually_updated()

func _ready() -> void:
	pass

# Función para inyectar las dependencias (Patrón Inyección de Dependencias)
func setup_dashboard(tree: InvestigationTree, inv: InventoryModel) -> void:
	investigation_tree = tree
	inventory = inv

# --- MECÁNICA PRINCIPAL: CLASIFICAR EVIDENCIA (Mini-juego) ---
# El jugador selecciona una evidencia del inventario, escoge el delito asociado,
# la ley que aplica y define la gravedad. El sistema evalúa si es correcto.
func classify_evidence(evidence_id: String, selected_crime: String, selected_law: String, assigned_severity: int) -> void:
	if not inventory.has_evidence(evidence_id):
		emit_signal("evidence_classified_incorrectly", "No tienes esa evidencia en tu inventario.")
		return
	
	# --- VALIDACIÓN DEL NIVEL 1 (Injuria - Atacando las primeras señales) ---
	if evidence_id == "ev_01_injuria":
		if selected_crime == "Injuria" and selected_law == "Articulo_220_Codigo_Penal":
			if assigned_severity >= 1 and assigned_severity <= 3: # Gravedad leve
				print("Clasificación Correcta: Es Injuria por afectación al buen nombre.")
				
				# 1. Recuperar la evidencia de nuestro inventario (Estructura de Datos)
				var evidence_data = _get_evidence_data(evidence_id)
				
				# 2. Preparar los datos del nodo (B-Tree inserta diccionarios)
				var penalty = "Multa o sanciones legales por afectar el buen nombre."
				var case_data = {
					"id": 101,
					"harassment_type": selected_crime,
					"evidences": [evidence_data.name],
					"colombian_law": selected_law,
					"penalty": penalty,
					"severity": assigned_severity # Criterio de ordenamiento
				}
				
				# 3. Insertar el caso en el Árbol B
				investigation_tree.insert_case(case_data)
				
				# 4. Notificar a la Vista para que dibuje el nodo y avance de nivel
				emit_signal("evidence_classified_correctly", case_data)
				emit_signal("tree_visually_updated")
				
				# Marcar evidencia como "usada"
				_mark_evidence_as_used(evidence_id)
				
			else:
				emit_signal("evidence_classified_incorrectly", "La gravedad asignada no es correcta. La injuria simple es un delito de gravedad baja (1-3).")
		else:
			emit_signal("evidence_classified_incorrectly", "Clasificación incorrecta. Revisa el Artículo 220 sobre afectación a la integridad moral.")
	
	# Aquí se añadirían las validaciones para ev_02 (Calumnia), ev_03 (Suplantación), etc.

# --- MÉTODOS AUXILIARES ---
func _get_evidence_data(id: String) -> Dictionary:
	for ev in inventory.collected_evidences:
		if ev.id == id:
			return ev
	return {}

func _mark_evidence_as_used(_id: String) -> void:
	# En una implementación real, se cambiaría el estado a "clasificada"
	# o se removería de la lista visible de "Pistas pendientes".
	pass
