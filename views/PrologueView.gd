class_name PrologueView
extends Control

# --- VISTA: GMAIL CLONE ---
# Interfaz principal simulando ser el cliente de correo CyberMail de Alex.

@onready var lbl_subject = $VBoxMain/Workspace/EmailContainer/EmailCard/Margin/VBox/SubjectLabel
@onready var lbl_sender_name = $VBoxMain/Workspace/EmailContainer/EmailCard/Margin/VBox/SenderBox/SenderDetails/NameHBox/NameLabel
@onready var lbl_sender_email = $VBoxMain/Workspace/EmailContainer/EmailCard/Margin/VBox/SenderBox/SenderDetails/NameHBox/EmailLabel
@onready var lbl_avatar = $VBoxMain/Workspace/EmailContainer/EmailCard/Margin/VBox/SenderBox/Avatar/Label
@onready var rtb_body = $VBoxMain/Workspace/EmailContainer/EmailCard/Margin/VBox/BodyText
@onready var btn_next = $VBoxMain/Workspace/EmailContainer/EmailCard/Margin/VBox/ActionBox/BtnSiguiente

var prologue_controller: PrologueController

func _ready() -> void:
	prologue_controller = PrologueController.new()
	add_child(prologue_controller)

	prologue_controller.connect("email_opened", Callable(self, "_on_email_opened"))
	prologue_controller.connect("prologue_finished", Callable(self, "_on_prologue_finished"))

	btn_next.connect("pressed", Callable(prologue_controller, "next_email"))

	prologue_controller.start_prologue()

func _on_email_opened(email_data: Dictionary) -> void:
	lbl_subject.text = email_data.subject
	
	# Extraer nombre del correo
	var sender_str = email_data.from.split("@")[0].replace(".", " ").capitalize()
	lbl_sender_name.text = sender_str
	lbl_sender_email.text = "<" + email_data["from"] + ">"
	lbl_avatar.text = sender_str.substr(0, 1).to_upper()
	
	rtb_body.text = email_data.body

	var emails_left = prologue_controller.email_inbox.size() - prologue_controller.current_email_index
	if emails_left > 1:
		btn_next.text = "Leer Siguiente ->"
	else:
		btn_next.text = "Continuar..."

func _on_prologue_finished() -> void:
	btn_next.text = "INICIAR CONEXIÓN SEGURA"
	btn_next.disconnect("pressed", Callable(prologue_controller, "next_email"))
	btn_next.connect("pressed", Callable(self, "_start_level_1"))

func _start_level_1() -> void:
	print("Abriendo la escena del Teléfono/Chat (Nivel 1)...")
	get_tree().change_scene_to_file("res://views/ChatScene.tscn")
