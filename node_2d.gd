extends Node2D

const Caramelo = preload("res://caramelo.gd")

@export var escena_hormiga: PackedScene
@export var cantidad_total := 15
@export var duracion := 30.0
@export var zona_de_aparicion := Rect2(100, 100, 800, 450)

@onready var aviso_aparicion: AnimatedSprite2D = $AvisoAparicion
@onready var contador_caramelos: Label = $Interfaz/ContadorCaramelos/Contenido/Etiqueta
@onready var icono_caramelo: TextureRect = $Interfaz/ContadorCaramelos/Contenido/Icono
@onready var contenido_contador: HBoxContainer = $Interfaz/ContadorCaramelos/Contenido

var hormigas_creadas := 0
var caramelos := 0
var contador := 0.0
var intervalo := 1.0
var anuncio_en_proceso := false
var posicion_pendiente := Vector2.ZERO

func _ready():
	_actualizar_contador_caramelos()
	for hormiga in get_tree().get_nodes_in_group("hormiga"):
		_registrar_hormiga(hormiga)

	if cantidad_total <= 0:
		return

	intervalo = duracion / cantidad_total
	aviso_aparicion.animation_finished.connect(_al_terminar_aviso)

func _process(delta):
	if hormigas_creadas >= cantidad_total or anuncio_en_proceso:
		return

	contador += delta

	if contador >= intervalo:
		contador -= intervalo
		anunciar_aparicion()

func anunciar_aparicion():
	posicion_pendiente = Vector2(
		randf_range(zona_de_aparicion.position.x, zona_de_aparicion.end.x),
		randf_range(zona_de_aparicion.position.y, zona_de_aparicion.end.y)
	)

	anuncio_en_proceso = true
	aviso_aparicion.global_position = posicion_pendiente
	aviso_aparicion.visible = true
	aviso_aparicion.play("aviso")

func _al_terminar_aviso():
	crear_hormiga(posicion_pendiente)

	# Mantiene el último fotograma visible un instante, detrás de la hormiga.
	await get_tree().create_timer(0.15).timeout
	aviso_aparicion.visible = false
	anuncio_en_proceso = false

func crear_hormiga(posicion: Vector2):
	var hormiga = escena_hormiga.instantiate() as CharacterBody2D
	if hormiga == null:
		return

	hormiga.global_position = posicion
	add_child(hormiga)
	_registrar_hormiga(hormiga)
	hormigas_creadas += 1

func _registrar_hormiga(hormiga: Node):
	if not hormiga.has_signal("muerta"):
		return

	var callable = Callable(self, "_al_morir_hormiga")
	if not hormiga.is_connected("muerta", callable):
		hormiga.connect("muerta", callable)

func _al_morir_hormiga(posicion_global: Vector2):
	var caramelo = Caramelo.new()
	add_child(caramelo)
	caramelo.global_position = posicion_global
	caramelo.llego_al_contador.connect(_al_llegar_caramelo)
	caramelo.iniciar(icono_caramelo.get_global_rect().get_center())

func _al_llegar_caramelo():
	caramelos += 1
	_actualizar_contador_caramelos()
	_animar_contador()

func _actualizar_contador_caramelos():
	contador_caramelos.text = str(caramelos)

func _animar_contador():
	contenido_contador.pivot_offset = contenido_contador.size * 0.5
	contenido_contador.scale = Vector2(1.2, 1.2)
	var animacion = create_tween()
	animacion.tween_property(contenido_contador, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
