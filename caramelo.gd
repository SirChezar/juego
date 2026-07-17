extends Node2D

signal llego_al_contador

const TEXTURA = preload("res://caramelo.svg")
const TIEMPO_EN_EL_SUELO := 0.65
const DURACION_VUELO := 0.6
const ESCALA_OBJETO := 0.48

var tiempo := 0.0
var origen_global := Vector2.ZERO
var punto_de_salida := Vector2.ZERO
var destino_global := Vector2.ZERO
var impulso_horizontal := 0.0
var giro := 0.0
var iniciado := false

func _ready():
	z_index = 4
	var sprite = Sprite2D.new()
	sprite.texture = TEXTURA
	add_child(sprite)

	impulso_horizontal = randf_range(-26.0, 26.0)
	giro = randf_range(-2.8, 2.8)
	scale = Vector2(0.18, 0.18)
	set_process(false)

func iniciar(destino: Vector2):
	origen_global = global_position
	punto_de_salida = origen_global + Vector2(impulso_horizontal, 18.0)
	destino_global = destino
	iniciado = true
	set_process(true)

func _process(delta):
	if not iniciado:
		return

	tiempo += delta

	if tiempo <= TIEMPO_EN_EL_SUELO:
		_animar_caida(delta)
		return

	_animar_vuelo(delta)

func _animar_caida(delta: float):
	var progreso = clampf(tiempo / TIEMPO_EN_EL_SUELO, 0.0, 1.0)
	var arco = sin(progreso * PI) * 48.0
	global_position = origen_global.lerp(punto_de_salida, progreso) - Vector2(0.0, arco)
	rotation += giro * delta
	var aparicion = minf(progreso / 0.22, 1.0)
	scale = Vector2.ONE * lerpf(0.18, ESCALA_OBJETO, aparicion)

func _animar_vuelo(delta: float):
	var progreso = clampf((tiempo - TIEMPO_EN_EL_SUELO) / DURACION_VUELO, 0.0, 1.0)
	var suavizado = progreso * progreso * (3.0 - 2.0 * progreso)
	var arco = sin(progreso * PI) * 70.0
	global_position = punto_de_salida.lerp(destino_global, suavizado) - Vector2(0.0, arco)
	rotation += giro * 2.4 * delta
	scale = Vector2.ONE * lerpf(ESCALA_OBJETO, 0.28, suavizado)

	if progreso >= 1.0:
		llego_al_contador.emit()
		queue_free()
