extends Control

const ESCENA_JUEGO := "res://node_2d.tscn"
const ESCENA_TIENDA := "res://tienda.tscn"
const ESCENA_OPCIONES := "res://opciones.tscn"

@onready var boton_jugar: Button = $MargenSeguro/Centrador/Panel/Contenido/BotonJugar
@onready var boton_tienda: Button = $MargenSeguro/Centrador/Panel/Contenido/BotonTienda
@onready var boton_opciones: Button = $MargenSeguro/Centrador/Panel/Contenido/BotonOpciones

var cambiando_escena := false

func _ready():
	boton_jugar.pressed.connect(func(): _cambiar_escena(ESCENA_JUEGO))
	boton_tienda.pressed.connect(func(): _cambiar_escena(ESCENA_TIENDA))
	boton_opciones.pressed.connect(func(): _cambiar_escena(ESCENA_OPCIONES))
	boton_jugar.grab_focus()

func _cambiar_escena(ruta: String):
	if cambiando_escena:
		return

	cambiando_escena = true
	var salida = create_tween()
	salida.tween_property(self, "modulate:a", 0.0, 0.2)
	await salida.finished

	var error = get_tree().change_scene_to_file(ruta)
	if error != OK:
		modulate.a = 1.0
		cambiando_escena = false
