class_name TreeView
extends Control

@onready var tree_scroll = $TreeScroll
@onready var tree_canvas = $TreeScroll/TreeCanvas

var tree_model: InvestigationTree
var dragging_tree: bool = false
var last_mouse_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm and gm.investigation_tree:
		tree_model = gm.investigation_tree
		tree_model.connect("tree_updated", Callable(self, "_draw_tree"))
	_draw_tree()

func _draw_tree() -> void:
	for child in tree_canvas.get_children():
		child.queue_free()
		
	if tree_model and tree_model.root:
		_draw_node_recursive(tree_model.root, Vector2(1500, 200), 500)

func _draw_node_recursive(node: CrimeNode, pos: Vector2, horizontal_spacing: float) -> void:
	var container = PanelContainer.new()
	container.position = pos - Vector2(125, 30)
	container.custom_minimum_size = Vector2(250, 60)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.06, 0.1, 0.95)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.0, 0.6, 0.8, 0.8)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_right = 12
	style.corner_radius_bottom_left = 12
	style.shadow_color = Color(0.0, 0.8, 1.0, 0.2)
	style.shadow_size = 10
	container.add_theme_stylebox_override("panel", style)
	
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	for k in node.keys:
		var lbl = Label.new()
		lbl.text = "◆ [" + str(k.get("severity", 0)) + "] " + str(k.get("id", "Caso")).to_upper()
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0))
		lbl.add_theme_font_size_override("font_size", 14)
		vbox.add_child(lbl)
	
	container.add_child(vbox)
	tree_canvas.add_child(container)
	
	# Animación
	container.scale = Vector2.ZERO
	container.pivot_offset = Vector2(125, 30)
	var tween = create_tween()
	tween.tween_property(container, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	if not node.is_leaf:
		var num_children = node.children.size()
		var start_x = pos.x - (horizontal_spacing * (num_children - 1) / 2.0)
		var y_offset = 180.0
		
		for i in range(num_children):
			var child_pos = Vector2(start_x + (i * horizontal_spacing), pos.y + y_offset)
			_create_line(pos + Vector2(0, 30), child_pos - Vector2(0, 30))
			_draw_node_recursive(node.children[i], child_pos, horizontal_spacing / 1.8)

func _create_line(p1: Vector2, p2: Vector2) -> void:
	var line = Line2D.new()
	var path = Curve2D.new()
	path.add_point(p1)
	var ctrl_offset = Vector2(0, abs(p2.y - p1.y) * 0.4)
	path.add_point(p1 + ctrl_offset, -ctrl_offset, ctrl_offset)
	path.add_point(p2, -ctrl_offset, ctrl_offset)
	
	var points = path.tessellate()
	for p in points:
		line.add_point(p)
		
	line.width = 3.0
	line.default_color = Color(0.1, 0.4, 0.6, 0.6)
	line.z_index = -1
	tree_canvas.add_child(line)

func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
		
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE or event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				dragging_tree = true
				last_mouse_pos = event.position
			else:
				dragging_tree = false
	
	if event is InputEventMouseMotion and dragging_tree:
		var delta = last_mouse_pos - event.position
		tree_scroll.scroll_horizontal += int(delta.x)
		tree_scroll.scroll_vertical += int(delta.y)
		last_mouse_pos = event.position
