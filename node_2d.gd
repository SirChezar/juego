extends Node2D

@export var escena_hormiga: PackedScene
@export var cantidad_total := 15
@export var duracion := 30.0
@export var zona_de_aparicion := Rect2(100, 100, 800, 450)

@onready var aviso_aparicion: AnimatedSprite2D = $AvisoAparicion

var hormigas_creadas := 0
var contador := 0.0
var intervalo := 1.0
var anuncio_en_proceso := false
var posicion_pendiente := Vector2.ZERO

func _ready():
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
	hormigas_creadas += 1
