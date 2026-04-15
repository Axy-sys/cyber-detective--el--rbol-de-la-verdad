class_name InvestigationTree
extends Object

# REFERENCIA A LA RAÍZ DEL ÁRBOL B
var root: CrimeNode = null
var t: int = 2 # Grado mínimo de nuestro Árbol B (Ej. 2 -> Almacena de 1 a 3 elementos por nodo)

# --- SEÑALES (Patrón Observer: Notificar a la Vista gráfica) ---
signal node_inserted(node)
signal tree_updated()

func _init() -> void:
	root = CrimeNode.new()
	root.is_leaf = true

# --- MÉTODO PARA INSERTAR UN NUEVO CASO (METODOLOGÍA B-TREE) ---
func insert_case(case_data: Dictionary) -> void:
	var r = root
	if r.keys.size() == (2 * t) - 1:
		# La raíz está llena, hay que dividirla (Split)
		var s = CrimeNode.new()
		s.is_leaf = false
		s.children.append(root)
		root = s
		_split_child(s, 0, r)
		_insert_non_full(s, case_data)
	else:
		_insert_non_full(r, case_data)
	
	emit_signal("node_inserted", case_data)
	emit_signal("tree_updated")

func _insert_non_full(x: CrimeNode, k: Dictionary) -> void:
	var i = x.keys.size() - 1
	if x.is_leaf:
		x.keys.append(k) # Agregamos un espacio para crecer el array
		while i >= 0 and k.severity < x.keys[i].severity:
			x.keys[i + 1] = x.keys[i]
			i -= 1
		x.keys[i + 1] = k
	else:
		while i >= 0 and k.severity < x.keys[i].severity:
			i -= 1
		i += 1
		if x.children[i].keys.size() == (2 * t) - 1:
			_split_child(x, i, x.children[i])
			if k.severity > x.keys[i].severity:
				i += 1
		_insert_non_full(x.children[i], k)

func _split_child(x: CrimeNode, i: int, y: CrimeNode) -> void:
	var z = CrimeNode.new()
	z.is_leaf = y.is_leaf
	
	# Mover las t-1 claves más grandes de y a z
	for j in range(t - 1):
		z.keys.append(y.keys[j + t])
		
	# Mover los hijos correspondientes de y a z
	if not y.is_leaf:
		for j in range(t):
			z.children.append(y.children[j + t])
			
	# Reducir el tamaño de y a t-1
	var median_key = y.keys[t - 1]
	var new_y_keys = []
	for j in range(t - 1):
		new_y_keys.append(y.keys[j])
	y.keys = new_y_keys
	
	var new_y_children = []
	if not y.is_leaf:
		for j in range(t):
			new_y_children.append(y.children[j])
	y.children = new_y_children
	
	# Insertar a z como hijo de x
	x.children.insert(i + 1, z)
	
	# Subir la clave mediana a x
	x.keys.insert(i, median_key)

# --- RECORRIDO IN-ORDER ---
func get_all_cases() -> Array:
	var result = []
	_in_order_traversal(root, result)
	return result

func _in_order_traversal(node: CrimeNode, result: Array) -> void:
	if node != null:
		var i = 0
		for k in node.keys:
			if not node.is_leaf:
				_in_order_traversal(node.children[i], result)
			result.append(k)
			i += 1
		if not node.is_leaf:
			_in_order_traversal(node.children[i], result)

func to_dict() -> Dictionary:
	return {
		"t": t,
		"root": root.to_dict()
	}

func from_dict(dict: Dictionary) -> void:
	if dict.has("t"):
		t = dict["t"]
	if dict.has("root"):
		root = CrimeNode.from_dict(dict["root"])
	emit_signal("tree_updated")
