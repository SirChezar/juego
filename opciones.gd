extends Control

const ESCENA_MENU := "res://menu_principal.tscn"

@onready var volumen: HSlider = $MargenSeguro/Centrador/Panel/Contenido/Volumen
@onready var valor_volumen: Label = $MargenSeguro/Centrador/Panel/Contenido/ValorVolumen
@onready var boton_volver: Button = $MargenSeguro/Centrador/Panel/Contenido/BotonVolver

func _ready():
	volumen.value_changed.connect(_cambiar_volumen)
	boton_volver.pressed.connect(_volver)
	var volumen_actual = 0.0 if AudioServer.is_bus_mute(0) else db_to_linear(AudioServer.get_bus_volume_db(0)) * 100.0
	volumen.value = volumen_actual
	_actualizar_valor(volumen_actual)
	volumen.grab_focus()

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		_volver()
		get_viewport().set_input_as_handled()

func _cambiar_volumen(nuevo_valor: float):
	var silenciado = nuevo_valor <= 0.0
	AudioServer.set_bus_mute(0, silenciado)
	if not silenciado:
		AudioServer.set_bus_volume_db(0, linear_to_db(nuevo_valor / 100.0))
	_actualizar_valor(nuevo_valor)

func _actualizar_valor(nuevo_valor: float):
	valor_volumen.text = "%d%%" % roundi(nuevo_valor)

func _volver():
	get_tree().change_scene_to_file(ESCENA_MENU)
