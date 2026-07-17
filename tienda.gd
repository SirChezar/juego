extends Control

const ESCENA_MENU := "res://menu_principal.tscn"

@onready var boton_volver: Button = $MargenSeguro/Centrador/Panel/Contenido/BotonVolver

func _ready():
	boton_volver.pressed.connect(_volver)
	boton_volver.grab_focus()

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		_volver()
		get_viewport().set_input_as_handled()

func _volver():
	get_tree().change_scene_to_file(ESCENA_MENU)
