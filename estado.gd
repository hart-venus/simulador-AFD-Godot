extends Node2D
var activo = false
var inicial = false
var vinculos = {}
var mouse = false
var aceptacion = false
var recienCreado = true
onready var nombre = $nombre
onready var ini_ui = $PopupMenu/ini
var flecha = preload("res://vinculo.tscn")

func _ready():
	nombre.text = 'q' + str(len(global.listaEstados))
	modulate.a = 0.4

func _physics_process(delta):
	if not activo:
		position = get_viewport().get_mouse_position()
		if Input.is_action_just_pressed("click"):
			activo = true
			recienCreado = false
			modulate.a = 1
		elif Input.is_action_just_released("click") and not recienCreado:
			activo = true
	elif Input.is_action_just_pressed("click") and mouse:
		activo = false
	elif Input.is_action_just_pressed("rclick") and mouse:
		$PopupMenu.popup_centered()

func _on_area_mouse_entered():
	mouse = true
func _on_area_mouse_exited():
	mouse = false

func _on_Button_pressed(): # Borrar Nodo
	# Actualizar nombres
	global.listaEstados.erase(self)
	var i = 0
	for estado in global.listaEstados:
		estado.nombre.text = 'q' + str(i)
		i+=1
	# Actualizar vinculos
	for estado in global.listaEstados:
		for vinculo in estado.vinculos.keys():
			if estado.vinculos[vinculo] == self:
				estado.vinculos.erase(vinculo)
		estado.renderizarVinculos()
	queue_free()

func _on_acep_toggled(button_pressed):
	# Estado de aceptacion
	aceptacion = button_pressed
	if aceptacion:
		$acep.show()
	else:
		$acep.hide()

func _on_ini_toggled(button_pressed):
	# Estado inicial
	inicial = button_pressed
	if inicial:
		for estado in global.listaEstados:
			if estado.nombre != self.nombre:
				estado.inicial = false
				estado.ini_ui.pressed = false
		$ini.show()
	else:
		$ini.hide()

func renderizarVinculos():
	# Borrar flechas
	var nodosViejos = $vinculos.get_children()
	for flecha in $vinculos.get_children():
		flecha.queue_free()
	for vinculo in vinculos.keys():
		var duplicada = false
		# Revisa si se ha vinculado al nodo con otra llave
		for flecha in $vinculos.get_children():
			if flecha in nodosViejos:
				continue
			if flecha.apuntandoHacia == vinculos[vinculo]:
				flecha.entradaTexto.text += vinculo
				duplicada = true
				break
		if duplicada:
			continue
		var nuevaFlecha = flecha.instance()
		nuevaFlecha.entradas = vinculo
		nuevaFlecha.apuntandoHacia = vinculos[vinculo]
		$vinculos.add_child(nuevaFlecha)
