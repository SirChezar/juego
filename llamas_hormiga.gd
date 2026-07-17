extends Node2D

const CANTIDAD_LLAMAS := 10

var activas := false
var tiempo := 0.0
var llamas: Array[Dictionary] = []

func _ready():
	visible = false
	set_process(false)

func activar(valor: bool):
	if activas == valor:
		return

	activas = valor
	visible = valor
	set_process(valor)

	if valor:
		llamas.clear()
		for indice in CANTIDAD_LLAMAS:
			llamas.append(_crear_llama(true))

	queue_redraw()

func _process(delta):
	tiempo += delta

	for indice in llamas.size():
		var llama = llamas[indice]
		var posicion: Vector2 = llama["posicion"]
		var velocidad: float = llama["velocidad"]
		var fase: float = llama["fase"]

		posicion.y -= velocidad * delta
		posicion.x += sin(tiempo * 12.0 + fase) * 9.0 * delta
		llama["posicion"] = posicion
		llama["vida"] = float(llama["vida"]) - delta

		if float(llama["vida"]) <= 0.0:
			llama = _crear_llama(false)

		llamas[indice] = llama

	queue_redraw()

func _crear_llama(distribuir: bool) -> Dictionary:
	var duracion = randf_range(0.35, 0.75)
	var velocidad = randf_range(28.0, 52.0)
	var edad = randf_range(0.0, duracion) if distribuir else 0.0

	return {
		"posicion": Vector2(randf_range(-15.0, 15.0), randf_range(-3.0, 6.0) - velocidad * edad),
		"velocidad": velocidad,
		"fase": randf_range(0.0, TAU),
		"radio": randf_range(3.5, 7.0),
		"duracion": duracion,
		"vida": duracion - edad
	}

func _draw():
	if not activas:
		return

	for llama in llamas:
		var posicion: Vector2 = llama["posicion"]
		var radio: float = llama["radio"]
		var vida = clampf(float(llama["vida"]) / float(llama["duracion"]), 0.0, 1.0)
		var pulso = 0.78 + 0.22 * sin(tiempo * 18.0 + float(llama["fase"]))

		# Halo rojo, cuerpo naranja y punta amarilla de cada llama.
		draw_circle(posicion, radio * 1.45 * pulso, Color(1.0, 0.12, 0.01, 0.28 * vida))
		draw_circle(posicion, radio * pulso, Color(1.0, 0.38, 0.02, 0.82 * vida))
		draw_circle(posicion + Vector2(0, -radio * 0.75), radio * 0.58, Color(1.0, 0.88, 0.18, 0.90 * vida))
