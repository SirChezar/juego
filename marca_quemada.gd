extends Node2D

const DURACION := 3.5

var tiempo_restante := DURACION
var chispas: Array[Dictionary] = []

func _ready():
	z_index = 0
	rotation = randf_range(0.0, TAU)
	for indice in 8:
		chispas.append({
			"posicion": Vector2(randf_range(-13.0, 13.0), randf_range(-13.0, 13.0)),
			"radio": randf_range(1.5, 4.0)
		})
	queue_redraw()

func _process(delta):
	tiempo_restante -= delta
	modulate.a = maxf(tiempo_restante / DURACION, 0.0)

	if tiempo_restante <= 0.0:
		queue_free()

func _draw():
	draw_circle(Vector2.ZERO, 14.0, Color(0.13, 0.06, 0.02, 0.48))
	draw_circle(Vector2.ZERO, 8.0, Color(0.05, 0.025, 0.01, 0.55))

	for chispa in chispas:
		draw_circle(chispa.posicion, chispa.radio, Color(0.25, 0.1, 0.025, 0.55))
