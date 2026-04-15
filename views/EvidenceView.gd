class_name EvidenceView
extends Control

@onready var inv_list = $Panel/VBox/HBox/InvScroll/InvList
@onready var severity_slider = $Panel/VBox/HBox/Classification/Details/Sliders/Severity
@onready var label_ev_name = $Panel/VBox/HBox/Classification/Details/EvName
@onready var label_ev_desc = $Panel/VBox/HBox/Classification/Details/EvDesc

var selected_item_id: String = ""

func _ready() -> void:
	_refresh_inventory()
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.inventory.connect("evidence_added", Callable(self, "_on_evidence_added"))
		
	$Panel/VBox/HBox/Classification/Details/HBox/BtnLaw.pressed.connect(_on_classify_law)
	$Panel/VBox/HBox/Classification/Details/HBox/BtnCrime.pressed.connect(_on_classify_crime)

func _on_evidence_added(_data: Dictionary) -> void:
	_refresh_inventory()

func _refresh_inventory():
	for child in inv_list.get_children():
		child.queue_free()
		
	var gm = get_node_or_null("/root/GameManager")
	if not gm: return
	
	var items = gm.inventory.get_all_evidences()
	for item in items:
		var btn = Button.new()
		var is_classified = item.get("classified", false)
		var item_name = item.get("name", "Desconocido")
		btn.text = item_name + (" (Clasificado)" if is_classified else " (Pendiente)")
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.add_theme_color_override("font_color", Color(0, 0.8, 1, 1))
		
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.1, 0.15, 0.25, 0.8) if is_classified else Color(0.2, 0.2, 0.2, 0.8)
		style.corner_radius_top_left = 6
		style.corner_radius_top_right = 6
		style.corner_radius_bottom_right = 6
		style.corner_radius_bottom_left = 6
		btn.add_theme_stylebox_override("normal", style)
		
		btn.pressed.connect(func(): _select_item(item.get("id", ""), item_name, item.get("description", "")))
		inv_list.add_child(btn)

func _select_item(id: String, nom: String, desc: String):
	selected_item_id = id
	label_ev_name.text = nom
	label_ev_desc.text = desc

func _on_classify_law():
	_classify_evidence(false)

func _on_classify_crime():
	_classify_evidence(true)

func _classify_evidence(is_crime: bool):
	if selected_item_id == "":
		return
	
	var severity = int(severity_slider.value)
	var controller = get_node_or_null("/root/GameManager/DashboardController")
	if controller:
		controller.classify_evidence(selected_item_id, is_crime, severity)
		_refresh_inventory()
