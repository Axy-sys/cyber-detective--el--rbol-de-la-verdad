class_name CentralOSView
extends Control

@onready var app_container = $MainLayout/AppContainer
@onready var btn_tree = $MainLayout/Sidebar/VBox/BtnTree
@onready var btn_evidence = $MainLayout/Sidebar/VBox/BtnEvidence
@onready var btn_chat = $MainLayout/Sidebar/VBox/BtnChat
@onready var btn_radar = $MainLayout/Sidebar/VBox/BtnRadar
@onready var global_progress = $MainLayout/Sidebar/VBox/GlobalProgressBox/GlobalProgress

var apps = {}
var current_app_name: String = ""

func _ready() -> void:
	print("Inicializando OS Persistente Multitarea...")
	
	btn_tree.connect("pressed", Callable(self, "_switch_app").bind("tree"))
	btn_evidence.connect("pressed", Callable(self, "_switch_app").bind("evidence"))
	btn_chat.connect("pressed", Callable(self, "_switch_app").bind("chat"))
	btn_radar.connect("pressed", Callable(self, "_switch_app").bind("radar"))
	
	# Pre-instanciar todas las aplicaciones para que vivan en segundo plano
	_preload_app("tree", "res://views/TreeScene.tscn")
	_preload_app("evidence", "res://views/EvidenceScene.tscn")
	_preload_app("chat", "res://views/ChatScene.tscn")
	_preload_app("radar", "res://views/ProgressScene.tscn")
	
	# Suscribirse a los cambios globales para la barra de tareas
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.connect("level_changed", Callable(self, "_update_global_progress"))
	_update_global_progress(gm.current_level if gm else 0)

	# Mostrar el chat por defecto al arrancar
	_switch_app("chat")

func _preload_app(app_name: String, scene_path: String) -> void:
	var app_scene = load(scene_path)
	if app_scene:
		var instance = app_scene.instantiate()
		app_container.add_child(instance)
		instance.visible = false # Ocultas por defecto
		
		# Ocupar todo el espacio
		if instance is Control:
			instance.set_anchors_preset(Control.PRESET_FULL_RECT)
			
		apps[app_name] = instance
		print("App precargada en memoria: ", app_name)

func _switch_app(app_name: String) -> void:
	if current_app_name == app_name:
		return # Ya estamos ahí
		
	# Ocultar la app activa
	if current_app_name != "" and apps.has(current_app_name):
		apps[current_app_name].visible = false
		
	# Mostrar la nueva app
	if apps.has(app_name):
		apps[app_name].visible = true
		current_app_name = app_name
		print("Cambiando vista a: ", app_name)

func _update_global_progress(_level) -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		global_progress.value = (float(gm.current_level) / 5.0) * 100.0
