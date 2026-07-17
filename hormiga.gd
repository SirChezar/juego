extends CharacterBody2D

signal muerta(posicion_global: Vector2, volteada: bool)

@export var velocidad := 120.0
@export var vida_maxima := 100.0

const BARRA_POSICION := Vector2(-5, -12)
const BARRA_TAMANO := Vector2(42, 6)

var direccion := Vector2.RIGHT
var tiempo_para_cambiar := 0.0
var vida_actual := 100.0
var tiempo_ardiendo := 0.0
var dano_ardor_por_segundo := 0.0
var tiempo_animacion := 0.0

@onready var sprite: AnimatedSprite2D = $Sprite2D
@onready var llamas = $Llamas

func _ready():
	collision_layer = 2
	collision_mask = 1
	vida_actual = vida_maxima
	llamas.activar(false)
	elegir_direccion()
	queue_redraw()

func _physics_process(delta):
	tiempo_animacion += delta
	tiempo_para_cambiar -= delta

	if tiempo_para_cambiar <= 0:
		elegir_direccion()

	velocity = direccion * velocidad
	sprite.flip_h = direccion.x > 0.0
	move_and_slide()

	# Si chocó con una pared, se aleja en otra dirección.
	if get_slide_collision_count() > 0:
		cambiar_direccion_por_choque()

	if tiempo_ardiendo > 0.0:
		tiempo_ardiendo -= delta
		recibir_dano(dano_ardor_por_segundo * delta)
		_actualizar_aspecto_ardiendo()
	else:
		sprite.rotation = 0.0
		llamas.activar(false)
		_actualizar_color()

	queue_redraw()

func elegir_direccion():
	direccion = Vector2.RIGHT.rotated(randf() * TAU)
	tiempo_para_cambiar = randf_range(2.0, 4.0)

func cambiar_direccion_por_choque():
	direccion = (-direccion).rotated(randf_range(-1.0, 1.0))
	tiempo_para_cambiar = randf_range(2.0, 4.0)

func recibir_dano(cantidad: float):
	if vida_actual <= 0.0:
		return

	vida_actual = maxf(vida_actual - cantidad, 0.0)
	_actualizar_color()

	if vida_actual <= 0.0:
		muerta.emit(global_position, sprite.flip_h)
		queue_free()

func aplicar_quemadura(duracion: float, dano_por_segundo: float):
	tiempo_ardiendo = maxf(tiempo_ardiendo, duracion)
	dano_ardor_por_segundo = maxf(dano_ardor_por_segundo, dano_por_segundo)
	llamas.activar(true)

func _actualizar_color():
	var porcentaje_vida = vida_actual / vida_maxima
	var color_base = Color(1.0, 0.35 + 0.65 * porcentaje_vida, 0.35 + 0.65 * porcentaje_vida)

	if tiempo_ardiendo > 0.0:
		var pulso = 0.45 + 0.35 * (sin(tiempo_animacion * 20.0) + 1.0) * 0.5
		sprite.modulate = color_base.lerp(Color(1.0, 0.2, 0.02), pulso)
	else:
		sprite.modulate = color_base

func _actualizar_aspecto_ardiendo():
	_actualizar_color()
	sprite.rotation = sin(tiempo_animacion * 26.0) * 0.06

func _draw():
	var porcentaje_vida = vida_actual / vida_maxima
	var color_vida = Color(1.0 - porcentaje_vida, porcentaje_vida, 0.1)

	# Fondo, relleno y borde de la barra de vida.
	draw_rect(Rect2(BARRA_POSICION, BARRA_TAMANO), Color("#2a1b16"))
	draw_rect(Rect2(BARRA_POSICION, Vector2(BARRA_TAMANO.x * porcentaje_vida, BARRA_TAMANO.y)), color_vida)
	draw_rect(Rect2(BARRA_POSICION, BARRA_TAMANO), Color("#f5e4b9"), false, 1.0)
