extends Control
var estado = preload('res://estado.tscn')
export var colorPrincipal = Color()
func _ready():
	pass # Replace with function body.

func _on_generarEstado_pressed():
	var nuevoEstado = estado.instance()
	get_parent().add_child(nuevoEstado)
	global.listaEstados.append(nuevoEstado)

func _on_Button_pressed():
	$PopupMenu.popup_centered()
	# Limpiar
	$PopupMenu/entradas.text = ''
	# Anadir opciones de vinculo
	var i = 0
	for menu in [$PopupMenu/opcionDe, $PopupMenu/opcionA]:
		menu.clear()
		for estado in global.listaEstados:
			menu.add_item(estado.nombre.text, i)
			i += 1

func crearVinculo(nodoDe, nodoA, entradas):
	for letra in entradas:
		nodoDe.vinculos[letra] = nodoA
	nodoDe.renderizarVinculos()

func aviso(msg):
	$Aviso/Label.text = msg
	$Aviso.popup_centered()

func _on_generarBoton_pressed():
	if ($PopupMenu/opcionDe.selected == -1) or ($PopupMenu/opcionA.selected == -1):
		aviso('Debe especificar ambos nodos.')
		return
	if $PopupMenu/entradas.text == '':
		aviso('Entrada debe ser no vacia.')
		return
	var nodoDe = global.listaEstados[$PopupMenu/opcionDe.selected]
	var nodoA = global.listaEstados[$PopupMenu/opcionA.selected]
	
	for letra in $PopupMenu/entradas.text:
		if not letra in $LineEdit.text:
			aviso('Cada letra de la entrada debe estar en el \nalfabeto.')
			return
		if letra in nodoDe.vinculos:
			aviso('El nodo De ya tiene una vinculo con esa letra.')
			return
	aviso('Vinculo creado exitosamente.')
	crearVinculo(nodoDe, nodoA, $PopupMenu/entradas.text)
	$PopupMenu.hide()


func _on_LineEdit_text_changed(new_text):
	for estado in global.listaEstados:
		for vinculo in estado.vinculos.keys():
			if not (vinculo in new_text):
				estado.vinculos.erase(vinculo)
				estado.renderizarVinculos()

func correrAFD(estado, entrada):
	for caracter in entrada:
		estado.modulate = colorPrincipal
		var t = Timer.new()
		t.set_wait_time(0.5)
		t.set_one_shot(true)
		self.add_child(t)
		t.start()
		yield(t, "timeout")
		estado.modulate = Color(1,1,1)
		estado = estado.vinculos[caracter]
		t.queue_free()
	estado.modulate = colorPrincipal
	var t = Timer.new()
	t.set_wait_time(0.5)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	estado.modulate = Color(1,1,1)
	# Estado final
	if estado.aceptacion:
		aviso('La entrada es aceptada por el AFD')
	else:
		aviso('La entrada no es aceptada por el AFD.')
func _on_Button2_pressed():
	# Check de si la entrada es valida
	if $entrada.text == '':
		aviso('Entrada debe ser no vacia.')
		return 
	for letra in $entrada.text:
		if not (letra in $LineEdit.text):
			aviso('El alfabeto no tiene ' + letra)
			return
	# Check de si es determinista
	for letra in $LineEdit.text:
		for estado in global.listaEstados:
			if not (letra in estado.vinculos.keys()):
				aviso(estado.nombre.text + ' no tiene vinculo para ' + letra)
				return
	# Check de que tenga primer estado
	var primerEstado = false
	for estado in global.listaEstados:
		if estado.inicial:
			primerEstado = estado
			break
	if (not primerEstado):
		aviso('Debe existir un estado inicial')
		return
	correrAFD(primerEstado, $entrada.text)
