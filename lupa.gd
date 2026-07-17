extends Area2D

const ORIGEN_RAYO := Vector2(32, 19)
const VECTOR_RAYO := Vector2(0, 120)
const PUNTO_IMPACTO := ORIGEN_RAYO + VECTOR_RAYO
const DISTANCIA_ENTRE_MARCAS := 16.0
const MarcaQuemada = preload("res://marca_quemada.gd")

@export var dano_por_segundo := 45.0
@export var dano_ardor_por_segundo := 18.0
@export var duracion_ardor := 2.5

@onready var rayo_visual: Polygon2D = $RayoVisual

var objetivo_global := Vector2.ZERO
var ultima_marca := Vector2.ZERO
var tiene_ultima_marca := false
var tiempo := 0.0

func _ready():
	# La lupa queda fija y el rayo detecta solo hormigas de la capa 2.
	collision_layer = 4
	collision_mask = 2
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	objetivo_global = get_global_mouse_position()
	_actualizar_lupa_y_rayo()
	queue_redraw()

func _exit_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	tiempo += delta
	objetivo_global = get_global_mouse_position()
	_actualizar_lupa_y_rayo()
	_dejar_rastro(objetivo_global)

	for cuerpo in get_overlapping_bodies():
		_aplicar_calor(cuerpo, dano_por_segundo * delta)

	queue_redraw()

func _actualizar_lupa_y_rayo():
	# La punta queda sobre el mouse; la lupa y el rayo se trasladan juntos.
	global_position = objetivo_global - PUNTO_IMPACTO

	var direccion = VECTOR_RAYO.normalized()
	var perpendicular = Vector2(-direccion.y, direccion.x)
	var pulso = 0.5 + 0.5 * sin(tiempo * 16.0)
	var ancho_inicio = 6.0 + pulso * 2.0
	var ancho_impacto = 10.0 + pulso * 3.0
	var puntos = PackedVector2Array([
		ORIGEN_RAYO + perpendicular * ancho_inicio,
		ORIGEN_RAYO - perpendicular * ancho_inicio,
		PUNTO_IMPACTO - perpendicular * ancho_impacto,
		PUNTO_IMPACTO + perpendicular * ancho_impacto
	])

	rayo_visual.polygon = puntos
	rayo_visual.color = Color(1.0, 0.75, 0.16, 0.23 + pulso * 0.10)

func _dejar_rastro(posicion: Vector2):
	if not tiene_ultima_marca:
		tiene_ultima_marca = true
		ultima_marca = posicion
		_crear_marca(posicion)
		return

	while ultima_marca.distance_to(posicion) >= DISTANCIA_ENTRE_MARCAS:
		ultima_marca = ultima_marca.move_toward(posicion, DISTANCIA_ENTRE_MARCAS)
		_crear_marca(ultima_marca)

func _crear_marca(posicion: Vector2):
	var marca = MarcaQuemada.new()
	get_parent().add_child(marca)
	marca.global_position = posicion

func _aplicar_calor(cuerpo: Node2D, dano: float):
	if cuerpo.is_in_group("hormiga") and cuerpo.has_method("recibir_dano"):
		cuerpo.recibir_dano(dano)

		if cuerpo.has_method("aplicar_quemadura"):
			cuerpo.aplicar_quemadura(duracion_ardor, dano_ardor_por_segundo)

func _draw():
	var pulso = 0.5 + 0.5 * sin(tiempo * 20.0)
	var radio = 9.0 + pulso * 4.0

	# El centro de este destello coincide exactamente con el mouse.
	draw_circle(PUNTO_IMPACTO, radio, Color(1.0, 0.48, 0.05, 0.28))
	draw_circle(PUNTO_IMPACTO, 4.0 + pulso * 2.0, Color(1.0, 0.95, 0.55, 0.88))
	draw_arc(PUNTO_IMPACTO, radio + 4.0, 0.0, TAU, 24, Color(1.0, 0.8, 0.25, 0.52), 2.0, true)
