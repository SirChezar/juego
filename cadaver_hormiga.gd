extends Node2D

const TEXTURA = preload("res://hormiga_calcinada.png")
const TIEMPO_VISIBLE := 2.5
const TIEMPO_DESVANECIENDO := 1.0

var volteado := false
var tiempo := 0.0
var sprite: Sprite2D

func _ready():
	z_index = 2
	sprite = Sprite2D.new()
	sprite.texture = TEXTURA
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.position = Vector2(16.0, 40.0)
	sprite.scale = Vector2(0.1, 0.1)
	sprite.flip_h = volteado
	add_child(sprite)

func _process(delta):
	tiempo += delta

	# Durante el primer instante conserva un brillo rojizo y luego se enfría.
	if tiempo < 0.45:
		var enfriamiento = tiempo / 0.45
		sprite.modulate = Color(1.25, 0.72, 0.52).lerp(Color.WHITE, enfriamiento)
	else:
		sprite.modulate = Color.WHITE

	if tiempo > TIEMPO_VISIBLE:
		var progreso = (tiempo - TIEMPO_VISIBLE) / TIEMPO_DESVANECIENDO
		modulate.a = 1.0 - clampf(progreso, 0.0, 1.0)

	if tiempo >= TIEMPO_VISIBLE + TIEMPO_DESVANECIENDO:
		queue_free()
