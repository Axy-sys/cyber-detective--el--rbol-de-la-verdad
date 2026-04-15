class_name CrimeNode
extends Object

# --- ATRIBUTOS DEL NODO (Árbol B) ---
# En un Árbol B, un nodo agrupa múltiples claves (en este caso, múltiples crímenes/evidencias)
# y tiene múltiples hijos (ramas).

var keys: Array = [] # Arreglo de diccionarios o estructuras con los datos del caso
var children: Array = [] # Arreglo de referencias a otros CrimeNode (Hijos)
var is_leaf: bool = true

func _init() -> void:
    keys = []
    children = []
    is_leaf = true

func has_children() -> bool:
    return children.size() > 0

func to_dict() -> Dictionary:
    var dict = {
        "keys": keys.duplicate(true),
        "is_leaf": is_leaf,
        "children": []
    }
    for child in children:
        dict["children"].append(child.to_dict())
    return dict

static func from_dict(dict: Dictionary) -> CrimeNode:
    var node = CrimeNode.new()
    node.keys = dict.get("keys", [])
    node.is_leaf = dict.get("is_leaf", true)
    if dict.has("children"):
        for child_dict in dict["children"]:
            node.children.append(CrimeNode.from_dict(child_dict))
    return node
