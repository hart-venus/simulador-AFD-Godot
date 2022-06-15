extends Node2D
onready var entradaTexto = $Entradas
var entradas = ''
var apuntandoHacia = -1

func _ready():
	entradaTexto.text = entradas
	if get_parent().get_parent() == apuntandoHacia:
		$Flecha.hide()
		$Flecha2.show()
		$Entradas.rect_position.y = -242
func _physics_process(delta):
	var distancia = apuntandoHacia.global_position - get_parent().get_parent().global_position
	var distancia_rot = acos((distancia).normalized().x)
	if distancia.y < 0:
		distancia_rot *= -1
	$Flecha.rotation = distancia_rot
	position = distancia/3
